From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v17 08/15] seccomp: add system call filtering using BPF
Date: Fri, 6 Apr 2012 13:23:30 -0700
Message-ID: <20120406132330.457a05cf.akpm@linux-foundation.org>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
	<1333051320-30872-9-git-send-email-wad@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
	corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org, jmorris@namei.org
To: Will Drewry <wad@chromium.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1333051320-30872-9-git-send-email-wad@chromium.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 29 Mar 2012 15:01:53 -0500
Will Drewry <wad@chromium.org> wrote:

> [This patch depends on luto@mit.edu's no_new_privs patch:
>    https://lkml.org/lkml/2012/1/30/264
>  included in this series for ease of consumption.
> ]
> 
> This patch adds support for seccomp mode 2.  Mode 2 introduces the
> ability for unprivileged processes to install system call filtering
> policy expressed in terms of a Berkeley Packet Filter (BPF) program.
> This program will be evaluated in the kernel for each system call
> the task makes and computes a result based on data in the format
> of struct seccomp_data.
> 
> A filter program may be installed by calling:
>   struct sock_fprog fprog = { ... };
>   ...
>   prctl(PR_SET_SECCOMP, SECCOMP_MODE_FILTER, &fprog);
> 
> The return value of the filter program determines if the system call is
> allowed to proceed or denied.  If the first filter program installed
> allows prctl(2) calls, then the above call may be made repeatedly
> by a task to further reduce its access to the kernel.  All attached
> programs must be evaluated before a system call will be allowed to
> proceed.
> 
> Filter programs will be inherited across fork/clone and execve.
> However, if the task attaching the filter is unprivileged
> (!CAP_SYS_ADMIN) the no_new_privs bit will be set on the task.  This
> ensures that unprivileged tasks cannot attach filters that affect
> privileged tasks (e.g., setuid binary).
> 
> There are a number of benefits to this approach. A few of which are
> as follows:
> - BPF has been exposed to userland for a long time
> - BPF optimization (and JIT'ing) are well understood
> - Userland already knows its ABI: system call numbers and desired
>   arguments
> - No time-of-check-time-of-use vulnerable data accesses are possible.
> - system call arguments are loaded on access only to minimize copying
>   required for system call policy decisions.
> 
> Mode 2 support is restricted to architectures that enable
> HAVE_ARCH_SECCOMP_FILTER.  In this patch, the primary dependency is on
> syscall_get_arguments().  The full desired scope of this feature will
> add a few minor additional requirements expressed later in this series.
> Based on discussion, SECCOMP_RET_ERRNO and SECCOMP_RET_TRACE seem to be
> the desired additional functionality.
> 
> No architectures are enabled in this patch.
> 
>
> ...
>
> +/**
> + * struct seccomp_filter - container for seccomp BPF programs
> + *
> + * @usage: reference count to manage the object liftime.

i found a bug

> + *         get/put helpers should be used when accessing an instance
> + *         outside of a lifetime-guarded section.  In general, this
> + *         is only needed for handling filters shared across tasks.
> + * @prev: points to a previously installed, or inherited, filter
> + * @len: the number of instructions in the program
> + * @insns: the BPF program instructions to evaluate
> + *
> + * seccomp_filter objects are organized in a tree linked via the @prev
> + * pointer.  For any task, it appears to be a singly-linked list starting
> + * with current->seccomp.filter, the most recently attached or inherited filter.
> + * However, multiple filters may share a @prev node, by way of fork(), which
> + * results in a unidirectional tree existing in memory.  This is similar to
> + * how namespaces work.
> + *
> + * seccomp_filter objects should never be modified after being attached
> + * to a task_struct (other than @usage).
> + */
> +struct seccomp_filter {
> +	atomic_t usage;
> +	struct seccomp_filter *prev;
> +	unsigned short len;  /* Instruction count */
> +	struct sock_filter insns[];
> +};
> +
> +/* Limit any path through the tree to 256KB worth of instructions. */
> +#define MAX_INSNS_PER_PATH ((1 << 18) / sizeof(struct sock_filter))
> +
> +static void seccomp_filter_log_failure(int syscall)
> +{
> +	int compat = 0;
> +#ifdef CONFIG_COMPAT
> +	compat = is_compat_task();
> +#endif

hm, I'm surprised that we don't have a zero-returning implementation of
is_compat_task() when CONFIG_COMPAT=n.  Seems silly.  Blames Arnd.

> +	pr_info("%s[%d]: %ssystem call %d blocked at 0x%lx\n",
> +		current->comm, task_pid_nr(current),
> +		(compat ? "compat " : ""),
> +		syscall, KSTK_EIP(current));
> +}
> +
> +/**
> + * get_u32 - returns a u32 offset into data
> + * @data: a unsigned 64 bit value
> + * @index: 0 or 1 to return the first or second 32-bits
> + *
> + * This inline exists to hide the length of unsigned long.
> + * If a 32-bit unsigned long is passed in, it will be extended
> + * and the top 32-bits will be 0. If it is a 64-bit unsigned
> + * long, then whatever data is resident will be properly returned.
> + */
> +static inline u32 get_u32(u64 data, int index)
> +{
> +	return ((u32 *)&data)[index];
> +}

This seems utterly broken on big-endian machines.  If so: fix.  If not:
add comment explaining why?

>
> ...
>
> +/**
> + *	seccomp_chk_filter - verify seccomp filter code
> + *	@filter: filter to verify
> + *	@flen: length of filter
> + *
> + * Takes a previously checked filter (by sk_chk_filter) and
> + * redirects all filter code that loads struct sk_buff data
> + * and related data through seccomp_bpf_load.  It also
> + * enforces length and alignment checking of those loads.
> + *
> + * Returns 0 if the rule set is legal or -EINVAL if not.
> + */
> +static int seccomp_chk_filter(struct sock_filter *filter, unsigned int flen)
> +{
> +	int pc;
> +	for (pc = 0; pc < flen; pc++) {
> +		struct sock_filter *ftest = &filter[pc];
> +		u16 code = ftest->code;
> +		u32 k = ftest->k;
> +		switch (code) {

It's conventional to have a blank line between end-of-locals and
start-of-code.


> +		case BPF_S_LD_W_ABS:
> +			ftest->code = BPF_S_ANC_SECCOMP_LD_W;
> +			/* 32-bit aligned and not out of bounds. */
> +			if (k >= sizeof(struct seccomp_data) || k & 3)
> +				return -EINVAL;
>
> ...
>
> +static u32 seccomp_run_filters(int syscall)
> +{
> +	struct seccomp_filter *f;
> +	u32 ret = SECCOMP_RET_KILL;
> +	/*
> +	 * All filters are evaluated in order of youngest to oldest. The lowest
> +	 * BPF return value always takes priority.
> +	 */

The youngest-first design surprised me.  It wasn't mentioned at all in
the changelog.  Thinking about it, I guess it just doesn't matter.  But
some description of the reasons for and implications of this decision
for the uninitiated would be welcome.

> +	for (f = current->seccomp.filter; f; f = f->prev) {
> +		ret = sk_run_filter(NULL, f->insns);
> +		if (ret != SECCOMP_RET_ALLOW)
> +			break;
> +	}
> +	return ret;
> +}
> +
> +/**
> + * seccomp_attach_filter: Attaches a seccomp filter to current.
> + * @fprog: BPF program to install
> + *
> + * Returns 0 on success or an errno on failure.
> + */
> +static long seccomp_attach_filter(struct sock_fprog *fprog)
> +{
> +	struct seccomp_filter *filter;
> +	unsigned long fp_size = fprog->len * sizeof(struct sock_filter);
> +	unsigned long total_insns = fprog->len;
> +	long ret;
> +
> +	if (fprog->len == 0 || fprog->len > BPF_MAXINSNS)
> +		return -EINVAL;
> +
> +	for (filter = current->seccomp.filter; filter; filter = filter->prev)
> +		total_insns += filter->len + 4;  /* include a 4 instr penalty */

So tasks don't share filters?  We copy them by value at fork?  Do we do
this at vfork() too?

> +	if (total_insns > MAX_INSNS_PER_PATH)
> +		return -ENOMEM;
> +
> +	/*
> +	 * Installing a seccomp filter requires that the task have
> +	 * CAP_SYS_ADMIN in its namespace or be running with no_new_privs.
> +	 * This avoids scenarios where unprivileged tasks can affect the
> +	 * behavior of privileged children.
> +	 */
> +	if (!current->no_new_privs &&
> +	    security_capable_noaudit(current_cred(), current_user_ns(),
> +				     CAP_SYS_ADMIN) != 0)
> +		return -EACCES;
> +
> +	/* Allocate a new seccomp_filter */
> +	filter = kzalloc(sizeof(struct seccomp_filter) + fp_size, GFP_KERNEL);

I think this gives userspace an easy way of causing page allocation
failure warnings, by permitting large kmalloc() attempts.  Add
__GFP_NOWARN?

> +	if (!filter)
> +		return -ENOMEM;
> +	atomic_set(&filter->usage, 1);
> +	filter->len = fprog->len;
> +
> +	/* Copy the instructions from fprog. */
> +	ret = -EFAULT;
> +	if (copy_from_user(filter->insns, fprog->filter, fp_size))
> +		goto fail;
> +
> +	/* Check and rewrite the fprog via the skb checker */
> +	ret = sk_chk_filter(filter->insns, filter->len);
> +	if (ret)
> +		goto fail;
> +
> +	/* Check and rewrite the fprog for seccomp use */
> +	ret = seccomp_chk_filter(filter->insns, filter->len);

"check" is spelled "check"!

> +	if (ret)
> +		goto fail;
> +
> +	/*
> +	 * If there is an existing filter, make it the prev and don't drop its
> +	 * task reference.
> +	 */
> +	filter->prev = current->seccomp.filter;
> +	current->seccomp.filter = filter;
> +	return 0;
> +fail:
> +	kfree(filter);
> +	return ret;
> +}
> +
>
> ...
>
> +/* put_seccomp_filter - decrements the ref count of tsk->seccomp.filter */
> +void put_seccomp_filter(struct task_struct *tsk)
> +{
> +	struct seccomp_filter *orig = tsk->seccomp.filter;
> +	/* Clean up single-reference branches iteratively. */
> +	while (orig && atomic_dec_and_test(&orig->usage)) {
> +		struct seccomp_filter *freeme = orig;
> +		orig = orig->prev;
> +		kfree(freeme);
> +	}
> +}

So if one of the filters in the list has an elevated refcount, we bail
out on the remainder of the list.  Seems odd.

> +#endif	/* CONFIG_SECCOMP_FILTER */
>
> ...
>

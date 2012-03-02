From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: [PATCH v12 06/13] seccomp: add system call filtering using BPF
Date: Fri, 2 Mar 2012 06:45:20 +0100
Message-ID: <a6fdbe9d1daf6864589c9affc7048965.squirrel@webmail.greenhost.nl>
References: <1330559620-23543-1-git-send-email-wad@chromium.org>
    <1330559620-23543-6-git-send-email-wad@chromium.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org,
 linux-arch@vger.kernel.org,
 linux-doc@vger.kernel.org,
 kernel-hardening@lists.openwall.com,
 netdev@vger.kernel.org,
 x86@kernel.org,
 arnd@arndb.de,
 davem@davemloft.net,
 hpa@zytor.com,
 mingo@redhat.com,
 oleg@redhat.com,
 peterz@infradead.org,
 rdunlap@xenotime.net,
 mcgrathr@chromium.org,
 tglx@linutronix.de,
 luto@mit.edu,
 eparis@redhat.com,
 serge.hallyn@canonical.com,
 djm@mindrot.org,
 scarybeasts@gmail.com,
 pmoore@redhat.com,
 akpm@linux-foundation.org,
 corbet@lwn.net,
 eric.dumazet@gmail.com,
 markus@chromium.org,
 coreyb@linux.vnet.ibm.com,
 keescook@chromium.org,
 "Will Drewry" <wad@chromium.org>
To: "Will Drewry" <wad@chromium.org>
Return-path: <kernel-hardening-return-1028-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1330559620-23543-6-git-send-email-wad@chromium.org>
List-Id: netdev.vger.kernel.org

Hello,

Mostly minor nitpicks.

On Thu, March 1, 2012 00:53, Will Drewry wrote:
> diff --git a/arch/Kconfig b/arch/Kconfig
> index e5d3778..7a696a9 100644
> --- a/arch/Kconfig
> +++ b/arch/Kconfig
> @@ -233,4 +233,21 @@ config HAVE_CMPXCHG_DOUBLE
> config ARCH_WANT_OLD_COMPAT_IPC
> 	bool
>
> +config HAVE_ARCH_SECCOMP_FILTER
> +	bool
> +	help
> +	  This symbol should be selected by an architecure if it provides

'architecture'

> +	  asm/syscall.h, specifically syscall_get_arguments() and
> +	  syscall_get_arch().
> +
> +config SECCOMP_FILTER
> +	def_bool y
> +	depends on HAVE_ARCH_SECCOMP_FILTER && SECCOMP && NET
> +	help
> +	  Enable tasks to build secure computing environments defined
> +	  in terms of Berkeley Packet Filter programs which implement
> +	  task-defined system call filtering polices.
> +
> +	  See Documentation/prctl/seccomp_filter.txt for details.
> +
> source "kernel/gcov/Kconfig"
> diff --git a/include/linux/Kbuild b/include/linux/Kbuild
> index ecd0afb..b1e6a74 100644
> --- a/include/linux/Kbuild
> +++ b/include/linux/Kbuild
> @@ -332,6 +332,7 @@ header-y += scc.h
> header-y += sched.h
> header-y += screen_info.h
> header-y += sdla.h
> +header-y += seccomp.h
> header-y += securebits.h
> header-y += selinux_netlink.h
> header-y += sem.h
> diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
> index d61f27f..6ef133c 100644
> --- a/include/linux/seccomp.h
> +++ b/include/linux/seccomp.h
> @@ -1,14 +1,67 @@
> #ifndef _LINUX_SECCOMP_H
> #define _LINUX_SECCOMP_H
>
> +#include <linux/compiler.h>
> +#include <linux/types.h>
> +
> +
> +/* Valid values for seccomp.mode and prctl(PR_SET_SECCOMP, <mode>) */
> +#define SECCOMP_MODE_DISABLED	0 /* seccomp is not in use. */
> +#define SECCOMP_MODE_STRICT	1 /* uses hard-coded filter. */
> +#define SECCOMP_MODE_FILTER	2 /* uses user-supplied filter. */

I'd add a space or tab to align the numbers, or rename DISABLED to NONE,
but that's just me I guess.

> +
> +/*
> + * All BPF programs must return a 32-bit value.
> + * The bottom 16-bits are reserved for future use.
> + * The upper 16-bits are ordered from least permissive values to most.
> + *
> + * The ordering ensures that a min_t() over composed return values always
> + * selects the least permissive choice.
> + */
> +#define SECCOMP_RET_KILL	0x00000000U /* kill the task immediately */
> +#define SECCOMP_RET_ALLOW	0x7fff0000U /* allow */
> +
> +/* Masks for the return value sections. */
> +#define SECCOMP_RET_ACTION	0xffff0000U
> +#define SECCOMP_RET_DATA	0x0000ffffU
> +
> +/**
> + * struct seccomp_data - the format the BPF program executes over.

format?

> + * @nr: the system call number
> + * @arch: indicates system call convention as an AUDIT_ARCH_* value
> + *        as defined in <linux/audit.h>.
> + * @instruction_pointer: at the time of the system call.

If the vDSO is used this will always be the same, so what good is this?
I haven't gotten an answer to this yet.

That said, it's eays enough to add, I just don't see the point of it.

> + * @args: up to 6 system call arguments always stored as 64-bit values
> + *        regardless of the architecture.
> + */
> +struct seccomp_data {
> +	int nr;
> +	__u32 arch;
> +	__u64 instruction_pointer;
> +	__u64 args[6];
> +};
>
> +#ifdef __KERNEL__
> #ifdef CONFIG_SECCOMP
>
> #include <linux/thread_info.h>
> #include <asm/seccomp.h>
>
> +struct seccomp_filter;
> +/**
> + * struct seccomp - the state of a seccomp'ed process
> + *
> + * @mode:  indicates one of the valid values above for controlled
> + *         system calls available to a process.
> + * @filter: The metadata and ruleset for determining what system calls
> + *          are allowed for a task.
> + *
> + *          @filter must only be accessed from the context of current as there

I'd move 'as there' to the next line.

> + *          is no locking.
> + */
> struct seccomp {
> 	int mode;
> +	struct seccomp_filter *filter;
> };

If the extra memory usage is a problem, a union could be used:

union seccomp {
	long mode;
	struct seccomp_filter *filter;
};

That way mode is 0 when it's disabled, 1 for SECCOMP_MODE_STRICT and
a pointer for SECCOMP_MODE_FILTER.

>
> extern void __secure_computing(int);
> @@ -19,7 +72,7 @@ static inline void secure_computing(int this_syscall)
> }
>
> extern long prctl_get_seccomp(void);
> -extern long prctl_set_seccomp(unsigned long);
> +extern long prctl_set_seccomp(unsigned long, char __user *);
>
> static inline int seccomp_mode(struct seccomp *s)
> {
> @@ -31,15 +84,16 @@ static inline int seccomp_mode(struct seccomp *s)
> #include <linux/errno.h>
>
> struct seccomp { };
> +struct seccomp_filter { };
>
> -#define secure_computing(x) do { } while (0)
> +#define secure_computing(x) 0
>
> static inline long prctl_get_seccomp(void)
> {
> 	return -EINVAL;
> }
>
> -static inline long prctl_set_seccomp(unsigned long arg2)
> +static inline long prctl_set_seccomp(unsigned long arg2, char __user *arg3)
> {
> 	return -EINVAL;
> }
> @@ -48,7 +102,15 @@ static inline int seccomp_mode(struct seccomp *s)
> {
> 	return 0;
> }
> -
> #endif /* CONFIG_SECCOMP */
>
> +#ifdef CONFIG_SECCOMP_FILTER
> +extern void put_seccomp_filter(struct seccomp_filter *);
> +extern void get_seccomp_filter(struct seccomp_filter *);
> +#else  /* CONFIG_SECCOMP_FILTER */
> +/* These macros consume the seccomp.filter reference. */

I think it's cleaner to let put/get_seccomp_filter have struct task*
as a parameter instead of the filter.

> +#define put_seccomp_filter(_s) do { } while (0)
> +#define get_seccomp_filter(_s) do { } while (0)
> +#endif /* CONFIG_SECCOMP_FILTER */
> +#endif /* __KERNEL__ */
> #endif /* _LINUX_SECCOMP_H */
> diff --git a/kernel/fork.c b/kernel/fork.c
> index b18c107..da3e489 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -34,6 +34,7 @@
> #include <linux/cgroup.h>
> #include <linux/security.h>
> #include <linux/hugetlb.h>
> +#include <linux/seccomp.h>
> #include <linux/swap.h>
> #include <linux/syscalls.h>
> #include <linux/jiffies.h>
> @@ -171,6 +172,7 @@ void free_task(struct task_struct *tsk)
> 	free_thread_info(tsk->stack);
> 	rt_mutex_debug_task_free(tsk);
> 	ftrace_graph_exit_task(tsk);
> +	put_seccomp_filter(tsk->seccomp.filter);
> 	free_task_struct(tsk);
> }
> EXPORT_SYMBOL(free_task);
> @@ -1166,6 +1168,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
> 		goto fork_out;
>
> 	ftrace_graph_init_task(p);
> +	get_seccomp_filter(p->seccomp.filter);
>
> 	rt_mutex_init_task(p);
>
> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
> index e8d76c5..71df324 100644
> --- a/kernel/seccomp.c
> +++ b/kernel/seccomp.c
> @@ -3,16 +3,272 @@
>  *
>  * Copyright 2004-2005  Andrea Arcangeli <andrea@cpushare.com>
>  *
> - * This defines a simple but solid secure-computing mode.
> + * Copyright (C) 2012 Google, Inc.
> + * Will Drewry <wad@chromium.org>
> + *
> + * This defines a simple but solid secure-computing facility.
> + *
> + * Mode 1 uses a fixed list of allowed system calls.
> + * Mode 2 allows user-defined system call filters in the form
> + *        of Berkeley Packet Filters/Linux Socket Filters.
>  */
>
> +#include <linux/atomic.h>
> #include <linux/audit.h>
> -#include <linux/seccomp.h>
> -#include <linux/sched.h>
> #include <linux/compat.h>
> +#include <linux/filter.h>
> +#include <linux/sched.h>
> +#include <linux/seccomp.h>
> +#include <linux/security.h>
> +#include <linux/slab.h>
> +#include <linux/uaccess.h>
> +
> +#include <linux/tracehook.h>
> +#include <asm/syscall.h>
>
> /* #define SECCOMP_DEBUG 1 */
> -#define NR_SECCOMP_MODES 1
> +
> +#ifdef CONFIG_SECCOMP_FILTER
> +/**
> + * struct seccomp_filter - container for seccomp BPF programs
> + *
> + * @usage: reference count to manage the object liftime.
> + *         get/put helpers should be used when accessing an instance
> + *         outside of a lifetime-guarded section.  In general, this
> + *         is only needed for handling filters shared across tasks.
> + * @prev: points to a previously installed, or inherited, filter
> + * @insns: the BPF program instructions to evaluate
> + * @len: the number of instructions in the program
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

To avoid 4 bytes of the padding on 64-bit, you could move len to just after
atomic_t, which is an int.

> +	struct sock_filter insns[];
> +};
> +
> +/* Limit any path through the tree to 5 megabytes worth of instructions. */
> +#define MAX_INSNS_PER_PATH ((5 << 20) / sizeof(struct sock_filter))

I think this is too high, that are 160 filters with max instruction length.

I vote for a 1MB or lower limit, that's 32 filters with max size.

> +
> +static void seccomp_filter_log_failure(int syscall)
> +{
> +	int compat = 0;
> +#ifdef CONFIG_COMPAT
> +	compat = is_compat_task();
> +#endif
> +	pr_info("%s[%d]: %ssystem call %d blocked at 0x%lx\n",
> +		current->comm, task_pid_nr(current),
> +		(compat ? "compat " : ""),
> +		syscall, KSTK_EIP(current));
> +}

Hm, I thought everyone agreed this wasn't really necessary?

> +
> +/**
> + * get_u32 - returns a u32 offset into data

It doesn't return an offset.

> + * @data: a unsigned 64 bit value

Well, yes, it's a u64.

> + * @index: 0 or 1 to return the first or second 32-bits
> + *
> + * This inline exists to hide the length of unsigned long.

and to get the upper half of it.

> + * If a 32-bit unsigned long is passed in, it will be extended
> + * and the top 32-bits will be 0. If it is a 64-bit unsigned
> + * long, then whatever data is resident will be properly returned.
> + */

Personally I would leave out the whole comment, because reading the
two lines of code is faster and gives the same info.

> +static inline u32 get_u32(u64 data, int index)
> +{
> +	return ((u32 *)&data)[index];
> +}
> +
> +/* Helper for bpf_load below. */
> +#define BPF_DATA(_name) offsetof(struct seccomp_data, _name)
> +/**
> + * bpf_load: checks and returns a pointer to the requested offset
> + * @nr: int syscall passed as a void * to bpf_run_filter
> + * @off: offset into struct seccomp_data to load from (must be u32 aligned)
> + * @size: number of bytes to load (must be 4 bytes)
> + * @buf: temporary storage supplied by bpf_run_filter (4 bytes)
> + *
> + * Returns a pointer to the loaded data (usually @buf).
> + * On failure, returns NULL.
> + */
> +static void *bpf_load(const void *nr, int off, unsigned int size, void *buf)
> +{
> +	unsigned long value;
> +	u32 *A = buf;
> +
> +	if (size != sizeof(u32) || off % sizeof(u32))
> +		return NULL;
> +
> +	if (off >= BPF_DATA(args[0]) && off < BPF_DATA(args[6])) {
> +		struct pt_regs *regs = task_pt_regs(current);
> +		int arg = (off - BPF_DATA(args[0])) / sizeof(u64);
> +		int index = (off % sizeof(u64)) ? 1 : 0;
> +		syscall_get_arguments(current, regs, arg, 1, &value);
> +		*A = get_u32(value, index);
> +	} else if (off == BPF_DATA(nr)) {
> +		*A = (u32)(uintptr_t)nr;
> +	} else if (off == BPF_DATA(arch)) {
> +		struct pt_regs *regs = task_pt_regs(current);
> +		*A = syscall_get_arch(current, regs);
> +	} else if (off == BPF_DATA(instruction_pointer)) {
> +		*A = get_u32(KSTK_EIP(current), 0);
> +	} else if (off == BPF_DATA(instruction_pointer) + sizeof(u32)) {
> +		*A = get_u32(KSTK_EIP(current), 1);
> +	} else {
> +		return NULL;
> +	}
> +	return buf;
> +}

The interface doesn't match, the alignment doesn't match, and the LD
instructions couldn't be reused, with code size and even slowdowns in
the networking filter code as a result. I have the impression this
isn't the best approach after all.

I'm going to take a look at implementing it as anscillary data accesses
instead of generic loads. That hopefully reduces the code churn in filter.c
a lot.

> +
> +/**
> + * seccomp_run_filters - evaluates all seccomp filters against @syscall
> + * @syscall: number of the current system call
> + *
> + * Returns valid seccomp BPF response codes.
> + */
> +static u32 seccomp_run_filters(int syscall)
> +{
> +	struct seccomp_filter *f;
> +	u32 ret = SECCOMP_RET_KILL;
> +	static const struct bpf_load_fn fns = {
> +		bpf_load,
> +		sizeof(struct seccomp_data),
> +	};
> +	const void *sc_ptr = (const void *)(uintptr_t)syscall;
> +
> +	/*
> +	 * All filters are evaluated in order of youngest to oldest. The lowest
> +	 * BPF return value always takes priority.
> +	 */
> +	for (f = current->seccomp.filter; f; f = f->prev) {
> +		ret = bpf_run_filter(sc_ptr, f->insns, &fns);
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
> +	/* Walk the list to ensure the new instruction count is allowed. */
> +	for (filter = current->seccomp.filter; filter; filter = filter->prev) {
> +		if (total_insns > MAX_INSNS_PER_PATH - filter->len)
> +			return -E2BIG;
> +		total_insns += filter->len;
> +	}

Now you go over the limit once before that if check is ever true, and it can
only be true for the last filter. So take it out of the loop, that makes the
code clearer, faster and more correct.

I'm not sure E2BIG ("Argument list too long") is the best return value.
ENOMEM seems more fitting, because it's not this filter's instruction
length that's too long, it's the combined filters that are taking too
much memory.

> +
> +	/* Allocate a new seccomp_filter */
> +	filter = kzalloc(sizeof(struct seccomp_filter) + fp_size, GFP_KERNEL);
> +	if (!filter)
> +		return -ENOMEM;
> +	atomic_set(&filter->usage, 1);
> +	filter->len = fprog->len;
> +
> +	/* Copy the instructions from fprog. */
> +	ret = -EFAULT;
> +	if (copy_from_user(filter->insns, fprog->filter, fp_size))
> +		goto out;
> +
> +	/* Check the fprog */
> +	ret = bpf_chk_filter(filter->insns, filter->len, BPF_CHK_FLAGS_NO_SKB);
> +	if (ret)
> +		goto out;
> +
> +	/*
> +	 * Installing a seccomp filter requires that the task have
> +	 * CAP_SYS_ADMIN in its namespace or be running with no_new_privs.
> +	 * This avoids scenarios where unprivileged tasks can affect the
> +	 * behavior of privileged children.
> +	 */
> +	ret = -EACCES;
> +	if (!current->no_new_privs &&
> +	    security_capable_noaudit(current_cred(), current_user_ns(),
> +				     CAP_SYS_ADMIN) != 0)
> +		goto out;

I think this check should be done first, before allocating any memory.

> +
> +	/*
> +	 * If there is an existing filter, make it the prev and don't drop its
> +	 * task reference.
> +	 */
> +	filter->prev = current->seccomp.filter;
> +	current->seccomp.filter = filter;
> +	return 0;
> +out:
> +	put_seccomp_filter(filter);  /* for get or task, on err */

Let put_seccomp_filter() take a struct task* as argument and instead of
calling it here, just do a kfree() directly. That's more symmetrical too.

> +	return ret;
> +}
> +
> +/**
> + * seccomp_attach_user_filter - attaches a user-supplied sock_fprog
> + * @user_filter: pointer to the user data containing a sock_fprog.
> + *
> + * Returns 0 on success and non-zero otherwise.
> + */
> +long seccomp_attach_user_filter(char __user *user_filter)
> +{
> +	struct sock_fprog fprog;
> +	long ret = -EFAULT;
> +
> +	if (!user_filter)
> +		goto out;

Isn't this checked by copy_from_user() already?

> +#ifdef CONFIG_COMPAT
> +	if (is_compat_task()) {
> +		struct compat_sock_fprog fprog32;
> +		if (copy_from_user(&fprog32, user_filter, sizeof(fprog32)))
> +			goto out;
> +		fprog.len = fprog32.len;
> +		fprog.filter = compat_ptr(fprog32.filter);
> +	} else /* falls through to the if below. */
> +#endif
> +	if (copy_from_user(&fprog, user_filter, sizeof(fprog)))
> +		goto out;
> +	ret = seccomp_attach_filter(&fprog);
> +out:
> +	return ret;
> +}
> +
> +/* get_seccomp_filter - increments the reference count of @orig. */
> +void get_seccomp_filter(struct seccomp_filter *orig)
> +{
> +	if (!orig)
> +		return;
> +	/* Reference count is bounded by the number of total processes. */
> +	atomic_inc(&orig->usage);
> +}
> +
> +/* put_seccomp_filter - decrements the ref count of @orig and may free. */
> +void put_seccomp_filter(struct seccomp_filter *orig)
> +{
> +	/* Clean up single-reference branches iteratively. */
> +	while (orig && atomic_dec_and_test(&orig->usage)) {
> +		struct seccomp_filter *freeme = orig;
> +		orig = orig->prev;
> +		kfree(freeme);
> +	}
> +}
> +#endif	/* CONFIG_SECCOMP_FILTER */
>
> /*
>  * Secure computing mode 1 allows only read/write/exit/sigreturn.
> @@ -34,10 +290,11 @@ static int mode1_syscalls_32[] = {
> void __secure_computing(int this_syscall)
> {
> 	int mode = current->seccomp.mode;
> -	int * syscall;
> +	int exit_code = SIGKILL;
> +	int *syscall;
>
> 	switch (mode) {
> -	case 1:
> +	case SECCOMP_MODE_STRICT:
> 		syscall = mode1_syscalls;
> #ifdef CONFIG_COMPAT
> 		if (is_compat_task())
> @@ -48,6 +305,14 @@ void __secure_computing(int this_syscall)
> 				return;
> 		} while (*++syscall);
> 		break;
> +#ifdef CONFIG_SECCOMP_FILTER
> +	case SECCOMP_MODE_FILTER:
> +		if (seccomp_run_filters(this_syscall) == SECCOMP_RET_ALLOW)
> +			return;
> +		seccomp_filter_log_failure(this_syscall);
> +		exit_code = SIGSYS;
> +		break;
> +#endif
> 	default:
> 		BUG();
> 	}
> @@ -56,7 +321,7 @@ void __secure_computing(int this_syscall)
> 	dump_stack();
> #endif
> 	audit_seccomp(this_syscall);
> -	do_exit(SIGKILL);
> +	do_exit(exit_code);
> }
>
> long prctl_get_seccomp(void)
> @@ -64,25 +329,48 @@ long prctl_get_seccomp(void)
> 	return current->seccomp.mode;
> }
>
> -long prctl_set_seccomp(unsigned long seccomp_mode)
> +/**
> + * prctl_set_seccomp: configures current->seccomp.mode
> + * @seccomp_mode: requested mode to use
> + * @filter: optional struct sock_fprog for use with SECCOMP_MODE_FILTER
> + *
> + * This function may be called repeatedly with a @seccomp_mode of
> + * SECCOMP_MODE_FILTER to install additional filters.  Every filter
> + * successfully installed will be evaluated (in reverse order) for each system

I'd move the 'each system' to the next line.

> + * call the task makes.
> + *
> + * Once current->seccomp.mode is non-zero, it may not be changed.
> + *
> + * Returns 0 on success or -EINVAL on failure.
> + */
> +long prctl_set_seccomp(unsigned long seccomp_mode, char __user *filter)
> {
> -	long ret;
> +	long ret = -EINVAL;
>
> -	/* can set it only once to be even more secure */
> -	ret = -EPERM;
> -	if (unlikely(current->seccomp.mode))
> +	if (current->seccomp.mode &&
> +	    current->seccomp.mode != seccomp_mode)
> 		goto out;
>
> -	ret = -EINVAL;
> -	if (seccomp_mode && seccomp_mode <= NR_SECCOMP_MODES) {
> -		current->seccomp.mode = seccomp_mode;
> -		set_thread_flag(TIF_SECCOMP);
> +	switch (seccomp_mode) {
> +	case SECCOMP_MODE_STRICT:
> +		ret = 0;
> #ifdef TIF_NOTSC
> 		disable_TSC();
> #endif
> -		ret = 0;
> +		break;
> +#ifdef CONFIG_SECCOMP_FILTER
> +	case SECCOMP_MODE_FILTER:
> +		ret = seccomp_attach_user_filter(filter);
> +		if (ret)
> +			goto out;
> +		break;
> +#endif
> +	default:
> +		goto out;
> 	}
>
> - out:
> +	current->seccomp.mode = seccomp_mode;
> +	set_thread_flag(TIF_SECCOMP);
> +out:
> 	return ret;
> }
> diff --git a/kernel/sys.c b/kernel/sys.c
> index 4686119..0addc11 100644
> --- a/kernel/sys.c
> +++ b/kernel/sys.c
> @@ -1955,7 +1955,7 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2,
unsigned long, arg3,
> 			error = prctl_get_seccomp();
> 			break;
> 		case PR_SET_SECCOMP:
> -			error = prctl_set_seccomp(arg2);
> +			error = prctl_set_seccomp(arg2, (char __user *)arg3);
> 			break;
> 		case PR_GET_TSC:
> 			error = GET_TSC_CTL(arg2);
> --

Reviewed-by: Indan Zupancic <indan@nul.nu>

Greetings,

Indan

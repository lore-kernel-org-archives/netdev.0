From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: [PATCH v17 08/15] seccomp: add system call filtering using BPF
Date: Mon, 9 Apr 2012 04:22:40 +1000
Message-ID: <67e30a0c8655fc53a92e8138bba9de66.squirrel@webmail.greenhost.nl>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
    <1333051320-30872-9-git-send-email-wad@chromium.org>
    <20120406132330.457a05cf.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "Will Drewry" <wad@chromium.org>, linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, pmoore@redhat.com, corbet@lwn.net,
	eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org, jmorris@namei.org
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20120406132330.457a05cf.akpm@linux-foundation.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, April 7, 2012 06:23, Andrew Morton wrote:
> hm, I'm surprised that we don't have a zero-returning implementation of
> is_compat_task() when CONFIG_COMPAT=n.  Seems silly.  Blames Arnd.

It's sneakily hidden at the end of compat.h.

>> +/**
>> + * get_u32 - returns a u32 offset into data
>> + * @data: a unsigned 64 bit value
>> + * @index: 0 or 1 to return the first or second 32-bits
>> + *
>> + * This inline exists to hide the length of unsigned long.
>> + * If a 32-bit unsigned long is passed in, it will be extended
>> + * and the top 32-bits will be 0. If it is a 64-bit unsigned
>> + * long, then whatever data is resident will be properly returned.
>> + */
>> +static inline u32 get_u32(u64 data, int index)
>> +{
>> +	return ((u32 *)&data)[index];
>> +}
>
> This seems utterly broken on big-endian machines.  If so: fix.  If not:
> add comment explaining why?

It's not a bug, it's intentional.

I tried to convince them to have a stable ABI for all archs, but they
didn't want to make the ABI endianness independent, because it looks
uglier. The argument being that system call numbers are arch dependent
anyway.

So a filter for a little endian arch needs to check a different offset
than one for a big endian archs.

>> +static u32 seccomp_run_filters(int syscall)
>> +{
>> +	struct seccomp_filter *f;
>> +	u32 ret = SECCOMP_RET_KILL;
>> +	/*
>> +	 * All filters are evaluated in order of youngest to oldest. The lowest
>> +	 * BPF return value always takes priority.
>> +	 */
>
> The youngest-first design surprised me.  It wasn't mentioned at all in
> the changelog.  Thinking about it, I guess it just doesn't matter.  But
> some description of the reasons for and implications of this decision
> for the uninitiated would be welcome.

I think it's less confusing to not mention the order at all, exactly
because it doesn't matter. It has been like this from the start, so
that's why it's not mentioned in the changelog I guess.

The reason to check the youngest first is because the filters are shared
between processes: childs inherit it. If later on additional filters are
added, the only way of adding them without modifying an older filter is
by adding them to the head of the list. This way no locking is needed,
because filters are only added and removed single-threadedly, and never
modified when being shared.

>> +/**
>> + * seccomp_attach_filter: Attaches a seccomp filter to current.
>> + * @fprog: BPF program to install
>> + *
>> + * Returns 0 on success or an errno on failure.
>> + */
>> +static long seccomp_attach_filter(struct sock_fprog *fprog)
>> +{
>> +	struct seccomp_filter *filter;
>> +	unsigned long fp_size = fprog->len * sizeof(struct sock_filter);
>> +	unsigned long total_insns = fprog->len;
>> +	long ret;
>> +
>> +	if (fprog->len == 0 || fprog->len > BPF_MAXINSNS)
>> +		return -EINVAL;
>> +
>> +	for (filter = current->seccomp.filter; filter; filter = filter->prev)
>> +		total_insns += filter->len + 4;  /* include a 4 instr penalty */
>
> So tasks don't share filters?  We copy them by value at fork?  Do we do
> this at vfork() too?

Yes they do. But shared filters are never modified, except for the refcount.

>
>> +	if (total_insns > MAX_INSNS_PER_PATH)
>> +		return -ENOMEM;
>> +
>> +	/*
>> +	 * Installing a seccomp filter requires that the task have
>> +	 * CAP_SYS_ADMIN in its namespace or be running with no_new_privs.
>> +	 * This avoids scenarios where unprivileged tasks can affect the
>> +	 * behavior of privileged children.
>> +	 */
>> +	if (!current->no_new_privs &&
>> +	    security_capable_noaudit(current_cred(), current_user_ns(),
>> +				     CAP_SYS_ADMIN) != 0)
>> +		return -EACCES;
>> +
>> +	/* Allocate a new seccomp_filter */
>> +	filter = kzalloc(sizeof(struct seccomp_filter) + fp_size, GFP_KERNEL);
>
> I think this gives userspace an easy way of causing page allocation
> failure warnings, by permitting large kmalloc() attempts.  Add
> __GFP_NOWARN?

Max is 32kb. sk_attach_filter() in net/core/filter.c is worse,
it allocates up to 512kb before even checking the length.

What about using GFP_USER (and adding __GFP_NOWARN to GFP_USER) instead?

>> +	/* Check and rewrite the fprog via the skb checker */
>> +	ret = sk_chk_filter(filter->insns, filter->len);
>> +	if (ret)
>> +		goto fail;
>> +
>> +	/* Check and rewrite the fprog for seccomp use */
>> +	ret = seccomp_chk_filter(filter->insns, filter->len);
>
> "check" is spelled "check"!

Yes, it is and he did spell "check" as "Check".

seccomp_chk_filter() mirrors sk_chk_filter(). So it refers to
"chk", not "check".

>
>> +	if (ret)
>> +		goto fail;
>> +
>> +	/*
>> +	 * If there is an existing filter, make it the prev and don't drop its
>> +	 * task reference.
>> +	 */
>> +	filter->prev = current->seccomp.filter;
>> +	current->seccomp.filter = filter;
>> +	return 0;
>> +fail:
>> +	kfree(filter);
>> +	return ret;
>> +}
>> +
>>
>> ...
>>
>> +/* put_seccomp_filter - decrements the ref count of tsk->seccomp.filter */
>> +void put_seccomp_filter(struct task_struct *tsk)
>> +{
>> +	struct seccomp_filter *orig = tsk->seccomp.filter;
>> +	/* Clean up single-reference branches iteratively. */
>> +	while (orig && atomic_dec_and_test(&orig->usage)) {
>> +		struct seccomp_filter *freeme = orig;
>> +		orig = orig->prev;
>> +		kfree(freeme);
>> +	}
>> +}
>
> So if one of the filters in the list has an elevated refcount, we bail
> out on the remainder of the list.  Seems odd.

A bit odd yes, but fiddling with the other refcounts makes no functional
difference. You can see it as a tree of filters, with a fork at each
point any process forked, and the filters between forks having the same
life-time (added by the same process). Every process's filter list is
a path from a leaf filter to the root.

Only leaf filters get their refcount incremented at fork time, so their
refcount is always the same or higher than the refcount of the filters
before them, up to the previous fork. The intermediate filters always
have a refcount of 1, real refcounting only happens on the fork filters.
A refcount of 1 means it's an intermediate or a leaf filter, a higher
refcount means it's a fork filter.

With "proper" refcounting all the filters from the new leaf up to the
root would get their refcount incremented at fork time, but that is
wasted work, because they can be guarded by the last filter instead.

So the code bails when reaching a fork point, as it means that filter
and hence the rest of the list is shared and used by other processes.

Greetings,

Indan



From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] netfilter: use per-CPU r**ursive lock {XV}
Date: Mon, 27 Apr 2009 16:01:58 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904271525120.22156@localhost.localdomain>
References: <49F22465.80305@gmail.com> <20090425133052.4cb711f5@nehalam> <49F4A6E3.7080102@cosmosbay.com> <20090426185646.GB29238@Krystal> <20090426145746.1184aeba@nehalam> <1240854297.7620.65.camel@twins> <20090427113010.5e3f1700@nehalam> <20090427185423.GC23862@elte.hu>
 <20090427120658.35a858bb@nehalam> <alpine.LFD.2.00.0904271219570.22156@localhost.localdomain> <20090427203616.GB3836@ioremap.net> <alpine.LFD.2.00.0904271340400.22156@localhost.localdomain> <20090427144054.1fb9b7a6@nehalam>
 <alpine.LFD.2.00.0904271506530.22156@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Evgeniy Polyakov <zbr@ioremap.net>, Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	kaber@trash.net, jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.0904271506530.22156@localhost.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 27 Apr 2009, Linus Torvalds wrote:
> 
> Btw, if you do use the "explicit count" case, then please please please 
> make sure it's documented and bug-free. And dammit, correct documentation 
> in this case very much talks about how it is _not_ a "recursive lock", but 
> a spinlock that then has an explicit counter that avoids taking the lock 
> entirely in one very specific path (that happens to be recursive).

So, just as an example, I would not object to the counter approach, as 
long as it really talks about the issues, and why it works (and as long 
that doesn't call the locks "recursive locks").

So if you are just nervous about rwlocks, then something like this might
work (needs testing, and other people to sanity-check it).

I left the commentary about "readers" and "writers", because in many
ways it's correct, and what the code actually does is very much to
emulate a reader-writer lock.  I put quotes around the uses in the
comments to high-light that it largely _acts_ as a reader-writer lock. 

Now, it would actually be a really _bad_ reader-writer lock in general, 
exactly because it's not very "atomic" (ie this would be a truly sucky and 
broken lock if we didn't have the strict per-cpu usage rules).

So it just so happens that the per-cpu'ness of the lock, together with the 
very limited way in which it is used, make that sucky implementation 
possible - and indeed possibly faster than the standard (and generic) 
kernel rwlock implementation.

So it's basically a special-case rwlock that happens to work due to the
specific rules. 

And exactly because it really wouldn't work in the absense of those
rules, those rules really do need to have big comments on them so that 
people don't then later forget about the limitations.

BTW: THIS IS TOTALLY UNTESTED.  I just cut-and-pasted the existing
rwlock version from one of the later patches, used the counting approach
from one of the earlier ones, and basically just added what I think
would be minimal required comments for this special case.  All of it was
written inside the mail reader, none of it has been compiled or tested
in any other way. 

Because it's exactly the "lock semantics awareness" that I think is so
important here (and that's why all the naming and commentary is so
critical). 

Btw, the "counter" could probably be just a single bit, since apparently
the nesting level is always supposed to be just one.  I made it
"unsigned char" just because sometimes spinlocks can be small, and it
seemed the simplest type.  But perhaps it would be better as an
"unsigned int", since some architectures potentially could do that
faster (eg old alphas).

			Linus

---
/*
 * Per-CPU spinlock associated with per-cpu table entries, and
 * with a counter for the "reading" side that allows a recursive
 * reader to avoid taking the lock and deadlocking.
 *
 * "reading" is used by ip/arp/ip6 tables rule processing which runs per-cpu.
 * It needs to ensure that the rules are not being changed while the packet
 * is being processed. In some cases, the read lock will be acquired
 * twice on the same CPU; this is okay because of the count.
 *
 * The write lock is used in two cases:
 *    1. reading counter values
 *       all rule processing need to be stopped and the per-CPU values are summed.
 *
 *    2. replacing tables
 *       any readers that are using the old tables have to complete
 *       before freeing the old table. This is handled by reading
 *       as a side effect of reading counters
 */
struct xt_info_lock {
	spin_lock_t lock;
	unsigned char readers;
};
DECLARE_PER_CPU(struct xt_info_lock, xt_info_locks);

/*
 * Note: we need to ensure that preemption is disabled before acquiring
 * the per-cpu-variable, so we do it as a two step process rather than
 * using "spin_lock_bh()". 
 *
 * We _also_ need to disable bottom half processing before updating our
 * nesting count, to make sure that the only kind of re-entrancy is this
 * code being called by itself: since the count+lock is not an atomic
 * operation, we can allow no races. 
 *
 * _Only_ that special combination of being per-cpu and never getting
 * re-entered asynchronously means that the count is safe. 
 */
static inline void xt_info_rdlock_bh(void)
{
	struct xt_info_lock *lock;

	local_bh_disable();
	lock = &__get_cpu_var(xt_info_locks);
	if (!lock->readers++)
		spin_lock(&lock->lock);
}

static inline void xt_info_rdunlock_bh(void)
{
	struct xt_info_lock *lock;

	lock = &__get_cpu_var(xt_info_locks);
	if (!--lock->readers)
		spin_unlock(&lock->lock);
}

/*
 * The "writer" side needs to get exclusive access to the lock,
 * regardless of readers.  This must be called with bottom half
 * processing (and thus also preemption) disabled. 
 */
static inline void xt_info_wrlock(unsigned int cpu)
{
	spin_lock(&per_cpu(xt_info_locks, cpu).lock);
}

static inline void xt_info_wrunlock(unsigned int cpu)
{
	spin_unlock(&per_cpu(xt_info_locks, cpu).lock);
}

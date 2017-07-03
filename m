From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH RFC 01/26] netfilter: Replace spin_unlock_wait() with
 lock/unlock pair
Date: Mon, 3 Jul 2017 15:57:03 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1707031543170.2027-100000@iolanthe.rowland.org>
References: <53bbfa1a-2836-863d-3a5c-4f2f7f0baa40@colorfullife.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: paulmck@linux.vnet.ibm.com, <linux-kernel@vger.kernel.org>,
        <netfilter-devel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <oleg@redhat.com>, <akpm@linux-foundation.org>, <mingo@redhat.com>,
        <dave@stgolabs.net>, <tj@kernel.org>, <arnd@arndb.de>,
        <linux-arch@vger.kernel.org>, <will.deacon@arm.com>,
        <peterz@infradead.org>, <parri.andrea@gmail.com>,
        <torvalds@linux-foundation.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>, <coreteam@netfilter.org>,
        <1vier1@web.de>
To: Manfred Spraul <manfred@colorfullife.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <53bbfa1a-2836-863d-3a5c-4f2f7f0baa40@colorfullife.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 3 Jul 2017, Manfred Spraul wrote:

> >>> +	/* 2) read nf_conntrack_locks_all, with ACQUIRE semantics */
> >>> +	if (likely(smp_load_acquire(&nf_conntrack_locks_all) == false))
> >>> +		return;
> >> As far as I can tell, this read does not need to have ACQUIRE
> >> semantics.
> >>
> >> You need to guarantee that two things can never happen:
> >>
> >>      (1) We read nf_conntrack_locks_all == false, and this routine's
> >> 	critical section for nf_conntrack_locks[i] runs after the
> >> 	(empty) critical section for that lock in
> >> 	nf_conntrack_all_lock().
> >>
> >>      (2) We read nf_conntrack_locks_all == true, and this routine's
> >> 	critical section for nf_conntrack_locks_all_lock runs before
> >> 	the critical section in nf_conntrack_all_lock().
> I was looking at nf_conntrack_all_unlock:
> There is a smp_store_release() - which memory barrier does this pair with?
> 
> nf_conntrack_all_unlock()
>      <arbitrary writes>
>      smp_store_release(a, false)
>      spin_unlock(b);
> 
> nf_conntrack_lock()
>      spin_lock(c);
>      xx=read_once(a)
>      if (xx==false)
>          return
>      <arbitrary read>

Ah, I see your point.  Yes, I did wonder about what would happen when
nf_conntrack_locks_all was set back to false.  But I didn't think about
it any further, because the relevant code wasn't in your patch.

> I tried to pair the memory barriers:
> nf_conntrack_all_unlock() contains a smp_store_release().
> What does that pair with?

You are right, this does need to be smp_load_acquire() after all.  
Perhaps the preceding comment should mention that it pairs with the 
smp_store_release() from an earlier invocation of 
nf_conntrack_all_unlock().

(Alternatively, you could make nf_conntrack_all_unlock() do a
lock+unlock on all the locks in the array, just like
nf_conntrack_all_lock().  But of course, that would be a lot less
efficient.)

Alan Stern

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v11)
Date: Tue, 21 Apr 2009 11:34:29 -0700
Message-ID: <20090421183429.GL6642@linux.vnet.ibm.com>
References: <20090417012812.GA25534@linux.vnet.ibm.com> <20090418094001.GA2369@ioremap.net> <20090418141455.GA7082@linux.vnet.ibm.com> <20090420103414.1b4c490f@nehalam> <49ECBE0A.7010303@cosmosbay.com> <18924.59347.375292.102385@cargo.ozlabs.ibm.com> <20090420215827.GK6822@linux.vnet.ibm.com> <18924.64032.103954.171918@cargo.ozlabs.ibm.com> <20090420160121.268a8226@nehalam> <alpine.LFD.2.00.0904210831560.2199@localhost.localdomain>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Paul Mackerras <paulus@samba.org>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	jeff.chua.linux@gmail.com, mingo@elte.hu, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:46362 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755109AbZDUSeg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Apr 2009 14:34:36 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0904210831560.2199@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 21, 2009 at 09:13:52AM -0700, Linus Torvalds wrote:
> 
> Ok, so others already pointed out how dangerous/buggy this looks, but I'd 
> like to strengthen that a bit more:

I believe that at least some of this is naming...

> On Mon, 20 Apr 2009, Stephen Hemminger wrote:

[ . . . ]

> If you want a counting read-lock (in _order_ to allow recursion, but not 
> because the lock itself is somehow recursive!), then that function should 
> look like this:
> 
> 	void xt_info_rdlock_bh(void)
> 	{
> 		struct xt_info_lock *lock
> 
> 		local_bh_disable();
> 		lock = &__get_cpu_var(xt_info_locks);
> 		read_lock(&lock->lock);
> 	}
> 
> And then the "unlock" should be the reverse. No games, no crap, and 
> hopefully then no bugs. And if you do it that way, you don't even need the 
> comments, although quite frankly, it probably makes a lot of sense to talk 
> about the interaction between "local_bh_disable()" and the preempt count, 
> and why you're not using "read_lock_bh()".
> 
> And if you don't want a read-lock, then fine - don't use a read-lock, do 
> something else. But then don't just re-implement it (badly) either and 
> call it something else!

Sigh!!!

Part of the problem is that back in 1971, Courtois, Heymans, and Parnas
foolishly named their article "Concurrent Control with 'Readers' and
'Writers'", which lead to the name "reader-writer lock".  This started
really biting around 1991, when Hsieh and Weihl created a reader-optimized
lock similar to brlock, but with each of the per-CPU locks being
exclusive rather than each being an rwlock.

The problem was that Hsieh's and Weihl's lock was more than just
a reader-writer lock.  It could also be used (and -was- used) as a
local/global lock, where for example you acquire your own lock to make
local changes, and acquire all of the locks to obtain a consistent view
of global state.  In which case, you would read-acquire the lock in
order to write, and write-acquire the lock in order to read.  Blech.

So, would it help if the function names names in this patch said something
about "local" and "global" rather than "read" and "write"?

							Thanx, Paul


> 			Linus
> 
> PS: Ingo, why do the *_bh() functions in kernel/spinlock.c do _both_ a 
> "local_bh_disable()" and a "preempt_disable()"? BH disable should disable 
> preemption too, no? Or am I confused? In which case we need that in 
> the above rdlock_bh too.

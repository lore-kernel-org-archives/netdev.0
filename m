From: Nicholas Mc Guire <der.herr@hofr.at>
Subject: Re: [PATCH] rebalance locks by converting write_lock_bh to
	write_lock+local_bh_disable
Date: Sun, 24 Nov 2013 00:58:23 +0100
Message-ID: <20131123235823.GA23670@opentech.at>
References: <20131121235402.GA11774@opentech.at> <20131123.143929.975712910203893827.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, eric.dumazet@gmail.com, roque@di.fc.ul.pt,
	peterz@infradead.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hofr.at ([212.69.189.236]:44644 "EHLO mail.hofr.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755583Ab3KWX6Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Nov 2013 18:58:25 -0500
Content-Disposition: inline
In-Reply-To: <20131123.143929.975712910203893827.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 23 Nov 2013, David Miller wrote:

> From: Nicholas Mc Guire <der.herr@hofr.at>
> Date: Fri, 22 Nov 2013 00:54:02 +0100
> 
> > From 2c8e669b691b825c0ed2a02bd7a698d8ed5c6d29 Mon Sep 17 00:00:00 2001
> > From: Nicholas Mc Guire <der.herr@hofr.at>
> > Date: Thu, 21 Nov 2013 18:22:55 -0500
> > Subject: [PATCH] rebalance locks by converting write_lock_bh to write_lock+local_bh_disable
> >  
> > 
> >  in __neigh_event_send write_lock_bh(&neigh->lock) is implicitly balanced by
> >  write_unlock(&neigh->lock)+local_bh_disable() - while this is equivalent with
> >  respect to the effective low level locking primitives it breaks balancing
> >  in the locking api. This makes automatic lock-checking trigger false 
> >  positives, creates an implicit dependency between *_lock_bh and *_lock 
> >  functions as well as making the extremly simply locking of net core even
> >  easier to understand.
> > 
> >  The api inbalance was introduced in:
> >  commit cd28ca0a3dd17c68d24b839602a0e6268ad28b5d
> >  Author: Eric Dumazet <eric.dumazet@gmail.com>
> >  This patch just rebalances the lock api
> > 
> >  No change of functionality
> > 
> > Signed-off-by: Nicholas Mc Guire <der.herr@hofr.at>
> 
> This is a valid locking idiom, fix the lock checking.

for lock checking that is doable but what is with the api coupling and 
readability ?

any change you do to the spin_lock_bh/spin_unlock_bh side would need to also
take care of the spin_lock/spin_unlock variance and keep them functionally 
equivalent - currently there is a very small number of such inbalances in
place it seems (scan of 3.12.1 found 1 write_lock/write_lock_bh, 
2 spin_lock/spin_lock_bh, 0 in read_lock/read_lock_bh) so is this idiomatic extension sensible given that it introduces implicit api-coupling ?

in one of the cases I do not understand the intent behind the split:
in net/core/sock.c:lock_sock_fast

	spin_lock_bh(&sk->sk_lock.slock);
	...
        spin_unlock(&sk->sk_lock.slock);
        /*
         * The sk_lock has mutex_lock() semantics here:
         */
        mutex_acquire(&sk->sk_lock.dep_map, 0, 0, _RET_IP_);
        local_bh_enable();

 I think that 

	spin_lock_bh(&sk->sk_lock.slock);
	...
        /*
         * The sk_lock has mutex_lock() semantics here:
         */
        mutex_acquire(&sk->sk_lock.dep_map, 0, 0, _RET_IP_);
        spin_unlock_bh(&sk->sk_lock.slock);

 should be equivalent ?

thx!
hofrat

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fwd: [PATCH 12/23] e1000: Maybe stop TX if not enough free descriptors
Date: Sun, 24 Sep 2006 21:30:23 +1000
Message-ID: <20060924113023.GA10526@gondor.apana.org.au>
References: <20060919172623.4605.56860.stgit@gitlost.site> <20060919172859.4605.60855.stgit@gitlost.site> <45104719.9080708@pobox.com> <4807377b0609211659mb0cb308hcbc78520148300a1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:29957 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751996AbWIXLal
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Sep 2006 07:30:41 -0400
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Content-Disposition: inline
In-Reply-To: <4807377b0609211659mb0cb308hcbc78520148300a1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 21, 2006 at 04:59:37PM -0700, Jesse Brandeburg wrote:
> Herbert can you help describe why we need this patch on this thread on
> netdev?  We reproduced the race without it and it appears to go away
> with it.

Of course you can resolve it by adding a lock to the txclean path.
However, the advantages of a lockless txclean path is obvious.

Here's the original changelog:

[NETDRV] e1000: Fix potential tx wake up race

Jamal posted a patch which improved e1000 TX performance.  That in
turn spawned a discussion on potential tx wake up races caused by
the change.  During that discussion, Michael Chan posted the following
scenario (redrawn by me for e1000):

CPU0                                    CPU1
e1000_xmit_frame
        tx_lock
        if (tx_ring_empty)
                                        e1000_clean_tx_irq
                                                if (netif_queue_stopped)
                                                        tx_lock
                                                        netif_wake_queue
                                                        tx_unlock
                netif_stop_queue
        tx_unlock

As you can see, even with the locks around netif_wake_queue this still
allows the race to occur because the netif_wake_queue code path is
conditional on netif_queue_stopped.

So here is a patch that uses the memory barriers rather than spin locks
to solve the problem.

First of all I've made netif_wake_queue independent of netif_queue_stopped.
This means that we operate on the stopped bit only once which closes a race
window.

Furthermore, netif_wake_queue itself is already a memory barrier because
it does a test_and_clear_bit.  This means that if the other side can
observe the netif_wake_queue then it can observe the extra room we've
made on the
queue.

On the e1000_xmit_frame side, I've changed netif_stop_queue into a new
function netif_test_and_stop_queue which does test_and_set_bit.  This
means that it also is a full memory barrier.

In order to close the race then, we simply recheck the tx queue size
if netif_test_and_stop_queue returns 0 indicating that the queue was
previously started.  There are two possibilities:

1) netif_wake_queue is about to occur.  In this case it doesn't really
matter what we do as netif_wake_queue will always wake the queue for us.
In the worst case, it'll wake up the queue with too little room but that's
really uncommon and we can cope with that anyway.

2) netif_wake_queue has just occured.  Because it is a memory barrier,
when we recheck the queue size we're guaranteed to see the new indices
which means that we'll see the extra room it has made for us.  As a
result we'll simply restart the queue.

The one wart in the patch is that we now have an unconditional atomic
operation in e1000_clean_tx_irq (netif_wake_queue).  If anyone can
think of a way to get rid of it without opening up the race, please
let us know.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

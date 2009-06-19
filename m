From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/4] virtio_net: return NETDEV_TX_BUSY instead of
	queueing an extra skb.
Date: Fri, 19 Jun 2009 12:36:13 +0800
Message-ID: <20090619043613.GA15163@gondor.apana.org.au>
References: <200905292346.04815.rusty@rustcorp.com.au> <200906181647.51045.rusty@rustcorp.com.au> <20090618073422.GA4087@gondor.apana.org.au> <200906191307.20360.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>,
	Matt Carlson <mcarlson@broadcom.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43142 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751189AbZFSEgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2009 00:36:15 -0400
Content-Disposition: inline
In-Reply-To: <200906191307.20360.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 19, 2009 at 01:07:19PM +0930, Rusty Russell wrote:
>
> You didn't comment on my patch which tried to fix NETDEV_TX_BUSY tho?

I think fixing it would only encourage more drivers to use and
abuse TX_BUSY.  The fundamental problem with TX_BUSY is that
you're doing the check before transmitting a packet instead of
after transmitting it.

Let me explain why this is wrong, beyond the fact that tcpdump
may see the packet twice which you've tried to fix.  The problem
is that requeueing is fundamentally hard.  We use to have this
horrible logic in the schedulers to handle this.  Thankfully that
seems to have been replaced with a single device-level packet
holder shared with GSO.

However, that is still wrong for many packet schedulers.  For
example, if the requeued packet is of a lower priority, and a
higher priority packet comes along, we want the higher priority
packet to preempt the requeued packet.  Right now it just doesn't
happen.

This is not as trivial as it seems because on a busy host this can
happen many times a second.  With TX_BUSY the QoS guarantees are
simply not workable.

BTW you pointed out that GSO also uses TX_BUSY, but that is
different because the packet schedulers treat a GSO packet as
a single entity so there is no issue of preemption.  Also tcpdump
will never see it twice by design.

> e1000/e1000_main.c: fifo bug workaround?

The workaround should work just as well as a stop-queue check
after packet transmission.

> ehea/ehea_main.c: ?

Ahh! The bastard LLTX drivers are still around.  LLTX was the
worst abuse associated with TX_BUSY.  Thankfully not many of them
are left.

The fix is to not use LLTX and use the xmit_lock like normal
drivers.

> starfire.c: "we may not have enough slots even when it seems we do."?

Just replace skb_num_frags with SKB_MAX_FRAGS and move the check
after the transmit.

> tg3.c: tg3_gso_bug

A better solution would in fact be to disable hardware TSO when
we encounter such a packet (and drop the first one).

Because once you get one you're likely to get a lot more.  The
difference between hardware TSO and GSO on a card like tg3 is
negligible anyway.

Alternatively just disable TSO completely on those chips.

Ccing the tg3 maintainer.
 
> We provided an API, people used it.  Constantly trying to disclaim our 
> responsibility for the resulting mess makes me fucking ANGRY.

Where have I disclaimed responsibility? If we were doing that
then we wouldn't be having this discussion.

> We either remove the API, or fix it.  I think fixing it is better, because my 
> driver will be simpler and it's obvious noone wants to rewrite 50 drivers and 
> break several of them.

My preference is obviously in the long term removal of TX_BUSY.
Due to resource constraints that cannot be done immediately.  So
at least we should try to stop its proliferation.

BTW removing TX_BUSY does not mean that your driver has to stay
complicated.  As I have said repeatedly your driver should be
checking the stop-queue condition after transmission, not before.

In fact queueing it in the driver is just as bad as return TX_BUSY!

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

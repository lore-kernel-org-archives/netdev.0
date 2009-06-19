From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/4] virtio_net: return NETDEV_TX_BUSY instead of
	queueing an extra skb.
Date: Fri, 19 Jun 2009 22:10:14 +0800
Message-ID: <20090619141014.GA19828@gondor.apana.org.au>
References: <200905292346.04815.rusty@rustcorp.com.au> <200906191307.20360.rusty@rustcorp.com.au> <20090619043613.GA15163@gondor.apana.org.au> <200906192320.44904.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>,
	Matt Carlson <mcarlson@broadcom.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46382 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751559AbZFSOKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2009 10:10:14 -0400
Content-Disposition: inline
In-Reply-To: <200906192320.44904.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 19, 2009 at 11:20:44PM +0930, Rusty Russell wrote:
>
> Your use of the word guarantee here indicates an idealized concept of QoS 
> which cannot exist on any NIC which has a queue.  We should try to approach 
> the ideal, but understand we cannot reach it.

I'm just pointing out that it's better to not have to do this.

Since TX_BUSY and requeueing the packet is unnecessary in the
first place because we can avoid it by managing the stop-queue
action properly, there is no reason to do this because of its
downsides.

> On the other hand, we're underutilizing the queue to avoid it.  I find that a 
> little embarrassing.

Here's why I think this is not an issue.  If your NIC is high
bandwidth then your ring is going to have to be huge so the
amount that is underutilised (a 64K packet) is tiny.  If your
NIC is low bandwidth then this is where you often need QoS and
in that case you do *NOT* want to fully utilise the HW queue.

> I feel we're being horribly deceptive by giving them a nice API, and upon 
> review, telling them "don't use that".  And it's been ongoing for far too 
> long.

If you look at our API documentation it actually says:

        Return codes:
        o NETDEV_TX_OK everything ok.
        o NETDEV_TX_BUSY Cannot transmit packet, try later
          Usually a bug, means queue start/stop flow control is broken in
          the driver. Note: the driver must NOT put the skb in its DMA ring.
        o NETDEV_TX_LOCKED Locking failed, please retry quickly.
          Only valid when NETIF_F_LLTX is set.

So I don't feel too bad :)

> > In fact queueing it in the driver is just as bad as return TX_BUSY!
> 
> Agreed (modulo the tcpdump issue).  And worse, because it's ugly and complex!

The right solution is to stop the queue properly.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

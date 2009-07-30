From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] 3c515: Write outside array bounds
Date: Thu, 30 Jul 2009 12:26:32 +0200
Message-ID: <4A717558.2050407@gmail.com>
References: <4A6B88B1.9000907@gmail.com> <4A6CC7BD.9020602@gmail.com> <4A705904.4020505@gmail.com> <20090729204300.GC3058@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:27143 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752183AbZG3KXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 06:23:36 -0400
Received: by ey-out-2122.google.com with SMTP id 9so356031eyd.37
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2009 03:23:36 -0700 (PDT)
In-Reply-To: <20090729204300.GC3058@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

if dev_alloc_skb() fails on the first iteration, a write to
cp->rx_ring[-1] occurs.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
>>>> can we error return like this?
>>>
>>> I doubt we can return here: there is a lot of cleaning missing.

>> I took drivers/net/3c59x.c as an example
>>
>> Is this going in the right direction?
> 
> The direction is right but a long and winding road... I guess it's for
> somebody with drivers knowhow. It seems most of the corkscrew_close()
> might be needed, including del_timer(). So, since this -1 case looks
> quite unlikely, it might be reasonable to only limit the most obvious
> damage with 'if (i != 0)' before [i - 1] write, like David advised
> in lmc case?
> 
> Cheers,
> Jarek P.

Thanks, here it is:

diff --git a/drivers/net/3c515.c b/drivers/net/3c515.c
index 3e00fa8..4a7c328 100644
--- a/drivers/net/3c515.c
+++ b/drivers/net/3c515.c
@@ -832,7 +832,9 @@ static int corkscrew_open(struct net_device *dev)
 			skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
 			vp->rx_ring[i].addr = isa_virt_to_bus(skb->data);
 		}
-		vp->rx_ring[i - 1].next = isa_virt_to_bus(&vp->rx_ring[0]);	/* Wrap the ring. */
+		if (i != 0)
+			vp->rx_ring[i - 1].next =
+				isa_virt_to_bus(&vp->rx_ring[0]);	/* Wrap the ring. */
 		outl(isa_virt_to_bus(&vp->rx_ring[0]), ioaddr + UpListPtr);
 	}
 	if (vp->full_bus_master_tx) {	/* Boomerang bus master Tx. */

From: roel kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] korina: Read buffer overflow
Date: Sat, 8 Aug 2009 15:14:57 +0200
Message-ID: <25e057c00908080614q6d7efa3x46789e51b0b544b3@mail.gmail.com>
References: <4A7C494B.2060204@gmail.com>
	 <20090808004815.F10394CEAA@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Roel Kluin <roel.kluin@gmail.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f228.google.com ([209.85.220.228]:44031 "EHLO
	mail-fx0-f228.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934127AbZHHNO5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Aug 2009 09:14:57 -0400
Received: by fxm28 with SMTP id 28so229786fxm.17
        for <netdev@vger.kernel.org>; Sat, 08 Aug 2009 06:14:57 -0700 (PDT)
In-Reply-To: <20090808004815.F10394CEAA@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> If the loop breaks with an i of 0, then we read lp->rd_ring[-1].

>> @@ -771,7 +771,7 @@ static void korina_alloc_ring(struct net_device =
*dev)
>> =A0 =A0 =A0 for (i =3D 0; i < KORINA_NUM_RDS; i++) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D dev_alloc_skb(KORINA_RBSIZE + 2)=
;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!skb)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_free;
>
> This implies that all KORINA_NUM_TDS receive descriptors need to be
> available for the driver to work.

> Also I guess there should be some error handling, as the driver proba=
bly
> wont be useful without a single receive descriptor. What do you think
> about the following:

A few comments:

> | diff --git a/drivers/net/korina.c b/drivers/net/korina.c
> | index a2701f5..d1c5276 100644
> | --- a/drivers/net/korina.c
> | +++ b/drivers/net/korina.c

> | @@ -772,6 +772,13 @@ static void korina_alloc_ring(struct net_devic=
e *dev)
> | =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->rd_ring[i].ca =3D CPHYSADDR(skb->da=
ta);
> | =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->rd_ring[i].link =3D CPHYSADDR(&lp->=
rd_ring[i+1]);
> | =A0 =A0 =A0 }
> | + =A0 =A0 if (!i) {
> | + =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR DRV_NAME "%s: could not a=
llocate a single"
> | + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 " receive=
 descriptor\n", dev->name)

            printk(KERN_ERR "%s: could not allocate a single receive
descriptor\n",
                            dev->name);

Don't interrupt strings, they are an exception in the 80 character
limit (since they are
easier to grep that way). Also I think the DRV_NAME should be omitted, =
Doesn't
`DRV_NAME "%s:...\n", dev->name)' result in "korinakorina:..."? It
occurs at more
places in the file. Also a semicolon was missing.

> | + =A0 =A0 =A0 =A0 =A0 =A0 return 1;

I think -ENOMEM is more appropriate.

> | + =A0 =A0 }
> | + =A0 =A0 printk(KERN_DEBUG DRV_NAME "%s: allocated %d receive desc=
riptors\n",
> | + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->name, i);

same `DRV_NAME "%s:...\n", dev->name)' issue.

> | @@ -824,7 +833,8 @@ static int korina_init(struct net_device *dev)
> | =A0 =A0 =A0 writel(ETH_INT_FC_EN, &lp->eth_regs->ethintfc);
> |
> | =A0 =A0 =A0 /* Allocate rings */
> | - =A0 =A0 korina_alloc_ring(dev);
> | + =A0 =A0 if (korina_alloc_ring(dev))
> | + =A0 =A0 =A0 =A0 =A0 =A0 return 1;

-ENOMEM

> |
> | =A0 =A0 =A0 writel(0, &lp->rx_dma_regs->dmas);
> | =A0 =A0 =A0 /* Start Rx DMA */
>
> Greetings, Phil

Otherwise looks fine to me.

Thanks,

Roel

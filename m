From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] gianfar: fix potential sk_wmem_alloc imbalance
Date: Sun, 08 Jul 2012 11:09:02 +0200
Message-ID: <1341738542.3265.1406.camel@edumazet-glaptop>
References: <1341524713.3265.41.camel@edumazet-glaptop>
	 <20120706180947.GI1817@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Manfred Rudigier <manfred.rudigier@omicron.at>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Jiajun Wu <b06378@freescale.com>,
	Andy Fleming <afleming@freescale.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:37569 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013Ab2GHJJJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jul 2012 05:09:09 -0400
Received: by wgbdr13 with SMTP id dr13so10523690wgb.1
        for <netdev@vger.kernel.org>; Sun, 08 Jul 2012 02:09:07 -0700 (PDT)
In-Reply-To: <20120706180947.GI1817@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-06 at 14:09 -0400, Paul Gortmaker wrote:

> Aside from the one line change at driver init, is there more to it than
> that?  More specifically, it currently does:
> 
> fcb_length = GMAC_FCB_LEN;
> 
> if (...timestamps...)
> 	fcb_length = GMAC_FCB_LEN + GMAC_TXPAL_LEN;
> 
> if (... && (skb_headroom(skb) < fcb_length))
> 	...
> 	skb_new = skb_realloc_headroom(skb, fcb_length);
> 
> and I don't know the code well enough to know if setting the
> needed_headroom value _guarantees_ the above fcb_length comparison
> will always be false, and hence can be deleted.  It kind of looks
> like it via LL_RESERVED_SPACE, but I'm not 100% sure...

This is not a guarantee but should take care of most cases.

So we should keep the test anyway.

And init needed_headroom to the largest room. Existing tests seems to
ignore vlan case and timestamping.

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index af16f9f..b4517b7 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1084,9 +1084,7 @@ static int gfar_probe(struct platform_device *ofdev)
 	else
 		priv->padding = 0;
 
-	if (dev->features & NETIF_F_IP_CSUM ||
-	    priv->device_flags & FSL_GIANFAR_DEV_HAS_TIMER)
-		dev->needed_headroom = GMAC_FCB_LEN;
+	dev->needed_headroom = GMAC_FCB_LEN + GMAC_TXPAL_LEN;
 
 	/* Program the isrg regs only if number of grps > 1 */
 	if (priv->num_grps > 1) {

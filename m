From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] GRE: Use IS_ERR_OR_NULL in gre_gso_segment
Date: Thu, 25 Apr 2013 06:58:34 -0700
Message-ID: <1366898314.8964.135.camel@edumazet-glaptop>
References: <20130423075042.GA25776@verge.net.au>
	 <CAEP_g=93aAXPk+A2u7LzAzEk6Fr33y7HiEMmXBCEkD8+B90kZQ@mail.gmail.com>
	 <20130425084617.GA27463@gondor.apana.org.au>
	 <20130425.050157.1080837692941670798.davem@davemloft.net>
	 <20130425090346.GA27618@gondor.apana.org.au>
	 <20130425091151.GA27681@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jesse@nicira.com,
	horms@verge.net.au, netdev@vger.kernel.org, xeb@mail.ru
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:46118 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758693Ab3DYN6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 09:58:37 -0400
Received: by mail-pd0-f172.google.com with SMTP id 4so1832946pdd.31
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 06:58:36 -0700 (PDT)
In-Reply-To: <20130425091151.GA27681@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-25 at 17:11 +0800, Herbert Xu wrote:

> In any case, returning an error in this case makes little sense
> because when we return NULL it is precisely because the packet is
> well-formed and ready for direct processing by the hardware which
> will perform GSO instead of us.
> 
> The reason this dichotomy exists is because we've reused the
> normal software GSO path to do header verification for hardware
> GSO.
> 

OK, then current code is fine. Comments will save future 'cleanups'.

diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
index d2d5a99..ddf72eb 100644
--- a/net/ipv4/gre.c
+++ b/net/ipv4/gre.c
@@ -168,7 +168,11 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	/* segment inner packet. */
 	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
 	segs = skb_mac_gso_segment(skb, enc_features);
-	if (!segs || IS_ERR(segs))
+	/* if no segmentation is needed, we're done */
+	if (!segs)
+		goto out;
+	/* if an error happened during segmentation, we're done */
+	if (IS_ERR(segs))
 		goto out;
 
 	skb = segs;

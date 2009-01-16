From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: net: Add debug info to track down GSO checksum bug
Date: Fri, 16 Jan 2009 18:22:51 +1100
Message-ID: <20090116072251.GA13327@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45534 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750895AbZAPHWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 02:22:55 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

net: Add debug info to track down GSO checksum bug

I'm trying to track down why people're hitting the checksum warning
in skb_gso_segment.  As the problem seems to be hitting lots of
people and I can't reproduce it or locate the bug, here is a patch
to print out more details which hopefully should help us to track
this down.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/dev.c b/net/core/dev.c
index b715a55..752dd11 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1534,7 +1534,19 @@ struct sk_buff *skb_gso_segment(struct sk_buff *skb, int features)
 	skb->mac_len = skb->network_header - skb->mac_header;
 	__skb_pull(skb, skb->mac_len);
 
-	if (WARN_ON(skb->ip_summed != CHECKSUM_PARTIAL)) {
+	if (unlikely(skb->ip_summed != CHECKSUM_PARTIAL)) {
+		struct net_device *dev = skb->dev;
+		struct ethtool_drvinfo info = {};
+
+		if (dev && dev->ethtool_ops && dev->ethtool_ops->get_drvinfo)
+			dev->ethtool_ops->get_drvinfo(dev, &info);
+
+		WARN(1, "%s: caps=(0x%lx, 0x%lx) len=%d data_len=%d "
+			"ip_summed=%d",
+		     info.driver, dev ? dev->features : 0L,
+		     skb->sk ? skb->sk->sk_route_caps : 0L,
+		     skb->len, skb->data_len, skb->ip_summed);
+
 		if (skb_header_cloned(skb) &&
 		    (err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
 			return ERR_PTR(err);

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

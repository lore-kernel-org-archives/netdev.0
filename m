From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: gso: Stop fraglists from escaping
Date: Thu, 4 Jun 2009 11:01:21 +1000
Message-ID: <20090604010121.GA22871@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44488 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752239AbZFDBBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 21:01:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

gso: Stop fraglists from escaping

As it stands skb fraglists can get past the check in dev_queue_xmit
if the skb is marked as GSO.  In particular, if the packet doesn't
have the proper checksums for GSO, but can otherwise be handled by
the underlying device, we will not perform the fraglist check on it
at all.

If the underlying device cannot handle fraglists, then this will
break.

The fix is as simple as moving the fraglist check from the device
check into skb_gso_ok.

This has caused crashes with Xen when used together with GRO which
can generate GSO packets with fraglists.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5a96a1a..a28daad 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1856,15 +1856,14 @@ static inline int net_gso_ok(int features, int gso_type)
 
 static inline int skb_gso_ok(struct sk_buff *skb, int features)
 {
-	return net_gso_ok(features, skb_shinfo(skb)->gso_type);
+	return net_gso_ok(features, skb_shinfo(skb)->gso_type) &&
+	       (!skb_shinfo(skb)->frag_list || (features & NETIF_F_FRAGLIST));
 }
 
 static inline int netif_needs_gso(struct net_device *dev, struct sk_buff *skb)
 {
 	return skb_is_gso(skb) &&
 	       (!skb_gso_ok(skb, dev->features) ||
-	        (skb_shinfo(skb)->frag_list &&
-	         !(dev->features & NETIF_F_FRAGLIST)) ||
 		unlikely(skb->ip_summed != CHECKSUM_PARTIAL));
 }
 
Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

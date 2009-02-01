From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: gro: Fix handling of imprecisely split packets
Date: Sun, 1 Feb 2009 18:01:17 +1100
Message-ID: <20090201070117.GA2200@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35638 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750993AbZBAHBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2009 02:01:25 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff:

Please let me know if the ixgbe problems persist with this patch
against net-next.

gro: Fix handling of imprecisely split packets

The commit 89a1b249edcf9be884e71f92df84d48355c576aa (gro: Avoid
copying headers of unmerged packets) only worked for packets
which are either completely linear, completely non-linear, or
packets which exactly split at the boundary between headers and
payload.

Anything else would cause bits in the header to go missing if
the packet is held by GRO.

This may have broken drivers such as ixgbe.

This patch fixes the places that assumed or only worked with
the above cases.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/dev.c b/net/core/dev.c
index dd56c32..089c7c9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -217,7 +217,7 @@ static inline struct hlist_head *dev_index_hash(struct net *net, int ifindex)
 
 static inline void *skb_gro_mac_header(struct sk_buff *skb)
 {
-	return skb_headlen(skb) ? skb_mac_header(skb) :
+	return skb_mac_header(skb) < skb->data ? skb_mac_header(skb) :
 	       page_address(skb_shinfo(skb)->frags[0].page) +
 	       skb_shinfo(skb)->frags[0].page_offset;
 }
@@ -2479,11 +2479,19 @@ int dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	napi->gro_list = skb;
 	ret = GRO_HELD;
 
+pull:
+	if (unlikely(!pskb_may_pull(skb, skb_gro_offset(skb)))) {
+		if (napi->gro_list == skb)
+			napi->gro_list = skb->next;
+		ret = GRO_DROP;
+	}
+
 ok:
 	return ret;
 
 normal:
-	return GRO_NORMAL;
+	ret = GRO_NORMAL;
+	goto pull;
 }
 EXPORT_SYMBOL(dev_gro_receive);
 
@@ -2599,14 +2607,10 @@ EXPORT_SYMBOL(napi_fraginfo_skb);
 int napi_frags_finish(struct napi_struct *napi, struct sk_buff *skb, int ret)
 {
 	int err = NET_RX_SUCCESS;
-	int may;
 
 	switch (ret) {
 	case GRO_NORMAL:
 	case GRO_HELD:
-		may = pskb_may_pull(skb, skb_gro_offset(skb));
-		BUG_ON(!may);
-
 		skb->protocol = eth_type_trans(skb, napi->dev);
 
 		if (ret == GRO_NORMAL)

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/8] net: Add frag_list support to GSO
Date: Sat, 13 Dec 2008 12:35:20 +1100
Message-ID: <E1LBJPc-0003YL-7r@gondolin.me.apana.org.au>
References: <20081213013420.GA13549@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53830 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753579AbYLMBfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 20:35:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net: Add frag_list support to GSO

This patch allows GSO to handle frag_list in a limited way for the
purposes of allowing packets merged by GRO to be refragmented on
output.

Most hardware won't (and aren't expected to) support handling GRO
frag_list packets directly.  Therefore we will perform GSO in
software for those cases.

However, for drivers that can support it (such as virtual NICs) we
may not have to segment the packets at all.

Whether the added overhead of GRO/GSO is worthwhile for bridges
and routers when weighed against the benefit of potentially
increasing the MTU within the host is still an open question.
However, for the case of host nodes this is undoubtedly a win.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/netdevice.h |    2 ++
 net/core/dev.c            |    2 --
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9d77b1d..8bf9127 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1724,6 +1724,8 @@ static inline int netif_needs_gso(struct net_device *dev, struct sk_buff *skb)
 {
 	return skb_is_gso(skb) &&
 	       (!skb_gso_ok(skb, dev->features) ||
+	        (skb_shinfo(skb)->frag_list &&
+	         !(dev->features & NETIF_F_FRAGLIST)) ||
 		unlikely(skb->ip_summed != CHECKSUM_PARTIAL));
 }
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 9174c77..4388e27 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1527,8 +1527,6 @@ struct sk_buff *skb_gso_segment(struct sk_buff *skb, int features)
 	__be16 type = skb->protocol;
 	int err;
 
-	BUG_ON(skb_shinfo(skb)->frag_list);
-
 	skb_reset_mac_header(skb);
 	skb->mac_len = skb->network_header - skb->mac_header;
 	__skb_pull(skb, skb->mac_len);

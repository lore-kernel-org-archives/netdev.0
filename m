From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/2] net: Add __dev_forward_skb
Date: Thu, 17 Apr 2014 13:45:03 +0800
Message-ID: <20140417054502.GA23959@gondor.apana.org.au>
References: <20140407075347.GA26461@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:55166 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754880AbaDQFpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2014 01:45:07 -0400
Content-Disposition: inline
In-Reply-To: <20140407075347.GA26461@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the helper __dev_forward_skb which is identical to
dev_forward_skb except that it doesn't actually inject the skb into
the stack.  This is useful where we wish to have finer control over
how the packet is injected, e.g., via netif_rx_ni or netif_receive_skb.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/netdevice.h |    1 +
 net/core/dev.c            |   42 ++++++++++++++++++++++++------------------
 2 files changed, 25 insertions(+), 18 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 775cc95..4ab86d1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2619,6 +2619,7 @@ int dev_get_phys_port_id(struct net_device *dev,
 			 struct netdev_phys_port_id *ppid);
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			struct netdev_queue *txq);
+int __dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
 int dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
 bool is_skb_forwardable(struct net_device *dev, struct sk_buff *skb);
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 7570634..bd6ca09 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1661,6 +1661,29 @@ bool is_skb_forwardable(struct net_device *dev, struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(is_skb_forwardable);
 
+int __dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
+{
+	if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
+		if (skb_copy_ubufs(skb, GFP_ATOMIC)) {
+			atomic_long_inc(&dev->rx_dropped);
+			kfree_skb(skb);
+			return NET_RX_DROP;
+		}
+	}
+
+	if (unlikely(!is_skb_forwardable(dev, skb))) {
+		atomic_long_inc(&dev->rx_dropped);
+		kfree_skb(skb);
+		return NET_RX_DROP;
+	}
+
+	skb_scrub_packet(skb, true);
+	skb->protocol = eth_type_trans(skb, dev);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(__dev_forward_skb);
+
 /**
  * dev_forward_skb - loopback an skb to another netif
  *
@@ -1681,24 +1704,7 @@ EXPORT_SYMBOL_GPL(is_skb_forwardable);
  */
 int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 {
-	if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
-		if (skb_copy_ubufs(skb, GFP_ATOMIC)) {
-			atomic_long_inc(&dev->rx_dropped);
-			kfree_skb(skb);
-			return NET_RX_DROP;
-		}
-	}
-
-	if (unlikely(!is_skb_forwardable(dev, skb))) {
-		atomic_long_inc(&dev->rx_dropped);
-		kfree_skb(skb);
-		return NET_RX_DROP;
-	}
-
-	skb_scrub_packet(skb, true);
-	skb->protocol = eth_type_trans(skb, dev);
-
-	return netif_rx_internal(skb);
+	return __dev_forward_skb(dev, skb) ?: netif_rx_internal(skb);
 }
 EXPORT_SYMBOL_GPL(dev_forward_skb);
 
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

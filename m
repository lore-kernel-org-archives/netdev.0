From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH v2 net-next 1/2] dev: introduce skb_scrub_packet()
Date: Tue, 25 Jun 2013 16:24:54 +0200
Message-ID: <1372170295-4717-2-git-send-email-nicolas.dichtel@6wind.com>
References: <51C9A4E3.2060906@6wind.com>
 <1372170295-4717-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com, bcrl@kvack.org,
	ravi.mlists@gmail.com, bhutchings@solarflare.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:40736 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751891Ab3FYO3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 10:29:48 -0400
In-Reply-To: <1372170295-4717-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of this new function is to perform all needed cleanup before sending
an skb into another netns.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/skbuff.h |  1 +
 net/core/dev.c         | 11 +----------
 net/core/skbuff.c      | 23 +++++++++++++++++++++++
 3 files changed, 25 insertions(+), 10 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index a7393ad..6b06023 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2384,6 +2384,7 @@ extern void	       skb_split(struct sk_buff *skb,
 				 struct sk_buff *skb1, const u32 len);
 extern int	       skb_shift(struct sk_buff *tgt, struct sk_buff *skb,
 				 int shiftlen);
+extern void	       skb_scrub_packet(struct sk_buff *skb);
 
 extern struct sk_buff *skb_segment(struct sk_buff *skb,
 				   netdev_features_t features);
diff --git a/net/core/dev.c b/net/core/dev.c
index 722f633..370354a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1652,22 +1652,13 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 		}
 	}
 
-	skb_orphan(skb);
-
 	if (unlikely(!is_skb_forwardable(dev, skb))) {
 		atomic_long_inc(&dev->rx_dropped);
 		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
-	skb->skb_iif = 0;
-	skb_dst_drop(skb);
-	skb->tstamp.tv64 = 0;
-	skb->pkt_type = PACKET_HOST;
+	skb_scrub_packet(skb);
 	skb->protocol = eth_type_trans(skb, dev);
-	skb->mark = 0;
-	secpath_reset(skb);
-	nf_reset(skb);
-	nf_reset_trace(skb);
 	return netif_rx(skb);
 }
 EXPORT_SYMBOL_GPL(dev_forward_skb);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 9f73eca..b1fcb87 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3492,3 +3492,26 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
 	return true;
 }
 EXPORT_SYMBOL(skb_try_coalesce);
+
+/**
+ * skb_scrub_packet - scrub an skb before sending it to another netns
+ *
+ * @skb: buffer to clean
+ *
+ * skb_scrub_packet can be used to clean an skb before injecting it in
+ * another namespace. We have to clear all information in the skb that
+ * could impact namespace isolation.
+ */
+void skb_scrub_packet(struct sk_buff *skb)
+{
+	skb_orphan(skb);
+	skb->tstamp.tv64 = 0;
+	skb->pkt_type = PACKET_HOST;
+	skb->skb_iif = 0;
+	skb_dst_drop(skb);
+	skb->mark = 0;
+	secpath_reset(skb);
+	nf_reset(skb);
+	nf_reset_trace(skb);
+}
+EXPORT_SYMBOL_GPL(skb_scrub_packet);
-- 
1.8.2.1

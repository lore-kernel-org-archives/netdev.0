From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH net-next 1/2] dev: introduce dev_cleanup_skb()
Date: Mon, 24 Jun 2013 16:13:58 +0200
Message-ID: <1372083239-9451-2-git-send-email-nicolas.dichtel@6wind.com>
References: <87y5ijd98e.fsf@xmission.com>
 <1372083239-9451-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com, bcrl@kvack.org,
	ravi.mlists@gmail.com, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:37612 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751112Ab3FXOOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 10:14:20 -0400
In-Reply-To: <1372083239-9451-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of this new function is to perform all needed cleanup before sending
an skb into another netns.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/netdevice.h |  1 +
 net/core/dev.c            | 34 ++++++++++++++++++++++++----------
 2 files changed, 25 insertions(+), 10 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 09b4188..9b72d87 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2321,6 +2321,7 @@ extern int		dev_hard_start_xmit(struct sk_buff *skb,
 					    struct netdev_queue *txq);
 extern int		dev_forward_skb(struct net_device *dev,
 					struct sk_buff *skb);
+extern void		dev_cleanup_skb(struct sk_buff *skb);
 
 extern int		netdev_budget;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 722f633..d30bc22 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1625,6 +1625,29 @@ static inline bool is_skb_forwardable(struct net_device *dev,
 }
 
 /**
+ * dev_cleanup_skb - cleanup an skb before sending it to another netns
+ *
+ * @skb: buffer to clean
+ *
+ * dev_cleanup_skb can be used to clean an skb before injecting it in
+ * another namespace. We have to clear all information in the skb that
+ * could impact namespace isolation.
+ */
+void dev_cleanup_skb(struct sk_buff *skb)
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
+EXPORT_SYMBOL_GPL(dev_cleanup_skb);
+
+/**
  * dev_forward_skb - loopback an skb to another netif
  *
  * @dev: destination network device
@@ -1652,22 +1675,13 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
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
+	dev_cleanup_skb(skb);
 	skb->protocol = eth_type_trans(skb, dev);
-	skb->mark = 0;
-	secpath_reset(skb);
-	nf_reset(skb);
-	nf_reset_trace(skb);
 	return netif_rx(skb);
 }
 EXPORT_SYMBOL_GPL(dev_forward_skb);
-- 
1.8.2.1

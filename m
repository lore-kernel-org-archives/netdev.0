From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net 2/3] netdevice: move netdev_cap_txqueue for shared usage to header
Date: Sun, 16 Feb 2014 15:55:21 +0100
Message-ID: <1392562522-15585-3-git-send-email-dborkman@redhat.com>
References: <1392562522-15585-1-git-send-email-dborkman@redhat.com>
Cc: brouer@redhat.com, mathias.kretschmer@fokus.fraunhofer.de,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19655 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752508AbaBPOzd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Feb 2014 09:55:33 -0500
In-Reply-To: <1392562522-15585-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to allow users to invoke netdev_cap_txqueue, it needs to
be moved into netdevice.h header file. While at it, also add kernel
doc header to document the API.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/linux/netdevice.h | 20 ++++++++++++++++++++
 net/core/flow_dissector.c | 13 +------------
 2 files changed, 21 insertions(+), 12 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1de9c13..e8eeebd 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2279,6 +2279,26 @@ static inline void netdev_reset_queue(struct net_device *dev_queue)
 }
 
 /**
+ * 	netdev_cap_txqueue - check if selected tx queue exceeds device queues
+ * 	@dev: network device
+ * 	@queue_index: given tx queue index
+ *
+ * 	Returns 0 if given tx queue index >= number of device tx queues,
+ * 	otherwise returns the originally passed tx queue index.
+ */
+static inline u16 netdev_cap_txqueue(struct net_device *dev, u16 queue_index)
+{
+	if (unlikely(queue_index >= dev->real_num_tx_queues)) {
+		net_warn_ratelimited("%s selects TX queue %d, but real number of TX queues is %d\n",
+				     dev->name, queue_index,
+				     dev->real_num_tx_queues);
+		return 0;
+	}
+
+	return queue_index;
+}
+
+/**
  *	netif_running - test if up
  *	@dev: network device
  *
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 75fe83f..e29e810 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -323,17 +323,6 @@ u32 __skb_get_poff(const struct sk_buff *skb)
 	return poff;
 }
 
-static inline u16 dev_cap_txqueue(struct net_device *dev, u16 queue_index)
-{
-	if (unlikely(queue_index >= dev->real_num_tx_queues)) {
-		net_warn_ratelimited("%s selects TX queue %d, but real number of TX queues is %d\n",
-				     dev->name, queue_index,
-				     dev->real_num_tx_queues);
-		return 0;
-	}
-	return queue_index;
-}
-
 static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
 {
 #ifdef CONFIG_XPS
@@ -408,7 +397,7 @@ struct netdev_queue *netdev_pick_tx(struct net_device *dev,
 			queue_index = __netdev_pick_tx(dev, skb);
 
 		if (!accel_priv)
-			queue_index = dev_cap_txqueue(dev, queue_index);
+			queue_index = netdev_cap_txqueue(dev, queue_index);
 	}
 
 	skb_set_queue_mapping(skb, queue_index);
-- 
1.7.11.7

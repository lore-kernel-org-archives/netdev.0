From: David Ahern <dsa@cumulusnetworks.com>
Subject: [RFC PATCH net-next 1/3] net: Introduce L3 RX Handler
Date: Fri, 28 Aug 2015 17:34:21 -0700
Message-ID: <1440808463-14526-2-git-send-email-dsa@cumulusnetworks.com>
References: <1440808463-14526-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33600 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753128AbbH2Aea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 20:34:30 -0400
Received: by pacgr6 with SMTP id gr6so4636303pac.0
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 17:34:30 -0700 (PDT)
In-Reply-To: <1440808463-14526-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current rx_handler approach was introduced for bonding, bridging, etc.
For L3 devices like VRF it would be better to intercept the packet at the
L3 layer. This patch adds a new handler to be invoked by the L3 protocol.

For the RFC I re-use the existing data_handler and only allow 1 of the
rx_handlers to be set. This could be expanded to alllow both intercepts
if desired.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/linux/netdevice.h |  6 ++++++
 net/core/dev.c            | 55 ++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 51 insertions(+), 10 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 6abe0d6f1e1d..c1b5a651a32f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1451,6 +1451,8 @@ enum netdev_priv_flags {
  *	@real_num_rx_queues: 	Number of RX queues currently active in device
  *
  *	@rx_handler:		handler for received packets
+ *	@l3_rx_handler:		L3 handler for received packets
+ *				Only rx_handler OR l3_rx_handler can be set
  *	@rx_handler_data: 	XXX: need comments on this one
  *	@ingress_queue:		XXX: need comments on this one
  *	@broadcast:		hw bcast address
@@ -1683,6 +1685,7 @@ struct net_device {
 
 	unsigned long		gro_flush_timeout;
 	rx_handler_func_t __rcu	*rx_handler;
+	rx_handler_func_t __rcu	*l3_rx_handler;
 	void __rcu		*rx_handler_data;
 
 #ifdef CONFIG_NET_CLS_ACT
@@ -3015,6 +3018,9 @@ static inline void napi_free_frags(struct napi_struct *napi)
 int netdev_rx_handler_register(struct net_device *dev,
 			       rx_handler_func_t *rx_handler,
 			       void *rx_handler_data);
+int netdev_l3_rx_handler_register(struct net_device *dev,
+				  rx_handler_func_t *rx_handler,
+				  void *rx_handler_data);
 void netdev_rx_handler_unregister(struct net_device *dev);
 
 bool dev_valid_name(const char *name);
diff --git a/net/core/dev.c b/net/core/dev.c
index 7bb24f1879b8..5698f43f9c5b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3675,6 +3675,26 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 	return skb;
 }
 
+static int __netdev_rx_handler_register(struct net_device *dev,
+					rx_handler_func_t *rx_handler,
+					void *rx_handler_data,
+					bool l3_hdlr)
+{
+	ASSERT_RTNL();
+
+	if (dev->rx_handler || dev->l3_rx_handler)
+		return -EBUSY;
+
+	/* Note: rx_handler_data must be set before rx_handler */
+	rcu_assign_pointer(dev->rx_handler_data, rx_handler_data);
+	if (l3_hdlr)
+		rcu_assign_pointer(dev->l3_rx_handler, rx_handler);
+	else
+		rcu_assign_pointer(dev->rx_handler, rx_handler);
+
+	return 0;
+}
+
 /**
  *	netdev_rx_handler_register - register receive handler
  *	@dev: device to register a handler for
@@ -3693,20 +3713,35 @@ int netdev_rx_handler_register(struct net_device *dev,
 			       rx_handler_func_t *rx_handler,
 			       void *rx_handler_data)
 {
-	ASSERT_RTNL();
-
-	if (dev->rx_handler)
-		return -EBUSY;
-
-	/* Note: rx_handler_data must be set before rx_handler */
-	rcu_assign_pointer(dev->rx_handler_data, rx_handler_data);
-	rcu_assign_pointer(dev->rx_handler, rx_handler);
-
-	return 0;
+	return __netdev_rx_handler_register(dev, rx_handler,
+					    rx_handler_data, 0);
 }
 EXPORT_SYMBOL_GPL(netdev_rx_handler_register);
 
 /**
+ *	netdev_l3_rx_handler_register - register L3 receive handler
+ *	@dev: device to register a handler for
+ *	@rx_handler: receive handler to register
+ *	@rx_handler_data: data pointer that is used by rx handler
+ *
+ *	Register a receive handler for a device. This handler will then be
+ *	called from __netif_receive_skb. A negative errno code is returned
+ *	on a failure.
+ *
+ *	The caller must hold the rtnl_mutex.
+ *
+ *	For a general description of rx_handler, see enum rx_handler_result.
+ */
+int netdev_l3_rx_handler_register(struct net_device *dev,
+				  rx_handler_func_t *rx_handler,
+				  void *rx_handler_data)
+{
+	return __netdev_rx_handler_register(dev, rx_handler,
+					    rx_handler_data, 1);
+}
+EXPORT_SYMBOL_GPL(netdev_l3_rx_handler_register);
+
+/**
  *	netdev_rx_handler_unregister - unregister receive handler
  *	@dev: device to unregister a handler from
  *
-- 
1.9.1

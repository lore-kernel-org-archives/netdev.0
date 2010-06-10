From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6 1/3] net: add rx_handler data pointer
Date: Thu, 10 Jun 2010 15:34:59 +0200
Message-ID: <20100610133458.GD2618@psychotron.lab.eng.brq.redhat.com>
References: <20100610133412.GC2618@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shemminger@vyatta.com, kaber@trash.net,
	eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43255 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758492Ab0FJNfE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jun 2010 09:35:04 -0400
Content-Disposition: inline
In-Reply-To: <20100610133412.GC2618@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add possibility to register rx_handler data pointer along with a rx_handler.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/macvlan.c     |    2 +-
 include/linux/netdevice.h |    4 +++-
 net/bridge/br_if.c        |    2 +-
 net/core/dev.c            |    6 +++++-
 4 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 59c3155..87a3bf6 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -532,7 +532,7 @@ static int macvlan_port_create(struct net_device *dev)
 		INIT_HLIST_HEAD(&port->vlan_hash[i]);
 	rcu_assign_pointer(dev->macvlan_port, port);
 
-	err = netdev_rx_handler_register(dev, macvlan_handle_frame);
+	err = netdev_rx_handler_register(dev, macvlan_handle_frame, NULL);
 	if (err) {
 		rcu_assign_pointer(dev->macvlan_port, NULL);
 		kfree(port);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c319f28..32cc219 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -960,6 +960,7 @@ struct net_device {
 
 	struct netdev_queue	rx_queue;
 	rx_handler_func_t	*rx_handler;
+	void			*rx_handler_data;
 
 	struct netdev_queue	*_tx ____cacheline_aligned_in_smp;
 
@@ -1693,7 +1694,8 @@ static inline void napi_free_frags(struct napi_struct *napi)
 }
 
 extern int netdev_rx_handler_register(struct net_device *dev,
-				      rx_handler_func_t *rx_handler);
+				      rx_handler_func_t *rx_handler,
+				      void *rx_handler_data);
 extern void netdev_rx_handler_unregister(struct net_device *dev);
 
 extern void		netif_nit_deliver(struct sk_buff *skb);
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index d924234..90ac003 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -431,7 +431,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 
 	rcu_assign_pointer(dev->br_port, p);
 
-	err = netdev_rx_handler_register(dev, br_handle_frame);
+	err = netdev_rx_handler_register(dev, br_handle_frame, NULL);
 	if (err)
 		goto err3;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 6f330ce..c49dda0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2705,6 +2705,7 @@ void netif_nit_deliver(struct sk_buff *skb)
  *	netdev_rx_handler_register - register receive handler
  *	@dev: device to register a handler for
  *	@rx_handler: receive handler to register
+ *	@rx_handler_data: data pointer that is used by rx handler
  *
  *	Register a receive hander for a device. This handler will then be
  *	called from __netif_receive_skb. A negative errno code is returned
@@ -2713,13 +2714,15 @@ void netif_nit_deliver(struct sk_buff *skb)
  *	The caller must hold the rtnl_mutex.
  */
 int netdev_rx_handler_register(struct net_device *dev,
-			       rx_handler_func_t *rx_handler)
+			       rx_handler_func_t *rx_handler,
+			       void *rx_handler_data)
 {
 	ASSERT_RTNL();
 
 	if (dev->rx_handler)
 		return -EBUSY;
 
+	rcu_assign_pointer(dev->rx_handler_data, rx_handler_data);
 	rcu_assign_pointer(dev->rx_handler, rx_handler);
 
 	return 0;
@@ -2739,6 +2742,7 @@ void netdev_rx_handler_unregister(struct net_device *dev)
 
 	ASSERT_RTNL();
 	rcu_assign_pointer(dev->rx_handler, NULL);
+	rcu_assign_pointer(dev->rx_handler_data, NULL);
 }
 EXPORT_SYMBOL_GPL(netdev_rx_handler_unregister);
 
-- 
1.7.0.1


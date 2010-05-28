From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] net: replace hooks in __netif_receive_skb V4
Date: Fri, 28 May 2010 09:33:46 +0200
Message-ID: <20100528073345.GD2823@psychotron.redhat.com>
References: <20100527180813.GA3714@psychotron.redhat.com>
 <20100527130822.02cb1661@nehalam>
 <20100528055154.GB2823@psychotron.redhat.com>
 <20100528061241.GC2823@psychotron.redhat.com>
 <1275030163.2650.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shemminger@vyatta.com, kaber@trash.net,
	eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23724 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754626Ab0E1Hdy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 May 2010 03:33:54 -0400
Content-Disposition: inline
In-Reply-To: <1275030163.2650.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

changelog:
v3->v4
	- moved rx_handlers in net_device structure to be near to other data
	  used in rx path
v2->v3
	- used GPL-ed exports
v1->v2
	- writers are locked by rtnl_lock (removed unnecessary spinlock)
	- using call_rcu in unregister
	- nicer macvlan_port_create cleanup
	- struct rx_hanler is made const in funtion parameters

What this patch does is it removes two receive frame hooks (for bridge and for
macvlan) from __netif_receive_skb. These are replaced them with a general
list of rx_handlers which is iterated thru instead.

Then a network driver (of virtual netdev like macvlan or bridge) can register
an rx_handler for needed net device.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/macvlan.c      |   27 ++++++--
 include/linux/if_bridge.h  |    2 -
 include/linux/if_macvlan.h |    4 -
 include/linux/netdevice.h  |   18 +++++
 net/bridge/br.c            |    2 -
 net/bridge/br_if.c         |   14 ++++
 net/bridge/br_input.c      |   12 +++-
 net/bridge/br_private.h    |    3 +-
 net/core/dev.c             |  160 ++++++++++++++++++++++++++------------------
 9 files changed, 160 insertions(+), 82 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 87e8d4c..f6b7924 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -145,15 +145,16 @@ static void macvlan_broadcast(struct sk_buff *skb,
 }
 
 /* called under rcu_read_lock() from netif_receive_skb */
-static struct sk_buff *macvlan_handle_frame(struct macvlan_port *port,
-					    struct sk_buff *skb)
+static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
 {
+	struct macvlan_port *port;
 	const struct ethhdr *eth = eth_hdr(skb);
 	const struct macvlan_dev *vlan;
 	const struct macvlan_dev *src;
 	struct net_device *dev;
 	unsigned int len;
 
+	port = rcu_dereference(skb->dev->macvlan_port);
 	if (is_multicast_ether_addr(eth->h_dest)) {
 		src = macvlan_hash_lookup(port, eth->h_source);
 		if (!src)
@@ -511,10 +512,16 @@ static void macvlan_setup(struct net_device *dev)
 	dev->tx_queue_len	= 0;
 }
 
+static const struct netdev_rx_handler macvlan_rx_handler = {
+	.order		= NETDEV_RX_HANDLER_ORDER_MACVLAN,
+	.callback	= macvlan_handle_frame,
+};
+
 static int macvlan_port_create(struct net_device *dev)
 {
 	struct macvlan_port *port;
 	unsigned int i;
+	int err;
 
 	if (dev->type != ARPHRD_ETHER || dev->flags & IFF_LOOPBACK)
 		return -EINVAL;
@@ -528,13 +535,26 @@ static int macvlan_port_create(struct net_device *dev)
 	for (i = 0; i < MACVLAN_HASH_SIZE; i++)
 		INIT_HLIST_HEAD(&port->vlan_hash[i]);
 	rcu_assign_pointer(dev->macvlan_port, port);
+
+	err = netdev_rx_handler_register(dev, &macvlan_rx_handler);
+	if (err)
+		goto cleanup;
+
 	return 0;
+
+cleanup:
+	rcu_assign_pointer(dev->macvlan_port, NULL);
+	synchronize_rcu();
+	kfree(port);
+
+	return err;
 }
 
 static void macvlan_port_destroy(struct net_device *dev)
 {
 	struct macvlan_port *port = dev->macvlan_port;
 
+	netdev_rx_handler_unregister(dev, &macvlan_rx_handler);
 	rcu_assign_pointer(dev->macvlan_port, NULL);
 	synchronize_rcu();
 	kfree(port);
@@ -767,14 +787,12 @@ static int __init macvlan_init_module(void)
 	int err;
 
 	register_netdevice_notifier(&macvlan_notifier_block);
-	macvlan_handle_frame_hook = macvlan_handle_frame;
 
 	err = macvlan_link_register(&macvlan_link_ops);
 	if (err < 0)
 		goto err1;
 	return 0;
 err1:
-	macvlan_handle_frame_hook = NULL;
 	unregister_netdevice_notifier(&macvlan_notifier_block);
 	return err;
 }
@@ -782,7 +800,6 @@ err1:
 static void __exit macvlan_cleanup_module(void)
 {
 	rtnl_link_unregister(&macvlan_link_ops);
-	macvlan_handle_frame_hook = NULL;
 	unregister_netdevice_notifier(&macvlan_notifier_block);
 }
 
diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index 938b7e8..0d241a5 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -102,8 +102,6 @@ struct __fdb_entry {
 #include <linux/netdevice.h>
 
 extern void brioctl_set(int (*ioctl_hook)(struct net *, unsigned int, void __user *));
-extern struct sk_buff *(*br_handle_frame_hook)(struct net_bridge_port *p,
-					       struct sk_buff *skb);
 extern int (*br_should_route_hook)(struct sk_buff *skb);
 
 #endif
diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index 9ea047a..c26a0e4 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -84,8 +84,4 @@ extern int macvlan_link_register(struct rtnl_link_ops *ops);
 extern netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
 				      struct net_device *dev);
 
-
-extern struct sk_buff *(*macvlan_handle_frame_hook)(struct macvlan_port *,
-						    struct sk_buff *);
-
 #endif /* _LINUX_IF_MACVLAN_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a1bff65..8c8bfe3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -254,6 +254,16 @@ struct netdev_hw_addr_list {
 #define netdev_for_each_mc_addr(ha, dev) \
 	netdev_hw_addr_list_for_each(ha, &(dev)->mc)
 
+
+struct netdev_rx_handler {
+	struct list_head	list;
+	unsigned int		order;
+#define NETDEV_RX_HANDLER_ORDER_BRIDGE	1
+#define NETDEV_RX_HANDLER_ORDER_MACVLAN	2
+	struct sk_buff		*(*callback)(struct sk_buff *skb);
+	struct rcu_head		rcu;
+};
+
 struct hh_cache {
 	struct hh_cache *hh_next;	/* Next entry			     */
 	atomic_t	hh_refcnt;	/* number of users                   */
@@ -958,6 +968,9 @@ struct net_device {
 
 	struct netdev_queue	rx_queue;
 
+	/* receive handlers (hooks) list */
+	struct list_head	rx_handlers;
+
 	struct netdev_queue	*_tx ____cacheline_aligned_in_smp;
 
 	/* Number of TX queues allocated at alloc_netdev_mq() time  */
@@ -1685,6 +1698,11 @@ static inline void napi_free_frags(struct napi_struct *napi)
 	napi->skb = NULL;
 }
 
+extern int netdev_rx_handler_register(struct net_device *dev,
+				      const struct netdev_rx_handler *rh);
+extern void netdev_rx_handler_unregister(struct net_device *dev,
+					 const struct netdev_rx_handler *rh);
+
 extern void		netif_nit_deliver(struct sk_buff *skb);
 extern int		dev_valid_name(const char *name);
 extern int		dev_ioctl(struct net *net, unsigned int cmd, void __user *);
diff --git a/net/bridge/br.c b/net/bridge/br.c
index 76357b5..c8436fa 100644
--- a/net/bridge/br.c
+++ b/net/bridge/br.c
@@ -63,7 +63,6 @@ static int __init br_init(void)
 		goto err_out4;
 
 	brioctl_set(br_ioctl_deviceless_stub);
-	br_handle_frame_hook = br_handle_frame;
 
 #if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
 	br_fdb_test_addr_hook = br_fdb_test_addr;
@@ -100,7 +99,6 @@ static void __exit br_deinit(void)
 	br_fdb_test_addr_hook = NULL;
 #endif
 
-	br_handle_frame_hook = NULL;
 	br_fdb_fini();
 }
 
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 18b245e..45270e5 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -119,6 +119,11 @@ static void destroy_nbp_rcu(struct rcu_head *head)
 	destroy_nbp(p);
 }
 
+static const struct netdev_rx_handler br_rx_handler = {
+	.order		= NETDEV_RX_HANDLER_ORDER_BRIDGE,
+	.callback	= br_handle_frame,
+};
+
 /* Delete port(interface) from bridge is done in two steps.
  * via RCU. First step, marks device as down. That deletes
  * all the timers and stops new packets from flowing through.
@@ -147,6 +152,7 @@ static void del_nbp(struct net_bridge_port *p)
 
 	list_del_rcu(&p->list);
 
+	netdev_rx_handler_unregister(dev, &br_rx_handler);
 	rcu_assign_pointer(dev->br_port, NULL);
 
 	br_multicast_del_port(p);
@@ -429,6 +435,11 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 		goto err2;
 
 	rcu_assign_pointer(dev->br_port, p);
+
+	err = netdev_rx_handler_register(dev, &br_rx_handler);
+	if (err)
+		goto err3;
+
 	dev_disable_lro(dev);
 
 	list_add_rcu(&p->list, &br->port_list);
@@ -451,6 +462,9 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	br_netpoll_enable(br, dev);
 
 	return 0;
+err3:
+	rcu_assign_pointer(dev->br_port, NULL);
+	synchronize_rcu();
 err2:
 	br_fdb_delete_by_port(br, p, 1);
 err1:
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index d36e700..99647d8 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -131,15 +131,19 @@ static inline int is_link_local(const unsigned char *dest)
 }
 
 /*
- * Called via br_handle_frame_hook.
  * Return NULL if skb is handled
- * note: already called with rcu_read_lock (preempt_disabled)
+ * note: already called with rcu_read_lock (preempt_disabled) from
+ * netif_receive_skb
  */
-struct sk_buff *br_handle_frame(struct net_bridge_port *p, struct sk_buff *skb)
+struct sk_buff *br_handle_frame(struct sk_buff *skb)
 {
+	struct net_bridge_port *p;
 	const unsigned char *dest = eth_hdr(skb)->h_dest;
 	int (*rhook)(struct sk_buff *skb);
 
+	if (skb->pkt_type == PACKET_LOOPBACK)
+		return skb;
+
 	if (!is_valid_ether_addr(eth_hdr(skb)->h_source))
 		goto drop;
 
@@ -147,6 +151,8 @@ struct sk_buff *br_handle_frame(struct net_bridge_port *p, struct sk_buff *skb)
 	if (!skb)
 		return NULL;
 
+	p = rcu_dereference(skb->dev->br_port);
+
 	if (unlikely(is_link_local(dest))) {
 		/* Pause frames shouldn't be passed up by driver anyway */
 		if (skb->protocol == htons(ETH_P_PAUSE))
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 0f4a74b..c83519b 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -331,8 +331,7 @@ extern void br_features_recompute(struct net_bridge *br);
 
 /* br_input.c */
 extern int br_handle_frame_finish(struct sk_buff *skb);
-extern struct sk_buff *br_handle_frame(struct net_bridge_port *p,
-				       struct sk_buff *skb);
+extern struct sk_buff *br_handle_frame(struct sk_buff *skb);
 
 /* br_ioctl.c */
 extern int br_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
diff --git a/net/core/dev.c b/net/core/dev.c
index 6c82065..d2ab71a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2585,70 +2585,14 @@ static inline int deliver_skb(struct sk_buff *skb,
 	return pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
 }
 
-#if defined(CONFIG_BRIDGE) || defined (CONFIG_BRIDGE_MODULE)
-
-#if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
+#if (defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)) && \
+    (defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE))
 /* This hook is defined here for ATM LANE */
 int (*br_fdb_test_addr_hook)(struct net_device *dev,
 			     unsigned char *addr) __read_mostly;
 EXPORT_SYMBOL_GPL(br_fdb_test_addr_hook);
 #endif
 
-/*
- * If bridge module is loaded call bridging hook.
- *  returns NULL if packet was consumed.
- */
-struct sk_buff *(*br_handle_frame_hook)(struct net_bridge_port *p,
-					struct sk_buff *skb) __read_mostly;
-EXPORT_SYMBOL_GPL(br_handle_frame_hook);
-
-static inline struct sk_buff *handle_bridge(struct sk_buff *skb,
-					    struct packet_type **pt_prev, int *ret,
-					    struct net_device *orig_dev)
-{
-	struct net_bridge_port *port;
-
-	if (skb->pkt_type == PACKET_LOOPBACK ||
-	    (port = rcu_dereference(skb->dev->br_port)) == NULL)
-		return skb;
-
-	if (*pt_prev) {
-		*ret = deliver_skb(skb, *pt_prev, orig_dev);
-		*pt_prev = NULL;
-	}
-
-	return br_handle_frame_hook(port, skb);
-}
-#else
-#define handle_bridge(skb, pt_prev, ret, orig_dev)	(skb)
-#endif
-
-#if defined(CONFIG_MACVLAN) || defined(CONFIG_MACVLAN_MODULE)
-struct sk_buff *(*macvlan_handle_frame_hook)(struct macvlan_port *p,
-					     struct sk_buff *skb) __read_mostly;
-EXPORT_SYMBOL_GPL(macvlan_handle_frame_hook);
-
-static inline struct sk_buff *handle_macvlan(struct sk_buff *skb,
-					     struct packet_type **pt_prev,
-					     int *ret,
-					     struct net_device *orig_dev)
-{
-	struct macvlan_port *port;
-
-	port = rcu_dereference(skb->dev->macvlan_port);
-	if (!port)
-		return skb;
-
-	if (*pt_prev) {
-		*ret = deliver_skb(skb, *pt_prev, orig_dev);
-		*pt_prev = NULL;
-	}
-	return macvlan_handle_frame_hook(port, skb);
-}
-#else
-#define handle_macvlan(skb, pt_prev, ret, orig_dev)	(skb)
-#endif
-
 #ifdef CONFIG_NET_CLS_ACT
 /* TODO: Maybe we should just force sch_ingress to be compiled in
  * when CONFIG_NET_CLS_ACT is? otherwise some useless instructions
@@ -2744,6 +2688,85 @@ void netif_nit_deliver(struct sk_buff *skb)
 	rcu_read_unlock();
 }
 
+static bool rx_handlers_equal(const struct netdev_rx_handler *rh1,
+			      const struct netdev_rx_handler *rh2)
+{
+	return (rh1->order == rh2->order) && (rh1->callback == rh2->callback);
+}
+
+/**
+ *	netdev_rx_handler_register - register receive handler
+ *	@dev: device to register a handler for
+ *	@rh: receive handler to register
+ *
+ *	Register a receive hander for a device. This handler will then be
+ *	called from __netif_receive_skb. A negative errno code is returned
+ *	on a failure.
+ *
+ *	The caller must hold the rtnl_mutex.
+ */
+int netdev_rx_handler_register(struct net_device *dev,
+			       const struct netdev_rx_handler *rh)
+{
+	struct list_head *iter, *add_after;
+	struct netdev_rx_handler *rh1;
+	int err = 0;
+
+	ASSERT_RTNL();
+	add_after = &dev->rx_handlers;
+	list_for_each(iter, &dev->rx_handlers) {
+		rh1 = list_entry(iter, struct netdev_rx_handler, list);
+		if (rx_handlers_equal(rh, rh1))
+			return -EEXIST;
+		if (rh1->order > rh->order)
+			break;
+		add_after = iter;
+	}
+	rh1 = kzalloc(sizeof(*rh), GFP_KERNEL);
+	if (!rh1)
+		return -ENOMEM;
+
+	rh1->order = rh->order;
+	rh1->callback = rh->callback;
+	list_add_rcu(&rh1->list, add_after);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(netdev_rx_handler_register);
+
+static void rx_handler_rcu_free(struct rcu_head *head)
+{
+	struct netdev_rx_handler *rh;
+
+	rh = container_of(head, struct netdev_rx_handler, rcu);
+	kfree(rh);
+}
+
+/**
+ *	netdev_rx_handler_unregister - unregister receive handler
+ *	@dev: device to unregister a handler from
+ *	@rh: receive handler to unregister
+ *
+ *	Unregister a receive hander from a device.
+ *
+ *	The caller must hold the rtnl_mutex.
+ */
+void netdev_rx_handler_unregister(struct net_device *dev,
+				  const struct netdev_rx_handler *rh)
+{
+	struct netdev_rx_handler *rh1;
+
+	ASSERT_RTNL();
+	list_for_each_entry(rh1, &dev->rx_handlers, list) {
+		if (rx_handlers_equal(rh, rh1)) {
+			list_del_rcu(&rh1->list);
+			call_rcu(&rh1->rcu, rx_handler_rcu_free);
+			return;
+		}
+	}
+}
+EXPORT_SYMBOL_GPL(netdev_rx_handler_unregister);
+
 static inline void skb_bond_set_mac_by_master(struct sk_buff *skb,
 					      struct net_device *master)
 {
@@ -2796,6 +2819,7 @@ EXPORT_SYMBOL(__skb_bond_should_drop);
 static int __netif_receive_skb(struct sk_buff *skb)
 {
 	struct packet_type *ptype, *pt_prev;
+	struct netdev_rx_handler *rh;
 	struct net_device *orig_dev;
 	struct net_device *master;
 	struct net_device *null_or_orig;
@@ -2859,12 +2883,18 @@ static int __netif_receive_skb(struct sk_buff *skb)
 ncls:
 #endif
 
-	skb = handle_bridge(skb, &pt_prev, &ret, orig_dev);
-	if (!skb)
-		goto out;
-	skb = handle_macvlan(skb, &pt_prev, &ret, orig_dev);
-	if (!skb)
-		goto out;
+	/*
+	 * Go through various rx handlers, like bridge, macvlan etc.
+	 */
+	list_for_each_entry_rcu(rh, &skb->dev->rx_handlers, list) {
+		if (pt_prev) {
+			ret = deliver_skb(skb, pt_prev, orig_dev);
+			pt_prev = NULL;
+		}
+		skb = rh->callback(skb);
+		if (!skb)
+			goto out;
+	}
 
 	/*
 	 * Make sure frames received on VLAN interfaces stacked on
@@ -5371,6 +5401,8 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	dev_mc_init(dev);
 	dev_uc_init(dev);
 
+	INIT_LIST_HEAD(&dev->rx_handlers);
+
 	dev_net_set(dev, &init_net);
 
 	dev->_tx = tx;
-- 
1.6.6.1


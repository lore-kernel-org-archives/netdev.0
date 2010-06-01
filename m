From: Stephen Hemminger <shemminger@vyatta.com>
Subject: net: replace hooks in __netif_receive_skb (v4)
Date: Tue, 1 Jun 2010 08:28:05 -0700
Message-ID: <20100601082805.1c84b16d@nehalam>
References: <20100527180813.GA3714@psychotron.redhat.com>
	<20100527130822.02cb1661@nehalam>
	<20100528055154.GB2823@psychotron.redhat.com>
	<20100528061241.GC2823@psychotron.redhat.com>
	<1275030163.2650.3.camel@edumazet-laptop>
	<20100528073345.GD2823@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, eric.dumazet@gmail.com
To: Jiri Pirko <jpirko@redhat.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46486 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755601Ab0FAP2M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jun 2010 11:28:12 -0400
In-Reply-To: <20100528073345.GD2823@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Jiri Pirko <jpirko@redhat.com>

What this patch does is it removes two receive frame hooks (for bridge and for
macvlan) from __netif_receive_skb. These are replaced them with a single
hook for both. It only supports one hook per device because it makes no
sense to do bridging and macvlan on the same device.

Then a network driver (of virtual netdev like macvlan or bridge) can register
an rx_handler for needed net device.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
v3->v4 
       - only one hook per device.
v2->v3
	- used GPL-ed exports
v1->v2
	- writers are locked by rtnl_lock (removed unnecessary spinlock)
	- using call_rcu in unregister
	- nicer macvlan_port_create cleanup
	- struct rx_hanler is made const in funtion parameters

 drivers/net/macvlan.c      |   19 ++++---
 include/linux/if_bridge.h  |    2 
 include/linux/if_macvlan.h |    4 -
 include/linux/netdevice.h  |    8 +++
 net/bridge/br.c            |    2 
 net/bridge/br_if.c         |    8 +++
 net/bridge/br_input.c      |   12 +++-
 net/bridge/br_private.h    |    3 -
 net/core/dev.c             |  119 ++++++++++++++++++++-------------------------
 9 files changed, 94 insertions(+), 83 deletions(-)

--- a/drivers/net/macvlan.c	2010-05-28 08:41:38.248169422 -0700
+++ b/drivers/net/macvlan.c	2010-06-01 08:16:52.307206412 -0700
@@ -145,15 +145,16 @@ static void macvlan_broadcast(struct sk_
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
@@ -515,6 +516,7 @@ static int macvlan_port_create(struct ne
 {
 	struct macvlan_port *port;
 	unsigned int i;
+	int err;
 
 	if (dev->type != ARPHRD_ETHER || dev->flags & IFF_LOOPBACK)
 		return -EINVAL;
@@ -528,13 +530,21 @@ static int macvlan_port_create(struct ne
 	for (i = 0; i < MACVLAN_HASH_SIZE; i++)
 		INIT_HLIST_HEAD(&port->vlan_hash[i]);
 	rcu_assign_pointer(dev->macvlan_port, port);
-	return 0;
+
+	err = netdev_rx_handler_register(dev, macvlan_handle_frame);
+	if (err) {
+		dev->macvlan_port = NULL;
+		kfree(port);
+	}
+
+	return err;
 }
 
 static void macvlan_port_destroy(struct net_device *dev)
 {
 	struct macvlan_port *port = dev->macvlan_port;
 
+	netdev_rx_handler_unregister(dev);
 	rcu_assign_pointer(dev->macvlan_port, NULL);
 	synchronize_rcu();
 	kfree(port);
@@ -767,14 +777,12 @@ static int __init macvlan_init_module(vo
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
@@ -782,7 +790,6 @@ err1:
 static void __exit macvlan_cleanup_module(void)
 {
 	rtnl_link_unregister(&macvlan_link_ops);
-	macvlan_handle_frame_hook = NULL;
 	unregister_netdevice_notifier(&macvlan_notifier_block);
 }
 
--- a/include/linux/if_bridge.h	2010-05-28 08:35:11.628190230 -0700
+++ b/include/linux/if_bridge.h	2010-06-01 08:02:39.859736930 -0700
@@ -102,8 +102,6 @@ struct __fdb_entry {
 #include <linux/netdevice.h>
 
 extern void brioctl_set(int (*ioctl_hook)(struct net *, unsigned int, void __user *));
-extern struct sk_buff *(*br_handle_frame_hook)(struct net_bridge_port *p,
-					       struct sk_buff *skb);
 extern int (*br_should_route_hook)(struct sk_buff *skb);
 
 #endif
--- a/include/linux/if_macvlan.h	2010-05-28 08:35:11.628190230 -0700
+++ b/include/linux/if_macvlan.h	2010-06-01 08:02:39.869738723 -0700
@@ -84,8 +84,4 @@ extern int macvlan_link_register(struct 
 extern netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
 				      struct net_device *dev);
 
-
-extern struct sk_buff *(*macvlan_handle_frame_hook)(struct macvlan_port *,
-						    struct sk_buff *);
-
 #endif /* _LINUX_IF_MACVLAN_H */
--- a/include/linux/netdevice.h	2010-05-28 08:41:38.628169375 -0700
+++ b/include/linux/netdevice.h	2010-06-01 08:12:59.680035275 -0700
@@ -254,6 +254,7 @@ struct netdev_hw_addr_list {
 #define netdev_for_each_mc_addr(ha, dev) \
 	netdev_hw_addr_list_for_each(ha, &(dev)->mc)
 
+
 struct hh_cache {
 	struct hh_cache *hh_next;	/* Next entry			     */
 	atomic_t	hh_refcnt;	/* number of users                   */
@@ -381,6 +382,8 @@ enum gro_result {
 };
 typedef enum gro_result gro_result_t;
 
+typedef struct sk_buff *rx_callback_func_t(struct sk_buff *skb);
+
 extern void __napi_schedule(struct napi_struct *n);
 
 static inline int napi_disable_pending(struct napi_struct *n)
@@ -957,6 +960,7 @@ struct net_device {
 #endif
 
 	struct netdev_queue	rx_queue;
+	rx_callback_func_t	*rx_handler;
 
 	struct netdev_queue	*_tx ____cacheline_aligned_in_smp;
 
@@ -1693,6 +1697,10 @@ static inline void napi_free_frags(struc
 	napi->skb = NULL;
 }
 
+extern int netdev_rx_handler_register(struct net_device *dev,
+				      rx_callback_func_t *hook);
+extern void netdev_rx_handler_unregister(struct net_device *dev);
+
 extern void		netif_nit_deliver(struct sk_buff *skb);
 extern int		dev_valid_name(const char *name);
 extern int		dev_ioctl(struct net *net, unsigned int cmd, void __user *);
--- a/net/bridge/br.c	2010-05-28 08:35:11.858189945 -0700
+++ b/net/bridge/br.c	2010-06-01 08:02:39.889741050 -0700
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
 
--- a/net/bridge/br_if.c	2010-05-28 08:35:11.858189945 -0700
+++ b/net/bridge/br_if.c	2010-06-01 08:14:30.521680943 -0700
@@ -147,6 +147,7 @@ static void del_nbp(struct net_bridge_po
 
 	list_del_rcu(&p->list);
 
+	netdev_rx_handler_unregister(dev);
 	rcu_assign_pointer(dev->br_port, NULL);
 
 	br_multicast_del_port(p);
@@ -429,6 +430,11 @@ int br_add_if(struct net_bridge *br, str
 		goto err2;
 
 	rcu_assign_pointer(dev->br_port, p);
+
+	err = netdev_rx_handler_register(dev, br_handle_frame);
+	if (err)
+		goto err3;
+
 	dev_disable_lro(dev);
 
 	list_add_rcu(&p->list, &br->port_list);
@@ -451,6 +457,8 @@ int br_add_if(struct net_bridge *br, str
 	br_netpoll_enable(br, dev);
 
 	return 0;
+err3:
+	dev->br_port = NULL;
 err2:
 	br_fdb_delete_by_port(br, p, 1);
 err1:
--- a/net/bridge/br_input.c	2010-05-28 08:35:11.858189945 -0700
+++ b/net/bridge/br_input.c	2010-06-01 08:02:39.909740447 -0700
@@ -131,15 +131,19 @@ static inline int is_link_local(const un
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
 
@@ -147,6 +151,8 @@ struct sk_buff *br_handle_frame(struct n
 	if (!skb)
 		return NULL;
 
+	p = rcu_dereference(skb->dev->br_port);
+
 	if (unlikely(is_link_local(dest))) {
 		/* Pause frames shouldn't be passed up by driver anyway */
 		if (skb->protocol == htons(ETH_P_PAUSE))
--- a/net/bridge/br_private.h	2010-05-28 08:35:11.858189945 -0700
+++ b/net/bridge/br_private.h	2010-06-01 08:02:39.919725220 -0700
@@ -331,8 +331,7 @@ extern void br_features_recompute(struct
 
 /* br_input.c */
 extern int br_handle_frame_finish(struct sk_buff *skb);
-extern struct sk_buff *br_handle_frame(struct net_bridge_port *p,
-				       struct sk_buff *skb);
+extern struct sk_buff *br_handle_frame(struct sk_buff *skb);
 
 /* br_ioctl.c */
 extern int br_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
--- a/net/core/dev.c	2010-05-28 08:41:38.678169590 -0700
+++ b/net/core/dev.c	2010-06-01 08:16:38.563051750 -0700
@@ -2581,70 +2581,14 @@ static inline int deliver_skb(struct sk_
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
@@ -2740,6 +2684,48 @@ void netif_nit_deliver(struct sk_buff *s
 	rcu_read_unlock();
 }
 
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
+			       rx_callback_func_t *hook)
+{
+	ASSERT_RTNL();
+
+	if (dev->rx_handler)
+		return -EBUSY;
+
+	rcu_assign_pointer(dev->rx_handler, hook);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(netdev_rx_handler_register);
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
+void netdev_rx_handler_unregister(struct net_device *dev)
+{
+
+	ASSERT_RTNL();
+	dev->rx_handler = NULL;
+}
+EXPORT_SYMBOL_GPL(netdev_rx_handler_unregister);
+
 static inline void skb_bond_set_mac_by_master(struct sk_buff *skb,
 					      struct net_device *master)
 {
@@ -2792,6 +2778,7 @@ EXPORT_SYMBOL(__skb_bond_should_drop);
 static int __netif_receive_skb(struct sk_buff *skb)
 {
 	struct packet_type *ptype, *pt_prev;
+	rx_callback_func_t *rh;
 	struct net_device *orig_dev;
 	struct net_device *master;
 	struct net_device *null_or_orig;
@@ -2855,12 +2842,16 @@ static int __netif_receive_skb(struct sk
 ncls:
 #endif
 
-	skb = handle_bridge(skb, &pt_prev, &ret, orig_dev);
-	if (!skb)
-		goto out;
-	skb = handle_macvlan(skb, &pt_prev, &ret, orig_dev);
-	if (!skb)
-		goto out;
+	/* Handle special case of bridge or macvlan */
+	if ((rh = rcu_dereference(skb->dev->rx_handler)) != NULL) {
+		if (pt_prev) {
+			ret = deliver_skb(skb, pt_prev, orig_dev);
+			pt_prev = NULL;
+		}
+		skb = rh(skb);
+		if (!skb)
+			goto out;
+	}
 
 	/*
 	 * Make sure frames received on VLAN interfaces stacked on

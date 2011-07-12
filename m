From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6] net: allow multiple rx_handler registration
Date: Tue, 12 Jul 2011 13:06:01 +0200
Message-ID: <1310468761-2304-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net,
	greearb@candelatech.com, mirqus@gmail.com, equinox@diac24.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33824 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753028Ab1GLLHg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2011 07:07:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For some net topos it is necessary to have multiple "soft-net-devices"
hooked on one netdev. For example very common is to have
eth<->(br+vlan). Vlan is not using rh_handler (yet) but it might be useful
for other setups.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/bonding/bond_main.c |   14 ++++---
 drivers/net/bonding/bonding.h   |    9 +++-
 drivers/net/macvlan.c           |   35 +++++++++++-----
 include/linux/netdevice.h       |   63 +++++++++++++++++++++++++---
 net/bridge/br_if.c              |    5 +-
 net/bridge/br_input.c           |    5 +-
 net/bridge/br_private.h         |   28 ++++++++++---
 net/core/dev.c                  |   87 +++++++++++++++++++++++++++++++--------
 8 files changed, 193 insertions(+), 53 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 61265f7..f18af47 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1482,7 +1482,8 @@ static bool bond_should_deliver_exact_match(struct sk_buff *skb,
 	return false;
 }
 
-static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
+static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb,
+					     struct rx_handler *rx_handler)
 {
 	struct sk_buff *skb = *pskb;
 	struct slave *slave;
@@ -1494,7 +1495,7 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
 
 	*pskb = skb;
 
-	slave = bond_slave_get_rcu(skb->dev);
+	slave = bond_slave_get(rx_handler);
 	bond = slave->bond;
 
 	if (bond->params.arp_interval)
@@ -1897,8 +1898,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	if (res)
 		goto err_close;
 
-	res = netdev_rx_handler_register(slave_dev, bond_handle_frame,
-					 new_slave);
+	res = netdev_rx_handler_register(slave_dev, &new_slave->rx_handler,
+					 bond_handle_frame,
+					 RX_HANDLER_PRIO_BOND);
 	if (res) {
 		pr_debug("Error %d calling netdev_rx_handler_register\n", res);
 		goto err_dest_symlinks;
@@ -1988,7 +1990,7 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 	/* unregister rx_handler early so bond_handle_frame wouldn't be called
 	 * for this slave anymore.
 	 */
-	netdev_rx_handler_unregister(slave_dev);
+	netdev_rx_handler_unregister(slave_dev, &slave->rx_handler);
 	write_unlock_bh(&bond->lock);
 	synchronize_net();
 	write_lock_bh(&bond->lock);
@@ -2189,7 +2191,7 @@ static int bond_release_all(struct net_device *bond_dev)
 		/* unregister rx_handler early so bond_handle_frame wouldn't
 		 * be called for this slave anymore.
 		 */
-		netdev_rx_handler_unregister(slave_dev);
+		netdev_rx_handler_unregister(slave_dev, &slave->rx_handler);
 		synchronize_net();
 
 		if (bond_is_lb(bond)) {
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 2936171..e732e16 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -172,6 +172,7 @@ struct vlan_entry {
 
 struct slave {
 	struct net_device *dev; /* first - useful for panic debug */
+	struct rx_handler rx_handler;
 	struct slave *next;
 	struct slave *prev;
 	struct bonding *bond; /* our master */
@@ -196,6 +197,11 @@ struct slave {
 #endif
 };
 
+#define bond_slave_get(rx_handler)			\
+	netdev_rx_handler_get_priv(rx_handler,		\
+				   struct slave,	\
+				   rx_handler)
+
 /*
  * Link pseudo-state only used internally by monitors
  */
@@ -253,9 +259,6 @@ struct bonding {
 #endif /* CONFIG_DEBUG_FS */
 };
 
-#define bond_slave_get_rcu(dev) \
-	((struct slave *) rcu_dereference(dev->rx_handler_data))
-
 /**
  * Returns NULL if the net_device does not belong to any of the bond's slaves
  *
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index cc67cbe..49ca58b 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -34,19 +34,28 @@
 #define MACVLAN_HASH_SIZE	(1 << BITS_PER_BYTE)
 
 struct macvlan_port {
+	struct rx_handler	rx_handler;
 	struct net_device	*dev;
 	struct hlist_head	vlan_hash[MACVLAN_HASH_SIZE];
 	struct list_head	vlans;
 	struct rcu_head		rcu;
-	bool 			passthru;
+	bool			passthru;
 	int			count;
 };
 
+#define macvlan_port_get(rx_handler)				\
+	netdev_rx_handler_get_priv(rx_handler,			\
+				   struct macvlan_port,		\
+				   rx_handler)
+
+#define macvlan_port_get_by_dev(dev)					\
+	netdev_rx_handler_get_priv_by_prio(dev,				\
+					   RX_HANDLER_PRIO_MACVLAN,	\
+					   struct macvlan_port,		\
+					   rx_handler)
+
 static void macvlan_port_destroy(struct net_device *dev);
 
-#define macvlan_port_get_rcu(dev) \
-	((struct macvlan_port *) rcu_dereference(dev->rx_handler_data))
-#define macvlan_port_get(dev) ((struct macvlan_port *) dev->rx_handler_data)
 #define macvlan_port_exists(dev) (dev->priv_flags & IFF_MACVLAN_PORT)
 
 static struct macvlan_dev *macvlan_hash_lookup(const struct macvlan_port *port,
@@ -156,7 +165,8 @@ static void macvlan_broadcast(struct sk_buff *skb,
 }
 
 /* called under rcu_read_lock() from netif_receive_skb */
-static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
+static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb,
+						struct rx_handler *rx_handler)
 {
 	struct macvlan_port *port;
 	struct sk_buff *skb = *pskb;
@@ -167,7 +177,7 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 	unsigned int len = 0;
 	int ret = NET_RX_DROP;
 
-	port = macvlan_port_get_rcu(skb->dev);
+	port = macvlan_port_get(rx_handler);
 	if (is_multicast_ether_addr(eth->h_dest)) {
 		src = macvlan_hash_lookup(port, eth->h_source);
 		if (!src)
@@ -617,7 +627,9 @@ static int macvlan_port_create(struct net_device *dev)
 	for (i = 0; i < MACVLAN_HASH_SIZE; i++)
 		INIT_HLIST_HEAD(&port->vlan_hash[i]);
 
-	err = netdev_rx_handler_register(dev, macvlan_handle_frame, port);
+	err = netdev_rx_handler_register(dev, &port->rx_handler,
+					 macvlan_handle_frame,
+					 RX_HANDLER_PRIO_MACVLAN);
 	if (err)
 		kfree(port);
 	else
@@ -627,10 +639,11 @@ static int macvlan_port_create(struct net_device *dev)
 
 static void macvlan_port_destroy(struct net_device *dev)
 {
-	struct macvlan_port *port = macvlan_port_get(dev);
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	struct macvlan_port *port = vlan->port;
 
 	dev->priv_flags &= ~IFF_MACVLAN_PORT;
-	netdev_rx_handler_unregister(dev);
+	netdev_rx_handler_unregister(dev, &port->rx_handler);
 	kfree_rcu(port, rcu);
 }
 
@@ -696,7 +709,7 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 		if (err < 0)
 			return err;
 	}
-	port = macvlan_port_get(lowerdev);
+	port = macvlan_port_get_by_dev(lowerdev);
 
 	/* Only 1 macvlan device can be created in passthru mode */
 	if (port->passthru)
@@ -818,7 +831,7 @@ static int macvlan_device_event(struct notifier_block *unused,
 	if (!macvlan_port_exists(dev))
 		return NOTIFY_DONE;
 
-	port = macvlan_port_get(dev);
+	port = macvlan_port_get_by_dev(dev);
 
 	switch (event) {
 	case NETDEV_CHANGE:
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 011eb89..126cd07 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -437,7 +437,51 @@ enum rx_handler_result {
 	RX_HANDLER_PASS,
 };
 typedef enum rx_handler_result rx_handler_result_t;
-typedef rx_handler_result_t rx_handler_func_t(struct sk_buff **pskb);
+
+struct rx_handler;
+typedef rx_handler_result_t rx_handler_func_t(struct sk_buff **pskb,
+					      struct rx_handler *rx_handler);
+
+enum rx_handler_prio {
+	RX_HANDLER_PRIO_BRIDGE,
+	RX_HANDLER_PRIO_BOND,
+	RX_HANDLER_PRIO_MACVLAN,
+};
+
+/*
+ * struct rx_handler should be embedded into
+ * private struct used by rx_handler
+ */
+struct rx_handler {
+	struct list_head	list;
+	rx_handler_func_t	*callback;
+	unsigned int		prio;
+};
+
+/**
+ * netdev_rx_handler_get_priv - get containing private structure of given
+ *				receive handler
+ * @rx_handler: receive_handler
+ * @type: the type of the container struct this is embedded in
+ * @member: the name of the member within the struct
+ */
+#define netdev_rx_handler_get_priv(rx_handler, type, member) \
+	container_of(rx_handler, type, member)
+
+/**
+ * netdev_rx_handler_get_priv_by_prio, netdev_rx_handler_get_priv_by_prio_rcu
+ *	- get containing private structure of given receive handler priority
+ * @dev: netdevice
+ * @type: the type of the container struct this is embedded in
+ * @member: the name of the member within the struct
+ */
+#define netdev_rx_handler_get_priv_by_prio(dev, prio, type, member)		\
+	netdev_rx_handler_get_priv(netdev_rx_handler_get_by_prio(dev, prio),	\
+				   type, member)
+
+#define netdev_rx_handler_get_priv_by_prio_rcu(dev, prio, type, member)		\
+	netdev_rx_handler_get_priv(netdev_rx_handler_get_by_prio_rcu(dev, prio),\
+				   type, member)
 
 extern void __napi_schedule(struct napi_struct *n);
 
@@ -1238,8 +1282,7 @@ struct net_device {
 #endif
 #endif
 
-	rx_handler_func_t __rcu	*rx_handler;
-	void __rcu		*rx_handler_data;
+	struct list_head	rx_handler_list;
 
 	struct netdev_queue __rcu *ingress_queue;
 
@@ -2082,10 +2125,18 @@ static inline void napi_free_frags(struct napi_struct *napi)
 	napi->skb = NULL;
 }
 
+extern struct rx_handler *
+netdev_rx_handler_get_by_prio(const struct net_device *dev,
+			      unsigned int prio);
+extern struct rx_handler *
+netdev_rx_handler_get_by_prio_rcu(const struct net_device *dev,
+				  unsigned int prio);
 extern int netdev_rx_handler_register(struct net_device *dev,
-				      rx_handler_func_t *rx_handler,
-				      void *rx_handler_data);
-extern void netdev_rx_handler_unregister(struct net_device *dev);
+				      struct rx_handler *rx_handler,
+			              rx_handler_func_t *callback,
+				      unsigned int prio);
+extern void netdev_rx_handler_unregister(struct net_device *dev,
+					 struct rx_handler *rx_handler);
 
 extern int		dev_valid_name(const char *name);
 extern int		dev_ioctl(struct net *net, unsigned int cmd, void __user *);
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 1bacca4..4ee5d78 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -146,7 +146,7 @@ static void del_nbp(struct net_bridge_port *p)
 
 	dev->priv_flags &= ~IFF_BRIDGE_PORT;
 
-	netdev_rx_handler_unregister(dev);
+	netdev_rx_handler_unregister(dev, &p->rx_handler);
 	synchronize_net();
 
 	netdev_set_master(dev, NULL);
@@ -365,7 +365,8 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	if (err)
 		goto err3;
 
-	err = netdev_rx_handler_register(dev, br_handle_frame, p);
+	err = netdev_rx_handler_register(dev, &p->rx_handler, br_handle_frame,
+					 RX_HANDLER_PRIO_BRIDGE);
 	if (err)
 		goto err4;
 
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index f06ee39..1f729a0 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -142,7 +142,8 @@ static inline int is_link_local(const unsigned char *dest)
  * Return NULL if skb is handled
  * note: already called with rcu_read_lock
  */
-rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
+rx_handler_result_t br_handle_frame(struct sk_buff **pskb,
+				    struct rx_handler *rx_handler)
 {
 	struct net_bridge_port *p;
 	struct sk_buff *skb = *pskb;
@@ -159,7 +160,7 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 	if (!skb)
 		return RX_HANDLER_CONSUMED;
 
-	p = br_port_get_rcu(skb->dev);
+	p = br_port_get(rx_handler);
 
 	if (unlikely(is_link_local(dest))) {
 		/* Pause frames shouldn't be passed up by driver anyway */
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 54578f2..1a1ea40 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -108,6 +108,7 @@ struct net_bridge_mdb_htable
 
 struct net_bridge_port
 {
+	struct rx_handler		rx_handler;
 	struct net_bridge		*br;
 	struct net_device		*dev;
 	struct list_head		list;
@@ -152,18 +153,32 @@ struct net_bridge_port
 #endif
 };
 
+#define br_port_get(rx_handler)					\
+	netdev_rx_handler_get_priv(rx_handler,			\
+				   struct net_bridge_port,	\
+				   rx_handler)
+
 #define br_port_exists(dev) (dev->priv_flags & IFF_BRIDGE_PORT)
 
-static inline struct net_bridge_port *br_port_get_rcu(const struct net_device *dev)
+static inline struct net_bridge_port *
+br_port_get_rcu(const struct net_device *dev)
 {
-	struct net_bridge_port *port = rcu_dereference(dev->rx_handler_data);
-	return br_port_exists(dev) ? port : NULL;
+	if (unlikely(!br_port_exists(dev)))
+		return NULL;
+	return netdev_rx_handler_get_priv_by_prio_rcu(dev,
+						      RX_HANDLER_PRIO_BRIDGE,
+						      struct net_bridge_port,
+						      rx_handler);
 }
 
 static inline struct net_bridge_port *br_port_get_rtnl(struct net_device *dev)
 {
-	return br_port_exists(dev) ?
-		rtnl_dereference(dev->rx_handler_data) : NULL;
+	if (unlikely(!br_port_exists(dev)))
+		return NULL;
+	return netdev_rx_handler_get_priv_by_prio(dev,
+						  RX_HANDLER_PRIO_BRIDGE,
+						  struct net_bridge_port,
+						  rx_handler);
 }
 
 struct br_cpu_netstats {
@@ -382,7 +397,8 @@ extern u32 br_features_recompute(struct net_bridge *br, u32 features);
 
 /* br_input.c */
 extern int br_handle_frame_finish(struct sk_buff *skb);
-extern rx_handler_result_t br_handle_frame(struct sk_buff **pskb);
+extern rx_handler_result_t br_handle_frame(struct sk_buff **pskb,
+					   struct rx_handler *rx_handler);
 
 /* br_ioctl.c */
 extern int br_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
diff --git a/net/core/dev.c b/net/core/dev.c
index 9ca1514..ea5e3fb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3053,10 +3053,55 @@ out:
 #endif
 
 /**
+ *	netdev_rx_handler_get_by_prio - get receive handler struct by priority
+ *	@dev: net device
+ *	@prio: receive handler priority
+ *
+ *	Find and return receive handler for given priority.
+ *
+ *	The caller must hold the rtnl_mutex.
+ */
+struct rx_handler *
+netdev_rx_handler_get_by_prio(const struct net_device *dev, unsigned int prio)
+{
+	struct rx_handler *rx_handler;
+
+	ASSERT_RTNL();
+	list_for_each_entry(rx_handler, &dev->rx_handler_list, list)
+		if (rx_handler->prio == prio)
+			return rx_handler;
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(netdev_rx_handler_get_by_prio);
+
+/**
+ *	netdev_rx_handler_get_by_prio_rcu - get receive handler struct by priority
+ *	@dev: net device
+ *	@prio: receive handler priority
+ *
+ *	RCU variant to find and return receive handler for given priority.
+ *
+ *	The caller must hold the rcu_read_lock.
+ */
+struct rx_handler *
+netdev_rx_handler_get_by_prio_rcu(const struct net_device *dev,
+				  unsigned int prio)
+{
+	struct rx_handler *rx_handler;
+
+	list_for_each_entry_rcu(rx_handler, &dev->rx_handler_list, list)
+		if (rx_handler->prio == prio)
+			return rx_handler;
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(netdev_rx_handler_get_by_prio_rcu);
+
+/**
  *	netdev_rx_handler_register - register receive handler
  *	@dev: device to register a handler for
- *	@rx_handler: receive handler to register
- *	@rx_handler_data: data pointer that is used by rx handler
+ *	@rx_handler: receive handler structure to register
+ *	@callback: receive handler callback function to register
+ *	@prio: receive handler priority
  *
  *	Register a receive hander for a device. This handler will then be
  *	called from __netif_receive_skb. A negative errno code is returned
@@ -3067,17 +3112,24 @@ out:
  *	For a general description of rx_handler, see enum rx_handler_result.
  */
 int netdev_rx_handler_register(struct net_device *dev,
-			       rx_handler_func_t *rx_handler,
-			       void *rx_handler_data)
+			       struct rx_handler *rx_handler,
+			       rx_handler_func_t *callback, unsigned int prio)
 {
-	ASSERT_RTNL();
+	struct list_head *pos;
 
-	if (dev->rx_handler)
+	ASSERT_RTNL();
+	if (netdev_rx_handler_get_by_prio(dev, prio))
 		return -EBUSY;
+	list_for_each(pos, &dev->rx_handler_list) {
+		struct rx_handler *entry;
 
-	rcu_assign_pointer(dev->rx_handler_data, rx_handler_data);
-	rcu_assign_pointer(dev->rx_handler, rx_handler);
-
+		entry = list_entry(pos, struct rx_handler, list);
+		if (prio > entry->prio)
+			break;
+	}
+	rx_handler->callback = callback;
+	rx_handler->prio = prio;
+	list_add_rcu(&rx_handler->list, pos);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(netdev_rx_handler_register);
@@ -3085,24 +3137,24 @@ EXPORT_SYMBOL_GPL(netdev_rx_handler_register);
 /**
  *	netdev_rx_handler_unregister - unregister receive handler
  *	@dev: device to unregister a handler from
+ *	@prio: handler priority
  *
  *	Unregister a receive hander from a device.
  *
  *	The caller must hold the rtnl_mutex.
  */
-void netdev_rx_handler_unregister(struct net_device *dev)
+void netdev_rx_handler_unregister(struct net_device *dev,
+				  struct rx_handler *rx_handler)
 {
-
 	ASSERT_RTNL();
-	rcu_assign_pointer(dev->rx_handler, NULL);
-	rcu_assign_pointer(dev->rx_handler_data, NULL);
+	list_del_rcu(&rx_handler->list);
 }
 EXPORT_SYMBOL_GPL(netdev_rx_handler_unregister);
 
 static int __netif_receive_skb(struct sk_buff *skb)
 {
 	struct packet_type *ptype, *pt_prev;
-	rx_handler_func_t *rx_handler;
+	struct rx_handler *rx_handler;
 	struct net_device *orig_dev;
 	struct net_device *null_or_dev;
 	bool deliver_exact = false;
@@ -3162,13 +3214,12 @@ another_round:
 ncls:
 #endif
 
-	rx_handler = rcu_dereference(skb->dev->rx_handler);
-	if (rx_handler) {
+	list_for_each_entry_rcu(rx_handler, &skb->dev->rx_handler_list, list) {
 		if (pt_prev) {
 			ret = deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev = NULL;
 		}
-		switch (rx_handler(&skb)) {
+		switch (rx_handler->callback(&skb, rx_handler)) {
 		case RX_HANDLER_CONSUMED:
 			goto out;
 		case RX_HANDLER_ANOTHER:
@@ -5881,6 +5932,8 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	INIT_LIST_HEAD(&dev->napi_list);
 	INIT_LIST_HEAD(&dev->unreg_list);
 	INIT_LIST_HEAD(&dev->link_watch_list);
+	INIT_LIST_HEAD(&dev->rx_handler_list);
+
 	dev->priv_flags = IFF_XMIT_DST_RELEASE;
 	setup(dev);
 
-- 
1.7.6


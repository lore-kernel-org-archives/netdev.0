From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] net: squash ->rx_handler and ->rx_handler_data into single rcu pointer
Date: Sat, 30 Mar 2013 16:57:14 +0100
Message-ID: <1364659034-7049-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, fubar@us.ibm.com,
	andy@greyhouse.net, kaber@trash.net, stephen@networkplumber.org,
	jesse@nicira.com, alexander.h.duyck@intel.com,
	xiyou.wangcong@gmail.com, dev@openvswitch.org, rostedt@goodmis.org,
	nicolas.2p.debian@gmail.com, tglx@linutronix.de,
	streeter@redhat.com, paulmck@us.ibm.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:50023 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756609Ab3C3P5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Mar 2013 11:57:20 -0400
Received: by mail-ee0-f47.google.com with SMTP id t10so554809eei.34
        for <netdev@vger.kernel.org>; Sat, 30 Mar 2013 08:57:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to have two pointers in struct netdevice for rx_handler func and
priv data. Just embed rx_handler structure into driver port_priv and
have ->func pointer there. This introduces no performance penalty,
reduces struct netdevice by one pointer and reduces number of needed
rcu_dereference calls from 2 to 1.

Note this also fixes the race bug pointed out by Steven Rostedt and
fixed by patch "[PATCH] net: add a synchronize_net() in
netdev_rx_handler_unregister()" by Eric Dumazet. This is based on
current net-next tree where the patch is not applied yet.
I can rebase it on whatever tree/state, just say so.

Smoke tested with all drivers who use rx_handler.

Reported-by: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/bonding/bond_main.c |  9 +++++----
 drivers/net/bonding/bonding.h   | 16 +++++++++++-----
 drivers/net/macvlan.c           | 30 +++++++++++++++++++++---------
 drivers/net/team/team.c         | 22 +++++++++++-----------
 include/linux/if_team.h         |  1 +
 include/linux/netdevice.h       | 17 ++++++++++++-----
 net/bridge/br_if.c              |  3 ++-
 net/bridge/br_input.c           |  5 +++--
 net/bridge/br_private.h         | 26 ++++++++++++++++++--------
 net/core/dev.c                  | 24 +++++++++++++++++-------
 net/openvswitch/dp_notify.c     |  2 +-
 net/openvswitch/vport-netdev.c  | 22 +++++-----------------
 net/openvswitch/vport-netdev.h  | 16 +++++++++++++++-
 net/openvswitch/vport.h         |  2 ++
 14 files changed, 124 insertions(+), 71 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 11a8cb3..03e9895 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1440,7 +1440,8 @@ static bool bond_should_deliver_exact_match(struct sk_buff *skb,
 	return false;
 }
 
-static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
+static rx_handler_result_t
+bond_handle_frame(struct sk_buff **pskb, struct netdev_rx_handler *rx_handler)
 {
 	struct sk_buff *skb = *pskb;
 	struct slave *slave;
@@ -1455,7 +1456,7 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
 
 	*pskb = skb;
 
-	slave = bond_slave_get_rcu(skb->dev);
+	slave = bond_slave_get_by_rx_handler(rx_handler);
 	bond = slave->bond;
 
 	if (bond->params.arp_interval)
@@ -1880,8 +1881,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	if (res)
 		goto err_detach;
 
-	res = netdev_rx_handler_register(slave_dev, bond_handle_frame,
-					 new_slave);
+	netdev_rx_handler_init(&new_slave->rx_handler, bond_handle_frame);
+	res = netdev_rx_handler_register(slave_dev, &new_slave->rx_handler);
 	if (res) {
 		pr_debug("Error %d calling netdev_rx_handler_register\n", res);
 		goto err_dest_symlinks;
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 2baec24..cd3ccb4 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -172,7 +172,8 @@ struct vlan_entry {
 };
 
 struct slave {
-	struct net_device *dev; /* first - useful for panic debug */
+	struct netdev_rx_handler rx_handler;
+	struct net_device *dev;
 	struct slave *next;
 	struct slave *prev;
 	struct bonding *bond; /* our master */
@@ -256,11 +257,16 @@ static inline bool bond_vlan_used(struct bonding *bond)
 	return !list_empty(&bond->vlan_list);
 }
 
-#define bond_slave_get_rcu(dev) \
-	((struct slave *) rcu_dereference(dev->rx_handler_data))
+static inline struct slave *
+bond_slave_get_by_rx_handler(const struct netdev_rx_handler *rx_handler)
+{
+	return container_of(rx_handler, struct slave, rx_handler);
+}
 
-#define bond_slave_get_rtnl(dev) \
-	((struct slave *) rtnl_dereference(dev->rx_handler_data))
+static inline struct slave *bond_slave_get_rtnl(const struct net_device *dev)
+{
+	return bond_slave_get_by_rx_handler(rtnl_dereference(dev->rx_handler));
+}
 
 /**
  * Returns NULL if the net_device does not belong to any of the bond's slaves
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 73abbc1..9a065e4 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -36,6 +36,7 @@
 #define MACVLAN_HASH_SIZE	(1 << BITS_PER_BYTE)
 
 struct macvlan_port {
+	struct netdev_rx_handler rx_handler;
 	struct net_device	*dev;
 	struct hlist_head	vlan_hash[MACVLAN_HASH_SIZE];
 	struct list_head	vlans;
@@ -46,9 +47,17 @@ struct macvlan_port {
 
 static void macvlan_port_destroy(struct net_device *dev);
 
-#define macvlan_port_get_rcu(dev) \
-	((struct macvlan_port *) rcu_dereference(dev->rx_handler_data))
-#define macvlan_port_get(dev) ((struct macvlan_port *) dev->rx_handler_data)
+static struct macvlan_port *
+macvlan_port_get_by_rx_handler(const struct netdev_rx_handler *rx_handler)
+{
+	return container_of(rx_handler, struct macvlan_port, rx_handler);
+}
+
+static struct macvlan_port *macvlan_port_get_rtnl(const struct net_device *dev)
+{
+	return macvlan_port_get_by_rx_handler(rtnl_dereference(dev->rx_handler));
+}
+
 #define macvlan_port_exists(dev) (dev->priv_flags & IFF_MACVLAN_PORT)
 
 static struct macvlan_dev *macvlan_hash_lookup(const struct macvlan_port *port,
@@ -174,7 +183,9 @@ static void macvlan_broadcast(struct sk_buff *skb,
 }
 
 /* called under rcu_read_lock() from netif_receive_skb */
-static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
+static rx_handler_result_t
+macvlan_handle_frame(struct sk_buff **pskb,
+		     struct netdev_rx_handler *rx_handler)
 {
 	struct macvlan_port *port;
 	struct sk_buff *skb = *pskb;
@@ -185,7 +196,7 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 	unsigned int len = 0;
 	int ret = NET_RX_DROP;
 
-	port = macvlan_port_get_rcu(skb->dev);
+	port = macvlan_port_get_by_rx_handler(rx_handler);
 	if (is_multicast_ether_addr(eth->h_dest)) {
 		skb = ip_check_defrag(skb, IP_DEFRAG_MACVLAN);
 		if (!skb)
@@ -693,7 +704,8 @@ static int macvlan_port_create(struct net_device *dev)
 	for (i = 0; i < MACVLAN_HASH_SIZE; i++)
 		INIT_HLIST_HEAD(&port->vlan_hash[i]);
 
-	err = netdev_rx_handler_register(dev, macvlan_handle_frame, port);
+	netdev_rx_handler_init(&port->rx_handler, macvlan_handle_frame);
+	err = netdev_rx_handler_register(dev, &port->rx_handler);
 	if (err)
 		kfree(port);
 	else
@@ -703,7 +715,7 @@ static int macvlan_port_create(struct net_device *dev)
 
 static void macvlan_port_destroy(struct net_device *dev)
 {
-	struct macvlan_port *port = macvlan_port_get(dev);
+	struct macvlan_port *port = macvlan_port_get_rtnl(dev);
 
 	dev->priv_flags &= ~IFF_MACVLAN_PORT;
 	netdev_rx_handler_unregister(dev);
@@ -772,7 +784,7 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 		if (err < 0)
 			return err;
 	}
-	port = macvlan_port_get(lowerdev);
+	port = macvlan_port_get_rtnl(lowerdev);
 
 	/* Only 1 macvlan device can be created in passthru mode */
 	if (port->passthru)
@@ -921,7 +933,7 @@ static int macvlan_device_event(struct notifier_block *unused,
 	if (!macvlan_port_exists(dev))
 		return NOTIFY_DONE;
 
-	port = macvlan_port_get(dev);
+	port = macvlan_port_get_rtnl(dev);
 
 	switch (event) {
 	case NETDEV_CHANGE:
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 621c1bd..86dcbf1 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -40,18 +40,17 @@
 
 #define team_port_exists(dev) (dev->priv_flags & IFF_TEAM_PORT)
 
-static struct team_port *team_port_get_rcu(const struct net_device *dev)
+static struct team_port *
+team_port_get_by_rx_handler(const struct netdev_rx_handler *rx_handler)
 {
-	struct team_port *port = rcu_dereference(dev->rx_handler_data);
-
-	return team_port_exists(dev) ? port : NULL;
+	return container_of(rx_handler, struct team_port, rx_handler);
 }
 
 static struct team_port *team_port_get_rtnl(const struct net_device *dev)
 {
-	struct team_port *port = rtnl_dereference(dev->rx_handler_data);
-
-	return team_port_exists(dev) ? port : NULL;
+	if (!team_port_exists(dev))
+		return NULL;
+	return team_port_get_by_rx_handler(rtnl_dereference(dev->rx_handler));
 }
 
 /*
@@ -632,7 +631,8 @@ static int team_change_mode(struct team *team, const char *kind)
  ************************/
 
 /* note: already called with rcu_read_lock */
-static rx_handler_result_t team_handle_frame(struct sk_buff **pskb)
+static rx_handler_result_t
+team_handle_frame(struct sk_buff **pskb, struct netdev_rx_handler *rx_handler)
 {
 	struct sk_buff *skb = *pskb;
 	struct team_port *port;
@@ -645,7 +645,7 @@ static rx_handler_result_t team_handle_frame(struct sk_buff **pskb)
 
 	*pskb = skb;
 
-	port = team_port_get_rcu(skb->dev);
+	port = team_port_get_by_rx_handler(rx_handler);
 	team = port->team;
 	if (!team_port_enabled(port)) {
 		/* allow exact match delivery for disabled ports */
@@ -1076,8 +1076,8 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
 		goto err_set_upper_link;
 	}
 
-	err = netdev_rx_handler_register(port_dev, team_handle_frame,
-					 port);
+	netdev_rx_handler_init(&port->rx_handler, team_handle_frame);
+	err = netdev_rx_handler_register(port_dev, &port->rx_handler);
 	if (err) {
 		netdev_err(dev, "Device %s failed to register rx_handler\n",
 			   portname);
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index 4474557..72fd12e 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -29,6 +29,7 @@ struct team_pcpu_stats {
 struct team;
 
 struct team_port {
+	struct netdev_rx_handler rx_handler;
 	struct net_device *dev;
 	struct hlist_node hlist; /* node in enabled ports hash list */
 	struct list_head list; /* node in ordinary list */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1dbb02c..738226e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -387,8 +387,15 @@ enum rx_handler_result {
 	RX_HANDLER_EXACT,
 	RX_HANDLER_PASS,
 };
+
 typedef enum rx_handler_result rx_handler_result_t;
-typedef rx_handler_result_t rx_handler_func_t(struct sk_buff **pskb);
+struct netdev_rx_handler;
+typedef rx_handler_result_t rx_handler_func_t(struct sk_buff **pskb,
+					      struct netdev_rx_handler *rx_handler);
+
+struct netdev_rx_handler {
+	rx_handler_func_t *func;
+};
 
 extern void __napi_schedule(struct napi_struct *n);
 
@@ -1208,8 +1215,7 @@ struct net_device {
 #endif
 #endif
 
-	rx_handler_func_t __rcu	*rx_handler;
-	void __rcu		*rx_handler_data;
+	struct netdev_rx_handler __rcu *rx_handler;
 
 	struct netdev_queue __rcu *ingress_queue;
 
@@ -2212,9 +2218,10 @@ static inline void napi_free_frags(struct napi_struct *napi)
 	napi->skb = NULL;
 }
 
+extern void netdev_rx_handler_init(struct netdev_rx_handler *rx_handler,
+				   rx_handler_func_t *func);
 extern int netdev_rx_handler_register(struct net_device *dev,
-				      rx_handler_func_t *rx_handler,
-				      void *rx_handler_data);
+				      struct netdev_rx_handler *rx_handler);
 extern void netdev_rx_handler_unregister(struct net_device *dev);
 
 extern bool		dev_valid_name(const char *name);
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index ef1b914..f855c07 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -370,7 +370,8 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	if (err)
 		goto err4;
 
-	err = netdev_rx_handler_register(dev, br_handle_frame, p);
+	netdev_rx_handler_init(&p->rx_handler, br_handle_frame);
+	err = netdev_rx_handler_register(dev, &p->rx_handler);
 	if (err)
 		goto err5;
 
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 828e2bc..a8bc5a6 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -150,7 +150,8 @@ static int br_handle_local_finish(struct sk_buff *skb)
  * Return NULL if skb is handled
  * note: already called with rcu_read_lock
  */
-rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
+rx_handler_result_t br_handle_frame(struct sk_buff **pskb,
+				    struct netdev_rx_handler *rx_handler)
 {
 	struct net_bridge_port *p;
 	struct sk_buff *skb = *pskb;
@@ -167,7 +168,7 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 	if (!skb)
 		return RX_HANDLER_CONSUMED;
 
-	p = br_port_get_rcu(skb->dev);
+	p = br_port_get_by_rx_handler(rx_handler);
 
 	if (unlikely(is_link_local_ether_addr(dest))) {
 		/*
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 3cbf5be..727cc51 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -127,6 +127,7 @@ struct net_bridge_mdb_htable
 
 struct net_bridge_port
 {
+	struct netdev_rx_handler	rx_handler;
 	struct net_bridge		*br;
 	struct net_device		*dev;
 	struct list_head		list;
@@ -180,18 +181,26 @@ struct net_bridge_port
 
 #define br_port_exists(dev) (dev->priv_flags & IFF_BRIDGE_PORT)
 
-static inline struct net_bridge_port *br_port_get_rcu(const struct net_device *dev)
+static inline struct net_bridge_port *
+br_port_get_by_rx_handler(const struct netdev_rx_handler *rx_handler)
 {
-	struct net_bridge_port *port =
-			rcu_dereference_rtnl(dev->rx_handler_data);
+	return container_of(rx_handler, struct net_bridge_port, rx_handler);
+}
 
-	return br_port_exists(dev) ? port : NULL;
+static inline struct net_bridge_port *
+br_port_get_rcu(const struct net_device *dev)
+{
+	if (!br_port_exists(dev))
+		return NULL;
+	return br_port_get_by_rx_handler(rcu_dereference_rtnl(dev->rx_handler));
 }
 
-static inline struct net_bridge_port *br_port_get_rtnl(struct net_device *dev)
+static inline struct net_bridge_port *
+br_port_get_rtnl(const struct net_device *dev)
 {
-	return br_port_exists(dev) ?
-		rtnl_dereference(dev->rx_handler_data) : NULL;
+	if (!br_port_exists(dev))
+		return NULL;
+	return br_port_get_by_rx_handler(rtnl_dereference(dev->rx_handler));
 }
 
 struct br_cpu_netstats {
@@ -429,7 +438,8 @@ extern netdev_features_t br_features_recompute(struct net_bridge *br,
 
 /* br_input.c */
 extern int br_handle_frame_finish(struct sk_buff *skb);
-extern rx_handler_result_t br_handle_frame(struct sk_buff **pskb);
+extern rx_handler_result_t br_handle_frame(struct sk_buff **pskb,
+					   struct netdev_rx_handler *rx_handler);
 
 /* br_ioctl.c */
 extern int br_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
diff --git a/net/core/dev.c b/net/core/dev.c
index 2db88df..88e839c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3296,10 +3296,23 @@ out:
 #endif
 
 /**
+ *	netdev_rx_handler_init - init receive handler structure
+ *	@rx_handler: receive handler to init
+ *	@func: receive handler function
+ *
+ *	Inits receive handler structure.
+ */
+void netdev_rx_handler_init(struct netdev_rx_handler *rx_handler,
+			    rx_handler_func_t *func)
+{
+	rx_handler->func = func;
+}
+EXPORT_SYMBOL_GPL(netdev_rx_handler_init);
+
+/**
  *	netdev_rx_handler_register - register receive handler
  *	@dev: device to register a handler for
  *	@rx_handler: receive handler to register
- *	@rx_handler_data: data pointer that is used by rx handler
  *
  *	Register a receive hander for a device. This handler will then be
  *	called from __netif_receive_skb. A negative errno code is returned
@@ -3310,15 +3323,13 @@ out:
  *	For a general description of rx_handler, see enum rx_handler_result.
  */
 int netdev_rx_handler_register(struct net_device *dev,
-			       rx_handler_func_t *rx_handler,
-			       void *rx_handler_data)
+			       struct netdev_rx_handler *rx_handler)
 {
 	ASSERT_RTNL();
 
 	if (dev->rx_handler)
 		return -EBUSY;
 
-	rcu_assign_pointer(dev->rx_handler_data, rx_handler_data);
 	rcu_assign_pointer(dev->rx_handler, rx_handler);
 
 	return 0;
@@ -3338,7 +3349,6 @@ void netdev_rx_handler_unregister(struct net_device *dev)
 
 	ASSERT_RTNL();
 	RCU_INIT_POINTER(dev->rx_handler, NULL);
-	RCU_INIT_POINTER(dev->rx_handler_data, NULL);
 }
 EXPORT_SYMBOL_GPL(netdev_rx_handler_unregister);
 
@@ -3362,7 +3372,7 @@ static bool skb_pfmemalloc_protocol(struct sk_buff *skb)
 static int __netif_receive_skb_core(struct sk_buff *skb, bool pfmemalloc)
 {
 	struct packet_type *ptype, *pt_prev;
-	rx_handler_func_t *rx_handler;
+	struct netdev_rx_handler *rx_handler;
 	struct net_device *orig_dev;
 	struct net_device *null_or_dev;
 	bool deliver_exact = false;
@@ -3445,7 +3455,7 @@ ncls:
 			ret = deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev = NULL;
 		}
-		switch (rx_handler(&skb)) {
+		switch (rx_handler->func(&skb, rx_handler)) {
 		case RX_HANDLER_CONSUMED:
 			ret = NET_RX_SUCCESS;
 			goto unlock;
diff --git a/net/openvswitch/dp_notify.c b/net/openvswitch/dp_notify.c
index 5558350..5248f8e 100644
--- a/net/openvswitch/dp_notify.c
+++ b/net/openvswitch/dp_notify.c
@@ -32,7 +32,7 @@ static int dp_device_event(struct notifier_block *unused, unsigned long event,
 	if (ovs_is_internal_dev(dev))
 		vport = ovs_internal_dev_get_vport(dev);
 	else
-		vport = ovs_netdev_get_vport(dev);
+		vport = ovs_netdev_get_vport_rtnl(dev);
 
 	if (!vport)
 		return NOTIFY_DONE;
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 2130d61..0ff6aa1 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -35,9 +35,6 @@
 /* Must be called with rcu_read_lock. */
 static void netdev_port_receive(struct vport *vport, struct sk_buff *skb)
 {
-	if (unlikely(!vport))
-		goto error;
-
 	if (unlikely(skb_warn_if_lro(skb)))
 		goto error;
 
@@ -57,7 +54,8 @@ error:
 }
 
 /* Called with rcu_read_lock and bottom-halves disabled. */
-static rx_handler_result_t netdev_frame_hook(struct sk_buff **pskb)
+static rx_handler_result_t
+netdev_frame_hook(struct sk_buff **pskb, struct netdev_rx_handler *rx_handler)
 {
 	struct sk_buff *skb = *pskb;
 	struct vport *vport;
@@ -65,7 +63,7 @@ static rx_handler_result_t netdev_frame_hook(struct sk_buff **pskb)
 	if (unlikely(skb->pkt_type == PACKET_LOOPBACK))
 		return RX_HANDLER_PASS;
 
-	vport = ovs_netdev_get_vport(skb->dev);
+	vport = ovs_netdev_get_vport_by_rx_handler(rx_handler);
 
 	netdev_port_receive(vport, skb);
 
@@ -100,8 +98,8 @@ static struct vport *netdev_create(const struct vport_parms *parms)
 		goto error_put;
 	}
 
-	err = netdev_rx_handler_register(netdev_vport->dev, netdev_frame_hook,
-					 vport);
+	netdev_rx_handler_init(&vport->rx_handler, netdev_frame_hook);
+	err = netdev_rx_handler_register(netdev_vport->dev, &vport->rx_handler);
 	if (err)
 		goto error_put;
 
@@ -185,16 +183,6 @@ error:
 	return 0;
 }
 
-/* Returns null if this device is not attached to a datapath. */
-struct vport *ovs_netdev_get_vport(struct net_device *dev)
-{
-	if (likely(dev->priv_flags & IFF_OVS_DATAPATH))
-		return (struct vport *)
-			rcu_dereference_rtnl(dev->rx_handler_data);
-	else
-		return NULL;
-}
-
 const struct vport_ops ovs_netdev_vport_ops = {
 	.type		= OVS_VPORT_TYPE_NETDEV,
 	.create		= netdev_create,
diff --git a/net/openvswitch/vport-netdev.h b/net/openvswitch/vport-netdev.h
index 6478079..d3f1471 100644
--- a/net/openvswitch/vport-netdev.h
+++ b/net/openvswitch/vport-netdev.h
@@ -24,7 +24,21 @@
 
 #include "vport.h"
 
-struct vport *ovs_netdev_get_vport(struct net_device *dev);
+#define ovs_netdev_vport_exists(dev) (dev->priv_flags & IFF_OVS_DATAPATH)
+
+static inline struct vport *
+ovs_netdev_get_vport_by_rx_handler(const struct netdev_rx_handler *rx_handler)
+{
+	return container_of(rx_handler, struct vport, rx_handler);
+}
+
+static inline struct vport *
+ovs_netdev_get_vport_rtnl(const struct net_device *dev)
+{
+	if (!ovs_netdev_vport_exists(dev))
+		return NULL;
+	return ovs_netdev_get_vport_by_rx_handler(rtnl_dereference(dev->rx_handler));
+}
 
 struct netdev_vport {
 	struct rcu_head rcu;
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index aee7d43..a7a07c0 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -67,6 +67,7 @@ struct vport_err_stats {
 
 /**
  * struct vport - one port within a datapath
+ * @rx_handler: RX handler structure.
  * @rcu: RCU callback head for deferred destruction.
  * @dp: Datapath to which this port belongs.
  * @upcall_portid: The Netlink port to use for packets received on this port that
@@ -80,6 +81,7 @@ struct vport_err_stats {
  * @err_stats: Points to error statistics used and maintained by vport
  */
 struct vport {
+	struct netdev_rx_handler rx_handler;
 	struct rcu_head rcu;
 	struct datapath	*dp;
 	u32 upcall_portid;
-- 
1.8.1.2

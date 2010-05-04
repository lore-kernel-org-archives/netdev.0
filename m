From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] net: change bridge/macvlan hook to be be generic
Date: Tue, 4 May 2010 15:37:58 -0700
Message-ID: <20100504153758.0ed3a87d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35938 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757608Ab0EDWiE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 May 2010 18:38:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The existing macvlan and bridge have special hooks in the packet input
path. This patch changes it to a generic hook chain, like the packet type
processing. I have been wanting to look into flow based switching, etc...

Pro: generic code rather than special purpose
     safer against race during insertion/removal
     easier for out of tree network code

Con: performance (loop vs unrolled) and calling module for each packet
     easier for out of tree network code

This is prototype only, don't use it as is...



---
 drivers/net/macvlan.c     |   24 ++++++----
 include/linux/netdevice.h |   19 ++++++++
 net/bridge/br.c           |    4 -
 net/bridge/br_fdb.c       |    5 ++
 net/bridge/br_input.c     |   25 ++++++++--
 net/bridge/br_private.h   |    3 -
 net/core/dev.c            |  107 +++++++++++++++++-----------------------------
 7 files changed, 103 insertions(+), 84 deletions(-)

--- a/drivers/net/macvlan.c	2010-05-04 15:15:54.532454436 -0700
+++ b/drivers/net/macvlan.c	2010-05-04 15:30:19.461536637 -0700
@@ -145,21 +145,24 @@ static void macvlan_broadcast(struct sk_
 }
 
 /* called under rcu_read_lock() from netif_receive_skb */
-static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
+static struct sk_buff *macvlan_handle_frame(struct net_device *orig_dev,
+					    struct sk_buff *skb)
 {
-	const struct ethhdr *eth = eth_hdr(skb);
+	const struct ethhdr *eth;
 	const struct macvlan_port *port;
 	const struct macvlan_dev *vlan;
-	const struct macvlan_dev *src;
 	struct net_device *dev;
 	unsigned int len;
 
-	port = rcu_dereference(skb->dev->macvlan_port);
+	port = rcu_dereference(orig_dev->macvlan_port);
 	if (port == NULL)
 		return skb;
 
+	eth = eth_hdr(skb);
 	if (is_multicast_ether_addr(eth->h_dest)) {
-		src = macvlan_hash_lookup(port, eth->h_source);
+		const struct macvlan_dev *src
+			= macvlan_hash_lookup(port, eth->h_source);
+
 		if (!src)
 			/* frame comes from an external address */
 			macvlan_broadcast(skb, port, NULL,
@@ -759,19 +762,24 @@ static struct notifier_block macvlan_not
 	.notifier_call	= macvlan_device_event,
 };
 
+static struct packet_handler macvlan_hook = {
+	.priority = MACVLAN_HANDLER,
+	.func     = macvlan_handle_frame,
+};
+
 static int __init macvlan_init_module(void)
 {
 	int err;
 
 	register_netdevice_notifier(&macvlan_notifier_block);
-	macvlan_handle_frame_hook = macvlan_handle_frame;
 
 	err = macvlan_link_register(&macvlan_link_ops);
 	if (err < 0)
 		goto err1;
+
+	dev_add_handler(&macvlan_hook);
 	return 0;
 err1:
-	macvlan_handle_frame_hook = NULL;
 	unregister_netdevice_notifier(&macvlan_notifier_block);
 	return err;
 }
@@ -779,7 +787,7 @@ err1:
 static void __exit macvlan_cleanup_module(void)
 {
 	rtnl_link_unregister(&macvlan_link_ops);
-	macvlan_handle_frame_hook = NULL;
+	dev_remove_handler(&macvlan_hook);
 	unregister_netdevice_notifier(&macvlan_notifier_block);
 }
 
--- a/include/linux/netdevice.h	2010-05-04 15:15:54.592523341 -0700
+++ b/include/linux/netdevice.h	2010-05-04 15:26:14.741067048 -0700
@@ -1011,10 +1011,15 @@ struct net_device {
 	/* mid-layer private */
 	void			*ml_priv;
 
+
+#if defined(CONFIG_BRIDGE) || defined (CONFIG_BRIDGE_MODULE)
 	/* bridge stuff */
 	struct net_bridge_port	*br_port;
+#endif
+#if defined(CONFIG_MACVLAN) || defined(CONFIG_MACVLAN_MODULE)
 	/* macvlan */
 	struct macvlan_port	*macvlan_port;
+#endif
 	/* GARP */
 	struct garp_port	*garp_port;
 
@@ -1204,6 +1209,17 @@ struct packet_type {
 	struct list_head	list;
 };
 
+enum handler_priority {
+	BRIDGE_HANDLER    = 1,
+	MACVLAN_HANDLER,
+};
+
+struct packet_handler {
+	struct list_head       list;
+	enum handler_priority  priority;
+	struct sk_buff *       (*func)(struct net_device *, struct sk_buff *);
+};
+
 #include <linux/interrupt.h>
 #include <linux/notifier.h>
 
@@ -1259,6 +1275,9 @@ extern void		dev_add_pack(struct packet_
 extern void		dev_remove_pack(struct packet_type *pt);
 extern void		__dev_remove_pack(struct packet_type *pt);
 
+extern void		dev_add_handler(struct packet_handler *h);
+extern void		dev_remove_handler(struct packet_handler *h);
+
 extern struct net_device	*dev_get_by_flags(struct net *net, unsigned short flags,
 						  unsigned short mask);
 extern struct net_device	*dev_get_by_name(struct net *net, const char *name);
--- a/net/bridge/br.c	2010-05-04 15:15:54.542453499 -0700
+++ b/net/bridge/br.c	2010-05-04 15:16:10.111257969 -0700
@@ -63,7 +63,7 @@ static int __init br_init(void)
 		goto err_out4;
 
 	brioctl_set(br_ioctl_deviceless_stub);
-	br_handle_frame_hook = br_handle_frame;
+	dev_add_handler(&br_packet_hook);
 
 #if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
 	br_fdb_test_addr_hook = br_fdb_test_addr;
@@ -100,7 +100,7 @@ static void __exit br_deinit(void)
 	br_fdb_test_addr_hook = NULL;
 #endif
 
-	br_handle_frame_hook = NULL;
+	dev_remove_handler(&br_packet_hook);
 	br_fdb_fini();
 }
 
--- a/net/bridge/br_fdb.c	2010-05-04 15:15:54.552508079 -0700
+++ b/net/bridge/br_fdb.c	2010-05-04 15:16:23.020967283 -0700
@@ -253,6 +253,11 @@ int br_fdb_test_addr(struct net_device *
 
 	return ret;
 }
+
+/* This hook is defined here for ATM LANE */
+int (*br_fdb_test_addr_hook)(struct net_device *dev,
+			     unsigned char *addr) __read_mostly;
+EXPORT_SYMBOL_GPL(br_fdb_test_addr_hook);
 #endif /* CONFIG_ATM_LANE */
 
 /*
--- a/net/bridge/br_input.c	2010-05-04 15:15:54.562453677 -0700
+++ b/net/bridge/br_input.c	2010-05-04 15:21:35.521115299 -0700
@@ -133,13 +133,19 @@ static inline int is_link_local(const un
 /*
  * Called via br_handle_frame_hook.
  * Return NULL if skb is handled
- * note: already called with rcu_read_lock (preempt_disabled)
+ * note: already called with rcu_read_lock
  */
-struct sk_buff *br_handle_frame(struct net_bridge_port *p, struct sk_buff *skb)
+static struct sk_buff *br_handle_frame(struct net_device *dev,
+				       struct sk_buff *skb)
 {
-	const unsigned char *dest = eth_hdr(skb)->h_dest;
+	const unsigned char *dest;
+	struct net_bridge_port *port;
 	int (*rhook)(struct sk_buff *skb);
 
+	if (skb->pkt_type == PACKET_LOOPBACK ||
+	    (port = rcu_dereference(skb->dev->br_port)) == NULL)
+		return skb;
+
 	if (!is_valid_ether_addr(eth_hdr(skb)->h_source))
 		goto drop;
 
@@ -147,13 +153,14 @@ struct sk_buff *br_handle_frame(struct n
 	if (!skb)
 		return NULL;
 
+	dest = eth_hdr(skb)->h_dest;
 	if (unlikely(is_link_local(dest))) {
 		/* Pause frames shouldn't be passed up by driver anyway */
 		if (skb->protocol == htons(ETH_P_PAUSE))
 			goto drop;
 
 		/* If STP is turned off, then forward */
-		if (p->br->stp_enabled == BR_NO_STP && dest[5] == 0)
+		if (port->br->stp_enabled == BR_NO_STP && dest[5] == 0)
 			goto forward;
 
 		if (NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
@@ -164,7 +171,7 @@ struct sk_buff *br_handle_frame(struct n
 	}
 
 forward:
-	switch (p->state) {
+	switch (port->state) {
 	case BR_STATE_FORWARDING:
 		rhook = rcu_dereference(br_should_route_hook);
 		if (rhook != NULL) {
@@ -174,7 +181,7 @@ forward:
 		}
 		/* fall through */
 	case BR_STATE_LEARNING:
-		if (!compare_ether_addr(p->br->dev->dev_addr, dest))
+		if (!compare_ether_addr(port->br->dev->dev_addr, dest))
 			skb->pkt_type = PACKET_HOST;
 
 		NF_HOOK(PF_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
@@ -186,3 +193,9 @@ drop:
 	}
 	return NULL;
 }
+
+struct packet_handler br_packet_hook = {
+	.priority = BRIDGE_HANDLER,
+	.func     = br_handle_frame,
+};
+
--- a/net/bridge/br_private.h	2010-05-04 15:15:54.542453499 -0700
+++ b/net/bridge/br_private.h	2010-05-04 15:16:10.111257969 -0700
@@ -300,8 +300,7 @@ extern void br_features_recompute(struct
 
 /* br_input.c */
 extern int br_handle_frame_finish(struct sk_buff *skb);
-extern struct sk_buff *br_handle_frame(struct net_bridge_port *p,
-				       struct sk_buff *skb);
+extern struct packet_handler br_packet_hook;
 
 /* br_ioctl.c */
 extern int br_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
--- a/net/core/dev.c	2010-05-04 15:15:54.572453666 -0700
+++ b/net/core/dev.c	2010-05-04 15:23:03.945389538 -0700
@@ -175,6 +175,9 @@ static DEFINE_SPINLOCK(ptype_lock);
 static struct list_head ptype_base[PTYPE_HASH_SIZE] __read_mostly;
 static struct list_head ptype_all __read_mostly;	/* Taps */
 
+static DEFINE_SPINLOCK(phook_lock);
+static struct list_head packet_hook __read_mostly;
+
 /*
  * The @dev_base_head list is protected by @dev_base_lock and the rtnl
  * semaphore.
@@ -459,6 +462,33 @@ void dev_remove_pack(struct packet_type 
 }
 EXPORT_SYMBOL(dev_remove_pack);
 
+void dev_add_handler(struct packet_handler *nh)
+{
+	struct packet_handler *h;
+	struct list_head *slot = &packet_hook;
+
+	spin_lock_bh(&phook_lock);
+	list_for_each_entry(h, &packet_hook, list) {
+		if (h->priority > nh->priority)
+			break;
+		slot = &h->list;
+	}
+	list_add_rcu(&nh->list, slot);
+	spin_unlock_bh(&phook_lock);
+
+}
+EXPORT_SYMBOL_GPL(dev_add_handler);
+
+
+void dev_remove_handler(struct packet_handler *h)
+{
+	spin_lock_bh(&phook_lock);
+	list_del_rcu(&h->list);
+	spin_unlock_bh(&phook_lock);
+	synchronize_net();
+}
+EXPORT_SYMBOL_GPL(dev_remove_handler);
+
 /******************************************************************************
 
 		      Device Boot-time Settings Routines
@@ -2566,66 +2596,6 @@ static inline int deliver_skb(struct sk_
 	return pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
 }
 
-#if defined(CONFIG_BRIDGE) || defined (CONFIG_BRIDGE_MODULE)
-
-#if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
-/* This hook is defined here for ATM LANE */
-int (*br_fdb_test_addr_hook)(struct net_device *dev,
-			     unsigned char *addr) __read_mostly;
-EXPORT_SYMBOL_GPL(br_fdb_test_addr_hook);
-#endif
-
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
-struct sk_buff *(*macvlan_handle_frame_hook)(struct sk_buff *skb) __read_mostly;
-EXPORT_SYMBOL_GPL(macvlan_handle_frame_hook);
-
-static inline struct sk_buff *handle_macvlan(struct sk_buff *skb,
-					     struct packet_type **pt_prev,
-					     int *ret,
-					     struct net_device *orig_dev)
-{
-	if (skb->dev->macvlan_port == NULL)
-		return skb;
-
-	if (*pt_prev) {
-		*ret = deliver_skb(skb, *pt_prev, orig_dev);
-		*pt_prev = NULL;
-	}
-	return macvlan_handle_frame_hook(skb);
-}
-#else
-#define handle_macvlan(skb, pt_prev, ret, orig_dev)	(skb)
-#endif
-
 #ifdef CONFIG_NET_CLS_ACT
 /* TODO: Maybe we should just force sch_ingress to be compiled in
  * when CONFIG_NET_CLS_ACT is? otherwise some useless instructions
@@ -2773,6 +2743,7 @@ EXPORT_SYMBOL(__skb_bond_should_drop);
 static int __netif_receive_skb(struct sk_buff *skb)
 {
 	struct packet_type *ptype, *pt_prev;
+	struct packet_handler *phook;
 	struct net_device *orig_dev;
 	struct net_device *master;
 	struct net_device *null_or_orig;
@@ -2835,13 +2806,15 @@ static int __netif_receive_skb(struct sk
 		goto out;
 ncls:
 #endif
+	if (pt_prev)
+		ret = deliver_skb(skb, pt_prev, orig_dev);
 
-	skb = handle_bridge(skb, &pt_prev, &ret, orig_dev);
-	if (!skb)
-		goto out;
-	skb = handle_macvlan(skb, &pt_prev, &ret, orig_dev);
-	if (!skb)
-		goto out;
+	/* Process special hooks used for bridging and macvlan */
+	list_for_each_entry_rcu(phook, &packet_hook, list) {
+		skb = (*phook->func)(orig_dev, skb);
+		if (!skb)
+			goto out;
+	}
 
 	/*
 	 * Make sure frames received on VLAN interfaces stacked on
@@ -2856,6 +2829,7 @@ ncls:
 	}
 
 	type = skb->protocol;
+	pt_prev = NULL;
 	list_for_each_entry_rcu(ptype,
 			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
 		if (ptype->type == type && (ptype->dev == null_or_orig ||
@@ -5855,6 +5829,7 @@ static int __init net_dev_init(void)
 	INIT_LIST_HEAD(&ptype_all);
 	for (i = 0; i < PTYPE_HASH_SIZE; i++)
 		INIT_LIST_HEAD(&ptype_base[i]);
+	INIT_LIST_HEAD(&packet_hook);
 
 	if (register_pernet_subsys(&netdev_net_ops))
 		goto out;

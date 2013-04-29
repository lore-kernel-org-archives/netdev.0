From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next 2/2] bridge: Add a flag to control unicast packet flood.
Date: Mon, 29 Apr 2013 11:58:22 -0400
Message-ID: <1367251102-25193-3-git-send-email-vyasevic@redhat.com>
References: <1367251102-25193-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, mst@redhat.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50478 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757285Ab3D2P61 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Apr 2013 11:58:27 -0400
In-Reply-To: <1367251102-25193-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a flag to control flood of unicast traffic.  By default, flood is
on and the bridge will flood unicast traffic if it doesn't know
the destination.  When the flag is turned off, unicast traffic
without an FDB will not be forwarded to the specified port.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/uapi/linux/if_link.h |    1 +
 net/bridge/br_device.c       |    8 ++++----
 net/bridge/br_forward.c      |   14 +++++++++-----
 net/bridge/br_if.c           |    2 +-
 net/bridge/br_input.c        |    9 ++++++---
 net/bridge/br_netlink.c      |    6 +++++-
 net/bridge/br_private.h      |    6 ++++--
 net/bridge/br_sysfs_if.c     |    2 ++
 8 files changed, 32 insertions(+), 16 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 80fad7f..8d32021 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -222,6 +222,7 @@ enum {
 	IFLA_BRPORT_PROTECT,	/* root port protection    */
 	IFLA_BRPORT_FAST_LEAVE,	/* multicast fast leave    */
 	IFLA_BRPORT_LEARNING,	/* mac learning */
+	IFLA_BRPORT_UNICAST_FLOOD,	/* control flood of unicast traffic */
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 9673128..014d690 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -55,10 +55,10 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	skb_pull(skb, ETH_HLEN);
 
 	if (is_broadcast_ether_addr(dest))
-		br_flood_deliver(br, skb);
+		br_flood_deliver(br, skb, false);
 	else if (is_multicast_ether_addr(dest)) {
 		if (unlikely(netpoll_tx_running(dev))) {
-			br_flood_deliver(br, skb);
+			br_flood_deliver(br, skb, false);
 			goto out;
 		}
 		if (br_multicast_rcv(br, NULL, skb)) {
@@ -70,11 +70,11 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb))
 			br_multicast_deliver(mdst, skb);
 		else
-			br_flood_deliver(br, skb);
+			br_flood_deliver(br, skb, false);
 	} else if ((dst = __br_fdb_get(br, dest, vid)) != NULL)
 		br_deliver(dst->dst, skb);
 	else
-		br_flood_deliver(br, skb);
+		br_flood_deliver(br, skb, true);
 
 out:
 	rcu_read_unlock();
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 092b20e..3ca17eb 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -174,7 +174,8 @@ out:
 static void br_flood(struct net_bridge *br, struct sk_buff *skb,
 		     struct sk_buff *skb0,
 		     void (*__packet_hook)(const struct net_bridge_port *p,
-					   struct sk_buff *skb))
+					   struct sk_buff *skb),
+		     bool unicast)
 {
 	struct net_bridge_port *p;
 	struct net_bridge_port *prev;
@@ -182,6 +183,9 @@ static void br_flood(struct net_bridge *br, struct sk_buff *skb,
 	prev = NULL;
 
 	list_for_each_entry_rcu(p, &br->port_list, list) {
+		/* Do not flood unicast traffic to ports that turn it off */
+		if (unicast && !(p->flags & BR_UNICAST_FLOOD))
+			continue;
 		prev = maybe_deliver(prev, p, skb, __packet_hook);
 		if (IS_ERR(prev))
 			goto out;
@@ -203,16 +207,16 @@ out:
 
 
 /* called with rcu_read_lock */
-void br_flood_deliver(struct net_bridge *br, struct sk_buff *skb)
+void br_flood_deliver(struct net_bridge *br, struct sk_buff *skb, bool unicast)
 {
-	br_flood(br, skb, NULL, __br_deliver);
+	br_flood(br, skb, NULL, __br_deliver, unicast);
 }
 
 /* called under bridge lock */
 void br_flood_forward(struct net_bridge *br, struct sk_buff *skb,
-		      struct sk_buff *skb2)
+		      struct sk_buff *skb2, bool unicast)
 {
-	br_flood(br, skb, skb2, __br_forward);
+	br_flood(br, skb, skb2, __br_forward, unicast);
 }
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 9751103..3b15668 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -220,7 +220,7 @@ static struct net_bridge_port *new_nbp(struct net_bridge *br,
 	p->path_cost = port_cost(dev);
 	p->priority = 0x8000 >> BR_PORT_BITS;
 	p->port_no = index;
-	p->flags = BR_LEARNING;
+	p->flags = BR_LEARNING | BR_UNICAST_FLOOD;
 	br_init_port(p);
 	p->state = BR_STATE_DISABLED;
 	br_stp_port_timer_init(p);
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 828e2bc..6b6a49e 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -65,6 +65,7 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	struct net_bridge_fdb_entry *dst;
 	struct net_bridge_mdb_entry *mdst;
 	struct sk_buff *skb2;
+	bool unicast = true;
 	u16 vid = 0;
 
 	if (!p || p->state == BR_STATE_DISABLED)
@@ -94,9 +95,10 @@ int br_handle_frame_finish(struct sk_buff *skb)
 
 	dst = NULL;
 
-	if (is_broadcast_ether_addr(dest))
+	if (is_broadcast_ether_addr(dest)) {
 		skb2 = skb;
-	else if (is_multicast_ether_addr(dest)) {
+		unicast = false;
+	} else if (is_multicast_ether_addr(dest)) {
 		mdst = br_mdb_get(br, skb, vid);
 		if (mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb)) {
 			if ((mdst && mdst->mglist) ||
@@ -109,6 +111,7 @@ int br_handle_frame_finish(struct sk_buff *skb)
 		} else
 			skb2 = skb;
 
+		unicast = false;
 		br->dev->stats.multicast++;
 	} else if ((dst = __br_fdb_get(br, dest, vid)) &&
 			dst->is_local) {
@@ -122,7 +125,7 @@ int br_handle_frame_finish(struct sk_buff *skb)
 			dst->used = jiffies;
 			br_forward(dst->dst, skb, skb2);
 		} else
-			br_flood_forward(br, skb, skb2);
+			br_flood_forward(br, skb, skb2, unicast);
 	}
 
 	if (skb2)
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index ce902bf..d27599c 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -31,6 +31,7 @@ static inline size_t br_port_info_size(void)
 		+ nla_total_size(1)	/* IFLA_BRPORT_PROTECT */
 		+ nla_total_size(1)	/* IFLA_BRPORT_FAST_LEAVE */
 		+ nla_total_size(1)	/* IFLA_BRPORT_LEARNING */
+		+ nla_total_size(1)	/* IFLA_BRPORT_UNICAST_FLOOD */
 		+ 0;
 }
 
@@ -58,7 +59,8 @@ static int br_port_fill_attrs(struct sk_buff *skb,
 	    nla_put_u8(skb, IFLA_BRPORT_GUARD, !!(p->flags & BR_BPDU_GUARD)) ||
 	    nla_put_u8(skb, IFLA_BRPORT_PROTECT, !!(p->flags & BR_ROOT_BLOCK)) ||
 	    nla_put_u8(skb, IFLA_BRPORT_FAST_LEAVE, !!(p->flags & BR_MULTICAST_FAST_LEAVE)) ||
-	    nla_put_u8(skb, IFLA_BRPORT_LEARNING, !!(p->flags & BR_LEARNING)))
+	    nla_put_u8(skb, IFLA_BRPORT_LEARNING, !!(p->flags & BR_LEARNING)) ||
+	    nla_put_u8(skb, IFLA_BRPORT_UNICAST_FLOOD, !!(p->flags & BR_UNICAST_FLOOD)))
 		return -EMSGSIZE;
 
 	return 0;
@@ -284,6 +286,7 @@ static const struct nla_policy ifla_brport_policy[IFLA_BRPORT_MAX + 1] = {
 	[IFLA_BRPORT_GUARD]	= { .type = NLA_U8 },
 	[IFLA_BRPORT_PROTECT]	= { .type = NLA_U8 },
 	[IFLA_BRPORT_LEARNING]	= { .type = NLA_U8 },
+	[IFLA_BRPORT_UNICAST_FLOOD] = { .type = NLA_U8 },
 };
 
 /* Change the state of the port and notify spanning tree */
@@ -332,6 +335,7 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 	br_set_port_flag(p, tb, IFLA_BRPORT_FAST_LEAVE, BR_MULTICAST_FAST_LEAVE);
 	br_set_port_flag(p, tb, IFLA_BRPORT_PROTECT, BR_ROOT_BLOCK);
 	br_set_port_flag(p, tb, IFLA_BRPORT_LEARNING, BR_LEARNING);
+	br_set_port_flag(p, tb, IFLA_BRPORT_UNICAST_FLOOD, BR_UNICAST_FLOOD);
 
 	if (tb[IFLA_BRPORT_COST]) {
 		err = br_stp_set_path_cost(p, nla_get_u32(tb[IFLA_BRPORT_COST]));
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 67842b9..50b6f55 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -157,6 +157,7 @@ struct net_bridge_port
 #define BR_ROOT_BLOCK		0x00000004
 #define BR_MULTICAST_FAST_LEAVE	0x00000008
 #define BR_LEARNING		0x00000010
+#define BR_UNICAST_FLOOD	0x00000020
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	u32				multicast_startup_queries_sent;
@@ -411,9 +412,10 @@ extern int br_dev_queue_push_xmit(struct sk_buff *skb);
 extern void br_forward(const struct net_bridge_port *to,
 		struct sk_buff *skb, struct sk_buff *skb0);
 extern int br_forward_finish(struct sk_buff *skb);
-extern void br_flood_deliver(struct net_bridge *br, struct sk_buff *skb);
+extern void br_flood_deliver(struct net_bridge *br, struct sk_buff *skb,
+			     bool unicast);
 extern void br_flood_forward(struct net_bridge *br, struct sk_buff *skb,
-			     struct sk_buff *skb2);
+			     struct sk_buff *skb2, bool unicast);
 
 /* br_if.c */
 extern void br_port_carrier_check(struct net_bridge_port *p);
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 707f362..ea6990f 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -159,6 +159,7 @@ BRPORT_ATTR_FLAG(hairpin_mode, BR_HAIRPIN_MODE);
 BRPORT_ATTR_FLAG(bpdu_guard, BR_BPDU_GUARD);
 BRPORT_ATTR_FLAG(root_block, BR_ROOT_BLOCK);
 BRPORT_ATTR_FLAG(learning, BR_LEARNING);
+BRPORT_ATTR_FLAG(unicast_flood, BR_UNICAST_FLOOD);
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 static ssize_t show_multicast_router(struct net_bridge_port *p, char *buf)
@@ -197,6 +198,7 @@ static const struct brport_attribute *brport_attrs[] = {
 	&brport_attr_bpdu_guard,
 	&brport_attr_root_block,
 	&brport_attr_learning,
+	&brport_attr_unicast_flood,
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	&brport_attr_multicast_router,
 	&brport_attr_multicast_fast_leave,
-- 
1.7.7.6

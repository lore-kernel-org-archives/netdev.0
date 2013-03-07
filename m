From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCH net-next 2/3] bridge: Allow an ability to designate an uplink port
Date: Wed,  6 Mar 2013 21:31:24 -0500
Message-ID: <1362623485-18209-3-git-send-email-vyasevic@redhat.com>
References: <1362623485-18209-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3722 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758717Ab3CGCbc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Mar 2013 21:31:32 -0500
In-Reply-To: <1362623485-18209-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow a ports to be designated as uplink.  Multiple ports
may be designated as uplinks and they will be kept in a
list.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/uapi/linux/if_link.h |    1 +
 net/bridge/br_device.c       |    1 +
 net/bridge/br_if.c           |   16 ++++++++++++++++
 net/bridge/br_netlink.c      |    6 ++++++
 net/bridge/br_private.h      |    4 ++++
 net/bridge/br_sysfs_if.c     |   13 +++++++++++++
 6 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index c4edfe1..b9444e9 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -220,6 +220,7 @@ enum {
 	IFLA_BRPORT_GUARD,	/* bpdu guard              */
 	IFLA_BRPORT_PROTECT,	/* root port protection    */
 	IFLA_BRPORT_FAST_LEAVE,	/* multicast fast leave    */
+	IFLA_BRPORT_UPLINK,	/* uplink port */
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 160bc74..c525e36 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -396,6 +396,7 @@ void br_dev_setup(struct net_device *dev)
 	br->dev = dev;
 	spin_lock_init(&br->lock);
 	INIT_LIST_HEAD(&br->port_list);
+	INIT_LIST_HEAD(&br->uplink_list);
 	spin_lock_init(&br->hash_lock);
 
 	br->bridge_id.prio[0] = 0x80;
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 02b4440..4b0636b 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -131,6 +131,7 @@ static void del_nbp(struct net_bridge_port *p)
 	struct net_device *dev = p->dev;
 
 	sysfs_remove_link(br->ifobj, p->dev->name);
+	list_del_rcu(&p->uplink_list);
 
 	if (br->promisc_enabled)
 		dev_set_promiscuity(dev, -1);
@@ -461,6 +462,21 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
 	return 0;
 }
 
+void br_set_uplink(struct net_bridge_port *p, unsigned long v)
+{
+	if (v) {
+		if (!list_empty(&p->uplink_list))
+			return;
+
+		list_add_rcu(&p->uplink_list, &p->br->uplink_list);
+	} else {
+		if (list_empty(&p->uplink_list))
+			return;
+
+		list_del_rcu(&p->uplink_list);
+	}
+}
+
 void __net_exit br_net_exit(struct net *net)
 {
 	struct net_device *dev;
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 27aa3ee..8965b51 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -283,6 +283,7 @@ static const struct nla_policy ifla_brport_policy[IFLA_BRPORT_MAX + 1] = {
 	[IFLA_BRPORT_MODE]	= { .type = NLA_U8 },
 	[IFLA_BRPORT_GUARD]	= { .type = NLA_U8 },
 	[IFLA_BRPORT_PROTECT]	= { .type = NLA_U8 },
+	[IFLA_BRPORT_UPLINK]	= { .type = NLA_U8 },
 };
 
 /* Change the state of the port and notify spanning tree */
@@ -347,6 +348,11 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 		if (err)
 			return err;
 	}
+
+	if (tb[IFLA_BRPORT_UPLINK]) {
+		br_set_uplink(p, nla_get_u8(tb[IFLA_BRPORT_UPLINK]));
+	}
+
 	return 0;
 }
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 4a0fa29..9502b1e 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -130,6 +130,7 @@ struct net_bridge_port
 	struct net_bridge		*br;
 	struct net_device		*dev;
 	struct list_head		list;
+	struct list_head		uplink_list;
 
 	/* STP */
 	u8				priority;
@@ -277,6 +278,7 @@ struct net_bridge
 	struct timer_list		topology_change_timer;
 	struct timer_list		gc_timer;
 	struct kobject			*ifobj;
+	struct list_head		uplink_list;
 	u8				promisc_enabled;
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
 	u8				vlan_enabled;
@@ -428,6 +430,8 @@ extern int br_del_if(struct net_bridge *br,
 extern int br_min_mtu(const struct net_bridge *br);
 extern netdev_features_t br_features_recompute(struct net_bridge *br,
 	netdev_features_t features);
+extern void br_set_uplink(struct net_bridge_port *port, unsigned long v);
+
 
 /* br_input.c */
 extern int br_handle_frame_finish(struct sk_buff *skb);
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index a1ef1b6..5e1d861 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -159,6 +159,18 @@ BRPORT_ATTR_FLAG(hairpin_mode, BR_HAIRPIN_MODE);
 BRPORT_ATTR_FLAG(bpdu_guard, BR_BPDU_GUARD);
 BRPORT_ATTR_FLAG(root_block, BR_ROOT_BLOCK);
 
+static ssize_t show_uplink(struct net_bridge_port *p, char *buf)
+{
+	return sprintf(buf, "%d\n", list_empty(&p->uplink_list) ? 0 : 1);
+}
+
+static int store_uplink(struct net_bridge_port *p, unsigned long v)
+{
+	br_set_uplink(p, v);
+	return 0;
+}
+static BRPORT_ATTR(uplink, S_IRUGO | S_IWUSR, show_uplink, store_uplink);
+
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 static ssize_t show_multicast_router(struct net_bridge_port *p, char *buf)
 {
@@ -195,6 +207,7 @@ static const struct brport_attribute *brport_attrs[] = {
 	&brport_attr_hairpin_mode,
 	&brport_attr_bpdu_guard,
 	&brport_attr_root_block,
+	&brport_attr_uplink,
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	&brport_attr_multicast_router,
 	&brport_attr_multicast_fast_leave,
-- 
1.7.7.6

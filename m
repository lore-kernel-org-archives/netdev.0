From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCH v2 net-next 2/7] bridge: Keep track of ports capable of automatic discovery.
Date: Tue, 29 Apr 2014 17:20:23 -0400
Message-ID: <1398806428-640-3-git-send-email-vyasevic@redhat.com>
References: <1398806428-640-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, shemminger@vyatta.com,
	jhs@mojatatu.com, john.r.fastabend@intel.com, mst@redhat.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48778 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755851AbaD2VUu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2014 17:20:50 -0400
In-Reply-To: <1398806428-640-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By default, ports on the bridge are capable of automatic
discovery of nodes located behind the port.  This is accomplished
via flooding of unknown traffic (BR_FLOOD) and learning the
mac addresses from these packets (BR_LEARNING).
If the above functionality is diabled by turning off these
flags, the port requires static configuration in the form
of static FDB entries to function properly.

This patch adds functionality to keep track of all ports
capable of automatic discovery.  This will later be used
to control promiscuity settings.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_if.c       | 27 +++++++++++++++++++++++++++
 net/bridge/br_netlink.c  |  3 +++
 net/bridge/br_private.h  |  6 ++++++
 net/bridge/br_sysfs_if.c |  6 +++++-
 4 files changed, 41 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 5262b86..7e60c4c 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -85,6 +85,18 @@ void br_port_carrier_check(struct net_bridge_port *p)
 	spin_unlock_bh(&br->lock);
 }
 
+static void nbp_update_port_count(struct net_bridge *br)
+{
+	struct net_bridge_port *p;
+	u32 cnt = 0;
+
+	list_for_each_entry(p, &br->port_list, list) {
+		if (br_is_auto_port(p))
+			cnt++;
+	}
+	br->auto_cnt = cnt;
+}
+
 static void release_nbp(struct kobject *kobj)
 {
 	struct net_bridge_port *p
@@ -146,6 +158,8 @@ static void del_nbp(struct net_bridge_port *p)
 
 	list_del_rcu(&p->list);
 
+	nbp_update_port_count(br);
+
 	dev->priv_flags &= ~IFF_BRIDGE_PORT;
 
 	netdev_rx_handler_unregister(dev);
@@ -384,6 +398,8 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 
 	list_add_rcu(&p->list, &br->port_list);
 
+	nbp_update_port_count(br);
+
 	netdev_update_features(br->dev);
 
 	if (br->dev->needed_headroom < dev->needed_headroom)
@@ -455,3 +471,14 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
 
 	return 0;
 }
+
+void br_port_flags_change(struct net_bridge_port *p, unsigned long old_flags)
+{
+	struct net_bridge *br = p->br;
+	unsigned long mask = old_flags ^ p->flags;
+
+	if (!(mask & BR_AUTO_MASK))
+		return;
+
+	nbp_update_port_count(br);
+}
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index e74b6d53..01382b9 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -328,6 +328,7 @@ static void br_set_port_flag(struct net_bridge_port *p, struct nlattr *tb[],
 static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 {
 	int err;
+	unsigned long old_flags = p->flags;
 
 	br_set_port_flag(p, tb, IFLA_BRPORT_MODE, BR_HAIRPIN_MODE);
 	br_set_port_flag(p, tb, IFLA_BRPORT_GUARD, BR_BPDU_GUARD);
@@ -353,6 +354,8 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 		if (err)
 			return err;
 	}
+
+	br_port_flags_change(p, old_flags ^ p->flags);
 	return 0;
 }
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 06811d7..db714a1 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -174,6 +174,7 @@ struct net_bridge_port
 #define BR_ADMIN_COST		0x00000010
 #define BR_LEARNING		0x00000020
 #define BR_FLOOD		0x00000040
+#define BR_AUTO_MASK (BR_FLOOD | BR_LEARNING)
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	struct bridge_mcast_query	ip4_query;
@@ -198,6 +199,8 @@ struct net_bridge_port
 #endif
 };
 
+#define br_is_auto_port(p) (((p)->flags & BR_AUTO_MASK) == BR_AUTO_MASK)
+
 #define br_port_exists(dev) (dev->priv_flags & IFF_BRIDGE_PORT)
 
 static inline struct net_bridge_port *br_port_get_rcu(const struct net_device *dev)
@@ -290,6 +293,7 @@ struct net_bridge
 	struct timer_list		topology_change_timer;
 	struct timer_list		gc_timer;
 	struct kobject			*ifobj;
+	u32				auto_cnt;
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
 	u8				vlan_enabled;
 	struct net_port_vlans __rcu	*vlan_info;
@@ -415,6 +419,8 @@ int br_del_if(struct net_bridge *br, struct net_device *dev);
 int br_min_mtu(const struct net_bridge *br);
 netdev_features_t br_features_recompute(struct net_bridge *br,
 					netdev_features_t features);
+void br_port_flags_change(struct net_bridge_port *port,
+			  unsigned long old_flags);
 
 /* br_input.c */
 int br_handle_frame_finish(struct sk_buff *skb);
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 112a25e..58c26e3 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -49,7 +49,10 @@ static BRPORT_ATTR(_name, S_IRUGO | S_IWUSR,			\
 static int store_flag(struct net_bridge_port *p, unsigned long v,
 		     unsigned long mask)
 {
-	unsigned long flags = p->flags;
+	unsigned long flags;
+	unsigned long old_flags;
+
+	old_flags = flags = p->flags;
 
 	if (v)
 		flags |= mask;
@@ -58,6 +61,7 @@ static int store_flag(struct net_bridge_port *p, unsigned long v,
 
 	if (flags != p->flags) {
 		p->flags = flags;
+		br_port_flags_change(p, old_flags ^ flags);
 		br_ifinfo_notify(RTM_NEWLINK, p);
 	}
 	return 0;
-- 
1.9.0

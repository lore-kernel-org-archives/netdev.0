From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next 1/2] bridge: Add flag to control mac learning.
Date: Mon, 29 Apr 2013 11:58:21 -0400
Message-ID: <1367251102-25193-2-git-send-email-vyasevic@redhat.com>
References: <1367251102-25193-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, mst@redhat.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26242 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757230Ab3D2P60 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Apr 2013 11:58:26 -0400
In-Reply-To: <1367251102-25193-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow user to control whether mac learning is enabled on the port.
By default, mac learning is enabled.  Disabling mac learning will
cause new dynamic FDB entries to not be created for a particular port.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/uapi/linux/if_link.h |    1 +
 net/bridge/br_fdb.c          |    4 ++++
 net/bridge/br_if.c           |    2 +-
 net/bridge/br_netlink.c      |    6 +++++-
 net/bridge/br_private.h      |    1 +
 net/bridge/br_sysfs_if.c     |    2 ++
 6 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index e316354..80fad7f 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -221,6 +221,7 @@ enum {
 	IFLA_BRPORT_GUARD,	/* bpdu guard              */
 	IFLA_BRPORT_PROTECT,	/* root port protection    */
 	IFLA_BRPORT_FAST_LEAVE,	/* multicast fast leave    */
+	IFLA_BRPORT_LEARNING,	/* mac learning */
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index c581f12..9c4fe65 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -477,10 +477,14 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 	} else {
 		spin_lock(&br->hash_lock);
 		if (likely(!fdb_find(head, addr, vid))) {
+			if (!(source->flags & BR_LEARNING))
+				goto unlock;
+
 			fdb = fdb_create(head, source, addr, vid);
 			if (fdb)
 				fdb_notify(br, fdb, RTM_NEWNEIGH);
 		}
+unlock:
 		/* else  we lose race and someone else inserts
 		 * it first, don't bother updating
 		 */
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index f17fcb3..9751103 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -220,7 +220,7 @@ static struct net_bridge_port *new_nbp(struct net_bridge *br,
 	p->path_cost = port_cost(dev);
 	p->priority = 0x8000 >> BR_PORT_BITS;
 	p->port_no = index;
-	p->flags = 0;
+	p->flags = BR_LEARNING;
 	br_init_port(p);
 	p->state = BR_STATE_DISABLED;
 	br_stp_port_timer_init(p);
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 8e3abf5..ce902bf 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -30,6 +30,7 @@ static inline size_t br_port_info_size(void)
 		+ nla_total_size(1)	/* IFLA_BRPORT_GUARD */
 		+ nla_total_size(1)	/* IFLA_BRPORT_PROTECT */
 		+ nla_total_size(1)	/* IFLA_BRPORT_FAST_LEAVE */
+		+ nla_total_size(1)	/* IFLA_BRPORT_LEARNING */
 		+ 0;
 }
 
@@ -56,7 +57,8 @@ static int br_port_fill_attrs(struct sk_buff *skb,
 	    nla_put_u8(skb, IFLA_BRPORT_MODE, mode) ||
 	    nla_put_u8(skb, IFLA_BRPORT_GUARD, !!(p->flags & BR_BPDU_GUARD)) ||
 	    nla_put_u8(skb, IFLA_BRPORT_PROTECT, !!(p->flags & BR_ROOT_BLOCK)) ||
-	    nla_put_u8(skb, IFLA_BRPORT_FAST_LEAVE, !!(p->flags & BR_MULTICAST_FAST_LEAVE)))
+	    nla_put_u8(skb, IFLA_BRPORT_FAST_LEAVE, !!(p->flags & BR_MULTICAST_FAST_LEAVE)) ||
+	    nla_put_u8(skb, IFLA_BRPORT_LEARNING, !!(p->flags & BR_LEARNING)))
 		return -EMSGSIZE;
 
 	return 0;
@@ -281,6 +283,7 @@ static const struct nla_policy ifla_brport_policy[IFLA_BRPORT_MAX + 1] = {
 	[IFLA_BRPORT_MODE]	= { .type = NLA_U8 },
 	[IFLA_BRPORT_GUARD]	= { .type = NLA_U8 },
 	[IFLA_BRPORT_PROTECT]	= { .type = NLA_U8 },
+	[IFLA_BRPORT_LEARNING]	= { .type = NLA_U8 },
 };
 
 /* Change the state of the port and notify spanning tree */
@@ -328,6 +331,7 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 	br_set_port_flag(p, tb, IFLA_BRPORT_GUARD, BR_BPDU_GUARD);
 	br_set_port_flag(p, tb, IFLA_BRPORT_FAST_LEAVE, BR_MULTICAST_FAST_LEAVE);
 	br_set_port_flag(p, tb, IFLA_BRPORT_PROTECT, BR_ROOT_BLOCK);
+	br_set_port_flag(p, tb, IFLA_BRPORT_LEARNING, BR_LEARNING);
 
 	if (tb[IFLA_BRPORT_COST]) {
 		err = br_stp_set_path_cost(p, nla_get_u32(tb[IFLA_BRPORT_COST]));
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 3cbf5be..67842b9 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -156,6 +156,7 @@ struct net_bridge_port
 #define BR_BPDU_GUARD           0x00000002
 #define BR_ROOT_BLOCK		0x00000004
 #define BR_MULTICAST_FAST_LEAVE	0x00000008
+#define BR_LEARNING		0x00000010
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	u32				multicast_startup_queries_sent;
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index a1ef1b6..707f362 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -158,6 +158,7 @@ static BRPORT_ATTR(flush, S_IWUSR, NULL, store_flush);
 BRPORT_ATTR_FLAG(hairpin_mode, BR_HAIRPIN_MODE);
 BRPORT_ATTR_FLAG(bpdu_guard, BR_BPDU_GUARD);
 BRPORT_ATTR_FLAG(root_block, BR_ROOT_BLOCK);
+BRPORT_ATTR_FLAG(learning, BR_LEARNING);
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 static ssize_t show_multicast_router(struct net_bridge_port *p, char *buf)
@@ -195,6 +196,7 @@ static const struct brport_attribute *brport_attrs[] = {
 	&brport_attr_hairpin_mode,
 	&brport_attr_bpdu_guard,
 	&brport_attr_root_block,
+	&brport_attr_learning,
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	&brport_attr_multicast_router,
 	&brport_attr_multicast_fast_leave,
-- 
1.7.7.6

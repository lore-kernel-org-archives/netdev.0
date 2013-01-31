From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v7 net-next 05/12] bridge: Add the ability to configure pvid
Date: Wed, 30 Jan 2013 22:12:52 -0500
Message-ID: <1359601979-14942-6-git-send-email-vyasevic@redhat.com>
References: <1359601979-14942-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org, shmulik.ladkani@gmail.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17888 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756319Ab3AaDNK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2013 22:13:10 -0500
In-Reply-To: <1359601979-14942-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A user may designate a certain vlan as PVID.  This means that
any ingress frame that does not contain a vlan tag is assigned to
this vlan and any forwarding decisions are made with this vlan in mind.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/uapi/linux/if_bridge.h |    1 +
 net/bridge/br_netlink.c        |    7 +++--
 net/bridge/br_private.h        |    9 ++++---
 net/bridge/br_vlan.c           |   49 +++++++++++++++++++++++++++++++--------
 4 files changed, 49 insertions(+), 17 deletions(-)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index 3ca9817..c6c30e2 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -120,6 +120,7 @@ enum {
 #define IFLA_BRIDGE_MAX (__IFLA_BRIDGE_MAX - 1)
 
 #define BRIDGE_VLAN_INFO_MASTER	(1<<0)	/* Operate on Bridge device as well */
+#define BRIDGE_VLAN_INFO_PVID	(1<<1)	/* VLAN is PVID, ingress untagged */
 
 struct bridge_vlan_info {
 	u16 flags;
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 534a9f4..0089a3f 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -198,14 +198,15 @@ static int br_afspec(struct net_bridge *br,
 		switch (cmd) {
 		case RTM_SETLINK:
 			if (p) {
-				err = nbp_vlan_add(p, vinfo->vid);
+				err = nbp_vlan_add(p, vinfo->vid, vinfo->flags);
 				if (err)
 					break;
 
 				if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
-					err = br_vlan_add(p->br, vinfo->vid);
+					err = br_vlan_add(p->br, vinfo->vid,
+							  vinfo->flags);
 			} else
-				err = br_vlan_add(br, vinfo->vid);
+				err = br_vlan_add(br, vinfo->vid, vinfo->flags);
 
 			if (err)
 				break;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 36821f0..108aeeb 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -68,6 +68,7 @@ struct br_ip
 
 struct net_port_vlans {
 	u16				port_idx;
+	u16				pvid;
 	void				*parent;
 	struct rcu_head			rcu;
 	unsigned long			vlan_bitmap[BR_VLAN_BITMAP_LEN];
@@ -556,11 +557,11 @@ extern bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
 extern bool br_allowed_egress(struct net_bridge *br,
 			      const struct net_port_vlans *v,
 			      const struct sk_buff *skb);
-extern int br_vlan_add(struct net_bridge *br, u16 vid);
+extern int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags);
 extern int br_vlan_delete(struct net_bridge *br, u16 vid);
 extern void br_vlan_flush(struct net_bridge *br);
 extern int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val);
-extern int nbp_vlan_add(struct net_bridge_port *port, u16 vid);
+extern int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags);
 extern int nbp_vlan_delete(struct net_bridge_port *port, u16 vid);
 extern void nbp_vlan_flush(struct net_bridge_port *port);
 
@@ -602,7 +603,7 @@ static inline bool br_allowed_egress(struct net_bridge *br,
 	return true;
 }
 
-static inline int br_vlan_add(struct net_bridge *br, u16 vid)
+static inline int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
 {
 	return -EOPNOTSUPP;
 }
@@ -616,7 +617,7 @@ static inline void br_vlan_flush(struct net_bridge *br)
 {
 }
 
-static inline int nbp_vlan_add(struct net_bridge_port *port, u16 vid)
+static inline int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags)
 {
 	return -EOPNOTSUPP;
 }
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 912bc75..f2ae529 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -27,12 +27,33 @@ static inline struct net_bridge *vlans_to_bridge(struct net_port_vlans *vlans)
 	return br;
 }
 
-static int __vlan_add(struct net_port_vlans *v, u16 vid)
+static void __vlan_add_pvid(struct net_port_vlans *v, u16 vid)
+{
+	if (v->pvid == vid)
+		return;
+
+	smp_wmb();
+	v->pvid = vid;
+}
+
+static void __vlan_delete_pvid(struct net_port_vlans *v, u16 vid)
+{
+	if (v->pvid != vid)
+		return;
+
+	smp_wmb();
+	v->pvid = BR_INVALID_VID;
+}
+
+static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 {
 	int err;
 
-	if (test_bit(vid, v->vlan_bitmap))
-		return -EEXIST;
+	if (test_bit(vid, v->vlan_bitmap)) {
+		if (flags & BRIDGE_VLAN_INFO_PVID)
+			__vlan_add_pvid(v, vid);
+		return 0;
+	}
 
 	if (v->port_idx && vid) {
 		struct net_device *dev = vlans_to_port(v)->dev;
@@ -50,6 +71,9 @@ static int __vlan_add(struct net_port_vlans *v, u16 vid)
 	}
 
 	set_bit(vid, v->vlan_bitmap);
+	if (flags & BRIDGE_VLAN_INFO_PVID)
+		__vlan_add_pvid(v, vid);
+
 	return 0;
 }
 
@@ -61,6 +85,8 @@ static int __vlan_del(struct net_port_vlans *v, u16 vid)
 	if (!test_bit(vid, v->vlan_bitmap))
 		return -EINVAL;
 
+	__vlan_delete_pvid(v, vid);
+
 	/* Check to see if any other vlans are in this table.  If this
 	 * is the last vlan, delete the whole structure.  If this is not the
 	 * last vlan, just clear the bit.
@@ -91,6 +117,8 @@ static int __vlan_del(struct net_port_vlans *v, u16 vid)
 
 static void __vlan_flush(struct net_port_vlans *v)
 {
+	smp_wmb();
+	v->pvid = BR_INVALID_VID;
 	bitmap_zero(v->vlan_bitmap, BR_VLAN_BITMAP_LEN);
 	if (v->port_idx)
 		rcu_assign_pointer(vlans_to_port(v)->vlan_info, NULL);
@@ -145,7 +173,7 @@ bool br_allowed_egress(struct net_bridge *br,
 }
 
 /* Must be protected by RTNL */
-int br_vlan_add(struct net_bridge *br, u16 vid)
+int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
 {
 	struct net_port_vlans *pv = NULL;
 	int err;
@@ -154,7 +182,7 @@ int br_vlan_add(struct net_bridge *br, u16 vid)
 
 	pv = rtnl_dereference(br->vlan_info);
 	if (pv)
-		return __vlan_add(pv, vid);
+		return __vlan_add(pv, vid, flags);
 
 	/* Create port vlan infomration
 	 */
@@ -163,7 +191,8 @@ int br_vlan_add(struct net_bridge *br, u16 vid)
 		return -ENOMEM;
 
 	pv->parent = br;
-	err = __vlan_add(pv, vid);
+	pv->pvid = BR_INVALID_VID;
+	err = __vlan_add(pv, vid, flags);
 	if (err)
 		goto out;
 
@@ -194,7 +223,6 @@ void br_vlan_flush(struct net_bridge *br)
 	struct net_port_vlans *pv;
 
 	ASSERT_RTNL();
-
 	pv = rtnl_dereference(br->vlan_info);
 	if (!pv)
 		return;
@@ -218,7 +246,7 @@ unlock:
 }
 
 /* Must be protected by RTNL */
-int nbp_vlan_add(struct net_bridge_port *port, u16 vid)
+int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags)
 {
 	struct net_port_vlans *pv = NULL;
 	int err;
@@ -227,7 +255,7 @@ int nbp_vlan_add(struct net_bridge_port *port, u16 vid)
 
 	pv = rtnl_dereference(port->vlan_info);
 	if (pv)
-		return __vlan_add(pv, vid);
+		return __vlan_add(pv, vid, flags);
 
 	/* Create port vlan infomration
 	 */
@@ -239,7 +267,8 @@ int nbp_vlan_add(struct net_bridge_port *port, u16 vid)
 
 	pv->port_idx = port->port_no;
 	pv->parent = port;
-	err = __vlan_add(pv, vid);
+	pv->pvid = BR_INVALID_VID;
+	err = __vlan_add(pv, vid, flags);
 	if (err)
 		goto clean_up;
 
-- 
1.7.7.6

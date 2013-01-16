From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next V6 07/14] bridge: Add the ability to configure pvid
Date: Wed, 16 Jan 2013 13:18:02 -0500
Message-ID: <1358360289-23249-8-git-send-email-vyasevic@redhat.com>
References: <1358360289-23249-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, davem@davemloft.net,
	shemminger@vyatta.com, mst@redhat.com, shmulik.ladkani@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29626 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756672Ab3APSSX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 13:18:23 -0500
In-Reply-To: <1358360289-23249-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A user may designate a certain vlan as PVID.  This means that
any ingress frame that does not contain a vlan tag is assigned to
this vlan and any forwarding decisions are made with this vlan in mind.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/uapi/linux/if_bridge.h |    1 +
 net/bridge/br_netlink.c        |    4 +-
 net/bridge/br_private.h        |    5 ++-
 net/bridge/br_vlan.c           |   70 +++++++++++++++++++++++++++++++++++++++-
 4 files changed, 75 insertions(+), 5 deletions(-)

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
index 75f368c..1dbfcf3 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -200,12 +200,12 @@ static int br_afspec(struct net_bridge *br,
 
 		switch (cmd) {
 		case RTM_SETLINK:
-			err = nbp_vlan_add(v, vinfo->vid);
+			err = nbp_vlan_add(v, vinfo->vid, vinfo->flags);
 			if (err)
 				break;
 			if (p && (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)) {
 				err = nbp_vlan_add(&p->br->vlan_info,
-						   vinfo->vid);
+						   vinfo->vid, vinfo->flags);
 			}
 			break;
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 1e7a202..ecf5f34 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -88,6 +88,7 @@ struct net_port_vlan {
 struct net_port_vlans {
 	u16				port_idx;
 	struct list_head		vlan_list;
+	struct net_bridge_vlan __rcu	*pvlan;
 };
 
 struct net_bridge_fdb_entry
@@ -588,7 +589,7 @@ extern bool br_allowed_egress(const struct net_port_vlans *v,
 			      const struct sk_buff *skb);
 extern struct net_bridge_vlan *br_vlan_find(struct net_bridge *br, u16 vid);
 extern void br_vlan_flush(struct net_bridge *br);
-extern int nbp_vlan_add(struct net_port_vlans *v, u16 vid);
+extern int nbp_vlan_add(struct net_port_vlans *v, u16 vid, u16 flags);
 extern int nbp_vlan_delete(struct net_port_vlans *v, u16 vid);
 extern struct net_port_vlan *nbp_vlan_find(const struct net_port_vlans *v,
 					   u16 vid);
@@ -631,7 +632,7 @@ static inline void br_vlan_flush(struct net_bridge *br)
 {
 }
 
-static inline int nbp_vlan_add(struct net_port_vlans *v, u16 vid)
+static inline int nbp_vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 {
 	return -EINVAL;
 }
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 01ebfbc..f6dc8a7 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -157,6 +157,56 @@ void br_vlan_flush(struct net_bridge *br)
 	}
 }
 
+static int nbp_vlan_add_pvid(struct net_port_vlans *v,
+			     struct net_bridge_vlan *vlan)
+{
+	struct net_bridge_vlan *pvlan = rtnl_dereference(v->pvlan);
+
+	if (pvlan == vlan)
+		return 0;
+	else if (pvlan) {
+		/* PVID is already set.  Drop the ref
+		 * to the old one since we'll be replace it.
+		 */
+		br_vlan_put(pvlan);
+	} else if (v->port_idx) {
+		struct net_device *dev = vlans_to_port(v)->dev;
+
+		/* Add vid 0 to filter if filter is available. */
+		if (!vlan_hw_buggy(dev)) {
+			int err = vlan_vid_add_hw(dev, 0);
+			if (err)
+				return err;
+		}
+	}
+
+	br_vlan_hold(vlan);
+	rcu_assign_pointer(v->pvlan, vlan);
+	return 0;
+}
+
+static void nbp_vlan_delete_pvid(struct net_port_vlans *v,
+				 struct net_bridge_vlan *vlan)
+{
+	struct net_bridge_vlan *pvlan = rtnl_dereference(v->pvlan);
+
+	if (pvlan != vlan)
+		return;
+
+	if (v->port_idx &&
+	    vlan_vid_del_hw(vlans_to_port(v)->dev, 0)) {
+		pr_warn("failed to kill vid 0 for device %s\n",
+			vlans_to_port(v)->dev->name);
+	}
+
+	/* If this VLAN is currently functioning as pvlan, clear it.
+	 * It's safe to drop the refcount, since the vlan is still held
+	 * by the pve->vlan pointer.
+	 */
+	br_vlan_put(vlan);
+	rcu_assign_pointer(v->pvlan, NULL);
+}
+
 struct net_port_vlan *nbp_vlan_find(const struct net_port_vlans *v, u16 vid)
 {
 	struct net_port_vlan *pve;
@@ -173,7 +223,7 @@ struct net_port_vlan *nbp_vlan_find(const struct net_port_vlans *v, u16 vid)
 }
 
 /* Must be protected by RTNL */
-int nbp_vlan_add(struct net_port_vlans *v, u16 vid)
+int nbp_vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 {
 	struct net_port_vlan *pve = NULL;
 	struct net_bridge_vlan *vlan;
@@ -222,12 +272,22 @@ int nbp_vlan_add(struct net_port_vlans *v, u16 vid)
 	set_bit(v->port_idx, vlan->port_bitmap);
 
 	list_add_tail_rcu(&pve->list, &v->vlan_list);
+
+	if (flags & BRIDGE_VLAN_INFO_PVID) {
+		err = nbp_vlan_add_pvid(v, vlan);
+		if (err)
+			goto del_vlan;
+	}
+
 	return 0;
 
 clean_up:
 	kfree(pve);
 	br_vlan_del(vlan);
 	return err;
+del_vlan:
+	nbp_vlan_delete(v, vid);
+	return err;
 }
 
 /* Must be protected by RTNL */
@@ -235,13 +295,21 @@ int nbp_vlan_delete(struct net_port_vlans *v, u16 vid)
 {
 	struct net_port_vlan *pve;
 	struct net_bridge_vlan *vlan;
+	struct net_bridge *br;
 
 	ASSERT_RTNL();
 
+	if (v->port_idx)
+		br = vlans_to_port(v)->br;
+	else
+		br = vlans_to_bridge(v);
+
 	pve = nbp_vlan_find(v, vid);
 	if (!pve)
 		return -ENOENT;
 
+	nbp_vlan_delete_pvid(v, pve->vlan);
+
 	if (v->port_idx) {
 		/* A valid port index means this is a port.
 		 * Remove VLAN from the port device filter if it is supported.
-- 
1.7.7.6

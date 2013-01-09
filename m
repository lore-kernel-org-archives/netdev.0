From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next v5 10/14] bridge: Add the ability to configure pvid
Date: Wed,  9 Jan 2013 12:17:57 -0500
Message-ID: <1357751882-8619-11-git-send-email-vyasevic@redhat.com>
References: <1357751882-8619-1-git-send-email-vyasevic@redhat.com>
Cc: davem@davemloft.net, stephen@redhat.com,
	bridge@lists.linux-foundation.org, shmulik.ladkani@gmail.com,
	mst@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2418 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932282Ab3AIRSU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2013 12:18:20 -0500
In-Reply-To: <1357751882-8619-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A user may designate a certain vlan as PVID.  This means that
any ingress frame that does not contain a vlan tag is assigned to
this vlan and any forwarding decisions are made with this vlan in mind.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/uapi/linux/if_bridge.h |    1 +
 net/bridge/br_if.c             |   72 ++++++++++++++++++++++++++++++++++++++-
 net/bridge/br_netlink.c        |    4 +-
 net/bridge/br_private.h        |    3 +-
 4 files changed, 75 insertions(+), 5 deletions(-)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index 2645d51..875c9e2 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -120,6 +120,7 @@ enum {
 #define IFLA_BRIDGE_MAX (__IFLA_BRIDGE_MAX - 1)
 
 #define BRIDGE_VLAN_INFO_MASTER	(1<<0)	/* Operate on Bridge device as well */
+#define BRIDGE_VLAN_INFO_PVID	(1<<1)	/* VLAN is PVID, ingress untagged */
 
 struct bridge_vlan_info {
 	u16 flags;
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 4878c20..ca8ae30 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -182,6 +182,56 @@ static void br_vlan_flush(struct net_bridge *br)
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
@@ -198,9 +248,9 @@ struct net_port_vlan *nbp_vlan_find(const struct net_port_vlans *v, u16 vid)
 }
 
 /* Must be protected by RTNL */
-int nbp_vlan_add(struct net_port_vlans *v, u16 vid)
+int nbp_vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 {
-	struct net_port_vlan *pve;
+	struct net_port_vlan *pve = NULL;
 	struct net_bridge_vlan *vlan;
 	struct net_bridge *br = vlans_to_bridge(v);
 	struct net_bridge_port *p = vlans_to_port(v);
@@ -247,12 +297,22 @@ int nbp_vlan_add(struct net_port_vlans *v, u16 vid)
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
@@ -260,13 +320,21 @@ int nbp_vlan_delete(struct net_port_vlans *v, u16 vid)
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
index 9a5cdb2..bf00a5e 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -89,6 +89,7 @@ struct net_port_vlan {
 struct net_port_vlans {
 	u16				port_idx;
 	struct list_head		vlan_list;
+	struct net_bridge_vlan __rcu	*pvlan;
 };
 
 struct net_bridge_fdb_entry
@@ -475,7 +476,7 @@ extern int br_min_mtu(const struct net_bridge *br);
 extern netdev_features_t br_features_recompute(struct net_bridge *br,
 	netdev_features_t features);
 extern struct net_bridge_vlan *br_vlan_find(struct net_bridge *br, u16 vid);
-extern int nbp_vlan_add(struct net_port_vlans *v, u16 vid);
+extern int nbp_vlan_add(struct net_port_vlans *v, u16 vid, u16 flags);
 extern int nbp_vlan_delete(struct net_port_vlans *v, u16 vid);
 extern struct net_port_vlan *nbp_vlan_find(const struct net_port_vlans *v,
 					   u16 vid);
-- 
1.7.7.6

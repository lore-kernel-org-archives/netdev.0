From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH 09/11] bridge: Add the ability to configure untagged vlans
Date: Wed, 12 Dec 2012 15:01:15 -0500
Message-ID: <1355342477-4971-10-git-send-email-vyasevic@redhat.com>
References: <1355342477-4971-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, davem@davemloft.net, mst@redhat.com,
	john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8351 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755205Ab2LLUBl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 15:01:41 -0500
In-Reply-To: <1355342477-4971-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A user may designate a certain vlan as untagged.  This means that
any ingress frame is assigned to this vlan and any forwarding decisions
are made with this vlan in mind.  On egress, any frames tagged/labeled
with untagged vlan have the vlan tag removed and are send as regular
ethernet frames.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/uapi/linux/if_bridge.h |    4 +
 net/bridge/br_if.c             |  134 +++++++++++++++++++++++++++++++++++----
 net/bridge/br_netlink.c        |    4 +-
 net/bridge/br_private.h        |    8 ++-
 4 files changed, 132 insertions(+), 18 deletions(-)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index c65ce5f..e82bfcd 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -181,6 +181,10 @@ enum {
 	BR_VLAN_DEL,
 };
 
+#define BRIDGE_FLAGS_VLAN_UNTAGGED	1	/* VLAN is untagged/native */
+#define BRIDGE_FLAGS_VLAN_MASTER	2	/* Add to master device. For now
+						 * only valid with UNTAGGED
+						 */
 struct bridge_vlan_info {
 	u16 op_code;
 	u16 flags;
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 9a3451b..def3ceb 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -146,7 +146,7 @@ static void br_vlan_put(struct net_bridge_vlan *vlan)
 }
 
 /* Must be protected by RTNL */
-static void br_vlan_del(struct net_bridge_vlan *vlan)
+static void br_vlan_del(struct net_bridge *br, struct net_bridge_vlan *vlan)
 {
 	ASSERT_RTNL();
 
@@ -158,14 +158,70 @@ static void br_vlan_del(struct net_bridge_vlan *vlan)
 
 	vlan->vid = BR_INVALID_VID;
 
+	/* If, for whatever reason, bridge still has a ref on this vlan
+	 * through the @untagged pointer, drop that ref and clear untagged.
+	 */
+	if (br->untagged == vlan) {
+		br_vlan_put(vlan);
+		rcu_assign_pointer(br->untagged, NULL);
+	}
+
 	/* Drop the self-ref to trigger descrution. */
 	br_vlan_put(vlan);
 }
 
+static int nbp_vlan_add_untagged(struct net_bridge_port *p,
+			  struct net_bridge_vlan *vlan,
+			  struct bridge_vlan_info *vinfo)
+{
+	struct net_device *dev = p->dev;
+
+	if (!(vinfo->flags & BRIDGE_FLAGS_VLAN_UNTAGGED))
+		return 0;
+
+	if (p->untagged) {
+		/* Port already has untagged vlan set.  Drop the ref
+		 * to the old one since we'll be replace it.
+		 */
+		br_vlan_put(p->untagged);
+	} else {
+		/* Add vid 0 to filter if filter is available. */
+		if ((dev->features & NETIF_F_HW_VLAN_FILTER) &&
+		    dev->netdev_ops->ndo_vlan_rx_add_vid &&
+		    dev->netdev_ops->ndo_vlan_rx_kill_vid) {
+			err = dev->netdev_ops->ndo_vlan_rx_add_vid(dev, 0);
+			if (err)
+				return err;
+		}
+	}
+
+	/* This VLAN is handled as untagged/native. Save an
+	 * additional ref.
+	 */
+	br_vlan_hold(vlan);
+	rcu_assign_pointer(p->untagged, vlan);
+
+	/* See if we need to add this VLAN to the master device also */
+	if (vinfo->flags & BRIDGE_FLAGS_VLAN_MASTER) {
+		struct net_bridge *br = p->br;
+
+		if (br->untagged) {
+			/* Untagged vlan is already set on the master,
+			 * so drop the ref since we'll be replacing it.
+			 */
+			br_vlan_put(br->untagged);
+		}
+		br_vlan_hold(vlan);
+		rcu_assign_pointer(br->untagged, vlan);
+	}
+
+	return 0;
+}
+
 /* Must be protected by RTNL */
-int nbp_vlan_add(struct net_bridge_port *p, u16 vid)
+int nbp_vlan_add(struct net_bridge_port *p, struct bridge_vlan_info *vinfo)
 {
-	struct net_port_vlan *pve;
+	struct net_port_vlan *pve = NULL;
 	struct net_bridge_vlan *vlan;
 	struct net_device *dev = p->dev;
 	int err;
@@ -175,7 +231,7 @@ int nbp_vlan_add(struct net_bridge_port *p, u16 vid)
 	/* Find a vlan in the bridge vlan list.  If it isn't there,
 	 * create it
 	 */
-	vlan = br_vlan_add(p->br, vid);
+	vlan = br_vlan_add(p->br, vinfo->vid);
 	if (!vlan)
 		return -ENOMEM;
 	
@@ -202,22 +258,27 @@ int nbp_vlan_add(struct net_bridge_port *p, u16 vid)
 	if ((dev->features & NETIF_F_HW_VLAN_FILTER) &&
 	    dev->netdev_ops->ndo_vlan_rx_add_vid &&
 	    dev->netdev_ops->ndo_vlan_rx_kill_vid) {
-		err = dev->netdev_ops->ndo_vlan_rx_add_vid(dev, vid);
+		err = dev->netdev_ops->ndo_vlan_rx_add_vid(dev, vinfo->vid);
 		if (err)
 			goto clean_up;
 	}
 
-	pve->vid = vid;
+	pve->vid = vinfo->vid;
 	pve->vlan = vlan;
 	br_vlan_hold(vlan);
 	set_bit(p->port_no, vlan->port_bitmap);
 
 	list_add_tail_rcu(&pve->list, &p->vlan_list);
+
+	err = nbp_vlan_add_untagged(p, vlan, vinfo);
+	if (err)
+		goto cleanup;
+
 	return 0;
 
 clean_up:
 	kfree(pve);
-	br_vlan_del(vlan);
+	br_vlan_del(p->br, vlan);
 	return err;
 }
 
@@ -236,8 +297,45 @@ struct net_port_vlan *nbp_vlan_find(const struct net_bridge_port *p, u16 vid)
 	return NULL;
 }
 
+static void nbp_vlan_delete_untagged(struct net_bridge_port *p
+			     struct net_bridge_vlan *vlan,
+			     struct bridge_vlan_info *vinfo)
+{
+	if (p->untagged != vlan)
+		return;
+
+	/* If this VLAN is currently functioning as untagged, clear it.
+	 * It's safe to drop the refcount, since the vlan is still held
+	 * by the pve->vlan pointer.
+	 */
+	br_vlan_put(pve->vlan);
+	rcu_assign_pointer(p->untagged, NULL);
+
+	/* Remove VLAN from the device filter if it is supported. */
+	if ((dev->features & NETIF_F_HW_VLAN_FILTER) &&
+    	    dev->netdev_ops->ndo_vlan_rx_kill_vid) {
+		int err;
+
+		err = dev->netdev_ops->ndo_vlan_rx_kill_vid(dev, 0);
+		if (err)
+			pr_warn("failed to kill vid %d for device %s\n",
+					vinfo->vid, dev->name);
+		}
+	}
+
+	if (vinfo->flags &
+	    (BRIDGE_FLAGS_VLAN_UNTAGGED | BRIDGE_FLAGS_VLAN_MASTER)) {
+		struct net_bridge *br = p->br;
+
+		if (br->untagged == vlan) {
+			br_vlan_put(vlan);
+			rcu_assign_pointer(br->untagged, NULL);
+		}
+	}
+}
+
 /* Must be protected by RTNL */
-int nbp_vlan_delete(struct net_bridge_port *p, u16 vid)
+int nbp_vlan_delete(struct net_bridge_port *p, struct bridge_vlan_info *vinfo)
 {
 	struct net_device *dev = p->dev;
 	struct net_port_vlan *pve;
@@ -245,20 +343,24 @@ int nbp_vlan_delete(struct net_bridge_port *p, u16 vid)
 
 	ASSERT_RTNL();
 
-	pve = nbp_vlan_find(p, vid);
+	pve = nbp_vlan_find(p, vinfo->vid);
 	if (!pve)
 		return -ENOENT;
 
+	nbp_vlan_delete_untagged(p, pve->vlan, vinfo);
+
 	/* Remove VLAN from the device filter if it is supported. */
 	if ((dev->features & NETIF_F_HW_VLAN_FILTER) &&
 	    dev->netdev_ops->ndo_vlan_rx_kill_vid) {
 		int err;
 
-		err = dev->netdev_ops->ndo_vlan_rx_kill_vid(dev, vid);
+		err = dev->netdev_ops->ndo_vlan_rx_kill_vid(dev,
+							    vinfo->vid);
 		if (err)
 			pr_warn("failed to kill vid %d for device %s\n",
-				vid, dev->name);
+				vinfo->vid, dev->name);
 	}
+
 	pve->vid = BR_INVALID_VID;
 
 	vlan = pve->vlan;
@@ -269,7 +371,7 @@ int nbp_vlan_delete(struct net_bridge_port *p, u16 vid)
 	list_del_rcu(&pve->list);
 	kfree_rcu(pve, rcu);
 
-	br_vlan_del(vlan);
+	br_vlan_del(p->br, vlan);
 
 	return 0;
 }
@@ -278,11 +380,15 @@ static void nbp_vlan_flush(struct net_bridge_port *p)
 {
 	struct net_port_vlan *pve;
 	struct net_port_vlan *tmp;
+	struct bridge_vlan_info vinfo;
 
 	ASSERT_RTNL();
 
-	list_for_each_entry_safe(pve, tmp, &p->vlan_list, list)
-		nbp_vlan_delete(p, pve->vid);
+	memset(&vinfo, 0, sizeof(vinfo));
+	list_for_each_entry_safe(pve, tmp, &p->vlan_list, list) {
+		vinfo.vid = pve->vid;
+		nbp_vlan_delete(p, &vinfo);
+	}
 }
 	
 static void release_nbp(struct kobject *kobj)
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index c7301a9..4ab0096 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -192,11 +192,11 @@ static int br_afspec(struct net_bridge_port *p, struct nlattr *af_spec)
 
 		switch(vinfo->op_code) {
 		case BR_VLAN_ADD:
-			nbp_vlan_add(p, vinfo->vid);
+			nbp_vlan_add(p, vinfo);
 			break;
 
 		case BR_VLAN_DEL:
-			nbp_vlan_delete(p, vinfo->vid);
+			nbp_vlan_delete(p, vinfo);
 			break;
 		}
 	}
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 16616b9..f82d5f6 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -179,6 +179,7 @@ struct net_bridge_port
 	struct netpoll			*np;
 #endif
 	struct list_head		vlan_list;
+	struct net_bridge_vlan __rcu	*untagged;
 };
 
 #define br_port_exists(dev) (dev->priv_flags & IFF_BRIDGE_PORT)
@@ -298,6 +299,7 @@ struct net_bridge
 	struct timer_list		gc_timer;
 	struct kobject			*ifobj;
 	struct hlist_head		vlan_hlist[BR_VID_HASH_SIZE];
+	struct net_bridge_vlan __rcu	*untagged;
 };
 
 struct br_input_skb_cb {
@@ -443,8 +445,10 @@ extern int br_min_mtu(const struct net_bridge *br);
 extern netdev_features_t br_features_recompute(struct net_bridge *br,
 	netdev_features_t features);
 extern struct net_bridge_vlan* br_vlan_find(struct net_bridge *br, u16 vid);
-extern int nbp_vlan_add(struct net_bridge_port *p, u16 vid);
-extern int nbp_vlan_delete(struct net_bridge_port *p, u16 vid);
+extern int nbp_vlan_add(struct net_bridge_port *p,
+			struct bridge_vlan_info *vinfo);
+extern int nbp_vlan_delete(struct net_bridge_port *p,
+			   struct bridge_vlan_info *vinfo);
 extern struct net_port_vlan* nbp_vlan_find(const struct net_bridge_port *p,
 					   u16 vid);
 
-- 
1.7.7.6

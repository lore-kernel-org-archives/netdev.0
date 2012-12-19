From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next V4 10/13] bridge: Add the ability to configure untagged vlans
Date: Wed, 19 Dec 2012 12:48:21 -0500
Message-ID: <1355939304-21804-11-git-send-email-vyasevic@redhat.com>
References: <1355939304-21804-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, davem@davemloft.net, or.gerlitz@gmail.com,
	jhs@mojatatu.com, mst@redhat.com, erdnetdev@gmail.com,
	jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39732 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751805Ab2LSSRd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2012 13:17:33 -0500
In-Reply-To: <1355939304-21804-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A user may designate a certain vlan as untagged.  This means that
any ingress frame is assigned to this vlan and any forwarding decisions
are made with this vlan in mind.  On egress, any frames tagged/labeled
with untagged vlan have the vlan tag removed and are send as regular
ethernet frames.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/uapi/linux/if_bridge.h |    3 +
 net/bridge/br_if.c             |  139 ++++++++++++++++++++++++++++++++++++---
 net/bridge/br_netlink.c        |    6 +-
 net/bridge/br_private.h        |    2 +
 4 files changed, 137 insertions(+), 13 deletions(-)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index d0b4f5c..988d858 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -127,6 +127,9 @@ enum {
 	BR_VLAN_DEL,
 };
 
+#define BRIDGE_VLAN_INFO_MASTER		1
+#define BRIDGE_VLAN_INFO_UNTAGGED	2
+
 struct bridge_vlan_info {
 	u16 op_code;
 	u16 flags;
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 33bc740..c9f2c06 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -107,6 +107,36 @@ static void br_vlan_put(struct net_bridge_vlan *vlan)
 		br_vlan_destroy(vlan);
 }
 
+/* Must be protected by RTNL */
+static void br_vlan_add_untagged(struct net_bridge *br,
+				 struct net_bridge_vlan *vlan)
+{
+	struct net_bridge_vlan *untagged = rtnl_dereference(br->untagged);
+
+	if (untagged == vlan)
+		return;
+	else if (untagged) {
+		/* Untagged vlan is already set on the master,
+		 * so drop the ref since we'll be replacing it.
+		 */
+		br_vlan_put(untagged);
+	}
+	br_vlan_hold(vlan);
+	rcu_assign_pointer(br->untagged, vlan);
+}
+
+/* Must be protected by RTNL */
+static void br_vlan_del_untagged(struct net_bridge *br,
+				 struct net_bridge_vlan *vlan)
+{
+	struct net_bridge_vlan *untagged = rtnl_dereference(br->untagged);
+
+	if (untagged == vlan) {
+		br_vlan_put(vlan);
+		rcu_assign_pointer(br->untagged, NULL);
+	}
+}
+
 struct net_bridge_vlan *br_vlan_find(struct net_bridge *br, u16 vid)
 {
 	struct net_bridge_vlan *vlan;
@@ -131,7 +161,7 @@ struct net_bridge_vlan *br_vlan_add(struct net_bridge *br, u16 vid,
 
 	vlan = br_vlan_find(br, vid);
 	if (vlan)
-		return vlan;
+		goto untagged;
 
 	vlan = kzalloc(sizeof(struct net_bridge_vlan), GFP_KERNEL);
 	if (!vlan)
@@ -140,7 +170,7 @@ struct net_bridge_vlan *br_vlan_add(struct net_bridge *br, u16 vid,
 	vlan->vid = vid;
 	atomic_set(&vlan->refcnt, 1);
 
-	if (flags & BRIDGE_FLAGS_SELF) {
+	if (flags & BRIDGE_VLAN_INFO_MASTER) {
 		/* Set bit 0 that is associated with the bridge master
 		 * device.  Port numbers start with 1.
 		 */
@@ -148,15 +178,24 @@ struct net_bridge_vlan *br_vlan_add(struct net_bridge *br, u16 vid,
 	}
 
 	hlist_add_head_rcu(&vlan->hlist, &br->vlan_hlist[br_vlan_hash(vid)]);
+
+untagged:
+	if (flags & BRIDGE_VLAN_INFO_UNTAGGED)
+		br_vlan_add_untagged(br, vlan);
+
 	return vlan;
 }
 
 /* Must be protected by RTNL */
-static void br_vlan_del(struct net_bridge_vlan *vlan, u16 flags)
+static void br_vlan_del(struct net_bridge *br, struct net_bridge_vlan *vlan,
+			u16 flags)
 {
 	ASSERT_RTNL();
 
-	if (flags & BRIDGE_FLAGS_SELF) {
+	if (flags & BRIDGE_VLAN_INFO_UNTAGGED)
+		br_vlan_del_untagged(br, vlan);
+
+	if (flags & BRIDGE_VLAN_INFO_MASTER) {
 		/* Clear bit 0 that is associated with the bridge master
 		 * device.
 		 */
@@ -171,6 +210,14 @@ static void br_vlan_del(struct net_bridge_vlan *vlan, u16 flags)
 
 	vlan->vid = BR_INVALID_VID;
 
+	/* If, for whatever reason, bridge still has a ref on this vlan
+	 * through the @untagged pointer, drop that ref and clear untagged.
+	 */
+	if (rtnl_dereference(br->untagged) == vlan) {
+		br_vlan_put(vlan);
+		rcu_assign_pointer(br->untagged, NULL);
+	}
+
 	/* Drop the self-ref to trigger descrution. */
 	br_vlan_put(vlan);
 }
@@ -186,7 +233,7 @@ int br_vlan_delete(struct net_bridge *br, u16 vid, u16 flags)
 	if (!vlan)
 		return -ENOENT;
 
-	br_vlan_del(vlan, flags);
+	br_vlan_del(br, vlan, flags);
 	return 0;
 }
 
@@ -203,7 +250,9 @@ static void br_vlan_flush(struct net_bridge *br)
 	for (i = 0; i < BR_VID_HASH_SIZE; i++) {
 		hlist_for_each_entry_safe(vlan, node, tmp,
 					  &br->vlan_hlist[i], hlist) {
-			br_vlan_del(vlan, BRIDGE_FLAGS_SELF);
+			br_vlan_del(br, vlan,
+				    (BRIDGE_VLAN_INFO_MASTER |
+				     BRIDGE_VLAN_INFO_UNTAGGED));
 		}
 	}
 }
@@ -223,10 +272,62 @@ struct net_port_vlan *nbp_vlan_find(const struct net_bridge_port *p, u16 vid)
 	return NULL;
 }
 
+static int nbp_vlan_add_untagged(struct net_bridge_port *p,
+			  struct net_bridge_vlan *vlan,
+			  u16 flags)
+{
+	struct net_device *dev = p->dev;
+	struct net_bridge_vlan *untagged = rtnl_dereference(p->untagged);
+
+	if (untagged) {
+		/* Port already has untagged vlan set.  Drop the ref
+		 * to the old one since we'll be replace it.
+		 */
+		br_vlan_put(untagged);
+	} else {
+		if (!vlan_hw_buggy(dev)) {
+			int err = vlan_vid_add_hw(dev, 0);
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
+	return 0;
+}
+
+static void nbp_vlan_delete_untagged(struct net_bridge_port *p,
+				     struct net_bridge_vlan *vlan)
+{
+	struct net_bridge_vlan *untagged = rtnl_dereference(p->untagged);
+
+	if (untagged != vlan)
+		return;
+
+	/* Remove VLAN from the device filter if it is supported. */
+	if (vlan_vid_del_hw(p->dev, 0)) {
+		pr_warn("failed to kill vid %d for device %s\n",
+			vlan->vid, p->dev->name);
+	}
+
+	/* If this VLAN is currently functioning as untagged, clear it.
+	 * It's safe to drop the refcount, since the vlan is still held
+	 * by the port.
+	 */
+	br_vlan_put(vlan);
+	rcu_assign_pointer(p->untagged, NULL);
+
+}
+
 /* Must be protected by RTNL */
 int nbp_vlan_add(struct net_bridge_port *p, u16 vid, u16 flags)
 {
-	struct net_port_vlan *pve;
+	struct net_port_vlan *pve = NULL;
 	struct net_bridge_vlan *vlan;
 	struct net_device *dev = p->dev;
 	int err;
@@ -272,11 +373,21 @@ int nbp_vlan_add(struct net_bridge_port *p, u16 vid, u16 flags)
 	set_bit(p->port_no, vlan->port_bitmap);
 
 	list_add_tail_rcu(&pve->list, &p->vlan_list);
+
+	if (flags & BRIDGE_VLAN_INFO_UNTAGGED) {
+		err = nbp_vlan_add_untagged(p, vlan, flags);
+		if (err)
+			goto del_vlan;
+	}
+
 	return 0;
 
 clean_up:
 	kfree(pve);
-	br_vlan_del(vlan, flags);
+	br_vlan_del(p->br, vlan, flags);
+	return err;
+del_vlan:
+	nbp_vlan_delete(p, vid, flags);
 	return err;
 }
 
@@ -293,6 +404,9 @@ int nbp_vlan_delete(struct net_bridge_port *p, u16 vid, u16 flags)
 	if (!pve)
 		return -ENOENT;
 
+	if (flags & BRIDGE_VLAN_INFO_UNTAGGED)
+		nbp_vlan_delete_untagged(p, pve->vlan);
+
 	/* Remove VLAN from the device filter if it is supported. */
 	if (vlan_vid_del_hw(dev, vid))
 		pr_warn("failed to kill vid %d for device %s\n",
@@ -308,7 +422,7 @@ int nbp_vlan_delete(struct net_bridge_port *p, u16 vid, u16 flags)
 	list_del_rcu(&pve->list);
 	kfree_rcu(pve, rcu);
 
-	br_vlan_del(vlan, flags);
+	br_vlan_del(p->br, vlan, flags);
 
 	return 0;
 }
@@ -320,8 +434,11 @@ static void nbp_vlan_flush(struct net_bridge_port *p)
 
 	ASSERT_RTNL();
 
-	list_for_each_entry_safe(pve, tmp, &p->vlan_list, list)
-		nbp_vlan_delete(p, pve->vid, BRIDGE_FLAGS_SELF);
+	list_for_each_entry_safe(pve, tmp, &p->vlan_list, list)  {
+		nbp_vlan_delete(p, pve->vid,
+				(BRIDGE_VLAN_INFO_MASTER |
+				 BRIDGE_VLAN_INFO_UNTAGGED));
+	}
 }
 
 static void release_nbp(struct kobject *kobj)
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 84c6f04..fc6ba39 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -197,7 +197,8 @@ static int br_afspec(struct net_bridge *br, struct net_bridge_port *p,
 			if (p)
 				err = nbp_vlan_add(p, vinfo->vid, vinfo->flags);
 			else {
-				u16 flags = vinfo->flags | BRIDGE_FLAGS_SELF;
+				u16 flags = vinfo->flags |
+					    BRIDGE_VLAN_INFO_MASTER;
 				if (!br_vlan_add(br, vinfo->vid, flags))
 					err = -ENOMEM;
 			}
@@ -208,7 +209,8 @@ static int br_afspec(struct net_bridge *br, struct net_bridge_port *p,
 				err = nbp_vlan_delete(p, vinfo->vid,
 						      vinfo->flags);
 			else {
-				u16 flags = vinfo->flags | BRIDGE_FLAGS_SELF;
+				u16 flags = vinfo->flags |
+					    BRIDGE_VLAN_INFO_MASTER;
 				err = br_vlan_delete(br, vinfo->vid, flags);
 			}
 			break;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index cc75212..9328463 100644
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
-- 
1.7.7.6

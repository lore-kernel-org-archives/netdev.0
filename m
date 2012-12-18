From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH V2 09/12] bridge: Add the ability to configure untagged vlans
Date: Tue, 18 Dec 2012 14:01:00 -0500
Message-ID: <1355857263-31197-10-git-send-email-vyasevic@redhat.com>
References: <1355857263-31197-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, davem@davemloft.net, or.gerlitz@gmail.com,
	jhs@mojatatu.com, mst@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56294 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755579Ab2LRTBh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2012 14:01:37 -0500
In-Reply-To: <1355857263-31197-1-git-send-email-vyasevic@redhat.com>
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
 net/bridge/br_if.c             |  146 +++++++++++++++++++++++++++++++++++++---
 net/bridge/br_netlink.c        |    6 +-
 net/bridge/br_private.h        |    2 +
 4 files changed, 144 insertions(+), 13 deletions(-)

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
index 57bbb35..14563fb 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -108,6 +108,34 @@ static void br_vlan_put(struct net_bridge_vlan *vlan)
 		br_vlan_destroy(vlan);
 }
 
+/* Must be protected by RTNL */
+static void br_vlan_add_untagged(struct net_bridge *br,
+				 struct net_bridge_vlan *vlan)
+{
+	ASSERT_RTNL();
+	if (br->untagged == vlan)
+		return;
+	else if (br->untagged) {
+		/* Untagged vlan is already set on the master,
+		 * so drop the ref since we'll be replacing it.
+		 */
+		br_vlan_put(br->untagged);
+	}
+	br_vlan_hold(vlan);
+	rcu_assign_pointer(br->untagged, vlan);
+}
+
+/* Must be protected by RTNL */
+static void br_vlan_del_untagged(struct net_bridge *br,
+				 struct net_bridge_vlan *vlan)
+{
+	ASSERT_RTNL();
+	if (br->untagged == vlan) {
+		br_vlan_put(vlan);
+		rcu_assign_pointer(br->untagged, NULL);
+	}
+}
+
 struct net_bridge_vlan *br_vlan_find(struct net_bridge *br, u16 vid)
 {
 	struct net_bridge_vlan *vlan;
@@ -132,7 +160,7 @@ struct net_bridge_vlan *br_vlan_add(struct net_bridge *br, u16 vid,
 
 	vlan = br_vlan_find(br, vid);
 	if (vlan)
-		return vlan;
+		goto untagged;
 
 	vlan = kzalloc(sizeof(struct net_bridge_vlan), GFP_KERNEL);
 	if (!vlan)
@@ -141,7 +169,7 @@ struct net_bridge_vlan *br_vlan_add(struct net_bridge *br, u16 vid,
 	vlan->vid = vid;
 	atomic_set(&vlan->refcnt, 1);
 
-	if (flags & BRIDGE_FLAGS_SELF) {
+	if (flags & BRIDGE_VLAN_INFO_MASTER) {
 		/* Set bit 0 that is associated with the bridge master
 		 * device.  Port numbers start with 1.
 		 */
@@ -149,15 +177,24 @@ struct net_bridge_vlan *br_vlan_add(struct net_bridge *br, u16 vid,
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
@@ -172,6 +209,14 @@ static void br_vlan_del(struct net_bridge_vlan *vlan, u16 flags)
 
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
@@ -187,7 +232,7 @@ int br_vlan_delete(struct net_bridge *br, u16 vid, u16 flags)
 	if (!vlan)
 		return -ENOENT;
 
-	br_vlan_del(vlan, flags);
+	br_vlan_del(br, vlan, flags);
 	return 0;
 }
 
@@ -204,7 +249,9 @@ static void br_vlan_flush(struct net_bridge *br)
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
@@ -224,10 +271,70 @@ struct net_port_vlan *nbp_vlan_find(const struct net_bridge_port *p, u16 vid)
 	return NULL;
 }
 
+static int nbp_vlan_add_untagged(struct net_bridge_port *p,
+			  struct net_bridge_vlan *vlan,
+			  u16 flags)
+{
+	struct net_device *dev = p->dev;
+
+	if (p->untagged) {
+		/* Port already has untagged vlan set.  Drop the ref
+		 * to the old one since we'll be replace it.
+		 */
+		br_vlan_put(p->untagged);
+	} else {
+		int err;
+
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
+	return 0;
+}
+
+static void nbp_vlan_delete_untagged(struct net_bridge_port *p,
+				     struct net_bridge_vlan *vlan)
+{
+	if (p->untagged != vlan)
+		return;
+
+	/* Remove VLAN from the device filter if it is supported. */
+	if ((p->dev->features & NETIF_F_HW_VLAN_FILTER) &&
+	    p->dev->netdev_ops->ndo_vlan_rx_kill_vid) {
+		int err;
+
+		err = p->dev->netdev_ops->ndo_vlan_rx_kill_vid(p->dev, 0);
+		if (err) {
+			pr_warn("failed to kill vid %d for device %s\n",
+				vlan->vid, p->dev->name);
+		}
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
@@ -275,11 +382,21 @@ int nbp_vlan_add(struct net_bridge_port *p, u16 vid, u16 flags)
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
 
@@ -296,6 +413,9 @@ int nbp_vlan_delete(struct net_bridge_port *p, u16 vid, u16 flags)
 	if (!pve)
 		return -ENOENT;
 
+	if (flags & BRIDGE_VLAN_INFO_UNTAGGED)
+		nbp_vlan_delete_untagged(p, pve->vlan);
+
 	/* Remove VLAN from the device filter if it is supported. */
 	if ((dev->features & NETIF_F_HW_VLAN_FILTER) &&
 	    dev->netdev_ops->ndo_vlan_rx_kill_vid) {
@@ -306,6 +426,7 @@ int nbp_vlan_delete(struct net_bridge_port *p, u16 vid, u16 flags)
 			pr_warn("failed to kill vid %d for device %s\n",
 				vid, dev->name);
 	}
+
 	pve->vid = BR_INVALID_VID;
 
 	vlan = pve->vlan;
@@ -316,7 +437,7 @@ int nbp_vlan_delete(struct net_bridge_port *p, u16 vid, u16 flags)
 	list_del_rcu(&pve->list);
 	kfree_rcu(pve, rcu);
 
-	br_vlan_del(vlan, flags);
+	br_vlan_del(p->br, vlan, flags);
 
 	return 0;
 }
@@ -328,8 +449,11 @@ static void nbp_vlan_flush(struct net_bridge_port *p)
 
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
index 9cf2879..1b302ce 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -199,7 +199,8 @@ static int br_afspec(struct net_bridge *br, struct net_bridge_port *p,
 			if (p)
 				err = nbp_vlan_add(p, vinfo->vid, vinfo->flags);
 			else {
-				u16 flags = vinfo->flags | BRIDGE_FLAGS_SELF;
+				u16 flags = vinfo->flags |
+					    BRIDGE_VLAN_INFO_MASTER;
 				if (!br_vlan_add(br, vinfo->vid, flags))
 					err = -ENOMEM;
 			}
@@ -210,7 +211,8 @@ static int br_afspec(struct net_bridge *br, struct net_bridge_port *p,
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

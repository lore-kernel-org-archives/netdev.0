From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 4/6] vlan: introduce vid list with reference counting
Date: Thu,  8 Dec 2011 15:11:18 +0100
Message-ID: <1323353480-1900-5-git-send-email-jpirko@redhat.com>
References: <1323353480-1900-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	ebiederm@xmission.com, mirqus@gmail.com, kaber@trash.net,
	greearb@candelatech.com, jesse@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17277 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751404Ab1LHOLp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Dec 2011 09:11:45 -0500
In-Reply-To: <1323353480-1900-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows to keep track of vids needed to be in rx vlan filters of
devices even if they are used in bond/team etc.

vlan_info as well as vlan_group previously was, is allocated when first
vid is added and dealocated whan last vid is deleted.

vlan_group definition is moved to private header.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/linux/if_vlan.h   |   17 +----
 include/linux/netdevice.h |    3 +-
 net/8021q/vlan.c          |   90 ++++++++----------------
 net/8021q/vlan.h          |   30 +++++++-
 net/8021q/vlan_core.c     |  168 ++++++++++++++++++++++++++++++++++++++++++--
 5 files changed, 219 insertions(+), 89 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 71168a6..0c96913 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -74,22 +74,7 @@ static inline struct vlan_ethhdr *vlan_eth_hdr(const struct sk_buff *skb)
 /* found in socket.c */
 extern void vlan_ioctl_set(int (*hook)(struct net *, void __user *));
 
-/* if this changes, algorithm will have to be reworked because this
- * depends on completely exhausting the VLAN identifier space.  Thus
- * it gives constant time look-up, but in many cases it wastes memory.
- */
-#define VLAN_GROUP_ARRAY_SPLIT_PARTS  8
-#define VLAN_GROUP_ARRAY_PART_LEN     (VLAN_N_VID/VLAN_GROUP_ARRAY_SPLIT_PARTS)
-
-struct vlan_group {
-	struct net_device	*real_dev; /* The ethernet(like) device
-					    * the vlan is attached to.
-					    */
-	unsigned int		nr_vlans;
-	struct hlist_node	hlist;	/* linked list */
-	struct net_device **vlan_devices_arrays[VLAN_GROUP_ARRAY_SPLIT_PARTS];
-	struct rcu_head		rcu;
-};
+struct vlan_info;
 
 static inline int is_vlan_dev(struct net_device *dev)
 {
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f7bff96..6037308 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -55,7 +55,6 @@
 
 #include <linux/netdev_features.h>
 
-struct vlan_group;
 struct netpoll_info;
 struct phy_device;
 /* 802.11 specific */
@@ -1096,7 +1095,7 @@ struct net_device {
 	/* Protocol specific pointers */
 
 #if IS_ENABLED(CONFIG_VLAN_8021Q)
-	struct vlan_group __rcu	*vlgrp;		/* VLAN group */
+	struct vlan_info __rcu	*vlan_info;	/* VLAN info */
 #endif
 #if IS_ENABLED(CONFIG_NET_DSA)
 	struct dsa_switch_tree	*dsa_ptr;	/* dsa specific data */
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index dd9aa40..efea35b 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -51,27 +51,6 @@ const char vlan_version[] = DRV_VERSION;
 
 /* End of global variables definitions. */
 
-static void vlan_group_free(struct vlan_group *grp)
-{
-	int i;
-
-	for (i = 0; i < VLAN_GROUP_ARRAY_SPLIT_PARTS; i++)
-		kfree(grp->vlan_devices_arrays[i]);
-	kfree(grp);
-}
-
-static struct vlan_group *vlan_group_alloc(struct net_device *real_dev)
-{
-	struct vlan_group *grp;
-
-	grp = kzalloc(sizeof(struct vlan_group), GFP_KERNEL);
-	if (!grp)
-		return NULL;
-
-	grp->real_dev = real_dev;
-	return grp;
-}
-
 static int vlan_group_prealloc_vid(struct vlan_group *vg, u16 vlan_id)
 {
 	struct net_device **array;
@@ -92,22 +71,20 @@ static int vlan_group_prealloc_vid(struct vlan_group *vg, u16 vlan_id)
 	return 0;
 }
 
-static void vlan_rcu_free(struct rcu_head *rcu)
-{
-	vlan_group_free(container_of(rcu, struct vlan_group, rcu));
-}
-
 void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 {
 	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	struct net_device *real_dev = vlan->real_dev;
+	struct vlan_info *vlan_info;
 	struct vlan_group *grp;
 	u16 vlan_id = vlan->vlan_id;
 
 	ASSERT_RTNL();
 
-	grp = rtnl_dereference(real_dev->vlgrp);
-	BUG_ON(!grp);
+	vlan_info = rtnl_dereference(real_dev->vlan_info);
+	BUG_ON(!vlan_info);
+
+	grp = &vlan_info->grp;
 
 	/* Take it out of our own structures, but be sure to interlock with
 	 * HW accelerating devices or SW vlan input packet processing if
@@ -116,7 +93,7 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 	if (vlan_id)
 		vlan_vid_del(real_dev, vlan_id);
 
-	grp->nr_vlans--;
+	grp->nr_vlan_devs--;
 
 	if (vlan->flags & VLAN_FLAG_GVRP)
 		vlan_gvrp_request_leave(dev);
@@ -128,16 +105,9 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 	 */
 	unregister_netdevice_queue(dev, head);
 
-	/* If the group is now empty, kill off the group. */
-	if (grp->nr_vlans == 0) {
+	if (grp->nr_vlan_devs == 0)
 		vlan_gvrp_uninit_applicant(real_dev);
 
-		RCU_INIT_POINTER(real_dev->vlgrp, NULL);
-
-		/* Free the group, after all cpu's are done. */
-		call_rcu(&grp->rcu, vlan_rcu_free);
-	}
-
 	/* Get rid of the vlan's reference to real_dev */
 	dev_put(real_dev);
 }
@@ -169,17 +139,23 @@ int register_vlan_dev(struct net_device *dev)
 	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	struct net_device *real_dev = vlan->real_dev;
 	u16 vlan_id = vlan->vlan_id;
-	struct vlan_group *grp, *ngrp = NULL;
+	struct vlan_info *vlan_info;
+	struct vlan_group *grp;
 	int err;
 
-	grp = rtnl_dereference(real_dev->vlgrp);
-	if (!grp) {
-		ngrp = grp = vlan_group_alloc(real_dev);
-		if (!grp)
-			return -ENOBUFS;
+	err = vlan_vid_add(real_dev, vlan_id);
+	if (err)
+		return err;
+
+	vlan_info = rtnl_dereference(real_dev->vlan_info);
+	/* vlan_info should be there now. vlan_vid_add took care of it */
+	BUG_ON(!vlan_info);
+
+	grp = &vlan_info->grp;
+	if (grp->nr_vlan_devs == 0) {
 		err = vlan_gvrp_init_applicant(real_dev);
 		if (err < 0)
-			goto out_free_group;
+			goto out_vid_del;
 	}
 
 	err = vlan_group_prealloc_vid(grp, vlan_id);
@@ -200,23 +176,15 @@ int register_vlan_dev(struct net_device *dev)
 	 * it into our local structure.
 	 */
 	vlan_group_set_device(grp, vlan_id, dev);
-	grp->nr_vlans++;
-
-	if (ngrp) {
-		rcu_assign_pointer(real_dev->vlgrp, ngrp);
-	}
-	vlan_vid_add(real_dev, vlan_id);
+	grp->nr_vlan_devs++;
 
 	return 0;
 
 out_uninit_applicant:
-	if (ngrp)
+	if (grp->nr_vlan_devs == 0)
 		vlan_gvrp_uninit_applicant(real_dev);
-out_free_group:
-	if (ngrp) {
-		/* Free the group, after all cpu's are done. */
-		call_rcu(&ngrp->rcu, vlan_rcu_free);
-	}
+out_vid_del:
+	vlan_vid_del(real_dev, vlan_id);
 	return err;
 }
 
@@ -357,6 +325,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 {
 	struct net_device *dev = ptr;
 	struct vlan_group *grp;
+	struct vlan_info *vlan_info;
 	int i, flgs;
 	struct net_device *vlandev;
 	struct vlan_dev_priv *vlan;
@@ -372,9 +341,10 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		vlan_vid_add(dev, 0);
 	}
 
-	grp = rtnl_dereference(dev->vlgrp);
-	if (!grp)
+	vlan_info = rtnl_dereference(dev->vlan_info);
+	if (!vlan_info)
 		goto out;
+	grp = &vlan_info->grp;
 
 	/* It is OK that we do not hold the group lock right now,
 	 * as we run under the RTNL lock.
@@ -478,9 +448,9 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 			if (!vlandev)
 				continue;
 
-			/* unregistration of last vlan destroys group, abort
+			/* removal of last vid destroys vlan_info, abort
 			 * afterwards */
-			if (grp->nr_vlans == 1)
+			if (vlan_info->nr_vids == 1)
 				i = VLAN_N_VID;
 
 			unregister_vlan_dev(vlandev, &list);
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index d3c4ea4..28d8dc2 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -3,6 +3,7 @@
 
 #include <linux/if_vlan.h>
 #include <linux/u64_stats_sync.h>
+#include <linux/list.h>
 
 
 /**
@@ -74,6 +75,29 @@ static inline struct vlan_dev_priv *vlan_dev_priv(const struct net_device *dev)
 	return netdev_priv(dev);
 }
 
+/* if this changes, algorithm will have to be reworked because this
+ * depends on completely exhausting the VLAN identifier space.  Thus
+ * it gives constant time look-up, but in many cases it wastes memory.
+ */
+#define VLAN_GROUP_ARRAY_SPLIT_PARTS  8
+#define VLAN_GROUP_ARRAY_PART_LEN     (VLAN_N_VID/VLAN_GROUP_ARRAY_SPLIT_PARTS)
+
+struct vlan_group {
+	unsigned int		nr_vlan_devs;
+	struct hlist_node	hlist;	/* linked list */
+	struct net_device **vlan_devices_arrays[VLAN_GROUP_ARRAY_SPLIT_PARTS];
+};
+
+struct vlan_info {
+	struct net_device	*real_dev; /* The ethernet(like) device
+					    * the vlan is attached to.
+					    */
+	struct vlan_group	grp;
+	struct list_head	vid_list;
+	unsigned int		nr_vids;
+	struct rcu_head		rcu;
+};
+
 static inline struct net_device *vlan_group_get_device(struct vlan_group *vg,
 						       u16 vlan_id)
 {
@@ -97,10 +121,10 @@ static inline void vlan_group_set_device(struct vlan_group *vg,
 static inline struct net_device *vlan_find_dev(struct net_device *real_dev,
 					       u16 vlan_id)
 {
-	struct vlan_group *grp = rcu_dereference_rtnl(real_dev->vlgrp);
+	struct vlan_info *vlan_info = rcu_dereference_rtnl(real_dev->vlan_info);
 
-	if (grp)
-		return vlan_group_get_device(grp, vlan_id);
+	if (vlan_info)
+		return vlan_group_get_device(&vlan_info->grp, vlan_id);
 
 	return NULL;
 }
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 544f9cb..329e031 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -71,10 +71,10 @@ bool vlan_do_receive(struct sk_buff **skbp, bool last_handler)
 struct net_device *__vlan_find_dev_deep(struct net_device *real_dev,
 					u16 vlan_id)
 {
-	struct vlan_group *grp = rcu_dereference_rtnl(real_dev->vlgrp);
+	struct vlan_info *vlan_info = rcu_dereference_rtnl(real_dev->vlan_info);
 
-	if (grp) {
-		return vlan_group_get_device(grp, vlan_id);
+	if (vlan_info) {
+		return vlan_group_get_device(&vlan_info->grp, vlan_id);
 	} else {
 		/*
 		 * Bonding slaves do not have grp assigned to themselves.
@@ -147,25 +147,177 @@ err_free:
 	return NULL;
 }
 
-int vlan_vid_add(struct net_device *dev, unsigned short vid)
+
+/*
+ * vlan info and vid list
+ */
+
+static void vlan_group_free(struct vlan_group *grp)
+{
+	int i;
+
+	for (i = 0; i < VLAN_GROUP_ARRAY_SPLIT_PARTS; i++)
+		kfree(grp->vlan_devices_arrays[i]);
+}
+
+static void vlan_info_free(struct vlan_info *vlan_info)
+{
+	vlan_group_free(&vlan_info->grp);
+	kfree(vlan_info);
+}
+
+static void vlan_info_rcu_free(struct rcu_head *rcu)
+{
+	vlan_info_free(container_of(rcu, struct vlan_info, rcu));
+}
+
+static struct vlan_info *vlan_info_alloc(struct net_device *dev)
+{
+	struct vlan_info *vlan_info;
+
+	vlan_info = kzalloc(sizeof(struct vlan_info), GFP_KERNEL);
+	if (!vlan_info)
+		return NULL;
+
+	vlan_info->real_dev = dev;
+	INIT_LIST_HEAD(&vlan_info->vid_list);
+	return vlan_info;
+}
+
+struct vlan_vid_info {
+	struct list_head list;
+	unsigned short vid;
+	int refcount;
+};
+
+static struct vlan_vid_info *vlan_vid_info_get(struct vlan_info *vlan_info,
+					       unsigned short vid)
+{
+	struct vlan_vid_info *vid_info;
+
+	list_for_each_entry(vid_info, &vlan_info->vid_list, list) {
+		if (vid_info->vid == vid)
+			return vid_info;
+	}
+	return NULL;
+}
+
+static struct vlan_vid_info *vlan_vid_info_alloc(unsigned short vid)
+{
+	struct vlan_vid_info *vid_info;
+
+	vid_info = kzalloc(sizeof(struct vlan_vid_info), GFP_KERNEL);
+	if (!vid_info)
+		return NULL;
+	vid_info->vid = vid;
+
+	return vid_info;
+}
+
+static int __vlan_vid_add(struct vlan_info *vlan_info, unsigned short vid,
+			  struct vlan_vid_info **pvid_info)
 {
+	struct net_device *dev = vlan_info->real_dev;
 	const struct net_device_ops *ops = dev->netdev_ops;
+	struct vlan_vid_info *vid_info;
+	int err;
+
+	vid_info = vlan_vid_info_alloc(vid);
+	if (!vid_info)
+		return -ENOMEM;
 
 	if ((dev->features & NETIF_F_HW_VLAN_FILTER) &&
-	     ops->ndo_vlan_rx_add_vid) {
-		return ops->ndo_vlan_rx_add_vid(dev, vid);
+	    ops->ndo_vlan_rx_add_vid) {
+		err =  ops->ndo_vlan_rx_add_vid(dev, vid);
+		if (err) {
+			kfree(vid_info);
+			return err;
+		}
 	}
+	list_add(&vid_info->list, &vlan_info->vid_list);
+	vlan_info->nr_vids++;
+	*pvid_info = vid_info;
 	return 0;
 }
+
+int vlan_vid_add(struct net_device *dev, unsigned short vid)
+{
+	struct vlan_info *vlan_info;
+	struct vlan_vid_info *vid_info;
+	bool vlan_info_created = false;
+	int err;
+
+	ASSERT_RTNL();
+
+	vlan_info = rtnl_dereference(dev->vlan_info);
+	if (!vlan_info) {
+		vlan_info = vlan_info_alloc(dev);
+		if (!vlan_info)
+			return -ENOMEM;
+		vlan_info_created = true;
+	}
+	vid_info = vlan_vid_info_get(vlan_info, vid);
+	if (!vid_info) {
+		err = __vlan_vid_add(vlan_info, vid, &vid_info);
+		if (err)
+			goto out_free_vlan_info;
+	}
+	vid_info->refcount++;
+
+	if (vlan_info_created)
+		rcu_assign_pointer(dev->vlan_info, vlan_info);
+
+	return 0;
+
+out_free_vlan_info:
+	if (vlan_info_created)
+		kfree(vlan_info);
+	return err;
+}
 EXPORT_SYMBOL(vlan_vid_add);
 
-void vlan_vid_del(struct net_device *dev, unsigned short vid)
+static void __vlan_vid_del(struct vlan_info *vlan_info,
+			   struct vlan_vid_info *vid_info)
 {
+	struct net_device *dev = vlan_info->real_dev;
 	const struct net_device_ops *ops = dev->netdev_ops;
+	unsigned short vid = vid_info->vid;
+	int err;
 
 	if ((dev->features & NETIF_F_HW_VLAN_FILTER) &&
 	     ops->ndo_vlan_rx_kill_vid) {
-		ops->ndo_vlan_rx_kill_vid(dev, vid);
+		err = ops->ndo_vlan_rx_kill_vid(dev, vid);
+		if (err) {
+			pr_warn("failed to kill vid %d for device %s\n",
+				vid, dev->name);
+		}
+	}
+	list_del(&vid_info->list);
+	kfree(vid_info);
+	vlan_info->nr_vids--;
+}
+
+void vlan_vid_del(struct net_device *dev, unsigned short vid)
+{
+	struct vlan_info *vlan_info;
+	struct vlan_vid_info *vid_info;
+
+	ASSERT_RTNL();
+
+	vlan_info = rtnl_dereference(dev->vlan_info);
+	if (!vlan_info)
+		return;
+
+	vid_info = vlan_vid_info_get(vlan_info, vid);
+	if (!vid_info)
+		return;
+	vid_info->refcount--;
+	if (vid_info->refcount == 0) {
+		__vlan_vid_del(vlan_info, vid_info);
+		if (vlan_info->nr_vids == 0) {
+			RCU_INIT_POINTER(dev->vlan_info, NULL);
+			call_rcu(&vlan_info->rcu, vlan_info_rcu_free);
+		}
 	}
 }
 EXPORT_SYMBOL(vlan_vid_del);
-- 
1.7.6

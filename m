From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN 12/18]: Simplify vlan unregistration
Date: Sun, 20 Jan 2008 18:11:33 +0100 (MET)
Message-ID: <20080120171133.7980.6354.sendpatchset@localhost.localdomain>
References: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62366 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754492AbYATRLf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 12:11:35 -0500
In-Reply-To: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[VLAN]: Simplify vlan unregistration

Keep track of the number of VLAN devices in a vlan group. This allows
to have the caller sense when the group is going to be destroyed and
stop using it, which in turn allows to remove the wrapper around
unregister_vlan_dev for the NETDEV_UNREGISTER notifier and avoid
iterating over all possible VLAN ids whenever a device in unregistered.

Also fix what looks like a use-after-free (but is actually safe since
we're holding the RTNL), the real_dev reference should not be dropped
while we still use it.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit cd41c792d7df5107c05f2529426ae68f817e38f6
tree 469a2f8242654a34329d4b51e66e27f200ec314f
parent 9f39c0253f370dae13a81cda9cf119052bb11750
author Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 17:37:31 +0100
committer Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 17:37:31 +0100

 include/linux/if_vlan.h  |    1 +
 net/8021q/vlan.c         |   76 ++++++++++++----------------------------------
 net/8021q/vlan.h         |    2 +
 net/8021q/vlan_netlink.c |    7 +---
 4 files changed, 23 insertions(+), 63 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 07db416..129fa87 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -82,6 +82,7 @@ extern void vlan_ioctl_set(int (*hook)(struct net *, void __user *));
 
 struct vlan_group {
 	int real_dev_ifindex; /* The ifindex of the ethernet(like) device the vlan is attached to. */
+	unsigned int		nr_vlans;
 	struct hlist_node	hlist;	/* linked list */
 	struct net_device **vlan_devices_arrays[VLAN_GROUP_ARRAY_SPLIT_PARTS];
 	struct rcu_head		rcu;
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index ad34e4a..ac79638 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -132,33 +132,17 @@ static void vlan_rcu_free(struct rcu_head *rcu)
 	vlan_group_free(container_of(rcu, struct vlan_group, rcu));
 }
 
-
-/* This returns 0 if everything went fine.
- * It will return 1 if the group was killed as a result.
- * A negative return indicates failure.
- *
- * The RTNL lock must be held.
- */
-static int unregister_vlan_dev(struct net_device *real_dev,
-			       unsigned short vlan_id)
+void unregister_vlan_dev(struct net_device *dev)
 {
-	struct net_device *dev;
-	int real_dev_ifindex = real_dev->ifindex;
+	struct vlan_dev_info *vlan = VLAN_DEV_INFO(dev);
+	struct net_device *real_dev = vlan->real_dev;
 	struct vlan_group *grp;
-	unsigned int i;
-	int ret;
-
-	if (vlan_id >= VLAN_VID_MASK)
-		return -EINVAL;
+	unsigned short vlan_id = vlan->vlan_id;
 
 	ASSERT_RTNL();
-	grp = __vlan_find_group(real_dev_ifindex);
-	if (!grp)
-		return -ENOENT;
 
-	dev = vlan_group_get_device(grp, vlan_id);
-	if (!dev)
-		return -ENOENT;
+	grp = __vlan_find_group(real_dev->ifindex);
+	BUG_ON(!grp);
 
 	vlan_proc_rem_dev(dev);
 
@@ -169,20 +153,12 @@ static int unregister_vlan_dev(struct net_device *real_dev,
 		real_dev->vlan_rx_kill_vid(real_dev, vlan_id);
 
 	vlan_group_set_device(grp, vlan_id, NULL);
-	synchronize_net();
+	grp->nr_vlans--;
 
-	/* Caller unregisters (and if necessary, puts) VLAN device, but we
-	 * get rid of the reference to real_dev here.
-	 */
-	dev_put(real_dev);
+	synchronize_net();
 
 	/* If the group is now empty, kill off the group. */
-	ret = 0;
-	for (i = 0; i < VLAN_VID_MASK; i++)
-		if (vlan_group_get_device(grp, i))
-			break;
-
-	if (i == VLAN_VID_MASK) {
+	if (grp->nr_vlans == 0) {
 		if (real_dev->features & NETIF_F_HW_VLAN_RX)
 			real_dev->vlan_rx_register(real_dev, NULL);
 
@@ -190,23 +166,12 @@ static int unregister_vlan_dev(struct net_device *real_dev,
 
 		/* Free the group, after all cpu's are done. */
 		call_rcu(&grp->rcu, vlan_rcu_free);
-		ret = 1;
 	}
 
-	return ret;
-}
-
-int unregister_vlan_device(struct net_device *dev)
-{
-	int ret;
+	/* Get rid of the vlan's reference to real_dev */
+	dev_put(real_dev);
 
-	ret = unregister_vlan_dev(VLAN_DEV_INFO(dev)->real_dev,
-				  VLAN_DEV_INFO(dev)->vlan_id);
 	unregister_netdevice(dev);
-
-	if (ret == 1)
-		ret = 0;
-	return ret;
 }
 
 static void vlan_transfer_operstate(const struct net_device *dev, struct net_device *vlandev)
@@ -291,6 +256,8 @@ int register_vlan_dev(struct net_device *dev)
 	 * it into our local structure.
 	 */
 	vlan_group_set_device(grp, vlan_id, dev);
+	grp->nr_vlans++;
+
 	if (ngrp && real_dev->features & NETIF_F_HW_VLAN_RX)
 		real_dev->vlan_rx_register(real_dev, ngrp);
 	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
@@ -479,20 +446,16 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 	case NETDEV_UNREGISTER:
 		/* Delete all VLANs for this dev. */
 		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
-			int ret;
-
 			vlandev = vlan_group_get_device(grp, i);
 			if (!vlandev)
 				continue;
 
-			ret = unregister_vlan_dev(dev,
-						  VLAN_DEV_INFO(vlandev)->vlan_id);
-
-			unregister_netdevice(vlandev);
+			/* unregistration of last vlan destroys group, abort
+			 * afterwards */
+			if (grp->nr_vlans == 1)
+				i = VLAN_GROUP_ARRAY_LEN;
 
-			/* Group was destroyed? */
-			if (ret == 1)
-				break;
+			unregister_vlan_dev(vlandev);
 		}
 		break;
 	}
@@ -598,7 +561,8 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
 		err = -EPERM;
 		if (!capable(CAP_NET_ADMIN))
 			break;
-		err = unregister_vlan_device(dev);
+		unregister_vlan_dev(dev);
+		err = 0;
 		break;
 
 	case GET_VLAN_REALDEV_NAME_CMD:
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 5637865..0cfdf77 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -38,7 +38,7 @@ void vlan_dev_get_vid(const struct net_device *dev, unsigned short *result);
 int vlan_check_real_dev(struct net_device *real_dev, unsigned short vlan_id);
 void vlan_setup(struct net_device *dev);
 int register_vlan_dev(struct net_device *dev);
-int unregister_vlan_device(struct net_device *dev);
+void unregister_vlan_dev(struct net_device *dev);
 
 int vlan_netlink_init(void);
 void vlan_netlink_fini(void);
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index 0996185..9ee6358 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -137,11 +137,6 @@ static int vlan_newlink(struct net_device *dev,
 	return register_vlan_dev(dev);
 }
 
-static void vlan_dellink(struct net_device *dev)
-{
-	unregister_vlan_device(dev);
-}
-
 static inline size_t vlan_qos_map_size(unsigned int n)
 {
 	if (n == 0)
@@ -226,7 +221,7 @@ struct rtnl_link_ops vlan_link_ops __read_mostly = {
 	.validate	= vlan_validate,
 	.newlink	= vlan_newlink,
 	.changelink	= vlan_changelink,
-	.dellink	= vlan_dellink,
+	.dellink	= unregister_vlan_dev,
 	.get_size	= vlan_get_size,
 	.fill_info	= vlan_fill_info,
 };

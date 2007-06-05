From: Patrick McHardy <kaber@trash.net>
Subject: [RFC VLAN 02/08]: Remove unregister_vlan_dev wrapper
Date: Tue,  5 Jun 2007 16:23:32 +0200 (MEST)
Message-ID: <20070605142331.20372.55373.sendpatchset@localhost.localdomain>
References: <20070605142327.20372.18108.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64164 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764116AbXFEOXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 10:23:33 -0400
In-Reply-To: <20070605142327.20372.18108.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[VLAN]: Remove unregister_vlan_dev wrapper

Remove the now useless unregister_vlan_dev wrapper by moving the final
unregister_netdev to unregister_vlan_dev itself. Also replace a few
impossible conditions by BUG_ON and don't try to handle them as valid.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 7286bd4222a1a9722b1d3b80988078b0af973a67
tree e9a21434dc634051d99513432b051b3e18c5e5c7
parent b2981f2b9c99d414e9ea990cda7ca31c5bef2420
author Patrick McHardy <kaber@trash.net> Tue, 29 May 2007 15:48:16 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 29 May 2007 15:48:16 +0200

 net/8021q/vlan.c |  140 +++++++++++++++++++-----------------------------------
 1 files changed, 48 insertions(+), 92 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 0d95388..87de961 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -51,7 +51,7 @@ static char vlan_buggyright[] = "David S. Miller <davem@redhat.com>";
 
 static int vlan_device_event(struct notifier_block *, unsigned long, void *);
 static int vlan_ioctl_handler(void __user *);
-static int unregister_vlan_dev(struct net_device *, unsigned short );
+static int unregister_vlan_dev(struct net_device *);
 
 static struct notifier_block vlan_notifier_block = {
 	.notifier_call = vlan_device_event,
@@ -118,12 +118,8 @@ static void __exit vlan_cleanup_devices(void)
 
 	rtnl_lock();
 	for_each_netdev_safe(dev, nxt) {
-		if (dev->priv_flags & IFF_802_1Q_VLAN) {
-			unregister_vlan_dev(VLAN_DEV_INFO(dev)->real_dev,
-					    VLAN_DEV_INFO(dev)->vlan_id);
-
-			unregister_netdevice(dev);
-		}
+		if (dev->priv_flags & IFF_802_1Q_VLAN)
+			unregister_vlan_dev(dev);
 	}
 	rtnl_unlock();
 }
@@ -202,94 +198,61 @@ static void vlan_rcu_free(struct rcu_head *rcu)
 	vlan_group_free(container_of(rcu, struct vlan_group, rcu));
 }
 
-
-/* This returns 0 if everything went fine.
- * It will return 1 if the group was killed as a result.
- * A negative return indicates failure.
- *
- * The RTNL lock must be held.
+/* Destroy a VLAN device. Returns 1 if the device destroyed was the
+ * last one on the underlying device and the group was destroyed,
+ * 0 otherwise.
  */
-static int unregister_vlan_dev(struct net_device *real_dev,
-			       unsigned short vlan_id)
+static int unregister_vlan_dev(struct net_device *dev)
 {
-	struct net_device *dev = NULL;
-	int real_dev_ifindex = real_dev->ifindex;
+	struct net_device *real_dev = VLAN_DEV_INFO(dev)->real_dev;
+	unsigned short vlan_id = VLAN_DEV_INFO(dev)->vlan_id;
 	struct vlan_group *grp;
-	int i, ret;
+	int i, ret = 0;
 
 #ifdef VLAN_DEBUG
 	printk(VLAN_DBG "%s: VID: %i\n", __FUNCTION__, vlan_id);
 #endif
+	ASSERT_RTNL();
 
-	/* sanity check */
-	if (vlan_id >= VLAN_VID_MASK)
-		return -EINVAL;
+	grp = __vlan_find_group(real_dev->ifindex);
 
-	ASSERT_RTNL();
-	grp = __vlan_find_group(real_dev_ifindex);
-
-	ret = 0;
-
-	if (grp) {
-		dev = vlan_group_get_device(grp, vlan_id);
-		if (dev) {
-			/* Remove proc entry */
-			vlan_proc_rem_dev(dev);
-
-			/* Take it out of our own structures, but be sure to
-			 * interlock with HW accelerating devices or SW vlan
-			 * input packet processing.
-			 */
-			if (real_dev->features &
-			    (NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER)) {
-				real_dev->vlan_rx_kill_vid(real_dev, vlan_id);
-			}
-
-			vlan_group_set_device(grp, vlan_id, NULL);
-			synchronize_net();
-
-
-			/* Caller unregisters (and if necessary, puts)
-			 * VLAN device, but we get rid of the reference to
-			 * real_dev here.
-			 */
-			dev_put(real_dev);
-
-			/* If the group is now empty, kill off the
-			 * group.
-			 */
-			for (i = 0; i < VLAN_VID_MASK; i++)
-				if (vlan_group_get_device(grp, i))
-					break;
-
-			if (i == VLAN_VID_MASK) {
-				if (real_dev->features & NETIF_F_HW_VLAN_RX)
-					real_dev->vlan_rx_register(real_dev, NULL);
-
-				hlist_del_rcu(&grp->hlist);
-
-				/* Free the group, after all cpu's are done. */
-				call_rcu(&grp->rcu, vlan_rcu_free);
-
-				grp = NULL;
-				ret = 1;
-			}
-		}
-	}
+	BUG_ON(!grp);
+	BUG_ON(vlan_id >= VLAN_VID_MASK);
+	BUG_ON(vlan_group_get_device(grp, vlan_id) != dev);
 
-	return ret;
-}
+	/* Remove proc entry */
+	vlan_proc_rem_dev(dev);
 
-static int unregister_vlan_device(struct net_device *dev)
-{
-	int ret;
+	/* Take it out of our own structures, but be sure to interlock with
+	 * HW accelerating devices or SW vlan input packet processing.
+	 */
+	if (real_dev->features &
+	    (NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER))
+		real_dev->vlan_rx_kill_vid(real_dev, vlan_id);
 
-	ret = unregister_vlan_dev(VLAN_DEV_INFO(dev)->real_dev,
-				  VLAN_DEV_INFO(dev)->vlan_id);
-	unregister_netdevice(dev);
+	vlan_group_set_device(grp, vlan_id, NULL);
+	synchronize_net();
+
+	/* Get rid of the reference to real_dev in struct vlan_dev_info */
+	dev_put(real_dev);
+
+	/* If the group is now empty, kill off the group. */
+	for (i = 0; i < VLAN_VID_MASK; i++)
+		if (vlan_group_get_device(grp, i))
+			break;
+
+	if (i == VLAN_VID_MASK) {
+		if (real_dev->features & NETIF_F_HW_VLAN_RX)
+			real_dev->vlan_rx_register(real_dev, NULL);
 
-	if (ret == 1)
-		ret = 0;
+		hlist_del_rcu(&grp->hlist);
+
+		/* Free the group, after all cpu's are done. */
+		call_rcu(&grp->rcu, vlan_rcu_free);
+		ret = 1;
+
+	}
+	unregister_netdevice(dev);
 	return ret;
 }
 
@@ -623,19 +586,12 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
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
-
-			/* Group was destroyed? */
-			if (ret == 1)
+			if (unregister_vlan_dev(vlandev))
+				/* Group was destroyed? */
 				break;
 		}
 		break;
@@ -749,7 +705,7 @@ static int vlan_ioctl_handler(void __user *arg)
 		err = -EPERM;
 		if (!capable(CAP_NET_ADMIN))
 			break;
-		err = unregister_vlan_device(dev);
+		err = unregister_vlan_dev(dev);
 		break;
 
 	case GET_VLAN_INGRESS_PRIORITY_CMD:

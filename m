From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN 13/18]: Move device registation to seperate function
Date: Wed, 13 Jun 2007 18:51:00 +0200 (MEST)
Message-ID: <20070613165056.7780.96546.sendpatchset@localhost.localdomain>
References: <20070613165039.7780.15855.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35961 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759091AbXFMQvC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 12:51:02 -0400
In-Reply-To: <20070613165039.7780.15855.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[VLAN]: Move device registation to seperate function

Move device registration and configuration of the underlying device to a
seperate function.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 0bd5a42a938a42aa15a4e9ac01777d74653e7c8d
tree e7ddfd00b19f52f1e04ad955fa3e4037485e0cdc
parent 8defb0af6d2f31cfa6180b0b4c83124f5d90cb32
author Patrick McHardy <kaber@trash.net> Wed, 06 Jun 2007 14:46:48 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 13 Jun 2007 18:10:32 +0200

 net/8021q/vlan.c |   83 +++++++++++++++++++++++++++++++-----------------------
 1 files changed, 47 insertions(+), 36 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 1e33dbb..e68b503 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -447,6 +447,51 @@ static int vlan_check_real_dev(struct net_device *real_dev, unsigned short vlan_
 	return 0;
 }
 
+static int register_vlan_dev(struct net_device *dev)
+{
+	struct vlan_dev_info *vlan = VLAN_DEV_INFO(dev);
+	struct net_device *real_dev = vlan->real_dev;
+	unsigned short vlan_id = vlan->vlan_id;
+	struct vlan_group *grp, *ngrp = NULL;
+	int err;
+
+	grp = __vlan_find_group(real_dev->ifindex);
+	if (!grp) {
+		ngrp = grp = vlan_group_alloc(real_dev->ifindex);
+		if (!grp)
+			return -ENOBUFS;
+	}
+
+	err = register_netdevice(dev);
+	if (err < 0)
+		goto out_free_group;
+
+	/* Account for reference in struct vlan_dev_info */
+	dev_hold(real_dev);
+
+	vlan_transfer_operstate(real_dev, dev);
+	linkwatch_fire_event(dev); /* _MUST_ call rfc2863_policy() */
+
+	/* So, got the sucker initialized, now lets place
+	 * it into our local structure.
+	 */
+	vlan_group_set_device(grp, vlan_id, dev);
+	if (ngrp && real_dev->features & NETIF_F_HW_VLAN_RX)
+		real_dev->vlan_rx_register(real_dev, ngrp);
+	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
+		real_dev->vlan_rx_add_vid(real_dev, vlan_id);
+
+	if (vlan_proc_add_dev(dev) < 0)
+		printk(KERN_WARNING "VLAN: failed to add proc entry for %s\n",
+		       dev->name);
+	return 0;
+
+out_free_group:
+	if (ngrp)
+		vlan_group_free(ngrp);
+	return err;
+}
+
 /*  Attach a VLAN device to a mac address (ie Ethernet Card).
  *  Returns the device that was created, or NULL if there was
  *  an error of some kind.
@@ -454,7 +499,6 @@ static int vlan_check_real_dev(struct net_device *real_dev, unsigned short vlan_
 static struct net_device *register_vlan_device(struct net_device *real_dev,
 					       unsigned short VLAN_ID)
 {
-	struct vlan_group *grp, *ngrp = NULL;
 	struct net_device *new_dev;
 	char name[IFNAMSIZ];
 
@@ -522,37 +566,8 @@ static struct net_device *register_vlan_device(struct net_device *real_dev,
 	VLAN_DEV_INFO(new_dev)->dent = NULL;
 	VLAN_DEV_INFO(new_dev)->flags = 1;
 
-#ifdef VLAN_DEBUG
-	printk(VLAN_DBG "About to go find the group for idx: %i\n",
-	       real_dev->ifindex);
-#endif
-	grp = __vlan_find_group(real_dev->ifindex);
-	if (!grp) {
-		ngrp = grp = vlan_group_alloc(real_dev->ifindex);
-		if (!grp)
-			goto out_free_newdev;
-	}
-
-	if (register_netdevice(new_dev))
-		goto out_free_group;
-
-	vlan_transfer_operstate(real_dev, new_dev);
-	linkwatch_fire_event(new_dev); /* _MUST_ call rfc2863_policy() */
-
-	/* So, got the sucker initialized, now lets place
-	 * it into our local structure.
-	 */
-	if (ngrp && real_dev->features & NETIF_F_HW_VLAN_RX)
-		real_dev->vlan_rx_register(real_dev, ngrp);
-
-	vlan_group_set_device(grp, VLAN_ID, new_dev);
-
-	if (vlan_proc_add_dev(new_dev)<0)/* create it's proc entry */
-		printk(KERN_WARNING "VLAN: failed to add proc entry for %s\n",
-							 new_dev->name);
-
-	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
-		real_dev->vlan_rx_add_vid(real_dev, VLAN_ID);
+	if (register_vlan_dev(new_dev) < 0)
+		goto out_free_newdev;
 
 	/* Account for reference in struct vlan_dev_info */
 	dev_hold(real_dev);
@@ -561,10 +576,6 @@ static struct net_device *register_vlan_device(struct net_device *real_dev,
 #endif
 	return new_dev;
 
-out_free_group:
-	if (ngrp)
-		vlan_group_free(ngrp);
-
 out_free_newdev:
 	free_netdev(new_dev);
 

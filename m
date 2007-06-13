From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN 11/18]: Move vlan_group allocation to seperate function
Date: Wed, 13 Jun 2007 18:50:57 +0200 (MEST)
Message-ID: <20070613165054.7780.7306.sendpatchset@localhost.localdomain>
References: <20070613165039.7780.15855.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35952 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758932AbXFMQu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 12:50:59 -0400
In-Reply-To: <20070613165039.7780.15855.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[VLAN]: Move vlan_group allocation to seperate function

Move group allocation to a seperate function to clean up the code a bit
and allocate groups before registering the device. Device registration
is globally visible and causes netlink events, so we shouldn't fail
afterwards.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit db130c75de212df303702758f553a7f4349ae56a
tree cd086b8106cb58dab0d28bf276b06f8b3f1295dc
parent cdca24994aa848abede6d80566fd64be997d3a20
author Patrick McHardy <kaber@trash.net> Wed, 06 Jun 2007 14:46:38 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 13 Jun 2007 18:10:31 +0200

 net/8021q/vlan.c |   78 ++++++++++++++++++++++++++++--------------------------
 1 files changed, 41 insertions(+), 37 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index dc95f7c..1b9dc5e 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -197,6 +197,34 @@ static void vlan_group_free(struct vlan_group *grp)
 	kfree(grp);
 }
 
+static struct vlan_group *vlan_group_alloc(int ifindex)
+{
+	struct vlan_group *grp;
+	unsigned int size;
+	unsigned int i;
+
+	grp = kzalloc(sizeof(struct vlan_group), GFP_KERNEL);
+	if (!grp)
+		return NULL;
+
+	size = sizeof(struct net_device *) * VLAN_GROUP_ARRAY_PART_LEN;
+
+	for (i = 0; i < VLAN_GROUP_ARRAY_SPLIT_PARTS; i++) {
+		grp->vlan_devices_arrays[i] = kzalloc(size, GFP_KERNEL);
+		if (!grp->vlan_devices_arrays[i])
+			goto err;
+	}
+
+	grp->real_dev_ifindex = ifindex;
+	hlist_add_head_rcu(&grp->hlist,
+			   &vlan_group_hash[vlan_grp_hashfn(ifindex)]);
+	return grp;
+
+err:
+	vlan_group_free(grp);
+	return NULL;
+}
+
 static void vlan_rcu_free(struct rcu_head *rcu)
 {
 	vlan_group_free(container_of(rcu, struct vlan_group, rcu));
@@ -389,10 +417,9 @@ static void vlan_transfer_operstate(const struct net_device *dev, struct net_dev
 static struct net_device *register_vlan_device(struct net_device *real_dev,
 					       unsigned short VLAN_ID)
 {
-	struct vlan_group *grp;
+	struct vlan_group *grp, *ngrp = NULL;
 	struct net_device *new_dev;
 	char name[IFNAMSIZ];
-	int i;
 
 #ifdef VLAN_DEBUG
 	printk(VLAN_DBG "%s: if_name -:%s:-	vid: %i\n",
@@ -491,9 +518,15 @@ static struct net_device *register_vlan_device(struct net_device *real_dev,
 	printk(VLAN_DBG "About to go find the group for idx: %i\n",
 	       real_dev->ifindex);
 #endif
+	grp = __vlan_find_group(real_dev->ifindex);
+	if (!grp) {
+		ngrp = grp = vlan_group_alloc(real_dev->ifindex);
+		if (!grp)
+			goto out_free_newdev;
+	}
 
 	if (register_netdevice(new_dev))
-		goto out_free_newdev;
+		goto out_free_group;
 
 	vlan_transfer_operstate(real_dev, new_dev);
 	linkwatch_fire_event(new_dev); /* _MUST_ call rfc2863_policy() */
@@ -501,34 +534,8 @@ static struct net_device *register_vlan_device(struct net_device *real_dev,
 	/* So, got the sucker initialized, now lets place
 	 * it into our local structure.
 	 */
-	grp = __vlan_find_group(real_dev->ifindex);
-
-	/* Note, we are running under the RTNL semaphore
-	 * so it cannot "appear" on us.
-	 */
-	if (!grp) { /* need to add a new group */
-		grp = kzalloc(sizeof(struct vlan_group), GFP_KERNEL);
-		if (!grp)
-			goto out_free_unregister;
-
-		for (i=0; i < VLAN_GROUP_ARRAY_SPLIT_PARTS; i++) {
-			grp->vlan_devices_arrays[i] = kzalloc(
-				sizeof(struct net_device *)*VLAN_GROUP_ARRAY_PART_LEN,
-				GFP_KERNEL);
-
-			if (!grp->vlan_devices_arrays[i])
-				goto out_free_arrays;
-		}
-
-		/* printk(KERN_ALERT "VLAN REGISTER:  Allocated new group.\n"); */
-		grp->real_dev_ifindex = real_dev->ifindex;
-
-		hlist_add_head_rcu(&grp->hlist,
-				   &vlan_group_hash[vlan_grp_hashfn(real_dev->ifindex)]);
-
-		if (real_dev->features & NETIF_F_HW_VLAN_RX)
-			real_dev->vlan_rx_register(real_dev, grp);
-	}
+	if (ngrp && real_dev->features & NETIF_F_HW_VLAN_RX)
+		real_dev->vlan_rx_register(real_dev, ngrp);
 
 	vlan_group_set_device(grp, VLAN_ID, new_dev);
 
@@ -546,12 +553,9 @@ static struct net_device *register_vlan_device(struct net_device *real_dev,
 #endif
 	return new_dev;
 
-out_free_arrays:
-	vlan_group_free(grp);
-
-out_free_unregister:
-	unregister_netdev(new_dev);
-	goto out_ret_null;
+out_free_group:
+	if (ngrp)
+		vlan_group_free(ngrp);
 
 out_free_newdev:
 	free_netdev(new_dev);

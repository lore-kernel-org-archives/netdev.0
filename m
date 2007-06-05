From: Patrick McHardy <kaber@trash.net>
Subject: [RFC VLAN 04/08]: Move vlan_group allocation to seperate function
Date: Tue,  5 Jun 2007 16:23:35 +0200 (MEST)
Message-ID: <20070605142334.20372.10312.sendpatchset@localhost.localdomain>
References: <20070605142327.20372.18108.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64168 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764298AbXFEOXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 10:23:37 -0400
In-Reply-To: <20070605142327.20372.18108.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[VLAN]: Move vlan_group allocation to seperate function

Move group allocation to a seperate function to clean up the code a bit
and allocate groups before registering the device. Device registration
is globally visible and causes netlink events, so we shouldn't fail
afterwards.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 1057887432918a89e5b374c29ac36224716cb0e4
tree 280fcd63f25b1c19053285d5b0ebf983a95e08a9
parent c771a6df20db3f21062bbbf56f09f2a64535cb71
author Patrick McHardy <kaber@trash.net> Tue, 29 May 2007 15:48:16 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 29 May 2007 15:48:16 +0200

 net/8021q/vlan.c |   78 ++++++++++++++++++++++++++++--------------------------
 1 files changed, 41 insertions(+), 37 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index c745530..d470913 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -193,6 +193,34 @@ static void vlan_group_free(struct vlan_group *grp)
 	kfree(grp);
 }
 
+static struct vlan_group *vlan_group_alloc(int ifindex)
+{
+	struct vlan_group *group;
+	unsigned int size;
+	unsigned int i;
+
+	group = kzalloc(sizeof(struct vlan_group), GFP_KERNEL);
+	if (!group)
+		return NULL;
+
+	size = sizeof(struct net_device *) * VLAN_GROUP_ARRAY_PART_LEN;
+
+	for (i = 0; i < VLAN_GROUP_ARRAY_SPLIT_PARTS; i++) {
+		group->vlan_devices_arrays[i] = kzalloc(size, GFP_KERNEL);
+		if (!group->vlan_devices_arrays[i])
+			goto err;
+	}
+
+	group->real_dev_ifindex = ifindex;
+	hlist_add_head_rcu(&group->hlist,
+			   &vlan_group_hash[vlan_grp_hashfn(ifindex)]);
+	return group;
+
+err:
+	vlan_group_free(group);
+	return NULL;
+}
+
 static void vlan_rcu_free(struct rcu_head *rcu)
 {
 	vlan_group_free(container_of(rcu, struct vlan_group, rcu));
@@ -359,10 +387,9 @@ static void vlan_transfer_operstate(const struct net_device *dev, struct net_dev
 static struct net_device *register_vlan_device(struct net_device *real_dev,
 					       unsigned short VLAN_ID)
 {
-	struct vlan_group *grp;
+	struct vlan_group *grp, *reg = NULL;
 	struct net_device *new_dev;
 	char name[IFNAMSIZ];
-	int i;
 
 #ifdef VLAN_DEBUG
 	printk(VLAN_DBG "%s: if_name -:%s:-	vid: %i\n",
@@ -459,9 +486,15 @@ static struct net_device *register_vlan_device(struct net_device *real_dev,
 	printk(VLAN_DBG "About to go find the group for idx: %i\n",
 	       real_dev->ifindex);
 #endif
+	grp = __vlan_find_group(real_dev->ifindex);
+	if (!grp) {
+		reg = grp = vlan_group_alloc(real_dev->ifindex);
+		if (!grp)
+			goto out_free_newdev;
+	}
 
 	if (register_netdevice(new_dev))
-		goto out_free_newdev;
+		goto out_free_group;
 
 	vlan_transfer_operstate(real_dev, new_dev);
 	linkwatch_fire_event(new_dev); /* _MUST_ call rfc2863_policy() */
@@ -469,34 +502,8 @@ static struct net_device *register_vlan_device(struct net_device *real_dev,
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
+	if (reg && real_dev->features & NETIF_F_HW_VLAN_RX)
+		real_dev->vlan_rx_register(real_dev, reg);
 
 	vlan_group_set_device(grp, VLAN_ID, new_dev);
 
@@ -514,12 +521,9 @@ static struct net_device *register_vlan_device(struct net_device *real_dev,
 #endif
 	return new_dev;
 
-out_free_arrays:
-	vlan_group_free(grp);
-
-out_free_unregister:
-	unregister_netdev(new_dev);
-	goto out_ret_null;
+out_free_group:
+	if (reg)
+		vlan_group_free(reg);
 
 out_free_newdev:
 	free_netdev(new_dev);

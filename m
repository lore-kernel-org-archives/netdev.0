From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26][VLAN]: Reduce memory consumed by vlan_group-s.
Date: Mon, 03 Mar 2008 19:43:59 +0300
Message-ID: <47CC2ACF.6080903@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:58852 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754142AbYCCQoD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 11:44:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently each vlan_groupd contains 8 pointers on arrays with 512 
pointers on struct net_device each :) Such a construction "in many 
cases ... wastes memory".

My proposal is to allow for some of these arrays pointers be NULL,
meaning that there are no devices in it. When a new device is added 
to the vlan_group, the appropriate array is allocated.

The check in vlan_group_get_device's is safe, since the pointer
vg->vlan_devices_arrays[x] can only switch from NULL to not-NULL.
The vlan_group_prealloc_vid() is guarded with rtnl lock and is
also safe.

I've checked (I hope that) all the places, that use these arrays 
and found, that the register_vlan_dev is the only place, that can
put a vlan device on an empty vlan_group.

Rough calculations shows, that after the patch a setup with a 
single vlan dev (or up to 512 vlans with sequential vids) will 
occupy approximately 8 times less memory.

The question I have is - does this patch makes sense, or a totally 
new structures are required to store the vlan_devs?

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 79504b2..edd55af 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -93,7 +93,7 @@ static inline struct net_device *vlan_group_get_device(struct vlan_group *vg,
 {
 	struct net_device **array;
 	array = vg->vlan_devices_arrays[vlan_id / VLAN_GROUP_ARRAY_PART_LEN];
-	return array[vlan_id % VLAN_GROUP_ARRAY_PART_LEN];
+	return array ? array[vlan_id % VLAN_GROUP_ARRAY_PART_LEN] : NULL;
 }
 
 static inline void vlan_group_set_device(struct vlan_group *vg,
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index dbc81b9..4ff856d 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -106,29 +106,35 @@ static void vlan_group_free(struct vlan_group *grp)
 static struct vlan_group *vlan_group_alloc(int ifindex)
 {
 	struct vlan_group *grp;
-	unsigned int size;
-	unsigned int i;
 
 	grp = kzalloc(sizeof(struct vlan_group), GFP_KERNEL);
 	if (!grp)
 		return NULL;
 
-	size = sizeof(struct net_device *) * VLAN_GROUP_ARRAY_PART_LEN;
-
-	for (i = 0; i < VLAN_GROUP_ARRAY_SPLIT_PARTS; i++) {
-		grp->vlan_devices_arrays[i] = kzalloc(size, GFP_KERNEL);
-		if (!grp->vlan_devices_arrays[i])
-			goto err;
-	}
-
 	grp->real_dev_ifindex = ifindex;
 	hlist_add_head_rcu(&grp->hlist,
 			   &vlan_group_hash[vlan_grp_hashfn(ifindex)]);
 	return grp;
+}
 
-err:
-	vlan_group_free(grp);
-	return NULL;
+static int vlan_group_prealloc_vid(struct vlan_group *vg, int vid)
+{
+	struct net_device **array;
+	unsigned int size;
+
+	ASSERT_RTNL();
+
+	array = vg->vlan_devices_arrays[vid / VLAN_GROUP_ARRAY_PART_LEN];
+	if (array != NULL)
+		return 0;
+
+	size = sizeof(struct net_device *) * VLAN_GROUP_ARRAY_PART_LEN;
+	array = kzalloc(size, GFP_KERNEL);
+	if (array == NULL)
+		return -ENOBUFS;
+
+	vg->vlan_devices_arrays[vid / VLAN_GROUP_ARRAY_PART_LEN] = array;
+	return 0;
 }
 
 static void vlan_rcu_free(struct rcu_head *rcu)
@@ -247,6 +253,10 @@ int register_vlan_dev(struct net_device *dev)
 			return -ENOBUFS;
 	}
 
+	err = vlan_group_prealloc_vid(grp, vlan_id);
+	if (err < 0)
+		goto out_free_group;
+
 	err = register_netdevice(dev);
 	if (err < 0)
 		goto out_free_group;


From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] vlan: add rtnl_dereference() annotations
Date: Wed, 14 Dec 2011 09:29:43 +0300
Message-ID: <20111214062943.GD7499@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:16423 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119Ab1LNGaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 01:30:07 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original code generates a Sparse warning:
net/8021q/vlan_core.c:336:9:
	error: incompatible types in comparison expression (different address spaces)

It's ok to dereference __rcu pointers here because we are holding the
RTNL lock.  I've added some calls to rtnl_dereference() to silence the
warning.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
I haven't tested this, and I'm not super familiar with this code.
Please review it carefully.

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 1414c93..4d39d80 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -326,14 +326,16 @@ int vlan_vids_add_by_dev(struct net_device *dev,
 			 const struct net_device *by_dev)
 {
 	struct vlan_vid_info *vid_info;
+	struct vlan_info *vlan_info;
 	int err;
 
 	ASSERT_RTNL();
 
-	if (!by_dev->vlan_info)
+	vlan_info = rtnl_dereference(by_dev->vlan_info);
+	if (!vlan_info)
 		return 0;
 
-	list_for_each_entry(vid_info, &by_dev->vlan_info->vid_list, list) {
+	list_for_each_entry(vid_info, &vlan_info->vid_list, list) {
 		err = vlan_vid_add(dev, vid_info->vid);
 		if (err)
 			goto unwind;
@@ -342,7 +344,7 @@ int vlan_vids_add_by_dev(struct net_device *dev,
 
 unwind:
 	list_for_each_entry_continue_reverse(vid_info,
-					     &by_dev->vlan_info->vid_list,
+					     &vlan_info->vid_list,
 					     list) {
 		vlan_vid_del(dev, vid_info->vid);
 	}
@@ -355,13 +357,15 @@ void vlan_vids_del_by_dev(struct net_device *dev,
 			  const struct net_device *by_dev)
 {
 	struct vlan_vid_info *vid_info;
+	struct vlan_info *vlan_info;
 
 	ASSERT_RTNL();
 
-	if (!by_dev->vlan_info)
+	vlan_info = rtnl_dereference(by_dev->vlan_info);
+	if (!vlan_info)
 		return;
 
-	list_for_each_entry(vid_info, &by_dev->vlan_info->vid_list, list)
+	list_for_each_entry(vid_info, &vlan_info->vid_list, list)
 		vlan_vid_del(dev, vid_info->vid);
 }
 EXPORT_SYMBOL(vlan_vids_del_by_dev);

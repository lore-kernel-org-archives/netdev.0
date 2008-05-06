From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 4/4 (optional)][MAC80211]: Brush up error paths in mesh_path_add.
Date: Tue, 06 May 2008 18:53:43 +0400
Message-ID: <482070F7.5060506@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-wireless@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:46053 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750744AbYEFO4x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 10:56:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are already tree paths, that do incremental rollbacks, so
merge them together, rename labels and format the code to look a
bit nicer.

(I do not mind dropping/delaying this patch however).

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/mac80211/mesh_pathtbl.c |   42 ++++++++++++++++++++----------------------
 1 files changed, 20 insertions(+), 22 deletions(-)

diff --git a/net/mac80211/mesh_pathtbl.c b/net/mac80211/mesh_pathtbl.c
index 99c2d36..7097ef9 100644
--- a/net/mac80211/mesh_pathtbl.c
+++ b/net/mac80211/mesh_pathtbl.c
@@ -158,19 +158,14 @@ int mesh_path_add(u8 *dst, struct net_device *dev)
 	if (atomic_add_unless(&sdata->u.sta.mpaths, 1, MESH_MAX_MPATHS) == 0)
 		return -ENOSPC;
 
+	err = -ENOMEM;
 	new_mpath = kzalloc(sizeof(struct mesh_path), GFP_KERNEL);
-	if (!new_mpath) {
-		atomic_dec(&sdata->u.sta.mpaths);
-		err = -ENOMEM;
-		goto endadd2;
-	}
+	if (!new_mpath)
+		goto err_path_alloc;
+
 	new_node = kmalloc(sizeof(struct mpath_node), GFP_KERNEL);
-	if (!new_node) {
-		kfree(new_mpath);
-		atomic_dec(&sdata->u.sta.mpaths);
-		err = -ENOMEM;
-		goto endadd2;
-	}
+	if (!new_node)
+		goto err_node_alloc;
 
 	read_lock(&pathtbl_resize_lock);
 	memcpy(new_mpath->dst, dst, ETH_ALEN);
@@ -189,16 +184,11 @@ int mesh_path_add(u8 *dst, struct net_device *dev)
 
 	spin_lock(&mesh_paths->hashwlock[hash_idx]);
 
+	err = -EEXIST;
 	hlist_for_each_entry(node, n, bucket, list) {
 		mpath = node->mpath;
-		if (mpath->dev == dev && memcmp(dst, mpath->dst, ETH_ALEN)
-				== 0) {
-			err = -EEXIST;
-			atomic_dec(&sdata->u.sta.mpaths);
-			kfree(new_node);
-			kfree(new_mpath);
-			goto endadd;
-		}
+		if (mpath->dev == dev && memcmp(dst, mpath->dst, ETH_ALEN) == 0)
+			goto err_exists;
 	}
 
 	hlist_add_head_rcu(&new_node->list, bucket);
@@ -206,10 +196,9 @@ int mesh_path_add(u8 *dst, struct net_device *dev)
 		mesh_paths->mean_chain_len * (mesh_paths->hash_mask + 1))
 		grow = 1;
 
-endadd:
 	spin_unlock(&mesh_paths->hashwlock[hash_idx]);
 	read_unlock(&pathtbl_resize_lock);
-	if (!err && grow) {
+	if (grow) {
 		struct mesh_table *oldtbl, *newtbl;
 
 		write_lock(&pathtbl_resize_lock);
@@ -225,7 +214,16 @@ endadd:
 		synchronize_rcu();
 		mesh_table_free(oldtbl, false);
 	}
-endadd2:
+	return 0;
+
+err_exists:
+	spin_unlock(&mesh_paths->hashwlock[hash_idx]);
+	read_unlock(&pathtbl_resize_lock);
+	kfree(new_node);
+err_node_alloc:
+	kfree(new_mpath);
+err_path_alloc:
+	atomic_dec(&sdata->u.sta.mpaths);
 	return err;
 }
 
-- 
1.5.3.4


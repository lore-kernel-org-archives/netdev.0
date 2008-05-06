From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 1/4][MAC80211]: Fix GFP_KERNEL allocation under read lock.
Date: Tue, 06 May 2008 18:46:36 +0400
Message-ID: <48206F4C.5050105@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-wireless@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:50228 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755658AbYEFOtw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 10:49:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mesh_path_add() read-locks the pathtbl_resize_lock and calls
kmalloc with GFP_KERNEL mask.

Fix it and move the endadd2 label lower. It should be _before_ the
if() beyond, but it makes no sense for it being there, so I move it
right after this if().

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/mac80211/mesh_pathtbl.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/mac80211/mesh_pathtbl.c b/net/mac80211/mesh_pathtbl.c
index 5845dc2..727aa52 100644
--- a/net/mac80211/mesh_pathtbl.c
+++ b/net/mac80211/mesh_pathtbl.c
@@ -158,14 +158,14 @@ int mesh_path_add(u8 *dst, struct net_device *dev)
 	if (atomic_add_unless(&sdata->u.sta.mpaths, 1, MESH_MAX_MPATHS) == 0)
 		return -ENOSPC;
 
-	read_lock(&pathtbl_resize_lock);
-
 	new_mpath = kzalloc(sizeof(struct mesh_path), GFP_KERNEL);
 	if (!new_mpath) {
 		atomic_dec(&sdata->u.sta.mpaths);
 		err = -ENOMEM;
 		goto endadd2;
 	}
+
+	read_lock(&pathtbl_resize_lock);
 	memcpy(new_mpath->dst, dst, ETH_ALEN);
 	new_mpath->dev = dev;
 	new_mpath->flags = 0;
@@ -202,7 +202,6 @@ int mesh_path_add(u8 *dst, struct net_device *dev)
 
 endadd:
 	spin_unlock(&mesh_paths->hashwlock[hash_idx]);
-endadd2:
 	read_unlock(&pathtbl_resize_lock);
 	if (!err && grow) {
 		struct mesh_table *oldtbl, *newtbl;
@@ -219,6 +218,7 @@ endadd2:
 		mesh_table_free(oldtbl, false);
 		write_unlock(&pathtbl_resize_lock);
 	}
+endadd2:
 	return err;
 }
 
-- 
1.5.3.4


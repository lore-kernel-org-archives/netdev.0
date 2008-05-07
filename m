From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 7/7][MAC80211]: Consolidate hash kfree-ing in mesh.c.
Date: Wed, 07 May 2008 19:57:11 +0400
Message-ID: <4821D157.90403@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:37424 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758550AbYEGP77 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 May 2008 11:59:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are already two places, that kfree the mesh_table and
its buckets.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/mac80211/mesh.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index f46fbdb..876ec18 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -315,6 +315,13 @@ struct mesh_table *mesh_table_alloc(int size_order)
 	return newtbl;
 }
 
+static void __mesh_table_free(struct mesh_table *tbl)
+{
+	kfree(tbl->hash_buckets);
+	kfree(tbl->hashwlock);
+	kfree(tbl);
+}
+
 void mesh_table_free(struct mesh_table *tbl, bool free_leafs)
 {
 	struct hlist_head *mesh_hash;
@@ -330,9 +337,7 @@ void mesh_table_free(struct mesh_table *tbl, bool free_leafs)
 		}
 		spin_unlock(&tbl->hashwlock[i]);
 	}
-	kfree(tbl->hash_buckets);
-	kfree(tbl->hashwlock);
-	kfree(tbl);
+	__mesh_table_free(tbl);
 }
 
 static void ieee80211_mesh_path_timer(unsigned long data)
@@ -378,9 +383,7 @@ errcopy:
 		hlist_for_each_safe(p, q, &newtbl->hash_buckets[i])
 			tbl->free_node(p, 0);
 	}
-	kfree(newtbl->hash_buckets);
-	kfree(newtbl->hashwlock);
-	kfree(newtbl);
+	__mesh_table_free(tbl);
 endgrow:
 	return NULL;
 }
-- 
1.5.3.4


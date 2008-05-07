From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/7][MAC80211]: Prepare mesh_table_grow to failing copy_node
 callback.
Date: Wed, 07 May 2008 19:47:01 +0400
Message-ID: <4821CEF5.7020501@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The mesh_path_node_copy() performs kmalloc() and thus - may fail
(well, it does not now, but I'm fixing this right now). Its caller -
the mesh_table_grow() - isn't prepared for such a trick yet.

This preparation is just flush the new hash and make copy_node()
return an int value.

Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

---
 net/mac80211/mesh.c         |   15 +++++++++++++--
 net/mac80211/mesh.h         |    2 +-
 net/mac80211/mesh_pathtbl.c |    3 ++-
 3 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index f76bc26..273f0b6 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -349,7 +349,7 @@ struct mesh_table *mesh_table_grow(struct mesh_table *tbl)
 {
 	struct mesh_table *newtbl;
 	struct hlist_head *oldhash;
-	struct hlist_node *p;
+	struct hlist_node *p, *q;
 	int err = 0;
 	int i;
 
@@ -373,13 +373,24 @@ struct mesh_table *mesh_table_grow(struct mesh_table *tbl)
 	oldhash = tbl->hash_buckets;
 	for (i = 0; i <= tbl->hash_mask; i++)
 		hlist_for_each(p, &oldhash[i])
-			tbl->copy_node(p, newtbl);
+			if (tbl->copy_node(p, newtbl) < 0)
+				goto errcopy;
 
 endgrow:
 	if (err)
 		return NULL;
 	else
 		return newtbl;
+
+errcopy:
+	for (i = 0; i <= newtbl->hash_mask; i++) {
+		hlist_for_each_safe(p, q, &newtbl->hash_buckets[i])
+			tbl->free_node(p, 0);
+	}
+	kfree(newtbl->hash_buckets);
+	kfree(newtbl->hashwlock);
+	kfree(newtbl);
+	return NULL;
 }
 
 /**
diff --git a/net/mac80211/mesh.h b/net/mac80211/mesh.h
index 2e161f6..669eafa 100644
--- a/net/mac80211/mesh.h
+++ b/net/mac80211/mesh.h
@@ -109,7 +109,7 @@ struct mesh_table {
 	__u32 hash_rnd;			/* Used for hash generation */
 	atomic_t entries;		/* Up to MAX_MESH_NEIGHBOURS */
 	void (*free_node) (struct hlist_node *p, bool free_leafs);
-	void (*copy_node) (struct hlist_node *p, struct mesh_table *newtbl);
+	int (*copy_node) (struct hlist_node *p, struct mesh_table *newtbl);
 	int size_order;
 	int mean_chain_len;
 };
diff --git a/net/mac80211/mesh_pathtbl.c b/net/mac80211/mesh_pathtbl.c
index 0b6c4bf..512bfa1 100644
--- a/net/mac80211/mesh_pathtbl.c
+++ b/net/mac80211/mesh_pathtbl.c
@@ -463,7 +463,7 @@ static void mesh_path_node_free(struct hlist_node *p, bool free_leafs)
 	kfree(node);
 }
 
-static void mesh_path_node_copy(struct hlist_node *p, struct mesh_table *newtbl)
+static int mesh_path_node_copy(struct hlist_node *p, struct mesh_table *newtbl)
 {
 	struct mesh_path *mpath;
 	struct mpath_node *node, *new_node;
@@ -476,6 +476,7 @@ static void mesh_path_node_copy(struct hlist_node *p, struct mesh_table *newtbl)
 	hash_idx = mesh_table_hash(mpath->dst, mpath->dev, newtbl);
 	hlist_add_head(&new_node->list,
 			&newtbl->hash_buckets[hash_idx]);
+	return 0;
 }
 
 int mesh_pathtbl_init(void)
-- 
1.5.3.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

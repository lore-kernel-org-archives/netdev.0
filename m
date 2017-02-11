From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v2 PATCH 1/3] gfs2: Use rhashtable walk interface in glock_hash_walk
Date: Sat, 11 Feb 2017 19:26:45 +0800
Message-ID: <E1ccVpF-0000Qj-GU@gondobar>
References: <20170211112421.GA1570@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
        Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:36097 "EHLO
        helcar.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751200AbdBKS61 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2017 13:58:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function glock_hash_walk walks the rhashtable by hand.  This
is broken because if it catches the hash table in the middle of
a rehash, then it will miss entries.

This patch replaces the manual walk by using the rhashtable walk
interface.

Fixes: 88ffbf3e037e ("GFS2: Use resizable hash table for glocks")
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 fs/gfs2/glock.c |   28 +++++++++++++++++-----------
 1 file changed, 17 insertions(+), 11 deletions(-)

diff --git a/fs/gfs2/glock.c b/fs/gfs2/glock.c
index 94f50ca..70e9417 100644
--- a/fs/gfs2/glock.c
+++ b/fs/gfs2/glock.c
@@ -1420,26 +1420,32 @@ static unsigned long gfs2_glock_shrink_count(struct shrinker *shrink,
  * @sdp: the filesystem
  * @bucket: the bucket
  *
+ * Note that the function can be called multiple times on the same
+ * object.  So the user must ensure that the function can cope with
+ * that.
  */
 
 static void glock_hash_walk(glock_examiner examiner, const struct gfs2_sbd *sdp)
 {
 	struct gfs2_glock *gl;
-	struct rhash_head *pos;
-	const struct bucket_table *tbl;
-	int i;
+	struct rhashtable_iter iter;
 
-	rcu_read_lock();
-	tbl = rht_dereference_rcu(gl_hash_table.tbl, &gl_hash_table);
-	for (i = 0; i < tbl->size; i++) {
-		rht_for_each_entry_rcu(gl, pos, tbl, i, gl_node) {
+	rhashtable_walk_enter(&gl_hash_table, &iter);
+
+	do {
+		gl = ERR_PTR(rhashtable_walk_start(&iter));
+		if (gl)
+			continue;
+
+		while ((gl = rhashtable_walk_next(&iter)) && !IS_ERR(gl))
 			if ((gl->gl_name.ln_sbd == sdp) &&
 			    lockref_get_not_dead(&gl->gl_lockref))
 				examiner(gl);
-		}
-	}
-	rcu_read_unlock();
-	cond_resched();
+
+		rhashtable_walk_stop(&iter);
+	} while (cond_resched(), gl == ERR_PTR(-EAGAIN));
+
+	rhashtable_walk_exit(&iter);
 }
 
 /**

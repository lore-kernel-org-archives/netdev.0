From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 21/21] batman-adv: Convert batadv_tt_common_entry to kref
Date: Wed, 10 Feb 2016 23:57:27 +0800
Message-ID: <1455119847-5862-22-git-send-email-a@unstable.cc>
References: <1455119847-5862-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:39732 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752558AbcBJQSc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2016 11:18:32 -0500
In-Reply-To: <1455119847-5862-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

batman-adv uses a self-written reference implementation which is just based
on atomic_t. This is less obvious when reading the code than kref and
therefore increases the change that the reference counting will be missed.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/translation-table.c | 64 +++++++++++++++++++++++++++++---------
 net/batman-adv/types.h             |  2 +-
 2 files changed, 51 insertions(+), 15 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 96b1571213bd..11882793f0a4 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -142,7 +142,7 @@ batadv_tt_hash_find(struct batadv_hashtable *hash, const u8 *addr,
 		if (tt->vid != vid)
 			continue;
 
-		if (!atomic_inc_not_zero(&tt->refcount))
+		if (!kref_get_unless_zero(&tt->refcount))
 			continue;
 
 		tt_tmp = tt;
@@ -203,25 +203,59 @@ batadv_tt_global_hash_find(struct batadv_priv *bat_priv, const u8 *addr,
 	return tt_global_entry;
 }
 
-static void
-batadv_tt_local_entry_free_ref(struct batadv_tt_local_entry *tt_local_entry)
+/**
+ * batadv_tt_local_entry_release - release tt_local_entry from lists and queue
+ *  for free after rcu grace period
+ * @ref: kref pointer of the nc_node
+ */
+static void batadv_tt_local_entry_release(struct kref *ref)
 {
-	if (atomic_dec_and_test(&tt_local_entry->common.refcount))
-		kfree_rcu(tt_local_entry, common.rcu);
+	struct batadv_tt_local_entry *tt_local_entry;
+
+	tt_local_entry = container_of(ref, struct batadv_tt_local_entry,
+				      common.refcount);
+
+	kfree_rcu(tt_local_entry, common.rcu);
 }
 
 /**
- * batadv_tt_global_entry_free_ref - decrement the refcounter for a
- *  tt_global_entry and possibly free it
- * @tt_global_entry: the object to free
+ * batadv_tt_local_entry_free_ref - decrement the tt_local_entry refcounter and
+ *  possibly release it
+ * @tt_local_entry: tt_local_entry to be free'd
+ */
+static void
+batadv_tt_local_entry_free_ref(struct batadv_tt_local_entry *tt_local_entry)
+{
+	kref_put(&tt_local_entry->common.refcount,
+		 batadv_tt_local_entry_release);
+}
+
+/**
+ * batadv_tt_global_entry_release - release tt_global_entry from lists and queue
+ *  for free after rcu grace period
+ * @ref: kref pointer of the nc_node
+ */
+static void batadv_tt_global_entry_release(struct kref *ref)
+{
+	struct batadv_tt_global_entry *tt_global_entry;
+
+	tt_global_entry = container_of(ref, struct batadv_tt_global_entry,
+				       common.refcount);
+
+	batadv_tt_global_del_orig_list(tt_global_entry);
+	kfree_rcu(tt_global_entry, common.rcu);
+}
+
+/**
+ * batadv_tt_global_entry_free_ref - decrement the tt_global_entry refcounter
+ *  and possibly release it
+ * @tt_global_entry: tt_global_entry to be free'd
  */
 static void
 batadv_tt_global_entry_free_ref(struct batadv_tt_global_entry *tt_global_entry)
 {
-	if (atomic_dec_and_test(&tt_global_entry->common.refcount)) {
-		batadv_tt_global_del_orig_list(tt_global_entry);
-		kfree_rcu(tt_global_entry, common.rcu);
-	}
+	kref_put(&tt_global_entry->common.refcount,
+		 batadv_tt_global_entry_release);
 }
 
 /**
@@ -633,7 +667,8 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const u8 *addr,
 	tt_local->common.vid = vid;
 	if (batadv_is_wifi_netdev(in_dev))
 		tt_local->common.flags |= BATADV_TT_CLIENT_WIFI;
-	atomic_set(&tt_local->common.refcount, 2);
+	kref_init(&tt_local->common.refcount);
+	kref_get(&tt_local->common.refcount);
 	tt_local->last_seen = jiffies;
 	tt_local->common.added_at = tt_local->last_seen;
 
@@ -1415,7 +1450,8 @@ static bool batadv_tt_global_add(struct batadv_priv *bat_priv,
 		 */
 		if (flags & BATADV_TT_CLIENT_ROAM)
 			tt_global_entry->roam_at = jiffies;
-		atomic_set(&common->refcount, 2);
+		kref_init(&common->refcount);
+		kref_get(&common->refcount);
 		common->added_at = jiffies;
 
 		INIT_HLIST_HEAD(&tt_global_entry->orig_list);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index aea82a121c02..612de23178e6 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -972,7 +972,7 @@ struct batadv_tt_common_entry {
 	struct hlist_node hash_entry;
 	u16 flags;
 	unsigned long added_at;
-	atomic_t refcount;
+	struct kref refcount;
 	struct rcu_head rcu;
 };
 
-- 
2.7.1

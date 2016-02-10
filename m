From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 10/21] batman-adv: Convert batadv_nc_path to kref
Date: Wed, 10 Feb 2016 23:57:16 +0800
Message-ID: <1455119847-5862-11-git-send-email-a@unstable.cc>
References: <1455119847-5862-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:12309 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752935AbcBJQSY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2016 11:18:24 -0500
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
 net/batman-adv/network-coding.c | 28 +++++++++++++++++++++-------
 net/batman-adv/types.h          |  2 +-
 2 files changed, 22 insertions(+), 8 deletions(-)

diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index 7a1216eeb4cf..371fc6bbf9d6 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -233,14 +233,27 @@ static void batadv_nc_node_free_ref(struct batadv_nc_node *nc_node)
 }
 
 /**
- * batadv_nc_path_free_ref - decrements the nc path refcounter and possibly
- * frees it
- * @nc_path: the nc node to free
+ * batadv_nc_path_release - release nc_path from lists and queue for free after
+ *  rcu grace period
+ * @ref: kref pointer of the nc_path
+ */
+static void batadv_nc_path_release(struct kref *ref)
+{
+	struct batadv_nc_path *nc_path;
+
+	nc_path = container_of(ref, struct batadv_nc_path, refcount);
+
+	kfree_rcu(nc_path, rcu);
+}
+
+/**
+ * batadv_nc_path_free_ref - decrement the nc_path refcounter and possibly
+ *  release it
+ * @nc_path: nc_path to be free'd
  */
 static void batadv_nc_path_free_ref(struct batadv_nc_path *nc_path)
 {
-	if (atomic_dec_and_test(&nc_path->refcount))
-		kfree_rcu(nc_path, rcu);
+	kref_put(&nc_path->refcount, batadv_nc_path_release);
 }
 
 /**
@@ -545,7 +558,7 @@ batadv_nc_hash_find(struct batadv_hashtable *hash,
 		if (!batadv_nc_hash_compare(&nc_path->hash_entry, data))
 			continue;
 
-		if (!atomic_inc_not_zero(&nc_path->refcount))
+		if (!kref_get_unless_zero(&nc_path->refcount))
 			continue;
 
 		nc_path_tmp = nc_path;
@@ -972,7 +985,8 @@ static struct batadv_nc_path *batadv_nc_get_path(struct batadv_priv *bat_priv,
 	/* Initialize nc_path */
 	INIT_LIST_HEAD(&nc_path->packet_list);
 	spin_lock_init(&nc_path->packet_list_lock);
-	atomic_set(&nc_path->refcount, 2);
+	kref_init(&nc_path->refcount);
+	kref_get(&nc_path->refcount);
 	nc_path->last_valid = jiffies;
 	ether_addr_copy(nc_path->next_hop, dst);
 	ether_addr_copy(nc_path->prev_hop, src);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 05421afb1d74..b3d9b5b566a2 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1087,7 +1087,7 @@ struct batadv_nc_node {
 struct batadv_nc_path {
 	struct hlist_node hash_entry;
 	struct rcu_head rcu;
-	atomic_t refcount;
+	struct kref refcount;
 	struct list_head packet_list;
 	spinlock_t packet_list_lock; /* Protects packet_list */
 	u8 next_hop[ETH_ALEN];
-- 
2.7.1

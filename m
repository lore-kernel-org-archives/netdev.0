From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 1/8] batman-adv: hash_add() has to discriminate on the return value
Date: Wed, 24 Aug 2011 15:00:31 +0200
Message-ID: <1314190838-2273-2-git-send-email-lindner_marek@yahoo.de>
References: <1314190838-2273-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm18.bullet.mail.ukl.yahoo.com ([217.146.183.192]:33106 "HELO
	nm18.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751090Ab1HXNAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 09:00:50 -0400
In-Reply-To: <1314190838-2273-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>

hash_add() returns 0 on success while returns -1 either on error and on
entry already present. The caller could use such information to select
its behaviour. For this reason it is useful that hash_add() returns -1
in case on error and returns 1 in case of entry already present.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/hash.h       |   25 +++++++++++++++++++------
 net/batman-adv/originator.c |    2 +-
 net/batman-adv/vis.c        |    4 ++--
 3 files changed, 22 insertions(+), 9 deletions(-)

diff --git a/net/batman-adv/hash.h b/net/batman-adv/hash.h
index dd5c9fd..d20aa71 100644
--- a/net/batman-adv/hash.h
+++ b/net/batman-adv/hash.h
@@ -76,19 +76,30 @@ static inline void hash_delete(struct hashtable_t *hash,
 	hash_destroy(hash);
 }
 
-/* adds data to the hashtable. returns 0 on success, -1 on error */
+/**
+ *	hash_add - adds data to the hashtable
+ *	@hash: storage hash table
+ *	@compare: callback to determine if 2 hash elements are identical
+ *	@choose: callback calculating the hash index
+ *	@data: data passed to the aforementioned callbacks as argument
+ *	@data_node: to be added element
+ *
+ *	Returns 0 on success, 1 if the element already is in the hash
+ *	and -1 on error.
+ */
+
 static inline int hash_add(struct hashtable_t *hash,
 			   hashdata_compare_cb compare,
 			   hashdata_choose_cb choose,
 			   const void *data, struct hlist_node *data_node)
 {
-	int index;
+	int index, ret = -1;
 	struct hlist_head *head;
 	struct hlist_node *node;
 	spinlock_t *list_lock; /* spinlock to protect write access */
 
 	if (!hash)
-		goto err;
+		goto out;
 
 	index = choose(data, hash->size);
 	head = &hash->table[index];
@@ -99,6 +110,7 @@ static inline int hash_add(struct hashtable_t *hash,
 		if (!compare(node, data))
 			continue;
 
+		ret = 1;
 		goto err_unlock;
 	}
 	rcu_read_unlock();
@@ -108,12 +120,13 @@ static inline int hash_add(struct hashtable_t *hash,
 	hlist_add_head_rcu(data_node, head);
 	spin_unlock_bh(list_lock);
 
-	return 0;
+	ret = 0;
+	goto out;
 
 err_unlock:
 	rcu_read_unlock();
-err:
-	return -1;
+out:
+	return ret;
 }
 
 /* removes data from hash, if found. returns pointer do data on success, so you
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index f3c3f62..d448018 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -252,7 +252,7 @@ struct orig_node *get_orig_node(struct bat_priv *bat_priv, const uint8_t *addr)
 
 	hash_added = hash_add(bat_priv->orig_hash, compare_orig,
 			      choose_orig, orig_node, &orig_node->hash_entry);
-	if (hash_added < 0)
+	if (hash_added != 0)
 		goto free_bcast_own_sum;
 
 	return orig_node;
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 8a1b985..8b75cc5 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -465,7 +465,7 @@ static struct vis_info *add_packet(struct bat_priv *bat_priv,
 	/* try to add it */
 	hash_added = hash_add(bat_priv->vis_hash, vis_info_cmp, vis_info_choose,
 			      info, &info->hash_entry);
-	if (hash_added < 0) {
+	if (hash_added != 0) {
 		/* did not work (for some reason) */
 		kref_put(&info->refcount, free_info);
 		info = NULL;
@@ -920,7 +920,7 @@ int vis_init(struct bat_priv *bat_priv)
 	hash_added = hash_add(bat_priv->vis_hash, vis_info_cmp, vis_info_choose,
 			      bat_priv->my_vis_info,
 			      &bat_priv->my_vis_info->hash_entry);
-	if (hash_added < 0) {
+	if (hash_added != 0) {
 		pr_err("Can't add own vis packet into hash\n");
 		/* not in hash, need to remove it manually. */
 		kref_put(&bat_priv->my_vis_info->refcount, free_info);
-- 
1.7.5.3

From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 1/4] batman-adv: prefer kmalloc_array to kmalloc when possible
Date: Tue,  5 Aug 2014 09:36:25 +0200
Message-ID: <1407224188-28626-2-git-send-email-antonio@meshcoding.com>
References: <1407224188-28626-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@meshcoding.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:25323 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753748AbaHEHhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 03:37:16 -0400
In-Reply-To: <1407224188-28626-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported by checkpatch with the following warning:
WARNING: Prefer kmalloc_array over kmalloc with multiply

Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/bat_iv_ogm.c            | 13 +++++++------
 net/batman-adv/distributed-arp-table.c |  3 ++-
 net/batman-adv/hash.c                  |  6 +++---
 3 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index f04224c..1e80539 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -108,14 +108,15 @@ static int batadv_iv_ogm_orig_add_if(struct batadv_orig_node *orig_node,
 				     int max_if_num)
 {
 	void *data_ptr;
-	size_t data_size, old_size;
+	size_t old_size;
 	int ret = -ENOMEM;
 
 	spin_lock_bh(&orig_node->bat_iv.ogm_cnt_lock);
 
-	data_size = max_if_num * sizeof(unsigned long) * BATADV_NUM_WORDS;
 	old_size = (max_if_num - 1) * sizeof(unsigned long) * BATADV_NUM_WORDS;
-	data_ptr = kmalloc(data_size, GFP_ATOMIC);
+	data_ptr = kmalloc_array(max_if_num,
+				 BATADV_NUM_WORDS * sizeof(unsigned long),
+				 GFP_ATOMIC);
 	if (!data_ptr)
 		goto unlock;
 
@@ -123,7 +124,7 @@ static int batadv_iv_ogm_orig_add_if(struct batadv_orig_node *orig_node,
 	kfree(orig_node->bat_iv.bcast_own);
 	orig_node->bat_iv.bcast_own = data_ptr;
 
-	data_ptr = kmalloc(max_if_num * sizeof(uint8_t), GFP_ATOMIC);
+	data_ptr = kmalloc_array(max_if_num, sizeof(uint8_t), GFP_ATOMIC);
 	if (!data_ptr) {
 		kfree(orig_node->bat_iv.bcast_own);
 		goto unlock;
@@ -164,7 +165,7 @@ static int batadv_iv_ogm_orig_del_if(struct batadv_orig_node *orig_node,
 		goto free_bcast_own;
 
 	chunk_size = sizeof(unsigned long) * BATADV_NUM_WORDS;
-	data_ptr = kmalloc(max_if_num * chunk_size, GFP_ATOMIC);
+	data_ptr = kmalloc_array(max_if_num, chunk_size, GFP_ATOMIC);
 	if (!data_ptr)
 		goto unlock;
 
@@ -183,7 +184,7 @@ free_bcast_own:
 	if (max_if_num == 0)
 		goto free_own_sum;
 
-	data_ptr = kmalloc(max_if_num * sizeof(uint8_t), GFP_ATOMIC);
+	data_ptr = kmalloc_array(max_if_num, sizeof(uint8_t), GFP_ATOMIC);
 	if (!data_ptr) {
 		kfree(orig_node->bat_iv.bcast_own);
 		goto unlock;
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index f2c066b..b598111 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -537,7 +537,8 @@ batadv_dat_select_candidates(struct batadv_priv *bat_priv, __be32 ip_dst)
 	if (!bat_priv->orig_hash)
 		return NULL;
 
-	res = kmalloc(BATADV_DAT_CANDIDATES_NUM * sizeof(*res), GFP_ATOMIC);
+	res = kmalloc_array(BATADV_DAT_CANDIDATES_NUM, sizeof(*res),
+			    GFP_ATOMIC);
 	if (!res)
 		return NULL;
 
diff --git a/net/batman-adv/hash.c b/net/batman-adv/hash.c
index 63bdf7e..7c1c630 100644
--- a/net/batman-adv/hash.c
+++ b/net/batman-adv/hash.c
@@ -46,12 +46,12 @@ struct batadv_hashtable *batadv_hash_new(uint32_t size)
 	if (!hash)
 		return NULL;
 
-	hash->table = kmalloc(sizeof(*hash->table) * size, GFP_ATOMIC);
+	hash->table = kmalloc_array(size, sizeof(*hash->table), GFP_ATOMIC);
 	if (!hash->table)
 		goto free_hash;
 
-	hash->list_locks = kmalloc(sizeof(*hash->list_locks) * size,
-				   GFP_ATOMIC);
+	hash->list_locks = kmalloc_array(size, sizeof(*hash->list_locks),
+					 GFP_ATOMIC);
 	if (!hash->list_locks)
 		goto free_table;
 
-- 
1.8.5.5

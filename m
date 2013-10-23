From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 08/16] batman-adv: provide orig_node routing API
Date: Wed, 23 Oct 2013 18:04:55 +0200
Message-ID: <1382544303-2694-9-git-send-email-antonio@meshcoding.com>
References: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:2975 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752313Ab3JWQFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 12:05:53 -0400
In-Reply-To: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

Some operations executed on an orig_node depends on the
current routing algorithm being used. To easily make this
mechanism routing algorithm agnostic add a orig_node
specific API that each algorithm can populate with its own
routines.

Such routines are then invoked by the code when needed,
without knowing which routing algorithm is currently in use

With this patch 3 API functions are added:
- orig_free (to free routing depending internal structs)
- orig_add_if (to change the inner state of an orig_node
  when a new hard interface is added)
- orig_del_if (to change the inner state of an orig_node
  when an hard interface is removed)

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/bat_iv_ogm.c | 126 ++++++++++++++++++++++++++++++++++++++++++++
 net/batman-adv/originator.c | 102 +++++------------------------------
 net/batman-adv/types.h      |  11 ++++
 3 files changed, 151 insertions(+), 88 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 7cdc394..a2b480a 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -88,6 +88,129 @@ static uint8_t batadv_ring_buffer_avg(const uint8_t lq_recv[])
 }
 
 /**
+ * batadv_iv_ogm_orig_free - free the private resources allocated for this
+ *  orig_node
+ * @orig_node: the orig_node for which the resources have to be free'd
+ */
+static void batadv_iv_ogm_orig_free(struct batadv_orig_node *orig_node)
+{
+	kfree(orig_node->bat_iv.bcast_own);
+	kfree(orig_node->bat_iv.bcast_own_sum);
+}
+
+/**
+ * batadv_iv_ogm_orig_add_if - change the private structures of the orig_node to
+ *  include the new hard-interface
+ * @orig_node: the orig_node that has to be changed
+ * @max_if_num: the current amount of interfaces
+ *
+ * Returns 0 on success, a negative error code otherwise.
+ */
+static int batadv_iv_ogm_orig_add_if(struct batadv_orig_node *orig_node,
+				     int max_if_num)
+{
+	void *data_ptr;
+	size_t data_size, old_size;
+	int ret = -ENOMEM;
+
+	spin_lock_bh(&orig_node->bat_iv.ogm_cnt_lock);
+
+	data_size = max_if_num * sizeof(unsigned long) * BATADV_NUM_WORDS;
+	old_size = (max_if_num - 1) * sizeof(unsigned long) * BATADV_NUM_WORDS;
+	data_ptr = kmalloc(data_size, GFP_ATOMIC);
+	if (!data_ptr)
+		goto unlock;
+
+	memcpy(data_ptr, orig_node->bat_iv.bcast_own, old_size);
+	kfree(orig_node->bat_iv.bcast_own);
+	orig_node->bat_iv.bcast_own = data_ptr;
+
+	data_ptr = kmalloc(max_if_num * sizeof(uint8_t), GFP_ATOMIC);
+	if (!data_ptr) {
+		kfree(orig_node->bat_iv.bcast_own);
+		goto unlock;
+	}
+
+	memcpy(data_ptr, orig_node->bat_iv.bcast_own_sum,
+	       (max_if_num - 1) * sizeof(uint8_t));
+	kfree(orig_node->bat_iv.bcast_own_sum);
+	orig_node->bat_iv.bcast_own_sum = data_ptr;
+
+	ret = 0;
+
+unlock:
+	spin_unlock_bh(&orig_node->bat_iv.ogm_cnt_lock);
+
+	return ret;
+}
+
+/**
+ * batadv_iv_ogm_orig_del_if - change the private structures of the orig_node to
+ *  exclude the removed interface
+ * @orig_node: the orig_node that has to be changed
+ * @max_if_num: the current amount of interfaces
+ * @del_if_num: the index of the interface being removed
+ *
+ * Returns 0 on success, a negative error code otherwise.
+ */
+static int batadv_iv_ogm_orig_del_if(struct batadv_orig_node *orig_node,
+				     int max_if_num, int del_if_num)
+{
+	int chunk_size,  ret = -ENOMEM, if_offset;
+	void *data_ptr = NULL;
+
+	spin_lock_bh(&orig_node->bat_iv.ogm_cnt_lock);
+
+	/* last interface was removed */
+	if (max_if_num == 0)
+		goto free_bcast_own;
+
+	chunk_size = sizeof(unsigned long) * BATADV_NUM_WORDS;
+	data_ptr = kmalloc(max_if_num * chunk_size, GFP_ATOMIC);
+	if (!data_ptr)
+		goto unlock;
+
+	/* copy first part */
+	memcpy(data_ptr, orig_node->bat_iv.bcast_own, del_if_num * chunk_size);
+
+	/* copy second part */
+	memcpy((char *)data_ptr + del_if_num * chunk_size,
+	       orig_node->bat_iv.bcast_own + ((del_if_num + 1) * chunk_size),
+	       (max_if_num - del_if_num) * chunk_size);
+
+free_bcast_own:
+	kfree(orig_node->bat_iv.bcast_own);
+	orig_node->bat_iv.bcast_own = data_ptr;
+
+	if (max_if_num == 0)
+		goto free_own_sum;
+
+	data_ptr = kmalloc(max_if_num * sizeof(uint8_t), GFP_ATOMIC);
+	if (!data_ptr) {
+		kfree(orig_node->bat_iv.bcast_own);
+		goto unlock;
+	}
+
+	memcpy(data_ptr, orig_node->bat_iv.bcast_own_sum,
+	       del_if_num * sizeof(uint8_t));
+
+	if_offset = (del_if_num + 1) * sizeof(uint8_t);
+	memcpy((char *)data_ptr + del_if_num * sizeof(uint8_t),
+	       orig_node->bat_iv.bcast_own_sum + if_offset,
+	       (max_if_num - del_if_num) * sizeof(uint8_t));
+
+free_own_sum:
+	kfree(orig_node->bat_iv.bcast_own_sum);
+	orig_node->bat_iv.bcast_own_sum = data_ptr;
+
+	ret = 0;
+unlock:
+	spin_unlock_bh(&orig_node->bat_iv.ogm_cnt_lock);
+
+	return ret;
+}
+
+/**
  * batadv_iv_ogm_orig_get - retrieve or create (if does not exist) an originator
  * @bat_priv: the bat priv with all the soft interface information
  * @addr: mac address of the originator
@@ -1522,6 +1645,9 @@ static struct batadv_algo_ops batadv_batman_iv __read_mostly = {
 	.bat_neigh_cmp = batadv_iv_ogm_neigh_cmp,
 	.bat_neigh_is_equiv_or_better = batadv_iv_ogm_neigh_is_eob,
 	.bat_orig_print = batadv_iv_ogm_orig_print,
+	.bat_orig_free = batadv_iv_ogm_orig_free,
+	.bat_orig_add_if = batadv_iv_ogm_orig_add_if,
+	.bat_orig_del_if = batadv_iv_ogm_orig_del_if,
 };
 
 int __init batadv_iv_init(void)
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 9cee053..8ab1434 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -241,9 +241,10 @@ static void batadv_orig_node_free_rcu(struct rcu_head *rcu)
 	batadv_tt_global_del_orig(orig_node->bat_priv, orig_node, -1,
 				  "originator timed out");
 
+	if (orig_node->bat_priv->bat_algo_ops->bat_orig_free)
+		orig_node->bat_priv->bat_algo_ops->bat_orig_free(orig_node);
+
 	kfree(orig_node->tt_buff);
-	kfree(orig_node->bat_iv.bcast_own);
-	kfree(orig_node->bat_iv.bcast_own_sum);
 	kfree(orig_node);
 }
 
@@ -538,38 +539,11 @@ int batadv_orig_seq_print_text(struct seq_file *seq, void *offset)
 	return 0;
 }
 
-static int batadv_orig_node_add_if(struct batadv_orig_node *orig_node,
-				   int max_if_num)
-{
-	void *data_ptr;
-	size_t data_size, old_size;
-
-	data_size = max_if_num * sizeof(unsigned long) * BATADV_NUM_WORDS;
-	old_size = (max_if_num - 1) * sizeof(unsigned long) * BATADV_NUM_WORDS;
-	data_ptr = kmalloc(data_size, GFP_ATOMIC);
-	if (!data_ptr)
-		return -ENOMEM;
-
-	memcpy(data_ptr, orig_node->bat_iv.bcast_own, old_size);
-	kfree(orig_node->bat_iv.bcast_own);
-	orig_node->bat_iv.bcast_own = data_ptr;
-
-	data_ptr = kmalloc(max_if_num * sizeof(uint8_t), GFP_ATOMIC);
-	if (!data_ptr)
-		return -ENOMEM;
-
-	memcpy(data_ptr, orig_node->bat_iv.bcast_own_sum,
-	       (max_if_num - 1) * sizeof(uint8_t));
-	kfree(orig_node->bat_iv.bcast_own_sum);
-	orig_node->bat_iv.bcast_own_sum = data_ptr;
-
-	return 0;
-}
-
 int batadv_orig_hash_add_if(struct batadv_hard_iface *hard_iface,
 			    int max_if_num)
 {
 	struct batadv_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
+	struct batadv_algo_ops *bao = bat_priv->bat_algo_ops;
 	struct batadv_hashtable *hash = bat_priv->orig_hash;
 	struct hlist_head *head;
 	struct batadv_orig_node *orig_node;
@@ -584,10 +558,10 @@ int batadv_orig_hash_add_if(struct batadv_hard_iface *hard_iface,
 
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(orig_node, head, hash_entry) {
-			spin_lock_bh(&orig_node->bat_iv.ogm_cnt_lock);
-			ret = batadv_orig_node_add_if(orig_node, max_if_num);
-			spin_unlock_bh(&orig_node->bat_iv.ogm_cnt_lock);
-
+			ret = 0;
+			if (bao->bat_orig_add_if)
+				ret = bao->bat_orig_add_if(orig_node,
+							   max_if_num);
 			if (ret == -ENOMEM)
 				goto err;
 		}
@@ -601,55 +575,6 @@ err:
 	return -ENOMEM;
 }
 
-static int batadv_orig_node_del_if(struct batadv_orig_node *orig_node,
-				   int max_if_num, int del_if_num)
-{
-	int chunk_size, if_offset;
-	void *data_ptr = NULL;
-
-	/* last interface was removed */
-	if (max_if_num == 0)
-		goto free_bcast_own;
-
-	chunk_size = sizeof(unsigned long) * BATADV_NUM_WORDS;
-	data_ptr = kmalloc(max_if_num * chunk_size, GFP_ATOMIC);
-	if (!data_ptr)
-		return -ENOMEM;
-
-	/* copy first part */
-	memcpy(data_ptr, orig_node->bat_iv.bcast_own, del_if_num * chunk_size);
-
-	/* copy second part */
-	memcpy((char *)data_ptr + del_if_num * chunk_size,
-	       orig_node->bat_iv.bcast_own + ((del_if_num + 1) * chunk_size),
-	       (max_if_num - del_if_num) * chunk_size);
-
-free_bcast_own:
-	kfree(orig_node->bat_iv.bcast_own);
-	orig_node->bat_iv.bcast_own = data_ptr;
-
-	if (max_if_num == 0)
-		goto free_own_sum;
-
-	data_ptr = kmalloc(max_if_num * sizeof(uint8_t), GFP_ATOMIC);
-	if (!data_ptr)
-		return -ENOMEM;
-
-	memcpy(data_ptr, orig_node->bat_iv.bcast_own_sum,
-	       del_if_num * sizeof(uint8_t));
-
-	if_offset = (del_if_num + 1) * sizeof(uint8_t);
-	memcpy((char *)data_ptr + del_if_num * sizeof(uint8_t),
-	       orig_node->bat_iv.bcast_own_sum + if_offset,
-	       (max_if_num - del_if_num) * sizeof(uint8_t));
-
-free_own_sum:
-	kfree(orig_node->bat_iv.bcast_own_sum);
-	orig_node->bat_iv.bcast_own_sum = data_ptr;
-
-	return 0;
-}
-
 int batadv_orig_hash_del_if(struct batadv_hard_iface *hard_iface,
 			    int max_if_num)
 {
@@ -658,6 +583,7 @@ int batadv_orig_hash_del_if(struct batadv_hard_iface *hard_iface,
 	struct hlist_head *head;
 	struct batadv_hard_iface *hard_iface_tmp;
 	struct batadv_orig_node *orig_node;
+	struct batadv_algo_ops *bao = bat_priv->bat_algo_ops;
 	uint32_t i;
 	int ret;
 
@@ -669,11 +595,11 @@ int batadv_orig_hash_del_if(struct batadv_hard_iface *hard_iface,
 
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(orig_node, head, hash_entry) {
-			spin_lock_bh(&orig_node->bat_iv.ogm_cnt_lock);
-			ret = batadv_orig_node_del_if(orig_node, max_if_num,
-						      hard_iface->if_num);
-			spin_unlock_bh(&orig_node->bat_iv.ogm_cnt_lock);
-
+			ret = 0;
+			if (bao->bat_orig_del_if)
+				ret = bao->bat_orig_del_if(orig_node,
+							   max_if_num,
+							   hard_iface->if_num);
 			if (ret == -ENOMEM)
 				goto err;
 		}
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index d0e64d2..672a813 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -996,6 +996,12 @@ struct batadv_forw_packet {
  * @bat_neigh_is_equiv_or_better: check if neigh1 is equally good or
  *  better than neigh2 from the metric prospective
  * @bat_orig_print: print the originator table (optional)
+ * @bat_orig_free: free the resources allocated by the routing algorithm for an
+ *  orig_node object
+ * @bat_orig_add_if: ask the routing algorithm to apply the needed changes to
+ *  the orig_node due to a new hard-interface being added into the mesh
+ * @bat_orig_del_if: ask the routing algorithm to apply the needed changes to
+ *  the orig_node due to an hard-interface being removed from the mesh
  */
 struct batadv_algo_ops {
 	struct hlist_node list;
@@ -1012,6 +1018,11 @@ struct batadv_algo_ops {
 					     struct batadv_neigh_node *neigh2);
 	/* orig_node handling API */
 	void (*bat_orig_print)(struct batadv_priv *priv, struct seq_file *seq);
+	void (*bat_orig_free)(struct batadv_orig_node *orig_node);
+	int (*bat_orig_add_if)(struct batadv_orig_node *orig_node,
+			       int max_if_num);
+	int (*bat_orig_del_if)(struct batadv_orig_node *orig_node,
+			       int max_if_num, int del_if_num);
 };
 
 /**
-- 
1.8.4

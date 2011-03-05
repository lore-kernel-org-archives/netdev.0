From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 04/28] batman-adv: protect neighbor list with
	rcu locks
Date: Sat,  5 Mar 2011 13:28:18 +0100
Message-ID: <1299328122-21468-5-git-send-email-sven@narfation.org>
References: <1299328122-21468-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1299328122-21468-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>

Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
---
 net/batman-adv/originator.c |   35 ++++++++++++++++++++++++++++-------
 net/batman-adv/routing.c    |   41 +++++++++++++++++++++++++++--------------
 net/batman-adv/types.h      |    2 ++
 3 files changed, 57 insertions(+), 21 deletions(-)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 68b04e7..6cb9af3 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -67,6 +67,14 @@ void neigh_node_free_ref(struct kref *refcount)
 	kfree(neigh_node);
 }
 
+static void neigh_node_free_rcu(struct rcu_head *rcu)
+{
+	struct neigh_node *neigh_node;
+
+	neigh_node = container_of(rcu, struct neigh_node, rcu);
+	kref_put(&neigh_node->refcount, neigh_node_free_ref);
+}
+
 struct neigh_node *create_neighbor(struct orig_node *orig_node,
 				   struct orig_node *orig_neigh_node,
 				   uint8_t *neigh,
@@ -89,7 +97,9 @@ struct neigh_node *create_neighbor(struct orig_node *orig_node,
 	neigh_node->if_incoming = if_incoming;
 	kref_init(&neigh_node->refcount);
 
-	hlist_add_head(&neigh_node->list, &orig_node->neigh_list);
+	spin_lock_bh(&orig_node->neigh_list_lock);
+	hlist_add_head_rcu(&neigh_node->list, &orig_node->neigh_list);
+	spin_unlock_bh(&orig_node->neigh_list_lock);
 	return neigh_node;
 }
 
@@ -100,13 +110,17 @@ static void free_orig_node(void *data, void *arg)
 	struct orig_node *orig_node = (struct orig_node *)data;
 	struct bat_priv *bat_priv = (struct bat_priv *)arg;
 
+	spin_lock_bh(&orig_node->neigh_list_lock);
+
 	/* for all neighbors towards this originator ... */
 	hlist_for_each_entry_safe(neigh_node, node, node_tmp,
 				  &orig_node->neigh_list, list) {
-		hlist_del(&neigh_node->list);
-		kref_put(&neigh_node->refcount, neigh_node_free_ref);
+		hlist_del_rcu(&neigh_node->list);
+		call_rcu(&neigh_node->rcu, neigh_node_free_rcu);
 	}
 
+	spin_unlock_bh(&orig_node->neigh_list_lock);
+
 	frag_list_free(&orig_node->frag_list);
 	hna_global_del_orig(bat_priv, orig_node, "originator timed out");
 
@@ -151,6 +165,7 @@ struct orig_node *get_orig_node(struct bat_priv *bat_priv, uint8_t *addr)
 		return NULL;
 
 	INIT_HLIST_HEAD(&orig_node->neigh_list);
+	spin_lock_init(&orig_node->neigh_list_lock);
 
 	memcpy(orig_node->orig, addr, ETH_ALEN);
 	orig_node->router = NULL;
@@ -200,6 +215,8 @@ static bool purge_orig_neighbors(struct bat_priv *bat_priv,
 
 	*best_neigh_node = NULL;
 
+	spin_lock_bh(&orig_node->neigh_list_lock);
+
 	/* for all neighbors towards this originator ... */
 	hlist_for_each_entry_safe(neigh_node, node, node_tmp,
 				  &orig_node->neigh_list, list) {
@@ -225,14 +242,16 @@ static bool purge_orig_neighbors(struct bat_priv *bat_priv,
 
 			neigh_purged = true;
 
-			hlist_del(&neigh_node->list);
-			kref_put(&neigh_node->refcount, neigh_node_free_ref);
+			hlist_del_rcu(&neigh_node->list);
+			call_rcu(&neigh_node->rcu, neigh_node_free_rcu);
 		} else {
 			if ((!*best_neigh_node) ||
 			    (neigh_node->tq_avg > (*best_neigh_node)->tq_avg))
 				*best_neigh_node = neigh_node;
 		}
 	}
+
+	spin_unlock_bh(&orig_node->neigh_list_lock);
 	return neigh_purged;
 }
 
@@ -384,11 +403,13 @@ int orig_seq_print_text(struct seq_file *seq, void *offset)
 				   neigh_node->addr,
 				   neigh_node->if_incoming->net_dev->name);
 
-			hlist_for_each_entry(neigh_node, node,
-					     &orig_node->neigh_list, list) {
+			rcu_read_lock();
+			hlist_for_each_entry_rcu(neigh_node, node,
+						 &orig_node->neigh_list, list) {
 				seq_printf(seq, " %pM (%3i)", neigh_node->addr,
 						neigh_node->tq_avg);
 			}
+			rcu_read_unlock();
 
 			seq_printf(seq, "\n");
 			batman_count++;
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index e8379ba..97f3216 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -153,14 +153,16 @@ static int is_bidirectional_neigh(struct orig_node *orig_node,
 	unsigned char total_count;
 
 	if (orig_node == orig_neigh_node) {
-		hlist_for_each_entry(tmp_neigh_node, node,
-				     &orig_node->neigh_list, list) {
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(tmp_neigh_node, node,
+					 &orig_node->neigh_list, list) {
 
 			if (compare_orig(tmp_neigh_node->addr,
 					 orig_neigh_node->orig) &&
 			    (tmp_neigh_node->if_incoming == if_incoming))
 				neigh_node = tmp_neigh_node;
 		}
+		rcu_read_unlock();
 
 		if (!neigh_node)
 			neigh_node = create_neighbor(orig_node,
@@ -174,14 +176,16 @@ static int is_bidirectional_neigh(struct orig_node *orig_node,
 		neigh_node->last_valid = jiffies;
 	} else {
 		/* find packet count of corresponding one hop neighbor */
-		hlist_for_each_entry(tmp_neigh_node, node,
-				     &orig_neigh_node->neigh_list, list) {
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(tmp_neigh_node, node,
+					 &orig_neigh_node->neigh_list, list) {
 
 			if (compare_orig(tmp_neigh_node->addr,
 					 orig_neigh_node->orig) &&
 			    (tmp_neigh_node->if_incoming == if_incoming))
 				neigh_node = tmp_neigh_node;
 		}
+		rcu_read_unlock();
 
 		if (!neigh_node)
 			neigh_node = create_neighbor(orig_neigh_node,
@@ -266,8 +270,9 @@ static void update_orig(struct bat_priv *bat_priv,
 	bat_dbg(DBG_BATMAN, bat_priv, "update_originator(): "
 		"Searching and updating originator entry of received packet\n");
 
-	hlist_for_each_entry(tmp_neigh_node, node,
-			     &orig_node->neigh_list, list) {
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(tmp_neigh_node, node,
+				 &orig_node->neigh_list, list) {
 		if (compare_orig(tmp_neigh_node->addr, ethhdr->h_source) &&
 		    (tmp_neigh_node->if_incoming == if_incoming)) {
 			neigh_node = tmp_neigh_node;
@@ -282,6 +287,7 @@ static void update_orig(struct bat_priv *bat_priv,
 		tmp_neigh_node->tq_avg =
 			ring_buffer_avg(tmp_neigh_node->tq_recv);
 	}
+	rcu_read_unlock();
 
 	if (!neigh_node) {
 		struct orig_node *orig_tmp;
@@ -410,8 +416,9 @@ static char count_real_packets(struct ethhdr *ethhdr,
 			     &orig_node->batman_seqno_reset))
 		return -1;
 
-	hlist_for_each_entry(tmp_neigh_node, node,
-			     &orig_node->neigh_list, list) {
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(tmp_neigh_node, node,
+				 &orig_node->neigh_list, list) {
 
 		is_duplicate |= get_bit_status(tmp_neigh_node->real_bits,
 					       orig_node->last_real_seqno,
@@ -431,6 +438,7 @@ static char count_real_packets(struct ethhdr *ethhdr,
 		tmp_neigh_node->real_packet_count =
 			bit_packet_count(tmp_neigh_node->real_bits);
 	}
+	rcu_read_unlock();
 
 	if (need_update) {
 		bat_dbg(DBG_BATMAN, bat_priv,
@@ -481,15 +489,19 @@ void update_bonding_candidates(struct orig_node *orig_node)
 	 * as "bonding partner" */
 
 	/* first, zero the list */
-	hlist_for_each_entry(tmp_neigh_node, node,
-			     &orig_node->neigh_list, list) {
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(tmp_neigh_node, node,
+				 &orig_node->neigh_list, list) {
 		tmp_neigh_node->next_bond_candidate = NULL;
 	}
+	rcu_read_unlock();
 
 	first_candidate = NULL;
 	last_candidate = NULL;
-	hlist_for_each_entry(tmp_neigh_node, node,
-			     &orig_node->neigh_list, list) {
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(tmp_neigh_node, node,
+				 &orig_node->neigh_list, list) {
 
 		/* only consider if it has the same primary address ...  */
 		if (memcmp(orig_node->orig,
@@ -506,8 +518,8 @@ void update_bonding_candidates(struct orig_node *orig_node)
 		 * select this candidate because of possible interference. */
 
 		interference_candidate = 0;
-		hlist_for_each_entry(tmp_neigh_node2, node2,
-				     &orig_node->neigh_list, list) {
+		hlist_for_each_entry_rcu(tmp_neigh_node2, node2,
+					 &orig_node->neigh_list, list) {
 
 			if (tmp_neigh_node2 == tmp_neigh_node)
 				continue;
@@ -541,6 +553,7 @@ void update_bonding_candidates(struct orig_node *orig_node)
 
 		candidates++;
 	}
+	rcu_read_unlock();
 
 	if (candidates > 0) {
 		first_candidate->next_bond_candidate = last_candidate;
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 779c5c3..d4fa727 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -85,6 +85,7 @@ struct orig_node {
 	uint32_t last_bcast_seqno;
 	struct hlist_head neigh_list;
 	struct list_head frag_list;
+	spinlock_t neigh_list_lock; /* protects neighbor list */
 	unsigned long last_frag_packet;
 	struct {
 		uint8_t candidates;
@@ -116,6 +117,7 @@ struct neigh_node {
 	unsigned long last_valid;
 	unsigned long real_bits[NUM_WORDS];
 	struct kref refcount;
+	struct rcu_head rcu;
 	struct orig_node *orig_node;
 	struct batman_if *if_incoming;
 };
-- 
1.7.2.3

From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 03/28] batman-adv: convert neighbor list to
	hlist
Date: Sat,  5 Mar 2011 13:28:17 +0100
Message-ID: <1299328122-21468-4-git-send-email-sven@narfation.org>
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
 net/batman-adv/originator.c |   30 +++++++++++++++---------------
 net/batman-adv/routing.c    |   29 ++++++++++++++++++-----------
 net/batman-adv/types.h      |    4 ++--
 3 files changed, 35 insertions(+), 28 deletions(-)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index b1b1773..68b04e7 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -82,29 +82,28 @@ struct neigh_node *create_neighbor(struct orig_node *orig_node,
 	if (!neigh_node)
 		return NULL;
 
-	INIT_LIST_HEAD(&neigh_node->list);
+	INIT_HLIST_NODE(&neigh_node->list);
 
 	memcpy(neigh_node->addr, neigh, ETH_ALEN);
 	neigh_node->orig_node = orig_neigh_node;
 	neigh_node->if_incoming = if_incoming;
 	kref_init(&neigh_node->refcount);
 
-	list_add_tail(&neigh_node->list, &orig_node->neigh_list);
+	hlist_add_head(&neigh_node->list, &orig_node->neigh_list);
 	return neigh_node;
 }
 
 static void free_orig_node(void *data, void *arg)
 {
-	struct list_head *list_pos, *list_pos_tmp;
+	struct hlist_node *node, *node_tmp;
 	struct neigh_node *neigh_node;
 	struct orig_node *orig_node = (struct orig_node *)data;
 	struct bat_priv *bat_priv = (struct bat_priv *)arg;
 
 	/* for all neighbors towards this originator ... */
-	list_for_each_safe(list_pos, list_pos_tmp, &orig_node->neigh_list) {
-		neigh_node = list_entry(list_pos, struct neigh_node, list);
-
-		list_del(list_pos);
+	hlist_for_each_entry_safe(neigh_node, node, node_tmp,
+				  &orig_node->neigh_list, list) {
+		hlist_del(&neigh_node->list);
 		kref_put(&neigh_node->refcount, neigh_node_free_ref);
 	}
 
@@ -151,7 +150,7 @@ struct orig_node *get_orig_node(struct bat_priv *bat_priv, uint8_t *addr)
 	if (!orig_node)
 		return NULL;
 
-	INIT_LIST_HEAD(&orig_node->neigh_list);
+	INIT_HLIST_HEAD(&orig_node->neigh_list);
 
 	memcpy(orig_node->orig, addr, ETH_ALEN);
 	orig_node->router = NULL;
@@ -195,15 +194,15 @@ static bool purge_orig_neighbors(struct bat_priv *bat_priv,
 				 struct orig_node *orig_node,
 				 struct neigh_node **best_neigh_node)
 {
-	struct list_head *list_pos, *list_pos_tmp;
+	struct hlist_node *node, *node_tmp;
 	struct neigh_node *neigh_node;
 	bool neigh_purged = false;
 
 	*best_neigh_node = NULL;
 
 	/* for all neighbors towards this originator ... */
-	list_for_each_safe(list_pos, list_pos_tmp, &orig_node->neigh_list) {
-		neigh_node = list_entry(list_pos, struct neigh_node, list);
+	hlist_for_each_entry_safe(neigh_node, node, node_tmp,
+				  &orig_node->neigh_list, list) {
 
 		if ((time_after(jiffies,
 			neigh_node->last_valid + PURGE_TIMEOUT * HZ)) ||
@@ -225,7 +224,8 @@ static bool purge_orig_neighbors(struct bat_priv *bat_priv,
 					(neigh_node->last_valid / HZ));
 
 			neigh_purged = true;
-			list_del(list_pos);
+
+			hlist_del(&neigh_node->list);
 			kref_put(&neigh_node->refcount, neigh_node_free_ref);
 		} else {
 			if ((!*best_neigh_node) ||
@@ -328,7 +328,7 @@ int orig_seq_print_text(struct seq_file *seq, void *offset)
 	struct net_device *net_dev = (struct net_device *)seq->private;
 	struct bat_priv *bat_priv = netdev_priv(net_dev);
 	struct hashtable_t *hash = bat_priv->orig_hash;
-	struct hlist_node *walk;
+	struct hlist_node *walk, *node;
 	struct hlist_head *head;
 	struct element_t *bucket;
 	struct orig_node *orig_node;
@@ -384,8 +384,8 @@ int orig_seq_print_text(struct seq_file *seq, void *offset)
 				   neigh_node->addr,
 				   neigh_node->if_incoming->net_dev->name);
 
-			list_for_each_entry(neigh_node, &orig_node->neigh_list,
-					    list) {
+			hlist_for_each_entry(neigh_node, node,
+					     &orig_node->neigh_list, list) {
 				seq_printf(seq, " %pM (%3i)", neigh_node->addr,
 						neigh_node->tq_avg);
 			}
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 36351d3..e8379ba 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -149,12 +149,12 @@ static int is_bidirectional_neigh(struct orig_node *orig_node,
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct neigh_node *neigh_node = NULL, *tmp_neigh_node = NULL;
+	struct hlist_node *node;
 	unsigned char total_count;
 
 	if (orig_node == orig_neigh_node) {
-		list_for_each_entry(tmp_neigh_node,
-				    &orig_node->neigh_list,
-				    list) {
+		hlist_for_each_entry(tmp_neigh_node, node,
+				     &orig_node->neigh_list, list) {
 
 			if (compare_orig(tmp_neigh_node->addr,
 					 orig_neigh_node->orig) &&
@@ -174,8 +174,8 @@ static int is_bidirectional_neigh(struct orig_node *orig_node,
 		neigh_node->last_valid = jiffies;
 	} else {
 		/* find packet count of corresponding one hop neighbor */
-		list_for_each_entry(tmp_neigh_node,
-				    &orig_neigh_node->neigh_list, list) {
+		hlist_for_each_entry(tmp_neigh_node, node,
+				     &orig_neigh_node->neigh_list, list) {
 
 			if (compare_orig(tmp_neigh_node->addr,
 					 orig_neigh_node->orig) &&
@@ -260,12 +260,14 @@ static void update_orig(struct bat_priv *bat_priv,
 			char is_duplicate)
 {
 	struct neigh_node *neigh_node = NULL, *tmp_neigh_node = NULL;
+	struct hlist_node *node;
 	int tmp_hna_buff_len;
 
 	bat_dbg(DBG_BATMAN, bat_priv, "update_originator(): "
 		"Searching and updating originator entry of received packet\n");
 
-	list_for_each_entry(tmp_neigh_node, &orig_node->neigh_list, list) {
+	hlist_for_each_entry(tmp_neigh_node, node,
+			     &orig_node->neigh_list, list) {
 		if (compare_orig(tmp_neigh_node->addr, ethhdr->h_source) &&
 		    (tmp_neigh_node->if_incoming == if_incoming)) {
 			neigh_node = tmp_neigh_node;
@@ -391,6 +393,7 @@ static char count_real_packets(struct ethhdr *ethhdr,
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct orig_node *orig_node;
 	struct neigh_node *tmp_neigh_node;
+	struct hlist_node *node;
 	char is_duplicate = 0;
 	int32_t seq_diff;
 	int need_update = 0;
@@ -407,7 +410,8 @@ static char count_real_packets(struct ethhdr *ethhdr,
 			     &orig_node->batman_seqno_reset))
 		return -1;
 
-	list_for_each_entry(tmp_neigh_node, &orig_node->neigh_list, list) {
+	hlist_for_each_entry(tmp_neigh_node, node,
+			     &orig_node->neigh_list, list) {
 
 		is_duplicate |= get_bit_status(tmp_neigh_node->real_bits,
 					       orig_node->last_real_seqno,
@@ -457,6 +461,7 @@ void update_bonding_candidates(struct orig_node *orig_node)
 	int candidates;
 	int interference_candidate;
 	int best_tq;
+	struct hlist_node *node, *node2;
 	struct neigh_node *tmp_neigh_node, *tmp_neigh_node2;
 	struct neigh_node *first_candidate, *last_candidate;
 
@@ -476,13 +481,15 @@ void update_bonding_candidates(struct orig_node *orig_node)
 	 * as "bonding partner" */
 
 	/* first, zero the list */
-	list_for_each_entry(tmp_neigh_node, &orig_node->neigh_list, list) {
+	hlist_for_each_entry(tmp_neigh_node, node,
+			     &orig_node->neigh_list, list) {
 		tmp_neigh_node->next_bond_candidate = NULL;
 	}
 
 	first_candidate = NULL;
 	last_candidate = NULL;
-	list_for_each_entry(tmp_neigh_node, &orig_node->neigh_list, list) {
+	hlist_for_each_entry(tmp_neigh_node, node,
+			     &orig_node->neigh_list, list) {
 
 		/* only consider if it has the same primary address ...  */
 		if (memcmp(orig_node->orig,
@@ -499,8 +506,8 @@ void update_bonding_candidates(struct orig_node *orig_node)
 		 * select this candidate because of possible interference. */
 
 		interference_candidate = 0;
-		list_for_each_entry(tmp_neigh_node2,
-				&orig_node->neigh_list, list) {
+		hlist_for_each_entry(tmp_neigh_node2, node2,
+				     &orig_node->neigh_list, list) {
 
 			if (tmp_neigh_node2 == tmp_neigh_node)
 				continue;
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index f9217d5..779c5c3 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -83,7 +83,7 @@ struct orig_node {
 	uint8_t last_ttl;
 	unsigned long bcast_bits[NUM_WORDS];
 	uint32_t last_bcast_seqno;
-	struct list_head neigh_list;
+	struct hlist_head neigh_list;
 	struct list_head frag_list;
 	unsigned long last_frag_packet;
 	struct {
@@ -105,7 +105,7 @@ struct gw_node {
  *	@last_valid: when last packet via this neighbor was received
  */
 struct neigh_node {
-	struct list_head list;
+	struct hlist_node list;
 	uint8_t addr[ETH_ALEN];
 	uint8_t real_packet_count;
 	uint8_t tq_recv[TQ_GLOBAL_WINDOW_SIZE];
-- 
1.7.2.3

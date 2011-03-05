From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 20/28] batman-adv: separate ethernet comparing calls from hash functions
Date: Sat,  5 Mar 2011 13:28:34 +0100
Message-ID: <1299328122-21468-21-git-send-email-sven@narfation.org>
References: <1299328122-21468-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:36334 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753343Ab1CEMaF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 07:30:05 -0500
In-Reply-To: <1299328122-21468-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Note: The function compare_ether_addr() provided by the Linux kernel
requires aligned memory.

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/hard-interface.c    |    2 +-
 net/batman-adv/main.c              |    2 +-
 net/batman-adv/main.h              |   10 ++++++
 net/batman-adv/routing.c           |   55 +++++++++++++++++------------------
 net/batman-adv/send.c              |    2 +-
 net/batman-adv/soft-interface.c    |    2 +-
 net/batman-adv/translation-table.c |    2 +-
 net/batman-adv/vis.c               |   18 ++++++------
 8 files changed, 51 insertions(+), 42 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 8982485..de9bd36 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -187,7 +187,7 @@ static void check_known_mac_addr(struct net_device *net_dev)
 		if (batman_if->net_dev == net_dev)
 			continue;
 
-		if (!compare_orig(batman_if->net_dev->dev_addr,
+		if (!compare_eth(batman_if->net_dev->dev_addr,
 				  net_dev->dev_addr))
 			continue;
 
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 06d956c..3f977ea 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -161,7 +161,7 @@ int is_my_mac(uint8_t *addr)
 		if (batman_if->if_status != IF_ACTIVE)
 			continue;
 
-		if (compare_orig(batman_if->net_dev->dev_addr, addr)) {
+		if (compare_eth(batman_if->net_dev->dev_addr, addr)) {
 			rcu_read_unlock();
 			return 1;
 		}
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index e235d7b..06b5b99 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -165,4 +165,14 @@ static inline void bat_dbg(char type __always_unused,
 		pr_err("%s: " fmt, _netdev->name, ## arg);		\
 	} while (0)
 
+/**
+ * returns 1 if they are the same ethernet addr
+ *
+ * note: can't use compare_ether_addr() as it requires aligned memory
+ */
+static inline int compare_eth(void *data1, void *data2)
+{
+	return (memcmp(data1, data2, ETH_ALEN) == 0 ? 1 : 0);
+}
+
 #endif /* _NET_BATMAN_ADV_MAIN_H_ */
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index ce68815..b54bf6e 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -163,8 +163,8 @@ static int is_bidirectional_neigh(struct orig_node *orig_node,
 		hlist_for_each_entry_rcu(tmp_neigh_node, node,
 					 &orig_node->neigh_list, list) {
 
-			if (compare_orig(tmp_neigh_node->addr,
-					 orig_neigh_node->orig) &&
+			if (compare_eth(tmp_neigh_node->addr,
+					orig_neigh_node->orig) &&
 			    (tmp_neigh_node->if_incoming == if_incoming))
 				neigh_node = tmp_neigh_node;
 		}
@@ -192,8 +192,8 @@ static int is_bidirectional_neigh(struct orig_node *orig_node,
 		hlist_for_each_entry_rcu(tmp_neigh_node, node,
 					 &orig_neigh_node->neigh_list, list) {
 
-			if (compare_orig(tmp_neigh_node->addr,
-					 orig_neigh_node->orig) &&
+			if (compare_eth(tmp_neigh_node->addr,
+					orig_neigh_node->orig) &&
 			    (tmp_neigh_node->if_incoming == if_incoming))
 				neigh_node = tmp_neigh_node;
 		}
@@ -304,8 +304,8 @@ static void bonding_candidate_add(struct orig_node *orig_node,
 	spin_lock_bh(&orig_node->neigh_list_lock);
 
 	/* only consider if it has the same primary address ...  */
-	if (!compare_orig(orig_node->orig,
-			  neigh_node->orig_node->primary_addr))
+	if (!compare_eth(orig_node->orig,
+			 neigh_node->orig_node->primary_addr))
 		goto candidate_del;
 
 	if (!orig_node->router)
@@ -334,7 +334,7 @@ static void bonding_candidate_add(struct orig_node *orig_node,
 			continue;
 
 		if ((neigh_node->if_incoming == tmp_neigh_node->if_incoming) ||
-		    (compare_orig(neigh_node->addr, tmp_neigh_node->addr))) {
+		    (compare_eth(neigh_node->addr, tmp_neigh_node->addr))) {
 			interference_candidate = 1;
 			break;
 		}
@@ -394,7 +394,7 @@ static void update_orig(struct bat_priv *bat_priv,
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(tmp_neigh_node, node,
 				 &orig_node->neigh_list, list) {
-		if (compare_orig(tmp_neigh_node->addr, ethhdr->h_source) &&
+		if (compare_eth(tmp_neigh_node->addr, ethhdr->h_source) &&
 		    (tmp_neigh_node->if_incoming == if_incoming) &&
 		     atomic_inc_not_zero(&tmp_neigh_node->refcount)) {
 			if (neigh_node)
@@ -579,7 +579,7 @@ static char count_real_packets(struct ethhdr *ethhdr,
 					       orig_node->last_real_seqno,
 					       batman_packet->seqno);
 
-		if (compare_orig(tmp_neigh_node->addr, ethhdr->h_source) &&
+		if (compare_eth(tmp_neigh_node->addr, ethhdr->h_source) &&
 		    (tmp_neigh_node->if_incoming == if_incoming))
 			set_mark = 1;
 		else
@@ -644,8 +644,8 @@ void receive_bat_packet(struct ethhdr *ethhdr,
 
 	has_directlink_flag = (batman_packet->flags & DIRECTLINK ? 1 : 0);
 
-	is_single_hop_neigh = (compare_orig(ethhdr->h_source,
-					    batman_packet->orig) ? 1 : 0);
+	is_single_hop_neigh = (compare_eth(ethhdr->h_source,
+					   batman_packet->orig) ? 1 : 0);
 
 	bat_dbg(DBG_BATMAN, bat_priv,
 		"Received BATMAN packet via NB: %pM, IF: %s [%pM] "
@@ -665,19 +665,19 @@ void receive_bat_packet(struct ethhdr *ethhdr,
 		if (batman_if->soft_iface != if_incoming->soft_iface)
 			continue;
 
-		if (compare_orig(ethhdr->h_source,
-				 batman_if->net_dev->dev_addr))
+		if (compare_eth(ethhdr->h_source,
+				batman_if->net_dev->dev_addr))
 			is_my_addr = 1;
 
-		if (compare_orig(batman_packet->orig,
-				 batman_if->net_dev->dev_addr))
+		if (compare_eth(batman_packet->orig,
+				batman_if->net_dev->dev_addr))
 			is_my_orig = 1;
 
-		if (compare_orig(batman_packet->prev_sender,
-				 batman_if->net_dev->dev_addr))
+		if (compare_eth(batman_packet->prev_sender,
+				batman_if->net_dev->dev_addr))
 			is_my_oldorig = 1;
 
-		if (compare_orig(ethhdr->h_source, broadcast_addr))
+		if (compare_eth(ethhdr->h_source, broadcast_addr))
 			is_broadcast = 1;
 	}
 	rcu_read_unlock();
@@ -717,8 +717,8 @@ void receive_bat_packet(struct ethhdr *ethhdr,
 		/* if received seqno equals last send seqno save new
 		 * seqno for bidirectional check */
 		if (has_directlink_flag &&
-		    compare_orig(if_incoming->net_dev->dev_addr,
-				 batman_packet->orig) &&
+		    compare_eth(if_incoming->net_dev->dev_addr,
+				batman_packet->orig) &&
 		    (batman_packet->seqno - if_incoming_seqno + 2 == 0)) {
 			offset = if_incoming->if_num * NUM_WORDS;
 
@@ -765,11 +765,11 @@ void receive_bat_packet(struct ethhdr *ethhdr,
 	/* avoid temporary routing loops */
 	if ((orig_node->router) &&
 	    (orig_node->router->orig_node->router) &&
-	    (compare_orig(orig_node->router->addr,
-			  batman_packet->prev_sender)) &&
-	    !(compare_orig(batman_packet->orig, batman_packet->prev_sender)) &&
-	    (compare_orig(orig_node->router->addr,
-			  orig_node->router->orig_node->router->addr))) {
+	    (compare_eth(orig_node->router->addr,
+			 batman_packet->prev_sender)) &&
+	    !(compare_eth(batman_packet->orig, batman_packet->prev_sender)) &&
+	    (compare_eth(orig_node->router->addr,
+			 orig_node->router->orig_node->router->addr))) {
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Drop packet: ignoring all rebroadcast packets that "
 			"may make me loop (sender: %pM)\n", ethhdr->h_source);
@@ -1185,14 +1185,13 @@ struct neigh_node *find_router(struct bat_priv *bat_priv,
 
 	/* if we have something in the primary_addr, we can search
 	 * for a potential bonding candidate. */
-	if (memcmp(router_orig->primary_addr, zero_mac, ETH_ALEN) == 0)
+	if (compare_eth(router_orig->primary_addr, zero_mac))
 		goto return_router;
 
 	/* find the orig_node which has the primary interface. might
 	 * even be the same as our router_orig in many cases */
 
-	if (memcmp(router_orig->primary_addr,
-				router_orig->orig, ETH_ALEN) == 0) {
+	if (compare_eth(router_orig->primary_addr, router_orig->orig)) {
 		primary_orig_node = router_orig;
 	} else {
 		primary_orig_node = hash_find(bat_priv->orig_hash, compare_orig,
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 8314276..f0232ad 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -326,7 +326,7 @@ void schedule_forward_packet(struct orig_node *orig_node,
 	if ((orig_node->router) && (orig_node->router->tq_avg != 0)) {
 
 		/* rebroadcast ogm of best ranking neighbor as is */
-		if (!compare_orig(orig_node->router->addr, ethhdr->h_source)) {
+		if (!compare_eth(orig_node->router->addr, ethhdr->h_source)) {
 			batman_packet->tq = orig_node->router->tq_avg;
 
 			if (orig_node->router->last_ttl)
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index c30ccd6..bea2dcf 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -132,7 +132,7 @@ static struct softif_neigh *softif_neigh_get(struct bat_priv *bat_priv,
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(softif_neigh, node,
 				 &bat_priv->softif_neigh_list, list) {
-		if (memcmp(softif_neigh->addr, addr, ETH_ALEN) != 0)
+		if (!compare_eth(softif_neigh->addr, addr))
 			continue;
 
 		if (softif_neigh->vid != vid)
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index b25e4b3..77d0ee0 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -101,7 +101,7 @@ void hna_local_add(struct net_device *soft_iface, uint8_t *addr)
 	hna_local_entry->last_seen = jiffies;
 
 	/* the batman interface mac address should never be purged */
-	if (compare_orig(addr, soft_iface->dev_addr))
+	if (compare_eth(addr, soft_iface->dev_addr))
 		hna_local_entry->never_purge = 1;
 	else
 		hna_local_entry->never_purge = 0;
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 9832d8f..fc97329 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -75,7 +75,7 @@ static int vis_info_cmp(void *data1, void *data2)
 	d2 = data2;
 	p1 = (struct vis_packet *)d1->skb_packet->data;
 	p2 = (struct vis_packet *)d2->skb_packet->data;
-	return compare_orig(p1->vis_orig, p2->vis_orig);
+	return compare_eth(p1->vis_orig, p2->vis_orig);
 }
 
 /* hash function to choose an entry in a hash table of given size */
@@ -113,7 +113,7 @@ static void vis_data_insert_interface(const uint8_t *interface,
 	struct hlist_node *pos;
 
 	hlist_for_each_entry(entry, pos, if_list, list) {
-		if (compare_orig(entry->addr, (void *)interface))
+		if (compare_eth(entry->addr, (void *)interface))
 			return;
 	}
 
@@ -165,7 +165,7 @@ static ssize_t vis_data_read_entry(char *buff, struct vis_info_entry *entry,
 	/* maximal length: max(4+17+2, 3+17+1+3+2) == 26 */
 	if (primary && entry->quality == 0)
 		return sprintf(buff, "HNA %pM, ", entry->dest);
-	else if (compare_orig(entry->src, src))
+	else if (compare_eth(entry->src, src))
 		return sprintf(buff, "TQ %pM %d, ", entry->dest,
 			       entry->quality);
 
@@ -212,7 +212,7 @@ int vis_seq_print_text(struct seq_file *seq, void *offset)
 				if (entries[j].quality == 0)
 					continue;
 				compare =
-				 compare_orig(entries[j].src, packet->vis_orig);
+				 compare_eth(entries[j].src, packet->vis_orig);
 				vis_data_insert_interface(entries[j].src,
 							  &vis_if_list,
 							  compare);
@@ -222,7 +222,7 @@ int vis_seq_print_text(struct seq_file *seq, void *offset)
 				buf_size += 18 + 26 * packet->entries;
 
 				/* add primary/secondary records */
-				if (compare_orig(entry->addr, packet->vis_orig))
+				if (compare_eth(entry->addr, packet->vis_orig))
 					buf_size +=
 					  vis_data_count_prim_sec(&vis_if_list);
 
@@ -258,7 +258,7 @@ int vis_seq_print_text(struct seq_file *seq, void *offset)
 				if (entries[j].quality == 0)
 					continue;
 				compare =
-				 compare_orig(entries[j].src, packet->vis_orig);
+				 compare_eth(entries[j].src, packet->vis_orig);
 				vis_data_insert_interface(entries[j].src,
 							  &vis_if_list,
 							  compare);
@@ -276,7 +276,7 @@ int vis_seq_print_text(struct seq_file *seq, void *offset)
 							entry->primary);
 
 				/* add primary/secondary records */
-				if (compare_orig(entry->addr, packet->vis_orig))
+				if (compare_eth(entry->addr, packet->vis_orig))
 					buff_pos +=
 					 vis_data_read_prim_sec(buff + buff_pos,
 								&vis_if_list);
@@ -344,7 +344,7 @@ static int recv_list_is_in(struct bat_priv *bat_priv,
 
 	spin_lock_bh(&bat_priv->vis_list_lock);
 	list_for_each_entry(entry, recv_list, list) {
-		if (memcmp(entry->mac, mac, ETH_ALEN) == 0) {
+		if (compare_eth(entry->mac, mac)) {
 			spin_unlock_bh(&bat_priv->vis_list_lock);
 			return 1;
 		}
@@ -617,7 +617,7 @@ static int generate_vis_packet(struct bat_priv *bat_priv)
 			if (!neigh_node)
 				continue;
 
-			if (!compare_orig(neigh_node->addr, orig_node->orig))
+			if (!compare_eth(neigh_node->addr, orig_node->orig))
 				continue;
 
 			if (neigh_node->if_incoming->if_status != IF_ACTIVE)
-- 
1.7.2.3


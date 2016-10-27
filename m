From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 14/17] batman-adv: Use proper name for fragments list head
Date: Thu, 27 Oct 2016 21:01:47 +0200
Message-ID: <20161027190150.7880-15-sw@simonwunderlich.de>
References: <20161027190150.7880-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:38348 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941658AbcJ0TCA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 15:02:00 -0400
In-Reply-To: <20161027190150.7880-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The batman-adv codebase is using "list" for the list node (prev/next) and
<list content descriptor>+"_list" for the head of a list. Not using this
naming scheme can up in confusions because list_head is used for both the
head of the list and the list node (prev/next) in each item of the list.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/fragmentation.c | 14 +++++++-------
 net/batman-adv/fragmentation.h |  2 +-
 net/batman-adv/originator.c    |  2 +-
 net/batman-adv/types.h         |  6 +++---
 4 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentation.c
index 1b2f5b9..2b967a3 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -73,7 +73,7 @@ void batadv_frag_purge_orig(struct batadv_orig_node *orig_node,
 		spin_lock_bh(&chain->lock);
 
 		if (!check_cb || check_cb(chain)) {
-			batadv_frag_clear_chain(&chain->head);
+			batadv_frag_clear_chain(&chain->fragment_list);
 			chain->size = 0;
 		}
 
@@ -117,8 +117,8 @@ static bool batadv_frag_init_chain(struct batadv_frag_table_entry *chain,
 	if (chain->seqno == seqno)
 		return false;
 
-	if (!hlist_empty(&chain->head))
-		batadv_frag_clear_chain(&chain->head);
+	if (!hlist_empty(&chain->fragment_list))
+		batadv_frag_clear_chain(&chain->fragment_list);
 
 	chain->size = 0;
 	chain->seqno = seqno;
@@ -176,7 +176,7 @@ static bool batadv_frag_insert_packet(struct batadv_orig_node *orig_node,
 	chain = &orig_node->fragments[bucket];
 	spin_lock_bh(&chain->lock);
 	if (batadv_frag_init_chain(chain, seqno)) {
-		hlist_add_head(&frag_entry_new->list, &chain->head);
+		hlist_add_head(&frag_entry_new->list, &chain->fragment_list);
 		chain->size = skb->len - hdr_size;
 		chain->timestamp = jiffies;
 		chain->total_size = ntohs(frag_packet->total_size);
@@ -185,7 +185,7 @@ static bool batadv_frag_insert_packet(struct batadv_orig_node *orig_node,
 	}
 
 	/* Find the position for the new fragment. */
-	hlist_for_each_entry(frag_entry_curr, &chain->head, list) {
+	hlist_for_each_entry(frag_entry_curr, &chain->fragment_list, list) {
 		/* Drop packet if fragment already exists. */
 		if (frag_entry_curr->no == frag_entry_new->no)
 			goto err_unlock;
@@ -220,11 +220,11 @@ static bool batadv_frag_insert_packet(struct batadv_orig_node *orig_node,
 		 * exceeds the maximum size of one merged packet. Don't allow
 		 * packets to have different total_size.
 		 */
-		batadv_frag_clear_chain(&chain->head);
+		batadv_frag_clear_chain(&chain->fragment_list);
 		chain->size = 0;
 	} else if (ntohs(frag_packet->total_size) == chain->size) {
 		/* All fragments received. Hand over chain to caller. */
-		hlist_move_list(&chain->head, chain_out);
+		hlist_move_list(&chain->fragment_list, chain_out);
 		chain->size = 0;
 	}
 
diff --git a/net/batman-adv/fragmentation.h b/net/batman-adv/fragmentation.h
index 3202fe3..b95f619 100644
--- a/net/batman-adv/fragmentation.h
+++ b/net/batman-adv/fragmentation.h
@@ -47,7 +47,7 @@ int batadv_frag_send_packet(struct sk_buff *skb,
 static inline bool
 batadv_frag_check_entry(struct batadv_frag_table_entry *frags_entry)
 {
-	if (!hlist_empty(&frags_entry->head) &&
+	if (!hlist_empty(&frags_entry->fragment_list) &&
 	    batadv_has_timed_out(frags_entry->timestamp, BATADV_FRAG_TIMEOUT))
 		return true;
 	return false;
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 6af87c9..518b1ed 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -1021,7 +1021,7 @@ struct batadv_orig_node *batadv_orig_node_new(struct batadv_priv *bat_priv,
 	batadv_orig_node_vlan_put(vlan);
 
 	for (i = 0; i < BATADV_FRAG_BUFFER_COUNT; i++) {
-		INIT_HLIST_HEAD(&orig_node->fragments[i].head);
+		INIT_HLIST_HEAD(&orig_node->fragments[i].fragment_list);
 		spin_lock_init(&orig_node->fragments[i].lock);
 		orig_node->fragments[i].size = 0;
 	}
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 97336ec..d31e7ec 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -184,7 +184,7 @@ struct batadv_orig_ifinfo {
 
 /**
  * struct batadv_frag_table_entry - head in the fragment buffer table
- * @head: head of list with fragments
+ * @fragment_list: head of list with fragments
  * @lock: lock to protect the list of fragments
  * @timestamp: time (jiffie) of last received fragment
  * @seqno: sequence number of the fragments in the list
@@ -192,8 +192,8 @@ struct batadv_orig_ifinfo {
  * @total_size: expected size of the assembled packet
  */
 struct batadv_frag_table_entry {
-	struct hlist_head head;
-	spinlock_t lock; /* protects head */
+	struct hlist_head fragment_list;
+	spinlock_t lock; /* protects fragment_list */
 	unsigned long timestamp;
 	u16 seqno;
 	u16 size;
-- 
2.10.1

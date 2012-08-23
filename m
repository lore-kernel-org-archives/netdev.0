From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 10/18] batman-adv: Split batadv_priv in sub-structures for features
Date: Thu, 23 Aug 2012 15:10:19 +0200
Message-ID: <1345727427-20805-11-git-send-email-ordex@autistici.org>
References: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:28866 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933161Ab2HWNK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 09:10:59 -0400
In-Reply-To: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The structure batadv_priv grows everytime a new feature is introduced. It gets
hard to find the parts of the struct that belongs to a specific feature. This
becomes even harder by the fact that not every feature uses a prefix in the
member name.

The variables for bridge loop avoidence, gateway handling, translation table
and visualization server are moved into separate structs that are included in
the bat_priv main struct.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c            |    4 +-
 net/batman-adv/bridge_loop_avoidance.c |  115 +++++++++---------
 net/batman-adv/gateway_client.c        |   32 ++---
 net/batman-adv/hard-interface.c        |    5 +-
 net/batman-adv/main.c                  |   24 ++--
 net/batman-adv/routing.c               |    6 +-
 net/batman-adv/soft-interface.c        |   17 +--
 net/batman-adv/translation-table.c     |  208 ++++++++++++++++----------------
 net/batman-adv/types.h                 |  113 ++++++++++-------
 net/batman-adv/vis.c                   |  130 ++++++++++----------
 10 files changed, 343 insertions(+), 311 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index e877af8..eb507c9 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -603,8 +603,8 @@ static void batadv_iv_ogm_schedule(struct batadv_hard_iface *hard_iface)
 			htonl((uint32_t)atomic_read(&hard_iface->seqno));
 	atomic_inc(&hard_iface->seqno);
 
-	batadv_ogm_packet->ttvn = atomic_read(&bat_priv->ttvn);
-	batadv_ogm_packet->tt_crc = htons(bat_priv->tt_crc);
+	batadv_ogm_packet->ttvn = atomic_read(&bat_priv->tt.vn);
+	batadv_ogm_packet->tt_crc = htons(bat_priv->tt.local_crc);
 	if (tt_num_changes >= 0)
 		batadv_ogm_packet->tt_num_changes = tt_num_changes;
 
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index c9732ac..ad18017 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -133,7 +133,7 @@ static void batadv_claim_free_ref(struct batadv_claim *claim)
 static struct batadv_claim *batadv_claim_hash_find(struct batadv_priv *bat_priv,
 						   struct batadv_claim *data)
 {
-	struct batadv_hashtable *hash = bat_priv->claim_hash;
+	struct batadv_hashtable *hash = bat_priv->bla.claim_hash;
 	struct hlist_head *head;
 	struct hlist_node *node;
 	struct batadv_claim *claim;
@@ -174,7 +174,7 @@ static struct batadv_backbone_gw *
 batadv_backbone_hash_find(struct batadv_priv *bat_priv,
 			  uint8_t *addr, short vid)
 {
-	struct batadv_hashtable *hash = bat_priv->backbone_hash;
+	struct batadv_hashtable *hash = bat_priv->bla.backbone_hash;
 	struct hlist_head *head;
 	struct hlist_node *node;
 	struct batadv_backbone_gw search_entry, *backbone_gw;
@@ -218,7 +218,7 @@ batadv_bla_del_backbone_claims(struct batadv_backbone_gw *backbone_gw)
 	int i;
 	spinlock_t *list_lock;	/* protects write access to the hash lists */
 
-	hash = backbone_gw->bat_priv->claim_hash;
+	hash = backbone_gw->bat_priv->bla.claim_hash;
 	if (!hash)
 		return;
 
@@ -265,7 +265,7 @@ static void batadv_bla_send_claim(struct batadv_priv *bat_priv, uint8_t *mac,
 	if (!primary_if)
 		return;
 
-	memcpy(&local_claim_dest, &bat_priv->claim_dest,
+	memcpy(&local_claim_dest, &bat_priv->bla.claim_dest,
 	       sizeof(local_claim_dest));
 	local_claim_dest.type = claimtype;
 
@@ -391,7 +391,7 @@ batadv_bla_get_backbone_gw(struct batadv_priv *bat_priv, uint8_t *orig,
 	/* one for the hash, one for returning */
 	atomic_set(&entry->refcount, 2);
 
-	hash_added = batadv_hash_add(bat_priv->backbone_hash,
+	hash_added = batadv_hash_add(bat_priv->bla.backbone_hash,
 				     batadv_compare_backbone_gw,
 				     batadv_choose_backbone_gw, entry,
 				     &entry->hash_entry);
@@ -458,7 +458,7 @@ static void batadv_bla_answer_request(struct batadv_priv *bat_priv,
 	if (!backbone_gw)
 		return;
 
-	hash = bat_priv->claim_hash;
+	hash = bat_priv->bla.claim_hash;
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
@@ -499,7 +499,7 @@ static void batadv_bla_send_request(struct batadv_backbone_gw *backbone_gw)
 
 	/* no local broadcasts should be sent or received, for now. */
 	if (!atomic_read(&backbone_gw->request_sent)) {
-		atomic_inc(&backbone_gw->bat_priv->bla_num_requests);
+		atomic_inc(&backbone_gw->bat_priv->bla.num_requests);
 		atomic_set(&backbone_gw->request_sent, 1);
 	}
 }
@@ -559,7 +559,7 @@ static void batadv_bla_add_claim(struct batadv_priv *bat_priv,
 		batadv_dbg(BATADV_DBG_BLA, bat_priv,
 			   "bla_add_claim(): adding new entry %pM, vid %d to hash ...\n",
 			   mac, vid);
-		hash_added = batadv_hash_add(bat_priv->claim_hash,
+		hash_added = batadv_hash_add(bat_priv->bla.claim_hash,
 					     batadv_compare_claim,
 					     batadv_choose_claim, claim,
 					     &claim->hash_entry);
@@ -612,7 +612,7 @@ static void batadv_bla_del_claim(struct batadv_priv *bat_priv,
 	batadv_dbg(BATADV_DBG_BLA, bat_priv, "bla_del_claim(): %pM, vid %d\n",
 		   mac, vid);
 
-	batadv_hash_remove(bat_priv->claim_hash, batadv_compare_claim,
+	batadv_hash_remove(bat_priv->bla.claim_hash, batadv_compare_claim,
 			   batadv_choose_claim, claim);
 	batadv_claim_free_ref(claim); /* reference from the hash is gone */
 
@@ -659,7 +659,7 @@ static int batadv_handle_announce(struct batadv_priv *bat_priv,
 		 * we can allow traffic again.
 		 */
 		if (atomic_read(&backbone_gw->request_sent)) {
-			atomic_dec(&backbone_gw->bat_priv->bla_num_requests);
+			atomic_dec(&backbone_gw->bat_priv->bla.num_requests);
 			atomic_set(&backbone_gw->request_sent, 0);
 		}
 	}
@@ -774,7 +774,7 @@ static int batadv_check_claim_group(struct batadv_priv *bat_priv,
 	struct batadv_bla_claim_dst *bla_dst, *bla_dst_own;
 
 	bla_dst = (struct batadv_bla_claim_dst *)hw_dst;
-	bla_dst_own = &bat_priv->claim_dest;
+	bla_dst_own = &bat_priv->bla.claim_dest;
 
 	/* check if it is a claim packet in general */
 	if (memcmp(bla_dst->magic, bla_dst_own->magic,
@@ -947,7 +947,7 @@ static void batadv_bla_purge_backbone_gw(struct batadv_priv *bat_priv, int now)
 	spinlock_t *list_lock;	/* protects write access to the hash lists */
 	int i;
 
-	hash = bat_priv->backbone_hash;
+	hash = bat_priv->bla.backbone_hash;
 	if (!hash)
 		return;
 
@@ -971,7 +971,7 @@ static void batadv_bla_purge_backbone_gw(struct batadv_priv *bat_priv, int now)
 purge_now:
 			/* don't wait for the pending request anymore */
 			if (atomic_read(&backbone_gw->request_sent))
-				atomic_dec(&bat_priv->bla_num_requests);
+				atomic_dec(&bat_priv->bla.num_requests);
 
 			batadv_bla_del_backbone_claims(backbone_gw);
 
@@ -1001,7 +1001,7 @@ static void batadv_bla_purge_claims(struct batadv_priv *bat_priv,
 	struct batadv_hashtable *hash;
 	int i;
 
-	hash = bat_priv->claim_hash;
+	hash = bat_priv->bla.claim_hash;
 	if (!hash)
 		return;
 
@@ -1048,11 +1048,12 @@ void batadv_bla_update_orig_address(struct batadv_priv *bat_priv,
 	struct hlist_node *node;
 	struct hlist_head *head;
 	struct batadv_hashtable *hash;
+	__be16 group;
 	int i;
 
 	/* reset bridge loop avoidance group id */
-	bat_priv->claim_dest.group =
-		htons(crc16(0, primary_if->net_dev->dev_addr, ETH_ALEN));
+	group = htons(crc16(0, primary_if->net_dev->dev_addr, ETH_ALEN));
+	bat_priv->bla.claim_dest.group = group;
 
 	if (!oldif) {
 		batadv_bla_purge_claims(bat_priv, NULL, 1);
@@ -1060,7 +1061,7 @@ void batadv_bla_update_orig_address(struct batadv_priv *bat_priv,
 		return;
 	}
 
-	hash = bat_priv->backbone_hash;
+	hash = bat_priv->bla.backbone_hash;
 	if (!hash)
 		return;
 
@@ -1090,8 +1091,8 @@ void batadv_bla_update_orig_address(struct batadv_priv *bat_priv,
 /* (re)start the timer */
 static void batadv_bla_start_timer(struct batadv_priv *bat_priv)
 {
-	INIT_DELAYED_WORK(&bat_priv->bla_work, batadv_bla_periodic_work);
-	queue_delayed_work(batadv_event_workqueue, &bat_priv->bla_work,
+	INIT_DELAYED_WORK(&bat_priv->bla.work, batadv_bla_periodic_work);
+	queue_delayed_work(batadv_event_workqueue, &bat_priv->bla.work,
 			   msecs_to_jiffies(BATADV_BLA_PERIOD_LENGTH));
 }
 
@@ -1104,6 +1105,7 @@ static void batadv_bla_periodic_work(struct work_struct *work)
 	struct delayed_work *delayed_work =
 		container_of(work, struct delayed_work, work);
 	struct batadv_priv *bat_priv;
+	struct batadv_priv_bla *priv_bla;
 	struct hlist_node *node;
 	struct hlist_head *head;
 	struct batadv_backbone_gw *backbone_gw;
@@ -1111,7 +1113,8 @@ static void batadv_bla_periodic_work(struct work_struct *work)
 	struct batadv_hard_iface *primary_if;
 	int i;
 
-	bat_priv = container_of(delayed_work, struct batadv_priv, bla_work);
+	priv_bla = container_of(delayed_work, struct batadv_priv_bla, work);
+	bat_priv = container_of(priv_bla, struct batadv_priv, bla);
 	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
 		goto out;
@@ -1122,7 +1125,7 @@ static void batadv_bla_periodic_work(struct work_struct *work)
 	if (!atomic_read(&bat_priv->bridge_loop_avoidance))
 		goto out;
 
-	hash = bat_priv->backbone_hash;
+	hash = bat_priv->bla.backbone_hash;
 	if (!hash)
 		goto out;
 
@@ -1162,40 +1165,41 @@ int batadv_bla_init(struct batadv_priv *bat_priv)
 	int i;
 	uint8_t claim_dest[ETH_ALEN] = {0xff, 0x43, 0x05, 0x00, 0x00, 0x00};
 	struct batadv_hard_iface *primary_if;
+	uint16_t crc;
+	unsigned long entrytime;
 
 	batadv_dbg(BATADV_DBG_BLA, bat_priv, "bla hash registering\n");
 
 	/* setting claim destination address */
-	memcpy(&bat_priv->claim_dest.magic, claim_dest, 3);
-	bat_priv->claim_dest.type = 0;
+	memcpy(&bat_priv->bla.claim_dest.magic, claim_dest, 3);
+	bat_priv->bla.claim_dest.type = 0;
 	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (primary_if) {
-		bat_priv->claim_dest.group =
-			htons(crc16(0, primary_if->net_dev->dev_addr,
-				    ETH_ALEN));
+		crc = crc16(0, primary_if->net_dev->dev_addr, ETH_ALEN);
+		bat_priv->bla.claim_dest.group = htons(crc);
 		batadv_hardif_free_ref(primary_if);
 	} else {
-		bat_priv->claim_dest.group = 0; /* will be set later */
+		bat_priv->bla.claim_dest.group = 0; /* will be set later */
 	}
 
 	/* initialize the duplicate list */
+	entrytime = jiffies - msecs_to_jiffies(BATADV_DUPLIST_TIMEOUT);
 	for (i = 0; i < BATADV_DUPLIST_SIZE; i++)
-		bat_priv->bcast_duplist[i].entrytime =
-			jiffies - msecs_to_jiffies(BATADV_DUPLIST_TIMEOUT);
-	bat_priv->bcast_duplist_curr = 0;
+		bat_priv->bla.bcast_duplist[i].entrytime = entrytime;
+	bat_priv->bla.bcast_duplist_curr = 0;
 
-	if (bat_priv->claim_hash)
+	if (bat_priv->bla.claim_hash)
 		return 0;
 
-	bat_priv->claim_hash = batadv_hash_new(128);
-	bat_priv->backbone_hash = batadv_hash_new(32);
+	bat_priv->bla.claim_hash = batadv_hash_new(128);
+	bat_priv->bla.backbone_hash = batadv_hash_new(32);
 
-	if (!bat_priv->claim_hash || !bat_priv->backbone_hash)
+	if (!bat_priv->bla.claim_hash || !bat_priv->bla.backbone_hash)
 		return -ENOMEM;
 
-	batadv_hash_set_lock_class(bat_priv->claim_hash,
+	batadv_hash_set_lock_class(bat_priv->bla.claim_hash,
 				   &batadv_claim_hash_lock_class_key);
-	batadv_hash_set_lock_class(bat_priv->backbone_hash,
+	batadv_hash_set_lock_class(bat_priv->bla.backbone_hash,
 				   &batadv_backbone_hash_lock_class_key);
 
 	batadv_dbg(BATADV_DBG_BLA, bat_priv, "bla hashes initialized\n");
@@ -1236,8 +1240,9 @@ int batadv_bla_check_bcast_duplist(struct batadv_priv *bat_priv,
 	crc = crc16(0, content, length);
 
 	for (i = 0; i < BATADV_DUPLIST_SIZE; i++) {
-		curr = (bat_priv->bcast_duplist_curr + i) % BATADV_DUPLIST_SIZE;
-		entry = &bat_priv->bcast_duplist[curr];
+		curr = (bat_priv->bla.bcast_duplist_curr + i);
+		curr %= BATADV_DUPLIST_SIZE;
+		entry = &bat_priv->bla.bcast_duplist[curr];
 
 		/* we can stop searching if the entry is too old ;
 		 * later entries will be even older
@@ -1258,13 +1263,13 @@ int batadv_bla_check_bcast_duplist(struct batadv_priv *bat_priv,
 		return 1;
 	}
 	/* not found, add a new entry (overwrite the oldest entry) */
-	curr = (bat_priv->bcast_duplist_curr + BATADV_DUPLIST_SIZE - 1);
+	curr = (bat_priv->bla.bcast_duplist_curr + BATADV_DUPLIST_SIZE - 1);
 	curr %= BATADV_DUPLIST_SIZE;
-	entry = &bat_priv->bcast_duplist[curr];
+	entry = &bat_priv->bla.bcast_duplist[curr];
 	entry->crc = crc;
 	entry->entrytime = jiffies;
 	memcpy(entry->orig, bcast_packet->orig, ETH_ALEN);
-	bat_priv->bcast_duplist_curr = curr;
+	bat_priv->bla.bcast_duplist_curr = curr;
 
 	/* allow it, its the first occurence. */
 	return 0;
@@ -1281,7 +1286,7 @@ int batadv_bla_check_bcast_duplist(struct batadv_priv *bat_priv,
  */
 int batadv_bla_is_backbone_gw_orig(struct batadv_priv *bat_priv, uint8_t *orig)
 {
-	struct batadv_hashtable *hash = bat_priv->backbone_hash;
+	struct batadv_hashtable *hash = bat_priv->bla.backbone_hash;
 	struct hlist_head *head;
 	struct hlist_node *node;
 	struct batadv_backbone_gw *backbone_gw;
@@ -1361,18 +1366,18 @@ void batadv_bla_free(struct batadv_priv *bat_priv)
 {
 	struct batadv_hard_iface *primary_if;
 
-	cancel_delayed_work_sync(&bat_priv->bla_work);
+	cancel_delayed_work_sync(&bat_priv->bla.work);
 	primary_if = batadv_primary_if_get_selected(bat_priv);
 
-	if (bat_priv->claim_hash) {
+	if (bat_priv->bla.claim_hash) {
 		batadv_bla_purge_claims(bat_priv, primary_if, 1);
-		batadv_hash_destroy(bat_priv->claim_hash);
-		bat_priv->claim_hash = NULL;
+		batadv_hash_destroy(bat_priv->bla.claim_hash);
+		bat_priv->bla.claim_hash = NULL;
 	}
-	if (bat_priv->backbone_hash) {
+	if (bat_priv->bla.backbone_hash) {
 		batadv_bla_purge_backbone_gw(bat_priv, 1);
-		batadv_hash_destroy(bat_priv->backbone_hash);
-		bat_priv->backbone_hash = NULL;
+		batadv_hash_destroy(bat_priv->bla.backbone_hash);
+		bat_priv->bla.backbone_hash = NULL;
 	}
 	if (primary_if)
 		batadv_hardif_free_ref(primary_if);
@@ -1411,7 +1416,7 @@ int batadv_bla_rx(struct batadv_priv *bat_priv, struct sk_buff *skb, short vid,
 		goto allow;
 
 
-	if (unlikely(atomic_read(&bat_priv->bla_num_requests)))
+	if (unlikely(atomic_read(&bat_priv->bla.num_requests)))
 		/* don't allow broadcasts while requests are in flight */
 		if (is_multicast_ether_addr(ethhdr->h_dest) && is_bcast)
 			goto handled;
@@ -1510,7 +1515,7 @@ int batadv_bla_tx(struct batadv_priv *bat_priv, struct sk_buff *skb, short vid)
 
 	ethhdr = (struct ethhdr *)skb_mac_header(skb);
 
-	if (unlikely(atomic_read(&bat_priv->bla_num_requests)))
+	if (unlikely(atomic_read(&bat_priv->bla.num_requests)))
 		/* don't allow broadcasts while requests are in flight */
 		if (is_multicast_ether_addr(ethhdr->h_dest))
 			goto handled;
@@ -1566,7 +1571,7 @@ int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *offset)
 {
 	struct net_device *net_dev = (struct net_device *)seq->private;
 	struct batadv_priv *bat_priv = netdev_priv(net_dev);
-	struct batadv_hashtable *hash = bat_priv->claim_hash;
+	struct batadv_hashtable *hash = bat_priv->bla.claim_hash;
 	struct batadv_claim *claim;
 	struct batadv_hard_iface *primary_if;
 	struct hlist_node *node;
@@ -1595,7 +1600,7 @@ int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *offset)
 	seq_printf(seq,
 		   "Claims announced for the mesh %s (orig %pM, group id %04x)\n",
 		   net_dev->name, primary_addr,
-		   ntohs(bat_priv->claim_dest.group));
+		   ntohs(bat_priv->bla.claim_dest.group));
 	seq_printf(seq, "   %-17s    %-5s    %-17s [o] (%-4s)\n",
 		   "Client", "VID", "Originator", "CRC");
 	for (i = 0; i < hash->size; i++) {
@@ -1623,7 +1628,7 @@ int batadv_bla_backbone_table_seq_print_text(struct seq_file *seq, void *offset)
 {
 	struct net_device *net_dev = (struct net_device *)seq->private;
 	struct batadv_priv *bat_priv = netdev_priv(net_dev);
-	struct batadv_hashtable *hash = bat_priv->backbone_hash;
+	struct batadv_hashtable *hash = bat_priv->bla.backbone_hash;
 	struct batadv_backbone_gw *backbone_gw;
 	struct batadv_hard_iface *primary_if;
 	struct hlist_node *node;
@@ -1653,7 +1658,7 @@ int batadv_bla_backbone_table_seq_print_text(struct seq_file *seq, void *offset)
 	seq_printf(seq,
 		   "Backbones announced for the mesh %s (orig %pM, group id %04x)\n",
 		   net_dev->name, primary_addr,
-		   ntohs(bat_priv->claim_dest.group));
+		   ntohs(bat_priv->bla.claim_dest.group));
 	seq_printf(seq, "   %-17s    %-5s %-9s (%-4s)\n",
 		   "Originator", "VID", "last seen", "CRC");
 	for (i = 0; i < hash->size; i++) {
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index fc866f2..eef7cc7 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -48,7 +48,7 @@ batadv_gw_get_selected_gw_node(struct batadv_priv *bat_priv)
 	struct batadv_gw_node *gw_node;
 
 	rcu_read_lock();
-	gw_node = rcu_dereference(bat_priv->curr_gw);
+	gw_node = rcu_dereference(bat_priv->gw.curr_gw);
 	if (!gw_node)
 		goto out;
 
@@ -91,23 +91,23 @@ static void batadv_gw_select(struct batadv_priv *bat_priv,
 {
 	struct batadv_gw_node *curr_gw_node;
 
-	spin_lock_bh(&bat_priv->gw_list_lock);
+	spin_lock_bh(&bat_priv->gw.list_lock);
 
 	if (new_gw_node && !atomic_inc_not_zero(&new_gw_node->refcount))
 		new_gw_node = NULL;
 
-	curr_gw_node = rcu_dereference_protected(bat_priv->curr_gw, 1);
-	rcu_assign_pointer(bat_priv->curr_gw, new_gw_node);
+	curr_gw_node = rcu_dereference_protected(bat_priv->gw.curr_gw, 1);
+	rcu_assign_pointer(bat_priv->gw.curr_gw, new_gw_node);
 
 	if (curr_gw_node)
 		batadv_gw_node_free_ref(curr_gw_node);
 
-	spin_unlock_bh(&bat_priv->gw_list_lock);
+	spin_unlock_bh(&bat_priv->gw.list_lock);
 }
 
 void batadv_gw_deselect(struct batadv_priv *bat_priv)
 {
-	atomic_set(&bat_priv->gw_reselect, 1);
+	atomic_set(&bat_priv->gw.reselect, 1);
 }
 
 static struct batadv_gw_node *
@@ -122,7 +122,7 @@ batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 	struct batadv_orig_node *orig_node;
 
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(gw_node, node, &bat_priv->gw_list, list) {
+	hlist_for_each_entry_rcu(gw_node, node, &bat_priv->gw.list, list) {
 		if (gw_node->deleted)
 			continue;
 
@@ -202,7 +202,7 @@ void batadv_gw_election(struct batadv_priv *bat_priv)
 
 	curr_gw = batadv_gw_get_selected_gw_node(bat_priv);
 
-	if (!batadv_atomic_dec_not_zero(&bat_priv->gw_reselect) && curr_gw)
+	if (!batadv_atomic_dec_not_zero(&bat_priv->gw.reselect) && curr_gw)
 		goto out;
 
 	next_gw = batadv_gw_get_best_gw_node(bat_priv);
@@ -321,9 +321,9 @@ static void batadv_gw_node_add(struct batadv_priv *bat_priv,
 	gw_node->orig_node = orig_node;
 	atomic_set(&gw_node->refcount, 1);
 
-	spin_lock_bh(&bat_priv->gw_list_lock);
-	hlist_add_head_rcu(&gw_node->list, &bat_priv->gw_list);
-	spin_unlock_bh(&bat_priv->gw_list_lock);
+	spin_lock_bh(&bat_priv->gw.list_lock);
+	hlist_add_head_rcu(&gw_node->list, &bat_priv->gw.list);
+	spin_unlock_bh(&bat_priv->gw.list_lock);
 
 	batadv_gw_bandwidth_to_kbit(new_gwflags, &down, &up);
 	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
@@ -350,7 +350,7 @@ void batadv_gw_node_update(struct batadv_priv *bat_priv,
 	curr_gw = batadv_gw_get_selected_gw_node(bat_priv);
 
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(gw_node, node, &bat_priv->gw_list, list) {
+	hlist_for_each_entry_rcu(gw_node, node, &bat_priv->gw.list, list) {
 		if (gw_node->orig_node != orig_node)
 			continue;
 
@@ -404,10 +404,10 @@ void batadv_gw_node_purge(struct batadv_priv *bat_priv)
 
 	curr_gw = batadv_gw_get_selected_gw_node(bat_priv);
 
-	spin_lock_bh(&bat_priv->gw_list_lock);
+	spin_lock_bh(&bat_priv->gw.list_lock);
 
 	hlist_for_each_entry_safe(gw_node, node, node_tmp,
-				  &bat_priv->gw_list, list) {
+				  &bat_priv->gw.list, list) {
 		if (((!gw_node->deleted) ||
 		     (time_before(jiffies, gw_node->deleted + timeout))) &&
 		    atomic_read(&bat_priv->mesh_state) == BATADV_MESH_ACTIVE)
@@ -420,7 +420,7 @@ void batadv_gw_node_purge(struct batadv_priv *bat_priv)
 		batadv_gw_node_free_ref(gw_node);
 	}
 
-	spin_unlock_bh(&bat_priv->gw_list_lock);
+	spin_unlock_bh(&bat_priv->gw.list_lock);
 
 	/* gw_deselect() needs to acquire the gw_list_lock */
 	if (do_deselect)
@@ -496,7 +496,7 @@ int batadv_gw_client_seq_print_text(struct seq_file *seq, void *offset)
 		   primary_if->net_dev->dev_addr, net_dev->name);
 
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(gw_node, node, &bat_priv->gw_list, list) {
+	hlist_for_each_entry_rcu(gw_node, node, &bat_priv->gw.list, list) {
 		if (gw_node->deleted)
 			continue;
 
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 2c5a247..d112fd6 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -103,13 +103,14 @@ static void batadv_primary_if_update_addr(struct batadv_priv *bat_priv,
 {
 	struct batadv_vis_packet *vis_packet;
 	struct batadv_hard_iface *primary_if;
+	struct sk_buff *skb;
 
 	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
 		goto out;
 
-	vis_packet = (struct batadv_vis_packet *)
-				bat_priv->my_vis_info->skb_packet->data;
+	skb = bat_priv->vis.my_info->skb_packet;
+	vis_packet = (struct batadv_vis_packet *)skb->data;
 	memcpy(vis_packet->vis_orig, primary_if->net_dev->dev_addr, ETH_ALEN);
 	memcpy(vis_packet->sender_orig,
 	       primary_if->net_dev->dev_addr, ETH_ALEN);
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 2a1f243..b4aa470 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -94,20 +94,20 @@ int batadv_mesh_init(struct net_device *soft_iface)
 
 	spin_lock_init(&bat_priv->forw_bat_list_lock);
 	spin_lock_init(&bat_priv->forw_bcast_list_lock);
-	spin_lock_init(&bat_priv->tt_changes_list_lock);
-	spin_lock_init(&bat_priv->tt_req_list_lock);
-	spin_lock_init(&bat_priv->tt_roam_list_lock);
-	spin_lock_init(&bat_priv->tt_buff_lock);
-	spin_lock_init(&bat_priv->gw_list_lock);
-	spin_lock_init(&bat_priv->vis_hash_lock);
-	spin_lock_init(&bat_priv->vis_list_lock);
+	spin_lock_init(&bat_priv->tt.changes_list_lock);
+	spin_lock_init(&bat_priv->tt.req_list_lock);
+	spin_lock_init(&bat_priv->tt.roam_list_lock);
+	spin_lock_init(&bat_priv->tt.last_changeset_lock);
+	spin_lock_init(&bat_priv->gw.list_lock);
+	spin_lock_init(&bat_priv->vis.hash_lock);
+	spin_lock_init(&bat_priv->vis.list_lock);
 
 	INIT_HLIST_HEAD(&bat_priv->forw_bat_list);
 	INIT_HLIST_HEAD(&bat_priv->forw_bcast_list);
-	INIT_HLIST_HEAD(&bat_priv->gw_list);
-	INIT_LIST_HEAD(&bat_priv->tt_changes_list);
-	INIT_LIST_HEAD(&bat_priv->tt_req_list);
-	INIT_LIST_HEAD(&bat_priv->tt_roam_list);
+	INIT_HLIST_HEAD(&bat_priv->gw.list);
+	INIT_LIST_HEAD(&bat_priv->tt.changes_list);
+	INIT_LIST_HEAD(&bat_priv->tt.req_list);
+	INIT_LIST_HEAD(&bat_priv->tt.roam_list);
 
 	ret = batadv_originator_init(bat_priv);
 	if (ret < 0)
@@ -128,7 +128,7 @@ int batadv_mesh_init(struct net_device *soft_iface)
 	if (ret < 0)
 		goto err;
 
-	atomic_set(&bat_priv->gw_reselect, 0);
+	atomic_set(&bat_priv->gw.reselect, 0);
 	atomic_set(&bat_priv->mesh_state, BATADV_MESH_ACTIVE);
 
 	return 0;
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index bc2b88b..d5edee7 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -721,7 +721,7 @@ int batadv_recv_roam_adv(struct sk_buff *skb, struct batadv_hard_iface *recv_if)
 	 * been incremented yet. This flag will make me check all the incoming
 	 * packets for the correct destination.
 	 */
-	bat_priv->tt_poss_change = true;
+	bat_priv->tt.poss_change = true;
 
 	batadv_orig_node_free_ref(orig_node);
 out:
@@ -947,8 +947,8 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 	unicast_packet = (struct batadv_unicast_packet *)skb->data;
 
 	if (batadv_is_my_mac(unicast_packet->dest)) {
-		tt_poss_change = bat_priv->tt_poss_change;
-		curr_ttvn = (uint8_t)atomic_read(&bat_priv->ttvn);
+		tt_poss_change = bat_priv->tt.poss_change;
+		curr_ttvn = (uint8_t)atomic_read(&bat_priv->tt.vn);
 	} else {
 		orig_node = batadv_orig_hash_find(bat_priv,
 						  unicast_packet->dest);
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 2b3842b..6d44625 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -420,14 +420,15 @@ struct net_device *batadv_softif_create(const char *name)
 
 	atomic_set(&bat_priv->mesh_state, BATADV_MESH_INACTIVE);
 	atomic_set(&bat_priv->bcast_seqno, 1);
-	atomic_set(&bat_priv->ttvn, 0);
-	atomic_set(&bat_priv->tt_local_changes, 0);
-	atomic_set(&bat_priv->tt_ogm_append_cnt, 0);
-	atomic_set(&bat_priv->bla_num_requests, 0);
-
-	bat_priv->tt_buff = NULL;
-	bat_priv->tt_buff_len = 0;
-	bat_priv->tt_poss_change = false;
+	atomic_set(&bat_priv->tt.vn, 0);
+	atomic_set(&bat_priv->tt.local_changes, 0);
+	atomic_set(&bat_priv->tt.ogm_append_cnt, 0);
+#ifdef CONFIG_BATMAN_ADV_BLA
+	atomic_set(&bat_priv->bla.num_requests, 0);
+#endif
+	bat_priv->tt.last_changeset = NULL;
+	bat_priv->tt.last_changeset_len = 0;
+	bat_priv->tt.poss_change = false;
 
 	bat_priv->primary_if = NULL;
 	bat_priv->num_ifaces = 0;
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index eb8490e..b01049a 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -46,8 +46,8 @@ static int batadv_compare_tt(const struct hlist_node *node, const void *data2)
 
 static void batadv_tt_start_timer(struct batadv_priv *bat_priv)
 {
-	INIT_DELAYED_WORK(&bat_priv->tt_work, batadv_tt_purge);
-	queue_delayed_work(batadv_event_workqueue, &bat_priv->tt_work,
+	INIT_DELAYED_WORK(&bat_priv->tt.work, batadv_tt_purge);
+	queue_delayed_work(batadv_event_workqueue, &bat_priv->tt.work,
 			   msecs_to_jiffies(5000));
 }
 
@@ -88,7 +88,7 @@ batadv_tt_local_hash_find(struct batadv_priv *bat_priv, const void *data)
 	struct batadv_tt_common_entry *tt_common_entry;
 	struct batadv_tt_local_entry *tt_local_entry = NULL;
 
-	tt_common_entry = batadv_tt_hash_find(bat_priv->tt_local_hash, data);
+	tt_common_entry = batadv_tt_hash_find(bat_priv->tt.local_hash, data);
 	if (tt_common_entry)
 		tt_local_entry = container_of(tt_common_entry,
 					      struct batadv_tt_local_entry,
@@ -102,7 +102,7 @@ batadv_tt_global_hash_find(struct batadv_priv *bat_priv, const void *data)
 	struct batadv_tt_common_entry *tt_common_entry;
 	struct batadv_tt_global_entry *tt_global_entry = NULL;
 
-	tt_common_entry = batadv_tt_hash_find(bat_priv->tt_global_hash, data);
+	tt_common_entry = batadv_tt_hash_find(bat_priv->tt.global_hash, data);
 	if (tt_common_entry)
 		tt_global_entry = container_of(tt_common_entry,
 					       struct batadv_tt_global_entry,
@@ -177,8 +177,8 @@ static void batadv_tt_local_event(struct batadv_priv *bat_priv,
 	del_op_requested = flags & BATADV_TT_CLIENT_DEL;
 
 	/* check for ADD+DEL or DEL+ADD events */
-	spin_lock_bh(&bat_priv->tt_changes_list_lock);
-	list_for_each_entry_safe(entry, safe, &bat_priv->tt_changes_list,
+	spin_lock_bh(&bat_priv->tt.changes_list_lock);
+	list_for_each_entry_safe(entry, safe, &bat_priv->tt.changes_list,
 				 list) {
 		if (!batadv_compare_eth(entry->change.addr, addr))
 			continue;
@@ -205,15 +205,15 @@ del:
 	}
 
 	/* track the change in the OGMinterval list */
-	list_add_tail(&tt_change_node->list, &bat_priv->tt_changes_list);
+	list_add_tail(&tt_change_node->list, &bat_priv->tt.changes_list);
 
 unlock:
-	spin_unlock_bh(&bat_priv->tt_changes_list_lock);
+	spin_unlock_bh(&bat_priv->tt.changes_list_lock);
 
 	if (event_removed)
-		atomic_dec(&bat_priv->tt_local_changes);
+		atomic_dec(&bat_priv->tt.local_changes);
 	else
-		atomic_inc(&bat_priv->tt_local_changes);
+		atomic_inc(&bat_priv->tt.local_changes);
 }
 
 int batadv_tt_len(int changes_num)
@@ -223,12 +223,12 @@ int batadv_tt_len(int changes_num)
 
 static int batadv_tt_local_init(struct batadv_priv *bat_priv)
 {
-	if (bat_priv->tt_local_hash)
+	if (bat_priv->tt.local_hash)
 		return 0;
 
-	bat_priv->tt_local_hash = batadv_hash_new(1024);
+	bat_priv->tt.local_hash = batadv_hash_new(1024);
 
-	if (!bat_priv->tt_local_hash)
+	if (!bat_priv->tt.local_hash)
 		return -ENOMEM;
 
 	return 0;
@@ -260,7 +260,7 @@ void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Creating new local tt entry: %pM (ttvn: %d)\n", addr,
-		   (uint8_t)atomic_read(&bat_priv->ttvn));
+		   (uint8_t)atomic_read(&bat_priv->tt.vn));
 
 	memcpy(tt_local_entry->common.addr, addr, ETH_ALEN);
 	tt_local_entry->common.flags = BATADV_NO_FLAGS;
@@ -279,7 +279,7 @@ void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 	 */
 	tt_local_entry->common.flags |= BATADV_TT_CLIENT_NEW;
 
-	hash_added = batadv_hash_add(bat_priv->tt_local_hash, batadv_compare_tt,
+	hash_added = batadv_hash_add(bat_priv->tt.local_hash, batadv_compare_tt,
 				     batadv_choose_orig,
 				     &tt_local_entry->common,
 				     &tt_local_entry->common.hash_entry);
@@ -350,7 +350,7 @@ static void batadv_tt_prepare_packet_buff(struct batadv_priv *bat_priv,
 	primary_if = batadv_primary_if_get_selected(bat_priv);
 
 	req_len = min_packet_len;
-	req_len += batadv_tt_len(atomic_read(&bat_priv->tt_local_changes));
+	req_len += batadv_tt_len(atomic_read(&bat_priv->tt.local_changes));
 
 	/* if we have too many changes for one packet don't send any
 	 * and wait for the tt table request which will be fragmented
@@ -383,10 +383,10 @@ static int batadv_tt_changes_fill_buff(struct batadv_priv *bat_priv,
 	if (new_len > 0)
 		tot_changes = new_len / batadv_tt_len(1);
 
-	spin_lock_bh(&bat_priv->tt_changes_list_lock);
-	atomic_set(&bat_priv->tt_local_changes, 0);
+	spin_lock_bh(&bat_priv->tt.changes_list_lock);
+	atomic_set(&bat_priv->tt.local_changes, 0);
 
-	list_for_each_entry_safe(entry, safe, &bat_priv->tt_changes_list,
+	list_for_each_entry_safe(entry, safe, &bat_priv->tt.changes_list,
 				 list) {
 		if (count < tot_changes) {
 			memcpy(tt_buff + batadv_tt_len(count),
@@ -396,25 +396,25 @@ static int batadv_tt_changes_fill_buff(struct batadv_priv *bat_priv,
 		list_del(&entry->list);
 		kfree(entry);
 	}
-	spin_unlock_bh(&bat_priv->tt_changes_list_lock);
+	spin_unlock_bh(&bat_priv->tt.changes_list_lock);
 
 	/* Keep the buffer for possible tt_request */
-	spin_lock_bh(&bat_priv->tt_buff_lock);
-	kfree(bat_priv->tt_buff);
-	bat_priv->tt_buff_len = 0;
-	bat_priv->tt_buff = NULL;
+	spin_lock_bh(&bat_priv->tt.last_changeset_lock);
+	kfree(bat_priv->tt.last_changeset);
+	bat_priv->tt.last_changeset_len = 0;
+	bat_priv->tt.last_changeset = NULL;
 	/* check whether this new OGM has no changes due to size problems */
 	if (new_len > 0) {
 		/* if kmalloc() fails we will reply with the full table
 		 * instead of providing the diff
 		 */
-		bat_priv->tt_buff = kmalloc(new_len, GFP_ATOMIC);
-		if (bat_priv->tt_buff) {
-			memcpy(bat_priv->tt_buff, tt_buff, new_len);
-			bat_priv->tt_buff_len = new_len;
+		bat_priv->tt.last_changeset = kmalloc(new_len, GFP_ATOMIC);
+		if (bat_priv->tt.last_changeset) {
+			memcpy(bat_priv->tt.last_changeset, tt_buff, new_len);
+			bat_priv->tt.last_changeset_len = new_len;
 		}
 	}
-	spin_unlock_bh(&bat_priv->tt_buff_lock);
+	spin_unlock_bh(&bat_priv->tt.last_changeset_lock);
 
 	return count;
 }
@@ -423,7 +423,7 @@ int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset)
 {
 	struct net_device *net_dev = (struct net_device *)seq->private;
 	struct batadv_priv *bat_priv = netdev_priv(net_dev);
-	struct batadv_hashtable *hash = bat_priv->tt_local_hash;
+	struct batadv_hashtable *hash = bat_priv->tt.local_hash;
 	struct batadv_tt_common_entry *tt_common_entry;
 	struct batadv_hard_iface *primary_if;
 	struct hlist_node *node;
@@ -448,7 +448,7 @@ int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset)
 
 	seq_printf(seq,
 		   "Locally retrieved addresses (from %s) announced via TT (TTVN: %u):\n",
-		   net_dev->name, (uint8_t)atomic_read(&bat_priv->ttvn));
+		   net_dev->name, (uint8_t)atomic_read(&bat_priv->tt.vn));
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
@@ -546,7 +546,7 @@ static void batadv_tt_local_purge_list(struct batadv_priv *bat_priv,
 
 static void batadv_tt_local_purge(struct batadv_priv *bat_priv)
 {
-	struct batadv_hashtable *hash = bat_priv->tt_local_hash;
+	struct batadv_hashtable *hash = bat_priv->tt.local_hash;
 	struct hlist_head *head;
 	spinlock_t *list_lock; /* protects write access to the hash lists */
 	uint32_t i;
@@ -572,10 +572,10 @@ static void batadv_tt_local_table_free(struct batadv_priv *bat_priv)
 	struct hlist_head *head;
 	uint32_t i;
 
-	if (!bat_priv->tt_local_hash)
+	if (!bat_priv->tt.local_hash)
 		return;
 
-	hash = bat_priv->tt_local_hash;
+	hash = bat_priv->tt.local_hash;
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
@@ -595,17 +595,17 @@ static void batadv_tt_local_table_free(struct batadv_priv *bat_priv)
 
 	batadv_hash_destroy(hash);
 
-	bat_priv->tt_local_hash = NULL;
+	bat_priv->tt.local_hash = NULL;
 }
 
 static int batadv_tt_global_init(struct batadv_priv *bat_priv)
 {
-	if (bat_priv->tt_global_hash)
+	if (bat_priv->tt.global_hash)
 		return 0;
 
-	bat_priv->tt_global_hash = batadv_hash_new(1024);
+	bat_priv->tt.global_hash = batadv_hash_new(1024);
 
-	if (!bat_priv->tt_global_hash)
+	if (!bat_priv->tt.global_hash)
 		return -ENOMEM;
 
 	return 0;
@@ -615,16 +615,16 @@ static void batadv_tt_changes_list_free(struct batadv_priv *bat_priv)
 {
 	struct batadv_tt_change_node *entry, *safe;
 
-	spin_lock_bh(&bat_priv->tt_changes_list_lock);
+	spin_lock_bh(&bat_priv->tt.changes_list_lock);
 
-	list_for_each_entry_safe(entry, safe, &bat_priv->tt_changes_list,
+	list_for_each_entry_safe(entry, safe, &bat_priv->tt.changes_list,
 				 list) {
 		list_del(&entry->list);
 		kfree(entry);
 	}
 
-	atomic_set(&bat_priv->tt_local_changes, 0);
-	spin_unlock_bh(&bat_priv->tt_changes_list_lock);
+	atomic_set(&bat_priv->tt.local_changes, 0);
+	spin_unlock_bh(&bat_priv->tt.changes_list_lock);
 }
 
 /* retrieves the orig_tt_list_entry belonging to orig_node from the
@@ -733,7 +733,7 @@ int batadv_tt_global_add(struct batadv_priv *bat_priv,
 		INIT_HLIST_HEAD(&tt_global_entry->orig_list);
 		spin_lock_init(&tt_global_entry->list_lock);
 
-		hash_added = batadv_hash_add(bat_priv->tt_global_hash,
+		hash_added = batadv_hash_add(bat_priv->tt.global_hash,
 					     batadv_compare_tt,
 					     batadv_choose_orig, common,
 					     &common->hash_entry);
@@ -812,7 +812,7 @@ int batadv_tt_global_seq_print_text(struct seq_file *seq, void *offset)
 {
 	struct net_device *net_dev = (struct net_device *)seq->private;
 	struct batadv_priv *bat_priv = netdev_priv(net_dev);
-	struct batadv_hashtable *hash = bat_priv->tt_global_hash;
+	struct batadv_hashtable *hash = bat_priv->tt.global_hash;
 	struct batadv_tt_common_entry *tt_common_entry;
 	struct batadv_tt_global_entry *tt_global;
 	struct batadv_hard_iface *primary_if;
@@ -913,7 +913,7 @@ batadv_tt_global_del_struct(struct batadv_priv *bat_priv,
 		   "Deleting global tt entry %pM: %s\n",
 		   tt_global_entry->common.addr, message);
 
-	batadv_hash_remove(bat_priv->tt_global_hash, batadv_compare_tt,
+	batadv_hash_remove(bat_priv->tt.global_hash, batadv_compare_tt,
 			   batadv_choose_orig, tt_global_entry->common.addr);
 	batadv_tt_global_entry_free_ref(tt_global_entry);
 
@@ -1024,7 +1024,7 @@ void batadv_tt_global_del_orig(struct batadv_priv *bat_priv,
 	struct batadv_tt_global_entry *tt_global;
 	struct batadv_tt_common_entry *tt_common_entry;
 	uint32_t i;
-	struct batadv_hashtable *hash = bat_priv->tt_global_hash;
+	struct batadv_hashtable *hash = bat_priv->tt.global_hash;
 	struct hlist_node *node, *safe;
 	struct hlist_head *head;
 	spinlock_t *list_lock; /* protects write access to the hash lists */
@@ -1088,7 +1088,7 @@ static void batadv_tt_global_roam_purge_list(struct batadv_priv *bat_priv,
 
 static void batadv_tt_global_roam_purge(struct batadv_priv *bat_priv)
 {
-	struct batadv_hashtable *hash = bat_priv->tt_global_hash;
+	struct batadv_hashtable *hash = bat_priv->tt.global_hash;
 	struct hlist_head *head;
 	spinlock_t *list_lock; /* protects write access to the hash lists */
 	uint32_t i;
@@ -1114,10 +1114,10 @@ static void batadv_tt_global_table_free(struct batadv_priv *bat_priv)
 	struct hlist_head *head;
 	uint32_t i;
 
-	if (!bat_priv->tt_global_hash)
+	if (!bat_priv->tt.global_hash)
 		return;
 
-	hash = bat_priv->tt_global_hash;
+	hash = bat_priv->tt.global_hash;
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
@@ -1137,7 +1137,7 @@ static void batadv_tt_global_table_free(struct batadv_priv *bat_priv)
 
 	batadv_hash_destroy(hash);
 
-	bat_priv->tt_global_hash = NULL;
+	bat_priv->tt.global_hash = NULL;
 }
 
 static bool
@@ -1216,7 +1216,7 @@ static uint16_t batadv_tt_global_crc(struct batadv_priv *bat_priv,
 				     struct batadv_orig_node *orig_node)
 {
 	uint16_t total = 0, total_one;
-	struct batadv_hashtable *hash = bat_priv->tt_global_hash;
+	struct batadv_hashtable *hash = bat_priv->tt.global_hash;
 	struct batadv_tt_common_entry *tt_common;
 	struct batadv_tt_global_entry *tt_global;
 	struct hlist_node *node;
@@ -1263,7 +1263,7 @@ static uint16_t batadv_tt_global_crc(struct batadv_priv *bat_priv,
 static uint16_t batadv_tt_local_crc(struct batadv_priv *bat_priv)
 {
 	uint16_t total = 0, total_one;
-	struct batadv_hashtable *hash = bat_priv->tt_local_hash;
+	struct batadv_hashtable *hash = bat_priv->tt.local_hash;
 	struct batadv_tt_common_entry *tt_common;
 	struct hlist_node *node;
 	struct hlist_head *head;
@@ -1296,14 +1296,14 @@ static void batadv_tt_req_list_free(struct batadv_priv *bat_priv)
 {
 	struct batadv_tt_req_node *node, *safe;
 
-	spin_lock_bh(&bat_priv->tt_req_list_lock);
+	spin_lock_bh(&bat_priv->tt.req_list_lock);
 
-	list_for_each_entry_safe(node, safe, &bat_priv->tt_req_list, list) {
+	list_for_each_entry_safe(node, safe, &bat_priv->tt.req_list, list) {
 		list_del(&node->list);
 		kfree(node);
 	}
 
-	spin_unlock_bh(&bat_priv->tt_req_list_lock);
+	spin_unlock_bh(&bat_priv->tt.req_list_lock);
 }
 
 static void batadv_tt_save_orig_buffer(struct batadv_priv *bat_priv,
@@ -1333,15 +1333,15 @@ static void batadv_tt_req_purge(struct batadv_priv *bat_priv)
 {
 	struct batadv_tt_req_node *node, *safe;
 
-	spin_lock_bh(&bat_priv->tt_req_list_lock);
-	list_for_each_entry_safe(node, safe, &bat_priv->tt_req_list, list) {
+	spin_lock_bh(&bat_priv->tt.req_list_lock);
+	list_for_each_entry_safe(node, safe, &bat_priv->tt.req_list, list) {
 		if (batadv_has_timed_out(node->issued_at,
 					 BATADV_TT_REQUEST_TIMEOUT)) {
 			list_del(&node->list);
 			kfree(node);
 		}
 	}
-	spin_unlock_bh(&bat_priv->tt_req_list_lock);
+	spin_unlock_bh(&bat_priv->tt.req_list_lock);
 }
 
 /* returns the pointer to the new tt_req_node struct if no request
@@ -1353,8 +1353,8 @@ batadv_new_tt_req_node(struct batadv_priv *bat_priv,
 {
 	struct batadv_tt_req_node *tt_req_node_tmp, *tt_req_node = NULL;
 
-	spin_lock_bh(&bat_priv->tt_req_list_lock);
-	list_for_each_entry(tt_req_node_tmp, &bat_priv->tt_req_list, list) {
+	spin_lock_bh(&bat_priv->tt.req_list_lock);
+	list_for_each_entry(tt_req_node_tmp, &bat_priv->tt.req_list, list) {
 		if (batadv_compare_eth(tt_req_node_tmp, orig_node) &&
 		    !batadv_has_timed_out(tt_req_node_tmp->issued_at,
 					  BATADV_TT_REQUEST_TIMEOUT))
@@ -1368,9 +1368,9 @@ batadv_new_tt_req_node(struct batadv_priv *bat_priv,
 	memcpy(tt_req_node->addr, orig_node->orig, ETH_ALEN);
 	tt_req_node->issued_at = jiffies;
 
-	list_add(&tt_req_node->list, &bat_priv->tt_req_list);
+	list_add(&tt_req_node->list, &bat_priv->tt.req_list);
 unlock:
-	spin_unlock_bh(&bat_priv->tt_req_list_lock);
+	spin_unlock_bh(&bat_priv->tt.req_list_lock);
 	return tt_req_node;
 }
 
@@ -1536,9 +1536,9 @@ out:
 	if (ret)
 		kfree_skb(skb);
 	if (ret && tt_req_node) {
-		spin_lock_bh(&bat_priv->tt_req_list_lock);
+		spin_lock_bh(&bat_priv->tt.req_list_lock);
 		list_del(&tt_req_node->list);
-		spin_unlock_bh(&bat_priv->tt_req_list_lock);
+		spin_unlock_bh(&bat_priv->tt.req_list_lock);
 		kfree(tt_req_node);
 	}
 	return ret;
@@ -1629,7 +1629,7 @@ batadv_send_other_tt_response(struct batadv_priv *bat_priv,
 		ttvn = (uint8_t)atomic_read(&req_dst_orig_node->last_ttvn);
 
 		skb = batadv_tt_response_fill_table(tt_len, ttvn,
-						    bat_priv->tt_global_hash,
+						    bat_priv->tt.global_hash,
 						    primary_if,
 						    batadv_tt_global_valid,
 						    req_dst_orig_node);
@@ -1700,7 +1700,7 @@ batadv_send_my_tt_response(struct batadv_priv *bat_priv,
 		   (tt_request->flags & BATADV_TT_FULL_TABLE ? 'F' : '.'));
 
 
-	my_ttvn = (uint8_t)atomic_read(&bat_priv->ttvn);
+	my_ttvn = (uint8_t)atomic_read(&bat_priv->tt.vn);
 	req_ttvn = tt_request->ttvn;
 
 	orig_node = batadv_orig_hash_find(bat_priv, tt_request->src);
@@ -1719,7 +1719,7 @@ batadv_send_my_tt_response(struct batadv_priv *bat_priv,
 	 * is too big send the whole local translation table
 	 */
 	if (tt_request->flags & BATADV_TT_FULL_TABLE || my_ttvn != req_ttvn ||
-	    !bat_priv->tt_buff)
+	    !bat_priv->tt.last_changeset)
 		full_table = true;
 	else
 		full_table = false;
@@ -1728,8 +1728,8 @@ batadv_send_my_tt_response(struct batadv_priv *bat_priv,
 	 * I'll send only one packet with as much TT entries as I can
 	 */
 	if (!full_table) {
-		spin_lock_bh(&bat_priv->tt_buff_lock);
-		tt_len = bat_priv->tt_buff_len;
+		spin_lock_bh(&bat_priv->tt.last_changeset_lock);
+		tt_len = bat_priv->tt.last_changeset_len;
 		tt_tot = tt_len / sizeof(struct batadv_tt_change);
 
 		len = sizeof(*tt_response) + tt_len;
@@ -1744,16 +1744,16 @@ batadv_send_my_tt_response(struct batadv_priv *bat_priv,
 		tt_response->tt_data = htons(tt_tot);
 
 		tt_buff = skb->data + sizeof(*tt_response);
-		memcpy(tt_buff, bat_priv->tt_buff,
-		       bat_priv->tt_buff_len);
-		spin_unlock_bh(&bat_priv->tt_buff_lock);
+		memcpy(tt_buff, bat_priv->tt.last_changeset,
+		       bat_priv->tt.last_changeset_len);
+		spin_unlock_bh(&bat_priv->tt.last_changeset_lock);
 	} else {
-		tt_len = (uint16_t)atomic_read(&bat_priv->num_local_tt);
+		tt_len = (uint16_t)atomic_read(&bat_priv->tt.local_entry_num);
 		tt_len *= sizeof(struct batadv_tt_change);
-		ttvn = (uint8_t)atomic_read(&bat_priv->ttvn);
+		ttvn = (uint8_t)atomic_read(&bat_priv->tt.vn);
 
 		skb = batadv_tt_response_fill_table(tt_len, ttvn,
-						    bat_priv->tt_local_hash,
+						    bat_priv->tt.local_hash,
 						    primary_if,
 						    batadv_tt_local_valid_entry,
 						    NULL);
@@ -1785,7 +1785,7 @@ batadv_send_my_tt_response(struct batadv_priv *bat_priv,
 	goto out;
 
 unlock:
-	spin_unlock_bh(&bat_priv->tt_buff_lock);
+	spin_unlock_bh(&bat_priv->tt.last_changeset_lock);
 out:
 	if (orig_node)
 		batadv_orig_node_free_ref(orig_node);
@@ -1938,14 +1938,14 @@ void batadv_handle_tt_response(struct batadv_priv *bat_priv,
 	}
 
 	/* Delete the tt_req_node from pending tt_requests list */
-	spin_lock_bh(&bat_priv->tt_req_list_lock);
-	list_for_each_entry_safe(node, safe, &bat_priv->tt_req_list, list) {
+	spin_lock_bh(&bat_priv->tt.req_list_lock);
+	list_for_each_entry_safe(node, safe, &bat_priv->tt.req_list, list) {
 		if (!batadv_compare_eth(node->addr, tt_response->src))
 			continue;
 		list_del(&node->list);
 		kfree(node);
 	}
-	spin_unlock_bh(&bat_priv->tt_req_list_lock);
+	spin_unlock_bh(&bat_priv->tt.req_list_lock);
 
 	/* Recalculate the CRC for this orig_node and store it */
 	orig_node->tt_crc = batadv_tt_global_crc(bat_priv, orig_node);
@@ -1979,22 +1979,22 @@ static void batadv_tt_roam_list_free(struct batadv_priv *bat_priv)
 {
 	struct batadv_tt_roam_node *node, *safe;
 
-	spin_lock_bh(&bat_priv->tt_roam_list_lock);
+	spin_lock_bh(&bat_priv->tt.roam_list_lock);
 
-	list_for_each_entry_safe(node, safe, &bat_priv->tt_roam_list, list) {
+	list_for_each_entry_safe(node, safe, &bat_priv->tt.roam_list, list) {
 		list_del(&node->list);
 		kfree(node);
 	}
 
-	spin_unlock_bh(&bat_priv->tt_roam_list_lock);
+	spin_unlock_bh(&bat_priv->tt.roam_list_lock);
 }
 
 static void batadv_tt_roam_purge(struct batadv_priv *bat_priv)
 {
 	struct batadv_tt_roam_node *node, *safe;
 
-	spin_lock_bh(&bat_priv->tt_roam_list_lock);
-	list_for_each_entry_safe(node, safe, &bat_priv->tt_roam_list, list) {
+	spin_lock_bh(&bat_priv->tt.roam_list_lock);
+	list_for_each_entry_safe(node, safe, &bat_priv->tt.roam_list, list) {
 		if (!batadv_has_timed_out(node->first_time,
 					  BATADV_ROAMING_MAX_TIME))
 			continue;
@@ -2002,7 +2002,7 @@ static void batadv_tt_roam_purge(struct batadv_priv *bat_priv)
 		list_del(&node->list);
 		kfree(node);
 	}
-	spin_unlock_bh(&bat_priv->tt_roam_list_lock);
+	spin_unlock_bh(&bat_priv->tt.roam_list_lock);
 }
 
 /* This function checks whether the client already reached the
@@ -2017,11 +2017,11 @@ static bool batadv_tt_check_roam_count(struct batadv_priv *bat_priv,
 	struct batadv_tt_roam_node *tt_roam_node;
 	bool ret = false;
 
-	spin_lock_bh(&bat_priv->tt_roam_list_lock);
+	spin_lock_bh(&bat_priv->tt.roam_list_lock);
 	/* The new tt_req will be issued only if I'm not waiting for a
 	 * reply from the same orig_node yet
 	 */
-	list_for_each_entry(tt_roam_node, &bat_priv->tt_roam_list, list) {
+	list_for_each_entry(tt_roam_node, &bat_priv->tt.roam_list, list) {
 		if (!batadv_compare_eth(tt_roam_node->addr, client))
 			continue;
 
@@ -2046,12 +2046,12 @@ static bool batadv_tt_check_roam_count(struct batadv_priv *bat_priv,
 			   BATADV_ROAMING_MAX_COUNT - 1);
 		memcpy(tt_roam_node->addr, client, ETH_ALEN);
 
-		list_add(&tt_roam_node->list, &bat_priv->tt_roam_list);
+		list_add(&tt_roam_node->list, &bat_priv->tt.roam_list);
 		ret = true;
 	}
 
 unlock:
-	spin_unlock_bh(&bat_priv->tt_roam_list_lock);
+	spin_unlock_bh(&bat_priv->tt.roam_list_lock);
 	return ret;
 }
 
@@ -2115,10 +2115,12 @@ out:
 static void batadv_tt_purge(struct work_struct *work)
 {
 	struct delayed_work *delayed_work;
+	struct batadv_priv_tt *priv_tt;
 	struct batadv_priv *bat_priv;
 
 	delayed_work = container_of(work, struct delayed_work, work);
-	bat_priv = container_of(delayed_work, struct batadv_priv, tt_work);
+	priv_tt = container_of(delayed_work, struct batadv_priv_tt, work);
+	bat_priv = container_of(priv_tt, struct batadv_priv, tt);
 
 	batadv_tt_local_purge(bat_priv);
 	batadv_tt_global_roam_purge(bat_priv);
@@ -2130,7 +2132,7 @@ static void batadv_tt_purge(struct work_struct *work)
 
 void batadv_tt_free(struct batadv_priv *bat_priv)
 {
-	cancel_delayed_work_sync(&bat_priv->tt_work);
+	cancel_delayed_work_sync(&bat_priv->tt.work);
 
 	batadv_tt_local_table_free(bat_priv);
 	batadv_tt_global_table_free(bat_priv);
@@ -2138,7 +2140,7 @@ void batadv_tt_free(struct batadv_priv *bat_priv)
 	batadv_tt_changes_list_free(bat_priv);
 	batadv_tt_roam_list_free(bat_priv);
 
-	kfree(bat_priv->tt_buff);
+	kfree(bat_priv->tt.last_changeset);
 }
 
 /* This function will enable or disable the specified flags for all the entries
@@ -2182,7 +2184,7 @@ out:
 /* Purge out all the tt local entries marked with BATADV_TT_CLIENT_PENDING */
 static void batadv_tt_local_purge_pending_clients(struct batadv_priv *bat_priv)
 {
-	struct batadv_hashtable *hash = bat_priv->tt_local_hash;
+	struct batadv_hashtable *hash = bat_priv->tt.local_hash;
 	struct batadv_tt_common_entry *tt_common;
 	struct batadv_tt_local_entry *tt_local;
 	struct hlist_node *node, *node_tmp;
@@ -2207,7 +2209,7 @@ static void batadv_tt_local_purge_pending_clients(struct batadv_priv *bat_priv)
 				   "Deleting local tt entry (%pM): pending\n",
 				   tt_common->addr);
 
-			atomic_dec(&bat_priv->num_local_tt);
+			atomic_dec(&bat_priv->tt.local_entry_num);
 			hlist_del_rcu(node);
 			tt_local = container_of(tt_common,
 						struct batadv_tt_local_entry,
@@ -2225,26 +2227,26 @@ static int batadv_tt_commit_changes(struct batadv_priv *bat_priv,
 {
 	uint16_t changed_num = 0;
 
-	if (atomic_read(&bat_priv->tt_local_changes) < 1)
+	if (atomic_read(&bat_priv->tt.local_changes) < 1)
 		return -ENOENT;
 
-	changed_num = batadv_tt_set_flags(bat_priv->tt_local_hash,
+	changed_num = batadv_tt_set_flags(bat_priv->tt.local_hash,
 					  BATADV_TT_CLIENT_NEW, false);
 
 	/* all reset entries have to be counted as local entries */
-	atomic_add(changed_num, &bat_priv->num_local_tt);
+	atomic_add(changed_num, &bat_priv->tt.local_entry_num);
 	batadv_tt_local_purge_pending_clients(bat_priv);
-	bat_priv->tt_crc = batadv_tt_local_crc(bat_priv);
+	bat_priv->tt.local_crc = batadv_tt_local_crc(bat_priv);
 
 	/* Increment the TTVN only once per OGM interval */
-	atomic_inc(&bat_priv->ttvn);
+	atomic_inc(&bat_priv->tt.vn);
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Local changes committed, updating to ttvn %u\n",
-		   (uint8_t)atomic_read(&bat_priv->ttvn));
-	bat_priv->tt_poss_change = false;
+		   (uint8_t)atomic_read(&bat_priv->tt.vn));
+	bat_priv->tt.poss_change = false;
 
 	/* reset the sending counter */
-	atomic_set(&bat_priv->tt_ogm_append_cnt, BATADV_TT_OGM_APPEND_MAX);
+	atomic_set(&bat_priv->tt.ogm_append_cnt, BATADV_TT_OGM_APPEND_MAX);
 
 	return batadv_tt_changes_fill_buff(bat_priv, packet_buff,
 					   packet_buff_len, packet_min_len);
@@ -2264,7 +2266,7 @@ int batadv_tt_append_diff(struct batadv_priv *bat_priv,
 
 	/* if the changes have been sent often enough */
 	if ((tt_num_changes < 0) &&
-	    (!batadv_atomic_dec_not_zero(&bat_priv->tt_ogm_append_cnt))) {
+	    (!batadv_atomic_dec_not_zero(&bat_priv->tt.ogm_append_cnt))) {
 		batadv_tt_realloc_packet_buff(packet_buff, packet_buff_len,
 					      packet_min_len, packet_min_len);
 		tt_num_changes = 0;
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 664ef81..97c4978 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -165,6 +165,67 @@ enum batadv_counters {
 	BATADV_CNT_NUM,
 };
 
+/**
+ * struct batadv_priv_tt - per mesh interface translation table data
+ * @vn: translation table version number
+ * @local_changes: changes registered in an originator interval
+ * @poss_change: Detect an ongoing roaming phase. If true, then this node
+ *  received a roaming_adv and has to inspect every packet directed to it to
+ *  check whether it still is the true destination or not. This flag will be
+ *  reset to false as soon as the this node's ttvn is increased
+ * @changes_list: tracks tt local changes within an originator interval
+ * @req_list: list of pending tt_requests
+ * @local_crc: Checksum of the local table, recomputed before sending a new OGM
+ */
+struct batadv_priv_tt {
+	atomic_t vn;
+	atomic_t ogm_append_cnt;
+	atomic_t local_changes;
+	bool poss_change;
+	struct list_head changes_list;
+	struct batadv_hashtable *local_hash;
+	struct batadv_hashtable *global_hash;
+	struct list_head req_list;
+	struct list_head roam_list;
+	spinlock_t changes_list_lock; /* protects changes */
+	spinlock_t req_list_lock; /* protects req_list */
+	spinlock_t roam_list_lock; /* protects roam_list */
+	atomic_t local_entry_num;
+	uint16_t local_crc;
+	unsigned char *last_changeset;
+	int16_t last_changeset_len;
+	spinlock_t last_changeset_lock; /* protects last_changeset */
+	struct delayed_work work;
+};
+
+#ifdef CONFIG_BATMAN_ADV_BLA
+struct batadv_priv_bla {
+	atomic_t num_requests; /* number of bla requests in flight */
+	struct batadv_hashtable *claim_hash;
+	struct batadv_hashtable *backbone_hash;
+	struct batadv_bcast_duplist_entry bcast_duplist[BATADV_DUPLIST_SIZE];
+	int bcast_duplist_curr;
+	struct batadv_bla_claim_dst claim_dest;
+	struct delayed_work work;
+};
+#endif
+
+struct batadv_priv_gw {
+	struct hlist_head list;
+	spinlock_t list_lock; /* protects gw_list and curr_gw */
+	struct batadv_gw_node __rcu *curr_gw;  /* rcu protected pointer */
+	atomic_t reselect;
+};
+
+struct batadv_priv_vis {
+	struct list_head send_list;
+	struct batadv_hashtable *hash;
+	spinlock_t hash_lock; /* protects hash */
+	spinlock_t list_lock; /* protects info::recv_list */
+	struct delayed_work work;
+	struct batadv_vis_info *my_info;
+};
+
 struct batadv_priv {
 	atomic_t mesh_state;
 	struct net_device_stats stats;
@@ -184,64 +245,24 @@ struct batadv_priv {
 	atomic_t bcast_seqno;
 	atomic_t bcast_queue_left;
 	atomic_t batman_queue_left;
-	atomic_t ttvn; /* translation table version number */
-	atomic_t tt_ogm_append_cnt;
-	atomic_t tt_local_changes; /* changes registered in a OGM interval */
-	atomic_t bla_num_requests; /* number of bla requests in flight */
-	/* The tt_poss_change flag is used to detect an ongoing roaming phase.
-	 * If true, then I received a Roaming_adv and I have to inspect every
-	 * packet directed to me to check whether I am still the true
-	 * destination or not. This flag will be reset to false as soon as I
-	 * increase my TTVN
-	 */
-	bool tt_poss_change;
 	char num_ifaces;
 	struct batadv_debug_log *debug_log;
 	struct kobject *mesh_obj;
 	struct dentry *debug_dir;
 	struct hlist_head forw_bat_list;
 	struct hlist_head forw_bcast_list;
-	struct hlist_head gw_list;
-	struct list_head tt_changes_list; /* tracks changes in a OGM int */
-	struct list_head vis_send_list;
 	struct batadv_hashtable *orig_hash;
-	struct batadv_hashtable *tt_local_hash;
-	struct batadv_hashtable *tt_global_hash;
-#ifdef CONFIG_BATMAN_ADV_BLA
-	struct batadv_hashtable *claim_hash;
-	struct batadv_hashtable *backbone_hash;
-#endif
-	struct list_head tt_req_list; /* list of pending tt_requests */
-	struct list_head tt_roam_list;
-	struct batadv_hashtable *vis_hash;
-#ifdef CONFIG_BATMAN_ADV_BLA
-	struct batadv_bcast_duplist_entry bcast_duplist[BATADV_DUPLIST_SIZE];
-	int bcast_duplist_curr;
-	struct batadv_bla_claim_dst claim_dest;
-#endif
 	spinlock_t forw_bat_list_lock; /* protects forw_bat_list */
 	spinlock_t forw_bcast_list_lock; /* protects  */
-	spinlock_t tt_changes_list_lock; /* protects tt_changes */
-	spinlock_t tt_req_list_lock; /* protects tt_req_list */
-	spinlock_t tt_roam_list_lock; /* protects tt_roam_list */
-	spinlock_t gw_list_lock; /* protects gw_list and curr_gw */
-	spinlock_t vis_hash_lock; /* protects vis_hash */
-	spinlock_t vis_list_lock; /* protects vis_info::recv_list */
-	atomic_t num_local_tt;
-	/* Checksum of the local table, recomputed before sending a new OGM */
-	uint16_t tt_crc;
-	unsigned char *tt_buff;
-	int16_t tt_buff_len;
-	spinlock_t tt_buff_lock; /* protects tt_buff */
-	struct delayed_work tt_work;
 	struct delayed_work orig_work;
-	struct delayed_work vis_work;
-	struct delayed_work bla_work;
-	struct batadv_gw_node __rcu *curr_gw;  /* rcu protected pointer */
-	atomic_t gw_reselect;
 	struct batadv_hard_iface __rcu *primary_if;  /* rcu protected pointer */
-	struct batadv_vis_info *my_vis_info;
 	struct batadv_algo_ops *bat_algo_ops;
+#ifdef CONFIG_BATMAN_ADV_BLA
+	struct batadv_priv_bla bla;
+#endif
+	struct batadv_priv_gw gw;
+	struct batadv_priv_tt tt;
+	struct batadv_priv_vis vis;
 };
 
 struct batadv_socket_client {
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 2a2ea06..4608c1b2 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -41,13 +41,13 @@ static void batadv_free_info(struct kref *ref)
 	bat_priv = info->bat_priv;
 
 	list_del_init(&info->send_list);
-	spin_lock_bh(&bat_priv->vis_list_lock);
+	spin_lock_bh(&bat_priv->vis.list_lock);
 	list_for_each_entry_safe(entry, tmp, &info->recv_list, list) {
 		list_del(&entry->list);
 		kfree(entry);
 	}
 
-	spin_unlock_bh(&bat_priv->vis_list_lock);
+	spin_unlock_bh(&bat_priv->vis.list_lock);
 	kfree_skb(info->skb_packet);
 	kfree(info);
 }
@@ -94,7 +94,7 @@ static uint32_t batadv_vis_info_choose(const void *data, uint32_t size)
 static struct batadv_vis_info *
 batadv_vis_hash_find(struct batadv_priv *bat_priv, const void *data)
 {
-	struct batadv_hashtable *hash = bat_priv->vis_hash;
+	struct batadv_hashtable *hash = bat_priv->vis.hash;
 	struct hlist_head *head;
 	struct hlist_node *node;
 	struct batadv_vis_info *vis_info, *vis_info_tmp = NULL;
@@ -252,7 +252,7 @@ int batadv_vis_seq_print_text(struct seq_file *seq, void *offset)
 	struct hlist_head *head;
 	struct net_device *net_dev = (struct net_device *)seq->private;
 	struct batadv_priv *bat_priv = netdev_priv(net_dev);
-	struct batadv_hashtable *hash = bat_priv->vis_hash;
+	struct batadv_hashtable *hash = bat_priv->vis.hash;
 	uint32_t i;
 	int ret = 0;
 	int vis_server = atomic_read(&bat_priv->vis_mode);
@@ -264,12 +264,12 @@ int batadv_vis_seq_print_text(struct seq_file *seq, void *offset)
 	if (vis_server == BATADV_VIS_TYPE_CLIENT_UPDATE)
 		goto out;
 
-	spin_lock_bh(&bat_priv->vis_hash_lock);
+	spin_lock_bh(&bat_priv->vis.hash_lock);
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 		batadv_vis_seq_print_text_bucket(seq, head);
 	}
-	spin_unlock_bh(&bat_priv->vis_hash_lock);
+	spin_unlock_bh(&bat_priv->vis.hash_lock);
 
 out:
 	if (primary_if)
@@ -285,7 +285,7 @@ static void batadv_send_list_add(struct batadv_priv *bat_priv,
 {
 	if (list_empty(&info->send_list)) {
 		kref_get(&info->refcount);
-		list_add_tail(&info->send_list, &bat_priv->vis_send_list);
+		list_add_tail(&info->send_list, &bat_priv->vis.send_list);
 	}
 }
 
@@ -311,9 +311,9 @@ static void batadv_recv_list_add(struct batadv_priv *bat_priv,
 		return;
 
 	memcpy(entry->mac, mac, ETH_ALEN);
-	spin_lock_bh(&bat_priv->vis_list_lock);
+	spin_lock_bh(&bat_priv->vis.list_lock);
 	list_add_tail(&entry->list, recv_list);
-	spin_unlock_bh(&bat_priv->vis_list_lock);
+	spin_unlock_bh(&bat_priv->vis.list_lock);
 }
 
 /* returns 1 if this mac is in the recv_list */
@@ -323,14 +323,14 @@ static int batadv_recv_list_is_in(struct batadv_priv *bat_priv,
 {
 	const struct batadv_recvlist_node *entry;
 
-	spin_lock_bh(&bat_priv->vis_list_lock);
+	spin_lock_bh(&bat_priv->vis.list_lock);
 	list_for_each_entry(entry, recv_list, list) {
 		if (batadv_compare_eth(entry->mac, mac)) {
-			spin_unlock_bh(&bat_priv->vis_list_lock);
+			spin_unlock_bh(&bat_priv->vis.list_lock);
 			return 1;
 		}
 	}
-	spin_unlock_bh(&bat_priv->vis_list_lock);
+	spin_unlock_bh(&bat_priv->vis.list_lock);
 	return 0;
 }
 
@@ -354,7 +354,7 @@ batadv_add_packet(struct batadv_priv *bat_priv,
 
 	*is_new = 0;
 	/* sanity check */
-	if (!bat_priv->vis_hash)
+	if (!bat_priv->vis.hash)
 		return NULL;
 
 	/* see if the packet is already in vis_hash */
@@ -385,7 +385,7 @@ batadv_add_packet(struct batadv_priv *bat_priv,
 			}
 		}
 		/* remove old entry */
-		batadv_hash_remove(bat_priv->vis_hash, batadv_vis_info_cmp,
+		batadv_hash_remove(bat_priv->vis.hash, batadv_vis_info_cmp,
 				   batadv_vis_info_choose, old_info);
 		batadv_send_list_del(old_info);
 		kref_put(&old_info->refcount, batadv_free_info);
@@ -426,7 +426,7 @@ batadv_add_packet(struct batadv_priv *bat_priv,
 	batadv_recv_list_add(bat_priv, &info->recv_list, packet->sender_orig);
 
 	/* try to add it */
-	hash_added = batadv_hash_add(bat_priv->vis_hash, batadv_vis_info_cmp,
+	hash_added = batadv_hash_add(bat_priv->vis.hash, batadv_vis_info_cmp,
 				     batadv_vis_info_choose, info,
 				     &info->hash_entry);
 	if (hash_added != 0) {
@@ -449,7 +449,7 @@ void batadv_receive_server_sync_packet(struct batadv_priv *bat_priv,
 
 	make_broadcast = (vis_server == BATADV_VIS_TYPE_SERVER_SYNC);
 
-	spin_lock_bh(&bat_priv->vis_hash_lock);
+	spin_lock_bh(&bat_priv->vis.hash_lock);
 	info = batadv_add_packet(bat_priv, vis_packet, vis_info_len,
 				 &is_new, make_broadcast);
 	if (!info)
@@ -461,7 +461,7 @@ void batadv_receive_server_sync_packet(struct batadv_priv *bat_priv,
 	if (vis_server == BATADV_VIS_TYPE_SERVER_SYNC && is_new)
 		batadv_send_list_add(bat_priv, info);
 end:
-	spin_unlock_bh(&bat_priv->vis_hash_lock);
+	spin_unlock_bh(&bat_priv->vis.hash_lock);
 }
 
 /* handle an incoming client update packet and schedule forward if needed. */
@@ -484,7 +484,7 @@ void batadv_receive_client_update_packet(struct batadv_priv *bat_priv,
 	    batadv_is_my_mac(vis_packet->target_orig))
 		are_target = 1;
 
-	spin_lock_bh(&bat_priv->vis_hash_lock);
+	spin_lock_bh(&bat_priv->vis.hash_lock);
 	info = batadv_add_packet(bat_priv, vis_packet, vis_info_len,
 				 &is_new, are_target);
 
@@ -505,7 +505,7 @@ void batadv_receive_client_update_packet(struct batadv_priv *bat_priv,
 	}
 
 end:
-	spin_unlock_bh(&bat_priv->vis_hash_lock);
+	spin_unlock_bh(&bat_priv->vis.hash_lock);
 }
 
 /* Walk the originators and find the VIS server with the best tq. Set the packet
@@ -574,7 +574,7 @@ static int batadv_generate_vis_packet(struct batadv_priv *bat_priv)
 	struct hlist_head *head;
 	struct batadv_orig_node *orig_node;
 	struct batadv_neigh_node *router;
-	struct batadv_vis_info *info = bat_priv->my_vis_info;
+	struct batadv_vis_info *info = bat_priv->vis.my_info;
 	struct batadv_vis_packet *packet;
 	struct batadv_vis_info_entry *entry;
 	struct batadv_tt_common_entry *tt_common_entry;
@@ -636,7 +636,7 @@ next:
 		rcu_read_unlock();
 	}
 
-	hash = bat_priv->tt_local_hash;
+	hash = bat_priv->tt.local_hash;
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
@@ -671,7 +671,7 @@ unlock:
 static void batadv_purge_vis_packets(struct batadv_priv *bat_priv)
 {
 	uint32_t i;
-	struct batadv_hashtable *hash = bat_priv->vis_hash;
+	struct batadv_hashtable *hash = bat_priv->vis.hash;
 	struct hlist_node *node, *node_tmp;
 	struct hlist_head *head;
 	struct batadv_vis_info *info;
@@ -682,7 +682,7 @@ static void batadv_purge_vis_packets(struct batadv_priv *bat_priv)
 		hlist_for_each_entry_safe(info, node, node_tmp,
 					  head, hash_entry) {
 			/* never purge own data. */
-			if (info == bat_priv->my_vis_info)
+			if (info == bat_priv->vis.my_info)
 				continue;
 
 			if (batadv_has_timed_out(info->first_seen,
@@ -817,31 +817,33 @@ static void batadv_send_vis_packets(struct work_struct *work)
 	struct delayed_work *delayed_work =
 		container_of(work, struct delayed_work, work);
 	struct batadv_priv *bat_priv;
+	struct batadv_priv_vis *priv_vis;
 	struct batadv_vis_info *info;
 
-	bat_priv = container_of(delayed_work, struct batadv_priv, vis_work);
-	spin_lock_bh(&bat_priv->vis_hash_lock);
+	priv_vis = container_of(delayed_work, struct batadv_priv_vis, work);
+	bat_priv = container_of(priv_vis, struct batadv_priv, vis);
+	spin_lock_bh(&bat_priv->vis.hash_lock);
 	batadv_purge_vis_packets(bat_priv);
 
 	if (batadv_generate_vis_packet(bat_priv) == 0) {
 		/* schedule if generation was successful */
-		batadv_send_list_add(bat_priv, bat_priv->my_vis_info);
+		batadv_send_list_add(bat_priv, bat_priv->vis.my_info);
 	}
 
-	while (!list_empty(&bat_priv->vis_send_list)) {
-		info = list_first_entry(&bat_priv->vis_send_list,
+	while (!list_empty(&bat_priv->vis.send_list)) {
+		info = list_first_entry(&bat_priv->vis.send_list,
 					typeof(*info), send_list);
 
 		kref_get(&info->refcount);
-		spin_unlock_bh(&bat_priv->vis_hash_lock);
+		spin_unlock_bh(&bat_priv->vis.hash_lock);
 
 		batadv_send_vis_packet(bat_priv, info);
 
-		spin_lock_bh(&bat_priv->vis_hash_lock);
+		spin_lock_bh(&bat_priv->vis.hash_lock);
 		batadv_send_list_del(info);
 		kref_put(&info->refcount, batadv_free_info);
 	}
-	spin_unlock_bh(&bat_priv->vis_hash_lock);
+	spin_unlock_bh(&bat_priv->vis.hash_lock);
 	batadv_start_vis_timer(bat_priv);
 }
 
@@ -856,37 +858,37 @@ int batadv_vis_init(struct batadv_priv *bat_priv)
 	unsigned long first_seen;
 	struct sk_buff *tmp_skb;
 
-	if (bat_priv->vis_hash)
+	if (bat_priv->vis.hash)
 		return 0;
 
-	spin_lock_bh(&bat_priv->vis_hash_lock);
+	spin_lock_bh(&bat_priv->vis.hash_lock);
 
-	bat_priv->vis_hash = batadv_hash_new(256);
-	if (!bat_priv->vis_hash) {
+	bat_priv->vis.hash = batadv_hash_new(256);
+	if (!bat_priv->vis.hash) {
 		pr_err("Can't initialize vis_hash\n");
 		goto err;
 	}
 
-	bat_priv->my_vis_info = kmalloc(BATADV_MAX_VIS_PACKET_SIZE, GFP_ATOMIC);
-	if (!bat_priv->my_vis_info)
+	bat_priv->vis.my_info = kmalloc(BATADV_MAX_VIS_PACKET_SIZE, GFP_ATOMIC);
+	if (!bat_priv->vis.my_info)
 		goto err;
 
 	len = sizeof(*packet) + BATADV_MAX_VIS_PACKET_SIZE + ETH_HLEN;
-	bat_priv->my_vis_info->skb_packet = dev_alloc_skb(len);
-	if (!bat_priv->my_vis_info->skb_packet)
+	bat_priv->vis.my_info->skb_packet = dev_alloc_skb(len);
+	if (!bat_priv->vis.my_info->skb_packet)
 		goto free_info;
 
-	skb_reserve(bat_priv->my_vis_info->skb_packet, ETH_HLEN);
-	tmp_skb = bat_priv->my_vis_info->skb_packet;
+	skb_reserve(bat_priv->vis.my_info->skb_packet, ETH_HLEN);
+	tmp_skb = bat_priv->vis.my_info->skb_packet;
 	packet = (struct batadv_vis_packet *)skb_put(tmp_skb, sizeof(*packet));
 
 	/* prefill the vis info */
 	first_seen = jiffies - msecs_to_jiffies(BATADV_VIS_INTERVAL);
-	bat_priv->my_vis_info->first_seen = first_seen;
-	INIT_LIST_HEAD(&bat_priv->my_vis_info->recv_list);
-	INIT_LIST_HEAD(&bat_priv->my_vis_info->send_list);
-	kref_init(&bat_priv->my_vis_info->refcount);
-	bat_priv->my_vis_info->bat_priv = bat_priv;
+	bat_priv->vis.my_info->first_seen = first_seen;
+	INIT_LIST_HEAD(&bat_priv->vis.my_info->recv_list);
+	INIT_LIST_HEAD(&bat_priv->vis.my_info->send_list);
+	kref_init(&bat_priv->vis.my_info->refcount);
+	bat_priv->vis.my_info->bat_priv = bat_priv;
 	packet->header.version = BATADV_COMPAT_VERSION;
 	packet->header.packet_type = BATADV_VIS;
 	packet->header.ttl = BATADV_TTL;
@@ -894,28 +896,28 @@ int batadv_vis_init(struct batadv_priv *bat_priv)
 	packet->reserved = 0;
 	packet->entries = 0;
 
-	INIT_LIST_HEAD(&bat_priv->vis_send_list);
+	INIT_LIST_HEAD(&bat_priv->vis.send_list);
 
-	hash_added = batadv_hash_add(bat_priv->vis_hash, batadv_vis_info_cmp,
+	hash_added = batadv_hash_add(bat_priv->vis.hash, batadv_vis_info_cmp,
 				     batadv_vis_info_choose,
-				     bat_priv->my_vis_info,
-				     &bat_priv->my_vis_info->hash_entry);
+				     bat_priv->vis.my_info,
+				     &bat_priv->vis.my_info->hash_entry);
 	if (hash_added != 0) {
 		pr_err("Can't add own vis packet into hash\n");
 		/* not in hash, need to remove it manually. */
-		kref_put(&bat_priv->my_vis_info->refcount, batadv_free_info);
+		kref_put(&bat_priv->vis.my_info->refcount, batadv_free_info);
 		goto err;
 	}
 
-	spin_unlock_bh(&bat_priv->vis_hash_lock);
+	spin_unlock_bh(&bat_priv->vis.hash_lock);
 	batadv_start_vis_timer(bat_priv);
 	return 0;
 
 free_info:
-	kfree(bat_priv->my_vis_info);
-	bat_priv->my_vis_info = NULL;
+	kfree(bat_priv->vis.my_info);
+	bat_priv->vis.my_info = NULL;
 err:
-	spin_unlock_bh(&bat_priv->vis_hash_lock);
+	spin_unlock_bh(&bat_priv->vis.hash_lock);
 	batadv_vis_quit(bat_priv);
 	return -ENOMEM;
 }
@@ -933,23 +935,23 @@ static void batadv_free_info_ref(struct hlist_node *node, void *arg)
 /* shutdown vis-server */
 void batadv_vis_quit(struct batadv_priv *bat_priv)
 {
-	if (!bat_priv->vis_hash)
+	if (!bat_priv->vis.hash)
 		return;
 
-	cancel_delayed_work_sync(&bat_priv->vis_work);
+	cancel_delayed_work_sync(&bat_priv->vis.work);
 
-	spin_lock_bh(&bat_priv->vis_hash_lock);
+	spin_lock_bh(&bat_priv->vis.hash_lock);
 	/* properly remove, kill timers ... */
-	batadv_hash_delete(bat_priv->vis_hash, batadv_free_info_ref, NULL);
-	bat_priv->vis_hash = NULL;
-	bat_priv->my_vis_info = NULL;
-	spin_unlock_bh(&bat_priv->vis_hash_lock);
+	batadv_hash_delete(bat_priv->vis.hash, batadv_free_info_ref, NULL);
+	bat_priv->vis.hash = NULL;
+	bat_priv->vis.my_info = NULL;
+	spin_unlock_bh(&bat_priv->vis.hash_lock);
 }
 
 /* schedule packets for (re)transmission */
 static void batadv_start_vis_timer(struct batadv_priv *bat_priv)
 {
-	INIT_DELAYED_WORK(&bat_priv->vis_work, batadv_send_vis_packets);
-	queue_delayed_work(batadv_event_workqueue, &bat_priv->vis_work,
+	INIT_DELAYED_WORK(&bat_priv->vis.work, batadv_send_vis_packets);
+	queue_delayed_work(batadv_event_workqueue, &bat_priv->vis.work,
 			   msecs_to_jiffies(BATADV_VIS_INTERVAL));
 }
-- 
1.7.9.4

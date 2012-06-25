From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 10/20] batman-adv: Prefix bridge_loop_avoidance local static functions with batadv_
Date: Mon, 25 Jun 2012 08:54:34 +0200
Message-ID: <1340607284-29950-11-git-send-email-ordex@autistici.org>
References: <1340607284-29950-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:30519 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754656Ab2FYGys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 02:54:48 -0400
In-Reply-To: <1340607284-29950-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

All non-static symbols of batman-adv were prefixed with batadv_ to avoid
collisions with other symbols of the kernel. Other symbols of batman-adv
should use the same prefix to keep the naming scheme consistent.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bridge_loop_avoidance.c |  320 +++++++++++++++++---------------
 1 file changed, 168 insertions(+), 152 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index b7d7084..0592d2b 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -31,14 +31,14 @@
 #include <net/arp.h>
 #include <linux/if_vlan.h>
 
-static const uint8_t announce_mac[4] = {0x43, 0x05, 0x43, 0x05};
+static const uint8_t batadv_announce_mac[4] = {0x43, 0x05, 0x43, 0x05};
 
-static void bla_periodic_work(struct work_struct *work);
-static void bla_send_announce(struct bat_priv *bat_priv,
-			      struct backbone_gw *backbone_gw);
+static void batadv_bla_periodic_work(struct work_struct *work);
+static void batadv_bla_send_announce(struct bat_priv *bat_priv,
+				     struct backbone_gw *backbone_gw);
 
 /* return the index of the claim */
-static inline uint32_t choose_claim(const void *data, uint32_t size)
+static inline uint32_t batadv_choose_claim(const void *data, uint32_t size)
 {
 	const unsigned char *key = data;
 	uint32_t hash = 0;
@@ -58,7 +58,8 @@ static inline uint32_t choose_claim(const void *data, uint32_t size)
 }
 
 /* return the index of the backbone gateway */
-static inline uint32_t choose_backbone_gw(const void *data, uint32_t size)
+static inline uint32_t batadv_choose_backbone_gw(const void *data,
+						 uint32_t size)
 {
 	const unsigned char *key = data;
 	uint32_t hash = 0;
@@ -79,7 +80,8 @@ static inline uint32_t choose_backbone_gw(const void *data, uint32_t size)
 
 
 /* compares address and vid of two backbone gws */
-static int compare_backbone_gw(const struct hlist_node *node, const void *data2)
+static int batadv_compare_backbone_gw(const struct hlist_node *node,
+				      const void *data2)
 {
 	const void *data1 = container_of(node, struct backbone_gw,
 					 hash_entry);
@@ -88,7 +90,8 @@ static int compare_backbone_gw(const struct hlist_node *node, const void *data2)
 }
 
 /* compares address and vid of two claims */
-static int compare_claim(const struct hlist_node *node, const void *data2)
+static int batadv_compare_claim(const struct hlist_node *node,
+				const void *data2)
 {
 	const void *data1 = container_of(node, struct claim,
 					 hash_entry);
@@ -97,28 +100,28 @@ static int compare_claim(const struct hlist_node *node, const void *data2)
 }
 
 /* free a backbone gw */
-static void backbone_gw_free_ref(struct backbone_gw *backbone_gw)
+static void batadv_backbone_gw_free_ref(struct backbone_gw *backbone_gw)
 {
 	if (atomic_dec_and_test(&backbone_gw->refcount))
 		kfree_rcu(backbone_gw, rcu);
 }
 
 /* finally deinitialize the claim */
-static void claim_free_rcu(struct rcu_head *rcu)
+static void batadv_claim_free_rcu(struct rcu_head *rcu)
 {
 	struct claim *claim;
 
 	claim = container_of(rcu, struct claim, rcu);
 
-	backbone_gw_free_ref(claim->backbone_gw);
+	batadv_backbone_gw_free_ref(claim->backbone_gw);
 	kfree(claim);
 }
 
 /* free a claim, call claim_free_rcu if its the last reference */
-static void claim_free_ref(struct claim *claim)
+static void batadv_claim_free_ref(struct claim *claim)
 {
 	if (atomic_dec_and_test(&claim->refcount))
-		call_rcu(&claim->rcu, claim_free_rcu);
+		call_rcu(&claim->rcu, batadv_claim_free_rcu);
 }
 
 /* @bat_priv: the bat priv with all the soft interface information
@@ -127,8 +130,8 @@ static void claim_free_ref(struct claim *claim)
  * looks for a claim in the hash, and returns it if found
  * or NULL otherwise.
  */
-static struct claim *claim_hash_find(struct bat_priv *bat_priv,
-				     struct claim *data)
+static struct claim *batadv_claim_hash_find(struct bat_priv *bat_priv,
+					    struct claim *data)
 {
 	struct hashtable_t *hash = bat_priv->claim_hash;
 	struct hlist_head *head;
@@ -140,12 +143,12 @@ static struct claim *claim_hash_find(struct bat_priv *bat_priv,
 	if (!hash)
 		return NULL;
 
-	index = choose_claim(data, hash->size);
+	index = batadv_choose_claim(data, hash->size);
 	head = &hash->table[index];
 
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(claim, node, head, hash_entry) {
-		if (!compare_claim(&claim->hash_entry, data))
+		if (!batadv_compare_claim(&claim->hash_entry, data))
 			continue;
 
 		if (!atomic_inc_not_zero(&claim->refcount))
@@ -166,8 +169,8 @@ static struct claim *claim_hash_find(struct bat_priv *bat_priv,
  * looks for a claim in the hash, and returns it if found
  * or NULL otherwise.
  */
-static struct backbone_gw *backbone_hash_find(struct bat_priv *bat_priv,
-					      uint8_t *addr, short vid)
+static struct backbone_gw *batadv_backbone_hash_find(struct bat_priv *bat_priv,
+						     uint8_t *addr, short vid)
 {
 	struct hashtable_t *hash = bat_priv->backbone_hash;
 	struct hlist_head *head;
@@ -182,13 +185,13 @@ static struct backbone_gw *backbone_hash_find(struct bat_priv *bat_priv,
 	memcpy(search_entry.orig, addr, ETH_ALEN);
 	search_entry.vid = vid;
 
-	index = choose_backbone_gw(&search_entry, hash->size);
+	index = batadv_choose_backbone_gw(&search_entry, hash->size);
 	head = &hash->table[index];
 
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(backbone_gw, node, head, hash_entry) {
-		if (!compare_backbone_gw(&backbone_gw->hash_entry,
-					 &search_entry))
+		if (!batadv_compare_backbone_gw(&backbone_gw->hash_entry,
+						&search_entry))
 			continue;
 
 		if (!atomic_inc_not_zero(&backbone_gw->refcount))
@@ -203,7 +206,7 @@ static struct backbone_gw *backbone_hash_find(struct bat_priv *bat_priv,
 }
 
 /* delete all claims for a backbone */
-static void bla_del_backbone_claims(struct backbone_gw *backbone_gw)
+static void batadv_bla_del_backbone_claims(struct backbone_gw *backbone_gw)
 {
 	struct hashtable_t *hash;
 	struct hlist_node *node, *node_tmp;
@@ -227,7 +230,7 @@ static void bla_del_backbone_claims(struct backbone_gw *backbone_gw)
 			if (claim->backbone_gw != backbone_gw)
 				continue;
 
-			claim_free_ref(claim);
+			batadv_claim_free_ref(claim);
 			hlist_del_rcu(node);
 		}
 		spin_unlock_bh(list_lock);
@@ -244,8 +247,8 @@ static void bla_del_backbone_claims(struct backbone_gw *backbone_gw)
  *
  * sends a claim frame according to the provided info.
  */
-static void bla_send_claim(struct bat_priv *bat_priv, uint8_t *mac,
-			   short vid, int claimtype)
+static void batadv_bla_send_claim(struct bat_priv *bat_priv, uint8_t *mac,
+				  short vid, int claimtype)
 {
 	struct sk_buff *skb;
 	struct ethhdr *ethhdr;
@@ -350,14 +353,14 @@ out:
  * searches for the backbone gw or creates a new one if it could not
  * be found.
  */
-static struct backbone_gw *bla_get_backbone_gw(struct bat_priv *bat_priv,
-					       uint8_t *orig, short vid)
+static struct backbone_gw *batadv_bla_get_backbone_gw(struct bat_priv *bat_priv,
+						      uint8_t *orig, short vid)
 {
 	struct backbone_gw *entry;
 	struct orig_node *orig_node;
 	int hash_added;
 
-	entry = backbone_hash_find(bat_priv, orig, vid);
+	entry = batadv_backbone_hash_find(bat_priv, orig, vid);
 
 	if (entry)
 		return entry;
@@ -381,8 +384,9 @@ static struct backbone_gw *bla_get_backbone_gw(struct bat_priv *bat_priv,
 	atomic_set(&entry->refcount, 2);
 
 	hash_added = batadv_hash_add(bat_priv->backbone_hash,
-				     compare_backbone_gw, choose_backbone_gw,
-				     entry, &entry->hash_entry);
+				     batadv_compare_backbone_gw,
+				     batadv_choose_backbone_gw, entry,
+				     &entry->hash_entry);
 
 	if (unlikely(hash_added != 0)) {
 		/* hash failed, free the structure */
@@ -403,19 +407,20 @@ static struct backbone_gw *bla_get_backbone_gw(struct bat_priv *bat_priv,
 /* update or add the own backbone gw to make sure we announce
  * where we receive other backbone gws
  */
-static void bla_update_own_backbone_gw(struct bat_priv *bat_priv,
-				       struct hard_iface *primary_if,
-				       short vid)
+static void batadv_bla_update_own_backbone_gw(struct bat_priv *bat_priv,
+					      struct hard_iface *primary_if,
+					      short vid)
 {
 	struct backbone_gw *backbone_gw;
 
-	backbone_gw = bla_get_backbone_gw(bat_priv,
-					  primary_if->net_dev->dev_addr, vid);
+	backbone_gw = batadv_bla_get_backbone_gw(bat_priv,
+						 primary_if->net_dev->dev_addr,
+						 vid);
 	if (unlikely(!backbone_gw))
 		return;
 
 	backbone_gw->lasttime = jiffies;
-	backbone_gw_free_ref(backbone_gw);
+	batadv_backbone_gw_free_ref(backbone_gw);
 }
 
 /* @bat_priv: the bat priv with all the soft interface information
@@ -424,8 +429,8 @@ static void bla_update_own_backbone_gw(struct bat_priv *bat_priv,
  * Repeat all of our own claims, and finally send an ANNOUNCE frame
  * to allow the requester another check if the CRC is correct now.
  */
-static void bla_answer_request(struct bat_priv *bat_priv,
-			       struct hard_iface *primary_if, short vid)
+static void batadv_bla_answer_request(struct bat_priv *bat_priv,
+				      struct hard_iface *primary_if, short vid)
 {
 	struct hlist_node *node;
 	struct hlist_head *head;
@@ -437,8 +442,9 @@ static void bla_answer_request(struct bat_priv *bat_priv,
 	batadv_dbg(DBG_BLA, bat_priv,
 		   "bla_answer_request(): received a claim request, send all of our own claims again\n");
 
-	backbone_gw = backbone_hash_find(bat_priv,
-					 primary_if->net_dev->dev_addr, vid);
+	backbone_gw = batadv_backbone_hash_find(bat_priv,
+						primary_if->net_dev->dev_addr,
+						vid);
 	if (!backbone_gw)
 		return;
 
@@ -452,15 +458,15 @@ static void bla_answer_request(struct bat_priv *bat_priv,
 			if (claim->backbone_gw != backbone_gw)
 				continue;
 
-			bla_send_claim(bat_priv, claim->addr, claim->vid,
-				       CLAIM_TYPE_ADD);
+			batadv_bla_send_claim(bat_priv, claim->addr, claim->vid,
+					      CLAIM_TYPE_ADD);
 		}
 		rcu_read_unlock();
 	}
 
 	/* finally, send an announcement frame */
-	bla_send_announce(bat_priv, backbone_gw);
-	backbone_gw_free_ref(backbone_gw);
+	batadv_bla_send_announce(bat_priv, backbone_gw);
+	batadv_backbone_gw_free_ref(backbone_gw);
 }
 
 /* @backbone_gw: the backbone gateway from whom we are out of sync
@@ -469,17 +475,17 @@ static void bla_answer_request(struct bat_priv *bat_priv,
  * After the request, it will repeat all of his own claims and finally
  * send an announcement claim with which we can check again.
  */
-static void bla_send_request(struct backbone_gw *backbone_gw)
+static void batadv_bla_send_request(struct backbone_gw *backbone_gw)
 {
 	/* first, remove all old entries */
-	bla_del_backbone_claims(backbone_gw);
+	batadv_bla_del_backbone_claims(backbone_gw);
 
 	batadv_dbg(DBG_BLA, backbone_gw->bat_priv, "Sending REQUEST to %pM\n",
 		   backbone_gw->orig);
 
 	/* send request */
-	bla_send_claim(backbone_gw->bat_priv, backbone_gw->orig,
-		       backbone_gw->vid, CLAIM_TYPE_REQUEST);
+	batadv_bla_send_claim(backbone_gw->bat_priv, backbone_gw->orig,
+			      backbone_gw->vid, CLAIM_TYPE_REQUEST);
 
 	/* no local broadcasts should be sent or received, for now. */
 	if (!atomic_read(&backbone_gw->request_sent)) {
@@ -494,17 +500,18 @@ static void bla_send_request(struct backbone_gw *backbone_gw)
  * This function sends an announcement. It is called from multiple
  * places.
  */
-static void bla_send_announce(struct bat_priv *bat_priv,
-			      struct backbone_gw *backbone_gw)
+static void batadv_bla_send_announce(struct bat_priv *bat_priv,
+				     struct backbone_gw *backbone_gw)
 {
 	uint8_t mac[ETH_ALEN];
 	__be16 crc;
 
-	memcpy(mac, announce_mac, 4);
+	memcpy(mac, batadv_announce_mac, 4);
 	crc = htons(backbone_gw->crc);
 	memcpy(&mac[4], &crc, 2);
 
-	bla_send_claim(bat_priv, mac, backbone_gw->vid, CLAIM_TYPE_ANNOUNCE);
+	batadv_bla_send_claim(bat_priv, mac, backbone_gw->vid,
+			      CLAIM_TYPE_ANNOUNCE);
 
 }
 
@@ -515,8 +522,9 @@ static void bla_send_announce(struct bat_priv *bat_priv,
  *
  * Adds a claim in the claim hash.
  */
-static void bla_add_claim(struct bat_priv *bat_priv, const uint8_t *mac,
-			  const short vid, struct backbone_gw *backbone_gw)
+static void batadv_bla_add_claim(struct bat_priv *bat_priv, const uint8_t *mac,
+				 const short vid,
+				 struct backbone_gw *backbone_gw)
 {
 	struct claim *claim;
 	struct claim search_claim;
@@ -524,7 +532,7 @@ static void bla_add_claim(struct bat_priv *bat_priv, const uint8_t *mac,
 
 	memcpy(search_claim.addr, mac, ETH_ALEN);
 	search_claim.vid = vid;
-	claim = claim_hash_find(bat_priv, &search_claim);
+	claim = batadv_claim_hash_find(bat_priv, &search_claim);
 
 	/* create a new claim entry if it does not exist yet. */
 	if (!claim) {
@@ -542,8 +550,9 @@ static void bla_add_claim(struct bat_priv *bat_priv, const uint8_t *mac,
 			   "bla_add_claim(): adding new entry %pM, vid %d to hash ...\n",
 			   mac, vid);
 		hash_added = batadv_hash_add(bat_priv->claim_hash,
-					     compare_claim, choose_claim,
-					     claim, &claim->hash_entry);
+					     batadv_compare_claim,
+					     batadv_choose_claim, claim,
+					     &claim->hash_entry);
 
 		if (unlikely(hash_added != 0)) {
 			/* only local changes happened. */
@@ -562,7 +571,7 @@ static void bla_add_claim(struct bat_priv *bat_priv, const uint8_t *mac,
 
 		claim->backbone_gw->crc ^=
 			crc16(0, claim->addr, ETH_ALEN);
-		backbone_gw_free_ref(claim->backbone_gw);
+		batadv_backbone_gw_free_ref(claim->backbone_gw);
 
 	}
 	/* set (new) backbone gw */
@@ -573,47 +582,48 @@ static void bla_add_claim(struct bat_priv *bat_priv, const uint8_t *mac,
 	backbone_gw->lasttime = jiffies;
 
 claim_free_ref:
-	claim_free_ref(claim);
+	batadv_claim_free_ref(claim);
 }
 
 /* Delete a claim from the claim hash which has the
  * given mac address and vid.
  */
-static void bla_del_claim(struct bat_priv *bat_priv, const uint8_t *mac,
-			  const short vid)
+static void batadv_bla_del_claim(struct bat_priv *bat_priv, const uint8_t *mac,
+				 const short vid)
 {
 	struct claim search_claim, *claim;
 
 	memcpy(search_claim.addr, mac, ETH_ALEN);
 	search_claim.vid = vid;
-	claim = claim_hash_find(bat_priv, &search_claim);
+	claim = batadv_claim_hash_find(bat_priv, &search_claim);
 	if (!claim)
 		return;
 
 	batadv_dbg(DBG_BLA, bat_priv, "bla_del_claim(): %pM, vid %d\n", mac,
 		   vid);
 
-	batadv_hash_remove(bat_priv->claim_hash, compare_claim, choose_claim,
-			   claim);
-	claim_free_ref(claim); /* reference from the hash is gone */
+	batadv_hash_remove(bat_priv->claim_hash, batadv_compare_claim,
+			   batadv_choose_claim, claim);
+	batadv_claim_free_ref(claim); /* reference from the hash is gone */
 
 	claim->backbone_gw->crc ^= crc16(0, claim->addr, ETH_ALEN);
 
 	/* don't need the reference from hash_find() anymore */
-	claim_free_ref(claim);
+	batadv_claim_free_ref(claim);
 }
 
 /* check for ANNOUNCE frame, return 1 if handled */
-static int handle_announce(struct bat_priv *bat_priv,
-			   uint8_t *an_addr, uint8_t *backbone_addr, short vid)
+static int batadv_handle_announce(struct bat_priv *bat_priv,
+				  uint8_t *an_addr, uint8_t *backbone_addr,
+				  short vid)
 {
 	struct backbone_gw *backbone_gw;
 	uint16_t crc;
 
-	if (memcmp(an_addr, announce_mac, 4) != 0)
+	if (memcmp(an_addr, batadv_announce_mac, 4) != 0)
 		return 0;
 
-	backbone_gw = bla_get_backbone_gw(bat_priv, backbone_addr, vid);
+	backbone_gw = batadv_bla_get_backbone_gw(bat_priv, backbone_addr, vid);
 
 	if (unlikely(!backbone_gw))
 		return 1;
@@ -633,7 +643,7 @@ static int handle_announce(struct bat_priv *bat_priv,
 			   backbone_gw->orig, backbone_gw->vid,
 			   backbone_gw->crc, crc);
 
-		bla_send_request(backbone_gw);
+		batadv_bla_send_request(backbone_gw);
 	} else {
 		/* if we have sent a request and the crc was OK,
 		 * we can allow traffic again.
@@ -644,15 +654,15 @@ static int handle_announce(struct bat_priv *bat_priv,
 		}
 	}
 
-	backbone_gw_free_ref(backbone_gw);
+	batadv_backbone_gw_free_ref(backbone_gw);
 	return 1;
 }
 
 /* check for REQUEST frame, return 1 if handled */
-static int handle_request(struct bat_priv *bat_priv,
-			  struct hard_iface *primary_if,
-			  uint8_t *backbone_addr,
-			  struct ethhdr *ethhdr, short vid)
+static int batadv_handle_request(struct bat_priv *bat_priv,
+				 struct hard_iface *primary_if,
+				 uint8_t *backbone_addr,
+				 struct ethhdr *ethhdr, short vid)
 {
 	/* check for REQUEST frame */
 	if (!batadv_compare_eth(backbone_addr, ethhdr->h_dest))
@@ -668,24 +678,25 @@ static int handle_request(struct bat_priv *bat_priv,
 		   "handle_request(): REQUEST vid %d (sent by %pM)...\n",
 		   vid, ethhdr->h_source);
 
-	bla_answer_request(bat_priv, primary_if, vid);
+	batadv_bla_answer_request(bat_priv, primary_if, vid);
 	return 1;
 }
 
 /* check for UNCLAIM frame, return 1 if handled */
-static int handle_unclaim(struct bat_priv *bat_priv,
-			  struct hard_iface *primary_if,
-			  uint8_t *backbone_addr,
-			  uint8_t *claim_addr, short vid)
+static int batadv_handle_unclaim(struct bat_priv *bat_priv,
+				 struct hard_iface *primary_if,
+				 uint8_t *backbone_addr,
+				 uint8_t *claim_addr, short vid)
 {
 	struct backbone_gw *backbone_gw;
 
 	/* unclaim in any case if it is our own */
 	if (primary_if && batadv_compare_eth(backbone_addr,
 					     primary_if->net_dev->dev_addr))
-		bla_send_claim(bat_priv, claim_addr, vid, CLAIM_TYPE_DEL);
+		batadv_bla_send_claim(bat_priv, claim_addr, vid,
+				      CLAIM_TYPE_DEL);
 
-	backbone_gw = backbone_hash_find(bat_priv, backbone_addr, vid);
+	backbone_gw = batadv_backbone_hash_find(bat_priv, backbone_addr, vid);
 
 	if (!backbone_gw)
 		return 1;
@@ -695,33 +706,35 @@ static int handle_unclaim(struct bat_priv *bat_priv,
 		   "handle_unclaim(): UNCLAIM %pM on vid %d (sent by %pM)...\n",
 		   claim_addr, vid, backbone_gw->orig);
 
-	bla_del_claim(bat_priv, claim_addr, vid);
-	backbone_gw_free_ref(backbone_gw);
+	batadv_bla_del_claim(bat_priv, claim_addr, vid);
+	batadv_backbone_gw_free_ref(backbone_gw);
 	return 1;
 }
 
 /* check for CLAIM frame, return 1 if handled */
-static int handle_claim(struct bat_priv *bat_priv,
-			struct hard_iface *primary_if, uint8_t *backbone_addr,
-			uint8_t *claim_addr, short vid)
+static int batadv_handle_claim(struct bat_priv *bat_priv,
+			       struct hard_iface *primary_if,
+			       uint8_t *backbone_addr, uint8_t *claim_addr,
+			       short vid)
 {
 	struct backbone_gw *backbone_gw;
 
 	/* register the gateway if not yet available, and add the claim. */
 
-	backbone_gw = bla_get_backbone_gw(bat_priv, backbone_addr, vid);
+	backbone_gw = batadv_bla_get_backbone_gw(bat_priv, backbone_addr, vid);
 
 	if (unlikely(!backbone_gw))
 		return 1;
 
 	/* this must be a CLAIM frame */
-	bla_add_claim(bat_priv, claim_addr, vid, backbone_gw);
+	batadv_bla_add_claim(bat_priv, claim_addr, vid, backbone_gw);
 	if (batadv_compare_eth(backbone_addr, primary_if->net_dev->dev_addr))
-		bla_send_claim(bat_priv, claim_addr, vid, CLAIM_TYPE_ADD);
+		batadv_bla_send_claim(bat_priv, claim_addr, vid,
+				      CLAIM_TYPE_ADD);
 
 	/* TODO: we could call something like tt_local_del() here. */
 
-	backbone_gw_free_ref(backbone_gw);
+	batadv_backbone_gw_free_ref(backbone_gw);
 	return 1;
 }
 
@@ -739,10 +752,10 @@ static int handle_claim(struct bat_priv *bat_priv,
  *	1  - if is a claim packet from another group
  *	0  - if it is not a claim packet
  */
-static int check_claim_group(struct bat_priv *bat_priv,
-			     struct hard_iface *primary_if,
-			     uint8_t *hw_src, uint8_t *hw_dst,
-			     struct ethhdr *ethhdr)
+static int batadv_check_claim_group(struct bat_priv *bat_priv,
+				    struct hard_iface *primary_if,
+				    uint8_t *hw_src, uint8_t *hw_dst,
+				    struct ethhdr *ethhdr)
 {
 	uint8_t *backbone_addr;
 	struct orig_node *orig_node;
@@ -811,9 +824,9 @@ static int check_claim_group(struct bat_priv *bat_priv,
  * returns 1 if it was a claim frame, otherwise return 0 to
  * tell the callee that it can use the frame on its own.
  */
-static int bla_process_claim(struct bat_priv *bat_priv,
-			     struct hard_iface *primary_if,
-			     struct sk_buff *skb)
+static int batadv_bla_process_claim(struct bat_priv *bat_priv,
+				    struct hard_iface *primary_if,
+				    struct sk_buff *skb)
 {
 	struct ethhdr *ethhdr;
 	struct vlan_ethhdr *vhdr;
@@ -866,7 +879,8 @@ static int bla_process_claim(struct bat_priv *bat_priv,
 	bla_dst = (struct bla_claim_dst *)hw_dst;
 
 	/* check if it is a claim frame. */
-	ret = check_claim_group(bat_priv, primary_if, hw_src, hw_dst, ethhdr);
+	ret = batadv_check_claim_group(bat_priv, primary_if, hw_src, hw_dst,
+				       ethhdr);
 	if (ret == 1)
 		batadv_dbg(DBG_BLA, bat_priv,
 			   "bla_process_claim(): received a claim frame from another group. From: %pM on vid %d ...(hw_src %pM, hw_dst %pM)\n",
@@ -876,27 +890,29 @@ static int bla_process_claim(struct bat_priv *bat_priv,
 		return ret;
 
 	/* become a backbone gw ourselves on this vlan if not happened yet */
-	bla_update_own_backbone_gw(bat_priv, primary_if, vid);
+	batadv_bla_update_own_backbone_gw(bat_priv, primary_if, vid);
 
 	/* check for the different types of claim frames ... */
 	switch (bla_dst->type) {
 	case CLAIM_TYPE_ADD:
-		if (handle_claim(bat_priv, primary_if, hw_src,
-				 ethhdr->h_source, vid))
+		if (batadv_handle_claim(bat_priv, primary_if, hw_src,
+					ethhdr->h_source, vid))
 			return 1;
 		break;
 	case CLAIM_TYPE_DEL:
-		if (handle_unclaim(bat_priv, primary_if,
-				   ethhdr->h_source, hw_src, vid))
+		if (batadv_handle_unclaim(bat_priv, primary_if,
+					  ethhdr->h_source, hw_src, vid))
 			return 1;
 		break;
 
 	case CLAIM_TYPE_ANNOUNCE:
-		if (handle_announce(bat_priv, hw_src, ethhdr->h_source, vid))
+		if (batadv_handle_announce(bat_priv, hw_src, ethhdr->h_source,
+					   vid))
 			return 1;
 		break;
 	case CLAIM_TYPE_REQUEST:
-		if (handle_request(bat_priv, primary_if, hw_src, ethhdr, vid))
+		if (batadv_handle_request(bat_priv, primary_if, hw_src, ethhdr,
+					  vid))
 			return 1;
 		break;
 	}
@@ -910,7 +926,7 @@ static int bla_process_claim(struct bat_priv *bat_priv,
 /* Check when we last heard from other nodes, and remove them in case of
  * a time out, or clean all backbone gws if now is set.
  */
-static void bla_purge_backbone_gw(struct bat_priv *bat_priv, int now)
+static void batadv_bla_purge_backbone_gw(struct bat_priv *bat_priv, int now)
 {
 	struct backbone_gw *backbone_gw;
 	struct hlist_node *node, *node_tmp;
@@ -945,10 +961,10 @@ purge_now:
 			if (atomic_read(&backbone_gw->request_sent))
 				atomic_dec(&bat_priv->bla_num_requests);
 
-			bla_del_backbone_claims(backbone_gw);
+			batadv_bla_del_backbone_claims(backbone_gw);
 
 			hlist_del_rcu(node);
-			backbone_gw_free_ref(backbone_gw);
+			batadv_backbone_gw_free_ref(backbone_gw);
 		}
 		spin_unlock_bh(list_lock);
 	}
@@ -961,8 +977,8 @@ purge_now:
  * Check when we heard last time from our own claims, and remove them in case of
  * a time out, or clean all claims if now is set
  */
-static void bla_purge_claims(struct bat_priv *bat_priv,
-			     struct hard_iface *primary_if, int now)
+static void batadv_bla_purge_claims(struct bat_priv *bat_priv,
+				    struct hard_iface *primary_if, int now)
 {
 	struct claim *claim;
 	struct hlist_node *node;
@@ -993,9 +1009,9 @@ static void bla_purge_claims(struct bat_priv *bat_priv,
 				   claim->addr, claim->vid);
 
 purge_now:
-			handle_unclaim(bat_priv, primary_if,
-				       claim->backbone_gw->orig,
-				       claim->addr, claim->vid);
+			batadv_handle_unclaim(bat_priv, primary_if,
+					      claim->backbone_gw->orig,
+					      claim->addr, claim->vid);
 		}
 		rcu_read_unlock();
 	}
@@ -1022,8 +1038,8 @@ void batadv_bla_update_orig_address(struct bat_priv *bat_priv,
 		htons(crc16(0, primary_if->net_dev->dev_addr, ETH_ALEN));
 
 	if (!oldif) {
-		bla_purge_claims(bat_priv, NULL, 1);
-		bla_purge_backbone_gw(bat_priv, 1);
+		batadv_bla_purge_claims(bat_priv, NULL, 1);
+		batadv_bla_purge_backbone_gw(bat_priv, 1);
 		return;
 	}
 
@@ -1046,7 +1062,7 @@ void batadv_bla_update_orig_address(struct bat_priv *bat_priv,
 			/* send an announce frame so others will ask for our
 			 * claims and update their tables.
 			 */
-			bla_send_announce(bat_priv, backbone_gw);
+			batadv_bla_send_announce(bat_priv, backbone_gw);
 		}
 		rcu_read_unlock();
 	}
@@ -1055,9 +1071,9 @@ void batadv_bla_update_orig_address(struct bat_priv *bat_priv,
 
 
 /* (re)start the timer */
-static void bla_start_timer(struct bat_priv *bat_priv)
+static void batadv_bla_start_timer(struct bat_priv *bat_priv)
 {
-	INIT_DELAYED_WORK(&bat_priv->bla_work, bla_periodic_work);
+	INIT_DELAYED_WORK(&bat_priv->bla_work, batadv_bla_periodic_work);
 	queue_delayed_work(batadv_event_workqueue, &bat_priv->bla_work,
 			   msecs_to_jiffies(BLA_PERIOD_LENGTH));
 }
@@ -1066,7 +1082,7 @@ static void bla_start_timer(struct bat_priv *bat_priv)
  *  * purge structures when they are too old
  *  * send announcements
  */
-static void bla_periodic_work(struct work_struct *work)
+static void batadv_bla_periodic_work(struct work_struct *work)
 {
 	struct delayed_work *delayed_work =
 		container_of(work, struct delayed_work, work);
@@ -1083,8 +1099,8 @@ static void bla_periodic_work(struct work_struct *work)
 	if (!primary_if)
 		goto out;
 
-	bla_purge_claims(bat_priv, primary_if, 0);
-	bla_purge_backbone_gw(bat_priv, 0);
+	batadv_bla_purge_claims(bat_priv, primary_if, 0);
+	batadv_bla_purge_backbone_gw(bat_priv, 0);
 
 	if (!atomic_read(&bat_priv->bridge_loop_avoidance))
 		goto out;
@@ -1104,7 +1120,7 @@ static void bla_periodic_work(struct work_struct *work)
 
 			backbone_gw->lasttime = jiffies;
 
-			bla_send_announce(bat_priv, backbone_gw);
+			batadv_bla_send_announce(bat_priv, backbone_gw);
 		}
 		rcu_read_unlock();
 	}
@@ -1112,7 +1128,7 @@ out:
 	if (primary_if)
 		batadv_hardif_free_ref(primary_if);
 
-	bla_start_timer(bat_priv);
+	batadv_bla_start_timer(bat_priv);
 }
 
 /* The hash for claim and backbone hash receive the same key because they
@@ -1120,8 +1136,8 @@ out:
  * them with to different keys to allow nested locking without generating
  * lockdep warnings
  */
-static struct lock_class_key claim_hash_lock_class_key;
-static struct lock_class_key backbone_hash_lock_class_key;
+static struct lock_class_key batadv_claim_hash_lock_class_key;
+static struct lock_class_key batadv_backbone_hash_lock_class_key;
 
 /* initialize all bla structures */
 int batadv_bla_init(struct bat_priv *bat_priv)
@@ -1161,13 +1177,13 @@ int batadv_bla_init(struct bat_priv *bat_priv)
 		return -ENOMEM;
 
 	batadv_hash_set_lock_class(bat_priv->claim_hash,
-				   &claim_hash_lock_class_key);
+				   &batadv_claim_hash_lock_class_key);
 	batadv_hash_set_lock_class(bat_priv->backbone_hash,
-				   &backbone_hash_lock_class_key);
+				   &batadv_backbone_hash_lock_class_key);
 
 	batadv_dbg(DBG_BLA, bat_priv, "bla hashes initialized\n");
 
-	bla_start_timer(bat_priv);
+	batadv_bla_start_timer(bat_priv);
 	return 0;
 }
 
@@ -1308,12 +1324,12 @@ int batadv_bla_is_backbone_gw(struct sk_buff *skb,
 	}
 
 	/* see if this originator is a backbone gw for this VLAN */
-	backbone_gw = backbone_hash_find(orig_node->bat_priv,
-					 orig_node->orig, vid);
+	backbone_gw = batadv_backbone_hash_find(orig_node->bat_priv,
+						orig_node->orig, vid);
 	if (!backbone_gw)
 		return 0;
 
-	backbone_gw_free_ref(backbone_gw);
+	batadv_backbone_gw_free_ref(backbone_gw);
 	return 1;
 }
 
@@ -1326,12 +1342,12 @@ void batadv_bla_free(struct bat_priv *bat_priv)
 	primary_if = batadv_primary_if_get_selected(bat_priv);
 
 	if (bat_priv->claim_hash) {
-		bla_purge_claims(bat_priv, primary_if, 1);
+		batadv_bla_purge_claims(bat_priv, primary_if, 1);
 		batadv_hash_destroy(bat_priv->claim_hash);
 		bat_priv->claim_hash = NULL;
 	}
 	if (bat_priv->backbone_hash) {
-		bla_purge_backbone_gw(bat_priv, 1);
+		batadv_bla_purge_backbone_gw(bat_priv, 1);
 		batadv_hash_destroy(bat_priv->backbone_hash);
 		bat_priv->backbone_hash = NULL;
 	}
@@ -1375,15 +1391,15 @@ int batadv_bla_rx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid)
 
 	memcpy(search_claim.addr, ethhdr->h_source, ETH_ALEN);
 	search_claim.vid = vid;
-	claim = claim_hash_find(bat_priv, &search_claim);
+	claim = batadv_claim_hash_find(bat_priv, &search_claim);
 
 	if (!claim) {
 		/* possible optimization: race for a claim */
 		/* No claim exists yet, claim it for us!
 		 */
-		handle_claim(bat_priv, primary_if,
-			     primary_if->net_dev->dev_addr,
-			     ethhdr->h_source, vid);
+		batadv_handle_claim(bat_priv, primary_if,
+				    primary_if->net_dev->dev_addr,
+				    ethhdr->h_source, vid);
 		goto allow;
 	}
 
@@ -1404,13 +1420,13 @@ int batadv_bla_rx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid)
 		 * send a claim and update the claim table
 		 * immediately.
 		 */
-		handle_claim(bat_priv, primary_if,
-			     primary_if->net_dev->dev_addr,
-			     ethhdr->h_source, vid);
+		batadv_handle_claim(bat_priv, primary_if,
+				    primary_if->net_dev->dev_addr,
+				    ethhdr->h_source, vid);
 		goto allow;
 	}
 allow:
-	bla_update_own_backbone_gw(bat_priv, primary_if, vid);
+	batadv_bla_update_own_backbone_gw(bat_priv, primary_if, vid);
 	ret = 0;
 	goto out;
 
@@ -1422,7 +1438,7 @@ out:
 	if (primary_if)
 		batadv_hardif_free_ref(primary_if);
 	if (claim)
-		claim_free_ref(claim);
+		batadv_claim_free_ref(claim);
 	return ret;
 }
 
@@ -1455,7 +1471,7 @@ int batadv_bla_tx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid)
 	/* in VLAN case, the mac header might not be set. */
 	skb_reset_mac_header(skb);
 
-	if (bla_process_claim(bat_priv, primary_if, skb))
+	if (batadv_bla_process_claim(bat_priv, primary_if, skb))
 		goto handled;
 
 	ethhdr = (struct ethhdr *)skb_mac_header(skb);
@@ -1468,7 +1484,7 @@ int batadv_bla_tx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid)
 	memcpy(search_claim.addr, ethhdr->h_source, ETH_ALEN);
 	search_claim.vid = vid;
 
-	claim = claim_hash_find(bat_priv, &search_claim);
+	claim = batadv_claim_hash_find(bat_priv, &search_claim);
 
 	/* if no claim exists, allow it. */
 	if (!claim)
@@ -1480,9 +1496,9 @@ int batadv_bla_tx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid)
 		/* if yes, the client has roamed and we have
 		 * to unclaim it.
 		 */
-		handle_unclaim(bat_priv, primary_if,
-			       primary_if->net_dev->dev_addr,
-			       ethhdr->h_source, vid);
+		batadv_handle_unclaim(bat_priv, primary_if,
+				      primary_if->net_dev->dev_addr,
+				      ethhdr->h_source, vid);
 		goto allow;
 	}
 
@@ -1499,7 +1515,7 @@ int batadv_bla_tx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid)
 		goto allow;
 	}
 allow:
-	bla_update_own_backbone_gw(bat_priv, primary_if, vid);
+	batadv_bla_update_own_backbone_gw(bat_priv, primary_if, vid);
 	ret = 0;
 	goto out;
 handled:
@@ -1508,7 +1524,7 @@ out:
 	if (primary_if)
 		batadv_hardif_free_ref(primary_if);
 	if (claim)
-		claim_free_ref(claim);
+		batadv_claim_free_ref(claim);
 	return ret;
 }
 
-- 
1.7.9.4

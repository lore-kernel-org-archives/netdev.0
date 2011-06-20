From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 07/12] batman-adv: improved roaming mechanism
Date: Mon, 20 Jun 2011 12:17:00 +0200
Message-ID: <1308565025-21293-8-git-send-email-sven@narfation.org>
References: <1308565025-21293-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1308565025-21293-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
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

From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>

With the current client announcement implementation, in case of roaming,
an update is triggered on the new AP serving the client. At that point
the new information is spread around by means of the OGM broadcasting
mechanism. Until this operations is not executed, no node is able to
correctly route traffic towards the client. This obviously causes packet
drops and introduces a delay in the time needed by the client to recover
its connections.

A new packet type called ROAMING_ADVERTISEMENT is added to account this
issue.

This message is sent in case of roaming from the new AP serving the
client to the old one and will contain the client MAC address. In this
way an out-of-OGM update is immediately committed, so that the old node
can update its global translation table. Traffic reaching this node will
then be redirected to the correct destination utilising the fresher
information. Thus reducing the packet drops and the connection recovery
delay.

Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/hard-interface.c    |    4 +
 net/batman-adv/main.c              |    2 +
 net/batman-adv/main.h              |    6 +-
 net/batman-adv/originator.c        |    1 +
 net/batman-adv/packet.h            |   13 ++-
 net/batman-adv/routing.c           |   61 +++++++++-
 net/batman-adv/routing.h           |    1 +
 net/batman-adv/send.c              |    1 +
 net/batman-adv/soft-interface.c    |    3 +-
 net/batman-adv/translation-table.c |  241 ++++++++++++++++++++++++++++++++---
 net/batman-adv/translation-table.h |    8 +-
 net/batman-adv/types.h             |   26 ++++-
 12 files changed, 334 insertions(+), 33 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index d40426c..55b5def 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -658,6 +658,10 @@ static int batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	case BAT_TT_QUERY:
 		ret = recv_tt_query(skb, hard_iface);
 		break;
+		/* Roaming advertisement */
+	case BAT_ROAM_ADV:
+		ret = recv_roam_adv(skb, hard_iface);
+		break;
 	default:
 		ret = NET_RX_DROP;
 	}
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 49a5e64..3318ee2 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -88,6 +88,7 @@ int mesh_init(struct net_device *soft_iface)
 	spin_lock_init(&bat_priv->tt_ghash_lock);
 	spin_lock_init(&bat_priv->tt_changes_list_lock);
 	spin_lock_init(&bat_priv->tt_req_list_lock);
+	spin_lock_init(&bat_priv->tt_roam_list_lock);
 	spin_lock_init(&bat_priv->tt_buff_lock);
 	spin_lock_init(&bat_priv->gw_list_lock);
 	spin_lock_init(&bat_priv->vis_hash_lock);
@@ -101,6 +102,7 @@ int mesh_init(struct net_device *soft_iface)
 	INIT_HLIST_HEAD(&bat_priv->softif_neigh_vids);
 	INIT_LIST_HEAD(&bat_priv->tt_changes_list);
 	INIT_LIST_HEAD(&bat_priv->tt_req_list);
+	INIT_LIST_HEAD(&bat_priv->tt_roam_list);
 
 	if (originator_init(bat_priv) < 1)
 		goto err;
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 6f53a1d..8eae05e 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -42,7 +42,7 @@
  * -> TODO: check influence on TQ_LOCAL_WINDOW_SIZE */
 #define PURGE_TIMEOUT 200
 #define TT_LOCAL_TIMEOUT 3600 /* in seconds */
-
+#define TT_CLIENT_ROAM_TIMEOUT 600
 /* sliding packet range of received originator messages in squence numbers
  * (should be a multiple of our word size) */
 #define TQ_LOCAL_WINDOW_SIZE 64
@@ -55,6 +55,10 @@
 
 #define TT_OGM_APPEND_MAX 3 /* number of OGMs sent with the last tt diff */
 
+#define ROAMING_MAX_TIME 20 /* Time in which a client can roam at most
+			     * ROAMING_MAX_COUNT times */
+#define ROAMING_MAX_COUNT 5
+
 #define NO_FLAGS 0
 
 #define NUM_WORDS (TQ_LOCAL_WINDOW_SIZE / WORD_BIT_SIZE)
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 25e7e50..338b3c5 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -219,6 +219,7 @@ struct orig_node *get_orig_node(struct bat_priv *bat_priv, const uint8_t *addr)
 	/* extra reference for return */
 	atomic_set(&orig_node->refcount, 2);
 
+	orig_node->tt_poss_change = false;
 	orig_node->bat_priv = bat_priv;
 	memcpy(orig_node->orig, addr, ETH_ALEN);
 	orig_node->router = NULL;
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 407dd2e..c5f081d 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -31,7 +31,8 @@ enum bat_packettype {
 	BAT_BCAST        = 0x04,
 	BAT_VIS          = 0x05,
 	BAT_UNICAST_FRAG = 0x06,
-	BAT_TT_QUERY     = 0x07
+	BAT_TT_QUERY     = 0x07,
+	BAT_ROAM_ADV     = 0x08
 };
 
 /* this file is included by batctl which needs these defines */
@@ -194,6 +195,16 @@ struct tt_query_packet {
 	uint16_t tt_data;
 } __packed;
 
+struct roam_adv_packet {
+	uint8_t  packet_type;
+	uint8_t  version;
+	uint8_t  ttl;
+	uint8_t  reserved;
+	uint8_t  dst[ETH_ALEN];
+	uint8_t  src[ETH_ALEN];
+	uint8_t  client[ETH_ALEN];
+} __packed;
+
 struct tt_change {
 	uint8_t flags;
 	uint8_t addr[ETH_ALEN];
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 8b0f833..05d50ca 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -93,6 +93,9 @@ static void update_transtable(struct bat_priv *bat_priv,
 		spin_lock_bh(&bat_priv->tt_ghash_lock);
 		orig_node->tt_crc = tt_global_crc(bat_priv, orig_node);
 		spin_unlock_bh(&bat_priv->tt_ghash_lock);
+		/* Roaming phase is over: tables are in sync again. I can
+		 * unset the flag */
+		orig_node->tt_poss_change = false;
 	} else {
 		/* if we missed more than one change or our tables are not
 		 * in sync anymore -> request fresh tt data */
@@ -1252,6 +1255,54 @@ out:
 	return NET_RX_DROP;
 }
 
+int recv_roam_adv(struct sk_buff *skb, struct hard_iface *recv_if)
+{
+	struct bat_priv *bat_priv = netdev_priv(recv_if->soft_iface);
+	struct roam_adv_packet *roam_adv_packet;
+	struct orig_node *orig_node;
+	struct ethhdr *ethhdr;
+
+	/* drop packet if it has not necessary minimum size */
+	if (unlikely(!pskb_may_pull(skb, sizeof(struct roam_adv_packet))))
+		goto out;
+
+	ethhdr = (struct ethhdr *)skb_mac_header(skb);
+
+	/* packet with unicast indication but broadcast recipient */
+	if (is_broadcast_ether_addr(ethhdr->h_dest))
+		goto out;
+
+	/* packet with broadcast sender address */
+	if (is_broadcast_ether_addr(ethhdr->h_source))
+		goto out;
+
+	roam_adv_packet = (struct roam_adv_packet *)skb->data;
+
+	if (!is_my_mac(roam_adv_packet->dst))
+		return route_unicast_packet(skb, recv_if);
+
+	orig_node = orig_hash_find(bat_priv, roam_adv_packet->src);
+	if (!orig_node)
+		goto out;
+
+	bat_dbg(DBG_TT, bat_priv, "Received ROAMING_ADV from %pM "
+		"(client %pM)\n", roam_adv_packet->src,
+		roam_adv_packet->client);
+
+	tt_global_add(bat_priv, orig_node, roam_adv_packet->client,
+		      atomic_read(&orig_node->last_ttvn) + 1, true);
+
+	/* Roaming phase starts: I have new information but the ttvn has not
+	 * been incremented yet. This flag will make me check all the incoming
+	 * packets for the correct destination. */
+	bat_priv->tt_poss_change = true;
+
+	orig_node_free_ref(orig_node);
+out:
+	/* returning NET_RX_DROP will make the caller function kfree the skb */
+	return NET_RX_DROP;
+}
+
 /* find a suitable router for this originator, and use
  * bonding if possible. increases the found neighbors
  * refcount.*/
@@ -1445,6 +1496,7 @@ static int check_unicast_ttvn(struct bat_priv *bat_priv,
 	struct ethhdr *ethhdr;
 	struct hard_iface *primary_if;
 	struct unicast_packet *unicast_packet;
+	bool tt_poss_change;
 
 	/* I could need to modify it */
 	if (skb_cow(skb, sizeof(struct unicast_packet)) < 0)
@@ -1452,27 +1504,28 @@ static int check_unicast_ttvn(struct bat_priv *bat_priv,
 
 	unicast_packet = (struct unicast_packet *)skb->data;
 
-	if (is_my_mac(unicast_packet->dest))
+	if (is_my_mac(unicast_packet->dest)) {
+		tt_poss_change = bat_priv->tt_poss_change;
 		curr_ttvn = (uint8_t)atomic_read(&bat_priv->ttvn);
-	else {
+	} else {
 		orig_node = orig_hash_find(bat_priv, unicast_packet->dest);
 
 		if (!orig_node)
 			return 0;
 
 		curr_ttvn = (uint8_t)atomic_read(&orig_node->last_ttvn);
+		tt_poss_change = orig_node->tt_poss_change;
 		orig_node_free_ref(orig_node);
 	}
 
 	/* Check whether I have to reroute the packet */
-	if (seq_before(unicast_packet->ttvn, curr_ttvn)) {
+	if (seq_before(unicast_packet->ttvn, curr_ttvn) || tt_poss_change) {
 		/* Linearize the skb before accessing it */
 		if (skb_linearize(skb) < 0)
 			return 0;
 
 		ethhdr = (struct ethhdr *)(skb->data +
 			sizeof(struct unicast_packet));
-
 		orig_node = transtable_search(bat_priv, ethhdr->h_dest);
 
 		if (!orig_node) {
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index e77d464..fb14e95 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -37,6 +37,7 @@ int recv_bcast_packet(struct sk_buff *skb, struct hard_iface *recv_if);
 int recv_vis_packet(struct sk_buff *skb, struct hard_iface *recv_if);
 int recv_bat_packet(struct sk_buff *skb, struct hard_iface *recv_if);
 int recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if);
+int recv_roam_adv(struct sk_buff *skb, struct hard_iface *recv_if);
 struct neigh_node *find_router(struct bat_priv *bat_priv,
 			       struct orig_node *orig_node,
 			       const struct hard_iface *recv_if);
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 6b14075..7a2f082 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -303,6 +303,7 @@ void schedule_own_packet(struct hard_iface *hard_iface)
 			prepare_packet_buffer(bat_priv, hard_iface);
 			/* Increment the TTVN only once per OGM interval */
 			atomic_inc(&bat_priv->ttvn);
+			bat_priv->tt_poss_change = false;
 		}
 
 		/* if the changes have been sent enough times */
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index c288d93..3371ece 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -534,7 +534,7 @@ static int interface_set_mac_addr(struct net_device *dev, void *p)
 	/* only modify transtable if it has been initialised before */
 	if (atomic_read(&bat_priv->mesh_state) == MESH_ACTIVE) {
 		tt_local_remove(bat_priv, dev->dev_addr,
-				"mac address changed");
+				"mac address changed", false);
 		tt_local_add(dev, addr->sa_data);
 	}
 
@@ -836,6 +836,7 @@ struct net_device *softif_create(const char *name)
 
 	bat_priv->tt_buff = NULL;
 	bat_priv->tt_buff_len = 0;
+	bat_priv->tt_poss_change = false;
 
 	bat_priv->primary_if = NULL;
 	bat_priv->num_ifaces = 0;
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 597cd1a..d516d85 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -126,7 +126,7 @@ static bool is_out_of_time(unsigned long starting_time, unsigned long timeout)
 }
 
 static void tt_local_event(struct bat_priv *bat_priv, uint8_t op,
-			   const uint8_t *addr)
+			   const uint8_t *addr, uint8_t roaming)
 {
 	struct tt_change_node *tt_change_node;
 
@@ -136,6 +136,9 @@ static void tt_local_event(struct bat_priv *bat_priv, uint8_t op,
 		return;
 
 	tt_change_node->change.flags = op;
+	if (roaming)
+		tt_change_node->change.flags |= TT_CLIENT_ROAM;
+
 	memcpy(tt_change_node->change.addr, addr, ETH_ALEN);
 
 	spin_lock_bh(&bat_priv->tt_changes_list_lock);
@@ -170,6 +173,7 @@ void tt_local_add(struct net_device *soft_iface, const uint8_t *addr)
 	struct bat_priv *bat_priv = netdev_priv(soft_iface);
 	struct tt_local_entry *tt_local_entry;
 	struct tt_global_entry *tt_global_entry;
+	uint8_t roam_addr[ETH_ALEN];
 
 	spin_lock_bh(&bat_priv->tt_lhash_lock);
 	tt_local_entry = tt_local_hash_find(bat_priv, addr);
@@ -183,7 +187,7 @@ void tt_local_add(struct net_device *soft_iface, const uint8_t *addr)
 	if (!tt_local_entry)
 		goto unlock;
 
-	tt_local_event(bat_priv, NO_FLAGS, addr);
+	tt_local_event(bat_priv, NO_FLAGS, addr, false);
 
 	bat_dbg(DBG_TT, bat_priv,
 		"Creating new local tt entry: %pM (ttvn: %d)\n", addr,
@@ -208,11 +212,19 @@ void tt_local_add(struct net_device *soft_iface, const uint8_t *addr)
 
 	tt_global_entry = tt_global_hash_find(bat_priv, addr);
 
-	if (tt_global_entry)
+	/* Check whether it is a roaming! */
+	if (tt_global_entry) {
+		memcpy(roam_addr, tt_global_entry->addr, ETH_ALEN);
+		/* This node is probably going to update its tt table */
+		tt_global_entry->orig_node->tt_poss_change = true;
 		_tt_global_del(bat_priv, tt_global_entry,
 			       "local tt received");
+		spin_unlock_bh(&bat_priv->tt_ghash_lock);
+		send_roam_adv(bat_priv, tt_global_entry->addr,
+			tt_global_entry->orig_node);
+	} else
+		spin_unlock_bh(&bat_priv->tt_ghash_lock);
 
-	spin_unlock_bh(&bat_priv->tt_ghash_lock);
 	return;
 unlock:
 	spin_unlock_bh(&bat_priv->tt_lhash_lock);
@@ -367,7 +379,7 @@ static void tt_local_del(struct bat_priv *bat_priv,
 }
 
 void tt_local_remove(struct bat_priv *bat_priv, const uint8_t *addr,
-		     const char *message)
+		     const char *message, bool roaming)
 {
 	struct tt_local_entry *tt_local_entry;
 
@@ -375,7 +387,8 @@ void tt_local_remove(struct bat_priv *bat_priv, const uint8_t *addr,
 	tt_local_entry = tt_local_hash_find(bat_priv, addr);
 
 	if (tt_local_entry) {
-		tt_local_event(bat_priv, TT_CHANGE_DEL, tt_local_entry->addr);
+		tt_local_event(bat_priv, TT_CHANGE_DEL, tt_local_entry->addr,
+			       roaming);
 		tt_local_del(bat_priv, tt_local_entry, message);
 	}
 	spin_unlock_bh(&bat_priv->tt_lhash_lock);
@@ -404,7 +417,7 @@ static void tt_local_purge(struct bat_priv *bat_priv)
 				continue;
 
 			tt_local_event(bat_priv, TT_CHANGE_DEL,
-				       tt_local_entry->addr);
+				       tt_local_entry->addr, false);
 			tt_local_del(bat_priv, tt_local_entry,
 				     "address timed out");
 		}
@@ -476,7 +489,7 @@ static void tt_changes_list_free(struct bat_priv *bat_priv)
 
 /* caller must hold orig_node refcount */
 int tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
-		  const unsigned char *tt_addr, uint8_t ttvn)
+		  const unsigned char *tt_addr, uint8_t ttvn, bool roaming)
 {
 	struct tt_global_entry *tt_global_entry;
 	struct tt_local_entry *tt_local_entry;
@@ -496,6 +509,8 @@ int tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
 		atomic_inc(&orig_node->refcount);
 		tt_global_entry->orig_node = orig_node;
 		tt_global_entry->ttvn = ttvn;
+		tt_global_entry->flags = NO_FLAGS;
+		tt_global_entry->roam_at = 0;
 		atomic_inc(&orig_node->tt_size);
 		hash_add(bat_priv->tt_global_hash, compare_gtt,
 			 choose_orig, tt_global_entry,
@@ -506,10 +521,12 @@ int tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
 			orig_node_tmp = tt_global_entry->orig_node;
 			atomic_inc(&orig_node->refcount);
 			tt_global_entry->orig_node = orig_node;
-			tt_global_entry->ttvn = ttvn;
 			orig_node_free_ref(orig_node_tmp);
 			atomic_inc(&orig_node->tt_size);
 		}
+		tt_global_entry->ttvn = ttvn;
+		tt_global_entry->flags = NO_FLAGS;
+		tt_global_entry->roam_at = 0;
 	}
 
 	spin_unlock_bh(&bat_priv->tt_ghash_lock);
@@ -523,8 +540,9 @@ int tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
 	tt_local_entry = tt_local_hash_find(bat_priv, tt_addr);
 
 	if (tt_local_entry)
-		tt_local_del(bat_priv, tt_local_entry,
-			     "global tt received");
+		tt_local_remove(bat_priv, tt_global_entry->addr,
+				"global tt received", roaming);
+
 	spin_unlock_bh(&bat_priv->tt_lhash_lock);
 	return 1;
 unlock:
@@ -637,7 +655,7 @@ static void _tt_global_del(struct bat_priv *bat_priv,
 
 void tt_global_del(struct bat_priv *bat_priv,
 		   struct orig_node *orig_node, const unsigned char *addr,
-		   const char *message)
+		   const char *message, bool roaming)
 {
 	struct tt_global_entry *tt_global_entry;
 
@@ -645,9 +663,15 @@ void tt_global_del(struct bat_priv *bat_priv,
 	tt_global_entry = tt_global_hash_find(bat_priv, addr);
 
 	if (tt_global_entry && tt_global_entry->orig_node == orig_node) {
+		if (roaming) {
+			tt_global_entry->flags |= TT_CLIENT_ROAM;
+			tt_global_entry->roam_at = jiffies;
+			goto out;
+		}
 		atomic_dec(&orig_node->tt_size);
 		_tt_global_del(bat_priv, tt_global_entry, message);
 	}
+out:
 	spin_unlock_bh(&bat_priv->tt_ghash_lock);
 }
 
@@ -685,6 +709,35 @@ static void tt_global_entry_free(struct hlist_node *node, void *arg)
 	kfree(data);
 }
 
+static void tt_global_roam_purge(struct bat_priv *bat_priv)
+{
+	struct hashtable_t *hash = bat_priv->tt_global_hash;
+	struct tt_global_entry *tt_global_entry;
+	struct hlist_node *node, *node_tmp;
+	struct hlist_head *head;
+	int i;
+
+	spin_lock_bh(&bat_priv->tt_ghash_lock);
+
+	for (i = 0; i < hash->size; i++) {
+		head = &hash->table[i];
+
+		hlist_for_each_entry_safe(tt_global_entry, node, node_tmp,
+					  head, hash_entry) {
+			if (!(tt_global_entry->flags & TT_CLIENT_ROAM))
+				continue;
+			if (!is_out_of_time(tt_global_entry->roam_at,
+					    TT_CLIENT_ROAM_TIMEOUT * 1000))
+				continue;
+
+			_tt_global_del(bat_priv, tt_global_entry,
+				       "Roaming timeout");
+		}
+	}
+
+	spin_unlock_bh(&bat_priv->tt_ghash_lock);
+}
+
 static void tt_global_table_free(struct bat_priv *bat_priv)
 {
 	if (!bat_priv->tt_global_hash)
@@ -734,6 +787,12 @@ uint16_t tt_global_crc(struct bat_priv *bat_priv, struct orig_node *orig_node)
 					 head, hash_entry) {
 			if (compare_eth(tt_global_entry->orig_node,
 					orig_node)) {
+				/* Roaming clients are in the global table for
+				 * consistency only. They don't have to be
+				 * taken into account while computing the
+				 * global crc */
+				if (tt_global_entry->flags & TT_CLIENT_ROAM)
+					continue;
 				total_one = 0;
 				for (j = 0; j < ETH_ALEN; j++)
 					total_one = crc16_byte(total_one,
@@ -858,6 +917,9 @@ static int tt_global_valid_entry(const void *entry_ptr, const void *data_ptr)
 	const struct tt_global_entry *tt_global_entry = entry_ptr;
 	const struct orig_node *orig_node = data_ptr;
 
+	if (tt_global_entry->flags & TT_CLIENT_ROAM)
+		return 0;
+
 	return (tt_global_entry->orig_node == orig_node);
 }
 
@@ -1251,10 +1313,11 @@ static void _tt_update_changes(struct bat_priv *bat_priv,
 		if ((tt_change + i)->flags & TT_CHANGE_DEL)
 			tt_global_del(bat_priv, orig_node,
 				      (tt_change + i)->addr,
-				      "tt removed by changes");
+				      "tt removed by changes",
+				      (tt_change + i)->flags & TT_CLIENT_ROAM);
 		else
 			if (!tt_global_add(bat_priv, orig_node,
-					   (tt_change + i)->addr, ttvn))
+					   (tt_change + i)->addr, ttvn, false))
 				/* In case of problem while storing a
 				 * global_entry, we stop the updating
 				 * procedure without committing the
@@ -1356,6 +1419,9 @@ void handle_tt_response(struct bat_priv *bat_priv,
 	spin_lock_bh(&bat_priv->tt_ghash_lock);
 	orig_node->tt_crc = tt_global_crc(bat_priv, orig_node);
 	spin_unlock_bh(&bat_priv->tt_ghash_lock);
+	/* Roaming phase is over: tables are in sync again. I can
+	 * unset the flag */
+	orig_node->tt_poss_change = false;
 out:
 	if (orig_node)
 		orig_node_free_ref(orig_node);
@@ -1374,16 +1440,134 @@ int tt_init(struct bat_priv *bat_priv)
 	return 1;
 }
 
-void tt_free(struct bat_priv *bat_priv)
+static void tt_roam_list_free(struct bat_priv *bat_priv)
 {
-	cancel_delayed_work_sync(&bat_priv->tt_work);
+	struct tt_roam_node *node, *safe;
 
-	tt_local_table_free(bat_priv);
-	tt_global_table_free(bat_priv);
-	tt_req_list_free(bat_priv);
-	tt_changes_list_free(bat_priv);
+	spin_lock_bh(&bat_priv->tt_roam_list_lock);
 
-	kfree(bat_priv->tt_buff);
+	list_for_each_entry_safe(node, safe, &bat_priv->tt_roam_list, list) {
+		list_del(&node->list);
+		kfree(node);
+	}
+
+	spin_unlock_bh(&bat_priv->tt_roam_list_lock);
+}
+
+static void tt_roam_purge(struct bat_priv *bat_priv)
+{
+	struct tt_roam_node *node, *safe;
+
+	spin_lock_bh(&bat_priv->tt_roam_list_lock);
+	list_for_each_entry_safe(node, safe, &bat_priv->tt_roam_list, list) {
+		if (!is_out_of_time(node->first_time,
+				    ROAMING_MAX_TIME * 1000))
+			continue;
+
+		list_del(&node->list);
+		kfree(node);
+	}
+	spin_unlock_bh(&bat_priv->tt_roam_list_lock);
+}
+
+/* This function checks whether the client already reached the
+ * maximum number of possible roaming phases. In this case the ROAMING_ADV
+ * will not be sent.
+ *
+ * returns true if the ROAMING_ADV can be sent, false otherwise */
+static bool tt_check_roam_count(struct bat_priv *bat_priv,
+				uint8_t *client)
+{
+	struct tt_roam_node *tt_roam_node;
+	bool ret = false;
+
+	spin_lock_bh(&bat_priv->tt_roam_list_lock);
+	/* The new tt_req will be issued only if I'm not waiting for a
+	 * reply from the same orig_node yet */
+	list_for_each_entry(tt_roam_node, &bat_priv->tt_roam_list, list) {
+		if (!compare_eth(tt_roam_node->addr, client))
+			continue;
+
+		if (is_out_of_time(tt_roam_node->first_time,
+				   ROAMING_MAX_TIME * 1000))
+			continue;
+
+		if (!atomic_dec_not_zero(&tt_roam_node->counter))
+			/* Sorry, you roamed too many times! */
+			goto unlock;
+		ret = true;
+		break;
+	}
+
+	if (!ret) {
+		tt_roam_node = kmalloc(sizeof(*tt_roam_node), GFP_ATOMIC);
+		if (!tt_roam_node)
+			goto unlock;
+
+		tt_roam_node->first_time = jiffies;
+		atomic_set(&tt_roam_node->counter, ROAMING_MAX_COUNT - 1);
+		memcpy(tt_roam_node->addr, client, ETH_ALEN);
+
+		list_add(&tt_roam_node->list, &bat_priv->tt_roam_list);
+		ret = true;
+	}
+
+unlock:
+	spin_unlock_bh(&bat_priv->tt_roam_list_lock);
+	return ret;
+}
+
+void send_roam_adv(struct bat_priv *bat_priv, uint8_t *client,
+		   struct orig_node *orig_node)
+{
+	struct neigh_node *neigh_node = NULL;
+	struct sk_buff *skb = NULL;
+	struct roam_adv_packet *roam_adv_packet;
+	int ret = 1;
+	struct hard_iface *primary_if;
+
+	/* before going on we have to check whether the client has
+	 * already roamed to us too many times */
+	if (!tt_check_roam_count(bat_priv, client))
+		goto out;
+
+	skb = dev_alloc_skb(sizeof(struct roam_adv_packet) + ETH_HLEN);
+	if (!skb)
+		goto out;
+
+	skb_reserve(skb, ETH_HLEN);
+
+	roam_adv_packet = (struct roam_adv_packet *)skb_put(skb,
+					sizeof(struct roam_adv_packet));
+
+	roam_adv_packet->packet_type = BAT_ROAM_ADV;
+	roam_adv_packet->version = COMPAT_VERSION;
+	roam_adv_packet->ttl = TTL;
+	primary_if = primary_if_get_selected(bat_priv);
+	if (!primary_if)
+		goto out;
+	memcpy(roam_adv_packet->src, primary_if->net_dev->dev_addr, ETH_ALEN);
+	hardif_free_ref(primary_if);
+	memcpy(roam_adv_packet->dst, orig_node->orig, ETH_ALEN);
+	memcpy(roam_adv_packet->client, client, ETH_ALEN);
+
+	neigh_node = orig_node_get_router(orig_node);
+	if (!neigh_node)
+		goto out;
+
+	bat_dbg(DBG_TT, bat_priv,
+		"Sending ROAMING_ADV to %pM (client %pM) via %pM\n",
+		orig_node->orig, client, neigh_node->addr);
+
+	send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
+	ret = 0;
+
+out:
+	if (neigh_node)
+		neigh_node_free_ref(neigh_node);
+	if (ret)
+		kfree_skb(skb);
+	return;
 }
 
 static void tt_purge(struct work_struct *work)
@@ -1394,7 +1578,22 @@ static void tt_purge(struct work_struct *work)
 		container_of(delayed_work, struct bat_priv, tt_work);
 
 	tt_local_purge(bat_priv);
+	tt_global_roam_purge(bat_priv);
 	tt_req_purge(bat_priv);
+	tt_roam_purge(bat_priv);
 
 	tt_start_timer(bat_priv);
 }
+
+void tt_free(struct bat_priv *bat_priv)
+{
+	cancel_delayed_work_sync(&bat_priv->tt_work);
+
+	tt_local_table_free(bat_priv);
+	tt_global_table_free(bat_priv);
+	tt_req_list_free(bat_priv);
+	tt_changes_list_free(bat_priv);
+	tt_roam_list_free(bat_priv);
+
+	kfree(bat_priv->tt_buff);
+}
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index 51f7e30..1cd2d39 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -28,20 +28,20 @@ int tt_changes_fill_buffer(struct bat_priv *bat_priv,
 int tt_init(struct bat_priv *bat_priv);
 void tt_local_add(struct net_device *soft_iface, const uint8_t *addr);
 void tt_local_remove(struct bat_priv *bat_priv,
-		     const uint8_t *addr, const char *message);
+		     const uint8_t *addr, const char *message, bool roaming);
 int tt_local_seq_print_text(struct seq_file *seq, void *offset);
 void tt_global_add_orig(struct bat_priv *bat_priv,
 			struct orig_node *orig_node,
 			const unsigned char *tt_buff, int tt_buff_len);
 int tt_global_add(struct bat_priv *bat_priv,
 		  struct orig_node *orig_node, const unsigned char *addr,
-		  uint8_t ttvn);
+		  uint8_t ttvn, bool roaming);
 int tt_global_seq_print_text(struct seq_file *seq, void *offset);
 void tt_global_del_orig(struct bat_priv *bat_priv,
 			struct orig_node *orig_node, const char *message);
 void tt_global_del(struct bat_priv *bat_priv,
 		   struct orig_node *orig_node, const unsigned char *addr,
-		   const char *message);
+		   const char *message, bool roaming);
 struct orig_node *transtable_search(struct bat_priv *bat_priv,
 				    const uint8_t *addr);
 void tt_save_orig_buffer(struct bat_priv *bat_priv, struct orig_node *orig_node,
@@ -60,5 +60,7 @@ void tt_update_changes(struct bat_priv *bat_priv, struct orig_node *orig_node,
 bool is_my_client(struct bat_priv *bat_priv, const uint8_t *addr);
 void handle_tt_response(struct bat_priv *bat_priv,
 			struct tt_query_packet *tt_response);
+void send_roam_adv(struct bat_priv *bat_priv, uint8_t *client,
+		   struct orig_node *orig_node);
 
 #endif /* _NET_BATMAN_ADV_TRANSLATION_TABLE_H_ */
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 3b642a9..9c84fa9 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -81,6 +81,12 @@ struct orig_node {
 	int16_t tt_buff_len;
 	spinlock_t tt_buff_lock; /* protects tt_buff */
 	atomic_t tt_size;
+	/* The tt_poss_change flag is used to detect an ongoing roaming phase.
+	 * If true, then I sent a Roaming_adv to this orig_node and I have to
+	 * inspect every packet directed to it to check whether it is still
+	 * the true destination or not. This flag will be reset to false as
+	 * soon as I receive a new TTVN from this orig_node */
+	bool tt_poss_change;
 	uint32_t last_real_seqno;
 	uint8_t last_ttl;
 	unsigned long bcast_bits[NUM_WORDS];
@@ -153,6 +159,12 @@ struct bat_priv {
 	atomic_t ttvn; /* tranlation table version number */
 	atomic_t tt_ogm_append_cnt;
 	atomic_t tt_local_changes; /* changes registered in a OGM interval */
+	/* The tt_poss_change flag is used to detect an ongoing roaming phase.
+	 * If true, then I received a Roaming_adv and I have to inspect every
+	 * packet directed to me to check whether I am still the true
+	 * destination or not. This flag will be reset to false as soon as I
+	 * increase my TTVN */
+	bool tt_poss_change;
 	char num_ifaces;
 	struct debug_log *debug_log;
 	struct kobject *mesh_obj;
@@ -167,6 +179,7 @@ struct bat_priv {
 	struct hashtable_t *tt_local_hash;
 	struct hashtable_t *tt_global_hash;
 	struct list_head tt_req_list; /* list of pending tt_requests */
+	struct list_head tt_roam_list;
 	struct hashtable_t *vis_hash;
 	spinlock_t forw_bat_list_lock; /* protects forw_bat_list */
 	spinlock_t forw_bcast_list_lock; /* protects  */
@@ -174,6 +187,7 @@ struct bat_priv {
 	spinlock_t tt_lhash_lock; /* protects tt_local_hash */
 	spinlock_t tt_ghash_lock; /* protects tt_global_hash */
 	spinlock_t tt_req_list_lock; /* protects tt_req_list */
+	spinlock_t tt_roam_list_lock; /* protects tt_roam_list */
 	spinlock_t gw_list_lock; /* protects gw_list and curr_gw */
 	spinlock_t vis_hash_lock; /* protects vis_hash */
 	spinlock_t vis_list_lock; /* protects vis_info::recv_list */
@@ -219,8 +233,9 @@ struct tt_global_entry {
 	uint8_t addr[ETH_ALEN];
 	struct orig_node *orig_node;
 	uint8_t ttvn;
-	/* entry in the global table */
-	struct hlist_node hash_entry;
+	uint8_t flags; /* only TT_GLOBAL_ROAM is used */
+	unsigned long roam_at; /* time at which TT_GLOBAL_ROAM was set */
+	struct hlist_node hash_entry; /* entry in the global table */
 };
 
 struct tt_change_node {
@@ -234,6 +249,13 @@ struct tt_req_node {
 	struct list_head list;
 };
 
+struct tt_roam_node {
+	uint8_t addr[ETH_ALEN];
+	atomic_t counter;
+	unsigned long first_time;
+	struct list_head list;
+};
+
 /**
  *	forw_packet - structure for forw_list maintaining packets to be
  *	              send/forwarded
-- 
1.7.5.3

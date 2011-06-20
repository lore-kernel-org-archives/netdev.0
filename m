From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 06/12] batman-adv: improved client
	announcement mechanism
Date: Mon, 20 Jun 2011 12:16:59 +0200
Message-ID: <1308565025-21293-7-git-send-email-sven@narfation.org>
References: <1308565025-21293-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
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

The client announcement mechanism informs every mesh node in the network
of any connected non-mesh client, in order to find the path towards that
client from any given point in the mesh.

The old implementation was based on the simple idea of appending a data
buffer to each OGM containing all the client MAC addresses the node is
serving. All other nodes can populate their global translation tables
(table which links client MAC addresses to node addresses) using this
MAC address buffer and linking it to the node's address contained in the
OGM. A node that wants to contact a client has to lookup the node the
client is connected to and its address in the global translation table.

It is easy to understand that this implementation suffers from several
issues:
 - big overhead (each and every OGM contains the entire list of
   connected clients)
 - high latencies for client route updates due to long OGM trip time and
   OGM losses

The new implementation addresses these issues by appending client
changes (new client joined or a client left) to the OGM instead of
filling it with all the client addresses each time. In this way nodes
can modify their global tables by means of "updates", thus reducing the
overhead within the OGMs.

To keep the entire network in sync each node maintains a translation
table version number (ttvn) and a translation table checksum. These
values are spread with the OGM to allow all the network participants to
determine whether or not they need to update their translation table
information.

When a translation table lookup is performed in order to send a packet
to a client attached to another node, the destination's ttvn is added to
the payload packet. Forwarding nodes can compare the packet's ttvn with
their destination's ttvn (this node could have a fresher information
than the source) and re-route the packet if necessary. This greatly
reduces the packet loss of clients roaming from one AP to the next.

Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/Kconfig             |    1 +
 net/batman-adv/aggregation.c       |   23 +-
 net/batman-adv/aggregation.h       |    6 +-
 net/batman-adv/bat_sysfs.c         |    2 +-
 net/batman-adv/hard-interface.c    |   13 +-
 net/batman-adv/main.c              |   13 +-
 net/batman-adv/main.h              |    7 +-
 net/batman-adv/originator.c        |    8 +-
 net/batman-adv/packet.h            |   59 ++-
 net/batman-adv/routing.c           |  248 +++++++--
 net/batman-adv/routing.h           |    6 +-
 net/batman-adv/send.c              |   87 +++-
 net/batman-adv/send.h              |    2 +-
 net/batman-adv/soft-interface.c    |   11 +-
 net/batman-adv/translation-table.c | 1134 ++++++++++++++++++++++++++++++------
 net/batman-adv/translation-table.h |   34 +-
 net/batman-adv/types.h             |   33 +-
 net/batman-adv/unicast.c           |    3 +
 18 files changed, 1383 insertions(+), 307 deletions(-)

diff --git a/net/batman-adv/Kconfig b/net/batman-adv/Kconfig
index 6c051ad..2b68d06 100644
--- a/net/batman-adv/Kconfig
+++ b/net/batman-adv/Kconfig
@@ -5,6 +5,7 @@
 config BATMAN_ADV
 	tristate "B.A.T.M.A.N. Advanced Meshing Protocol"
 	depends on NET
+	select CRC16
         default n
 	---help---
 
diff --git a/net/batman-adv/aggregation.c b/net/batman-adv/aggregation.c
index 29c6740..c583e04 100644
--- a/net/batman-adv/aggregation.c
+++ b/net/batman-adv/aggregation.c
@@ -20,17 +20,12 @@
  */
 
 #include "main.h"
+#include "translation-table.h"
 #include "aggregation.h"
 #include "send.h"
 #include "routing.h"
 #include "hard-interface.h"
 
-/* calculate the size of the tt information for a given packet */
-static int tt_len(const struct batman_packet *batman_packet)
-{
-	return batman_packet->num_tt * ETH_ALEN;
-}
-
 /* return true if new_packet can be aggregated with forw_packet */
 static bool can_aggregate_with(const struct batman_packet *new_batman_packet,
 			       int packet_len,
@@ -264,18 +259,20 @@ void receive_aggr_bat_packet(const struct ethhdr *ethhdr,
 	batman_packet = (struct batman_packet *)packet_buff;
 
 	do {
-		/* network to host order for our 32bit seqno, and the
-		   orig_interval. */
+		/* network to host order for our 32bit seqno and the
+		   orig_interval */
 		batman_packet->seqno = ntohl(batman_packet->seqno);
+		batman_packet->tt_crc = ntohs(batman_packet->tt_crc);
 
 		tt_buff = packet_buff + buff_pos + BAT_PACKET_LEN;
-		receive_bat_packet(ethhdr, batman_packet,
-				   tt_buff, tt_len(batman_packet),
-				   if_incoming);
 
-		buff_pos += BAT_PACKET_LEN + tt_len(batman_packet);
+		receive_bat_packet(ethhdr, batman_packet, tt_buff, if_incoming);
+
+		buff_pos += BAT_PACKET_LEN +
+			tt_len(batman_packet->tt_num_changes);
+
 		batman_packet = (struct batman_packet *)
 			(packet_buff + buff_pos);
 	} while (aggregated_packet(buff_pos, packet_len,
-				   batman_packet->num_tt));
+				   batman_packet->tt_num_changes));
 }
diff --git a/net/batman-adv/aggregation.h b/net/batman-adv/aggregation.h
index 0547fd8..216337b 100644
--- a/net/batman-adv/aggregation.h
+++ b/net/batman-adv/aggregation.h
@@ -25,9 +25,11 @@
 #include "main.h"
 
 /* is there another aggregated packet here? */
-static inline int aggregated_packet(int buff_pos, int packet_len, int num_tt)
+static inline int aggregated_packet(int buff_pos, int packet_len,
+				    int tt_num_changes)
 {
-	int next_buff_pos = buff_pos + BAT_PACKET_LEN + (num_tt * ETH_ALEN);
+	int next_buff_pos = buff_pos + BAT_PACKET_LEN + (tt_num_changes *
+						sizeof(struct tt_change));
 
 	return (next_buff_pos <= packet_len) &&
 		(next_buff_pos <= MAX_AGGREGATION_BYTES);
diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index 924d577..63738ec 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -375,7 +375,7 @@ BAT_ATTR_UINT(gw_sel_class, S_IRUGO | S_IWUSR, 1, TQ_MAX_VALUE,
 static BAT_ATTR(gw_bandwidth, S_IRUGO | S_IWUSR, show_gw_bwidth,
 		store_gw_bwidth);
 #ifdef CONFIG_BATMAN_ADV_DEBUG
-BAT_ATTR_UINT(log_level, S_IRUGO | S_IWUSR, 0, 3, NULL);
+BAT_ATTR_UINT(log_level, S_IRUGO | S_IWUSR, 0, 7, NULL);
 #endif
 
 static struct bat_attribute *mesh_attrs[] = {
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index b55e861..d40426c 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -152,12 +152,6 @@ static void primary_if_select(struct bat_priv *bat_priv,
 	batman_packet->ttl = TTL;
 
 	primary_if_update_addr(bat_priv);
-
-	/***
-	 * hacky trick to make sure that we send the TT information via
-	 * our new primary interface
-	 */
-	atomic_set(&bat_priv->tt_local_changed, 1);
 }
 
 static bool hardif_is_iface_up(const struct hard_iface *hard_iface)
@@ -340,7 +334,8 @@ int hardif_enable_interface(struct hard_iface *hard_iface,
 	batman_packet->flags = NO_FLAGS;
 	batman_packet->ttl = 2;
 	batman_packet->tq = TQ_MAX_VALUE;
-	batman_packet->num_tt = 0;
+	batman_packet->tt_num_changes = 0;
+	batman_packet->ttvn = 0;
 
 	hard_iface->if_num = bat_priv->num_ifaces;
 	bat_priv->num_ifaces++;
@@ -659,6 +654,10 @@ static int batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	case BAT_VIS:
 		ret = recv_vis_packet(skb, hard_iface);
 		break;
+		/* Translation table query (request or response) */
+	case BAT_TT_QUERY:
+		ret = recv_tt_query(skb, hard_iface);
+		break;
 	default:
 		ret = NET_RX_DROP;
 	}
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 2d6445e..49a5e64 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -86,6 +86,9 @@ int mesh_init(struct net_device *soft_iface)
 	spin_lock_init(&bat_priv->forw_bcast_list_lock);
 	spin_lock_init(&bat_priv->tt_lhash_lock);
 	spin_lock_init(&bat_priv->tt_ghash_lock);
+	spin_lock_init(&bat_priv->tt_changes_list_lock);
+	spin_lock_init(&bat_priv->tt_req_list_lock);
+	spin_lock_init(&bat_priv->tt_buff_lock);
 	spin_lock_init(&bat_priv->gw_list_lock);
 	spin_lock_init(&bat_priv->vis_hash_lock);
 	spin_lock_init(&bat_priv->vis_list_lock);
@@ -96,14 +99,13 @@ int mesh_init(struct net_device *soft_iface)
 	INIT_HLIST_HEAD(&bat_priv->forw_bcast_list);
 	INIT_HLIST_HEAD(&bat_priv->gw_list);
 	INIT_HLIST_HEAD(&bat_priv->softif_neigh_vids);
+	INIT_LIST_HEAD(&bat_priv->tt_changes_list);
+	INIT_LIST_HEAD(&bat_priv->tt_req_list);
 
 	if (originator_init(bat_priv) < 1)
 		goto err;
 
-	if (tt_local_init(bat_priv) < 1)
-		goto err;
-
-	if (tt_global_init(bat_priv) < 1)
+	if (tt_init(bat_priv) < 1)
 		goto err;
 
 	tt_local_add(soft_iface, soft_iface->dev_addr);
@@ -137,8 +139,7 @@ void mesh_free(struct net_device *soft_iface)
 	gw_node_purge(bat_priv);
 	originator_free(bat_priv);
 
-	tt_local_free(bat_priv);
-	tt_global_free(bat_priv);
+	tt_free(bat_priv);
 
 	softif_neigh_purge(bat_priv);
 
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 714a241..6f53a1d 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -46,11 +46,15 @@
 /* sliding packet range of received originator messages in squence numbers
  * (should be a multiple of our word size) */
 #define TQ_LOCAL_WINDOW_SIZE 64
+#define TT_REQUEST_TIMEOUT 3 /* seconds we have to keep pending tt_req */
+
 #define TQ_GLOBAL_WINDOW_SIZE 5
 #define TQ_LOCAL_BIDRECT_SEND_MINIMUM 1
 #define TQ_LOCAL_BIDRECT_RECV_MINIMUM 1
 #define TQ_TOTAL_BIDRECT_LIMIT 1
 
+#define TT_OGM_APPEND_MAX 3 /* number of OGMs sent with the last tt diff */
+
 #define NO_FLAGS 0
 
 #define NUM_WORDS (TQ_LOCAL_WINDOW_SIZE / WORD_BIT_SIZE)
@@ -96,7 +100,8 @@ enum mesh_state {
 enum dbg_level {
 	DBG_BATMAN = 1 << 0,
 	DBG_ROUTES = 1 << 1, /* route added / changed / deleted */
-	DBG_ALL    = 3
+	DBG_TT	   = 1 << 2, /* translation table operations */
+	DBG_ALL    = 7
 };
 
 
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 991a6e7..25e7e50 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -145,6 +145,7 @@ static void orig_node_free_rcu(struct rcu_head *rcu)
 	tt_global_del_orig(orig_node->bat_priv, orig_node,
 			    "originator timed out");
 
+	kfree(orig_node->tt_buff);
 	kfree(orig_node->bcast_own);
 	kfree(orig_node->bcast_own_sum);
 	kfree(orig_node);
@@ -213,6 +214,7 @@ struct orig_node *get_orig_node(struct bat_priv *bat_priv, const uint8_t *addr)
 	spin_lock_init(&orig_node->ogm_cnt_lock);
 	spin_lock_init(&orig_node->bcast_seqno_lock);
 	spin_lock_init(&orig_node->neigh_list_lock);
+	spin_lock_init(&orig_node->tt_buff_lock);
 
 	/* extra reference for return */
 	atomic_set(&orig_node->refcount, 2);
@@ -221,6 +223,8 @@ struct orig_node *get_orig_node(struct bat_priv *bat_priv, const uint8_t *addr)
 	memcpy(orig_node->orig, addr, ETH_ALEN);
 	orig_node->router = NULL;
 	orig_node->tt_buff = NULL;
+	orig_node->tt_buff_len = 0;
+	atomic_set(&orig_node->tt_size, 0);
 	orig_node->bcast_seqno_reset = jiffies - 1
 					- msecs_to_jiffies(RESET_PROTECTION_MS);
 	orig_node->batman_seqno_reset = jiffies - 1
@@ -330,9 +334,7 @@ static bool purge_orig_node(struct bat_priv *bat_priv,
 		if (purge_orig_neighbors(bat_priv, orig_node,
 							&best_neigh_node)) {
 			update_routes(bat_priv, orig_node,
-				      best_neigh_node,
-				      orig_node->tt_buff,
-				      orig_node->tt_buff_len);
+				      best_neigh_node);
 		}
 	}
 
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 6ddbfd8..407dd2e 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -30,7 +30,8 @@ enum bat_packettype {
 	BAT_UNICAST      = 0x03,
 	BAT_BCAST        = 0x04,
 	BAT_VIS          = 0x05,
-	BAT_UNICAST_FRAG = 0x06
+	BAT_UNICAST_FRAG = 0x06,
+	BAT_TT_QUERY     = 0x07
 };
 
 /* this file is included by batctl which needs these defines */
@@ -63,6 +64,25 @@ enum unicast_frag_flags {
 	UNI_FRAG_LARGETAIL = 1 << 1
 };
 
+/* TT_QUERY subtypes */
+#define TT_QUERY_TYPE_MASK 0x3
+
+enum tt_query_packettype {
+	TT_REQUEST    = 0,
+	TT_RESPONSE   = 1
+};
+
+/* TT_QUERY flags */
+enum tt_query_flags {
+	TT_FULL_TABLE = 1 << 2
+};
+
+/* TT_CHANGE flags */
+enum tt_change_flags {
+	TT_CHANGE_DEL  = 0x01,
+	TT_CLIENT_ROAM = 0x02
+};
+
 struct batman_packet {
 	uint8_t  packet_type;
 	uint8_t  version;  /* batman version field */
@@ -73,8 +93,9 @@ struct batman_packet {
 	uint8_t  prev_sender[6];
 	uint8_t  gw_flags;  /* flags related to gateway class */
 	uint8_t  tq;
-	uint8_t  num_tt;
-	uint8_t  reserved;
+	uint8_t  tt_num_changes;
+	uint8_t  ttvn; /* translation table version number */
+	uint16_t tt_crc;
 } __packed;
 
 #define BAT_PACKET_LEN sizeof(struct batman_packet)
@@ -112,7 +133,7 @@ struct unicast_packet {
 	uint8_t  packet_type;
 	uint8_t  version;  /* batman version field */
 	uint8_t  ttl;
-	uint8_t  reserved;
+	uint8_t  ttvn; /* destination translation table version number */
 	uint8_t  dest[6];
 } __packed;
 
@@ -120,7 +141,7 @@ struct unicast_frag_packet {
 	uint8_t  packet_type;
 	uint8_t  version;  /* batman version field */
 	uint8_t  ttl;
-	uint8_t  reserved;
+	uint8_t  ttvn; /* destination translation table version number */
 	uint8_t  dest[6];
 	uint8_t  flags;
 	uint8_t  align;
@@ -150,4 +171,32 @@ struct vis_packet {
 	uint8_t  sender_orig[6]; /* who sent or rebroadcasted this packet */
 } __packed;
 
+struct tt_query_packet {
+	uint8_t  packet_type;
+	uint8_t  version;  /* batman version field */
+	uint8_t  ttl;
+	/* the flag field is a combination of:
+	 * - TT_REQUEST or TT_RESPONSE
+	 * - TT_FULL_TABLE */
+	uint8_t  flags;
+	uint8_t  dst[ETH_ALEN];
+	uint8_t  src[ETH_ALEN];
+	/* the ttvn field is:
+	 * if TT_REQUEST: ttvn that triggered the
+	 *		  request
+	 * if TT_RESPONSE: new ttvn for the src
+	 *		   orig_node */
+	uint8_t  ttvn;
+	/* tt_data field is:
+	 * if TT_REQUEST: crc associated with the
+	 *		  ttvn
+	 * if TT_RESPONSE: table_size */
+	uint16_t tt_data;
+} __packed;
+
+struct tt_change {
+	uint8_t flags;
+	uint8_t addr[ETH_ALEN];
+} __packed;
+
 #endif /* _NET_BATMAN_ADV_PACKET_H_ */
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index eb6fb7d..8b0f833 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -64,27 +64,56 @@ void slide_own_bcast_window(struct hard_iface *hard_iface)
 	}
 }
 
-static void update_TT(struct bat_priv *bat_priv, struct orig_node *orig_node,
-		      const unsigned char *tt_buff, int tt_buff_len)
+static void update_transtable(struct bat_priv *bat_priv,
+			      struct orig_node *orig_node,
+			      const unsigned char *tt_buff,
+			      uint8_t tt_num_changes, uint8_t ttvn,
+			      uint16_t tt_crc)
 {
-	if ((tt_buff_len != orig_node->tt_buff_len) ||
-	    ((tt_buff_len > 0) &&
-	     (orig_node->tt_buff_len > 0) &&
-	     (memcmp(orig_node->tt_buff, tt_buff, tt_buff_len) != 0))) {
+	uint8_t orig_ttvn = (uint8_t)atomic_read(&orig_node->last_ttvn);
+	bool full_table = true;
 
-		if (orig_node->tt_buff_len > 0)
-			tt_global_del_orig(bat_priv, orig_node,
-					    "originator changed tt");
+	/* the ttvn increased by one -> we can apply the attached changes */
+	if (ttvn - orig_ttvn == 1) {
+		/* the OGM could not contain the changes because they were too
+		 * many to fit in one frame or because they have already been
+		 * sent TT_OGM_APPEND_MAX times. In this case send a tt
+		 * request */
+		if (!tt_num_changes) {
+			full_table = false;
+			goto request_table;
+		}
 
-		if ((tt_buff_len > 0) && (tt_buff))
-			tt_global_add_orig(bat_priv, orig_node,
-					    tt_buff, tt_buff_len);
+		tt_update_changes(bat_priv, orig_node, tt_num_changes, ttvn,
+				  (struct tt_change *)tt_buff);
+
+		/* Even if we received the crc into the OGM, we prefer
+		 * to recompute it to spot any possible inconsistency
+		 * in the global table */
+		spin_lock_bh(&bat_priv->tt_ghash_lock);
+		orig_node->tt_crc = tt_global_crc(bat_priv, orig_node);
+		spin_unlock_bh(&bat_priv->tt_ghash_lock);
+	} else {
+		/* if we missed more than one change or our tables are not
+		 * in sync anymore -> request fresh tt data */
+		if (ttvn != orig_ttvn || orig_node->tt_crc != tt_crc) {
+request_table:
+			bat_dbg(DBG_TT, bat_priv, "TT inconsistency for %pM. "
+				"Need to retrieve the correct information "
+				"(ttvn: %u last_ttvn: %u crc: %u last_crc: "
+				"%u num_changes: %u)\n", orig_node->orig, ttvn,
+				orig_ttvn, tt_crc, orig_node->tt_crc,
+				tt_num_changes);
+			send_tt_request(bat_priv, orig_node, ttvn, tt_crc,
+					full_table);
+			return;
+		}
 	}
 }
 
-static void update_route(struct bat_priv *bat_priv, struct orig_node *orig_node,
-			 struct neigh_node *neigh_node,
-			 const unsigned char *tt_buff, int tt_buff_len)
+static void update_route(struct bat_priv *bat_priv,
+			 struct orig_node *orig_node,
+			 struct neigh_node *neigh_node)
 {
 	struct neigh_node *curr_router;
 
@@ -92,11 +121,10 @@ static void update_route(struct bat_priv *bat_priv, struct orig_node *orig_node,
 
 	/* route deleted */
 	if ((curr_router) && (!neigh_node)) {
-
 		bat_dbg(DBG_ROUTES, bat_priv, "Deleting route towards: %pM\n",
 			orig_node->orig);
 		tt_global_del_orig(bat_priv, orig_node,
-				    "originator timed out");
+				    "Deleted route towards originator");
 
 	/* route added */
 	} else if ((!curr_router) && (neigh_node)) {
@@ -104,9 +132,6 @@ static void update_route(struct bat_priv *bat_priv, struct orig_node *orig_node,
 		bat_dbg(DBG_ROUTES, bat_priv,
 			"Adding route towards: %pM (via %pM)\n",
 			orig_node->orig, neigh_node->addr);
-		tt_global_add_orig(bat_priv, orig_node,
-				    tt_buff, tt_buff_len);
-
 	/* route changed */
 	} else if (neigh_node && curr_router) {
 		bat_dbg(DBG_ROUTES, bat_priv,
@@ -133,8 +158,7 @@ static void update_route(struct bat_priv *bat_priv, struct orig_node *orig_node,
 }
 
 void update_routes(struct bat_priv *bat_priv, struct orig_node *orig_node,
-		   struct neigh_node *neigh_node, const unsigned char *tt_buff,
-		   int tt_buff_len)
+		   struct neigh_node *neigh_node)
 {
 	struct neigh_node *router = NULL;
 
@@ -144,11 +168,7 @@ void update_routes(struct bat_priv *bat_priv, struct orig_node *orig_node,
 	router = orig_node_get_router(orig_node);
 
 	if (router != neigh_node)
-		update_route(bat_priv, orig_node, neigh_node,
-			     tt_buff, tt_buff_len);
-	/* may be just TT changed */
-	else
-		update_TT(bat_priv, orig_node, tt_buff, tt_buff_len);
+		update_route(bat_priv, orig_node, neigh_node);
 
 out:
 	if (router)
@@ -360,14 +380,12 @@ static void update_orig(struct bat_priv *bat_priv, struct orig_node *orig_node,
 			const struct ethhdr *ethhdr,
 			const struct batman_packet *batman_packet,
 			struct hard_iface *if_incoming,
-			const unsigned char *tt_buff, int tt_buff_len,
-			int is_duplicate)
+			const unsigned char *tt_buff, int is_duplicate)
 {
 	struct neigh_node *neigh_node = NULL, *tmp_neigh_node = NULL;
 	struct neigh_node *router = NULL;
 	struct orig_node *orig_node_tmp;
 	struct hlist_node *node;
-	int tmp_tt_buff_len;
 	uint8_t bcast_own_sum_orig, bcast_own_sum_neigh;
 
 	bat_dbg(DBG_BATMAN, bat_priv, "update_originator(): "
@@ -432,9 +450,6 @@ static void update_orig(struct bat_priv *bat_priv, struct orig_node *orig_node,
 
 	bonding_candidate_add(orig_node, neigh_node);
 
-	tmp_tt_buff_len = (tt_buff_len > batman_packet->num_tt * ETH_ALEN ?
-			    batman_packet->num_tt * ETH_ALEN : tt_buff_len);
-
 	/* if this neighbor already is our next hop there is nothing
 	 * to change */
 	router = orig_node_get_router(orig_node);
@@ -464,15 +479,19 @@ static void update_orig(struct bat_priv *bat_priv, struct orig_node *orig_node,
 			goto update_tt;
 	}
 
-	update_routes(bat_priv, orig_node, neigh_node,
-		      tt_buff, tmp_tt_buff_len);
-	goto update_gw;
+	update_routes(bat_priv, orig_node, neigh_node);
 
 update_tt:
-	update_routes(bat_priv, orig_node, router,
-		      tt_buff, tmp_tt_buff_len);
+	/* I have to check for transtable changes only if the OGM has been
+	 * sent through a primary interface */
+	if (((batman_packet->orig != ethhdr->h_source) &&
+				(batman_packet->ttl > 2)) ||
+				(batman_packet->flags & PRIMARIES_FIRST_HOP))
+		update_transtable(bat_priv, orig_node, tt_buff,
+				  batman_packet->tt_num_changes,
+				  batman_packet->ttvn,
+				  batman_packet->tt_crc);
 
-update_gw:
 	if (orig_node->gw_flags != batman_packet->gw_flags)
 		gw_node_update(bat_priv, orig_node, batman_packet->gw_flags);
 
@@ -594,7 +613,7 @@ out:
 
 void receive_bat_packet(const struct ethhdr *ethhdr,
 			struct batman_packet *batman_packet,
-			const unsigned char *tt_buff, int tt_buff_len,
+			const unsigned char *tt_buff,
 			struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
@@ -633,12 +652,14 @@ void receive_bat_packet(const struct ethhdr *ethhdr,
 
 	bat_dbg(DBG_BATMAN, bat_priv,
 		"Received BATMAN packet via NB: %pM, IF: %s [%pM] "
-		"(from OG: %pM, via prev OG: %pM, seqno %d, tq %d, "
-		"TTL %d, V %d, IDF %d)\n",
+		"(from OG: %pM, via prev OG: %pM, seqno %d, ttvn %u, "
+		"crc %u, changes %u, td %d, TTL %d, V %d, IDF %d)\n",
 		ethhdr->h_source, if_incoming->net_dev->name,
 		if_incoming->net_dev->dev_addr, batman_packet->orig,
 		batman_packet->prev_sender, batman_packet->seqno,
-		batman_packet->tq, batman_packet->ttl, batman_packet->version,
+		batman_packet->ttvn, batman_packet->tt_crc,
+		batman_packet->tt_num_changes, batman_packet->tq,
+		batman_packet->ttl, batman_packet->version,
 		has_directlink_flag);
 
 	rcu_read_lock();
@@ -790,14 +811,14 @@ void receive_bat_packet(const struct ethhdr *ethhdr,
 	     ((orig_node->last_real_seqno == batman_packet->seqno) &&
 	      (orig_node->last_ttl - 3 <= batman_packet->ttl))))
 		update_orig(bat_priv, orig_node, ethhdr, batman_packet,
-			    if_incoming, tt_buff, tt_buff_len, is_duplicate);
+			    if_incoming, tt_buff, is_duplicate);
 
 	/* is single hop (direct) neighbor */
 	if (is_single_hop_neigh) {
 
 		/* mark direct link on incoming interface */
 		schedule_forward_packet(orig_node, ethhdr, batman_packet,
-					1, tt_buff_len, if_incoming);
+					1, if_incoming);
 
 		bat_dbg(DBG_BATMAN, bat_priv, "Forwarding packet: "
 			"rebroadcast neighbor packet with direct link flag\n");
@@ -820,7 +841,7 @@ void receive_bat_packet(const struct ethhdr *ethhdr,
 	bat_dbg(DBG_BATMAN, bat_priv,
 		"Forwarding packet: rebroadcast originator packet\n");
 	schedule_forward_packet(orig_node, ethhdr, batman_packet,
-				0, tt_buff_len, if_incoming);
+				0, if_incoming);
 
 out_neigh:
 	if ((orig_neigh_node) && (!is_single_hop_neigh))
@@ -1167,6 +1188,70 @@ static struct neigh_node *find_ifalter_router(struct orig_node *primary_orig,
 	return router;
 }
 
+int recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if)
+{
+	struct bat_priv *bat_priv = netdev_priv(recv_if->soft_iface);
+	struct tt_query_packet *tt_query;
+	struct ethhdr *ethhdr;
+
+	/* drop packet if it has not necessary minimum size */
+	if (unlikely(!pskb_may_pull(skb, sizeof(struct tt_query_packet))))
+		goto out;
+
+	/* I could need to modify it */
+	if (skb_cow(skb, sizeof(struct tt_query_packet)) < 0)
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
+	tt_query = (struct tt_query_packet *)skb->data;
+
+	tt_query->tt_data = ntohs(tt_query->tt_data);
+
+	switch (tt_query->flags & TT_QUERY_TYPE_MASK) {
+	case TT_REQUEST:
+		/* If we cannot provide an answer the tt_request is
+		 * forwarded */
+		if (!send_tt_response(bat_priv, tt_query)) {
+			bat_dbg(DBG_TT, bat_priv,
+				"Routing TT_REQUEST to %pM [%c]\n",
+				tt_query->dst,
+				(tt_query->flags & TT_FULL_TABLE ? 'F' : '.'));
+			tt_query->tt_data = htons(tt_query->tt_data);
+			return route_unicast_packet(skb, recv_if);
+		}
+		break;
+	case TT_RESPONSE:
+		/* packet needs to be linearised to access the TT changes */
+		if (skb_linearize(skb) < 0)
+			goto out;
+
+		if (is_my_mac(tt_query->dst))
+			handle_tt_response(bat_priv, tt_query);
+		else {
+			bat_dbg(DBG_TT, bat_priv,
+				"Routing TT_RESPONSE to %pM [%c]\n",
+				tt_query->dst,
+				(tt_query->flags & TT_FULL_TABLE ? 'F' : '.'));
+			tt_query->tt_data = htons(tt_query->tt_data);
+			return route_unicast_packet(skb, recv_if);
+		}
+		break;
+	}
+
+out:
+	/* returning NET_RX_DROP will make the caller function kfree the skb */
+	return NET_RX_DROP;
+}
+
 /* find a suitable router for this originator, and use
  * bonding if possible. increases the found neighbors
  * refcount.*/
@@ -1353,14 +1438,82 @@ out:
 	return ret;
 }
 
+static int check_unicast_ttvn(struct bat_priv *bat_priv,
+			       struct sk_buff *skb) {
+	uint8_t curr_ttvn;
+	struct orig_node *orig_node;
+	struct ethhdr *ethhdr;
+	struct hard_iface *primary_if;
+	struct unicast_packet *unicast_packet;
+
+	/* I could need to modify it */
+	if (skb_cow(skb, sizeof(struct unicast_packet)) < 0)
+		return 0;
+
+	unicast_packet = (struct unicast_packet *)skb->data;
+
+	if (is_my_mac(unicast_packet->dest))
+		curr_ttvn = (uint8_t)atomic_read(&bat_priv->ttvn);
+	else {
+		orig_node = orig_hash_find(bat_priv, unicast_packet->dest);
+
+		if (!orig_node)
+			return 0;
+
+		curr_ttvn = (uint8_t)atomic_read(&orig_node->last_ttvn);
+		orig_node_free_ref(orig_node);
+	}
+
+	/* Check whether I have to reroute the packet */
+	if (seq_before(unicast_packet->ttvn, curr_ttvn)) {
+		/* Linearize the skb before accessing it */
+		if (skb_linearize(skb) < 0)
+			return 0;
+
+		ethhdr = (struct ethhdr *)(skb->data +
+			sizeof(struct unicast_packet));
+
+		orig_node = transtable_search(bat_priv, ethhdr->h_dest);
+
+		if (!orig_node) {
+			if (!is_my_client(bat_priv, ethhdr->h_dest))
+				return 0;
+			primary_if = primary_if_get_selected(bat_priv);
+			if (!primary_if)
+				return 0;
+			memcpy(unicast_packet->dest,
+			       primary_if->net_dev->dev_addr, ETH_ALEN);
+			hardif_free_ref(primary_if);
+		} else {
+			memcpy(unicast_packet->dest, orig_node->orig,
+			       ETH_ALEN);
+			curr_ttvn = (uint8_t)
+				atomic_read(&orig_node->last_ttvn);
+			orig_node_free_ref(orig_node);
+		}
+
+		bat_dbg(DBG_ROUTES, bat_priv, "TTVN mismatch (old_ttvn %u "
+			"new_ttvn %u)! Rerouting unicast packet (for %pM) to "
+			"%pM\n", unicast_packet->ttvn, curr_ttvn,
+			ethhdr->h_dest, unicast_packet->dest);
+
+		unicast_packet->ttvn = curr_ttvn;
+	}
+	return 1;
+}
+
 int recv_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 {
+	struct bat_priv *bat_priv = netdev_priv(recv_if->soft_iface);
 	struct unicast_packet *unicast_packet;
 	int hdr_size = sizeof(*unicast_packet);
 
 	if (check_unicast_packet(skb, hdr_size) < 0)
 		return NET_RX_DROP;
 
+	if (!check_unicast_ttvn(bat_priv, skb))
+		return NET_RX_DROP;
+
 	unicast_packet = (struct unicast_packet *)skb->data;
 
 	/* packet for me */
@@ -1383,6 +1536,9 @@ int recv_ucast_frag_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	if (check_unicast_packet(skb, hdr_size) < 0)
 		return NET_RX_DROP;
 
+	if (!check_unicast_ttvn(bat_priv, skb))
+		return NET_RX_DROP;
+
 	unicast_packet = (struct unicast_frag_packet *)skb->data;
 
 	/* packet for me */
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index 0ce0392..e77d464 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -25,11 +25,10 @@
 void slide_own_bcast_window(struct hard_iface *hard_iface);
 void receive_bat_packet(const struct ethhdr *ethhdr,
 			struct batman_packet *batman_packet,
-			const unsigned char *tt_buff, int tt_buff_len,
+			const unsigned char *tt_buff,
 			struct hard_iface *if_incoming);
 void update_routes(struct bat_priv *bat_priv, struct orig_node *orig_node,
-		   struct neigh_node *neigh_node, const unsigned char *tt_buff,
-		   int tt_buff_len);
+		   struct neigh_node *neigh_node);
 int route_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if);
 int recv_icmp_packet(struct sk_buff *skb, struct hard_iface *recv_if);
 int recv_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if);
@@ -37,6 +36,7 @@ int recv_ucast_frag_packet(struct sk_buff *skb, struct hard_iface *recv_if);
 int recv_bcast_packet(struct sk_buff *skb, struct hard_iface *recv_if);
 int recv_vis_packet(struct sk_buff *skb, struct hard_iface *recv_if);
 int recv_bat_packet(struct sk_buff *skb, struct hard_iface *recv_if);
+int recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if);
 struct neigh_node *find_router(struct bat_priv *bat_priv,
 			       struct orig_node *orig_node,
 			       const struct hard_iface *recv_if);
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index be0d581..6b14075 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -120,7 +120,7 @@ static void send_packet_to_if(struct forw_packet *forw_packet,
 	/* adjust all flags and log packets */
 	while (aggregated_packet(buff_pos,
 				 forw_packet->packet_len,
-				 batman_packet->num_tt)) {
+				 batman_packet->tt_num_changes)) {
 
 		/* we might have aggregated direct link packets with an
 		 * ordinary base packet */
@@ -135,17 +135,17 @@ static void send_packet_to_if(struct forw_packet *forw_packet,
 							    "Forwarding"));
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"%s %spacket (originator %pM, seqno %d, TQ %d, TTL %d,"
-			" IDF %s) on interface %s [%pM]\n",
+			" IDF %s, hvn %d) on interface %s [%pM]\n",
 			fwd_str, (packet_num > 0 ? "aggregated " : ""),
 			batman_packet->orig, ntohl(batman_packet->seqno),
 			batman_packet->tq, batman_packet->ttl,
 			(batman_packet->flags & DIRECTLINK ?
 			 "on" : "off"),
-			hard_iface->net_dev->name,
+			batman_packet->ttvn, hard_iface->net_dev->name,
 			hard_iface->net_dev->dev_addr);
 
 		buff_pos += sizeof(*batman_packet) +
-			(batman_packet->num_tt * ETH_ALEN);
+			tt_len(batman_packet->tt_num_changes);
 		packet_num++;
 		batman_packet = (struct batman_packet *)
 			(forw_packet->skb->data + buff_pos);
@@ -213,25 +213,18 @@ static void send_packet(struct forw_packet *forw_packet)
 	rcu_read_unlock();
 }
 
-static void rebuild_batman_packet(struct bat_priv *bat_priv,
-				  struct hard_iface *hard_iface)
+static void realloc_packet_buffer(struct hard_iface *hard_iface,
+				int new_len)
 {
-	int new_len;
 	unsigned char *new_buff;
 	struct batman_packet *batman_packet;
 
-	new_len = sizeof(*batman_packet) + (bat_priv->num_local_tt * ETH_ALEN);
 	new_buff = kmalloc(new_len, GFP_ATOMIC);
 
 	/* keep old buffer if kmalloc should fail */
 	if (new_buff) {
 		memcpy(new_buff, hard_iface->packet_buff,
 		       sizeof(*batman_packet));
-		batman_packet = (struct batman_packet *)new_buff;
-
-		batman_packet->num_tt = tt_local_fill_buffer(bat_priv,
-					new_buff + sizeof(*batman_packet),
-					new_len - sizeof(*batman_packet));
 
 		kfree(hard_iface->packet_buff);
 		hard_iface->packet_buff = new_buff;
@@ -239,6 +232,46 @@ static void rebuild_batman_packet(struct bat_priv *bat_priv,
 	}
 }
 
+/* when calling this function (hard_iface == primary_if) has to be true */
+static void prepare_packet_buffer(struct bat_priv *bat_priv,
+				  struct hard_iface *hard_iface)
+{
+	int new_len;
+	struct batman_packet *batman_packet;
+
+	new_len = BAT_PACKET_LEN +
+		  tt_len((uint8_t)atomic_read(&bat_priv->tt_local_changes));
+
+	/* if we have too many changes for one packet don't send any
+	 * and wait for the tt table request which will be fragmented */
+	if (new_len > hard_iface->soft_iface->mtu)
+		new_len = BAT_PACKET_LEN;
+
+	realloc_packet_buffer(hard_iface, new_len);
+	batman_packet = (struct batman_packet *)hard_iface->packet_buff;
+
+	atomic_set(&bat_priv->tt_crc, tt_local_crc(bat_priv));
+
+	/* reset the sending counter */
+	atomic_set(&bat_priv->tt_ogm_append_cnt, TT_OGM_APPEND_MAX);
+
+	batman_packet->tt_num_changes = tt_changes_fill_buffer(bat_priv,
+				hard_iface->packet_buff + BAT_PACKET_LEN,
+				hard_iface->packet_len - BAT_PACKET_LEN);
+
+}
+
+static void reset_packet_buffer(struct bat_priv *bat_priv,
+	struct hard_iface *hard_iface)
+{
+	struct batman_packet *batman_packet;
+
+	realloc_packet_buffer(hard_iface, BAT_PACKET_LEN);
+
+	batman_packet = (struct batman_packet *)hard_iface->packet_buff;
+	batman_packet->tt_num_changes = 0;
+}
+
 void schedule_own_packet(struct hard_iface *hard_iface)
 {
 	struct bat_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
@@ -264,14 +297,22 @@ void schedule_own_packet(struct hard_iface *hard_iface)
 	if (hard_iface->if_status == IF_TO_BE_ACTIVATED)
 		hard_iface->if_status = IF_ACTIVE;
 
-	/* if local tt has changed and interface is a primary interface */
-	if ((atomic_read(&bat_priv->tt_local_changed)) &&
-	    (hard_iface == primary_if))
-		rebuild_batman_packet(bat_priv, hard_iface);
+	if (hard_iface == primary_if) {
+		/* if at least one change happened */
+		if (atomic_read(&bat_priv->tt_local_changes) > 0) {
+			prepare_packet_buffer(bat_priv, hard_iface);
+			/* Increment the TTVN only once per OGM interval */
+			atomic_inc(&bat_priv->ttvn);
+		}
+
+		/* if the changes have been sent enough times */
+		if (!atomic_dec_not_zero(&bat_priv->tt_ogm_append_cnt))
+			reset_packet_buffer(bat_priv, hard_iface);
+	}
 
 	/**
 	 * NOTE: packet_buff might just have been re-allocated in
-	 * rebuild_batman_packet()
+	 * prepare_packet_buffer() or in reset_packet_buffer()
 	 */
 	batman_packet = (struct batman_packet *)hard_iface->packet_buff;
 
@@ -279,6 +320,9 @@ void schedule_own_packet(struct hard_iface *hard_iface)
 	batman_packet->seqno =
 		htonl((uint32_t)atomic_read(&hard_iface->seqno));
 
+	batman_packet->ttvn = atomic_read(&bat_priv->ttvn);
+	batman_packet->tt_crc = htons((uint16_t)atomic_read(&bat_priv->tt_crc));
+
 	if (vis_server == VIS_TYPE_SERVER_SYNC)
 		batman_packet->flags |= VIS_SERVER;
 	else
@@ -307,13 +351,14 @@ void schedule_own_packet(struct hard_iface *hard_iface)
 void schedule_forward_packet(struct orig_node *orig_node,
 			     const struct ethhdr *ethhdr,
 			     struct batman_packet *batman_packet,
-			     int directlink, int tt_buff_len,
+			     int directlink,
 			     struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct neigh_node *router;
 	uint8_t in_tq, in_ttl, tq_avg = 0;
 	unsigned long send_time;
+	uint8_t tt_num_changes;
 
 	if (batman_packet->ttl <= 1) {
 		bat_dbg(DBG_BATMAN, bat_priv, "ttl exceeded\n");
@@ -324,6 +369,7 @@ void schedule_forward_packet(struct orig_node *orig_node,
 
 	in_tq = batman_packet->tq;
 	in_ttl = batman_packet->ttl;
+	tt_num_changes = batman_packet->tt_num_changes;
 
 	batman_packet->ttl--;
 	memcpy(batman_packet->prev_sender, ethhdr->h_source, ETH_ALEN);
@@ -356,6 +402,7 @@ void schedule_forward_packet(struct orig_node *orig_node,
 		batman_packet->ttl);
 
 	batman_packet->seqno = htonl(batman_packet->seqno);
+	batman_packet->tt_crc = htons(batman_packet->tt_crc);
 
 	/* switch of primaries first hop flag when forwarding */
 	batman_packet->flags &= ~PRIMARIES_FIRST_HOP;
@@ -367,7 +414,7 @@ void schedule_forward_packet(struct orig_node *orig_node,
 	send_time = forward_send_time();
 	add_bat_packet_to_list(bat_priv,
 			       (unsigned char *)batman_packet,
-			       sizeof(*batman_packet) + tt_buff_len,
+			       sizeof(*batman_packet) + tt_len(tt_num_changes),
 			       if_incoming, 0, send_time);
 }
 
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index 6d9c14d..633224a 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -28,7 +28,7 @@ void schedule_own_packet(struct hard_iface *hard_iface);
 void schedule_forward_packet(struct orig_node *orig_node,
 			     const struct ethhdr *ethhdr,
 			     struct batman_packet *batman_packet,
-			     int directlink, int tt_buff_len,
+			     int directlink,
 			     struct hard_iface *if_outgoing);
 int add_bcast_packet_to_list(struct bat_priv *bat_priv,
 			     const struct sk_buff *skb);
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 69c0022..c288d93 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -534,7 +534,7 @@ static int interface_set_mac_addr(struct net_device *dev, void *p)
 	/* only modify transtable if it has been initialised before */
 	if (atomic_read(&bat_priv->mesh_state) == MESH_ACTIVE) {
 		tt_local_remove(bat_priv, dev->dev_addr,
-				 "mac address changed");
+				"mac address changed");
 		tt_local_add(dev, addr->sa_data);
 	}
 
@@ -592,7 +592,7 @@ static int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 	if (curr_softif_neigh)
 		goto dropped;
 
-	/* TODO: check this for locks */
+	/* Register the client MAC in the transtable */
 	tt_local_add(soft_iface, ethhdr->h_source);
 
 	if (is_multicast_ether_addr(ethhdr->h_dest)) {
@@ -830,7 +830,12 @@ struct net_device *softif_create(const char *name)
 
 	atomic_set(&bat_priv->mesh_state, MESH_INACTIVE);
 	atomic_set(&bat_priv->bcast_seqno, 1);
-	atomic_set(&bat_priv->tt_local_changed, 0);
+	atomic_set(&bat_priv->ttvn, 0);
+	atomic_set(&bat_priv->tt_local_changes, 0);
+	atomic_set(&bat_priv->tt_ogm_append_cnt, 0);
+
+	bat_priv->tt_buff = NULL;
+	bat_priv->tt_buff_len = 0;
 
 	bat_priv->primary_if = NULL;
 	bat_priv->num_ifaces = 0;
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 561f769..597cd1a 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -23,13 +23,17 @@
 #include "translation-table.h"
 #include "soft-interface.h"
 #include "hard-interface.h"
+#include "send.h"
 #include "hash.h"
 #include "originator.h"
+#include "routing.h"
 
-static void tt_local_purge(struct work_struct *work);
-static void _tt_global_del_orig(struct bat_priv *bat_priv,
-				 struct tt_global_entry *tt_global_entry,
-				 const char *message);
+#include <linux/crc16.h>
+
+static void _tt_global_del(struct bat_priv *bat_priv,
+			   struct tt_global_entry *tt_global_entry,
+			   const char *message);
+static void tt_purge(struct work_struct *work);
 
 /* returns 1 if they are the same mac addr */
 static int compare_ltt(const struct hlist_node *node, const void *data2)
@@ -49,10 +53,11 @@ static int compare_gtt(const struct hlist_node *node, const void *data2)
 	return (memcmp(data1, data2, ETH_ALEN) == 0 ? 1 : 0);
 }
 
-static void tt_local_start_timer(struct bat_priv *bat_priv)
+static void tt_start_timer(struct bat_priv *bat_priv)
 {
-	INIT_DELAYED_WORK(&bat_priv->tt_work, tt_local_purge);
-	queue_delayed_work(bat_event_workqueue, &bat_priv->tt_work, 10 * HZ);
+	INIT_DELAYED_WORK(&bat_priv->tt_work, tt_purge);
+	queue_delayed_work(bat_event_workqueue, &bat_priv->tt_work,
+			   msecs_to_jiffies(5000));
 }
 
 static struct tt_local_entry *tt_local_hash_find(struct bat_priv *bat_priv,
@@ -112,7 +117,42 @@ static struct tt_global_entry *tt_global_hash_find(struct bat_priv *bat_priv,
 	return tt_global_entry_tmp;
 }
 
-int tt_local_init(struct bat_priv *bat_priv)
+static bool is_out_of_time(unsigned long starting_time, unsigned long timeout)
+{
+	unsigned long deadline;
+	deadline = starting_time + msecs_to_jiffies(timeout);
+
+	return time_after(jiffies, deadline);
+}
+
+static void tt_local_event(struct bat_priv *bat_priv, uint8_t op,
+			   const uint8_t *addr)
+{
+	struct tt_change_node *tt_change_node;
+
+	tt_change_node = kmalloc(sizeof(*tt_change_node), GFP_ATOMIC);
+
+	if (!tt_change_node)
+		return;
+
+	tt_change_node->change.flags = op;
+	memcpy(tt_change_node->change.addr, addr, ETH_ALEN);
+
+	spin_lock_bh(&bat_priv->tt_changes_list_lock);
+	/* track the change in the OGMinterval list */
+	list_add_tail(&tt_change_node->list, &bat_priv->tt_changes_list);
+	atomic_inc(&bat_priv->tt_local_changes);
+	spin_unlock_bh(&bat_priv->tt_changes_list_lock);
+
+	atomic_set(&bat_priv->tt_ogm_append_cnt, 0);
+}
+
+int tt_len(int changes_num)
+{
+	return changes_num * sizeof(struct tt_change);
+}
+
+static int tt_local_init(struct bat_priv *bat_priv)
 {
 	if (bat_priv->tt_local_hash)
 		return 1;
@@ -122,9 +162,6 @@ int tt_local_init(struct bat_priv *bat_priv)
 	if (!bat_priv->tt_local_hash)
 		return 0;
 
-	atomic_set(&bat_priv->tt_local_changed, 0);
-	tt_local_start_timer(bat_priv);
-
 	return 1;
 }
 
@@ -133,40 +170,24 @@ void tt_local_add(struct net_device *soft_iface, const uint8_t *addr)
 	struct bat_priv *bat_priv = netdev_priv(soft_iface);
 	struct tt_local_entry *tt_local_entry;
 	struct tt_global_entry *tt_global_entry;
-	int required_bytes;
 
 	spin_lock_bh(&bat_priv->tt_lhash_lock);
 	tt_local_entry = tt_local_hash_find(bat_priv, addr);
-	spin_unlock_bh(&bat_priv->tt_lhash_lock);
 
 	if (tt_local_entry) {
 		tt_local_entry->last_seen = jiffies;
-		return;
+		goto unlock;
 	}
 
-	/* only announce as many hosts as possible in the batman-packet and
-	   space in batman_packet->num_tt That also should give a limit to
-	   MAC-flooding. */
-	required_bytes = (bat_priv->num_local_tt + 1) * ETH_ALEN;
-	required_bytes += BAT_PACKET_LEN;
-
-	if ((required_bytes > ETH_DATA_LEN) ||
-	    (atomic_read(&bat_priv->aggregated_ogms) &&
-	     required_bytes > MAX_AGGREGATION_BYTES) ||
-	    (bat_priv->num_local_tt + 1 > 255)) {
-		bat_dbg(DBG_ROUTES, bat_priv,
-			"Can't add new local tt entry (%pM): "
-			"number of local tt entries exceeds packet size\n",
-			addr);
-		return;
-	}
-
-	bat_dbg(DBG_ROUTES, bat_priv,
-		"Creating new local tt entry: %pM\n", addr);
-
 	tt_local_entry = kmalloc(sizeof(*tt_local_entry), GFP_ATOMIC);
 	if (!tt_local_entry)
-		return;
+		goto unlock;
+
+	tt_local_event(bat_priv, NO_FLAGS, addr);
+
+	bat_dbg(DBG_TT, bat_priv,
+		"Creating new local tt entry: %pM (ttvn: %d)\n", addr,
+		(uint8_t)atomic_read(&bat_priv->ttvn));
 
 	memcpy(tt_local_entry->addr, addr, ETH_ALEN);
 	tt_local_entry->last_seen = jiffies;
@@ -177,13 +198,9 @@ void tt_local_add(struct net_device *soft_iface, const uint8_t *addr)
 	else
 		tt_local_entry->never_purge = 0;
 
-	spin_lock_bh(&bat_priv->tt_lhash_lock);
-
 	hash_add(bat_priv->tt_local_hash, compare_ltt, choose_orig,
 		 tt_local_entry, &tt_local_entry->hash_entry);
-	bat_priv->num_local_tt++;
-	atomic_set(&bat_priv->tt_local_changed, 1);
-
+	atomic_inc(&bat_priv->num_local_tt);
 	spin_unlock_bh(&bat_priv->tt_lhash_lock);
 
 	/* remove address from global hash if present */
@@ -192,46 +209,60 @@ void tt_local_add(struct net_device *soft_iface, const uint8_t *addr)
 	tt_global_entry = tt_global_hash_find(bat_priv, addr);
 
 	if (tt_global_entry)
-		_tt_global_del_orig(bat_priv, tt_global_entry,
-				     "local tt received");
+		_tt_global_del(bat_priv, tt_global_entry,
+			       "local tt received");
 
 	spin_unlock_bh(&bat_priv->tt_ghash_lock);
+	return;
+unlock:
+	spin_unlock_bh(&bat_priv->tt_lhash_lock);
 }
 
-int tt_local_fill_buffer(struct bat_priv *bat_priv,
-			  unsigned char *buff, int buff_len)
+int tt_changes_fill_buffer(struct bat_priv *bat_priv,
+			   unsigned char *buff, int buff_len)
 {
-	struct hashtable_t *hash = bat_priv->tt_local_hash;
-	struct tt_local_entry *tt_local_entry;
-	struct hlist_node *node;
-	struct hlist_head *head;
-	int i, count = 0;
+	int count = 0, tot_changes = 0;
+	struct tt_change_node *entry, *safe;
 
-	spin_lock_bh(&bat_priv->tt_lhash_lock);
+	if (buff_len > 0)
+		tot_changes = buff_len / tt_len(1);
 
-	for (i = 0; i < hash->size; i++) {
-		head = &hash->table[i];
-
-		rcu_read_lock();
-		hlist_for_each_entry_rcu(tt_local_entry, node,
-					 head, hash_entry) {
-			if (buff_len < (count + 1) * ETH_ALEN)
-				break;
-
-			memcpy(buff + (count * ETH_ALEN), tt_local_entry->addr,
-			       ETH_ALEN);
+	spin_lock_bh(&bat_priv->tt_changes_list_lock);
+	atomic_set(&bat_priv->tt_local_changes, 0);
 
+	list_for_each_entry_safe(entry, safe, &bat_priv->tt_changes_list,
+			list) {
+		if (count < tot_changes) {
+			memcpy(buff + tt_len(count),
+			       &entry->change, sizeof(struct tt_change));
 			count++;
 		}
-		rcu_read_unlock();
+		list_del(&entry->list);
+		kfree(entry);
 	}
+	spin_unlock_bh(&bat_priv->tt_changes_list_lock);
 
-	/* if we did not get all new local tts see you next time  ;-) */
-	if (count == bat_priv->num_local_tt)
-		atomic_set(&bat_priv->tt_local_changed, 0);
+	/* Keep the buffer for possible tt_request */
+	spin_lock_bh(&bat_priv->tt_buff_lock);
+	kfree(bat_priv->tt_buff);
+	bat_priv->tt_buff_len = 0;
+	bat_priv->tt_buff = NULL;
+	/* We check whether this new OGM has no changes due to size
+	 * problems */
+	if (buff_len > 0) {
+		/**
+		 * if kmalloc() fails we will reply with the full table
+		 * instead of providing the diff
+		 */
+		bat_priv->tt_buff = kmalloc(buff_len, GFP_ATOMIC);
+		if (bat_priv->tt_buff) {
+			memcpy(bat_priv->tt_buff, buff, buff_len);
+			bat_priv->tt_buff_len = buff_len;
+		}
+	}
+	spin_unlock_bh(&bat_priv->tt_buff_lock);
 
-	spin_unlock_bh(&bat_priv->tt_lhash_lock);
-	return count;
+	return tot_changes;
 }
 
 int tt_local_seq_print_text(struct seq_file *seq, void *offset)
@@ -263,8 +294,8 @@ int tt_local_seq_print_text(struct seq_file *seq, void *offset)
 	}
 
 	seq_printf(seq, "Locally retrieved addresses (from %s) "
-		   "announced via TT:\n",
-		   net_dev->name);
+		   "announced via TT (TTVN: %u):\n",
+		   net_dev->name, (uint8_t)atomic_read(&bat_priv->ttvn));
 
 	spin_lock_bh(&bat_priv->tt_lhash_lock);
 
@@ -311,54 +342,51 @@ out:
 	return ret;
 }
 
-static void _tt_local_del(struct hlist_node *node, void *arg)
+static void tt_local_entry_free(struct hlist_node *node, void *arg)
 {
 	struct bat_priv *bat_priv = arg;
 	void *data = container_of(node, struct tt_local_entry, hash_entry);
 
 	kfree(data);
-	bat_priv->num_local_tt--;
-	atomic_set(&bat_priv->tt_local_changed, 1);
+	atomic_dec(&bat_priv->num_local_tt);
 }
 
 static void tt_local_del(struct bat_priv *bat_priv,
 			 struct tt_local_entry *tt_local_entry,
 			 const char *message)
 {
-	bat_dbg(DBG_ROUTES, bat_priv, "Deleting local tt entry (%pM): %s\n",
+	bat_dbg(DBG_TT, bat_priv, "Deleting local tt entry (%pM): %s\n",
 		tt_local_entry->addr, message);
 
+	atomic_dec(&bat_priv->num_local_tt);
+
 	hash_remove(bat_priv->tt_local_hash, compare_ltt, choose_orig,
 		    tt_local_entry->addr);
-	_tt_local_del(&tt_local_entry->hash_entry, bat_priv);
+
+	tt_local_entry_free(&tt_local_entry->hash_entry, bat_priv);
 }
 
-void tt_local_remove(struct bat_priv *bat_priv,
-		     const uint8_t *addr, const char *message)
+void tt_local_remove(struct bat_priv *bat_priv, const uint8_t *addr,
+		     const char *message)
 {
 	struct tt_local_entry *tt_local_entry;
 
 	spin_lock_bh(&bat_priv->tt_lhash_lock);
-
 	tt_local_entry = tt_local_hash_find(bat_priv, addr);
 
-	if (tt_local_entry)
+	if (tt_local_entry) {
+		tt_local_event(bat_priv, TT_CHANGE_DEL, tt_local_entry->addr);
 		tt_local_del(bat_priv, tt_local_entry, message);
-
+	}
 	spin_unlock_bh(&bat_priv->tt_lhash_lock);
 }
 
-static void tt_local_purge(struct work_struct *work)
+static void tt_local_purge(struct bat_priv *bat_priv)
 {
-	struct delayed_work *delayed_work =
-		container_of(work, struct delayed_work, work);
-	struct bat_priv *bat_priv =
-		container_of(delayed_work, struct bat_priv, tt_work);
 	struct hashtable_t *hash = bat_priv->tt_local_hash;
 	struct tt_local_entry *tt_local_entry;
 	struct hlist_node *node, *node_tmp;
 	struct hlist_head *head;
-	unsigned long timeout;
 	int i;
 
 	spin_lock_bh(&bat_priv->tt_lhash_lock);
@@ -371,32 +399,53 @@ static void tt_local_purge(struct work_struct *work)
 			if (tt_local_entry->never_purge)
 				continue;
 
-			timeout = tt_local_entry->last_seen;
-			timeout += TT_LOCAL_TIMEOUT * HZ;
-
-			if (time_before(jiffies, timeout))
+			if (!is_out_of_time(tt_local_entry->last_seen,
+					   TT_LOCAL_TIMEOUT * 1000))
 				continue;
 
+			tt_local_event(bat_priv, TT_CHANGE_DEL,
+				       tt_local_entry->addr);
 			tt_local_del(bat_priv, tt_local_entry,
-				      "address timed out");
+				     "address timed out");
 		}
 	}
 
 	spin_unlock_bh(&bat_priv->tt_lhash_lock);
-	tt_local_start_timer(bat_priv);
 }
 
-void tt_local_free(struct bat_priv *bat_priv)
+static void tt_local_table_free(struct bat_priv *bat_priv)
 {
+	struct hashtable_t *hash;
+	int i;
+	spinlock_t *list_lock; /* protects write access to the hash lists */
+	struct hlist_head *head;
+	struct hlist_node *node, *node_tmp;
+	struct tt_local_entry *tt_local_entry;
+
 	if (!bat_priv->tt_local_hash)
 		return;
 
-	cancel_delayed_work_sync(&bat_priv->tt_work);
-	hash_delete(bat_priv->tt_local_hash, _tt_local_del, bat_priv);
+	hash = bat_priv->tt_local_hash;
+
+	for (i = 0; i < hash->size; i++) {
+		head = &hash->table[i];
+		list_lock = &hash->list_locks[i];
+
+		spin_lock_bh(list_lock);
+		hlist_for_each_entry_safe(tt_local_entry, node, node_tmp,
+					  head, hash_entry) {
+			hlist_del_rcu(node);
+			kfree(tt_local_entry);
+		}
+		spin_unlock_bh(list_lock);
+	}
+
+	hash_destroy(hash);
+
 	bat_priv->tt_local_hash = NULL;
 }
 
-int tt_global_init(struct bat_priv *bat_priv)
+static int tt_global_init(struct bat_priv *bat_priv)
 {
 	if (bat_priv->tt_global_hash)
 		return 1;
@@ -409,73 +458,78 @@ int tt_global_init(struct bat_priv *bat_priv)
 	return 1;
 }
 
-void tt_global_add_orig(struct bat_priv *bat_priv,
-			 struct orig_node *orig_node,
-			 const unsigned char *tt_buff, int tt_buff_len)
+static void tt_changes_list_free(struct bat_priv *bat_priv)
+{
+	struct tt_change_node *entry, *safe;
+
+	spin_lock_bh(&bat_priv->tt_changes_list_lock);
+
+	list_for_each_entry_safe(entry, safe, &bat_priv->tt_changes_list,
+				 list) {
+		list_del(&entry->list);
+		kfree(entry);
+	}
+
+	atomic_set(&bat_priv->tt_local_changes, 0);
+	spin_unlock_bh(&bat_priv->tt_changes_list_lock);
+}
+
+/* caller must hold orig_node refcount */
+int tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
+		  const unsigned char *tt_addr, uint8_t ttvn)
 {
 	struct tt_global_entry *tt_global_entry;
 	struct tt_local_entry *tt_local_entry;
-	int tt_buff_count = 0;
-	const unsigned char *tt_ptr;
-
-	while ((tt_buff_count + 1) * ETH_ALEN <= tt_buff_len) {
-		spin_lock_bh(&bat_priv->tt_ghash_lock);
-
-		tt_ptr = tt_buff + (tt_buff_count * ETH_ALEN);
-		tt_global_entry = tt_global_hash_find(bat_priv, tt_ptr);
-
-		if (!tt_global_entry) {
-			spin_unlock_bh(&bat_priv->tt_ghash_lock);
-
-			tt_global_entry = kmalloc(sizeof(*tt_global_entry),
-						  GFP_ATOMIC);
-
-			if (!tt_global_entry)
-				break;
-
-			memcpy(tt_global_entry->addr, tt_ptr, ETH_ALEN);
-
-			bat_dbg(DBG_ROUTES, bat_priv,
-				"Creating new global tt entry: "
-				"%pM (via %pM)\n",
-				tt_global_entry->addr, orig_node->orig);
-
-			spin_lock_bh(&bat_priv->tt_ghash_lock);
-			hash_add(bat_priv->tt_global_hash, compare_gtt,
-				 choose_orig, tt_global_entry,
-				 &tt_global_entry->hash_entry);
-
-		}
-
+	struct orig_node *orig_node_tmp;
+
+	spin_lock_bh(&bat_priv->tt_ghash_lock);
+	tt_global_entry = tt_global_hash_find(bat_priv, tt_addr);
+
+	if (!tt_global_entry) {
+		tt_global_entry =
+			kmalloc(sizeof(*tt_global_entry),
+				GFP_ATOMIC);
+		if (!tt_global_entry)
+			goto unlock;
+		memcpy(tt_global_entry->addr, tt_addr, ETH_ALEN);
+		/* Assign the new orig_node */
+		atomic_inc(&orig_node->refcount);
 		tt_global_entry->orig_node = orig_node;
-		spin_unlock_bh(&bat_priv->tt_ghash_lock);
-
-		/* remove address from local hash if present */
-		spin_lock_bh(&bat_priv->tt_lhash_lock);
-
-		tt_ptr = tt_buff + (tt_buff_count * ETH_ALEN);
-		tt_local_entry = tt_local_hash_find(bat_priv, tt_ptr);
-
-		if (tt_local_entry)
-			tt_local_del(bat_priv, tt_local_entry,
-				      "global tt received");
-
-		spin_unlock_bh(&bat_priv->tt_lhash_lock);
-
-		tt_buff_count++;
-	}
-
-	/* initialize, and overwrite if malloc succeeds */
-	orig_node->tt_buff = NULL;
-	orig_node->tt_buff_len = 0;
-
-	if (tt_buff_len > 0) {
-		orig_node->tt_buff = kmalloc(tt_buff_len, GFP_ATOMIC);
-		if (orig_node->tt_buff) {
-			memcpy(orig_node->tt_buff, tt_buff, tt_buff_len);
-			orig_node->tt_buff_len = tt_buff_len;
+		tt_global_entry->ttvn = ttvn;
+		atomic_inc(&orig_node->tt_size);
+		hash_add(bat_priv->tt_global_hash, compare_gtt,
+			 choose_orig, tt_global_entry,
+			 &tt_global_entry->hash_entry);
+	} else {
+		if (tt_global_entry->orig_node != orig_node) {
+			atomic_dec(&tt_global_entry->orig_node->tt_size);
+			orig_node_tmp = tt_global_entry->orig_node;
+			atomic_inc(&orig_node->refcount);
+			tt_global_entry->orig_node = orig_node;
+			tt_global_entry->ttvn = ttvn;
+			orig_node_free_ref(orig_node_tmp);
+			atomic_inc(&orig_node->tt_size);
 		}
 	}
+
+	spin_unlock_bh(&bat_priv->tt_ghash_lock);
+
+	bat_dbg(DBG_TT, bat_priv,
+		"Creating new global tt entry: %pM (via %pM)\n",
+		tt_global_entry->addr, orig_node->orig);
+
+	/* remove address from local hash if present */
+	spin_lock_bh(&bat_priv->tt_lhash_lock);
+	tt_local_entry = tt_local_hash_find(bat_priv, tt_addr);
+
+	if (tt_local_entry)
+		tt_local_del(bat_priv, tt_local_entry,
+			     "global tt received");
+	spin_unlock_bh(&bat_priv->tt_lhash_lock);
+	return 1;
+unlock:
+	spin_unlock_bh(&bat_priv->tt_ghash_lock);
+	return 0;
 }
 
 int tt_global_seq_print_text(struct seq_file *seq, void *offset)
@@ -509,17 +563,20 @@ int tt_global_seq_print_text(struct seq_file *seq, void *offset)
 	seq_printf(seq,
 		   "Globally announced TT entries received via the mesh %s\n",
 		   net_dev->name);
+	seq_printf(seq, "       %-13s %s       %-15s %s\n",
+		   "Client", "(TTVN)", "Originator", "(Curr TTVN)");
 
 	spin_lock_bh(&bat_priv->tt_ghash_lock);
 
 	buf_size = 1;
-	/* Estimate length for: " * xx:xx:xx:xx:xx:xx via xx:xx:xx:xx:xx:xx\n"*/
+	/* Estimate length for: " * xx:xx:xx:xx:xx:xx (ttvn) via
+	 * xx:xx:xx:xx:xx:xx (cur_ttvn)\n"*/
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
 		rcu_read_lock();
 		__hlist_for_each_rcu(node, head)
-			buf_size += 43;
+			buf_size += 59;
 		rcu_read_unlock();
 	}
 
@@ -538,10 +595,14 @@ int tt_global_seq_print_text(struct seq_file *seq, void *offset)
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(tt_global_entry, node,
 					 head, hash_entry) {
-			pos += snprintf(buff + pos, 44,
-					" * %pM via %pM\n",
+			pos += snprintf(buff + pos, 61,
+					" * %pM  (%3u) via %pM     (%3u)\n",
 					tt_global_entry->addr,
-					tt_global_entry->orig_node->orig);
+					tt_global_entry->ttvn,
+					tt_global_entry->orig_node->orig,
+					(uint8_t) atomic_read(
+						&tt_global_entry->orig_node->
+						last_ttvn));
 		}
 		rcu_read_unlock();
 	}
@@ -556,64 +617,80 @@ out:
 	return ret;
 }
 
-static void _tt_global_del_orig(struct bat_priv *bat_priv,
-				 struct tt_global_entry *tt_global_entry,
-				 const char *message)
+static void _tt_global_del(struct bat_priv *bat_priv,
+			   struct tt_global_entry *tt_global_entry,
+			   const char *message)
 {
-	bat_dbg(DBG_ROUTES, bat_priv,
+	if (!tt_global_entry)
+		return;
+
+	bat_dbg(DBG_TT, bat_priv,
 		"Deleting global tt entry %pM (via %pM): %s\n",
 		tt_global_entry->addr, tt_global_entry->orig_node->orig,
 		message);
 
+	atomic_dec(&tt_global_entry->orig_node->tt_size);
 	hash_remove(bat_priv->tt_global_hash, compare_gtt, choose_orig,
 		    tt_global_entry->addr);
 	kfree(tt_global_entry);
 }
 
+void tt_global_del(struct bat_priv *bat_priv,
+		   struct orig_node *orig_node, const unsigned char *addr,
+		   const char *message)
+{
+	struct tt_global_entry *tt_global_entry;
+
+	spin_lock_bh(&bat_priv->tt_ghash_lock);
+	tt_global_entry = tt_global_hash_find(bat_priv, addr);
+
+	if (tt_global_entry && tt_global_entry->orig_node == orig_node) {
+		atomic_dec(&orig_node->tt_size);
+		_tt_global_del(bat_priv, tt_global_entry, message);
+	}
+	spin_unlock_bh(&bat_priv->tt_ghash_lock);
+}
+
 void tt_global_del_orig(struct bat_priv *bat_priv,
-			 struct orig_node *orig_node, const char *message)
+			struct orig_node *orig_node, const char *message)
 {
 	struct tt_global_entry *tt_global_entry;
-	int tt_buff_count = 0;
-	unsigned char *tt_ptr;
+	int i;
+	struct hashtable_t *hash = bat_priv->tt_global_hash;
+	struct hlist_node *node, *safe;
+	struct hlist_head *head;
 
-	if (orig_node->tt_buff_len == 0)
+	if (!bat_priv->tt_global_hash)
 		return;
 
 	spin_lock_bh(&bat_priv->tt_ghash_lock);
+	for (i = 0; i < hash->size; i++) {
+		head = &hash->table[i];
 
-	while ((tt_buff_count + 1) * ETH_ALEN <= orig_node->tt_buff_len) {
-		tt_ptr = orig_node->tt_buff + (tt_buff_count * ETH_ALEN);
-		tt_global_entry = tt_global_hash_find(bat_priv, tt_ptr);
-
-		if ((tt_global_entry) &&
-		    (tt_global_entry->orig_node == orig_node))
-			_tt_global_del_orig(bat_priv, tt_global_entry,
-					     message);
-
-		tt_buff_count++;
+		hlist_for_each_entry_safe(tt_global_entry, node, safe,
+					 head, hash_entry) {
+			if (tt_global_entry->orig_node == orig_node)
+				_tt_global_del(bat_priv, tt_global_entry,
+					       message);
+		}
 	}
+	atomic_set(&orig_node->tt_size, 0);
 
 	spin_unlock_bh(&bat_priv->tt_ghash_lock);
-
-	orig_node->tt_buff_len = 0;
-	kfree(orig_node->tt_buff);
-	orig_node->tt_buff = NULL;
 }
 
-static void tt_global_del(struct hlist_node *node, void *arg)
+static void tt_global_entry_free(struct hlist_node *node, void *arg)
 {
 	void *data = container_of(node, struct tt_global_entry, hash_entry);
-
 	kfree(data);
 }
 
-void tt_global_free(struct bat_priv *bat_priv)
+static void tt_global_table_free(struct bat_priv *bat_priv)
 {
 	if (!bat_priv->tt_global_hash)
 		return;
 
-	hash_delete(bat_priv->tt_global_hash, tt_global_del, NULL);
+	hash_delete(bat_priv->tt_global_hash, tt_global_entry_free, NULL);
 	bat_priv->tt_global_hash = NULL;
 }
 
@@ -638,3 +715,686 @@ out:
 	spin_unlock_bh(&bat_priv->tt_ghash_lock);
 	return orig_node;
 }
+
+/* Calculates the checksum of the local table of a given orig_node */
+uint16_t tt_global_crc(struct bat_priv *bat_priv, struct orig_node *orig_node)
+{
+	uint16_t total = 0, total_one;
+	struct hashtable_t *hash = bat_priv->tt_global_hash;
+	struct tt_global_entry *tt_global_entry;
+	struct hlist_node *node;
+	struct hlist_head *head;
+	int i, j;
+
+	for (i = 0; i < hash->size; i++) {
+		head = &hash->table[i];
+
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(tt_global_entry, node,
+					 head, hash_entry) {
+			if (compare_eth(tt_global_entry->orig_node,
+					orig_node)) {
+				total_one = 0;
+				for (j = 0; j < ETH_ALEN; j++)
+					total_one = crc16_byte(total_one,
+						tt_global_entry->addr[j]);
+				total ^= total_one;
+			}
+		}
+		rcu_read_unlock();
+	}
+
+	return total;
+}
+
+/* Calculates the checksum of the local table */
+uint16_t tt_local_crc(struct bat_priv *bat_priv)
+{
+	uint16_t total = 0, total_one;
+	struct hashtable_t *hash = bat_priv->tt_local_hash;
+	struct tt_local_entry *tt_local_entry;
+	struct hlist_node *node;
+	struct hlist_head *head;
+	int i, j;
+
+	for (i = 0; i < hash->size; i++) {
+		head = &hash->table[i];
+
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(tt_local_entry, node,
+					 head, hash_entry) {
+			total_one = 0;
+			for (j = 0; j < ETH_ALEN; j++)
+				total_one = crc16_byte(total_one,
+						   tt_local_entry->addr[j]);
+			total ^= total_one;
+		}
+
+		rcu_read_unlock();
+	}
+
+	return total;
+}
+
+static void tt_req_list_free(struct bat_priv *bat_priv)
+{
+	struct tt_req_node *node, *safe;
+
+	spin_lock_bh(&bat_priv->tt_req_list_lock);
+
+	list_for_each_entry_safe(node, safe, &bat_priv->tt_req_list, list) {
+		list_del(&node->list);
+		kfree(node);
+	}
+
+	spin_unlock_bh(&bat_priv->tt_req_list_lock);
+}
+
+void tt_save_orig_buffer(struct bat_priv *bat_priv, struct orig_node *orig_node,
+			 const unsigned char *tt_buff, uint8_t tt_num_changes)
+{
+	uint16_t tt_buff_len = tt_len(tt_num_changes);
+
+	/* Replace the old buffer only if I received something in the
+	 * last OGM (the OGM could carry no changes) */
+	spin_lock_bh(&orig_node->tt_buff_lock);
+	if (tt_buff_len > 0) {
+		kfree(orig_node->tt_buff);
+		orig_node->tt_buff_len = 0;
+		orig_node->tt_buff = kmalloc(tt_buff_len, GFP_ATOMIC);
+		if (orig_node->tt_buff) {
+			memcpy(orig_node->tt_buff, tt_buff, tt_buff_len);
+			orig_node->tt_buff_len = tt_buff_len;
+		}
+	}
+	spin_unlock_bh(&orig_node->tt_buff_lock);
+}
+
+static void tt_req_purge(struct bat_priv *bat_priv)
+{
+	struct tt_req_node *node, *safe;
+
+	spin_lock_bh(&bat_priv->tt_req_list_lock);
+	list_for_each_entry_safe(node, safe, &bat_priv->tt_req_list, list) {
+		if (is_out_of_time(node->issued_at,
+		    TT_REQUEST_TIMEOUT * 1000)) {
+			list_del(&node->list);
+			kfree(node);
+		}
+	}
+	spin_unlock_bh(&bat_priv->tt_req_list_lock);
+}
+
+/* returns the pointer to the new tt_req_node struct if no request
+ * has already been issued for this orig_node, NULL otherwise */
+static struct tt_req_node *new_tt_req_node(struct bat_priv *bat_priv,
+					  struct orig_node *orig_node)
+{
+	struct tt_req_node *tt_req_node_tmp, *tt_req_node = NULL;
+
+	spin_lock_bh(&bat_priv->tt_req_list_lock);
+	list_for_each_entry(tt_req_node_tmp, &bat_priv->tt_req_list, list) {
+		if (compare_eth(tt_req_node_tmp, orig_node) &&
+		    !is_out_of_time(tt_req_node_tmp->issued_at,
+				    TT_REQUEST_TIMEOUT * 1000))
+			goto unlock;
+	}
+
+	tt_req_node = kmalloc(sizeof(*tt_req_node), GFP_ATOMIC);
+	if (!tt_req_node)
+		goto unlock;
+
+	memcpy(tt_req_node->addr, orig_node->orig, ETH_ALEN);
+	tt_req_node->issued_at = jiffies;
+
+	list_add(&tt_req_node->list, &bat_priv->tt_req_list);
+unlock:
+	spin_unlock_bh(&bat_priv->tt_req_list_lock);
+	return tt_req_node;
+}
+
+static int tt_global_valid_entry(const void *entry_ptr, const void *data_ptr)
+{
+	const struct tt_global_entry *tt_global_entry = entry_ptr;
+	const struct orig_node *orig_node = data_ptr;
+
+	return (tt_global_entry->orig_node == orig_node);
+}
+
+static struct sk_buff *tt_response_fill_table(uint16_t tt_len, uint8_t ttvn,
+					      struct hashtable_t *hash,
+					      struct hard_iface *primary_if,
+					      int (*valid_cb)(const void *,
+							      const void *),
+					      void *cb_data)
+{
+	struct tt_local_entry *tt_local_entry;
+	struct tt_query_packet *tt_response;
+	struct tt_change *tt_change;
+	struct hlist_node *node;
+	struct hlist_head *head;
+	struct sk_buff *skb = NULL;
+	uint16_t tt_tot, tt_count;
+	ssize_t tt_query_size = sizeof(struct tt_query_packet);
+	int i;
+
+	if (tt_query_size + tt_len > primary_if->soft_iface->mtu) {
+		tt_len = primary_if->soft_iface->mtu - tt_query_size;
+		tt_len -= tt_len % sizeof(struct tt_change);
+	}
+	tt_tot = tt_len / sizeof(struct tt_change);
+
+	skb = dev_alloc_skb(tt_query_size + tt_len + ETH_HLEN);
+	if (!skb)
+		goto out;
+
+	skb_reserve(skb, ETH_HLEN);
+	tt_response = (struct tt_query_packet *)skb_put(skb,
+						     tt_query_size + tt_len);
+	tt_response->ttvn = ttvn;
+	tt_response->tt_data = htons(tt_tot);
+
+	tt_change = (struct tt_change *)(skb->data + tt_query_size);
+	tt_count = 0;
+
+	rcu_read_lock();
+	for (i = 0; i < hash->size; i++) {
+		head = &hash->table[i];
+
+		hlist_for_each_entry_rcu(tt_local_entry, node,
+					 head, hash_entry) {
+			if (tt_count == tt_tot)
+				break;
+
+			if ((valid_cb) && (!valid_cb(tt_local_entry, cb_data)))
+				continue;
+
+			memcpy(tt_change->addr, tt_local_entry->addr, ETH_ALEN);
+			tt_change->flags = NO_FLAGS;
+
+			tt_count++;
+			tt_change++;
+		}
+	}
+	rcu_read_unlock();
+
+out:
+	return skb;
+}
+
+int send_tt_request(struct bat_priv *bat_priv, struct orig_node *dst_orig_node,
+		    uint8_t ttvn, uint16_t tt_crc, bool full_table)
+{
+	struct sk_buff *skb = NULL;
+	struct tt_query_packet *tt_request;
+	struct neigh_node *neigh_node = NULL;
+	struct hard_iface *primary_if;
+	struct tt_req_node *tt_req_node = NULL;
+	int ret = 1;
+
+	primary_if = primary_if_get_selected(bat_priv);
+	if (!primary_if)
+		goto out;
+
+	/* The new tt_req will be issued only if I'm not waiting for a
+	 * reply from the same orig_node yet */
+	tt_req_node = new_tt_req_node(bat_priv, dst_orig_node);
+	if (!tt_req_node)
+		goto out;
+
+	skb = dev_alloc_skb(sizeof(struct tt_query_packet) + ETH_HLEN);
+	if (!skb)
+		goto out;
+
+	skb_reserve(skb, ETH_HLEN);
+
+	tt_request = (struct tt_query_packet *)skb_put(skb,
+				sizeof(struct tt_query_packet));
+
+	tt_request->packet_type = BAT_TT_QUERY;
+	tt_request->version = COMPAT_VERSION;
+	memcpy(tt_request->src, primary_if->net_dev->dev_addr, ETH_ALEN);
+	memcpy(tt_request->dst, dst_orig_node->orig, ETH_ALEN);
+	tt_request->ttl = TTL;
+	tt_request->ttvn = ttvn;
+	tt_request->tt_data = tt_crc;
+	tt_request->flags = TT_REQUEST;
+
+	if (full_table)
+		tt_request->flags |= TT_FULL_TABLE;
+
+	neigh_node = orig_node_get_router(dst_orig_node);
+	if (!neigh_node)
+		goto out;
+
+	bat_dbg(DBG_TT, bat_priv, "Sending TT_REQUEST to %pM via %pM "
+		"[%c]\n", dst_orig_node->orig, neigh_node->addr,
+		(full_table ? 'F' : '.'));
+
+	send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
+	ret = 0;
+
+out:
+	if (neigh_node)
+		neigh_node_free_ref(neigh_node);
+	if (primary_if)
+		hardif_free_ref(primary_if);
+	if (ret)
+		kfree_skb(skb);
+	if (ret && tt_req_node) {
+		spin_lock_bh(&bat_priv->tt_req_list_lock);
+		list_del(&tt_req_node->list);
+		spin_unlock_bh(&bat_priv->tt_req_list_lock);
+		kfree(tt_req_node);
+	}
+	return ret;
+}
+
+static bool send_other_tt_response(struct bat_priv *bat_priv,
+				   struct tt_query_packet *tt_request)
+{
+	struct orig_node *req_dst_orig_node = NULL, *res_dst_orig_node = NULL;
+	struct neigh_node *neigh_node = NULL;
+	struct hard_iface *primary_if = NULL;
+	uint8_t orig_ttvn, req_ttvn, ttvn;
+	int ret = false;
+	unsigned char *tt_buff;
+	bool full_table;
+	uint16_t tt_len, tt_tot;
+	struct sk_buff *skb = NULL;
+	struct tt_query_packet *tt_response;
+
+	bat_dbg(DBG_TT, bat_priv,
+		"Received TT_REQUEST from %pM for "
+		"ttvn: %u (%pM) [%c]\n", tt_request->src,
+		tt_request->ttvn, tt_request->dst,
+		(tt_request->flags & TT_FULL_TABLE ? 'F' : '.'));
+
+	/* Let's get the orig node of the REAL destination */
+	req_dst_orig_node = get_orig_node(bat_priv, tt_request->dst);
+	if (!req_dst_orig_node)
+		goto out;
+
+	res_dst_orig_node = get_orig_node(bat_priv, tt_request->src);
+	if (!res_dst_orig_node)
+		goto out;
+
+	neigh_node = orig_node_get_router(res_dst_orig_node);
+	if (!neigh_node)
+		goto out;
+
+	primary_if = primary_if_get_selected(bat_priv);
+	if (!primary_if)
+		goto out;
+
+	orig_ttvn = (uint8_t)atomic_read(&req_dst_orig_node->last_ttvn);
+	req_ttvn = tt_request->ttvn;
+
+	/* I have not the requested data */
+	if (orig_ttvn != req_ttvn ||
+	    tt_request->tt_data != req_dst_orig_node->tt_crc)
+		goto out;
+
+	/* If it has explicitly been requested the full table */
+	if (tt_request->flags & TT_FULL_TABLE ||
+	    !req_dst_orig_node->tt_buff)
+		full_table = true;
+	else
+		full_table = false;
+
+	/* In this version, fragmentation is not implemented, then
+	 * I'll send only one packet with as much TT entries as I can */
+	if (!full_table) {
+		spin_lock_bh(&req_dst_orig_node->tt_buff_lock);
+		tt_len = req_dst_orig_node->tt_buff_len;
+		tt_tot = tt_len / sizeof(struct tt_change);
+
+		skb = dev_alloc_skb(sizeof(struct tt_query_packet) +
+				    tt_len + ETH_HLEN);
+		if (!skb)
+			goto unlock;
+
+		skb_reserve(skb, ETH_HLEN);
+		tt_response = (struct tt_query_packet *)skb_put(skb,
+				sizeof(struct tt_query_packet) + tt_len);
+		tt_response->ttvn = req_ttvn;
+		tt_response->tt_data = htons(tt_tot);
+
+		tt_buff = skb->data + sizeof(struct tt_query_packet);
+		/* Copy the last orig_node's OGM buffer */
+		memcpy(tt_buff, req_dst_orig_node->tt_buff,
+		       req_dst_orig_node->tt_buff_len);
+
+		spin_unlock_bh(&req_dst_orig_node->tt_buff_lock);
+	} else {
+		tt_len = (uint16_t)atomic_read(&req_dst_orig_node->tt_size) *
+						sizeof(struct tt_change);
+		ttvn = (uint8_t)atomic_read(&req_dst_orig_node->last_ttvn);
+
+		skb = tt_response_fill_table(tt_len, ttvn,
+					     bat_priv->tt_global_hash,
+					     primary_if, tt_global_valid_entry,
+					     req_dst_orig_node);
+		if (!skb)
+			goto out;
+
+		tt_response = (struct tt_query_packet *)skb->data;
+	}
+
+	tt_response->packet_type = BAT_TT_QUERY;
+	tt_response->version = COMPAT_VERSION;
+	tt_response->ttl = TTL;
+	memcpy(tt_response->src, req_dst_orig_node->orig, ETH_ALEN);
+	memcpy(tt_response->dst, tt_request->src, ETH_ALEN);
+	tt_response->flags = TT_RESPONSE;
+
+	if (full_table)
+		tt_response->flags |= TT_FULL_TABLE;
+
+	bat_dbg(DBG_TT, bat_priv,
+		"Sending TT_RESPONSE %pM via %pM for %pM (ttvn: %u)\n",
+		res_dst_orig_node->orig, neigh_node->addr,
+		req_dst_orig_node->orig, req_ttvn);
+
+	send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
+	ret = true;
+	goto out;
+
+unlock:
+	spin_unlock_bh(&req_dst_orig_node->tt_buff_lock);
+
+out:
+	if (res_dst_orig_node)
+		orig_node_free_ref(res_dst_orig_node);
+	if (req_dst_orig_node)
+		orig_node_free_ref(req_dst_orig_node);
+	if (neigh_node)
+		neigh_node_free_ref(neigh_node);
+	if (primary_if)
+		hardif_free_ref(primary_if);
+	if (!ret)
+		kfree_skb(skb);
+	return ret;
+
+}
+static bool send_my_tt_response(struct bat_priv *bat_priv,
+				struct tt_query_packet *tt_request)
+{
+	struct orig_node *orig_node = NULL;
+	struct neigh_node *neigh_node = NULL;
+	struct hard_iface *primary_if = NULL;
+	uint8_t my_ttvn, req_ttvn, ttvn;
+	int ret = false;
+	unsigned char *tt_buff;
+	bool full_table;
+	uint16_t tt_len, tt_tot;
+	struct sk_buff *skb = NULL;
+	struct tt_query_packet *tt_response;
+
+	bat_dbg(DBG_TT, bat_priv,
+		"Received TT_REQUEST from %pM for "
+		"ttvn: %u (me) [%c]\n", tt_request->src,
+		tt_request->ttvn,
+		(tt_request->flags & TT_FULL_TABLE ? 'F' : '.'));
+
+
+	my_ttvn = (uint8_t)atomic_read(&bat_priv->ttvn);
+	req_ttvn = tt_request->ttvn;
+
+	orig_node = get_orig_node(bat_priv, tt_request->src);
+	if (!orig_node)
+		goto out;
+
+	neigh_node = orig_node_get_router(orig_node);
+	if (!neigh_node)
+		goto out;
+
+	primary_if = primary_if_get_selected(bat_priv);
+	if (!primary_if)
+		goto out;
+
+	/* If the full table has been explicitly requested or the gap
+	 * is too big send the whole local translation table */
+	if (tt_request->flags & TT_FULL_TABLE || my_ttvn != req_ttvn ||
+	    !bat_priv->tt_buff)
+		full_table = true;
+	else
+		full_table = false;
+
+	/* In this version, fragmentation is not implemented, then
+	 * I'll send only one packet with as much TT entries as I can */
+	if (!full_table) {
+		spin_lock_bh(&bat_priv->tt_buff_lock);
+		tt_len = bat_priv->tt_buff_len;
+		tt_tot = tt_len / sizeof(struct tt_change);
+
+		skb = dev_alloc_skb(sizeof(struct tt_query_packet) +
+				    tt_len + ETH_HLEN);
+		if (!skb)
+			goto unlock;
+
+		skb_reserve(skb, ETH_HLEN);
+		tt_response = (struct tt_query_packet *)skb_put(skb,
+				sizeof(struct tt_query_packet) + tt_len);
+		tt_response->ttvn = req_ttvn;
+		tt_response->tt_data = htons(tt_tot);
+
+		tt_buff = skb->data + sizeof(struct tt_query_packet);
+		memcpy(tt_buff, bat_priv->tt_buff,
+		       bat_priv->tt_buff_len);
+		spin_unlock_bh(&bat_priv->tt_buff_lock);
+	} else {
+		tt_len = (uint16_t)atomic_read(&bat_priv->num_local_tt) *
+						sizeof(struct tt_change);
+		ttvn = (uint8_t)atomic_read(&bat_priv->ttvn);
+
+		skb = tt_response_fill_table(tt_len, ttvn,
+					     bat_priv->tt_local_hash,
+					     primary_if, NULL, NULL);
+		if (!skb)
+			goto out;
+
+		tt_response = (struct tt_query_packet *)skb->data;
+	}
+
+	tt_response->packet_type = BAT_TT_QUERY;
+	tt_response->version = COMPAT_VERSION;
+	tt_response->ttl = TTL;
+	memcpy(tt_response->src, primary_if->net_dev->dev_addr, ETH_ALEN);
+	memcpy(tt_response->dst, tt_request->src, ETH_ALEN);
+	tt_response->flags = TT_RESPONSE;
+
+	if (full_table)
+		tt_response->flags |= TT_FULL_TABLE;
+
+	bat_dbg(DBG_TT, bat_priv,
+		"Sending TT_RESPONSE to %pM via %pM [%c]\n",
+		orig_node->orig, neigh_node->addr,
+		(tt_response->flags & TT_FULL_TABLE ? 'F' : '.'));
+
+	send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
+	ret = true;
+	goto out;
+
+unlock:
+	spin_unlock_bh(&bat_priv->tt_buff_lock);
+out:
+	if (orig_node)
+		orig_node_free_ref(orig_node);
+	if (neigh_node)
+		neigh_node_free_ref(neigh_node);
+	if (primary_if)
+		hardif_free_ref(primary_if);
+	if (!ret)
+		kfree_skb(skb);
+	/* This packet was for me, so it doesn't need to be re-routed */
+	return true;
+}
+
+bool send_tt_response(struct bat_priv *bat_priv,
+		      struct tt_query_packet *tt_request)
+{
+	if (is_my_mac(tt_request->dst))
+		return send_my_tt_response(bat_priv, tt_request);
+	else
+		return send_other_tt_response(bat_priv, tt_request);
+}
+
+static void _tt_update_changes(struct bat_priv *bat_priv,
+			       struct orig_node *orig_node,
+			       struct tt_change *tt_change,
+			       uint16_t tt_num_changes, uint8_t ttvn)
+{
+	int i;
+
+	for (i = 0; i < tt_num_changes; i++) {
+		if ((tt_change + i)->flags & TT_CHANGE_DEL)
+			tt_global_del(bat_priv, orig_node,
+				      (tt_change + i)->addr,
+				      "tt removed by changes");
+		else
+			if (!tt_global_add(bat_priv, orig_node,
+					   (tt_change + i)->addr, ttvn))
+				/* In case of problem while storing a
+				 * global_entry, we stop the updating
+				 * procedure without committing the
+				 * ttvn change. This will avoid to send
+				 * corrupted data on tt_request
+				 */
+				return;
+	}
+}
+
+static void tt_fill_gtable(struct bat_priv *bat_priv,
+			   struct tt_query_packet *tt_response)
+{
+	struct orig_node *orig_node = NULL;
+
+	orig_node = orig_hash_find(bat_priv, tt_response->src);
+	if (!orig_node)
+		goto out;
+
+	/* Purge the old table first.. */
+	tt_global_del_orig(bat_priv, orig_node, "Received full table");
+
+	_tt_update_changes(bat_priv, orig_node,
+			   (struct tt_change *)(tt_response + 1),
+			   tt_response->tt_data, tt_response->ttvn);
+
+	spin_lock_bh(&orig_node->tt_buff_lock);
+	kfree(orig_node->tt_buff);
+	orig_node->tt_buff_len = 0;
+	orig_node->tt_buff = NULL;
+	spin_unlock_bh(&orig_node->tt_buff_lock);
+
+	atomic_set(&orig_node->last_ttvn, tt_response->ttvn);
+
+out:
+	if (orig_node)
+		orig_node_free_ref(orig_node);
+}
+
+void tt_update_changes(struct bat_priv *bat_priv, struct orig_node *orig_node,
+		       uint16_t tt_num_changes, uint8_t ttvn,
+		       struct tt_change *tt_change)
+{
+	_tt_update_changes(bat_priv, orig_node, tt_change, tt_num_changes,
+			   ttvn);
+
+	tt_save_orig_buffer(bat_priv, orig_node, (unsigned char *)tt_change,
+			    tt_num_changes);
+	atomic_set(&orig_node->last_ttvn, ttvn);
+}
+
+bool is_my_client(struct bat_priv *bat_priv, const uint8_t *addr)
+{
+	struct tt_local_entry *tt_local_entry;
+
+	spin_lock_bh(&bat_priv->tt_lhash_lock);
+	tt_local_entry = tt_local_hash_find(bat_priv, addr);
+	spin_unlock_bh(&bat_priv->tt_lhash_lock);
+
+	if (tt_local_entry)
+		return true;
+	return false;
+}
+
+void handle_tt_response(struct bat_priv *bat_priv,
+			struct tt_query_packet *tt_response)
+{
+	struct tt_req_node *node, *safe;
+	struct orig_node *orig_node = NULL;
+
+	bat_dbg(DBG_TT, bat_priv, "Received TT_RESPONSE from %pM for "
+		"ttvn %d t_size: %d [%c]\n",
+		tt_response->src, tt_response->ttvn,
+		tt_response->tt_data,
+		(tt_response->flags & TT_FULL_TABLE ? 'F' : '.'));
+
+	orig_node = orig_hash_find(bat_priv, tt_response->src);
+	if (!orig_node)
+		goto out;
+
+	if (tt_response->flags & TT_FULL_TABLE)
+		tt_fill_gtable(bat_priv, tt_response);
+	else
+		tt_update_changes(bat_priv, orig_node, tt_response->tt_data,
+				  tt_response->ttvn,
+				  (struct tt_change *)(tt_response + 1));
+
+	/* Delete the tt_req_node from pending tt_requests list */
+	spin_lock_bh(&bat_priv->tt_req_list_lock);
+	list_for_each_entry_safe(node, safe, &bat_priv->tt_req_list, list) {
+		if (!compare_eth(node->addr, tt_response->src))
+			continue;
+		list_del(&node->list);
+		kfree(node);
+	}
+	spin_unlock_bh(&bat_priv->tt_req_list_lock);
+
+	/* Recalculate the CRC for this orig_node and store it */
+	spin_lock_bh(&bat_priv->tt_ghash_lock);
+	orig_node->tt_crc = tt_global_crc(bat_priv, orig_node);
+	spin_unlock_bh(&bat_priv->tt_ghash_lock);
+out:
+	if (orig_node)
+		orig_node_free_ref(orig_node);
+}
+
+int tt_init(struct bat_priv *bat_priv)
+{
+	if (!tt_local_init(bat_priv))
+		return 0;
+
+	if (!tt_global_init(bat_priv))
+		return 0;
+
+	tt_start_timer(bat_priv);
+
+	return 1;
+}
+
+void tt_free(struct bat_priv *bat_priv)
+{
+	cancel_delayed_work_sync(&bat_priv->tt_work);
+
+	tt_local_table_free(bat_priv);
+	tt_global_table_free(bat_priv);
+	tt_req_list_free(bat_priv);
+	tt_changes_list_free(bat_priv);
+
+	kfree(bat_priv->tt_buff);
+}
+
+static void tt_purge(struct work_struct *work)
+{
+	struct delayed_work *delayed_work =
+		container_of(work, struct delayed_work, work);
+	struct bat_priv *bat_priv =
+		container_of(delayed_work, struct bat_priv, tt_work);
+
+	tt_local_purge(bat_priv);
+	tt_req_purge(bat_priv);
+
+	tt_start_timer(bat_priv);
+}
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index 0f2b990..51f7e30 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -22,23 +22,43 @@
 #ifndef _NET_BATMAN_ADV_TRANSLATION_TABLE_H_
 #define _NET_BATMAN_ADV_TRANSLATION_TABLE_H_
 
-int tt_local_init(struct bat_priv *bat_priv);
+int tt_len(int changes_num);
+int tt_changes_fill_buffer(struct bat_priv *bat_priv,
+			   unsigned char *buff, int buff_len);
+int tt_init(struct bat_priv *bat_priv);
 void tt_local_add(struct net_device *soft_iface, const uint8_t *addr);
 void tt_local_remove(struct bat_priv *bat_priv,
 		     const uint8_t *addr, const char *message);
-int tt_local_fill_buffer(struct bat_priv *bat_priv,
-			  unsigned char *buff, int buff_len);
 int tt_local_seq_print_text(struct seq_file *seq, void *offset);
-void tt_local_free(struct bat_priv *bat_priv);
-int tt_global_init(struct bat_priv *bat_priv);
 void tt_global_add_orig(struct bat_priv *bat_priv,
 			struct orig_node *orig_node,
 			const unsigned char *tt_buff, int tt_buff_len);
+int tt_global_add(struct bat_priv *bat_priv,
+		  struct orig_node *orig_node, const unsigned char *addr,
+		  uint8_t ttvn);
 int tt_global_seq_print_text(struct seq_file *seq, void *offset);
 void tt_global_del_orig(struct bat_priv *bat_priv,
-			 struct orig_node *orig_node, const char *message);
-void tt_global_free(struct bat_priv *bat_priv);
+			struct orig_node *orig_node, const char *message);
+void tt_global_del(struct bat_priv *bat_priv,
+		   struct orig_node *orig_node, const unsigned char *addr,
+		   const char *message);
 struct orig_node *transtable_search(struct bat_priv *bat_priv,
 				    const uint8_t *addr);
+void tt_save_orig_buffer(struct bat_priv *bat_priv, struct orig_node *orig_node,
+			 const unsigned char *tt_buff, uint8_t tt_num_changes);
+uint16_t tt_local_crc(struct bat_priv *bat_priv);
+uint16_t tt_global_crc(struct bat_priv *bat_priv, struct orig_node *orig_node);
+void tt_free(struct bat_priv *bat_priv);
+int send_tt_request(struct bat_priv *bat_priv,
+		    struct orig_node *dst_orig_node, uint8_t hvn,
+		    uint16_t tt_crc, bool full_table);
+bool send_tt_response(struct bat_priv *bat_priv,
+		      struct tt_query_packet *tt_request);
+void tt_update_changes(struct bat_priv *bat_priv, struct orig_node *orig_node,
+		       uint16_t tt_num_changes, uint8_t ttvn,
+		       struct tt_change *tt_change);
+bool is_my_client(struct bat_priv *bat_priv, const uint8_t *addr);
+void handle_tt_response(struct bat_priv *bat_priv,
+			struct tt_query_packet *tt_response);
 
 #endif /* _NET_BATMAN_ADV_TRANSLATION_TABLE_H_ */
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 65b3222..3b642a9 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -75,8 +75,12 @@ struct orig_node {
 	unsigned long batman_seqno_reset;
 	uint8_t gw_flags;
 	uint8_t flags;
+	atomic_t last_ttvn; /* last seen translation table version number */
+	uint16_t tt_crc;
 	unsigned char *tt_buff;
 	int16_t tt_buff_len;
+	spinlock_t tt_buff_lock; /* protects tt_buff */
+	atomic_t tt_size;
 	uint32_t last_real_seqno;
 	uint8_t last_ttl;
 	unsigned long bcast_bits[NUM_WORDS];
@@ -94,6 +98,7 @@ struct orig_node {
 	spinlock_t ogm_cnt_lock;
 	/* bcast_seqno_lock protects bcast_bits, last_bcast_seqno */
 	spinlock_t bcast_seqno_lock;
+	spinlock_t tt_list_lock; /* protects tt_list */
 	atomic_t bond_candidates;
 	struct list_head bond_list;
 };
@@ -145,6 +150,9 @@ struct bat_priv {
 	atomic_t bcast_seqno;
 	atomic_t bcast_queue_left;
 	atomic_t batman_queue_left;
+	atomic_t ttvn; /* tranlation table version number */
+	atomic_t tt_ogm_append_cnt;
+	atomic_t tt_local_changes; /* changes registered in a OGM interval */
 	char num_ifaces;
 	struct debug_log *debug_log;
 	struct kobject *mesh_obj;
@@ -153,22 +161,30 @@ struct bat_priv {
 	struct hlist_head forw_bcast_list;
 	struct hlist_head gw_list;
 	struct hlist_head softif_neigh_vids;
+	struct list_head tt_changes_list; /* tracks changes in a OGM int */
 	struct list_head vis_send_list;
 	struct hashtable_t *orig_hash;
 	struct hashtable_t *tt_local_hash;
 	struct hashtable_t *tt_global_hash;
+	struct list_head tt_req_list; /* list of pending tt_requests */
 	struct hashtable_t *vis_hash;
 	spinlock_t forw_bat_list_lock; /* protects forw_bat_list */
 	spinlock_t forw_bcast_list_lock; /* protects  */
+	spinlock_t tt_changes_list_lock; /* protects tt_changes */
 	spinlock_t tt_lhash_lock; /* protects tt_local_hash */
 	spinlock_t tt_ghash_lock; /* protects tt_global_hash */
+	spinlock_t tt_req_list_lock; /* protects tt_req_list */
 	spinlock_t gw_list_lock; /* protects gw_list and curr_gw */
 	spinlock_t vis_hash_lock; /* protects vis_hash */
 	spinlock_t vis_list_lock; /* protects vis_info::recv_list */
 	spinlock_t softif_neigh_lock; /* protects soft-interface neigh list */
 	spinlock_t softif_neigh_vid_lock; /* protects soft-interface vid list */
-	int16_t num_local_tt;
-	atomic_t tt_local_changed;
+	atomic_t num_local_tt;
+	/* Checksum of the local table, recomputed before sending a new OGM */
+	atomic_t tt_crc;
+	unsigned char *tt_buff;
+	int16_t tt_buff_len;
+	spinlock_t tt_buff_lock; /* protects tt_buff */
 	struct delayed_work tt_work;
 	struct delayed_work orig_work;
 	struct delayed_work vis_work;
@@ -202,9 +218,22 @@ struct tt_local_entry {
 struct tt_global_entry {
 	uint8_t addr[ETH_ALEN];
 	struct orig_node *orig_node;
+	uint8_t ttvn;
+	/* entry in the global table */
 	struct hlist_node hash_entry;
 };
 
+struct tt_change_node {
+	struct list_head list;
+	struct tt_change change;
+};
+
+struct tt_req_node {
+	uint8_t addr[ETH_ALEN];
+	unsigned long issued_at;
+	struct list_head list;
+};
+
 /**
  *	forw_packet - structure for forw_list maintaining packets to be
  *	              send/forwarded
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 6eabf42..32b125f 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -325,6 +325,9 @@ find_router:
 	unicast_packet->ttl = TTL;
 	/* copy the destination for faster routing */
 	memcpy(unicast_packet->dest, orig_node->orig, ETH_ALEN);
+	/* set the destination tt version number */
+	unicast_packet->ttvn =
+		(uint8_t)atomic_read(&orig_node->last_ttvn);
 
 	if (atomic_read(&bat_priv->fragmentation) &&
 	    data_len + sizeof(*unicast_packet) >
-- 
1.7.5.3

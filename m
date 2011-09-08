From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: [PATCH 1/7] batman-adv: rename all instances of
	batman_packet to batman_ogm_packet
Date: Thu,  8 Sep 2011 18:40:45 +0200
Message-ID: <1315500051-1122-2-git-send-email-lindner_marek@yahoo.de>
References: <1315500051-1122-1-git-send-email-lindner_marek@yahoo.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1315500051-1122-1-git-send-email-lindner_marek-LWAfsSFWpa4@public.gmane.org>
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

The follow-up routing code changes are going to introduce additional
routing packet types which make this distinction necessary.

Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
---
 net/batman-adv/aggregation.c    |   48 ++++++++-------
 net/batman-adv/aggregation.h    |    2 +-
 net/batman-adv/hard-interface.c |   49 ++++++++-------
 net/batman-adv/packet.h         |   18 +++---
 net/batman-adv/routing.c        |  118 +++++++++++++++++++----------------
 net/batman-adv/routing.h        |    2 +-
 net/batman-adv/send.c           |  130 ++++++++++++++++++++-------------------
 net/batman-adv/send.h           |    2 +-
 net/batman-adv/soft-interface.c |   17 +++---
 9 files changed, 204 insertions(+), 182 deletions(-)

diff --git a/net/batman-adv/aggregation.c b/net/batman-adv/aggregation.c
index 69467fe..f20423f 100644
--- a/net/batman-adv/aggregation.c
+++ b/net/batman-adv/aggregation.c
@@ -27,7 +27,8 @@
 #include "hard-interface.h"
 
 /* return true if new_packet can be aggregated with forw_packet */
-static bool can_aggregate_with(const struct batman_packet *new_batman_packet,
+static bool can_aggregate_with(const struct batman_ogm_packet
+							*new_batman_ogm_packet,
 			       struct bat_priv *bat_priv,
 			       int packet_len,
 			       unsigned long send_time,
@@ -35,8 +36,8 @@ static bool can_aggregate_with(const struct batman_packet *new_batman_packet,
 			       const struct hard_iface *if_incoming,
 			       const struct forw_packet *forw_packet)
 {
-	struct batman_packet *batman_packet =
-		(struct batman_packet *)forw_packet->skb->data;
+	struct batman_ogm_packet *batman_ogm_packet =
+			(struct batman_ogm_packet *)forw_packet->skb->data;
 	int aggregated_bytes = forw_packet->packet_len + packet_len;
 	struct hard_iface *primary_if = NULL;
 	bool res = false;
@@ -71,8 +72,8 @@ static bool can_aggregate_with(const struct batman_packet *new_batman_packet,
 		/* packets without direct link flag and high TTL
 		 * are flooded through the net  */
 		if ((!directlink) &&
-		    (!(batman_packet->flags & DIRECTLINK)) &&
-		    (batman_packet->ttl != 1) &&
+		    (!(batman_ogm_packet->flags & DIRECTLINK)) &&
+		    (batman_ogm_packet->ttl != 1) &&
 
 		    /* own packets originating non-primary
 		     * interfaces leave only that interface */
@@ -85,13 +86,13 @@ static bool can_aggregate_with(const struct batman_packet *new_batman_packet,
 		/* if the incoming packet is sent via this one
 		 * interface only - we still can aggregate */
 		if ((directlink) &&
-		    (new_batman_packet->ttl == 1) &&
+		    (new_batman_ogm_packet->ttl == 1) &&
 		    (forw_packet->if_incoming == if_incoming) &&
 
 		    /* packets from direct neighbors or
 		     * own secondary interface packets
 		     * (= secondary interface packets in general) */
-		    (batman_packet->flags & DIRECTLINK ||
+		    (batman_ogm_packet->flags & DIRECTLINK ||
 		     (forw_packet->own &&
 		      forw_packet->if_incoming != primary_if))) {
 			res = true;
@@ -213,9 +214,11 @@ void add_bat_packet_to_list(struct bat_priv *bat_priv,
 	 */
 	struct forw_packet *forw_packet_aggr = NULL, *forw_packet_pos = NULL;
 	struct hlist_node *tmp_node;
-	struct batman_packet *batman_packet =
-		(struct batman_packet *)packet_buff;
-	bool direct_link = batman_packet->flags & DIRECTLINK ? 1 : 0;
+	struct batman_ogm_packet *batman_ogm_packet;
+	bool direct_link;
+
+	batman_ogm_packet = (struct batman_ogm_packet *)packet_buff;
+	direct_link = batman_ogm_packet->flags & DIRECTLINK ? 1 : 0;
 
 	/* find position for the packet in the forward queue */
 	spin_lock_bh(&bat_priv->forw_bat_list_lock);
@@ -223,7 +226,7 @@ void add_bat_packet_to_list(struct bat_priv *bat_priv,
 	if ((atomic_read(&bat_priv->aggregated_ogms)) && (!own_packet)) {
 		hlist_for_each_entry(forw_packet_pos, tmp_node,
 				     &bat_priv->forw_bat_list, list) {
-			if (can_aggregate_with(batman_packet,
+			if (can_aggregate_with(batman_ogm_packet,
 					       bat_priv,
 					       packet_len,
 					       send_time,
@@ -267,27 +270,28 @@ void receive_aggr_bat_packet(const struct ethhdr *ethhdr,
 			     unsigned char *packet_buff, int packet_len,
 			     struct hard_iface *if_incoming)
 {
-	struct batman_packet *batman_packet;
+	struct batman_ogm_packet *batman_ogm_packet;
 	int buff_pos = 0;
 	unsigned char *tt_buff;
 
-	batman_packet = (struct batman_packet *)packet_buff;
+	batman_ogm_packet = (struct batman_ogm_packet *)packet_buff;
 
 	do {
 		/* network to host order for our 32bit seqno and the
 		   orig_interval */
-		batman_packet->seqno = ntohl(batman_packet->seqno);
-		batman_packet->tt_crc = ntohs(batman_packet->tt_crc);
+		batman_ogm_packet->seqno = ntohl(batman_ogm_packet->seqno);
+		batman_ogm_packet->tt_crc = ntohs(batman_ogm_packet->tt_crc);
 
-		tt_buff = packet_buff + buff_pos + BAT_PACKET_LEN;
+		tt_buff = packet_buff + buff_pos + BATMAN_OGM_LEN;
 
-		receive_bat_packet(ethhdr, batman_packet, tt_buff, if_incoming);
+		receive_bat_packet(ethhdr, batman_ogm_packet,
+				   tt_buff, if_incoming);
 
-		buff_pos += BAT_PACKET_LEN +
-			tt_len(batman_packet->tt_num_changes);
+		buff_pos += BATMAN_OGM_LEN +
+				tt_len(batman_ogm_packet->tt_num_changes);
 
-		batman_packet = (struct batman_packet *)
-			(packet_buff + buff_pos);
+		batman_ogm_packet = (struct batman_ogm_packet *)
+						(packet_buff + buff_pos);
 	} while (aggregated_packet(buff_pos, packet_len,
-				   batman_packet->tt_num_changes));
+				   batman_ogm_packet->tt_num_changes));
 }
diff --git a/net/batman-adv/aggregation.h b/net/batman-adv/aggregation.h
index df4a5a9..7fc23b0 100644
--- a/net/batman-adv/aggregation.h
+++ b/net/batman-adv/aggregation.h
@@ -28,7 +28,7 @@
 static inline int aggregated_packet(int buff_pos, int packet_len,
 				    int tt_num_changes)
 {
-	int next_buff_pos = buff_pos + BAT_PACKET_LEN + tt_len(tt_num_changes);
+	int next_buff_pos = buff_pos + BATMAN_OGM_LEN + tt_len(tt_num_changes);
 
 	return (next_buff_pos <= packet_len) &&
 		(next_buff_pos <= MAX_AGGREGATION_BYTES);
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index bf91e4d..cf9f4af 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -131,7 +131,7 @@ static void primary_if_select(struct bat_priv *bat_priv,
 			      struct hard_iface *new_hard_iface)
 {
 	struct hard_iface *curr_hard_iface;
-	struct batman_packet *batman_packet;
+	struct batman_ogm_packet *batman_ogm_packet;
 
 	ASSERT_RTNL();
 
@@ -147,9 +147,10 @@ static void primary_if_select(struct bat_priv *bat_priv,
 	if (!new_hard_iface)
 		return;
 
-	batman_packet = (struct batman_packet *)(new_hard_iface->packet_buff);
-	batman_packet->flags = PRIMARIES_FIRST_HOP;
-	batman_packet->ttl = TTL;
+	batman_ogm_packet = (struct batman_ogm_packet *)
+						(new_hard_iface->packet_buff);
+	batman_ogm_packet->flags = PRIMARIES_FIRST_HOP;
+	batman_ogm_packet->ttl = TTL;
 
 	primary_if_update_addr(bat_priv);
 }
@@ -164,9 +165,12 @@ static bool hardif_is_iface_up(const struct hard_iface *hard_iface)
 
 static void update_mac_addresses(struct hard_iface *hard_iface)
 {
-	memcpy(((struct batman_packet *)(hard_iface->packet_buff))->orig,
+	struct batman_ogm_packet *batman_ogm_packet;
+
+	batman_ogm_packet = (struct batman_ogm_packet *)hard_iface->packet_buff;
+	memcpy(batman_ogm_packet->orig,
 	       hard_iface->net_dev->dev_addr, ETH_ALEN);
-	memcpy(((struct batman_packet *)(hard_iface->packet_buff))->prev_sender,
+	memcpy(batman_ogm_packet->prev_sender,
 	       hard_iface->net_dev->dev_addr, ETH_ALEN);
 }
 
@@ -283,7 +287,7 @@ int hardif_enable_interface(struct hard_iface *hard_iface,
 			    const char *iface_name)
 {
 	struct bat_priv *bat_priv;
-	struct batman_packet *batman_packet;
+	struct batman_ogm_packet *batman_ogm_packet;
 	struct net_device *soft_iface;
 	int ret;
 
@@ -318,7 +322,7 @@ int hardif_enable_interface(struct hard_iface *hard_iface,
 
 	hard_iface->soft_iface = soft_iface;
 	bat_priv = netdev_priv(hard_iface->soft_iface);
-	hard_iface->packet_len = BAT_PACKET_LEN;
+	hard_iface->packet_len = BATMAN_OGM_LEN;
 	hard_iface->packet_buff = kmalloc(hard_iface->packet_len, GFP_ATOMIC);
 
 	if (!hard_iface->packet_buff) {
@@ -328,14 +332,15 @@ int hardif_enable_interface(struct hard_iface *hard_iface,
 		goto err;
 	}
 
-	batman_packet = (struct batman_packet *)(hard_iface->packet_buff);
-	batman_packet->packet_type = BAT_PACKET;
-	batman_packet->version = COMPAT_VERSION;
-	batman_packet->flags = NO_FLAGS;
-	batman_packet->ttl = 2;
-	batman_packet->tq = TQ_MAX_VALUE;
-	batman_packet->tt_num_changes = 0;
-	batman_packet->ttvn = 0;
+	batman_ogm_packet = (struct batman_ogm_packet *)
+						(hard_iface->packet_buff);
+	batman_ogm_packet->packet_type = BAT_OGM;
+	batman_ogm_packet->version = COMPAT_VERSION;
+	batman_ogm_packet->flags = NO_FLAGS;
+	batman_ogm_packet->ttl = 2;
+	batman_ogm_packet->tq = TQ_MAX_VALUE;
+	batman_ogm_packet->tt_num_changes = 0;
+	batman_ogm_packet->ttvn = 0;
 
 	hard_iface->if_num = bat_priv->num_ifaces;
 	bat_priv->num_ifaces++;
@@ -580,7 +585,7 @@ static int batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
 			   struct net_device *orig_dev)
 {
 	struct bat_priv *bat_priv;
-	struct batman_packet *batman_packet;
+	struct batman_ogm_packet *batman_ogm_packet;
 	struct hard_iface *hard_iface;
 	int ret;
 
@@ -612,21 +617,21 @@ static int batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	if (hard_iface->if_status != IF_ACTIVE)
 		goto err_free;
 
-	batman_packet = (struct batman_packet *)skb->data;
+	batman_ogm_packet = (struct batman_ogm_packet *)skb->data;
 
-	if (batman_packet->version != COMPAT_VERSION) {
+	if (batman_ogm_packet->version != COMPAT_VERSION) {
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Drop packet: incompatible batman version (%i)\n",
-			batman_packet->version);
+			batman_ogm_packet->version);
 		goto err_free;
 	}
 
 	/* all receive handlers return whether they received or reused
 	 * the supplied skb. if not, we have to free the skb. */
 
-	switch (batman_packet->packet_type) {
+	switch (batman_ogm_packet->packet_type) {
 		/* batman originator packet */
-	case BAT_PACKET:
+	case BAT_OGM:
 		ret = recv_bat_packet(skb, hard_iface);
 		break;
 
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 8802eab..4d9e54c 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -25,14 +25,14 @@
 #define ETH_P_BATMAN  0x4305	/* unofficial/not registered Ethertype */
 
 enum bat_packettype {
-	BAT_PACKET       = 0x01,
-	BAT_ICMP         = 0x02,
-	BAT_UNICAST      = 0x03,
-	BAT_BCAST        = 0x04,
-	BAT_VIS          = 0x05,
+	BAT_OGM		 = 0x01,
+	BAT_ICMP	 = 0x02,
+	BAT_UNICAST	 = 0x03,
+	BAT_BCAST	 = 0x04,
+	BAT_VIS		 = 0x05,
 	BAT_UNICAST_FRAG = 0x06,
-	BAT_TT_QUERY     = 0x07,
-	BAT_ROAM_ADV     = 0x08
+	BAT_TT_QUERY	 = 0x07,
+	BAT_ROAM_ADV	 = 0x08
 };
 
 /* this file is included by batctl which needs these defines */
@@ -90,7 +90,7 @@ enum tt_client_flags {
 	TT_CLIENT_PENDING = 1 << 10
 };
 
-struct batman_packet {
+struct batman_ogm_packet {
 	uint8_t  packet_type;
 	uint8_t  version;  /* batman version field */
 	uint8_t  ttl;
@@ -105,7 +105,7 @@ struct batman_packet {
 	uint16_t tt_crc;
 } __packed;
 
-#define BAT_PACKET_LEN sizeof(struct batman_packet)
+#define BATMAN_OGM_LEN sizeof(struct batman_ogm_packet)
 
 struct icmp_packet {
 	uint8_t  packet_type;
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 1949928..6efd1d0 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -130,7 +130,7 @@ out:
 
 static int is_bidirectional_neigh(struct orig_node *orig_node,
 				struct orig_node *orig_neigh_node,
-				struct batman_packet *batman_packet,
+				struct batman_ogm_packet *batman_ogm_packet,
 				struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
@@ -209,7 +209,8 @@ static int is_bidirectional_neigh(struct orig_node *orig_node,
 					 TQ_LOCAL_WINDOW_SIZE *
 					 TQ_LOCAL_WINDOW_SIZE);
 
-	batman_packet->tq = ((batman_packet->tq * tq_own * tq_asym_penalty) /
+	batman_ogm_packet->tq = ((batman_ogm_packet->tq * tq_own
+							* tq_asym_penalty) /
 						(TQ_MAX_VALUE * TQ_MAX_VALUE));
 
 	bat_dbg(DBG_BATMAN, bat_priv,
@@ -218,11 +219,11 @@ static int is_bidirectional_neigh(struct orig_node *orig_node,
 		"real recv = %2i, local tq: %3i, asym_penalty: %3i, "
 		"total tq: %3i\n",
 		orig_node->orig, orig_neigh_node->orig, total_count,
-		neigh_rq_count, tq_own,	tq_asym_penalty, batman_packet->tq);
+		neigh_rq_count, tq_own,	tq_asym_penalty, batman_ogm_packet->tq);
 
 	/* if link has the minimum required transmission quality
 	 * consider it bidirectional */
-	if (batman_packet->tq >= TQ_TOTAL_BIDRECT_LIMIT)
+	if (batman_ogm_packet->tq >= TQ_TOTAL_BIDRECT_LIMIT)
 		ret = 1;
 
 out:
@@ -321,9 +322,10 @@ out:
 /* copy primary address for bonding */
 static void bonding_save_primary(const struct orig_node *orig_node,
 				 struct orig_node *orig_neigh_node,
-				 const struct batman_packet *batman_packet)
+				 const struct batman_ogm_packet
+							*batman_ogm_packet)
 {
-	if (!(batman_packet->flags & PRIMARIES_FIRST_HOP))
+	if (!(batman_ogm_packet->flags & PRIMARIES_FIRST_HOP))
 		return;
 
 	memcpy(orig_neigh_node->primary_addr, orig_node->orig, ETH_ALEN);
@@ -331,7 +333,7 @@ static void bonding_save_primary(const struct orig_node *orig_node,
 
 static void update_orig(struct bat_priv *bat_priv, struct orig_node *orig_node,
 			const struct ethhdr *ethhdr,
-			const struct batman_packet *batman_packet,
+			const struct batman_ogm_packet *batman_ogm_packet,
 			struct hard_iface *if_incoming,
 			const unsigned char *tt_buff, int is_duplicate)
 {
@@ -386,19 +388,19 @@ static void update_orig(struct bat_priv *bat_priv, struct orig_node *orig_node,
 
 	rcu_read_unlock();
 
-	orig_node->flags = batman_packet->flags;
+	orig_node->flags = batman_ogm_packet->flags;
 	neigh_node->last_valid = jiffies;
 
 	spin_lock_bh(&neigh_node->tq_lock);
 	ring_buffer_set(neigh_node->tq_recv,
 			&neigh_node->tq_index,
-			batman_packet->tq);
+			batman_ogm_packet->tq);
 	neigh_node->tq_avg = ring_buffer_avg(neigh_node->tq_recv);
 	spin_unlock_bh(&neigh_node->tq_lock);
 
 	if (!is_duplicate) {
-		orig_node->last_ttl = batman_packet->ttl;
-		neigh_node->last_ttl = batman_packet->ttl;
+		orig_node->last_ttl = batman_ogm_packet->ttl;
+		neigh_node->last_ttl = batman_ogm_packet->ttl;
 	}
 
 	bonding_candidate_add(orig_node, neigh_node);
@@ -437,17 +439,19 @@ static void update_orig(struct bat_priv *bat_priv, struct orig_node *orig_node,
 update_tt:
 	/* I have to check for transtable changes only if the OGM has been
 	 * sent through a primary interface */
-	if (((batman_packet->orig != ethhdr->h_source) &&
-				(batman_packet->ttl > 2)) ||
-				(batman_packet->flags & PRIMARIES_FIRST_HOP))
+	if (((batman_ogm_packet->orig != ethhdr->h_source) &&
+	     (batman_ogm_packet->ttl > 2)) ||
+	    (batman_ogm_packet->flags & PRIMARIES_FIRST_HOP))
 		tt_update_orig(bat_priv, orig_node, tt_buff,
-			       batman_packet->tt_num_changes,
-			       batman_packet->ttvn, batman_packet->tt_crc);
+			       batman_ogm_packet->tt_num_changes,
+			       batman_ogm_packet->ttvn,
+			       batman_ogm_packet->tt_crc);
 
-	if (orig_node->gw_flags != batman_packet->gw_flags)
-		gw_node_update(bat_priv, orig_node, batman_packet->gw_flags);
+	if (orig_node->gw_flags != batman_ogm_packet->gw_flags)
+		gw_node_update(bat_priv, orig_node,
+			       batman_ogm_packet->gw_flags);
 
-	orig_node->gw_flags = batman_packet->gw_flags;
+	orig_node->gw_flags = batman_ogm_packet->gw_flags;
 
 	/* restart gateway selection if fast or late switching was enabled */
 	if ((orig_node->gw_flags) &&
@@ -500,8 +504,8 @@ static int window_protected(struct bat_priv *bat_priv,
  *     was protected. Caller should drop it.
  */
 static int count_real_packets(const struct ethhdr *ethhdr,
-			       const struct batman_packet *batman_packet,
-			       const struct hard_iface *if_incoming)
+			      const struct batman_ogm_packet *batman_ogm_packet,
+			      const struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct orig_node *orig_node;
@@ -512,12 +516,12 @@ static int count_real_packets(const struct ethhdr *ethhdr,
 	int need_update = 0;
 	int set_mark, ret = -1;
 
-	orig_node = get_orig_node(bat_priv, batman_packet->orig);
+	orig_node = get_orig_node(bat_priv, batman_ogm_packet->orig);
 	if (!orig_node)
 		return 0;
 
 	spin_lock_bh(&orig_node->ogm_cnt_lock);
-	seq_diff = batman_packet->seqno - orig_node->last_real_seqno;
+	seq_diff = batman_ogm_packet->seqno - orig_node->last_real_seqno;
 
 	/* signalize caller that the packet is to be dropped. */
 	if (window_protected(bat_priv, seq_diff,
@@ -530,7 +534,7 @@ static int count_real_packets(const struct ethhdr *ethhdr,
 
 		is_duplicate |= get_bit_status(tmp_neigh_node->real_bits,
 					       orig_node->last_real_seqno,
-					       batman_packet->seqno);
+					       batman_ogm_packet->seqno);
 
 		if (compare_eth(tmp_neigh_node->addr, ethhdr->h_source) &&
 		    (tmp_neigh_node->if_incoming == if_incoming))
@@ -551,8 +555,8 @@ static int count_real_packets(const struct ethhdr *ethhdr,
 	if (need_update) {
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"updating last_seqno: old %d, new %d\n",
-			orig_node->last_real_seqno, batman_packet->seqno);
-		orig_node->last_real_seqno = batman_packet->seqno;
+			orig_node->last_real_seqno, batman_ogm_packet->seqno);
+		orig_node->last_real_seqno = batman_ogm_packet->seqno;
 	}
 
 	ret = is_duplicate;
@@ -564,7 +568,7 @@ out:
 }
 
 void receive_bat_packet(const struct ethhdr *ethhdr,
-			struct batman_packet *batman_packet,
+			struct batman_ogm_packet *batman_ogm_packet,
 			const unsigned char *tt_buff,
 			struct hard_iface *if_incoming)
 {
@@ -587,31 +591,31 @@ void receive_bat_packet(const struct ethhdr *ethhdr,
 	 * it as an additional length.
 	 *
 	 * TODO: A more sane solution would be to have a bit in the
-	 * batman_packet to detect whether the packet is the last
+	 * batman_ogm_packet to detect whether the packet is the last
 	 * packet in an aggregation.  Here we expect that the padding
 	 * is always zero (or not 0x01)
 	 */
-	if (batman_packet->packet_type != BAT_PACKET)
+	if (batman_ogm_packet->packet_type != BAT_OGM)
 		return;
 
 	/* could be changed by schedule_own_packet() */
 	if_incoming_seqno = atomic_read(&if_incoming->seqno);
 
-	has_directlink_flag = (batman_packet->flags & DIRECTLINK ? 1 : 0);
+	has_directlink_flag = (batman_ogm_packet->flags & DIRECTLINK ? 1 : 0);
 
 	is_single_hop_neigh = (compare_eth(ethhdr->h_source,
-					   batman_packet->orig) ? 1 : 0);
+					   batman_ogm_packet->orig) ? 1 : 0);
 
 	bat_dbg(DBG_BATMAN, bat_priv,
 		"Received BATMAN packet via NB: %pM, IF: %s [%pM] "
 		"(from OG: %pM, via prev OG: %pM, seqno %d, ttvn %u, "
 		"crc %u, changes %u, td %d, TTL %d, V %d, IDF %d)\n",
 		ethhdr->h_source, if_incoming->net_dev->name,
-		if_incoming->net_dev->dev_addr, batman_packet->orig,
-		batman_packet->prev_sender, batman_packet->seqno,
-		batman_packet->ttvn, batman_packet->tt_crc,
-		batman_packet->tt_num_changes, batman_packet->tq,
-		batman_packet->ttl, batman_packet->version,
+		if_incoming->net_dev->dev_addr, batman_ogm_packet->orig,
+		batman_ogm_packet->prev_sender, batman_ogm_packet->seqno,
+		batman_ogm_packet->ttvn, batman_ogm_packet->tt_crc,
+		batman_ogm_packet->tt_num_changes, batman_ogm_packet->tq,
+		batman_ogm_packet->ttl, batman_ogm_packet->version,
 		has_directlink_flag);
 
 	rcu_read_lock();
@@ -626,11 +630,11 @@ void receive_bat_packet(const struct ethhdr *ethhdr,
 				hard_iface->net_dev->dev_addr))
 			is_my_addr = 1;
 
-		if (compare_eth(batman_packet->orig,
+		if (compare_eth(batman_ogm_packet->orig,
 				hard_iface->net_dev->dev_addr))
 			is_my_orig = 1;
 
-		if (compare_eth(batman_packet->prev_sender,
+		if (compare_eth(batman_ogm_packet->prev_sender,
 				hard_iface->net_dev->dev_addr))
 			is_my_oldorig = 1;
 
@@ -639,10 +643,10 @@ void receive_bat_packet(const struct ethhdr *ethhdr,
 	}
 	rcu_read_unlock();
 
-	if (batman_packet->version != COMPAT_VERSION) {
+	if (batman_ogm_packet->version != COMPAT_VERSION) {
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Drop packet: incompatible batman version (%i)\n",
-			batman_packet->version);
+			batman_ogm_packet->version);
 		return;
 	}
 
@@ -674,13 +678,14 @@ void receive_bat_packet(const struct ethhdr *ethhdr,
 		/* save packet seqno for bidirectional check */
 		if (has_directlink_flag &&
 		    compare_eth(if_incoming->net_dev->dev_addr,
-				batman_packet->orig)) {
+				batman_ogm_packet->orig)) {
 			offset = if_incoming->if_num * NUM_WORDS;
 
 			spin_lock_bh(&orig_neigh_node->ogm_cnt_lock);
 			word = &(orig_neigh_node->bcast_own[offset]);
 			bit_mark(word,
-				 if_incoming_seqno - batman_packet->seqno - 2);
+				 if_incoming_seqno -
+						batman_ogm_packet->seqno - 2);
 			orig_neigh_node->bcast_own_sum[if_incoming->if_num] =
 				bit_packet_count(word);
 			spin_unlock_bh(&orig_neigh_node->ogm_cnt_lock);
@@ -699,11 +704,12 @@ void receive_bat_packet(const struct ethhdr *ethhdr,
 		return;
 	}
 
-	orig_node = get_orig_node(bat_priv, batman_packet->orig);
+	orig_node = get_orig_node(bat_priv, batman_ogm_packet->orig);
 	if (!orig_node)
 		return;
 
-	is_duplicate = count_real_packets(ethhdr, batman_packet, if_incoming);
+	is_duplicate = count_real_packets(ethhdr, batman_ogm_packet,
+					  if_incoming);
 
 	if (is_duplicate == -1) {
 		bat_dbg(DBG_BATMAN, bat_priv,
@@ -712,7 +718,7 @@ void receive_bat_packet(const struct ethhdr *ethhdr,
 		goto out;
 	}
 
-	if (batman_packet->tq == 0) {
+	if (batman_ogm_packet->tq == 0) {
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Drop packet: originator packet with tq equal 0\n");
 		goto out;
@@ -724,8 +730,9 @@ void receive_bat_packet(const struct ethhdr *ethhdr,
 
 	/* avoid temporary routing loops */
 	if (router && router_router &&
-	    (compare_eth(router->addr, batman_packet->prev_sender)) &&
-	    !(compare_eth(batman_packet->orig, batman_packet->prev_sender)) &&
+	    (compare_eth(router->addr, batman_ogm_packet->prev_sender)) &&
+	    !(compare_eth(batman_ogm_packet->orig,
+			  batman_ogm_packet->prev_sender)) &&
 	    (compare_eth(router->addr, router_router->addr))) {
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Drop packet: ignoring all rebroadcast packets that "
@@ -752,24 +759,25 @@ void receive_bat_packet(const struct ethhdr *ethhdr,
 	}
 
 	is_bidirectional = is_bidirectional_neigh(orig_node, orig_neigh_node,
-						batman_packet, if_incoming);
+						  batman_ogm_packet,
+						  if_incoming);
 
-	bonding_save_primary(orig_node, orig_neigh_node, batman_packet);
+	bonding_save_primary(orig_node, orig_neigh_node, batman_ogm_packet);
 
 	/* update ranking if it is not a duplicate or has the same
 	 * seqno and similar ttl as the non-duplicate */
 	if (is_bidirectional &&
 	    (!is_duplicate ||
-	     ((orig_node->last_real_seqno == batman_packet->seqno) &&
-	      (orig_node->last_ttl - 3 <= batman_packet->ttl))))
-		update_orig(bat_priv, orig_node, ethhdr, batman_packet,
+	     ((orig_node->last_real_seqno == batman_ogm_packet->seqno) &&
+	      (orig_node->last_ttl - 3 <= batman_ogm_packet->ttl))))
+		update_orig(bat_priv, orig_node, ethhdr, batman_ogm_packet,
 			    if_incoming, tt_buff, is_duplicate);
 
 	/* is single hop (direct) neighbor */
 	if (is_single_hop_neigh) {
 
 		/* mark direct link on incoming interface */
-		schedule_forward_packet(orig_node, ethhdr, batman_packet,
+		schedule_forward_packet(orig_node, ethhdr, batman_ogm_packet,
 					1, if_incoming);
 
 		bat_dbg(DBG_BATMAN, bat_priv, "Forwarding packet: "
@@ -792,7 +800,7 @@ void receive_bat_packet(const struct ethhdr *ethhdr,
 
 	bat_dbg(DBG_BATMAN, bat_priv,
 		"Forwarding packet: rebroadcast originator packet\n");
-	schedule_forward_packet(orig_node, ethhdr, batman_packet,
+	schedule_forward_packet(orig_node, ethhdr, batman_ogm_packet,
 				0, if_incoming);
 
 out_neigh:
@@ -814,7 +822,7 @@ int recv_bat_packet(struct sk_buff *skb, struct hard_iface *hard_iface)
 	struct ethhdr *ethhdr;
 
 	/* drop packet if it has not necessary minimum size */
-	if (unlikely(!pskb_may_pull(skb, sizeof(struct batman_packet))))
+	if (unlikely(!pskb_may_pull(skb, BATMAN_OGM_LEN)))
 		return NET_RX_DROP;
 
 	ethhdr = (struct ethhdr *)skb_mac_header(skb);
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index fb14e95..893db7f 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -24,7 +24,7 @@
 
 void slide_own_bcast_window(struct hard_iface *hard_iface);
 void receive_bat_packet(const struct ethhdr *ethhdr,
-			struct batman_packet *batman_packet,
+			struct batman_ogm_packet *batman_ogm_packet,
 			const unsigned char *tt_buff,
 			struct hard_iface *if_incoming);
 void update_routes(struct bat_priv *bat_priv, struct orig_node *orig_node,
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 57ae809..40a5fcd 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -107,7 +107,7 @@ static void send_packet_to_if(struct forw_packet *forw_packet,
 	char *fwd_str;
 	uint8_t packet_num;
 	int16_t buff_pos;
-	struct batman_packet *batman_packet;
+	struct batman_ogm_packet *batman_ogm_packet;
 	struct sk_buff *skb;
 
 	if (hard_iface->if_status != IF_ACTIVE)
@@ -115,20 +115,20 @@ static void send_packet_to_if(struct forw_packet *forw_packet,
 
 	packet_num = 0;
 	buff_pos = 0;
-	batman_packet = (struct batman_packet *)forw_packet->skb->data;
+	batman_ogm_packet = (struct batman_ogm_packet *)forw_packet->skb->data;
 
 	/* adjust all flags and log packets */
 	while (aggregated_packet(buff_pos,
 				 forw_packet->packet_len,
-				 batman_packet->tt_num_changes)) {
+				 batman_ogm_packet->tt_num_changes)) {
 
 		/* we might have aggregated direct link packets with an
 		 * ordinary base packet */
 		if ((forw_packet->direct_link_flags & (1 << packet_num)) &&
 		    (forw_packet->if_incoming == hard_iface))
-			batman_packet->flags |= DIRECTLINK;
+			batman_ogm_packet->flags |= DIRECTLINK;
 		else
-			batman_packet->flags &= ~DIRECTLINK;
+			batman_ogm_packet->flags &= ~DIRECTLINK;
 
 		fwd_str = (packet_num > 0 ? "Forwarding" : (forw_packet->own ?
 							    "Sending own" :
@@ -137,18 +137,19 @@ static void send_packet_to_if(struct forw_packet *forw_packet,
 			"%s %spacket (originator %pM, seqno %d, TQ %d, TTL %d,"
 			" IDF %s, ttvn %d) on interface %s [%pM]\n",
 			fwd_str, (packet_num > 0 ? "aggregated " : ""),
-			batman_packet->orig, ntohl(batman_packet->seqno),
-			batman_packet->tq, batman_packet->ttl,
-			(batman_packet->flags & DIRECTLINK ?
+			batman_ogm_packet->orig,
+			ntohl(batman_ogm_packet->seqno),
+			batman_ogm_packet->tq, batman_ogm_packet->ttl,
+			(batman_ogm_packet->flags & DIRECTLINK ?
 			 "on" : "off"),
-			batman_packet->ttvn, hard_iface->net_dev->name,
+			batman_ogm_packet->ttvn, hard_iface->net_dev->name,
 			hard_iface->net_dev->dev_addr);
 
-		buff_pos += sizeof(*batman_packet) +
-			tt_len(batman_packet->tt_num_changes);
+		buff_pos += BATMAN_OGM_LEN +
+				tt_len(batman_ogm_packet->tt_num_changes);
 		packet_num++;
-		batman_packet = (struct batman_packet *)
-			(forw_packet->skb->data + buff_pos);
+		batman_ogm_packet = (struct batman_ogm_packet *)
+					(forw_packet->skb->data + buff_pos);
 	}
 
 	/* create clone because function is called more than once */
@@ -164,9 +165,11 @@ static void send_packet(struct forw_packet *forw_packet)
 	struct net_device *soft_iface;
 	struct bat_priv *bat_priv;
 	struct hard_iface *primary_if = NULL;
-	struct batman_packet *batman_packet =
-		(struct batman_packet *)(forw_packet->skb->data);
-	int directlink = (batman_packet->flags & DIRECTLINK ? 1 : 0);
+	struct batman_ogm_packet *batman_ogm_packet =
+			(struct batman_ogm_packet *)(forw_packet->skb->data);
+	unsigned char directlink;
+
+	directlink = (batman_ogm_packet->flags & DIRECTLINK ? 1 : 0);
 
 	if (!forw_packet->if_incoming) {
 		pr_err("Error - can't forward packet: incoming iface not "
@@ -186,7 +189,7 @@ static void send_packet(struct forw_packet *forw_packet)
 
 	/* multihomed peer assumed */
 	/* non-primary OGMs are only broadcasted on their interface */
-	if ((directlink && (batman_packet->ttl == 1)) ||
+	if ((directlink && (batman_ogm_packet->ttl == 1)) ||
 	    (forw_packet->own && (forw_packet->if_incoming != primary_if))) {
 
 		/* FIXME: what about aggregated packets ? */
@@ -194,8 +197,9 @@ static void send_packet(struct forw_packet *forw_packet)
 			"%s packet (originator %pM, seqno %d, TTL %d) "
 			"on interface %s [%pM]\n",
 			(forw_packet->own ? "Sending own" : "Forwarding"),
-			batman_packet->orig, ntohl(batman_packet->seqno),
-			batman_packet->ttl,
+			batman_ogm_packet->orig,
+			ntohl(batman_ogm_packet->seqno),
+			batman_ogm_packet->ttl,
 			forw_packet->if_incoming->net_dev->name,
 			forw_packet->if_incoming->net_dev->dev_addr);
 
@@ -223,17 +227,16 @@ out:
 }
 
 static void realloc_packet_buffer(struct hard_iface *hard_iface,
-				int new_len)
+				  int new_len)
 {
 	unsigned char *new_buff;
-	struct batman_packet *batman_packet;
 
 	new_buff = kmalloc(new_len, GFP_ATOMIC);
 
 	/* keep old buffer if kmalloc should fail */
 	if (new_buff) {
 		memcpy(new_buff, hard_iface->packet_buff,
-		       sizeof(*batman_packet));
+		       BATMAN_OGM_LEN);
 
 		kfree(hard_iface->packet_buff);
 		hard_iface->packet_buff = new_buff;
@@ -246,39 +249,39 @@ static void prepare_packet_buffer(struct bat_priv *bat_priv,
 				  struct hard_iface *hard_iface)
 {
 	int new_len;
-	struct batman_packet *batman_packet;
+	struct batman_ogm_packet *batman_ogm_packet;
 
-	new_len = BAT_PACKET_LEN +
+	new_len = BATMAN_OGM_LEN +
 		  tt_len((uint8_t)atomic_read(&bat_priv->tt_local_changes));
 
 	/* if we have too many changes for one packet don't send any
 	 * and wait for the tt table request which will be fragmented */
 	if (new_len > hard_iface->soft_iface->mtu)
-		new_len = BAT_PACKET_LEN;
+		new_len = BATMAN_OGM_LEN;
 
 	realloc_packet_buffer(hard_iface, new_len);
-	batman_packet = (struct batman_packet *)hard_iface->packet_buff;
+	batman_ogm_packet = (struct batman_ogm_packet *)hard_iface->packet_buff;
 
 	atomic_set(&bat_priv->tt_crc, tt_local_crc(bat_priv));
 
 	/* reset the sending counter */
 	atomic_set(&bat_priv->tt_ogm_append_cnt, TT_OGM_APPEND_MAX);
 
-	batman_packet->tt_num_changes = tt_changes_fill_buffer(bat_priv,
-				hard_iface->packet_buff + BAT_PACKET_LEN,
-				hard_iface->packet_len - BAT_PACKET_LEN);
+	batman_ogm_packet->tt_num_changes = tt_changes_fill_buffer(bat_priv,
+				hard_iface->packet_buff + BATMAN_OGM_LEN,
+				hard_iface->packet_len - BATMAN_OGM_LEN);
 
 }
 
 static void reset_packet_buffer(struct bat_priv *bat_priv,
-	struct hard_iface *hard_iface)
+				struct hard_iface *hard_iface)
 {
-	struct batman_packet *batman_packet;
+	struct batman_ogm_packet *batman_ogm_packet;
 
-	realloc_packet_buffer(hard_iface, BAT_PACKET_LEN);
+	realloc_packet_buffer(hard_iface, BATMAN_OGM_LEN);
 
-	batman_packet = (struct batman_packet *)hard_iface->packet_buff;
-	batman_packet->tt_num_changes = 0;
+	batman_ogm_packet = (struct batman_ogm_packet *)hard_iface->packet_buff;
+	batman_ogm_packet->tt_num_changes = 0;
 }
 
 void schedule_own_packet(struct hard_iface *hard_iface)
@@ -286,7 +289,7 @@ void schedule_own_packet(struct hard_iface *hard_iface)
 	struct bat_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
 	struct hard_iface *primary_if;
 	unsigned long send_time;
-	struct batman_packet *batman_packet;
+	struct batman_ogm_packet *batman_ogm_packet;
 	int vis_server;
 
 	if ((hard_iface->if_status == IF_NOT_IN_USE) ||
@@ -322,26 +325,27 @@ void schedule_own_packet(struct hard_iface *hard_iface)
 	 * NOTE: packet_buff might just have been re-allocated in
 	 * prepare_packet_buffer() or in reset_packet_buffer()
 	 */
-	batman_packet = (struct batman_packet *)hard_iface->packet_buff;
+	batman_ogm_packet = (struct batman_ogm_packet *)hard_iface->packet_buff;
 
 	/* change sequence number to network order */
-	batman_packet->seqno =
-		htonl((uint32_t)atomic_read(&hard_iface->seqno));
+	batman_ogm_packet->seqno =
+			htonl((uint32_t)atomic_read(&hard_iface->seqno));
 
-	batman_packet->ttvn = atomic_read(&bat_priv->ttvn);
-	batman_packet->tt_crc = htons((uint16_t)atomic_read(&bat_priv->tt_crc));
+	batman_ogm_packet->ttvn = atomic_read(&bat_priv->ttvn);
+	batman_ogm_packet->tt_crc = htons((uint16_t)
+						atomic_read(&bat_priv->tt_crc));
 
 	if (vis_server == VIS_TYPE_SERVER_SYNC)
-		batman_packet->flags |= VIS_SERVER;
+		batman_ogm_packet->flags |= VIS_SERVER;
 	else
-		batman_packet->flags &= ~VIS_SERVER;
+		batman_ogm_packet->flags &= ~VIS_SERVER;
 
 	if ((hard_iface == primary_if) &&
 	    (atomic_read(&bat_priv->gw_mode) == GW_MODE_SERVER))
-		batman_packet->gw_flags =
+		batman_ogm_packet->gw_flags =
 				(uint8_t)atomic_read(&bat_priv->gw_bandwidth);
 	else
-		batman_packet->gw_flags = NO_FLAGS;
+		batman_ogm_packet->gw_flags = NO_FLAGS;
 
 	atomic_inc(&hard_iface->seqno);
 
@@ -358,7 +362,7 @@ void schedule_own_packet(struct hard_iface *hard_iface)
 
 void schedule_forward_packet(struct orig_node *orig_node,
 			     const struct ethhdr *ethhdr,
-			     struct batman_packet *batman_packet,
+			     struct batman_ogm_packet *batman_ogm_packet,
 			     int directlink,
 			     struct hard_iface *if_incoming)
 {
@@ -368,19 +372,19 @@ void schedule_forward_packet(struct orig_node *orig_node,
 	unsigned long send_time;
 	uint8_t tt_num_changes;
 
-	if (batman_packet->ttl <= 1) {
+	if (batman_ogm_packet->ttl <= 1) {
 		bat_dbg(DBG_BATMAN, bat_priv, "ttl exceeded\n");
 		return;
 	}
 
 	router = orig_node_get_router(orig_node);
 
-	in_tq = batman_packet->tq;
-	in_ttl = batman_packet->ttl;
-	tt_num_changes = batman_packet->tt_num_changes;
+	in_tq = batman_ogm_packet->tq;
+	in_ttl = batman_ogm_packet->ttl;
+	tt_num_changes = batman_ogm_packet->tt_num_changes;
 
-	batman_packet->ttl--;
-	memcpy(batman_packet->prev_sender, ethhdr->h_source, ETH_ALEN);
+	batman_ogm_packet->ttl--;
+	memcpy(batman_ogm_packet->prev_sender, ethhdr->h_source, ETH_ALEN);
 
 	/* rebroadcast tq of our best ranking neighbor to ensure the rebroadcast
 	 * of our best tq value */
@@ -388,10 +392,10 @@ void schedule_forward_packet(struct orig_node *orig_node,
 
 		/* rebroadcast ogm of best ranking neighbor as is */
 		if (!compare_eth(router->addr, ethhdr->h_source)) {
-			batman_packet->tq = router->tq_avg;
+			batman_ogm_packet->tq = router->tq_avg;
 
 			if (router->last_ttl)
-				batman_packet->ttl = router->last_ttl - 1;
+				batman_ogm_packet->ttl = router->last_ttl - 1;
 		}
 
 		tq_avg = router->tq_avg;
@@ -401,28 +405,28 @@ void schedule_forward_packet(struct orig_node *orig_node,
 		neigh_node_free_ref(router);
 
 	/* apply hop penalty */
-	batman_packet->tq = hop_penalty(batman_packet->tq, bat_priv);
+	batman_ogm_packet->tq = hop_penalty(batman_ogm_packet->tq, bat_priv);
 
 	bat_dbg(DBG_BATMAN, bat_priv,
 		"Forwarding packet: tq_orig: %i, tq_avg: %i, "
 		"tq_forw: %i, ttl_orig: %i, ttl_forw: %i\n",
-		in_tq, tq_avg, batman_packet->tq, in_ttl - 1,
-		batman_packet->ttl);
+		in_tq, tq_avg, batman_ogm_packet->tq, in_ttl - 1,
+		batman_ogm_packet->ttl);
 
-	batman_packet->seqno = htonl(batman_packet->seqno);
-	batman_packet->tt_crc = htons(batman_packet->tt_crc);
+	batman_ogm_packet->seqno = htonl(batman_ogm_packet->seqno);
+	batman_ogm_packet->tt_crc = htons(batman_ogm_packet->tt_crc);
 
 	/* switch of primaries first hop flag when forwarding */
-	batman_packet->flags &= ~PRIMARIES_FIRST_HOP;
+	batman_ogm_packet->flags &= ~PRIMARIES_FIRST_HOP;
 	if (directlink)
-		batman_packet->flags |= DIRECTLINK;
+		batman_ogm_packet->flags |= DIRECTLINK;
 	else
-		batman_packet->flags &= ~DIRECTLINK;
+		batman_ogm_packet->flags &= ~DIRECTLINK;
 
 	send_time = forward_send_time();
 	add_bat_packet_to_list(bat_priv,
-			       (unsigned char *)batman_packet,
-			       sizeof(*batman_packet) + tt_len(tt_num_changes),
+			       (unsigned char *)batman_ogm_packet,
+			       BATMAN_OGM_LEN + tt_len(tt_num_changes),
 			       if_incoming, 0, send_time);
 }
 
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index 1f2d1e8..8a22d84 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -27,7 +27,7 @@ int send_skb_packet(struct sk_buff *skb, struct hard_iface *hard_iface,
 void schedule_own_packet(struct hard_iface *hard_iface);
 void schedule_forward_packet(struct orig_node *orig_node,
 			     const struct ethhdr *ethhdr,
-			     struct batman_packet *batman_packet,
+			     struct batman_ogm_packet *batman_ogm_packet,
 			     int directlink,
 			     struct hard_iface *if_outgoing);
 int add_bcast_packet_to_list(struct bat_priv *bat_priv,
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 402fd96..7d8332e 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -445,30 +445,31 @@ static void softif_batman_recv(struct sk_buff *skb, struct net_device *dev,
 {
 	struct bat_priv *bat_priv = netdev_priv(dev);
 	struct ethhdr *ethhdr = (struct ethhdr *)skb->data;
-	struct batman_packet *batman_packet;
+	struct batman_ogm_packet *batman_ogm_packet;
 	struct softif_neigh *softif_neigh = NULL;
 	struct hard_iface *primary_if = NULL;
 	struct softif_neigh *curr_softif_neigh = NULL;
 
 	if (ntohs(ethhdr->h_proto) == ETH_P_8021Q)
-		batman_packet = (struct batman_packet *)
+		batman_ogm_packet = (struct batman_ogm_packet *)
 					(skb->data + ETH_HLEN + VLAN_HLEN);
 	else
-		batman_packet = (struct batman_packet *)(skb->data + ETH_HLEN);
+		batman_ogm_packet = (struct batman_ogm_packet *)
+							(skb->data + ETH_HLEN);
 
-	if (batman_packet->version != COMPAT_VERSION)
+	if (batman_ogm_packet->version != COMPAT_VERSION)
 		goto out;
 
-	if (batman_packet->packet_type != BAT_PACKET)
+	if (batman_ogm_packet->packet_type != BAT_OGM)
 		goto out;
 
-	if (!(batman_packet->flags & PRIMARIES_FIRST_HOP))
+	if (!(batman_ogm_packet->flags & PRIMARIES_FIRST_HOP))
 		goto out;
 
-	if (is_my_mac(batman_packet->orig))
+	if (is_my_mac(batman_ogm_packet->orig))
 		goto out;
 
-	softif_neigh = softif_neigh_get(bat_priv, batman_packet->orig, vid);
+	softif_neigh = softif_neigh_get(bat_priv, batman_ogm_packet->orig, vid);
 	if (!softif_neigh)
 		goto out;
 
-- 
1.7.5.4

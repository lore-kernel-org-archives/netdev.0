From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: batman: keep batman_ogm_packet ->seqno net-endian
	all along
Date: Wed, 18 Apr 2012 19:11:50 +0100
Message-ID: <20120418181150.GE6589@ZenIV.linux.org.uk>
References: <1334743210-12338-1-git-send-email-ordex@autistici.org>
	<20120418180837.GB6589@ZenIV.linux.org.uk>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120418180837.GB6589-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
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

Ditto for its ->seqno...

Signed-off-by: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
---
 net/batman-adv/bat_iv_ogm.c |   25 ++++++++++---------------
 net/batman-adv/packet.h     |    2 +-
 2 files changed, 11 insertions(+), 16 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 5aa8861..cc6d4c3 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -34,11 +34,11 @@ static struct neigh_node *bat_iv_ogm_neigh_new(struct hard_iface *hard_iface,
 					       const uint8_t *neigh_addr,
 					       struct orig_node *orig_node,
 					       struct orig_node *orig_neigh,
-					       uint32_t seqno)
+					       __be32 seqno)
 {
 	struct neigh_node *neigh_node;
 
-	neigh_node = neigh_node_new(hard_iface, neigh_addr, seqno);
+	neigh_node = neigh_node_new(hard_iface, neigh_addr, ntohl(seqno));
 	if (!neigh_node)
 		goto out;
 
@@ -543,8 +543,6 @@ static void bat_iv_ogm_forward(struct orig_node *orig_node,
 		"Forwarding packet: tq: %i, ttl: %i\n",
 		batman_ogm_packet->tq, batman_ogm_packet->header.ttl);
 
-	batman_ogm_packet->seqno = htonl(batman_ogm_packet->seqno);
-
 	/* switch of primaries first hop flag when forwarding */
 	batman_ogm_packet->flags &= ~PRIMARIES_FIRST_HOP;
 	if (is_single_hop_neigh)
@@ -868,13 +866,14 @@ static int bat_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 	int32_t seq_diff;
 	int need_update = 0;
 	int set_mark, ret = -1;
+	uint32_t seqno = ntohl(batman_ogm_packet->seqno);
 
 	orig_node = get_orig_node(bat_priv, batman_ogm_packet->orig);
 	if (!orig_node)
 		return 0;
 
 	spin_lock_bh(&orig_node->ogm_cnt_lock);
-	seq_diff = batman_ogm_packet->seqno - orig_node->last_real_seqno;
+	seq_diff = seqno - orig_node->last_real_seqno;
 
 	/* signalize caller that the packet is to be dropped. */
 	if (!hlist_empty(&orig_node->neigh_list) &&
@@ -888,7 +887,7 @@ static int bat_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 
 		is_duplicate |= bat_test_bit(tmp_neigh_node->real_bits,
 					     orig_node->last_real_seqno,
-					     batman_ogm_packet->seqno);
+					     seqno);
 
 		if (compare_eth(tmp_neigh_node->addr, ethhdr->h_source) &&
 		    (tmp_neigh_node->if_incoming == if_incoming))
@@ -910,8 +909,8 @@ static int bat_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 	if (need_update) {
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"updating last_seqno: old %u, new %u\n",
-			orig_node->last_real_seqno, batman_ogm_packet->seqno);
-		orig_node->last_real_seqno = batman_ogm_packet->seqno;
+			orig_node->last_real_seqno, seqno);
+		orig_node->last_real_seqno = seqno;
 	}
 
 	ret = is_duplicate;
@@ -967,7 +966,7 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 		"Received BATMAN packet via NB: %pM, IF: %s [%pM] (from OG: %pM, via prev OG: %pM, seqno %u, ttvn %u, crc %u, changes %u, td %d, TTL %d, V %d, IDF %d)\n",
 		ethhdr->h_source, if_incoming->net_dev->name,
 		if_incoming->net_dev->dev_addr, batman_ogm_packet->orig,
-		batman_ogm_packet->prev_sender, batman_ogm_packet->seqno,
+		batman_ogm_packet->prev_sender, ntohl(batman_ogm_packet->seqno),
 		batman_ogm_packet->ttvn, ntohs(batman_ogm_packet->tt_crc),
 		batman_ogm_packet->tt_num_changes, batman_ogm_packet->tq,
 		batman_ogm_packet->header.ttl,
@@ -1039,7 +1038,7 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 			word = &(orig_neigh_node->bcast_own[offset]);
 			bat_set_bit(word,
 				    if_incoming_seqno -
-						batman_ogm_packet->seqno - 2);
+					ntohl(batman_ogm_packet->seqno) - 2);
 			orig_neigh_node->bcast_own_sum[if_incoming->if_num] =
 				bitmap_weight(word, TQ_LOCAL_WINDOW_SIZE);
 			spin_unlock_bh(&orig_neigh_node->ogm_cnt_lock);
@@ -1132,7 +1131,7 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 	 * seqno and similar ttl as the non-duplicate */
 	if (is_bidirectional &&
 	    (!is_duplicate ||
-	     ((orig_node->last_real_seqno == batman_ogm_packet->seqno) &&
+	     ((orig_node->last_real_seqno == ntohl(batman_ogm_packet->seqno)) &&
 	      (orig_node->last_ttl - 3 <= batman_ogm_packet->header.ttl))))
 		bat_iv_ogm_orig_update(bat_priv, orig_node, ethhdr,
 				       batman_ogm_packet, if_incoming,
@@ -1210,10 +1209,6 @@ static int bat_iv_ogm_receive(struct sk_buff *skb,
 
 	/* unpack the aggregated packets and process them one by one */
 	do {
-		/* network to host order for our 32bit seqno and the
-		   orig_interval */
-		batman_ogm_packet->seqno = ntohl(batman_ogm_packet->seqno);
-
 		tt_buff = packet_buff + buff_pos + BATMAN_OGM_HLEN;
 
 		bat_iv_ogm_process(ethhdr, batman_ogm_packet,
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 61a7fe0..ad39938 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -125,7 +125,7 @@ struct batman_header {
 struct batman_ogm_packet {
 	struct batman_header header;
 	uint8_t  flags;    /* 0x40: DIRECTLINK flag, 0x20 VIS_SERVER flag... */
-	uint32_t seqno;
+	__be32   seqno;
 	uint8_t  orig[ETH_ALEN];
 	uint8_t  prev_sender[ETH_ALEN];
 	uint8_t  gw_flags;  /* flags related to gateway class */
-- 
1.7.2.5

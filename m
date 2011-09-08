From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: [PATCH 2/7] batman-adv: agglomerate all batman iv
	ogm processing functions in a single file
Date: Thu,  8 Sep 2011 18:40:46 +0200
Message-ID: <1315500051-1122-3-git-send-email-lindner_marek@yahoo.de>
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

In preparation of the upcoming improved routing algorithm the code based has
to be re-organized to allow choosing the routing algorithm at compile time.

Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
---
 net/batman-adv/Makefile         |    1 +
 net/batman-adv/aggregation.c    |   31 --
 net/batman-adv/aggregation.h    |    3 -
 net/batman-adv/bat_iv_ogm.c     |  639 +++++++++++++++++++++++++++++++++++++++
 net/batman-adv/bat_ogm.h        |   30 ++
 net/batman-adv/hard-interface.c |    2 +-
 net/batman-adv/originator.c     |    3 +-
 net/batman-adv/routing.c        |  606 +------------------------------------
 net/batman-adv/routing.h        |   17 +-
 9 files changed, 698 insertions(+), 634 deletions(-)
 create mode 100644 net/batman-adv/bat_iv_ogm.c
 create mode 100644 net/batman-adv/bat_ogm.h

diff --git a/net/batman-adv/Makefile b/net/batman-adv/Makefile
index 2de93d0..3293598 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -21,6 +21,7 @@
 obj-$(CONFIG_BATMAN_ADV) += batman-adv.o
 batman-adv-y += aggregation.o
 batman-adv-y += bat_debugfs.o
+batman-adv-y += bat_iv_ogm.o
 batman-adv-y += bat_sysfs.o
 batman-adv-y += bitarray.o
 batman-adv-y += gateway_client.o
diff --git a/net/batman-adv/aggregation.c b/net/batman-adv/aggregation.c
index f20423f..4716c93 100644
--- a/net/batman-adv/aggregation.c
+++ b/net/batman-adv/aggregation.c
@@ -264,34 +264,3 @@ void add_bat_packet_to_list(struct bat_priv *bat_priv,
 		spin_unlock_bh(&bat_priv->forw_bat_list_lock);
 	}
 }
-
-/* unpack the aggregated packets and process them one by one */
-void receive_aggr_bat_packet(const struct ethhdr *ethhdr,
-			     unsigned char *packet_buff, int packet_len,
-			     struct hard_iface *if_incoming)
-{
-	struct batman_ogm_packet *batman_ogm_packet;
-	int buff_pos = 0;
-	unsigned char *tt_buff;
-
-	batman_ogm_packet = (struct batman_ogm_packet *)packet_buff;
-
-	do {
-		/* network to host order for our 32bit seqno and the
-		   orig_interval */
-		batman_ogm_packet->seqno = ntohl(batman_ogm_packet->seqno);
-		batman_ogm_packet->tt_crc = ntohs(batman_ogm_packet->tt_crc);
-
-		tt_buff = packet_buff + buff_pos + BATMAN_OGM_LEN;
-
-		receive_bat_packet(ethhdr, batman_ogm_packet,
-				   tt_buff, if_incoming);
-
-		buff_pos += BATMAN_OGM_LEN +
-				tt_len(batman_ogm_packet->tt_num_changes);
-
-		batman_ogm_packet = (struct batman_ogm_packet *)
-						(packet_buff + buff_pos);
-	} while (aggregated_packet(buff_pos, packet_len,
-				   batman_ogm_packet->tt_num_changes));
-}
diff --git a/net/batman-adv/aggregation.h b/net/batman-adv/aggregation.h
index 7fc23b0..7a92e4c 100644
--- a/net/batman-adv/aggregation.h
+++ b/net/batman-adv/aggregation.h
@@ -38,8 +38,5 @@ void add_bat_packet_to_list(struct bat_priv *bat_priv,
 			    unsigned char *packet_buff, int packet_len,
 			    struct hard_iface *if_incoming, int own_packet,
 			    unsigned long send_time);
-void receive_aggr_bat_packet(const struct ethhdr *ethhdr,
-			     unsigned char *packet_buff, int packet_len,
-			     struct hard_iface *if_incoming);
 
 #endif /* _NET_BATMAN_ADV_AGGREGATION_H_ */
diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
new file mode 100644
index 0000000..6fa2d46
--- /dev/null
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -0,0 +1,639 @@
+/*
+ * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner, Simon Wunderlich
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#include "main.h"
+#include "bat_ogm.h"
+#include "translation-table.h"
+#include "ring_buffer.h"
+#include "originator.h"
+#include "routing.h"
+#include "gateway_common.h"
+#include "gateway_client.h"
+#include "hard-interface.h"
+#include "send.h"
+
+/* is there another aggregated packet here? */
+static int bat_ogm_aggr_packet(int buff_pos, int packet_len,
+			       int tt_num_changes)
+{
+	int next_buff_pos = buff_pos + BATMAN_OGM_LEN + tt_len(tt_num_changes);
+
+	return (next_buff_pos <= packet_len) &&
+		(next_buff_pos <= MAX_AGGREGATION_BYTES);
+}
+
+static void bat_ogm_orig_update(struct bat_priv *bat_priv,
+				struct orig_node *orig_node,
+				const struct ethhdr *ethhdr,
+				const struct batman_ogm_packet
+							*batman_ogm_packet,
+				struct hard_iface *if_incoming,
+				const unsigned char *tt_buff, int is_duplicate)
+{
+	struct neigh_node *neigh_node = NULL, *tmp_neigh_node = NULL;
+	struct neigh_node *router = NULL;
+	struct orig_node *orig_node_tmp;
+	struct hlist_node *node;
+	uint8_t bcast_own_sum_orig, bcast_own_sum_neigh;
+
+	bat_dbg(DBG_BATMAN, bat_priv, "update_originator(): "
+		"Searching and updating originator entry of received packet\n");
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(tmp_neigh_node, node,
+				 &orig_node->neigh_list, list) {
+		if (compare_eth(tmp_neigh_node->addr, ethhdr->h_source) &&
+		    (tmp_neigh_node->if_incoming == if_incoming) &&
+		     atomic_inc_not_zero(&tmp_neigh_node->refcount)) {
+			if (neigh_node)
+				neigh_node_free_ref(neigh_node);
+			neigh_node = tmp_neigh_node;
+			continue;
+		}
+
+		if (is_duplicate)
+			continue;
+
+		spin_lock_bh(&tmp_neigh_node->tq_lock);
+		ring_buffer_set(tmp_neigh_node->tq_recv,
+				&tmp_neigh_node->tq_index, 0);
+		tmp_neigh_node->tq_avg =
+			ring_buffer_avg(tmp_neigh_node->tq_recv);
+		spin_unlock_bh(&tmp_neigh_node->tq_lock);
+	}
+
+	if (!neigh_node) {
+		struct orig_node *orig_tmp;
+
+		orig_tmp = get_orig_node(bat_priv, ethhdr->h_source);
+		if (!orig_tmp)
+			goto unlock;
+
+		neigh_node = create_neighbor(orig_node, orig_tmp,
+					     ethhdr->h_source, if_incoming);
+
+		orig_node_free_ref(orig_tmp);
+		if (!neigh_node)
+			goto unlock;
+	} else
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Updating existing last-hop neighbor of originator\n");
+
+	rcu_read_unlock();
+
+	orig_node->flags = batman_ogm_packet->flags;
+	neigh_node->last_valid = jiffies;
+
+	spin_lock_bh(&neigh_node->tq_lock);
+	ring_buffer_set(neigh_node->tq_recv,
+			&neigh_node->tq_index,
+			batman_ogm_packet->tq);
+	neigh_node->tq_avg = ring_buffer_avg(neigh_node->tq_recv);
+	spin_unlock_bh(&neigh_node->tq_lock);
+
+	if (!is_duplicate) {
+		orig_node->last_ttl = batman_ogm_packet->ttl;
+		neigh_node->last_ttl = batman_ogm_packet->ttl;
+	}
+
+	bonding_candidate_add(orig_node, neigh_node);
+
+	/* if this neighbor already is our next hop there is nothing
+	 * to change */
+	router = orig_node_get_router(orig_node);
+	if (router == neigh_node)
+		goto update_tt;
+
+	/* if this neighbor does not offer a better TQ we won't consider it */
+	if (router && (router->tq_avg > neigh_node->tq_avg))
+		goto update_tt;
+
+	/* if the TQ is the same and the link not more symmetric we
+	 * won't consider it either */
+	if (router && (neigh_node->tq_avg == router->tq_avg)) {
+		orig_node_tmp = router->orig_node;
+		spin_lock_bh(&orig_node_tmp->ogm_cnt_lock);
+		bcast_own_sum_orig =
+			orig_node_tmp->bcast_own_sum[if_incoming->if_num];
+		spin_unlock_bh(&orig_node_tmp->ogm_cnt_lock);
+
+		orig_node_tmp = neigh_node->orig_node;
+		spin_lock_bh(&orig_node_tmp->ogm_cnt_lock);
+		bcast_own_sum_neigh =
+			orig_node_tmp->bcast_own_sum[if_incoming->if_num];
+		spin_unlock_bh(&orig_node_tmp->ogm_cnt_lock);
+
+		if (bcast_own_sum_orig >= bcast_own_sum_neigh)
+			goto update_tt;
+	}
+
+	update_route(bat_priv, orig_node, neigh_node);
+
+update_tt:
+	/* I have to check for transtable changes only if the OGM has been
+	 * sent through a primary interface */
+	if (((batman_ogm_packet->orig != ethhdr->h_source) &&
+	     (batman_ogm_packet->ttl > 2)) ||
+	    (batman_ogm_packet->flags & PRIMARIES_FIRST_HOP))
+		tt_update_orig(bat_priv, orig_node, tt_buff,
+			       batman_ogm_packet->tt_num_changes,
+			       batman_ogm_packet->ttvn,
+			       batman_ogm_packet->tt_crc);
+
+	if (orig_node->gw_flags != batman_ogm_packet->gw_flags)
+		gw_node_update(bat_priv, orig_node,
+			       batman_ogm_packet->gw_flags);
+
+	orig_node->gw_flags = batman_ogm_packet->gw_flags;
+
+	/* restart gateway selection if fast or late switching was enabled */
+	if ((orig_node->gw_flags) &&
+	    (atomic_read(&bat_priv->gw_mode) == GW_MODE_CLIENT) &&
+	    (atomic_read(&bat_priv->gw_sel_class) > 2))
+		gw_check_election(bat_priv, orig_node);
+
+	goto out;
+
+unlock:
+	rcu_read_unlock();
+out:
+	if (neigh_node)
+		neigh_node_free_ref(neigh_node);
+	if (router)
+		neigh_node_free_ref(router);
+}
+
+static int bat_ogm_calc_tq(struct orig_node *orig_node,
+			   struct orig_node *orig_neigh_node,
+			   struct batman_ogm_packet *batman_ogm_packet,
+			   struct hard_iface *if_incoming)
+{
+	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
+	struct neigh_node *neigh_node = NULL, *tmp_neigh_node;
+	struct hlist_node *node;
+	uint8_t total_count;
+	uint8_t orig_eq_count, neigh_rq_count, tq_own;
+	int tq_asym_penalty, ret = 0;
+
+	/* find corresponding one hop neighbor */
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(tmp_neigh_node, node,
+				 &orig_neigh_node->neigh_list, list) {
+
+		if (!compare_eth(tmp_neigh_node->addr, orig_neigh_node->orig))
+			continue;
+
+		if (tmp_neigh_node->if_incoming != if_incoming)
+			continue;
+
+		if (!atomic_inc_not_zero(&tmp_neigh_node->refcount))
+			continue;
+
+		neigh_node = tmp_neigh_node;
+		break;
+	}
+	rcu_read_unlock();
+
+	if (!neigh_node)
+		neigh_node = create_neighbor(orig_neigh_node,
+					     orig_neigh_node,
+					     orig_neigh_node->orig,
+					     if_incoming);
+
+	if (!neigh_node)
+		goto out;
+
+	/* if orig_node is direct neighbor update neigh_node last_valid */
+	if (orig_node == orig_neigh_node)
+		neigh_node->last_valid = jiffies;
+
+	orig_node->last_valid = jiffies;
+
+	/* find packet count of corresponding one hop neighbor */
+	spin_lock_bh(&orig_node->ogm_cnt_lock);
+	orig_eq_count = orig_neigh_node->bcast_own_sum[if_incoming->if_num];
+	neigh_rq_count = neigh_node->real_packet_count;
+	spin_unlock_bh(&orig_node->ogm_cnt_lock);
+
+	/* pay attention to not get a value bigger than 100 % */
+	total_count = (orig_eq_count > neigh_rq_count ?
+		       neigh_rq_count : orig_eq_count);
+
+	/* if we have too few packets (too less data) we set tq_own to zero */
+	/* if we receive too few packets it is not considered bidirectional */
+	if ((total_count < TQ_LOCAL_BIDRECT_SEND_MINIMUM) ||
+	    (neigh_rq_count < TQ_LOCAL_BIDRECT_RECV_MINIMUM))
+		tq_own = 0;
+	else
+		/* neigh_node->real_packet_count is never zero as we
+		 * only purge old information when getting new
+		 * information */
+		tq_own = (TQ_MAX_VALUE * total_count) /	neigh_rq_count;
+
+	/*
+	 * 1 - ((1-x) ** 3), normalized to TQ_MAX_VALUE this does
+	 * affect the nearly-symmetric links only a little, but
+	 * punishes asymmetric links more.  This will give a value
+	 * between 0 and TQ_MAX_VALUE
+	 */
+	tq_asym_penalty = TQ_MAX_VALUE - (TQ_MAX_VALUE *
+				(TQ_LOCAL_WINDOW_SIZE - neigh_rq_count) *
+				(TQ_LOCAL_WINDOW_SIZE - neigh_rq_count) *
+				(TQ_LOCAL_WINDOW_SIZE - neigh_rq_count)) /
+					(TQ_LOCAL_WINDOW_SIZE *
+					 TQ_LOCAL_WINDOW_SIZE *
+					 TQ_LOCAL_WINDOW_SIZE);
+
+	batman_ogm_packet->tq = ((batman_ogm_packet->tq * tq_own
+							* tq_asym_penalty) /
+						(TQ_MAX_VALUE * TQ_MAX_VALUE));
+
+	bat_dbg(DBG_BATMAN, bat_priv,
+		"bidirectional: "
+		"orig = %-15pM neigh = %-15pM => own_bcast = %2i, "
+		"real recv = %2i, local tq: %3i, asym_penalty: %3i, "
+		"total tq: %3i\n",
+		orig_node->orig, orig_neigh_node->orig, total_count,
+		neigh_rq_count, tq_own,	tq_asym_penalty, batman_ogm_packet->tq);
+
+	/* if link has the minimum required transmission quality
+	 * consider it bidirectional */
+	if (batman_ogm_packet->tq >= TQ_TOTAL_BIDRECT_LIMIT)
+		ret = 1;
+
+out:
+	if (neigh_node)
+		neigh_node_free_ref(neigh_node);
+	return ret;
+}
+
+/* processes a batman packet for all interfaces, adjusts the sequence number and
+ * finds out whether it is a duplicate.
+ * returns:
+ *   1 the packet is a duplicate
+ *   0 the packet has not yet been received
+ *  -1 the packet is old and has been received while the seqno window
+ *     was protected. Caller should drop it.
+ */
+static int bat_ogm_update_seqnos(const struct ethhdr *ethhdr,
+				 const struct batman_ogm_packet
+							*batman_ogm_packet,
+				 const struct hard_iface *if_incoming)
+{
+	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
+	struct orig_node *orig_node;
+	struct neigh_node *tmp_neigh_node;
+	struct hlist_node *node;
+	int is_duplicate = 0;
+	int32_t seq_diff;
+	int need_update = 0;
+	int set_mark, ret = -1;
+
+	orig_node = get_orig_node(bat_priv, batman_ogm_packet->orig);
+	if (!orig_node)
+		return 0;
+
+	spin_lock_bh(&orig_node->ogm_cnt_lock);
+	seq_diff = batman_ogm_packet->seqno - orig_node->last_real_seqno;
+
+	/* signalize caller that the packet is to be dropped. */
+	if (window_protected(bat_priv, seq_diff,
+			     &orig_node->batman_seqno_reset))
+		goto out;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(tmp_neigh_node, node,
+				 &orig_node->neigh_list, list) {
+
+		is_duplicate |= get_bit_status(tmp_neigh_node->real_bits,
+					       orig_node->last_real_seqno,
+					       batman_ogm_packet->seqno);
+
+		if (compare_eth(tmp_neigh_node->addr, ethhdr->h_source) &&
+		    (tmp_neigh_node->if_incoming == if_incoming))
+			set_mark = 1;
+		else
+			set_mark = 0;
+
+		/* if the window moved, set the update flag. */
+		need_update |= bit_get_packet(bat_priv,
+					      tmp_neigh_node->real_bits,
+					      seq_diff, set_mark);
+
+		tmp_neigh_node->real_packet_count =
+			bit_packet_count(tmp_neigh_node->real_bits);
+	}
+	rcu_read_unlock();
+
+	if (need_update) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"updating last_seqno: old %d, new %d\n",
+			orig_node->last_real_seqno, batman_ogm_packet->seqno);
+		orig_node->last_real_seqno = batman_ogm_packet->seqno;
+	}
+
+	ret = is_duplicate;
+
+out:
+	spin_unlock_bh(&orig_node->ogm_cnt_lock);
+	orig_node_free_ref(orig_node);
+	return ret;
+}
+
+static void bat_ogm_process(const struct ethhdr *ethhdr,
+			    struct batman_ogm_packet *batman_ogm_packet,
+			    const unsigned char *tt_buff,
+			    struct hard_iface *if_incoming)
+{
+	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
+	struct hard_iface *hard_iface;
+	struct orig_node *orig_neigh_node, *orig_node;
+	struct neigh_node *router = NULL, *router_router = NULL;
+	struct neigh_node *orig_neigh_router = NULL;
+	int has_directlink_flag;
+	int is_my_addr = 0, is_my_orig = 0, is_my_oldorig = 0;
+	int is_broadcast = 0, is_bidirectional, is_single_hop_neigh;
+	int is_duplicate;
+	uint32_t if_incoming_seqno;
+
+	/* Silently drop when the batman packet is actually not a
+	 * correct packet.
+	 *
+	 * This might happen if a packet is padded (e.g. Ethernet has a
+	 * minimum frame length of 64 byte) and the aggregation interprets
+	 * it as an additional length.
+	 *
+	 * TODO: A more sane solution would be to have a bit in the
+	 * batman_ogm_packet to detect whether the packet is the last
+	 * packet in an aggregation.  Here we expect that the padding
+	 * is always zero (or not 0x01)
+	 */
+	if (batman_ogm_packet->packet_type != BAT_OGM)
+		return;
+
+	/* could be changed by schedule_own_packet() */
+	if_incoming_seqno = atomic_read(&if_incoming->seqno);
+
+	has_directlink_flag = (batman_ogm_packet->flags & DIRECTLINK ? 1 : 0);
+
+	is_single_hop_neigh = (compare_eth(ethhdr->h_source,
+					   batman_ogm_packet->orig) ? 1 : 0);
+
+	bat_dbg(DBG_BATMAN, bat_priv,
+		"Received BATMAN packet via NB: %pM, IF: %s [%pM] "
+		"(from OG: %pM, via prev OG: %pM, seqno %d, ttvn %u, "
+		"crc %u, changes %u, td %d, TTL %d, V %d, IDF %d)\n",
+		ethhdr->h_source, if_incoming->net_dev->name,
+		if_incoming->net_dev->dev_addr, batman_ogm_packet->orig,
+		batman_ogm_packet->prev_sender, batman_ogm_packet->seqno,
+		batman_ogm_packet->ttvn, batman_ogm_packet->tt_crc,
+		batman_ogm_packet->tt_num_changes, batman_ogm_packet->tq,
+		batman_ogm_packet->ttl, batman_ogm_packet->version,
+		has_directlink_flag);
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(hard_iface, &hardif_list, list) {
+		if (hard_iface->if_status != IF_ACTIVE)
+			continue;
+
+		if (hard_iface->soft_iface != if_incoming->soft_iface)
+			continue;
+
+		if (compare_eth(ethhdr->h_source,
+				hard_iface->net_dev->dev_addr))
+			is_my_addr = 1;
+
+		if (compare_eth(batman_ogm_packet->orig,
+				hard_iface->net_dev->dev_addr))
+			is_my_orig = 1;
+
+		if (compare_eth(batman_ogm_packet->prev_sender,
+				hard_iface->net_dev->dev_addr))
+			is_my_oldorig = 1;
+
+		if (is_broadcast_ether_addr(ethhdr->h_source))
+			is_broadcast = 1;
+	}
+	rcu_read_unlock();
+
+	if (batman_ogm_packet->version != COMPAT_VERSION) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Drop packet: incompatible batman version (%i)\n",
+			batman_ogm_packet->version);
+		return;
+	}
+
+	if (is_my_addr) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Drop packet: received my own broadcast (sender: %pM"
+			")\n",
+			ethhdr->h_source);
+		return;
+	}
+
+	if (is_broadcast) {
+		bat_dbg(DBG_BATMAN, bat_priv, "Drop packet: "
+		"ignoring all packets with broadcast source addr (sender: %pM"
+		")\n", ethhdr->h_source);
+		return;
+	}
+
+	if (is_my_orig) {
+		unsigned long *word;
+		int offset;
+
+		orig_neigh_node = get_orig_node(bat_priv, ethhdr->h_source);
+		if (!orig_neigh_node)
+			return;
+
+		/* neighbor has to indicate direct link and it has to
+		 * come via the corresponding interface */
+		/* save packet seqno for bidirectional check */
+		if (has_directlink_flag &&
+		    compare_eth(if_incoming->net_dev->dev_addr,
+				batman_ogm_packet->orig)) {
+			offset = if_incoming->if_num * NUM_WORDS;
+
+			spin_lock_bh(&orig_neigh_node->ogm_cnt_lock);
+			word = &(orig_neigh_node->bcast_own[offset]);
+			bit_mark(word,
+				 if_incoming_seqno -
+						batman_ogm_packet->seqno - 2);
+			orig_neigh_node->bcast_own_sum[if_incoming->if_num] =
+				bit_packet_count(word);
+			spin_unlock_bh(&orig_neigh_node->ogm_cnt_lock);
+		}
+
+		bat_dbg(DBG_BATMAN, bat_priv, "Drop packet: "
+			"originator packet from myself (via neighbor)\n");
+		orig_node_free_ref(orig_neigh_node);
+		return;
+	}
+
+	if (is_my_oldorig) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Drop packet: ignoring all rebroadcast echos (sender: "
+			"%pM)\n", ethhdr->h_source);
+		return;
+	}
+
+	orig_node = get_orig_node(bat_priv, batman_ogm_packet->orig);
+	if (!orig_node)
+		return;
+
+	is_duplicate = bat_ogm_update_seqnos(ethhdr, batman_ogm_packet,
+					     if_incoming);
+
+	if (is_duplicate == -1) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Drop packet: packet within seqno protection time "
+			"(sender: %pM)\n", ethhdr->h_source);
+		goto out;
+	}
+
+	if (batman_ogm_packet->tq == 0) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Drop packet: originator packet with tq equal 0\n");
+		goto out;
+	}
+
+	router = orig_node_get_router(orig_node);
+	if (router)
+		router_router = orig_node_get_router(router->orig_node);
+
+	/* avoid temporary routing loops */
+	if (router && router_router &&
+	    (compare_eth(router->addr, batman_ogm_packet->prev_sender)) &&
+	    !(compare_eth(batman_ogm_packet->orig,
+			  batman_ogm_packet->prev_sender)) &&
+	    (compare_eth(router->addr, router_router->addr))) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Drop packet: ignoring all rebroadcast packets that "
+			"may make me loop (sender: %pM)\n", ethhdr->h_source);
+		goto out;
+	}
+
+	/* if sender is a direct neighbor the sender mac equals
+	 * originator mac */
+	orig_neigh_node = (is_single_hop_neigh ?
+			   orig_node :
+			   get_orig_node(bat_priv, ethhdr->h_source));
+	if (!orig_neigh_node)
+		goto out;
+
+	orig_neigh_router = orig_node_get_router(orig_neigh_node);
+
+	/* drop packet if sender is not a direct neighbor and if we
+	 * don't route towards it */
+	if (!is_single_hop_neigh && (!orig_neigh_router)) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Drop packet: OGM via unknown neighbor!\n");
+		goto out_neigh;
+	}
+
+	is_bidirectional = bat_ogm_calc_tq(orig_node, orig_neigh_node,
+					   batman_ogm_packet, if_incoming);
+
+	bonding_save_primary(orig_node, orig_neigh_node, batman_ogm_packet);
+
+	/* update ranking if it is not a duplicate or has the same
+	 * seqno and similar ttl as the non-duplicate */
+	if (is_bidirectional &&
+	    (!is_duplicate ||
+	     ((orig_node->last_real_seqno == batman_ogm_packet->seqno) &&
+	      (orig_node->last_ttl - 3 <= batman_ogm_packet->ttl))))
+		bat_ogm_orig_update(bat_priv, orig_node, ethhdr,
+				    batman_ogm_packet, if_incoming,
+				    tt_buff, is_duplicate);
+
+	/* is single hop (direct) neighbor */
+	if (is_single_hop_neigh) {
+
+		/* mark direct link on incoming interface */
+		schedule_forward_packet(orig_node, ethhdr, batman_ogm_packet,
+					1, if_incoming);
+
+		bat_dbg(DBG_BATMAN, bat_priv, "Forwarding packet: "
+			"rebroadcast neighbor packet with direct link flag\n");
+		goto out_neigh;
+	}
+
+	/* multihop originator */
+	if (!is_bidirectional) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Drop packet: not received via bidirectional link\n");
+		goto out_neigh;
+	}
+
+	if (is_duplicate) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Drop packet: duplicate packet received\n");
+		goto out_neigh;
+	}
+
+	bat_dbg(DBG_BATMAN, bat_priv,
+		"Forwarding packet: rebroadcast originator packet\n");
+	schedule_forward_packet(orig_node, ethhdr, batman_ogm_packet,
+				0, if_incoming);
+
+out_neigh:
+	if ((orig_neigh_node) && (!is_single_hop_neigh))
+		orig_node_free_ref(orig_neigh_node);
+out:
+	if (router)
+		neigh_node_free_ref(router);
+	if (router_router)
+		neigh_node_free_ref(router_router);
+	if (orig_neigh_router)
+		neigh_node_free_ref(orig_neigh_router);
+
+	orig_node_free_ref(orig_node);
+}
+
+void bat_ogm_receive(const struct ethhdr *ethhdr, unsigned char *packet_buff,
+		     int packet_len, struct hard_iface *if_incoming)
+{
+	struct batman_ogm_packet *batman_ogm_packet;
+	int buff_pos = 0;
+	unsigned char *tt_buff;
+
+	batman_ogm_packet = (struct batman_ogm_packet *)packet_buff;
+
+	/* unpack the aggregated packets and process them one by one */
+	do {
+		/* network to host order for our 32bit seqno and the
+		   orig_interval */
+		batman_ogm_packet->seqno = ntohl(batman_ogm_packet->seqno);
+		batman_ogm_packet->tt_crc = ntohs(batman_ogm_packet->tt_crc);
+
+		tt_buff = packet_buff + buff_pos + BATMAN_OGM_LEN;
+
+		bat_ogm_process(ethhdr, batman_ogm_packet,
+				tt_buff, if_incoming);
+
+		buff_pos += BATMAN_OGM_LEN +
+				tt_len(batman_ogm_packet->tt_num_changes);
+
+		batman_ogm_packet = (struct batman_ogm_packet *)
+						(packet_buff + buff_pos);
+	} while (bat_ogm_aggr_packet(buff_pos, packet_len,
+				     batman_ogm_packet->tt_num_changes));
+}
diff --git a/net/batman-adv/bat_ogm.h b/net/batman-adv/bat_ogm.h
new file mode 100644
index 0000000..bdd3d1e
--- /dev/null
+++ b/net/batman-adv/bat_ogm.h
@@ -0,0 +1,30 @@
+/*
+ * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner, Simon Wunderlich
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ *
+ */
+
+#ifndef _NET_BATMAN_ADV_OGM_H_
+#define _NET_BATMAN_ADV_OGM_H_
+
+#include "main.h"
+
+void bat_ogm_receive(const struct ethhdr *ethhdr, unsigned char *packet_buff,
+		     int packet_len, struct hard_iface *if_incoming);
+
+#endif /* _NET_BATMAN_ADV_OGM_H_ */
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index cf9f4af..cfee017 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -632,7 +632,7 @@ static int batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	switch (batman_ogm_packet->packet_type) {
 		/* batman originator packet */
 	case BAT_OGM:
-		ret = recv_bat_packet(skb, hard_iface);
+		ret = recv_bat_ogm_packet(skb, hard_iface);
 		break;
 
 		/* batman icmp packet */
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index d448018..cd7d256 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -336,8 +336,7 @@ static bool purge_orig_node(struct bat_priv *bat_priv,
 	} else {
 		if (purge_orig_neighbors(bat_priv, orig_node,
 							&best_neigh_node)) {
-			update_routes(bat_priv, orig_node,
-				      best_neigh_node);
+			update_route(bat_priv, orig_node, best_neigh_node);
 		}
 	}
 
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 6efd1d0..f961cc5 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -22,18 +22,14 @@
 #include "main.h"
 #include "routing.h"
 #include "send.h"
-#include "hash.h"
 #include "soft-interface.h"
 #include "hard-interface.h"
 #include "icmp_socket.h"
 #include "translation-table.h"
 #include "originator.h"
-#include "ring_buffer.h"
 #include "vis.h"
-#include "aggregation.h"
-#include "gateway_common.h"
-#include "gateway_client.h"
 #include "unicast.h"
+#include "bat_ogm.h"
 
 void slide_own_bcast_window(struct hard_iface *hard_iface)
 {
@@ -64,9 +60,9 @@ void slide_own_bcast_window(struct hard_iface *hard_iface)
 	}
 }
 
-static void update_route(struct bat_priv *bat_priv,
-			 struct orig_node *orig_node,
-			 struct neigh_node *neigh_node)
+static void _update_route(struct bat_priv *bat_priv,
+			  struct orig_node *orig_node,
+			  struct neigh_node *neigh_node)
 {
 	struct neigh_node *curr_router;
 
@@ -110,8 +106,8 @@ static void update_route(struct bat_priv *bat_priv,
 		neigh_node_free_ref(curr_router);
 }
 
-void update_routes(struct bat_priv *bat_priv, struct orig_node *orig_node,
-		   struct neigh_node *neigh_node)
+void update_route(struct bat_priv *bat_priv, struct orig_node *orig_node,
+		  struct neigh_node *neigh_node)
 {
 	struct neigh_node *router = NULL;
 
@@ -121,117 +117,13 @@ void update_routes(struct bat_priv *bat_priv, struct orig_node *orig_node,
 	router = orig_node_get_router(orig_node);
 
 	if (router != neigh_node)
-		update_route(bat_priv, orig_node, neigh_node);
+		_update_route(bat_priv, orig_node, neigh_node);
 
 out:
 	if (router)
 		neigh_node_free_ref(router);
 }
 
-static int is_bidirectional_neigh(struct orig_node *orig_node,
-				struct orig_node *orig_neigh_node,
-				struct batman_ogm_packet *batman_ogm_packet,
-				struct hard_iface *if_incoming)
-{
-	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
-	struct neigh_node *neigh_node = NULL, *tmp_neigh_node;
-	struct hlist_node *node;
-	uint8_t total_count;
-	uint8_t orig_eq_count, neigh_rq_count, tq_own;
-	int tq_asym_penalty, ret = 0;
-
-	/* find corresponding one hop neighbor */
-	rcu_read_lock();
-	hlist_for_each_entry_rcu(tmp_neigh_node, node,
-				 &orig_neigh_node->neigh_list, list) {
-
-		if (!compare_eth(tmp_neigh_node->addr, orig_neigh_node->orig))
-			continue;
-
-		if (tmp_neigh_node->if_incoming != if_incoming)
-			continue;
-
-		if (!atomic_inc_not_zero(&tmp_neigh_node->refcount))
-			continue;
-
-		neigh_node = tmp_neigh_node;
-		break;
-	}
-	rcu_read_unlock();
-
-	if (!neigh_node)
-		neigh_node = create_neighbor(orig_neigh_node,
-					     orig_neigh_node,
-					     orig_neigh_node->orig,
-					     if_incoming);
-
-	if (!neigh_node)
-		goto out;
-
-	/* if orig_node is direct neighbor update neigh_node last_valid */
-	if (orig_node == orig_neigh_node)
-		neigh_node->last_valid = jiffies;
-
-	orig_node->last_valid = jiffies;
-
-	/* find packet count of corresponding one hop neighbor */
-	spin_lock_bh(&orig_node->ogm_cnt_lock);
-	orig_eq_count = orig_neigh_node->bcast_own_sum[if_incoming->if_num];
-	neigh_rq_count = neigh_node->real_packet_count;
-	spin_unlock_bh(&orig_node->ogm_cnt_lock);
-
-	/* pay attention to not get a value bigger than 100 % */
-	total_count = (orig_eq_count > neigh_rq_count ?
-		       neigh_rq_count : orig_eq_count);
-
-	/* if we have too few packets (too less data) we set tq_own to zero */
-	/* if we receive too few packets it is not considered bidirectional */
-	if ((total_count < TQ_LOCAL_BIDRECT_SEND_MINIMUM) ||
-	    (neigh_rq_count < TQ_LOCAL_BIDRECT_RECV_MINIMUM))
-		tq_own = 0;
-	else
-		/* neigh_node->real_packet_count is never zero as we
-		 * only purge old information when getting new
-		 * information */
-		tq_own = (TQ_MAX_VALUE * total_count) /	neigh_rq_count;
-
-	/*
-	 * 1 - ((1-x) ** 3), normalized to TQ_MAX_VALUE this does
-	 * affect the nearly-symmetric links only a little, but
-	 * punishes asymmetric links more.  This will give a value
-	 * between 0 and TQ_MAX_VALUE
-	 */
-	tq_asym_penalty = TQ_MAX_VALUE - (TQ_MAX_VALUE *
-				(TQ_LOCAL_WINDOW_SIZE - neigh_rq_count) *
-				(TQ_LOCAL_WINDOW_SIZE - neigh_rq_count) *
-				(TQ_LOCAL_WINDOW_SIZE - neigh_rq_count)) /
-					(TQ_LOCAL_WINDOW_SIZE *
-					 TQ_LOCAL_WINDOW_SIZE *
-					 TQ_LOCAL_WINDOW_SIZE);
-
-	batman_ogm_packet->tq = ((batman_ogm_packet->tq * tq_own
-							* tq_asym_penalty) /
-						(TQ_MAX_VALUE * TQ_MAX_VALUE));
-
-	bat_dbg(DBG_BATMAN, bat_priv,
-		"bidirectional: "
-		"orig = %-15pM neigh = %-15pM => own_bcast = %2i, "
-		"real recv = %2i, local tq: %3i, asym_penalty: %3i, "
-		"total tq: %3i\n",
-		orig_node->orig, orig_neigh_node->orig, total_count,
-		neigh_rq_count, tq_own,	tq_asym_penalty, batman_ogm_packet->tq);
-
-	/* if link has the minimum required transmission quality
-	 * consider it bidirectional */
-	if (batman_ogm_packet->tq >= TQ_TOTAL_BIDRECT_LIMIT)
-		ret = 1;
-
-out:
-	if (neigh_node)
-		neigh_node_free_ref(neigh_node);
-	return ret;
-}
-
 /* caller must hold the neigh_list_lock */
 void bonding_candidate_del(struct orig_node *orig_node,
 			   struct neigh_node *neigh_node)
@@ -249,8 +141,8 @@ out:
 	return;
 }
 
-static void bonding_candidate_add(struct orig_node *orig_node,
-				  struct neigh_node *neigh_node)
+void bonding_candidate_add(struct orig_node *orig_node,
+			   struct neigh_node *neigh_node)
 {
 	struct hlist_node *node;
 	struct neigh_node *tmp_neigh_node, *router = NULL;
@@ -320,10 +212,9 @@ out:
 }
 
 /* copy primary address for bonding */
-static void bonding_save_primary(const struct orig_node *orig_node,
-				 struct orig_node *orig_neigh_node,
-				 const struct batman_ogm_packet
-							*batman_ogm_packet)
+void bonding_save_primary(const struct orig_node *orig_node,
+			  struct orig_node *orig_neigh_node,
+			  const struct batman_ogm_packet *batman_ogm_packet)
 {
 	if (!(batman_ogm_packet->flags & PRIMARIES_FIRST_HOP))
 		return;
@@ -331,153 +222,13 @@ static void bonding_save_primary(const struct orig_node *orig_node,
 	memcpy(orig_neigh_node->primary_addr, orig_node->orig, ETH_ALEN);
 }
 
-static void update_orig(struct bat_priv *bat_priv, struct orig_node *orig_node,
-			const struct ethhdr *ethhdr,
-			const struct batman_ogm_packet *batman_ogm_packet,
-			struct hard_iface *if_incoming,
-			const unsigned char *tt_buff, int is_duplicate)
-{
-	struct neigh_node *neigh_node = NULL, *tmp_neigh_node = NULL;
-	struct neigh_node *router = NULL;
-	struct orig_node *orig_node_tmp;
-	struct hlist_node *node;
-	uint8_t bcast_own_sum_orig, bcast_own_sum_neigh;
-
-	bat_dbg(DBG_BATMAN, bat_priv, "update_originator(): "
-		"Searching and updating originator entry of received packet\n");
-
-	rcu_read_lock();
-	hlist_for_each_entry_rcu(tmp_neigh_node, node,
-				 &orig_node->neigh_list, list) {
-		if (compare_eth(tmp_neigh_node->addr, ethhdr->h_source) &&
-		    (tmp_neigh_node->if_incoming == if_incoming) &&
-		     atomic_inc_not_zero(&tmp_neigh_node->refcount)) {
-			if (neigh_node)
-				neigh_node_free_ref(neigh_node);
-			neigh_node = tmp_neigh_node;
-			continue;
-		}
-
-		if (is_duplicate)
-			continue;
-
-		spin_lock_bh(&tmp_neigh_node->tq_lock);
-		ring_buffer_set(tmp_neigh_node->tq_recv,
-				&tmp_neigh_node->tq_index, 0);
-		tmp_neigh_node->tq_avg =
-			ring_buffer_avg(tmp_neigh_node->tq_recv);
-		spin_unlock_bh(&tmp_neigh_node->tq_lock);
-	}
-
-	if (!neigh_node) {
-		struct orig_node *orig_tmp;
-
-		orig_tmp = get_orig_node(bat_priv, ethhdr->h_source);
-		if (!orig_tmp)
-			goto unlock;
-
-		neigh_node = create_neighbor(orig_node, orig_tmp,
-					     ethhdr->h_source, if_incoming);
-
-		orig_node_free_ref(orig_tmp);
-		if (!neigh_node)
-			goto unlock;
-	} else
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Updating existing last-hop neighbor of originator\n");
-
-	rcu_read_unlock();
-
-	orig_node->flags = batman_ogm_packet->flags;
-	neigh_node->last_valid = jiffies;
-
-	spin_lock_bh(&neigh_node->tq_lock);
-	ring_buffer_set(neigh_node->tq_recv,
-			&neigh_node->tq_index,
-			batman_ogm_packet->tq);
-	neigh_node->tq_avg = ring_buffer_avg(neigh_node->tq_recv);
-	spin_unlock_bh(&neigh_node->tq_lock);
-
-	if (!is_duplicate) {
-		orig_node->last_ttl = batman_ogm_packet->ttl;
-		neigh_node->last_ttl = batman_ogm_packet->ttl;
-	}
-
-	bonding_candidate_add(orig_node, neigh_node);
-
-	/* if this neighbor already is our next hop there is nothing
-	 * to change */
-	router = orig_node_get_router(orig_node);
-	if (router == neigh_node)
-		goto update_tt;
-
-	/* if this neighbor does not offer a better TQ we won't consider it */
-	if (router && (router->tq_avg > neigh_node->tq_avg))
-		goto update_tt;
-
-	/* if the TQ is the same and the link not more symmetric we
-	 * won't consider it either */
-	if (router && (neigh_node->tq_avg == router->tq_avg)) {
-		orig_node_tmp = router->orig_node;
-		spin_lock_bh(&orig_node_tmp->ogm_cnt_lock);
-		bcast_own_sum_orig =
-			orig_node_tmp->bcast_own_sum[if_incoming->if_num];
-		spin_unlock_bh(&orig_node_tmp->ogm_cnt_lock);
-
-		orig_node_tmp = neigh_node->orig_node;
-		spin_lock_bh(&orig_node_tmp->ogm_cnt_lock);
-		bcast_own_sum_neigh =
-			orig_node_tmp->bcast_own_sum[if_incoming->if_num];
-		spin_unlock_bh(&orig_node_tmp->ogm_cnt_lock);
-
-		if (bcast_own_sum_orig >= bcast_own_sum_neigh)
-			goto update_tt;
-	}
-
-	update_routes(bat_priv, orig_node, neigh_node);
-
-update_tt:
-	/* I have to check for transtable changes only if the OGM has been
-	 * sent through a primary interface */
-	if (((batman_ogm_packet->orig != ethhdr->h_source) &&
-	     (batman_ogm_packet->ttl > 2)) ||
-	    (batman_ogm_packet->flags & PRIMARIES_FIRST_HOP))
-		tt_update_orig(bat_priv, orig_node, tt_buff,
-			       batman_ogm_packet->tt_num_changes,
-			       batman_ogm_packet->ttvn,
-			       batman_ogm_packet->tt_crc);
-
-	if (orig_node->gw_flags != batman_ogm_packet->gw_flags)
-		gw_node_update(bat_priv, orig_node,
-			       batman_ogm_packet->gw_flags);
-
-	orig_node->gw_flags = batman_ogm_packet->gw_flags;
-
-	/* restart gateway selection if fast or late switching was enabled */
-	if ((orig_node->gw_flags) &&
-	    (atomic_read(&bat_priv->gw_mode) == GW_MODE_CLIENT) &&
-	    (atomic_read(&bat_priv->gw_sel_class) > 2))
-		gw_check_election(bat_priv, orig_node);
-
-	goto out;
-
-unlock:
-	rcu_read_unlock();
-out:
-	if (neigh_node)
-		neigh_node_free_ref(neigh_node);
-	if (router)
-		neigh_node_free_ref(router);
-}
-
 /* checks whether the host restarted and is in the protection time.
  * returns:
  *  0 if the packet is to be accepted
  *  1 if the packet is to be ignored.
  */
-static int window_protected(struct bat_priv *bat_priv,
-			    int32_t seq_num_diff,
-			    unsigned long *last_reset)
+int window_protected(struct bat_priv *bat_priv, int32_t seq_num_diff,
+		     unsigned long *last_reset)
 {
 	if ((seq_num_diff <= -TQ_LOCAL_WINDOW_SIZE)
 		|| (seq_num_diff >= EXPECTED_SEQNO_RANGE)) {
@@ -495,329 +246,7 @@ static int window_protected(struct bat_priv *bat_priv,
 	return 0;
 }
 
-/* processes a batman packet for all interfaces, adjusts the sequence number and
- * finds out whether it is a duplicate.
- * returns:
- *   1 the packet is a duplicate
- *   0 the packet has not yet been received
- *  -1 the packet is old and has been received while the seqno window
- *     was protected. Caller should drop it.
- */
-static int count_real_packets(const struct ethhdr *ethhdr,
-			      const struct batman_ogm_packet *batman_ogm_packet,
-			      const struct hard_iface *if_incoming)
-{
-	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
-	struct orig_node *orig_node;
-	struct neigh_node *tmp_neigh_node;
-	struct hlist_node *node;
-	int is_duplicate = 0;
-	int32_t seq_diff;
-	int need_update = 0;
-	int set_mark, ret = -1;
-
-	orig_node = get_orig_node(bat_priv, batman_ogm_packet->orig);
-	if (!orig_node)
-		return 0;
-
-	spin_lock_bh(&orig_node->ogm_cnt_lock);
-	seq_diff = batman_ogm_packet->seqno - orig_node->last_real_seqno;
-
-	/* signalize caller that the packet is to be dropped. */
-	if (window_protected(bat_priv, seq_diff,
-			     &orig_node->batman_seqno_reset))
-		goto out;
-
-	rcu_read_lock();
-	hlist_for_each_entry_rcu(tmp_neigh_node, node,
-				 &orig_node->neigh_list, list) {
-
-		is_duplicate |= get_bit_status(tmp_neigh_node->real_bits,
-					       orig_node->last_real_seqno,
-					       batman_ogm_packet->seqno);
-
-		if (compare_eth(tmp_neigh_node->addr, ethhdr->h_source) &&
-		    (tmp_neigh_node->if_incoming == if_incoming))
-			set_mark = 1;
-		else
-			set_mark = 0;
-
-		/* if the window moved, set the update flag. */
-		need_update |= bit_get_packet(bat_priv,
-					      tmp_neigh_node->real_bits,
-					      seq_diff, set_mark);
-
-		tmp_neigh_node->real_packet_count =
-			bit_packet_count(tmp_neigh_node->real_bits);
-	}
-	rcu_read_unlock();
-
-	if (need_update) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"updating last_seqno: old %d, new %d\n",
-			orig_node->last_real_seqno, batman_ogm_packet->seqno);
-		orig_node->last_real_seqno = batman_ogm_packet->seqno;
-	}
-
-	ret = is_duplicate;
-
-out:
-	spin_unlock_bh(&orig_node->ogm_cnt_lock);
-	orig_node_free_ref(orig_node);
-	return ret;
-}
-
-void receive_bat_packet(const struct ethhdr *ethhdr,
-			struct batman_ogm_packet *batman_ogm_packet,
-			const unsigned char *tt_buff,
-			struct hard_iface *if_incoming)
-{
-	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
-	struct hard_iface *hard_iface;
-	struct orig_node *orig_neigh_node, *orig_node;
-	struct neigh_node *router = NULL, *router_router = NULL;
-	struct neigh_node *orig_neigh_router = NULL;
-	int has_directlink_flag;
-	int is_my_addr = 0, is_my_orig = 0, is_my_oldorig = 0;
-	int is_broadcast = 0, is_bidirectional, is_single_hop_neigh;
-	int is_duplicate;
-	uint32_t if_incoming_seqno;
-
-	/* Silently drop when the batman packet is actually not a
-	 * correct packet.
-	 *
-	 * This might happen if a packet is padded (e.g. Ethernet has a
-	 * minimum frame length of 64 byte) and the aggregation interprets
-	 * it as an additional length.
-	 *
-	 * TODO: A more sane solution would be to have a bit in the
-	 * batman_ogm_packet to detect whether the packet is the last
-	 * packet in an aggregation.  Here we expect that the padding
-	 * is always zero (or not 0x01)
-	 */
-	if (batman_ogm_packet->packet_type != BAT_OGM)
-		return;
-
-	/* could be changed by schedule_own_packet() */
-	if_incoming_seqno = atomic_read(&if_incoming->seqno);
-
-	has_directlink_flag = (batman_ogm_packet->flags & DIRECTLINK ? 1 : 0);
-
-	is_single_hop_neigh = (compare_eth(ethhdr->h_source,
-					   batman_ogm_packet->orig) ? 1 : 0);
-
-	bat_dbg(DBG_BATMAN, bat_priv,
-		"Received BATMAN packet via NB: %pM, IF: %s [%pM] "
-		"(from OG: %pM, via prev OG: %pM, seqno %d, ttvn %u, "
-		"crc %u, changes %u, td %d, TTL %d, V %d, IDF %d)\n",
-		ethhdr->h_source, if_incoming->net_dev->name,
-		if_incoming->net_dev->dev_addr, batman_ogm_packet->orig,
-		batman_ogm_packet->prev_sender, batman_ogm_packet->seqno,
-		batman_ogm_packet->ttvn, batman_ogm_packet->tt_crc,
-		batman_ogm_packet->tt_num_changes, batman_ogm_packet->tq,
-		batman_ogm_packet->ttl, batman_ogm_packet->version,
-		has_directlink_flag);
-
-	rcu_read_lock();
-	list_for_each_entry_rcu(hard_iface, &hardif_list, list) {
-		if (hard_iface->if_status != IF_ACTIVE)
-			continue;
-
-		if (hard_iface->soft_iface != if_incoming->soft_iface)
-			continue;
-
-		if (compare_eth(ethhdr->h_source,
-				hard_iface->net_dev->dev_addr))
-			is_my_addr = 1;
-
-		if (compare_eth(batman_ogm_packet->orig,
-				hard_iface->net_dev->dev_addr))
-			is_my_orig = 1;
-
-		if (compare_eth(batman_ogm_packet->prev_sender,
-				hard_iface->net_dev->dev_addr))
-			is_my_oldorig = 1;
-
-		if (is_broadcast_ether_addr(ethhdr->h_source))
-			is_broadcast = 1;
-	}
-	rcu_read_unlock();
-
-	if (batman_ogm_packet->version != COMPAT_VERSION) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Drop packet: incompatible batman version (%i)\n",
-			batman_ogm_packet->version);
-		return;
-	}
-
-	if (is_my_addr) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Drop packet: received my own broadcast (sender: %pM"
-			")\n",
-			ethhdr->h_source);
-		return;
-	}
-
-	if (is_broadcast) {
-		bat_dbg(DBG_BATMAN, bat_priv, "Drop packet: "
-		"ignoring all packets with broadcast source addr (sender: %pM"
-		")\n", ethhdr->h_source);
-		return;
-	}
-
-	if (is_my_orig) {
-		unsigned long *word;
-		int offset;
-
-		orig_neigh_node = get_orig_node(bat_priv, ethhdr->h_source);
-		if (!orig_neigh_node)
-			return;
-
-		/* neighbor has to indicate direct link and it has to
-		 * come via the corresponding interface */
-		/* save packet seqno for bidirectional check */
-		if (has_directlink_flag &&
-		    compare_eth(if_incoming->net_dev->dev_addr,
-				batman_ogm_packet->orig)) {
-			offset = if_incoming->if_num * NUM_WORDS;
-
-			spin_lock_bh(&orig_neigh_node->ogm_cnt_lock);
-			word = &(orig_neigh_node->bcast_own[offset]);
-			bit_mark(word,
-				 if_incoming_seqno -
-						batman_ogm_packet->seqno - 2);
-			orig_neigh_node->bcast_own_sum[if_incoming->if_num] =
-				bit_packet_count(word);
-			spin_unlock_bh(&orig_neigh_node->ogm_cnt_lock);
-		}
-
-		bat_dbg(DBG_BATMAN, bat_priv, "Drop packet: "
-			"originator packet from myself (via neighbor)\n");
-		orig_node_free_ref(orig_neigh_node);
-		return;
-	}
-
-	if (is_my_oldorig) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Drop packet: ignoring all rebroadcast echos (sender: "
-			"%pM)\n", ethhdr->h_source);
-		return;
-	}
-
-	orig_node = get_orig_node(bat_priv, batman_ogm_packet->orig);
-	if (!orig_node)
-		return;
-
-	is_duplicate = count_real_packets(ethhdr, batman_ogm_packet,
-					  if_incoming);
-
-	if (is_duplicate == -1) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Drop packet: packet within seqno protection time "
-			"(sender: %pM)\n", ethhdr->h_source);
-		goto out;
-	}
-
-	if (batman_ogm_packet->tq == 0) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Drop packet: originator packet with tq equal 0\n");
-		goto out;
-	}
-
-	router = orig_node_get_router(orig_node);
-	if (router)
-		router_router = orig_node_get_router(router->orig_node);
-
-	/* avoid temporary routing loops */
-	if (router && router_router &&
-	    (compare_eth(router->addr, batman_ogm_packet->prev_sender)) &&
-	    !(compare_eth(batman_ogm_packet->orig,
-			  batman_ogm_packet->prev_sender)) &&
-	    (compare_eth(router->addr, router_router->addr))) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Drop packet: ignoring all rebroadcast packets that "
-			"may make me loop (sender: %pM)\n", ethhdr->h_source);
-		goto out;
-	}
-
-	/* if sender is a direct neighbor the sender mac equals
-	 * originator mac */
-	orig_neigh_node = (is_single_hop_neigh ?
-			   orig_node :
-			   get_orig_node(bat_priv, ethhdr->h_source));
-	if (!orig_neigh_node)
-		goto out;
-
-	orig_neigh_router = orig_node_get_router(orig_neigh_node);
-
-	/* drop packet if sender is not a direct neighbor and if we
-	 * don't route towards it */
-	if (!is_single_hop_neigh && (!orig_neigh_router)) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Drop packet: OGM via unknown neighbor!\n");
-		goto out_neigh;
-	}
-
-	is_bidirectional = is_bidirectional_neigh(orig_node, orig_neigh_node,
-						  batman_ogm_packet,
-						  if_incoming);
-
-	bonding_save_primary(orig_node, orig_neigh_node, batman_ogm_packet);
-
-	/* update ranking if it is not a duplicate or has the same
-	 * seqno and similar ttl as the non-duplicate */
-	if (is_bidirectional &&
-	    (!is_duplicate ||
-	     ((orig_node->last_real_seqno == batman_ogm_packet->seqno) &&
-	      (orig_node->last_ttl - 3 <= batman_ogm_packet->ttl))))
-		update_orig(bat_priv, orig_node, ethhdr, batman_ogm_packet,
-			    if_incoming, tt_buff, is_duplicate);
-
-	/* is single hop (direct) neighbor */
-	if (is_single_hop_neigh) {
-
-		/* mark direct link on incoming interface */
-		schedule_forward_packet(orig_node, ethhdr, batman_ogm_packet,
-					1, if_incoming);
-
-		bat_dbg(DBG_BATMAN, bat_priv, "Forwarding packet: "
-			"rebroadcast neighbor packet with direct link flag\n");
-		goto out_neigh;
-	}
-
-	/* multihop originator */
-	if (!is_bidirectional) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Drop packet: not received via bidirectional link\n");
-		goto out_neigh;
-	}
-
-	if (is_duplicate) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Drop packet: duplicate packet received\n");
-		goto out_neigh;
-	}
-
-	bat_dbg(DBG_BATMAN, bat_priv,
-		"Forwarding packet: rebroadcast originator packet\n");
-	schedule_forward_packet(orig_node, ethhdr, batman_ogm_packet,
-				0, if_incoming);
-
-out_neigh:
-	if ((orig_neigh_node) && (!is_single_hop_neigh))
-		orig_node_free_ref(orig_neigh_node);
-out:
-	if (router)
-		neigh_node_free_ref(router);
-	if (router_router)
-		neigh_node_free_ref(router_router);
-	if (orig_neigh_router)
-		neigh_node_free_ref(orig_neigh_router);
-
-	orig_node_free_ref(orig_node);
-}
-
-int recv_bat_packet(struct sk_buff *skb, struct hard_iface *hard_iface)
+int recv_bat_ogm_packet(struct sk_buff *skb, struct hard_iface *hard_iface)
 {
 	struct ethhdr *ethhdr;
 
@@ -845,10 +274,7 @@ int recv_bat_packet(struct sk_buff *skb, struct hard_iface *hard_iface)
 
 	ethhdr = (struct ethhdr *)skb_mac_header(skb);
 
-	receive_aggr_bat_packet(ethhdr,
-				skb->data,
-				skb_headlen(skb),
-				hard_iface);
+	bat_ogm_receive(ethhdr, skb->data, skb_headlen(skb), hard_iface);
 
 	kfree_skb(skb);
 	return NET_RX_SUCCESS;
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index 893db7f..7aaee0f 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -23,19 +23,15 @@
 #define _NET_BATMAN_ADV_ROUTING_H_
 
 void slide_own_bcast_window(struct hard_iface *hard_iface);
-void receive_bat_packet(const struct ethhdr *ethhdr,
-			struct batman_ogm_packet *batman_ogm_packet,
-			const unsigned char *tt_buff,
-			struct hard_iface *if_incoming);
-void update_routes(struct bat_priv *bat_priv, struct orig_node *orig_node,
-		   struct neigh_node *neigh_node);
+void update_route(struct bat_priv *bat_priv, struct orig_node *orig_node,
+		  struct neigh_node *neigh_node);
 int route_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if);
 int recv_icmp_packet(struct sk_buff *skb, struct hard_iface *recv_if);
 int recv_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if);
 int recv_ucast_frag_packet(struct sk_buff *skb, struct hard_iface *recv_if);
 int recv_bcast_packet(struct sk_buff *skb, struct hard_iface *recv_if);
 int recv_vis_packet(struct sk_buff *skb, struct hard_iface *recv_if);
-int recv_bat_packet(struct sk_buff *skb, struct hard_iface *recv_if);
+int recv_bat_ogm_packet(struct sk_buff *skb, struct hard_iface *recv_if);
 int recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if);
 int recv_roam_adv(struct sk_buff *skb, struct hard_iface *recv_if);
 struct neigh_node *find_router(struct bat_priv *bat_priv,
@@ -43,5 +39,12 @@ struct neigh_node *find_router(struct bat_priv *bat_priv,
 			       const struct hard_iface *recv_if);
 void bonding_candidate_del(struct orig_node *orig_node,
 			   struct neigh_node *neigh_node);
+void bonding_candidate_add(struct orig_node *orig_node,
+			   struct neigh_node *neigh_node);
+void bonding_save_primary(const struct orig_node *orig_node,
+			  struct orig_node *orig_neigh_node,
+			  const struct batman_ogm_packet *batman_ogm_packet);
+int window_protected(struct bat_priv *bat_priv, int32_t seq_num_diff,
+		     unsigned long *last_reset);
 
 #endif /* _NET_BATMAN_ADV_ROUTING_H_ */
-- 
1.7.5.4

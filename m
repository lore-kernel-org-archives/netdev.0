From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 02/20] batman-adv: Prefix bitarray static
	inline functions with batadv_
Date: Mon, 25 Jun 2012 08:54:26 +0200
Message-ID: <1340607284-29950-3-git-send-email-ordex@autistici.org>
References: <1340607284-29950-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1340607284-29950-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
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

From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>

All non-static symbols of batman-adv were prefixed with batadv_ to avoid
collisions with other symbols of the kernel. Other symbols of batman-adv
should use the same prefix to keep the naming scheme consistent.

Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/bat_iv_ogm.c |   13 +++++++------
 net/batman-adv/bitarray.c   |    8 ++++----
 net/batman-adv/bitarray.h   |    6 +++---
 net/batman-adv/routing.c    |    4 ++--
 4 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 94859d4..ad641e8 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -901,9 +901,9 @@ static int bat_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 	hlist_for_each_entry_rcu(tmp_neigh_node, node,
 				 &orig_node->neigh_list, list) {
 
-		is_duplicate |= bat_test_bit(tmp_neigh_node->real_bits,
-					     orig_node->last_real_seqno,
-					     seqno);
+		is_duplicate |= batadv_test_bit(tmp_neigh_node->real_bits,
+						orig_node->last_real_seqno,
+						seqno);
 
 		if (compare_eth(tmp_neigh_node->addr, ethhdr->h_source) &&
 		    (tmp_neigh_node->if_incoming == if_incoming))
@@ -1037,6 +1037,7 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 	if (is_my_orig) {
 		unsigned long *word;
 		int offset;
+		int32_t bit_pos;
 
 		orig_neigh_node = batadv_get_orig_node(bat_priv,
 						       ethhdr->h_source);
@@ -1054,9 +1055,9 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 
 			spin_lock_bh(&orig_neigh_node->ogm_cnt_lock);
 			word = &(orig_neigh_node->bcast_own[offset]);
-			bat_set_bit(word,
-				    if_incoming_seqno -
-					ntohl(batman_ogm_packet->seqno) - 2);
+			bit_pos = if_incoming_seqno - 2;
+			bit_pos -= ntohl(batman_ogm_packet->seqno);
+			batadv_set_bit(word, bit_pos);
 			orig_neigh_node->bcast_own_sum[if_incoming->if_num] =
 				bitmap_weight(word, TQ_LOCAL_WINDOW_SIZE);
 			spin_unlock_bh(&orig_neigh_node->ogm_cnt_lock);
diff --git a/net/batman-adv/bitarray.c b/net/batman-adv/bitarray.c
index 838abbc..7a7065c 100644
--- a/net/batman-adv/bitarray.c
+++ b/net/batman-adv/bitarray.c
@@ -48,7 +48,7 @@ int batadv_bit_get_packet(void *priv, unsigned long *seq_bits,
 	 */
 	if ((seq_num_diff <= 0) && (seq_num_diff > -TQ_LOCAL_WINDOW_SIZE)) {
 		if (set_mark)
-			bat_set_bit(seq_bits, -seq_num_diff);
+			batadv_set_bit(seq_bits, -seq_num_diff);
 		return 0;
 	}
 
@@ -59,7 +59,7 @@ int batadv_bit_get_packet(void *priv, unsigned long *seq_bits,
 		batadv_bitmap_shift_left(seq_bits, seq_num_diff);
 
 		if (set_mark)
-			bat_set_bit(seq_bits, 0);
+			batadv_set_bit(seq_bits, 0);
 		return 1;
 	}
 
@@ -71,7 +71,7 @@ int batadv_bit_get_packet(void *priv, unsigned long *seq_bits,
 			seq_num_diff - 1);
 		bitmap_zero(seq_bits, TQ_LOCAL_WINDOW_SIZE);
 		if (set_mark)
-			bat_set_bit(seq_bits, 0);
+			batadv_set_bit(seq_bits, 0);
 		return 1;
 	}
 
@@ -88,7 +88,7 @@ int batadv_bit_get_packet(void *priv, unsigned long *seq_bits,
 
 		bitmap_zero(seq_bits, TQ_LOCAL_WINDOW_SIZE);
 		if (set_mark)
-			bat_set_bit(seq_bits, 0);
+			batadv_set_bit(seq_bits, 0);
 
 		return 1;
 	}
diff --git a/net/batman-adv/bitarray.h b/net/batman-adv/bitarray.h
index 8ab5426..7954ba8 100644
--- a/net/batman-adv/bitarray.h
+++ b/net/batman-adv/bitarray.h
@@ -23,8 +23,8 @@
 /* returns true if the corresponding bit in the given seq_bits indicates true
  * and curr_seqno is within range of last_seqno
  */
-static inline int bat_test_bit(const unsigned long *seq_bits,
-			       uint32_t last_seqno, uint32_t curr_seqno)
+static inline int batadv_test_bit(const unsigned long *seq_bits,
+				  uint32_t last_seqno, uint32_t curr_seqno)
 {
 	int32_t diff;
 
@@ -36,7 +36,7 @@ static inline int bat_test_bit(const unsigned long *seq_bits,
 }
 
 /* turn corresponding bit on, so we can remember that we got the packet */
-static inline void bat_set_bit(unsigned long *seq_bits, int32_t n)
+static inline void batadv_set_bit(unsigned long *seq_bits, int32_t n)
 {
 	/* if too old, just drop it */
 	if (n < 0 || n >= TQ_LOCAL_WINDOW_SIZE)
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 79f63cf..9c90cce 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -1086,8 +1086,8 @@ int batadv_recv_bcast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	spin_lock_bh(&orig_node->bcast_seqno_lock);
 
 	/* check whether the packet is a duplicate */
-	if (bat_test_bit(orig_node->bcast_bits, orig_node->last_bcast_seqno,
-			 ntohl(bcast_packet->seqno)))
+	if (batadv_test_bit(orig_node->bcast_bits, orig_node->last_bcast_seqno,
+			    ntohl(bcast_packet->seqno)))
 		goto spin_unlock;
 
 	seq_diff = ntohl(bcast_packet->seqno) - orig_node->last_bcast_seqno;
-- 
1.7.9.4

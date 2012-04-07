From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 04/16] batman-adv: Replace bitarray
	operations with bitmap
Date: Sat,  7 Apr 2012 20:49:46 +0200
Message-ID: <1333824598-27771-5-git-send-email-ordex@autistici.org>
References: <1333824598-27771-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1333824598-27771-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
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

bitarray.c consists mostly of functionality that is already available as part
of the standard kernel API. batman-adv could use architecture optimized code
and reduce the binary size by switching to the standard functions.

Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/bat_iv_ogm.c |   15 +++---
 net/batman-adv/bitarray.c   |  118 ++++---------------------------------------
 net/batman-adv/bitarray.h   |   26 +++++++---
 net/batman-adv/main.h       |    2 +-
 net/batman-adv/routing.c    |    6 +--
 net/batman-adv/types.h      |    4 +-
 6 files changed, 41 insertions(+), 130 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index a6d5d63..fab1071 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -850,9 +850,9 @@ static int bat_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 	hlist_for_each_entry_rcu(tmp_neigh_node, node,
 				 &orig_node->neigh_list, list) {
 
-		is_duplicate |= get_bit_status(tmp_neigh_node->real_bits,
-					       orig_node->last_real_seqno,
-					       batman_ogm_packet->seqno);
+		is_duplicate |= bat_test_bit(tmp_neigh_node->real_bits,
+					     orig_node->last_real_seqno,
+					     batman_ogm_packet->seqno);
 
 		if (compare_eth(tmp_neigh_node->addr, ethhdr->h_source) &&
 		    (tmp_neigh_node->if_incoming == if_incoming))
@@ -866,7 +866,8 @@ static int bat_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 					      seq_diff, set_mark);
 
 		tmp_neigh_node->real_packet_count =
-			bit_packet_count(tmp_neigh_node->real_bits);
+			bitmap_weight(tmp_neigh_node->real_bits,
+				      TQ_LOCAL_WINDOW_SIZE);
 	}
 	rcu_read_unlock();
 
@@ -998,11 +999,11 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 
 			spin_lock_bh(&orig_neigh_node->ogm_cnt_lock);
 			word = &(orig_neigh_node->bcast_own[offset]);
-			bit_mark(word,
-				 if_incoming_seqno -
+			bat_set_bit(word,
+				    if_incoming_seqno -
 						batman_ogm_packet->seqno - 2);
 			orig_neigh_node->bcast_own_sum[if_incoming->if_num] =
-				bit_packet_count(word);
+				bitmap_weight(word, TQ_LOCAL_WINDOW_SIZE);
 			spin_unlock_bh(&orig_neigh_node->ogm_cnt_lock);
 		}
 
diff --git a/net/batman-adv/bitarray.c b/net/batman-adv/bitarray.c
index 6d0aa21..07ae6e1 100644
--- a/net/batman-adv/bitarray.c
+++ b/net/batman-adv/bitarray.c
@@ -24,100 +24,13 @@
 
 #include <linux/bitops.h>
 
-/* returns true if the corresponding bit in the given seq_bits indicates true
- * and curr_seqno is within range of last_seqno */
-int get_bit_status(const unsigned long *seq_bits, uint32_t last_seqno,
-		   uint32_t curr_seqno)
-{
-	int32_t diff, word_offset, word_num;
-
-	diff = last_seqno - curr_seqno;
-	if (diff < 0 || diff >= TQ_LOCAL_WINDOW_SIZE) {
-		return 0;
-	} else {
-		/* which word */
-		word_num = (last_seqno - curr_seqno) / WORD_BIT_SIZE;
-		/* which position in the selected word */
-		word_offset = (last_seqno - curr_seqno) % WORD_BIT_SIZE;
-
-		if (test_bit(word_offset, &seq_bits[word_num]))
-			return 1;
-		else
-			return 0;
-	}
-}
-
-/* turn corresponding bit on, so we can remember that we got the packet */
-void bit_mark(unsigned long *seq_bits, int32_t n)
-{
-	int32_t word_offset, word_num;
-
-	/* if too old, just drop it */
-	if (n < 0 || n >= TQ_LOCAL_WINDOW_SIZE)
-		return;
-
-	/* which word */
-	word_num = n / WORD_BIT_SIZE;
-	/* which position in the selected word */
-	word_offset = n % WORD_BIT_SIZE;
-
-	set_bit(word_offset, &seq_bits[word_num]); /* turn the position on */
-}
-
 /* shift the packet array by n places. */
-static void bit_shift(unsigned long *seq_bits, int32_t n)
+static void bat_bitmap_shift_left(unsigned long *seq_bits, int32_t n)
 {
-	int32_t word_offset, word_num;
-	int32_t i;
-
 	if (n <= 0 || n >= TQ_LOCAL_WINDOW_SIZE)
 		return;
 
-	word_offset = n % WORD_BIT_SIZE;/* shift how much inside each word */
-	word_num = n / WORD_BIT_SIZE;	/* shift over how much (full) words */
-
-	for (i = NUM_WORDS - 1; i > word_num; i--) {
-		/* going from old to new, so we don't overwrite the data we copy
-		 * from.
-		 *
-		 * left is high, right is low: FEDC BA98 7654 3210
-		 *					  ^^ ^^
-		 *			       vvvv
-		 * ^^^^ = from, vvvvv =to, we'd have word_num==1 and
-		 * word_offset==WORD_BIT_SIZE/2 ????? in this example.
-		 * (=24 bits)
-		 *
-		 * our desired output would be: 9876 5432 1000 0000
-		 * */
-
-		seq_bits[i] =
-			(seq_bits[i - word_num] << word_offset) +
-			/* take the lower port from the left half, shift it left
-			 * to its final position */
-			(seq_bits[i - word_num - 1] >>
-			 (WORD_BIT_SIZE-word_offset));
-		/* and the upper part of the right half and shift it left to
-		 * its position */
-		/* for our example that would be: word[0] = 9800 + 0076 =
-		 * 9876 */
-	}
-	/* now for our last word, i==word_num, we only have its "left" half.
-	 * that's the 1000 word in our example.*/
-
-	seq_bits[i] = (seq_bits[i - word_num] << word_offset);
-
-	/* pad the rest with 0, if there is anything */
-	i--;
-
-	for (; i >= 0; i--)
-		seq_bits[i] = 0;
-}
-
-static void bit_reset_window(unsigned long *seq_bits)
-{
-	int i;
-	for (i = 0; i < NUM_WORDS; i++)
-		seq_bits[i] = 0;
+	bitmap_shift_left(seq_bits, seq_bits, n, TQ_LOCAL_WINDOW_SIZE);
 }
 
 
@@ -137,7 +50,7 @@ int bit_get_packet(void *priv, unsigned long *seq_bits,
 
 	if ((seq_num_diff <= 0) && (seq_num_diff > -TQ_LOCAL_WINDOW_SIZE)) {
 		if (set_mark)
-			bit_mark(seq_bits, -seq_num_diff);
+			bat_set_bit(seq_bits, -seq_num_diff);
 		return 0;
 	}
 
@@ -145,10 +58,10 @@ int bit_get_packet(void *priv, unsigned long *seq_bits,
 	 * set the mark if required */
 
 	if ((seq_num_diff > 0) && (seq_num_diff < TQ_LOCAL_WINDOW_SIZE)) {
-		bit_shift(seq_bits, seq_num_diff);
+		bat_bitmap_shift_left(seq_bits, seq_num_diff);
 
 		if (set_mark)
-			bit_mark(seq_bits, 0);
+			bat_set_bit(seq_bits, 0);
 		return 1;
 	}
 
@@ -159,9 +72,9 @@ int bit_get_packet(void *priv, unsigned long *seq_bits,
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"We missed a lot of packets (%i) !\n",
 			seq_num_diff - 1);
-		bit_reset_window(seq_bits);
+		bitmap_zero(seq_bits, TQ_LOCAL_WINDOW_SIZE);
 		if (set_mark)
-			bit_mark(seq_bits, 0);
+			bat_set_bit(seq_bits, 0);
 		return 1;
 	}
 
@@ -176,9 +89,9 @@ int bit_get_packet(void *priv, unsigned long *seq_bits,
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Other host probably restarted!\n");
 
-		bit_reset_window(seq_bits);
+		bitmap_zero(seq_bits, TQ_LOCAL_WINDOW_SIZE);
 		if (set_mark)
-			bit_mark(seq_bits, 0);
+			bat_set_bit(seq_bits, 0);
 
 		return 1;
 	}
@@ -186,16 +99,3 @@ int bit_get_packet(void *priv, unsigned long *seq_bits,
 	/* never reached */
 	return 0;
 }
-
-/* count the hamming weight, how many good packets did we receive? just count
- * the 1's.
- */
-int bit_packet_count(const unsigned long *seq_bits)
-{
-	int i, hamming = 0;
-
-	for (i = 0; i < NUM_WORDS; i++)
-		hamming += hweight_long(seq_bits[i]);
-
-	return hamming;
-}
diff --git a/net/batman-adv/bitarray.h b/net/batman-adv/bitarray.h
index c613572..1835c15 100644
--- a/net/batman-adv/bitarray.h
+++ b/net/batman-adv/bitarray.h
@@ -22,23 +22,33 @@
 #ifndef _NET_BATMAN_ADV_BITARRAY_H_
 #define _NET_BATMAN_ADV_BITARRAY_H_
 
-#define WORD_BIT_SIZE (sizeof(unsigned long) * 8)
-
 /* returns true if the corresponding bit in the given seq_bits indicates true
  * and curr_seqno is within range of last_seqno */
-int get_bit_status(const unsigned long *seq_bits, uint32_t last_seqno,
-		   uint32_t curr_seqno);
+static inline int bat_test_bit(const unsigned long *seq_bits,
+			       uint32_t last_seqno, uint32_t curr_seqno)
+{
+	int32_t diff;
+
+	diff = last_seqno - curr_seqno;
+	if (diff < 0 || diff >= TQ_LOCAL_WINDOW_SIZE)
+		return 0;
+	else
+		return  test_bit(diff, seq_bits);
+}
 
 /* turn corresponding bit on, so we can remember that we got the packet */
-void bit_mark(unsigned long *seq_bits, int32_t n);
+static inline void bat_set_bit(unsigned long *seq_bits, int32_t n)
+{
+	/* if too old, just drop it */
+	if (n < 0 || n >= TQ_LOCAL_WINDOW_SIZE)
+		return;
 
+	set_bit(n, seq_bits); /* turn the position on */
+}
 
 /* receive and process one packet, returns 1 if received seq_num is considered
  * new, 0 if old  */
 int bit_get_packet(void *priv, unsigned long *seq_bits,
 		   int32_t seq_num_diff, int set_mark);
 
-/* count the hamming weight, how many good packets did we receive? */
-int bit_packet_count(const unsigned long *seq_bits);
-
 #endif /* _NET_BATMAN_ADV_BITARRAY_H_ */
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 94fa1c2..0a20a19 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -65,7 +65,7 @@
 
 #define NULL_IFINDEX 0 /* dummy ifindex used to avoid iface checks */
 
-#define NUM_WORDS (TQ_LOCAL_WINDOW_SIZE / WORD_BIT_SIZE)
+#define NUM_WORDS BITS_TO_LONGS(TQ_LOCAL_WINDOW_SIZE)
 
 #define LOG_BUF_LEN 8192	  /* has to be a power of 2 */
 
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 7f8e158..b0370e3 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -52,7 +52,7 @@ void slide_own_bcast_window(struct hard_iface *hard_iface)
 
 			bit_get_packet(bat_priv, word, 1, 0);
 			orig_node->bcast_own_sum[hard_iface->if_num] =
-				bit_packet_count(word);
+				bitmap_weight(word, TQ_LOCAL_WINDOW_SIZE);
 			spin_unlock_bh(&orig_node->ogm_cnt_lock);
 		}
 		rcu_read_unlock();
@@ -1047,8 +1047,8 @@ int recv_bcast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	spin_lock_bh(&orig_node->bcast_seqno_lock);
 
 	/* check whether the packet is a duplicate */
-	if (get_bit_status(orig_node->bcast_bits, orig_node->last_bcast_seqno,
-			   ntohl(bcast_packet->seqno)))
+	if (bat_test_bit(orig_node->bcast_bits, orig_node->last_bcast_seqno,
+			 ntohl(bcast_packet->seqno)))
 		goto spin_unlock;
 
 	seq_diff = ntohl(bcast_packet->seqno) - orig_node->last_bcast_seqno;
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 302efb5..24c8a31 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -90,7 +90,7 @@ struct orig_node {
 	bool tt_poss_change;
 	uint32_t last_real_seqno;
 	uint8_t last_ttl;
-	unsigned long bcast_bits[NUM_WORDS];
+	DECLARE_BITMAP(bcast_bits, TQ_LOCAL_WINDOW_SIZE);
 	uint32_t last_bcast_seqno;
 	struct hlist_head neigh_list;
 	struct list_head frag_list;
@@ -132,7 +132,7 @@ struct neigh_node {
 	uint8_t last_ttl;
 	struct list_head bonding_list;
 	unsigned long last_valid;
-	unsigned long real_bits[NUM_WORDS];
+	DECLARE_BITMAP(real_bits, TQ_LOCAL_WINDOW_SIZE);
 	atomic_t refcount;
 	struct rcu_head rcu;
 	struct orig_node *orig_node;
-- 
1.7.9.4

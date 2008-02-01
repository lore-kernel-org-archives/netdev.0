From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH]: TCP + SACK + skb processing latency
Date: Fri, 1 Feb 2008 18:18:02 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0802011756140.31652@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-367280119-1201882682=:31652"
Cc: David Miller <davem@davemloft.net>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47405 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753986AbYBAQSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 11:18:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-367280119-1201882682=:31652
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

Hi all,

Here's an attempt to reduce amount of skb cleanup work TCP with TSO has to 
do after SACKs have arrived.

I'm not on very familiar grounds with TSOed skbs so there likely is much I 
just couldn't take into account. I probably should at least check some 
flag somewhere? (=NETIF_F_SG?). Also the current the length handling and 
potential presence of headers worries me a lot.

I'd appreciate if somebody with more knowledge about skb internals could 
take a look at the relevant parts (mainly skb_shift) and confirm that 
doing all this I'm trying to do is allowed :-).


--
 i.


--
[RFC PATCH] [TCP]: Try to restore large SKBs while SACK processing

During SACK processing, most of the benefits of TSO are eaten by
the SACK blocks that one-by-one fragment SKBs to MSS sized chunks.
Then we're in problems when cleanup work for them has to be done
when a large cumulative ACK comes. Try to return to pre-split
state while more and more SACK info gets discovered.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h    |    5 +
 net/ipv4/tcp_input.c |  206 +++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 209 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 7de4ea3..cdf4468 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1170,6 +1170,11 @@ static inline struct sk_buff *tcp_write_queue_next(struct sock *sk, struct sk_bu
 	return skb->next;
 }
 
+static inline struct sk_buff *tcp_write_queue_prev(struct sock *sk, struct sk_buff *skb)
+{
+	return skb->prev;
+}
+
 #define tcp_for_write_queue(skb, sk)					\
 		for (skb = (sk)->sk_write_queue.next;			\
 		     (skb != (struct sk_buff *)&(sk)->sk_write_queue);	\
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 19c449f..2cb7e86 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1206,6 +1206,8 @@ static int tcp_check_dsack(struct tcp_sock *tp, struct sk_buff *ack_skb,
  * aligned portion of it that matches. Therefore we might need to fragment
  * which may fail and creates some hassle (caller must handle error case
  * returns).
+ *
+ * FIXME: this could be merged to shift decision code
  */
 static int tcp_match_skb_to_sack(struct sock *sk, struct sk_buff *skb,
 				 u32 start_seq, u32 end_seq)
@@ -1322,6 +1324,206 @@ static int tcp_sacktag_one(struct sk_buff *skb, struct sock *sk,
 	return flag;
 }
 
+/* Attempts to shift up to shiftlen worth of bytes from prev to skb.
+ * Returns number bytes shifted.
+ *
+ * TODO: in case the prev runs out of frag space, operation could be
+ * made to return with a partial result (would allow tighter packing).
+ */
+static int skb_shift(struct sk_buff *prev, struct sk_buff *skb,
+		     unsigned int shiftlen)
+{
+	int i, to, merge;
+	unsigned int todo;
+	struct skb_frag_struct *from, *fragto;
+
+	if (skb_cloned(skb) || skb_cloned(prev))
+		return 0;
+
+	todo = shiftlen;
+	i = 0;
+	from = &skb_shinfo(skb)->frags[i];
+	to = skb_shinfo(prev)->nr_frags;
+
+	merge = to - 1;
+	if (!skb_can_coalesce(prev, merge + 1, from->page, from->page_offset))
+		merge = -1;
+	if (merge >= 0) {
+		i++;
+		if (from->size >= shiftlen)
+			goto onlymerge;
+		todo -= from->size;
+	}
+
+	/* Skip full, not-fitting skb to avoid expensive operations */
+	if ((shiftlen == skb->len) &&
+	    (skb_shinfo(skb)->nr_frags - merge) < (MAX_SKB_FRAGS - to))
+		return 0;
+
+	while (todo && (i < skb_shinfo(skb)->nr_frags)) {
+		if (to == MAX_SKB_FRAGS)
+			return 0;
+
+		from = &skb_shinfo(skb)->frags[i];
+		fragto = &skb_shinfo(prev)->frags[to];
+
+		if (todo >= from->size) {
+			*fragto = *from;
+			todo -= from->size;
+			i++;
+			to++;
+
+		} else {
+			fragto->page = from->page;
+			get_page(fragto->page);
+			fragto->page_offset = from->page_offset;
+			fragto->size = todo;
+			from->page_offset += todo;
+			from->size -= todo;
+
+			to++;
+			break;
+		}
+	}
+	skb_shinfo(prev)->nr_frags = to;
+
+	/* Delayed, so that we don't have to undo it */
+	if (merge >= 0) {
+onlymerge:
+		from = &skb_shinfo(skb)->frags[0];
+		skb_shinfo(prev)->frags[merge].size += min(from->size, shiftlen);
+		put_page(from->page);
+	}
+
+	/* Reposition in the original skb */
+	to = 0;
+	while (i < skb_shinfo(skb)->nr_frags)
+		skb_shinfo(skb)->frags[to++] = skb_shinfo(skb)->frags[i++];
+	skb_shinfo(skb)->nr_frags = to;
+
+	/* Yak, is it really working this way? */
+	/* FIXME: should probably handle headers gracefully? */
+	skb->len -= shiftlen;
+	skb->data_len -= shiftlen;
+	skb->truesize -= shiftlen;
+	prev->len += shiftlen;
+	prev->data_len += shiftlen;
+	prev->truesize += shiftlen;
+
+	return shiftlen;
+}
+
+static int tcp_shifted_skb(struct sock *sk,
+			   struct sk_buff *prev, struct sk_buff *skb,
+		           unsigned int pcount, unsigned int shifted)
+{
+	TCP_SKB_CB(prev)->end_seq += shifted;
+	TCP_SKB_CB(skb)->seq -= shifted;
+
+	skb_shinfo(prev)->gso_segs += pcount;
+	skb_shinfo(skb)->gso_segs -= pcount;
+
+	/* FIXME: should adjust _out counters here too, uh-oh, needs to
+	 * split sacktag one to do that then :-)
+	 */
+	/* FIXME: think what to do with timestamps */
+
+	/* FIXME: what about FIN? */
+	if (shifted < skb->len)
+		return 0;
+
+	/* Whole SKB was eaten :-) */
+	tcp_unlink_write_queue(skb, sk);
+	__kfree_skb(skb);
+	return 1;
+}
+
+/* Try collapsing SACK blocks spanning across multiple skbs to a single
+ * skb.
+ */
+static int tcp_shift_skb_data(struct sock *sk, struct sk_buff *skb,
+			      u32 start_seq, u32 end_seq)
+{
+	struct sk_buff *prev;
+	unsigned int mss, len, pcount;
+	int in_sack;
+
+	in_sack = !after(start_seq, TCP_SKB_CB(skb)->seq) &&
+		  !before(end_seq, TCP_SKB_CB(skb)->end_seq);
+	if (in_sack) {
+		len = skb->len;
+		pcount = tcp_skb_pcount(skb);
+	} else {
+		/* CHECKME: This is non-MSS split case only?, this will
+		 * cause skipped skbs due to advancing loop btw, original
+		 * has that feature too
+		 */
+		if (tcp_skb_pcount(skb) <= 1)
+			return 0;
+
+		in_sack = !after(start_seq, TCP_SKB_CB(skb)->seq);
+		if (!in_sack) {
+			/* FIXME: merge to next could be attempted here
+			   if (!after(TCP_SKB_CB(skb)->end_seq, end_seq)) */
+
+			/* THINKME: what to do here, should probably just
+			 * fallback to what was done previously, we could try
+			 * merging non-SACKed ones as well but it probably
+			 * isn't going to buy off because later SACKs might
+			 * again split them.
+			 */
+			goto fallback;
+		}
+
+		len = end_seq - TCP_SKB_CB(skb)->seq;
+
+		/* MSS boundaries should be honoured or else pcount will
+		 * severely break even though it makes things bit trickier,
+		 * optimize 1 MSS common case to avoid divides
+		*/
+		mss = tcp_skb_mss(skb);
+		if (len < mss) {
+			return 0;
+		} else if (len == mss) {
+			pcount = 1;
+		} else {
+			pcount = len / mss;
+			len = pcount * mss;
+		}
+	}
+
+	/* Can only happen with delayed DSACK + discard craziness */
+	if (unlikely(skb == tcp_write_queue_head(sk)))
+		goto fallback;
+	prev = tcp_write_queue_prev(sk, skb);
+	if ((TCP_SKB_CB(prev)->sacked & TCPCB_TAGBITS) != TCPCB_SACKED_ACKED)
+		goto fallback;
+
+	if (!skb_shift(prev, skb, len))
+		goto fallback;
+	if (!tcp_shifted_skb(sk, prev, skb, pcount, len))
+		return 0;
+
+	/* Hole filled allows collapsing with the next as well */
+	if (prev == tcp_write_queue_tail(sk))
+		return 0;
+	skb = tcp_write_queue_next(sk, prev);
+	if (skb == tcp_send_head(sk))
+		return 0;
+	if ((TCP_SKB_CB(skb)->sacked & TCPCB_TAGBITS) != TCPCB_SACKED_ACKED)
+		return 0;
+
+	pcount = tcp_skb_pcount(skb);
+	len = skb->len;
+	if (skb_shift(prev, skb, len))
+		tcp_shifted_skb(sk, prev, skb, pcount, len);
+
+	return 0;
+
+fallback:
+	return tcp_match_skb_to_sack(sk, skb, start_seq, end_seq);
+}
+
 static struct sk_buff *tcp_sacktag_walk(struct sk_buff *skb, struct sock *sk,
 					struct tcp_sack_block *next_dup,
 					u32 start_seq, u32 end_seq,
@@ -1349,8 +1551,8 @@ static struct sk_buff *tcp_sacktag_walk(struct sk_buff *skb, struct sock *sk,
 		}
 
 		if (in_sack <= 0)
-			in_sack = tcp_match_skb_to_sack(sk, skb, start_seq,
-							end_seq);
+			in_sack = tcp_shift_skb_data(sk, skb, start_seq,
+						     end_seq);
 		if (unlikely(in_sack < 0))
 			break;
 
-- 
1.5.2.2

---696243703-367280119-1201882682=:31652--

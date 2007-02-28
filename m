From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/4]: Kill fastpath_{skb,cnt}_hint.
Date: Wed, 28 Feb 2007 11:49:49 -0800 (PST)
Message-ID: <20070228.114949.18302561.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48290
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751853AbXB1Ttu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Feb 2007 14:49:50 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 233CEAE426D
	for <netdev@vger.kernel.org>; Wed, 28 Feb 2007 11:49:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


commit 71b270d966cd42e29eabcd39434c4ad4d33aa2be
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Tue Feb 27 19:28:07 2007 -0800

    [TCP]: Kill fastpath_{skb,cnt}_hint.
    
    Now that we have per-skb fack_counts and an interval
    search mechanism for the retransmit queue, we don't
    need these things any more.
    
    Instead, as we traverse the SACK blocks to tag the
    queue, we use the RB tree to lookup the first SKB
    covering the SACK block by sequence number.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index b73687a..c3f08a5 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -326,9 +326,7 @@ struct tcp_sock {
 	struct sk_buff *scoreboard_skb_hint;
 	struct sk_buff *retransmit_skb_hint;
 	struct sk_buff *forward_skb_hint;
-	struct sk_buff *fastpath_skb_hint;
 
-	int     fastpath_cnt_hint;
 	int     lost_cnt_hint;
 	int     retransmit_cnt_hint;
 	int     forward_cnt_hint;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 80a572b..408f210 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1047,12 +1047,12 @@ static inline void tcp_mib_init(void)
 }
 
 /*from STCP */
-static inline void clear_all_retrans_hints(struct tcp_sock *tp){
+static inline void clear_all_retrans_hints(struct tcp_sock *tp)
+{
 	tp->lost_skb_hint = NULL;
 	tp->scoreboard_skb_hint = NULL;
 	tp->retransmit_skb_hint = NULL;
 	tp->forward_skb_hint = NULL;
-	tp->fastpath_skb_hint = NULL;
 }
 
 /* MD5 Signature */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b919cd7..df69726 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -942,16 +942,14 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 	struct tcp_sock *tp = tcp_sk(sk);
 	unsigned char *ptr = ack_skb->h.raw + TCP_SKB_CB(ack_skb)->sacked;
 	struct tcp_sack_block_wire *sp = (struct tcp_sack_block_wire *)(ptr+2);
-	struct sk_buff *cached_skb;
 	int num_sacks = (ptr[1] - TCPOLEN_SACK_BASE)>>3;
 	int reord = tp->packets_out;
 	int prior_fackets;
 	u32 lost_retrans = 0;
 	int flag = 0;
 	int dup_sack = 0;
-	int cached_fack_count;
+	int fack_count_base;
 	int i;
-	int first_sack_index;
 
 	if (!tp->sacked_out)
 		tp->fackets_out = 0;
@@ -1010,12 +1008,10 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 		tp->recv_sack_cache[i].end_seq = 0;
 	}
 
-	first_sack_index = 0;
 	if (flag)
 		num_sacks = 1;
 	else {
 		int j;
-		tp->fastpath_skb_hint = NULL;
 
 		/* order SACK blocks to allow in order walk of the retrans queue */
 		for (i = num_sacks-1; i > 0; i--) {
@@ -1027,10 +1023,6 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 					tmp = sp[j];
 					sp[j] = sp[j+1];
 					sp[j+1] = tmp;
-
-					/* Track where the first SACK block goes to */
-					if (j == first_sack_index)
-						first_sack_index = j+1;
 				}
 
 			}
@@ -1040,22 +1032,17 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 	/* clear flag as used for different purpose in following code */
 	flag = 0;
 
-	/* Use SACK fastpath hint if valid */
-	cached_skb = tp->fastpath_skb_hint;
-	cached_fack_count = tp->fastpath_cnt_hint;
-	if (!cached_skb) {
-		cached_skb = tcp_write_queue_head(sk);
-		cached_fack_count = 0;
-	}
-
+	fack_count_base = TCP_SKB_CB(tcp_write_queue_head(sk))->fack_count;
 	for (i=0; i<num_sacks; i++, sp++) {
 		struct sk_buff *skb;
 		__u32 start_seq = ntohl(sp->start_seq);
 		__u32 end_seq = ntohl(sp->end_seq);
 		int fack_count;
 
-		skb = cached_skb;
-		fack_count = cached_fack_count;
+		skb = tcp_write_queue_find(sk, start_seq);
+		if (!skb)
+			continue;
+		fack_count = TCP_SKB_CB(skb)->fack_count - fack_count_base;
 
 		/* Event "B" in the comment above. */
 		if (after(end_seq, tp->high_seq))
@@ -1068,13 +1055,6 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 			if (skb == tcp_send_head(sk))
 				break;
 
-			cached_skb = skb;
-			cached_fack_count = fack_count;
-			if (i == first_sack_index) {
-				tp->fastpath_skb_hint = skb;
-				tp->fastpath_cnt_hint = fack_count;
-			}
-
 			/* The retransmission queue is always in order, so
 			 * we can short-circuit the walk early.
 			 */

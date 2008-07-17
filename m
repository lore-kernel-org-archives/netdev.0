From: "Adam Langley" <agl@imperialviolet.org>
Subject: [Resend v2 PATCH 3/3] TCP: Remove redundant checks when setting eff_sacks
Date: Thu, 17 Jul 2008 16:08:10 -0700
Message-ID: <396556a20805301217k293e5718h6bbf02bfe069023@europa>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.224]:13826 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932786AbYGQXJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 19:09:53 -0400
Received: by rv-out-0506.google.com with SMTP id k40so107335rvb.1
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2008 16:09:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove redundant checks when setting eff_sacks and make the number of SACKs a
compile time constant. Now that the options code knows how many SACK blocks can
fit in the header, we don't need to have the SACK code guessing at it.

Signed-off-by: Adam Langley <agl@imperialviolet.org>

---

 include/linux/tcp.h  |    6 ++++++
 net/ipv4/tcp_input.c |   25 ++++++++++---------------
 2 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 07e79bd..2e25573 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -224,6 +224,12 @@ struct tcp_options_received {
 	u16	mss_clamp;	/* Maximal mss, negotiated at connection setup */
 };
 
+/* This is the max number of SACKS that we'll generate and process. It's safe
+ * to increse this, although since:
+ *   size = TCPOLEN_SACK_BASE_ALIGNED (4) + n * TCPOLEN_SACK_PERBLOCK (8)
+ * only four options will fit in a standard TCP header */
+#define TCP_NUM_SACKS 4
+
 struct tcp_request_sock {
 	struct inet_request_sock 	req;
 #ifdef CONFIG_TCP_MD5SIG
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d6ea970..2c9b469 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1416,10 +1416,10 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 	unsigned char *ptr = (skb_transport_header(ack_skb) +
 			      TCP_SKB_CB(ack_skb)->sacked);
 	struct tcp_sack_block_wire *sp_wire = (struct tcp_sack_block_wire *)(ptr+2);
-	struct tcp_sack_block sp[4];
+	struct tcp_sack_block sp[TCP_NUM_SACKS];
 	struct tcp_sack_block *cache;
 	struct sk_buff *skb;
-	int num_sacks = (ptr[1] - TCPOLEN_SACK_BASE) >> 3;
+	int num_sacks = min(TCP_NUM_SACKS, (ptr[1] - TCPOLEN_SACK_BASE) >> 3);
 	int used_sacks;
 	int reord = tp->packets_out;
 	int flag = 0;
@@ -3726,8 +3726,7 @@ static void tcp_dsack_set(struct tcp_sock *tp, u32 seq, u32 end_seq)
 		tp->rx_opt.dsack = 1;
 		tp->duplicate_sack[0].start_seq = seq;
 		tp->duplicate_sack[0].end_seq = end_seq;
-		tp->rx_opt.eff_sacks = min(tp->rx_opt.num_sacks + 1,
-					   4 - tp->rx_opt.tstamp_ok);
+		tp->rx_opt.eff_sacks = tp->rx_opt.num_sacks + 1;
 	}
 }
 
@@ -3780,9 +3779,8 @@ static void tcp_sack_maybe_coalesce(struct tcp_sock *tp)
 			 * Decrease num_sacks.
 			 */
 			tp->rx_opt.num_sacks--;
-			tp->rx_opt.eff_sacks = min(tp->rx_opt.num_sacks +
-						   tp->rx_opt.dsack,
-						   4 - tp->rx_opt.tstamp_ok);
+			tp->rx_opt.eff_sacks = tp->rx_opt.num_sacks +
+					       tp->rx_opt.dsack;
 			for (i = this_sack; i < tp->rx_opt.num_sacks; i++)
 				sp[i] = sp[i + 1];
 			continue;
@@ -3832,7 +3830,7 @@ static void tcp_sack_new_ofo_skb(struct sock *sk, u32 seq, u32 end_seq)
 	 *
 	 * If the sack array is full, forget about the last one.
 	 */
-	if (this_sack >= 4) {
+	if (this_sack >= TCP_NUM_SACKS) {
 		this_sack--;
 		tp->rx_opt.num_sacks--;
 		sp--;
@@ -3845,8 +3843,7 @@ new_sack:
 	sp->start_seq = seq;
 	sp->end_seq = end_seq;
 	tp->rx_opt.num_sacks++;
-	tp->rx_opt.eff_sacks = min(tp->rx_opt.num_sacks + tp->rx_opt.dsack,
-				   4 - tp->rx_opt.tstamp_ok);
+	tp->rx_opt.eff_sacks = tp->rx_opt.num_sacks + tp->rx_opt.dsack;
 }
 
 /* RCV.NXT advances, some SACKs should be eaten. */
@@ -3883,9 +3880,8 @@ static void tcp_sack_remove(struct tcp_sock *tp)
 	}
 	if (num_sacks != tp->rx_opt.num_sacks) {
 		tp->rx_opt.num_sacks = num_sacks;
-		tp->rx_opt.eff_sacks = min(tp->rx_opt.num_sacks +
-					   tp->rx_opt.dsack,
-					   4 - tp->rx_opt.tstamp_ok);
+		tp->rx_opt.eff_sacks = tp->rx_opt.num_sacks +
+				       tp->rx_opt.dsack;
 	}
 }
 
@@ -3964,8 +3960,7 @@ static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 
 	if (tp->rx_opt.dsack) {
 		tp->rx_opt.dsack = 0;
-		tp->rx_opt.eff_sacks = min_t(unsigned int, tp->rx_opt.num_sacks,
-					     4 - tp->rx_opt.tstamp_ok);
+		tp->rx_opt.eff_sacks = tp->rx_opt.num_sacks;
 	}
 
 	/*  Queue data for delivery to the user.

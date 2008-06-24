From: "Adam Langley" <agl@imperialviolet.org>
Subject: [PATCH] Remove options logic from SACK calculations in tcp_input.c
Date: Tue, 24 Jun 2008 15:57:18 -0700
Message-ID: <396556a20805301217k293e5718h6bbf02bfe0683149@europa>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.226]:37254 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750789AbYFXXGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 19:06:49 -0400
Received: by wr-out-0506.google.com with SMTP id 69so2344114wri.5
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2008 16:06:48 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adam Langley <agl@imperialviolet.org>

TCP: Remove options logic from SACK calculations in tcp_input.c

Previously, eff_sacks was set at SACK calculation time to the number of SACKs
that should fit in the options space. This isn't the correct place for options
logic, isn't correct in the face non-timestamp options (i.e. MD5), and is no
longer needed with [1].

Additionally, make the magic number 4 (which is the max number of SACKs that
will fit into 40 bytes) a #define.

[1] http://marc.info/?l=linux-netdev&m=121426260509452&w=2

Signed-off-by: Adam Langley <agl@imperialviolet.org>

---


Note: *don't* apply until *after* "[PATCH] TCP options clean up", referenced
above.


 include/linux/tcp.h  |   13 ++++++++++---
 net/ipv4/tcp_input.c |   25 ++++++++++---------------
 2 files changed, 20 insertions(+), 18 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 18e62e3..20f9e27 100644
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
@@ -331,11 +337,12 @@ struct tcp_sock {
 	u32	write_seq;	/* Tail(+1) of data held in tcp send buffer */
 	u32	pushed_seq;	/* Last pushed seq, required to talk to windows */
 
-/*	SACKs data	*/
+/*	SACKs data. Note that the code requires that these two members be
+ *	sequential, in this order and without padding between */
 	struct tcp_sack_block duplicate_sack[1]; /* D-SACK block */
-	struct tcp_sack_block selective_acks[4]; /* The SACKS themselves*/
+	struct tcp_sack_block selective_acks[TCP_NUM_SACKS];/*SACKS themselves*/
 
-	struct tcp_sack_block recv_sack_cache[4];
+	struct tcp_sack_block recv_sack_cache[TCP_NUM_SACKS];
 
 	struct sk_buff *highest_sack;   /* highest skb with SACK received
 					 * (validity guaranteed only if
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b54d9d3..6aff2fd 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1414,10 +1414,10 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
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
@@ -3664,8 +3664,7 @@ static void tcp_dsack_set(struct tcp_sock *tp, u32 seq, u32 end_seq)
 		tp->rx_opt.dsack = 1;
 		tp->duplicate_sack[0].start_seq = seq;
 		tp->duplicate_sack[0].end_seq = end_seq;
-		tp->rx_opt.eff_sacks = min(tp->rx_opt.num_sacks + 1,
-					   4 - tp->rx_opt.tstamp_ok);
+		tp->rx_opt.eff_sacks = tp->rx_opt.num_sacks + 1;
 	}
 }
 
@@ -3718,9 +3717,8 @@ static void tcp_sack_maybe_coalesce(struct tcp_sock *tp)
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
@@ -3770,7 +3768,7 @@ static void tcp_sack_new_ofo_skb(struct sock *sk, u32 seq, u32 end_seq)
 	 *
 	 * If the sack array is full, forget about the last one.
 	 */
-	if (this_sack >= 4) {
+	if (this_sack >= TCP_NUM_SACKS) {
 		this_sack--;
 		tp->rx_opt.num_sacks--;
 		sp--;
@@ -3783,8 +3781,7 @@ new_sack:
 	sp->start_seq = seq;
 	sp->end_seq = end_seq;
 	tp->rx_opt.num_sacks++;
-	tp->rx_opt.eff_sacks = min(tp->rx_opt.num_sacks + tp->rx_opt.dsack,
-				   4 - tp->rx_opt.tstamp_ok);
+	tp->rx_opt.eff_sacks = tp->rx_opt.num_sacks + tp->rx_opt.dsack;
 }
 
 /* RCV.NXT advances, some SACKs should be eaten. */
@@ -3821,9 +3818,8 @@ static void tcp_sack_remove(struct tcp_sock *tp)
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
 
@@ -3902,8 +3898,7 @@ static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 
 	if (tp->rx_opt.dsack) {
 		tp->rx_opt.dsack = 0;
-		tp->rx_opt.eff_sacks = min_t(unsigned int, tp->rx_opt.num_sacks,
-					     4 - tp->rx_opt.tstamp_ok);
+		tp->rx_opt.eff_sacks = tp->rx_opt.num_sacks;
 	}
 
 	/*  Queue data for delivery to the user.

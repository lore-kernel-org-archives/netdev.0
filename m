From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: [PATCH v2 net-next 2/2] tcp: remove SKBTX_ACK_TSTAMP since it is redundant
Date: Wed, 27 Apr 2016 23:39:01 -0400
Message-ID: <1461814741-848-3-git-send-email-soheil.kdev@gmail.com>
References: <1461814741-848-1-git-send-email-soheil.kdev@gmail.com>
Cc: kafai@fb.com, willemb@google.com, edumazet@google.com,
	ycheng@google.com, ncardwell@google.com,
	Soheil Hassas Yeganeh <soheil@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35632 "EHLO
	mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734AbcD1DjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 23:39:08 -0400
Received: by mail-qk0-f196.google.com with SMTP id b63so4781342qkg.2
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 20:39:07 -0700 (PDT)
In-Reply-To: <1461814741-848-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil@google.com>

The SKBTX_ACK_TSTAMP flag is set in skb_shinfo->tx_flags when
the timestamp of the TCP acknowledgement should be reported on
error queue. Since accessing skb_shinfo is likely to incur a
cache-line miss at the time of receiving the ack, the
txstamp_ack bit was added in tcp_skb_cb, which is set iff
the SKBTX_ACK_TSTAMP flag is set for an skb. This makes
SKBTX_ACK_TSTAMP flag redundant.

Remove the SKBTX_ACK_TSTAMP and instead use the txstamp_ack bit
everywhere.

Note that this frees one bit in shinfo->tx_flags.

Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
Acked-by: Martin KaFai Lau <kafai@fb.com>
Suggested-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/skbuff.h |  6 +-----
 net/ipv4/tcp.c         |  5 +++--
 net/ipv4/tcp_input.c   |  3 +--
 net/ipv4/tcp_output.c  | 17 +++++++++++------
 net/socket.c           |  3 ---
 5 files changed, 16 insertions(+), 18 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index da0ace3..ae30555 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -382,14 +382,10 @@ enum {
 
 	/* generate software time stamp when entering packet scheduling */
 	SKBTX_SCHED_TSTAMP = 1 << 6,
-
-	/* generate software timestamp on peer data acknowledgment */
-	SKBTX_ACK_TSTAMP = 1 << 7,
 };
 
 #define SKBTX_ANY_SW_TSTAMP	(SKBTX_SW_TSTAMP    | \
-				 SKBTX_SCHED_TSTAMP | \
-				 SKBTX_ACK_TSTAMP)
+				 SKBTX_SCHED_TSTAMP)
 #define SKBTX_ANY_TSTAMP	(SKBTX_HW_TSTAMP | SKBTX_ANY_SW_TSTAMP)
 
 /*
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3c542dc..8e05eb6 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -435,9 +435,10 @@ static void tcp_tx_timestamp(struct sock *sk, u16 tsflags, struct sk_buff *skb)
 		struct tcp_skb_cb *tcb = TCP_SKB_CB(skb);
 
 		sock_tx_timestamp(sk, tsflags, &shinfo->tx_flags);
-		if (shinfo->tx_flags & SKBTX_ANY_TSTAMP)
+		if (tsflags & SOF_TIMESTAMPING_TX_ACK)
+			tcb->txstamp_ack = 1;
+		if (tsflags & SOF_TIMESTAMPING_TX_RECORD_MASK)
 			shinfo->tskey = TCP_SKB_CB(skb)->seq + skb->len - 1;
-		tcb->txstamp_ack = !!(shinfo->tx_flags & SKBTX_ACK_TSTAMP);
 	}
 }
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 967520d..2f3fd92 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3087,8 +3087,7 @@ static void tcp_ack_tstamp(struct sock *sk, struct sk_buff *skb,
 		return;
 
 	shinfo = skb_shinfo(skb);
-	if ((shinfo->tx_flags & SKBTX_ACK_TSTAMP) &&
-	    !before(shinfo->tskey, prior_snd_una) &&
+	if (!before(shinfo->tskey, prior_snd_una) &&
 	    before(shinfo->tskey, tcp_sk(sk)->snd_una))
 		__skb_tstamp_tx(skb, NULL, sk, SCM_TSTAMP_ACK);
 }
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 9d3b4b3..ace183c 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1111,11 +1111,17 @@ static void tcp_adjust_pcount(struct sock *sk, const struct sk_buff *skb, int de
 	tcp_verify_left_out(tp);
 }
 
+static bool tcp_has_tx_tstamp(const struct sk_buff *skb)
+{
+	return TCP_SKB_CB(skb)->txstamp_ack ||
+		(skb_shinfo(skb)->tx_flags & SKBTX_ANY_TSTAMP);
+}
+
 static void tcp_fragment_tstamp(struct sk_buff *skb, struct sk_buff *skb2)
 {
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
 
-	if (unlikely(shinfo->tx_flags & SKBTX_ANY_TSTAMP) &&
+	if (unlikely(tcp_has_tx_tstamp(skb)) &&
 	    !before(shinfo->tskey, TCP_SKB_CB(skb2)->seq)) {
 		struct skb_shared_info *shinfo2 = skb_shinfo(skb2);
 		u8 tsflags = shinfo->tx_flags & SKBTX_ANY_TSTAMP;
@@ -2446,13 +2452,12 @@ u32 __tcp_select_window(struct sock *sk)
 void tcp_skb_collapse_tstamp(struct sk_buff *skb,
 			     const struct sk_buff *next_skb)
 {
-	const struct skb_shared_info *next_shinfo = skb_shinfo(next_skb);
-	u8 tsflags = next_shinfo->tx_flags & SKBTX_ANY_TSTAMP;
-
-	if (unlikely(tsflags)) {
+	if (unlikely(tcp_has_tx_tstamp(next_skb))) {
+		const struct skb_shared_info *next_shinfo =
+			skb_shinfo(next_skb);
 		struct skb_shared_info *shinfo = skb_shinfo(skb);
 
-		shinfo->tx_flags |= tsflags;
+		shinfo->tx_flags |= next_shinfo->tx_flags & SKBTX_ANY_TSTAMP;
 		shinfo->tskey = next_shinfo->tskey;
 		TCP_SKB_CB(skb)->txstamp_ack |=
 			TCP_SKB_CB(next_skb)->txstamp_ack;
diff --git a/net/socket.c b/net/socket.c
index 5dbb0bb..7789d79 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -600,9 +600,6 @@ void __sock_tx_timestamp(__u16 tsflags, __u8 *tx_flags)
 	if (tsflags & SOF_TIMESTAMPING_TX_SCHED)
 		flags |= SKBTX_SCHED_TSTAMP;
 
-	if (tsflags & SOF_TIMESTAMPING_TX_ACK)
-		flags |= SKBTX_ACK_TSTAMP;
-
 	*tx_flags = flags;
 }
 EXPORT_SYMBOL(__sock_tx_timestamp);
-- 
2.8.0.rc3.226.g39d4020

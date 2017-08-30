From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 1/2] tcp: Revert "tcp: remove CA_ACK_SLOWPATH"
Date: Wed, 30 Aug 2017 19:24:57 +0200
Message-ID: <20170830172458.18544-2-fw@strlen.de>
References: <20170830172458.18544-1-fw@strlen.de>
Cc: edumazet@google.com, Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:35760 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751955AbdH3RYn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 13:24:43 -0400
In-Reply-To: <20170830172458.18544-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change was a followup to the header prediction removal,
so first revert this as a prerequisite to back out hp removal.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/tcp.h       |  5 +++--
 net/ipv4/tcp_input.c    | 35 +++++++++++++++++++----------------
 net/ipv4/tcp_westwood.c | 31 +++++++++++++++++++++++++++----
 3 files changed, 49 insertions(+), 22 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index c614ff135b66..c546d13ffbca 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -910,8 +910,9 @@ enum tcp_ca_event {
 
 /* Information about inbound ACK, passed to cong_ops->in_ack_event() */
 enum tcp_ca_ack_event_flags {
-	CA_ACK_WIN_UPDATE	= (1 << 0),	/* ACK updated window */
-	CA_ACK_ECE		= (1 << 1),	/* ECE bit is set on ack */
+	CA_ACK_SLOWPATH		= (1 << 0),	/* In slow path processing */
+	CA_ACK_WIN_UPDATE	= (1 << 1),	/* ACK updated window */
+	CA_ACK_ECE		= (1 << 2),	/* ECE bit is set on ack */
 };
 
 /*
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 7616cd76f6f6..a0e436366d31 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3552,7 +3552,6 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	u32 lost = tp->lost;
 	int acked = 0; /* Number of packets newly acked */
 	int rexmit = REXMIT_NONE; /* Flag to (re)transmit to recover losses */
-	u32 ack_ev_flags = 0;
 
 	sack_state.first_sackt = 0;
 	sack_state.rate = &rs;
@@ -3593,26 +3592,30 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	if (flag & FLAG_UPDATE_TS_RECENT)
 		tcp_replace_ts_recent(tp, TCP_SKB_CB(skb)->seq);
 
-	if (ack_seq != TCP_SKB_CB(skb)->end_seq)
-		flag |= FLAG_DATA;
-	else
-		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPPUREACKS);
+	{
+		u32 ack_ev_flags = CA_ACK_SLOWPATH;
 
-	flag |= tcp_ack_update_window(sk, skb, ack, ack_seq);
+		if (ack_seq != TCP_SKB_CB(skb)->end_seq)
+			flag |= FLAG_DATA;
+		else
+			NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPPUREACKS);
 
-	if (TCP_SKB_CB(skb)->sacked)
-		flag |= tcp_sacktag_write_queue(sk, skb, prior_snd_una,
-						&sack_state);
+		flag |= tcp_ack_update_window(sk, skb, ack, ack_seq);
 
-	if (tcp_ecn_rcv_ecn_echo(tp, tcp_hdr(skb))) {
-		flag |= FLAG_ECE;
-		ack_ev_flags = CA_ACK_ECE;
-	}
+		if (TCP_SKB_CB(skb)->sacked)
+			flag |= tcp_sacktag_write_queue(sk, skb, prior_snd_una,
+							&sack_state);
+
+		if (tcp_ecn_rcv_ecn_echo(tp, tcp_hdr(skb))) {
+			flag |= FLAG_ECE;
+			ack_ev_flags |= CA_ACK_ECE;
+		}
 
-	if (flag & FLAG_WIN_UPDATE)
-		ack_ev_flags |= CA_ACK_WIN_UPDATE;
+		if (flag & FLAG_WIN_UPDATE)
+			ack_ev_flags |= CA_ACK_WIN_UPDATE;
 
-	tcp_in_ack_event(sk, ack_ev_flags);
+		tcp_in_ack_event(sk, ack_ev_flags);
+	}
 
 	/* We passed data and got it acked, remove any soft error
 	 * log. Something worked...
diff --git a/net/ipv4/tcp_westwood.c b/net/ipv4/tcp_westwood.c
index e5de84310949..bec9cafbe3f9 100644
--- a/net/ipv4/tcp_westwood.c
+++ b/net/ipv4/tcp_westwood.c
@@ -154,6 +154,24 @@ static inline void update_rtt_min(struct westwood *w)
 }
 
 /*
+ * @westwood_fast_bw
+ * It is called when we are in fast path. In particular it is called when
+ * header prediction is successful. In such case in fact update is
+ * straight forward and doesn't need any particular care.
+ */
+static inline void westwood_fast_bw(struct sock *sk)
+{
+	const struct tcp_sock *tp = tcp_sk(sk);
+	struct westwood *w = inet_csk_ca(sk);
+
+	westwood_update_window(sk);
+
+	w->bk += tp->snd_una - w->snd_una;
+	w->snd_una = tp->snd_una;
+	update_rtt_min(w);
+}
+
+/*
  * @westwood_acked_count
  * This function evaluates cumul_ack for evaluating bk in case of
  * delayed or partial acks.
@@ -205,12 +223,17 @@ static u32 tcp_westwood_bw_rttmin(const struct sock *sk)
 
 static void tcp_westwood_ack(struct sock *sk, u32 ack_flags)
 {
-	struct westwood *w = inet_csk_ca(sk);
+	if (ack_flags & CA_ACK_SLOWPATH) {
+		struct westwood *w = inet_csk_ca(sk);
 
-	westwood_update_window(sk);
-	w->bk += westwood_acked_count(sk);
+		westwood_update_window(sk);
+		w->bk += westwood_acked_count(sk);
 
-	update_rtt_min(w);
+		update_rtt_min(w);
+		return;
+	}
+
+	westwood_fast_bw(sk);
 }
 
 static void tcp_westwood_event(struct sock *sk, enum tcp_ca_event event)
-- 
2.13.0

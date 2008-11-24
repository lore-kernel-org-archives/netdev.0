From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 02/10] tcp: move tcp_simple_retransmit to tcp_input
Date: Mon, 24 Nov 2008 16:50:58 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0811241648010.28566@wrl-59.cs.helsinki.fi>
References: <1227536527-29713-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-3-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1771940622-1227538258=:28566"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37763 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752523AbYKXOvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 09:51:00 -0500
In-Reply-To: <1227536527-29713-3-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1771940622-1227538258=:28566
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 24 Nov 2008, Ilpo Järvinen wrote:

> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -472,8 +472,6 @@ extern void tcp_send_delayed_ack(struct sock *sk);
>  
>  /* tcp_input.c */
>  extern void tcp_cwnd_application_limited(struct sock *sk);
> -extern void tcp_skb_mark_lost_uncond_verify(struct tcp_sock *tp,
> -					    struct sk_buff *skb);
>  
>  /* tcp_timer.c */
>  extern void tcp_init_xmit_timers(struct sock *);

Doh, already noticed I'm missing the to-static counterpart of this.
A fixed patch below...

--
 i.


[PATCHv2 02/10] tcp: move tcp_simple_retransmit to tcp_input

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h     |    2 -
 net/ipv4/tcp_input.c  |   53 ++++++++++++++++++++++++++++++++++++++++++++++++-
 net/ipv4/tcp_output.c |   50 ----------------------------------------------
 3 files changed, 52 insertions(+), 53 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 8f26b28..90b4c3b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -472,8 +472,6 @@ extern void tcp_send_delayed_ack(struct sock *sk);
 
 /* tcp_input.c */
 extern void tcp_cwnd_application_limited(struct sock *sk);
-extern void tcp_skb_mark_lost_uncond_verify(struct tcp_sock *tp,
-					    struct sk_buff *skb);
 
 /* tcp_timer.c */
 extern void tcp_init_xmit_timers(struct sock *);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 097294b..8085704 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1002,7 +1002,8 @@ static void tcp_skb_mark_lost(struct tcp_sock *tp, struct sk_buff *skb)
 	}
 }
 
-void tcp_skb_mark_lost_uncond_verify(struct tcp_sock *tp, struct sk_buff *skb)
+static void tcp_skb_mark_lost_uncond_verify(struct tcp_sock *tp,
+					    struct sk_buff *skb)
 {
 	tcp_verify_retransmit_hint(tp, skb);
 
@@ -2559,6 +2560,56 @@ static void tcp_mtup_probe_success(struct sock *sk, struct sk_buff *skb)
 	tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
 }
 
+/* Do a simple retransmit without using the backoff mechanisms in
+ * tcp_timer. This is used for path mtu discovery.
+ * The socket is already locked here.
+ */
+void tcp_simple_retransmit(struct sock *sk)
+{
+	const struct inet_connection_sock *icsk = inet_csk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct sk_buff *skb;
+	unsigned int mss = tcp_current_mss(sk, 0);
+	u32 prior_lost = tp->lost_out;
+
+	tcp_for_write_queue(skb, sk) {
+		if (skb == tcp_send_head(sk))
+			break;
+		if (skb->len > mss &&
+		    !(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)) {
+			if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS) {
+				TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_RETRANS;
+				tp->retrans_out -= tcp_skb_pcount(skb);
+			}
+			tcp_skb_mark_lost_uncond_verify(tp, skb);
+		}
+	}
+
+	tcp_clear_retrans_hints_partial(tp);
+
+	if (prior_lost == tp->lost_out)
+		return;
+
+	if (tcp_is_reno(tp))
+		tcp_limit_reno_sacked(tp);
+
+	tcp_verify_left_out(tp);
+
+	/* Don't muck with the congestion window here.
+	 * Reason is that we do not increase amount of _data_
+	 * in network, but units changed and effective
+	 * cwnd/ssthresh really reduced now.
+	 */
+	if (icsk->icsk_ca_state != TCP_CA_Loss) {
+		tp->high_seq = tp->snd_nxt;
+		tp->snd_ssthresh = tcp_current_ssthresh(sk);
+		tp->prior_ssthresh = 0;
+		tp->undo_marker = 0;
+		tcp_set_ca_state(sk, TCP_CA_Loss);
+	}
+	tcp_xmit_retransmit_queue(sk);
+}
+
 /* Process an event, which can update packets-in-flight not trivially.
  * Main goal of this function is to calculate new estimate for left_out,
  * taking into account both packets sitting in receiver's buffer and
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 86ef989..c069ecb 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1879,56 +1879,6 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *to,
 	}
 }
 
-/* Do a simple retransmit without using the backoff mechanisms in
- * tcp_timer. This is used for path mtu discovery.
- * The socket is already locked here.
- */
-void tcp_simple_retransmit(struct sock *sk)
-{
-	const struct inet_connection_sock *icsk = inet_csk(sk);
-	struct tcp_sock *tp = tcp_sk(sk);
-	struct sk_buff *skb;
-	unsigned int mss = tcp_current_mss(sk, 0);
-	u32 prior_lost = tp->lost_out;
-
-	tcp_for_write_queue(skb, sk) {
-		if (skb == tcp_send_head(sk))
-			break;
-		if (skb->len > mss &&
-		    !(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)) {
-			if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS) {
-				TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_RETRANS;
-				tp->retrans_out -= tcp_skb_pcount(skb);
-			}
-			tcp_skb_mark_lost_uncond_verify(tp, skb);
-		}
-	}
-
-	tcp_clear_retrans_hints_partial(tp);
-
-	if (prior_lost == tp->lost_out)
-		return;
-
-	if (tcp_is_reno(tp))
-		tcp_limit_reno_sacked(tp);
-
-	tcp_verify_left_out(tp);
-
-	/* Don't muck with the congestion window here.
-	 * Reason is that we do not increase amount of _data_
-	 * in network, but units changed and effective
-	 * cwnd/ssthresh really reduced now.
-	 */
-	if (icsk->icsk_ca_state != TCP_CA_Loss) {
-		tp->high_seq = tp->snd_nxt;
-		tp->snd_ssthresh = tcp_current_ssthresh(sk);
-		tp->prior_ssthresh = 0;
-		tp->undo_marker = 0;
-		tcp_set_ca_state(sk, TCP_CA_Loss);
-	}
-	tcp_xmit_retransmit_queue(sk);
-}
-
 /* This retransmits one SKB.  Policy decisions and retransmit queue
  * state updates are done by the caller.  Returns non-zero if an
  * error occurred which prevented the send.
-- 
1.5.2.2

---696208474-1771940622-1227538258=:28566--

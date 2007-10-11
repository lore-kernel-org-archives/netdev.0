From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 3/6] [TCP]: Convert highest_sack to sk_buff to allow direct access
Date: Thu, 11 Oct 2007 15:21:55 +0300
Message-ID: <11921053182585-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11921053182989-git-send-email-ilpo.jarvinen@helsinki.fi> <11921053181239-git-send-email-ilpo.jarvinen@helsinki.fi> <11921053181212-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, TAKANO Ryousei <takano@axe-inc.co.jp>,
	--cc@cs.helsinki.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34816 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752249AbXJKMWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 08:22:01 -0400
In-Reply-To: <11921053181212-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is going to replace the sack fastpath hint quite soon... :-)

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/tcp.h   |    6 ++++--
 include/net/tcp.h     |   13 +++++++++++++
 net/ipv4/tcp_input.c  |   11 ++++++-----
 net/ipv4/tcp_output.c |   19 ++++++++++---------
 4 files changed, 33 insertions(+), 16 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index c5b94c1..0ec6bb6 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -332,8 +332,10 @@ struct tcp_sock {
=20
 	struct tcp_sack_block_wire recv_sack_cache[4];
=20
-	u32	highest_sack;	/* Start seq of globally highest revd SACK
-				 * (validity guaranteed only if sacked_out > 0) */
+	struct sk_buff *highest_sack;   /* highest skb with SACK received
+					 * (validity guaranteed only if
+					 * sacked_out > 0)
+					 */
=20
 	/* from STCP, retrans queue hinting */
 	struct sk_buff* lost_skb_hint;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 92049e6..aead90a 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1306,6 +1306,19 @@ static inline int tcp_write_queue_empty(struct s=
ock *sk)
 	return skb_queue_empty(&sk->sk_write_queue);
 }
=20
+/* Start sequence of the highest skb with SACKed bit, valid only if
+ * sacked > 0 or when the caller has ensured validity by itself.
+ */
+static inline u32 tcp_highest_sack_seq(struct sock *sk)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+
+	if (WARN_ON(!tp->sacked_out &&
+	    tp->highest_sack !=3D tcp_write_queue_head(sk)))
+		return tp->snd_una;
+	return TCP_SKB_CB(tp->highest_sack)->seq;
+}
+
 /* /proc */
 enum tcp_seq_states {
 	TCP_SEQ_STATE_LISTENING,
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9d3d390..39d6a6a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1238,10 +1238,11 @@ int tcp_match_skb_to_sack(struct sock *sk, stru=
ct sk_buff *skb,
 	return in_sack;
 }
=20
-static void tcp_sacktag_one(struct sk_buff *skb, struct tcp_sock *tp,
+static void tcp_sacktag_one(struct sk_buff *skb, struct sock *sk,
 			    struct tcp_sacktag_state *state, int in_sack,
 			    int dup_sack, int fack_count, u32 end_seq)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	u8 sacked =3D TCP_SKB_CB(skb)->sacked;
=20
 	/* Account D-SACK for retransmitted packet. */
@@ -1321,8 +1322,8 @@ static void tcp_sacktag_one(struct sk_buff *skb, =
struct tcp_sock *tp,
 		if (fack_count > tp->fackets_out)
 			tp->fackets_out =3D fack_count;
=20
-		if (after(TCP_SKB_CB(skb)->seq, tp->highest_sack)) {
-			tp->highest_sack =3D TCP_SKB_CB(skb)->seq;
+		if (after(TCP_SKB_CB(skb)->seq, tcp_highest_sack_seq(sk))) {
+			tp->highest_sack =3D skb;
 			state->highest_sack_end_seq =3D TCP_SKB_CB(skb)->end_seq;
 		}
 	} else {
@@ -1363,7 +1364,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 	if (!tp->sacked_out) {
 		if (WARN_ON(tp->fackets_out))
 			tp->fackets_out =3D 0;
-		tp->highest_sack =3D tp->snd_una;
+		tp->highest_sack =3D tcp_write_queue_head(sk);
 	}
=20
 	found_dup_sack =3D tcp_check_dsack(tp, ack_skb, sp, num_sacks, prior_=
snd_una);
@@ -1497,7 +1498,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
=20
 			fack_count +=3D tcp_skb_pcount(skb);
=20
-			tcp_sacktag_one(skb, tp, &state, in_sack,
+			tcp_sacktag_one(skb, sk, &state, in_sack,
 					dup_sack, fack_count, end_seq);
 		}
 	}
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 324b420..9603de8 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -657,13 +657,15 @@ static void tcp_set_skb_tso_segs(struct sock *sk,=
 struct sk_buff *skb, unsigned
  * tweak SACK fastpath hint too as it would overwrite all changes unle=
ss
  * hint is also changed.
  */
-static void tcp_adjust_fackets_out(struct tcp_sock *tp, struct sk_buff=
 *skb,
+static void tcp_adjust_fackets_out(struct sock *sk, struct sk_buff *sk=
b,
 				   int decr)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
+
 	if (!tp->sacked_out || tcp_is_reno(tp))
 		return;
=20
-	if (!before(tp->highest_sack, TCP_SKB_CB(skb)->seq))
+	if (!before(tcp_highest_sack_seq(sk), TCP_SKB_CB(skb)->seq))
 		tp->fackets_out -=3D decr;
=20
 	/* cnt_hint is "off-by-one" compared with fackets_out (see sacktag) *=
/
@@ -712,9 +714,8 @@ int tcp_fragment(struct sock *sk, struct sk_buff *s=
kb, u32 len, unsigned int mss
 	TCP_SKB_CB(buff)->end_seq =3D TCP_SKB_CB(skb)->end_seq;
 	TCP_SKB_CB(skb)->end_seq =3D TCP_SKB_CB(buff)->seq;
=20
-	if (tcp_is_sack(tp) && tp->sacked_out &&
-	    (TCP_SKB_CB(skb)->seq =3D=3D tp->highest_sack))
-		tp->highest_sack =3D TCP_SKB_CB(buff)->seq;
+	if (tcp_is_sack(tp) && tp->sacked_out && (skb =3D=3D tp->highest_sack=
))
+		tp->highest_sack =3D buff;
=20
 	/* PSH and FIN should only be set in the second packet. */
 	flags =3D TCP_SKB_CB(skb)->flags;
@@ -772,7 +773,7 @@ int tcp_fragment(struct sock *sk, struct sk_buff *s=
kb, u32 len, unsigned int mss
 			tcp_dec_pcount_approx_int(&tp->sacked_out, diff);
 			tcp_verify_left_out(tp);
 		}
-		tcp_adjust_fackets_out(tp, skb, diff);
+		tcp_adjust_fackets_out(sk, skb, diff);
 	}
=20
 	/* Link BUFF into the send queue. */
@@ -1720,7 +1721,7 @@ static void tcp_retrans_try_collapse(struct sock =
*sk, struct sk_buff *skb, int m
 		       tcp_skb_pcount(next_skb) !=3D 1);
=20
 		if (WARN_ON(tcp_is_sack(tp) && tp->sacked_out &&
-		    (TCP_SKB_CB(next_skb)->seq =3D=3D tp->highest_sack)))
+		    (next_skb =3D=3D tp->highest_sack)))
 			return;
=20
 		/* Ok.	We will be able to collapse the packet. */
@@ -1755,7 +1756,7 @@ static void tcp_retrans_try_collapse(struct sock =
*sk, struct sk_buff *skb, int m
 		if (tcp_is_reno(tp) && tp->sacked_out)
 			tcp_dec_pcount_approx(&tp->sacked_out, next_skb);
=20
-		tcp_adjust_fackets_out(tp, next_skb, tcp_skb_pcount(next_skb));
+		tcp_adjust_fackets_out(sk, next_skb, tcp_skb_pcount(next_skb));
 		tp->packets_out -=3D tcp_skb_pcount(next_skb);
=20
 		/* changed transmit queue under us so clear hints */
@@ -2036,7 +2037,7 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 			break;
 		tp->forward_skb_hint =3D skb;
=20
-		if (after(TCP_SKB_CB(skb)->seq, tp->highest_sack))
+		if (after(TCP_SKB_CB(skb)->seq, tcp_highest_sack_seq(sk)))
 			break;
=20
 		if (tcp_packets_in_flight(tp) >=3D tp->snd_cwnd)
--=20
1.5.0.6


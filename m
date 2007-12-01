From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 11/21] [TCP]: Abstract tp->highest_sack accessing & point to next skb
Date: Sun,  2 Dec 2007 00:48:06 +0200
Message-ID: <11965492961234-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11965492963603-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492964079-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296202-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296278-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961750-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296588-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962509-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962214-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492963057-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296324-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962283-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47544 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753280AbXLAWsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 17:48:22 -0500
In-Reply-To: <11965492962283-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

Pointing to the next skb is necessary to avoid referencing
already SACKed skbs which will soon be on a separate list.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h     |   35 ++++++++++++++++++++++++++++++++++-
 net/ipv4/tcp_input.c  |   27 +++++++++++++++------------
 net/ipv4/tcp_output.c |   11 +++--------
 3 files changed, 52 insertions(+), 21 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 6e392ba..5ec1cac 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1267,8 +1267,12 @@ static inline void tcp_add_write_queue_tail(stru=
ct sock *sk, struct sk_buff *skb
 	__tcp_add_write_queue_tail(sk, skb);
=20
 	/* Queue it, remembering where we must start sending. */
-	if (sk->sk_send_head =3D=3D NULL)
+	if (sk->sk_send_head =3D=3D NULL) {
 		sk->sk_send_head =3D skb;
+
+		if (tcp_sk(sk)->highest_sack =3D=3D NULL)
+			tcp_sk(sk)->highest_sack =3D skb;
+	}
 }
=20
 static inline void __tcp_add_write_queue_head(struct sock *sk, struct =
sk_buff *skb)
@@ -1318,9 +1322,38 @@ static inline u32 tcp_highest_sack_seq(struct tc=
p_sock *tp)
 {
 	if (!tp->sacked_out)
 		return tp->snd_una;
+
+	if (tp->highest_sack =3D=3D NULL)
+		return tp->snd_nxt;
+
 	return TCP_SKB_CB(tp->highest_sack)->seq;
 }
=20
+static inline void tcp_advance_highest_sack(struct sock *sk, struct sk=
_buff *skb)
+{
+	tcp_sk(sk)->highest_sack =3D tcp_skb_is_last(sk, skb) ? NULL :
+						tcp_write_queue_next(sk, skb);
+}
+
+static inline struct sk_buff *tcp_highest_sack(struct sock *sk)
+{
+	return tcp_sk(sk)->highest_sack;
+}
+
+static inline void tcp_highest_sack_reset(struct sock *sk)
+{
+	tcp_sk(sk)->highest_sack =3D tcp_write_queue_head(sk);
+}
+
+/* Called when old skb is about to be deleted (to be combined with new=
 skb) */
+static inline void tcp_highest_sack_combine(struct sock *sk,
+					    struct sk_buff *old,
+					    struct sk_buff *new)
+{
+	if (tcp_sk(sk)->sacked_out && (old =3D=3D tcp_sk(sk)->highest_sack))
+		tcp_sk(sk)->highest_sack =3D new;
+}
+
 /* /proc */
 enum tcp_seq_states {
 	TCP_SEQ_STATE_LISTENING,
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a43c897..35753b7 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1125,7 +1125,7 @@ static void tcp_mark_lost_retrans(struct sock *sk=
)
 	struct sk_buff *skb;
 	int cnt =3D 0;
 	u32 new_low_seq =3D tp->snd_nxt;
-	u32 received_upto =3D TCP_SKB_CB(tp->highest_sack)->end_seq;
+	u32 received_upto =3D tcp_highest_sack_seq(tp);
=20
 	if (!tcp_is_fack(tp) || !tp->retrans_out ||
 	    !after(received_upto, tp->lost_retrans_low) ||
@@ -1236,9 +1236,10 @@ static int tcp_match_skb_to_sack(struct sock *sk=
, struct sk_buff *skb,
 	return in_sack;
 }
=20
-static int tcp_sacktag_one(struct sk_buff *skb, struct tcp_sock *tp,
+static int tcp_sacktag_one(struct sk_buff *skb, struct sock *sk,
 			   int *reord, int dup_sack, int fack_count)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	u8 sacked =3D TCP_SKB_CB(skb)->sacked;
 	int flag =3D 0;
=20
@@ -1307,8 +1308,8 @@ static int tcp_sacktag_one(struct sk_buff *skb, s=
truct tcp_sock *tp,
 		if (fack_count > tp->fackets_out)
 			tp->fackets_out =3D fack_count;
=20
-		if (after(TCP_SKB_CB(skb)->seq, tcp_highest_sack_seq(tp)))
-			tp->highest_sack =3D skb;
+		if (!before(TCP_SKB_CB(skb)->seq, tcp_highest_sack_seq(tp)))
+			tcp_advance_highest_sack(sk, skb);
 	}
=20
 	/* D-SACK. We can detect redundant retransmission in S|R and plain R
@@ -1330,8 +1331,6 @@ static struct sk_buff *tcp_sacktag_walk(struct sk=
_buff *skb, struct sock *sk,
 					int dup_sack_in, int *fack_count,
 					int *reord, int *flag)
 {
-	struct tcp_sock *tp =3D tcp_sk(sk);
-
 	tcp_for_write_queue_from(skb, sk) {
 		int in_sack =3D 0;
 		int dup_sack =3D dup_sack_in;
@@ -1358,7 +1357,7 @@ static struct sk_buff *tcp_sacktag_walk(struct sk=
_buff *skb, struct sock *sk,
 			break;
=20
 		if (in_sack)
-			*flag |=3D tcp_sacktag_one(skb, tp, reord, dup_sack, *fack_count);
+			*flag |=3D tcp_sacktag_one(skb, sk, reord, dup_sack, *fack_count);
=20
 		*fack_count +=3D tcp_skb_pcount(skb);
 	}
@@ -1429,7 +1428,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 	if (!tp->sacked_out) {
 		if (WARN_ON(tp->fackets_out))
 			tp->fackets_out =3D 0;
-		tp->highest_sack =3D tcp_write_queue_head(sk);
+		tcp_highest_sack_reset(sk);
 	}
=20
 	found_dup_sack =3D tcp_check_dsack(tp, ack_skb, sp_wire,
@@ -1552,9 +1551,11 @@ tcp_sacktag_write_queue(struct sock *sk, struct =
sk_buff *ack_skb, u32 prior_snd_
 						       &fack_count, &reord, &flag);
=20
 			/* ...tail remains todo... */
-			if (TCP_SKB_CB(tp->highest_sack)->end_seq =3D=3D cache->end_seq) {
+			if (tcp_highest_sack_seq(tp) =3D=3D cache->end_seq) {
 				/* ...but better entrypoint exists! */
-				skb =3D tcp_write_queue_next(sk, tp->highest_sack);
+				skb =3D tcp_highest_sack(sk);
+				if (skb =3D=3D NULL)
+					break;
 				fack_count =3D tp->fackets_out;
 				cache++;
 				goto walk;
@@ -1566,8 +1567,10 @@ tcp_sacktag_write_queue(struct sock *sk, struct =
sk_buff *ack_skb, u32 prior_snd_
 			continue;
 		}
=20
-		if (tp->sacked_out && !before(start_seq, tcp_highest_sack_seq(tp))) =
{
-			skb =3D tcp_write_queue_next(sk, tp->highest_sack);
+		if (!before(start_seq, tcp_highest_sack_seq(tp))) {
+			skb =3D tcp_highest_sack(sk);
+			if (skb =3D=3D NULL)
+				break;
 			fack_count =3D tp->fackets_out;
 		}
 		skb =3D tcp_sacktag_skip(skb, sk, start_seq);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 4f2bd70..07907ce 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -667,7 +667,7 @@ static void tcp_adjust_fackets_out(struct sock *sk,=
 struct sk_buff *skb,
 	if (!tp->sacked_out || tcp_is_reno(tp))
 		return;
=20
-	if (!before(tcp_highest_sack_seq(tp), TCP_SKB_CB(skb)->seq))
+	if (after(tcp_highest_sack_seq(tp), TCP_SKB_CB(skb)->seq))
 		tp->fackets_out -=3D decr;
 }
=20
@@ -711,9 +711,6 @@ int tcp_fragment(struct sock *sk, struct sk_buff *s=
kb, u32 len, unsigned int mss
 	TCP_SKB_CB(buff)->end_seq =3D TCP_SKB_CB(skb)->end_seq;
 	TCP_SKB_CB(skb)->end_seq =3D TCP_SKB_CB(buff)->seq;
=20
-	if (tcp_is_sack(tp) && tp->sacked_out && (skb =3D=3D tp->highest_sack=
))
-		tp->highest_sack =3D buff;
-
 	/* PSH and FIN should only be set in the second packet. */
 	flags =3D TCP_SKB_CB(skb)->flags;
 	TCP_SKB_CB(skb)->flags =3D flags & ~(TCPCB_FLAG_FIN|TCPCB_FLAG_PSH);
@@ -1708,9 +1705,7 @@ static void tcp_retrans_try_collapse(struct sock =
*sk, struct sk_buff *skb, int m
 		BUG_ON(tcp_skb_pcount(skb) !=3D 1 ||
 		       tcp_skb_pcount(next_skb) !=3D 1);
=20
-		if (WARN_ON(tcp_is_sack(tp) && tp->sacked_out &&
-		    (next_skb =3D=3D tp->highest_sack)))
-			return;
+		tcp_highest_sack_combine(sk, next_skb, skb);
=20
 		/* Ok.	We will be able to collapse the packet. */
 		tcp_unlink_write_queue(next_skb, sk);
@@ -2020,7 +2015,7 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 			break;
 		tp->forward_skb_hint =3D skb;
=20
-		if (after(TCP_SKB_CB(skb)->seq, tcp_highest_sack_seq(tp)))
+		if (!before(TCP_SKB_CB(skb)->seq, tcp_highest_sack_seq(tp)))
 			break;
=20
 		if (tcp_packets_in_flight(tp) >=3D tp->snd_cwnd)
--=20
1.5.0.6


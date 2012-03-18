From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next 1/2] tcp: introduce tcp_data_queue_ofo
Date: Sun, 18 Mar 2012 14:06:44 -0700
Message-ID: <1332104804.3597.0.camel@edumazet-laptop>
References: <1332077854.3722.52.camel@edumazet-laptop>
	 <CADVnQy=_Adr9xTd=7aUFT6m38YQ8V-V7KQc9c6L4nej-dfvekQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:62974 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753717Ab2CRVGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2012 17:06:49 -0400
Received: by dajr28 with SMTP id r28so8895172daj.19
        for <netdev@vger.kernel.org>; Sun, 18 Mar 2012 14:06:48 -0700 (PDT)
In-Reply-To: <CADVnQy=_Adr9xTd=7aUFT6m38YQ8V-V7KQc9c6L4nej-dfvekQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split tcp_data_queue() in two parts for better readability.

tcp_data_queue_ofo() is responsible for queueing incoming skb into out
of order queue.

Change code layout so that the skb_set_owner_r() is performed only if
skb is not dropped.

This is a preliminary patch before "reduce out_of_order memory use"
following patch.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: H.K. Jerry Chu <hkchu@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |  214 ++++++++++++++++++++++-------------------
 1 file changed, 115 insertions(+), 99 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 68d4057..fa7de12 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4446,6 +4446,120 @@ static inline int tcp_try_rmem_schedule(struct =
sock *sk, unsigned int size)
 	return 0;
 }
=20
+static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	struct sk_buff *skb1;
+	u32 seq, end_seq;
+
+	TCP_ECN_check_ce(tp, skb);
+
+	if (tcp_try_rmem_schedule(sk, skb->truesize)) {
+		/* TODO: should increment a counter */
+		__kfree_skb(skb);
+		return;
+	}
+
+	/* Disable header prediction. */
+	tp->pred_flags =3D 0;
+	inet_csk_schedule_ack(sk);
+
+	SOCK_DEBUG(sk, "out of order segment: rcv_next %X seq %X - %X\n",
+		   tp->rcv_nxt, TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq);
+
+	skb1 =3D skb_peek_tail(&tp->out_of_order_queue);
+	if (!skb1) {
+		/* Initial out of order segment, build 1 SACK. */
+		if (tcp_is_sack(tp)) {
+			tp->rx_opt.num_sacks =3D 1;
+			tp->selective_acks[0].start_seq =3D TCP_SKB_CB(skb)->seq;
+			tp->selective_acks[0].end_seq =3D
+						TCP_SKB_CB(skb)->end_seq;
+		}
+		__skb_queue_head(&tp->out_of_order_queue, skb);
+		goto end;
+	}
+
+	seq =3D TCP_SKB_CB(skb)->seq;
+	end_seq =3D TCP_SKB_CB(skb)->end_seq;
+
+	if (seq =3D=3D TCP_SKB_CB(skb1)->end_seq) {
+		__skb_queue_after(&tp->out_of_order_queue, skb1, skb);
+
+		if (!tp->rx_opt.num_sacks ||
+		    tp->selective_acks[0].end_seq !=3D seq)
+			goto add_sack;
+
+		/* Common case: data arrive in order after hole. */
+		tp->selective_acks[0].end_seq =3D end_seq;
+		goto end;
+	}
+
+	/* Find place to insert this segment. */
+	while (1) {
+		if (!after(TCP_SKB_CB(skb1)->seq, seq))
+			break;
+		if (skb_queue_is_first(&tp->out_of_order_queue, skb1)) {
+			skb1 =3D NULL;
+			break;
+		}
+		skb1 =3D skb_queue_prev(&tp->out_of_order_queue, skb1);
+	}
+
+	/* Do skb overlap to previous one? */
+	if (skb1 && before(seq, TCP_SKB_CB(skb1)->end_seq)) {
+		if (!after(end_seq, TCP_SKB_CB(skb1)->end_seq)) {
+			/* All the bits are present. Drop. */
+			__kfree_skb(skb);
+			skb =3D NULL;
+			tcp_dsack_set(sk, seq, end_seq);
+			goto add_sack;
+		}
+		if (after(seq, TCP_SKB_CB(skb1)->seq)) {
+			/* Partial overlap. */
+			tcp_dsack_set(sk, seq,
+				      TCP_SKB_CB(skb1)->end_seq);
+		} else {
+			if (skb_queue_is_first(&tp->out_of_order_queue,
+					       skb1))
+				skb1 =3D NULL;
+			else
+				skb1 =3D skb_queue_prev(
+					&tp->out_of_order_queue,
+					skb1);
+		}
+	}
+	if (!skb1)
+		__skb_queue_head(&tp->out_of_order_queue, skb);
+	else
+		__skb_queue_after(&tp->out_of_order_queue, skb1, skb);
+
+	/* And clean segments covered by new one as whole. */
+	while (!skb_queue_is_last(&tp->out_of_order_queue, skb)) {
+		skb1 =3D skb_queue_next(&tp->out_of_order_queue, skb);
+
+		if (!after(end_seq, TCP_SKB_CB(skb1)->seq))
+			break;
+		if (before(end_seq, TCP_SKB_CB(skb1)->end_seq)) {
+			tcp_dsack_extend(sk, TCP_SKB_CB(skb1)->seq,
+					 end_seq);
+			break;
+		}
+		__skb_unlink(skb1, &tp->out_of_order_queue);
+		tcp_dsack_extend(sk, TCP_SKB_CB(skb1)->seq,
+				 TCP_SKB_CB(skb1)->end_seq);
+		__kfree_skb(skb1);
+	}
+
+add_sack:
+	if (tcp_is_sack(tp))
+		tcp_sack_new_ofo_skb(sk, seq, end_seq);
+end:
+	if (skb)
+		skb_set_owner_r(skb, sk);
+}
+
+
 static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 {
 	const struct tcphdr *th =3D tcp_hdr(skb);
@@ -4561,105 +4675,7 @@ drop:
 		goto queue_and_out;
 	}
=20
-	TCP_ECN_check_ce(tp, skb);
-
-	if (tcp_try_rmem_schedule(sk, skb->truesize))
-		goto drop;
-
-	/* Disable header prediction. */
-	tp->pred_flags =3D 0;
-	inet_csk_schedule_ack(sk);
-
-	SOCK_DEBUG(sk, "out of order segment: rcv_next %X seq %X - %X\n",
-		   tp->rcv_nxt, TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq);
-
-	skb_set_owner_r(skb, sk);
-
-	if (!skb_peek(&tp->out_of_order_queue)) {
-		/* Initial out of order segment, build 1 SACK. */
-		if (tcp_is_sack(tp)) {
-			tp->rx_opt.num_sacks =3D 1;
-			tp->selective_acks[0].start_seq =3D TCP_SKB_CB(skb)->seq;
-			tp->selective_acks[0].end_seq =3D
-						TCP_SKB_CB(skb)->end_seq;
-		}
-		__skb_queue_head(&tp->out_of_order_queue, skb);
-	} else {
-		struct sk_buff *skb1 =3D skb_peek_tail(&tp->out_of_order_queue);
-		u32 seq =3D TCP_SKB_CB(skb)->seq;
-		u32 end_seq =3D TCP_SKB_CB(skb)->end_seq;
-
-		if (seq =3D=3D TCP_SKB_CB(skb1)->end_seq) {
-			__skb_queue_after(&tp->out_of_order_queue, skb1, skb);
-
-			if (!tp->rx_opt.num_sacks ||
-			    tp->selective_acks[0].end_seq !=3D seq)
-				goto add_sack;
-
-			/* Common case: data arrive in order after hole. */
-			tp->selective_acks[0].end_seq =3D end_seq;
-			return;
-		}
-
-		/* Find place to insert this segment. */
-		while (1) {
-			if (!after(TCP_SKB_CB(skb1)->seq, seq))
-				break;
-			if (skb_queue_is_first(&tp->out_of_order_queue, skb1)) {
-				skb1 =3D NULL;
-				break;
-			}
-			skb1 =3D skb_queue_prev(&tp->out_of_order_queue, skb1);
-		}
-
-		/* Do skb overlap to previous one? */
-		if (skb1 && before(seq, TCP_SKB_CB(skb1)->end_seq)) {
-			if (!after(end_seq, TCP_SKB_CB(skb1)->end_seq)) {
-				/* All the bits are present. Drop. */
-				__kfree_skb(skb);
-				tcp_dsack_set(sk, seq, end_seq);
-				goto add_sack;
-			}
-			if (after(seq, TCP_SKB_CB(skb1)->seq)) {
-				/* Partial overlap. */
-				tcp_dsack_set(sk, seq,
-					      TCP_SKB_CB(skb1)->end_seq);
-			} else {
-				if (skb_queue_is_first(&tp->out_of_order_queue,
-						       skb1))
-					skb1 =3D NULL;
-				else
-					skb1 =3D skb_queue_prev(
-						&tp->out_of_order_queue,
-						skb1);
-			}
-		}
-		if (!skb1)
-			__skb_queue_head(&tp->out_of_order_queue, skb);
-		else
-			__skb_queue_after(&tp->out_of_order_queue, skb1, skb);
-
-		/* And clean segments covered by new one as whole. */
-		while (!skb_queue_is_last(&tp->out_of_order_queue, skb)) {
-			skb1 =3D skb_queue_next(&tp->out_of_order_queue, skb);
-
-			if (!after(end_seq, TCP_SKB_CB(skb1)->seq))
-				break;
-			if (before(end_seq, TCP_SKB_CB(skb1)->end_seq)) {
-				tcp_dsack_extend(sk, TCP_SKB_CB(skb1)->seq,
-						 end_seq);
-				break;
-			}
-			__skb_unlink(skb1, &tp->out_of_order_queue);
-			tcp_dsack_extend(sk, TCP_SKB_CB(skb1)->seq,
-					 TCP_SKB_CB(skb1)->end_seq);
-			__kfree_skb(skb1);
-		}
-
-add_sack:
-		if (tcp_is_sack(tp))
-			tcp_sack_new_ofo_skb(sk, seq, end_seq);
-	}
+	tcp_data_queue_ofo(sk, skb);
 }
=20
 static struct sk_buff *tcp_collapse_one(struct sock *sk, struct sk_buf=
f *skb,

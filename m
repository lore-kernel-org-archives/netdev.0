From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 5/7] [TCP]: No need to re-count fackets_out/sacked_out at RTO
Date: Thu, 11 Oct 2007 14:41:05 +0300
Message-ID: <11921028672853-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1192102867479-git-send-email-ilpo.jarvinen@helsinki.fi> <11921028673599-git-send-email-ilpo.jarvinen@helsinki.fi> <1192102867725-git-send-email-ilpo.jarvinen@helsinki.fi> <11921028673528-git-send-email-ilpo.jarvinen@helsinki.fi> <11921028673030-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, TAKANO Ryousei <takano@axe-inc.co.jp>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46000 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755270AbXJKLlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 07:41:17 -0400
In-Reply-To: <11921028673030-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Both sacked_out and fackets_out are directly known from how
parameter. Since fackets_out is accurate, there's no need for
recounting (sacked_out was previously unnecessarily counted
in the loop anyway).

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   26 ++++++++++++++++----------
 1 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index bd18c25..a066039 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1711,18 +1711,23 @@ static void tcp_enter_frto_loss(struct sock *sk=
, int allowed_segments, int flag)
 	tcp_clear_retrans_hints_partial(tp);
 }
=20
-void tcp_clear_retrans(struct tcp_sock *tp)
+static void tcp_clear_retrans_partial(struct tcp_sock *tp)
 {
 	tp->retrans_out =3D 0;
-
-	tp->fackets_out =3D 0;
-	tp->sacked_out =3D 0;
 	tp->lost_out =3D 0;
=20
 	tp->undo_marker =3D 0;
 	tp->undo_retrans =3D 0;
 }
=20
+void tcp_clear_retrans(struct tcp_sock *tp)
+{
+	tcp_clear_retrans_partial(tp);
+
+	tp->fackets_out =3D 0;
+	tp->sacked_out =3D 0;
+}
+
 /* Enter Loss state. If "how" is not zero, forget all SACK information
  * and reset tags completely, otherwise preserve SACKs. If receiver
  * dropped its ofo queue, we will know this due to reneging detection.
@@ -1732,7 +1737,6 @@ void tcp_enter_loss(struct sock *sk, int how)
 	const struct inet_connection_sock *icsk =3D inet_csk(sk);
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *skb;
-	int cnt =3D 0;
=20
 	/* Reduce ssthresh if it has not yet been made inside this window. */
 	if (icsk->icsk_ca_state <=3D TCP_CA_Disorder || tp->snd_una =3D=3D tp=
->high_seq ||
@@ -1746,7 +1750,10 @@ void tcp_enter_loss(struct sock *sk, int how)
 	tp->snd_cwnd_stamp =3D tcp_time_stamp;
=20
 	tp->bytes_acked =3D 0;
-	tcp_clear_retrans(tp);
+	tcp_clear_retrans_partial(tp);
+
+	if (tcp_is_reno(tp))
+		tcp_reset_reno_sack(tp);
=20
 	if (!how) {
 		/* Push undo marker, if it was plain RTO and nothing
@@ -1754,13 +1761,15 @@ void tcp_enter_loss(struct sock *sk, int how)
 		tp->undo_marker =3D tp->snd_una;
 		tcp_clear_retrans_hints_partial(tp);
 	} else {
+		tp->sacked_out =3D 0;
+		tp->fackets_out =3D 0;
 		tcp_clear_all_retrans_hints(tp);
 	}
=20
 	tcp_for_write_queue(skb, sk) {
 		if (skb =3D=3D tcp_send_head(sk))
 			break;
-		cnt +=3D tcp_skb_pcount(skb);
+
 		if (TCP_SKB_CB(skb)->sacked&TCPCB_RETRANS)
 			tp->undo_marker =3D 0;
 		TCP_SKB_CB(skb)->sacked &=3D (~TCPCB_TAGBITS)|TCPCB_SACKED_ACKED;
@@ -1768,9 +1777,6 @@ void tcp_enter_loss(struct sock *sk, int how)
 			TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_SACKED_ACKED;
 			TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
 			tp->lost_out +=3D tcp_skb_pcount(skb);
-		} else {
-			tp->sacked_out +=3D tcp_skb_pcount(skb);
-			tp->fackets_out =3D cnt;
 		}
 	}
 	tcp_verify_left_out(tp);
--=20
1.5.0.6


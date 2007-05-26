From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/9] [TCP] FRTO: remove unnecessary fackets/sacked_out recounting
Date: Sat, 26 May 2007 11:35:55 +0300
Message-ID: <11801685626-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11801685622325-git-send-email-ilpo.jarvinen@helsinki.fi> <11801685621267-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:40613 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315AbXEZIgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 May 2007 04:36:06 -0400
In-Reply-To: <11801685621267-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

=46-RTO does not touch SACKED_ACKED bits at all, so there is no
need to recount them in tcp_enter_frto_loss. After removal of
the else branch, nested ifs can be combined.

This must also reset sacked_out when SACK is not in use as TCP
could have received some duplicate ACKs prior RTO. To achieve
that in a sane manner, tcp_reset_reno_sack was re-placed by the
previous patch.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   23 +++++++----------------
 1 files changed, 7 insertions(+), 16 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 925a26f..4dab5d7 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1479,17 +1479,15 @@ static void tcp_enter_frto_loss(struct sock *sk=
, int allowed_segments, int flag)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *skb;
-	int cnt =3D 0;
=20
-	tp->sacked_out =3D 0;
 	tp->lost_out =3D 0;
-	tp->fackets_out =3D 0;
 	tp->retrans_out =3D 0;
+	if (IsReno(tp))
+		tcp_reset_reno_sack(tp);
=20
 	tcp_for_write_queue(skb, sk) {
 		if (skb =3D=3D tcp_send_head(sk))
 			break;
-		cnt +=3D tcp_skb_pcount(skb);
 		/*
 		 * Count the retransmission made on RTO correctly (only when
 		 * waiting for the first ACK and did not get it)...
@@ -1501,19 +1499,12 @@ static void tcp_enter_frto_loss(struct sock *sk=
, int allowed_segments, int flag)
 		} else {
 			TCP_SKB_CB(skb)->sacked &=3D ~(TCPCB_LOST|TCPCB_SACKED_RETRANS);
 		}
-		if (!(TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_ACKED)) {
=20
-			/* Do not mark those segments lost that were
-			 * forward transmitted after RTO
-			 */
-			if (!after(TCP_SKB_CB(skb)->end_seq,
-				   tp->frto_highmark)) {
-				TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
-				tp->lost_out +=3D tcp_skb_pcount(skb);
-			}
-		} else {
-			tp->sacked_out +=3D tcp_skb_pcount(skb);
-			tp->fackets_out =3D cnt;
+		/* Don't lost mark skbs that were fwd transmitted after RTO */
+		if (!(TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_ACKED) &&
+		    !after(TCP_SKB_CB(skb)->end_seq, tp->frto_highmark)) {
+			TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
+			tp->lost_out +=3D tcp_skb_pcount(skb);
 		}
 	}
 	tcp_sync_left_out(tp);
--=20
1.5.0.6


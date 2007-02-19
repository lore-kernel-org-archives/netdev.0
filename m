From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 14/18] [TCP] FRTO: Reverse RETRANS bit clearing logic
Date: Mon, 19 Feb 2007 13:38:08 +0200
Message-ID: <11718850921389-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11718850923446-git-send-email-ilpo.jarvinen@helsinki.fi> <1171885092563-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921459-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850923208-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921817-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922528-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921864-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922604-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921021-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850923324-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922734-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921158-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921574-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921409-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Pasi Sarolahti <pasi.sarolahti@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37500 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932143AbXBSLiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 06:38:18 -0500
In-Reply-To: <11718850921409-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Previously RETRANS bits were cleared on the entry to FRTO. We
postpone that into tcp_enter_frto_loss, which is really the
place were the clearing should be done anyway. This allows
simplification of the logic from a clearing loop to the head skb
clearing only.

Besides, the other changes made in the previous patches to
tcp_use_frto made it impossible for the non-SACKed FRTO to be
entered if other than the head has been rexmitted.

With SACK-enhanced FRTO (and Appendix B), however, there can be
a number retransmissions in flight when RTO expires (same thing
could happen before this patchset also with non-SACK FRTO). To
not introduce any jumpiness into the packet counting during FRTO,
instead of clearing RETRANS bits from skbs during entry, do it
later on.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   35 +++++++++++++++++++++++------------
 1 files changed, 23 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 8f0aa9d..2c0b387 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1268,7 +1268,11 @@ int tcp_use_frto(struct sock *sk)
=20
 /* RTO occurred, but do not yet enter Loss state. Instead, defer RTO
  * recovery a bit and use heuristics in tcp_process_frto() to detect i=
f
- * the RTO was spurious.
+ * the RTO was spurious. Only clear SACKED_RETRANS of the head here to
+ * keep retrans_out counting accurate (with SACK F-RTO, other than hea=
d
+ * may still have that bit set); TCPCB_LOST and remaining SACKED_RETRA=
NS
+ * bits are handled if the Loss state is really to be entered (in
+ * tcp_enter_frto_loss).
  *
  * Do like tcp_enter_loss() would; when RTO expires the second time it
  * does:
@@ -1289,17 +1293,13 @@ void tcp_enter_frto(struct sock *sk)
 		tcp_ca_event(sk, CA_EVENT_FRTO);
 	}
=20
-	/* Have to clear retransmission markers here to keep the bookkeeping
-	 * in shape, even though we are not yet in Loss state.
-	 * If something was really lost, it is eventually caught up
-	 * in tcp_enter_frto_loss.
-	 */
-	tp->retrans_out =3D 0;
 	tp->undo_marker =3D tp->snd_una;
 	tp->undo_retrans =3D 0;
=20
-	sk_stream_for_retrans_queue(skb, sk) {
+	skb =3D skb_peek(&sk->sk_write_queue);
+	if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS) {
 		TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_SACKED_RETRANS;
+		tp->retrans_out -=3D tcp_skb_pcount(skb);
 	}
 	tcp_sync_left_out(tp);
=20
@@ -1313,7 +1313,7 @@ void tcp_enter_frto(struct sock *sk)
  * which indicates that we should follow the traditional RTO recovery,
  * i.e. mark everything lost and do go-back-N retransmission.
  */
-static void tcp_enter_frto_loss(struct sock *sk, int allowed_segments)
+static void tcp_enter_frto_loss(struct sock *sk, int allowed_segments,=
 int flag)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *skb;
@@ -1322,10 +1322,21 @@ static void tcp_enter_frto_loss(struct s
 	tp->sacked_out =3D 0;
 	tp->lost_out =3D 0;
 	tp->fackets_out =3D 0;
+	tp->retrans_out =3D 0;
=20
 	sk_stream_for_retrans_queue(skb, sk) {
 		cnt +=3D tcp_skb_pcount(skb);
-		TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_LOST;
+		/*
+		 * Count the retransmission made on RTO correctly (only when
+		 * waiting for the first ACK and did not get it)...
+		 */
+		if ((tp->frto_counter =3D=3D 1) && !(flag&FLAG_DATA_ACKED)) {
+			tp->retrans_out +=3D tcp_skb_pcount(skb);
+			/* ...enter this if branch just for the first segment */
+			flag |=3D FLAG_DATA_ACKED;
+		} else {
+			TCP_SKB_CB(skb)->sacked &=3D ~(TCPCB_LOST|TCPCB_SACKED_RETRANS);
+		}
 		if (!(TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_ACKED)) {
=20
 			/* Do not mark those segments lost that were
@@ -2550,7 +2561,7 @@ static int tcp_process_frto(struct sock=20
 		inet_csk(sk)->icsk_retransmits =3D 0;
=20
 	if (!before(tp->snd_una, tp->frto_highmark)) {
-		tcp_enter_frto_loss(sk, tp->frto_counter + 1);
+		tcp_enter_frto_loss(sk, tp->frto_counter + 1, flag);
 		return 1;
 	}
=20
@@ -2562,7 +2573,7 @@ static int tcp_process_frto(struct sock=20
 		return 1;
=20
 	if (!(flag&FLAG_DATA_ACKED)) {
-		tcp_enter_frto_loss(sk, (tp->frto_counter =3D=3D 1 ? 0 : 3));
+		tcp_enter_frto_loss(sk, (tp->frto_counter =3D=3D 1 ? 0 : 3), flag);
 		return 1;
 	}
=20
--=20
1.4.2


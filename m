From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 12/18] [TCP]: Prevent unrelated cwnd adjustment while using FRTO
Date: Mon, 19 Feb 2007 13:38:06 +0200
Message-ID: <11718850921574-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11718850923446-git-send-email-ilpo.jarvinen@helsinki.fi> <1171885092563-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921459-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850923208-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921817-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922528-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921864-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922604-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921021-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850923324-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922734-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921158-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Pasi Sarolahti <pasi.sarolahti@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46068 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932120AbXBSLiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 06:38:18 -0500
In-Reply-To: <11718850921158-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46RTO controls cwnd when it still processes the ACK input or it
has just reverted back to conventional RTO recovery; the normal
rules apply when FRTO has reverted to standard congestion
control.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9fc7f66..5e952f0 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2522,7 +2522,7 @@ static void tcp_conservative_spur_to_res
  *     to prove that the RTO is indeed spurious. It transfers the cont=
rol
  *     from F-RTO to the conventional RTO recovery
  */
-static void tcp_process_frto(struct sock *sk, u32 prior_snd_una, int f=
lag)
+static int tcp_process_frto(struct sock *sk, u32 prior_snd_una, int fl=
ag)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
=20
@@ -2534,7 +2534,7 @@ static void tcp_process_frto(struct sock
=20
 	if (!before(tp->snd_una, tp->frto_highmark)) {
 		tcp_enter_frto_loss(sk, tp->frto_counter + 1);
-		return;
+		return 1;
 	}
=20
 	/* RFC4138 shortcoming in step 2; should also have case c): ACK isn't
@@ -2542,20 +2542,22 @@ static void tcp_process_frto(struct sock
 	 */
 	if ((tp->snd_una =3D=3D prior_snd_una) && (flag&FLAG_NOT_DUP) &&
 	    !(flag&FLAG_FORWARD_PROGRESS))
-		return;
+		return 1;
=20
 	if (!(flag&FLAG_DATA_ACKED)) {
 		tcp_enter_frto_loss(sk, (tp->frto_counter =3D=3D 1 ? 0 : 3));
-		return;
+		return 1;
 	}
=20
 	if (tp->frto_counter =3D=3D 1) {
 		tp->snd_cwnd =3D tcp_packets_in_flight(tp) + 2;
 		tp->frto_counter =3D 2;
+		return 1;
 	} else /* frto_counter =3D=3D 2 */ {
 		tcp_conservative_spur_to_response(tp);
 		tp->frto_counter =3D 0;
 	}
+	return 0;
 }
=20
 /* This routine deals with incoming acks, but not outgoing ones. */
@@ -2569,6 +2571,7 @@ static int tcp_ack(struct sock *sk, stru
 	u32 prior_in_flight;
 	s32 seq_rtt;
 	int prior_packets;
+	int frto_cwnd =3D 0;
=20
 	/* If the ack is newer than sent or older than previous acks
 	 * then we can probably ignore it.
@@ -2631,15 +2634,16 @@ static int tcp_ack(struct sock *sk, stru
 	flag |=3D tcp_clean_rtx_queue(sk, &seq_rtt);
=20
 	if (tp->frto_counter)
-		tcp_process_frto(sk, prior_snd_una, flag);
+		frto_cwnd =3D tcp_process_frto(sk, prior_snd_una, flag);
=20
 	if (tcp_ack_is_dubious(sk, flag)) {
 		/* Advance CWND, if state allows this. */
-		if ((flag & FLAG_DATA_ACKED) && tcp_may_raise_cwnd(sk, flag))
+		if ((flag & FLAG_DATA_ACKED) && !frto_cwnd &&
+		    tcp_may_raise_cwnd(sk, flag))
 			tcp_cong_avoid(sk, ack,  seq_rtt, prior_in_flight, 0);
 		tcp_fastretrans_alert(sk, prior_snd_una, prior_packets, flag);
 	} else {
-		if ((flag & FLAG_DATA_ACKED))
+		if ((flag & FLAG_DATA_ACKED) && !frto_cwnd)
 			tcp_cong_avoid(sk, ack, seq_rtt, prior_in_flight, 1);
 	}
=20
--=20
1.4.2


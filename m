From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/18] [TCP] FRTO: Separated response from FRTO detection algorithm
Date: Mon, 19 Feb 2007 13:37:56 +0200
Message-ID: <11718850921459-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11718850923446-git-send-email-ilpo.jarvinen@helsinki.fi> <1171885092563-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Pasi Sarolahti <pasi.sarolahti@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50238 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932123AbXBSLiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 06:38:14 -0500
In-Reply-To: <1171885092563-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46RTO spurious RTO detection algorithm (RFC4138) does not include resp=
onse
to a detected spurious RTO but can use different response algorithms.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b21e232..c5be3d0 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2467,6 +2467,15 @@ static int tcp_ack_update_window(struct=20
 	return flag;
 }
=20
+/* A very conservative spurious RTO response algorithm: reduce cwnd an=
d
+ * continue in congestion avoidance.
+ */
+static void tcp_conservative_spur_to_response(struct tcp_sock *tp)
+{
+	tp->snd_cwnd =3D min(tp->snd_cwnd, tp->snd_ssthresh);
+	tcp_moderate_cwnd(tp);
+}
+
 static void tcp_process_frto(struct sock *sk, u32 prior_snd_una)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
@@ -2488,12 +2497,7 @@ static void tcp_process_frto(struct sock
 		 */
 		tp->snd_cwnd =3D tcp_packets_in_flight(tp) + 2;
 	} else {
-		/* Also the second ACK after RTO advances the window.
-		 * The RTO was likely spurious. Reduce cwnd and continue
-		 * in congestion avoidance
-		 */
-		tp->snd_cwnd =3D min(tp->snd_cwnd, tp->snd_ssthresh);
-		tcp_moderate_cwnd(tp);
+		tcp_conservative_spur_to_response(tp);
 	}
=20
 	/* F-RTO affects on two new ACKs following RTO.
--=20
1.4.2


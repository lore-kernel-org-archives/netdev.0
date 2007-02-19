From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 4/18] [TCP] FRTO: Comment cleanup & improvement
Date: Mon, 19 Feb 2007 13:37:58 +0200
Message-ID: <11718850921817-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11718850923446-git-send-email-ilpo.jarvinen@helsinki.fi> <1171885092563-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921459-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850923208-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Pasi Sarolahti <pasi.sarolahti@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50238 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932124AbXBSLiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 06:38:15 -0500
In-Reply-To: <11718850923208-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Moved comments out from the body of process_frto() to the head
(preferred way; see Documentation/CodingStyle). Bonus: it's much
easier to read in this compacted form.

=46RTO algorithm and implementation is described in greater detail.
=46or interested reader, more information is available in RFC4138.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   49 ++++++++++++++++++++++++++++++++----------=
-------
 1 files changed, 32 insertions(+), 17 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 294cb44..f645c3e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1236,22 +1236,22 @@ #endif
 	return flag;
 }
=20
+/* F-RTO can only be used if these conditions are satisfied:
+ *  - there must be some unsent new data
+ *  - the advertised window should allow sending it
+ */
 int tcp_use_frto(const struct sock *sk)
 {
 	const struct tcp_sock *tp =3D tcp_sk(sk);
 =09
-	/* F-RTO must be activated in sysctl and there must be some
-	 * unsent new data, and the advertised window should allow
-	 * sending it.
-	 */
 	return (sysctl_tcp_frto && sk->sk_send_head &&
 		!after(TCP_SKB_CB(sk->sk_send_head)->end_seq,
 		       tp->snd_una + tp->snd_wnd));
 }
=20
-/* RTO occurred, but do not yet enter loss state. Instead, transmit tw=
o new
- * segments to see from the next ACKs whether any data was really miss=
ing.
- * If the RTO was spurious, new ACKs should arrive.
+/* RTO occurred, but do not yet enter Loss state. Instead, defer RTO
+ * recovery a bit and use heuristics in tcp_process_frto() to detect i=
f
+ * the RTO was spurious.
  */
 void tcp_enter_frto(struct sock *sk)
 {
@@ -2489,6 +2489,30 @@ static void tcp_conservative_spur_to_res
 	tcp_moderate_cwnd(tp);
 }
=20
+/* F-RTO spurious RTO detection algorithm (RFC4138)
+ *
+ * F-RTO affects during two new ACKs following RTO. State (ACK number)=
 is kept
+ * in frto_counter. When ACK advances window (but not to or beyond hig=
hest
+ * sequence sent before RTO):
+ *   On First ACK,  send two new segments out.
+ *   On Second ACK, RTO was likely spurious. Do spurious response (res=
ponse
+ *                  algorithm is not part of the F-RTO detection algor=
ithm
+ *                  given in RFC4138 but can be selected separately).
+ * Otherwise (basically on duplicate ACK), RTO was (likely) caused by =
a loss
+ * and TCP falls back to conventional RTO recovery.
+ *
+ * Rationale: if the RTO was spurious, new ACKs should arrive from the
+ * original window even after we transmit two new data segments.
+ *
+ * F-RTO is implemented (mainly) in four functions:
+ *   - tcp_use_frto() is used to determine if TCP is can use F-RTO
+ *   - tcp_enter_frto() prepares TCP state on RTO if F-RTO is used, it=
 is
+ *     called when tcp_use_frto() showed green light
+ *   - tcp_process_frto() handles incoming ACKs during F-RTO algorithm
+ *   - tcp_enter_frto_loss() is called if there is not enough evidence
+ *     to prove that the RTO is indeed spurious. It transfers the cont=
rol
+ *     from F-RTO to the conventional RTO recovery
+ */
 static void tcp_process_frto(struct sock *sk, u32 prior_snd_una)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
@@ -2497,25 +2521,16 @@ static void tcp_process_frto(struct sock
=20
 	if (tp->snd_una =3D=3D prior_snd_una ||
 	    !before(tp->snd_una, tp->frto_highmark)) {
-		/* RTO was caused by loss, start retransmitting in
-		 * go-back-N slow start
-		 */
 		tcp_enter_frto_loss(sk);
 		return;
 	}
=20
 	if (tp->frto_counter =3D=3D 1) {
-		/* First ACK after RTO advances the window: allow two new
-		 * segments out.
-		 */
 		tp->snd_cwnd =3D tcp_packets_in_flight(tp) + 2;
-	} else {
+	} else /* frto_counter =3D=3D 2 */ {
 		tcp_conservative_spur_to_response(tp);
 	}
=20
-	/* F-RTO affects on two new ACKs following RTO.
-	 * At latest on third ACK the TCP behavior is back to normal.
-	 */
 	tp->frto_counter =3D (tp->frto_counter + 1) % 3;
 }
=20
--=20
1.4.2


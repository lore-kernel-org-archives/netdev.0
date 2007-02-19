From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 8/18] [TCP] FRTO: fixes fallback to conventional recovery
Date: Mon, 19 Feb 2007 13:38:02 +0200
Message-ID: <11718850921021-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11718850923446-git-send-email-ilpo.jarvinen@helsinki.fi> <1171885092563-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921459-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850923208-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921817-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922528-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921864-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922604-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Pasi Sarolahti <pasi.sarolahti@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50238 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932133AbXBSLiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 06:38:16 -0500
In-Reply-To: <11718850922604-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The FRTO detection did not care how ACK pattern affects to cwnd
calculation of the conventional recovery. This caused incorrect
setting of cwnd when the fallback becames necessary. The
knowledge tcp_process_frto() has about the incoming ACK is now
passed on to tcp_enter_frto_loss() in allowed_segments parameter
that gives the number of segments that must be added to
packets-in-flight while calculating the new cwnd.

Instead of snd_una we use FLAG_DATA_ACKED in duplicate ACK
detection because RFC4138 states (in Section 2.2):
  If the first acknowledgment after the RTO retransmission
  does not acknowledge all of the data that was retransmitted
  in step 1, the TCP sender reverts to the conventional RTO
  recovery.  Otherwise, a malicious receiver acknowledging
  partial segments could cause the sender to declare the
  timeout spurious in a case where data was lost.

If the next ACK after RTO is duplicate, we do not retransmit
anything, which is equal to what conservative conventional
recovery does in such case.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 5831daa..2679279 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1296,7 +1296,7 @@ void tcp_enter_frto(struct sock *sk)
  * which indicates that we should follow the traditional RTO recovery,
  * i.e. mark everything lost and do go-back-N retransmission.
  */
-static void tcp_enter_frto_loss(struct sock *sk)
+static void tcp_enter_frto_loss(struct sock *sk, int allowed_segments)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *skb;
@@ -1326,7 +1326,7 @@ static void tcp_enter_frto_loss(struct s
 	}
 	tcp_sync_left_out(tp);
=20
-	tp->snd_cwnd =3D tp->frto_counter + tcp_packets_in_flight(tp)+1;
+	tp->snd_cwnd =3D tcp_packets_in_flight(tp) + allowed_segments;
 	tp->snd_cwnd_cnt =3D 0;
 	tp->snd_cwnd_stamp =3D tcp_time_stamp;
 	tp->undo_marker =3D 0;
@@ -2527,6 +2527,11 @@ static void tcp_process_frto(struct sock
 	if (flag&FLAG_DATA_ACKED)
 		inet_csk(sk)->icsk_retransmits =3D 0;
=20
+	if (!before(tp->snd_una, tp->frto_highmark)) {
+		tcp_enter_frto_loss(sk, tp->frto_counter + 1);
+		return;
+	}
+
 	/* RFC4138 shortcoming in step 2; should also have case c): ACK isn't
 	 * duplicate nor advances window, e.g., opposite dir data, winupdate
 	 */
@@ -2534,9 +2539,8 @@ static void tcp_process_frto(struct sock
 	    !(flag&FLAG_FORWARD_PROGRESS))
 		return;
=20
-	if (tp->snd_una =3D=3D prior_snd_una ||
-	    !before(tp->snd_una, tp->frto_highmark)) {
-		tcp_enter_frto_loss(sk);
+	if (!(flag&FLAG_DATA_ACKED)) {
+		tcp_enter_frto_loss(sk, (tp->frto_counter =3D=3D 1 ? 0 : 3));
 		return;
 	}
=20
--=20
1.4.2


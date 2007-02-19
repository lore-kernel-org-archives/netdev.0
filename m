From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 7/18] [TCP] FRTO: Ignore some uninteresting ACKs
Date: Mon, 19 Feb 2007 13:38:01 +0200
Message-ID: <11718850922604-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11718850923446-git-send-email-ilpo.jarvinen@helsinki.fi> <1171885092563-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921459-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850923208-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921817-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922528-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921864-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Pasi Sarolahti <pasi.sarolahti@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37500 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932128AbXBSLiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 06:38:15 -0500
In-Reply-To: <11718850921864-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Handles RFC4138 shortcoming (in step 2); it should also have case
c) which ignores ACKs that are not duplicates nor advance window
(opposite dir data, winupdate).

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d1e731f..5831daa 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2495,9 +2495,9 @@ static void tcp_conservative_spur_to_res
=20
 /* F-RTO spurious RTO detection algorithm (RFC4138)
  *
- * F-RTO affects during two new ACKs following RTO. State (ACK number)=
 is kept
- * in frto_counter. When ACK advances window (but not to or beyond hig=
hest
- * sequence sent before RTO):
+ * F-RTO affects during two new ACKs following RTO (well, almost, see =
inline
+ * comments). State (ACK number) is kept in frto_counter. When ACK adv=
ances
+ * window (but not to or beyond highest sequence sent before RTO):
  *   On First ACK,  send two new segments out.
  *   On Second ACK, RTO was likely spurious. Do spurious response (res=
ponse
  *                  algorithm is not part of the F-RTO detection algor=
ithm
@@ -2527,6 +2527,13 @@ static void tcp_process_frto(struct sock
 	if (flag&FLAG_DATA_ACKED)
 		inet_csk(sk)->icsk_retransmits =3D 0;
=20
+	/* RFC4138 shortcoming in step 2; should also have case c): ACK isn't
+	 * duplicate nor advances window, e.g., opposite dir data, winupdate
+	 */
+	if ((tp->snd_una =3D=3D prior_snd_una) && (flag&FLAG_NOT_DUP) &&
+	    !(flag&FLAG_FORWARD_PROGRESS))
+		return;
+
 	if (tp->snd_una =3D=3D prior_snd_una ||
 	    !before(tp->snd_una, tp->frto_highmark)) {
 		tcp_enter_frto_loss(sk);
--=20
1.4.2


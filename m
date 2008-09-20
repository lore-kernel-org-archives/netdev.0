From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCHv2 net-next 07/15] tcp: add tcp_can_forward_retransmit
Date: Sun, 21 Sep 2008 00:47:50 +0300
Message-ID: <1221947278-16715-8-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1221947278-16715-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-5-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-6-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-7-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45382 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751652AbYITVsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 17:48:04 -0400
In-Reply-To: <1221947278-16715-7-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |   46 ++++++++++++++++++++++++++++-------------=
-----
 1 files changed, 28 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index bb30e68..8919077 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1990,6 +1990,33 @@ int tcp_retransmit_skb(struct sock *sk, struct s=
k_buff *skb)
 	return err;
 }
=20
+static int tcp_can_forward_retransmit(struct sock *sk)
+{
+	const struct inet_connection_sock *icsk =3D inet_csk(sk);
+	struct tcp_sock *tp =3D tcp_sk(sk);
+
+	/* Forward retransmissions are possible only during Recovery. */
+	if (icsk->icsk_ca_state !=3D TCP_CA_Recovery)
+		return 0;
+
+	/* No forward retransmissions in Reno are possible. */
+	if (tcp_is_reno(tp))
+		return 0;
+
+	/* Yeah, we have to make difficult choice between forward transmissio=
n
+	 * and retransmission... Both ways have their merits...
+	 *
+	 * For now we do not retransmit anything, while we have some new
+	 * segments to send. In the other cases, follow rule 3 for
+	 * NextSeg() specified in RFC3517.
+	 */
+
+	if (tcp_may_send_now(sk))
+		return 0;
+
+	return 1;
+}
+
 /* This gets called after a retransmit timeout, and the initially
  * retransmitted data is acknowledged.  It tries to continue
  * resending the rest of the retransmit queue, until either
@@ -2055,24 +2082,7 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 	}
=20
 	/* OK, demanded retransmission is finished. */
-
-	/* Forward retransmissions are possible only during Recovery. */
-	if (icsk->icsk_ca_state !=3D TCP_CA_Recovery)
-		return;
-
-	/* No forward retransmissions in Reno are possible. */
-	if (tcp_is_reno(tp))
-		return;
-
-	/* Yeah, we have to make difficult choice between forward transmissio=
n
-	 * and retransmission... Both ways have their merits...
-	 *
-	 * For now we do not retransmit anything, while we have some new
-	 * segments to send. In the other cases, follow rule 3 for
-	 * NextSeg() specified in RFC3517.
-	 */
-
-	if (tcp_may_send_now(sk))
+	if (!tcp_can_forward_retransmit(sk))
 		return;
=20
 	/* If nothing is SACKed, highest_sack in the loop won't be valid */
--=20
1.5.2.2


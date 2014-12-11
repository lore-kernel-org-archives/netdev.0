From: =?UTF-8?q?S=C3=A9bastien=20Barr=C3=A9?=
	<sebastien.barre@uclouvain.be>
Subject: [PATCH net-next] Avoid reducing cwnd when ACK+DSACK is received
Date: Thu, 11 Dec 2014 20:58:10 +0100
Message-ID: <1418327890-368-1-git-send-email-sebastien.barre@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?S=C3=A9bastien=20Barr=C3=A9?=
	<sebastien.barre@uclouvain.be>, <netdev@vger.kernel.org>,
	Gregory Detal <gregory.detal@uclouvain.be>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:40353 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752783AbaLKUF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 15:05:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the peer has delayed ack enabled, it may reply to a probe with an
ACK+D-SACK, with ack value set to tlp_high_seq. In the current code,
such ACK+DSACK will be missed and only at next, higher ack will the TLP
episode be considered done. Since the DSACK is not present anymore,
this will cost a cwnd reduction.

This patch ensures that this scenario does not cause a cwnd reduction, =
since
receiving an ACK+DSACK indicates that both the initial segment and the =
probe
have been received by the peer.

Cc: Gregory Detal <gregory.detal@uclouvain.be>
Cc: Nandita Dukkipati <nanditad@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Signed-off-by: S=C3=A9bastien Barr=C3=A9 <sebastien.barre@uclouvain.be>

---
 net/ipv4/tcp_input.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 075ab4d..fb007cc 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3369,23 +3369,23 @@ static void tcp_process_tlp_ack(struct sock *sk=
, u32 ack, int flag)
=20
 	/* Mark the end of TLP episode on receiving TLP dupack or when
 	 * ack is after tlp_high_seq.
+	 * With delayed acks, we may also get a regular ACK+DSACK, in which
+	 * case we don't want to reduce the cwnd either.
 	 */
-	if (is_tlp_dupack) {
+	if (is_tlp_dupack ||
+	    !before(ack, tp->tlp_high_seq) && (flag & FLAG_DSACKING_ACK)) {
 		tp->tlp_high_seq =3D 0;
 		return;
 	}
=20
 	if (after(ack, tp->tlp_high_seq)) {
 		tp->tlp_high_seq =3D 0;
-		/* Don't reduce cwnd if DSACK arrives for TLP retrans. */
-		if (!(flag & FLAG_DSACKING_ACK)) {
-			tcp_init_cwnd_reduction(sk);
-			tcp_set_ca_state(sk, TCP_CA_CWR);
-			tcp_end_cwnd_reduction(sk);
-			tcp_try_keep_open(sk);
-			NET_INC_STATS_BH(sock_net(sk),
-					 LINUX_MIB_TCPLOSSPROBERECOVERY);
-		}
+		tcp_init_cwnd_reduction(sk);
+		tcp_set_ca_state(sk, TCP_CA_CWR);
+		tcp_end_cwnd_reduction(sk);
+		tcp_try_keep_open(sk);
+		NET_INC_STATS_BH(sock_net(sk),
+				 LINUX_MIB_TCPLOSSPROBERECOVERY);
 	}
 }
=20
--=20
tg: (52c9b12..) net-next/tlp-dsack-handling (depends on: net-next/maste=
r)

From: =?UTF-8?q?S=C3=A9bastien=20Barr=C3=A9?=
	<sebastien.barre@uclouvain.be>
Subject: [PATCH net-next v2] tcp: avoid reducing cwnd when ACK+DSACK is received
Date: Thu, 8 Jan 2015 13:20:09 +0100
Message-ID: <1420719609-18638-1-git-send-email-sebastien.barre@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?S=C3=A9bastien=20Barr=C3=A9?=
	<sebastien.barre@uclouvain.be>, <netdev@vger.kernel.org>,
	Gregory Detal <gregory.detal@uclouvain.be>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:39504 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751579AbbAHMYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 07:24:03 -0500
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
Cc: Neal Cardwell <ncardwell@google.com>
Signed-off-by: S=C3=A9bastien Barr=C3=A9 <sebastien.barre@uclouvain.be>

---

Changes:
Applied Neal's comments:
-adapted commit first line
-moved logic to if condition, and removed is_tlp_dupack

Thanks Neal for those comments !

 net/ipv4/tcp_input.c | 30 +++++++++++++-----------------
 1 file changed, 13 insertions(+), 17 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 075ab4d..cf63a29 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3363,29 +3363,25 @@ static void tcp_replace_ts_recent(struct tcp_so=
ck *tp, u32 seq)
 static void tcp_process_tlp_ack(struct sock *sk, u32 ack, int flag)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
-	bool is_tlp_dupack =3D (ack =3D=3D tp->tlp_high_seq) &&
-			     !(flag & (FLAG_SND_UNA_ADVANCED |
-				       FLAG_NOT_DUP | FLAG_DATA_SACKED));
=20
 	/* Mark the end of TLP episode on receiving TLP dupack or when
 	 * ack is after tlp_high_seq.
+	 * With delayed acks, we may also get a regular ACK+DSACK, in which
+	 * case we don't want to reduce the cwnd either.
 	 */
-	if (is_tlp_dupack) {
+	if (((ack =3D=3D tp->tlp_high_seq) &&
+	     !(flag & (FLAG_SND_UNA_ADVANCED |
+		       FLAG_NOT_DUP | FLAG_DATA_SACKED))) ||
+	    (!before(ack, tp->tlp_high_seq) && (flag & FLAG_DSACKING_ACK))) {
 		tp->tlp_high_seq =3D 0;
-		return;
-	}
-
-	if (after(ack, tp->tlp_high_seq)) {
+	} else if (after(ack, tp->tlp_high_seq)) {
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
tg: (44d84d7..) net-next/tlp-dsack-handling (depends on: net-next/maste=
r)

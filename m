From: =?UTF-8?q?S=C3=A9bastien=20Barr=C3=A9?=
	<sebastien.barre@uclouvain.be>
Subject: [PATCH net-next v3] tcp: avoid reducing cwnd when ACK+DSACK is received
Date: Mon, 12 Jan 2015 10:30:40 +0100
Message-ID: <1421055040-8732-1-git-send-email-sebastien.barre@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?S=C3=A9bastien=20Barr=C3=A9?=
	<sebastien.barre@uclouvain.be>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>,
	Gregory Detal <gregory.detal@uclouvain.be>,
	Nandita Dukkipati <nanditad@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:54973 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753029AbbALJbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 04:31:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With TLP, the peer may reply to a probe with an
ACK+D-SACK, with ack value set to tlp_high_seq. In the current code,
such ACK+DSACK will be missed and only at next, higher ack will the TLP
episode be considered done. Since the DSACK is not present anymore,
this will cost a cwnd reduction.

This patch ensures that this scenario does not cause a cwnd reduction, =
since
receiving an ACK+DSACK indicates that both the initial segment and the =
probe
have been received by the peer.

The following packetdrill test, from Neal Cardwell, validates this patc=
h:

// Establish a connection.
0     socket(..., SOCK_STREAM, IPPROTO_TCP) =3D 3
+0     setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
+0    bind(3, ..., ...) =3D 0
+0    listen(3, 1) =3D 0

+0    < S 0:0(0) win 32792 <mss 1000,sackOK,nop,nop,nop,wscale 7>
+0    > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 6>
+.020 < . 1:1(0) ack 1 win 257
+0    accept(3, ..., ...) =3D 4

// Send 1 packet.
+0    write(4, ..., 1000) =3D 1000
+0    > P. 1:1001(1000) ack 1

// Loss probe retransmission.
// packets_out =3D=3D 1 =3D> schedule PTO in max(2*RTT, 1.5*RTT + 200ms=
)
// In this case, this means: 1.5*RTT + 200ms =3D 230ms
+.230 > P. 1:1001(1000) ack 1
+0    %{ assert tcpi_snd_cwnd =3D=3D 10 }%

// Receiver ACKs at tlp_high_seq with a DSACK,
// indicating they received the original packet and probe.
+.020 < . 1:1(0) ack 1001 win 257 <sack 1:1001,nop,nop>
+0    %{ assert tcpi_snd_cwnd =3D=3D 10 }%

// Send another packet.
+0    write(4, ..., 1000) =3D 1000
+0    > P. 1001:2001(1000) ack 1

// Receiver ACKs above tlp_high_seq, which should end the TLP episode
// if we haven't already. We should not reduce cwnd.
+.020 < . 1:1(0) ack 2001 win 257
+0    %{ assert tcpi_snd_cwnd =3D=3D 10, tcpi_snd_cwnd }%

Credits:
-Gregory helped in finding that tcp_process_tlp_ack was where the cwnd
got reduced in our MPTCP tests.
-Neal wrote the packetdrill test above
-Yuchung reworked the patch to make it more readable.

Cc: Gregory Detal <gregory.detal@uclouvain.be>
Cc: Nandita Dukkipati <nanditad@google.com>
Tested-by: Neal Cardwell <ncardwell@google.com>
Reviewed-by: Yuchung Cheng <ycheng@google.com>
Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: S=C3=A9bastien Barr=C3=A9 <sebastien.barre@uclouvain.be>

---

Changes:
-Added Neal's test in commit text
-applied Yuchung's changes to if conditions (for readability)
-removed delayed ack as main reason for triggering an ACK+DSACK, as
Eric mentioned that lost ack has higher chances to be the trigger.

Neal, Yuchung, Eric: I added Tested-by/Reviewed-by as I thought it was
appropriate, please correct if it is not. Thanks again for you help !

 net/ipv4/tcp_input.c | 38 +++++++++++++++++++-------------------
 1 file changed, 19 insertions(+), 19 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 075ab4d..71fb37c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3358,34 +3358,34 @@ static void tcp_replace_ts_recent(struct tcp_so=
ck *tp, u32 seq)
 }
=20
 /* This routine deals with acks during a TLP episode.
+ * We mark the end of a TLP episode on receiving TLP dupack or when
+ * ack is after tlp_high_seq.
  * Ref: loss detection algorithm in draft-dukkipati-tcpm-tcp-loss-prob=
e.
  */
 static void tcp_process_tlp_ack(struct sock *sk, u32 ack, int flag)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
-	bool is_tlp_dupack =3D (ack =3D=3D tp->tlp_high_seq) &&
-			     !(flag & (FLAG_SND_UNA_ADVANCED |
-				       FLAG_NOT_DUP | FLAG_DATA_SACKED));
=20
-	/* Mark the end of TLP episode on receiving TLP dupack or when
-	 * ack is after tlp_high_seq.
-	 */
-	if (is_tlp_dupack) {
-		tp->tlp_high_seq =3D 0;
+	if (before(ack, tp->tlp_high_seq))
 		return;
-	}
=20
-	if (after(ack, tp->tlp_high_seq)) {
+	if (flag & FLAG_DSACKING_ACK) {
+		/* This DSACK means original and TLP probe arrived; no loss */
+		tp->tlp_high_seq =3D 0;
+	} else if (after(ack, tp->tlp_high_seq)) {
+		/* ACK advances: there was a loss, so reduce cwnd. Reset
+		 * tlp_high_seq in tcp_init_cwnd_reduction()
+		 */
+		tcp_init_cwnd_reduction(sk);
+		tcp_set_ca_state(sk, TCP_CA_CWR);
+		tcp_end_cwnd_reduction(sk);
+		tcp_try_keep_open(sk);
+		NET_INC_STATS_BH(sock_net(sk),
+				 LINUX_MIB_TCPLOSSPROBERECOVERY);
+	} else if (!(flag & (FLAG_SND_UNA_ADVANCED |
+			     FLAG_NOT_DUP | FLAG_DATA_SACKED))) {
+		/* Pure dupack: original and TLP probe arrived; no loss */
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
 	}
 }
=20
--=20
tg: (44d84d7..) net-next/tlp-dsack-handling (depends on: net-next/maste=
r)

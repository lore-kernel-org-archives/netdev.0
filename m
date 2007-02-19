From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 6/18] [TCP] FRTO: Use Disorder state during operation instead of Open
Date: Mon, 19 Feb 2007 13:38:00 +0200
Message-ID: <11718850921864-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11718850923446-git-send-email-ilpo.jarvinen@helsinki.fi> <1171885092563-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921459-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850923208-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921817-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922528-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Pasi Sarolahti <pasi.sarolahti@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46068 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932127AbXBSLiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 06:38:15 -0500
In-Reply-To: <11718850922528-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Retransmission counter assumptions are to be changed. Forcing
reason to do this exist: Using sysctl in check would be racy
as soon as FRTO starts to ignore some ACKs (doing that in the
following patches). Userspace may disable it at any moment
giving nice oops if timing is right. frto_counter would be
inaccessible from userspace, but with SACK enhanced FRTO
retrans_out can include other than head, and possibly leaving
it non-zero after spurious RTO, boom again.

Luckily, solution seems rather simple: never go directly to Open
state but use Disorder instead. This does not really change much,
since TCP could anyway change its state to Disorder during FRTO
using path tcp_fastretrans_alert -> tcp_try_to_open (e.g., when
a SACK block makes ACK dubious). Besides, Disorder seems to be
the state where TCP should be if not recovering (in Recovery or
Loss state) while having some retransmissions in-flight (see
tcp_try_to_open), which is exactly what happens with FRTO.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c846beb..d1e731f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1286,7 +1286,8 @@ void tcp_enter_frto(struct sock *sk)
 	}
 	tcp_sync_left_out(tp);
=20
-	tcp_set_ca_state(sk, TCP_CA_Open);
+	tcp_set_ca_state(sk, TCP_CA_Disorder);
+	tp->high_seq =3D tp->snd_nxt;
 	tp->frto_highmark =3D tp->snd_nxt;
 	tp->frto_counter =3D 1;
 }
@@ -2014,8 +2015,7 @@ tcp_fastretrans_alert(struct sock *sk, u
 	/* E. Check state exit conditions. State can be terminated
 	 *    when high_seq is ACKed. */
 	if (icsk->icsk_ca_state =3D=3D TCP_CA_Open) {
-		if (!sysctl_tcp_frto)
-			BUG_TRAP(tp->retrans_out =3D=3D 0);
+		BUG_TRAP(tp->retrans_out =3D=3D 0);
 		tp->retrans_stamp =3D 0;
 	} else if (!before(tp->snd_una, tp->high_seq)) {
 		switch (icsk->icsk_ca_state) {
--=20
1.4.2


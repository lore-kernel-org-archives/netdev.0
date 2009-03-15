From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 4/7] tcp: don't check mtu probe completion in the loop
Date: Sun, 15 Mar 2009 02:23:04 +0200
Message-ID: <1237076587615-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12370765872509-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12370765871159-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12370765873185-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57532 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752206AbZCOAXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 20:23:09 -0400
In-Reply-To: <12370765873185-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems that no variables clash such that we couldn't do
the check just once later on. Therefore move it.

Also kill dead obvious comment, dead argument and add
unlikely since this mtu probe does not happen too often.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b7d02c5..311c30f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2836,7 +2836,7 @@ static void tcp_mtup_probe_failed(struct sock *sk=
)
 	icsk->icsk_mtup.probe_size =3D 0;
 }
=20
-static void tcp_mtup_probe_success(struct sock *sk, struct sk_buff *sk=
b)
+static void tcp_mtup_probe_success(struct sock *sk)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct inet_connection_sock *icsk =3D inet_csk(sk);
@@ -3219,12 +3219,6 @@ static int tcp_clean_rtx_queue(struct sock *sk, =
int prior_fackets,
 			acked_pcount =3D tcp_skb_pcount(skb);
 		}
=20
-		/* MTU probing checks */
-		if (fully_acked && icsk->icsk_mtup.probe_size &&
-		    !after(tp->mtu_probe.probe_seq_end, scb->end_seq)) {
-			tcp_mtup_probe_success(sk, skb);
-		}
-
 		if (sacked & TCPCB_RETRANS) {
 			if (sacked & TCPCB_SACKED_RETRANS)
 				tp->retrans_out -=3D acked_pcount;
@@ -3287,6 +3281,11 @@ static int tcp_clean_rtx_queue(struct sock *sk, =
int prior_fackets,
 		const struct tcp_congestion_ops *ca_ops
 			=3D inet_csk(sk)->icsk_ca_ops;
=20
+		if (unlikely(icsk->icsk_mtup.probe_size &&
+			     !after(tp->mtu_probe.probe_seq_end, tp->snd_una))) {
+			tcp_mtup_probe_success(sk);
+		}
+
 		tcp_ack_update_rtt(sk, flag, seq_rtt);
 		tcp_rearm_rto(sk);
=20
--=20
1.5.6.5


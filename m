From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 15/15] tcp: back retransmit_high when it over-estimated
Date: Sat, 20 Sep 2008 20:52:33 +0300
Message-ID: <1221933153-11874-16-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1221933153-11874-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-5-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-6-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-7-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-8-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-9-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-10-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-11-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-12-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-13-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-14-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-15-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39329 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751112AbYITRwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 13:52:39 -0400
In-Reply-To: <1221933153-11874-15-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If lost skb is sacked, we might have nothing to retransmit
as high as the retransmit_high is pointing to, so place
it lower to avoid unnecessary walking.

This is mainly for the case where high L'ed skbs gets sacked.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 01fb610..727522c 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2037,16 +2037,22 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *skb;
 	struct sk_buff *hole =3D NULL;
+	u32 last_lost;
 	int mib_idx;
 	int fwd_rexmitting =3D 0;
=20
 	if (!tp->lost_out)
 		tp->retransmit_high =3D tp->snd_una;
=20
-	if (tp->retransmit_skb_hint)
+	if (tp->retransmit_skb_hint) {
 		skb =3D tp->retransmit_skb_hint;
-	else
+		last_lost =3D TCP_SKB_CB(skb)->end_seq;
+		if (after(last_lost, tp->retransmit_high))
+			last_lost =3D tp->retransmit_high;
+	} else {
 		skb =3D tcp_write_queue_head(sk);
+		last_lost =3D tp->snd_una;
+	}
=20
 	/* First pass: retransmit lost packets. */
 	tcp_for_write_queue_from(skb, sk) {
@@ -2075,6 +2081,7 @@ begin_fwd:
 			mib_idx =3D LINUX_MIB_TCPFORWARDRETRANS;
=20
 		} else if (!before(TCP_SKB_CB(skb)->seq, tp->retransmit_high)) {
+			tp->retransmit_high =3D last_lost;
 			if (!tcp_can_forward_retransmit(sk))
 				break;
 			/* Backtrack if necessary to non-L'ed skb */
@@ -2091,6 +2098,7 @@ begin_fwd:
 			continue;
=20
 		} else {
+			last_lost =3D TCP_SKB_CB(skb)->end_seq;
 			if (icsk->icsk_ca_state !=3D TCP_CA_Loss)
 				mib_idx =3D LINUX_MIB_TCPFASTRETRANS;
 			else
--=20
1.5.2.2


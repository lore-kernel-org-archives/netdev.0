From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 14/15] tcp: don't clear lost_skb_hint when not necessary
Date: Sat, 20 Sep 2008 20:52:32 +0300
Message-ID: <1221933153-11874-15-git-send-email-ilpo.jarvinen@helsinki.fi>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59235 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751296AbYITRwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 13:52:41 -0400
In-Reply-To: <1221933153-11874-14-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most importantly avoid doing it with cumulative ACK. However,
since we have lost_cnt_hint in the picture as well needing
adjustments, it's not as trivial as dealing with
retransmit_skb_hint (and cannot be done in the all place we
could trivially leave retransmit_skb_hint untouched).

With the previous patch, this should mostly remove O(n^2)
behavior while cumulative ACKs start flowing once rexmit
after a lossy round-trip made it through.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index f217b4f..9daeb07 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2844,6 +2844,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, i=
nt prior_fackets)
 	int flag =3D 0;
 	u32 pkts_acked =3D 0;
 	u32 reord =3D tp->packets_out;
+	u32 prior_sacked =3D tp->sacked_out;
 	s32 seq_rtt =3D -1;
 	s32 ca_seq_rtt =3D -1;
 	ktime_t last_ackt =3D net_invalid_timestamp();
@@ -2925,9 +2926,11 @@ static int tcp_clean_rtx_queue(struct sock *sk, =
int prior_fackets)
=20
 		tcp_unlink_write_queue(skb, sk);
 		sk_wmem_free_skb(sk, skb);
-		tcp_clear_retrans_hints_partial(tp);
+		tp->scoreboard_skb_hint =3D NULL;
 		if (skb =3D=3D tp->retransmit_skb_hint)
 			tp->retransmit_skb_hint =3D NULL;
+		if (skb =3D=3D tp->lost_skb_hint)
+			tp->lost_skb_hint =3D NULL;
 	}
=20
 	if (skb && (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
@@ -2946,6 +2949,15 @@ static int tcp_clean_rtx_queue(struct sock *sk, =
int prior_fackets)
 			/* Non-retransmitted hole got filled? That's reordering */
 			if (reord < prior_fackets)
 				tcp_update_reordering(sk, tp->fackets_out - reord, 0);
+
+			/* No need to care for underflows here because
+			 * the lost_skb_hint gets NULLed if we're past it
+			 * (or something non-trivial happened)
+			 */
+			if (tcp_is_fack(tp))
+				tp->lost_cnt_hint -=3D pkts_acked;
+			else
+				tp->lost_cnt_hint -=3D prior_sacked - tp->sacked_out;
 		}
=20
 		tp->fackets_out -=3D min(pkts_acked, tp->fackets_out);
--=20
1.5.2.2


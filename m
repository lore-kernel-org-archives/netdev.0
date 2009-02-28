From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 03/17] tcp: fix lost_cnt_hint miscounts
Date: Sat, 28 Feb 2009 16:44:28 +0200
Message-ID: <12358322823783-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12358322821815-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322821434-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1235832282317-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54623 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752514AbZB1Oop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2009 09:44:45 -0500
In-Reply-To: <1235832282317-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>

It is possible that lost_cnt_hint gets underflow in
tcp_clean_rtx_queue because the cumulative ACK can cover
the segment where lost_skb_hint points to only partially,
which means that the hint is not cleared, opposite to what
my (earlier) comment claimed.

Also I don't agree what I ended up writing about non-trivial
case there to be what I intented to say. It was not supposed
to happen that the hint won't get cleared and we underflow
in any scenario.

In general, this is quite hard to trigger in practice.

Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c28976a..3f2f090 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3273,18 +3273,15 @@ static int tcp_clean_rtx_queue(struct sock *sk,=
 int prior_fackets,
 		if (tcp_is_reno(tp)) {
 			tcp_remove_reno_sacks(sk, pkts_acked);
 		} else {
+			int delta;
+
 			/* Non-retransmitted hole got filled? That's reordering */
 			if (reord < prior_fackets)
 				tcp_update_reordering(sk, tp->fackets_out - reord, 0);
=20
-			/* No need to care for underflows here because
-			 * the lost_skb_hint gets NULLed if we're past it
-			 * (or something non-trivial happened)
-			 */
-			if (tcp_is_fack(tp))
-				tp->lost_cnt_hint -=3D pkts_acked;
-			else
-				tp->lost_cnt_hint -=3D prior_sacked - tp->sacked_out;
+			delta =3D tcp_is_fack(tp) ? pkts_acked :
+						  prior_sacked - tp->sacked_out;
+			tp->lost_cnt_hint -=3D min(tp->lost_cnt_hint, delta);
 		}
=20
 		tp->fackets_out -=3D min(pkts_acked, tp->fackets_out);
--=20
1.5.6.5


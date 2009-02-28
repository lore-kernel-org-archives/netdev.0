From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 07/17] tcp: remove redundant code from tcp_mark_lost_retrans
Date: Sat, 28 Feb 2009 16:44:32 +0200
Message-ID: <12358322831147-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12358322821815-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322821434-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1235832282317-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322823783-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322821182-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322832831-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322831953-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54623 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606AbZB1Oor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2009 09:44:47 -0500
In-Reply-To: <12358322831953-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>

Arnd Hannemann <hannemann@nets.rwth-aachen.de> noticed and was
puzzled by the fact that !tcp_is_fack(tp) leads to early return
near the beginning and the later on tcp_is_fack(tp) was still
used in an if condition. The later check was a left-over from
RFC3517 SACK stuff (=3D=3D !tcp_is_fack(tp) behavior nowadays) as
there wasn't clear way how to handle this particular check
cheaply in the spirit of RFC3517 (using only SACK blocks, not
holes + SACK blocks as with FACK). I sort of left it there as
a reminder but since it's confusing other people just remove
it and comment the missing-feature stuff instead.

Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
Cc: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
---
 net/ipv4/tcp_input.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 3f2f090..125b451 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1178,10 +1178,18 @@ static void tcp_mark_lost_retrans(struct sock *=
sk)
 		if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS))
 			continue;
=20
-		if (after(received_upto, ack_seq) &&
-		    (tcp_is_fack(tp) ||
-		     !before(received_upto,
-			     ack_seq + tp->reordering * tp->mss_cache))) {
+		/* TODO: We would like to get rid of tcp_is_fack(tp) only
+		 * constraint here (see above) but figuring out that at
+		 * least tp->reordering SACK blocks reside between ack_seq
+		 * and received_upto is not easy task to do cheaply with
+		 * the available datastructures.
+		 *
+		 * Whether FACK should check here for tp->reordering segs
+		 * in-between one could argue for either way (it would be
+		 * rather simple to implement as we could count fack_count
+		 * during the walk and do tp->fackets_out - fack_count).
+		 */
+		if (after(received_upto, ack_seq)) {
 			TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_SACKED_RETRANS;
 			tp->retrans_out -=3D tcp_skb_pcount(skb);
=20
--=20
1.5.6.5


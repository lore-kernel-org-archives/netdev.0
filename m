From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6 01/17] tcp: fix retrans_out leaks
Date: Sat, 28 Feb 2009 16:44:26 +0200
Message-ID: <12358322821434-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12358322821815-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56777 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752477AbZB1Oop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2009 09:44:45 -0500
In-Reply-To: <12358322821815-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>

There's conflicting assumptions in shifting, the caller assumes
that dupsack results in S'ed skbs (or a part of it) for sure but
never gave a hint to tcp_sacktag_one when dsack is actually in
use. Thus DSACK retrans_out -=3D pcount was not taken and the
counter became out of sync. Remove obstacle from that information
flow to get DSACKs accounted in tcp_sacktag_one as expected.

Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
Tested-by: Denys Fedoryshchenko <denys@visp.net.lb>
---
 net/ipv4/tcp_input.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a6961d7..c28976a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1374,7 +1374,8 @@ static u8 tcp_sacktag_one(struct sk_buff *skb, st=
ruct sock *sk,
=20
 static int tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
 			   struct tcp_sacktag_state *state,
-			   unsigned int pcount, int shifted, int mss)
+			   unsigned int pcount, int shifted, int mss,
+			   int dup_sack)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *prev =3D tcp_write_queue_prev(sk, skb);
@@ -1410,7 +1411,7 @@ static int tcp_shifted_skb(struct sock *sk, struc=
t sk_buff *skb,
 	}
=20
 	/* We discard results */
-	tcp_sacktag_one(skb, sk, state, 0, pcount);
+	tcp_sacktag_one(skb, sk, state, dup_sack, pcount);
=20
 	/* Difference in this won't matter, both ACKed by the same cumul. ACK=
 */
 	TCP_SKB_CB(prev)->sacked |=3D (TCP_SKB_CB(skb)->sacked & TCPCB_EVER_R=
ETRANS);
@@ -1561,7 +1562,7 @@ static struct sk_buff *tcp_shift_skb_data(struct =
sock *sk, struct sk_buff *skb,
=20
 	if (!skb_shift(prev, skb, len))
 		goto fallback;
-	if (!tcp_shifted_skb(sk, skb, state, pcount, len, mss))
+	if (!tcp_shifted_skb(sk, skb, state, pcount, len, mss, dup_sack))
 		goto out;
=20
 	/* Hole filled allows collapsing with the next as well, this is very
@@ -1580,7 +1581,7 @@ static struct sk_buff *tcp_shift_skb_data(struct =
sock *sk, struct sk_buff *skb,
 	len =3D skb->len;
 	if (skb_shift(prev, skb, len)) {
 		pcount +=3D tcp_skb_pcount(skb);
-		tcp_shifted_skb(sk, skb, state, tcp_skb_pcount(skb), len, mss);
+		tcp_shifted_skb(sk, skb, state, tcp_skb_pcount(skb), len, mss, 0);
 	}
=20
 out:
--=20
1.5.6.5


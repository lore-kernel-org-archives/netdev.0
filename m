From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 05/10] tcp: make tcp_sacktag_one able to handle partial skb too
Date: Mon, 24 Nov 2008 16:22:02 +0200
Message-ID: <1227536527-29713-6-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1227536527-29713-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-5-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54925 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753087AbYKXOWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 09:22:12 -0500
In-Reply-To: <1227536527-29713-5-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is preparatory work for SACK combiner patch which may
have to count TCP state changes for only a part of the skb
because it will intentionally avoids splitting skb to SACKed
and not sacked parts.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   32 +++++++++++++++++---------------
 1 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 5e1e121..94533e4 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1288,7 +1288,8 @@ static int tcp_match_skb_to_sack(struct sock *sk,=
 struct sk_buff *skb,
 }
=20
 static int tcp_sacktag_one(struct sk_buff *skb, struct sock *sk,
-			   int *reord, int dup_sack, int fack_count)
+			   int *reord, int dup_sack, int fack_count,
+			   u8 *sackedto, int pcount)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	u8 sacked =3D TCP_SKB_CB(skb)->sacked;
@@ -1313,10 +1314,9 @@ static int tcp_sacktag_one(struct sk_buff *skb, =
struct sock *sk,
 			 * that retransmission is still in flight.
 			 */
 			if (sacked & TCPCB_LOST) {
-				TCP_SKB_CB(skb)->sacked &=3D
-					~(TCPCB_LOST|TCPCB_SACKED_RETRANS);
-				tp->lost_out -=3D tcp_skb_pcount(skb);
-				tp->retrans_out -=3D tcp_skb_pcount(skb);
+				*sackedto &=3D ~(TCPCB_LOST|TCPCB_SACKED_RETRANS);
+				tp->lost_out -=3D pcount;
+				tp->retrans_out -=3D pcount;
 			}
 		} else {
 			if (!(sacked & TCPCB_RETRANS)) {
@@ -1333,22 +1333,22 @@ static int tcp_sacktag_one(struct sk_buff *skb,=
 struct sock *sk,
 			}
=20
 			if (sacked & TCPCB_LOST) {
-				TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_LOST;
-				tp->lost_out -=3D tcp_skb_pcount(skb);
+				*sackedto &=3D ~TCPCB_LOST;
+				tp->lost_out -=3D pcount;
 			}
 		}
=20
-		TCP_SKB_CB(skb)->sacked |=3D TCPCB_SACKED_ACKED;
+		*sackedto |=3D TCPCB_SACKED_ACKED;
 		flag |=3D FLAG_DATA_SACKED;
-		tp->sacked_out +=3D tcp_skb_pcount(skb);
+		tp->sacked_out +=3D pcount;
=20
-		fack_count +=3D tcp_skb_pcount(skb);
+		fack_count +=3D pcount;
=20
 		/* Lost marker hint past SACKed? Tweak RFC3517 cnt */
 		if (!tcp_is_fack(tp) && (tp->lost_skb_hint !=3D NULL) &&
 		    before(TCP_SKB_CB(skb)->seq,
 			   TCP_SKB_CB(tp->lost_skb_hint)->seq))
-			tp->lost_cnt_hint +=3D tcp_skb_pcount(skb);
+			tp->lost_cnt_hint +=3D pcount;
=20
 		if (fack_count > tp->fackets_out)
 			tp->fackets_out =3D fack_count;
@@ -1361,9 +1361,9 @@ static int tcp_sacktag_one(struct sk_buff *skb, s=
truct sock *sk,
 	 * frames and clear it. undo_retrans is decreased above, L|R frames
 	 * are accounted above as well.
 	 */
-	if (dup_sack && (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS)) {
-		TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_SACKED_RETRANS;
-		tp->retrans_out -=3D tcp_skb_pcount(skb);
+	if (dup_sack && (*sackedto & TCPCB_SACKED_RETRANS)) {
+		*sackedto &=3D ~TCPCB_SACKED_RETRANS;
+		tp->retrans_out -=3D pcount;
 	}
=20
 	return flag;
@@ -1403,7 +1403,9 @@ static struct sk_buff *tcp_sacktag_walk(struct sk=
_buff *skb, struct sock *sk,
=20
 		if (in_sack)
 			*flag |=3D tcp_sacktag_one(skb, sk, reord, dup_sack,
-						 *fack_count);
+						 *fack_count,
+						 &(TCP_SKB_CB(skb)->sacked),
+						 tcp_skb_pcount(skb));
=20
 		*fack_count +=3D tcp_skb_pcount(skb);
 	}
--=20
1.5.2.2


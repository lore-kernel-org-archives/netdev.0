From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 03/10] tcp: make mtu probe failure to not break gso'ed skbs unnecessarily
Date: Fri,  5 Dec 2008 22:58:49 +0200
Message-ID: <1228510736-3655-4-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1228510736-3655-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-3-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50779 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121AbYLEU66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 15:58:58 -0500
In-Reply-To: <1228510736-3655-3-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I noticed that since skb->len has nothing to do with actual segment
length with gso, we need to figure it out separately, reuse
a function from the recent shifting stuff (generalize it).

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   19 +++++++------------
 1 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 33902f6..21c6701 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1445,14 +1445,9 @@ static int tcp_shifted_skb(struct sock *sk, stru=
ct sk_buff *prev,
 /* I wish gso_size would have a bit more sane initialization than
  * something-or-zero which complicates things
  */
-static int tcp_shift_mss(struct sk_buff *skb)
+static int tcp_skb_seglen(struct sk_buff *skb)
 {
-	int mss =3D tcp_skb_mss(skb);
-
-	if (!mss)
-		mss =3D skb->len;
-
-	return mss;
+	return tcp_skb_pcount(skb) =3D=3D 1 ? skb->len : tcp_skb_mss(skb);
 }
=20
 /* Shifting pages past head area doesn't work */
@@ -1503,12 +1498,12 @@ static struct sk_buff *tcp_shift_skb_data(struc=
t sock *sk, struct sk_buff *skb,
 	if (in_sack) {
 		len =3D skb->len;
 		pcount =3D tcp_skb_pcount(skb);
-		mss =3D tcp_shift_mss(skb);
+		mss =3D tcp_skb_seglen(skb);
=20
 		/* TODO: Fix DSACKs to not fragment already SACKed and we can
 		 * drop this restriction as unnecessary
 		 */
-		if (mss !=3D tcp_shift_mss(prev))
+		if (mss !=3D tcp_skb_seglen(prev))
 			goto fallback;
 	} else {
 		if (!after(TCP_SKB_CB(skb)->end_seq, start_seq))
@@ -1549,7 +1544,7 @@ static struct sk_buff *tcp_shift_skb_data(struct =
sock *sk, struct sk_buff *skb,
 		/* TODO: Fix DSACKs to not fragment already SACKed and we can
 		 * drop this restriction as unnecessary
 		 */
-		if (mss !=3D tcp_shift_mss(prev))
+		if (mss !=3D tcp_skb_seglen(prev))
 			goto fallback;
=20
 		if (len =3D=3D mss) {
@@ -1578,7 +1573,7 @@ static struct sk_buff *tcp_shift_skb_data(struct =
sock *sk, struct sk_buff *skb,
 	if (!skb_can_shift(skb) ||
 	    (skb =3D=3D tcp_send_head(sk)) ||
 	    ((TCP_SKB_CB(skb)->sacked & TCPCB_TAGBITS) !=3D TCPCB_SACKED_ACKE=
D) ||
-	    (mss !=3D tcp_shift_mss(skb)))
+	    (mss !=3D tcp_skb_seglen(skb)))
 		goto out;
=20
 	len =3D skb->len;
@@ -2853,7 +2848,7 @@ void tcp_simple_retransmit(struct sock *sk)
 	tcp_for_write_queue(skb, sk) {
 		if (skb =3D=3D tcp_send_head(sk))
 			break;
-		if (skb->len > mss &&
+		if (tcp_skb_seglen(skb) > mss &&
 		    !(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)) {
 			if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS) {
 				TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_SACKED_RETRANS;
--=20
1.5.2.2


From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 07/10] tcp: Make shifting not clear the hints
Date: Mon, 24 Nov 2008 16:22:04 +0200
Message-ID: <1227536527-29713-8-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1227536527-29713-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-5-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-6-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-7-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35317 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753090AbYKXOWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 09:22:11 -0500
In-Reply-To: <1227536527-29713-7-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The earlier version was just very basic one which is "playing
safe" by always clearing the hints. However, clearing of a hint
is extremely costly operation with large windows, so it must be
avoided at all cost whenever possible, there is a way with
shifting too achieve not-clearing.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 8106421..1f73cda 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1378,6 +1378,11 @@ static int tcp_shifted_skb(struct sock *sk, stru=
ct sk_buff *prev,
=20
 	BUG_ON(!pcount);
=20
+	/* Tweak before seqno plays */
+	if (!tcp_is_fack(tp) && tcp_is_sack(tp) && tp->lost_skb_hint &&
+	    !before(TCP_SKB_CB(tp->lost_skb_hint)->seq, TCP_SKB_CB(skb)->seq)=
)
+		tp->lost_cnt_hint +=3D pcount;
+
 	TCP_SKB_CB(prev)->end_seq +=3D shifted;
 	TCP_SKB_CB(skb)->seq +=3D shifted;
=20
@@ -1407,8 +1412,6 @@ static int tcp_shifted_skb(struct sock *sk, struc=
t sk_buff *prev,
 	/* Difference in this won't matter, both ACKed by the same cumul. ACK=
 */
 	TCP_SKB_CB(prev)->sacked |=3D (TCP_SKB_CB(skb)->sacked & TCPCB_EVER_R=
ETRANS);
=20
-	tcp_clear_all_retrans_hints(tp);
-
 	if (skb->len > 0) {
 		BUG_ON(!tcp_skb_pcount(skb));
 		return 0;
@@ -1416,6 +1419,15 @@ static int tcp_shifted_skb(struct sock *sk, stru=
ct sk_buff *prev,
=20
 	/* Whole SKB was eaten :-) */
=20
+	if (skb =3D=3D tp->retransmit_skb_hint)
+		tp->retransmit_skb_hint =3D prev;
+	if (skb =3D=3D tp->scoreboard_skb_hint)
+		tp->scoreboard_skb_hint =3D prev;
+	if (skb =3D=3D tp->lost_skb_hint) {
+		tp->lost_skb_hint =3D prev;
+		tp->lost_cnt_hint -=3D tcp_skb_pcount(prev);
+	}
+
 	TCP_SKB_CB(skb)->flags |=3D TCP_SKB_CB(prev)->flags;
 	if (skb =3D=3D tcp_highest_sack(sk))
 		tcp_advance_highest_sack(sk, skb);
--=20
1.5.2.2


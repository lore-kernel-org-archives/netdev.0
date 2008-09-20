From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCHv2 net-next 03/15] tcp: add helper for lost bit toggling
Date: Sun, 21 Sep 2008 00:47:46 +0300
Message-ID: <1221947278-16715-4-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1221947278-16715-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-3-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56256 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751470AbYITVsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 17:48:01 -0400
In-Reply-To: <1221947278-16715-3-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This useful because we'd need to verifying soon in many places
which makes things slightly more complex than it used to be.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   22 ++++++++++++----------
 1 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9e95ad6..1251233 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -992,6 +992,16 @@ static void tcp_verify_retransmit_hint(struct tcp_=
sock *tp, struct sk_buff *skb)
 		tp->retransmit_skb_hint =3D NULL;
 }
=20
+static void tcp_skb_mark_lost(struct tcp_sock *tp, struct sk_buff *skb=
)
+{
+	if (!(TCP_SKB_CB(skb)->sacked & (TCPCB_LOST|TCPCB_SACKED_ACKED))) {
+		tcp_verify_retransmit_hint(tp, skb);
+
+		tp->lost_out +=3D tcp_skb_pcount(skb);
+		TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
+	}
+}
+
 /* This procedure tags the retransmission queue when SACKs arrive.
  *
  * We have three tag bits: SACKED(S), RETRANS(R) and LOST(L).
@@ -2216,11 +2226,7 @@ static void tcp_mark_head_lost(struct sock *sk, =
int packets)
 			cnt =3D packets;
 		}
=20
-		if (!(TCP_SKB_CB(skb)->sacked & (TCPCB_SACKED_ACKED|TCPCB_LOST))) {
-			TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
-			tp->lost_out +=3D tcp_skb_pcount(skb);
-			tcp_verify_retransmit_hint(tp, skb);
-		}
+		tcp_skb_mark_lost(tp, skb);
 	}
 	tcp_verify_left_out(tp);
 }
@@ -2262,11 +2268,7 @@ static void tcp_update_scoreboard(struct sock *s=
k, int fast_rexmit)
 			if (!tcp_skb_timedout(sk, skb))
 				break;
=20
-			if (!(TCP_SKB_CB(skb)->sacked & (TCPCB_SACKED_ACKED|TCPCB_LOST))) {
-				TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
-				tp->lost_out +=3D tcp_skb_pcount(skb);
-				tcp_verify_retransmit_hint(tp, skb);
-			}
+			tcp_skb_mark_lost(tp, skb);
 		}
=20
 		tp->scoreboard_skb_hint =3D skb;
--=20
1.5.2.2


From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCHv5 2/5] [TCP]: Extracted rexmit hint clearing from the LOST marking code
Date: Fri, 16 Mar 2007 20:41:03 +0200
Message-ID: <11740704663404-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11740704663475-git-send-email-ilpo.jarvinen@helsinki.fi> <11740704662337-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56120 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753587AbXCPSlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 14:41:09 -0400
In-Reply-To: <11740704662337-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   31 ++++++++++++++++---------------
 1 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index dbc98ce..870404b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1733,6 +1733,20 @@ static inline void tcp_reset_reno_sack(s
 	tp->left_out =3D tp->lost_out;
 }
=20
+/* RFC: This is from the original, I doubt that this is necessary at a=
ll:
+ * clear xmit_retrans hint if seq of this skb is beyond hint. How coul=
d we
+ * retransmitted past LOST markings in the first place? I'm not fully =
sure
+ * about undo and end of connection cases, which can cause R without L=
?
+ */
+static void tcp_verify_retransmit_hint(struct tcp_sock *tp,
+				       struct sk_buff *skb)
+{
+	if ((tp->retransmit_skb_hint !=3D NULL) &&
+	    before(TCP_SKB_CB(skb)->seq,
+	    TCP_SKB_CB(tp->retransmit_skb_hint)->seq))
+		tp->retransmit_skb_hint =3D skb;
+}
+
 /* Mark head of queue up as lost. */
 static void tcp_mark_head_lost(struct sock *sk, struct tcp_sock *tp,
 			       int packets, u32 high_seq)
@@ -1762,14 +1776,7 @@ static void tcp_mark_head_lost(struct so
 		if (!(TCP_SKB_CB(skb)->sacked&TCPCB_TAGBITS)) {
 			TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
 			tp->lost_out +=3D tcp_skb_pcount(skb);
-
-			/* clear xmit_retransmit_queue hints
-			 *  if this is beyond hint */
-			if (tp->retransmit_skb_hint !=3D NULL &&
-			    before(TCP_SKB_CB(skb)->seq,
-				   TCP_SKB_CB(tp->retransmit_skb_hint)->seq))
-				tp->retransmit_skb_hint =3D NULL;
-
+			tcp_verify_retransmit_hint(tp, skb);
 		}
 	}
 	tcp_sync_left_out(tp);
@@ -1808,13 +1815,7 @@ static void tcp_update_scoreboard(struct
 			if (!(TCP_SKB_CB(skb)->sacked&TCPCB_TAGBITS)) {
 				TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
 				tp->lost_out +=3D tcp_skb_pcount(skb);
-
-				/* clear xmit_retrans hint */
-				if (tp->retransmit_skb_hint &&
-				    before(TCP_SKB_CB(skb)->seq,
-					   TCP_SKB_CB(tp->retransmit_skb_hint)->seq))
-
-					tp->retransmit_skb_hint =3D NULL;
+				tcp_verify_retransmit_hint(tp, skb);
 			}
 		}
=20
--=20
1.4.2


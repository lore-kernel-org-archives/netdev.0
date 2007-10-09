From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [TCP]: Separate lost_retrans loop into own function
Date: Tue,  9 Oct 2007 15:20:00 +0300
Message-ID: <11919324023846-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11919324023597-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	TAKANO Ryousei <takano@axe-inc.co.jp>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41551 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752449AbXJIMUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 08:20:04 -0400
In-Reply-To: <11919324023597-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46ollows own function for each task principle, this is really
somewhat separate task being done in sacktag. Also reduces
indentation.

In addition, added ack_seq local var to break some long
lines & fixed coding style things.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   80 +++++++++++++++++++++++++++---------------=
--------
 1 files changed, 43 insertions(+), 37 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a04e78e..56aa34a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1106,6 +1106,47 @@ static int tcp_is_sackblock_valid(struct tcp_soc=
k *tp, int is_dsack,
 	return !before(start_seq, end_seq - tp->max_window);
 }
=20
+/* Check for lost retransmit. This superb idea is borrowed from "rateh=
alving".
+ * Event "C". Later note: FACK people cheated me again 8), we have to =
account
+ * for reordering! Ugly, but should help.
+ */
+static int tcp_mark_lost_retrans(struct sock *sk, u32 lost_retrans)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	struct sk_buff *skb;
+	int flag =3D 0;
+
+	tcp_for_write_queue(skb, sk) {
+		u32 ack_seq =3D TCP_SKB_CB(skb)->ack_seq;
+
+		if (skb =3D=3D tcp_send_head(sk))
+			break;
+		if (after(TCP_SKB_CB(skb)->seq, lost_retrans))
+			break;
+		if (!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una))
+			continue;
+
+		if ((TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS) &&
+		    after(lost_retrans, ack_seq) &&
+		    (tcp_is_fack(tp) ||
+		     !before(lost_retrans,
+			     ack_seq + tp->reordering * tp->mss_cache))) {
+			TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_SACKED_RETRANS;
+			tp->retrans_out -=3D tcp_skb_pcount(skb);
+
+			/* clear lost hint */
+			tp->retransmit_skb_hint =3D NULL;
+
+			if (!(TCP_SKB_CB(skb)->sacked & (TCPCB_LOST|TCPCB_SACKED_ACKED))) {
+				tp->lost_out +=3D tcp_skb_pcount(skb);
+				TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
+				flag |=3D FLAG_DATA_SACKED;
+				NET_INC_STATS_BH(LINUX_MIB_TCPLOSTRETRANSMIT);
+			}
+		}
+	}
+	return flag;
+}
=20
 static int tcp_check_dsack(struct tcp_sock *tp, struct sk_buff *ack_sk=
b,
 			   struct tcp_sack_block_wire *sp, int num_sacks,
@@ -1422,43 +1463,8 @@ tcp_sacktag_write_queue(struct sock *sk, struct =
sk_buff *ack_skb, u32 prior_snd_
 		}
 	}
=20
-	/* Check for lost retransmit. This superb idea is
-	 * borrowed from "ratehalving". Event "C".
-	 * Later note: FACK people cheated me again 8),
-	 * we have to account for reordering! Ugly,
-	 * but should help.
-	 */
-	if (lost_retrans && icsk->icsk_ca_state =3D=3D TCP_CA_Recovery) {
-		struct sk_buff *skb;
-
-		tcp_for_write_queue(skb, sk) {
-			if (skb =3D=3D tcp_send_head(sk))
-				break;
-			if (after(TCP_SKB_CB(skb)->seq, lost_retrans))
-				break;
-			if (!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una))
-				continue;
-			if ((TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_RETRANS) &&
-			    after(lost_retrans, TCP_SKB_CB(skb)->ack_seq) &&
-			    (tcp_is_fack(tp) ||
-			     !before(lost_retrans,
-				     TCP_SKB_CB(skb)->ack_seq + tp->reordering *
-				     tp->mss_cache))) {
-				TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_SACKED_RETRANS;
-				tp->retrans_out -=3D tcp_skb_pcount(skb);
-
-				/* clear lost hint */
-				tp->retransmit_skb_hint =3D NULL;
-
-				if (!(TCP_SKB_CB(skb)->sacked&(TCPCB_LOST|TCPCB_SACKED_ACKED))) {
-					tp->lost_out +=3D tcp_skb_pcount(skb);
-					TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
-					flag |=3D FLAG_DATA_SACKED;
-					NET_INC_STATS_BH(LINUX_MIB_TCPLOSTRETRANSMIT);
-				}
-			}
-		}
-	}
+	if (lost_retrans && icsk->icsk_ca_state =3D=3D TCP_CA_Recovery)
+		flag |=3D tcp_mark_lost_retrans(sk, lost_retrans);
=20
 	tcp_verify_left_out(tp);
=20
--=20
1.5.0.6


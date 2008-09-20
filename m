From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCHv2 net-next 11/15] tcp: reorganize retransmit code loops
Date: Sun, 21 Sep 2008 00:47:54 +0300
Message-ID: <1221947278-16715-12-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1221947278-16715-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-5-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-6-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-7-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-8-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-9-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-10-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-11-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39570 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751796AbYITVsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 17:48:07 -0400
In-Reply-To: <1221947278-16715-11-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both loops are quite similar, so they can be combined
with little effort. As a result, forward_skb_hint becomes
obsolete as well.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/tcp.h   |    1 -
 include/net/tcp.h     |    1 -
 net/ipv4/tcp_output.c |   79 ++++++++++++++++++++---------------------=
-------
 3 files changed, 33 insertions(+), 48 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index d7637c4..7672906 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -342,7 +342,6 @@ struct tcp_sock {
 	struct sk_buff* lost_skb_hint;
 	struct sk_buff *scoreboard_skb_hint;
 	struct sk_buff *retransmit_skb_hint;
-	struct sk_buff *forward_skb_hint;
=20
 	struct sk_buff_head	out_of_order_queue; /* Out of order segments go h=
ere */
=20
diff --git a/include/net/tcp.h b/include/net/tcp.h
index d0e90c5..220f54c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1042,7 +1042,6 @@ static inline void tcp_clear_all_retrans_hints(st=
ruct tcp_sock *tp)
 	tp->lost_skb_hint =3D NULL;
 	tp->scoreboard_skb_hint =3D NULL;
 	tp->retransmit_skb_hint =3D NULL;
-	tp->forward_skb_hint =3D NULL;
 }
=20
 /* MD5 Signature */
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index bee31ff..cd83713 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2030,7 +2030,9 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 	const struct inet_connection_sock *icsk =3D inet_csk(sk);
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *skb;
+	struct sk_buff *hole =3D NULL;
 	int mib_idx;
+	int fwd_rexmitting =3D 0;
=20
 	if (!tp->lost_out)
 		tp->retransmit_high =3D tp->snd_una;
@@ -2047,7 +2049,8 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 		if (skb =3D=3D tcp_send_head(sk))
 			break;
 		/* we could do better than to assign each time */
-		tp->retransmit_skb_hint =3D skb;
+		if (hole =3D=3D NULL)
+			tp->retransmit_skb_hint =3D skb;
=20
 		/* Assume this retransmit will generate
 		 * only one packet for congestion window
@@ -2058,65 +2061,49 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 		 */
 		if (tcp_packets_in_flight(tp) >=3D tp->snd_cwnd)
 			return;
-		if (!before(TCP_SKB_CB(skb)->seq, tp->retransmit_high))
-			break;
-		if (sacked & (TCPCB_SACKED_ACKED|TCPCB_SACKED_RETRANS))
-			continue;
-
-		if (!(sacked & TCPCB_LOST))
-			continue;
-
-		if (tcp_retransmit_skb(sk, skb)) {
-			tp->retransmit_skb_hint =3D NULL;
-			return;
-		}
-		if (icsk->icsk_ca_state !=3D TCP_CA_Loss)
-			mib_idx =3D LINUX_MIB_TCPFASTRETRANS;
-		else
-			mib_idx =3D LINUX_MIB_TCPSLOWSTARTRETRANS;
-		NET_INC_STATS_BH(sock_net(sk), mib_idx);
-
-		if (skb =3D=3D tcp_write_queue_head(sk))
-			inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
-						  inet_csk(sk)->icsk_rto,
-						  TCP_RTO_MAX);
-	}
-
-	/* OK, demanded retransmission is finished. */
-	if (!tcp_can_forward_retransmit(sk))
-		return;
=20
-	if (tp->forward_skb_hint)
-		skb =3D tp->forward_skb_hint;
-	else
-		skb =3D tcp_write_queue_head(sk);
+		if (fwd_rexmitting) {
+begin_fwd:
+			if (!before(TCP_SKB_CB(skb)->seq, tcp_highest_sack_seq(tp)))
+				break;
+			mib_idx =3D LINUX_MIB_TCPFORWARDRETRANS;
=20
-	tcp_for_write_queue_from(skb, sk) {
-		if (skb =3D=3D tcp_send_head(sk))
-			break;
-		tp->forward_skb_hint =3D skb;
+		} else if (!before(TCP_SKB_CB(skb)->seq, tp->retransmit_high)) {
+			if (!tcp_can_forward_retransmit(sk))
+				break;
+			/* Backtrack if necessary to non-L'ed skb */
+			if (hole !=3D NULL) {
+				skb =3D hole;
+				hole =3D NULL;
+			}
+			fwd_rexmitting =3D 1;
+			goto begin_fwd;
=20
-		if (!before(TCP_SKB_CB(skb)->seq, tcp_highest_sack_seq(tp)))
-			break;
+		} else if (!(sacked & TCPCB_LOST)) {
+			if (hole =3D=3D NULL && !(sacked & TCPCB_SACKED_RETRANS))
+				hole =3D skb;
+			continue;
=20
-		if (tcp_packets_in_flight(tp) >=3D tp->snd_cwnd)
-			break;
+		} else {
+			if (icsk->icsk_ca_state !=3D TCP_CA_Loss)
+				mib_idx =3D LINUX_MIB_TCPFASTRETRANS;
+			else
+				mib_idx =3D LINUX_MIB_TCPSLOWSTARTRETRANS;
+		}
=20
-		if (TCP_SKB_CB(skb)->sacked & TCPCB_TAGBITS)
+		if (sacked & (TCPCB_SACKED_ACKED|TCPCB_SACKED_RETRANS))
 			continue;
=20
-		/* Ok, retransmit it. */
 		if (tcp_retransmit_skb(sk, skb)) {
-			tp->forward_skb_hint =3D NULL;
-			break;
+			tp->retransmit_skb_hint =3D NULL;
+			return;
 		}
+		NET_INC_STATS_BH(sock_net(sk), mib_idx);
=20
 		if (skb =3D=3D tcp_write_queue_head(sk))
 			inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
 						  inet_csk(sk)->icsk_rto,
 						  TCP_RTO_MAX);
-
-		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPFORWARDRETRANS);
 	}
 }
=20
--=20
1.5.2.2


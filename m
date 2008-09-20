From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 09/15] tcp: Reorganize skb tagbit checks
Date: Sat, 20 Sep 2008 20:52:27 +0300
Message-ID: <1221933153-11874-10-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1221933153-11874-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-5-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-6-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-7-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-8-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-9-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37645 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127AbYITRwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 13:52:39 -0400
In-Reply-To: <1221933153-11874-9-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |   38 +++++++++++++++++++-------------------
 1 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8d4859a..d5f53f8 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2034,6 +2034,7 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 	const struct inet_connection_sock *icsk =3D inet_csk(sk);
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *skb;
+	int mib_idx;
=20
 	if (tp->retransmit_skb_hint)
 		skb =3D tp->retransmit_skb_hint;
@@ -2061,27 +2062,26 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 				return;
 			if (!before(TCP_SKB_CB(skb)->seq, tp->retransmit_high))
 				break;
+			if (sacked & (TCPCB_SACKED_ACKED|TCPCB_SACKED_RETRANS))
+				continue;
=20
-			if (sacked & TCPCB_LOST) {
-				if (!(sacked & (TCPCB_SACKED_ACKED|TCPCB_SACKED_RETRANS))) {
-					int mib_idx;
-
-					if (tcp_retransmit_skb(sk, skb)) {
-						tp->retransmit_skb_hint =3D NULL;
-						return;
-					}
-					if (icsk->icsk_ca_state !=3D TCP_CA_Loss)
-						mib_idx =3D LINUX_MIB_TCPFASTRETRANS;
-					else
-						mib_idx =3D LINUX_MIB_TCPSLOWSTARTRETRANS;
-					NET_INC_STATS_BH(sock_net(sk), mib_idx);
-
-					if (skb =3D=3D tcp_write_queue_head(sk))
-						inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
-									  inet_csk(sk)->icsk_rto,
-									  TCP_RTO_MAX);
-				}
+			if (!(sacked & TCPCB_LOST))
+				continue;
+
+			if (tcp_retransmit_skb(sk, skb)) {
+				tp->retransmit_skb_hint =3D NULL;
+				return;
 			}
+			if (icsk->icsk_ca_state !=3D TCP_CA_Loss)
+				mib_idx =3D LINUX_MIB_TCPFASTRETRANS;
+			else
+				mib_idx =3D LINUX_MIB_TCPSLOWSTARTRETRANS;
+			NET_INC_STATS_BH(sock_net(sk), mib_idx);
+
+			if (skb =3D=3D tcp_write_queue_head(sk))
+				inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
+							  inet_csk(sk)->icsk_rto,
+							  TCP_RTO_MAX);
 		}
 	}
=20
--=20
1.5.2.2


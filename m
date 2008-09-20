From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCHv2 net-next 10/15] tcp: remove tp->lost_out guard to make joining diff nicer
Date: Sun, 21 Sep 2008 00:47:53 +0300
Message-ID: <1221947278-16715-11-git-send-email-ilpo.jarvinen@helsinki.fi>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36807 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751694AbYITVsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 17:48:05 -0400
In-Reply-To: <1221947278-16715-10-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The validity of the retransmit_high must then be ensured
if no L'ed skb exits!

This makes a minor change to behavior, we now have to
iterate the head to find out that the loop terminates.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |   75 +++++++++++++++++++++++++----------------=
--------
 1 files changed, 38 insertions(+), 37 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index efe3c58..bee31ff 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2032,53 +2032,54 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 	struct sk_buff *skb;
 	int mib_idx;
=20
+	if (!tp->lost_out)
+		tp->retransmit_high =3D tp->snd_una;
+
 	if (tp->retransmit_skb_hint)
 		skb =3D tp->retransmit_skb_hint;
 	else
 		skb =3D tcp_write_queue_head(sk);
=20
 	/* First pass: retransmit lost packets. */
-	if (tp->lost_out) {
-		tcp_for_write_queue_from(skb, sk) {
-			__u8 sacked =3D TCP_SKB_CB(skb)->sacked;
+	tcp_for_write_queue_from(skb, sk) {
+		__u8 sacked =3D TCP_SKB_CB(skb)->sacked;
=20
-			if (skb =3D=3D tcp_send_head(sk))
-				break;
-			/* we could do better than to assign each time */
-			tp->retransmit_skb_hint =3D skb;
-
-			/* Assume this retransmit will generate
-			 * only one packet for congestion window
-			 * calculation purposes.  This works because
-			 * tcp_retransmit_skb() will chop up the
-			 * packet to be MSS sized and all the
-			 * packet counting works out.
-			 */
-			if (tcp_packets_in_flight(tp) >=3D tp->snd_cwnd)
-				return;
-			if (!before(TCP_SKB_CB(skb)->seq, tp->retransmit_high))
-				break;
-			if (sacked & (TCPCB_SACKED_ACKED|TCPCB_SACKED_RETRANS))
-				continue;
+		if (skb =3D=3D tcp_send_head(sk))
+			break;
+		/* we could do better than to assign each time */
+		tp->retransmit_skb_hint =3D skb;
+
+		/* Assume this retransmit will generate
+		 * only one packet for congestion window
+		 * calculation purposes.  This works because
+		 * tcp_retransmit_skb() will chop up the
+		 * packet to be MSS sized and all the
+		 * packet counting works out.
+		 */
+		if (tcp_packets_in_flight(tp) >=3D tp->snd_cwnd)
+			return;
+		if (!before(TCP_SKB_CB(skb)->seq, tp->retransmit_high))
+			break;
+		if (sacked & (TCPCB_SACKED_ACKED|TCPCB_SACKED_RETRANS))
+			continue;
=20
-			if (!(sacked & TCPCB_LOST))
-				continue;
+		if (!(sacked & TCPCB_LOST))
+			continue;
=20
-			if (tcp_retransmit_skb(sk, skb)) {
-				tp->retransmit_skb_hint =3D NULL;
-				return;
-			}
-			if (icsk->icsk_ca_state !=3D TCP_CA_Loss)
-				mib_idx =3D LINUX_MIB_TCPFASTRETRANS;
-			else
-				mib_idx =3D LINUX_MIB_TCPSLOWSTARTRETRANS;
-			NET_INC_STATS_BH(sock_net(sk), mib_idx);
-
-			if (skb =3D=3D tcp_write_queue_head(sk))
-				inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
-							  inet_csk(sk)->icsk_rto,
-							  TCP_RTO_MAX);
+		if (tcp_retransmit_skb(sk, skb)) {
+			tp->retransmit_skb_hint =3D NULL;
+			return;
 		}
+		if (icsk->icsk_ca_state !=3D TCP_CA_Loss)
+			mib_idx =3D LINUX_MIB_TCPFASTRETRANS;
+		else
+			mib_idx =3D LINUX_MIB_TCPSLOWSTARTRETRANS;
+		NET_INC_STATS_BH(sock_net(sk), mib_idx);
+
+		if (skb =3D=3D tcp_write_queue_head(sk))
+			inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
+						  inet_csk(sk)->icsk_rto,
+						  TCP_RTO_MAX);
 	}
=20
 	/* OK, demanded retransmission is finished. */
--=20
1.5.2.2


From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/9] [TCP]: Rename update_send_head & include related increment to it
Date: Mon, 31 Dec 2007 12:47:50 +0200
Message-ID: <11990980773391-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11990980772344-git-send-email-ilpo.jarvinen@helsinki.fi> <1199098077874-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46986 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755524AbXLaKr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 05:47:59 -0500
In-Reply-To: <1199098077874-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's very little need to have the packets_out incrementing in
a separate function. Also name the combined function
appropriately.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |   32 ++++++++++++--------------------
 1 files changed, 12 insertions(+), 20 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 7a4834a..1ca638b 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -61,29 +61,22 @@ int sysctl_tcp_base_mss __read_mostly =3D 512;
 /* By default, RFC2861 behavior.  */
 int sysctl_tcp_slow_start_after_idle __read_mostly =3D 1;
=20
-static inline void tcp_packets_out_inc(struct sock *sk,
-				       const struct sk_buff *skb)
-{
-	struct tcp_sock *tp =3D tcp_sk(sk);
-	int orig =3D tp->packets_out;
-
-	tp->packets_out +=3D tcp_skb_pcount(skb);
-	if (!orig)
-		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
-					  inet_csk(sk)->icsk_rto, TCP_RTO_MAX);
-}
-
-static void update_send_head(struct sock *sk, struct sk_buff *skb)
+static void tcp_event_new_data_sent(struct sock *sk, struct sk_buff *s=
kb)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
+	unsigned int prior_packets =3D tp->packets_out;
=20
 	tcp_advance_send_head(sk, skb);
 	tp->snd_nxt =3D TCP_SKB_CB(skb)->end_seq;
-	tcp_packets_out_inc(sk, skb);
=20
 	/* Don't override Nagle indefinately with F-RTO */
 	if (tp->frto_counter =3D=3D 2)
 		tp->frto_counter =3D 3;
+
+	tp->packets_out +=3D tcp_skb_pcount(skb);
+	if (!prior_packets)
+		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
+					  inet_csk(sk)->icsk_rto, TCP_RTO_MAX);
 }
=20
 /* SND.NXT, if window was not shrunk.
@@ -1410,7 +1403,7 @@ static int tcp_mtu_probe(struct sock *sk)
 		/* Decrement cwnd here because we are sending
 		* effectively two packets. */
 		tp->snd_cwnd--;
-		update_send_head(sk, nskb);
+		tcp_event_new_data_sent(sk, nskb);
=20
 		icsk->icsk_mtup.probe_size =3D tcp_mss_to_mtu(sk, nskb->len);
 		tp->mtu_probe.probe_seq_start =3D TCP_SKB_CB(nskb)->seq;
@@ -1494,7 +1487,7 @@ static int tcp_write_xmit(struct sock *sk, unsign=
ed int mss_now, int nonagle)
 		/* Advance the send_head.  This one is sent out.
 		 * This call will increment packets_out.
 		 */
-		update_send_head(sk, skb);
+		tcp_event_new_data_sent(sk, skb);
=20
 		tcp_minshall_update(tp, mss_now, skb);
 		sent_pkts++;
@@ -1553,7 +1546,7 @@ void tcp_push_one(struct sock *sk, unsigned int m=
ss_now)
 		TCP_SKB_CB(skb)->when =3D tcp_time_stamp;
=20
 		if (likely(!tcp_transmit_skb(sk, skb, 1, sk->sk_allocation))) {
-			update_send_head(sk, skb);
+			tcp_event_new_data_sent(sk, skb);
 			tcp_cwnd_validate(sk);
 			return;
 		}
@@ -2528,9 +2521,8 @@ int tcp_write_wakeup(struct sock *sk)
 			TCP_SKB_CB(skb)->flags |=3D TCPCB_FLAG_PSH;
 			TCP_SKB_CB(skb)->when =3D tcp_time_stamp;
 			err =3D tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
-			if (!err) {
-				update_send_head(sk, skb);
-			}
+			if (!err)
+				tcp_event_new_data_sent(sk, skb);
 			return err;
 		} else {
 			if (tp->urg_mode &&
--=20
1.5.0.6


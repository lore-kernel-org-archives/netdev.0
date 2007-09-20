From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 4/9] [TCP]: Move accounting from tso_acked to clean_rtx_queue
Date: Thu, 20 Sep 2007 15:17:47 +0300
Message-ID: <1190290672770-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11902906724088-git-send-email-ilpo.jarvinen@helsinki.fi> <11902906721846-git-send-email-ilpo.jarvinen@helsinki.fi> <11902906723619-git-send-email-ilpo.jarvinen@helsinki.fi> <11902906723822-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39950 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752284AbXITMRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 08:17:55 -0400
In-Reply-To: <11902906723822-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The accounting code is pretty much the same, so it's a shame
we do it in two places.

I'm not too sure if added fully_acked check in MTU probing is
really what we want perhaps the added end_seq could be used in
the after() comparison.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   75 +++++++++++++++++++++---------------------=
-------
 1 files changed, 32 insertions(+), 43 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 89162a9..d340fd5 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2528,14 +2528,12 @@ static void tcp_rearm_rto(struct sock *sk)
 	}
 }
=20
-static int tcp_tso_acked(struct sock *sk, struct sk_buff *skb,
-			 __u32 now, __s32 *seq_rtt)
+static u32 tcp_tso_acked(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct tcp_skb_cb *scb =3D TCP_SKB_CB(skb);
 	__u32 seq =3D tp->snd_una;
 	__u32 packets_acked;
-	int acked =3D 0;
=20
 	/* If we get here, the whole TSO packet has not been
 	 * acked.
@@ -2548,36 +2546,11 @@ static int tcp_tso_acked(struct sock *sk, struc=
t sk_buff *skb,
 	packets_acked -=3D tcp_skb_pcount(skb);
=20
 	if (packets_acked) {
-		__u8 sacked =3D scb->sacked;
-
-		acked |=3D FLAG_DATA_ACKED;
-		if (sacked) {
-			if (sacked & TCPCB_RETRANS) {
-				if (sacked & TCPCB_SACKED_RETRANS)
-					tp->retrans_out -=3D packets_acked;
-				acked |=3D FLAG_RETRANS_DATA_ACKED;
-				*seq_rtt =3D -1;
-			} else if (*seq_rtt < 0)
-				*seq_rtt =3D now - scb->when;
-			if (sacked & TCPCB_SACKED_ACKED)
-				tp->sacked_out -=3D packets_acked;
-			if (sacked & TCPCB_LOST)
-				tp->lost_out -=3D packets_acked;
-			if (sacked & TCPCB_URG) {
-				if (tp->urg_mode &&
-				    !before(seq, tp->snd_up))
-					tp->urg_mode =3D 0;
-			}
-		} else if (*seq_rtt < 0)
-			*seq_rtt =3D now - scb->when;
-
-		tp->packets_out -=3D packets_acked;
-
 		BUG_ON(tcp_skb_pcount(skb) =3D=3D 0);
 		BUG_ON(!before(scb->seq, scb->end_seq));
 	}
=20
-	return acked;
+	return packets_acked;
 }
=20
 /* Remove acknowledged frames from the retransmission queue. */
@@ -2587,6 +2560,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, _=
_s32 *seq_rtt_p)
 	const struct inet_connection_sock *icsk =3D inet_csk(sk);
 	struct sk_buff *skb;
 	__u32 now =3D tcp_time_stamp;
+	int fully_acked =3D 1;
 	int acked =3D 0;
 	int prior_packets =3D tp->packets_out;
 	__s32 seq_rtt =3D -1;
@@ -2595,6 +2569,8 @@ static int tcp_clean_rtx_queue(struct sock *sk, _=
_s32 *seq_rtt_p)
 	while ((skb =3D tcp_write_queue_head(sk)) &&
 	       skb !=3D tcp_send_head(sk)) {
 		struct tcp_skb_cb *scb =3D TCP_SKB_CB(skb);
+		u32 end_seq;
+		u32 packets_acked;
 		__u8 sacked =3D scb->sacked;
=20
 		/* If our packet is before the ack sequence we can
@@ -2602,11 +2578,19 @@ static int tcp_clean_rtx_queue(struct sock *sk,=
 __s32 *seq_rtt_p)
 		 * the other end.
 		 */
 		if (after(scb->end_seq, tp->snd_una)) {
-			if (tcp_skb_pcount(skb) > 1 &&
-			    after(tp->snd_una, scb->seq))
-				acked |=3D tcp_tso_acked(sk, skb,
-						       now, &seq_rtt);
-			break;
+			if (tcp_skb_pcount(skb) =3D=3D 1 ||
+			    !after(tp->snd_una, scb->seq))
+				break;
+
+			packets_acked =3D tcp_tso_acked(sk, skb);
+			if (!packets_acked)
+				break;
+
+			fully_acked =3D 0;
+			end_seq =3D tp->snd_una;
+		} else {
+			packets_acked =3D tcp_skb_pcount(skb);
+			end_seq =3D scb->end_seq;
 		}
=20
 		/* Initial outgoing SYN's get put onto the write_queue
@@ -2624,7 +2608,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, _=
_s32 *seq_rtt_p)
 		}
=20
 		/* MTU probing checks */
-		if (icsk->icsk_mtup.probe_size) {
+		if (fully_acked && icsk->icsk_mtup.probe_size) {
 			if (!after(tp->mtu_probe.probe_seq_end, TCP_SKB_CB(skb)->end_seq)) =
{
 				tcp_mtup_probe_success(sk, skb);
 			}
@@ -2633,27 +2617,32 @@ static int tcp_clean_rtx_queue(struct sock *sk,=
 __s32 *seq_rtt_p)
 		if (sacked) {
 			if (sacked & TCPCB_RETRANS) {
 				if (sacked & TCPCB_SACKED_RETRANS)
-					tp->retrans_out -=3D tcp_skb_pcount(skb);
+					tp->retrans_out -=3D packets_acked;
 				acked |=3D FLAG_RETRANS_DATA_ACKED;
 				seq_rtt =3D -1;
 			} else if (seq_rtt < 0) {
 				seq_rtt =3D now - scb->when;
-				last_ackt =3D skb->tstamp;
+				if (fully_acked)
+					last_ackt =3D skb->tstamp;
 			}
 			if (sacked & TCPCB_SACKED_ACKED)
-				tp->sacked_out -=3D tcp_skb_pcount(skb);
+				tp->sacked_out -=3D packets_acked;
 			if (sacked & TCPCB_LOST)
-				tp->lost_out -=3D tcp_skb_pcount(skb);
+				tp->lost_out -=3D packets_acked;
 			if (sacked & TCPCB_URG) {
-				if (tp->urg_mode &&
-				    !before(scb->end_seq, tp->snd_up))
+				if (tp->urg_mode && !before(end_seq, tp->snd_up))
 					tp->urg_mode =3D 0;
 			}
 		} else if (seq_rtt < 0) {
 			seq_rtt =3D now - scb->when;
-			last_ackt =3D skb->tstamp;
+			if (fully_acked)
+				last_ackt =3D skb->tstamp;
 		}
-		tp->packets_out -=3D tcp_skb_pcount(skb);
+		tp->packets_out -=3D packets_acked;
+
+		if (!fully_acked)
+			break;
+
 		tcp_unlink_write_queue(skb, sk);
 		sk_stream_free_skb(sk, skb);
 		tcp_clear_all_retrans_hints(tp);
--=20
1.5.0.6


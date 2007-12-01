From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 10/21] [TCP]: Cleanup local variables of clean_rtx_queue
Date: Sun,  2 Dec 2007 00:48:05 +0200
Message-ID: <11965492962283-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11965492963603-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492964079-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296202-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296278-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961750-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296588-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962509-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962214-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492963057-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296324-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59570 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752842AbXLAWsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 17:48:21 -0500
In-Reply-To: <1196549296324-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   26 ++++++++++++--------------
 1 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 365c6d4..a43c897 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2765,8 +2765,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, s=
32 *seq_rtt_p,
 	u32 now =3D tcp_time_stamp;
 	int fully_acked =3D 1;
 	int flag =3D 0;
-	int prior_packets =3D tp->packets_out;
-	u32 cnt =3D 0;
+	u32 pkts_acked =3D 0;
 	u32 reord =3D tp->packets_out;
 	s32 seq_rtt =3D -1;
 	ktime_t last_ackt =3D net_invalid_timestamp();
@@ -2774,7 +2773,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, s=
32 *seq_rtt_p,
 	while ((skb =3D tcp_write_queue_head(sk)) && skb !=3D tcp_send_head(s=
k)) {
 		struct tcp_skb_cb *scb =3D TCP_SKB_CB(skb);
 		u32 end_seq;
-		u32 packets_acked;
+		u32 acked_pcount;
 		u8 sacked =3D scb->sacked;
=20
 		if (after(scb->end_seq, tp->snd_una)) {
@@ -2782,14 +2781,14 @@ static int tcp_clean_rtx_queue(struct sock *sk,=
 s32 *seq_rtt_p,
 			    !after(tp->snd_una, scb->seq))
 				break;
=20
-			packets_acked =3D tcp_tso_acked(sk, skb);
-			if (!packets_acked)
+			acked_pcount =3D tcp_tso_acked(sk, skb);
+			if (!acked_pcount)
 				break;
=20
 			fully_acked =3D 0;
 			end_seq =3D tp->snd_una;
 		} else {
-			packets_acked =3D tcp_skb_pcount(skb);
+			acked_pcount =3D tcp_skb_pcount(skb);
 			end_seq =3D scb->end_seq;
 		}
=20
@@ -2801,11 +2800,11 @@ static int tcp_clean_rtx_queue(struct sock *sk,=
 s32 *seq_rtt_p,
=20
 		if (sacked & TCPCB_RETRANS) {
 			if (sacked & TCPCB_SACKED_RETRANS)
-				tp->retrans_out -=3D packets_acked;
+				tp->retrans_out -=3D acked_pcount;
 			flag |=3D FLAG_RETRANS_DATA_ACKED;
 			seq_rtt =3D -1;
 			if ((flag & FLAG_DATA_ACKED) ||
-			    (packets_acked > 1))
+			    (acked_pcount > 1))
 				flag |=3D FLAG_NONHEAD_RETRANS_ACKED;
 		} else {
 			if (seq_rtt < 0) {
@@ -2814,20 +2813,20 @@ static int tcp_clean_rtx_queue(struct sock *sk,=
 s32 *seq_rtt_p,
 					last_ackt =3D skb->tstamp;
 			}
 			if (!(sacked & TCPCB_SACKED_ACKED))
-				reord =3D min(cnt, reord);
+				reord =3D min(pkts_acked, reord);
 		}
=20
 		if (sacked & TCPCB_SACKED_ACKED)
-			tp->sacked_out -=3D packets_acked;
+			tp->sacked_out -=3D acked_pcount;
 		if (sacked & TCPCB_LOST)
-			tp->lost_out -=3D packets_acked;
+			tp->lost_out -=3D acked_pcount;
=20
 		if (unlikely((sacked & TCPCB_URG) && tp->urg_mode &&
 			     !before(end_seq, tp->snd_up)))
 			tp->urg_mode =3D 0;
=20
-		tp->packets_out -=3D packets_acked;
-		cnt +=3D packets_acked;
+		tp->packets_out -=3D acked_pcount;
+		pkts_acked +=3D acked_pcount;
=20
 		/* Initial outgoing SYN's get put onto the write_queue
 		 * just like anything else we transmit.  It is not
@@ -2852,7 +2851,6 @@ static int tcp_clean_rtx_queue(struct sock *sk, s=
32 *seq_rtt_p,
 	}
=20
 	if (flag & FLAG_ACKED) {
-		u32 pkts_acked =3D prior_packets - tp->packets_out;
 		const struct tcp_congestion_ops *ca_ops
 			=3D inet_csk(sk)->icsk_ca_ops;
=20
--=20
1.5.0.6


From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 6/9] [TCP] FRTO: Improve interoperability with other undo_marker users
Date: Thu, 20 Sep 2007 15:17:49 +0300
Message-ID: <11902906723159-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11902906724088-git-send-email-ilpo.jarvinen@helsinki.fi> <11902906721846-git-send-email-ilpo.jarvinen@helsinki.fi> <11902906723619-git-send-email-ilpo.jarvinen@helsinki.fi> <11902906723822-git-send-email-ilpo.jarvinen@helsinki.fi> <1190290672770-git-send-email-ilpo.jarvinen@helsinki.fi> <11902906721671-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46855 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752771AbXITMRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 08:17:55 -0400
In-Reply-To: <11902906721671-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Basically this change enables it, previously other undo_marker
users were left with nothing. Reverse undo_marker logic
completely to get it set right in CA_Loss. On the other hand,
when spurious RTO is detected, clear it. Clearing might be too
heavy for some scenarios but seems safe enough starting point
for now and shouldn't have much effect except in majority of
cases (if in any).

By adding a new FLAG_ we avoid looping through write_queue when
RTO occurs.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   42 +++++++++++++++++++++++++++---------------
 1 files changed, 27 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 74accb0..948e79a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -104,6 +104,7 @@ int sysctl_tcp_abc __read_mostly;
 #define FLAG_ONLY_ORIG_SACKED	0x200 /* SACKs only non-rexmit sent befo=
re RTO */
 #define FLAG_SND_UNA_ADVANCED	0x400 /* Snd_una was changed (!=3D FLAG_=
DATA_ACKED) */
 #define FLAG_DSACKING_ACK	0x800 /* SACK blocks contained DSACK info */
+#define FLAG_NONHEAD_RETRANS_ACKED	0x1000 /* Non-head rexmitted data w=
as ACKed */
=20
 #define FLAG_ACKED		(FLAG_DATA_ACKED|FLAG_SYN_ACKED)
 #define FLAG_NOT_DUP		(FLAG_DATA|FLAG_WIN_UPDATE|FLAG_ACKED)
@@ -1597,6 +1598,8 @@ void tcp_enter_frto(struct sock *sk)
 	tp->undo_retrans =3D 0;
=20
 	skb =3D tcp_write_queue_head(sk);
+	if (TCP_SKB_CB(skb)->sacked & TCPCB_RETRANS)
+		tp->undo_marker =3D 0;
 	if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS) {
 		TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_SACKED_RETRANS;
 		tp->retrans_out -=3D tcp_skb_pcount(skb);
@@ -1646,6 +1649,8 @@ static void tcp_enter_frto_loss(struct sock *sk, =
int allowed_segments, int flag)
 			/* ...enter this if branch just for the first segment */
 			flag |=3D FLAG_DATA_ACKED;
 		} else {
+			if (TCP_SKB_CB(skb)->sacked & TCPCB_RETRANS)
+				tp->undo_marker =3D 0;
 			TCP_SKB_CB(skb)->sacked &=3D ~(TCPCB_LOST|TCPCB_SACKED_RETRANS);
 		}
=20
@@ -1661,7 +1666,6 @@ static void tcp_enter_frto_loss(struct sock *sk, =
int allowed_segments, int flag)
 	tp->snd_cwnd =3D tcp_packets_in_flight(tp) + allowed_segments;
 	tp->snd_cwnd_cnt =3D 0;
 	tp->snd_cwnd_stamp =3D tcp_time_stamp;
-	tp->undo_marker =3D 0;
 	tp->frto_counter =3D 0;
=20
 	tp->reordering =3D min_t(unsigned int, tp->reordering,
@@ -2587,20 +2591,6 @@ static int tcp_clean_rtx_queue(struct sock *sk, =
s32 *seq_rtt_p)
 			end_seq =3D scb->end_seq;
 		}
=20
-		/* Initial outgoing SYN's get put onto the write_queue
-		 * just like anything else we transmit.  It is not
-		 * true data, and if we misinform our callers that
-		 * this ACK acks real data, we will erroneously exit
-		 * connection startup slow start one packet too
-		 * quickly.  This is severely frowned upon behavior.
-		 */
-		if (!(scb->flags & TCPCB_FLAG_SYN)) {
-			flag |=3D FLAG_DATA_ACKED;
-		} else {
-			flag |=3D FLAG_SYN_ACKED;
-			tp->retrans_stamp =3D 0;
-		}
-
 		/* MTU probing checks */
 		if (fully_acked && icsk->icsk_mtup.probe_size &&
 		    !after(tp->mtu_probe.probe_seq_end, scb->end_seq)) {
@@ -2613,6 +2603,9 @@ static int tcp_clean_rtx_queue(struct sock *sk, s=
32 *seq_rtt_p)
 					tp->retrans_out -=3D packets_acked;
 				flag |=3D FLAG_RETRANS_DATA_ACKED;
 				seq_rtt =3D -1;
+				if ((flag & FLAG_DATA_ACKED) ||
+				    (packets_acked > 1))
+					flag |=3D FLAG_NONHEAD_RETRANS_ACKED;
 			} else if (seq_rtt < 0) {
 				seq_rtt =3D now - scb->when;
 				if (fully_acked)
@@ -2634,6 +2627,20 @@ static int tcp_clean_rtx_queue(struct sock *sk, =
s32 *seq_rtt_p)
 		}
 		tp->packets_out -=3D packets_acked;
=20
+		/* Initial outgoing SYN's get put onto the write_queue
+		 * just like anything else we transmit.  It is not
+		 * true data, and if we misinform our callers that
+		 * this ACK acks real data, we will erroneously exit
+		 * connection startup slow start one packet too
+		 * quickly.  This is severely frowned upon behavior.
+		 */
+		if (!(scb->flags & TCPCB_FLAG_SYN)) {
+			flag |=3D FLAG_DATA_ACKED;
+		} else {
+			flag |=3D FLAG_SYN_ACKED;
+			tp->retrans_stamp =3D 0;
+		}
+
 		if (!fully_acked)
 			break;
=20
@@ -2852,6 +2859,10 @@ static int tcp_process_frto(struct sock *sk, int=
 flag)
 	if (flag&FLAG_DATA_ACKED)
 		inet_csk(sk)->icsk_retransmits =3D 0;
=20
+	if ((flag & FLAG_NONHEAD_RETRANS_ACKED) ||
+	    ((tp->frto_counter >=3D 2) && (flag & FLAG_RETRANS_DATA_ACKED)))
+		tp->undo_marker =3D 0;
+
 	if (!before(tp->snd_una, tp->frto_highmark)) {
 		tcp_enter_frto_loss(sk, (tp->frto_counter =3D=3D 1 ? 2 : 3), flag);
 		return 1;
@@ -2916,6 +2927,7 @@ static int tcp_process_frto(struct sock *sk, int =
flag)
 			break;
 		}
 		tp->frto_counter =3D 0;
+		tp->undo_marker =3D 0;
 	}
 	return 0;
 }
--=20
1.5.0.6


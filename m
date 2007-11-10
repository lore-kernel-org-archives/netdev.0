From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 4/4] [TCP]: Split SACK FRTO flag clearing (fixes FRTO corner case bug)
Date: Sat, 10 Nov 2007 12:56:02 +0200
Message-ID: <11946921624037-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11946921623177-git-send-email-ilpo.jarvinen@helsinki.fi> <11946921623696-git-send-email-ilpo.jarvinen@helsinki.fi> <11946921621074-git-send-email-ilpo.jarvinen@helsinki.fi> <11946921622225-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50870 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384AbXKJK4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Nov 2007 05:56:07 -0500
In-Reply-To: <11946921622225-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In case we run out of mem when fragmenting, the clearing of
=46LAG_ONLY_ORIG_SACKED might get missed which then feeds FRTO
with false information. Move clearing outside skb processing
loop so that it will get executed even if the skb loop
terminates prematurely due to out-of-mem.

Besides, now the core of the loop truly deals with a single
skb only, which also enables creation a more self-contained
of tcp_sacktag_one later on.

In addition, small reorganization of if branches was made.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   35 +++++++++++++++++------------------
 1 files changed, 17 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 84bcdc9..20c9440 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1444,12 +1444,17 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
 						tp->retransmit_skb_hint =3D NULL;
 					}
 				} else {
-					/* New sack for not retransmitted frame,
-					 * which was in hole. It is reordering.
-					 */
-					if (!(sacked & TCPCB_RETRANS) &&
-					    fack_count < prior_fackets)
-						reord =3D min(fack_count, reord);
+					if (!(sacked & TCPCB_RETRANS)) {
+						/* New sack for not retransmitted frame,
+						 * which was in hole. It is reordering.
+						 */
+						if (fack_count < prior_fackets)
+							reord =3D min(fack_count, reord);
+
+						/* SACK enhanced F-RTO (RFC4138; Appendix B) */
+						if (!after(TCP_SKB_CB(skb)->end_seq, tp->frto_highmark))
+							flag |=3D FLAG_ONLY_ORIG_SACKED;
+					}
=20
 					if (sacked & TCPCB_LOST) {
 						TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_LOST;
@@ -1458,18 +1463,6 @@ tcp_sacktag_write_queue(struct sock *sk, struct =
sk_buff *ack_skb, u32 prior_snd_
 						/* clear lost hint */
 						tp->retransmit_skb_hint =3D NULL;
 					}
-					/* SACK enhanced F-RTO detection.
-					 * Set flag if and only if non-rexmitted
-					 * segments below frto_highmark are
-					 * SACKed (RFC4138; Appendix B).
-					 * Clearing correct due to in-order walk
-					 */
-					if (after(end_seq, tp->frto_highmark)) {
-						flag &=3D ~FLAG_ONLY_ORIG_SACKED;
-					} else {
-						if (!(sacked & TCPCB_RETRANS))
-							flag |=3D FLAG_ONLY_ORIG_SACKED;
-					}
 				}
=20
 				TCP_SKB_CB(skb)->sacked |=3D TCPCB_SACKED_ACKED;
@@ -1503,6 +1496,12 @@ tcp_sacktag_write_queue(struct sock *sk, struct =
sk_buff *ack_skb, u32 prior_snd_
 				tp->retransmit_skb_hint =3D NULL;
 			}
 		}
+
+		/* SACK enhanced FRTO (RFC4138, Appendix B): Clearing correct
+		 * due to in-order walk
+		 */
+		if (after(end_seq, tp->frto_highmark))
+			flag &=3D ~FLAG_ONLY_ORIG_SACKED;
 	}
=20
 	if (tp->retrans_out &&
--=20
1.5.0.6


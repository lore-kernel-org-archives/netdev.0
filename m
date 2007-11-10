From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/4] [TCP]: Consider GSO while counting reord in sacktag
Date: Sat, 10 Nov 2007 12:55:59 +0200
Message-ID: <11946921623696-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11946921623177-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45380 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334AbXKJK4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Nov 2007 05:56:05 -0500
In-Reply-To: <11946921623177-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reordering detection fails to take account that the reordered
skb may have pcount larger than 1. In such case the lowest of
them had the largest reordering, the old formula used the
highest of them which is pcount - 1 packets less reordered.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index ca9590f..0f75757 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1403,8 +1403,6 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 			if (in_sack < 0)
 				break;
=20
-			fack_count +=3D tcp_skb_pcount(skb);
-
 			sacked =3D TCP_SKB_CB(skb)->sacked;
=20
 			/* Account D-SACK for retransmitted packet. */
@@ -1427,11 +1425,14 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
 				}
=20
 				/* Nothing to do; acked frame is about to be dropped. */
+				fack_count +=3D tcp_skb_pcount(skb);
 				continue;
 			}
=20
-			if (!in_sack)
+			if (!in_sack) {
+				fack_count +=3D tcp_skb_pcount(skb);
 				continue;
+			}
=20
 			if (!(sacked&TCPCB_SACKED_ACKED)) {
 				if (sacked & TCPCB_SACKED_RETRANS) {
@@ -1480,6 +1481,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 				flag |=3D FLAG_DATA_SACKED;
 				tp->sacked_out +=3D tcp_skb_pcount(skb);
=20
+				fack_count +=3D tcp_skb_pcount(skb);
 				if (fack_count > tp->fackets_out)
 					tp->fackets_out =3D fack_count;
=20
@@ -1490,6 +1492,8 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 			} else {
 				if (dup_sack && (sacked&TCPCB_RETRANS))
 					reord =3D min(fack_count, reord);
+
+				fack_count +=3D tcp_skb_pcount(skb);
 			}
=20
 			/* D-SACK. We can detect redundant retransmission
@@ -1515,7 +1519,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
=20
 	if ((reord < tp->fackets_out) && icsk->icsk_ca_state !=3D TCP_CA_Loss=
 &&
 	    (!tp->frto_highmark || after(tp->snd_una, tp->frto_highmark)))
-		tcp_update_reordering(sk, ((tp->fackets_out + 1) - reord), 0);
+		tcp_update_reordering(sk, tp->fackets_out - reord, 0);
=20
 #if FASTRETRANS_DEBUG > 0
 	BUG_TRAP((int)tp->sacked_out >=3D 0);
--=20
1.5.0.6


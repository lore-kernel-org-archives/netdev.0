From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 01/10] [TCP]: Move !in_sack test earlier in sacktag & reorganize if()s
Date: Thu, 15 Nov 2007 15:37:25 +0200
Message-ID: <1195133854795-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11951338542267-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58227 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757360AbXKONhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 08:37:36 -0500
In-Reply-To: <11951338542267-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All intermediate conditions include it already, make them
simpler as well.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   31 ++++++++++++++-----------------
 1 files changed, 14 insertions(+), 17 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 0f0c1c9..c470b5a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1406,28 +1406,25 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
 			if (unlikely(in_sack < 0))
 				break;
=20
+			if (!in_sack) {
+				fack_count +=3D tcp_skb_pcount(skb);
+				continue;
+			}
+
 			sacked =3D TCP_SKB_CB(skb)->sacked;
=20
 			/* Account D-SACK for retransmitted packet. */
-			if ((dup_sack && in_sack) &&
-			    (sacked & TCPCB_RETRANS) &&
-			    after(TCP_SKB_CB(skb)->end_seq, tp->undo_marker))
-				tp->undo_retrans--;
-
-			/* The frame is ACKed. */
-			if (!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una)) {
-				if (sacked&TCPCB_RETRANS) {
-					if ((dup_sack && in_sack) &&
-					    (sacked&TCPCB_SACKED_ACKED))
-						reord =3D min(fack_count, reord);
-				}
-
-				/* Nothing to do; acked frame is about to be dropped. */
-				fack_count +=3D tcp_skb_pcount(skb);
-				continue;
+			if (dup_sack && (sacked & TCPCB_RETRANS)) {
+				if (after(TCP_SKB_CB(skb)->end_seq, tp->undo_marker))
+					tp->undo_retrans--;
+				if (!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una) &&
+				    (sacked & TCPCB_SACKED_ACKED))
+					reord =3D min(fack_count, reord);
 			}
=20
-			if (!in_sack) {
+
+			/* Nothing to do; acked frame is about to be dropped (was ACKed). *=
/
+			if (!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una)) {
 				fack_count +=3D tcp_skb_pcount(skb);
 				continue;
 			}
--=20
1.5.0.6


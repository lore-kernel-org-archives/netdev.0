From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [TCP] FRTO: remove unnecessary fackets/sacked_out recounting
Date: Sat, 21 Apr 2007 16:37:48 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0704211632580.30204@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-678719598-1177162668=:30204"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34997 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754399AbXDUNhx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2007 09:37:53 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-678719598-1177162668=:30204
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

F-RTO does not touch SACKED_ACKED bits at all, so there is no
need to recount them in tcp_enter_frto_loss. After removal of
the else branch, the nested ifs can be combined.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
I prepared this against tcp-2.6 but I see no reason why it wouldn't apply
cleanly to net-2.6.22 too if you choose to put this there. Compile tested.

 net/ipv4/tcp_input.c |   21 +++++----------------
 1 files changed, 5 insertions(+), 16 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a5a867f..d3c0316 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1437,17 +1437,13 @@ static void tcp_enter_frto_loss(struct s
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
-	int cnt = 0;
 
-	tp->sacked_out = 0;
 	tp->lost_out = 0;
-	tp->fackets_out = 0;
 	tp->retrans_out = 0;
 
 	tcp_for_write_queue(skb, sk) {
 		if (skb == tcp_send_head(sk))
 			break;
-		cnt += tcp_skb_pcount(skb);
 		/*
 		 * Count the retransmission made on RTO correctly (only when
 		 * waiting for the first ACK and did not get it)...
@@ -1459,19 +1455,12 @@ static void tcp_enter_frto_loss(struct s
 		} else {
 			TCP_SKB_CB(skb)->sacked &= ~(TCPCB_LOST|TCPCB_SACKED_RETRANS);
 		}
-		if (!(TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_ACKED)) {
 
-			/* Do not mark those segments lost that were
-			 * forward transmitted after RTO
-			 */
-			if (!after(TCP_SKB_CB(skb)->end_seq,
-				   tp->frto_highmark)) {
-				TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
-				tp->lost_out += tcp_skb_pcount(skb);
-			}
-		} else {
-			tp->sacked_out += tcp_skb_pcount(skb);
-			tp->fackets_out = cnt;
+		/* Don't lost mark skbs that were fwd transmitted after RTO */
+		if (!(TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_ACKED) &&
+		    !after(TCP_SKB_CB(skb)->end_seq, tp->frto_highmark)) {
+			TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
+			tp->lost_out += tcp_skb_pcount(skb);
 		}
 	}
 	tcp_sync_left_out(tp);
-- 
1.4.2

---696243703-678719598-1177162668=:30204--

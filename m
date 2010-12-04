From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 1/3] ifb: remove the useless debug stats
Date: Sat,  4 Dec 2010 13:55:19 +0800
Message-ID: <1291442121-3302-1-git-send-email-xiaosuo@gmail.com>
Cc: netdev@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Changli Gao <xiaosuo@gmail.com>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:50376 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752521Ab0LDFzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 00:55:49 -0500
Received: by yxt3 with SMTP id 3so4664708yxt.19
        for <netdev@vger.kernel.org>; Fri, 03 Dec 2010 21:55:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These debug stats are not exported, and become useless.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 drivers/net/ifb.c |   19 -------------------
 1 file changed, 19 deletions(-)
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index ab9f675..4387525 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -42,16 +42,6 @@
 struct ifb_private {
 	struct tasklet_struct   ifb_tasklet;
 	int     tasklet_pending;
-	/* mostly debug stats leave in for now */
-	unsigned long   st_task_enter; /* tasklet entered */
-	unsigned long   st_txq_refl_try; /* transmit queue refill attempt */
-	unsigned long   st_rxq_enter; /* receive queue entered */
-	unsigned long   st_rx2tx_tran; /* receive to trasmit transfers */
-	unsigned long   st_rxq_notenter; /*receiveQ not entered, resched */
-	unsigned long   st_rx_frm_egr; /* received from egress path */
-	unsigned long   st_rx_frm_ing; /* received from ingress path */
-	unsigned long   st_rxq_check;
-	unsigned long   st_rxq_rsch;
 	struct sk_buff_head     rq;
 	struct sk_buff_head     tq;
 };
@@ -73,19 +63,14 @@ static void ri_tasklet(unsigned long dev)
 	struct sk_buff *skb;
 
 	txq = netdev_get_tx_queue(_dev, 0);
-	dp->st_task_enter++;
 	if ((skb = skb_peek(&dp->tq)) == NULL) {
-		dp->st_txq_refl_try++;
 		if (__netif_tx_trylock(txq)) {
-			dp->st_rxq_enter++;
 			while ((skb = skb_dequeue(&dp->rq)) != NULL) {
 				skb_queue_tail(&dp->tq, skb);
-				dp->st_rx2tx_tran++;
 			}
 			__netif_tx_unlock(txq);
 		} else {
 			/* reschedule */
-			dp->st_rxq_notenter++;
 			goto resched;
 		}
 	}
@@ -110,10 +95,8 @@ static void ri_tasklet(unsigned long dev)
 		skb->skb_iif = _dev->ifindex;
 
 		if (from & AT_EGRESS) {
-			dp->st_rx_frm_egr++;
 			dev_queue_xmit(skb);
 		} else if (from & AT_INGRESS) {
-			dp->st_rx_frm_ing++;
 			skb_pull(skb, skb->dev->hard_header_len);
 			netif_rx(skb);
 		} else
@@ -121,13 +104,11 @@ static void ri_tasklet(unsigned long dev)
 	}
 
 	if (__netif_tx_trylock(txq)) {
-		dp->st_rxq_check++;
 		if ((skb = skb_peek(&dp->rq)) == NULL) {
 			dp->tasklet_pending = 0;
 			if (netif_queue_stopped(_dev))
 				netif_wake_queue(_dev);
 		} else {
-			dp->st_rxq_rsch++;
 			__netif_tx_unlock(txq);
 			goto resched;
 		}

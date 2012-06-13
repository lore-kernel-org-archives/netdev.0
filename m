From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] bnx2x: fix panic when TX ring is full
Date: Wed, 13 Jun 2012 21:45:16 +0200
Message-ID: <1339616716.22704.661.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>,
	Robert Evans <evansr@google.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Merav Sicron <meravs@broadcom.com>,
	Yaniv Rosner <yanivr@broadcom.com>,
	Willem de Bruijn <willemb@google.com>,
	Tomas Hruby <thruby@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:54210 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754212Ab2FMTpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 15:45:21 -0400
Received: by eaak11 with SMTP id k11so333585eaa.19
        for <netdev@vger.kernel.org>; Wed, 13 Jun 2012 12:45:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

There is a off by one error in the minimal number of BD in
bnx2x_start_xmit() and bnx2x_tx_int() before stopping/resuming tx queue.

A full size GSO packet, with data included in skb->head really needs
(MAX_SKB_FRAGS + 4) BDs, because of bnx2x_tx_split()

This error triggers if BQL is disabled and heavy TCP transmit traffic
occurs.

bnx2x_tx_split() definitely can be called, remove a wrong comment.

Reported-by: Tomas Hruby <thruby@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Eilon Greenstein <eilong@broadcom.com>
Cc: Yaniv Rosner <yanivr@broadcom.com>
Cc: Merav Sicron <meravs@broadcom.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Robert Evans <evansr@google.com>
Cc: Willem de Bruijn <willemb@google.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index ad0743b..302765a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -190,7 +190,7 @@ int bnx2x_tx_int(struct bnx2x *bp, struct bnx2x_fp_txdata *txdata)
 
 		if ((netif_tx_queue_stopped(txq)) &&
 		    (bp->state == BNX2X_STATE_OPEN) &&
-		    (bnx2x_tx_avail(bp, txdata) >= MAX_SKB_FRAGS + 3))
+		    (bnx2x_tx_avail(bp, txdata) >= MAX_SKB_FRAGS + 4))
 			netif_tx_wake_queue(txq);
 
 		__netif_tx_unlock(txq);
@@ -2501,8 +2501,6 @@ int bnx2x_poll(struct napi_struct *napi, int budget)
 /* we split the first BD into headers and data BDs
  * to ease the pain of our fellow microcode engineers
  * we use one mapping for both BDs
- * So far this has only been observed to happen
- * in Other Operating Systems(TM)
  */
 static noinline u16 bnx2x_tx_split(struct bnx2x *bp,
 				   struct bnx2x_fp_txdata *txdata,
@@ -3156,7 +3154,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	txdata->tx_bd_prod += nbd;
 
-	if (unlikely(bnx2x_tx_avail(bp, txdata) < MAX_SKB_FRAGS + 3)) {
+	if (unlikely(bnx2x_tx_avail(bp, txdata) < MAX_SKB_FRAGS + 4)) {
 		netif_tx_stop_queue(txq);
 
 		/* paired memory barrier is in bnx2x_tx_int(), we have to keep
@@ -3165,7 +3163,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		smp_mb();
 
 		fp->eth_q_stats.driver_xoff++;
-		if (bnx2x_tx_avail(bp, txdata) >= MAX_SKB_FRAGS + 3)
+		if (bnx2x_tx_avail(bp, txdata) >= MAX_SKB_FRAGS + 4)
 			netif_tx_wake_queue(txq);
 	}
 	txdata->tx_pkt++;

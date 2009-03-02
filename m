From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 03/18] bnx2x: Reduce the likelihood of smb_mb
Date: Mon, 02 Mar 2009 19:59:24 +0200
Message-ID: <1236016764.7723.74.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2320 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755602AbZCBSAO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 13:00:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 03/18] bnx2x: Reduce the likelihood of smb_mb

As the comment explains, this smb_mb is needed only if the queue is stopped
(which is unlikely) so the barrier can be moved to that location

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 5954bed..fbd0f88 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -916,18 +916,19 @@ static void bnx2x_tx_int(struct bnx2x_fastpath *fp, int work)
 	fp->tx_pkt_cons = sw_cons;
 	fp->tx_bd_cons = bd_cons;
 
-	/* Need to make the tx_bd_cons update visible to start_xmit()
-	 * before checking for netif_tx_queue_stopped().  Without the
-	 * memory barrier, there is a small possibility that start_xmit()
-	 * will miss it and cause the queue to be stopped forever.
-	 */
-	smp_mb();
-
 	/* TBD need a thresh? */
 	if (unlikely(netif_tx_queue_stopped(txq))) {
 
 		__netif_tx_lock(txq, smp_processor_id());
 
+		/* Need to make the tx_bd_cons update visible to start_xmit()
+		 * before checking for netif_tx_queue_stopped().  Without the
+		 * memory barrier, there is a small possibility that
+		 * start_xmit() will miss it and cause the queue to be stopped
+		 * forever.
+		 */
+		smp_mb();
+
 		if ((netif_tx_queue_stopped(txq)) &&
 		    (bp->state == BNX2X_STATE_OPEN) &&
 		    (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3))
-- 
1.5.4.3





From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH 1/1] bnx2x: Tx barriers and locks
Date: Sun, 28 Feb 2010 12:12:02 +0200
Message-ID: <1267351922.10409.2.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sgruszka@redhat.com, eilong@broadcom.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2514 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031648Ab0B1KV5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2010 05:21:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Resending with the proper subject. Sorry for the mess. ]

This patch is based on the RFC of Stanislaw Gruszka.

More specifically it fixes two possible races:
- One, described by Stanislaw, may lead to permanent disabling of the Tx
queue.
This is fixed by adding the smp_wmb() to propagate the BD consumer
change towards the memory.
- Second may lead to bnx2x_start_xmit() returning NETDEV_TX_BUSY.
This is fixed by taking a tx_lock() before rechecking the number of
available Tx BDs.

thanks,
vlad 

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   31 ++++++++++++++++++++++---------
 1 files changed, 22 insertions(+), 9 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 5adf2a0..ed785a3 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -57,8 +57,8 @@
 #include "bnx2x_init_ops.h"
 #include "bnx2x_dump.h"
 
-#define DRV_MODULE_VERSION	"1.52.1-6"
-#define DRV_MODULE_RELDATE	"2010/02/16"
+#define DRV_MODULE_VERSION	"1.52.1-7"
+#define DRV_MODULE_RELDATE	"2010/02/28"
 #define BNX2X_BC_VER		0x040200
 
 #include <linux/firmware.h>
@@ -957,21 +957,34 @@ static int bnx2x_tx_int(struct bnx2x_fastpath *fp)
 	fp->tx_pkt_cons = sw_cons;
 	fp->tx_bd_cons = bd_cons;
 
+	/* Need to make the tx_bd_cons update visible to start_xmit()
+	 * before checking for netif_tx_queue_stopped().  Without the
+	 * memory barrier, there is a small possibility that
+	 * start_xmit() will miss it and cause the queue to be stopped
+	 * forever.
+	 */
+	smp_wmb();
+
 	/* TBD need a thresh? */
 	if (unlikely(netif_tx_queue_stopped(txq))) {
-
-		/* Need to make the tx_bd_cons update visible to start_xmit()
-		 * before checking for netif_tx_queue_stopped().  Without the
-		 * memory barrier, there is a small possibility that
-		 * start_xmit() will miss it and cause the queue to be stopped
-		 * forever.
+		/* Taking tx_lock() is needed to prevent reenabling the queue
+		 * while it's empty. This could have happen if rx_action() gets
+		 * suspended in bnx2x_tx_int() after the condition before
+		 * netif_tx_wake_queue(), while tx_action (bnx2x_start_xmit()):
+		 *
+		 * stops the queue->sees fresh tx_bd_cons->releases the queue->
+		 * sends some packets consuming the whole queue again->
+		 * stops the queue
 		 */
-		smp_mb();
+
+		__netif_tx_lock(txq, smp_processor_id());
 
 		if ((netif_tx_queue_stopped(txq)) &&
 		    (bp->state == BNX2X_STATE_OPEN) &&
 		    (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3))
 			netif_tx_wake_queue(txq);
+
+		__netif_tx_unlock(txq);
 	}
 	return 0;
 }
-- 
1.6.3.3





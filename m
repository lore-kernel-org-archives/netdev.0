From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 6/9] bnx2x: NIC load failure cleanup
Date: Mon, 25 Aug 2008 17:24:55 +0300
Message-ID: <1219674295.19456.32.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yitchak Gertner" <gertner@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3159 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754585AbYHYO0M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2008 10:26:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NIC load failure cleanup
Load failures were not handled correctly

Signed-off-by: Yitchak Gertner <gertner@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   22 ++++++++++------------
 1 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 398daeb..1c81da4 100755
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -6341,7 +6341,7 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	rc = bnx2x_init_hw(bp, load_code);
 	if (rc) {
 		BNX2X_ERR("HW init failed, aborting\n");
-		goto load_error;
+		goto load_int_disable;
 	}
 
 	/* Setup NIC internals and enable interrupts */
@@ -6353,7 +6353,7 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		if (!load_code) {
 			BNX2X_ERR("MCP response failure, aborting\n");
 			rc = -EBUSY;
-			goto load_int_disable;
+			goto load_rings_free;
 		}
 	}
 
@@ -6372,7 +6372,7 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	rc = bnx2x_setup_leading(bp);
 	if (rc) {
 		BNX2X_ERR("Setup leading failed!\n");
-		goto load_stop_netif;
+		goto load_netif_stop;
 	}
 
 	if (CHIP_IS_E1H(bp))
@@ -6385,7 +6385,7 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		for_each_nondefault_queue(bp, i) {
 			rc = bnx2x_setup_multi(bp, i);
 			if (rc)
-				goto load_stop_netif;
+				goto load_netif_stop;
 		}
 
 	if (CHIP_IS_E1(bp))
@@ -6430,20 +6430,18 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 
 	return 0;
 
-load_stop_netif:
+load_netif_stop:
 	for_each_queue(bp, i)
 		napi_disable(&bnx2x_fp(bp, i, napi));
-
-load_int_disable:
-	bnx2x_int_disable_sync(bp);
-
-	/* Release IRQs */
-	bnx2x_free_irq(bp);
-
+load_rings_free:
 	/* Free SKBs, SGEs, TPA pool and driver internals */
 	bnx2x_free_skbs(bp);
 	for_each_queue(bp, i)
 		bnx2x_free_rx_sge_range(bp, bp->fp + i, NUM_RX_SGE);
+load_int_disable:
+	bnx2x_int_disable_sync(bp);
+	/* Release IRQs */
+	bnx2x_free_irq(bp);
 load_error:
 	bnx2x_free_mem(bp);
 
-- 
1.5.3.2





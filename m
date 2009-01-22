From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 3/4]bnx2x: Handling load failures
Date: Thu, 22 Jan 2009 15:37:44 +0200
Message-ID: <1232631464.29087.30.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4965 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752859AbZAVNjD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2009 08:39:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Failures on load were not handled correctly - separate the flow to handle
different failures

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |  154 ++++++++++++++++++++++++++--------------------
 1 files changed, 88 insertions(+), 66 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 860b9f8..707c4bb 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -6328,7 +6328,7 @@ static void bnx2x_set_rx_mode(struct net_device *dev);
 static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 {
 	u32 load_code;
-	int i, rc;
+	int i, rc = 0;
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
 		return -EPERM;
@@ -6336,48 +6336,6 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 
 	bp->state = BNX2X_STATE_OPENING_WAIT4_LOAD;
 
-	/* Send LOAD_REQUEST command to MCP
-	   Returns the type of LOAD command:
-	   if it is the first port to be initialized
-	   common blocks should be initialized, otherwise - not
-	*/
-	if (!BP_NOMCP(bp)) {
-		load_code = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_REQ);
-		if (!load_code) {
-			BNX2X_ERR("MCP response failure, aborting\n");
-			return -EBUSY;
-		}
-		if (load_code == FW_MSG_CODE_DRV_LOAD_REFUSED)
-			return -EBUSY; /* other port in diagnostic mode */
-
-	} else {
-		int port = BP_PORT(bp);
-
-		DP(NETIF_MSG_IFUP, "NO MCP load counts before us %d, %d, %d\n",
-		   load_count[0], load_count[1], load_count[2]);
-		load_count[0]++;
-		load_count[1 + port]++;
-		DP(NETIF_MSG_IFUP, "NO MCP new load counts       %d, %d, %d\n",
-		   load_count[0], load_count[1], load_count[2]);
-		if (load_count[0] == 1)
-			load_code = FW_MSG_CODE_DRV_LOAD_COMMON;
-		else if (load_count[1 + port] == 1)
-			load_code = FW_MSG_CODE_DRV_LOAD_PORT;
-		else
-			load_code = FW_MSG_CODE_DRV_LOAD_FUNCTION;
-	}
-
-	if ((load_code == FW_MSG_CODE_DRV_LOAD_COMMON) ||
-	    (load_code == FW_MSG_CODE_DRV_LOAD_PORT))
-		bp->port.pmf = 1;
-	else
-		bp->port.pmf = 0;
-	DP(NETIF_MSG_LINK, "pmf %d\n", bp->port.pmf);
-
-	/* if we can't use MSI-X we only need one fp,
-	 * so try to enable MSI-X with the requested number of fp's
-	 * and fallback to inta with one fp
-	 */
 	if (use_inta) {
 		bp->num_queues = 1;
 
@@ -6392,7 +6350,15 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		else
 			bp->num_queues = 1;
 
-		if (bnx2x_enable_msix(bp)) {
+		DP(NETIF_MSG_IFUP,
+		   "set number of queues to %d\n", bp->num_queues);
+
+		/* if we can't use MSI-X we only need one fp,
+		 * so try to enable MSI-X with the requested number of fp's
+		 * and fallback to MSI or legacy INTx with one fp
+		 */
+		rc = bnx2x_enable_msix(bp);
+		if (rc) {
 			/* failed to enable MSI-X */
 			bp->num_queues = 1;
 			if (use_multi)
@@ -6400,8 +6366,6 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 					  " to enable MSI-X\n");
 		}
 	}
-	DP(NETIF_MSG_IFUP,
-	   "set number of queues to %d\n", bp->num_queues);
 
 	if (bnx2x_alloc_mem(bp))
 		return -ENOMEM;
@@ -6410,30 +6374,85 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		bnx2x_fp(bp, i, disable_tpa) =
 					((bp->flags & TPA_ENABLE_FLAG) == 0);
 
+	for_each_queue(bp, i)
+		netif_napi_add(bp->dev, &bnx2x_fp(bp, i, napi),
+			       bnx2x_poll, 128);
+
+#ifdef BNX2X_STOP_ON_ERROR
+	for_each_queue(bp, i) {
+		struct bnx2x_fastpath *fp = &bp->fp[i];
+
+		fp->poll_no_work = 0;
+		fp->poll_calls = 0;
+		fp->poll_max_calls = 0;
+		fp->poll_complete = 0;
+		fp->poll_exit = 0;
+	}
+#endif
+	bnx2x_napi_enable(bp);
+
 	if (bp->flags & USING_MSIX_FLAG) {
 		rc = bnx2x_req_msix_irqs(bp);
 		if (rc) {
 			pci_disable_msix(bp->pdev);
-			goto load_error;
+			goto load_error1;
 		}
+		printk(KERN_INFO PFX "%s: using MSI-X\n", bp->dev->name);
 	} else {
 		bnx2x_ack_int(bp);
 		rc = bnx2x_req_irq(bp);
 		if (rc) {
-			BNX2X_ERR("IRQ request failed, aborting\n");
-			goto load_error;
+			BNX2X_ERR("IRQ request failed  rc %d, aborting\n", rc);
+			goto load_error1;
 		}
 	}
 
-	for_each_queue(bp, i)
-		netif_napi_add(bp->dev, &bnx2x_fp(bp, i, napi),
-			       bnx2x_poll, 128);
+	/* Send LOAD_REQUEST command to MCP
+	   Returns the type of LOAD command:
+	   if it is the first port to be initialized
+	   common blocks should be initialized, otherwise - not
+	*/
+	if (!BP_NOMCP(bp)) {
+		load_code = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_REQ);
+		if (!load_code) {
+			BNX2X_ERR("MCP response failure, aborting\n");
+			rc = -EBUSY;
+			goto load_error2;
+		}
+		if (load_code == FW_MSG_CODE_DRV_LOAD_REFUSED) {
+			rc = -EBUSY; /* other port in diagnostic mode */
+			goto load_error2;
+		}
+
+	} else {
+		int port = BP_PORT(bp);
+
+		DP(NETIF_MSG_IFUP, "NO MCP load counts before us %d, %d, %d\n",
+		   load_count[0], load_count[1], load_count[2]);
+		load_count[0]++;
+		load_count[1 + port]++;
+		DP(NETIF_MSG_IFUP, "NO MCP new load counts       %d, %d, %d\n",
+		   load_count[0], load_count[1], load_count[2]);
+		if (load_count[0] == 1)
+			load_code = FW_MSG_CODE_DRV_LOAD_COMMON;
+		else if (load_count[1 + port] == 1)
+			load_code = FW_MSG_CODE_DRV_LOAD_PORT;
+		else
+			load_code = FW_MSG_CODE_DRV_LOAD_FUNCTION;
+	}
+
+	if ((load_code == FW_MSG_CODE_DRV_LOAD_COMMON) ||
+	    (load_code == FW_MSG_CODE_DRV_LOAD_PORT))
+		bp->port.pmf = 1;
+	else
+		bp->port.pmf = 0;
+	DP(NETIF_MSG_LINK, "pmf %d\n", bp->port.pmf);
 
 	/* Initialize HW */
 	rc = bnx2x_init_hw(bp, load_code);
 	if (rc) {
 		BNX2X_ERR("HW init failed, aborting\n");
-		goto load_int_disable;
+		goto load_error2;
 	}
 
 	/* Setup NIC internals and enable interrupts */
@@ -6445,7 +6464,7 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		if (!load_code) {
 			BNX2X_ERR("MCP response failure, aborting\n");
 			rc = -EBUSY;
-			goto load_rings_free;
+			goto load_error3;
 		}
 	}
 
@@ -6454,7 +6473,7 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	rc = bnx2x_setup_leading(bp);
 	if (rc) {
 		BNX2X_ERR("Setup leading failed!\n");
-		goto load_netif_stop;
+		goto load_error3;
 	}
 
 	if (CHIP_IS_E1H(bp))
@@ -6467,7 +6486,7 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		for_each_nondefault_queue(bp, i) {
 			rc = bnx2x_setup_multi(bp, i);
 			if (rc)
-				goto load_netif_stop;
+				goto load_error3;
 		}
 
 	if (CHIP_IS_E1(bp))
@@ -6483,18 +6502,18 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	case LOAD_NORMAL:
 		/* Tx queue should be only reenabled */
 		netif_wake_queue(bp->dev);
+		/* Initialize the receive filter. */
 		bnx2x_set_rx_mode(bp->dev);
 		break;
 
 	case LOAD_OPEN:
 		netif_start_queue(bp->dev);
+		/* Initialize the receive filter. */
 		bnx2x_set_rx_mode(bp->dev);
-		if (bp->flags & USING_MSIX_FLAG)
-			printk(KERN_INFO PFX "%s: using MSI-X\n",
-			       bp->dev->name);
 		break;
 
 	case LOAD_DIAG:
+		/* Initialize the receive filter. */
 		bnx2x_set_rx_mode(bp->dev);
 		bp->state = BNX2X_STATE_DIAG;
 		break;
@@ -6512,20 +6531,23 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 
 	return 0;
 
-load_netif_stop:
-	bnx2x_napi_disable(bp);
-load_rings_free:
+load_error3:
+	bnx2x_int_disable_sync(bp, 1);
+	if (!BP_NOMCP(bp)) {
+		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_REQ_WOL_MCP);
+		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE);
+	}
+	bp->port.pmf = 0;
 	/* Free SKBs, SGEs, TPA pool and driver internals */
 	bnx2x_free_skbs(bp);
 	for_each_queue(bp, i)
 		bnx2x_free_rx_sge_range(bp, bp->fp + i, NUM_RX_SGE);
-load_int_disable:
-	bnx2x_int_disable_sync(bp, 1);
+load_error2:
 	/* Release IRQs */
 	bnx2x_free_irq(bp);
-load_error:
+load_error1:
+	bnx2x_napi_disable(bp);
 	bnx2x_free_mem(bp);
-	bp->port.pmf = 0;
 
 	/* TBD we really need to reset the chip
 	   if we want to recover from this */
-- 
1.5.4.3





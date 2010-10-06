From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 15/19] bnx2x: move msix table initialization to
 probe()
Date: Wed, 6 Oct 2010 15:32:10 +0200
Message-ID: <1286371930.30552.55.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4218 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758933Ab0JFNkd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 09:40:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Decide which interrupt mode to use (MSI-X, MSI, INTa) only once in probe() and
initialize appropriate structures.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h      |    3 +
 drivers/net/bnx2x/bnx2x_cmn.c  |  206 ++++++++++++++++++----------------------
 drivers/net/bnx2x/bnx2x_cmn.h  |   75 ++++++++++++++-
 drivers/net/bnx2x/bnx2x_main.c |   78 ++++++++++++----
 4 files changed, 228 insertions(+), 134 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 9b78a04..d80809f 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -308,6 +308,7 @@ union host_hc_status_block {
 
 struct bnx2x_fastpath {
 
+#define BNX2X_NAPI_WEIGHT       128
 	struct napi_struct	napi;
 	union host_hc_status_block status_blk;
 	/* chip independed shortcuts into sb structure */
@@ -920,8 +921,10 @@ struct bnx2x {
 #define USING_DAC_FLAG			0x10
 #define USING_MSIX_FLAG			0x20
 #define USING_MSI_FLAG			0x40
+
 #define TPA_ENABLE_FLAG			0x80
 #define NO_MCP_FLAG			0x100
+#define DISABLE_MSI_FLAG		0x200
 #define BP_NOMCP(bp)			(bp->flags & NO_MCP_FLAG)
 #define HW_VLAN_TX_FLAG			0x400
 #define HW_VLAN_RX_FLAG			0x800
diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index da46309..2998969 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -29,7 +29,6 @@
 
 #include "bnx2x_init.h"
 
-static int bnx2x_poll(struct napi_struct *napi, int budget);
 
 /* free skb in the packet ring at pos idx
  * return idx of last bd freed
@@ -989,55 +988,49 @@ static void bnx2x_free_msix_irqs(struct bnx2x *bp)
 	}
 }
 
-void bnx2x_free_irq(struct bnx2x *bp, bool disable_only)
+void bnx2x_free_irq(struct bnx2x *bp)
 {
-	if (bp->flags & USING_MSIX_FLAG) {
-		if (!disable_only)
-			bnx2x_free_msix_irqs(bp);
-		pci_disable_msix(bp->pdev);
-		bp->flags &= ~USING_MSIX_FLAG;
-
-	} else if (bp->flags & USING_MSI_FLAG) {
-		if (!disable_only)
-			free_irq(bp->pdev->irq, bp->dev);
-		pci_disable_msi(bp->pdev);
-		bp->flags &= ~USING_MSI_FLAG;
-
-	} else if (!disable_only)
+	if (bp->flags & USING_MSIX_FLAG)
+		bnx2x_free_msix_irqs(bp);
+	else if (bp->flags & USING_MSI_FLAG)
+		free_irq(bp->pdev->irq, bp->dev);
+	else
 		free_irq(bp->pdev->irq, bp->dev);
 }
 
-static int bnx2x_enable_msix(struct bnx2x *bp)
+int bnx2x_enable_msix(struct bnx2x *bp)
 {
-	int i, rc, offset = 1;
-	int igu_vec = 0;
+	int msix_vec = 0, i, rc, req_cnt;
 
-	bp->msix_table[0].entry = igu_vec;
-	DP(NETIF_MSG_IFUP, "msix_table[0].entry = %d (slowpath)\n", igu_vec);
+	bp->msix_table[msix_vec].entry = msix_vec;
+	DP(NETIF_MSG_IFUP, "msix_table[0].entry = %d (slowpath)\n",
+	   bp->msix_table[0].entry);
+	msix_vec++;
 
 #ifdef BCM_CNIC
-	igu_vec = BP_L_ID(bp) + offset;
-	bp->msix_table[1].entry = igu_vec;
-	DP(NETIF_MSG_IFUP, "msix_table[1].entry = %d (CNIC)\n", igu_vec);
-	offset++;
+	bp->msix_table[msix_vec].entry = msix_vec;
+	DP(NETIF_MSG_IFUP, "msix_table[%d].entry = %d (CNIC)\n",
+	   bp->msix_table[msix_vec].entry, bp->msix_table[msix_vec].entry);
+	msix_vec++;
 #endif
 	for_each_queue(bp, i) {
-		igu_vec = BP_L_ID(bp) + offset + i;
-		bp->msix_table[i + offset].entry = igu_vec;
+		bp->msix_table[msix_vec].entry = msix_vec;
 		DP(NETIF_MSG_IFUP, "msix_table[%d].entry = %d "
-		   "(fastpath #%u)\n", i + offset, igu_vec, i);
+		   "(fastpath #%u)\n", msix_vec, msix_vec, i);
+		msix_vec++;
 	}
 
-	rc = pci_enable_msix(bp->pdev, &bp->msix_table[0],
-			     BNX2X_NUM_QUEUES(bp) + offset);
+	req_cnt = BNX2X_NUM_QUEUES(bp) + CNIC_CONTEXT_USE + 1;
+
+	rc = pci_enable_msix(bp->pdev, &bp->msix_table[0], req_cnt);
 
 	/*
 	 * reconfigure number of tx/rx queues according to available
 	 * MSI-X vectors
 	 */
 	if (rc >= BNX2X_MIN_MSIX_VEC_CNT) {
-		/* vectors available for FP */
-		int fp_vec = rc - BNX2X_MSIX_VEC_FP_START;
+		/* how less vectors we will have? */
+		int diff = req_cnt - rc;
 
 		DP(NETIF_MSG_IFUP,
 		   "Trying to use less MSI-X vectors: %d\n", rc);
@@ -1049,12 +1042,17 @@ static int bnx2x_enable_msix(struct bnx2x *bp)
 			   "MSI-X is not attainable  rc %d\n", rc);
 			return rc;
 		}
-
-		bp->num_queues = min(bp->num_queues, fp_vec);
+		/*
+		 * decrease number of queues by number of unallocated entries
+		 */
+		bp->num_queues -= diff;
 
 		DP(NETIF_MSG_IFUP, "New queue configuration set: %d\n",
 				  bp->num_queues);
 	} else if (rc) {
+		/* fall to INTx if not enough memory */
+		if (rc == -ENOMEM)
+			bp->flags |= DISABLE_MSI_FLAG;
 		DP(NETIF_MSG_IFUP, "MSI-X is not attainable  rc %d\n", rc);
 		return rc;
 	}
@@ -1083,7 +1081,7 @@ static int bnx2x_req_msix_irqs(struct bnx2x *bp)
 		snprintf(fp->name, sizeof(fp->name), "%s-fp-%d",
 			 bp->dev->name, i);
 
-		rc = request_irq(bp->msix_table[i + offset].vector,
+		rc = request_irq(bp->msix_table[offset].vector,
 				 bnx2x_msix_fp_int, 0, fp->name, fp);
 		if (rc) {
 			BNX2X_ERR("request fp #%d irq failed  rc %d\n", i, rc);
@@ -1091,10 +1089,12 @@ static int bnx2x_req_msix_irqs(struct bnx2x *bp)
 			return -EBUSY;
 		}
 
+		offset++;
 		fp->state = BNX2X_FP_STATE_IRQ;
 	}
 
 	i = BNX2X_NUM_QUEUES(bp);
+	offset = 1 + CNIC_CONTEXT_USE;
 	netdev_info(bp->dev, "using MSI-X  IRQs: sp %d  fp[%d] %d"
 	       " ... fp[%d] %d\n",
 	       bp->msix_table[0].vector,
@@ -1104,7 +1104,7 @@ static int bnx2x_req_msix_irqs(struct bnx2x *bp)
 	return 0;
 }
 
-static int bnx2x_enable_msi(struct bnx2x *bp)
+int bnx2x_enable_msi(struct bnx2x *bp)
 {
 	int rc;
 
@@ -1175,44 +1175,20 @@ void bnx2x_netif_stop(struct bnx2x *bp, int disable_hw)
 	bnx2x_napi_disable(bp);
 	netif_tx_disable(bp->dev);
 }
-static int bnx2x_set_num_queues(struct bnx2x *bp)
-{
-	int rc = 0;
 
-	switch (bp->int_mode) {
-	case INT_MODE_MSI:
-		bnx2x_enable_msi(bp);
-		/* falling through... */
-	case INT_MODE_INTx:
+void bnx2x_set_num_queues(struct bnx2x *bp)
+{
+	switch (bp->multi_mode) {
+	case ETH_RSS_MODE_DISABLED:
 		bp->num_queues = 1;
-		DP(NETIF_MSG_IFUP, "set number of queues to 1\n");
+		break;
+	case ETH_RSS_MODE_REGULAR:
+		bp->num_queues = bnx2x_calc_num_queues(bp);
 		break;
 	default:
-		/* Set number of queues according to bp->multi_mode value */
-		bnx2x_set_num_queues_msix(bp);
-
-		DP(NETIF_MSG_IFUP, "set number of queues to %d\n",
-		   bp->num_queues);
-
-		/* if we can't use MSI-X we only need one fp,
-		 * so try to enable MSI-X with the requested number of fp's
-		 * and fallback to MSI or legacy INTx with one fp
-		 */
-		rc = bnx2x_enable_msix(bp);
-		if (rc) {
-			/* failed to enable MSI-X */
-			bp->num_queues = 1;
-
-			/* Fall to INTx if failed to enable MSI-X due to lack of
-			 * memory (in bnx2x_set_num_queues()) */
-			if ((rc != -ENOMEM) && (bp->int_mode != INT_MODE_INTx))
-				bnx2x_enable_msi(bp);
-		}
-
+		bp->num_queues = 1;
 		break;
 	}
-	netif_set_real_num_tx_queues(bp->dev, bp->num_queues);
-	return netif_set_real_num_rx_queues(bp->dev, bp->num_queues);
 }
 
 static void bnx2x_release_firmware(struct bnx2x *bp)
@@ -1243,49 +1219,25 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 
 	bp->state = BNX2X_STATE_OPENING_WAIT4_LOAD;
 
-	rc = bnx2x_set_num_queues(bp);
-	if (rc)
-		return rc;
-
 	/* must be called before memory allocation and HW init */
 	bnx2x_ilt_set_info(bp);
 
-	if (bnx2x_alloc_mem(bp)) {
-		bnx2x_free_irq(bp, true);
+	if (bnx2x_alloc_mem(bp))
 		return -ENOMEM;
+
+	netif_set_real_num_tx_queues(bp->dev, bp->num_queues);
+	rc = netif_set_real_num_rx_queues(bp->dev, bp->num_queues);
+	if (rc) {
+		BNX2X_ERR("Unable to update real_num_rx_queues\n");
+		goto load_error0;
 	}
 
 	for_each_queue(bp, i)
 		bnx2x_fp(bp, i, disable_tpa) =
 					((bp->flags & TPA_ENABLE_FLAG) == 0);
 
-	for_each_queue(bp, i)
-		netif_napi_add(bp->dev, &bnx2x_fp(bp, i, napi),
-			       bnx2x_poll, 128);
-
 	bnx2x_napi_enable(bp);
 
-	if (bp->flags & USING_MSIX_FLAG) {
-		rc = bnx2x_req_msix_irqs(bp);
-		if (rc) {
-			bnx2x_free_irq(bp, true);
-			goto load_error1;
-		}
-	} else {
-		bnx2x_ack_int(bp);
-		rc = bnx2x_req_irq(bp);
-		if (rc) {
-			BNX2X_ERR("IRQ request failed  rc %d, aborting\n", rc);
-			bnx2x_free_irq(bp, true);
-			goto load_error1;
-		}
-		if (bp->flags & USING_MSI_FLAG) {
-			bp->dev->irq = bp->pdev->irq;
-			netdev_info(bp->dev, "using MSI  IRQ %d\n",
-				    bp->pdev->irq);
-		}
-	}
-
 	/* Send LOAD_REQUEST command to MCP
 	   Returns the type of LOAD command:
 	   if it is the first port to be initialized
@@ -1296,11 +1248,11 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		if (!load_code) {
 			BNX2X_ERR("MCP response failure, aborting\n");
 			rc = -EBUSY;
-			goto load_error2;
+			goto load_error1;
 		}
 		if (load_code == FW_MSG_CODE_DRV_LOAD_REFUSED) {
 			rc = -EBUSY; /* other port in diagnostic mode */
-			goto load_error2;
+			goto load_error1;
 		}
 
 	} else {
@@ -1341,6 +1293,8 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		goto load_error2;
 	}
 
+	/* Connect to IRQs */
+	rc = bnx2x_setup_irqs(bp);
 	if (rc) {
 		bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_DONE, 0);
 		goto load_error2;
@@ -1481,22 +1435,24 @@ load_error4:
 #endif
 load_error3:
 	bnx2x_int_disable_sync(bp, 1);
-	if (!BP_NOMCP(bp)) {
-		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_REQ_WOL_MCP, 0);
-		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE, 0);
-	}
-	bp->port.pmf = 0;
+
 	/* Free SKBs, SGEs, TPA pool and driver internals */
 	bnx2x_free_skbs(bp);
 	for_each_queue(bp, i)
 		bnx2x_free_rx_sge_range(bp, bp->fp + i, NUM_RX_SGE);
-load_error2:
+
 	/* Release IRQs */
-	bnx2x_free_irq(bp, false);
+	bnx2x_free_irq(bp);
+load_error2:
+	if (!BP_NOMCP(bp)) {
+		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_REQ_WOL_MCP, 0);
+		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE, 0);
+	}
+
+	bp->port.pmf = 0;
 load_error1:
 	bnx2x_napi_disable(bp);
-	for_each_queue(bp, i)
-		netif_napi_del(&bnx2x_fp(bp, i, napi));
+load_error0:
 	bnx2x_free_mem(bp);
 
 	bnx2x_release_firmware(bp);
@@ -1544,7 +1500,7 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 		bnx2x_netif_stop(bp, 1);
 
 		/* Release IRQs */
-		bnx2x_free_irq(bp, false);
+		bnx2x_free_irq(bp);
 	}
 
 	bp->port.pmf = 0;
@@ -1553,8 +1509,7 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 	bnx2x_free_skbs(bp);
 	for_each_queue(bp, i)
 		bnx2x_free_rx_sge_range(bp, bp->fp + i, NUM_RX_SGE);
-	for_each_queue(bp, i)
-		netif_napi_del(&bnx2x_fp(bp, i, napi));
+
 	bnx2x_free_mem(bp);
 
 	bp->state = BNX2X_STATE_CLOSED;
@@ -1624,7 +1579,7 @@ int bnx2x_set_power_state(struct bnx2x *bp, pci_power_t state)
  * net_device service functions
  */
 
-static int bnx2x_poll(struct napi_struct *napi, int budget)
+int bnx2x_poll(struct napi_struct *napi, int budget)
 {
 	int work_done = 0;
 	struct bnx2x_fastpath *fp = container_of(napi, struct bnx2x_fastpath,
@@ -2261,6 +2216,31 @@ int bnx2x_change_mac_addr(struct net_device *dev, void *p)
 	return 0;
 }
 
+
+int bnx2x_setup_irqs(struct bnx2x *bp)
+{
+	int rc = 0;
+	if (bp->flags & USING_MSIX_FLAG) {
+		rc = bnx2x_req_msix_irqs(bp);
+		if (rc)
+			return rc;
+	} else {
+		bnx2x_ack_int(bp);
+		rc = bnx2x_req_irq(bp);
+		if (rc) {
+			BNX2X_ERR("IRQ request failed  rc %d, aborting\n", rc);
+			return rc;
+		}
+		if (bp->flags & USING_MSI_FLAG) {
+			bp->dev->irq = bp->pdev->irq;
+			netdev_info(bp->dev, "using MSI  IRQ %d\n",
+			       bp->pdev->irq);
+		}
+	}
+
+	return 0;
+}
+
 void bnx2x_free_mem_bp(struct bnx2x *bp)
 {
 	kfree(bp->fp);
diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
index f08a42a..1d9686e 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -23,6 +23,7 @@
 
 #include "bnx2x.h"
 
+extern int num_queues;
 
 /*********************** Interfaces ****************************
  *  Functions that need to be implemented by each driver version
@@ -193,12 +194,12 @@ int bnx2x_stop_fw_client(struct bnx2x *bp,
 			 struct bnx2x_client_ramrod_params *p);
 
 /**
- * Set number of quueus according to mode
+ * Set number of queues according to mode
  *
  * @param bp
  *
  */
-void bnx2x_set_num_queues_msix(struct bnx2x *bp);
+void bnx2x_set_num_queues(struct bnx2x *bp);
 
 /**
  * Cleanup chip internals:
@@ -325,6 +326,42 @@ int bnx2x_func_stop(struct bnx2x *bp);
  */
 void bnx2x_ilt_set_info(struct bnx2x *bp);
 
+/**
+ * Fill msix_table, request vectors, update num_queues according
+ * to number of available vectors
+ *
+ * @param bp
+ *
+ * @return int
+ */
+int bnx2x_enable_msix(struct bnx2x *bp);
+
+/**
+ * Request msi mode from OS, updated internals accordingly
+ *
+ * @param bp
+ *
+ * @return int
+ */
+int bnx2x_enable_msi(struct bnx2x *bp);
+
+/**
+ * Request IRQ vectors from OS.
+ *
+ * @param bp
+ *
+ * @return int
+ */
+int bnx2x_setup_irqs(struct bnx2x *bp);
+/**
+ * NAPI callback
+ *
+ * @param napi
+ * @param budget
+ *
+ * @return int
+ */
+int bnx2x_poll(struct napi_struct *napi, int budget);
 static inline void bnx2x_update_fpsb_idx(struct bnx2x_fastpath *fp)
 {
 	barrier(); /* status block is written to by the chip */
@@ -605,9 +642,41 @@ static inline void bnx2x_free_rx_sge(struct bnx2x *bp,
 	sge->addr_lo = 0;
 }
 
+static inline void bnx2x_add_all_napi(struct bnx2x *bp)
+{
+	int i;
 
+	/* Add NAPI objects */
+	for_each_queue(bp, i)
+		netif_napi_add(bp->dev, &bnx2x_fp(bp, i, napi),
+			       bnx2x_poll, BNX2X_NAPI_WEIGHT);
+}
 
+static inline void bnx2x_del_all_napi(struct bnx2x *bp)
+{
+	int i;
+
+	for_each_queue(bp, i)
+		netif_napi_del(&bnx2x_fp(bp, i, napi));
+}
 
+static inline void bnx2x_disable_msi(struct bnx2x *bp)
+{
+	if (bp->flags & USING_MSIX_FLAG) {
+		pci_disable_msix(bp->pdev);
+		bp->flags &= ~USING_MSIX_FLAG;
+	} else if (bp->flags & USING_MSI_FLAG) {
+		pci_disable_msi(bp->pdev);
+		bp->flags &= ~USING_MSI_FLAG;
+	}
+}
+
+static inline int bnx2x_calc_num_queues(struct bnx2x *bp)
+{
+	return  num_queues ?
+		 min_t(int, num_queues, BNX2X_MAX_QUEUES(bp)) :
+		 min_t(int, num_online_cpus(), BNX2X_MAX_QUEUES(bp));
+}
 
 static inline void bnx2x_clear_sge_mask_next_elems(struct bnx2x_fastpath *fp)
 {
@@ -877,7 +946,7 @@ void bnx2x_tx_timeout(struct net_device *dev);
 void bnx2x_vlan_rx_register(struct net_device *dev, struct vlan_group *vlgrp);
 void bnx2x_netif_start(struct bnx2x *bp);
 void bnx2x_netif_stop(struct bnx2x *bp, int disable_hw);
-void bnx2x_free_irq(struct bnx2x *bp, bool disable_only);
+void bnx2x_free_irq(struct bnx2x *bp);
 int bnx2x_suspend(struct pci_dev *pdev, pm_message_t state);
 int bnx2x_resume(struct pci_dev *pdev);
 void bnx2x_free_skbs(struct bnx2x *bp);
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 0ac416a..2572eb4 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -90,7 +90,7 @@ module_param(multi_mode, int, 0);
 MODULE_PARM_DESC(multi_mode, " Multi queue mode "
 			     "(0 Disable; 1 Enable (default))");
 
-static int num_queues;
+int num_queues;
 module_param(num_queues, int, 0);
 MODULE_PARM_DESC(num_queues, " Number of queues for multi_mode=1"
 				" (default is as a number of CPUs)");
@@ -6409,28 +6409,57 @@ int bnx2x_setup_fw_client(struct bnx2x *bp,
 	return rc;
 }
 
-void bnx2x_set_num_queues_msix(struct bnx2x *bp)
+/**
+ * Configure interrupt mode according to current configuration.
+ * In case of MSI-X it will also try to enable MSI-X.
+ *
+ * @param bp
+ *
+ * @return int
+ */
+static int __devinit bnx2x_set_int_mode(struct bnx2x *bp)
 {
+	int rc = 0;
 
-	switch (bp->multi_mode) {
-	case ETH_RSS_MODE_DISABLED:
+	switch (bp->int_mode) {
+	case INT_MODE_MSI:
+		bnx2x_enable_msi(bp);
+		/* falling through... */
+	case INT_MODE_INTx:
 		bp->num_queues = 1;
+		DP(NETIF_MSG_IFUP, "set number of queues to 1\n");
 		break;
+	default:
+		/* Set number of queues according to bp->multi_mode value */
+		bnx2x_set_num_queues(bp);
 
-	case ETH_RSS_MODE_REGULAR:
-		if (num_queues)
-			bp->num_queues = min_t(u32, num_queues,
-						  BNX2X_MAX_QUEUES(bp));
-		else
-			bp->num_queues = min_t(u32, num_online_cpus(),
-						  BNX2X_MAX_QUEUES(bp));
-		break;
+		DP(NETIF_MSG_IFUP, "set number of queues to %d\n",
+		   bp->num_queues);
 
+		/* if we can't use MSI-X we only need one fp,
+		 * so try to enable MSI-X with the requested number of fp's
+		 * and fallback to MSI or legacy INTx with one fp
+		 */
+		rc = bnx2x_enable_msix(bp);
+		if (rc) {
+			/* failed to enable MSI-X */
+			if (bp->multi_mode)
+				DP(NETIF_MSG_IFUP,
+					  "Multi requested but failed to "
+					  "enable MSI-X (%d), "
+					  "set number of queues to %d\n",
+				   bp->num_queues,
+				   1);
+			bp->num_queues = 1;
+
+			if (!(bp->flags & DISABLE_MSI_FLAG))
+				bnx2x_enable_msi(bp);
+		}
 
-	default:
-		bp->num_queues = 1;
 		break;
 	}
+
+	return rc;
 }
 
 void bnx2x_ilt_set_info(struct bnx2x *bp)
@@ -6881,7 +6910,7 @@ unload_error:
 	bnx2x_netif_stop(bp, 1);
 
 	/* Release IRQs */
-	bnx2x_free_irq(bp, false);
+	bnx2x_free_irq(bp);
 
 	/* Reset the chip */
 	bnx2x_reset_chip(bp, reset_code);
@@ -9024,7 +9053,16 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 		goto init_one_exit;
 	}
 
+	/* Configure interupt mode: try to enable MSI-X/MSI if
+	 * needed, set bp->num_queues appropriately.
+	 */
+	bnx2x_set_int_mode(bp);
+
+	/* Add all NAPI objects */
+	bnx2x_add_all_napi(bp);
+
 	bnx2x_get_pcie_width_speed(bp, &pcie_width, &pcie_speed);
+
 	netdev_info(dev, "%s (%c%d) PCI-E x%d %s found at mem %lx,"
 	       " IRQ %d, ", board_info[ent->driver_data].name,
 	       (CHIP_REV(bp) >> 12) + 'A', (CHIP_METAL(bp) >> 4),
@@ -9068,6 +9106,11 @@ static void __devexit bnx2x_remove_one(struct pci_dev *pdev)
 
 	unregister_netdev(dev);
 
+	/* Delete all NAPI objects */
+	bnx2x_del_all_napi(bp);
+
+	/* Disable MSI/MSI-X */
+	bnx2x_disable_msi(bp);
 	/* Make sure RESET task is not scheduled before continuing */
 	cancel_delayed_work_sync(&bp->reset_task);
 
@@ -9104,15 +9147,14 @@ static int bnx2x_eeh_nic_unload(struct bnx2x *bp)
 	DP(BNX2X_MSG_STATS, "stats_state - DISABLED\n");
 
 	/* Release IRQs */
-	bnx2x_free_irq(bp, false);
+	bnx2x_free_irq(bp);
 
 	/* Free SKBs, SGEs, TPA pool and driver internals */
 	bnx2x_free_skbs(bp);
 
 	for_each_queue(bp, i)
 		bnx2x_free_rx_sge_range(bp, bp->fp + i, NUM_RX_SGE);
-	for_each_queue(bp, i)
-		netif_napi_del(&bnx2x_fp(bp, i, napi));
+
 	bnx2x_free_mem(bp);
 
 	bp->state = BNX2X_STATE_CLOSED;
-- 
1.7.1





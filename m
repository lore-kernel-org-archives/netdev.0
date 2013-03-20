From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next] bnx2x: AER revised
Date: Wed, 20 Mar 2013 17:21:28 +0200
Message-ID: <1363792888-29392-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Ariel Elior" <ariele@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2895 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932536Ab3CTQ12 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Mar 2013 12:27:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Revised bnx2x implementation of PCI Express Advanced Error Recovery -
stop and free driver resources according to the AER flow (instead of the
currently implemented `hope-for-the-best' release approach), and do not make
any assumptions on the HW state after slot reset.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
Hi Dave,

Please apply this patch to `net-next'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |   3 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |   4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |   4 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 149 +++++++++++++++++++----
 4 files changed, 130 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index a4729c7..c59da2d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1226,10 +1226,11 @@ enum {
 
 
 struct bnx2x_prev_path_list {
+	struct list_head list;
 	u8 bus;
 	u8 slot;
 	u8 path;
-	struct list_head list;
+	u8 aer;
 	u8 undi;
 };
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 8091de7..6f8a81c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2010,7 +2010,7 @@ static int bnx2x_init_hw(struct bnx2x *bp, u32 load_code)
  * Cleans the object that have internal lists without sending
  * ramrods. Should be run when interrutps are disabled.
  */
-static void bnx2x_squeeze_objects(struct bnx2x *bp)
+void bnx2x_squeeze_objects(struct bnx2x *bp)
 {
 	int rc;
 	unsigned long ramrod_flags = 0, vlan_mac_flags = 0;
@@ -2774,7 +2774,7 @@ load_error0:
 #endif /* ! BNX2X_STOP_ON_ERROR */
 }
 
-static int bnx2x_drain_tx_queues(struct bnx2x *bp)
+int bnx2x_drain_tx_queues(struct bnx2x *bp)
 {
 	u8 rc = 0, cos, i;
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index f9098d8..54e1b14 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -1402,4 +1402,8 @@ static inline bool bnx2x_is_valid_ether_addr(struct bnx2x *bp, u8 *addr)
  *
  */
 void bnx2x_fill_fw_str(struct bnx2x *bp, char *buf, size_t buf_len);
+
+int bnx2x_drain_tx_queues(struct bnx2x *bp);
+void bnx2x_squeeze_objects(struct bnx2x *bp);
+
 #endif /* BNX2X_CMN_H */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 4902d1e..10b0748 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9718,6 +9718,31 @@ static struct bnx2x_prev_path_list *
 	return NULL;
 }
 
+static int bnx2x_prev_path_mark_eeh(struct bnx2x *bp)
+{
+	struct bnx2x_prev_path_list *tmp_list;
+	int rc;
+
+	rc = down_interruptible(&bnx2x_prev_sem);
+	if (rc) {
+		BNX2X_ERR("Received %d when tried to take lock\n", rc);
+		return rc;
+	}
+
+	tmp_list = bnx2x_prev_path_get_entry(bp);
+	if (tmp_list) {
+		tmp_list->aer = 1;
+		rc = 0;
+	} else {
+		BNX2X_ERR("path %d: Entry does not exist for eeh; Flow occurs before initial insmod is over ?\n",
+			  BP_PATH(bp));
+	}
+
+	up(&bnx2x_prev_sem);
+
+	return rc;
+}
+
 static bool bnx2x_prev_is_path_marked(struct bnx2x *bp)
 {
 	struct bnx2x_prev_path_list *tmp_list;
@@ -9726,14 +9751,15 @@ static bool bnx2x_prev_is_path_marked(struct bnx2x *bp)
 	if (down_trylock(&bnx2x_prev_sem))
 		return false;
 
-	list_for_each_entry(tmp_list, &bnx2x_prev_list, list) {
-		if (PCI_SLOT(bp->pdev->devfn) == tmp_list->slot &&
-		    bp->pdev->bus->number == tmp_list->bus &&
-		    BP_PATH(bp) == tmp_list->path) {
+	tmp_list = bnx2x_prev_path_get_entry(bp);
+	if (tmp_list) {
+		if (tmp_list->aer) {
+			DP(NETIF_MSG_HW, "Path %d was marked by AER\n",
+			   BP_PATH(bp));
+		} else {
 			rc = true;
 			BNX2X_DEV_INFO("Path %d was already cleaned from previous drivers\n",
 				       BP_PATH(bp));
-			break;
 		}
 	}
 
@@ -9747,6 +9773,28 @@ static int bnx2x_prev_mark_path(struct bnx2x *bp, bool after_undi)
 	struct bnx2x_prev_path_list *tmp_list;
 	int rc;
 
+	rc = down_interruptible(&bnx2x_prev_sem);
+	if (rc) {
+		BNX2X_ERR("Received %d when tried to take lock\n", rc);
+		return rc;
+	}
+
+	/* Check whether the entry for this path already exists */
+	tmp_list = bnx2x_prev_path_get_entry(bp);
+	if (tmp_list) {
+		if (!tmp_list->aer) {
+			BNX2X_ERR("Re-Marking the path.\n");
+		} else {
+			DP(NETIF_MSG_HW, "Removing AER indication from path %d\n",
+			   BP_PATH(bp));
+			tmp_list->aer = 0;
+		}
+		up(&bnx2x_prev_sem);
+		return 0;
+	}
+	up(&bnx2x_prev_sem);
+
+	/* Create an entry for this path and add it */
 	tmp_list = kmalloc(sizeof(struct bnx2x_prev_path_list), GFP_KERNEL);
 	if (!tmp_list) {
 		BNX2X_ERR("Failed to allocate 'bnx2x_prev_path_list'\n");
@@ -9756,6 +9804,7 @@ static int bnx2x_prev_mark_path(struct bnx2x *bp, bool after_undi)
 	tmp_list->bus = bp->pdev->bus->number;
 	tmp_list->slot = PCI_SLOT(bp->pdev->devfn);
 	tmp_list->path = BP_PATH(bp);
+	tmp_list->aer = 0;
 	tmp_list->undi = after_undi ? (1 << BP_PORT(bp)) : 0;
 
 	rc = down_interruptible(&bnx2x_prev_sem);
@@ -9763,8 +9812,8 @@ static int bnx2x_prev_mark_path(struct bnx2x *bp, bool after_undi)
 		BNX2X_ERR("Received %d when tried to take lock\n", rc);
 		kfree(tmp_list);
 	} else {
-		BNX2X_DEV_INFO("Marked path [%d] - finished previous unload\n",
-				BP_PATH(bp));
+		DP(NETIF_MSG_HW, "Marked path [%d] - finished previous unload\n",
+		   BP_PATH(bp));
 		list_add(&tmp_list->list, &bnx2x_prev_list);
 		up(&bnx2x_prev_sem);
 	}
@@ -10003,6 +10052,7 @@ static int bnx2x_prev_unload(struct bnx2x *bp)
 	}
 
 	do {
+		int aer = 0;
 		/* Lock MCP using an unload request */
 		fw = bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS, 0);
 		if (!fw) {
@@ -10011,7 +10061,18 @@ static int bnx2x_prev_unload(struct bnx2x *bp)
 			break;
 		}
 
-		if (fw == FW_MSG_CODE_DRV_UNLOAD_COMMON) {
+		rc = down_interruptible(&bnx2x_prev_sem);
+		if (rc) {
+			BNX2X_ERR("Cannot check for AER; Received %d when tried to take lock\n",
+				  rc);
+		} else {
+			/* If Path is marked by EEH, ignore unload status */
+			aer = !!(bnx2x_prev_path_get_entry(bp) &&
+				 bnx2x_prev_path_get_entry(bp)->aer);
+		}
+		up(&bnx2x_prev_sem);
+
+		if (fw == FW_MSG_CODE_DRV_UNLOAD_COMMON || aer) {
 			rc = bnx2x_prev_unload_common(bp);
 			break;
 		}
@@ -12632,9 +12693,7 @@ static void bnx2x_remove_one(struct pci_dev *pdev)
 
 static int bnx2x_eeh_nic_unload(struct bnx2x *bp)
 {
-	int i;
-
-	bp->state = BNX2X_STATE_ERROR;
+	bp->state = BNX2X_STATE_CLOSING_WAIT4_HALT;
 
 	bp->rx_mode = BNX2X_RX_MODE_NONE;
 
@@ -12643,29 +12702,21 @@ static int bnx2x_eeh_nic_unload(struct bnx2x *bp)
 
 	/* Stop Tx */
 	bnx2x_tx_disable(bp);
-
-	bnx2x_netif_stop(bp, 0);
 	/* Delete all NAPI objects */
 	bnx2x_del_all_napi(bp);
 	if (CNIC_LOADED(bp))
 		bnx2x_del_all_napi_cnic(bp);
+	netdev_reset_tc(bp->dev);
 
 	del_timer_sync(&bp->timer);
+	cancel_delayed_work(&bp->sp_task);
+	cancel_delayed_work(&bp->period_task);
 
-	bnx2x_stats_handle(bp, STATS_EVENT_STOP);
-
-	/* Release IRQs */
-	bnx2x_free_irq(bp);
-
-	/* Free SKBs, SGEs, TPA pool and driver internals */
-	bnx2x_free_skbs(bp);
-
-	for_each_rx_queue(bp, i)
-		bnx2x_free_rx_sge_range(bp, bp->fp + i, NUM_RX_SGE);
-
-	bnx2x_free_mem(bp);
+	spin_lock_bh(&bp->stats_lock);
+	bp->stats_state = STATS_STATE_DISABLED;
+	spin_unlock_bh(&bp->stats_lock);
 
-	bp->state = BNX2X_STATE_CLOSED;
+	bnx2x_save_statistics(bp);
 
 	netif_carrier_off(bp->dev);
 
@@ -12701,6 +12752,8 @@ static pci_ers_result_t bnx2x_io_error_detected(struct pci_dev *pdev,
 
 	rtnl_lock();
 
+	BNX2X_ERR("IO error detected\n");
+
 	netif_device_detach(dev);
 
 	if (state == pci_channel_io_perm_failure) {
@@ -12711,6 +12764,8 @@ static pci_ers_result_t bnx2x_io_error_detected(struct pci_dev *pdev,
 	if (netif_running(dev))
 		bnx2x_eeh_nic_unload(bp);
 
+	bnx2x_prev_path_mark_eeh(bp);
+
 	pci_disable_device(pdev);
 
 	rtnl_unlock();
@@ -12729,9 +12784,10 @@ static pci_ers_result_t bnx2x_io_slot_reset(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct bnx2x *bp = netdev_priv(dev);
+	int i;
 
 	rtnl_lock();
-
+	BNX2X_ERR("IO slot reset initializing...\n");
 	if (pci_enable_device(pdev)) {
 		dev_err(&pdev->dev,
 			"Cannot re-enable PCI device after reset\n");
@@ -12745,6 +12801,42 @@ static pci_ers_result_t bnx2x_io_slot_reset(struct pci_dev *pdev)
 	if (netif_running(dev))
 		bnx2x_set_power_state(bp, PCI_D0);
 
+	if (netif_running(dev)) {
+		BNX2X_ERR("IO slot reset --> driver unload\n");
+		if (IS_PF(bp) && SHMEM2_HAS(bp, drv_capabilities_flag)) {
+			u32 v;
+
+			v = SHMEM2_RD(bp,
+				      drv_capabilities_flag[BP_FW_MB_IDX(bp)]);
+			SHMEM2_WR(bp, drv_capabilities_flag[BP_FW_MB_IDX(bp)],
+				  v & ~DRV_FLAGS_CAPABILITIES_LOADED_L2);
+		}
+		bnx2x_drain_tx_queues(bp);
+		bnx2x_send_unload_req(bp, UNLOAD_RECOVERY);
+		bnx2x_netif_stop(bp, 1);
+		bnx2x_free_irq(bp);
+
+		/* Report UNLOAD_DONE to MCP */
+		bnx2x_send_unload_done(bp, true);
+
+		bp->sp_state = 0;
+		bp->port.pmf = 0;
+
+		bnx2x_prev_unload(bp);
+
+		/* We should have resetted the engine, so It's fair to
+		 * assume the FW will no longer write to the bnx2x driver.
+		 */
+		bnx2x_squeeze_objects(bp);
+		bnx2x_free_skbs(bp);
+		for_each_rx_queue(bp, i)
+			bnx2x_free_rx_sge_range(bp, bp->fp + i, NUM_RX_SGE);
+		bnx2x_free_fp_mem(bp);
+		bnx2x_free_mem(bp);
+
+		bp->state = BNX2X_STATE_CLOSED;
+	}
+
 	rtnl_unlock();
 
 	return PCI_ERS_RESULT_RECOVERED;
@@ -12771,6 +12863,9 @@ static void bnx2x_io_resume(struct pci_dev *pdev)
 
 	bnx2x_eeh_recover(bp);
 
+	bp->fw_seq = SHMEM_RD(bp, func_mb[BP_FW_MB_IDX(bp)].drv_mb_header) &
+							DRV_MSG_SEQ_NUMBER_MASK;
+
 	if (netif_running(dev))
 		bnx2x_nic_load(bp, LOAD_NORMAL);
 
-- 
1.8.1.227.g44fe835

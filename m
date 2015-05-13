From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Subject: [PATCH net-next 2/3] be2net: Report a "link down" to the stack when a fatal error or fw reset happens.
Date: Wed, 13 May 2015 13:00:13 +0530
Message-ID: <1431502214-11810-3-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
References: <1431502214-11810-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
Cc: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:49883 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753379AbbEMHwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 03:52:03 -0400
In-Reply-To: <1431502214-11810-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an error (related to HW or FW) is detected on a function, the driver
must pro-actively report a "link down" to the stack so that a possible
failover can be initiated. This is being done currently only for some
HW errors. This patch reports a "link down" even for fatal FW errors and
EEH errors.

Signed-off-by: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |   31 +++++++++++++------
 drivers/net/ethernet/emulex/benet/be_cmds.c |   10 +++---
 drivers/net/ethernet/emulex/benet/be_main.c |   42 ++++++++++++++------------
 3 files changed, 49 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index c62a32f..63922d4 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -522,6 +522,7 @@ struct be_adapter {
 	u16 work_counter;
 
 	struct delayed_work be_err_detection_work;
+	u8 err_flags;
 	u32 flags;
 	u32 cmd_privileges;
 	/* Ethtool knobs and info */
@@ -781,26 +782,36 @@ static inline bool is_ipv4_pkt(struct sk_buff *skb)
 	return skb->protocol == htons(ETH_P_IP) && ip_hdr(skb)->version == 4;
 }
 
-static inline bool be_multi_rxq(const struct be_adapter *adapter)
+#define BE_ERROR_EEH		1
+#define BE_ERROR_UE		BIT(1)
+#define BE_ERROR_FW		BIT(2)
+#define BE_ERROR_HW		(BE_ERROR_EEH | BE_ERROR_UE)
+#define BE_ERROR_ANY		(BE_ERROR_EEH | BE_ERROR_UE | BE_ERROR_FW)
+#define BE_CLEAR_ALL		0xFF
+
+static inline u8 be_check_error(struct be_adapter *adapter, u32 err_type)
 {
-	return adapter->num_rx_qs > 1;
+	return (adapter->err_flags & err_type);
 }
 
-static inline bool be_error(struct be_adapter *adapter)
+static inline void be_set_error(struct be_adapter *adapter, int err_type)
 {
-	return adapter->eeh_error || adapter->hw_error || adapter->fw_timeout;
+	struct net_device *netdev = adapter->netdev;
+
+	adapter->err_flags |= err_type;
+	netif_carrier_off(netdev);
+
+	dev_info(&adapter->pdev->dev, "%s: Link down\n", netdev->name);
 }
 
-static inline bool be_hw_error(struct be_adapter *adapter)
+static inline void  be_clear_error(struct be_adapter *adapter, int err_type)
 {
-	return adapter->eeh_error || adapter->hw_error;
+	adapter->err_flags &= ~err_type;
 }
 
-static inline void  be_clear_all_error(struct be_adapter *adapter)
+static inline bool be_multi_rxq(const struct be_adapter *adapter)
 {
-	adapter->eeh_error = false;
-	adapter->hw_error = false;
-	adapter->fw_timeout = false;
+	return adapter->num_rx_qs > 1;
 }
 
 void be_cq_notify(struct be_adapter *adapter, u16 qid, bool arm,
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index ecd92a0..dce8786 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -93,7 +93,7 @@ static void be_mcc_notify(struct be_adapter *adapter)
 	struct be_queue_info *mccq = &adapter->mcc_obj.q;
 	u32 val = 0;
 
-	if (be_error(adapter))
+	if (be_check_error(adapter, BE_ERROR_ANY))
 		return;
 
 	val |= mccq->id & DB_MCCQ_RING_ID_MASK;
@@ -489,7 +489,7 @@ static int be_mcc_wait_compl(struct be_adapter *adapter)
 	struct be_mcc_obj *mcc_obj = &adapter->mcc_obj;
 
 	for (i = 0; i < mcc_timeout; i++) {
-		if (be_error(adapter))
+		if (be_check_error(adapter, BE_ERROR_ANY))
 			return -EIO;
 
 		local_bh_disable();
@@ -502,7 +502,7 @@ static int be_mcc_wait_compl(struct be_adapter *adapter)
 	}
 	if (i == mcc_timeout) {
 		dev_err(&adapter->pdev->dev, "FW not responding\n");
-		adapter->fw_timeout = true;
+		be_set_error(adapter, BE_ERROR_FW);
 		return -EIO;
 	}
 	return status;
@@ -541,7 +541,7 @@ static int be_mbox_db_ready_wait(struct be_adapter *adapter, void __iomem *db)
 	u32 ready;
 
 	do {
-		if (be_error(adapter))
+		if (be_check_error(adapter, BE_ERROR_ANY))
 			return -EIO;
 
 		ready = ioread32(db);
@@ -554,7 +554,7 @@ static int be_mbox_db_ready_wait(struct be_adapter *adapter, void __iomem *db)
 
 		if (msecs > 4000) {
 			dev_err(&adapter->pdev->dev, "FW not responding\n");
-			adapter->fw_timeout = true;
+			be_set_error(adapter, BE_ERROR_FW);
 			be_detect_error(adapter);
 			return -1;
 		}
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index b4cea55..79fca82 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -179,7 +179,7 @@ static void be_intr_set(struct be_adapter *adapter, bool enable)
 	if (lancer_chip(adapter))
 		return;
 
-	if (adapter->eeh_error)
+	if (be_check_error(adapter, BE_ERROR_EEH))
 		return;
 
 	status = be_cmd_intr_set(adapter, enable);
@@ -191,6 +191,9 @@ static void be_rxq_notify(struct be_adapter *adapter, u16 qid, u16 posted)
 {
 	u32 val = 0;
 
+	if (be_check_error(adapter, BE_ERROR_HW))
+		return;
+
 	val |= qid & DB_RQ_RING_ID_MASK;
 	val |= posted << DB_RQ_NUM_POSTED_SHIFT;
 
@@ -203,6 +206,9 @@ static void be_txq_notify(struct be_adapter *adapter, struct be_tx_obj *txo,
 {
 	u32 val = 0;
 
+	if (be_check_error(adapter, BE_ERROR_HW))
+		return;
+
 	val |= txo->q.id & DB_TXULP_RING_ID_MASK;
 	val |= (posted & DB_TXULP_NUM_POSTED_MASK) << DB_TXULP_NUM_POSTED_SHIFT;
 
@@ -219,7 +225,7 @@ static void be_eq_notify(struct be_adapter *adapter, u16 qid,
 	val |= qid & DB_EQ_RING_ID_MASK;
 	val |= ((qid & DB_EQ_RING_ID_EXT_MASK) << DB_EQ_RING_ID_EXT_MASK_SHIFT);
 
-	if (adapter->eeh_error)
+	if (be_check_error(adapter, BE_ERROR_HW))
 		return;
 
 	if (arm)
@@ -240,7 +246,7 @@ void be_cq_notify(struct be_adapter *adapter, u16 qid, bool arm, u16 num_popped)
 	val |= ((qid & DB_CQ_RING_ID_EXT_MASK) <<
 			DB_CQ_RING_ID_EXT_MASK_SHIFT);
 
-	if (adapter->eeh_error)
+	if (be_check_error(adapter, BE_ERROR_HW))
 		return;
 
 	if (arm)
@@ -2324,7 +2330,9 @@ static void be_rx_cq_clean(struct be_rx_obj *rxo)
 			if (lancer_chip(adapter))
 				break;
 
-			if (flush_wait++ > 10 || be_hw_error(adapter)) {
+			if (flush_wait++ > 50 ||
+			    be_check_error(adapter,
+					   BE_ERROR_HW)) {
 				dev_warn(&adapter->pdev->dev,
 					 "did not receive flush compl\n");
 				break;
@@ -2385,7 +2393,8 @@ static void be_tx_compl_clean(struct be_adapter *adapter)
 				pending_txqs--;
 		}
 
-		if (pending_txqs == 0 || ++timeo > 10 || be_hw_error(adapter))
+		if (pending_txqs == 0 || ++timeo > 10 ||
+		    be_check_error(adapter, BE_ERROR_HW))
 			break;
 
 		mdelay(1);
@@ -2995,22 +3004,19 @@ void be_detect_error(struct be_adapter *adapter)
 	u32 ue_lo = 0, ue_hi = 0, ue_lo_mask = 0, ue_hi_mask = 0;
 	u32 sliport_status = 0, sliport_err1 = 0, sliport_err2 = 0;
 	u32 i;
-	bool error_detected = false;
 	struct device *dev = &adapter->pdev->dev;
-	struct net_device *netdev = adapter->netdev;
 
-	if (be_hw_error(adapter))
+	if (be_check_error(adapter, BE_ERROR_HW))
 		return;
 
 	if (lancer_chip(adapter)) {
 		sliport_status = ioread32(adapter->db + SLIPORT_STATUS_OFFSET);
 		if (sliport_status & SLIPORT_STATUS_ERR_MASK) {
+			be_set_error(adapter, BE_ERROR_UE);
 			sliport_err1 = ioread32(adapter->db +
 						SLIPORT_ERROR1_OFFSET);
 			sliport_err2 = ioread32(adapter->db +
 						SLIPORT_ERROR2_OFFSET);
-			adapter->hw_error = true;
-			error_detected = true;
 			/* Do not log error messages if its a FW reset */
 			if (sliport_err1 == SLIPORT_ERROR_FW_RESET1 &&
 			    sliport_err2 == SLIPORT_ERROR_FW_RESET2) {
@@ -3042,12 +3048,12 @@ void be_detect_error(struct be_adapter *adapter)
 		 */
 
 		if (ue_lo || ue_hi) {
-			error_detected = true;
 			dev_err(dev,
 				"Unrecoverable Error detected in the adapter");
 			dev_err(dev, "Please reboot server to recover");
 			if (skyhawk_chip(adapter))
-				adapter->hw_error = true;
+				be_set_error(adapter, BE_ERROR_UE);
+
 			for (i = 0; ue_lo; ue_lo >>= 1, i++) {
 				if (ue_lo & 1)
 					dev_err(dev, "UE: %s bit set\n",
@@ -3060,8 +3066,6 @@ void be_detect_error(struct be_adapter *adapter)
 			}
 		}
 	}
-	if (error_detected)
-		netif_carrier_off(netdev);
 }
 
 static void be_msix_disable(struct be_adapter *adapter)
@@ -4183,7 +4187,7 @@ static int be_func_init(struct be_adapter *adapter)
 		msleep(100);
 
 		/* We can clear all errors when function reset succeeds */
-		be_clear_all_error(adapter);
+		be_clear_error(adapter, BE_CLEAR_ALL);
 	}
 
 	/* Tell FW we're ready to fire cmds */
@@ -5204,7 +5208,7 @@ static void be_err_detection_task(struct work_struct *work)
 
 	be_detect_error(adapter);
 
-	if (adapter->hw_error) {
+	if (be_check_error(adapter, BE_ERROR_HW)) {
 		be_cleanup(adapter);
 
 		/* As of now error recovery support is in Lancer only */
@@ -5715,8 +5719,8 @@ static pci_ers_result_t be_eeh_err_detected(struct pci_dev *pdev,
 
 	dev_err(&adapter->pdev->dev, "EEH error detected\n");
 
-	if (!adapter->eeh_error) {
-		adapter->eeh_error = true;
+	if (!be_check_error(adapter, BE_ERROR_EEH)) {
+		be_set_error(adapter, BE_ERROR_EEH);
 
 		be_cancel_err_detection(adapter);
 
@@ -5763,7 +5767,7 @@ static pci_ers_result_t be_eeh_reset(struct pci_dev *pdev)
 		return PCI_ERS_RESULT_DISCONNECT;
 
 	pci_cleanup_aer_uncorrect_error_status(pdev);
-	be_clear_all_error(adapter);
+	be_clear_error(adapter, BE_CLEAR_ALL);
 	return PCI_ERS_RESULT_RECOVERED;
 }
 
-- 
1.7.1

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH repost net-next 3/3] qed*: Add and modify some prints
Date: Mon, 15 Aug 2016 10:42:45 +0300
Message-ID: <1471246965-26031-4-git-send-email-Yuval.Mintz@qlogic.com>
References: <1471246965-26031-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:40716 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752762AbcHOHm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 03:42:58 -0400
In-Reply-To: <1471246965-26031-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch touches various prints in the driver - it reduces the
verbosity of some prints [which were previously logged by default]
while adding several new debug prints and modifying others.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c    | 10 +++++++---
 drivers/net/ethernet/qlogic/qed/qed_int.c    |  8 ++++++--
 drivers/net/ethernet/qlogic/qed/qed_main.c   | 21 +++++++++++++++------
 drivers/net/ethernet/qlogic/qed/qed_mcp.c    |  7 ++++---
 drivers/net/ethernet/qlogic/qed/qed_spq.c    | 11 +++++++++--
 drivers/net/ethernet/qlogic/qede/qede_main.c | 20 ++++++++++++--------
 6 files changed, 53 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index da23169..66e9f91 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -1211,7 +1211,7 @@ static int qed_reg_assert(struct qed_hwfn *p_hwfn,
 	u32 assert_val = qed_rd(p_hwfn, p_ptt, reg);
 
 	if (assert_val != expected) {
-		DP_NOTICE(p_hwfn, "Value at address 0x%x != 0x%08x\n",
+		DP_NOTICE(p_hwfn, "Value at address 0x%08x != 0x%08x\n",
 			  reg, expected);
 		return -EINVAL;
 	}
@@ -1311,6 +1311,10 @@ static void get_function_id(struct qed_hwfn *p_hwfn)
 				      PXP_CONCRETE_FID_PFID);
 	p_hwfn->port_id = GET_FIELD(p_hwfn->hw_info.concrete_fid,
 				    PXP_CONCRETE_FID_PORT);
+
+	DP_VERBOSE(p_hwfn, NETIF_MSG_PROBE,
+		   "Read ME register: Concrete 0x%08x Opaque 0x%04x\n",
+		   p_hwfn->hw_info.concrete_fid, p_hwfn->hw_info.opaque_fid);
 }
 
 static void qed_hw_set_feat(struct qed_hwfn *p_hwfn)
@@ -1610,10 +1614,10 @@ static void qed_get_num_funcs(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 
 	DP_VERBOSE(p_hwfn,
 		   NETIF_MSG_PROBE,
-		   "PF [rel_id %d, abs_id %d] within the %d enabled functions on the engine\n",
+		   "PF [rel_id %d, abs_id %d] occupies index %d within the %d enabled functions on the engine\n",
 		   p_hwfn->rel_pf_id,
 		   p_hwfn->abs_pf_id,
-		   p_hwfn->num_funcs_on_engine);
+		   p_hwfn->enabled_func_idx, p_hwfn->num_funcs_on_engine);
 }
 
 static int
diff --git a/drivers/net/ethernet/qlogic/qed/qed_int.c b/drivers/net/ethernet/qlogic/qed/qed_int.c
index a701b76..61ec973 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_int.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_int.c
@@ -2576,8 +2576,12 @@ static u16 qed_get_igu_sb_id(struct qed_hwfn *p_hwfn, u16 sb_id)
 	else
 		igu_sb_id = qed_vf_get_igu_sb_id(p_hwfn, sb_id);
 
-	DP_VERBOSE(p_hwfn, NETIF_MSG_INTR, "SB [%s] index is 0x%04x\n",
-		   (sb_id == QED_SP_SB_ID) ? "DSB" : "non-DSB", igu_sb_id);
+	if (sb_id == QED_SP_SB_ID)
+		DP_VERBOSE(p_hwfn, NETIF_MSG_INTR,
+			   "Slowpath SB index in IGU is 0x%04x\n", igu_sb_id);
+	else
+		DP_VERBOSE(p_hwfn, NETIF_MSG_INTR,
+			   "SB [%04x] <--> IGU SB [%04x]\n", sb_id, igu_sb_id);
 
 	return igu_sb_id;
 }
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index aacd00f..675a503 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -51,8 +51,6 @@ MODULE_FIRMWARE(QED_FW_FILE_NAME);
 
 static int __init qed_init(void)
 {
-	pr_notice("qed_init called\n");
-
 	pr_info("%s", version);
 
 	return 0;
@@ -437,6 +435,11 @@ static int qed_set_int_mode(struct qed_dev *cdev, bool force_mode)
 	}
 
 out:
+	if (!rc)
+		DP_INFO(cdev, "Using %s interrupts\n",
+			int_params->out.int_mode == QED_INT_MODE_INTA ?
+			"INTa" : int_params->out.int_mode == QED_INT_MODE_MSI ?
+			"MSI" : "MSIX");
 	cdev->int_coalescing_mode = QED_COAL_MODE_ENABLE;
 
 	return rc;
@@ -512,19 +515,18 @@ static irqreturn_t qed_single_int(int irq, void *dev_instance)
 int qed_slowpath_irq_req(struct qed_hwfn *hwfn)
 {
 	struct qed_dev *cdev = hwfn->cdev;
+	u32 int_mode;
 	int rc = 0;
 	u8 id;
 
-	if (cdev->int_params.out.int_mode == QED_INT_MODE_MSIX) {
+	int_mode = cdev->int_params.out.int_mode;
+	if (int_mode == QED_INT_MODE_MSIX) {
 		id = hwfn->my_id;
 		snprintf(hwfn->name, NAME_SIZE, "sp-%d-%02x:%02x.%02x",
 			 id, cdev->pdev->bus->number,
 			 PCI_SLOT(cdev->pdev->devfn), hwfn->abs_pf_id);
 		rc = request_irq(cdev->int_params.msix_table[id].vector,
 				 qed_msix_sp_int, 0, hwfn->name, hwfn->sp_dpc);
-		if (!rc)
-			DP_VERBOSE(hwfn, (NETIF_MSG_INTR | QED_MSG_SP),
-				   "Requested slowpath MSI-X\n");
 	} else {
 		unsigned long flags = 0;
 
@@ -539,6 +541,13 @@ int qed_slowpath_irq_req(struct qed_hwfn *hwfn)
 				 flags, cdev->name, cdev);
 	}
 
+	if (rc)
+		DP_NOTICE(cdev, "request_irq failed, rc = %d\n", rc);
+	else
+		DP_VERBOSE(hwfn, (NETIF_MSG_INTR | QED_MSG_SP),
+			   "Requested slowpath %s\n",
+			   (int_mode == QED_INT_MODE_MSIX) ? "MSI-X" : "IRQ");
+
 	return rc;
 }
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index ad86262..a68bcf9 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -317,7 +317,8 @@ static int qed_do_mcp_cmd(struct qed_hwfn *p_hwfn,
 		*o_mcp_param = DRV_MB_RD(p_hwfn, p_ptt, fw_mb_param);
 	} else {
 		/* FW BUG! */
-		DP_ERR(p_hwfn, "MFW failed to respond!\n");
+		DP_ERR(p_hwfn, "MFW failed to respond [cmd 0x%x param 0x%x]\n",
+		       cmd, param);
 		*o_mcp_resp = 0;
 		rc = -EAGAIN;
 	}
@@ -333,7 +334,7 @@ static int qed_mcp_cmd_and_union(struct qed_hwfn *p_hwfn,
 
 	/* MCP not initialized */
 	if (!qed_mcp_is_init(p_hwfn)) {
-		DP_NOTICE(p_hwfn, "MFW is not initialized !\n");
+		DP_NOTICE(p_hwfn, "MFW is not initialized!\n");
 		return -EBUSY;
 	}
 
@@ -932,7 +933,7 @@ int qed_mcp_get_media_type(struct qed_dev *cdev, u32 *p_media_type)
 		return -EINVAL;
 
 	if (!qed_mcp_is_init(p_hwfn)) {
-		DP_NOTICE(p_hwfn, "MFW is not initialized !\n");
+		DP_NOTICE(p_hwfn, "MFW is not initialized!\n");
 		return -EBUSY;
 	}
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_spq.c b/drivers/net/ethernet/qlogic/qed/qed_spq.c
index 5e68a33..0265a32 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_spq.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_spq.c
@@ -824,15 +824,22 @@ int qed_spq_completion(struct qed_hwfn *p_hwfn,
 
 	if (!found) {
 		DP_NOTICE(p_hwfn,
-			  "Failed to find an entry this EQE completes\n");
+			  "Failed to find an entry this EQE [echo %04x] completes\n",
+			  le16_to_cpu(echo));
 		return -EEXIST;
 	}
 
-	DP_VERBOSE(p_hwfn, QED_MSG_SPQ, "Complete: func %p cookie %p)\n",
+	DP_VERBOSE(p_hwfn, QED_MSG_SPQ,
+		   "Complete EQE [echo %04x]: func %p cookie %p)\n",
+		   le16_to_cpu(echo),
 		   p_ent->comp_cb.function, p_ent->comp_cb.cookie);
 	if (found->comp_cb.function)
 		found->comp_cb.function(p_hwfn, found->comp_cb.cookie, p_data,
 					fw_return_code);
+	else
+		DP_VERBOSE(p_hwfn,
+			   QED_MSG_SPQ,
+			   "Got a completion without a callback function\n");
 
 	if ((found->comp_mode != QED_SPQ_MODE_EBLOCK) ||
 	    (found->queue == &p_spq->unlimited_pending))
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 0bf0e55..be6254e 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -222,7 +222,7 @@ int __init qede_init(void)
 {
 	int ret;
 
-	pr_notice("qede_init: %s\n", version);
+	pr_info("qede_init: %s\n", version);
 
 	qed_ops = qed_get_eth_ops();
 	if (!qed_ops) {
@@ -253,7 +253,8 @@ int __init qede_init(void)
 
 static void __exit qede_cleanup(void)
 {
-	pr_notice("qede_cleanup called\n");
+	if (debug & QED_LOG_INFO_MASK)
+		pr_info("qede_cleanup called\n");
 
 	unregister_netdevice_notifier(&qede_netdev_notifier);
 	pci_unregister_driver(&qede_pci_driver);
@@ -1453,7 +1454,7 @@ alloc_skb:
 		skb = netdev_alloc_skb(edev->ndev, QEDE_RX_HDR_SIZE);
 		if (unlikely(!skb)) {
 			DP_NOTICE(edev,
-				  "Build_skb failed, dropping incoming packet\n");
+				  "skb allocation failed, dropping incoming packet\n");
 			qede_recycle_rx_bd_ring(rxq, edev, fp_cqe->bd_num);
 			rxq->rx_alloc_errors++;
 			goto next_cqe;
@@ -2127,7 +2128,7 @@ static void qede_udp_tunnel_add(struct net_device *dev,
 
 		edev->vxlan_dst_port = t_port;
 
-		DP_VERBOSE(edev, QED_MSG_DEBUG, "Added vxlan port=%d",
+		DP_VERBOSE(edev, QED_MSG_DEBUG, "Added vxlan port=%d\n",
 			   t_port);
 
 		set_bit(QEDE_SP_VXLAN_PORT_CONFIG, &edev->sp_flags);
@@ -2138,7 +2139,7 @@ static void qede_udp_tunnel_add(struct net_device *dev,
 
 		edev->geneve_dst_port = t_port;
 
-		DP_VERBOSE(edev, QED_MSG_DEBUG, "Added geneve port=%d",
+		DP_VERBOSE(edev, QED_MSG_DEBUG, "Added geneve port=%d\n",
 			   t_port);
 		set_bit(QEDE_SP_GENEVE_PORT_CONFIG, &edev->sp_flags);
 		break;
@@ -2162,7 +2163,7 @@ static void qede_udp_tunnel_del(struct net_device *dev,
 
 		edev->vxlan_dst_port = 0;
 
-		DP_VERBOSE(edev, QED_MSG_DEBUG, "Deleted vxlan port=%d",
+		DP_VERBOSE(edev, QED_MSG_DEBUG, "Deleted vxlan port=%d\n",
 			   t_port);
 
 		set_bit(QEDE_SP_VXLAN_PORT_CONFIG, &edev->sp_flags);
@@ -2173,7 +2174,7 @@ static void qede_udp_tunnel_del(struct net_device *dev,
 
 		edev->geneve_dst_port = 0;
 
-		DP_VERBOSE(edev, QED_MSG_DEBUG, "Deleted geneve port=%d",
+		DP_VERBOSE(edev, QED_MSG_DEBUG, "Deleted geneve port=%d\n",
 			   t_port);
 		set_bit(QEDE_SP_GENEVE_PORT_CONFIG, &edev->sp_flags);
 		break;
@@ -2240,6 +2241,9 @@ static struct qede_dev *qede_alloc_etherdev(struct qed_dev *cdev,
 	edev->q_num_rx_buffers = NUM_RX_BDS_DEF;
 	edev->q_num_tx_buffers = NUM_TX_BDS_DEF;
 
+	DP_INFO(edev, "Allocated netdev with %d tx queues and %d rx queues\n",
+		info->num_queues, info->num_queues);
+
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 
 	memset(&edev->stats, 0, sizeof(edev->stats));
@@ -2565,7 +2569,7 @@ static void __qede_remove(struct pci_dev *pdev, enum qede_remove_mode mode)
 	qed_ops->common->slowpath_stop(cdev);
 	qed_ops->common->remove(cdev);
 
-	pr_notice("Ending successfully qede_remove\n");
+	dev_info(&pdev->dev, "Ending qede_remove successfully\n");
 }
 
 static void qede_remove(struct pci_dev *pdev)
-- 
1.9.3

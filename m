From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH v1 12/19] qlcnic: update irq management routines
Date: Wed, 19 Sep 2012 15:29:50 -0400
Message-ID: <1348082997-12333-13-git-send-email-sony.chacko@qlogic.com>
References: <1348082997-12333-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:48569 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1750852Ab2ITBMk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 21:12:40 -0400
In-Reply-To: <1348082997-12333-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Refactor 82xx driver to support new adapter - Qlogic 83XX CNA

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h      |    4 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |  135 ++++++++++++++--------
 2 files changed, 92 insertions(+), 47 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 151b43f..f06943d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -468,6 +468,7 @@ struct qlcnic_hardware_context {
 	u8 mc_enabled;
 	u8 max_mc_count;
 	u8 diag_test;
+	u8 num_msix;
 	char diag_cnt;
 
 	u16 port_type;
@@ -493,6 +494,7 @@ struct qlcnic_hardware_context {
 	struct qlcnic_hardware_ops *hw_ops;
 	struct qlcnic_nic_intr_coalesce coal;
 	struct qlcnic_fw_dump fw_dump;
+	struct qlcnic_intrpt_config *intr_tbl;
 	u32 *reg_tbl;
 	u32 *ext_reg_tbl;
 };
@@ -554,6 +556,8 @@ struct qlcnic_host_sds_ring {
 
 struct qlcnic_host_tx_ring {
 	int irq;
+	void __iomem *crb_intr_mask;
+	char name[IFNAMSIZ+4];
 	u16 ctx_id;
 	u32 producer;
 	u32 sw_consumer;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 1dadeb4..84ef9eb 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -87,6 +87,7 @@ static irqreturn_t qlcnic_tmp_intr(int irq, void *data);
 static irqreturn_t qlcnic_intr(int irq, void *data);
 static irqreturn_t qlcnic_msi_intr(int irq, void *data);
 static irqreturn_t qlcnic_msix_intr(int irq, void *data);
+static irqreturn_t qlcnic_msix_tx_intr(int irq, void *data);
 
 static struct net_device_stats *qlcnic_get_stats(struct net_device *netdev);
 static void qlcnic_restore_indev_addr(struct net_device *dev, unsigned long);
@@ -269,30 +270,6 @@ qlcnic_alloc_tx_rings(struct qlcnic_adapter *adapter, struct net_device *netdev)
 	return 0;
 }
 
-static void qlcnic_set_msix_bit(struct pci_dev *pdev, int enable)
-{
-	u32 control;
-	int pos;
-
-	pos = pci_find_capability(pdev, PCI_CAP_ID_MSIX);
-	if (pos) {
-		pci_read_config_dword(pdev, pos, &control);
-		if (enable)
-			control |= PCI_MSIX_FLAGS_ENABLE;
-		else
-			control = 0;
-		pci_write_config_dword(pdev, pos, control);
-	}
-}
-
-static void qlcnic_init_msix_entries(struct qlcnic_adapter *adapter, int count)
-{
-	int i;
-
-	for (i = 0; i < count; i++)
-		adapter->msix_entries[i].entry = i;
-}
-
 static int
 qlcnic_read_mac_addr(struct qlcnic_adapter *adapter)
 {
@@ -426,32 +403,50 @@ static struct qlcnic_hardware_ops qlcnic_hw_ops = {
 	.get_board_info			= qlcnic_82xx_get_board_info,
 };
 
-static int qlcnic_enable_msix(struct qlcnic_adapter *adapter, u32 num_msix)
+int qlcnic_enable_msix(struct qlcnic_adapter *adapter, u32 num_msix)
 {
 	struct pci_dev *pdev = adapter->pdev;
-	int err = -1;
+	int err = -1, i;
+
+	if (!adapter->msix_entries) {
+		adapter->msix_entries = kcalloc(num_msix,
+						sizeof(struct msix_entry),
+						GFP_KERNEL);
+		if (!adapter->msix_entries) {
+			dev_err(&pdev->dev, "failed allocating msix_entries\n");
+			return -ENOMEM;
+		}
+	}
 
 	adapter->max_sds_rings = 1;
 	adapter->flags &= ~(QLCNIC_MSI_ENABLED | QLCNIC_MSIX_ENABLED);
-	qlcnic_set_msix_bit(pdev, 0);
 
 	if (adapter->ahw->msix_supported) {
  enable_msix:
-		qlcnic_init_msix_entries(adapter, num_msix);
+		for (i = 0; i < num_msix; i++)
+			adapter->msix_entries[i].entry = i;
+
 		err = pci_enable_msix(pdev, adapter->msix_entries, num_msix);
 		if (err == 0) {
 			adapter->flags |= QLCNIC_MSIX_ENABLED;
-			qlcnic_set_msix_bit(pdev, 1);
-
-			adapter->max_sds_rings = num_msix;
+			if (QLCNIC_IS_83XX(adapter)) {
+				adapter->ahw->num_msix = num_msix;
+				/* subtract 2 vectors for mailbox and tx ring */
+				adapter->max_sds_rings = num_msix - 2;
+			} else {
+				adapter->max_sds_rings = num_msix;
+			}
 
 			dev_info(&pdev->dev, "using msi-x interrupts\n");
 			return err;
-		}
-		if (err > 0) {
+		} else if (err > 0) {
+			dev_info(&pdev->dev, "%s, failed", __func__);
 			num_msix = rounddown_pow_of_two(err);
-			if (num_msix)
+			if (num_msix) {
+				if (QLCNIC_IS_83XX(adapter))
+					num_msix += 1;
 				goto enable_msix;
+			}
 		}
 	}
 	return err;
@@ -509,6 +504,7 @@ qlcnic_82xx_setup_intr(struct qlcnic_adapter *adapter, u8 num_intr)
 	qlcnic_enable_msi_legacy(adapter);
 	return 0;
 }
+
 static void
 qlcnic_teardown_intr(struct qlcnic_adapter *adapter)
 {
@@ -516,6 +512,13 @@ qlcnic_teardown_intr(struct qlcnic_adapter *adapter)
 		pci_disable_msix(adapter->pdev);
 	if (adapter->flags & QLCNIC_MSI_ENABLED)
 		pci_disable_msi(adapter->pdev);
+	kfree(adapter->msix_entries);
+	adapter->msix_entries = NULL;
+
+	if (adapter->ahw->intr_tbl) {
+		vfree(adapter->ahw->intr_tbl);
+		adapter->ahw->intr_tbl = NULL;
+	}
 }
 
 static void
@@ -1180,6 +1183,7 @@ qlcnic_request_irq(struct qlcnic_adapter *adapter)
 {
 	irq_handler_t handler;
 	struct qlcnic_host_sds_ring *sds_ring;
+	struct qlcnic_host_tx_ring *tx_ring;
 	int err, ring;
 
 	unsigned long flags = 0;
@@ -1187,7 +1191,8 @@ qlcnic_request_irq(struct qlcnic_adapter *adapter)
 	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 
 	if (adapter->ahw->diag_test == QLCNIC_INTERRUPT_TEST) {
-		handler = qlcnic_tmp_intr;
+		if (QLCNIC_IS_82XX(adapter))
+			handler = qlcnic_tmp_intr;
 		if (!QLCNIC_IS_MSI_FAMILY(adapter))
 			flags |= IRQF_SHARED;
 
@@ -1203,15 +1208,32 @@ qlcnic_request_irq(struct qlcnic_adapter *adapter)
 	}
 	adapter->irq = netdev->irq;
 
-	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
-		sds_ring = &recv_ctx->sds_rings[ring];
-		sprintf(sds_ring->name, "%s[%d]", netdev->name, ring);
-		err = request_irq(sds_ring->irq, handler,
-				  flags, sds_ring->name, sds_ring);
-		if (err)
-			return err;
+	if (adapter->ahw->diag_test != QLCNIC_LOOPBACK_TEST) {
+		for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+			sds_ring = &recv_ctx->sds_rings[ring];
+			snprintf(sds_ring->name, sizeof(int) + IFNAMSIZ,
+				 "%s[%d]", netdev->name, ring);
+			err = request_irq(sds_ring->irq, handler, flags,
+					  sds_ring->name, sds_ring);
+			if (err)
+				return err;
+		}
+		if (QLCNIC_IS_83XX(adapter) &&
+				(adapter->flags & QLCNIC_MSIX_ENABLED)) {
+			handler = qlcnic_msix_tx_intr;
+			for (ring = 0; ring < adapter->max_drv_tx_rings;
+								ring++) {
+				tx_ring = &adapter->tx_ring[ring];
+				snprintf(tx_ring->name, sizeof(int) + IFNAMSIZ,
+					 "%s[%d]", netdev->name,
+				adapter->max_sds_rings + ring);
+				err = request_irq(tx_ring->irq, handler, flags,
+						  tx_ring->name, tx_ring);
+				if (err)
+					return err;
+			}
+		}
 	}
-
 	return 0;
 }
 
@@ -1220,12 +1242,23 @@ qlcnic_free_irq(struct qlcnic_adapter *adapter)
 {
 	int ring;
 	struct qlcnic_host_sds_ring *sds_ring;
+	struct qlcnic_host_tx_ring *tx_ring;
 
 	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 
-	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
-		sds_ring = &recv_ctx->sds_rings[ring];
-		free_irq(sds_ring->irq, sds_ring);
+	if (adapter->ahw->diag_test != QLCNIC_LOOPBACK_TEST) {
+		for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+			sds_ring = &recv_ctx->sds_rings[ring];
+			free_irq(sds_ring->irq, sds_ring);
+		}
+		if (QLCNIC_IS_83XX(adapter)) {
+			for (ring = 0; ring < adapter->max_drv_tx_rings;
+				 ring++) {
+				tx_ring = &adapter->tx_ring[ring];
+				if (tx_ring->irq)
+					free_irq(tx_ring->irq, tx_ring);
+			}
+		}
 	}
 }
 
@@ -2114,7 +2147,7 @@ static irqreturn_t qlcnic_tmp_intr(int irq, void *data)
 
 done:
 	adapter->ahw->diag_cnt++;
-	qlcnic_enable_int(sds_ring);
+	QLCNIC_ENABLE_INTR(adapter, sds_ring->crb_intr_mask);
 	return IRQ_HANDLED;
 }
 
@@ -2151,6 +2184,14 @@ static irqreturn_t qlcnic_msix_intr(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
+static irqreturn_t qlcnic_msix_tx_intr(int irq, void *data)
+{
+	struct qlcnic_host_tx_ring *tx_ring = data;
+
+	napi_schedule(&tx_ring->napi);
+	return IRQ_HANDLED;
+}
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void qlcnic_poll_controller(struct net_device *netdev)
 {
-- 
1.7.1

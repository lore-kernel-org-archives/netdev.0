From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH net-next-2.6 1/2] qlcnic: Remove obsolete code
Date: Tue, 29 Jun 2010 10:52:12 -0700
Message-ID: <alpine.OSX.2.00.1006291025050.30643@macintosh-2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Ameen Rahman <ameen.rahman@qlogic.com>
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:45458 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751772Ab0F2RwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 13:52:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Current driver uses FW API version 2 and thus code corresponding to FW API
version 1 has become obsolete. Clean up this from the driver.

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_ctx.c  |   26 ++++----------------------
 drivers/net/qlcnic/qlcnic_hdr.h  |    6 ------
 drivers/net/qlcnic/qlcnic_init.c |   16 +++++++---------
 drivers/net/qlcnic/qlcnic_main.c |   22 ++--------------------
 4 files changed, 13 insertions(+), 57 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlcnic_ctx.c
index 941cd08..7969a7a 100644
--- a/drivers/net/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/qlcnic/qlcnic_ctx.c
@@ -224,12 +224,7 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 		rds_ring = &recv_ctx->rds_rings[i];
 
 		reg = le32_to_cpu(prsp_rds[i].host_producer_crb);
-		if (adapter->fw_hal_version == QLCNIC_FW_BASE)
-			rds_ring->crb_rcv_producer = qlcnic_get_ioaddr(adapter,
-				QLCNIC_REG(reg - 0x200));
-		else
-			rds_ring->crb_rcv_producer = adapter->ahw.pci_base0 +
-				reg;
+		rds_ring->crb_rcv_producer = adapter->ahw.pci_base0 + reg;
 	}
 
 	prsp_sds = ((struct qlcnic_cardrsp_sds_ring *)
@@ -241,16 +236,8 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 		reg = le32_to_cpu(prsp_sds[i].host_consumer_crb);
 		reg2 = le32_to_cpu(prsp_sds[i].interrupt_crb);
 
-		if (adapter->fw_hal_version == QLCNIC_FW_BASE) {
-			sds_ring->crb_sts_consumer = qlcnic_get_ioaddr(adapter,
-				QLCNIC_REG(reg - 0x200));
-			sds_ring->crb_intr_mask = qlcnic_get_ioaddr(adapter,
-				QLCNIC_REG(reg2 - 0x200));
-		} else {
-			sds_ring->crb_sts_consumer = adapter->ahw.pci_base0 +
-				reg;
-			sds_ring->crb_intr_mask = adapter->ahw.pci_base0 + reg2;
-		}
+		sds_ring->crb_sts_consumer = adapter->ahw.pci_base0 + reg;
+		sds_ring->crb_intr_mask = adapter->ahw.pci_base0 + reg2;
 	}
 
 	recv_ctx->state = le32_to_cpu(prsp->host_ctx_state);
@@ -352,12 +339,7 @@ qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
 
 	if (err == QLCNIC_RCODE_SUCCESS) {
 		temp = le32_to_cpu(prsp->cds_ring.host_producer_crb);
-		if (adapter->fw_hal_version == QLCNIC_FW_BASE)
-			tx_ring->crb_cmd_producer = qlcnic_get_ioaddr(adapter,
-				QLCNIC_REG(temp - 0x200));
-		else
-			tx_ring->crb_cmd_producer = adapter->ahw.pci_base0 +
-				temp;
+		tx_ring->crb_cmd_producer = adapter->ahw.pci_base0 + temp;
 
 		adapter->tx_context_id =
 			le16_to_cpu(prsp->context_id);
diff --git a/drivers/net/qlcnic/qlcnic_hdr.h b/drivers/net/qlcnic/qlcnic_hdr.h
index 7b81cab..15fc320 100644
--- a/drivers/net/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/qlcnic/qlcnic_hdr.h
@@ -778,12 +778,6 @@ enum {
 	QLCNIC_NON_PRIV_FUNC	= 2
 };
 
-/* FW HAL api version */
-enum {
-	QLCNIC_FW_BASE	= 1,
-	QLCNIC_FW_NPAR	= 2
-};
-
 #define QLC_DEV_DRV_DEFAULT 0x11111111
 
 #define LSB(x)	((uint8_t)(x))
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 6678127..75ba744 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -548,16 +548,14 @@ qlcnic_setup_idc_param(struct qlcnic_adapter *adapter) {
 	int timeo;
 	u32 val;
 
-	if (adapter->fw_hal_version == QLCNIC_FW_BASE) {
-		val = QLCRD32(adapter, QLCNIC_CRB_DEV_PARTITION_INFO);
-		val = QLC_DEV_GET_DRV(val, adapter->portnum);
-		if ((val & 0x3) != QLCNIC_TYPE_NIC) {
-			dev_err(&adapter->pdev->dev,
-				"Not an Ethernet NIC func=%u\n", val);
-			return -EIO;
-		}
-		adapter->physical_port = (val >> 2);
+	val = QLCRD32(adapter, QLCNIC_CRB_DEV_PARTITION_INFO);
+	val = QLC_DEV_GET_DRV(val, adapter->portnum);
+	if ((val & 0x3) != QLCNIC_TYPE_NIC) {
+		dev_err(&adapter->pdev->dev,
+			"Not an Ethernet NIC func=%u\n", val);
+		return -EIO;
 	}
+	adapter->physical_port = (val >> 2);
 	if (qlcnic_rom_fast_read(adapter, QLCNIC_ROM_DEV_INIT_TIMEOUT, &timeo))
 		timeo = 30;
 
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 3b71dfc..981aa91 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -377,15 +377,6 @@ static const struct net_device_ops qlcnic_netdev_ops = {
 };
 
 static struct qlcnic_nic_template qlcnic_ops = {
-	.get_mac_addr = qlcnic_get_mac_addr,
-	.config_bridged_mode = qlcnic_config_bridged_mode,
-	.config_led = qlcnic_config_led,
-	.set_ilb_mode = qlcnic_set_ilb_mode,
-	.clear_ilb_mode = qlcnic_clear_ilb_mode,
-	.start_firmware = qlcnic_start_firmware
-};
-
-static struct qlcnic_nic_template qlcnic_pf_ops = {
 	.get_mac_addr = qlcnic_get_mac_address,
 	.config_bridged_mode = qlcnic_config_bridged_mode,
 	.config_led = qlcnic_config_led,
@@ -534,15 +525,6 @@ qlcnic_get_driver_mode(struct qlcnic_adapter *adapter)
 
 	/* Determine FW API version */
 	adapter->fw_hal_version = readl(adapter->ahw.pci_base0 + QLCNIC_FW_API);
-	if (adapter->fw_hal_version == ~0) {
-		adapter->nic_ops = &qlcnic_ops;
-		adapter->fw_hal_version = QLCNIC_FW_BASE;
-		adapter->ahw.pci_func = PCI_FUNC(adapter->pdev->devfn);
-		adapter->capabilities = QLCRD32(adapter, CRB_FW_CAPABILITIES_1);
-		dev_info(&adapter->pdev->dev,
-			"FW does not support nic partion\n");
-		return adapter->fw_hal_version;
-	}
 
 	/* Find PCI function number */
 	pci_read_config_dword(adapter->pdev, QLCNIC_MSIX_TABLE_OFFSET, &func);
@@ -569,7 +551,7 @@ qlcnic_get_driver_mode(struct qlcnic_adapter *adapter)
 	switch (priv_level) {
 	case QLCNIC_MGMT_FUNC:
 		adapter->op_mode = QLCNIC_MGMT_FUNC;
-		adapter->nic_ops = &qlcnic_pf_ops;
+		adapter->nic_ops = &qlcnic_ops;
 		qlcnic_get_pci_info(adapter);
 		/* Set privilege level for other functions */
 		qlcnic_set_function_modes(adapter);
@@ -582,7 +564,7 @@ qlcnic_get_driver_mode(struct qlcnic_adapter *adapter)
 		dev_info(&adapter->pdev->dev,
 			"HAL Version: %d, Privileged function\n",
 			adapter->fw_hal_version);
-		adapter->nic_ops = &qlcnic_pf_ops;
+		adapter->nic_ops = &qlcnic_ops;
 		break;
 	case QLCNIC_NON_PRIV_FUNC:
 		adapter->op_mode = QLCNIC_NON_PRIV_FUNC;
-- 
1.7.1


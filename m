From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next 2/4] be2net: add code to dump registers for debug
Date: Thu, 29 Jul 2010 21:46:33 +0530
Message-ID: <20100729161624.GA15482@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:17235 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S932069Ab0G2QQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jul 2010 12:16:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when the BE device becomes unresponsive, dump the registers to help debugging

Signed-off-by: Somnath K <somnathk@serverengines.com>
Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be.h      |    1 +
 drivers/net/benet/be_cmds.c |    1 +
 drivers/net/benet/be_cmds.h |    1 +
 drivers/net/benet/be_hw.h   |   10 ++++
 drivers/net/benet/be_main.c |  127 +++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 140 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index e06369c..5e6f581 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -288,6 +288,7 @@ struct be_adapter {
 	u32 function_mode;
 	u32 rx_fc;		/* Rx flow control */
 	u32 tx_fc;		/* Tx flow control */
+	bool ue_detected;
 	int link_speed;
 	u8 port_type;
 	u8 transceiver;
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 6eaf8a3..7fd860d 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -206,6 +206,7 @@ static int be_mbox_db_ready_wait(struct be_adapter *adapter, void __iomem *db)
 
 		if (msecs > 4000) {
 			dev_err(&adapter->pdev->dev, "mbox poll timed out\n");
+			be_dump_ue(adapter);
 			return -1;
 		}
 
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 036531c..bdc10a2 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -992,4 +992,5 @@ extern int be_cmd_set_loopback(struct be_adapter *adapter, u8 port_num,
 extern int be_cmd_get_phy_info(struct be_adapter *adapter,
 		struct be_dma_mem *cmd);
 extern int be_cmd_set_qos(struct be_adapter *adapter, u32 bps, u32 domain);
+extern void be_dump_ue(struct be_adapter *adapter);
 
diff --git a/drivers/net/benet/be_hw.h b/drivers/net/benet/be_hw.h
index 0683967..6c8f9bb 100644
--- a/drivers/net/benet/be_hw.h
+++ b/drivers/net/benet/be_hw.h
@@ -56,6 +56,16 @@
 #define PCICFG_PM_CONTROL_OFFSET		0x44
 #define PCICFG_PM_CONTROL_MASK			0x108	/* bits 3 & 8 */
 
+/********* Online Control Registers *******/
+#define PCICFG_ONLINE0				0xB0
+#define PCICFG_ONLINE1				0xB4
+
+/********* UE Status and Mask Registers ***/
+#define PCICFG_UE_STATUS_LOW			0xA0
+#define PCICFG_UE_STATUS_HIGH			0xA4
+#define PCICFG_UE_STATUS_LOW_MASK		0xA8
+#define PCICFG_UE_STATUS_HI_MASK		0xAC
+
 /********* ISR0 Register offset **********/
 #define CEV_ISR0_OFFSET 			0xC18
 #define CEV_ISR_SIZE				4
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index e72b482..e4a8ae3 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -40,6 +40,76 @@ static DEFINE_PCI_DEVICE_TABLE(be_dev_ids) = {
 	{ 0 }
 };
 MODULE_DEVICE_TABLE(pci, be_dev_ids);
+/* UE Status Low CSR */
+static char *ue_status_low_desc[] = {
+	"CEV",
+	"CTX",
+	"DBUF",
+	"ERX",
+	"Host",
+	"MPU",
+	"NDMA",
+	"PTC ",
+	"RDMA ",
+	"RXF ",
+	"RXIPS ",
+	"RXULP0 ",
+	"RXULP1 ",
+	"RXULP2 ",
+	"TIM ",
+	"TPOST ",
+	"TPRE ",
+	"TXIPS ",
+	"TXULP0 ",
+	"TXULP1 ",
+	"UC ",
+	"WDMA ",
+	"TXULP2 ",
+	"HOST1 ",
+	"P0_OB_LINK ",
+	"P1_OB_LINK ",
+	"HOST_GPIO ",
+	"MBOX ",
+	"AXGMAC0",
+	"AXGMAC1",
+	"JTAG",
+	"MPU_INTPEND"
+};
+/* UE Status High CSR */
+static char *ue_status_hi_desc[] = {
+	"LPCMEMHOST",
+	"MGMT_MAC",
+	"PCS0ONLINE",
+	"MPU_IRAM",
+	"PCS1ONLINE",
+	"PCTL0",
+	"PCTL1",
+	"PMEM",
+	"RR",
+	"TXPB",
+	"RXPP",
+	"XAUI",
+	"TXP",
+	"ARM",
+	"IPC",
+	"HOST2",
+	"HOST3",
+	"HOST4",
+	"HOST5",
+	"HOST6",
+	"HOST7",
+	"HOST8",
+	"HOST9",
+	"NETC"
+	"Unknown",
+	"Unknown",
+	"Unknown",
+	"Unknown",
+	"Unknown",
+	"Unknown",
+	"Unknown",
+	"Unknown"
+};
 
 static void be_queue_free(struct be_adapter *adapter, struct be_queue_info *q)
 {
@@ -1673,6 +1743,59 @@ static int be_poll_tx_mcc(struct napi_struct *napi, int budget)
 	return 1;
 }
 
+static inline bool be_detect_ue(struct be_adapter *adapter)
+{
+	u32 online0 = 0, online1 = 0;
+
+	pci_read_config_dword(adapter->pdev, PCICFG_ONLINE0, &online0);
+
+	pci_read_config_dword(adapter->pdev, PCICFG_ONLINE1, &online1);
+
+	if (!online0 || !online1) {
+		adapter->ue_detected = true;
+		dev_err(&adapter->pdev->dev,
+			"UE Detected!! online0=%d online1=%d\n",
+			online0, online1);
+		return true;
+	}
+
+	return false;
+}
+
+void be_dump_ue(struct be_adapter *adapter)
+{
+	u32 ue_status_lo, ue_status_hi, ue_status_lo_mask, ue_status_hi_mask;
+	u32 i;
+
+	pci_read_config_dword(adapter->pdev,
+				PCICFG_UE_STATUS_LOW, &ue_status_lo);
+	pci_read_config_dword(adapter->pdev,
+				PCICFG_UE_STATUS_HIGH, &ue_status_hi);
+	pci_read_config_dword(adapter->pdev,
+				PCICFG_UE_STATUS_LOW_MASK, &ue_status_lo_mask);
+	pci_read_config_dword(adapter->pdev,
+				PCICFG_UE_STATUS_HI_MASK, &ue_status_hi_mask);
+
+	ue_status_lo = (ue_status_lo & (~ue_status_lo_mask));
+	ue_status_hi = (ue_status_hi & (~ue_status_hi_mask));
+
+	if (ue_status_lo) {
+		for (i = 0; ue_status_lo; ue_status_lo >>= 1, i++) {
+			if (ue_status_lo & 1)
+				dev_err(&adapter->pdev->dev,
+				"UE: %s bit set\n", ue_status_low_desc[i]);
+		}
+	}
+	if (ue_status_hi) {
+		for (i = 0; ue_status_hi; ue_status_hi >>= 1, i++) {
+			if (ue_status_hi & 1)
+				dev_err(&adapter->pdev->dev,
+				"UE: %s bit set\n", ue_status_hi_desc[i]);
+		}
+	}
+
+}
+
 static void be_worker(struct work_struct *work)
 {
 	struct be_adapter *adapter =
@@ -1690,6 +1813,10 @@ static void be_worker(struct work_struct *work)
 		adapter->rx_post_starved = false;
 		be_post_rx_frags(adapter);
 	}
+	if (!adapter->ue_detected) {
+		if (be_detect_ue(adapter))
+			be_dump_ue(adapter);
+	}
 
 	schedule_delayed_work(&adapter->work, msecs_to_jiffies(1000));
 }
-- 
1.7.0.4


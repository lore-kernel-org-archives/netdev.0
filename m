From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net-next 08/17] net: hns: fix to intimate the link-status change by adding LF/RF method
Date: Wed, 9 Nov 2016 18:13:52 +0000
Message-ID: <20161109181401.913728-9-salil.mehta@huawei.com>
References: <20161109181401.913728-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        Daode Huang <huangdaode@hisilicon.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161109181401.913728-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daode Huang <huangdaode@hisilicon.com>

In current scenario, when the interface is disabled we reset the XGMAC
RX/TX functionality. This operation does not affects the PHY layer/SFP
and which appears UP to the remote end(this behaviour is unlike GMAC).
The result is remote end keeps on sending the packets which gets partly
processed by XMAC and dropped. Since these are partly processed these
appears as errored packets in the packet counter statistics.

This patch fixes this behaviour and adds local-fault and remote-fault
functionality which can be used to intimate the remote peer whenever
the state of the interface changes. This patch also removes the
existing hns_dsaf_xge_core_srst_by_port function which was being used
to reset the RX/TX functionality at XGE Core.

Reported-by: Jun He <hjat2005@huawei.com>
Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |    2 -
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c |   31 ---------------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |    7 +++-
 .../net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c    |   41 ++++++++++++++------
 .../net/ethernet/hisilicon/hns/hns_dsaf_xgmac.h    |    5 ++-
 5 files changed, 37 insertions(+), 49 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
index 2cae6eb..7f70f34 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
@@ -306,8 +306,6 @@ struct dsaf_misc_op {
 	/* reset series function, it will be reset if the dereset is 0 */
 	void (*dsaf_reset)(struct dsaf_device *dsaf_dev, bool dereset);
 	void (*xge_srst)(struct dsaf_device *dsaf_dev, u32 port, bool dereset);
-	void (*xge_core_srst)(struct dsaf_device *dsaf_dev, u32 port,
-			      bool dereset);
 	void (*ge_srst)(struct dsaf_device *dsaf_dev, u32 port, bool dereset);
 	void (*ppe_srst)(struct dsaf_device *dsaf_dev, u32 port, bool dereset);
 	void (*ppe_comm_srst)(struct dsaf_device *dsaf_dev, bool dereset);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
index 67accce..a2c22d0 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
@@ -23,7 +23,6 @@ enum _dsm_op_index {
 enum _dsm_rst_type {
 	HNS_DSAF_RESET_FUNC     = 0x1,
 	HNS_PPE_RESET_FUNC      = 0x2,
-	HNS_XGE_CORE_RESET_FUNC = 0x3,
 	HNS_XGE_RESET_FUNC      = 0x4,
 	HNS_GE_RESET_FUNC       = 0x5,
 	HNS_DSAF_CHN_RESET_FUNC = 0x6,
@@ -213,26 +212,6 @@ static void hns_dsaf_xge_srst_by_port_acpi(struct dsaf_device *dsaf_dev,
 				   HNS_XGE_RESET_FUNC, port, dereset);
 }
 
-static void hns_dsaf_xge_core_srst_by_port(struct dsaf_device *dsaf_dev,
-					   u32 port, bool dereset)
-{
-	u32 reg_val = 0;
-	u32 reg_addr;
-
-	if (port >= DSAF_XGE_NUM)
-		return;
-
-	reg_val |= XGMAC_TRX_CORE_SRST_M
-		<< dsaf_dev->mac_cb[port]->port_rst_off;
-
-	if (!dereset)
-		reg_addr = DSAF_SUB_SC_XGE_RESET_REQ_REG;
-	else
-		reg_addr = DSAF_SUB_SC_XGE_RESET_DREQ_REG;
-
-	dsaf_write_sub(dsaf_dev, reg_addr, reg_val);
-}
-
 /**
  * hns_dsaf_srst_chns - reset dsaf channels
  * @dsaf_dev: dsaf device struct pointer
@@ -293,14 +272,6 @@ void hns_dsaf_roce_srst_acpi(struct dsaf_device *dsaf_dev, bool dereset)
 				   HNS_ROCE_RESET_FUNC, 0, dereset);
 }
 
-static void
-hns_dsaf_xge_core_srst_by_port_acpi(struct dsaf_device *dsaf_dev,
-				    u32 port, bool dereset)
-{
-	hns_dsaf_acpi_srst_by_port(dsaf_dev, HNS_OP_RESET_FUNC,
-				   HNS_XGE_CORE_RESET_FUNC, port, dereset);
-}
-
 static void hns_dsaf_ge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port,
 				     bool dereset)
 {
@@ -597,7 +568,6 @@ struct dsaf_misc_op *hns_misc_op_get(struct dsaf_device *dsaf_dev)
 
 		misc_op->dsaf_reset = hns_dsaf_rst;
 		misc_op->xge_srst = hns_dsaf_xge_srst_by_port;
-		misc_op->xge_core_srst = hns_dsaf_xge_core_srst_by_port;
 		misc_op->ge_srst = hns_dsaf_ge_srst_by_port;
 		misc_op->ppe_srst = hns_ppe_srst_by_port;
 		misc_op->ppe_comm_srst = hns_ppe_com_srst;
@@ -615,7 +585,6 @@ struct dsaf_misc_op *hns_misc_op_get(struct dsaf_device *dsaf_dev)
 
 		misc_op->dsaf_reset = hns_dsaf_rst_acpi;
 		misc_op->xge_srst = hns_dsaf_xge_srst_by_port_acpi;
-		misc_op->xge_core_srst = hns_dsaf_xge_core_srst_by_port_acpi;
 		misc_op->ge_srst = hns_dsaf_ge_srst_by_port_acpi;
 		misc_op->ppe_srst = hns_ppe_srst_by_port_acpi;
 		misc_op->ppe_comm_srst = hns_ppe_com_srst;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index f5505e8..8722668 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -702,8 +702,6 @@
 #define XGMAC_RX_SYMBOLERRPKTS			0x0210
 #define XGMAC_RX_FCSERRPKTS			0x0218
 
-#define XGMAC_TRX_CORE_SRST_M			0x2080
-
 #define DSAF_SRAM_INIT_OVER_M 0xff
 #define DSAFV2_SRAM_INIT_OVER_M 0x3ff
 #define DSAF_SRAM_INIT_OVER_S 0
@@ -982,6 +980,11 @@
 #define XGMAC_ENABLE_TX_B		0
 #define XGMAC_ENABLE_RX_B		1
 
+#define XGMAC_UNIDIR_EN_B		0
+#define XGMAC_RF_TX_EN_B		1
+#define XGMAC_LF_RF_INSERT_S		2
+#define XGMAC_LF_RF_INSERT_M		(0x3 << XGMAC_LF_RF_INSERT_S)
+
 #define XGMAC_CTL_TX_FCS_B		0
 #define XGMAC_CTL_TX_PAD_B		1
 #define XGMAC_CTL_TX_PREAMBLE_TRANS_B	3
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
index 8f4f0e8..aae830a 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
@@ -108,6 +108,31 @@ static void hns_xgmac_rx_enable(struct mac_driver *drv, u32 value)
 }
 
 /**
+ * hns_xgmac_tx_lf_rf_insert - insert lf rf control about xgmac
+ * @mac_drv: mac driver
+ * @mode: inserf rf or lf
+ */
+static void hns_xgmac_lf_rf_insert(struct mac_driver *mac_drv, u32 mode)
+{
+	dsaf_set_dev_field(mac_drv, XGMAC_MAC_TX_LF_RF_CONTROL_REG,
+			   XGMAC_LF_RF_INSERT_M, XGMAC_LF_RF_INSERT_S, mode);
+}
+
+/**
+ * hns_xgmac__lf_rf_control_init - initial the lf rf control register
+ * @mac_drv: mac driver
+ */
+static void hns_xgmac_lf_rf_control_init(struct mac_driver *mac_drv)
+{
+	u32 val = 0;
+
+	dsaf_set_bit(val, XGMAC_UNIDIR_EN_B, 0);
+	dsaf_set_bit(val, XGMAC_RF_TX_EN_B, 1);
+	dsaf_set_field(val, XGMAC_LF_RF_INSERT_M, XGMAC_LF_RF_INSERT_S, 0);
+	dsaf_write_reg(mac_drv, XGMAC_MAC_TX_LF_RF_CONTROL_REG, val);
+}
+
+/**
  *hns_xgmac_enable - enable xgmac port
  *@drv: mac driver
  *@mode: mode of mac port
@@ -115,12 +140,8 @@ static void hns_xgmac_rx_enable(struct mac_driver *drv, u32 value)
 static void hns_xgmac_enable(void *mac_drv, enum mac_commom_mode mode)
 {
 	struct mac_driver *drv = (struct mac_driver *)mac_drv;
-	struct dsaf_device *dsaf_dev
-		= (struct dsaf_device *)dev_get_drvdata(drv->dev);
-	u32 port = drv->mac_id;
 
-	dsaf_dev->misc_op->xge_core_srst(dsaf_dev, port, 1);
-	mdelay(10);
+	hns_xgmac_lf_rf_insert(drv, HNS_XGMAC_NO_LF_RF_INSERT);
 
 	/*enable XGE rX/tX */
 	if (mode == MAC_COMM_MODE_TX) {
@@ -143,9 +164,6 @@ static void hns_xgmac_enable(void *mac_drv, enum mac_commom_mode mode)
 static void hns_xgmac_disable(void *mac_drv, enum mac_commom_mode mode)
 {
 	struct mac_driver *drv = (struct mac_driver *)mac_drv;
-	struct dsaf_device *dsaf_dev
-		= (struct dsaf_device *)dev_get_drvdata(drv->dev);
-	u32 port = drv->mac_id;
 
 	if (mode == MAC_COMM_MODE_TX) {
 		hns_xgmac_tx_enable(drv, 0);
@@ -155,9 +173,7 @@ static void hns_xgmac_disable(void *mac_drv, enum mac_commom_mode mode)
 		hns_xgmac_tx_enable(drv, 0);
 		hns_xgmac_rx_enable(drv, 0);
 	}
-
-	mdelay(10);
-	dsaf_dev->misc_op->xge_core_srst(dsaf_dev, port, 0);
+	hns_xgmac_lf_rf_insert(drv, HNS_XGMAC_LF_INSERT);
 }
 
 /**
@@ -203,6 +219,7 @@ static void hns_xgmac_init(void *mac_drv)
 	dsaf_dev->misc_op->xge_srst(dsaf_dev, port, 1);
 
 	mdelay(100);
+	hns_xgmac_lf_rf_control_init(drv);
 	hns_xgmac_exc_irq_en(drv, 0);
 
 	hns_xgmac_pma_fec_enable(drv, 0x0, 0x0);
@@ -788,7 +805,7 @@ static int hns_xgmac_get_sset_count(int stringset)
  */
 static int hns_xgmac_get_regs_count(void)
 {
-	return ETH_XGMAC_DUMP_NUM;
+	return HNS_XGMAC_DUMP_NUM;
 }
 
 void *hns_xgmac_config(struct hns_mac_cb *mac_cb, struct mac_params *mac_param)
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.h
index 139f729..da6c534 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.h
@@ -10,6 +10,7 @@
 #ifndef _HNS_XGMAC_H
 #define _HNS_XGMAC_H
 
-#define ETH_XGMAC_DUMP_NUM		(214)
-
+#define HNS_XGMAC_DUMP_NUM		214
+#define HNS_XGMAC_NO_LF_RF_INSERT	0x0
+#define HNS_XGMAC_LF_INSERT		0x2
 #endif
-- 
1.7.9.5

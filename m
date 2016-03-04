From: Lisheng <lisheng011@huawei.com>
Subject: [PATCH net 1/2] net: hns: fixed the pause ctl bug
Date: Fri, 4 Mar 2016 12:40:49 +0800
Message-ID: <1457066450-72395-2-git-send-email-lisheng011@huawei.com>
References: <1457066450-72395-1-git-send-email-lisheng011@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <haifeng.wei@huawei.com>, <kenneth-lee-2012@foxmail.com>,
	<xuwei5@hisilicon.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
	<salil.mehta@huawei.com>, <liguozhu@huawei.com>,
	<huangdaode@hisilicon.com>, <lisheng011@huawei.com>,
	<yankejian@huawei.com>, <arnd@arndb.de>,
	<andriy.shevchenko@linux.intel.com>, <andrew@lunn.ch>,
	<chenny.xu@huawei.com>, <ivecera@redhat.com>,
	<fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:40177 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751492AbcCDEzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 23:55:13 -0500
In-Reply-To: <1457066450-72395-1-git-send-email-lisheng011@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch is support pause in V2 chip, that are forbidden in V1 chip:
       1) service ports can disable rx pause frame.
       2) debug ports can open tx/rx pause frame.

Signed-off-by: Lisheng <lisheng011@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  | 20 +++++++--
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  | 30 ++++---------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 49 +++++++++++++++++++---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |  4 ++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c  |  6 ++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |  6 +++
 6 files changed, 81 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index 487d6e2..80f979a 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -398,11 +398,16 @@ static void hns_ae_get_ring_bdnum_limit(struct hnae_queue *queue,
 static void hns_ae_get_pauseparam(struct hnae_handle *handle,
 				  u32 *auto_neg, u32 *rx_en, u32 *tx_en)
 {
-	assert(handle);
+	struct hns_mac_cb *mac_cb = hns_get_mac_cb(handle);
+	struct dsaf_device *dsaf_dev = mac_cb->dsaf_dev;
 
-	hns_mac_get_autoneg(hns_get_mac_cb(handle), auto_neg);
+	hns_mac_get_autoneg(mac_cb, auto_neg);
 
-	hns_mac_get_pauseparam(hns_get_mac_cb(handle), rx_en, tx_en);
+	hns_mac_get_pauseparam(mac_cb, rx_en, tx_en);
+
+	/* Service port's pause feature is provided by DSAF, not mac */
+	if (handle->port_type == HNAE_PORT_SERVICE)
+		hns_dsaf_get_rx_mac_pause_en(dsaf_dev, mac_cb->mac_id, rx_en);
 }
 
 static int hns_ae_set_autoneg(struct hnae_handle *handle, u8 enable)
@@ -432,12 +437,21 @@ static int hns_ae_set_pauseparam(struct hnae_handle *handle,
 				 u32 autoneg, u32 rx_en, u32 tx_en)
 {
 	struct hns_mac_cb *mac_cb = hns_get_mac_cb(handle);
+	struct dsaf_device *dsaf_dev = mac_cb->dsaf_dev;
 	int ret;
 
 	ret = hns_mac_set_autoneg(mac_cb, autoneg);
 	if (ret)
 		return ret;
 
+	/* Service port's pause feature is provided by DSAF, not mac */
+	if (handle->port_type == HNAE_PORT_SERVICE) {
+		ret = hns_dsaf_set_rx_mac_pause_en(dsaf_dev,
+						   mac_cb->mac_id, rx_en);
+		if (ret)
+			return ret;
+		rx_en = 0;
+	}
 	return hns_mac_set_pauseparam(mac_cb, rx_en, tx_en);
 }
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index 5ef0e96..5e47cd2 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -439,9 +439,8 @@ int hns_mac_vm_config_bc_en(struct hns_mac_cb *mac_cb, u32 vmid, bool enable)
 
 void hns_mac_reset(struct hns_mac_cb *mac_cb)
 {
-	struct mac_driver *drv;
-
-	drv = hns_mac_get_drv(mac_cb);
+	struct mac_driver *drv = hns_mac_get_drv(mac_cb);
+	bool is_ver1 = AE_IS_VER1(mac_cb->dsaf_dev->dsaf_ver);
 
 	drv->mac_init(drv);
 
@@ -456,7 +455,7 @@ void hns_mac_reset(struct hns_mac_cb *mac_cb)
 
 	if (drv->mac_pausefrm_cfg) {
 		if (mac_cb->mac_type == HNAE_PORT_DEBUG)
-			drv->mac_pausefrm_cfg(drv, 0, 0);
+			drv->mac_pausefrm_cfg(drv, !is_ver1, !is_ver1);
 		else /* mac rx must disable, dsaf pfc close instead of it*/
 			drv->mac_pausefrm_cfg(drv, 0, 1);
 	}
@@ -556,14 +555,6 @@ void hns_mac_get_pauseparam(struct hns_mac_cb *mac_cb, u32 *rx_en, u32 *tx_en)
 		*rx_en = 0;
 		*tx_en = 0;
 	}
-
-	/* Due to the chip defect, the service mac's rx pause CAN'T be enabled.
-	 * We set the rx pause frm always be true (1), because DSAF deals with
-	 * the rx pause frm instead of service mac. After all, we still support
-	 * rx pause frm.
-	 */
-	if (mac_cb->mac_type == HNAE_PORT_SERVICE)
-		*rx_en = 1;
 }
 
 /**
@@ -597,20 +588,13 @@ int hns_mac_set_autoneg(struct hns_mac_cb *mac_cb, u8 enable)
 int hns_mac_set_pauseparam(struct hns_mac_cb *mac_cb, u32 rx_en, u32 tx_en)
 {
 	struct mac_driver *mac_ctrl_drv = hns_mac_get_drv(mac_cb);
+	bool is_ver1 = AE_IS_VER1(mac_cb->dsaf_dev->dsaf_ver);
 
-	if (mac_cb->mac_type == HNAE_PORT_SERVICE) {
-		if (!rx_en) {
-			dev_err(mac_cb->dev, "disable rx_pause is not allowed!");
+	if (mac_cb->mac_type == HNAE_PORT_DEBUG) {
+		if (is_ver1 && (tx_en || rx_en)) {
+			dev_err(mac_cb->dev, "macv1 cann't enable tx/rx_pause!");
 			return -EINVAL;
 		}
-	} else if (mac_cb->mac_type == HNAE_PORT_DEBUG) {
-		if (tx_en || rx_en) {
-			dev_err(mac_cb->dev, "enable tx_pause or enable rx_pause are not allowed!");
-			return -EINVAL;
-		}
-	} else {
-		dev_err(mac_cb->dev, "Unsupport this operation!");
-		return -EINVAL;
 	}
 
 	if (mac_ctrl_drv->mac_pausefrm_cfg)
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 9439f04..58d6091 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -986,13 +986,49 @@ static void hns_dsaf_tbl_tcam_init(struct dsaf_device *dsaf_dev)
  * hns_dsaf_pfc_en_cfg - dsaf pfc pause cfg
  * @mac_cb: mac contrl block
  */
-static void hns_dsaf_pfc_en_cfg(struct dsaf_device *dsaf_dev,
-				int mac_id, int en)
+static int hns_dsaf_pfc_en_cfg(struct dsaf_device *dsaf_dev,
+			       int mac_id, int tc_en, int tx_en, int rx_en)
 {
-	if (!en)
-		dsaf_write_dev(dsaf_dev, DSAF_PFC_EN_0_REG + mac_id * 4, 0);
+	dsaf_write_dev(dsaf_dev, DSAF_PFC_EN_0_REG + mac_id * 4, tc_en);
+
+	if (AE_IS_VER1(dsaf_dev->dsaf_ver)) {
+		if (!tx_en || !rx_en) {
+			dev_err(dsaf_dev->dev, "dsaf v1 can not close pfc!\n");
+			return -EINVAL;
+		}
+	}
+
+	dsaf_set_dev_bit(dsaf_dev, DSAF_PAUSE_CFG_REG + mac_id * 4,
+			 DSAF_PFC_PAUSE_RX_EN_B, !!rx_en);
+	dsaf_set_dev_bit(dsaf_dev, DSAF_PAUSE_CFG_REG + mac_id * 4,
+			 DSAF_PFC_PAUSE_TX_EN_B, !!tx_en);
+	return 0;
+}
+
+int hns_dsaf_set_rx_mac_pause_en(struct dsaf_device *dsaf_dev, int mac_id,
+				 u32 en)
+{
+	if (AE_IS_VER1(dsaf_dev->dsaf_ver)) {
+		if (!en) {
+			dev_err(dsaf_dev->dev, "dsafv1 can't close rx_pause!\n");
+			return -EINVAL;
+		}
+	} else {
+		dsaf_set_dev_bit(dsaf_dev, DSAF_PAUSE_CFG_REG + mac_id * 4,
+				 DSAF_MAC_PAUSE_RX_EN_B, !!en);
+	}
+	return 0;
+}
+
+void hns_dsaf_get_rx_mac_pause_en(struct dsaf_device *dsaf_dev, int mac_id,
+				  u32 *en)
+{
+	if (AE_IS_VER1(dsaf_dev->dsaf_ver))
+		*en = 1;
 	else
-		dsaf_write_dev(dsaf_dev, DSAF_PFC_EN_0_REG + mac_id * 4, 0xff);
+		*en = dsaf_get_dev_bit(dsaf_dev,
+				       DSAF_PAUSE_CFG_REG + mac_id * 4,
+				       DSAF_MAC_PAUSE_RX_EN_B);
 }
 
 /**
@@ -1004,6 +1040,7 @@ static void hns_dsaf_comm_init(struct dsaf_device *dsaf_dev)
 {
 	u32 i;
 	u32 o_dsaf_cfg;
+	bool is_ver1 = AE_IS_VER1(dsaf_dev->dsaf_ver);
 
 	o_dsaf_cfg = dsaf_read_dev(dsaf_dev, DSAF_CFG_0_REG);
 	dsaf_set_bit(o_dsaf_cfg, DSAF_CFG_EN_S, dsaf_dev->dsaf_en);
@@ -1027,7 +1064,7 @@ static void hns_dsaf_comm_init(struct dsaf_device *dsaf_dev)
 
 	/*set dsaf pfc  to 0 for parseing rx pause*/
 	for (i = 0; i < DSAF_COMM_CHN; i++)
-		hns_dsaf_pfc_en_cfg(dsaf_dev, i, 0);
+		(void)hns_dsaf_pfc_en_cfg(dsaf_dev, i, 0, is_ver1, is_ver1);
 
 	/*msk and  clr exception irqs */
 	for (i = 0; i < DSAF_COMM_CHN; i++) {
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
index 40205b9..572cbcc 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
@@ -418,4 +418,8 @@ void hns_dsaf_get_regs(struct dsaf_device *ddev, u32 port, void *data);
 int hns_dsaf_get_regs_count(void);
 void hns_dsaf_set_promisc_mode(struct dsaf_device *dsaf_dev, u32 en);
 
+void hns_dsaf_get_rx_mac_pause_en(struct dsaf_device *dsaf_dev, int mac_id,
+				  u32 *en);
+int hns_dsaf_set_rx_mac_pause_en(struct dsaf_device *dsaf_dev, int mac_id,
+				 u32 en);
 #endif /* __HNS_DSAF_MAIN_H__ */
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
index f302ef9..fa5711d 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
@@ -332,10 +332,12 @@ static void hns_ppe_init_hw(struct hns_ppe_cb *ppe_cb)
 	/* clr and msk except irq*/
 	hns_ppe_exc_irq_en(ppe_cb, 0);
 
-	if (ppe_common_cb->ppe_mode == PPE_COMMON_MODE_DEBUG)
+	if (ppe_common_cb->ppe_mode == PPE_COMMON_MODE_DEBUG) {
 		hns_ppe_set_port_mode(ppe_cb, PPE_MODE_GE);
-	else
+		dsaf_write_dev(ppe_cb, PPE_CFG_PAUSE_IDLE_CNT_REG, 0);
+	} else {
 		hns_ppe_set_port_mode(ppe_cb, PPE_MODE_XGE);
+	}
 
 	hns_ppe_checksum_hw(ppe_cb, 0xffffffff);
 	hns_ppe_cnt_clr_ce(ppe_cb);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index 943c1fd..576677a 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -134,6 +134,7 @@
 #define DSAF_XGE_INT_STS_0_REG		0x1C0
 #define DSAF_PPE_INT_STS_0_REG		0x1E0
 #define DSAF_ROCEE_INT_STS_0_REG	0x200
+#define DSAF_PAUSE_CFG_REG		0x240
 #define DSAF_PPE_QID_CFG_0_REG		0x300
 #define DSAF_SW_PORT_TYPE_0_REG		0x320
 #define DSAF_STP_PORT_TYPE_0_REG	0x340
@@ -152,6 +153,7 @@
 #define DSAF_INODE_FINAL_IN_PKT_NUM_0_REG	0x1030
 #define DSAF_INODE_SBM_PID_NUM_0_REG		0x1038
 #define DSAF_INODE_FINAL_IN_PAUSE_NUM_0_REG	0x103C
+#define DSAFV2_INODE_FINAL_IN_PAUSE_NUM_0_REG	0x1024
 #define DSAF_INODE_SBM_RELS_NUM_0_REG		0x104C
 #define DSAF_INODE_SBM_DROP_NUM_0_REG		0x1050
 #define DSAF_INODE_CRC_FALSE_NUM_0_REG		0x1054
@@ -708,6 +710,10 @@
 #define DSAF_PFC_UNINT_CNT_M ((1ULL << 9) - 1)
 #define DSAF_PFC_UNINT_CNT_S 0
 
+#define DSAF_MAC_PAUSE_RX_EN_B 2
+#define DSAF_PFC_PAUSE_RX_EN_B 1
+#define DSAF_PFC_PAUSE_TX_EN_B 0
+
 #define DSAF_PPE_QID_CFG_M 0xFF
 #define DSAF_PPE_QID_CFG_S 0
 
-- 
1.9.1

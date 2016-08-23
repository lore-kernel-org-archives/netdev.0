From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH for-next 1/2] net: hns: Add support of ACPI to HNS driver RoCE Reset function
Date: Wed, 24 Aug 2016 04:44:49 +0800
Message-ID: <1471985090-202472-2-git-send-email-salil.mehta@huawei.com>
References: <1471985090-202472-1-git-send-email-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <xavier.huwei@huawei.com>,
        <oulijun@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <linux-rdma@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>
To: <dledford@redhat.com>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471985090-202472-1-git-send-email-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the Hip06 SoC, the RoCE Engine is part of the Hisilicon Network
Subsystem and is dependent upon DSAF module. Therefore, certain
functions like RESET are exposed through the common registers of
HNS DSAF module which are memory-mapped by the HNS driver and
currently can only be accessed through DT/syscon interface.

This patch adds the support of ACPI to the existing RoCE reset
function in the HNS driver(please refer NOTE 2). Hisilicon RoCE
driver (please refer NOTE 1) shall call this reset function during
probe time to reset the RoCE Engine.

The HNS Reset function indirectly ends up in calling the _DSM()
function part of the DSDT ACPI Table. Actual reset functionality
for ACPI is implemented within the ACPI DSDT Table which also has
been enhanced to support this change.

Support of ACPI in the HNS RoCE driver shall be pushed through a
different accompanying below patch:
"IB/hns: Add support of ACPI to the Hisilicon RoCE Driver"

NOTE 1: HNS RoCE driver has already been accepted by its maintainer
Doug Ledford<dledford@redhat.com>. Please refer below link:
https://www.spinics.net/lists/linux-rdma/msg38850.html

NOTE 2: RoCE reset function patch has been accepted and now is
part of the net-next:
https://www.mail-archive.com/netdev@vger.kernel.org/msg123867.html

Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
---
Change Log

PATCH V1: Initial version to support ACPI in RoCE Reset
          functionality of the HNS driver.
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  |   17 +------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |   47 ++++++++++++-----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |    9 ++--
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c |   53 ++++++++++++++++++--
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.h |    3 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |    4 +-
 6 files changed, 92 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index a834774..a68eef0 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -644,21 +644,6 @@ hns_mac_phy_parse_addr(struct device *dev, struct fwnode_handle *fwnode)
 	return addr;
 }
 
-static int hns_mac_phydev_match(struct device *dev, void *fwnode)
-{
-	return dev->fwnode == fwnode;
-}
-
-static struct
-platform_device *hns_mac_find_platform_device(struct fwnode_handle *fwnode)
-{
-	struct device *dev;
-
-	dev = bus_find_device(&platform_bus_type, NULL,
-			      fwnode, hns_mac_phydev_match);
-	return dev ? to_platform_device(dev) : NULL;
-}
-
 static int
 hns_mac_register_phydev(struct mii_bus *mdio, struct hns_mac_cb *mac_cb,
 			u32 addr)
@@ -724,7 +709,7 @@ static void hns_mac_register_phy(struct hns_mac_cb *mac_cb)
 		return;
 
 	/* dev address in adev */
-	pdev = hns_mac_find_platform_device(acpi_fwnode_handle(args.adev));
+	pdev = hns_dsaf_find_platform_device(acpi_fwnode_handle(args.adev));
 	mii_bus = platform_get_drvdata(pdev);
 	rc = hns_mac_register_phydev(mii_bus, mac_cb, addr);
 	if (!rc)
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 05bd19f..9283bc6 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -2788,7 +2788,7 @@ module_platform_driver(g_dsaf_driver);
  * @enable: false - request reset , true - drop reset
  * retuen 0 - success , negative -fail
  */
-int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, bool enable)
+int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, bool dereset)
 {
 	struct dsaf_device *dsaf_dev;
 	struct platform_device *pdev;
@@ -2817,24 +2817,44 @@ int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, bool enable)
 		{DSAF_ROCE_SL_1, DSAF_ROCE_SL_1, DSAF_ROCE_SL_3},
 	};
 
-	if (!is_of_node(dsaf_fwnode)) {
-		pr_err("hisi_dsaf: Only support DT node!\n");
+	/* find the platform device corresponding to fwnode */
+	if (is_of_node(dsaf_fwnode)) {
+		pdev = of_find_device_by_node(to_of_node(dsaf_fwnode));
+	} else if (is_acpi_device_node(dsaf_fwnode)) {
+		pdev = hns_dsaf_find_platform_device(dsaf_fwnode);
+	} else {
+		pr_err("fwnode is neither OF or ACPI type\n");
 		return -EINVAL;
 	}
-	pdev = of_find_device_by_node(to_of_node(dsaf_fwnode));
+
+	/* check if we were a success in fetching pdev */
+	if (!pdev) {
+		pr_err("couldn't find platform device for node\n");
+		return -ENODEV;
+	}
+
+	/* retrieve the dsaf_device from the driver data */
 	dsaf_dev = dev_get_drvdata(&pdev->dev);
+	if (!dsaf_dev) {
+		dev_err(&pdev->dev, "dsaf_dev is NULL\n");
+		return -ENODEV;
+	}
+
+	/* now, make sure we are running on compatible SoC */
 	if (AE_IS_VER1(dsaf_dev->dsaf_ver)) {
 		dev_err(dsaf_dev->dev, "%s v1 chip doesn't support RoCE!\n",
 			dsaf_dev->ae_dev.name);
 		return -ENODEV;
 	}
 
-	if (!enable) {
-		/* Reset rocee-channels in dsaf and rocee */
-		hns_dsaf_srst_chns(dsaf_dev, DSAF_CHNS_MASK, false);
-		hns_dsaf_roce_srst(dsaf_dev, false);
+	/* do reset or de-reset according to the flag */
+	if (!dereset) {
+		/* reset rocee-channels in dsaf and rocee */
+		dsaf_dev->misc_op->hns_dsaf_srst_chns(dsaf_dev, DSAF_CHNS_MASK,
+						      false);
+		dsaf_dev->misc_op->hns_dsaf_roce_srst(dsaf_dev, false);
 	} else {
-		/* Configure dsaf tx roce correspond to port map and sl map */
+		/* configure dsaf tx roce correspond to port map and sl map */
 		mp = dsaf_read_dev(dsaf_dev, DSAF_ROCE_PORT_MAP_REG);
 		for (i = 0; i < DSAF_ROCE_CREDIT_CHN; i++)
 			dsaf_set_field(mp, 7 << i * 3, i * 3,
@@ -2848,12 +2868,13 @@ int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, bool enable)
 				       sl_map[i][DSAF_ROCE_6PORT_MODE]);
 		dsaf_write_dev(dsaf_dev, DSAF_ROCE_SL_MAP_REG, sl);
 
-		/* De-reset rocee-channels in dsaf and rocee */
-		hns_dsaf_srst_chns(dsaf_dev, DSAF_CHNS_MASK, true);
+		/* de-reset rocee-channels in dsaf and rocee */
+		dsaf_dev->misc_op->hns_dsaf_srst_chns(dsaf_dev, DSAF_CHNS_MASK,
+						      true);
 		msleep(SRST_TIME_INTERVAL);
-		hns_dsaf_roce_srst(dsaf_dev, true);
+		dsaf_dev->misc_op->hns_dsaf_roce_srst(dsaf_dev, true);
 
-		/* Eanble dsaf channel rocee credit */
+		/* enable dsaf channel rocee credit */
 		credit = dsaf_read_dev(dsaf_dev, DSAF_SBM_ROCEE_CFG_REG_REG);
 		dsaf_set_bit(credit, DSAF_SBM_ROCEE_CFG_CRD_EN_B, 0);
 		dsaf_write_dev(dsaf_dev, DSAF_SBM_ROCEE_CFG_REG_REG, credit);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
index f3681d5..35df187 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
@@ -305,7 +305,7 @@ struct dsaf_misc_op {
 	void (*cpld_reset_led)(struct hns_mac_cb *mac_cb);
 	int (*cpld_set_led_id)(struct hns_mac_cb *mac_cb,
 			       enum hnae_led_state status);
-	/* reset seris function, it will be reset if the dereseet is 0 */
+	/* reset series function, it will be reset if the dereset is 0 */
 	void (*dsaf_reset)(struct dsaf_device *dsaf_dev, bool dereset);
 	void (*xge_srst)(struct dsaf_device *dsaf_dev, u32 port, bool dereset);
 	void (*xge_core_srst)(struct dsaf_device *dsaf_dev, u32 port,
@@ -313,6 +313,9 @@ struct dsaf_misc_op {
 	void (*ge_srst)(struct dsaf_device *dsaf_dev, u32 port, bool dereset);
 	void (*ppe_srst)(struct dsaf_device *dsaf_dev, u32 port, bool dereset);
 	void (*ppe_comm_srst)(struct dsaf_device *dsaf_dev, bool dereset);
+	void (*hns_dsaf_srst_chns)(struct dsaf_device *dsaf_dev, u32 msk,
+				   bool dereset);
+	void (*hns_dsaf_roce_srst)(struct dsaf_device *dsaf_dev, bool dereset);
 
 	phy_interface_t (*get_phy_if)(struct hns_mac_cb *mac_cb);
 	int (*get_sfp_prsnt)(struct hns_mac_cb *mac_cb, int *sfp_prsnt);
@@ -445,10 +448,6 @@ int hns_dsaf_get_mac_entry_by_index(
 
 void hns_dsaf_fix_mac_mode(struct hns_mac_cb *mac_cb);
 
-void hns_dsaf_srst_chns(struct dsaf_device *dsaf_dev, u32 msk, bool enable);
-
-void hns_dsaf_roce_srst(struct dsaf_device *dsaf_dev, bool enable);
-
 int hns_dsaf_ae_init(struct dsaf_device *dsaf_dev);
 void hns_dsaf_ae_uninit(struct dsaf_device *dsaf_dev);
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
index 36b9f79..67accce 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
@@ -26,6 +26,8 @@ enum _dsm_rst_type {
 	HNS_XGE_CORE_RESET_FUNC = 0x3,
 	HNS_XGE_RESET_FUNC      = 0x4,
 	HNS_GE_RESET_FUNC       = 0x5,
+	HNS_DSAF_CHN_RESET_FUNC = 0x6,
+	HNS_ROCE_RESET_FUNC     = 0x7,
 };
 
 const u8 hns_dsaf_acpi_dsm_uuid[] = {
@@ -241,11 +243,11 @@ static void hns_dsaf_xge_core_srst_by_port(struct dsaf_device *dsaf_dev,
  * bit18-19 for com/dfx
  * @enable: false - request reset , true - drop reset
  */
-void hns_dsaf_srst_chns(struct dsaf_device *dsaf_dev, u32 msk, bool enable)
+void hns_dsaf_srst_chns(struct dsaf_device *dsaf_dev, u32 msk, bool dereset)
 {
 	u32 reg_addr;
 
-	if (!enable)
+	if (!dereset)
 		reg_addr = DSAF_SUB_SC_DSAF_RESET_REQ_REG;
 	else
 		reg_addr = DSAF_SUB_SC_DSAF_RESET_DREQ_REG;
@@ -253,9 +255,27 @@ void hns_dsaf_srst_chns(struct dsaf_device *dsaf_dev, u32 msk, bool enable)
 	dsaf_write_sub(dsaf_dev, reg_addr, msk);
 }
 
-void hns_dsaf_roce_srst(struct dsaf_device *dsaf_dev, bool enable)
+/**
+ * hns_dsaf_srst_chns - reset dsaf channels
+ * @dsaf_dev: dsaf device struct pointer
+ * @msk: xbar channels mask value:
+ * bit0-5 for xge0-5
+ * bit6-11 for ppe0-5
+ * bit12-17 for roce0-5
+ * bit18-19 for com/dfx
+ * @enable: false - request reset , true - drop reset
+ */
+void
+hns_dsaf_srst_chns_acpi(struct dsaf_device *dsaf_dev, u32 msk, bool dereset)
 {
-	if (!enable) {
+	hns_dsaf_acpi_srst_by_port(dsaf_dev, HNS_OP_RESET_FUNC,
+				   HNS_DSAF_CHN_RESET_FUNC,
+				   msk, dereset);
+}
+
+void hns_dsaf_roce_srst(struct dsaf_device *dsaf_dev, bool dereset)
+{
+	if (!dereset) {
 		dsaf_write_sub(dsaf_dev, DSAF_SUB_SC_ROCEE_RESET_REQ_REG, 1);
 	} else {
 		dsaf_write_sub(dsaf_dev,
@@ -267,6 +287,12 @@ void hns_dsaf_roce_srst(struct dsaf_device *dsaf_dev, bool enable)
 	}
 }
 
+void hns_dsaf_roce_srst_acpi(struct dsaf_device *dsaf_dev, bool dereset)
+{
+	hns_dsaf_acpi_srst_by_port(dsaf_dev, HNS_OP_RESET_FUNC,
+				   HNS_ROCE_RESET_FUNC, 0, dereset);
+}
+
 static void
 hns_dsaf_xge_core_srst_by_port_acpi(struct dsaf_device *dsaf_dev,
 				    u32 port, bool dereset)
@@ -575,6 +601,8 @@ struct dsaf_misc_op *hns_misc_op_get(struct dsaf_device *dsaf_dev)
 		misc_op->ge_srst = hns_dsaf_ge_srst_by_port;
 		misc_op->ppe_srst = hns_ppe_srst_by_port;
 		misc_op->ppe_comm_srst = hns_ppe_com_srst;
+		misc_op->hns_dsaf_srst_chns = hns_dsaf_srst_chns;
+		misc_op->hns_dsaf_roce_srst = hns_dsaf_roce_srst;
 
 		misc_op->get_phy_if = hns_mac_get_phy_if;
 		misc_op->get_sfp_prsnt = hns_mac_get_sfp_prsnt;
@@ -591,6 +619,8 @@ struct dsaf_misc_op *hns_misc_op_get(struct dsaf_device *dsaf_dev)
 		misc_op->ge_srst = hns_dsaf_ge_srst_by_port_acpi;
 		misc_op->ppe_srst = hns_ppe_srst_by_port_acpi;
 		misc_op->ppe_comm_srst = hns_ppe_com_srst;
+		misc_op->hns_dsaf_srst_chns = hns_dsaf_srst_chns_acpi;
+		misc_op->hns_dsaf_roce_srst = hns_dsaf_roce_srst_acpi;
 
 		misc_op->get_phy_if = hns_mac_get_phy_if_acpi;
 		misc_op->get_sfp_prsnt = hns_mac_get_sfp_prsnt;
@@ -603,3 +633,18 @@ struct dsaf_misc_op *hns_misc_op_get(struct dsaf_device *dsaf_dev)
 
 	return (void *)misc_op;
 }
+
+static int hns_dsaf_dev_match(struct device *dev, void *fwnode)
+{
+	return dev->fwnode == fwnode;
+}
+
+struct
+platform_device *hns_dsaf_find_platform_device(struct fwnode_handle *fwnode)
+{
+	struct device *dev;
+
+	dev = bus_find_device(&platform_bus_type, NULL,
+			      fwnode, hns_dsaf_dev_match);
+	return dev ? to_platform_device(dev) : NULL;
+}
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.h
index f06bb03..310e802 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.h
@@ -34,5 +34,6 @@
 #define DSAF_LED_ANCHOR_B 5
 
 struct dsaf_misc_op *hns_misc_op_get(struct dsaf_device *dsaf_dev);
-
+struct
+platform_device *hns_dsaf_find_platform_device(struct fwnode_handle *fwnode);
 #endif
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index 13c16ab..4b8b803 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -78,10 +78,10 @@
 #define DSAF_SUB_SC_RCB_PPE_COM_RESET_REQ_REG		0xA88
 #define DSAF_SUB_SC_RCB_PPE_COM_RESET_DREQ_REG		0xA8C
 #define DSAF_SUB_SC_DSAF_RESET_REQ_REG			0xAA8
-#define DSAF_SUB_SC_ROCEE_RESET_REQ_REG			0xA50
 #define DSAF_SUB_SC_DSAF_RESET_DREQ_REG			0xAAC
-#define DSAF_SUB_SC_ROCEE_CLK_DIS_REG			0x32C
+#define DSAF_SUB_SC_ROCEE_RESET_REQ_REG			0xA50
 #define DSAF_SUB_SC_ROCEE_RESET_DREQ_REG		0xA54
+#define DSAF_SUB_SC_ROCEE_CLK_DIS_REG			0x32C
 #define DSAF_SUB_SC_ROCEE_CLK_EN_REG			0x328
 #define DSAF_SUB_SC_LIGHT_MODULE_DETECT_EN_REG		0x2060
 #define DSAF_SUB_SC_TCAM_MBIST_EN_REG			0x2300
-- 
1.7.9.5

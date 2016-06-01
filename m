From: Lijun Ou <oulijun@huawei.com>
Subject: [PATCH v9 01/22] net: hns: Add reset function support for RoCE driver
Date: Wed, 1 Jun 2016 23:37:43 +0800
Message-ID: <1464795484-77395-2-git-send-email-oulijun@huawei.com>
References: <1464795484-77395-1-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <gongyangming@huawei.com>,
	<xiaokun@huawei.com>, <tangchaofei@huawei.com>,
	<oulijun@huawei.com>, <haifeng.wei@huawei.com>,
	<yisen.zhuang@huawei.com>, <yankejian@huawei.com>,
	<charles.chenxin@huawei.com>, <linuxarm@huawei.com>
To: <dledford@redhat.com>, <sean.hefty@intel.com>,
	<hal.rosenstock@gmail.com>, <davem@davemloft.net>,
	<jeffrey.t.kirsher@intel.com>, <jiri@mellanox.com>,
	<ogerlitz@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464795484-77395-1-git-send-email-oulijun@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It added reset function for RoCE driver. RoCE is a feature of hns.
In hip06 SoC, in RoCE reset process, it's needed to configure dsaf
channel reset, port and sl map info. Reset function of RoCE is
located in dsaf module, we only call it in RoCE driver when needed.

Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
Signed-off-by: Nenglong Zhao <zhaonenglong@hisilicon.com>
Signed-off-by: Lijun Ou <oulijun@huawei.com>
Signed-off-by: Sheng Li <lisheng011@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 84 ++++++++++++++++++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h | 32 ++++++++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 57 ++++++++++++---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  | 15 +++-
 4 files changed, 178 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 1c2ddb2..0c4a87c 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -14,6 +14,7 @@
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/mfd/syscon.h>
+#include <linux/of_platform.h>
 #include <linux/of.h>
 #include <linux/of_address.h>
 #include <linux/of_irq.h>
@@ -2685,6 +2686,89 @@ static struct platform_driver g_dsaf_driver = {
 
 module_platform_driver(g_dsaf_driver);
 
+/**
+ * hns_dsaf_roce_reset - reset dsaf and roce
+ * @dsaf_fwnode: Pointer to framework node for the dasf
+ * @enable: false - request reset , true - drop reset
+ * retuen 0 - success , negative -fail
+ */
+int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, bool enable)
+{
+	struct dsaf_device *dsaf_dev;
+	struct platform_device *pdev;
+	unsigned int mp;
+	unsigned int sl;
+	unsigned int credit;
+	int i;
+	const u32 port_map[DSAF_ROCE_CREDIT_CHN][DSAF_ROCE_CHAN_MODE_NUM] = {
+		{DSAF_ROCE_PORT_0, DSAF_ROCE_PORT_0, DSAF_ROCE_PORT_0},
+		{DSAF_ROCE_PORT_1, DSAF_ROCE_PORT_0, DSAF_ROCE_PORT_0},
+		{DSAF_ROCE_PORT_2, DSAF_ROCE_PORT_1, DSAF_ROCE_PORT_0},
+		{DSAF_ROCE_PORT_3, DSAF_ROCE_PORT_1, DSAF_ROCE_PORT_0},
+		{DSAF_ROCE_PORT_4, DSAF_ROCE_PORT_2, DSAF_ROCE_PORT_1},
+		{DSAF_ROCE_PORT_4, DSAF_ROCE_PORT_2, DSAF_ROCE_PORT_1},
+		{DSAF_ROCE_PORT_5, DSAF_ROCE_PORT_3, DSAF_ROCE_PORT_1},
+		{DSAF_ROCE_PORT_5, DSAF_ROCE_PORT_3, DSAF_ROCE_PORT_1},
+	};
+	const u32 sl_map[DSAF_ROCE_CREDIT_CHN][DSAF_ROCE_CHAN_MODE_NUM] = {
+		{DSAF_ROCE_SL_0, DSAF_ROCE_SL_0, DSAF_ROCE_SL_0},
+		{DSAF_ROCE_SL_0, DSAF_ROCE_SL_1, DSAF_ROCE_SL_1},
+		{DSAF_ROCE_SL_0, DSAF_ROCE_SL_0, DSAF_ROCE_SL_2},
+		{DSAF_ROCE_SL_0, DSAF_ROCE_SL_1, DSAF_ROCE_SL_3},
+		{DSAF_ROCE_SL_0, DSAF_ROCE_SL_0, DSAF_ROCE_SL_0},
+		{DSAF_ROCE_SL_1, DSAF_ROCE_SL_1, DSAF_ROCE_SL_1},
+		{DSAF_ROCE_SL_0, DSAF_ROCE_SL_0, DSAF_ROCE_SL_2},
+		{DSAF_ROCE_SL_1, DSAF_ROCE_SL_1, DSAF_ROCE_SL_3},
+	};
+
+	if (!is_of_node(dsaf_fwnode)) {
+		pr_err("hisi_dsaf: Only support DT node!\n");
+		return -EINVAL;
+	}
+	pdev = of_find_device_by_node(to_of_node(dsaf_fwnode));
+	dsaf_dev = dev_get_drvdata(&pdev->dev);
+	if (AE_IS_VER1(dsaf_dev->dsaf_ver)) {
+		dev_err(dsaf_dev->dev, "%s v1 chip do not support roce!\n",
+			dsaf_dev->ae_dev.name);
+		return -ENODEV;
+	}
+
+	if (!enable) {
+		/* Reset rocee-channels in dsaf and rocee */
+		hns_dsaf_srst_chns(dsaf_dev, DSAF_CHNS_MASK, false);
+		hns_dsaf_roce_srst(dsaf_dev, false);
+	} else {
+		/* Configure dsaf tx roce correspond to port map and sl map */
+		mp = dsaf_read_dev(dsaf_dev, DSAF_ROCE_PORT_MAP_REG);
+		for (i = 0; i < DSAF_ROCE_CREDIT_CHN; i++)
+			dsaf_set_field(mp, 7 << i * 3, i * 3,
+				       port_map[i][DSAF_ROCE_6PORT_MODE]);
+		dsaf_set_field(mp, 3 << i * 3, i * 3, 0);
+		dsaf_write_dev(dsaf_dev, DSAF_ROCE_PORT_MAP_REG, mp);
+
+		sl = dsaf_read_dev(dsaf_dev, DSAF_ROCE_SL_MAP_REG);
+		for (i = 0; i < DSAF_ROCE_CREDIT_CHN; i++)
+			dsaf_set_field(sl, 3 << i * 2, i * 2,
+				       sl_map[i][DSAF_ROCE_6PORT_MODE]);
+		dsaf_write_dev(dsaf_dev, DSAF_ROCE_SL_MAP_REG, sl);
+
+		/* De-reset rocee-channels in dsaf and rocee */
+		hns_dsaf_srst_chns(dsaf_dev, DSAF_CHNS_MASK, true);
+		msleep(20);
+		hns_dsaf_roce_srst(dsaf_dev, true);
+
+		/* Eanble dsaf channel rocee credit */
+		credit = dsaf_read_dev(dsaf_dev, DSAF_SBM_ROCEE_CFG_REG_REG);
+		dsaf_set_bit(credit, DSAF_SBM_ROCEE_CFG_CRD_EN_B, 0);
+		dsaf_write_dev(dsaf_dev, DSAF_SBM_ROCEE_CFG_REG_REG, credit);
+
+		dsaf_set_bit(credit, DSAF_SBM_ROCEE_CFG_CRD_EN_B, 1);
+		dsaf_write_dev(dsaf_dev, DSAF_SBM_ROCEE_CFG_REG_REG, credit);
+	}
+	return 0;
+}
+EXPORT_SYMBOL(hns_dsaf_roce_reset);
+
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Huawei Tech. Co., Ltd.");
 MODULE_DESCRIPTION("HNS DSAF driver");
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
index f0502ba..e00b585 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
@@ -40,6 +40,32 @@ struct hns_mac_cb;
 #define DSAF_DUMP_REGS_NUM 504
 #define DSAF_STATIC_NUM 28
 
+#define DSAF_ROCE_CREDIT_CHN 8
+#define DSAF_ROCE_CHAN_MODE 3
+
+enum dsaf_roce_port_mode {
+	DSAF_ROCE_6PORT_MODE,
+	DSAF_ROCE_4PORT_MODE,
+	DSAF_ROCE_2PORT_MODE,
+	DSAF_ROCE_CHAN_MODE_NUM,
+};
+
+enum dsaf_roce_port_num {
+	DSAF_ROCE_PORT_0 = 0,
+	DSAF_ROCE_PORT_1 = 1,
+	DSAF_ROCE_PORT_2 = 2,
+	DSAF_ROCE_PORT_3 = 3,
+	DSAF_ROCE_PORT_4 = 4,
+	DSAF_ROCE_PORT_5 = 5,
+};
+
+enum dsaf_roce_qos_sl {
+	DSAF_ROCE_SL_0 = 0,
+	DSAF_ROCE_SL_1 = 1,
+	DSAF_ROCE_SL_2 = 2,
+	DSAF_ROCE_SL_3 = 3,
+};
+
 #define DSAF_STATS_READ(p, offset) (*((u64 *)((u8 *)(p) + (offset))))
 #define HNS_DSAF_IS_DEBUG(dev) (dev->dsaf_mode == DSAF_MODE_DISABLE_SP)
 
@@ -388,7 +414,7 @@ int hns_dsaf_get_mac_entry_by_index(
 	u16 entry_index,
 	struct dsaf_drv_mac_multi_dest_entry *mac_entry);
 
-void hns_dsaf_rst(struct dsaf_device *dsaf_dev, u32 val);
+void hns_dsaf_rst(struct dsaf_device *dsaf_dev, bool enable);
 
 void hns_ppe_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val);
 
@@ -396,6 +422,10 @@ void hns_ppe_com_srst(struct ppe_common_cb *ppe_common, u32 val);
 
 void hns_dsaf_fix_mac_mode(struct hns_mac_cb *mac_cb);
 
+void hns_dsaf_srst_chns(struct dsaf_device *dsaf_dev, u32 msk, bool enable);
+
+void hns_dsaf_roce_srst(struct dsaf_device *dsaf_dev, bool enable);
+
 int hns_dsaf_ae_init(struct dsaf_device *dsaf_dev);
 void hns_dsaf_ae_uninit(struct dsaf_device *dsaf_dev);
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
index a837bb9..1fd41a7a3 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
@@ -109,21 +109,25 @@ int cpld_set_led_id(struct hns_mac_cb *mac_cb,
 
 #define RESET_REQ_OR_DREQ 1
 
-void hns_dsaf_rst(struct dsaf_device *dsaf_dev, u32 val)
+void hns_dsaf_rst(struct dsaf_device *dsaf_dev, bool enable)
 {
 	u32 xbar_reg_addr;
 	u32 nt_reg_addr;
 
-	if (!val) {
-		xbar_reg_addr = DSAF_SUB_SC_XBAR_RESET_REQ_REG;
-		nt_reg_addr = DSAF_SUB_SC_NT_RESET_REQ_REG;
-	} else {
-		xbar_reg_addr = DSAF_SUB_SC_XBAR_RESET_DREQ_REG;
-		nt_reg_addr = DSAF_SUB_SC_NT_RESET_DREQ_REG;
-	}
+	if (AE_IS_VER1(dsaf_dev->dsaf_ver)) {
+		if (!enable) {
+			xbar_reg_addr = DSAF_SUB_SC_XBAR_RESET_REQ_REG;
+			nt_reg_addr = DSAF_SUB_SC_NT_RESET_REQ_REG;
+		} else {
+			xbar_reg_addr = DSAF_SUB_SC_XBAR_RESET_DREQ_REG;
+			nt_reg_addr = DSAF_SUB_SC_NT_RESET_DREQ_REG;
+		}
 
 	dsaf_write_sub(dsaf_dev, xbar_reg_addr, RESET_REQ_OR_DREQ);
 	dsaf_write_sub(dsaf_dev, nt_reg_addr, RESET_REQ_OR_DREQ);
+	} else {
+		hns_dsaf_srst_chns(dsaf_dev, 0xfffff, enable);
+	}
 }
 
 void hns_dsaf_xge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
@@ -165,6 +169,43 @@ void hns_dsaf_xge_core_srst_by_port(struct dsaf_device *dsaf_dev,
 	dsaf_write_sub(dsaf_dev, reg_addr, reg_val);
 }
 
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
+void hns_dsaf_srst_chns(struct dsaf_device *dsaf_dev, u32 msk, bool enable)
+{
+	u32 reg_addr;
+
+	if (!enable)
+		reg_addr = DSAF_SUB_SC_DSAF_RESET_REQ_REG;
+	else
+		reg_addr = DSAF_SUB_SC_DSAF_RESET_DREQ_REG;
+
+	dsaf_write_sub(dsaf_dev, reg_addr, msk);
+}
+
+void hns_dsaf_roce_srst(struct dsaf_device *dsaf_dev, bool enable)
+{
+	if (!enable) {
+		dsaf_write_reg(dsaf_dev->sc_base,
+			       DSAF_SUB_SC_ROCEE_RESET_REQ_REG, 1);
+	} else {
+		dsaf_write_sub(dsaf_dev,
+			       DSAF_SUB_SC_ROCEE_CLK_DIS_REG, 1);
+		dsaf_write_sub(dsaf_dev,
+			       DSAF_SUB_SC_ROCEE_RESET_DREQ_REG, 1);
+		msleep(20);
+		dsaf_write_sub(dsaf_dev, DSAF_SUB_SC_ROCEE_CLK_EN_REG, 1);
+	}
+}
+
 void hns_dsaf_ge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
 {
 	u32 reg_val_1;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index 7c3b510..268383b 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -32,6 +32,7 @@
 #define DSAFV2_SBM_NUM		8
 #define DSAFV2_SBM_XGE_CHN    6
 #define DSAFV2_SBM_PPE_CHN    1
+#define DSAFV2_SBM_ROCE_CHN   1
 #define DASFV2_ROCEE_CRD_NUM  8
 
 #define DSAF_VOQ_NUM		DSAF_NODE_NUM
@@ -77,6 +78,12 @@
 #define DSAF_SUB_SC_PPE_RESET_DREQ_REG			0xA4C
 #define DSAF_SUB_SC_RCB_PPE_COM_RESET_REQ_REG		0xA88
 #define DSAF_SUB_SC_RCB_PPE_COM_RESET_DREQ_REG		0xA8C
+#define DSAF_SUB_SC_DSAF_RESET_REQ_REG			0xAA8
+#define DSAF_SUB_SC_ROCEE_RESET_REQ_REG			0xA50
+#define DSAF_SUB_SC_DSAF_RESET_DREQ_REG			0xAAC
+#define DSAF_SUB_SC_ROCEE_CLK_DIS_REG			0x32C
+#define DSAF_SUB_SC_ROCEE_RESET_DREQ_REG		0xA54
+#define DSAF_SUB_SC_ROCEE_CLK_EN_REG			0x328
 #define DSAF_SUB_SC_LIGHT_MODULE_DETECT_EN_REG		0x2060
 #define DSAF_SUB_SC_TCAM_MBIST_EN_REG			0x2300
 #define DSAF_SUB_SC_DSAF_CLK_ST_REG			0x5300
@@ -133,6 +140,8 @@
 #define DSAF_ROCEE_INT_STS_0_REG	0x200
 #define DSAFV2_SERDES_LBK_0_REG         0x220
 #define DSAF_PAUSE_CFG_REG		0x240
+#define DSAF_ROCE_PORT_MAP_REG		0x2A0
+#define DSAF_ROCE_SL_MAP_REG            0x2A4
 #define DSAF_PPE_QID_CFG_0_REG		0x300
 #define DSAF_SW_PORT_TYPE_0_REG		0x320
 #define DSAF_STP_PORT_TYPE_0_REG	0x340
@@ -175,7 +184,8 @@
 #define DSAF_SBM_BP_CFG_2_XGE_REG_0_REG		0x200C
 #define DSAF_SBM_BP_CFG_2_PPE_REG_0_REG		0x230C
 #define DSAF_SBM_BP_CFG_2_ROCEE_REG_0_REG	0x260C
-#define DSAFV2_SBM_BP_CFG_2_ROCEE_REG_0_REG		 0x238C
+#define DSAF_SBM_ROCEE_CFG_REG_REG		0x2380
+#define DSAFV2_SBM_BP_CFG_2_ROCEE_REG_0_REG	0x238C
 #define DSAF_SBM_FREE_CNT_0_0_REG		0x2010
 #define DSAF_SBM_FREE_CNT_1_0_REG		0x2014
 #define DSAF_SBM_BP_CNT_0_0_REG			0x2018
@@ -791,6 +801,9 @@
 #define DSAFV2_SBM_CFG4_RESET_BUF_NUM_NO_PFC_S 9
 #define DSAFV2_SBM_CFG4_RESET_BUF_NUM_NO_PFC_M (((1ULL << 9) - 1) << 9)
 
+#define DSAF_CHNS_MASK 0x3f000
+#define DSAF_SBM_ROCEE_CFG_CRD_EN_B 2
+
 #define DSAF_TBL_TCAM_ADDR_S 0
 #define DSAF_TBL_TCAM_ADDR_M ((1ULL << 9) - 1)
 
-- 
1.9.1

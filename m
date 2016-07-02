From: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v11 01/22] net: hns: Add reset function support for RoCE driver
Date: Sat, 2 Jul 2016 17:39:03 +0800
Message-ID: <1467452364-66522-2-git-send-email-oulijun@huawei.com>
References: <1467452364-66522-1-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	<ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1467452364-66522-1-git-send-email-oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

It added reset function for RoCE driver. RoCE is a feature of hns.
In hip06 SoC, in RoCE reset process, it's needed to configure dsaf
channel reset, port and sl map info. Reset function of RoCE is
located in dsaf module, we only call it in RoCE driver when needed.

Signed-off-by: Wei Hu <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Nenglong Zhao <zhaonenglong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Sheng Li <lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
PATCH v11:
This fixes the comments given by Leon Romanovsky over the PATCH v10:
  Link: https://lkml.org/lkml/2016/6/24/277

PATCH v10/v9/v8/v7:
- No change over PATCH v6

PATCH v6:
This fixes the comments given by Leon Romanovsky over the PATCH v5:
  Link: https://lkml.org/lkml/2016/5/3/733

PATCH v5/v4/v3:
- No change over PATCH v2

PATCH v2:
This fixes the comments given by Leon Romanovsky over the PATCH v1:
  Link: https://lkml.org/lkml/2016/3/12/46

PATCH v1:
- The initial patch
---
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 84 ++++++++++++++++++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h | 30 ++++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 36 ++++++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  | 15 +++-
 4 files changed, 164 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 1c2ddb2..3571f1f 100644
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
+		dev_err(dsaf_dev->dev, "%s v1 chip doesn't support RoCE!\n",
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
+		msleep(SRST_TIME_INTERVAL);
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
index f0502ba..8e7e67d 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
@@ -40,6 +40,32 @@ struct hns_mac_cb;
 #define DSAF_DUMP_REGS_NUM 504
 #define DSAF_STATIC_NUM 28
 
+#define DSAF_ROCE_CREDIT_CHN	8
+#define DSAF_ROCE_CHAN_MODE	3
+
+enum dsaf_roce_port_mode {
+	DSAF_ROCE_6PORT_MODE,
+	DSAF_ROCE_4PORT_MODE,
+	DSAF_ROCE_2PORT_MODE,
+	DSAF_ROCE_CHAN_MODE_NUM,
+};
+
+enum dsaf_roce_port_num {
+	DSAF_ROCE_PORT_0,
+	DSAF_ROCE_PORT_1,
+	DSAF_ROCE_PORT_2,
+	DSAF_ROCE_PORT_3,
+	DSAF_ROCE_PORT_4,
+	DSAF_ROCE_PORT_5,
+};
+
+enum dsaf_roce_qos_sl {
+	DSAF_ROCE_SL_0,
+	DSAF_ROCE_SL_1,
+	DSAF_ROCE_SL_2,
+	DSAF_ROCE_SL_3,
+};
+
 #define DSAF_STATS_READ(p, offset) (*((u64 *)((u8 *)(p) + (offset))))
 #define HNS_DSAF_IS_DEBUG(dev) (dev->dsaf_mode == DSAF_MODE_DISABLE_SP)
 
@@ -396,6 +422,10 @@ void hns_ppe_com_srst(struct ppe_common_cb *ppe_common, u32 val);
 
 void hns_dsaf_fix_mac_mode(struct hns_mac_cb *mac_cb);
 
+void hns_dsaf_srst_chns(struct dsaf_device *dsaf_dev, u32 msk, bool enable);
+
+void hns_dsaf_roce_srst(struct dsaf_device *dsaf_dev, bool enable);
+
 int hns_dsaf_ae_init(struct dsaf_device *dsaf_dev);
 void hns_dsaf_ae_uninit(struct dsaf_device *dsaf_dev);
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
index a837bb9..da3061c 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
@@ -165,6 +165,42 @@ void hns_dsaf_xge_core_srst_by_port(struct dsaf_device *dsaf_dev,
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
+		dsaf_write_sub(dsaf_dev, DSAF_SUB_SC_ROCEE_RESET_REQ_REG, 1);
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
index 7c3b510..750ab4b 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -77,6 +77,12 @@
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
@@ -133,6 +139,8 @@
 #define DSAF_ROCEE_INT_STS_0_REG	0x200
 #define DSAFV2_SERDES_LBK_0_REG         0x220
 #define DSAF_PAUSE_CFG_REG		0x240
+#define DSAF_ROCE_PORT_MAP_REG		0x2A0
+#define DSAF_ROCE_SL_MAP_REG            0x2A4
 #define DSAF_PPE_QID_CFG_0_REG		0x300
 #define DSAF_SW_PORT_TYPE_0_REG		0x320
 #define DSAF_STP_PORT_TYPE_0_REG	0x340
@@ -175,7 +183,8 @@
 #define DSAF_SBM_BP_CFG_2_XGE_REG_0_REG		0x200C
 #define DSAF_SBM_BP_CFG_2_PPE_REG_0_REG		0x230C
 #define DSAF_SBM_BP_CFG_2_ROCEE_REG_0_REG	0x260C
-#define DSAFV2_SBM_BP_CFG_2_ROCEE_REG_0_REG		 0x238C
+#define DSAF_SBM_ROCEE_CFG_REG_REG		0x2380
+#define DSAFV2_SBM_BP_CFG_2_ROCEE_REG_0_REG	0x238C
 #define DSAF_SBM_FREE_CNT_0_0_REG		0x2010
 #define DSAF_SBM_FREE_CNT_1_0_REG		0x2014
 #define DSAF_SBM_BP_CNT_0_0_REG			0x2018
@@ -791,6 +800,10 @@
 #define DSAFV2_SBM_CFG4_RESET_BUF_NUM_NO_PFC_S 9
 #define DSAFV2_SBM_CFG4_RESET_BUF_NUM_NO_PFC_M (((1ULL << 9) - 1) << 9)
 
+#define DSAF_CHNS_MASK			0x3f000
+#define DSAF_SBM_ROCEE_CFG_CRD_EN_B	2
+#define SRST_TIME_INTERVAL		20
+
 #define DSAF_TBL_TCAM_ADDR_S 0
 #define DSAF_TBL_TCAM_ADDR_M ((1ULL << 9) - 1)
 
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

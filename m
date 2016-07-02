From: Lijun Ou <oulijun@huawei.com>
Subject: [PATCH v11 10/22] IB/hns: Add process flow to init RoCE engine
Date: Sat, 2 Jul 2016 17:39:12 +0800
Message-ID: <1467452364-66522-11-git-send-email-oulijun@huawei.com>
References: <1467452364-66522-1-git-send-email-oulijun@huawei.com>
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
In-Reply-To: <1467452364-66522-1-git-send-email-oulijun@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch mainly initialized the RoCE engine. It is absolutely
necessary to run RoCE. It mainly includes that configure DMAE
user, initialize doorbell and raq operations, enable port.

Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
Signed-off-by: Nenglong Zhao <zhaonenglong@hisilicon.com>
Signed-off-by: Lijun Ou <oulijun@huawei.com>
---
PATCH v11:
This fixes hns_roce_set_db_event_mode's type for static which was
leaved out for the comments given by Leon Romanovsky over the
[PATCH v9 11/22]

PATCH v10:
This fixes the same questions with the comments given by Leon
Romanovsky over the [PATCH v9 11/22]:
  Link: https://lkml.org/lkml/2016/6/9/53

PATCH v9:
This fixes the comments given by Leon Romanovsky over the PATCH v8:
  Link: https://lkml.org/lkml/2016/5/25/562

PATCH v8/v7/v6:
- No change over the PATCH v5

PATCH v5:
- The initial patch which was redesigned based on the second patch
  in PATCH v4
---
---
 drivers/infiniband/hw/hns/hns_roce_common.h | 107 +++++++
 drivers/infiniband/hw/hns/hns_roce_device.h |  10 +
 drivers/infiniband/hw/hns/hns_roce_hw_v1.c  | 443 ++++++++++++++++++++++++++++
 drivers/infiniband/hw/hns/hns_roce_hw_v1.h  |  58 ++++
 drivers/infiniband/hw/hns/hns_roce_main.c   |  10 +
 5 files changed, 628 insertions(+)

diff --git a/drivers/infiniband/hw/hns/hns_roce_common.h b/drivers/infiniband/hw/hns/hns_roce_common.h
index f15bf1b..776286c 100644
--- a/drivers/infiniband/hw/hns/hns_roce_common.h
+++ b/drivers/infiniband/hw/hns/hns_roce_common.h
@@ -53,6 +53,93 @@
 #define roce_set_bit(origin, shift, val) \
 	roce_set_field((origin), (1ul << (shift)), (shift), (val))
 
+#define ROCEE_GLB_CFG_ROCEE_DB_SQ_MODE_S 3
+#define ROCEE_GLB_CFG_ROCEE_DB_OTH_MODE_S 4
+
+#define ROCEE_GLB_CFG_SQ_EXT_DB_MODE_S 5
+
+#define ROCEE_GLB_CFG_OTH_EXT_DB_MODE_S 6
+
+#define ROCEE_GLB_CFG_ROCEE_PORT_ST_S 10
+#define ROCEE_GLB_CFG_ROCEE_PORT_ST_M  \
+	(((1UL << 6) - 1) << ROCEE_GLB_CFG_ROCEE_PORT_ST_S)
+
+#define ROCEE_GLB_CFG_TRP_RAQ_DROP_EN_S 16
+
+#define ROCEE_DMAE_USER_CFG1_ROCEE_STREAM_ID_TB_CFG_S 0
+#define ROCEE_DMAE_USER_CFG1_ROCEE_STREAM_ID_TB_CFG_M  \
+	(((1UL << 24) - 1) << ROCEE_DMAE_USER_CFG1_ROCEE_STREAM_ID_TB_CFG_S)
+
+#define ROCEE_DMAE_USER_CFG1_ROCEE_CACHE_TB_CFG_S 24
+#define ROCEE_DMAE_USER_CFG1_ROCEE_CACHE_TB_CFG_M  \
+	(((1UL << 4) - 1) << ROCEE_DMAE_USER_CFG1_ROCEE_CACHE_TB_CFG_S)
+
+#define ROCEE_DMAE_USER_CFG2_ROCEE_STREAM_ID_PKT_CFG_S 0
+#define ROCEE_DMAE_USER_CFG2_ROCEE_STREAM_ID_PKT_CFG_M   \
+	(((1UL << 24) - 1) << ROCEE_DMAE_USER_CFG2_ROCEE_STREAM_ID_PKT_CFG_S)
+
+#define ROCEE_DMAE_USER_CFG2_ROCEE_CACHE_PKT_CFG_S 24
+#define ROCEE_DMAE_USER_CFG2_ROCEE_CACHE_PKT_CFG_M   \
+	(((1UL << 4) - 1) << ROCEE_DMAE_USER_CFG2_ROCEE_CACHE_PKT_CFG_S)
+
+#define ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_S 0
+#define ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_M   \
+	(((1UL << 16) - 1) << ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_S)
+
+#define ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_EMPTY_S 16
+#define ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_EMPTY_M   \
+	(((1UL << 16) - 1) << ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_EMPTY_S)
+
+#define ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_S 0
+#define ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_M   \
+	(((1UL << 16) - 1) << ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_S)
+
+#define ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_EMPTY_S 16
+#define ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_EMPTY_M   \
+	(((1UL << 16) - 1) << ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_EMPTY_S)
+
+#define ROCEE_RAQ_WL_ROCEE_RAQ_WL_S 0
+#define ROCEE_RAQ_WL_ROCEE_RAQ_WL_M   \
+	(((1UL << 8) - 1) << ROCEE_RAQ_WL_ROCEE_RAQ_WL_S)
+
+#define ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_POL_TIME_INTERVAL_S 0
+#define ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_POL_TIME_INTERVAL_M   \
+	(((1UL << 15) - 1) << \
+	ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_POL_TIME_INTERVAL_S)
+
+#define ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_RAQ_TIMEOUT_CHK_CFG_S 16
+#define ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_RAQ_TIMEOUT_CHK_CFG_M   \
+	(((1UL << 4) - 1) << \
+	ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_RAQ_TIMEOUT_CHK_CFG_S)
+
+#define ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_RAQ_TIMEOUT_CHK_EN_S 20
+
+#define ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_EXT_RAQ_MODE 21
+
+#define ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_SHIFT_S 0
+#define ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_SHIFT_M   \
+	(((1UL << 5) - 1) << ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_SHIFT_S)
+
+#define ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_BA_H_S 5
+#define ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_BA_H_M   \
+	(((1UL << 5) - 1) << ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_BA_H_S)
+
+#define ROCEE_EXT_DB_OTH_H_EXT_DB_OTH_SHIFT_S 0
+#define ROCEE_EXT_DB_OTH_H_EXT_DB_OTH_SHIFT_M   \
+	(((1UL << 5) - 1) << ROCEE_EXT_DB_OTH_H_EXT_DB_OTH_SHIFT_S)
+
+#define ROCEE_EXT_DB_SQ_H_EXT_DB_OTH_BA_H_S 5
+#define ROCEE_EXT_DB_SQ_H_EXT_DB_OTH_BA_H_M   \
+	(((1UL << 5) - 1) << ROCEE_EXT_DB_SQ_H_EXT_DB_OTH_BA_H_S)
+
+#define ROCEE_EXT_RAQ_H_EXT_RAQ_SHIFT_S 0
+#define ROCEE_EXT_RAQ_H_EXT_RAQ_SHIFT_M   \
+	(((1UL << 5) - 1) << ROCEE_EXT_RAQ_H_EXT_RAQ_SHIFT_S)
+
+#define ROCEE_EXT_RAQ_H_EXT_RAQ_BA_H_S 8
+#define ROCEE_EXT_RAQ_H_EXT_RAQ_BA_H_M   \
+	(((1UL << 5) - 1) << ROCEE_EXT_RAQ_H_EXT_RAQ_BA_H_S)
+
 #define ROCEE_BT_CMD_H_ROCEE_BT_CMD_IN_MDF_S 0
 #define ROCEE_BT_CMD_H_ROCEE_BT_CMD_IN_MDF_M   \
 	(((1UL << 19) - 1) << ROCEE_BT_CMD_H_ROCEE_BT_CMD_IN_MDF_S)
@@ -120,6 +207,26 @@
 #define ROCEE_ECC_CERR_ALM2_REG			0xB48
 
 #define ROCEE_ACK_DELAY_REG			0x14
+#define ROCEE_GLB_CFG_REG			0x18
+
+#define ROCEE_DMAE_USER_CFG1_REG		0x40
+#define ROCEE_DMAE_USER_CFG2_REG		0x44
+
+#define ROCEE_DB_SQ_WL_REG			0x154
+#define ROCEE_DB_OTHERS_WL_REG			0x158
+#define ROCEE_RAQ_WL_REG			0x15C
+#define ROCEE_WRMS_POL_TIME_INTERVAL_REG	0x160
+#define ROCEE_EXT_DB_SQ_REG			0x164
+#define ROCEE_EXT_DB_SQ_H_REG			0x168
+#define ROCEE_EXT_DB_OTH_REG			0x16C
+
+#define ROCEE_EXT_DB_OTH_H_REG			0x170
+#define ROCEE_EXT_DB_SQ_WL_EMPTY_REG		0x174
+#define ROCEE_EXT_DB_SQ_WL_REG			0x178
+#define ROCEE_EXT_DB_OTHERS_WL_EMPTY_REG	0x17C
+#define ROCEE_EXT_DB_OTHERS_WL_REG		0x180
+#define ROCEE_EXT_RAQ_REG			0x184
+#define ROCEE_EXT_RAQ_H_REG			0x188
 
 #define ROCEE_CAEP_CE_INTERVAL_CFG_REG		0x190
 #define ROCEE_CAEP_CE_BURST_NUM_CFG_REG		0x194
diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infiniband/hw/hns/hns_roce_device.h
index dc5bbc9..8b30b57 100644
--- a/drivers/infiniband/hw/hns/hns_roce_device.h
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -103,6 +103,9 @@ enum {
 
 #define HNS_ROCE_CMD_SUCCESS			1
 
+#define HNS_ROCE_PORT_DOWN			0
+#define HNS_ROCE_PORT_UP			1
+
 struct hns_roce_uar {
 	u64		pfn;
 	unsigned long	index;
@@ -188,6 +191,10 @@ struct hns_roce_cq_table {
 	struct hns_roce_hem_table	table;
 };
 
+struct hns_roce_raq_table {
+	struct hns_roce_buf_list	*e_raq_buf;
+};
+
 struct hns_roce_cmd_context {
 	struct completion	done;
 	int			result;
@@ -305,6 +312,9 @@ struct hns_roce_caps {
 struct hns_roce_hw {
 	int (*reset)(struct hns_roce_dev *hr_dev, bool enable);
 	void (*hw_profile)(struct hns_roce_dev *hr_dev);
+	int (*hw_init)(struct hns_roce_dev *hr_dev);
+	void (*hw_exit)(struct hns_roce_dev *hr_dev);
+	void	*priv;
 };
 
 struct hns_roce_dev {
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
index f2a824f..367d86c 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
@@ -36,6 +36,397 @@
 #include "hns_roce_device.h"
 #include "hns_roce_hw_v1.h"
 
+static void hns_roce_set_db_event_mode(struct hns_roce_dev *hr_dev,
+				       int sdb_mode, int odb_mode)
+{
+	u32 val;
+
+	val = roce_read(hr_dev, ROCEE_GLB_CFG_REG);
+	roce_set_bit(val, ROCEE_GLB_CFG_ROCEE_DB_SQ_MODE_S, sdb_mode);
+	roce_set_bit(val, ROCEE_GLB_CFG_ROCEE_DB_OTH_MODE_S, odb_mode);
+	roce_write(hr_dev, ROCEE_GLB_CFG_REG, val);
+}
+
+static void hns_roce_set_db_ext_mode(struct hns_roce_dev *hr_dev, u32 sdb_mode,
+				     u32 odb_mode)
+{
+	u32 val;
+
+	/* Configure SDB/ODB extend mode */
+	val = roce_read(hr_dev, ROCEE_GLB_CFG_REG);
+	roce_set_bit(val, ROCEE_GLB_CFG_SQ_EXT_DB_MODE_S, sdb_mode);
+	roce_set_bit(val, ROCEE_GLB_CFG_OTH_EXT_DB_MODE_S, odb_mode);
+	roce_write(hr_dev, ROCEE_GLB_CFG_REG, val);
+}
+
+static void hns_roce_set_sdb(struct hns_roce_dev *hr_dev, u32 sdb_alept,
+			     u32 sdb_alful)
+{
+	u32 val;
+
+	/* Configure SDB */
+	val = roce_read(hr_dev, ROCEE_DB_SQ_WL_REG);
+	roce_set_field(val, ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_M,
+		       ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_S, sdb_alful);
+	roce_set_field(val, ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_EMPTY_M,
+		       ROCEE_DB_SQ_WL_ROCEE_DB_SQ_WL_EMPTY_S, sdb_alept);
+	roce_write(hr_dev, ROCEE_DB_SQ_WL_REG, val);
+}
+
+static void hns_roce_set_odb(struct hns_roce_dev *hr_dev, u32 odb_alept,
+			     u32 odb_alful)
+{
+	u32 val;
+
+	/* Configure ODB */
+	val = roce_read(hr_dev, ROCEE_DB_OTHERS_WL_REG);
+	roce_set_field(val, ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_M,
+		       ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_S, odb_alful);
+	roce_set_field(val, ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_EMPTY_M,
+		       ROCEE_DB_OTHERS_WL_ROCEE_DB_OTH_WL_EMPTY_S, odb_alept);
+	roce_write(hr_dev, ROCEE_DB_OTHERS_WL_REG, val);
+}
+
+static void hns_roce_set_sdb_ext(struct hns_roce_dev *hr_dev, u32 ext_sdb_alept,
+				 u32 ext_sdb_alful)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_v1_priv *priv;
+	struct hns_roce_db_table *db;
+	dma_addr_t sdb_dma_addr;
+	u32 val;
+
+	priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+	db = &priv->db_table;
+
+	/* Configure extend SDB threshold */
+	roce_write(hr_dev, ROCEE_EXT_DB_SQ_WL_EMPTY_REG, ext_sdb_alept);
+	roce_write(hr_dev, ROCEE_EXT_DB_SQ_WL_REG, ext_sdb_alful);
+
+	/* Configure extend SDB base addr */
+	sdb_dma_addr = db->ext_db->sdb_buf_list->map;
+	roce_write(hr_dev, ROCEE_EXT_DB_SQ_REG, (u32)(sdb_dma_addr >> 12));
+
+	/* Configure extend SDB depth */
+	val = roce_read(hr_dev, ROCEE_EXT_DB_SQ_H_REG);
+	roce_set_field(val, ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_SHIFT_M,
+		       ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_SHIFT_S,
+		       db->ext_db->esdb_dep);
+	/*
+	 * 44 = 32 + 12, When evaluating addr to hardware, shift 12 because of
+	 * using 4K page, and shift more 32 because of
+	 * caculating the high 32 bit value evaluated to hardware.
+	 */
+	roce_set_field(val, ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_BA_H_M,
+		       ROCEE_EXT_DB_SQ_H_EXT_DB_SQ_BA_H_S, sdb_dma_addr >> 44);
+	roce_write(hr_dev, ROCEE_EXT_DB_SQ_H_REG, val);
+
+	dev_dbg(dev, "ext SDB depth: 0x%x\n", db->ext_db->esdb_dep);
+	dev_dbg(dev, "ext SDB threshold: epmty: 0x%x, ful: 0x%x\n",
+		ext_sdb_alept, ext_sdb_alful);
+}
+
+static void hns_roce_set_odb_ext(struct hns_roce_dev *hr_dev, u32 ext_odb_alept,
+				 u32 ext_odb_alful)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_v1_priv *priv;
+	struct hns_roce_db_table *db;
+	dma_addr_t odb_dma_addr;
+	u32 val;
+
+	priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+	db = &priv->db_table;
+
+	/* Configure extend ODB threshold */
+	roce_write(hr_dev, ROCEE_EXT_DB_OTHERS_WL_EMPTY_REG, ext_odb_alept);
+	roce_write(hr_dev, ROCEE_EXT_DB_OTHERS_WL_REG, ext_odb_alful);
+
+	/* Configure extend ODB base addr */
+	odb_dma_addr = db->ext_db->odb_buf_list->map;
+	roce_write(hr_dev, ROCEE_EXT_DB_OTH_REG, (u32)(odb_dma_addr >> 12));
+
+	/* Configure extend ODB depth */
+	val = roce_read(hr_dev, ROCEE_EXT_DB_OTH_H_REG);
+	roce_set_field(val, ROCEE_EXT_DB_OTH_H_EXT_DB_OTH_SHIFT_M,
+		       ROCEE_EXT_DB_OTH_H_EXT_DB_OTH_SHIFT_S,
+		       db->ext_db->eodb_dep);
+	roce_set_field(val, ROCEE_EXT_DB_SQ_H_EXT_DB_OTH_BA_H_M,
+		       ROCEE_EXT_DB_SQ_H_EXT_DB_OTH_BA_H_S,
+		       db->ext_db->eodb_dep);
+	roce_write(hr_dev, ROCEE_EXT_DB_OTH_H_REG, val);
+
+	dev_dbg(dev, "ext ODB depth: 0x%x\n", db->ext_db->eodb_dep);
+	dev_dbg(dev, "ext ODB threshold: empty: 0x%x, ful: 0x%x\n",
+		ext_odb_alept, ext_odb_alful);
+}
+
+static int hns_roce_db_ext_init(struct hns_roce_dev *hr_dev, u32 sdb_ext_mod,
+				u32 odb_ext_mod)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_v1_priv *priv;
+	struct hns_roce_db_table *db;
+	dma_addr_t sdb_dma_addr;
+	dma_addr_t odb_dma_addr;
+	int ret = 0;
+
+	priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+	db = &priv->db_table;
+
+	db->ext_db = kmalloc(sizeof(*db->ext_db), GFP_KERNEL);
+	if (!db->ext_db)
+		return -ENOMEM;
+
+	if (sdb_ext_mod) {
+		db->ext_db->sdb_buf_list = kmalloc(
+				sizeof(*db->ext_db->sdb_buf_list), GFP_KERNEL);
+		if (!db->ext_db->sdb_buf_list) {
+			ret = -ENOMEM;
+			goto ext_sdb_buf_fail_out;
+		}
+
+		db->ext_db->sdb_buf_list->buf = dma_alloc_coherent(dev,
+						     HNS_ROCE_V1_EXT_SDB_SIZE,
+						     &sdb_dma_addr, GFP_KERNEL);
+		if (!db->ext_db->sdb_buf_list->buf) {
+			ret = -ENOMEM;
+			goto alloc_sq_db_buf_fail;
+		}
+		db->ext_db->sdb_buf_list->map = sdb_dma_addr;
+
+		db->ext_db->esdb_dep = ilog2(HNS_ROCE_V1_EXT_SDB_DEPTH);
+		hns_roce_set_sdb_ext(hr_dev, HNS_ROCE_V1_EXT_SDB_ALEPT,
+				     HNS_ROCE_V1_EXT_SDB_ALFUL);
+	} else
+		hns_roce_set_sdb(hr_dev, HNS_ROCE_V1_SDB_ALEPT,
+				 HNS_ROCE_V1_SDB_ALFUL);
+
+	if (odb_ext_mod) {
+		db->ext_db->odb_buf_list = kmalloc(
+				sizeof(*db->ext_db->odb_buf_list), GFP_KERNEL);
+		if (!db->ext_db->odb_buf_list) {
+			ret = -ENOMEM;
+			goto ext_odb_buf_fail_out;
+		}
+
+		db->ext_db->odb_buf_list->buf = dma_alloc_coherent(dev,
+						     HNS_ROCE_V1_EXT_ODB_SIZE,
+						     &odb_dma_addr, GFP_KERNEL);
+		if (!db->ext_db->odb_buf_list->buf) {
+			ret = -ENOMEM;
+			goto alloc_otr_db_buf_fail;
+		}
+		db->ext_db->odb_buf_list->map = odb_dma_addr;
+
+		db->ext_db->eodb_dep = ilog2(HNS_ROCE_V1_EXT_ODB_DEPTH);
+		hns_roce_set_odb_ext(hr_dev, HNS_ROCE_V1_EXT_ODB_ALEPT,
+				     HNS_ROCE_V1_EXT_ODB_ALFUL);
+	} else
+		hns_roce_set_odb(hr_dev, HNS_ROCE_V1_ODB_ALEPT,
+				 HNS_ROCE_V1_ODB_ALFUL);
+
+	hns_roce_set_db_ext_mode(hr_dev, sdb_ext_mod, odb_ext_mod);
+
+	return 0;
+
+alloc_otr_db_buf_fail:
+	kfree(db->ext_db->odb_buf_list);
+
+ext_odb_buf_fail_out:
+	if (sdb_ext_mod) {
+		dma_free_coherent(dev, HNS_ROCE_V1_EXT_SDB_SIZE,
+				  db->ext_db->sdb_buf_list->buf,
+				  db->ext_db->sdb_buf_list->map);
+	}
+
+alloc_sq_db_buf_fail:
+	if (sdb_ext_mod)
+		kfree(db->ext_db->sdb_buf_list);
+
+ext_sdb_buf_fail_out:
+	kfree(db->ext_db);
+	return ret;
+}
+
+static int hns_roce_db_init(struct hns_roce_dev *hr_dev)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_v1_priv *priv;
+	struct hns_roce_db_table *db;
+	u32 sdb_ext_mod;
+	u32 odb_ext_mod;
+	u32 sdb_evt_mod;
+	u32 odb_evt_mod;
+	int ret = 0;
+
+	priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+	db = &priv->db_table;
+
+	memset(db, 0, sizeof(*db));
+
+	/* Default DB mode */
+	sdb_ext_mod = HNS_ROCE_SDB_EXTEND_MODE;
+	odb_ext_mod = HNS_ROCE_ODB_EXTEND_MODE;
+	sdb_evt_mod = HNS_ROCE_SDB_NORMAL_MODE;
+	odb_evt_mod = HNS_ROCE_ODB_POLL_MODE;
+
+	db->sdb_ext_mod = sdb_ext_mod;
+	db->odb_ext_mod = odb_ext_mod;
+
+	/* Init extend DB */
+	ret = hns_roce_db_ext_init(hr_dev, sdb_ext_mod, odb_ext_mod);
+	if (ret) {
+		dev_err(dev, "Failed in extend DB configuration.\n");
+		return ret;
+	}
+
+	hns_roce_set_db_event_mode(hr_dev, sdb_evt_mod, odb_evt_mod);
+
+	return 0;
+}
+
+static void hns_roce_db_free(struct hns_roce_dev *hr_dev)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_v1_priv *priv;
+	struct hns_roce_db_table *db;
+
+	priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+	db = &priv->db_table;
+
+	if (db->sdb_ext_mod) {
+		dma_free_coherent(dev, HNS_ROCE_V1_EXT_SDB_SIZE,
+				  db->ext_db->sdb_buf_list->buf,
+				  db->ext_db->sdb_buf_list->map);
+		kfree(db->ext_db->sdb_buf_list);
+	}
+
+	if (db->odb_ext_mod) {
+		dma_free_coherent(dev, HNS_ROCE_V1_EXT_ODB_SIZE,
+				  db->ext_db->odb_buf_list->buf,
+				  db->ext_db->odb_buf_list->map);
+		kfree(db->ext_db->odb_buf_list);
+	}
+
+	kfree(db->ext_db);
+}
+
+static int hns_roce_raq_init(struct hns_roce_dev *hr_dev)
+{
+	int ret;
+	int raq_shift = 0;
+	dma_addr_t addr;
+	u32 val;
+	struct hns_roce_v1_priv *priv;
+	struct hns_roce_raq_table *raq;
+	struct device *dev = &hr_dev->pdev->dev;
+
+	priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+	raq = &priv->raq_table;
+
+	raq->e_raq_buf = kzalloc(sizeof(*(raq->e_raq_buf)), GFP_KERNEL);
+	if (!raq->e_raq_buf)
+		return -ENOMEM;
+
+	raq->e_raq_buf->buf = dma_alloc_coherent(dev, HNS_ROCE_V1_RAQ_SIZE,
+						 &addr, GFP_KERNEL);
+	if (!raq->e_raq_buf->buf) {
+		ret = -ENOMEM;
+		goto err_dma_alloc_raq;
+	}
+	raq->e_raq_buf->map = addr;
+
+	/* Configure raq extended address. 48bit 4K align*/
+	roce_write(hr_dev, ROCEE_EXT_RAQ_REG, raq->e_raq_buf->map >> 12);
+
+	/* Configure raq_shift */
+	raq_shift = ilog2(HNS_ROCE_V1_RAQ_SIZE / HNS_ROCE_V1_RAQ_ENTRY);
+	val = roce_read(hr_dev, ROCEE_EXT_RAQ_H_REG);
+	roce_set_field(val, ROCEE_EXT_RAQ_H_EXT_RAQ_SHIFT_M,
+		       ROCEE_EXT_RAQ_H_EXT_RAQ_SHIFT_S, raq_shift);
+	/*
+	 * 44 = 32 + 12, When evaluating addr to hardware, shift 12 because of
+	 * using 4K page, and shift more 32 because of
+	 * caculating the high 32 bit value evaluated to hardware.
+	 */
+	roce_set_field(val, ROCEE_EXT_RAQ_H_EXT_RAQ_BA_H_M,
+		       ROCEE_EXT_RAQ_H_EXT_RAQ_BA_H_S,
+		       raq->e_raq_buf->map >> 44);
+	roce_write(hr_dev, ROCEE_EXT_RAQ_H_REG, val);
+	dev_dbg(dev, "Configure raq_shift 0x%x.\n", val);
+
+	/* Configure raq threshold */
+	val = roce_read(hr_dev, ROCEE_RAQ_WL_REG);
+	roce_set_field(val, ROCEE_RAQ_WL_ROCEE_RAQ_WL_M,
+		       ROCEE_RAQ_WL_ROCEE_RAQ_WL_S,
+		       HNS_ROCE_V1_EXT_RAQ_WF);
+	roce_write(hr_dev, ROCEE_RAQ_WL_REG, val);
+	dev_dbg(dev, "Configure raq_wl 0x%x.\n", val);
+
+	/* Enable extend raq */
+	val = roce_read(hr_dev, ROCEE_WRMS_POL_TIME_INTERVAL_REG);
+	roce_set_field(val,
+		       ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_POL_TIME_INTERVAL_M,
+		       ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_POL_TIME_INTERVAL_S,
+		       POL_TIME_INTERVAL_VAL);
+	roce_set_bit(val, ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_EXT_RAQ_MODE, 1);
+	roce_set_field(val,
+		       ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_RAQ_TIMEOUT_CHK_CFG_M,
+		       ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_RAQ_TIMEOUT_CHK_CFG_S,
+		       2);
+	roce_set_bit(val,
+		     ROCEE_WRMS_POL_TIME_INTERVAL_WRMS_RAQ_TIMEOUT_CHK_EN_S, 1);
+	roce_write(hr_dev, ROCEE_WRMS_POL_TIME_INTERVAL_REG, val);
+	dev_dbg(dev, "Configure WrmsPolTimeInterval 0x%x.\n", val);
+
+	/* Enable raq drop */
+	val = roce_read(hr_dev, ROCEE_GLB_CFG_REG);
+	roce_set_bit(val, ROCEE_GLB_CFG_TRP_RAQ_DROP_EN_S, 1);
+	roce_write(hr_dev, ROCEE_GLB_CFG_REG, val);
+	dev_dbg(dev, "Configure GlbCfg = 0x%x.\n", val);
+
+	return 0;
+
+err_dma_alloc_raq:
+	kfree(raq->e_raq_buf);
+	return ret;
+}
+
+static void hns_roce_raq_free(struct hns_roce_dev *hr_dev)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_v1_priv *priv;
+	struct hns_roce_raq_table *raq;
+
+	priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+	raq = &priv->raq_table;
+
+	dma_free_coherent(dev, HNS_ROCE_V1_RAQ_SIZE, raq->e_raq_buf->buf,
+			  raq->e_raq_buf->map);
+	kfree(raq->e_raq_buf);
+}
+
+static void hns_roce_port_enable(struct hns_roce_dev *hr_dev, int enable_flag)
+{
+	u32 val;
+
+	if (enable_flag) {
+		val = roce_read(hr_dev, ROCEE_GLB_CFG_REG);
+		 /* Open all ports */
+		roce_set_field(val, ROCEE_GLB_CFG_ROCEE_PORT_ST_M,
+			       ROCEE_GLB_CFG_ROCEE_PORT_ST_S,
+			       ALL_PORT_VAL_OPEN);
+		roce_write(hr_dev, ROCEE_GLB_CFG_REG, val);
+	} else {
+		val = roce_read(hr_dev, ROCEE_GLB_CFG_REG);
+		/* Close all ports */
+		roce_set_field(val, ROCEE_GLB_CFG_ROCEE_PORT_ST_M,
+			       ROCEE_GLB_CFG_ROCEE_PORT_ST_S, 0x0);
+		roce_write(hr_dev, ROCEE_GLB_CFG_REG, val);
+	}
+}
+
 /**
  * hns_roce_v1_reset - reset roce
  * @hr_dev: roce device struct pointer
@@ -137,7 +528,59 @@ void hns_roce_v1_profile(struct hns_roce_dev *hr_dev)
 	caps->max_mtu = IB_MTU_2048;
 }
 
+int hns_roce_v1_init(struct hns_roce_dev *hr_dev)
+{
+	int ret;
+	u32 val;
+	struct device *dev = &hr_dev->pdev->dev;
+
+	/* DMAE user config */
+	val = roce_read(hr_dev, ROCEE_DMAE_USER_CFG1_REG);
+	roce_set_field(val, ROCEE_DMAE_USER_CFG1_ROCEE_CACHE_TB_CFG_M,
+		       ROCEE_DMAE_USER_CFG1_ROCEE_CACHE_TB_CFG_S, 0xf);
+	roce_set_field(val, ROCEE_DMAE_USER_CFG1_ROCEE_STREAM_ID_TB_CFG_M,
+		       ROCEE_DMAE_USER_CFG1_ROCEE_STREAM_ID_TB_CFG_S,
+		       1 << PAGES_SHIFT_16);
+	roce_write(hr_dev, ROCEE_DMAE_USER_CFG1_REG, val);
+
+	val = roce_read(hr_dev, ROCEE_DMAE_USER_CFG2_REG);
+	roce_set_field(val, ROCEE_DMAE_USER_CFG2_ROCEE_CACHE_PKT_CFG_M,
+		       ROCEE_DMAE_USER_CFG2_ROCEE_CACHE_PKT_CFG_S, 0xf);
+	roce_set_field(val, ROCEE_DMAE_USER_CFG2_ROCEE_STREAM_ID_PKT_CFG_M,
+		       ROCEE_DMAE_USER_CFG2_ROCEE_STREAM_ID_PKT_CFG_S,
+		       1 << PAGES_SHIFT_16);
+
+	ret = hns_roce_db_init(hr_dev);
+	if (ret) {
+		dev_err(dev, "doorbell init failed!\n");
+		return ret;
+	}
+
+	ret = hns_roce_raq_init(hr_dev);
+	if (ret) {
+		dev_err(dev, "raq init failed!\n");
+		goto error_failed_raq_init;
+	}
+
+	hns_roce_port_enable(hr_dev, HNS_ROCE_PORT_UP);
+
+	return 0;
+
+error_failed_raq_init:
+	hns_roce_db_free(hr_dev);
+	return ret;
+}
+
+void hns_roce_v1_exit(struct hns_roce_dev *hr_dev)
+{
+	hns_roce_port_enable(hr_dev, HNS_ROCE_PORT_DOWN);
+	hns_roce_raq_free(hr_dev);
+	hns_roce_db_free(hr_dev);
+}
+
 struct hns_roce_hw hns_roce_hw_v1 = {
 	.reset = hns_roce_v1_reset,
 	.hw_profile = hns_roce_v1_profile,
+	.hw_init = hns_roce_v1_init,
+	.hw_exit = hns_roce_v1_exit,
 };
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
index a909889..28b3ca4 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
@@ -69,8 +69,66 @@
 #define HNS_ROCE_V1_CQE_ENTRY_SIZE			32
 #define HNS_ROCE_V1_PAGE_SIZE_SUPPORT			0xFFFFF000
 
+#define HNS_ROCE_V1_EXT_RAQ_WF				8
+#define HNS_ROCE_V1_RAQ_ENTRY				64
+#define HNS_ROCE_V1_RAQ_DEPTH				32768
+#define HNS_ROCE_V1_RAQ_SIZE	(HNS_ROCE_V1_RAQ_ENTRY * HNS_ROCE_V1_RAQ_DEPTH)
+
+#define HNS_ROCE_V1_SDB_DEPTH				0x400
+#define HNS_ROCE_V1_ODB_DEPTH				0x400
+
+#define HNS_ROCE_V1_DB_RSVD				0x80
+
+#define HNS_ROCE_V1_SDB_ALEPT				HNS_ROCE_V1_DB_RSVD
+#define HNS_ROCE_V1_SDB_ALFUL	(HNS_ROCE_V1_SDB_DEPTH - HNS_ROCE_V1_DB_RSVD)
+#define HNS_ROCE_V1_ODB_ALEPT				HNS_ROCE_V1_DB_RSVD
+#define HNS_ROCE_V1_ODB_ALFUL	(HNS_ROCE_V1_ODB_DEPTH - HNS_ROCE_V1_DB_RSVD)
+
+#define HNS_ROCE_V1_EXT_SDB_DEPTH			0x4000
+#define HNS_ROCE_V1_EXT_ODB_DEPTH			0x4000
+#define HNS_ROCE_V1_EXT_SDB_ENTRY			16
+#define HNS_ROCE_V1_EXT_ODB_ENTRY			16
+#define HNS_ROCE_V1_EXT_SDB_SIZE  \
+	(HNS_ROCE_V1_EXT_SDB_DEPTH * HNS_ROCE_V1_EXT_SDB_ENTRY)
+#define HNS_ROCE_V1_EXT_ODB_SIZE  \
+	(HNS_ROCE_V1_EXT_ODB_DEPTH * HNS_ROCE_V1_EXT_ODB_ENTRY)
+
+#define HNS_ROCE_V1_EXT_SDB_ALEPT			HNS_ROCE_V1_DB_RSVD
+#define HNS_ROCE_V1_EXT_SDB_ALFUL  \
+	(HNS_ROCE_V1_EXT_SDB_DEPTH - HNS_ROCE_V1_DB_RSVD)
+#define HNS_ROCE_V1_EXT_ODB_ALEPT			HNS_ROCE_V1_DB_RSVD
+#define HNS_ROCE_V1_EXT_ODB_ALFUL	\
+	(HNS_ROCE_V1_EXT_ODB_DEPTH - HNS_ROCE_V1_DB_RSVD)
+
+#define HNS_ROCE_ODB_POLL_MODE				0
+
+#define HNS_ROCE_SDB_NORMAL_MODE			0
+#define HNS_ROCE_SDB_EXTEND_MODE			1
+
+#define HNS_ROCE_ODB_EXTEND_MODE			1
+
+#define ALL_PORT_VAL_OPEN				0x3f
+#define POL_TIME_INTERVAL_VAL				0x80
 #define SLEEP_TIME_INTERVAL				20
 
+struct hns_roce_ext_db {
+	int esdb_dep;
+	int eodb_dep;
+	struct hns_roce_buf_list *sdb_buf_list;
+	struct hns_roce_buf_list *odb_buf_list;
+};
+
+struct hns_roce_db_table {
+	int  sdb_ext_mod;
+	int  odb_ext_mod;
+	struct hns_roce_ext_db *ext_db;
+};
+
+struct hns_roce_v1_priv {
+	struct hns_roce_db_table  db_table;
+	struct hns_roce_raq_table raq_table;
+};
+
 int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, bool enable);
 
 #endif
diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
index a0818fb..966e6d0 100644
--- a/drivers/infiniband/hw/hns/hns_roce_main.c
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -313,6 +313,15 @@ static int hns_roce_probe(struct platform_device *pdev)
 		goto error_failed_setup_hca;
 	}
 
+	ret = hr_dev->hw->hw_init(hr_dev);
+	if (ret) {
+		dev_err(dev, "hw_init failed!\n");
+		goto error_failed_engine_init;
+	}
+
+error_failed_engine_init:
+	hns_roce_cleanup_bitmap(hr_dev);
+
 error_failed_setup_hca:
 	hns_roce_cleanup_hem(hr_dev);
 
@@ -345,6 +354,7 @@ static int hns_roce_remove(struct platform_device *pdev)
 {
 	struct hns_roce_dev *hr_dev = platform_get_drvdata(pdev);
 
+	hr_dev->hw->hw_exit(hr_dev);
 	hns_roce_cleanup_bitmap(hr_dev);
 	hns_roce_cleanup_hem(hr_dev);
 
-- 
1.9.1

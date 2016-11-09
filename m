From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net-next 03/17] net: hns: fix for promisc mode in HNS driver
Date: Wed, 9 Nov 2016 18:13:47 +0000
Message-ID: <20161109181401.913728-4-salil.mehta@huawei.com>
References: <20161109181401.913728-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        Kejian Yan <yankejian@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161109181401.913728-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kejian Yan <yankejian@huawei.com>

If set promisc mode when there is some traffic, The service nic will
cause system halted. We reserve the last 6 tcam entry for the 6 ports.
If promisc mode is enabled, we can config the relative tcam as fuzzy
matching and set to be valid, or set the tcam to be invalid

Signed-off-by: Kejian Yan <yankejian@huawei.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  |    2 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |   63 ++++++++++++++++++--
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |    3 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |    3 +
 4 files changed, 67 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index 2d64f53..fc90260 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -1085,6 +1085,8 @@ void hns_mac_set_promisc(struct hns_mac_cb *mac_cb, u8 en)
 {
 	struct mac_driver *mac_ctrl_drv = hns_mac_get_drv(mac_cb);
 
+	hns_dsaf_set_promisc_tcam(mac_cb->dsaf_dev, mac_cb->mac_id, !!en);
+
 	if (mac_ctrl_drv->set_promiscuous)
 		mac_ctrl_drv->set_promiscuous(mac_ctrl_drv, en);
 }
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 64f45ee..2721458 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -765,7 +765,7 @@ static void hns_dsaf_tbl_tcam_data_ucast_pul(
 
 void hns_dsaf_set_promisc_mode(struct dsaf_device *dsaf_dev, u32 en)
 {
-	if (!HNS_DSAF_IS_DEBUG(dsaf_dev))
+	if (AE_IS_VER1(dsaf_dev->dsaf_ver) && !HNS_DSAF_IS_DEBUG(dsaf_dev))
 		dsaf_set_dev_bit(dsaf_dev, DSAF_CFG_0_REG,
 				 DSAF_CFG_MIX_MODE_S, !!en);
 }
@@ -1384,6 +1384,12 @@ static int hns_dsaf_init(struct dsaf_device *dsaf_dev)
 	if (HNS_DSAF_IS_DEBUG(dsaf_dev))
 		return 0;
 
+	if (AE_IS_VER1(dsaf_dev->dsaf_ver))
+		dsaf_dev->tcam_max_num = DSAF_TCAM_SUM;
+	else
+		dsaf_dev->tcam_max_num =
+			DSAF_TCAM_SUM - DSAFV2_MAC_FUZZY_TCAM_NUM;
+
 	spin_lock_init(&dsaf_dev->tcam_lock);
 	ret = hns_dsaf_init_hw(dsaf_dev);
 	if (ret)
@@ -1439,7 +1445,7 @@ static u16 hns_dsaf_find_soft_mac_entry(
 	u32 i;
 
 	soft_mac_entry = priv->soft_mac_tbl;
-	for (i = 0; i < DSAF_TCAM_SUM; i++) {
+	for (i = 0; i < dsaf_dev->tcam_max_num; i++) {
 		/* invall tab entry */
 		if ((soft_mac_entry->index != DSAF_INVALID_ENTRY_IDX) &&
 		    (soft_mac_entry->tcam_key.high.val == mac_key->high.val) &&
@@ -1464,7 +1470,7 @@ static u16 hns_dsaf_find_empty_mac_entry(struct dsaf_device *dsaf_dev)
 	u32 i;
 
 	soft_mac_entry = priv->soft_mac_tbl;
-	for (i = 0; i < DSAF_TCAM_SUM; i++) {
+	for (i = 0; i < dsaf_dev->tcam_max_num; i++) {
 		/* inv all entry */
 		if (soft_mac_entry->index == DSAF_INVALID_ENTRY_IDX)
 			/* return find result --soft index */
@@ -2040,7 +2046,7 @@ int hns_dsaf_get_mac_entry_by_index(
 	struct dsaf_tbl_tcam_ucast_cfg mac_uc_data;
 	char mac_addr[ETH_ALEN] = {0};
 
-	if (entry_index >= DSAF_TCAM_SUM) {
+	if (entry_index >= dsaf_dev->tcam_max_num) {
 		/* find none, del error */
 		dev_err(dsaf_dev->dev, "get_uc_entry failed, %s\n",
 			dsaf_dev->ae_dev.name);
@@ -2732,6 +2738,55 @@ int hns_dsaf_get_regs_count(void)
 	return DSAF_DUMP_REGS_NUM;
 }
 
+/* Reserve the last TCAM entry for promisc support */
+#define dsaf_promisc_tcam_entry(port) \
+	(DSAF_TCAM_SUM - DSAFV2_MAC_FUZZY_TCAM_NUM + (port))
+void hns_dsaf_set_promisc_tcam(struct dsaf_device *dsaf_dev,
+			       u32 port, bool enable)
+{
+	struct dsaf_drv_priv *priv = hns_dsaf_dev_priv(dsaf_dev);
+	struct dsaf_drv_soft_mac_tbl *soft_mac_entry = priv->soft_mac_tbl;
+	u16 entry_index;
+	struct dsaf_drv_tbl_tcam_key tbl_tcam_data, tbl_tcam_mask;
+	struct dsaf_tbl_tcam_mcast_cfg mac_data = {0};
+
+	if ((AE_IS_VER1(dsaf_dev->dsaf_ver)) || HNS_DSAF_IS_DEBUG(dsaf_dev))
+		return;
+
+	/* find the tcam entry index for promisc */
+	entry_index = dsaf_promisc_tcam_entry(port);
+
+	/* config key mask */
+	if (enable) {
+		memset(&tbl_tcam_data, 0, sizeof(tbl_tcam_data));
+		memset(&tbl_tcam_mask, 0, sizeof(tbl_tcam_mask));
+		tbl_tcam_data.low.bits.port = port;
+		tbl_tcam_mask.low.bits.port = 0xf;  /* [3:0]: port id */
+
+		/* SUB_QID */
+		dsaf_set_bit(mac_data.tbl_mcast_port_msk[0],
+			     DSAF_SERVICE_NW_NUM, true);
+		mac_data.tbl_mcast_item_vld = true;	/* item_vld bit */
+	} else {
+		mac_data.tbl_mcast_item_vld = false;	/* item_vld bit */
+	}
+
+	dev_dbg(dsaf_dev->dev,
+		"set_promisc_entry, %s Mac key(%#x:%#x) entry_index%d\n",
+		dsaf_dev->ae_dev.name, tbl_tcam_data.high.val,
+		tbl_tcam_data.low.val, entry_index);
+
+	/* config promisc entry with mask */
+	hns_dsaf_tcam_mc_cfg(dsaf_dev, entry_index,
+			     (struct dsaf_tbl_tcam_data *)&tbl_tcam_data,
+			     (struct dsaf_tbl_tcam_data *)&tbl_tcam_mask,
+			     &mac_data);
+
+	/* config software entry */
+	soft_mac_entry += entry_index;
+	soft_mac_entry->index = enable ? entry_index : DSAF_INVALID_ENTRY_IDX;
+}
+
 /**
  * dsaf_probe - probo dsaf dev
  * @pdev: dasf platform device
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
index f832a32..2cae6eb 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
@@ -341,6 +341,7 @@ struct dsaf_device {
 	enum hal_dsaf_mode dsaf_en;
 	enum hal_dsaf_tc_mode dsaf_tc_mode;
 	u32 dsaf_ver;
+	u16 tcam_max_num;	/* max TCAM entry for user except promisc */
 
 	struct ppe_common_cb *ppe_common[DSAF_COMM_DEV_NUM];
 	struct rcb_common_cb *rcb_common[DSAF_COMM_DEV_NUM];
@@ -459,6 +460,8 @@ void hns_dsaf_get_strings(int stringset, u8 *data, int port,
 void hns_dsaf_get_regs(struct dsaf_device *ddev, u32 port, void *data);
 int hns_dsaf_get_regs_count(void);
 void hns_dsaf_set_promisc_mode(struct dsaf_device *dsaf_dev, u32 en);
+void hns_dsaf_set_promisc_tcam(struct dsaf_device *dsaf_dev,
+			       u32 port, bool enable);
 
 void hns_dsaf_get_rx_mac_pause_en(struct dsaf_device *dsaf_dev, int mac_id,
 				  u32 *en);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index 6826b28..3eb8b4d 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -41,6 +41,9 @@
 #define DSAF_SW_PORT_NUM	8
 #define DSAF_TOTAL_QUEUE_NUM	129
 
+/* reserved a tcam entry for each port to support promisc by fuzzy match */
+#define DSAFV2_MAC_FUZZY_TCAM_NUM    DSAF_MAX_PORT_NUM
+
 #define DSAF_TCAM_SUM		512
 #define DSAF_LINE_SUM		(2048 * 14)
 
-- 
1.7.9.5

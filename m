From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 10/19] net: hns: bugfix about pfc pause frame statistics
Date: Tue, 21 Jun 2016 11:56:30 +0800
Message-ID: <1466481399-70080-11-git-send-email-Yisen.Zhuang@huawei.com>
References: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <liguozhu@huawei.com>, <huangdaode@hisilicon.com>, <arnd@arndb.de>,
	<andriy.shevchenko@linux.intel.com>, <andrew@lunn.ch>,
	<geliangtang@163.com>, <ivecera@redhat.com>,
	<fengguang.wu@intel.com>, <charles.chenxin@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
	<salil.mehta@huawei.com>, <yankejian@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daode Huang <huangdaode@hisilicon.com>

For SoC hip06, PFC pause handled in dsaf, while hip05 in XGMAC,
so change the statistics of pfc pause in dsaf and remove the old
pfc pause frame statistics.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |  6 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 72 +++++++++++++++++++---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h | 10 ++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |  5 ++
 4 files changed, 81 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index d37b778..b97cc75 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -587,6 +587,7 @@ void hns_ae_get_strings(struct hnae_handle *handle,
 	int idx;
 	struct hns_mac_cb *mac_cb;
 	struct hns_ppe_cb *ppe_cb;
+	struct dsaf_device *dsaf_dev = hns_ae_get_dsaf_dev(handle->dev);
 	u8 *p = data;
 	struct	hnae_vf_cb *vf_cb;
 
@@ -609,13 +610,14 @@ void hns_ae_get_strings(struct hnae_handle *handle,
 	p += ETH_GSTRING_LEN * hns_mac_get_sset_count(mac_cb, stringset);
 
 	if (mac_cb->mac_type == HNAE_PORT_SERVICE)
-		hns_dsaf_get_strings(stringset, p, port);
+		hns_dsaf_get_strings(stringset, p, port, dsaf_dev);
 }
 
 int hns_ae_get_sset_count(struct hnae_handle *handle, int stringset)
 {
 	u32 sset_count = 0;
 	struct hns_mac_cb *mac_cb;
+	struct dsaf_device *dsaf_dev = hns_ae_get_dsaf_dev(handle->dev);
 
 	assert(handle);
 
@@ -626,7 +628,7 @@ int hns_ae_get_sset_count(struct hnae_handle *handle, int stringset)
 	sset_count += hns_mac_get_sset_count(mac_cb, stringset);
 
 	if (mac_cb->mac_type == HNAE_PORT_SERVICE)
-		sset_count += hns_dsaf_get_sset_count(stringset);
+		sset_count += hns_dsaf_get_sset_count(dsaf_dev, stringset);
 
 	return sset_count;
 }
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index b8b2ff9..0edea9c 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -2096,11 +2096,24 @@ void hns_dsaf_fix_mac_mode(struct hns_mac_cb *mac_cb)
 	hns_dsaf_port_work_rate_cfg(dsaf_dev, mac_id, mode);
 }
 
+static u32 hns_dsaf_get_inode_prio_reg(int index)
+{
+	int base_index, offset;
+	u32 base_addr = DSAF_INODE_IN_PRIO_PAUSE_BASE_REG;
+
+	base_index = (index + 1) / DSAF_REG_PER_ZONE;
+	offset = (index + 1) % DSAF_REG_PER_ZONE;
+
+	return base_addr + DSAF_INODE_IN_PRIO_PAUSE_BASE_OFFSET * base_index +
+		DSAF_INODE_IN_PRIO_PAUSE_OFFSET * offset;
+}
+
 void hns_dsaf_update_stats(struct dsaf_device *dsaf_dev, u32 node_num)
 {
 	struct dsaf_hw_stats *hw_stats
 		= &dsaf_dev->hw_stats[node_num];
 	bool is_ver1 = AE_IS_VER1(dsaf_dev->dsaf_ver);
+	int i;
 	u32 reg_tmp;
 
 	hw_stats->pad_drop += dsaf_read_dev(dsaf_dev,
@@ -2135,6 +2148,18 @@ void hns_dsaf_update_stats(struct dsaf_device *dsaf_dev, u32 node_num)
 	hw_stats->stp_drop += dsaf_read_dev(dsaf_dev,
 		DSAF_INODE_IN_DATA_STP_DISC_0_REG + 0x80 * (u64)node_num);
 
+	/* pfc pause frame statistics stored in dsaf inode*/
+	if ((node_num < DSAF_SERVICE_NW_NUM) && !is_ver1) {
+		for (i = 0; i < DSAF_PRIO_NR; i++) {
+			reg_tmp = hns_dsaf_get_inode_prio_reg(i);
+			hw_stats->rx_pfc[i] += dsaf_read_dev(dsaf_dev,
+				reg_tmp + 0x4 * (u64)node_num);
+			hw_stats->tx_pfc[i] += dsaf_read_dev(dsaf_dev,
+				DSAF_XOD_XGE_PFC_PRIO_CNT_BASE_REG +
+				DSAF_XOD_XGE_PFC_PRIO_CNT_OFFSET * i +
+				0xF0 * (u64)node_num);
+		}
+	}
 	hw_stats->tx_pkts += dsaf_read_dev(dsaf_dev,
 		DSAF_XOD_RCVPKT_CNT_0_REG + 0x90 * (u64)node_num);
 }
@@ -2472,9 +2497,12 @@ void hns_dsaf_get_regs(struct dsaf_device *ddev, u32 port, void *data)
 		p[i] = 0xdddddddd;
 }
 
-static char *hns_dsaf_get_node_stats_strings(char *data, int node)
+static char *hns_dsaf_get_node_stats_strings(char *data, int node,
+					     struct dsaf_device *dsaf_dev)
 {
 	char *buff = data;
+	int i;
+	bool is_ver1 = AE_IS_VER1(dsaf_dev->dsaf_ver);
 
 	snprintf(buff, ETH_GSTRING_LEN, "innod%d_pad_drop_pkts", node);
 	buff = buff + ETH_GSTRING_LEN;
@@ -2502,6 +2530,18 @@ static char *hns_dsaf_get_node_stats_strings(char *data, int node)
 	buff = buff + ETH_GSTRING_LEN;
 	snprintf(buff, ETH_GSTRING_LEN, "innod%d_stp_drop_pkts", node);
 	buff = buff + ETH_GSTRING_LEN;
+	if ((node < DSAF_SERVICE_NW_NUM) && (!is_ver1)) {
+		for (i = 0; i < DSAF_PRIO_NR; i++) {
+			snprintf(buff, ETH_GSTRING_LEN,
+				 "inod%d_pfc_prio%d_pkts", node, i);
+			buff = buff + ETH_GSTRING_LEN;
+		}
+		for (i = 0; i < DSAF_PRIO_NR; i++) {
+			snprintf(buff, ETH_GSTRING_LEN,
+				 "onod%d_pfc_prio%d_pkts", node, i);
+			buff = buff + ETH_GSTRING_LEN;
+		}
+	}
 	snprintf(buff, ETH_GSTRING_LEN, "onnod%d_tx_pkts", node);
 	buff = buff + ETH_GSTRING_LEN;
 
@@ -2512,7 +2552,9 @@ static u64 *hns_dsaf_get_node_stats(struct dsaf_device *ddev, u64 *data,
 				    int node_num)
 {
 	u64 *p = data;
+	int i;
 	struct dsaf_hw_stats *hw_stats = &ddev->hw_stats[node_num];
+	bool is_ver1 = AE_IS_VER1(ddev->dsaf_ver);
 
 	p[0] = hw_stats->pad_drop;
 	p[1] = hw_stats->man_pkts;
@@ -2527,8 +2569,16 @@ static u64 *hns_dsaf_get_node_stats(struct dsaf_device *ddev, u64 *data,
 	p[10] = hw_stats->local_addr_false;
 	p[11] = hw_stats->vlan_drop;
 	p[12] = hw_stats->stp_drop;
-	p[13] = hw_stats->tx_pkts;
+	if ((node_num < DSAF_SERVICE_NW_NUM) && (!is_ver1)) {
+		for (i = 0; i < DSAF_PRIO_NR; i++) {
+			p[13 + i] = hw_stats->rx_pfc[i];
+			p[13 + i + DSAF_PRIO_NR] = hw_stats->tx_pfc[i];
+		}
+		p[29] = hw_stats->tx_pkts;
+		return &p[30];
+	}
 
+	p[13] = hw_stats->tx_pkts;
 	return &p[14];
 }
 
@@ -2556,11 +2606,16 @@ void hns_dsaf_get_stats(struct dsaf_device *ddev, u64 *data, int port)
  *@stringset: type of values in data
  *return dsaf string name count
  */
-int hns_dsaf_get_sset_count(int stringset)
+int hns_dsaf_get_sset_count(struct dsaf_device *dsaf_dev, int stringset)
 {
-	if (stringset == ETH_SS_STATS)
-		return DSAF_STATIC_NUM;
+	bool is_ver1 = AE_IS_VER1(dsaf_dev->dsaf_ver);
 
+	if (stringset == ETH_SS_STATS) {
+		if (is_ver1)
+			return DSAF_STATIC_NUM;
+		else
+			return DSAF_V2_STATIC_NUM;
+	}
 	return 0;
 }
 
@@ -2570,7 +2625,8 @@ int hns_dsaf_get_sset_count(int stringset)
  *@data:strings name value
  *@port:port index
  */
-void hns_dsaf_get_strings(int stringset, u8 *data, int port)
+void hns_dsaf_get_strings(int stringset, u8 *data, int port,
+			  struct dsaf_device *dsaf_dev)
 {
 	char *buff = (char *)data;
 	int node = port;
@@ -2579,11 +2635,11 @@ void hns_dsaf_get_strings(int stringset, u8 *data, int port)
 		return;
 
 	/* for ge/xge node info */
-	buff = hns_dsaf_get_node_stats_strings(buff, node);
+	buff = hns_dsaf_get_node_stats_strings(buff, node, dsaf_dev);
 
 	/* for ppe node info */
 	node = port + DSAF_PPE_INODE_BASE;
-	(void)hns_dsaf_get_node_stats_strings(buff, node);
+	(void)hns_dsaf_get_node_stats_strings(buff, node, dsaf_dev);
 }
 
 /**
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
index 2e55b3c..00a13de 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
@@ -39,6 +39,9 @@ struct hns_mac_cb;
 
 #define DSAF_DUMP_REGS_NUM 504
 #define DSAF_STATIC_NUM 28
+#define DSAF_V2_STATIC_NUM	44
+#define DSAF_PRIO_NR	8
+#define DSAF_REG_PER_ZONE	3
 
 #define DSAF_STATS_READ(p, offset) (*((u64 *)((u8 *)(p) + (offset))))
 #define HNS_DSAF_IS_DEBUG(dev) (dev->dsaf_mode == DSAF_MODE_DISABLE_SP)
@@ -176,6 +179,8 @@ struct dsaf_hw_stats {
 	u64 local_addr_false;
 	u64 vlan_drop;
 	u64 stp_drop;
+	u64 rx_pfc[DSAF_PRIO_NR];
+	u64 tx_pfc[DSAF_PRIO_NR];
 	u64 tx_pkts;
 };
 
@@ -417,9 +422,10 @@ void hns_dsaf_ae_uninit(struct dsaf_device *dsaf_dev);
 
 void hns_dsaf_update_stats(struct dsaf_device *dsaf_dev, u32 inode_num);
 
-int hns_dsaf_get_sset_count(int stringset);
+int hns_dsaf_get_sset_count(struct dsaf_device *dsaf_dev, int stringset);
 void hns_dsaf_get_stats(struct dsaf_device *ddev, u64 *data, int port);
-void hns_dsaf_get_strings(int stringset, u8 *data, int port);
+void hns_dsaf_get_strings(int stringset, u8 *data, int port,
+			  struct dsaf_device *dsaf_dev);
 
 void hns_dsaf_get_regs(struct dsaf_device *ddev, u32 port, void *data);
 int hns_dsaf_get_regs_count(void);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index 7c3b510..e35d0cb 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -166,6 +166,9 @@
 #define DSAF_INODE_GE_FC_EN_0_REG		0x1B00
 #define DSAF_INODE_VC0_IN_PKT_NUM_0_REG		0x1B50
 #define DSAF_INODE_VC1_IN_PKT_NUM_0_REG		0x1C00
+#define DSAF_INODE_IN_PRIO_PAUSE_BASE_REG	0x1C00
+#define DSAF_INODE_IN_PRIO_PAUSE_BASE_OFFSET	0x100
+#define DSAF_INODE_IN_PRIO_PAUSE_OFFSET		0x50
 
 #define DSAF_SBM_CFG_REG_0_REG			0x2000
 #define DSAF_SBM_BP_CFG_0_XGE_REG_0_REG		0x2004
@@ -232,6 +235,8 @@
 #define DSAF_XOD_ROCEE_RCVIN0_CNT_0_REG		0x3074
 #define DSAF_XOD_ROCEE_RCVIN1_CNT_0_REG		0x3078
 #define DSAF_XOD_FIFO_STATUS_0_REG		0x307C
+#define DSAF_XOD_XGE_PFC_PRIO_CNT_BASE_REG	0x3A00
+#define DSAF_XOD_XGE_PFC_PRIO_CNT_OFFSET	0x4
 
 #define DSAF_VOQ_ECC_INVERT_EN_0_REG		0x4004
 #define DSAF_VOQ_SRAM_PKT_NUM_0_REG		0x4008
-- 
1.9.1

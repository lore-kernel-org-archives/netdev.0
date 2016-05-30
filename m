From: Kejian Yan <yankejian@huawei.com>
Subject: [patch v2 net-next 09/13] net: hns: add dsaf misc operation method
Date: Mon, 30 May 2016 10:10:18 +0800
Message-ID: <1464574222-69608-10-git-send-email-yankejian@huawei.com>
References: <1464574222-69608-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <fengguang.wu@intel.com>, <andriy.shevchenko@linux.intel.com>,
	<andrew@lunn.ch>, <ivecera@redhat.com>, <f.fainelli@gmail.com>,
	<haifeng.wei@huawei.com>, <charles.chenxin@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-acpi@vger.kernel.org>, <linuxarm@huawei.com>
To: <rjw@rjwysocki.net>, <lenb@kernel.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464574222-69608-1-git-send-email-yankejian@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The misc operation for different hw platform may be different, if using
current implementation, it will add a new branch on each function for
every new hw platform, so we add a method for this operation.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |  4 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c |  6 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  | 14 ++--
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h  |  2 -
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 11 ++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h | 33 ++++++---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 79 +++++++++++++++-------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.h |  7 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c  | 15 ++--
 .../net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c    | 10 +--
 10 files changed, 111 insertions(+), 70 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index 8e009f4..d37b778 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -637,13 +637,15 @@ static int hns_ae_config_loopback(struct hnae_handle *handle,
 	int ret;
 	struct hnae_vf_cb *vf_cb = hns_ae_get_vf_cb(handle);
 	struct hns_mac_cb *mac_cb = hns_get_mac_cb(handle);
+	struct dsaf_device *dsaf_dev = mac_cb->dsaf_dev;
 
 	switch (loop) {
 	case MAC_INTERNALLOOP_PHY:
 		ret = 0;
 		break;
 	case MAC_INTERNALLOOP_SERDES:
-		ret = hns_mac_config_sds_loopback(vf_cb->mac_cb, en);
+		ret = dsaf_dev->misc_op->cfg_serdes_loopback(vf_cb->mac_cb,
+							     !!en);
 		break;
 	case MAC_INTERNALLOOP_MAC:
 		ret = hns_mac_config_mac_loopback(vf_cb->mac_cb, loop, en);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
index 44abb08..1235c7f 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
@@ -110,7 +110,7 @@ static void hns_gmac_free(void *mac_drv)
 
 	u32 mac_id = drv->mac_id;
 
-	hns_dsaf_ge_srst_by_port(dsaf_dev, mac_id, 0);
+	dsaf_dev->misc_op->ge_srst(dsaf_dev, mac_id, 0);
 }
 
 static void hns_gmac_set_tx_auto_pause_frames(void *mac_drv, u16 newval)
@@ -317,9 +317,9 @@ static void hns_gmac_init(void *mac_drv)
 
 	port = drv->mac_id;
 
-	hns_dsaf_ge_srst_by_port(dsaf_dev, port, 0);
+	dsaf_dev->misc_op->ge_srst(dsaf_dev, port, 0);
 	mdelay(10);
-	hns_dsaf_ge_srst_by_port(dsaf_dev, port, 1);
+	dsaf_dev->misc_op->ge_srst(dsaf_dev, port, 1);
 	mdelay(10);
 	hns_gmac_disable(mac_drv, MAC_COMM_MODE_RX_AND_TX);
 	hns_gmac_tx_loop_pkt_dis(mac_drv);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index 527b49d..2ebf14a 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -95,7 +95,7 @@ void hns_mac_get_link_status(struct hns_mac_cb *mac_cb, u32 *link_status)
 	else
 		*link_status = 0;
 
-	ret = hns_mac_get_sfp_prsnt(mac_cb, &sfp_prsnt);
+	ret = mac_cb->dsaf_dev->misc_op->get_sfp_prsnt(mac_cb, &sfp_prsnt);
 	if (!ret)
 		*link_status = *link_status && sfp_prsnt;
 
@@ -512,7 +512,7 @@ void hns_mac_stop(struct hns_mac_cb *mac_cb)
 
 	mac_ctrl_drv->mac_en_flg = 0;
 	mac_cb->link = 0;
-	cpld_led_reset(mac_cb);
+	mac_cb->dsaf_dev->misc_op->cpld_reset_led(mac_cb);
 }
 
 /**
@@ -804,7 +804,7 @@ int hns_mac_get_cfg(struct dsaf_device *dsaf_dev, struct hns_mac_cb *mac_cb)
 	else
 		mac_cb->mac_type = HNAE_PORT_DEBUG;
 
-	mac_cb->phy_if = hns_mac_get_phy_if(mac_cb);
+	mac_cb->phy_if = dsaf_dev->misc_op->get_phy_if(mac_cb);
 
 	ret = hns_mac_get_mode(mac_cb->phy_if);
 	if (ret < 0) {
@@ -819,7 +819,7 @@ int hns_mac_get_cfg(struct dsaf_device *dsaf_dev, struct hns_mac_cb *mac_cb)
 	if (ret)
 		return ret;
 
-	cpld_led_reset(mac_cb);
+	mac_cb->dsaf_dev->misc_op->cpld_reset_led(mac_cb);
 	mac_cb->vaddr = hns_mac_get_vaddr(dsaf_dev, mac_cb, mac_mode_idx);
 
 	return 0;
@@ -906,7 +906,7 @@ void hns_mac_uninit(struct dsaf_device *dsaf_dev)
 	int max_port_num = hns_mac_get_max_port_num(dsaf_dev);
 
 	for (i = 0; i < max_port_num; i++) {
-		cpld_led_reset(dsaf_dev->mac_cb[i]);
+		dsaf_dev->misc_op->cpld_reset_led(dsaf_dev->mac_cb[i]);
 		dsaf_dev->mac_cb[i] = NULL;
 	}
 }
@@ -989,7 +989,7 @@ void hns_set_led_opt(struct hns_mac_cb *mac_cb)
 		nic_data = 0;
 	mac_cb->txpkt_for_led = mac_cb->hw_stats.tx_good_pkts;
 	mac_cb->rxpkt_for_led = mac_cb->hw_stats.rx_good_pkts;
-	hns_cpld_set_led(mac_cb, (int)mac_cb->link,
+	mac_cb->dsaf_dev->misc_op->cpld_set_led(mac_cb, (int)mac_cb->link,
 			 mac_cb->speed, nic_data);
 }
 
@@ -999,5 +999,5 @@ int hns_cpld_led_set_id(struct hns_mac_cb *mac_cb,
 	if (!mac_cb || !mac_cb->cpld_ctrl)
 		return 0;
 
-	return cpld_set_led_id(mac_cb, status);
+	return mac_cb->dsaf_dev->misc_op->cpld_set_led_id(mac_cb, status);
 }
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
index 89b49d7..05a6e8f 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
@@ -448,8 +448,6 @@ int hns_mac_set_pauseparam(struct hns_mac_cb *mac_cb, u32 rx_en, u32 tx_en);
 int hns_mac_set_mtu(struct hns_mac_cb *mac_cb, u32 new_mtu);
 int hns_mac_get_port_info(struct hns_mac_cb *mac_cb,
 			  u8 *auto_neg, u16 *speed, u8 *duplex);
-phy_interface_t hns_mac_get_phy_if(struct hns_mac_cb *mac_cb);
-int hns_mac_config_sds_loopback(struct hns_mac_cb *mac_cb, u8 en);
 int hns_mac_config_mac_loopback(struct hns_mac_cb *mac_cb,
 				enum hnae_loop loop, int en);
 void hns_mac_update_stats(struct hns_mac_cb *mac_cb);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 9afc5e6..28bde08 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -24,6 +24,7 @@
 #include "hns_dsaf_main.h"
 #include "hns_dsaf_ppe.h"
 #include "hns_dsaf_rcb.h"
+#include "hns_dsaf_misc.h"
 
 const char *g_dsaf_mode_match[DSAF_MODE_MAX] = {
 	[DSAF_MODE_DISABLE_2PORT_64VM] = "2port-64vf",
@@ -174,6 +175,10 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 		goto unmap_base_addr;
 	}
 
+	dsaf_dev->misc_op = hns_misc_op_get(dsaf_dev);
+	if (!dsaf_dev->misc_op)
+		return -ENOMEM;
+
 	if (!dma_set_mask_and_coherent(dsaf_dev->dev, DMA_BIT_MASK(64ULL)))
 		dev_dbg(dsaf_dev->dev, "set mask to 64bit\n");
 	else
@@ -1296,9 +1301,9 @@ static int hns_dsaf_init_hw(struct dsaf_device *dsaf_dev)
 	dev_dbg(dsaf_dev->dev,
 		"hns_dsaf_init_hw begin %s !\n", dsaf_dev->ae_dev.name);
 
-	hns_dsaf_rst(dsaf_dev, 0);
+	dsaf_dev->misc_op->dsaf_reset(dsaf_dev, 0);
 	mdelay(10);
-	hns_dsaf_rst(dsaf_dev, 1);
+	dsaf_dev->misc_op->dsaf_reset(dsaf_dev, 1);
 
 	hns_dsaf_comm_init(dsaf_dev);
 
@@ -1326,7 +1331,7 @@ static int hns_dsaf_init_hw(struct dsaf_device *dsaf_dev)
 static void hns_dsaf_remove_hw(struct dsaf_device *dsaf_dev)
 {
 	/*reset*/
-	hns_dsaf_rst(dsaf_dev, 0);
+	dsaf_dev->misc_op->dsaf_reset(dsaf_dev, 0);
 }
 
 /**
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
index f0502ba..2e55b3c 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
@@ -268,6 +268,27 @@ struct dsaf_int_stat {
 
 };
 
+struct dsaf_misc_op {
+	void (*cpld_set_led)(struct hns_mac_cb *mac_cb, int link_status,
+			     u16 speed, int data);
+	void (*cpld_reset_led)(struct hns_mac_cb *mac_cb);
+	int (*cpld_set_led_id)(struct hns_mac_cb *mac_cb,
+			       enum hnae_led_state status);
+	/* reset seris function, it will be reset if the dereseet is 0 */
+	void (*dsaf_reset)(struct dsaf_device *dsaf_dev, bool dereset);
+	void (*xge_srst)(struct dsaf_device *dsaf_dev, u32 port, bool dereset);
+	void (*xge_core_srst)(struct dsaf_device *dsaf_dev, u32 port,
+			      bool dereset);
+	void (*ge_srst)(struct dsaf_device *dsaf_dev, u32 port, bool dereset);
+	void (*ppe_srst)(struct dsaf_device *dsaf_dev, u32 port, bool dereset);
+	void (*ppe_comm_srst)(struct dsaf_device *dsaf_dev, bool dereset);
+
+	phy_interface_t (*get_phy_if)(struct hns_mac_cb *mac_cb);
+	int (*get_sfp_prsnt)(struct hns_mac_cb *mac_cb, int *sfp_prsnt);
+
+	int (*cfg_serdes_loopback)(struct hns_mac_cb *mac_cb, bool en);
+};
+
 /* Dsaf device struct define ,and mac ->  dsaf */
 struct dsaf_device {
 	struct device *dev;
@@ -292,6 +313,7 @@ struct dsaf_device {
 	struct ppe_common_cb *ppe_common[DSAF_COMM_DEV_NUM];
 	struct rcb_common_cb *rcb_common[DSAF_COMM_DEV_NUM];
 	struct hns_mac_cb *mac_cb[DSAF_MAX_PORT_NUM];
+	struct dsaf_misc_op *misc_op;
 
 	struct dsaf_hw_stats hw_stats[DSAF_NODE_NUM];
 	struct dsaf_int_stat int_stat;
@@ -388,22 +410,11 @@ int hns_dsaf_get_mac_entry_by_index(
 	u16 entry_index,
 	struct dsaf_drv_mac_multi_dest_entry *mac_entry);
 
-void hns_dsaf_rst(struct dsaf_device *dsaf_dev, u32 val);
-
-void hns_ppe_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val);
-
-void hns_ppe_com_srst(struct ppe_common_cb *ppe_common, u32 val);
-
 void hns_dsaf_fix_mac_mode(struct hns_mac_cb *mac_cb);
 
 int hns_dsaf_ae_init(struct dsaf_device *dsaf_dev);
 void hns_dsaf_ae_uninit(struct dsaf_device *dsaf_dev);
 
-void hns_dsaf_xge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val);
-void hns_dsaf_ge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val);
-void hns_dsaf_xge_core_srst_by_port(struct dsaf_device *dsaf_dev,
-				    u32 port, u32 val);
-
 void hns_dsaf_update_stats(struct dsaf_device *dsaf_dev, u32 inode_num);
 
 int hns_dsaf_get_sset_count(int stringset);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
index a843a86..e1c3e0d 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
@@ -32,8 +32,8 @@ static u32 dsaf_read_sub(struct dsaf_device *dsaf_dev, u32 reg)
 	return ret;
 }
 
-void hns_cpld_set_led(struct hns_mac_cb *mac_cb, int link_status,
-		      u16 speed, int data)
+static void hns_cpld_set_led(struct hns_mac_cb *mac_cb, int link_status,
+			     u16 speed, int data)
 {
 	int speed_reg = 0;
 	u8 value;
@@ -71,7 +71,7 @@ void hns_cpld_set_led(struct hns_mac_cb *mac_cb, int link_status,
 	}
 }
 
-void cpld_led_reset(struct hns_mac_cb *mac_cb)
+static void cpld_led_reset(struct hns_mac_cb *mac_cb)
 {
 	if (!mac_cb || !mac_cb->cpld_ctrl)
 		return;
@@ -81,8 +81,8 @@ void cpld_led_reset(struct hns_mac_cb *mac_cb)
 	mac_cb->cpld_led_value = CPLD_LED_DEFAULT_VALUE;
 }
 
-int cpld_set_led_id(struct hns_mac_cb *mac_cb,
-		    enum hnae_led_state status)
+static int cpld_set_led_id(struct hns_mac_cb *mac_cb,
+			   enum hnae_led_state status)
 {
 	switch (status) {
 	case HNAE_LED_ACTIVE:
@@ -109,12 +109,12 @@ int cpld_set_led_id(struct hns_mac_cb *mac_cb,
 
 #define RESET_REQ_OR_DREQ 1
 
-void hns_dsaf_rst(struct dsaf_device *dsaf_dev, u32 val)
+static void hns_dsaf_rst(struct dsaf_device *dsaf_dev, bool dereset)
 {
 	u32 xbar_reg_addr;
 	u32 nt_reg_addr;
 
-	if (!val) {
+	if (!dereset) {
 		xbar_reg_addr = DSAF_SUB_SC_XBAR_RESET_REQ_REG;
 		nt_reg_addr = DSAF_SUB_SC_NT_RESET_REQ_REG;
 	} else {
@@ -126,7 +126,8 @@ void hns_dsaf_rst(struct dsaf_device *dsaf_dev, u32 val)
 	dsaf_write_sub(dsaf_dev, nt_reg_addr, RESET_REQ_OR_DREQ);
 }
 
-void hns_dsaf_xge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
+static void hns_dsaf_xge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port,
+				      bool dereset)
 {
 	u32 reg_val = 0;
 	u32 reg_addr;
@@ -137,7 +138,7 @@ void hns_dsaf_xge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
 	reg_val |= RESET_REQ_OR_DREQ;
 	reg_val |= 0x2082082 << dsaf_dev->mac_cb[port]->port_rst_off;
 
-	if (val == 0)
+	if (!dereset)
 		reg_addr = DSAF_SUB_SC_XGE_RESET_REQ_REG;
 	else
 		reg_addr = DSAF_SUB_SC_XGE_RESET_DREQ_REG;
@@ -145,8 +146,8 @@ void hns_dsaf_xge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
 	dsaf_write_sub(dsaf_dev, reg_addr, reg_val);
 }
 
-void hns_dsaf_xge_core_srst_by_port(struct dsaf_device *dsaf_dev,
-				    u32 port, u32 val)
+static void hns_dsaf_xge_core_srst_by_port(struct dsaf_device *dsaf_dev,
+					   u32 port, bool dereset)
 {
 	u32 reg_val = 0;
 	u32 reg_addr;
@@ -157,7 +158,7 @@ void hns_dsaf_xge_core_srst_by_port(struct dsaf_device *dsaf_dev,
 	reg_val |= XGMAC_TRX_CORE_SRST_M
 		<< dsaf_dev->mac_cb[port]->port_rst_off;
 
-	if (val == 0)
+	if (!dereset)
 		reg_addr = DSAF_SUB_SC_XGE_RESET_REQ_REG;
 	else
 		reg_addr = DSAF_SUB_SC_XGE_RESET_DREQ_REG;
@@ -165,7 +166,8 @@ void hns_dsaf_xge_core_srst_by_port(struct dsaf_device *dsaf_dev,
 	dsaf_write_sub(dsaf_dev, reg_addr, reg_val);
 }
 
-void hns_dsaf_ge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
+static void hns_dsaf_ge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port,
+				     bool dereset)
 {
 	u32 reg_val_1;
 	u32 reg_val_2;
@@ -183,7 +185,7 @@ void hns_dsaf_ge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
 		else
 			reg_val_2  = 0x2082082 << port_rst_off;
 
-		if (val == 0) {
+		if (!dereset) {
 			dsaf_write_sub(dsaf_dev, DSAF_SUB_SC_GE_RESET_REQ1_REG,
 				       reg_val_1);
 
@@ -200,7 +202,7 @@ void hns_dsaf_ge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
 		reg_val_1 = 0x15540 << dsaf_dev->reset_offset;
 		reg_val_2 = 0x100 << dsaf_dev->reset_offset;
 
-		if (val == 0) {
+		if (!dereset) {
 			dsaf_write_sub(dsaf_dev, DSAF_SUB_SC_GE_RESET_REQ1_REG,
 				       reg_val_1);
 
@@ -216,14 +218,15 @@ void hns_dsaf_ge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
 	}
 }
 
-void hns_ppe_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
+static void hns_ppe_srst_by_port(struct dsaf_device *dsaf_dev, u32 port,
+				 bool dereset)
 {
 	u32 reg_val = 0;
 	u32 reg_addr;
 
 	reg_val |= RESET_REQ_OR_DREQ <<	dsaf_dev->mac_cb[port]->port_rst_off;
 
-	if (val == 0)
+	if (!dereset)
 		reg_addr = DSAF_SUB_SC_PPE_RESET_REQ_REG;
 	else
 		reg_addr = DSAF_SUB_SC_PPE_RESET_DREQ_REG;
@@ -231,15 +234,14 @@ void hns_ppe_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
 	dsaf_write_sub(dsaf_dev, reg_addr, reg_val);
 }
 
-void hns_ppe_com_srst(struct ppe_common_cb *ppe_common, u32 val)
+static void hns_ppe_com_srst(struct dsaf_device *dsaf_dev, bool dereset)
 {
-	struct dsaf_device *dsaf_dev = ppe_common->dsaf_dev;
 	u32 reg_val;
 	u32 reg_addr;
 
 	if (!HNS_DSAF_IS_DEBUG(dsaf_dev)) {
 		reg_val = RESET_REQ_OR_DREQ;
-		if (val == 0)
+		if (!dereset)
 			reg_addr = DSAF_SUB_SC_RCB_PPE_COM_RESET_REQ_REG;
 		else
 			reg_addr = DSAF_SUB_SC_RCB_PPE_COM_RESET_DREQ_REG;
@@ -247,7 +249,7 @@ void hns_ppe_com_srst(struct ppe_common_cb *ppe_common, u32 val)
 	} else {
 		reg_val = 0x100 << dsaf_dev->reset_offset;
 
-		if (val == 0)
+		if (!dereset)
 			reg_addr = DSAF_SUB_SC_PPE_RESET_REQ_REG;
 		else
 			reg_addr = DSAF_SUB_SC_PPE_RESET_DREQ_REG;
@@ -261,7 +263,7 @@ void hns_ppe_com_srst(struct ppe_common_cb *ppe_common, u32 val)
  * @mac_cb: mac control block
  * retuen phy interface
  */
-phy_interface_t hns_mac_get_phy_if(struct hns_mac_cb *mac_cb)
+static phy_interface_t hns_mac_get_phy_if(struct hns_mac_cb *mac_cb)
 {
 	u32 mode;
 	u32 reg;
@@ -309,7 +311,7 @@ int hns_mac_get_sfp_prsnt(struct hns_mac_cb *mac_cb, int *sfp_prsnt)
  * @mac_cb: mac control block
  * retuen 0 == success
  */
-int hns_mac_config_sds_loopback(struct hns_mac_cb *mac_cb, u8 en)
+static int hns_mac_config_sds_loopback(struct hns_mac_cb *mac_cb, bool en)
 {
 	/* port 0-3 hilink4 base is serdes_vaddr + 0x00280000
 	 * port 4-7 hilink3 base is serdes_vaddr + 0x00200000
@@ -343,11 +345,38 @@ int hns_mac_config_sds_loopback(struct hns_mac_cb *mac_cb, u8 en)
 	if (mac_cb->serdes_ctrl) {
 		u32 origin = dsaf_read_syscon(mac_cb->serdes_ctrl, reg_offset);
 
-		dsaf_set_field(origin, 1ull << 10, 10, !!en);
+		dsaf_set_field(origin, 1ull << 10, 10, en);
 		dsaf_write_syscon(mac_cb->serdes_ctrl, reg_offset, origin);
 	} else {
-		dsaf_set_reg_field(base_addr, reg_offset, 1ull << 10, 10, !!en);
+		dsaf_set_reg_field(base_addr, reg_offset, 1ull << 10, 10, en);
 	}
 
 	return 0;
 }
+
+struct dsaf_misc_op *hns_misc_op_get(struct dsaf_device *dsaf_dev)
+{
+	struct dsaf_misc_op *misc_op;
+
+	misc_op = devm_kzalloc(dsaf_dev->dev, sizeof(*misc_op), GFP_KERNEL);
+	if (!misc_op)
+		return NULL;
+
+	misc_op->cpld_set_led = hns_cpld_set_led;
+	misc_op->cpld_reset_led = cpld_led_reset;
+	misc_op->cpld_set_led_id = cpld_set_led_id;
+
+	misc_op->dsaf_reset = hns_dsaf_rst;
+	misc_op->xge_srst = hns_dsaf_xge_srst_by_port;
+	misc_op->xge_core_srst = hns_dsaf_xge_core_srst_by_port;
+	misc_op->ge_srst = hns_dsaf_ge_srst_by_port;
+	misc_op->ppe_srst = hns_ppe_srst_by_port;
+	misc_op->ppe_comm_srst = hns_ppe_com_srst;
+
+	misc_op->get_phy_if = hns_mac_get_phy_if;
+	misc_op->get_sfp_prsnt = hns_mac_get_sfp_prsnt;
+
+	misc_op->cfg_serdes_loopback = hns_mac_config_sds_loopback;
+
+	return (void *)misc_op;
+}
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.h
index 419f07a..f06bb03 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.h
@@ -33,11 +33,6 @@
 #define DSAF_LED_DATA_B 4
 #define DSAF_LED_ANCHOR_B 5
 
-void hns_cpld_set_led(struct hns_mac_cb *mac_cb, int link_status,
-		      u16 speed, int data);
-void cpld_led_reset(struct hns_mac_cb *mac_cb);
-int cpld_set_led_id(struct hns_mac_cb *mac_cb,
-		    enum hnae_led_state status);
-int hns_mac_get_sfp_prsnt(struct hns_mac_cb *mac_cb, int *sfp_prsnt);
+struct dsaf_misc_op *hns_misc_op_get(struct dsaf_device *dsaf_dev);
 
 #endif
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
index 8cd151a..ff8b6a4 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
@@ -112,7 +112,6 @@ void hns_ppe_common_free_cfg(struct dsaf_device *dsaf_dev, u32 comm_index)
 static void __iomem *hns_ppe_get_iobase(struct ppe_common_cb *ppe_common,
 					int ppe_idx)
 {
-
 	return ppe_common->dsaf_dev->ppe_base + ppe_idx * PPE_REG_OFFSET;
 }
 
@@ -200,11 +199,12 @@ static void hns_ppe_set_port_mode(struct hns_ppe_cb *ppe_cb,
 static int hns_ppe_common_init_hw(struct ppe_common_cb *ppe_common)
 {
 	enum ppe_qid_mode qid_mode;
-	enum dsaf_mode dsaf_mode = ppe_common->dsaf_dev->dsaf_mode;
+	struct dsaf_device *dsaf_dev = ppe_common->dsaf_dev;
+	enum dsaf_mode dsaf_mode = dsaf_dev->dsaf_mode;
 
-	hns_ppe_com_srst(ppe_common, 0);
+	dsaf_dev->misc_op->ppe_comm_srst(dsaf_dev, 0);
 	mdelay(100);
-	hns_ppe_com_srst(ppe_common, 1);
+	dsaf_dev->misc_op->ppe_comm_srst(dsaf_dev, 1);
 	mdelay(100);
 
 	if (ppe_common->ppe_mode == PPE_COMMON_MODE_SERVICE) {
@@ -288,9 +288,9 @@ static void hns_ppe_init_hw(struct hns_ppe_cb *ppe_cb)
 	/* get default RSS key */
 	netdev_rss_key_fill(ppe_cb->rss_key, HNS_PPEV2_RSS_KEY_SIZE);
 
-	hns_ppe_srst_by_port(dsaf_dev, port, 0);
+	dsaf_dev->misc_op->ppe_srst(dsaf_dev, port, 0);
 	mdelay(10);
-	hns_ppe_srst_by_port(dsaf_dev, port, 1);
+	dsaf_dev->misc_op->ppe_srst(dsaf_dev, port, 1);
 
 	/* clr and msk except irq*/
 	hns_ppe_exc_irq_en(ppe_cb, 0);
@@ -328,10 +328,11 @@ static void hns_ppe_init_hw(struct hns_ppe_cb *ppe_cb)
 static void hns_ppe_uninit_hw(struct hns_ppe_cb *ppe_cb)
 {
 	u32 port;
+	struct dsaf_device *dsaf_dev = ppe_cb->ppe_common_cb->dsaf_dev;
 
 	if (ppe_cb->ppe_common_cb) {
 		port = ppe_cb->index;
-		hns_ppe_srst_by_port(ppe_cb->ppe_common_cb->dsaf_dev, port, 0);
+		dsaf_dev->misc_op->ppe_srst(dsaf_dev, port, 0);
 	}
 }
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
index fd90f37..8f4f0e8 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
@@ -119,7 +119,7 @@ static void hns_xgmac_enable(void *mac_drv, enum mac_commom_mode mode)
 		= (struct dsaf_device *)dev_get_drvdata(drv->dev);
 	u32 port = drv->mac_id;
 
-	hns_dsaf_xge_core_srst_by_port(dsaf_dev, port, 1);
+	dsaf_dev->misc_op->xge_core_srst(dsaf_dev, port, 1);
 	mdelay(10);
 
 	/*enable XGE rX/tX */
@@ -157,7 +157,7 @@ static void hns_xgmac_disable(void *mac_drv, enum mac_commom_mode mode)
 	}
 
 	mdelay(10);
-	hns_dsaf_xge_core_srst_by_port(dsaf_dev, port, 0);
+	dsaf_dev->misc_op->xge_core_srst(dsaf_dev, port, 0);
 }
 
 /**
@@ -198,9 +198,9 @@ static void hns_xgmac_init(void *mac_drv)
 		= (struct dsaf_device *)dev_get_drvdata(drv->dev);
 	u32 port = drv->mac_id;
 
-	hns_dsaf_xge_srst_by_port(dsaf_dev, port, 0);
+	dsaf_dev->misc_op->xge_srst(dsaf_dev, port, 0);
 	mdelay(100);
-	hns_dsaf_xge_srst_by_port(dsaf_dev, port, 1);
+	dsaf_dev->misc_op->xge_srst(dsaf_dev, port, 1);
 
 	mdelay(100);
 	hns_xgmac_exc_irq_en(drv, 0);
@@ -425,7 +425,7 @@ static void hns_xgmac_free(void *mac_drv)
 
 	u32 mac_id = drv->mac_id;
 
-	hns_dsaf_xge_srst_by_port(dsaf_dev, mac_id, 0);
+	dsaf_dev->misc_op->xge_srst(dsaf_dev, mac_id, 0);
 }
 
 /**
-- 
1.9.1

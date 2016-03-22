From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH V2 net 03/10] net: hns: add uc match for debug ports
Date: Tue, 22 Mar 2016 16:06:24 +0800
Message-ID: <1458633991-64313-4-git-send-email-Yisen.Zhuang@huawei.com>
References: <1458633991-64313-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yankejian@huawei.com>, <huangdaode@hisilicon.com>,
	<salil.mehta@huawei.com>, <lisheng011@huawei.com>,
	<lipeng321@huawei.com>, <liguozhu@huawei.com>, <arnd@arndb.de>,
	<sergei.shtylyov@cogentembedded.com>, <xieqianqian@huawei.com>,
	<andrew@lunn.ch>, <ivecera@redhat.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458633991-64313-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kejian Yan <yankejian@huawei.com>

Debug ports receives lots of packets with dest mac addr does not match
local mac addr, because the filter is close, and it does not drop the
useless packets. This patch adds ON/OFF switch of filtering the packets
whose dest mac addr do not match the local addr in  mac table. And the
switch is ON in initialization.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Peng Li <lipeng321@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
change log:
 PATCH v2:
  - fix the comments like unnecessary casts

 PATCH v1:
  - first submit

  Link: https://lkml.org/lkml/2016/3/21/224
---
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |  3 +++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c | 28 +++++++++++++++++++++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  |  8 +++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h  |  4 +++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |  2 ++
 5 files changed, 43 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index 90352d6..a7427b8 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -420,7 +420,10 @@ static int hns_ae_set_autoneg(struct hnae_handle *handle, u8 enable)
 
 static void hns_ae_set_promisc_mode(struct hnae_handle *handle, u32 en)
 {
+	struct hns_mac_cb *mac_cb = hns_get_mac_cb(handle);
+
 	hns_dsaf_set_promisc_mode(hns_ae_get_dsaf_dev(handle->dev), en);
+	hns_mac_set_promisc(mac_cb, (u8)!!en);
 }
 
 static int hns_ae_get_autoneg(struct hnae_handle *handle)
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
index b8517b0..b8cf0e4 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
@@ -290,6 +290,24 @@ static int hns_gmac_adjust_link(void *mac_drv, enum mac_speed speed,
 	return 0;
 }
 
+static void hns_gmac_set_uc_match(void *mac_drv, u16 en)
+{
+	struct mac_driver *drv = mac_drv;
+
+	dsaf_set_dev_bit(drv, GMAC_REC_FILT_CONTROL_REG,
+			 GMAC_UC_MATCH_EN_B, !en);
+	dsaf_set_dev_bit(drv, GMAC_STATION_ADDR_HIGH_2_REG,
+			 GMAC_ADDR_EN_B, !en);
+}
+
+static void hns_gmac_set_promisc(void *mac_drv, u8 en)
+{
+	struct mac_driver *drv = mac_drv;
+
+	if (drv->mac_cb->mac_type == HNAE_PORT_DEBUG)
+		hns_gmac_set_uc_match(mac_drv, en);
+}
+
 static void hns_gmac_init(void *mac_drv)
 {
 	u32 port;
@@ -305,6 +323,8 @@ static void hns_gmac_init(void *mac_drv)
 	mdelay(10);
 	hns_gmac_disable(mac_drv, MAC_COMM_MODE_RX_AND_TX);
 	hns_gmac_tx_loop_pkt_dis(mac_drv);
+	if (drv->mac_cb->mac_type == HNAE_PORT_DEBUG)
+		hns_gmac_set_uc_match(mac_drv, 0);
 }
 
 void hns_gmac_update_stats(void *mac_drv)
@@ -407,8 +427,13 @@ static void hns_gmac_set_mac_addr(void *mac_drv, char *mac_addr)
 
 		u32 low_val = mac_addr[5] | (mac_addr[4] << 8)
 			| (mac_addr[3] << 16) | (mac_addr[2] << 24);
+
+		u32 val = dsaf_read_dev(drv, GMAC_STATION_ADDR_HIGH_2_REG);
+		u32 sta_addr_en = dsaf_get_bit(val, GMAC_ADDR_EN_B);
+
 		dsaf_write_dev(drv, GMAC_STATION_ADDR_LOW_2_REG, low_val);
-		dsaf_write_dev(drv, GMAC_STATION_ADDR_HIGH_2_REG, high_val);
+		dsaf_write_dev(drv, GMAC_STATION_ADDR_HIGH_2_REG,
+			       high_val | (sta_addr_en << GMAC_ADDR_EN_B));
 	}
 }
 
@@ -699,6 +724,7 @@ void *hns_gmac_config(struct hns_mac_cb *mac_cb, struct mac_params *mac_param)
 	mac_drv->get_sset_count = hns_gmac_get_sset_count;
 	mac_drv->get_strings = hns_gmac_get_strings;
 	mac_drv->update_stats = hns_gmac_update_stats;
+	mac_drv->set_promiscuous = hns_gmac_set_promisc;
 
 	return (void *)mac_drv;
 }
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index 5ef0e96..138737d 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -861,6 +861,14 @@ int hns_mac_get_sset_count(struct hns_mac_cb *mac_cb, int stringset)
 	return mac_ctrl_drv->get_sset_count(stringset);
 }
 
+void hns_mac_set_promisc(struct hns_mac_cb *mac_cb, u8 en)
+{
+	struct mac_driver *mac_ctrl_drv = hns_mac_get_drv(mac_cb);
+
+	if (mac_ctrl_drv->set_promiscuous)
+		mac_ctrl_drv->set_promiscuous(mac_ctrl_drv, en);
+}
+
 int hns_mac_get_regs_count(struct hns_mac_cb *mac_cb)
 {
 	struct mac_driver *mac_ctrl_drv = hns_mac_get_drv(mac_cb);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
index 0b05219..0f60968 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
@@ -365,7 +365,7 @@ struct mac_driver {
 	/*config rx pause enable*/
 	void (*set_rx_ignore_pause_frames)(void *mac_drv, u32 enable);
 	/* config rx mode for promiscuous*/
-	int (*set_promiscuous)(void *mac_drv, u8 enable);
+	void (*set_promiscuous)(void *mac_drv, u8 enable);
 	/* get mac id */
 	void (*mac_get_id)(void *mac_drv, u8 *mac_id);
 	void (*mac_pausefrm_cfg)(void *mac_drv, u32 rx_en, u32 tx_en);
@@ -453,4 +453,6 @@ int hns_mac_get_regs_count(struct hns_mac_cb *mac_cb);
 void hns_set_led_opt(struct hns_mac_cb *mac_cb);
 int hns_cpld_led_set_id(struct hns_mac_cb *mac_cb,
 			enum hnae_led_state status);
+void hns_mac_set_promisc(struct hns_mac_cb *mac_cb, u8 en);
+
 #endif /* _HNS_DSAF_MAC_H */
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index 60d695d..bf62687 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -922,6 +922,8 @@
 #define GMAC_LP_REG_CF2MI_LP_EN_B	2
 
 #define GMAC_MODE_CHANGE_EB_B	0
+#define GMAC_UC_MATCH_EN_B	0
+#define GMAC_ADDR_EN_B		16
 
 #define GMAC_RECV_CTRL_STRIP_PAD_EN_B	3
 #define GMAC_RECV_CTRL_RUNT_PKT_EN_B	4
-- 
1.9.1

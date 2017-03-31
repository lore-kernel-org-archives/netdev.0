From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V3 net-next 03/18] net: hns: Optimize the code for GMAC pad and crc Config
Date: Fri, 31 Mar 2017 18:48:37 +0100
Message-ID: <20170331174852.13600-4-salil.mehta@huawei.com>
References: <20170331174852.13600-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        lipeng <lipeng321@huawei.com>,
        JinchuanTian <tianjinchuan1@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170331174852.13600-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: lipeng <lipeng321@huawei.com>

This patch optimises the init configuration code leg
for gmac pad and crc set interface.

Signed-off-by: lipeng <lipeng321@huawei.com>
Signed-off-by: JinchuanTian <tianjinchuan1@huawei.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c | 36 ++++++++++------------
 1 file changed, 16 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
index a8dbe00..723f3ae 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
@@ -148,6 +148,17 @@ static void hns_gmac_config_max_frame_length(void *mac_drv, u16 newval)
 			   GMAC_MAX_FRM_SIZE_S, newval);
 }
 
+static void hns_gmac_config_pad_and_crc(void *mac_drv, u8 newval)
+{
+	u32 tx_ctrl;
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	tx_ctrl = dsaf_read_dev(drv, GMAC_TRANSMIT_CONTROL_REG);
+	dsaf_set_bit(tx_ctrl, GMAC_TX_PAD_EN_B, !!newval);
+	dsaf_set_bit(tx_ctrl, GMAC_TX_CRC_ADD_B, !!newval);
+	dsaf_write_dev(drv, GMAC_TRANSMIT_CONTROL_REG, tx_ctrl);
+}
+
 static void hns_gmac_config_an_mode(void *mac_drv, u8 newval)
 {
 	struct mac_driver *drv = (struct mac_driver *)mac_drv;
@@ -250,7 +261,6 @@ static void hns_gmac_get_pausefrm_cfg(void *mac_drv, u32 *rx_pause_en,
 static int hns_gmac_adjust_link(void *mac_drv, enum mac_speed speed,
 				u32 full_duplex)
 {
-	u32 tx_ctrl;
 	struct mac_driver *drv = (struct mac_driver *)mac_drv;
 
 	dsaf_set_dev_bit(drv, GMAC_DUPLEX_TYPE_REG,
@@ -279,14 +289,6 @@ static int hns_gmac_adjust_link(void *mac_drv, enum mac_speed speed,
 		return -EINVAL;
 	}
 
-	tx_ctrl = dsaf_read_dev(drv, GMAC_TRANSMIT_CONTROL_REG);
-	dsaf_set_bit(tx_ctrl, GMAC_TX_PAD_EN_B, 1);
-	dsaf_set_bit(tx_ctrl, GMAC_TX_CRC_ADD_B, 1);
-	dsaf_write_dev(drv, GMAC_TRANSMIT_CONTROL_REG, tx_ctrl);
-
-	dsaf_set_dev_bit(drv, GMAC_MODE_CHANGE_EN_REG,
-			 GMAC_MODE_CHANGE_EB_B, 1);
-
 	return 0;
 }
 
@@ -326,6 +328,11 @@ static void hns_gmac_init(void *mac_drv)
 	if (drv->mac_cb->mac_type == HNAE_PORT_DEBUG)
 		hns_gmac_set_uc_match(mac_drv, 0);
 
+	hns_gmac_config_pad_and_crc(mac_drv, 1);
+
+	dsaf_set_dev_bit(drv, GMAC_MODE_CHANGE_EN_REG,
+			 GMAC_MODE_CHANGE_EB_B, 1);
+
 	/* reduce gmac tx water line to avoid gmac hang-up
 	 * in speed 100M and duplex half.
 	 */
@@ -459,17 +466,6 @@ static int hns_gmac_config_loopback(void *mac_drv, enum hnae_loop loop_mode,
 	return 0;
 }
 
-static void hns_gmac_config_pad_and_crc(void *mac_drv, u8 newval)
-{
-	u32 tx_ctrl;
-	struct mac_driver *drv = (struct mac_driver *)mac_drv;
-
-	tx_ctrl = dsaf_read_dev(drv, GMAC_TRANSMIT_CONTROL_REG);
-	dsaf_set_bit(tx_ctrl, GMAC_TX_PAD_EN_B, !!newval);
-	dsaf_set_bit(tx_ctrl, GMAC_TX_CRC_ADD_B, !!newval);
-	dsaf_write_dev(drv, GMAC_TRANSMIT_CONTROL_REG, tx_ctrl);
-}
-
 static void hns_gmac_get_id(void *mac_drv, u8 *mac_id)
 {
 	struct mac_driver *drv = (struct mac_driver *)mac_drv;
-- 
2.7.4

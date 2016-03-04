From: Daode Huang <huangdaode@hisilicon.com>
Subject: [PATCH net 4/6] net: hns: adds uc match for debug port
Date: Fri, 4 Mar 2016 09:09:56 +0800
Message-ID: <1457053798-93513-5-git-send-email-huangdaode@hisilicon.com>
References: <1457053798-93513-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<linuxarm@huawei.com>, <salil.mehta@huawei.com>,
	<huangdaode@hisilicon.com>, <kenneth-lee-2012@foxmail.com>,
	<xuwei5@hisilicon.com>, <lisheng011@huawei.com>,
	<yankejian@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457053798-93513-1-git-send-email-huangdaode@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds uc match for debug port by:
1)Enables uc match of debug port when initializing gmac
2)Enables uc match of mac address register2

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Signed-off-by: lipeng <lipeng321@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c | 18 +++++++++++++++++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |  2 ++
 2 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
index b8517b0..2591a51 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
@@ -290,6 +290,16 @@ static int hns_gmac_adjust_link(void *mac_drv, enum mac_speed speed,
 	return 0;
 }
 
+static void hns_gmac_set_uc_match(void *mac_drv, u16 en)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	dsaf_set_dev_bit(drv, GMAC_REC_FILT_CONTROL_REG,
+			 GMAC_UC_MATCH_EN_B, !en);
+	dsaf_set_dev_bit(drv, GMAC_STATION_ADDR_HIGH_2_REG,
+			 GMAC_ADDR_EN_B, !en);
+}
+
 static void hns_gmac_init(void *mac_drv)
 {
 	u32 port;
@@ -305,6 +315,8 @@ static void hns_gmac_init(void *mac_drv)
 	mdelay(10);
 	hns_gmac_disable(mac_drv, MAC_COMM_MODE_RX_AND_TX);
 	hns_gmac_tx_loop_pkt_dis(mac_drv);
+	if (drv->mac_cb->mac_type == HNAE_PORT_DEBUG)
+		hns_gmac_set_uc_match(mac_drv, 0);
 }
 
 void hns_gmac_update_stats(void *mac_drv)
@@ -407,8 +419,12 @@ static void hns_gmac_set_mac_addr(void *mac_drv, char *mac_addr)
 
 		u32 low_val = mac_addr[5] | (mac_addr[4] << 8)
 			| (mac_addr[3] << 16) | (mac_addr[2] << 24);
+
+		u32 val = dsaf_read_dev(drv, GMAC_STATION_ADDR_HIGH_2_REG);
+		u32 sta_addr_en = dsaf_get_bit(val, GMAC_ADDR_EN_B);
 		dsaf_write_dev(drv, GMAC_STATION_ADDR_LOW_2_REG, low_val);
-		dsaf_write_dev(drv, GMAC_STATION_ADDR_HIGH_2_REG, high_val);
+		dsaf_write_dev(drv, GMAC_STATION_ADDR_HIGH_2_REG,
+			       high_val | (sta_addr_en << GMAC_ADDR_EN_B));
 	}
 }
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index f0c4f9b..d8c49b6 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -917,6 +917,8 @@
 #define GMAC_LP_REG_CF2MI_LP_EN_B	2
 
 #define GMAC_MODE_CHANGE_EB_B	0
+#define GMAC_UC_MATCH_EN_B	0
+#define GMAC_ADDR_EN_B		16
 
 #define GMAC_RECV_CTRL_STRIP_PAD_EN_B	3
 #define GMAC_RECV_CTRL_RUNT_PKT_EN_B	4
-- 
1.9.1

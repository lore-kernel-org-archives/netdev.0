From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net 7/7] net: hns: bug fix about getting hilink status for HNS v2
Date: Thu, 24 Mar 2016 19:08:06 +0800
Message-ID: <1458817686-159708-8-git-send-email-Yisen.Zhuang@huawei.com>
References: <1458817686-159708-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yankejian@huawei.com>, <huangdaode@hisilicon.com>,
	<salil.mehta@huawei.com>, <lisheng011@huawei.com>,
	<lipeng321@huawei.com>, <liguozhu@huawei.com>,
	<xieqianqian@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458817686-159708-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sheng Li <lisheng011@huawei.com>

The hilink status reg in HNS V2 is different from HNS v1. In HNS V2, It
distinguishes differnt lane status according to the bit-field of the reg.
As is shown below:
[0:0] ---> lane0
[1:1] ---> lane1
...

But the current driver reads the reg to get the hilink status ONLY
concidering HNS V1 situation. Here is a patch to support both of them.

Signed-off-by: Sheng Li <lisheng011@huawei.com>
Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 40 ++++++++++++----------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |  2 ++
 2 files changed, 24 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
index 607c3be..e69b022 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
@@ -244,31 +244,35 @@ void hns_ppe_com_srst(struct ppe_common_cb *ppe_common, u32 val)
  */
 phy_interface_t hns_mac_get_phy_if(struct hns_mac_cb *mac_cb)
 {
-	u32 hilink3_mode;
-	u32 hilink4_mode;
+	u32 mode;
+	u32 reg;
+	u32 shift;
+	bool is_ver1 = AE_IS_VER1(mac_cb->dsaf_dev->dsaf_ver);
 	void __iomem *sys_ctl_vaddr = mac_cb->sys_ctl_vaddr;
-	int dev_id = mac_cb->mac_id;
+	int mac_id = mac_cb->mac_id;
 	phy_interface_t phy_if = PHY_INTERFACE_MODE_NA;
 
-	hilink3_mode = dsaf_read_reg(sys_ctl_vaddr, HNS_MAC_HILINK3_REG);
-	hilink4_mode = dsaf_read_reg(sys_ctl_vaddr, HNS_MAC_HILINK4_REG);
-	if (dev_id >= 0 && dev_id <= 3) {
-		if (hilink4_mode == 0)
-			phy_if = PHY_INTERFACE_MODE_SGMII;
-		else
+	if (is_ver1 && (mac_id >= 6 && mac_id <= 7)) {
+		phy_if = PHY_INTERFACE_MODE_SGMII;
+	} else if (mac_id >= 0 && mac_id <= 3) {
+		reg = is_ver1 ? HNS_MAC_HILINK4_REG : HNS_MAC_HILINK4V2_REG;
+		mode = dsaf_read_reg(sys_ctl_vaddr, reg);
+		/* mac_id 0, 1, 2, 3 ---> hilink4 lane 0, 1, 2, 3 */
+		shift = is_ver1 ? 0 : mac_id;
+		if (dsaf_get_bit(mode, shift))
 			phy_if = PHY_INTERFACE_MODE_XGMII;
-	} else if (dev_id >= 4 && dev_id <= 5) {
-		if (hilink3_mode == 0)
-			phy_if = PHY_INTERFACE_MODE_SGMII;
 		else
+			phy_if = PHY_INTERFACE_MODE_SGMII;
+	} else if (mac_id >= 4 && mac_id <= 7) {
+		reg = is_ver1 ? HNS_MAC_HILINK3_REG : HNS_MAC_HILINK3V2_REG;
+		mode = dsaf_read_reg(sys_ctl_vaddr, reg);
+		/* mac_id 4, 5, 6, 7 ---> hilink3 lane 2, 3, 0, 1 */
+		shift = is_ver1 ? 0 : mac_id <= 5 ? mac_id - 2 : mac_id - 6;
+		if (dsaf_get_bit(mode, shift))
 			phy_if = PHY_INTERFACE_MODE_XGMII;
-	} else {
-		phy_if = PHY_INTERFACE_MODE_SGMII;
+		else
+			phy_if = PHY_INTERFACE_MODE_SGMII;
 	}
-
-	dev_dbg(mac_cb->dev,
-		"hilink3_mode=%d, hilink4_mode=%d dev_id=%d, phy_if=%d\n",
-		hilink3_mode, hilink4_mode, dev_id, phy_if);
 	return phy_if;
 }
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index bf62687..e2206f9 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -103,6 +103,8 @@
 /*serdes offset**/
 #define HNS_MAC_HILINK3_REG DSAF_SUB_SC_HILINK3_CRG_CTRL0_REG
 #define HNS_MAC_HILINK4_REG DSAF_SUB_SC_HILINK4_CRG_CTRL0_REG
+#define HNS_MAC_HILINK3V2_REG DSAF_SUB_SC_HILINK3_CRG_CTRL1_REG
+#define HNS_MAC_HILINK4V2_REG DSAF_SUB_SC_HILINK4_CRG_CTRL1_REG
 #define HNS_MAC_LANE0_CTLEDFE_REG 0x000BFFCCULL
 #define HNS_MAC_LANE1_CTLEDFE_REG 0x000BFFBCULL
 #define HNS_MAC_LANE2_CTLEDFE_REG 0x000BFFACULL
-- 
1.9.1

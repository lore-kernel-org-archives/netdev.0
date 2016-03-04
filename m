From: Daode Huang <huangdaode@hisilicon.com>
Subject: [PATCH net 6/6] net: hns: bug fix of getting hilink status
Date: Fri, 4 Mar 2016 09:09:58 +0800
Message-ID: <1457053798-93513-7-git-send-email-huangdaode@hisilicon.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:10803 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932594AbcCDAvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 19:51:10 -0500
In-Reply-To: <1457053798-93513-1-git-send-email-huangdaode@hisilicon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

from Lisheng <lisheng011@huawei.com>

There is some difference in hilink status defination between
v1 and v2 chips.
for v1 chip, all ports connected to the same hilink share the same
hilink status register bit.
but for v2, all ports have separately hilink status register bit. And
the register addr is also changed.
So this patch fixes the bug.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Signed-off-by: Lisheng <lisheng011@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 39 +++++++++++-----------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |  2 ++
 2 files changed, 22 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
index 607c3be..2fa38f1 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
@@ -240,35 +240,36 @@ void hns_ppe_com_srst(struct ppe_common_cb *ppe_common, u32 val)
 /**
  * hns_mac_get_sds_mode - get phy ifterface form serdes mode
  * @mac_cb: mac control block
- * retuen phy interface
+ * return phy interface
  */
 phy_interface_t hns_mac_get_phy_if(struct hns_mac_cb *mac_cb)
 {
-	u32 hilink3_mode;
-	u32 hilink4_mode;
+	u32 reg, mode, shift;
 	void __iomem *sys_ctl_vaddr = mac_cb->sys_ctl_vaddr;
-	int dev_id = mac_cb->mac_id;
+	int mac_id = mac_cb->mac_id;
 	phy_interface_t phy_if = PHY_INTERFACE_MODE_NA;
+	bool is_ver1 = AE_IS_VER1(mac_cb->dsaf_dev->dsaf_ver);
 
-	hilink3_mode = dsaf_read_reg(sys_ctl_vaddr, HNS_MAC_HILINK3_REG);
-	hilink4_mode = dsaf_read_reg(sys_ctl_vaddr, HNS_MAC_HILINK4_REG);
-	if (dev_id >= 0 && dev_id <= 3) {
-		if (hilink4_mode == 0)
-			phy_if = PHY_INTERFACE_MODE_SGMII;
-		else
+	/*for hip05 soc, port6,7 only support ge mode*/
+	if (is_ver1 && (mac_id >= 6 && mac_id <= 7)) {
+		phy_if = PHY_INTERFACE_MODE_SGMII;
+	} else	if (mac_id >= 0 && mac_id <= 3) {
+		reg = is_ver1 ? HNS_MAC_HILINK4_REG : HNS_MAC_HILINK4V2_REG;
+		mode = dsaf_read_reg(sys_ctl_vaddr, reg);
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
+		shift = is_ver1 ? 0 : mac_id - 4;
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
index d8c49b6..690e4ea 100644
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

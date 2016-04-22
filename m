From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 10/10] net: hns: add attribute port-mode-offset for dsaf port node
Date: Fri, 22 Apr 2016 15:20:19 +0800
Message-ID: <1461309619-167621-11-git-send-email-Yisen.Zhuang@huawei.com>
References: <1461309619-167621-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<davem@davemloft.net>, <yankejian@huawei.com>,
	<huangdaode@hisilicon.com>, <salil.mehta@huawei.com>,
	<lipeng321@huawei.com>, <liguozhu@huawei.com>,
	<xieqianqian@huawei.com>, <linuxarm@huawei.com>
To: <devicetree@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:23553 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752546AbcDVHCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 03:02:53 -0400
In-Reply-To: <1461309619-167621-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Port mode offset for each dsaf port is different. The current code is not
so readability. This patch adds configuration named port-mode-offset to
make the code more simple and readability. If port-mode-offset doesn't
exist, default value 0 will be used.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 .../devicetree/bindings/net/hisilicon-hns-dsaf.txt |  3 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  | 10 +++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h  |  1 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 44 ++++++++++------------
 4 files changed, 32 insertions(+), 26 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
index 2afc3fa..5ccd4f0 100644
--- a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
+++ b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
@@ -45,7 +45,8 @@ Required properties:
   cpld-syscon.
 - port-rst-offset: is offset of reset field for each port in dsaf. Its value
   depends on the hardware user manual.
-
+- port-mode-offset: is offset of port mode field for each port in dsaf. Its
+  value depends on the hardware user manual.
 
 [1] Documentation/devicetree/bindings/net/phy.txt
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index 52d757d..1c8fdd3 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -665,6 +665,7 @@ static int  hns_mac_get_info(struct hns_mac_cb *mac_cb)
 	mac_cb->max_frm = MAC_DEFAULT_MTU;
 	mac_cb->tx_pause_frm_time = MAC_DEFAULT_PAUSE_TIME;
 	mac_cb->port_rst_off = mac_cb->mac_id;
+	mac_cb->port_mode_off = 0;
 
 	/* if the dsaf node doesn't contain a port subnode, get phy-handle
 	 * from dsaf node
@@ -703,6 +704,15 @@ static int  hns_mac_get_info(struct hns_mac_cb *mac_cb)
 			mac_cb->mac_id);
 	}
 
+	ret = fwnode_property_read_u32(mac_cb->fw_port,
+				       "port-mode-offset",
+				       &mac_cb->port_mode_off);
+	if (ret) {
+		dev_dbg(mac_cb->dev,
+			"mac%d port-mode-offset not found, use default value.\n",
+			mac_cb->mac_id);
+	}
+
 	syscon = syscon_node_to_regmap(
 			of_parse_phandle(to_of_node(mac_cb->fw_port),
 					 "cpld-syscon", 0));
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
index 7be7104..97ce9a7 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
@@ -319,6 +319,7 @@ struct hns_mac_cb {
 	struct regmap *cpld_ctrl;
 	u32 cpld_ctrl_reg;
 	u32 port_rst_off;
+	u32 port_mode_off;
 	struct mac_entry_idx addr_entry_idx[DSAF_MAX_VM_NUM];
 	u8 sfp_prsnt;
 	u8 cpld_led_value;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
index e549a11..a837bb9 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
@@ -265,37 +265,31 @@ phy_interface_t hns_mac_get_phy_if(struct hns_mac_cb *mac_cb)
 {
 	u32 mode;
 	u32 reg;
-	u32 shift;
-	u32 phy_offset;
 	bool is_ver1 = AE_IS_VER1(mac_cb->dsaf_dev->dsaf_ver);
 	int mac_id = mac_cb->mac_id;
-	phy_interface_t phy_if = PHY_INTERFACE_MODE_NA;
+	phy_interface_t phy_if;
 
-	if (is_ver1 && HNS_DSAF_IS_DEBUG(mac_cb->dsaf_dev)) {
-		phy_if = PHY_INTERFACE_MODE_SGMII;
-	} else if (mac_id >= 0 && mac_id <= 3 &&
-		   !HNS_DSAF_IS_DEBUG(mac_cb->dsaf_dev)) {
-		reg = is_ver1 ? HNS_MAC_HILINK4_REG : HNS_MAC_HILINK4V2_REG;
-		mode = dsaf_read_sub(mac_cb->dsaf_dev, reg);
-		/* mac_id 0, 1, 2, 3 ---> hilink4 lane 0, 1, 2, 3 */
-		shift = is_ver1 ? 0 : mac_id;
-		if (dsaf_get_bit(mode, shift))
-			phy_if = PHY_INTERFACE_MODE_XGMII;
+	if (is_ver1) {
+		if (HNS_DSAF_IS_DEBUG(mac_cb->dsaf_dev))
+			return PHY_INTERFACE_MODE_SGMII;
+
+		if (mac_id >= 0 && mac_id <= 3)
+			reg = HNS_MAC_HILINK4_REG;
 		else
-			phy_if = PHY_INTERFACE_MODE_SGMII;
-	} else {
-		reg = is_ver1 ? HNS_MAC_HILINK3_REG : HNS_MAC_HILINK3V2_REG;
-		mode = dsaf_read_sub(mac_cb->dsaf_dev, reg);
-		/* mac_id 4, 5,---> hilink3 lane 2, 3
-		 * debug port 0(6), 1(7) ---> hilink3 lane 0, 1
-		 */
-		phy_offset = mac_cb->dsaf_dev->reset_offset - 1;
-		shift = is_ver1 ? 0 : mac_id >= 4 ? mac_id - 2 : phy_offset;
-		if (dsaf_get_bit(mode, shift))
-			phy_if = PHY_INTERFACE_MODE_XGMII;
+			reg = HNS_MAC_HILINK3_REG;
+	} else{
+		if (!HNS_DSAF_IS_DEBUG(mac_cb->dsaf_dev) && mac_id <= 3)
+			reg = HNS_MAC_HILINK4V2_REG;
 		else
-			phy_if = PHY_INTERFACE_MODE_SGMII;
+			reg = HNS_MAC_HILINK3V2_REG;
 	}
+
+	mode = dsaf_read_sub(mac_cb->dsaf_dev, reg);
+	if (dsaf_get_bit(mode, mac_cb->port_mode_off))
+		phy_if = PHY_INTERFACE_MODE_XGMII;
+	else
+		phy_if = PHY_INTERFACE_MODE_SGMII;
+
 	return phy_if;
 }
 
-- 
1.9.1

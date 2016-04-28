From: Yisen Zhuang <Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 10/10] net: hns: add attribute port-mode-offset for dsaf port node
Date: Thu, 28 Apr 2016 15:01:42 +0800
Message-ID: <1461826902-51368-11-git-send-email-Yisen.Zhuang@huawei.com>
References: <1461826902-51368-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <will.deacon-5wv7dgnIgG8@public.gmane.org>,
	<catalin.marinas-5wv7dgnIgG8@public.gmane.org>, <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <liguozhu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<xieqianqian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
	<linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1461826902-51368-1-git-send-email-Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Port mode offset for each dsaf port is different. The current code is not
so readability. This patch adds configuration named port-mode-offset to
make the code simple and more readability. If port-mode-offset isn't
exists, default value 0 will be used.

Signed-off-by: Daode Huang <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 .../devicetree/bindings/net/hisilicon-hns-dsaf.txt |  2 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  | 10 +++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h  |  1 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 44 ++++++++++------------
 4 files changed, 32 insertions(+), 25 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
index 72efe71..31d9d19 100644
--- a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
+++ b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
@@ -45,6 +45,8 @@ Required properties:
   cpld-syscon. 
 - port-rst-offset: is offset of reset field for each port in dsaf. Its value 
   depends on the hardware user manual. 
+- port-mode-offset: is offset of port mode field for each port in dsaf. Its 
+  value depends on the hardware user manual.
 
 
 [1] Documentation/devicetree/bindings/net/phy.txt
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index 190477e..d825277 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -665,6 +665,7 @@ static int  hns_mac_get_info(struct hns_mac_cb *mac_cb)
 	mac_cb->max_frm = MAC_DEFAULT_MTU;
 	mac_cb->tx_pause_frm_time = MAC_DEFAULT_PAUSE_TIME;
 	mac_cb->port_rst_off = mac_cb->mac_id;
+	mac_cb->port_mode_off = 0;
 
 	/* if the dsaf node doesn't contain a port subnode,
 	 * parse the old dts to get phy-handle from dsaf node
@@ -704,6 +705,15 @@ static int  hns_mac_get_info(struct hns_mac_cb *mac_cb)
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
index fc3056e..eecdb14 100644
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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

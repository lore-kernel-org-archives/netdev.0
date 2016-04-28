From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 09/10] net: hns: add attribute port-rst-offset for dsaf port node
Date: Thu, 28 Apr 2016 15:01:41 +0800
Message-ID: <1461826902-51368-10-git-send-email-Yisen.Zhuang@huawei.com>
References: <1461826902-51368-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<davem@davemloft.net>, <will.deacon@arm.com>,
	<catalin.marinas@arm.com>, <yankejian@huawei.com>,
	<huangdaode@hisilicon.com>, <salil.mehta@huawei.com>,
	<lipeng321@huawei.com>, <liguozhu@huawei.com>,
	<xieqianqian@huawei.com>, <xuwei5@hisilicon.com>,
	<linuxarm@huawei.com>
To: <devicetree@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:26104 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751983AbcD1GrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 02:47:18 -0400
In-Reply-To: <1461826902-51368-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The reset offset for each port in a dsaf is different. The current code is
not so readability. This patch adds configuration named port-rst-offset to
make the code simple and more readability. If this attribute isn't exists,
default value of this attribute is equal to its port index.

Signed-off-by: Yisen Zhuang <yisen.zhuang@huawei.com>
---
 .../devicetree/bindings/net/hisilicon-hns-dsaf.txt |  4 +++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  | 10 +++++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h  |  1 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 26 +++++++---------------
 4 files changed, 22 insertions(+), 19 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
index c1358ea..72efe71 100644
--- a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
+++ b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
@@ -42,7 +42,9 @@ Required properties:
 - cpld-syscon: is syscon handle for cpld register. It is not required if there
   isn't cpld device.
 - cpld-ctrl-reg: is cpld register offset. It is not required if there isn't
-  cpld-syscon.  
+  cpld-syscon. 
+- port-rst-offset: is offset of reset field for each port in dsaf. Its value 
+  depends on the hardware user manual. 
 
 
 [1] Documentation/devicetree/bindings/net/phy.txt
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index f1a477d..190477e 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -664,6 +664,7 @@ static int  hns_mac_get_info(struct hns_mac_cb *mac_cb)
 
 	mac_cb->max_frm = MAC_DEFAULT_MTU;
 	mac_cb->tx_pause_frm_time = MAC_DEFAULT_PAUSE_TIME;
+	mac_cb->port_rst_off = mac_cb->mac_id;
 
 	/* if the dsaf node doesn't contain a port subnode,
 	 * parse the old dts to get phy-handle from dsaf node
@@ -694,6 +695,15 @@ static int  hns_mac_get_info(struct hns_mac_cb *mac_cb)
 	}
 	mac_cb->serdes_ctrl = syscon;
 
+	ret = fwnode_property_read_u32(mac_cb->fw_port,
+				       "port-rst-offset",
+				       &mac_cb->port_rst_off);
+	if (ret) {
+		dev_dbg(mac_cb->dev, 
+			"mac%d port-rst-offset not found, use default value.\n",
+			mac_cb->mac_id);
+	}
+
 	syscon = syscon_node_to_regmap(
 			of_parse_phandle(to_of_node(mac_cb->fw_port),
 					 "cpld-syscon", 0));
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
index 719816b..7be7104 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
@@ -318,6 +318,7 @@ struct hns_mac_cb {
 	struct regmap *serdes_ctrl;
 	struct regmap *cpld_ctrl;
 	u32 cpld_ctrl_reg;
+	u32 port_rst_off;
 	struct mac_entry_idx addr_entry_idx[DSAF_MAX_VM_NUM];
 	u8 sfp_prsnt;
 	u8 cpld_led_value;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
index 7e52ab5..fc3056e 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
@@ -136,11 +136,7 @@ void hns_dsaf_xge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
 		return;
 
 	reg_val |= RESET_REQ_OR_DREQ;
-
-	if (!HNS_DSAF_IS_DEBUG(dsaf_dev))
-		reg_val |= 0x2082082 << port;
-	else
-		reg_val |= 0x2082082 << (dsaf_dev->reset_offset + 6);
+	reg_val |= 0x2082082 << dsaf_dev->mac_cb[port]->port_rst_off;
 
 	if (val == 0)
 		reg_addr = DSAF_SUB_SC_XGE_RESET_REQ_REG;
@@ -159,11 +155,7 @@ void hns_dsaf_xge_core_srst_by_port(struct dsaf_device *dsaf_dev,
 	if (port >= DSAF_XGE_NUM)
 		return;
 
-	if (!HNS_DSAF_IS_DEBUG(dsaf_dev))
-		reg_val |= XGMAC_TRX_CORE_SRST_M << port;
-	else
-		reg_val |= XGMAC_TRX_CORE_SRST_M <<
-			(dsaf_dev->reset_offset + 6);
+	reg_val |= XGMAC_TRX_CORE_SRST_M << dsaf_dev->mac_cb[port]->port_rst_off;
 
 	if (val == 0)
 		reg_addr = DSAF_SUB_SC_XGE_RESET_REQ_REG;
@@ -177,17 +169,19 @@ void hns_dsaf_ge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
 {
 	u32 reg_val_1;
 	u32 reg_val_2;
+	u32 port_rst_off;
 
 	if (port >= DSAF_GE_NUM)
 		return;
 
 	if (!HNS_DSAF_IS_DEBUG(dsaf_dev)) {
 		reg_val_1  = 0x1 << port;
+		port_rst_off = dsaf_dev->mac_cb[port]->port_rst_off;
 		/* there is difference between V1 and V2 in register.*/
 		if (AE_IS_VER1(dsaf_dev->dsaf_ver))
-			reg_val_2  = 0x1041041 << port;
+			reg_val_2  = 0x1041041 << port_rst_off;
 		else
-			reg_val_2  = 0x2082082 << port;
+			reg_val_2  = 0x2082082 << port_rst_off;
 
 		if (val == 0) {
 			dsaf_write_sub(dsaf_dev, DSAF_SUB_SC_GE_RESET_REQ1_REG,
@@ -226,12 +220,8 @@ void hns_ppe_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
 {
 	u32 reg_val = 0;
 	u32 reg_addr;
-
-	if (!HNS_DSAF_IS_DEBUG(dsaf_dev))
-		reg_val |= RESET_REQ_OR_DREQ << port;
-	else
-		reg_val |= RESET_REQ_OR_DREQ <<
-			(dsaf_dev->reset_offset + 6);
+	
+	reg_val |= RESET_REQ_OR_DREQ <<	dsaf_dev->mac_cb[port]->port_rst_off;
 
 	if (val == 0)
 		reg_addr = DSAF_SUB_SC_PPE_RESET_REQ_REG;
-- 
1.9.1

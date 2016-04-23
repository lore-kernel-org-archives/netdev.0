From: Yisen Zhuang <Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v2 net-next 04/13] net: hns: add attribute reset-field-offset for dsaf node
Date: Sat, 23 Apr 2016 17:05:08 +0800
Message-ID: <1461402317-136499-5-git-send-email-Yisen.Zhuang@huawei.com>
References: <1461402317-136499-1-git-send-email-Yisen.Zhuang@huawei.com>
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
In-Reply-To: <1461402317-136499-1-git-send-email-Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add the subctrl reset offset for dsaf, this property is used to reset
xge/ge ports for different dsaf. If this attribute is not present,
default value 0 will be used.

Signed-off-by: Daode Huang <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Signed-off-by: Yisen Zhuang <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
change log:
 PATCH v2:
  - put DT bindings in separate patches.

 PATCH v1:
  - first submit
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |  8 +++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |  1 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 40 +++++++++++++++-------
 3 files changed, 37 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 7692853..b418d42 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -36,6 +36,7 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 	int ret, i;
 	u32 desc_num;
 	u32 buf_size;
+	u32 reset_offset = 0;
 	const char *mode_str;
 	struct device_node *np = dsaf_dev->dev->of_node;
 
@@ -119,6 +120,13 @@ int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 	}
 	dsaf_dev->desc_num = desc_num;
 
+	ret = of_property_read_u32(np, "reset-field-offset", &reset_offset);
+	if (ret < 0) {
+		dev_dbg(dsaf_dev->dev,
+			"get reset-field-offset fail, ret=%d!\r\n", ret);
+	}
+	dsaf_dev->reset_offset = reset_offset;
+
 	ret = of_property_read_u32(np, "buf-size", &buf_size);
 	if (ret < 0) {
 		dev_err(dsaf_dev->dev,
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
index a783019..47e768b 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
@@ -281,6 +281,7 @@ struct dsaf_device {
 
 	u32 desc_num; /*  desc num per queue*/
 	u32 buf_size; /*  ring buffer size */
+	u32 reset_offset; /* reset field offset in sub sysctrl */
 	int buf_size_type; /* ring buffer size-type */
 	enum dsaf_mode dsaf_mode;	 /* dsaf mode  */
 	enum hal_dsaf_mode dsaf_en;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
index 8cb13d9..91e0382 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
@@ -110,7 +110,11 @@ void hns_dsaf_xge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
 		return;
 
 	reg_val |= RESET_REQ_OR_DREQ;
-	reg_val |= 0x2082082 << port;
+
+	if (!HNS_DSAF_IS_DEBUG(dsaf_dev))
+		reg_val |= 0x2082082 << port;
+	else
+		reg_val |= 0x2082082 << (dsaf_dev->reset_offset + 6);
 
 	if (val == 0)
 		reg_addr = DSAF_SUB_SC_XGE_RESET_REQ_REG;
@@ -129,7 +133,11 @@ void hns_dsaf_xge_core_srst_by_port(struct dsaf_device *dsaf_dev,
 	if (port >= DSAF_XGE_NUM)
 		return;
 
-	reg_val |= XGMAC_TRX_CORE_SRST_M << port;
+	if (!HNS_DSAF_IS_DEBUG(dsaf_dev))
+		reg_val |= XGMAC_TRX_CORE_SRST_M << port;
+	else
+		reg_val |= XGMAC_TRX_CORE_SRST_M <<
+			(dsaf_dev->reset_offset + 6);
 
 	if (val == 0)
 		reg_addr = DSAF_SUB_SC_XGE_RESET_REQ_REG;
@@ -173,8 +181,8 @@ void hns_dsaf_ge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
 				       reg_val_1);
 		}
 	} else {
-		reg_val_1 = 0x15540 << (port - 6);
-		reg_val_2 = 0x100 << (port - 6);
+		reg_val_1 = 0x15540 << dsaf_dev->reset_offset;
+		reg_val_2 = 0x100 << dsaf_dev->reset_offset;
 
 		if (val == 0) {
 			dsaf_write_reg(dsaf_dev->sc_base,
@@ -201,7 +209,11 @@ void hns_ppe_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
 	u32 reg_val = 0;
 	u32 reg_addr;
 
-	reg_val |= RESET_REQ_OR_DREQ << port;
+	if (!HNS_DSAF_IS_DEBUG(dsaf_dev))
+		reg_val |= RESET_REQ_OR_DREQ << port;
+	else
+		reg_val |= RESET_REQ_OR_DREQ <<
+			(dsaf_dev->reset_offset + 6);
 
 	if (val == 0)
 		reg_addr = DSAF_SUB_SC_PPE_RESET_REQ_REG;
@@ -213,7 +225,6 @@ void hns_ppe_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
 
 void hns_ppe_com_srst(struct ppe_common_cb *ppe_common, u32 val)
 {
-	int comm_index = ppe_common->comm_index;
 	struct dsaf_device *dsaf_dev = ppe_common->dsaf_dev;
 	u32 reg_val;
 	u32 reg_addr;
@@ -226,7 +237,7 @@ void hns_ppe_com_srst(struct ppe_common_cb *ppe_common, u32 val)
 			reg_addr = DSAF_SUB_SC_RCB_PPE_COM_RESET_DREQ_REG;
 
 	} else {
-		reg_val = 0x100 << (comm_index - 1);
+		reg_val = 0x100 << dsaf_dev->reset_offset;
 
 		if (val == 0)
 			reg_addr = DSAF_SUB_SC_PPE_RESET_REQ_REG;
@@ -247,14 +258,16 @@ phy_interface_t hns_mac_get_phy_if(struct hns_mac_cb *mac_cb)
 	u32 mode;
 	u32 reg;
 	u32 shift;
+	u32 phy_offset;
 	bool is_ver1 = AE_IS_VER1(mac_cb->dsaf_dev->dsaf_ver);
 	void __iomem *sys_ctl_vaddr = mac_cb->sys_ctl_vaddr;
 	int mac_id = mac_cb->mac_id;
 	phy_interface_t phy_if = PHY_INTERFACE_MODE_NA;
 
-	if (is_ver1 && (mac_id >= 6 && mac_id <= 7)) {
+	if (is_ver1 && HNS_DSAF_IS_DEBUG(mac_cb->dsaf_dev)) {
 		phy_if = PHY_INTERFACE_MODE_SGMII;
-	} else if (mac_id >= 0 && mac_id <= 3) {
+	} else if (mac_id >= 0 && mac_id <= 3 &&
+		   !HNS_DSAF_IS_DEBUG(mac_cb->dsaf_dev)) {
 		reg = is_ver1 ? HNS_MAC_HILINK4_REG : HNS_MAC_HILINK4V2_REG;
 		mode = dsaf_read_reg(sys_ctl_vaddr, reg);
 		/* mac_id 0, 1, 2, 3 ---> hilink4 lane 0, 1, 2, 3 */
@@ -263,11 +276,14 @@ phy_interface_t hns_mac_get_phy_if(struct hns_mac_cb *mac_cb)
 			phy_if = PHY_INTERFACE_MODE_XGMII;
 		else
 			phy_if = PHY_INTERFACE_MODE_SGMII;
-	} else if (mac_id >= 4 && mac_id <= 7) {
+	} else {
 		reg = is_ver1 ? HNS_MAC_HILINK3_REG : HNS_MAC_HILINK3V2_REG;
 		mode = dsaf_read_reg(sys_ctl_vaddr, reg);
-		/* mac_id 4, 5, 6, 7 ---> hilink3 lane 2, 3, 0, 1 */
-		shift = is_ver1 ? 0 : mac_id <= 5 ? mac_id - 2 : mac_id - 6;
+		/* mac_id 4, 5,---> hilink3 lane 2, 3
+		 * debug port 0(6), 1(7) ---> hilink3 lane 0, 1
+		 */
+		phy_offset = mac_cb->dsaf_dev->reset_offset - 1;
+		shift = is_ver1 ? 0 : mac_id >= 4 ? mac_id - 2 : phy_offset;
 		if (dsaf_get_bit(mode, shift))
 			phy_if = PHY_INTERFACE_MODE_XGMII;
 		else
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

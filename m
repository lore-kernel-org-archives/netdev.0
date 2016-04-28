From: Yisen Zhuang <Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 08/10] net: hns: add attribute cpld_ctrl for dsaf port node
Date: Thu, 28 Apr 2016 15:01:40 +0800
Message-ID: <1461826902-51368-9-git-send-email-Yisen.Zhuang@huawei.com>
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

This patch add attribute cpld_ctrl for dsaf port node, parse the syscon
for mac_cb from dts, and change the method of access the cpld related
registers through syscon.

Signed-off-by: Daode Huang <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Signed-off-by: Yisen Zhuang <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 .../devicetree/bindings/net/hisilicon-hns-dsaf.txt |  4 +++
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |  2 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  | 38 ++++++++++++----------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h  |  3 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |  5 ---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |  1 -
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 36 +++++++++++++++-----
 7 files changed, 55 insertions(+), 34 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
index 01380a6..c1358ea 100644
--- a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
+++ b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
@@ -39,6 +39,10 @@ Required properties:
 - phy-handle: phy handle of physicl port. It is not required if there isn't 
   phy device. see ethernet.txt [1].
 - serdes-syscon: is syscon handle for SerDes register.
+- cpld-syscon: is syscon handle for cpld register. It is not required if there
+  isn't cpld device.
+- cpld-ctrl-reg: is cpld register offset. It is not required if there isn't
+  cpld-syscon.  
 
 
 [1] Documentation/devicetree/bindings/net/phy.txt
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index 58341da..7a757e8 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -664,7 +664,7 @@ void hns_ae_update_led_status(struct hnae_handle *handle)
 
 	assert(handle);
 	mac_cb = hns_get_mac_cb(handle);
-	if (!mac_cb->cpld_vaddr)
+	if (!mac_cb->cpld_ctrl)
 		return;
 	hns_set_led_opt(mac_cb);
 }
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index 39dd55f..f1a477d 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -82,17 +82,6 @@ static enum mac_mode hns_get_enet_interface(const struct hns_mac_cb *mac_cb)
 	}
 }
 
-int hns_mac_get_sfp_prsnt(struct hns_mac_cb *mac_cb, int *sfp_prsnt)
-{
-	if (!mac_cb->cpld_vaddr)
-		return -ENODEV;
-
-	*sfp_prsnt = !dsaf_read_b((u8 *)mac_cb->cpld_vaddr
-					+ MAC_SFP_PORT_OFFSET);
-
-	return 0;
-}
-
 void hns_mac_get_link_status(struct hns_mac_cb *mac_cb, u32 *link_status)
 {
 	struct mac_driver *mac_ctrl_drv;
@@ -658,6 +647,8 @@ static int  hns_mac_get_info(struct hns_mac_cb *mac_cb)
 {
 	struct device_node *np = mac_cb->dev->of_node;
 	struct regmap *syscon;
+	u32 ret;
+
 	mac_cb->link = false;
 	mac_cb->half_duplex = false;
 	mac_cb->speed = mac_phy_to_speed[mac_cb->phy_if];
@@ -702,6 +693,23 @@ static int  hns_mac_get_info(struct hns_mac_cb *mac_cb)
 		return -EINVAL;
 	}
 	mac_cb->serdes_ctrl = syscon;
+
+	syscon = syscon_node_to_regmap(
+			of_parse_phandle(to_of_node(mac_cb->fw_port),
+					 "cpld-syscon", 0));
+	if (IS_ERR_OR_NULL(syscon)) {
+		dev_dbg(mac_cb->dev, "no cpld-syscon found!\n");
+		mac_cb->cpld_ctrl = NULL;
+	} else {
+		mac_cb->cpld_ctrl = syscon;
+		ret = fwnode_property_read_u32(mac_cb->fw_port,
+					       "cpld-ctrl-reg",
+					       &mac_cb->cpld_ctrl_reg);
+		if (ret) {
+			dev_err(mac_cb->dev, "get cpld-ctrl-reg fail!\n");
+			return ret;
+		}
+	}
 	return 0;
 }
 
@@ -752,11 +760,6 @@ int hns_mac_get_cfg(struct dsaf_device *dsaf_dev, struct hns_mac_cb *mac_cb)
 	mac_cb->sys_ctl_vaddr =	dsaf_dev->sc_base;
 	mac_cb->serdes_vaddr = dsaf_dev->sds_base;
 
-	if (dsaf_dev->cpld_base && !HNS_DSAF_IS_DEBUG(dsaf_dev)) {
-		mac_cb->cpld_vaddr = dsaf_dev->cpld_base +
-			mac_cb->mac_id * CPLD_ADDR_PORT_OFFSET;
-		cpld_led_reset(mac_cb);
-	}
 	mac_cb->sfp_prsnt = 0;
 	mac_cb->txpkt_for_led = 0;
 	mac_cb->rxpkt_for_led = 0;
@@ -781,6 +784,7 @@ int hns_mac_get_cfg(struct dsaf_device *dsaf_dev, struct hns_mac_cb *mac_cb)
 	if (ret)
 		return ret;
 
+	cpld_led_reset(mac_cb);
 	mac_cb->vaddr = hns_mac_get_vaddr(dsaf_dev, mac_cb, mac_mode_idx);
 
 	return 0;
@@ -957,7 +961,7 @@ void hns_set_led_opt(struct hns_mac_cb *mac_cb)
 int hns_cpld_led_set_id(struct hns_mac_cb *mac_cb,
 			enum hnae_led_state status)
 {
-	if (!mac_cb || !mac_cb->cpld_vaddr)
+	if (!mac_cb || !mac_cb->cpld_ctrl)
 		return 0;
 
 	return cpld_set_led_id(mac_cb, status);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
index 45c5f16..719816b 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
@@ -313,10 +313,11 @@ struct hns_mac_cb {
 	struct mac_priv priv;
 	struct fwnode_handle *fw_port;
 	u8 __iomem *vaddr;
-	u8 __iomem *cpld_vaddr;
 	u8 __iomem *sys_ctl_vaddr;
 	u8 __iomem *serdes_vaddr;
 	struct regmap *serdes_ctrl;
+	struct regmap *cpld_ctrl;
+	u32 cpld_ctrl_reg;
 	struct mac_entry_idx addr_entry_idx[DSAF_MAX_VM_NUM];
 	u8 sfp_prsnt;
 	u8 cpld_led_value;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 542dd09..1b8439f 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -198,8 +198,6 @@ unmap_base_addr:
 		iounmap(dsaf_dev->sds_base);
 	if (dsaf_dev->sc_base)
 		iounmap(dsaf_dev->sc_base);
-	if (dsaf_dev->cpld_base)
-		iounmap(dsaf_dev->cpld_base);
 	return ret;
 }
 
@@ -216,9 +214,6 @@ static void hns_dsaf_free_cfg(struct dsaf_device *dsaf_dev)
 
 	if (dsaf_dev->sc_base)
 		iounmap(dsaf_dev->sc_base);
-
-	if (dsaf_dev->cpld_base)
-		iounmap(dsaf_dev->cpld_base);
 }
 
 /**
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
index a48ef26..f0502ba 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
@@ -277,7 +277,6 @@ struct dsaf_device {
 	u8 __iomem *sds_base;
 	u8 __iomem *ppe_base;
 	u8 __iomem *io_base;
-	u8 __iomem *cpld_base;
 	struct regmap *sub_ctrl;
 	phys_addr_t ppe_paddr;
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
index 4762893..7e52ab5 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
@@ -43,8 +43,8 @@ void hns_cpld_set_led(struct hns_mac_cb *mac_cb, int link_status,
 		pr_err("sfp_led_opt mac_dev is null!\n");
 		return;
 	}
-	if (!mac_cb->cpld_vaddr) {
-		dev_err(mac_cb->dev, "mac_id=%d, cpld_vaddr is null !\n",
+	if (!mac_cb->cpld_ctrl) {
+		dev_err(mac_cb->dev, "mac_id=%d, cpld syscon is null !\n",
 			mac_cb->mac_id);
 		return;
 	}
@@ -61,21 +61,24 @@ void hns_cpld_set_led(struct hns_mac_cb *mac_cb, int link_status,
 		dsaf_set_bit(value, DSAF_LED_DATA_B, data);
 
 		if (value != mac_cb->cpld_led_value) {
-			dsaf_write_b(mac_cb->cpld_vaddr, value);
+			dsaf_write_syscon(mac_cb->cpld_ctrl,
+					  mac_cb->cpld_ctrl_reg, value);
 			mac_cb->cpld_led_value = value;
 		}
 	} else {
-		dsaf_write_b(mac_cb->cpld_vaddr, CPLD_LED_DEFAULT_VALUE);
+		dsaf_write_syscon(mac_cb->cpld_ctrl, mac_cb->cpld_ctrl_reg,
+				  CPLD_LED_DEFAULT_VALUE);
 		mac_cb->cpld_led_value = CPLD_LED_DEFAULT_VALUE;
 	}
 }
 
 void cpld_led_reset(struct hns_mac_cb *mac_cb)
 {
-	if (!mac_cb || !mac_cb->cpld_vaddr)
+	if (!mac_cb || !mac_cb->cpld_ctrl)
 		return;
 
-	dsaf_write_b(mac_cb->cpld_vaddr, CPLD_LED_DEFAULT_VALUE);
+	dsaf_write_syscon(mac_cb->cpld_ctrl, mac_cb->cpld_ctrl_reg,
+			  CPLD_LED_DEFAULT_VALUE);
 	mac_cb->cpld_led_value = CPLD_LED_DEFAULT_VALUE;
 }
 
@@ -84,15 +87,19 @@ int cpld_set_led_id(struct hns_mac_cb *mac_cb,
 {
 	switch (status) {
 	case HNAE_LED_ACTIVE:
-		mac_cb->cpld_led_value = dsaf_read_b(mac_cb->cpld_vaddr);
+		mac_cb->cpld_led_value =
+			dsaf_read_syscon(mac_cb->cpld_ctrl,
+					 mac_cb->cpld_ctrl_reg);
 		dsaf_set_bit(mac_cb->cpld_led_value, DSAF_LED_ANCHOR_B,
 			     CPLD_LED_ON_VALUE);
-		dsaf_write_b(mac_cb->cpld_vaddr, mac_cb->cpld_led_value);
+		dsaf_write_syscon(mac_cb->cpld_ctrl, mac_cb->cpld_ctrl_reg,
+				  mac_cb->cpld_led_value);
 		return 2;
 	case HNAE_LED_INACTIVE:
 		dsaf_set_bit(mac_cb->cpld_led_value, DSAF_LED_ANCHOR_B,
 			     CPLD_LED_DEFAULT_VALUE);
-		dsaf_write_b(mac_cb->cpld_vaddr, mac_cb->cpld_led_value);
+		dsaf_write_syscon(mac_cb->cpld_ctrl, mac_cb->cpld_ctrl_reg,
+				  mac_cb->cpld_led_value);
 		break;
 	default:
 		break;
@@ -302,6 +309,17 @@ phy_interface_t hns_mac_get_phy_if(struct hns_mac_cb *mac_cb)
 	return phy_if;
 }
 
+int hns_mac_get_sfp_prsnt(struct hns_mac_cb *mac_cb, int *sfp_prsnt)
+{
+	if (!mac_cb->cpld_ctrl)
+		return -ENODEV;
+
+	*sfp_prsnt = !dsaf_read_syscon(mac_cb->cpld_ctrl, mac_cb->cpld_ctrl_reg
+					+ MAC_SFP_PORT_OFFSET);
+
+	return 0;
+}
+
 /**
  * hns_mac_config_sds_loopback - set loop back for serdes
  * @mac_cb: mac control block
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

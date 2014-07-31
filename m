From: freddy@asix.com.tw
Subject: [PATCH 1/1] AX88179_178A: Add ethtool ops for EEE support
Date: Thu, 31 Jul 2014 19:06:35 +0800
Message-ID: <1406804795-2754-1-git-send-email-freddy@asix.com.tw>
Cc: Freddy Xin <freddy@asix.com.tw>
To: davem@davemloft.net, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	louis@asix.com.tw
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Freddy Xin <freddy@asix.com.tw>

Add functions to support ethtool EEE manipulating, and the EEE
is disabled in default setting to enhance the compatibility
with certain switch.

Signed-off-by: Freddy Xin <freddy@asix.com.tw>
---
 drivers/net/usb/ax88179_178a.c | 264 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 264 insertions(+)

diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
index 054e59c..be42757 100644
--- a/drivers/net/usb/ax88179_178a.c
+++ b/drivers/net/usb/ax88179_178a.c
@@ -23,6 +23,8 @@
 #include <linux/usb.h>
 #include <linux/crc32.h>
 #include <linux/usb/usbnet.h>
+#include <uapi/linux/mdio.h>
+#include <linux/mdio.h>
 
 #define AX88179_PHY_ID				0x03
 #define AX_EEPROM_LEN				0x100
@@ -170,8 +172,12 @@
 #define GMII_PHY_PAGE_SELECT			0x1f
 	#define GMII_PHY_PGSEL_EXT	0x0007
 	#define GMII_PHY_PGSEL_PAGE0	0x0000
+	#define GMII_PHY_PGSEL_PAGE3	0x0003
+	#define GMII_PHY_PGSEL_PAGE5	0x0005
 
 struct ax88179_data {
+	u8  eee_enabled;
+	u8  eee_active;
 	u16 rxctl;
 	u16 reserved;
 };
@@ -373,6 +379,60 @@ static void ax88179_mdio_write(struct net_device *netdev, int phy_id, int loc,
 	ax88179_write_cmd(dev, AX_ACCESS_PHY, phy_id, (__u16)loc, 2, &res);
 }
 
+static inline int ax88179_phy_mmd_indirect(struct usbnet *dev, u16 prtad,
+					   u16 devad)
+{
+	u16 tmp16;
+	int ret;
+
+	tmp16 = devad;
+	ret = ax88179_write_cmd(dev, AX_ACCESS_PHY, AX88179_PHY_ID,
+				MII_MMD_CTRL, 2, &tmp16);
+
+	tmp16 = prtad;
+	ret = ax88179_write_cmd(dev, AX_ACCESS_PHY, AX88179_PHY_ID,
+				MII_MMD_DATA, 2, &tmp16);
+
+	tmp16 = devad | MII_MMD_CTRL_NOINCR;
+	ret = ax88179_write_cmd(dev, AX_ACCESS_PHY, AX88179_PHY_ID,
+				MII_MMD_CTRL, 2, &tmp16);
+
+	return ret;
+}
+
+static int
+ax88179_phy_read_mmd_indirect(struct usbnet *dev, u16 prtad, u16 devad)
+{
+	int ret;
+	u16 tmp16;
+
+	ax88179_phy_mmd_indirect(dev, prtad, devad);
+
+	ret = ax88179_read_cmd(dev, AX_ACCESS_PHY, AX88179_PHY_ID,
+			       MII_MMD_DATA, 2, &tmp16);
+	if (ret < 0)
+		return ret;
+
+	return tmp16;
+}
+
+static int
+ax88179_phy_write_mmd_indirect(struct usbnet *dev, u16 prtad, u16 devad,
+			       u16 data)
+{
+	int ret;
+
+	ax88179_phy_mmd_indirect(dev, prtad, devad);
+
+	ret = ax88179_write_cmd(dev, AX_ACCESS_PHY, AX88179_PHY_ID,
+				MII_MMD_DATA, 2, &data);
+
+	if (ret < 0)
+		return ret;
+
+	return 0;
+}
+
 static int ax88179_suspend(struct usb_interface *intf, pm_message_t message)
 {
 	struct usbnet *dev = usb_get_intfdata(intf);
@@ -572,6 +632,185 @@ static int ax88179_set_settings(struct net_device *net, struct ethtool_cmd *cmd)
 	return mii_ethtool_sset(&dev->mii, cmd);
 }
 
+static int
+ax88179_ethtool_get_eee(struct usbnet *dev, struct ethtool_eee *data)
+{
+	int val;
+
+	/* Get Supported EEE */
+	val = ax88179_phy_read_mmd_indirect(dev, MDIO_PCS_EEE_ABLE,
+					    MDIO_MMD_PCS);
+	if (val < 0)
+		return val;
+	data->supported = mmd_eee_cap_to_ethtool_sup_t(val);
+
+	/* Get advertisement EEE */
+	val = ax88179_phy_read_mmd_indirect(dev, MDIO_AN_EEE_ADV,
+					    MDIO_MMD_AN);
+	if (val < 0)
+		return val;
+	data->advertised = mmd_eee_adv_to_ethtool_adv_t(val);
+
+	/* Get LP advertisement EEE */
+	val = ax88179_phy_read_mmd_indirect(dev, MDIO_AN_EEE_LPABLE,
+					    MDIO_MMD_AN);
+	if (val < 0)
+		return val;
+	data->lp_advertised = mmd_eee_adv_to_ethtool_adv_t(val);
+
+	return 0;
+}
+
+static int
+ax88179_ethtool_set_eee(struct usbnet *dev, struct ethtool_eee *data)
+{
+	u16 tmp16 = ethtool_adv_to_mmd_eee_adv_t(data->advertised);
+
+	return ax88179_phy_write_mmd_indirect(dev, MDIO_AN_EEE_ADV,
+					      MDIO_MMD_AN, tmp16);
+}
+
+static int ax88179_chk_eee(struct usbnet *dev)
+{
+	struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET };
+	struct ax88179_data *priv = (struct ax88179_data *)dev->data;
+
+	mii_ethtool_gset(&dev->mii, &ecmd);
+
+	if (ecmd.duplex & DUPLEX_FULL) {
+		int eee_lp, eee_cap, eee_adv;
+		u32 lp, cap, adv, supported = 0;
+
+		eee_cap = ax88179_phy_read_mmd_indirect(dev,
+							MDIO_PCS_EEE_ABLE,
+							MDIO_MMD_PCS);
+		if (eee_cap < 0) {
+			priv->eee_active = 0;
+			return false;
+		}
+
+		cap = mmd_eee_cap_to_ethtool_sup_t(eee_cap);
+		if (!cap) {
+			priv->eee_active = 0;
+			return false;
+		}
+
+		eee_lp = ax88179_phy_read_mmd_indirect(dev,
+						       MDIO_AN_EEE_LPABLE,
+						       MDIO_MMD_AN);
+		if (eee_lp < 0) {
+			priv->eee_active = 0;
+			return false;
+		}
+
+		eee_adv = ax88179_phy_read_mmd_indirect(dev,
+							MDIO_AN_EEE_ADV,
+							MDIO_MMD_AN);
+
+		if (eee_adv < 0) {
+			priv->eee_active = 0;
+			return false;
+		}
+
+		adv = mmd_eee_adv_to_ethtool_adv_t(eee_adv);
+		lp = mmd_eee_adv_to_ethtool_adv_t(eee_lp);
+		supported = (ecmd.speed == SPEED_1000) ?
+			     SUPPORTED_1000baseT_Full :
+			     SUPPORTED_100baseT_Full;
+
+		if (!(lp & adv & supported)) {
+			priv->eee_active = 0;
+			return false;
+		}
+
+		priv->eee_active = 1;
+		return true;
+	}
+
+	priv->eee_active = 0;
+	return false;
+}
+
+static void ax88179_disable_eee(struct usbnet *dev)
+{
+	u16 tmp16;
+
+	tmp16 = GMII_PHY_PGSEL_PAGE3;
+	ax88179_write_cmd(dev, AX_ACCESS_PHY, AX88179_PHY_ID,
+			  GMII_PHY_PAGE_SELECT, 2, &tmp16);
+
+	tmp16 = 0x3246;
+	ax88179_write_cmd(dev, AX_ACCESS_PHY, AX88179_PHY_ID,
+			  MII_PHYADDR, 2, &tmp16);
+
+	tmp16 = GMII_PHY_PGSEL_PAGE0;
+	ax88179_write_cmd(dev, AX_ACCESS_PHY, AX88179_PHY_ID,
+			  GMII_PHY_PAGE_SELECT, 2, &tmp16);
+}
+
+static void ax88179_enable_eee(struct usbnet *dev)
+{
+	u16 tmp16;
+
+	tmp16 = GMII_PHY_PGSEL_PAGE3;
+	ax88179_write_cmd(dev, AX_ACCESS_PHY, AX88179_PHY_ID,
+			  GMII_PHY_PAGE_SELECT, 2, &tmp16);
+
+	tmp16 = 0x3247;
+	ax88179_write_cmd(dev, AX_ACCESS_PHY, AX88179_PHY_ID,
+			  MII_PHYADDR, 2, &tmp16);
+
+	tmp16 = GMII_PHY_PGSEL_PAGE5;
+	ax88179_write_cmd(dev, AX_ACCESS_PHY, AX88179_PHY_ID,
+			  GMII_PHY_PAGE_SELECT, 2, &tmp16);
+
+	tmp16 = 0x0680;
+	ax88179_write_cmd(dev, AX_ACCESS_PHY, AX88179_PHY_ID,
+			  MII_BMSR, 2, &tmp16);
+
+	tmp16 = GMII_PHY_PGSEL_PAGE0;
+	ax88179_write_cmd(dev, AX_ACCESS_PHY, AX88179_PHY_ID,
+			  GMII_PHY_PAGE_SELECT, 2, &tmp16);
+}
+
+static int ax88179_get_eee(struct net_device *net, struct ethtool_eee *edata)
+{
+	struct usbnet *dev = netdev_priv(net);
+	struct ax88179_data *priv = (struct ax88179_data *)dev->data;
+
+	edata->eee_enabled = priv->eee_enabled;
+	edata->eee_active = priv->eee_active;
+
+	return ax88179_ethtool_get_eee(dev, edata);
+}
+
+static int ax88179_set_eee(struct net_device *net, struct ethtool_eee *edata)
+{
+	struct usbnet *dev = netdev_priv(net);
+	struct ax88179_data *priv = (struct ax88179_data *)dev->data;
+	int ret = -EOPNOTSUPP;
+
+	priv->eee_enabled = edata->eee_enabled;
+	if (!priv->eee_enabled) {
+		ax88179_disable_eee(dev);
+	} else {
+		priv->eee_enabled = ax88179_chk_eee(dev);
+		if (!priv->eee_enabled)
+			return -EOPNOTSUPP;
+
+		ax88179_enable_eee(dev);
+	}
+
+	ret = ax88179_ethtool_set_eee(dev, edata);
+	if (ret)
+		return ret;
+
+	mii_nway_restart(&dev->mii);
+
+	usbnet_link_change(dev, 0, 0);
+
+	return ret;
+}
 
 static int ax88179_ioctl(struct net_device *net, struct ifreq *rq, int cmd)
 {
@@ -589,6 +828,8 @@ static const struct ethtool_ops ax88179_ethtool_ops = {
 	.get_eeprom		= ax88179_get_eeprom,
 	.get_settings		= ax88179_get_settings,
 	.set_settings		= ax88179_set_settings,
+	.get_eee		= ax88179_get_eee,
+	.set_eee		= ax88179_set_eee,
 	.nway_reset		= usbnet_nway_reset,
 };
 
@@ -980,6 +1221,7 @@ static int ax88179_bind(struct usbnet *dev, struct usb_interface *intf)
 	u16 *tmp16;
 	u8 *tmp;
 	struct ax88179_data *ax179_data = (struct ax88179_data *)dev->data;
+	struct ethtool_eee eee_data;
 
 	usbnet_get_endpoints(dev, intf);
 
@@ -1062,6 +1304,15 @@ static int ax88179_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	ax88179_led_setting(dev);
 
+	ax179_data->eee_enabled = 0;
+	ax179_data->eee_active = 0;
+
+	ax88179_disable_eee(dev);
+
+	ax88179_ethtool_get_eee(dev, &eee_data);
+	eee_data.advertised = 0;
+	ax88179_ethtool_set_eee(dev, &eee_data);
+
 	/* Restart autoneg */
 	mii_nway_restart(&dev->mii);
 
@@ -1261,6 +1512,8 @@ static int ax88179_link_reset(struct usbnet *dev)
 	ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_MEDIUM_STATUS_MODE,
 			  2, 2, &mode);
 
+	ax179_data->eee_enabled = ax88179_chk_eee(dev);
+
 	netif_carrier_on(dev->net);
 
 	return 0;
@@ -1271,6 +1524,8 @@ static int ax88179_reset(struct usbnet *dev)
 	u8 buf[5];
 	u16 *tmp16;
 	u8 *tmp;
+	struct ax88179_data *ax179_data = (struct ax88179_data *)dev->data;
+	struct ethtool_eee eee_data;
 
 	tmp16 = (u16 *)buf;
 	tmp = (u8 *)buf;
@@ -1340,6 +1595,15 @@ static int ax88179_reset(struct usbnet *dev)
 
 	ax88179_led_setting(dev);
 
+	ax179_data->eee_enabled = 0;
+	ax179_data->eee_active = 0;
+
+	ax88179_disable_eee(dev);
+
+	ax88179_ethtool_get_eee(dev, &eee_data);
+	eee_data.advertised = 0;
+	ax88179_ethtool_set_eee(dev, &eee_data);
+
 	/* Restart autoneg */
 	mii_nway_restart(&dev->mii);
 
-- 
1.9.1

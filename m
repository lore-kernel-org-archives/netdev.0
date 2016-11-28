From: <Woojung.Huh@microchip.com>
Subject: [PATCH net-netx] net: lan78xx: add LAN7801 MAC-only support
Date: Mon, 28 Nov 2016 20:03:56 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D4096E268@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <UNGLinuxDriver@microchip.com>
To: <davem@davemloft.net>, <f.fainelli@gmail.com>, <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp02.microchip.com ([198.175.253.38]:53101 "EHLO
        email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755060AbcK1UJk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 15:09:40 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Woojung Huh <woojung.huh@microchip.com>

Add LAN7801 MAC-only configuration support.

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/usb/Kconfig   |   5 +++
 drivers/net/usb/lan78xx.c | 111 +++++++++++++++++++++++++++++++++++++++++++++-
 drivers/net/usb/lan78xx.h |  14 ++++++
 3 files changed, 128 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index cdde590..3dd490f5 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -114,6 +114,11 @@ config USB_LAN78XX
 	help
 	  This option adds support for Microchip LAN78XX based USB 2
 	  & USB 3 10/100/1000 Ethernet adapters.
+	  LAN7800 : USB 3 to 10/100/1000 Ethernet adapter
+	  LAN7850 : USB 2 to 10/100/1000 Ethernet adapter
+	  LAN7801 : USB 3 to 10/100/1000 Ethernet adapter (MAC only)
+
+	  Proper PHY driver is required for LAN7801.
 
 	  To compile this driver as a module, choose M here: the
 	  module will be called lan78xx.
diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 0c459e9..08f2895 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -40,7 +40,7 @@
 #define DRIVER_AUTHOR	"WOOJUNG HUH <woojung.huh@microchip.com>"
 #define DRIVER_DESC	"LAN78XX USB 3.0 Gigabit Ethernet Devices"
 #define DRIVER_NAME	"lan78xx"
-#define DRIVER_VERSION	"1.0.5"
+#define DRIVER_VERSION	"1.0.6"
 
 #define TX_TIMEOUT_JIFFIES		(5 * HZ)
 #define THROTTLE_JIFFIES		(HZ / 8)
@@ -67,6 +67,7 @@
 #define LAN78XX_USB_VENDOR_ID		(0x0424)
 #define LAN7800_USB_PRODUCT_ID		(0x7800)
 #define LAN7850_USB_PRODUCT_ID		(0x7850)
+#define LAN7801_USB_PRODUCT_ID		(0x7801)
 #define LAN78XX_EEPROM_MAGIC		(0x78A5)
 #define LAN78XX_OTP_MAGIC		(0x78F3)
 
@@ -400,6 +401,21 @@ struct lan78xx_net {
 	struct irq_domain_data	domain_data;
 };
 
+/* define external phy id */
+#define	PHY_LAN8835			(0x0007C130)
+#define	PHY_KSZ9031RNX			(0x00221620)
+
+/* phyid : masked external phy id
+ * pre_config : if needed, configure MAC and/or external PHY
+ *		such as irq pin mux and RGMII timing.
+ */
+struct ext_phy_config_table {
+	int phyid;
+	void (*pre_config)(struct lan78xx_net *dev,
+			   struct phy_device *phydev,
+			   phy_interface_t *interface);
+};
+
 /* use ethtool to change the level for any given device */
 static int msg_level = -1;
 module_param(msg_level, int, 0);
@@ -1697,6 +1713,7 @@ static int lan78xx_mdiobus_read(struct mii_bus *bus, int phy_id, int idx)
 done:
 	mutex_unlock(&dev->phy_mutex);
 	usb_autopm_put_interface(dev->intf);
+
 	return ret;
 }
 
@@ -1759,6 +1776,10 @@ static int lan78xx_mdio_init(struct lan78xx_net *dev)
 		/* set to internal PHY id */
 		dev->mdiobus->phy_mask = ~(1 << 1);
 		break;
+	case ID_REV_CHIP_ID_7801_:
+		/* scan thru PHYAD[2..0] */
+		dev->mdiobus->phy_mask = ~(0xFF);
+		break;
 	}
 
 	ret = mdiobus_register(dev->mdiobus);
@@ -1933,11 +1954,58 @@ static void lan78xx_remove_irq_domain(struct lan78xx_net *dev)
 	dev->domain_data.irqdomain = NULL;
 }
 
+static void lan8835_pre_config(struct lan78xx_net *dev,
+			       struct phy_device *phydev,
+			       phy_interface_t *interface)
+{
+	int buf;
+	int ret;
+
+	/* LED2/PME_N/IRQ_N/RGMII_ID pin to IRQ_N mode */
+	buf = phy_read_mmd_indirect(phydev, 32784, 3);
+	buf &= ~0x1800;
+	buf |= 0x0800;
+	phy_write_mmd_indirect(phydev, 32784, 3, buf);
+
+	/* RGMII MAC TXC Delay Enable */
+	ret = lan78xx_write_reg(dev, MAC_RGMII_ID,
+				MAC_RGMII_ID_TXC_DELAY_EN_);
+
+	/* RGMII TX DLL Tune Adjust */
+	ret = lan78xx_write_reg(dev, RGMII_TX_BYP_DLL, 0x3D00);
+
+	*interface = PHY_INTERFACE_MODE_RGMII_TXID;
+}
+
+static void ksz9031rnx_pre_config(struct lan78xx_net *dev,
+				  struct phy_device *phydev,
+				  phy_interface_t *interface)
+{
+	/* Micrel9301RNX PHY configuration */
+	/* RGMII Control Signal Pad Skew */
+	phy_write_mmd_indirect(phydev, 4, 2, 0x0077);
+	/* RGMII RX Data Pad Skew */
+	phy_write_mmd_indirect(phydev, 5, 2, 0x7777);
+	/* RGMII RX Clock Pad Skew */
+	phy_write_mmd_indirect(phydev, 8, 2, 0x1FF);
+
+	*interface = PHY_INTERFACE_MODE_RGMII_RXID;
+}
+
+/* external phyid & configure routine for LAN7801 */
+static struct ext_phy_config_table ext_phy_table[] = {
+	{ PHY_LAN8835, lan8835_pre_config },
+	{ PHY_KSZ9031RNX, ksz9031rnx_pre_config },
+	{}
+};
+
 static int lan78xx_phy_init(struct lan78xx_net *dev)
 {
 	int ret;
 	u32 mii_adv;
+	u32 masked_phyid;
 	struct phy_device *phydev = dev->net->phydev;
+	phy_interface_t interface;
 
 	phydev = phy_find_first(dev->mdiobus);
 	if (!phydev) {
@@ -1945,6 +2013,37 @@ static int lan78xx_phy_init(struct lan78xx_net *dev)
 		return -EIO;
 	}
 
+	if ((dev->chipid == ID_REV_CHIP_ID_7800_) ||
+	    (dev->chipid == ID_REV_CHIP_ID_7850_)) {
+		phydev->is_internal = true;
+		interface = PHY_INTERFACE_MODE_GMII;
+
+	} else if (dev->chipid == ID_REV_CHIP_ID_7801_) {
+		int i;
+
+		if (!phydev->drv) {
+			netdev_err(dev->net, "no PHY driver found\n");
+			return -EIO;
+		}
+
+		masked_phyid = phydev->phy_id & phydev->drv->phy_id_mask;
+		interface = PHY_INTERFACE_MODE_RGMII;
+
+		for (i = 0; ext_phy_table[i].phyid != 0; i++) {
+			if ((masked_phyid == ext_phy_table[i].phyid) &&
+			    (ext_phy_table[i].pre_config)) {
+				ext_phy_table[i].pre_config(dev,
+							    phydev,
+							    &interface);
+			}
+		}
+
+		phydev->is_internal = false;
+	} else {
+		netdev_err(dev->net, "unknown ID found\n");
+		return -EIO;
+	}
+
 	/* if phyirq is not set, use polling mode in phylib */
 	if (dev->domain_data.phyirq > 0)
 		phydev->irq = dev->domain_data.phyirq;
@@ -1957,7 +2056,7 @@ static int lan78xx_phy_init(struct lan78xx_net *dev)
 
 	ret = phy_connect_direct(dev->net, phydev,
 				 lan78xx_link_status_change,
-				 PHY_INTERFACE_MODE_GMII);
+				 interface);
 	if (ret) {
 		netdev_err(dev->net, "can't attach PHY to %s\n",
 			   dev->mdiobus->id);
@@ -2338,6 +2437,9 @@ static int lan78xx_reset(struct lan78xx_net *dev)
 	} while ((buf & PMT_CTL_PHY_RST_) || !(buf & PMT_CTL_READY_));
 
 	ret = lan78xx_read_reg(dev, MAC_CR, &buf);
+	/* LAN7801 only has RGMII mode */
+	if (dev->chipid == ID_REV_CHIP_ID_7801_)
+		buf &= ~MAC_CR_GMII_EN_;
 	buf |= MAC_CR_AUTO_DUPLEX_ | MAC_CR_AUTO_SPEED_;
 	ret = lan78xx_write_reg(dev, MAC_CR, buf);
 
@@ -2466,6 +2568,7 @@ static int lan78xx_stop(struct net_device *net)
 
 	phy_stop(net->phydev);
 	phy_disconnect(net->phydev);
+
 	net->phydev = NULL;
 
 	clear_bit(EVENT_DEV_OPEN, &dev->flags);
@@ -3887,6 +3990,10 @@ static const struct usb_device_id products[] = {
 	/* LAN7850 USB Gigabit Ethernet Device */
 	USB_DEVICE(LAN78XX_USB_VENDOR_ID, LAN7850_USB_PRODUCT_ID),
 	},
+	{
+	/* LAN7801 USB Gigabit Ethernet Device */
+	USB_DEVICE(LAN78XX_USB_VENDOR_ID, LAN7801_USB_PRODUCT_ID),
+	},
 	{},
 };
 MODULE_DEVICE_TABLE(usb, products);
diff --git a/drivers/net/usb/lan78xx.h b/drivers/net/usb/lan78xx.h
index 4092790..25aa546 100644
--- a/drivers/net/usb/lan78xx.h
+++ b/drivers/net/usb/lan78xx.h
@@ -108,6 +108,7 @@
 #define ID_REV_CHIP_REV_MASK_		(0x0000FFFF)
 #define ID_REV_CHIP_ID_7800_		(0x7800)
 #define ID_REV_CHIP_ID_7850_		(0x7850)
+#define ID_REV_CHIP_ID_7801_		(0x7801)
 
 #define FPGA_REV			(0x04)
 #define FPGA_REV_MINOR_MASK_		(0x0000FF00)
@@ -550,6 +551,7 @@
 #define LTM_INACTIVE1_TIMER10_		(0x0000FFFF)
 
 #define MAC_CR				(0x100)
+#define MAC_CR_GMII_EN_			(0x00080000)
 #define MAC_CR_EEE_TX_CLK_STOP_EN_	(0x00040000)
 #define MAC_CR_EEE_EN_			(0x00020000)
 #define MAC_CR_EEE_TLAR_EN_		(0x00010000)
@@ -787,6 +789,18 @@
 #define PHY_DEV_ID_MODEL_MASK_		(0x0FC00000)
 #define PHY_DEV_ID_OUI_MASK_		(0x003FFFFF)
 
+#define RGMII_TX_BYP_DLL		(0x708)
+#define RGMII_TX_BYP_DLL_TX_TUNE_ADJ_MASK_	(0x000FC00)
+#define RGMII_TX_BYP_DLL_TX_TUNE_SEL_MASK_	(0x00003F0)
+#define RGMII_TX_BYP_DLL_TX_DLL_RESET_		(0x0000002)
+#define RGMII_TX_BYP_DLL_TX_DLL_BYPASS_		(0x0000001)
+
+#define RGMII_RX_BYP_DLL		(0x70C)
+#define RGMII_RX_BYP_DLL_RX_TUNE_ADJ_MASK_	(0x000FC00)
+#define RGMII_RX_BYP_DLL_RX_TUNE_SEL_MASK_	(0x00003F0)
+#define RGMII_RX_BYP_DLL_RX_DLL_RESET_		(0x0000002)
+#define RGMII_RX_BYP_DLL_RX_DLL_BYPASS_		(0x0000001)
+
 #define OTP_BASE_ADDR			(0x00001000)
 #define OTP_ADDR_RANGE_			(0x1FF)
 
-- 
2.7.4

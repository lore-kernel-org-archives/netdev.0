From: <Nisar.Sayed@microchip.com>
Subject: [PATCH net 2/4] lan78xx: Add fixed_phy device support for LAN7801
 device
Date: Wed, 6 Sep 2017 10:51:44 +0000
Message-ID: <CE371C1263339941885964188A0225FA333381@CHN-SV-EXMX03.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <UNGLinuxDriver@microchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa1.microchip.iphmx.com ([68.232.147.91]:1468 "EHLO
        esa1.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752734AbdIFKwB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 06:52:01 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nisar Sayed <Nisar.Sayed@microchip.com>

Add fixed_phy device support for LAN7801 device

When LAN7801 device connected to PHY Device which does not have
MDIO/MDC access, fixex_phy device will be added.

Signed-off-by: Nisar Sayed <Nisar.Sayed@microchip.com>
---
 drivers/net/usb/Kconfig   | 10 ++++++++
 drivers/net/usb/lan78xx.c | 59 ++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 68 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index f28bd74..34ef670 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -123,6 +123,16 @@ config USB_LAN78XX
 	  To compile this driver as a module, choose M here: the
 	  module will be called lan78xx.
 
+	if USB_LAN78XX
+	  	config LAN7801_NO_MDIO_DEVICE
+	  	bool "NO MDIO Device Support"
+	  	select FIXED_PHY
+	  	---help---
+	  	If LAN7801 connected to a PHY device which does not
+	  	have MDIO/MDC access this option adds support to LAN7801
+	  	with fixed_phy support
+	endif
+
 config USB_USBNET
 	tristate "Multi-purpose USB Networking Framework"
 	select MII
diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 955ab3b..6242cb7 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -30,6 +30,7 @@
 #include <linux/ipv6.h>
 #include <linux/mdio.h>
 #include <linux/phy.h>
+#include <linux/phy_fixed.h>
 #include <net/ip6_checksum.h>
 #include <linux/interrupt.h>
 #include <linux/irqdomain.h>
@@ -42,7 +43,7 @@
 #define DRIVER_AUTHOR	"WOOJUNG HUH <woojung.huh@microchip.com>"
 #define DRIVER_DESC	"LAN78XX USB 3.0 Gigabit Ethernet Devices"
 #define DRIVER_NAME	"lan78xx"
-#define DRIVER_VERSION	"1.0.6"
+#define DRIVER_VERSION	"1.0.7"
 
 #define TX_TIMEOUT_JIFFIES		(5 * HZ)
 #define THROTTLE_JIFFIES		(HZ / 8)
@@ -335,6 +336,7 @@ struct statstage {
 	struct lan78xx_statstage64	curr_stat;
 };
 
+#ifndef CONFIG_LAN7801_NO_MDIO_DEVICE
 struct irq_domain_data {
 	struct irq_domain	*irqdomain;
 	unsigned int		phyirq;
@@ -343,6 +345,7 @@ struct irq_domain_data {
 	u32			irqenable;
 	struct mutex		irq_lock;		/* for irq bus access */
 };
+#endif
 
 struct lan78xx_net {
 	struct net_device	*net;
@@ -401,7 +404,9 @@ struct lan78xx_net {
 	int			delta;
 	struct statstage	stats;
 
+#ifndef CONFIG_LAN7801_NO_MDIO_DEVICE
 	struct irq_domain_data	domain_data;
+#endif
 };
 
 /* define external phy id */
@@ -1169,6 +1174,9 @@ static int lan78xx_link_reset(struct lan78xx_net *dev)
 		ret = lan78xx_write_reg(dev, MAC_CR, buf);
 		if (unlikely(ret < 0))
 			return -EIO;
+#ifdef CONFIG_LAN7801_NO_MDIO_DEVICE
+		phy_mac_interrupt(phydev, 0);
+#endif
 
 		del_timer(&dev->stat_monitor);
 	} else if (phydev->link && !dev->link_on) {
@@ -1209,6 +1217,9 @@ static int lan78xx_link_reset(struct lan78xx_net *dev)
 
 		ret = lan78xx_update_flowcontrol(dev, ecmd.base.duplex, ladv,
 						 radv);
+#ifdef CONFIG_LAN7801_NO_MDIO_DEVICE
+		phy_mac_interrupt(phydev, 1);
+#endif
 
 		if (!timer_pending(&dev->stat_monitor)) {
 			dev->delta = 1;
@@ -1249,8 +1260,10 @@ static void lan78xx_status(struct lan78xx_net *dev, struct urb *urb)
 		netif_dbg(dev, link, dev->net, "PHY INTR: 0x%08x\n", intdata);
 		lan78xx_defer_kevent(dev, EVENT_LINK_RESET);
 
+#ifndef CONFIG_LAN7801_NO_MDIO_DEVICE
 		if (dev->domain_data.phyirq > 0)
 			generic_handle_irq(dev->domain_data.phyirq);
+#endif
 	} else
 		netdev_warn(dev->net,
 			    "unexpected interrupt: 0x%08x\n", intdata);
@@ -1825,6 +1838,7 @@ static void lan78xx_link_status_change(struct net_device *net)
 	}
 }
 
+#ifndef CONFIG_LAN7801_NO_MDIO_DEVICE
 static int irq_map(struct irq_domain *d, unsigned int irq,
 		   irq_hw_number_t hwirq)
 {
@@ -1945,6 +1959,7 @@ static void lan78xx_remove_irq_domain(struct lan78xx_net *dev)
 	dev->domain_data.phyirq = 0;
 	dev->domain_data.irqdomain = NULL;
 }
+#endif
 
 static int lan8835_fixup(struct phy_device *phydev)
 {
@@ -1987,12 +2002,37 @@ static int ksz9031rnx_fixup(struct phy_device *phydev)
 	return 1;
 }
 
+#ifdef CONFIG_LAN7801_NO_MDIO_DEVICE
+static struct fixed_phy_status fphy_status = {
+	.link = 1,
+	.speed = SPEED_1000,
+	.duplex = DUPLEX_FULL,
+};
+#endif
+
 static int lan78xx_phy_init(struct lan78xx_net *dev)
 {
 	int ret;
 	u32 mii_adv;
 	struct phy_device *phydev = dev->net->phydev;
 
+#ifdef CONFIG_LAN7801_NO_MDIO_DEVICE
+	if (dev->chipid != ID_REV_CHIP_ID_7801_) {
+		netdev_err(dev->net, "Invalid chip id : %x\n", dev->chipid);
+		return -EIO;
+	}
+	phydev = fixed_phy_register(PHY_POLL, &fphy_status,
+				    -1, NULL);
+	if (IS_ERR(phydev)) {
+		netdev_err(dev->net, "LAN7801 Fixed PHY register failed\n");
+		return -EIO;
+	}
+	netdev_info(dev->net, "LAN7801 fixed PHY registered\n");
+
+	dev->interface = PHY_INTERFACE_MODE_RGMII;
+
+	phydev->irq = PHY_IGNORE_INTERRUPT;
+#else
 	phydev = phy_find_first(dev->mdiobus);
 	if (!phydev) {
 		netdev_err(dev->net, "no PHY found\n");
@@ -2041,6 +2081,7 @@ static int lan78xx_phy_init(struct lan78xx_net *dev)
 		phydev->irq = dev->domain_data.phyirq;
 	else
 		phydev->irq = 0;
+#endif
 	netdev_dbg(dev->net, "phydev->irq = %d\n", phydev->irq);
 
 	/* set to AUTOMDIX */
@@ -2053,8 +2094,10 @@ static int lan78xx_phy_init(struct lan78xx_net *dev)
 		netdev_err(dev->net, "can't attach PHY to %s\n",
 			   dev->mdiobus->id);
 		ret = -EIO;
+#ifndef CONFIG_LAN7801_NO_MDIO_DEVICE
 		if (dev->chipid == ID_REV_CHIP_ID_7801_)
 			goto error;
+#endif
 		return ret;
 	}
 
@@ -2499,8 +2542,10 @@ static int lan78xx_open(struct net_device *net)
 	if (ret < 0)
 		goto done;
 
+#ifndef CONFIG_LAN7801_NO_MDIO_DEVICE
 	if (dev->domain_data.phyirq > 0)
 		phy_start_interrupts(dev->net->phydev);
+#endif
 	phy_start(dev->net->phydev);
 
 	/* for Link Check */
@@ -2563,8 +2608,10 @@ static int lan78xx_stop(struct net_device *net)
 		del_timer_sync(&dev->stat_monitor);
 
 	if (net->phydev) {
+#ifndef CONFIG_LAN7801_NO_MDIO_DEVICE
 		if (dev->domain_data.phyirq > 0)
 			phy_stop_interrupts(net->phydev);
+#endif
 		phy_stop(net->phydev);
 	}
 
@@ -2844,6 +2891,7 @@ static int lan78xx_bind(struct lan78xx_net *dev, struct usb_interface *intf)
 
 	dev->net->hw_features = dev->net->features;
 
+#ifndef CONFIG_LAN7801_NO_MDIO_DEVICE
 	ret = lan78xx_setup_irq_domain(dev);
 	if (ret < 0) {
 		netdev_warn(dev->net,
@@ -2851,6 +2899,7 @@ static int lan78xx_bind(struct lan78xx_net *dev, struct usb_interface *intf)
 		kfree(pdata);
 		return ret;
 	}
+#endif
 
 	dev->net->hard_header_len += TX_OVERHEAD;
 	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
@@ -2871,8 +2920,10 @@ static void lan78xx_unbind(struct lan78xx_net *dev, struct usb_interface *intf)
 {
 	struct lan78xx_priv *pdata = (struct lan78xx_priv *)(dev->data[0]);
 
+#ifndef CONFIG_LAN7801_NO_MDIO_DEVICE
 	lan78xx_remove_irq_domain(dev);
 
+#endif
 	lan78xx_remove_mdio(dev);
 
 	if (pdata) {
@@ -3464,11 +3515,15 @@ static void lan78xx_disconnect(struct usb_interface *intf)
 	udev = interface_to_usbdev(intf);
 
 	net = dev->net;
+#ifdef CONFIG_LAN7801_NO_MDIO_DEVICE
+	fixed_phy_unregister(net->phydev);
+#else
 	if (dev->chipid == ID_REV_CHIP_ID_7801_) {
 		phy_unregister_fixup_for_uid(PHY_KSZ9031RNX, 0xfffffff0);
 		phy_unregister_fixup_for_uid(PHY_LAN8835, 0xfffffff0);
 	}
 	phy_disconnect(net->phydev);
+#endif
 	net->phydev = NULL;
 	unregister_netdev(net);
 
@@ -3982,8 +4037,10 @@ static int lan78xx_reset_resume(struct usb_interface *intf)
 
 	lan78xx_reset(dev);
 
+#ifndef CONFIG_LAN7801_NO_MDIO_DEVICE
 	if (dev->domain_data.phyirq > 0)
 		phy_start_interrupts(dev->net->phydev);
+#endif
 	phy_start(dev->net->phydev);
 
 	return lan78xx_resume(intf);
-- 
1.9.1

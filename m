From: <Woojung.Huh@microchip.com>
Subject: [PATCH net-next] lan78xx: Use irq_domain for phy interrupt from USB
 Int. EP
Date: Fri, 28 Oct 2016 18:54:54 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40956B56@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <UNGLinuxDriver@microchip.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <f.fainelli@gmail.com>, <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout.microchip.com ([198.175.253.82]:33360 "EHLO
        email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S966111AbcJ1Sy4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 14:54:56 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Woojung Huh <woojung.huh@microchip.com>

To utilize phylib with interrupt fully than handling some of phy stuff in the MAC driver,
create irq_domain for USB interrupt EP of phy interrupt and
pass the irq number to phy_connect_direct() instead of PHY_IGNORE_INTERRUPT.

Idea comes from drivers/gpio/gpio-dl2.c

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/usb/lan78xx.c | 142 +++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 128 insertions(+), 14 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index c4e748e..88ff21d 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -30,13 +30,17 @@
 #include <linux/ipv6.h>
 #include <linux/mdio.h>
 #include <net/ip6_checksum.h>
+#include <linux/interrupt.h>
+#include <linux/irqdomain.h>
+#include <linux/irq.h>
+#include <linux/irqchip/chained_irq.h>
 #include <linux/microchipphy.h>
 #include "lan78xx.h"
 
 #define DRIVER_AUTHOR	"WOOJUNG HUH <woojung.huh@microchip.com>"
 #define DRIVER_DESC	"LAN78XX USB 3.0 Gigabit Ethernet Devices"
 #define DRIVER_NAME	"lan78xx"
-#define DRIVER_VERSION	"1.0.4"
+#define DRIVER_VERSION	"1.0.5"
 
 #define TX_TIMEOUT_JIFFIES		(5 * HZ)
 #define THROTTLE_JIFFIES		(HZ / 8)
@@ -296,6 +300,13 @@ struct statstage {
 	struct lan78xx_statstage64	curr_stat;
 };
 
+struct irq_domain_data {
+	struct irq_domain	*irqdomain;
+	unsigned int		irq_base;
+	struct irq_chip		*irqchip;
+	irq_flow_handler_t	irq_handler;
+};
+
 struct lan78xx_net {
 	struct net_device	*net;
 	struct usb_device	*udev;
@@ -351,6 +362,8 @@ struct lan78xx_net {
 
 	int			delta;
 	struct statstage	stats;
+
+	struct irq_domain_data	domain_data;
 };
 
 /* use ethtool to change the level for any given device */
@@ -1120,8 +1133,6 @@ static int lan78xx_link_reset(struct lan78xx_net *dev)
 		if (unlikely(ret < 0))
 			return -EIO;
 
-		phy_mac_interrupt(phydev, 0);
-
 		del_timer(&dev->stat_monitor);
 	} else if (phydev->link && !dev->link_on) {
 		dev->link_on = true;
@@ -1163,7 +1174,6 @@ static int lan78xx_link_reset(struct lan78xx_net *dev)
 
 		ret = lan78xx_update_flowcontrol(dev, ecmd.base.duplex, ladv,
 						 radv);
-		phy_mac_interrupt(phydev, 1);
 
 		if (!timer_pending(&dev->stat_monitor)) {
 			dev->delta = 1;
@@ -1202,7 +1212,10 @@ static void lan78xx_status(struct lan78xx_net *dev, struct urb *urb)
 
 	if (intdata & INT_ENP_PHY_INT) {
 		netif_dbg(dev, link, dev->net, "PHY INTR: 0x%08x\n", intdata);
-			  lan78xx_defer_kevent(dev, EVENT_LINK_RESET);
+		lan78xx_defer_kevent(dev, EVENT_LINK_RESET);
+
+		if (dev->domain_data.irq_base > 0)
+			generic_handle_irq(dev->domain_data.irq_base);
 	} else
 		netdev_warn(dev->net,
 			    "unexpected interrupt: 0x%08x\n", intdata);
@@ -1844,6 +1857,103 @@ static void lan78xx_link_status_change(struct net_device *net)
 	}
 }
 
+static int irq_map(struct irq_domain *d, unsigned int irq,
+		   irq_hw_number_t hwirq)
+{
+	struct irq_domain_data *data = d->host_data;
+
+	irq_set_chip_data(irq, data);
+	irq_set_chip_and_handler(irq, data->irqchip, data->irq_handler);
+	irq_set_noprobe(irq);
+
+	return 0;
+}
+
+static void irq_unmap(struct irq_domain *d, unsigned int irq)
+{
+	irq_set_chip_and_handler(irq, NULL, NULL);
+	irq_set_chip_data(irq, NULL);
+}
+
+static const struct irq_domain_ops chip_domain_ops = {
+	.map	= irq_map,
+	.unmap	= irq_unmap,
+};
+
+static void lan78xx_irq_mask(struct irq_data *irqd)
+{
+	struct irq_domain_data *data = irq_data_get_irq_chip_data(irqd);
+	struct lan78xx_net *dev =
+			container_of(data, struct lan78xx_net, domain_data);
+	u32 buf;
+
+	lan78xx_read_reg(dev, INT_EP_CTL, &buf);
+	buf &= ~INT_EP_PHY_INT_EN_;
+	lan78xx_write_reg(dev, INT_EP_CTL, buf);
+}
+
+static void lan78xx_irq_unmask(struct irq_data *irqd)
+{
+	struct irq_domain_data *data = irq_data_get_irq_chip_data(irqd);
+	struct lan78xx_net *dev =
+			container_of(data, struct lan78xx_net, domain_data);
+	u32 buf;
+
+	lan78xx_read_reg(dev, INT_EP_CTL, &buf);
+	buf |= INT_EP_PHY_INT_EN_;
+	lan78xx_write_reg(dev, INT_EP_CTL, buf);
+}
+
+static struct irq_chip lan78xx_irqchip = {
+	.name		= "lan78xx-phyirq",
+	.irq_mask	= lan78xx_irq_mask,
+	.irq_unmask	= lan78xx_irq_unmask,
+};
+
+static int lan78xx_setup_irq_domain(struct lan78xx_net *dev)
+{
+	struct device_node *of_node;
+	struct irq_domain *irqdomain;
+	unsigned int irq_base = 0;
+	int ret = 0;
+
+	of_node = dev->udev->dev.parent->of_node;
+
+	dev->domain_data.irqchip = &lan78xx_irqchip;
+	dev->domain_data.irq_handler = handle_simple_irq;
+
+	irqdomain = irq_domain_add_simple(of_node, 1, 0, &chip_domain_ops,
+					  &dev->domain_data);
+	if (irqdomain) {
+		irq_base = irq_create_mapping(irqdomain, 0);
+		if (!irq_base) {
+			irq_domain_remove(irqdomain);
+
+			irqdomain = NULL;
+			ret = -EINVAL;
+		}
+	} else {
+		ret = -EINVAL;
+	}
+
+	dev->domain_data.irqdomain = irqdomain;
+	dev->domain_data.irq_base = irq_base;
+
+	return ret;
+}
+
+static void lan78xx_remove_irq_domain(struct lan78xx_net *dev)
+{
+	if (dev->domain_data.irq_base > 0) {
+		irq_dispose_mapping(dev->domain_data.irq_base);
+
+		if (dev->domain_data.irqdomain)
+			irq_domain_remove(dev->domain_data.irqdomain);
+	}
+	dev->domain_data.irq_base = 0;
+	dev->domain_data.irqdomain = NULL;
+}
+
 static int lan78xx_phy_init(struct lan78xx_net *dev)
 {
 	int ret;
@@ -1856,15 +1966,12 @@ static int lan78xx_phy_init(struct lan78xx_net *dev)
 		return -EIO;
 	}
 
-	/* Enable PHY interrupts.
-	 * We handle our own interrupt
-	 */
-	ret = phy_read(phydev, LAN88XX_INT_STS);
-	ret = phy_write(phydev, LAN88XX_INT_MASK,
-			LAN88XX_INT_MASK_MDINTPIN_EN_ |
-			LAN88XX_INT_MASK_LINK_CHANGE_);
-
-	phydev->irq = PHY_IGNORE_INTERRUPT;
+	/* if irq_base is not set, use polling mode in phylib */
+	if (dev->domain_data.irq_base > 0)
+		phydev->irq = dev->domain_data.irq_base;
+	else
+		phydev->irq = 0;
+	netdev_dbg(dev->net, "phydev->irq = %d\n", phydev->irq);
 
 	ret = phy_connect_direct(dev->net, phydev,
 				 lan78xx_link_status_change,
@@ -2668,6 +2775,11 @@ static int lan78xx_bind(struct lan78xx_net *dev, struct usb_interface *intf)
 
 	dev->net->hw_features = dev->net->features;
 
+	if (lan78xx_setup_irq_domain(dev) < 0) {
+		netdev_warn(dev->net, "lan78xx_setup_irq_domain() failed");
+		return -EIO;
+	}
+
 	/* Init all registers */
 	ret = lan78xx_reset(dev);
 
@@ -2684,6 +2796,8 @@ static void lan78xx_unbind(struct lan78xx_net *dev, struct usb_interface *intf)
 {
 	struct lan78xx_priv *pdata = (struct lan78xx_priv *)(dev->data[0]);
 
+	lan78xx_remove_irq_domain(dev);
+
 	lan78xx_remove_mdio(dev);
 
 	if (pdata) {
-- 
2.7.4

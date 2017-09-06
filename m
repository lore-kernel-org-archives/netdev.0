From: <Nisar.Sayed@microchip.com>
Subject: [PATCH net 1/4] lan78xx: Fix for crash associated with System
 suspend
Date: Wed, 6 Sep 2017 10:51:31 +0000
Message-ID: <CE371C1263339941885964188A0225FA333370@CHN-SV-EXMX03.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <UNGLinuxDriver@microchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa5.microchip.iphmx.com ([216.71.150.166]:65533 "EHLO
        esa5.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753117AbdIFKwP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 06:52:15 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nisar Sayed <Nisar.Sayed@microchip.com>

Fix for crash associated with System suspend

Since ndo_stop removes phydev which makes phydev NULL.
Whenever system suspend is initiated or after "ifconfig <interface> down",
if set_wol or get_wol is triggered phydev is NULL leads system crash.
Hence phy_start/phy_stop for ndo_start/ndo_stop fixes the issues
instead of adding/removing phydevice

Signed-off-by: Nisar Sayed <Nisar.Sayed@microchip.com>
---
 drivers/net/usb/lan78xx.c | 44 ++++++++++++++++++++++++++++----------------
 1 file changed, 28 insertions(+), 16 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index b99a7fb..955ab3b 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -2024,6 +2024,8 @@ static int lan78xx_phy_init(struct lan78xx_net *dev)
 						 lan8835_fixup);
 		if (ret < 0) {
 			netdev_err(dev->net, "fail to register fixup\n");
+			phy_unregister_fixup_for_uid(PHY_KSZ9031RNX,
+						     0xfffffff0);
 			return ret;
 		}
 		/* add more external PHY fixup here if needed */
@@ -2031,8 +2033,7 @@ static int lan78xx_phy_init(struct lan78xx_net *dev)
 		phydev->is_internal = false;
 	} else {
 		netdev_err(dev->net, "unknown ID found\n");
-		ret = -EIO;
-		goto error;
+		return -EIO;
 	}
 
 	/* if phyirq is not set, use polling mode in phylib */
@@ -2051,7 +2052,10 @@ static int lan78xx_phy_init(struct lan78xx_net *dev)
 	if (ret) {
 		netdev_err(dev->net, "can't attach PHY to %s\n",
 			   dev->mdiobus->id);
-		return -EIO;
+		ret = -EIO;
+		if (dev->chipid == ID_REV_CHIP_ID_7801_)
+			goto error;
+		return ret;
 	}
 
 	/* MAC doesn't support 1000T Half */
@@ -2067,8 +2071,6 @@ static int lan78xx_phy_init(struct lan78xx_net *dev)
 
 	dev->fc_autoneg = phydev->autoneg;
 
-	phy_start(phydev);
-
 	netif_dbg(dev, ifup, dev->net, "phy initialised successfully");
 
 	return 0;
@@ -2497,9 +2499,9 @@ static int lan78xx_open(struct net_device *net)
 	if (ret < 0)
 		goto done;
 
-	ret = lan78xx_phy_init(dev);
-	if (ret < 0)
-		goto done;
+	if (dev->domain_data.phyirq > 0)
+		phy_start_interrupts(dev->net->phydev);
+	phy_start(dev->net->phydev);
 
 	/* for Link Check */
 	if (dev->urb_intr) {
@@ -2560,13 +2562,11 @@ static int lan78xx_stop(struct net_device *net)
 	if (timer_pending(&dev->stat_monitor))
 		del_timer_sync(&dev->stat_monitor);
 
-	phy_unregister_fixup_for_uid(PHY_KSZ9031RNX, 0xfffffff0);
-	phy_unregister_fixup_for_uid(PHY_LAN8835, 0xfffffff0);
-
-	phy_stop(net->phydev);
-	phy_disconnect(net->phydev);
-
-	net->phydev = NULL;
+	if (net->phydev) {
+		if (dev->domain_data.phyirq > 0)
+			phy_stop_interrupts(net->phydev);
+		phy_stop(net->phydev);
+	}
 
 	clear_bit(EVENT_DEV_OPEN, &dev->flags);
 	netif_stop_queue(net);
@@ -3464,6 +3464,12 @@ static void lan78xx_disconnect(struct usb_interface *intf)
 	udev = interface_to_usbdev(intf);
 
 	net = dev->net;
+	if (dev->chipid == ID_REV_CHIP_ID_7801_) {
+		phy_unregister_fixup_for_uid(PHY_KSZ9031RNX, 0xfffffff0);
+		phy_unregister_fixup_for_uid(PHY_LAN8835, 0xfffffff0);
+	}
+	phy_disconnect(net->phydev);
+	net->phydev = NULL;
 	unregister_netdev(net);
 
 	cancel_delayed_work_sync(&dev->wq);
@@ -3613,6 +3619,10 @@ static int lan78xx_probe(struct usb_interface *intf,
 		goto out3;
 	}
 
+	ret = lan78xx_phy_init(dev);
+	if (ret < 0)
+		goto out3;
+
 	usb_set_intfdata(intf, dev);
 
 	ret = device_set_wakeup_enable(&udev->dev, true);
@@ -3972,7 +3982,9 @@ static int lan78xx_reset_resume(struct usb_interface *intf)
 
 	lan78xx_reset(dev);
 
-	lan78xx_phy_init(dev);
+	if (dev->domain_data.phyirq > 0)
+		phy_start_interrupts(dev->net->phydev);
+	phy_start(dev->net->phydev);
 
 	return lan78xx_resume(intf);
 }
-- 
1.9.1

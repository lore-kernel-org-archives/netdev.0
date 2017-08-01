From: <Nisar.Sayed@microchip.com>
Subject: [PATCH net 1/2] lan78xx: USB fast connect/disconnect crash fix
Date: Tue, 1 Aug 2017 10:24:17 +0000
Message-ID: <CE371C1263339941885964188A0225FA322BD6@CHN-SV-EXMX03.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <UNGLinuxDriver@microchip.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa4.microchip.iphmx.com ([68.232.154.123]:33451 "EHLO
        esa4.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751784AbdHAKZE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 06:25:04 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nisar Sayed <Nisar.Sayed@microchip.com>

USB fast connect/disconnect crash fix

When USB plugged/unplugged at fast rate,
lan78xx_mdio_init() in lan78xx_bind() failing case is not handled.
Whenever  lan78xx_mdio_init() failed, dev->mdiobus will be freed, however
since lan78xx_bind() not consider as error and try to proceed for
further initialization in lan78xx_probe() which leads system hung/crash.
Also when register_netdev() failed, netdev is freed without calling lan78xx_unbind().
Hence halting the failed cases right manner fixes the system crash/hung issue.

Signed-off-by: Nisar Sayed <Nisar.Sayed@microchip.com>
---
 drivers/net/usb/lan78xx.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 5833f7e..8ef3639 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -2858,13 +2858,13 @@ static int lan78xx_bind(struct lan78xx_net *dev, struct usb_interface *intf)
 	/* Init all registers */
 	ret = lan78xx_reset(dev);
 
-	lan78xx_mdio_init(dev);
+	ret = lan78xx_mdio_init(dev);
 
 	dev->net->flags |= IFF_MULTICAST;
 
 	pdata->wol = WAKE_MAGIC;
 
-	return 0;
+	return ret;
 }
 
 static void lan78xx_unbind(struct lan78xx_net *dev, struct usb_interface *intf)
@@ -3525,11 +3525,11 @@ static int lan78xx_probe(struct usb_interface *intf,
 	udev = interface_to_usbdev(intf);
 	udev = usb_get_dev(udev);
 
-	ret = -ENOMEM;
 	netdev = alloc_etherdev(sizeof(struct lan78xx_net));
 	if (!netdev) {
-			dev_err(&intf->dev, "Error: OOM\n");
-			goto out1;
+		dev_err(&intf->dev, "Error: OOM\n");
+		ret = -ENOMEM;
+		goto out1;
 	}
 
 	/* netdev_printk() needs this */
@@ -3610,7 +3610,7 @@ static int lan78xx_probe(struct usb_interface *intf,
 	ret = register_netdev(netdev);
 	if (ret != 0) {
 		netif_err(dev, probe, netdev, "couldn't register the device\n");
-		goto out2;
+		goto out3;
 	}
 
 	usb_set_intfdata(intf, dev);
-- 
1.9.1

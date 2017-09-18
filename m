From: Nisar Sayed <Nisar.Sayed@microchip.com>
Subject: [PATCH v4 net 1/3] lan78xx: Fix for eeprom read/write when device auto suspend
Date: Tue, 19 Sep 2017 03:32:23 +0530
Message-ID: <20170918220225.3767-2-Nisar.Sayed@microchip.com>
References: <20170918220225.3767-1-Nisar.Sayed@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa5.microchip.iphmx.com ([216.71.150.166]:5780 "EHLO
        esa5.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932746AbdIRQju (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 12:39:50 -0400
In-Reply-To: <20170918220225.3767-1-Nisar.Sayed@microchip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix for eeprom read/write when device auto suspend

Fixes: 55d7de9de6c3 ("Microchip's LAN7800 family USB 2/3 to 10/100/1000 Ethernet device driver")
Signed-off-by: Nisar Sayed <Nisar.Sayed@microchip.com>
---
 drivers/net/usb/lan78xx.c | 24 ++++++++++++++++++++----
 1 file changed, 20 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index b99a7fb09f8e..fcf85ae37435 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -1265,30 +1265,46 @@ static int lan78xx_ethtool_get_eeprom(struct net_device *netdev,
 				      struct ethtool_eeprom *ee, u8 *data)
 {
 	struct lan78xx_net *dev = netdev_priv(netdev);
+	int ret;
+
+	ret = usb_autopm_get_interface(dev->intf);
+	if (ret)
+		return ret;
 
 	ee->magic = LAN78XX_EEPROM_MAGIC;
 
-	return lan78xx_read_raw_eeprom(dev, ee->offset, ee->len, data);
+	ret = lan78xx_read_raw_eeprom(dev, ee->offset, ee->len, data);
+
+	usb_autopm_put_interface(dev->intf);
+
+	return ret;
 }
 
 static int lan78xx_ethtool_set_eeprom(struct net_device *netdev,
 				      struct ethtool_eeprom *ee, u8 *data)
 {
 	struct lan78xx_net *dev = netdev_priv(netdev);
+	int ret;
+
+	ret = usb_autopm_get_interface(dev->intf);
+	if (ret)
+		return ret;
 
 	/* Allow entire eeprom update only */
 	if ((ee->magic == LAN78XX_EEPROM_MAGIC) &&
 	    (ee->offset == 0) &&
 	    (ee->len == 512) &&
 	    (data[0] == EEPROM_INDICATOR))
-		return lan78xx_write_raw_eeprom(dev, ee->offset, ee->len, data);
+		ret = lan78xx_write_raw_eeprom(dev, ee->offset, ee->len, data);
 	else if ((ee->magic == LAN78XX_OTP_MAGIC) &&
 		 (ee->offset == 0) &&
 		 (ee->len == 512) &&
 		 (data[0] == OTP_INDICATOR_1))
-		return lan78xx_write_raw_otp(dev, ee->offset, ee->len, data);
+		ret = lan78xx_write_raw_otp(dev, ee->offset, ee->len, data);
 
-	return -EINVAL;
+	usb_autopm_put_interface(dev->intf);
+
+	return ret;
 }
 
 static void lan78xx_get_strings(struct net_device *netdev, u32 stringset,
-- 
2.14.1

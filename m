From: <Nisar.Sayed@microchip.com>
Subject: [PATCH net 1/3] lan78xx: Fix for eeprom read/write when device
 autosuspend
Date: Thu, 7 Sep 2017 07:11:06 +0000
Message-ID: <CE371C1263339941885964188A0225FA333A6B@CHN-SV-EXMX03.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa5.microchip.iphmx.com ([216.71.150.166]:49698 "EHLO
        esa5.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752315AbdIGHLY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 03:11:24 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nisar Sayed <Nisar.Sayed@microchip.com>

Fix for eeprom read/write when device autosuspend

Signed-off-by: Nisar Sayed <Nisar.Sayed@microchip.com>
---
 drivers/net/usb/lan78xx.c | 22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index b99a7fb..baf91c7 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -1265,30 +1265,44 @@ static int lan78xx_ethtool_get_eeprom(struct net_device *netdev,
 				      struct ethtool_eeprom *ee, u8 *data)
 {
 	struct lan78xx_net *dev = netdev_priv(netdev);
+	int ret = -EINVAL;
+
+	if (usb_autopm_get_interface(dev->intf) < 0)
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
+	int ret = -EINVAL;
+
+	if (usb_autopm_get_interface(dev->intf) < 0)
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
1.9.1

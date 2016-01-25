From: <Woojung.Huh@microchip.com>
Subject: [PATCH net 3/4] lan78xx: Add to handle mux control per chip id
Date: Mon, 25 Jan 2016 23:03:25 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D4049DEE7@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:30935 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933449AbcAYXD1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 18:03:27 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Depends on chip, some EEPROM pins are muxed with LED function.
Disable & restore LED function to access EEPROM.

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/usb/lan78xx.c | 92 ++++++++++++++++++++++++++++++++++-------------
 1 file changed, 67 insertions(+), 25 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 7a8391b..9b95333 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -463,32 +463,53 @@ static int lan78xx_read_raw_eeprom(struct lan78xx_net *dev, u32 offset,
 				   u32 length, u8 *data)
 {
 	u32 val;
+	u32 saved;
 	int i, ret;
+	int retval;
 
-	ret = lan78xx_eeprom_confirm_not_busy(dev);
-	if (ret)
-		return ret;
+	/* depends on chip, some EEPROM pins are muxed with LED function.
+	 * disable & restore LED function to access EEPROM.
+	 */
+	ret = lan78xx_read_reg(dev, HW_CFG, &val);
+	saved = val;
+	if (dev->chipid == ID_REV_CHIP_ID_7800_) {
+		val &= ~(HW_CFG_LED1_EN_ | HW_CFG_LED0_EN_);
+		ret = lan78xx_write_reg(dev, HW_CFG, val);
+	}
+
+	retval = lan78xx_eeprom_confirm_not_busy(dev);
+	if (retval)
+		goto exit;
 
 	for (i = 0; i < length; i++) {
 		val = E2P_CMD_EPC_BUSY_ | E2P_CMD_EPC_CMD_READ_;
 		val |= (offset & E2P_CMD_EPC_ADDR_MASK_);
 		ret = lan78xx_write_reg(dev, E2P_CMD, val);
-		if (unlikely(ret < 0))
-			return -EIO;
+		if (unlikely(ret < 0)) {
+			retval = -EIO;
+			goto exit;
+		}
 
-		ret = lan78xx_wait_eeprom(dev);
-		if (ret < 0)
-			return ret;
+		retval = lan78xx_wait_eeprom(dev);
+		if (retval < 0)
+			goto exit;
 
 		ret = lan78xx_read_reg(dev, E2P_DATA, &val);
-		if (unlikely(ret < 0))
-			return -EIO;
+		if (unlikely(ret < 0)) {
+			retval = -EIO;
+			goto exit;
+		}
 
 		data[i] = val & 0xFF;
 		offset++;
 	}
 
-	return 0;
+	retval = 0;
+exit:
+	if (dev->chipid == ID_REV_CHIP_ID_7800_)
+		ret = lan78xx_write_reg(dev, HW_CFG, saved);
+
+	return retval;
 }
 
 static int lan78xx_read_eeprom(struct lan78xx_net *dev, u32 offset,
@@ -510,11 +531,23 @@ static int lan78xx_write_raw_eeprom(struct lan78xx_net *dev, u32 offset,
 				    u32 length, u8 *data)
 {
 	u32 val;
+	u32 saved;
 	int i, ret;
+	int retval;
 
-	ret = lan78xx_eeprom_confirm_not_busy(dev);
-	if (ret)
-		return ret;
+	/* depends on chip, some EEPROM pins are muxed with LED function.
+	 * disable & restore LED function to access EEPROM.
+	 */
+	ret = lan78xx_read_reg(dev, HW_CFG, &val);
+	saved = val;
+	if (dev->chipid == ID_REV_CHIP_ID_7800_) {
+		val &= ~(HW_CFG_LED1_EN_ | HW_CFG_LED0_EN_);
+		ret = lan78xx_write_reg(dev, HW_CFG, val);
+	}
+
+	retval = lan78xx_eeprom_confirm_not_busy(dev);
+	if (retval)
+		goto exit;
 
 	/* Issue write/erase enable command */
 	val = E2P_CMD_EPC_BUSY_ | E2P_CMD_EPC_CMD_EWEN_;
@@ -522,32 +555,41 @@ static int lan78xx_write_raw_eeprom(struct lan78xx_net *dev, u32 offset,
 	if (unlikely(ret < 0))
 		return -EIO;
 
-	ret = lan78xx_wait_eeprom(dev);
-	if (ret < 0)
-		return ret;
+	retval = lan78xx_wait_eeprom(dev);
+	if (retval < 0)
+		goto exit;
 
 	for (i = 0; i < length; i++) {
 		/* Fill data register */
 		val = data[i];
 		ret = lan78xx_write_reg(dev, E2P_DATA, val);
-		if (ret < 0)
-			return ret;
+		if (ret < 0) {
+			retval = -EIO;
+			goto exit;
+		}
 
 		/* Send "write" command */
 		val = E2P_CMD_EPC_BUSY_ | E2P_CMD_EPC_CMD_WRITE_;
 		val |= (offset & E2P_CMD_EPC_ADDR_MASK_);
 		ret = lan78xx_write_reg(dev, E2P_CMD, val);
-		if (ret < 0)
-			return ret;
+		if (ret < 0) {
+			retval = -EIO;
+			goto exit;
+		}
 
-		ret = lan78xx_wait_eeprom(dev);
-		if (ret < 0)
-			return ret;
+		retval = lan78xx_wait_eeprom(dev);
+		if (retval < 0)
+			goto exit;
 
 		offset++;
 	}
 
-	return 0;
+	retval = 0;
+exit:
+	if (dev->chipid == ID_REV_CHIP_ID_7800_)
+		ret = lan78xx_write_reg(dev, HW_CFG, saved);
+
+	return retval;
 }
 
 static int lan78xx_read_raw_otp(struct lan78xx_net *dev, u32 offset,
-- 
2.1.4

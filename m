From: <Woojung.Huh@microchip.com>
Subject: [PATCH] net: lan78xx: Fix to write to OTP(One Time Programmable)
 per magic number.
Date: Tue, 5 Jan 2016 17:29:59 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D4049271B@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp01.microchip.com ([198.175.253.37]:47440 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752359AbcAERfL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 12:35:11 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a bug writing to EEPROM in lan78xx_ethtool_set_eeprom()
when asked to write to OTP.

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/usb/lan78xx.c | 55 ++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 54 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 226668e..d54f536 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -603,6 +603,59 @@ static int lan78xx_read_raw_otp(struct lan78xx_net *dev, u32 offset,
 	return 0;
 }
 
+static int lan78xx_write_raw_otp(struct lan78xx_net *dev, u32 offset,
+				 u32 length, u8 *data)
+{
+	int i;
+	int ret;
+	u32 buf;
+	unsigned long timeout;
+
+	ret = lan78xx_read_reg(dev, OTP_PWR_DN, &buf);
+
+	if (buf & OTP_PWR_DN_PWRDN_N_) {
+		/* clear it and wait to be cleared */
+		ret = lan78xx_write_reg(dev, OTP_PWR_DN, 0);
+
+		timeout = jiffies + HZ;
+		do {
+			udelay(1);
+			ret = lan78xx_read_reg(dev, OTP_PWR_DN, &buf);
+			if (time_after(jiffies, timeout)) {
+				netdev_warn(dev->net,
+					    "timeout on OTP_PWR_DN completion");
+				return -EIO;
+			}
+		} while (buf & OTP_PWR_DN_PWRDN_N_);
+	}
+
+	/* set to BYTE program mode */
+	ret = lan78xx_write_reg(dev, OTP_PRGM_MODE, OTP_PRGM_MODE_BYTE_);
+
+	for (i = 0; i < length; i++) {
+		ret = lan78xx_write_reg(dev, OTP_ADDR1,
+					((offset + i) >> 8) & OTP_ADDR1_15_11);
+		ret = lan78xx_write_reg(dev, OTP_ADDR2,
+					((offset + i) & OTP_ADDR2_10_3));
+		ret = lan78xx_write_reg(dev, OTP_PRGM_DATA, data[i]);
+		ret = lan78xx_write_reg(dev, OTP_TST_CMD, OTP_TST_CMD_PRGVRFY_);
+		ret = lan78xx_write_reg(dev, OTP_CMD_GO, OTP_CMD_GO_GO_);
+
+		timeout = jiffies + HZ;
+		do {
+			udelay(1);
+			ret = lan78xx_read_reg(dev, OTP_STATUS, &buf);
+			if (time_after(jiffies, timeout)) {
+				netdev_warn(dev->net,
+					    "Timeout on OTP_STATUS completion");
+				return -EIO;
+			}
+		} while (buf & OTP_STATUS_BUSY_);
+	}
+
+	return 0;
+}
+
 static int lan78xx_read_otp(struct lan78xx_net *dev, u32 offset,
 			    u32 length, u8 *data)
 {
@@ -969,7 +1022,7 @@ static int lan78xx_ethtool_set_eeprom(struct net_device *netdev,
 		 (ee->offset == 0) &&
 		 (ee->len == 512) &&
 		 (data[0] == OTP_INDICATOR_1))
-		return lan78xx_write_raw_eeprom(dev, ee->offset, ee->len, data);
+		return lan78xx_write_raw_otp(dev, ee->offset, ee->len, data);
 
 	return -EINVAL;
 }
-- 
2.1.4

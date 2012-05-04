From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 3/3] smsc75xx: let EEPROM determine GPIO/LED settings
Date: Fri,  4 May 2012 11:57:13 +0100
Message-ID: <1336129033-15826-4-git-send-email-steve.glendinning@shawell.net>
References: <1336129033-15826-1-git-send-email-steve.glendinning@shawell.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:55616 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755590Ab2EDK5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 06:57:21 -0400
In-Reply-To: <1336129033-15826-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows the GPIO/LED settings to be configured by the
EEPROM if present, and only sets the default values (LED outputs
for link/activity) when an EEPROM is not detected.

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc75xx.c |   19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 72b62b5..fb1a087 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -903,15 +903,20 @@ static int smsc75xx_reset(struct usbnet *dev)
 
 	netif_dbg(dev, ifup, dev->net, "ID_REV = 0x%08x", buf);
 
-	/* Configure GPIO pins as LED outputs */
-	ret = smsc75xx_read_reg(dev, LED_GPIO_CFG, &buf);
-	check_warn_return(ret, "Failed to read LED_GPIO_CFG: %d", ret);
+	ret = smsc75xx_read_reg(dev, E2P_CMD, &buf);
+	check_warn_return(ret, "Failed to read E2P_CMD: %d", ret);
 
-	buf &= ~(LED_GPIO_CFG_LED2_FUN_SEL | LED_GPIO_CFG_LED10_FUN_SEL);
-	buf |= LED_GPIO_CFG_LEDGPIO_EN | LED_GPIO_CFG_LED2_FUN_SEL;
+	/* only set default GPIO/LED settings if no EEPROM is detected */
+	if (!(buf & E2P_CMD_LOADED)) {
+		ret = smsc75xx_read_reg(dev, LED_GPIO_CFG, &buf);
+		check_warn_return(ret, "Failed to read LED_GPIO_CFG: %d", ret);
 
-	ret = smsc75xx_write_reg(dev, LED_GPIO_CFG, buf);
-	check_warn_return(ret, "Failed to write LED_GPIO_CFG: %d", ret);
+		buf &= ~(LED_GPIO_CFG_LED2_FUN_SEL | LED_GPIO_CFG_LED10_FUN_SEL);
+		buf |= LED_GPIO_CFG_LEDGPIO_EN | LED_GPIO_CFG_LED2_FUN_SEL;
+
+		ret = smsc75xx_write_reg(dev, LED_GPIO_CFG, buf);
+		check_warn_return(ret, "Failed to write LED_GPIO_CFG: %d", ret);
+	}
 
 	ret = smsc75xx_write_reg(dev, FLOW, 0);
 	check_warn_return(ret, "Failed to write FLOW: %d", ret);
-- 
1.7.9.5

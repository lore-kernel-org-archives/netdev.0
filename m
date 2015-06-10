From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/2] net: phy: mdio-bcm-unimac: handle broken turn-around for specific PHYs
Date: Wed, 10 Jun 2015 12:14:03 -0700
Message-ID: <1433963643-15851-3-git-send-email-f.fainelli@gmail.com>
References: <1433963643-15851-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:32945 "EHLO
	mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752251AbbFJTPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 15:15:18 -0400
Received: by qkhg32 with SMTP id g32so30298051qkh.0
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 12:15:17 -0700 (PDT)
In-Reply-To: <1433963643-15851-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some Ethernet PHYs/switches such as Broadcom's BCM53125 have a hardware bug
which makes them not release the MDIO line during turn-around time.  This gets
flagged by the UniMAC MDIO controller as a read failure, and we fail the read
transaction.

Check the MDIO bus phy_ignore_ta_mask bitmask for the PHY we are reading
from and if it is listed in this bitmask, ignore the read failure and
proceed with returning the data we read out of the controller.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/mdio-bcm-unimac.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/mdio-bcm-unimac.c b/drivers/net/phy/mdio-bcm-unimac.c
index 414fdf1f343f..2237d5554e02 100644
--- a/drivers/net/phy/mdio-bcm-unimac.c
+++ b/drivers/net/phy/mdio-bcm-unimac.c
@@ -16,6 +16,7 @@
 #include <linux/module.h>
 #include <linux/io.h>
 #include <linux/delay.h>
+#include <linux/brcmphy.h>
 
 #include <linux/of.h>
 #include <linux/of_platform.h>
@@ -81,7 +82,7 @@ static int unimac_mdio_read(struct mii_bus *bus, int phy_id, int reg)
 		return -ETIMEDOUT;
 
 	cmd = __raw_readl(priv->base + MDIO_CMD);
-	if (cmd & MDIO_READ_FAIL)
+	if (!(bus->phy_ignore_ta_mask & 1 << phy_id) && (cmd & MDIO_READ_FAIL))
 		return -EIO;
 
 	return cmd & 0xffff;
-- 
2.1.0

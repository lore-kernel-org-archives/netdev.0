From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 04/10] smsc911x: allow mac address to be saved before device reset
Date: Tue, 27 Jan 2009 16:51:12 +0000
Message-ID: <1233075077-17205-5-git-send-email-steve.glendinning@smsc.com>
References: <1233075077-17205-1-git-send-email-steve.glendinning@smsc.com>
 <1233075077-17205-2-git-send-email-steve.glendinning@smsc.com>
 <1233075077-17205-3-git-send-email-steve.glendinning@smsc.com>
 <1233075077-17205-4-git-send-email-steve.glendinning@smsc.com>
Cc: David Miller <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Stanley Miao <stanley.miao@windriver.com>,
	Ian Saturley <ian.saturley@smsc.com>,
	Mark Brown <broonie@opensource.wolfsonmicro.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.114] ([86.54.240.114]:53200 "EHLO
	kensington.shawell.net" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756090AbZA0QvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 11:51:19 -0500
In-Reply-To: <1233075077-17205-4-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some platforms (for example pcm037) do not have an EEPROM fitted,
instead storing their mac address somewhere else.  The bootloader
fetches this and configures the ethernet adapter before the kernel is
started.

This patch allows a platform to indicate to the driver via the
SMSC911X_SAVE_MAC_ADDRESS flag that the mac address has already been
configured via such a mechanism, and should be saved before resetting
the chip.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
Acked-by: Sascha Hauer <s.hauer@pengutronix.de>
Tested-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/smsc911x.c   |   30 ++++++++++++++++++++++--------
 include/linux/smsc911x.h |    1 +
 2 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index c7379f5..2f7399e 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1748,6 +1748,21 @@ static const struct net_device_ops smsc911x_netdev_ops = {
 #endif
 };
 
+/* copies the current mac address from hardware to dev->dev_addr */
+static void __devinit smsc911x_read_mac_address(struct net_device *dev)
+{
+	struct smsc911x_data *pdata = netdev_priv(dev);
+	u32 mac_high16 = smsc911x_mac_read(pdata, ADDRH);
+	u32 mac_low32 = smsc911x_mac_read(pdata, ADDRL);
+
+	dev->dev_addr[0] = (u8)(mac_low32);
+	dev->dev_addr[1] = (u8)(mac_low32 >> 8);
+	dev->dev_addr[2] = (u8)(mac_low32 >> 16);
+	dev->dev_addr[3] = (u8)(mac_low32 >> 24);
+	dev->dev_addr[4] = (u8)(mac_high16);
+	dev->dev_addr[5] = (u8)(mac_high16 >> 8);
+}
+
 /* Initializing private device structures, only called from probe */
 static int __devinit smsc911x_init(struct net_device *dev)
 {
@@ -1835,6 +1850,12 @@ static int __devinit smsc911x_init(struct net_device *dev)
 		SMSC_WARNING(PROBE,
 			"This driver is not intended for this chip revision");
 
+	/* workaround for platforms without an eeprom, where the mac address
+	 * is stored elsewhere and set by the bootloader.  This saves the
+	 * mac address before resetting the device */
+	if (pdata->config.flags & SMSC911X_SAVE_MAC_ADDRESS)
+		smsc911x_read_mac_address(dev);
+
 	/* Reset the LAN911x */
 	if (smsc911x_soft_reset(pdata))
 		return -ENODEV;
@@ -2015,14 +2036,7 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 	} else {
 		/* Try reading mac address from device. if EEPROM is present
 		 * it will already have been set */
-		u32 mac_high16 = smsc911x_mac_read(pdata, ADDRH);
-		u32 mac_low32 = smsc911x_mac_read(pdata, ADDRL);
-		dev->dev_addr[0] = (u8)(mac_low32);
-		dev->dev_addr[1] = (u8)(mac_low32 >> 8);
-		dev->dev_addr[2] = (u8)(mac_low32 >> 16);
-		dev->dev_addr[3] = (u8)(mac_low32 >> 24);
-		dev->dev_addr[4] = (u8)(mac_high16);
-		dev->dev_addr[5] = (u8)(mac_high16 >> 8);
+		smsc911x_read_mac_address(dev);
 
 		if (is_valid_ether_addr(dev->dev_addr)) {
 			/* eeprom values are valid  so use them */
diff --git a/include/linux/smsc911x.h b/include/linux/smsc911x.h
index 170c76b..b327250 100644
--- a/include/linux/smsc911x.h
+++ b/include/linux/smsc911x.h
@@ -45,5 +45,6 @@ struct smsc911x_platform_config {
 #define SMSC911X_USE_32BIT 			(BIT(1))
 #define SMSC911X_FORCE_INTERNAL_PHY		(BIT(2))
 #define SMSC911X_FORCE_EXTERNAL_PHY 		(BIT(3))
+#define SMSC911X_SAVE_MAC_ADDRESS		(BIT(4))
 
 #endif /* __LINUX_SMSC911X_H__ */
-- 
1.6.0.6


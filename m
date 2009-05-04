From: Daniel Mack <daniel@caiaq.de>
Subject: [PATCH] net: smsc911x: add power management functions
Date: Mon,  4 May 2009 19:12:02 +0200
Message-ID: <1241457122-28161-1-git-send-email-daniel@caiaq.de>
Cc: Daniel Mack <daniel@caiaq.de>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from buzzloop.caiaq.de ([212.112.241.133]:57626 "EHLO
	buzzloop.caiaq.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750869AbZEDRMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 13:12:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a power management implementation for smsc911x.c which assumes
the chips remains powered during suspend. The device is put in its D1
power saving mode.

Cc: Steve Glendinning <steve.glendinning@smsc.com>
Signed-off-by: Daniel Mack <daniel@caiaq.de>
---
 drivers/net/smsc911x.c |   46 ++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 46 insertions(+), 0 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index eb7db03..77d164e 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -2096,12 +2096,58 @@ out_0:
 	return retval;
 }
 
+#ifdef CONFIG_PM
+/* This implementation assumes the devices remains powered on its VDDVARIO
+ * pins during suspend. */
+
+static int smsc911x_suspend(struct platform_device *pdev, pm_message_t state)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+	struct smsc911x_data *pdata = netdev_priv(dev);
+
+	/* enable wake on LAN, energy detection and the external PME
+	 * signal. */
+	smsc911x_reg_write(pdata, PMT_CTRL,
+		PMT_CTRL_PM_MODE_D1_ | PMT_CTRL_WOL_EN_ |
+		PMT_CTRL_ED_EN_ | PMT_CTRL_PME_EN_);
+
+	return 0;
+}
+
+static int smsc911x_resume(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+	struct smsc911x_data *pdata = netdev_priv(dev);
+	unsigned int to = 100;
+
+	/* Note 3.11 from the datasheet:
+	 * 	"When the LAN9220 is in a power saving state, a write of any
+	 * 	 data to the BYTE_TEST register will wake-up the device."
+	 */
+	smsc911x_reg_write(pdata, BYTE_TEST, 0);
+
+	/* poll the READY bit in PMT_CTRL. Any other access to the device is
+	 * forbidden while this bit isn't set. Try for 100ms and return -EIO
+	 * if it failed. */
+	while (!(smsc911x_reg_read(pdata, PMT_CTRL) & PMT_CTRL_READY_) && to--)
+		udelay(1000);
+
+	return (to == 0) ? -EIO : 0;
+}
+
+#else
+#define smsc911x_suspend	NULL
+#define smsc911x_resume		NULL
+#endif
+
 static struct platform_driver smsc911x_driver = {
 	.probe = smsc911x_drv_probe,
 	.remove = smsc911x_drv_remove,
 	.driver = {
 		.name = SMSC_CHIPNAME,
 	},
+	.suspend = smsc911x_suspend,
+	.resume = smsc911x_resume,
 };
 
 /* Entry point for loading the module */
-- 
1.6.2.1


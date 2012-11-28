From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 2/6] smsc75xx: refactor entering suspend modes
Date: Wed, 28 Nov 2012 15:59:46 +0000
Message-ID: <1354118391-22666-3-git-send-email-steve.glendinning@shawell.net>
References: <1354118391-22666-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:57254 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754123Ab2K1QAB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 11:00:01 -0500
In-Reply-To: <1354118391-22666-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch splits out the logic for entering suspend modes
to separate functions, to reduce the complexity of the
smsc75xx_suspend function.

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc75xx.c |   62 +++++++++++++++++++++++++++-----------------
 1 file changed, 38 insertions(+), 24 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index a36648b..c26aeba 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -1214,6 +1214,42 @@ static int smsc75xx_write_wuff(struct usbnet *dev, int filter, u32 wuf_cfg,
 	return 0;
 }
 
+static int smsc75xx_enter_suspend0(struct usbnet *dev)
+{
+	u32 val;
+	int ret;
+
+	ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
+	check_warn_return(ret, "Error reading PMT_CTL\n");
+
+	val &= (~(PMT_CTL_SUS_MODE | PMT_CTL_PHY_RST));
+	val |= PMT_CTL_SUS_MODE_0 | PMT_CTL_WOL_EN | PMT_CTL_WUPS;
+
+	ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
+	check_warn_return(ret, "Error writing PMT_CTL\n");
+
+	smsc75xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
+
+	return 0;
+}
+
+static int smsc75xx_enter_suspend2(struct usbnet *dev)
+{
+	u32 val;
+	int ret;
+
+	ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
+	check_warn_return(ret, "Error reading PMT_CTL\n");
+
+	val &= ~(PMT_CTL_SUS_MODE | PMT_CTL_WUPS | PMT_CTL_PHY_RST);
+	val |= PMT_CTL_SUS_MODE_2;
+
+	ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
+	check_warn_return(ret, "Error writing PMT_CTL\n");
+
+	return 0;
+}
+
 static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
 {
 	struct usbnet *dev = usb_get_intfdata(intf);
@@ -1245,17 +1281,7 @@ static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
 		ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
 		check_warn_return(ret, "Error writing PMT_CTL\n");
 
-		/* enter suspend2 mode */
-		ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
-		check_warn_return(ret, "Error reading PMT_CTL\n");
-
-		val &= ~(PMT_CTL_SUS_MODE | PMT_CTL_WUPS | PMT_CTL_PHY_RST);
-		val |= PMT_CTL_SUS_MODE_2;
-
-		ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
-		check_warn_return(ret, "Error writing PMT_CTL\n");
-
-		return 0;
+		return smsc75xx_enter_suspend2(dev);
 	}
 
 	if (pdata->wolopts & (WAKE_MCAST | WAKE_ARP)) {
@@ -1369,19 +1395,7 @@ static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
 
 	/* some wol options are enabled, so enter SUSPEND0 */
 	netdev_info(dev->net, "entering SUSPEND0 mode\n");
-
-	ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
-	check_warn_return(ret, "Error reading PMT_CTL\n");
-
-	val &= (~(PMT_CTL_SUS_MODE | PMT_CTL_PHY_RST));
-	val |= PMT_CTL_SUS_MODE_0 | PMT_CTL_WOL_EN | PMT_CTL_WUPS;
-
-	ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
-	check_warn_return(ret, "Error writing PMT_CTL\n");
-
-	smsc75xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
-
-	return 0;
+	return smsc75xx_enter_suspend0(dev);
 }
 
 static int smsc75xx_resume(struct usb_interface *intf)
-- 
1.7.10.4

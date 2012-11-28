From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 6/6] smsc75xx: don't enable remote wakeup directly
Date: Wed, 28 Nov 2012 15:59:50 +0000
Message-ID: <1354118391-22666-7-git-send-email-steve.glendinning@shawell.net>
References: <1354118391-22666-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	Bjorn Mork <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:57254 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754443Ab2K1QAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 11:00:08 -0500
In-Reply-To: <1354118391-22666-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As pointed out by Bjorn Mork, the generic "usb" driver sets this
for us so no need to directly set it in this driver.

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
Cc: Bjorn Mork <bjorn@mork.no>
---
 drivers/net/usb/smsc75xx.c |   43 ++++++++-----------------------------------
 1 file changed, 8 insertions(+), 35 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index b852c48..1823806 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -61,7 +61,6 @@
 #define SUSPEND_SUSPEND1		(0x02)
 #define SUSPEND_SUSPEND2		(0x04)
 #define SUSPEND_SUSPEND3		(0x08)
-#define SUSPEND_REMOTEWAKE		(0x10)
 #define SUSPEND_ALLMODES		(SUSPEND_SUSPEND0 | SUSPEND_SUSPEND1 | \
 					 SUSPEND_SUSPEND2 | SUSPEND_SUSPEND3)
 
@@ -172,26 +171,6 @@ static int __must_check smsc75xx_write_reg(struct usbnet *dev, u32 index,
 	return __smsc75xx_write_reg(dev, index, data, 0);
 }
 
-static int smsc75xx_set_feature(struct usbnet *dev, u32 feature)
-{
-	if (WARN_ON_ONCE(!dev))
-		return -EINVAL;
-
-	return usbnet_write_cmd_nopm(dev, USB_REQ_SET_FEATURE,
-				     USB_DIR_OUT | USB_RECIP_DEVICE,
-				     feature, 0, NULL, 0);
-}
-
-static int smsc75xx_clear_feature(struct usbnet *dev, u32 feature)
-{
-	if (WARN_ON_ONCE(!dev))
-		return -EINVAL;
-
-	return usbnet_write_cmd_nopm(dev, USB_REQ_CLEAR_FEATURE,
-				     USB_DIR_OUT | USB_RECIP_DEVICE,
-				     feature, 0, NULL, 0);
-}
-
 /* Loop until the read is completed with timeout
  * called with phy_mutex held */
 static __must_check int __smsc75xx_phy_wait_not_busy(struct usbnet *dev,
@@ -674,8 +653,13 @@ static int smsc75xx_ethtool_set_wol(struct net_device *net,
 {
 	struct usbnet *dev = netdev_priv(net);
 	struct smsc75xx_priv *pdata = (struct smsc75xx_priv *)(dev->data[0]);
+	int ret;
 
 	pdata->wolopts = wolinfo->wolopts & SUPPORTED_WAKE;
+
+	ret = device_set_wakeup_enable(&dev->udev->dev, pdata->wolopts);
+	check_warn_return(ret, "device_set_wakeup_enable error %d\n", ret);
+
 	return 0;
 }
 
@@ -1263,9 +1247,7 @@ static int smsc75xx_enter_suspend0(struct usbnet *dev)
 	ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
 	check_warn_return(ret, "Error writing PMT_CTL\n");
 
-	smsc75xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
-
-	pdata->suspend_flags |= SUSPEND_SUSPEND0 | SUSPEND_REMOTEWAKE;
+	pdata->suspend_flags |= SUSPEND_SUSPEND0;
 
 	return 0;
 }
@@ -1292,9 +1274,7 @@ static int smsc75xx_enter_suspend1(struct usbnet *dev)
 	ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
 	check_warn_return(ret, "Error writing PMT_CTL\n");
 
-	smsc75xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
-
-	pdata->suspend_flags |= SUSPEND_SUSPEND1 | SUSPEND_REMOTEWAKE;
+	pdata->suspend_flags |= SUSPEND_SUSPEND1;
 
 	return 0;
 }
@@ -1349,9 +1329,7 @@ static int smsc75xx_enter_suspend3(struct usbnet *dev)
 	ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
 	check_warn_return(ret, "Error writing PMT_CTL\n");
 
-	smsc75xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
-
-	pdata->suspend_flags |= SUSPEND_SUSPEND3 | SUSPEND_REMOTEWAKE;
+	pdata->suspend_flags |= SUSPEND_SUSPEND3;
 
 	return 0;
 }
@@ -1651,11 +1629,6 @@ static int smsc75xx_resume(struct usb_interface *intf)
 	/* do this first to ensure it's cleared even in error case */
 	pdata->suspend_flags = 0;
 
-	if (suspend_flags & SUSPEND_REMOTEWAKE) {
-		ret = smsc75xx_clear_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
-		check_warn_return(ret, "Error disabling remote wakeup\n");
-	}
-
 	if (suspend_flags & SUSPEND_ALLMODES) {
 		/* Disable wakeup sources */
 		ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
-- 
1.7.10.4

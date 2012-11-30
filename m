From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 3/5] smsc95xx: don't enable remote wakeup directly
Date: Fri, 30 Nov 2012 15:55:50 +0000
Message-ID: <1354290952-27109-4-git-send-email-steve.glendinning@shawell.net>
References: <1354290952-27109-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	Bjorn Mork <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:47841 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030982Ab2K3P4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 10:56:00 -0500
In-Reply-To: <1354290952-27109-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As pointed out by Bjorn Mork, the generic "usb" driver sets this
for us so no need to directly set it in this driver.

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
Cc: Bjorn Mork <bjorn@mork.no>
---
 drivers/net/usb/smsc95xx.c |   30 +++++-------------------------
 1 file changed, 5 insertions(+), 25 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index ffeaf13..064df1a 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -154,25 +154,6 @@ static int __must_check smsc95xx_write_reg(struct usbnet *dev, u32 index,
 {
 	return __smsc95xx_write_reg(dev, index, data, 0);
 }
-static int smsc95xx_set_feature(struct usbnet *dev, u32 feature)
-{
-	if (WARN_ON_ONCE(!dev))
-		return -EINVAL;
-
-	return usbnet_write_cmd_nopm(dev, USB_REQ_SET_FEATURE,
-				     USB_RECIP_DEVICE, feature, 0,
-				     NULL, 0);
-}
-
-static int smsc95xx_clear_feature(struct usbnet *dev, u32 feature)
-{
-	if (WARN_ON_ONCE(!dev))
-		return -EINVAL;
-
-	return usbnet_write_cmd_nopm(dev, USB_REQ_CLEAR_FEATURE,
-				     USB_RECIP_DEVICE, feature,
-				     0, NULL, 0);
-}
 
 /* Loop until the read is completed with timeout
  * called with phy_mutex held */
@@ -685,8 +666,13 @@ static int smsc95xx_ethtool_set_wol(struct net_device *net,
 {
 	struct usbnet *dev = netdev_priv(net);
 	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
+	int ret;
 
 	pdata->wolopts = wolinfo->wolopts & SUPPORTED_WAKE;
+
+	ret = device_set_wakeup_enable(&dev->udev->dev, pdata->wolopts);
+	check_warn_return(ret, "device_set_wakeup_enable error %d\n", ret);
+
 	return 0;
 }
 
@@ -1160,8 +1146,6 @@ static int smsc95xx_enter_suspend0(struct usbnet *dev)
 	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
 	check_warn_return(ret, "Error reading PM_CTRL\n");
 
-	smsc95xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
-
 	return 0;
 }
 
@@ -1204,8 +1188,6 @@ static int smsc95xx_enter_suspend1(struct usbnet *dev)
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
 	check_warn_return(ret, "Error writing PM_CTRL\n");
 
-	smsc95xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
-
 	return 0;
 }
 
@@ -1456,8 +1438,6 @@ static int smsc95xx_resume(struct usb_interface *intf)
 	BUG_ON(!dev);
 
 	if (pdata->wolopts) {
-		smsc95xx_clear_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
-
 		/* clear wake-up sources */
 		ret = smsc95xx_read_reg_nopm(dev, WUCSR, &val);
 		check_warn_return(ret, "Error reading WUCSR\n");
-- 
1.7.10.4

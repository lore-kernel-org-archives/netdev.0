From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 2/3] smsc95xx: fix error handling in suspend failure case
Date: Wed, 28 Nov 2012 17:46:58 +0000
Message-ID: <1354124819-29531-3-git-send-email-steve.glendinning@shawell.net>
References: <1354124819-29531-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:57943 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752324Ab2K1RrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 12:47:07 -0500
In-Reply-To: <1354124819-29531-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch ensures that if we fail to suspend the LAN9500 device
we call usbnet_resume before returning failure, instead of
leaving the usbnet driver in an unusable state.

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc95xx.c |   50 +++++++++++++++++++++++++-------------------
 1 file changed, 29 insertions(+), 21 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index c397b3a..ffeaf13 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1248,35 +1248,37 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 
 		/* disable energy detect (link up) & wake up events */
 		ret = smsc95xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_return(ret, "Error reading WUCSR\n");
+		check_warn_goto_done(ret, "Error reading WUCSR\n");
 
 		val &= ~(WUCSR_MPEN_ | WUCSR_WAKE_EN_);
 
 		ret = smsc95xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_return(ret, "Error writing WUCSR\n");
+		check_warn_goto_done(ret, "Error writing WUCSR\n");
 
 		ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-		check_warn_return(ret, "Error reading PM_CTRL\n");
+		check_warn_goto_done(ret, "Error reading PM_CTRL\n");
 
 		val &= ~(PM_CTL_ED_EN_ | PM_CTL_WOL_EN_);
 
 		ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-		check_warn_return(ret, "Error writing PM_CTRL\n");
+		check_warn_goto_done(ret, "Error writing PM_CTRL\n");
 
-		return smsc95xx_enter_suspend2(dev);
+		ret = smsc95xx_enter_suspend2(dev);
+		goto done;
 	}
 
 	if (pdata->wolopts & WAKE_PHY) {
 		ret = smsc95xx_enable_phy_wakeup_interrupts(dev,
 			(PHY_INT_MASK_ANEG_COMP_ | PHY_INT_MASK_LINK_DOWN_));
-		check_warn_return(ret, "error enabling PHY wakeup ints\n");
+		check_warn_goto_done(ret, "error enabling PHY wakeup ints\n");
 
 		/* if link is down then configure EDPD and enter SUSPEND1,
 		 * otherwise enter SUSPEND0 below
 		 */
 		if (!link_up) {
 			netdev_info(dev->net, "entering SUSPEND1 mode\n");
-			return smsc95xx_enter_suspend1(dev);
+			ret = smsc95xx_enter_suspend1(dev);
+			goto done;
 		}
 	}
 
@@ -1292,7 +1294,8 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 
 		if (!filter_mask) {
 			netdev_warn(dev->net, "Unable to allocate filter_mask\n");
-			return -ENOMEM;
+			ret = -ENOMEM;
+			goto done;
 		}
 
 		memset(command, 0, sizeof(command));
@@ -1354,49 +1357,49 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 			ret = smsc95xx_write_reg_nopm(dev, WUFF, filter_mask[i]);
 			if (ret < 0)
 				kfree(filter_mask);
-			check_warn_return(ret, "Error writing WUFF\n");
+			check_warn_goto_done(ret, "Error writing WUFF\n");
 		}
 		kfree(filter_mask);
 
 		for (i = 0; i < (wuff_filter_count / 4); i++) {
 			ret = smsc95xx_write_reg_nopm(dev, WUFF, command[i]);
-			check_warn_return(ret, "Error writing WUFF\n");
+			check_warn_goto_done(ret, "Error writing WUFF\n");
 		}
 
 		for (i = 0; i < (wuff_filter_count / 4); i++) {
 			ret = smsc95xx_write_reg_nopm(dev, WUFF, offset[i]);
-			check_warn_return(ret, "Error writing WUFF\n");
+			check_warn_goto_done(ret, "Error writing WUFF\n");
 		}
 
 		for (i = 0; i < (wuff_filter_count / 2); i++) {
 			ret = smsc95xx_write_reg_nopm(dev, WUFF, crc[i]);
-			check_warn_return(ret, "Error writing WUFF\n");
+			check_warn_goto_done(ret, "Error writing WUFF\n");
 		}
 
 		/* clear any pending pattern match packet status */
 		ret = smsc95xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_return(ret, "Error reading WUCSR\n");
+		check_warn_goto_done(ret, "Error reading WUCSR\n");
 
 		val |= WUCSR_WUFR_;
 
 		ret = smsc95xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_return(ret, "Error writing WUCSR\n");
+		check_warn_goto_done(ret, "Error writing WUCSR\n");
 	}
 
 	if (pdata->wolopts & WAKE_MAGIC) {
 		/* clear any pending magic packet status */
 		ret = smsc95xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_return(ret, "Error reading WUCSR\n");
+		check_warn_goto_done(ret, "Error reading WUCSR\n");
 
 		val |= WUCSR_MPR_;
 
 		ret = smsc95xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_return(ret, "Error writing WUCSR\n");
+		check_warn_goto_done(ret, "Error writing WUCSR\n");
 	}
 
 	/* enable/disable wakeup sources */
 	ret = smsc95xx_read_reg_nopm(dev, WUCSR, &val);
-	check_warn_return(ret, "Error reading WUCSR\n");
+	check_warn_goto_done(ret, "Error reading WUCSR\n");
 
 	if (pdata->wolopts & (WAKE_BCAST | WAKE_MCAST | WAKE_ARP | WAKE_UCAST)) {
 		netdev_info(dev->net, "enabling pattern match wakeup\n");
@@ -1415,11 +1418,11 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 	}
 
 	ret = smsc95xx_write_reg_nopm(dev, WUCSR, val);
-	check_warn_return(ret, "Error writing WUCSR\n");
+	check_warn_goto_done(ret, "Error writing WUCSR\n");
 
 	/* enable wol wakeup source */
 	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-	check_warn_return(ret, "Error reading PM_CTRL\n");
+	check_warn_goto_done(ret, "Error reading PM_CTRL\n");
 
 	val |= PM_CTL_WOL_EN_;
 
@@ -1428,14 +1431,19 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 		val |= PM_CTL_ED_EN_;
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-	check_warn_return(ret, "Error writing PM_CTRL\n");
+	check_warn_goto_done(ret, "Error writing PM_CTRL\n");
 
 	/* enable receiver to enable frame reception */
 	smsc95xx_start_rx_path(dev, 1);
 
 	/* some wol options are enabled, so enter SUSPEND0 */
 	netdev_info(dev->net, "entering SUSPEND0 mode\n");
-	return smsc95xx_enter_suspend0(dev);
+	ret = smsc95xx_enter_suspend0(dev);
+
+done:
+	if (ret)
+		usbnet_resume(intf);
+	return ret;
 }
 
 static int smsc95xx_resume(struct usb_interface *intf)
-- 
1.7.10.4

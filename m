From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 4/6] smsc75xx: fix error handling in suspend failure case
Date: Wed, 28 Nov 2012 15:59:48 +0000
Message-ID: <1354118391-22666-5-git-send-email-steve.glendinning@shawell.net>
References: <1354118391-22666-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:57254 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752152Ab2K1QAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 11:00:06 -0500
In-Reply-To: <1354118391-22666-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch ensures that if we fail to suspend the LAN7500 device
we call usbnet_resume before returning failure, instead of
leaving the usbnet driver in an unusable state.

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc75xx.c |   69 ++++++++++++++++++++++++--------------------
 1 file changed, 38 insertions(+), 31 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 3e3b101..649bf2a 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -1346,7 +1346,7 @@ static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
 	int ret;
 
 	ret = usbnet_suspend(intf, message);
-	check_warn_return(ret, "usbnet_suspend error\n");
+	check_warn_goto_done(ret, "usbnet_suspend error\n");
 
 	/* determine if link is up using only _nopm functions */
 	link_up = smsc75xx_link_ok_nopm(dev);
@@ -1360,28 +1360,29 @@ static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
 
 		/* disable energy detect (link up) & wake up events */
 		ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_return(ret, "Error reading WUCSR\n");
+		check_warn_goto_done(ret, "Error reading WUCSR\n");
 
 		val &= ~(WUCSR_MPEN | WUCSR_WUEN);
 
 		ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_return(ret, "Error writing WUCSR\n");
+		check_warn_goto_done(ret, "Error writing WUCSR\n");
 
 		ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
-		check_warn_return(ret, "Error reading PMT_CTL\n");
+		check_warn_goto_done(ret, "Error reading PMT_CTL\n");
 
 		val &= ~(PMT_CTL_ED_EN | PMT_CTL_WOL_EN);
 
 		ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
-		check_warn_return(ret, "Error writing PMT_CTL\n");
+		check_warn_goto_done(ret, "Error writing PMT_CTL\n");
 
-		return smsc75xx_enter_suspend2(dev);
+		ret = smsc75xx_enter_suspend2(dev);
+		goto done;
 	}
 
 	if (pdata->wolopts & WAKE_PHY) {
 		ret = smsc75xx_enable_phy_wakeup_interrupts(dev,
 			(PHY_INT_MASK_ANEG_COMP | PHY_INT_MASK_LINK_DOWN));
-		check_warn_return(ret, "error enabling PHY wakeup ints\n");
+		check_warn_goto_done(ret, "error enabling PHY wakeup ints\n");
 
 		/* if link is down then configure EDPD and enter SUSPEND1,
 		 * otherwise enter SUSPEND0 below
@@ -1393,7 +1394,7 @@ static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
 			/* enable energy detect power-down mode */
 			ret = smsc75xx_mdio_read_nopm(dev->net, mii->phy_id,
 				PHY_MODE_CTRL_STS);
-			check_warn_return(ret, "Error reading PHY_MODE_CTRL_STS\n");
+			check_warn_goto_done(ret, "Error reading PHY_MODE_CTRL_STS\n");
 
 			ret |= MODE_CTRL_STS_EDPWRDOWN;
 
@@ -1401,7 +1402,8 @@ static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
 				PHY_MODE_CTRL_STS, ret);
 
 			/* enter SUSPEND1 mode */
-			return smsc75xx_enter_suspend1(dev);
+			ret = smsc75xx_enter_suspend1(dev);
+			goto done;
 		}
 	}
 
@@ -1411,7 +1413,7 @@ static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
 		/* disable all filters */
 		for (i = 0; i < WUF_NUM; i++) {
 			ret = smsc75xx_write_reg_nopm(dev, WUF_CFGX + i * 4, 0);
-			check_warn_return(ret, "Error writing WUF_CFGX\n");
+			check_warn_goto_done(ret, "Error writing WUF_CFGX\n");
 		}
 
 		if (pdata->wolopts & WAKE_MCAST) {
@@ -1421,7 +1423,7 @@ static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
 			val = WUF_CFGX_EN | WUF_CFGX_ATYPE_MULTICAST
 				| smsc_crc(mcast, 3);
 			ret = smsc75xx_write_wuff(dev, filter++, val, 0x0007);
-			check_warn_return(ret, "Error writing wakeup filter\n");
+			check_warn_goto_done(ret, "Error writing wakeup filter\n");
 		}
 
 		if (pdata->wolopts & WAKE_ARP) {
@@ -1431,106 +1433,111 @@ static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
 			val = WUF_CFGX_EN | WUF_CFGX_ATYPE_ALL | (0x0C << 16)
 				| smsc_crc(arp, 2);
 			ret = smsc75xx_write_wuff(dev, filter++, val, 0x0003);
-			check_warn_return(ret, "Error writing wakeup filter\n");
+			check_warn_goto_done(ret, "Error writing wakeup filter\n");
 		}
 
 		/* clear any pending pattern match packet status */
 		ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_return(ret, "Error reading WUCSR\n");
+		check_warn_goto_done(ret, "Error reading WUCSR\n");
 
 		val |= WUCSR_WUFR;
 
 		ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_return(ret, "Error writing WUCSR\n");
+		check_warn_goto_done(ret, "Error writing WUCSR\n");
 
 		netdev_info(dev->net, "enabling packet match detection\n");
 		ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_return(ret, "Error reading WUCSR\n");
+		check_warn_goto_done(ret, "Error reading WUCSR\n");
 
 		val |= WUCSR_WUEN;
 
 		ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_return(ret, "Error writing WUCSR\n");
+		check_warn_goto_done(ret, "Error writing WUCSR\n");
 	} else {
 		netdev_info(dev->net, "disabling packet match detection\n");
 		ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_return(ret, "Error reading WUCSR\n");
+		check_warn_goto_done(ret, "Error reading WUCSR\n");
 
 		val &= ~WUCSR_WUEN;
 
 		ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_return(ret, "Error writing WUCSR\n");
+		check_warn_goto_done(ret, "Error writing WUCSR\n");
 	}
 
 	/* disable magic, bcast & unicast wakeup sources */
 	ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
-	check_warn_return(ret, "Error reading WUCSR\n");
+	check_warn_goto_done(ret, "Error reading WUCSR\n");
 
 	val &= ~(WUCSR_MPEN | WUCSR_BCST_EN | WUCSR_PFDA_EN);
 
 	ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
-	check_warn_return(ret, "Error writing WUCSR\n");
+	check_warn_goto_done(ret, "Error writing WUCSR\n");
 
 	if (pdata->wolopts & WAKE_PHY) {
 		netdev_info(dev->net, "enabling PHY wakeup\n");
 
 		ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
-		check_warn_return(ret, "Error reading PMT_CTL\n");
+		check_warn_goto_done(ret, "Error reading PMT_CTL\n");
 
 		/* clear wol status, enable energy detection */
 		val &= ~PMT_CTL_WUPS;
 		val |= (PMT_CTL_WUPS_ED | PMT_CTL_ED_EN);
 
 		ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
-		check_warn_return(ret, "Error writing PMT_CTL\n");
+		check_warn_goto_done(ret, "Error writing PMT_CTL\n");
 	}
 
 	if (pdata->wolopts & WAKE_MAGIC) {
 		netdev_info(dev->net, "enabling magic packet wakeup\n");
 		ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_return(ret, "Error reading WUCSR\n");
+		check_warn_goto_done(ret, "Error reading WUCSR\n");
 
 		/* clear any pending magic packet status */
 		val |= WUCSR_MPR | WUCSR_MPEN;
 
 		ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_return(ret, "Error writing WUCSR\n");
+		check_warn_goto_done(ret, "Error writing WUCSR\n");
 	}
 
 	if (pdata->wolopts & WAKE_BCAST) {
 		netdev_info(dev->net, "enabling broadcast detection\n");
 		ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_return(ret, "Error reading WUCSR\n");
+		check_warn_goto_done(ret, "Error reading WUCSR\n");
 
 		val |= WUCSR_BCAST_FR | WUCSR_BCST_EN;
 
 		ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_return(ret, "Error writing WUCSR\n");
+		check_warn_goto_done(ret, "Error writing WUCSR\n");
 	}
 
 	if (pdata->wolopts & WAKE_UCAST) {
 		netdev_info(dev->net, "enabling unicast detection\n");
 		ret = smsc75xx_read_reg_nopm(dev, WUCSR, &val);
-		check_warn_return(ret, "Error reading WUCSR\n");
+		check_warn_goto_done(ret, "Error reading WUCSR\n");
 
 		val |= WUCSR_WUFR | WUCSR_PFDA_EN;
 
 		ret = smsc75xx_write_reg_nopm(dev, WUCSR, val);
-		check_warn_return(ret, "Error writing WUCSR\n");
+		check_warn_goto_done(ret, "Error writing WUCSR\n");
 	}
 
 	/* enable receiver to enable frame reception */
 	ret = smsc75xx_read_reg_nopm(dev, MAC_RX, &val);
-	check_warn_return(ret, "Failed to read MAC_RX: %d\n", ret);
+	check_warn_goto_done(ret, "Failed to read MAC_RX: %d\n", ret);
 
 	val |= MAC_RX_RXEN;
 
 	ret = smsc75xx_write_reg_nopm(dev, MAC_RX, val);
-	check_warn_return(ret, "Failed to write MAC_RX: %d\n", ret);
+	check_warn_goto_done(ret, "Failed to write MAC_RX: %d\n", ret);
 
 	/* some wol options are enabled, so enter SUSPEND0 */
 	netdev_info(dev->net, "entering SUSPEND0 mode\n");
-	return smsc75xx_enter_suspend0(dev);
+	ret = smsc75xx_enter_suspend0(dev);
+
+done:
+	if (ret)
+		usbnet_resume(intf);
+	return ret;
 }
 
 static int smsc75xx_resume(struct usb_interface *intf)
-- 
1.7.10.4

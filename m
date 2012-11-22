From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 4/5] smsc95xx: refactor entering suspend modes
Date: Thu, 22 Nov 2012 18:05:25 +0000
Message-ID: <1353607526-19307-5-git-send-email-steve.glendinning@shawell.net>
References: <1353607526-19307-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:59736 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753924Ab2KVSfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 13:35:30 -0500
In-Reply-To: <1353607526-19307-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch splits out the logic for entering suspend modes
to separate functions, to reduce the complexity of the
smsc95xx_suspend function.

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc95xx.c |  178 ++++++++++++++++++++++++--------------------
 1 file changed, 99 insertions(+), 79 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index e98ff8c..bf88543 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1130,6 +1130,102 @@ static int smsc95xx_link_ok_nopm(struct usbnet *dev)
 	return !!(ret & BMSR_LSTATUS);
 }
 
+static int smsc95xx_enter_suspend0(struct usbnet *dev)
+{
+	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
+	u32 val;
+	int ret;
+
+	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
+	check_warn_return(ret, "Error reading PM_CTRL");
+
+	val &= (~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_));
+	val |= PM_CTL_SUS_MODE_0;
+
+	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
+	check_warn_return(ret, "Error writing PM_CTRL");
+
+	/* clear wol status */
+	val &= ~PM_CTL_WUPS_;
+	val |= PM_CTL_WUPS_WOL_;
+
+	/* enable energy detection */
+	if (pdata->wolopts & WAKE_PHY)
+		val |= PM_CTL_WUPS_ED_;
+
+	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
+	check_warn_return(ret, "Error writing PM_CTRL");
+
+	/* read back PM_CTRL */
+	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
+	check_warn_return(ret, "Error reading PM_CTRL");
+
+	smsc95xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
+
+	return 0;
+}
+
+static int smsc95xx_enter_suspend1(struct usbnet *dev)
+{
+	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
+	struct mii_if_info *mii = &dev->mii;
+	u32 val;
+	int ret;
+
+	/* reconfigure link pulse detection timing for
+	 * compatibility with non-standard link partners
+	 */
+	if (pdata->features & FEATURE_PHY_NLP_CROSSOVER)
+		smsc95xx_mdio_write_nopm(dev->net, mii->phy_id,	PHY_EDPD_CONFIG,
+			PHY_EDPD_CONFIG_DEFAULT);
+
+	/* enable energy detect power-down mode */
+	ret = smsc95xx_mdio_read_nopm(dev->net, mii->phy_id, PHY_MODE_CTRL_STS);
+	check_warn_return(ret, "Error reading PHY_MODE_CTRL_STS");
+
+	ret |= MODE_CTRL_STS_EDPWRDOWN_;
+
+	smsc95xx_mdio_write_nopm(dev->net, mii->phy_id, PHY_MODE_CTRL_STS, ret);
+
+	/* enter SUSPEND1 mode */
+	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
+	check_warn_return(ret, "Error reading PM_CTRL");
+
+	val &= ~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_);
+	val |= PM_CTL_SUS_MODE_1;
+
+	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
+	check_warn_return(ret, "Error writing PM_CTRL");
+
+	/* clear wol status, enable energy detection */
+	val &= ~PM_CTL_WUPS_;
+	val |= (PM_CTL_WUPS_ED_ | PM_CTL_ED_EN_);
+
+	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
+	check_warn_return(ret, "Error writing PM_CTRL");
+
+	smsc95xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
+
+	return 0;
+}
+
+static int smsc95xx_enter_suspend2(struct usbnet *dev)
+{
+	u32 val;
+	int ret;
+
+	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
+	check_warn_return(ret, "Error reading PM_CTRL");
+
+	val &= ~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_);
+	val |= PM_CTL_SUS_MODE_2;
+
+	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
+	check_warn_return(ret, "Error writing PM_CTRL");
+
+	return 0;
+}
+
 static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 {
 	struct usbnet *dev = usb_get_intfdata(intf);
@@ -1167,17 +1263,7 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 		ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
 		check_warn_return(ret, "Error writing PM_CTRL");
 
-		/* enter suspend2 mode */
-		ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-		check_warn_return(ret, "Error reading PM_CTRL");
-
-		val &= ~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_);
-		val |= PM_CTL_SUS_MODE_2;
-
-		ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-		check_warn_return(ret, "Error writing PM_CTRL");
-
-		return 0;
+		return smsc95xx_enter_suspend2(dev);
 	}
 
 	if (pdata->wolopts & WAKE_PHY) {
@@ -1189,47 +1275,8 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 		 * otherwise enter SUSPEND0 below
 		 */
 		if (!link_up) {
-			struct mii_if_info *mii = &dev->mii;
 			netdev_info(dev->net, "entering SUSPEND1 mode");
-
-			/* reconfigure link pulse detection timing for
-			 * compatibility with non-standard link partners
-			 */
-			if (pdata->features & FEATURE_PHY_NLP_CROSSOVER)
-				smsc95xx_mdio_write_nopm(dev->net, mii->phy_id,
-					PHY_EDPD_CONFIG,
-					PHY_EDPD_CONFIG_DEFAULT);
-
-			/* enable energy detect power-down mode */
-			ret = smsc95xx_mdio_read_nopm(dev->net, mii->phy_id,
-				PHY_MODE_CTRL_STS);
-			check_warn_return(ret, "Error reading PHY_MODE_CTRL_STS");
-
-			ret |= MODE_CTRL_STS_EDPWRDOWN_;
-
-			smsc95xx_mdio_write_nopm(dev->net, mii->phy_id,
-				PHY_MODE_CTRL_STS, ret);
-
-			/* enter SUSPEND1 mode */
-			ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-			check_warn_return(ret, "Error reading PM_CTRL");
-
-			val &= ~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_);
-			val |= PM_CTL_SUS_MODE_1;
-
-			ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-			check_warn_return(ret, "Error writing PM_CTRL");
-
-			/* clear wol status, enable energy detection */
-			val &= ~PM_CTL_WUPS_;
-			val |= (PM_CTL_WUPS_ED_ | PM_CTL_ED_EN_);
-
-			ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-			check_warn_return(ret, "Error writing PM_CTRL");
-
-			smsc95xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
-
-			return 0;
+			return smsc95xx_enter_suspend1(dev);
 		}
 	}
 
@@ -1383,34 +1430,7 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 
 	/* some wol options are enabled, so enter SUSPEND0 */
 	netdev_info(dev->net, "entering SUSPEND0 mode");
-
-	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-	check_warn_return(ret, "Error reading PM_CTRL");
-
-	val &= (~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_));
-	val |= PM_CTL_SUS_MODE_0;
-
-	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-	check_warn_return(ret, "Error writing PM_CTRL");
-
-	/* clear wol status */
-	val &= ~PM_CTL_WUPS_;
-	val |= PM_CTL_WUPS_WOL_;
-
-	/* enable energy detection */
-	if (pdata->wolopts & WAKE_PHY)
-		val |= PM_CTL_WUPS_ED_;
-
-	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-	check_warn_return(ret, "Error writing PM_CTRL");
-
-	/* read back PM_CTRL */
-	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-	check_warn_return(ret, "Error reading PM_CTRL");
-
-	smsc95xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
-
-	return 0;
+	return smsc95xx_enter_suspend0(dev);
 }
 
 static int smsc95xx_resume(struct usb_interface *intf)
-- 
1.7.10.4

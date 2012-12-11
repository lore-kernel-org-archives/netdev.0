From: Joe Perches <joe@perches.com>
Subject: Re: [PATCHv2][RFC] smsc95xx: enable dynamic autosuspend
Date: Tue, 11 Dec 2012 08:27:56 -0800
Message-ID: <1355243276.24219.3.camel@joe-AO722>
References: <1355239561-2740-1-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	ming.lei@canonical.com, oneukum@suse.de, gregkh@linuxfoundation.org
To: Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:39021 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752904Ab2LKQ15 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2012 11:27:57 -0500
In-Reply-To: <1355239561-2740-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-12-11 at 15:26 +0000, Steve Glendinning wrote:
> This patch enables USB dynamic autosuspend for LAN9500A.  This
> saves very little power in itself, but it allows power saving
> in upstream hubs/hosts.

[]> diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
[]
> +	ret = smsc95xx_read_reg_nopm(dev, RX_FIFO_INF, &val);
> +	if (ret < 0) {
> +		netdev_warn(dev->net, "Error reading RX_FIFO_INF");

Please remember terminating newlines.

If you are always going to warn bad reads or writes,
it'd be good to change smsc95xx_read_reg_nopm
and write to emit the message.

It saves ~3% of code, 1K
$ size drivers/net/usb/smsc95xx.o*
   text	   data	    bss	    dec	    hex	filename
  27064	   2724	   6072	  35860	   8c14	drivers/net/usb/smsc95xx.o.new
  27921	   2724	   6256	  36901	   9025	drivers/net/usb/smsc95xx.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/usb/smsc95xx.c |  126 +++++++++++++++-----------------------------
 1 files changed, 42 insertions(+), 84 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 9b73670..e86eca7 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -125,13 +125,28 @@ static int __must_check __smsc95xx_write_reg(struct usbnet *dev, u32 index,
 static int __must_check smsc95xx_read_reg_nopm(struct usbnet *dev, u32 index,
 					       u32 *data)
 {
-	return __smsc95xx_read_reg(dev, index, data, 1);
+	int rtn = __smsc95xx_read_reg(dev, index, data, 1);
+	if (rtn < 0)
+		netdev_warn(dev->net, "Error reading %#x:%s\n",
+			    index,
+			    index == PM_CTRL ? "PM_CTRL" :
+			    index == WUCSR ? "WUCSR" :
+			    "unknown");
+	return rtn;
 }
 
 static int __must_check smsc95xx_write_reg_nopm(struct usbnet *dev, u32 index,
 						u32 data)
 {
-	return __smsc95xx_write_reg(dev, index, data, 1);
+	int rtn = __smsc95xx_write_reg(dev, index, data, 1);
+	if (rtn < 0)
+		netdev_warn(dev->net, "Error writing %#x:%s\n",
+			    index,
+			    index == PM_CTRL ? "PM_CTRL" :
+			    index == WUCSR ? "WUCSR" :
+			    index == WUFF ? "WUFF" :
+			    "unknown");
+	return rtn;
 }
 
 static int __must_check smsc95xx_read_reg(struct usbnet *dev, u32 index,
@@ -1308,19 +1323,15 @@ static int smsc95xx_enter_suspend0(struct usbnet *dev)
 	int ret;
 
 	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error reading PM_CTRL\n");
+	if (ret < 0)
 		return ret;
-	}
 
 	val &= (~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_));
 	val |= PM_CTL_SUS_MODE_0;
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error writing PM_CTRL\n");
+	if (ret < 0)
 		return ret;
-	}
 
 	/* clear wol status */
 	val &= ~PM_CTL_WUPS_;
@@ -1331,15 +1342,11 @@ static int smsc95xx_enter_suspend0(struct usbnet *dev)
 		val |= PM_CTL_WUPS_ED_;
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error writing PM_CTRL\n");
+	if (ret < 0)
 		return ret;
-	}
 
 	/* read back PM_CTRL */
 	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-	if (ret < 0)
-		netdev_warn(dev->net, "Error reading PM_CTRL\n");
 
 	return ret;
 }
@@ -1371,27 +1378,21 @@ static int smsc95xx_enter_suspend1(struct usbnet *dev)
 
 	/* enter SUSPEND1 mode */
 	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error reading PM_CTRL\n");
+	if (ret < 0)
 		return ret;
-	}
 
 	val &= ~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_);
 	val |= PM_CTL_SUS_MODE_1;
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error writing PM_CTRL\n");
+	if (ret < 0)
 		return ret;
-	}
 
 	/* clear wol status, enable energy detection */
 	val &= ~PM_CTL_WUPS_;
 	val |= (PM_CTL_WUPS_ED_ | PM_CTL_ED_EN_);
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-	if (ret < 0)
-		netdev_warn(dev->net, "Error writing PM_CTRL\n");
 
 	return ret;
 }
@@ -1402,17 +1403,13 @@ static int smsc95xx_enter_suspend2(struct usbnet *dev)
 	int ret;
 
 	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error reading PM_CTRL\n");
+	if (ret < 0)
 		return ret;
-	}
 
 	val &= ~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_);
 	val |= PM_CTL_SUS_MODE_2;
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-	if (ret < 0)
-		netdev_warn(dev->net, "Error writing PM_CTRL\n");
 
 	return ret;
 }
@@ -1442,32 +1439,24 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 
 		/* disable energy detect (link up) & wake up events */
 		ret = smsc95xx_read_reg_nopm(dev, WUCSR, &val);
-		if (ret < 0) {
-			netdev_warn(dev->net, "Error reading WUCSR\n");
+		if (ret < 0)
 			goto done;
-		}
 
 		val &= ~(WUCSR_MPEN_ | WUCSR_WAKE_EN_);
 
 		ret = smsc95xx_write_reg_nopm(dev, WUCSR, val);
-		if (ret < 0) {
-			netdev_warn(dev->net, "Error writing WUCSR\n");
+		if (ret < 0)
 			goto done;
-		}
 
 		ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-		if (ret < 0) {
-			netdev_warn(dev->net, "Error reading PM_CTRL\n");
+		if (ret < 0)
 			goto done;
-		}
 
 		val &= ~(PM_CTL_ED_EN_ | PM_CTL_WOL_EN_);
 
 		ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-		if (ret < 0) {
-			netdev_warn(dev->net, "Error writing PM_CTRL\n");
+		if (ret < 0)
 			goto done;
-		}
 
 		ret = smsc95xx_enter_suspend2(dev);
 		goto done;
@@ -1565,7 +1554,6 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 		for (i = 0; i < (wuff_filter_count * 4); i++) {
 			ret = smsc95xx_write_reg_nopm(dev, WUFF, filter_mask[i]);
 			if (ret < 0) {
-				netdev_warn(dev->net, "Error writing WUFF\n");
 				kfree(filter_mask);
 				goto done;
 			}
@@ -1574,67 +1562,51 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 
 		for (i = 0; i < (wuff_filter_count / 4); i++) {
 			ret = smsc95xx_write_reg_nopm(dev, WUFF, command[i]);
-			if (ret < 0) {
-				netdev_warn(dev->net, "Error writing WUFF\n");
+			if (ret < 0)
 				goto done;
-			}
 		}
 
 		for (i = 0; i < (wuff_filter_count / 4); i++) {
 			ret = smsc95xx_write_reg_nopm(dev, WUFF, offset[i]);
-			if (ret < 0) {
-				netdev_warn(dev->net, "Error writing WUFF\n");
+			if (ret < 0)
 				goto done;
-			}
 		}
 
 		for (i = 0; i < (wuff_filter_count / 2); i++) {
 			ret = smsc95xx_write_reg_nopm(dev, WUFF, crc[i]);
-			if (ret < 0) {
-				netdev_warn(dev->net, "Error writing WUFF\n");
+			if (ret < 0)
 				goto done;
-			}
 		}
 
 		/* clear any pending pattern match packet status */
 		ret = smsc95xx_read_reg_nopm(dev, WUCSR, &val);
-		if (ret < 0) {
-			netdev_warn(dev->net, "Error reading WUCSR\n");
+		if (ret < 0)
 			goto done;
-		}
 
 		val |= WUCSR_WUFR_;
 
 		ret = smsc95xx_write_reg_nopm(dev, WUCSR, val);
-		if (ret < 0) {
-			netdev_warn(dev->net, "Error writing WUCSR\n");
+		if (ret < 0)
 			goto done;
-		}
 	}
 
 	if (pdata->wolopts & WAKE_MAGIC) {
 		/* clear any pending magic packet status */
 		ret = smsc95xx_read_reg_nopm(dev, WUCSR, &val);
-		if (ret < 0) {
-			netdev_warn(dev->net, "Error reading WUCSR\n");
+		if (ret < 0)
 			goto done;
-		}
 
 		val |= WUCSR_MPR_;
 
 		ret = smsc95xx_write_reg_nopm(dev, WUCSR, val);
-		if (ret < 0) {
-			netdev_warn(dev->net, "Error writing WUCSR\n");
+		if (ret < 0)
 			goto done;
-		}
 	}
 
 	/* enable/disable wakeup sources */
 	ret = smsc95xx_read_reg_nopm(dev, WUCSR, &val);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error reading WUCSR\n");
+	if (ret < 0)
 		goto done;
-	}
 
 	if (pdata->wolopts & (WAKE_BCAST | WAKE_MCAST | WAKE_ARP | WAKE_UCAST)) {
 		netdev_info(dev->net, "enabling pattern match wakeup\n");
@@ -1653,17 +1625,13 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 	}
 
 	ret = smsc95xx_write_reg_nopm(dev, WUCSR, val);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error writing WUCSR\n");
+	if (ret < 0)
 		goto done;
-	}
 
 	/* enable wol wakeup source */
 	ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error reading PM_CTRL\n");
+	if (ret < 0)
 		goto done;
-	}
 
 	val |= PM_CTL_WOL_EN_;
 
@@ -1672,10 +1640,8 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 		val |= PM_CTL_ED_EN_;
 
 	ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error writing PM_CTRL\n");
+	if (ret < 0)
 		goto done;
-	}
 
 	/* enable receiver to enable frame reception */
 	smsc95xx_start_rx_path(dev, 1);
@@ -1702,34 +1668,26 @@ static int smsc95xx_resume(struct usb_interface *intf)
 	if (pdata->wolopts) {
 		/* clear wake-up sources */
 		ret = smsc95xx_read_reg_nopm(dev, WUCSR, &val);
-		if (ret < 0) {
-			netdev_warn(dev->net, "Error reading WUCSR\n");
+		if (ret < 0)
 			return ret;
-		}
 
 		val &= ~(WUCSR_WAKE_EN_ | WUCSR_MPEN_);
 
 		ret = smsc95xx_write_reg_nopm(dev, WUCSR, val);
-		if (ret < 0) {
-			netdev_warn(dev->net, "Error writing WUCSR\n");
+		if (ret < 0)
 			return ret;
-		}
 
 		/* clear wake-up status */
 		ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
-		if (ret < 0) {
-			netdev_warn(dev->net, "Error reading PM_CTRL\n");
+		if (ret < 0)
 			return ret;
-		}
 
 		val &= ~PM_CTL_WOL_EN_;
 		val |= PM_CTL_WUPS_;
 
 		ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
-		if (ret < 0) {
-			netdev_warn(dev->net, "Error writing PM_CTRL\n");
+		if (ret < 0)
 			return ret;
-		}
 	}
 
 	ret = usbnet_resume(intf);

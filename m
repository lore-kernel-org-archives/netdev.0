From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 2/5] smsc95xx: detect chip revision specific features
Date: Thu, 22 Nov 2012 18:05:23 +0000
Message-ID: <1353607526-19307-3-git-send-email-steve.glendinning@shawell.net>
References: <1353607526-19307-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:59703 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752231Ab2KVSa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 13:30:27 -0500
In-Reply-To: <1353607526-19307-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of storing the number of wake-up frame filter registers
in the pdata structure, this patch changes the driver to detect
the type of device we have and store its available features.

The new two features will be used in future patches.

This patch is intended to have no change in behaviour.

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc95xx.c |   29 ++++++++++++++++++++---------
 drivers/net/usb/smsc95xx.h |    3 +++
 2 files changed, 23 insertions(+), 9 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index e8465fe..3bacb41 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -51,6 +51,10 @@
 #define SUPPORTED_WAKE			(WAKE_UCAST | WAKE_BCAST | \
 					 WAKE_MCAST | WAKE_ARP | WAKE_MAGIC)
 
+#define FEATURE_8_WAKEUP_FILTERS	(0x01)
+#define FEATURE_PHY_NLP_CROSSOVER	(0x02)
+#define FEATURE_AUTOSUSPEND		(0x04)
+
 #define check_warn(ret, fmt, args...) \
 	({ if (ret < 0) netdev_warn(dev->net, fmt, ##args); })
 
@@ -66,7 +70,7 @@ struct smsc95xx_priv {
 	u32 hash_lo;
 	u32 wolopts;
 	spinlock_t mac_cr_lock;
-	int wuff_filter_count;
+	u8 features;
 };
 
 static bool turbo_mode = true;
@@ -1031,10 +1035,14 @@ static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
 	ret = smsc95xx_read_reg(dev, ID_REV, &val);
 	check_warn_return(ret, "Failed to read ID_REV: %d\n", ret);
 	val >>= 16;
-	if ((val == ID_REV_CHIP_ID_9500A_) || (val == ID_REV_CHIP_ID_9512_))
-		pdata->wuff_filter_count = LAN9500A_WUFF_NUM;
-	else
-		pdata->wuff_filter_count = LAN9500_WUFF_NUM;
+
+	if ((val == ID_REV_CHIP_ID_9500A_) || (val == ID_REV_CHIP_ID_9530_) ||
+	    (val == ID_REV_CHIP_ID_89530_) || (val == ID_REV_CHIP_ID_9730_))
+		pdata->features = (FEATURE_8_WAKEUP_FILTERS |
+			FEATURE_PHY_NLP_CROSSOVER |
+			FEATURE_AUTOSUSPEND);
+	else if (val == ID_REV_CHIP_ID_9512_)
+		pdata->features = FEATURE_8_WAKEUP_FILTERS;
 
 	dev->net->netdev_ops = &smsc95xx_netdev_ops;
 	dev->net->ethtool_ops = &smsc95xx_ethtool_ops;
@@ -1109,6 +1117,9 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 		u32 command[2];
 		u32 offset[2];
 		u32 crc[4];
+		int wuff_filter_count =
+			(pdata->features & FEATURE_8_WAKEUP_FILTERS) ?
+			LAN9500A_WUFF_NUM : LAN9500_WUFF_NUM;
 		int i, filter = 0;
 
 		memset(command, 0, sizeof(command));
@@ -1166,7 +1177,7 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 			filter++;
 		}
 
-		for (i = 0; i < (pdata->wuff_filter_count * 4); i++) {
+		for (i = 0; i < (wuff_filter_count * 4); i++) {
 			ret = smsc95xx_write_reg_nopm(dev, WUFF, filter_mask[i]);
 			if (ret < 0)
 				kfree(filter_mask);
@@ -1174,17 +1185,17 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 		}
 		kfree(filter_mask);
 
-		for (i = 0; i < (pdata->wuff_filter_count / 4); i++) {
+		for (i = 0; i < (wuff_filter_count / 4); i++) {
 			ret = smsc95xx_write_reg_nopm(dev, WUFF, command[i]);
 			check_warn_return(ret, "Error writing WUFF");
 		}
 
-		for (i = 0; i < (pdata->wuff_filter_count / 4); i++) {
+		for (i = 0; i < (wuff_filter_count / 4); i++) {
 			ret = smsc95xx_write_reg_nopm(dev, WUFF, offset[i]);
 			check_warn_return(ret, "Error writing WUFF");
 		}
 
-		for (i = 0; i < (pdata->wuff_filter_count / 2); i++) {
+		for (i = 0; i < (wuff_filter_count / 2); i++) {
 			ret = smsc95xx_write_reg_nopm(dev, WUFF, crc[i]);
 			check_warn_return(ret, "Error writing WUFF");
 		}
diff --git a/drivers/net/usb/smsc95xx.h b/drivers/net/usb/smsc95xx.h
index 1f86269..99f04a2 100644
--- a/drivers/net/usb/smsc95xx.h
+++ b/drivers/net/usb/smsc95xx.h
@@ -55,6 +55,9 @@
 #define ID_REV_CHIP_ID_9500_		(0x9500)
 #define ID_REV_CHIP_ID_9500A_		(0x9E00)
 #define ID_REV_CHIP_ID_9512_		(0xEC00)
+#define ID_REV_CHIP_ID_9530_		(0x9530)
+#define ID_REV_CHIP_ID_89530_		(0x9E08)
+#define ID_REV_CHIP_ID_9730_		(0x9730)
 
 #define INT_STS				(0x08)
 #define INT_STS_TX_STOP_		(0x00020000)
-- 
1.7.10.4

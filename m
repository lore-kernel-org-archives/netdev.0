From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 2/4] smsc75xx: add explicit test that device is READY
Date: Fri, 28 Sep 2012 11:57:51 +0100
Message-ID: <1348829873-30779-3-git-send-email-steve.glendinning@shawell.net>
References: <1348829873-30779-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:46294 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757247Ab2I1K6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 06:58:05 -0400
In-Reply-To: <1348829873-30779-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds an explicit test that the READY bit is set on
the device when attempting to initialize it.

If this bit is clear then the device hasn't succesfully started
all its clocks, and this patch helps make the resulting logged
error more helpful.

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc75xx.c |   23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 376143e..1f45f7b 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -756,6 +756,26 @@ static int smsc75xx_set_features(struct net_device *netdev,
 	return 0;
 }
 
+static int smsc75xx_wait_ready(struct usbnet *dev)
+{
+	int timeout = 0;
+
+	do {
+		u32 buf;
+		int ret = smsc75xx_read_reg(dev, PMT_CTL, &buf);
+		check_warn_return(ret, "Failed to read PMT_CTL: %d", ret);
+
+		if (buf & PMT_CTL_DEV_RDY)
+			return 0;
+
+		msleep(10);
+		timeout++;
+	} while (timeout < 100);
+
+	netdev_warn(dev->net, "timeout waiting for device ready");
+	return -EIO;
+}
+
 static int smsc75xx_reset(struct usbnet *dev)
 {
 	struct smsc75xx_priv *pdata = (struct smsc75xx_priv *)(dev->data[0]);
@@ -764,6 +784,9 @@ static int smsc75xx_reset(struct usbnet *dev)
 
 	netif_dbg(dev, ifup, dev->net, "entering smsc75xx_reset");
 
+	ret = smsc75xx_wait_ready(dev);
+	check_warn_return(ret, "device not ready in smsc75xx_reset");
+
 	ret = smsc75xx_read_reg(dev, HW_CFG, &buf);
 	check_warn_return(ret, "Failed to read HW_CFG: %d", ret);
 
-- 
1.7.9.5

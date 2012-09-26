From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 2/2] smsc75xx: enable power saving mode during system suspend
Date: Wed, 26 Sep 2012 15:30:27 +0100
Message-ID: <1348669827-10923-2-git-send-email-steve.glendinning@shawell.net>
References: <1348669827-10923-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:57316 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753879Ab2IZOac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 10:30:32 -0400
In-Reply-To: <1348669827-10923-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch instructs the device to enter its lowest power SUSPEND2
state during system suspend.

This patch also explicitly wakes the device after resume, which
should address reports of the device not automatically coming
back after system suspend:

http://code.google.com/p/chromium-os/issues/detail?id=31871

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc75xx.c |   55 +++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 52 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 1f45f7b..83b9927 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -1106,6 +1106,55 @@ static void smsc75xx_unbind(struct usbnet *dev, struct usb_interface *intf)
 	}
 }
 
+static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
+{
+	struct usbnet *dev = usb_get_intfdata(intf);
+	int ret;
+	u32 val;
+
+	BUG_ON(!dev);
+
+	ret = usbnet_suspend(intf, message);
+	check_warn_return(ret, "usbnet_suspend error");
+
+	netdev_info(dev->net, "entering SUSPEND2 mode");
+
+	ret = smsc75xx_read_reg(dev, PMT_CTL, &val);
+	check_warn_return(ret, "Error reading PMT_CTL");
+
+	val &= ~(PMT_CTL_SUS_MODE | PMT_CTL_WUPS | PMT_CTL_PHY_RST);
+	val |= PMT_CTL_SUS_MODE_2;
+
+	ret = smsc75xx_write_reg(dev, PMT_CTL, val);
+	check_warn_return(ret, "Error writing PMT_CTL");
+
+	return 0;
+}
+
+static int smsc75xx_resume(struct usb_interface *intf)
+{
+	struct usbnet *dev = usb_get_intfdata(intf);
+	int ret;
+	u32 val;
+
+	BUG_ON(!dev);
+
+	netdev_info(dev->net, "resuming from SUSPEND2");
+
+	ret = smsc75xx_read_reg(dev, PMT_CTL, &val);
+	check_warn_return(ret, "Error reading PMT_CTL");
+
+	val |= PMT_CTL_PHY_PWRUP;
+
+	ret = smsc75xx_write_reg(dev, PMT_CTL, val);
+	check_warn_return(ret, "Error writing PMT_CTL");
+
+	ret = smsc75xx_wait_ready(dev);
+	check_warn_return(ret, "device not ready in smsc75xx_resume");
+
+	return usbnet_resume(intf);
+}
+
 static void smsc75xx_rx_csum_offload(struct usbnet *dev, struct sk_buff *skb,
 				     u32 rx_cmd_a, u32 rx_cmd_b)
 {
@@ -1274,9 +1323,9 @@ static struct usb_driver smsc75xx_driver = {
 	.name		= SMSC_CHIPNAME,
 	.id_table	= products,
 	.probe		= usbnet_probe,
-	.suspend	= usbnet_suspend,
-	.resume		= usbnet_resume,
-	.reset_resume	= usbnet_resume,
+	.suspend	= smsc75xx_suspend,
+	.resume		= smsc75xx_resume,
+	.reset_resume	= smsc75xx_resume,
 	.disconnect	= usbnet_disconnect,
 	.disable_hub_initiated_lpm = 1,
 };
-- 
1.7.9.5

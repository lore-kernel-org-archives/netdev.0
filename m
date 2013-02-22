From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 2/3] usbnet: smsc95xx: fix broken runtime suspend
Date: Fri, 22 Feb 2013 21:05:04 +0800
Message-ID: <1361538305-28418-3-git-send-email-ming.lei@canonical.com>
References: <1361538305-28418-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>,
	Steve Glendinning <steve.glendinning@shawell.net>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:42341 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756489Ab3BVNGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 08:06:21 -0500
In-Reply-To: <1361538305-28418-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit b2d4b150(smsc95xx: enable dynamic autosuspend) implements
autosuspend, but breaks current runtime suspend, such as:
when the interface becomes down, the usb device can't be put into
runtime suspend any more.

This patch fixes the broken runtime suspend.

Cc: Steve Glendinning <steve.glendinning@shawell.net>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/smsc95xx.c |   12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index b2721bc..7fa9622 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1418,15 +1418,6 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 	u32 val, link_up;
 	int ret;
 
-	/* TODO: don't indicate this feature to usb framework if
-	 * our current hardware doesn't have the capability
-	 */
-	if ((message.event == PM_EVENT_AUTO_SUSPEND) &&
-	    (!(pdata->features & FEATURE_AUTOSUSPEND))) {
-		netdev_warn(dev->net, "autosuspend not supported\n");
-		return -EBUSY;
-	}
-
 	ret = usbnet_suspend(intf, message);
 	if (ret < 0) {
 		netdev_warn(dev->net, "usbnet_suspend error\n");
@@ -1441,7 +1432,8 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 	/* determine if link is up using only _nopm functions */
 	link_up = smsc95xx_link_ok_nopm(dev);
 
-	if (message.event == PM_EVENT_AUTO_SUSPEND) {
+	if (message.event == PM_EVENT_AUTO_SUSPEND &&
+	    (pdata->features & FEATURE_AUTOSUSPEND)) {
 		ret = smsc95xx_autosuspend(dev, link_up);
 		goto done;
 	}
-- 
1.7.9.5

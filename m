From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 1/3] smsc95xx: fix suspend buffer overflow
Date: Wed, 28 Nov 2012 17:46:57 +0000
Message-ID: <1354124819-29531-2-git-send-email-steve.glendinning@shawell.net>
References: <1354124819-29531-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	Bjorn Mork <bjorn@mork.no>, Joe Perches <joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:57943 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754156Ab2K1RrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 12:47:05 -0500
In-Reply-To: <1354124819-29531-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a buffer overflow introduced by bbd9f9e, where
the filter_mask array is accessed beyond its bounds.

Updated to also add a check for kzalloc failure, as reported by
Bjorn Mork and Joe Perches.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
Cc: Bjorn Mork <bjorn@mork.no>
Cc: Joe Perches <joe@perches.com>
---
 drivers/net/usb/smsc95xx.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 79d495d..c397b3a 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1281,7 +1281,7 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 	}
 
 	if (pdata->wolopts & (WAKE_BCAST | WAKE_MCAST | WAKE_ARP | WAKE_UCAST)) {
-		u32 *filter_mask = kzalloc(32, GFP_KERNEL);
+		u32 *filter_mask = kzalloc(sizeof(u32) * 32, GFP_KERNEL);
 		u32 command[2];
 		u32 offset[2];
 		u32 crc[4];
@@ -1290,6 +1290,11 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 			LAN9500A_WUFF_NUM : LAN9500_WUFF_NUM;
 		int i, filter = 0;
 
+		if (!filter_mask) {
+			netdev_warn(dev->net, "Unable to allocate filter_mask\n");
+			return -ENOMEM;
+		}
+
 		memset(command, 0, sizeof(command));
 		memset(offset, 0, sizeof(offset));
 		memset(crc, 0, sizeof(crc));
-- 
1.7.10.4

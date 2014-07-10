From: Joonyoung Shim <jy0922.shim@samsung.com>
Subject: [PATCH] usbnet: smsc95xx: add reset_resume function with reset
 operation
Date: Thu, 10 Jul 2014 11:49:42 +0900
Message-ID: <1404960582-28096-1-git-send-email-jy0922.shim@samsung.com>
Cc: steve.glendinning@shawell.net, drake@endlessm.com
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:9745 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbaGJCtp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2014 22:49:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The smsc95xx needs to resume with reset operation. Otherwise it causes
system hang by network error like below after resume. This case appears
on odroid u3 board.

[    9.727600] smsc95xx 1-2:1.0 eth0: kevent 2 may have been dropped
[    9.727648] smsc95xx 1-2:1.0 eth0: kevent 2 may have been dropped
[    9.727689] smsc95xx 1-2:1.0 eth0: kevent 2 may have been dropped
[    9.727728] smsc95xx 1-2:1.0 eth0: kevent 2 may have been dropped
[    9.729486] PM: resume of devices complete after 2011.219 msecs
[   10.117609] Restarting tasks ... done.
[   11.725099] smsc95xx 1-2:1.0 eth0: kevent 2 may have been dropped
[   13.480846] smsc95xx 1-2:1.0 eth0: kevent 2 may have been dropped
[   13.481361] smsc95xx 1-2:1.0 eth0: kevent 2 may have been dropped
...

Signed-off-by: Joonyoung Shim <jy0922.shim@samsung.com>
---
 drivers/net/usb/smsc95xx.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 424db65e..d07bf4c 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1714,6 +1714,18 @@ static int smsc95xx_resume(struct usb_interface *intf)
 	return ret;
 }
 
+static int smsc95xx_reset_resume(struct usb_interface *intf)
+{
+	struct usbnet *dev = usb_get_intfdata(intf);
+	int ret;
+
+	ret = smsc95xx_reset(dev);
+	if (ret < 0)
+		return ret;
+
+	return smsc95xx_resume(intf);
+}
+
 static void smsc95xx_rx_csum_offload(struct sk_buff *skb)
 {
 	skb->csum = *(u16 *)(skb_tail_pointer(skb) - 2);
@@ -2004,7 +2016,7 @@ static struct usb_driver smsc95xx_driver = {
 	.probe		= usbnet_probe,
 	.suspend	= smsc95xx_suspend,
 	.resume		= smsc95xx_resume,
-	.reset_resume	= smsc95xx_resume,
+	.reset_resume	= smsc95xx_reset_resume,
 	.disconnect	= usbnet_disconnect,
 	.disable_hub_initiated_lpm = 1,
 	.supports_autosuspend = 1,
-- 
1.8.1.2

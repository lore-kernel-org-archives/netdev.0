From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Subject: [PATCH] usbnet: cleanup after bind() in probe()
Date: Mon,  7 Mar 2016 11:31:10 +0100
Message-ID: <1457346670-24059-1-git-send-email-oneukum@suse.com>
Cc: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>, Oliver Neukum <ONeukum-IBi9RG/b67k@public.gmane.org>
To: andreyknvl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In case bind() works, but a later error forces bailing
in probe() in error cases work and a timer may be scheduled.
They must be killed. This fixes an error case related to
the double free reported in
http://www.spinics.net/lists/netdev/msg367669.html
and needs to go on top of Linus' fix to cdc-ncm.

Signed-off-by: Oliver Neukum <ONeukum-IBi9RG/b67k@public.gmane.org>
---
 drivers/net/usb/usbnet.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 0b0ba7e..1079812 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1769,6 +1769,13 @@ out3:
 	if (info->unbind)
 		info->unbind (dev, udev);
 out1:
+	/* subdrivers must undo all they did in bind() if they
+	 * fail it, but we may fail later and a deferred kevent
+	 * may trigger an error resubmitting itself and, worse,
+	 * schedule a timer. So we kill it all just in case.
+	 */
+	cancel_work_sync(&dev->kevent);
+	del_timer_sync(&dev->delay);
 	free_netdev(net);
 out:
 	return status;
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

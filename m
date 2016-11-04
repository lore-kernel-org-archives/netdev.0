From: Kai-Heng Feng <kai.heng.feng-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH] usbnet: prevent device rpm suspend in usbnet_probe function
Date: Fri,  4 Nov 2016 17:57:35 +0800
Message-ID: <20161104095735.21071-1-kai.heng.feng@canonical.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Kai-Heng Feng <kai.heng.feng-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
To: oneukum-IBi9RG/b67k@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Sometimes cdc_mbim failed to probe if runtime pm is enabled:
[    9.305626] cdc_mbim: probe of 2-2:1.12 failed with error -22

This can be solved by increase its pm usage counter.

Signed-off-by: Kai-Heng Feng <kai.heng.feng-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/usb/usbnet.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index d5071e3..f77b4bf 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1674,12 +1674,15 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	net->watchdog_timeo = TX_TIMEOUT_JIFFIES;
 	net->ethtool_ops = &usbnet_ethtool_ops;
 
+	if (usb_autopm_get_interface(dev->intf) < 0)
+		goto out1;
+
 	// allow device-specific bind/init procedures
 	// NOTE net->name still not usable ...
 	if (info->bind) {
 		status = info->bind (dev, udev);
 		if (status < 0)
-			goto out1;
+			goto out2;
 
 		// heuristic:  "usb%d" for links we know are two-host,
 		// else "eth%d" when there's reasonable doubt.  userspace
@@ -1772,6 +1775,8 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 out3:
 	if (info->unbind)
 		info->unbind (dev, udev);
+out2:
+	usb_autopm_put_interface(dev->intf);
 out1:
 	/* subdrivers must undo all they did in bind() if they
 	 * fail it, but we may fail later and a deferred kevent
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

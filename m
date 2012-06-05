From: Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] usbnet: Activate the halt interrupt endpoint to fix endless
 "XactErr" error
Date: Tue, 5 Jun 2012 22:12:17 +0800
Message-ID: <CA+v9cxYHq4gcy11SDmsuHUhTSdLJM-G0sugYnOjSthbYWA+1Yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

There prints endless "XactErr" error msg once switch my device to the
configuration
 which needs cdc_ether driver, the root cause is the interrupt endpoint halts.
Maybe this is a common issue, so fix it by activating the endpoint
once the error occurs.

Signed-off-by: Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/usb/usbnet.c   |   33 +++++++++++++++++++++++++++++++++
 include/linux/usb/usbnet.h |   15 ++++++++-------
 2 files changed, 41 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 9f58330..f13922b 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -537,6 +537,11 @@ static void intr_complete (struct urb *urb)
 			  "intr shutdown, code %d\n", status);
 		return;

+	case -EPIPE:
+	case -EPROTO:
+		usbnet_defer_kevent(dev, EVENT_STS_HALT);
+		return;
+
 	/* NOTE:  not throttling like RX/TX, since this endpoint
 	 * already polls infrequently
 	 */
@@ -967,6 +972,34 @@ fail_halt:
 		}
 	}

+	if (test_bit(EVENT_STS_HALT, &dev->flags)) {
+		unsigned pipe;
+		struct usb_endpoint_descriptor *desc;
+
+		desc = &dev->status->desc;
+		pipe = usb_rcvintpipe(dev->udev,
+			desc->bEndpointAddress & USB_ENDPOINT_NUMBER_MASK);
+		status = usb_autopm_get_interface(dev->intf);
+		if (status < 0)
+			goto fail_sts;
+		status = usb_clear_halt(dev->udev, pipe);
+		usb_autopm_put_interface(dev->intf);
+
+		if (status < 0 && status != -EPIPE && status != -ESHUTDOWN) {
+fail_sts:
+			netdev_err(dev->net,
+				"can't clear intr halt, status %d\n", status);
+		} else {
+			clear_bit(EVENT_STS_HALT, &dev->flags);
+			memset(dev->interrupt->transfer_buffer, 0,
+				dev->interrupt->transfer_buffer_length);
+			status = usb_submit_urb(dev->interrupt, GFP_KERNEL);
+			if (status != 0)
+				netif_err(dev, timer, dev->net,
+					"intr resubmit --> %d\n", status);
+		}
+	}
+
 	/* tasklet could resubmit itself forever if memory is tight */
 	if (test_bit (EVENT_RX_MEMORY, &dev->flags)) {
 		struct urb	*urb = NULL;
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 76f4396..c0bcb61 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -62,13 +62,14 @@ struct usbnet {
 	unsigned long		flags;
 #		define EVENT_TX_HALT	0
 #		define EVENT_RX_HALT	1
-#		define EVENT_RX_MEMORY	2
-#		define EVENT_STS_SPLIT	3
-#		define EVENT_LINK_RESET	4
-#		define EVENT_RX_PAUSED	5
-#		define EVENT_DEV_WAKING 6
-#		define EVENT_DEV_ASLEEP 7
-#		define EVENT_DEV_OPEN	8
+#		define EVENT_STS_HALT	2
+#		define EVENT_RX_MEMORY	3
+#		define EVENT_STS_SPLIT	4
+#		define EVENT_LINK_RESET	5
+#		define EVENT_RX_PAUSED	6
+#		define EVENT_DEV_WAKING 7
+#		define EVENT_DEV_ASLEEP 8
+#		define EVENT_DEV_OPEN	9
 };

 static inline struct usb_driver *driver_of(struct usb_interface *intf)
-- 
1.7.9.5
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

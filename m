From: Huajun Li <huajun.li.lee@gmail.com>
Subject: [PATCH] usbnet: Activate halt interrupt endpoint before re-submit URB
Date: Wed, 13 Jun 2012 20:50:31 +0800
Message-ID: <CA+v9cxad+THL8u7tr_ubD7H7o+6x+qTOXOgowmPDnWUxa8aJtQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ming Lei <tom.leiming@gmail.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	lud <linux-usb@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Huajun Li <huajun.li.lee@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:60697 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752718Ab2FMMud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 08:50:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

intr_complete() submits URB even the interrupt endpoint stalls.
This patch will try to activate the endpoint once the exception
occurs, and then re-submit the URB if the endpoint works again.

Signed-off-by: Huajun Li <huajun.li.lee@gmail.com>
---
 drivers/net/usb/usbnet.c   |   31 +++++++++++++++++++++++++++++++
 include/linux/usb/usbnet.h |   13 +++++++------
 2 files changed, 38 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index ac2e493..314aaea 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -198,6 +198,10 @@ static void intr_complete (struct urb *urb)
 			  "intr shutdown, code %d\n", status);
 		return;

+	case -EPIPE:
+		usbnet_defer_kevent(dev, EVENT_STS_HALT);
+		return;
+
 	/* NOTE:  not throttling like RX/TX, since this endpoint
 	 * already polls infrequently
 	 */
@@ -964,6 +968,33 @@ fail_halt:
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
+		if (status < 0) {
+			usb_autopm_put_interface(dev->intf);
+fail_sts:
+			netdev_err(dev->net,
+				"can't clear intr halt, status %d\n", status);
+		} else {
+			clear_bit(EVENT_STS_HALT, &dev->flags);
+			status = usb_submit_urb(dev->interrupt, GFP_KERNEL);
+			if (status != 0)
+				netif_err(dev, timer, dev->net,
+					"intr resubmit --> %d\n", status);
+
+			usb_autopm_put_interface(dev->intf);
+		}
+	}
+
 	/* tasklet could resubmit itself forever if memory is tight */
 	if (test_bit (EVENT_RX_MEMORY, &dev->flags)) {
 		struct urb	*urb = NULL;
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index f87cf62..81b4473 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -62,12 +62,13 @@ struct usbnet {
 	unsigned long		flags;
 #		define EVENT_TX_HALT	0
 #		define EVENT_RX_HALT	1
-#		define EVENT_RX_MEMORY	2
-#		define EVENT_STS_SPLIT	3
-#		define EVENT_LINK_RESET	4
-#		define EVENT_RX_PAUSED	5
-#		define EVENT_DEV_ASLEEP 6
-#		define EVENT_DEV_OPEN	7
+#		define EVENT_STS_HALT	2
+#		define EVENT_RX_MEMORY	3
+#		define EVENT_STS_SPLIT	4
+#		define EVENT_LINK_RESET	5
+#		define EVENT_RX_PAUSED	6
+#		define EVENT_DEV_ASLEEP 7
+#		define EVENT_DEV_OPEN	8
 };

 static inline struct usb_driver *driver_of(struct usb_interface *intf)
-- 
1.7.9.5

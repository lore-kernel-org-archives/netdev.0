From: Jussi Kivilinna <jussi.kivilinna-X3B1VOXEql0@public.gmane.org>
Subject: [PATCH 2/2] net/usb: hso: allocate serial_state_notification as
 separate buffer
Date: Wed, 07 Aug 2013 16:29:07 +0300
Message-ID: <20130807132907.14451.2928.stgit@localhost6.localdomain6>
References: <20130807132902.14451.37517.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130807132902.14451.37517.stgit-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

URB transfer_buffers must not be allocated as part of larger structure because
DMA coherence issues.

Patch changes hso to allocate serial_state_notification member of
'struct hso_tiocmget' as separate buffer.

Patch is only compile tested.

Cc: <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Signed-off-by: Jussi Kivilinna <jussi.kivilinna-X3B1VOXEql0@public.gmane.org>
---
 drivers/net/usb/hso.c |   18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index fc082c0..21ffa6f 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -211,7 +211,7 @@ struct hso_tiocmget {
 	int    intr_completed;
 	struct usb_endpoint_descriptor *endp;
 	struct urb *urb;
-	struct hso_serial_state_notification serial_state_notification;
+	struct hso_serial_state_notification *serial_state_notification;
 	u16    prev_UART_state_bitmap;
 	struct uart_icount icount;
 };
@@ -1465,7 +1465,7 @@ static int tiocmget_submit_urb(struct hso_serial *serial,
 			 usb_rcvintpipe(usb,
 					tiocmget->endp->
 					bEndpointAddress & 0x7F),
-			 &tiocmget->serial_state_notification,
+			 tiocmget->serial_state_notification,
 			 sizeof(struct hso_serial_state_notification),
 			 tiocmget_intr_callback, serial,
 			 tiocmget->endp->bInterval);
@@ -1499,7 +1499,7 @@ static void tiocmget_intr_callback(struct urb *urb)
 	if (!tiocmget)
 		return;
 	usb = serial->parent->usb;
-	serial_state_notification = &tiocmget->serial_state_notification;
+	serial_state_notification = tiocmget->serial_state_notification;
 	if (serial_state_notification->bmRequestType != BM_REQUEST_TYPE ||
 	    serial_state_notification->bNotification != B_NOTIFICATION ||
 	    le16_to_cpu(serial_state_notification->wValue) != W_VALUE ||
@@ -2608,6 +2608,7 @@ static void hso_free_tiomget(struct hso_serial *serial)
 		usb_free_urb(tiocmget->urb);
 		tiocmget->urb = NULL;
 		serial->tiocmget = NULL;
+		kfree(tiocmget->serial_state_notification);
 		kfree(tiocmget);
 	}
 }
@@ -2664,6 +2665,13 @@ static struct hso_device *hso_create_bulk_serial_device(
 		 */
 		if (serial->tiocmget) {
 			tiocmget = serial->tiocmget;
+
+			tiocmget->serial_state_notification = kzalloc(
+				sizeof(struct hso_serial_state_notification),
+				GFP_KERNEL);
+			if (!tiocmget->serial_state_notification)
+				goto tiocmget_fail;
+
 			tiocmget->urb = usb_alloc_urb(0, GFP_KERNEL);
 			if (tiocmget->urb) {
 				mutex_init(&tiocmget->mutex);
@@ -2672,8 +2680,10 @@ static struct hso_device *hso_create_bulk_serial_device(
 					interface,
 					USB_ENDPOINT_XFER_INT,
 					USB_DIR_IN);
-			} else
+			} else {
+tiocmget_fail:
 				hso_free_tiomget(serial);
+			}
 		}
 	}
 	else

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

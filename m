From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 6/7] usbnet: remove declaration for intr_complete
Date: Tue, 12 Jun 2012 09:19:44 +0800
Message-ID: <1339463985-9006-7-git-send-email-tom.leiming@gmail.com>
References: <1339463985-9006-1-git-send-email-tom.leiming@gmail.com>
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1339463985-9006-1-git-send-email-tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Remove declaration for intr_complete so that ctags may be happy to
decrease duplicated symbols, also decrease one line code.

Signed-off-by: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/usb/usbnet.c |   72 ++++++++++++++++++++++------------------------
 1 file changed, 35 insertions(+), 37 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 96f8a08..f4bd5fa 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -180,7 +180,41 @@ int usbnet_get_ethernet_addr(struct usbnet *dev, int iMACAddress)
 }
 EXPORT_SYMBOL_GPL(usbnet_get_ethernet_addr);
 
-static void intr_complete (struct urb *urb);
+static void intr_complete (struct urb *urb)
+{
+	struct usbnet	*dev = urb->context;
+	int		status = urb->status;
+
+	switch (status) {
+	/* success */
+	case 0:
+		dev->driver_info->status(dev, urb);
+		break;
+
+	/* software-driven interface shutdown */
+	case -ENOENT:		/* urb killed */
+	case -ESHUTDOWN:	/* hardware gone */
+		netif_dbg(dev, ifdown, dev->net,
+			  "intr shutdown, code %d\n", status);
+		return;
+
+	/* NOTE:  not throttling like RX/TX, since this endpoint
+	 * already polls infrequently
+	 */
+	default:
+		netdev_dbg(dev->net, "intr status %d\n", status);
+		break;
+	}
+
+	if (!netif_running (dev->net))
+		return;
+
+	memset(urb->transfer_buffer, 0, urb->transfer_buffer_length);
+	status = usb_submit_urb (urb, GFP_ATOMIC);
+	if (status != 0)
+		netif_err(dev, timer, dev->net,
+			  "intr resubmit --> %d\n", status);
+}
 
 static int init_status (struct usbnet *dev, struct usb_interface *intf)
 {
@@ -519,42 +553,6 @@ block:
 	netif_dbg(dev, rx_err, dev->net, "no read resubmitted\n");
 }
 
-static void intr_complete (struct urb *urb)
-{
-	struct usbnet	*dev = urb->context;
-	int		status = urb->status;
-
-	switch (status) {
-	/* success */
-	case 0:
-		dev->driver_info->status(dev, urb);
-		break;
-
-	/* software-driven interface shutdown */
-	case -ENOENT:		/* urb killed */
-	case -ESHUTDOWN:	/* hardware gone */
-		netif_dbg(dev, ifdown, dev->net,
-			  "intr shutdown, code %d\n", status);
-		return;
-
-	/* NOTE:  not throttling like RX/TX, since this endpoint
-	 * already polls infrequently
-	 */
-	default:
-		netdev_dbg(dev->net, "intr status %d\n", status);
-		break;
-	}
-
-	if (!netif_running (dev->net))
-		return;
-
-	memset(urb->transfer_buffer, 0, urb->transfer_buffer_length);
-	status = usb_submit_urb (urb, GFP_ATOMIC);
-	if (status != 0)
-		netif_err(dev, timer, dev->net,
-			  "intr resubmit --> %d\n", status);
-}

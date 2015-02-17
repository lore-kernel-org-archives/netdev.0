From: Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>
Subject: [PATCH] hso: always read interface number from the current altsetting
Date: Tue, 17 Feb 2015 11:31:29 +0100
Message-ID: <1424169089-25039-1-git-send-email-aleksander@aleksander.es>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>
To: j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Always read bInterfaceNumber from the current altsetting, not from the first one
available in the altsetting array. This is coming from code review, not related
to any specific bug.

Signed-off-by: Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>
---
 drivers/net/usb/hso.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 9cdfb3f..3c8dfe5 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -1477,6 +1477,7 @@ static void tiocmget_intr_callback(struct urb *urb)
 	struct uart_icount *icount;
 	struct hso_serial_state_notification *serial_state_notification;
 	struct usb_device *usb;
+	struct usb_interface *interface;
 	int if_num;
 
 	/* Sanity checks */
@@ -1494,7 +1495,9 @@ static void tiocmget_intr_callback(struct urb *urb)
 	BUG_ON((serial->parent->port_spec & HSO_PORT_MASK) != HSO_PORT_MODEM);
 
 	usb = serial->parent->usb;
-	if_num = serial->parent->interface->altsetting->desc.bInterfaceNumber;
+	interface = serial->parent->interface;
+
+	if_num = interface->cur_altsetting->desc.bInterfaceNumber;
 
 	/* wIndex should be the USB interface number of the port to which the
 	 * notification applies, which should always be the Modem port.
@@ -1675,6 +1678,7 @@ static int hso_serial_tiocmset(struct tty_struct *tty,
 	unsigned long flags;
 	int if_num;
 	struct hso_serial *serial = tty->driver_data;
+	struct usb_interface *interface;
 
 	/* sanity check */
 	if (!serial) {
@@ -1685,7 +1689,8 @@ static int hso_serial_tiocmset(struct tty_struct *tty,
 	if ((serial->parent->port_spec & HSO_PORT_MASK) != HSO_PORT_MODEM)
 		return -EINVAL;
 
-	if_num = serial->parent->interface->altsetting->desc.bInterfaceNumber;
+	interface = serial->parent->interface;
+	if_num = interface->cur_altsetting->desc.bInterfaceNumber;
 
 	spin_lock_irqsave(&serial->serial_lock, flags);
 	if (set & TIOCM_RTS)
@@ -2808,7 +2813,7 @@ static int hso_get_config_data(struct usb_interface *interface)
 {
 	struct usb_device *usbdev = interface_to_usbdev(interface);
 	u8 *config_data = kmalloc(17, GFP_KERNEL);
-	u32 if_num = interface->altsetting->desc.bInterfaceNumber;
+	u32 if_num = interface->cur_altsetting->desc.bInterfaceNumber;
 	s32 result;
 
 	if (!config_data)
@@ -2886,7 +2891,7 @@ static int hso_probe(struct usb_interface *interface,
 		return -ENODEV;
 	}
 
-	if_num = interface->altsetting->desc.bInterfaceNumber;
+	if_num = interface->cur_altsetting->desc.bInterfaceNumber;
 
 	/* Get the interface/port specification from either driver_info or from
 	 * the device itself */
-- 
2.3.0

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

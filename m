From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH] hso: fix handling of modem port SERIAL_STATE notifications
Date: Mon, 06 Jan 2014 10:07:29 -0600
Message-ID: <1389024449.1866.3.camel@dcbw.local>
References: <B1808224-5850-41E3-9A8F-0F350F84FF89@goldelico.com>
	 <541AADAC-7D20-4410-90FC-3E354B0C1457@goldelico.com>
	 <1387222829.2156.51.camel@dcbw.foobar.com>
	 <174CD81C-6425-4560-A3FA-3BFAA83BA770@goldelico.com>
	 <1387319242.28943.42.camel@dcbw.local>
	 <54ED5542-6C9E-4AC6-90CC-ED77972D8CB1@goldelico.com>
	 <1387388963.5549.11.camel@dcbw.local>
	 <874B65AE-8B15-4427-8EF4-F0CA2BC55062@goldelico.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jan Dumon <j.dumon@option.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Belisko Marek <marek.belisko@gmail.com>, e.verdonck@option.com
To: "Dr. H. Nikolaus Schaller" <hns@goldelico.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <874B65AE-8B15-4427-8EF4-F0CA2BC55062@goldelico.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The existing serial state notification handling expected older Option
devices, having a hardcoded assumption that the Modem port was always
USB interface #2.  That isn't true for devices from the past few years.

hso_serial_state_notification is a local cache of a USB Communications
Interface Class SERIAL_STATE notification from the device, and the
USB CDC specification (section 6.3, table 67 "Class-Specific Notifications")
defines wIndex as the USB interface the event applies to.  For hso
devices this will always be the Modem port, as the Modem port is the
only port which is set up to receive them by the driver.

So instead of always expecting USB interface #2, instead validate the
notification with the actual USB interface number of the Modem port.

Signed-off-by: Dan Williams <dcbw@redhat.com>
Tested-by: H. Nikolaus Schaller <hns@goldelico.com>
---
 drivers/net/usb/hso.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 86292e6..1a48234 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -181,15 +181,14 @@ enum rx_ctrl_state{
 	RX_SENT,
 	RX_PENDING
 };
 
 #define BM_REQUEST_TYPE (0xa1)
 #define B_NOTIFICATION  (0x20)
 #define W_VALUE         (0x0)
-#define W_INDEX         (0x2)
 #define W_LENGTH        (0x2)
 
 #define B_OVERRUN       (0x1<<6)
 #define B_PARITY        (0x1<<5)
 #define B_FRAMING       (0x1<<4)
 #define B_RING_SIGNAL   (0x1<<3)
 #define B_BREAK         (0x1<<2)
@@ -1483,31 +1482,41 @@ static void tiocmget_intr_callback(struct urb *urb)
 	struct hso_serial *serial = urb->context;
 	struct hso_tiocmget *tiocmget;
 	int status = urb->status;
 	u16 UART_state_bitmap, prev_UART_state_bitmap;
 	struct uart_icount *icount;
 	struct hso_serial_state_notification *serial_state_notification;
 	struct usb_device *usb;
+	int if_num;
 
 	/* Sanity checks */
 	if (!serial)
 		return;
 	if (status) {
 		handle_usb_error(status, __func__, serial->parent);
 		return;
 	}
+
+	/* tiocmget is only supported on HSO_PORT_MODEM */
 	tiocmget = serial->tiocmget;
 	if (!tiocmget)
 		return;
+	BUG_ON((serial->parent->port_spec & HSO_PORT_MASK) != HSO_PORT_MODEM);
+
 	usb = serial->parent->usb;
+	if_num = serial->parent->interface->altsetting->desc.bInterfaceNumber;
+
+	/* wIndex should be the USB interface number of the port to which the
+	 * notification applies, which should always be the Modem port.
+	 */
 	serial_state_notification = &tiocmget->serial_state_notification;
 	if (serial_state_notification->bmRequestType != BM_REQUEST_TYPE ||
 	    serial_state_notification->bNotification != B_NOTIFICATION ||
 	    le16_to_cpu(serial_state_notification->wValue) != W_VALUE ||
-	    le16_to_cpu(serial_state_notification->wIndex) != W_INDEX ||
+	    le16_to_cpu(serial_state_notification->wIndex) != if_num ||
 	    le16_to_cpu(serial_state_notification->wLength) != W_LENGTH) {
 		dev_warn(&usb->dev,
 			 "hso received invalid serial state notification\n");
 		DUMP(serial_state_notification,
 		     sizeof(struct hso_serial_state_notification));
 	} else {
 
-- 
1.8.3.1

From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] hso: Use a more common logging style
Date: Fri,  2 Sep 2016 15:58:01 -0700
Message-ID: <178228a21f16abf9f9d867a3dd7a179c19cdde51.1472856901.git.joe@perches.com>
References: <cover.1472856901.git.joe@perches.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jan Dumon <j.dumon@option.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1472856901.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Macros that end in an underscore are just odd.
Add hso_dbg(level, fmt, ...) and use it everwhere instead.

Several uses had additional unnecessary newlines as the
macro added a newline.  Remove the newline from the macro
and add newlines to each use as appropriate.

Remove now unused D<digit> macros.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/usb/hso.c | 97 +++++++++++++++++++++++----------------------------
 1 file changed, 44 insertions(+), 53 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index c5544d3..6c37512 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -108,23 +108,12 @@
 /*****************************************************************************/
 /* Debugging functions                                                       */
 /*****************************************************************************/
-#define D__(lvl_, fmt, arg...)				\
-	do {						\
-		printk(lvl_ "[%d:%s]: " fmt "\n",	\
-		       __LINE__, __func__, ## arg);	\
-	} while (0)
-
-#define D_(lvl, args...)				\
-	do {						\
-		if (lvl & debug)			\
-			D__(KERN_INFO, args);		\
-	} while (0)
-
-#define D1(args...)	D_(0x01, ##args)
-#define D2(args...)	D_(0x02, ##args)
-#define D3(args...)	D_(0x04, ##args)
-#define D4(args...)	D_(0x08, ##args)
-#define D5(args...)	D_(0x10, ##args)
+#define hso_dbg(lvl, fmt, ...)						\
+do {									\
+	if ((lvl) & debug)						\
+		pr_info("[%d:%s] " fmt,					\
+			__LINE__, __func__, ##__VA_ARGS__);		\
+} while (0)
 
 /*****************************************************************************/
 /* Enumerators                                                               */
@@ -709,7 +698,8 @@ static void handle_usb_error(int status, const char *function,
 	}
 
 	/* log a meaningful explanation of an USB status */
-	D1("%s: received USB status - %s (%d)", function, explanation, status);
+	hso_dbg(0x1, "%s: received USB status - %s (%d)\n",
+		function, explanation, status);
 }
 
 /* Network interface functions */
@@ -808,7 +798,7 @@ static netdev_tx_t hso_net_start_xmit(struct sk_buff *skb,
 	DUMP1(skb->data, skb->len);
 	/* Copy it from kernel memory to OUR memory */
 	memcpy(odev->mux_bulk_tx_buf, skb->data, skb->len);
-	D1("len: %d/%d", skb->len, MUX_BULK_TX_BUF_SIZE);
+	hso_dbg(0x1, "len: %d/%d\n", skb->len, MUX_BULK_TX_BUF_SIZE);
 
 	/* Fill in the URB for shipping it out. */
 	usb_fill_bulk_urb(odev->mux_bulk_tx_urb,
@@ -872,7 +862,7 @@ static void packetizeRx(struct hso_net *odev, unsigned char *ip_pkt,
 	unsigned char *tmp_rx_buf;
 
 	/* log if needed */
-	D1("Rx %d bytes", count);
+	hso_dbg(0x1, "Rx %d bytes\n", count);
 	DUMP(ip_pkt, min(128, (int)count));
 
 	while (count) {
@@ -912,7 +902,7 @@ static void packetizeRx(struct hso_net *odev, unsigned char *ip_pkt,
 								    frame_len);
 				if (!odev->skb_rx_buf) {
 					/* We got no receive buffer. */
-					D1("could not allocate memory");
+					hso_dbg(0x1, "could not allocate memory\n");
 					odev->rx_parse_state = WAIT_SYNC;
 					continue;
 				}
@@ -972,11 +962,11 @@ static void packetizeRx(struct hso_net *odev, unsigned char *ip_pkt,
 			break;
 
 		case WAIT_SYNC:
-			D1(" W_S");
+			hso_dbg(0x1, " W_S\n");
 			count = 0;
 			break;
 		default:
-			D1(" ");
+			hso_dbg(0x1, "\n");
 			count--;
 			break;
 		}
@@ -1020,7 +1010,7 @@ static void read_bulk_callback(struct urb *urb)
 
 	/* Sanity check */
 	if (!odev || !test_bit(HSO_NET_RUNNING, &odev->flags)) {
-		D1("BULK IN callback but driver is not active!");
+		hso_dbg(0x1, "BULK IN callback but driver is not active!\n");
 		return;
 	}
 	usb_mark_last_busy(urb->dev);
@@ -1116,7 +1106,7 @@ static void _hso_serial_set_termios(struct tty_struct *tty,
 		return;
 	}
 
-	D4("port %d", serial->minor);
+	hso_dbg(0x8, "port %d\n", serial->minor);
 
 	/*
 	 *	Fix up unsupported bits
@@ -1205,11 +1195,11 @@ static void hso_std_serial_read_bulk_callback(struct urb *urb)
 	struct hso_serial *serial = urb->context;
 	int status = urb->status;
 
-	D4("\n--- Got serial_read_bulk callback %02x ---", status);
+	hso_dbg(0x8, "--- Got serial_read_bulk callback %02x ---\n", status);
 
 	/* sanity check */
 	if (!serial) {
-		D1("serial == NULL");
+		hso_dbg(0x1, "serial == NULL\n");
 		return;
 	}
 	if (status) {
@@ -1217,7 +1207,7 @@ static void hso_std_serial_read_bulk_callback(struct urb *urb)
 		return;
 	}
 
-	D1("Actual length = %d\n", urb->actual_length);
+	hso_dbg(0x1, "Actual length = %d\n", urb->actual_length);
 	DUMP1(urb->transfer_buffer, urb->actual_length);
 
 	/* Anyone listening? */
@@ -1266,7 +1256,7 @@ static int hso_serial_open(struct tty_struct *tty, struct file *filp)
 	if (serial == NULL || serial->magic != HSO_SERIAL_MAGIC) {
 		WARN_ON(1);
 		tty->driver_data = NULL;
-		D1("Failed to open port");
+		hso_dbg(0x1, "Failed to open port\n");
 		return -ENODEV;
 	}
 
@@ -1275,7 +1265,7 @@ static int hso_serial_open(struct tty_struct *tty, struct file *filp)
 	if (result < 0)
 		goto err_out;
 
-	D1("Opening %d", serial->minor);
+	hso_dbg(0x1, "Opening %d\n", serial->minor);
 
 	/* setup */
 	tty->driver_data = serial;
@@ -1298,7 +1288,7 @@ static int hso_serial_open(struct tty_struct *tty, struct file *filp)
 			kref_get(&serial->parent->ref);
 		}
 	} else {
-		D1("Port was already open");
+		hso_dbg(0x1, "Port was already open\n");
 	}
 
 	usb_autopm_put_interface(serial->parent->interface);
@@ -1317,7 +1307,7 @@ static void hso_serial_close(struct tty_struct *tty, struct file *filp)
 	struct hso_serial *serial = tty->driver_data;
 	u8 usb_gone;
 
-	D1("Closing serial port");
+	hso_dbg(0x1, "Closing serial port\n");
 
 	/* Open failed, no close cleanup required */
 	if (serial == NULL)
@@ -1412,8 +1402,8 @@ static void hso_serial_set_termios(struct tty_struct *tty, struct ktermios *old)
 	unsigned long flags;
 
 	if (old)
-		D5("Termios called with: cflags new[%d] - old[%d]",
-		   tty->termios.c_cflag, old->c_cflag);
+		hso_dbg(0x16, "Termios called with: cflags new[%d] - old[%d]\n",
+			tty->termios.c_cflag, old->c_cflag);
 
 	/* the actual setup */
 	spin_lock_irqsave(&serial->serial_lock, flags);
@@ -1649,7 +1639,7 @@ static int hso_serial_tiocmget(struct tty_struct *tty)
 
 	/* sanity check */
 	if (!serial) {
-		D1("no tty structures");
+		hso_dbg(0x1, "no tty structures\n");
 		return -EINVAL;
 	}
 	spin_lock_irq(&serial->serial_lock);
@@ -1682,7 +1672,7 @@ static int hso_serial_tiocmset(struct tty_struct *tty,
 
 	/* sanity check */
 	if (!serial) {
-		D1("no tty structures");
+		hso_dbg(0x1, "no tty structures\n");
 		return -EINVAL;
 	}
 
@@ -1721,7 +1711,7 @@ static int hso_serial_ioctl(struct tty_struct *tty,
 {
 	struct hso_serial *serial = tty->driver_data;
 	int ret = 0;
-	D4("IOCTL cmd: %d, arg: %ld", cmd, arg);
+	hso_dbg(0x8, "IOCTL cmd: %d, arg: %ld\n", cmd, arg);
 
 	if (!serial)
 		return -ENODEV;
@@ -1808,9 +1798,9 @@ static int mux_device_request(struct hso_serial *serial, u8 type, u16 port,
 		pipe = usb_sndctrlpipe(serial->parent->usb, 0);
 	}
 	/* syslog */
-	D2("%s command (%02x) len: %d, port: %d",
-	   type == USB_CDC_GET_ENCAPSULATED_RESPONSE ? "Read" : "Write",
-	   ctrl_req->bRequestType, ctrl_req->wLength, port);
+	hso_dbg(0x2, "%s command (%02x) len: %d, port: %d\n",
+		type == USB_CDC_GET_ENCAPSULATED_RESPONSE ? "Read" : "Write",
+		ctrl_req->bRequestType, ctrl_req->wLength, port);
 
 	/* Load ctrl urb */
 	ctrl_urb->transfer_flags = 0;
@@ -1876,11 +1866,11 @@ static void intr_callback(struct urb *urb)
 		handle_usb_error(status, __func__, NULL);
 		return;
 	}
-	D4("\n--- Got intr callback 0x%02X ---", status);
+	hso_dbg(0x8, "--- Got intr callback 0x%02X ---\n", status);
 
 	/* what request? */
 	port_req = urb->transfer_buffer;
-	D4(" port_req = 0x%.2X\n", *port_req);
+	hso_dbg(0x8, "port_req = 0x%.2X\n", *port_req);
 	/* loop over all muxed ports to find the one sending this */
 	for (i = 0; i < 8; i++) {
 		/* max 8 channels on MUX */
@@ -1888,7 +1878,8 @@ static void intr_callback(struct urb *urb)
 			serial = get_serial_by_shared_int_and_type(shared_int,
 								   (1 << i));
 			if (serial != NULL) {
-				D1("Pending read interrupt on port %d\n", i);
+				hso_dbg(0x1, "Pending read interrupt on port %d\n",
+					i);
 				spin_lock(&serial->serial_lock);
 				if (serial->rx_state == RX_IDLE &&
 					serial->port.count > 0) {
@@ -1900,8 +1891,8 @@ static void intr_callback(struct urb *urb)
 					} else
 						serial->rx_state = RX_PENDING;
 				} else {
-					D1("Already a read pending on "
-					   "port %d or port not open\n", i);
+					hso_dbg(0x1, "Already a read pending on port %d or port not open\n",
+						i);
 				}
 				spin_unlock(&serial->serial_lock);
 			}
@@ -1933,7 +1924,7 @@ static void hso_std_serial_write_bulk_callback(struct urb *urb)
 
 	/* sanity check */
 	if (!serial) {
-		D1("serial == NULL");
+		hso_dbg(0x1, "serial == NULL\n");
 		return;
 	}
 
@@ -1948,7 +1939,7 @@ static void hso_std_serial_write_bulk_callback(struct urb *urb)
 	tty_port_tty_wakeup(&serial->port);
 	hso_kick_transmit(serial);
 
-	D1(" ");
+	hso_dbg(0x1, "\n");
 }
 
 /* called for writing diag or CS serial port */
@@ -1996,8 +1987,8 @@ static void ctrl_callback(struct urb *urb)
 
 	/* what request? */
 	req = (struct usb_ctrlrequest *)(urb->setup_packet);
-	D4("\n--- Got muxed ctrl callback 0x%02X ---", status);
-	D4("Actual length of urb = %d\n", urb->actual_length);
+	hso_dbg(0x8, "--- Got muxed ctrl callback 0x%02X ---\n", status);
+	hso_dbg(0x8, "Actual length of urb = %d\n", urb->actual_length);
 	DUMP1(urb->transfer_buffer, urb->actual_length);
 
 	if (req->bRequestType ==
@@ -2023,7 +2014,7 @@ static int put_rxbuf_data(struct urb *urb, struct hso_serial *serial)
 
 	/* Sanity check */
 	if (urb == NULL || serial == NULL) {
-		D1("serial = NULL");
+		hso_dbg(0x1, "serial = NULL\n");
 		return -2;
 	}
 
@@ -2035,7 +2026,7 @@ static int put_rxbuf_data(struct urb *urb, struct hso_serial *serial)
 	}
 
 	/* Push data to tty */
-	D1("data to push to tty");
+	hso_dbg(0x1, "data to push to tty\n");
 	count = tty_buffer_request_room(&serial->port, urb->actual_length);
 	if (count >= urb->actual_length) {
 		tty_insert_flip_string(&serial->port, urb->transfer_buffer,
@@ -2415,7 +2406,7 @@ static void hso_net_init(struct net_device *net)
 {
 	struct hso_net *hso_net = netdev_priv(net);
 
-	D1("sizeof hso_net is %d", (int)sizeof(*hso_net));
+	hso_dbg(0x1, "sizeof hso_net is %zu\n", sizeof(*hso_net));
 
 	/* fill in the other fields */
 	net->netdev_ops = &hso_netdev_ops;
@@ -3301,7 +3292,7 @@ MODULE_DESCRIPTION(MOD_DESCRIPTION);
 MODULE_LICENSE(MOD_LICENSE);
 
 /* change the debug level (eg: insmod hso.ko debug=0x04) */
-MODULE_PARM_DESC(debug, "Level of debug [0x01 | 0x02 | 0x04 | 0x08 | 0x10]");
+MODULE_PARM_DESC(debug, "debug level mask [0x01 | 0x02 | 0x04 | 0x08 | 0x10]");
 module_param(debug, int, S_IRUGO | S_IWUSR);
 
 /* set the major tty number (eg: insmod hso.ko tty_major=245) */
-- 
2.10.0.rc2.1.g053435c

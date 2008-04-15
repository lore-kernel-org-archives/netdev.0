From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Tue, 15 Apr 2008 13:44:40 +0200
Message-ID: <200804151344.42085.oliver@neukum.org>
References: <20080414213238.GB28833@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>,
	Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>,
	ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080414213238.GB28833-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Montag, 14. April 2008 23:32:39 schrieb Greg KH:
> Hi all,
> 
> Here's a patch that I have cleaned up for context only from Option that
> is a USB serial / network device all in one.
> 
> I'd like to see this go into 2.6.26, so any review comments by anyone
> who wishes to review any portion of this would be greatly apprecited.

Hi,

this patch against Greg's version with Pauliaus patch applied

- uses correct CDC includes and constants
- fixes a race between disconnect and open
- fixes a race between probe and open
- corrects incorrect uses of GFP_KERNEL
- adds some error handling in open
- fixes races in access to urb->status

There's still a race condition in the write path left and the autosuspend
handling is broken in extremely interesting ways. The next patch will fix
these and I am still doing further reviews.

	Regards
		Oliver

Signed-off-by: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>

---

--- linux-2.6.25-rc7-vanilla/drivers/net/usb/hso.c	2008-04-15 13:33:25.000000000 +0200
+++ linux-2.6.25-rc7-work/drivers/net/usb/hso.c	2008-04-15 13:07:21.000000000 +0200
@@ -60,6 +60,7 @@
 #include <linux/ip.h>
 #include <linux/proc_fs.h>
 #include <linux/uaccess.h>
+#include <linux/usb/cdc.h>
 #include <net/arp.h>
 #include <asm/byteorder.h>
 
@@ -94,25 +95,10 @@
 
 #define	HSO_NET_TX_TIMEOUT		(HZ*10)
 
-#define SEND_ENCAPSULATED_COMMAND	0x00
-#define GET_ENCAPSULATED_RESPONSE	0x01
-
 /* Serial port defines and structs. */
 #define HSO_THRESHOLD_THROTTLE		(7*1024)
 #define HSO_THRESHOLD_UNTHROTTLE	(2*1024)
 
-/* These definitions used in the Ethernet Packet Filtering requests */
-/* See CDC Spec Table 62 */
-#define MODE_FLAG_PROMISCUOUS		(1<<0)
-#define MODE_FLAG_ALL_MULTICAST		(1<<1)
-#define MODE_FLAG_DIRECTED		(1<<2)
-#define MODE_FLAG_BROADCAST		(1<<3)
-#define MODE_FLAG_MULTICAST		(1<<4)
-
-/* CDC Spec class requests - CDC Spec Table 46 */
-#define SET_ETHERNET_MULTICAST_FILTER	0x40
-#define SET_ETHERNET_PACKET_FILTER	0x43
-
 #define HSO_SERIAL_FLAG_THROTTLED	0
 #define HSO_SERIAL_FLAG_TX_SENT		1
 #define HSO_SERIAL_FLAG_RX_SENT		2
@@ -262,6 +248,7 @@ struct hso_device {
 
 	struct device *dev;
 	struct kref ref;
+	struct mutex mutex;
 
 	/* TODO: Not sure about the ones below */
 	struct proc_dir_entry *ourproc;
@@ -339,7 +326,7 @@ static struct usb_endpoint_descriptor *h
 						  int type, int dir);
 static int hso_get_mux_ports(struct usb_interface *intf, unsigned char *ports);
 static void hso_free_interface(struct usb_interface *intf);
-static int hso_start_serial_device(struct hso_device *hso_dev);
+static int hso_start_serial_device(struct hso_device *hso_dev, gfp_t flags);
 static int hso_stop_serial_device(struct hso_device *hso_dev);
 static int hso_start_net_device(struct hso_device *hso_dev);
 static void hso_free_shared_int(struct hso_shared_int *shared_int);
@@ -655,12 +642,12 @@ static int hso_net_open(struct net_devic
 
 	hso_start_net_device(odev->parent);
 
-	/* Tell the kernel we are ready to start receiving from it */
-	netif_start_queue(net);
-
 	/* We are up and running. */
 	set_bit(HSO_NET_RUNNING, &odev->flags);
 
+	/* Tell the kernel we are ready to start receiving from it */
+	netif_start_queue(net);
+
 	return 0;
 }
 
@@ -669,10 +656,10 @@ static int hso_net_close(struct net_devi
 {
 	struct hso_net *odev = netdev_priv(net);
 
-	/* no longer running */
-	clear_bit(HSO_NET_RUNNING, &odev->flags);
 	/* we don't need the queue anymore */
 	netif_stop_queue(net);
+	/* no longer running */
+	clear_bit(HSO_NET_RUNNING, &odev->flags);
 
 	hso_stop_net_device(odev->parent);
 
@@ -834,34 +821,34 @@ static void hso_net_set_multicast(struct
 	if (net->flags & IFF_PROMISC) {
 		/* Unconditionally log net taps. */
 		D1("%s: Promiscuous mode enabled", net->name);
-		odev->mode_flags = MODE_FLAG_ALL_MULTICAST |
-				   MODE_FLAG_DIRECTED |
-				   MODE_FLAG_BROADCAST |
-				   MODE_FLAG_MULTICAST |
-				   MODE_FLAG_PROMISCUOUS;
+		odev->mode_flags = USB_CDC_PACKET_TYPE_ALL_MULTICAST |
+				   USB_CDC_PACKET_TYPE_DIRECTED |
+				   USB_CDC_PACKET_TYPE_BROADCAST |
+				   USB_CDC_PACKET_TYPE_MULTICAST |
+				   USB_CDC_PACKET_TYPE_PROMISCUOUS;
 	} else if (net->mc_count > odev->wNumberMCFilters) {
 		/* Too many to filter perfectly -- accept all multicasts. */
 		D1("%s: too many MC filters for hardware, using allmulti",
 		   net->name);
-		odev->mode_flags = MODE_FLAG_ALL_MULTICAST |
-				   MODE_FLAG_DIRECTED |
-				   MODE_FLAG_BROADCAST |
-				   MODE_FLAG_MULTICAST;
+		odev->mode_flags = USB_CDC_PACKET_TYPE_ALL_MULTICAST |
+				   USB_CDC_PACKET_TYPE_DIRECTED |
+				   USB_CDC_PACKET_TYPE_BROADCAST |
+				   USB_CDC_PACKET_TYPE_MULTICAST;
 	} else if (net->flags & IFF_ALLMULTI) {
 		/* Filter in software */
 		D1("%s: using allmulti", net->name);
-		odev->mode_flags = MODE_FLAG_ALL_MULTICAST |
-				   MODE_FLAG_DIRECTED |
-				   MODE_FLAG_BROADCAST |
-				   MODE_FLAG_MULTICAST;
+		odev->mode_flags = USB_CDC_PACKET_TYPE_ALL_MULTICAST |
+				   USB_CDC_PACKET_TYPE_DIRECTED |
+				   USB_CDC_PACKET_TYPE_BROADCAST |
+				   USB_CDC_PACKET_TYPE_MULTICAST;
 	} else {
 		/* do multicast filtering in hardware */
 		struct dev_mc_list *mclist;
 		D1("%s: set multicast filters", net->name);
-		odev->mode_flags = MODE_FLAG_ALL_MULTICAST |
-				   MODE_FLAG_DIRECTED |
-				   MODE_FLAG_BROADCAST |
-				   MODE_FLAG_MULTICAST;
+		odev->mode_flags = USB_CDC_PACKET_TYPE_ALL_MULTICAST |
+				   USB_CDC_PACKET_TYPE_DIRECTED |
+				   USB_CDC_PACKET_TYPE_BROADCAST |
+				   USB_CDC_PACKET_TYPE_MULTICAST;
 		buf = kmalloc(6 * net->mc_count, GFP_ATOMIC);
 		if (!buf) {
 			dev_err(&net->dev, "No memory to allocate?");
@@ -885,7 +872,6 @@ static void read_bulk_callback(struct ur
 	struct hso_net *odev = urb->context;
 	struct net_device *net = NULL;
 	int result = 0;
-	unsigned long flags = 0;
 	int status = urb->status;
 
 	/* is al ok?  (Filip: Who's Al ?) */
@@ -923,11 +909,11 @@ static void read_bulk_callback(struct ur
 	if (urb->actual_length) {
 		/* Handle the IP stream, add header and push it onto network
 		 * stack if the packet is complete. */
-		spin_lock_irqsave(&odev->net_lock, flags);
+		spin_lock(&odev->net_lock);
 		packetizeRx(odev, urb->transfer_buffer, urb->actual_length,
 			    (urb->transfer_buffer_length >
 			     urb->actual_length) ? 1 : 0);
-		spin_unlock_irqrestore(&odev->net_lock, flags);
+		spin_unlock(&odev->net_lock);
 	}
 
 	/* We are done with this URB, resubmit it. Prep the USB to wait for
@@ -1198,8 +1184,7 @@ static void _hso_serial_set_termios(stru
 static int hso_serial_open(struct tty_struct *tty, struct file *filp)
 {
 	struct hso_serial *serial = get_serial_by_index(tty->index);
-	int result = 0;
-	unsigned long flags;
+	int result;
 
 	/* sanity check */
 	if (serial == NULL || serial->magic != HSO_SERIAL_MAGIC) {
@@ -1208,12 +1193,12 @@ static int hso_serial_open(struct tty_st
 		return -ENODEV;
 	}
 
-	usb_autopm_get_interface(serial->parent->interface);
+	mutex_lock(&serial->parent->mutex);
+	result = usb_autopm_get_interface(serial->parent->interface);
+	if (result < 0)
+		goto err_out;
 
 	D1("Opening %d", serial->minor);
-	/* lock it down */
-	spin_lock_irqsave(&serial->serial_lock, flags);
-
 	kref_get(&serial->parent->ref);
 
 	/* setup */
@@ -1227,7 +1212,7 @@ static int hso_serial_open(struct tty_st
 		serial->flags = 0;
 		/* Force default termio settings */
 		_hso_serial_set_termios(tty, NULL);
-		result = hso_start_serial_device(serial->parent);
+		result = hso_start_serial_device(serial->parent, GFP_KERNEL);
 		if (result) {
 			hso_stop_serial_device(serial->parent);
 			serial->open_count--;
@@ -1237,13 +1222,13 @@ static int hso_serial_open(struct tty_st
 		D1("Port was already open");
 	}
 
-	spin_unlock_irqrestore(&serial->serial_lock, flags);
-
 	usb_autopm_put_interface(serial->parent->interface);
 
 	/* done */
 	if (result)
 		hso_serial_tiocmset(tty, NULL, TIOCM_RTS | TIOCM_DTR, 0);
+err_out:
+	mutex_unlock(&serial->parent->mutex);
 	return result;
 }
 
@@ -1251,7 +1236,6 @@ static int hso_serial_open(struct tty_st
 static void hso_serial_close(struct tty_struct *tty, struct file *filp)
 {
 	struct hso_serial *serial = tty->driver_data;
-	unsigned long flags;
 	u8 usb_gone;
 
 	D1("Closing serial port");
@@ -1262,6 +1246,7 @@ static void hso_serial_close(struct tty_
 		return;
 	}
 
+	mutex_lock(&serial->parent->mutex);
 	usb_gone = test_bit(HSO_SERIAL_USB_GONE, &serial->flags);
 
 	if (!usb_gone)
@@ -1269,7 +1254,6 @@ static void hso_serial_close(struct tty_
 
 	/* reset the rts and dtr */
 	/* do the actual close */
-	spin_lock_irqsave(&serial->serial_lock, flags);
 	serial->open_count--;
 	if (serial->open_count <= 0) {
 		kref_put(&serial->parent->ref, hso_serial_ref_free);
@@ -1281,11 +1265,9 @@ static void hso_serial_close(struct tty_
 		if (!usb_gone)
 			hso_stop_serial_device(serial->parent);
 	}
-	if (serial->open_count < 0)
-		serial->open_count = 0;
-	spin_unlock_irqrestore(&serial->serial_lock, flags);
 	if (!usb_gone)
 		usb_autopm_put_interface(serial->parent->interface);
+	mutex_unlock(&serial->parent->mutex);
 }
 
 /* close the requested serial port */
@@ -1639,24 +1621,24 @@ static int mux_device_request(struct hso
 	ctrl_req->wIndex = hso_port_to_mux(port);
 	ctrl_req->wLength = size;
 
-	if (type == GET_ENCAPSULATED_RESPONSE) {
+	if (type == USB_CDC_GET_ENCAPSULATED_RESPONSE) {
 		/* Reading command */
 		ctrl_req->bRequestType = USB_DIR_IN |
 					 USB_TYPE_OPTION_VENDOR |
 					 USB_RECIP_INTERFACE;
-		ctrl_req->bRequest = GET_ENCAPSULATED_RESPONSE;
+		ctrl_req->bRequest = USB_CDC_GET_ENCAPSULATED_RESPONSE;
 		pipe = usb_rcvctrlpipe(serial->parent->usb, 0);
 	} else {
 		/* Writing command */
 		ctrl_req->bRequestType = USB_DIR_OUT |
 					 USB_TYPE_OPTION_VENDOR |
 					 USB_RECIP_INTERFACE;
-		ctrl_req->bRequest = SEND_ENCAPSULATED_COMMAND;
+		ctrl_req->bRequest = USB_CDC_SEND_ENCAPSULATED_COMMAND;
 		pipe = usb_sndctrlpipe(serial->parent->usb, 0);
 	}
 	/* syslog */
 	D2("%s command (%02x) len: %d, port: %d",
-	   type == GET_ENCAPSULATED_RESPONSE ? "Read" : "Write",
+	   type == USB_CDC_GET_ENCAPSULATED_RESPONSE ? "Read" : "Write",
 	   ctrl_req->bRequestType, ctrl_req->wLength, port);
 
 	/* Load ctrl urb */
@@ -1696,7 +1678,7 @@ static int hso_mux_serial_read(struct hs
 		return 0;
 	}
 	return mux_device_request(serial,
-				  GET_ENCAPSULATED_RESPONSE,
+				  USB_CDC_GET_ENCAPSULATED_RESPONSE,
 				  serial->parent->port_spec & HSO_PORT_MASK,
 				  serial->rx_urb[0],
 				  &serial->ctrl_req_rx,
@@ -1759,7 +1741,7 @@ static int hso_mux_serial_write_data(str
 		return -EINVAL;
 
 	return mux_device_request(serial,
-				  SEND_ENCAPSULATED_COMMAND,
+				  USB_CDC_SEND_ENCAPSULATED_COMMAND,
 				  serial->parent->port_spec & HSO_PORT_MASK,
 				  serial->tx_urb,
 				  &serial->ctrl_req_tx,
@@ -2145,20 +2127,17 @@ static int hso_stop_net_device(struct hs
 		return -ENODEV;
 
 	for (i = 0; i < MUX_BULK_RX_BUF_COUNT; i++) {
-		if (hso_net->mux_bulk_rx_urb_pool[i]
-		    && (hso_net->mux_bulk_rx_urb_pool[i]->status ==
-			-EINPROGRESS))
-			usb_unlink_urb(hso_net->mux_bulk_rx_urb_pool[i]);
+		if (hso_net->mux_bulk_rx_urb_pool[i])
+			usb_kill_urb(hso_net->mux_bulk_rx_urb_pool[i]);
 
 	}
-	if (hso_net->mux_bulk_tx_urb
-	    && (hso_net->mux_bulk_tx_urb->status == -EINPROGRESS))
-		usb_unlink_urb(hso_net->mux_bulk_tx_urb);
+	if (hso_net->mux_bulk_tx_urb)
+		usb_kill_urb(hso_net->mux_bulk_tx_urb);
 
 	return 0;
 }
 
-static int hso_start_serial_device(struct hso_device *hso_dev)
+static int hso_start_serial_device(struct hso_device *hso_dev, gfp_t flags)
 {
 	int i, result = 0;
 	struct hso_serial *serial = dev2ser(hso_dev);
@@ -2180,7 +2159,7 @@ static int hso_start_serial_device(struc
 					  serial->rx_data_length,
 					  hso_std_serial_read_bulk_callback,
 					  serial);
-			result = usb_submit_urb(serial->rx_urb[i], GFP_KERNEL);
+			result = usb_submit_urb(serial->rx_urb[i], flags);
 			if (result) {
 				dev_warn(&serial->parent->usb->dev,
 					 "Failed to submit urb - res %d\n",
@@ -2361,6 +2340,7 @@ static struct hso_device *hso_create_dev
 	hso_dev->usb = interface_to_usbdev(intf);
 	hso_dev->interface = intf;
 	kref_init(&hso_dev->ref);
+	mutex_init(&hso_dev->mutex);
 
 	INIT_WORK(&hso_dev->async_get_intf, async_get_intf);
 	INIT_WORK(&hso_dev->async_put_intf, async_put_intf);
@@ -2959,7 +2939,7 @@ static int hso_resume(struct usb_interfa
 		if (serial_table[i] && (serial_table[i]->interface == iface)) {
 			if (dev2ser(serial_table[i])->open_count) {
 				result =
-				    hso_start_serial_device(serial_table[i]);
+				    hso_start_serial_device(serial_table[i], GFP_NOIO);
 				hso_kick_transmit(dev2ser(serial_table[i]));
 				if (result)
 					goto out;
@@ -2999,15 +2979,18 @@ static void hso_serial_ref_free(struct k
 
 static void hso_free_interface(struct usb_interface *interface)
 {
+	struct hso_serial *hso_dev;
 	int i;
 
 	for (i = 0; i < HSO_SERIAL_TTY_MINORS; i++) {
 		if (serial_table[i]
 		    && (serial_table[i]->interface == interface)) {
-			if (dev2ser(serial_table[i])->tty)
-				tty_hangup(dev2ser(serial_table[i])->tty);
-			set_bit(HSO_SERIAL_USB_GONE,
-				&dev2ser(serial_table[i])->flags);
+			hso_dev = dev2ser(serial_table[i]);
+			if (hso_dev->tty)
+				tty_hangup(hso_dev->tty);
+			mutex_lock(&hso_dev->parent->mutex);
+			set_bit(HSO_SERIAL_USB_GONE, &hso_dev->flags);
+			mutex_unlock(&hso_dev->parent->mutex);
 			kref_put(&serial_table[i]->ref, hso_serial_ref_free);
 		}
 	}
@@ -3069,7 +3052,7 @@ static int hso_get_mux_ports(struct usb_
 static int hso_mux_submit_intr_urb(struct hso_shared_int *shared_int,
 				   struct usb_device *usb, gfp_t gfp)
 {
-	int result = 0;
+	int result;
 
 	usb_fill_int_urb(shared_int->shared_intr_urb, usb,
 			 usb_rcvintpipe(usb,

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

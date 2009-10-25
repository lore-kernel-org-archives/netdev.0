From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 7/9] bas_gigaset: checkpatch cleanup
Date: Sun, 25 Oct 2009 20:30:37 +0100 (CET)
Message-ID: <20091023-patch-gigaset-07.tilman@imap.cc>
References: <20091023-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([195.227.45.7]:43590 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753892AbZJYTao (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Oct 2009 15:30:44 -0400
In-Reply-To: <20091023-patch-gigaset-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On the quest for the holy grail of checkpatch.pl silence.

Impact: cosmetic
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/bas-gigaset.c |   68 ++++++++++++++---------
 drivers/isdn/gigaset/isocdata.c    |  107 +++++++++++++++++------------------
 2 files changed, 93 insertions(+), 82 deletions(-)

diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index 388e63a..9fd19db 100644
--- a/drivers/isdn/gigaset/bas-gigaset.c
+++ b/drivers/isdn/gigaset/bas-gigaset.c
@@ -57,7 +57,7 @@ MODULE_PARM_DESC(cidmode, "Call-ID mode");
 #define USB_SX353_PRODUCT_ID    0x0022
 
 /* table of devices that work with this driver */
-static const struct usb_device_id gigaset_table [] = {
+static const struct usb_device_id gigaset_table[] = {
 	{ USB_DEVICE(USB_GIGA_VENDOR_ID, USB_3070_PRODUCT_ID) },
 	{ USB_DEVICE(USB_GIGA_VENDOR_ID, USB_3075_PRODUCT_ID) },
 	{ USB_DEVICE(USB_GIGA_VENDOR_ID, USB_SX303_PRODUCT_ID) },
@@ -137,7 +137,7 @@ struct bas_cardstate {
 #define BS_RESETTING	0x200	/* waiting for HD_RESET_INTERRUPT_PIPE_ACK */
 
 
-static struct gigaset_driver *driver = NULL;
+static struct gigaset_driver *driver;
 
 /* usb specific object needed to register this driver with the usb subsystem */
 static struct usb_driver gigaset_usb_driver = {
@@ -601,11 +601,12 @@ static int atread_submit(struct cardstate *cs, int timeout)
 	ucs->dr_cmd_in.wLength = cpu_to_le16(ucs->rcvbuf_size);
 	usb_fill_control_urb(ucs->urb_cmd_in, ucs->udev,
 			     usb_rcvctrlpipe(ucs->udev, 0),
-			     (unsigned char*) & ucs->dr_cmd_in,
+			     (unsigned char *) &ucs->dr_cmd_in,
 			     ucs->rcvbuf, ucs->rcvbuf_size,
 			     read_ctrl_callback, cs->inbuf);
 
-	if ((ret = usb_submit_urb(ucs->urb_cmd_in, GFP_ATOMIC)) != 0) {
+	ret = usb_submit_urb(ucs->urb_cmd_in, GFP_ATOMIC);
+	if (ret != 0) {
 		update_basstate(ucs, 0, BS_ATRDPEND);
 		dev_err(cs->dev, "could not submit HD_READ_ATMESSAGE: %s\n",
 			get_usb_rcmsg(ret));
@@ -652,13 +653,11 @@ static void read_int_callback(struct urb *urb)
 		return;
 	case -ENODEV:			/* device removed */
 	case -ESHUTDOWN:		/* device shut down */
-		//FIXME use this as disconnect indicator?
 		gig_dbg(DEBUG_USBREQ, "%s: device disconnected", __func__);
 		return;
 	default:		/* severe trouble */
 		dev_warn(cs->dev, "interrupt read: %s\n",
 			 get_usb_statmsg(status));
-		//FIXME corrective action? resubmission always ok?
 		goto resubmit;
 	}
 
@@ -742,7 +741,8 @@ static void read_int_callback(struct urb *urb)
 			kfree(ucs->rcvbuf);
 			ucs->rcvbuf_size = 0;
 		}
-		if ((ucs->rcvbuf = kmalloc(l, GFP_ATOMIC)) == NULL) {
+		ucs->rcvbuf = kmalloc(l, GFP_ATOMIC);
+		if (ucs->rcvbuf == NULL) {
 			spin_unlock_irqrestore(&cs->lock, flags);
 			dev_err(cs->dev, "out of memory receiving AT data\n");
 			error_reset(cs);
@@ -750,12 +750,12 @@ static void read_int_callback(struct urb *urb)
 		}
 		ucs->rcvbuf_size = l;
 		ucs->retry_cmd_in = 0;
-		if ((rc = atread_submit(cs, BAS_TIMEOUT)) < 0) {
+		rc = atread_submit(cs, BAS_TIMEOUT);
+		if (rc < 0) {
 			kfree(ucs->rcvbuf);
 			ucs->rcvbuf = NULL;
 			ucs->rcvbuf_size = 0;
 			if (rc != -ENODEV) {
-				//FIXME corrective action?
 				spin_unlock_irqrestore(&cs->lock, flags);
 				error_reset(cs);
 				break;
@@ -940,7 +940,8 @@ static int starturbs(struct bc_state *bcs)
 		}
 
 		dump_urb(DEBUG_ISO, "Initial isoc read", urb);
-		if ((rc = usb_submit_urb(urb, GFP_ATOMIC)) != 0)
+		rc = usb_submit_urb(urb, GFP_ATOMIC);
+		if (rc != 0)
 			goto error;
 	}
 
@@ -1045,7 +1046,8 @@ static int submit_iso_write_urb(struct isow_urbctx_t *ucx)
 
 		/* compute frame length according to flow control */
 		ifd->length = BAS_NORMFRAME;
-		if ((corrbytes = atomic_read(&ubc->corrbytes)) != 0) {
+		corrbytes = atomic_read(&ubc->corrbytes);
+		if (corrbytes != 0) {
 			gig_dbg(DEBUG_ISO, "%s: corrbytes=%d",
 				__func__, corrbytes);
 			if (corrbytes > BAS_HIGHFRAME - BAS_NORMFRAME)
@@ -1284,7 +1286,8 @@ static void read_iso_tasklet(unsigned long data)
 	for (;;) {
 		/* retrieve URB */
 		spin_lock_irqsave(&ubc->isoinlock, flags);
-		if (!(urb = ubc->isoindone)) {
+		urb = ubc->isoindone;
+		if (!urb) {
 			spin_unlock_irqrestore(&ubc->isoinlock, flags);
 			return;
 		}
@@ -1371,7 +1374,7 @@ static void read_iso_tasklet(unsigned long data)
 				 "isochronous read: %d data bytes missing\n",
 				 totleft);
 
-	error:
+error:
 		/* URB processed, resubmit */
 		for (frame = 0; frame < BAS_NUMFRAMES; frame++) {
 			urb->iso_frame_desc[frame].status = 0;
@@ -1568,7 +1571,7 @@ static int req_submit(struct bc_state *bcs, int req, int val, int timeout)
 	ucs->dr_ctrl.wLength = 0;
 	usb_fill_control_urb(ucs->urb_ctrl, ucs->udev,
 			     usb_sndctrlpipe(ucs->udev, 0),
-			     (unsigned char*) &ucs->dr_ctrl, NULL, 0,
+			     (unsigned char *) &ucs->dr_ctrl, NULL, 0,
 			     write_ctrl_callback, ucs);
 	ucs->retry_ctrl = 0;
 	ret = usb_submit_urb(ucs->urb_ctrl, GFP_ATOMIC);
@@ -1621,7 +1624,8 @@ static int gigaset_init_bchannel(struct bc_state *bcs)
 		return -EHOSTUNREACH;
 	}
 
-	if ((ret = starturbs(bcs)) < 0) {
+	ret = starturbs(bcs);
+	if (ret < 0) {
 		dev_err(cs->dev,
 			"could not start isochronous I/O for channel B%d: %s\n",
 			bcs->channel + 1,
@@ -1633,7 +1637,8 @@ static int gigaset_init_bchannel(struct bc_state *bcs)
 	}
 
 	req = bcs->channel ? HD_OPEN_B2CHANNEL : HD_OPEN_B1CHANNEL;
-	if ((ret = req_submit(bcs, req, 0, BAS_TIMEOUT)) < 0) {
+	ret = req_submit(bcs, req, 0, BAS_TIMEOUT);
+	if (ret < 0) {
 		dev_err(cs->dev, "could not open channel B%d\n",
 			bcs->channel + 1);
 		stopurbs(bcs->hw.bas);
@@ -1677,7 +1682,8 @@ static int gigaset_close_bchannel(struct bc_state *bcs)
 
 	/* channel running: tell device to close it */
 	req = bcs->channel ? HD_CLOSE_B2CHANNEL : HD_CLOSE_B1CHANNEL;
-	if ((ret = req_submit(bcs, req, 0, BAS_TIMEOUT)) < 0)
+	ret = req_submit(bcs, req, 0, BAS_TIMEOUT);
+	if (ret < 0)
 		dev_err(cs->dev, "closing channel B%d failed\n",
 			bcs->channel + 1);
 
@@ -1703,10 +1709,12 @@ static void complete_cb(struct cardstate *cs)
 	gig_dbg(DEBUG_TRANSCMD|DEBUG_LOCKCMD,
 		"write_command: sent %u bytes, %u left",
 		cs->curlen, cs->cmdbytes);
-	if ((cs->cmdbuf = cb->next) != NULL) {
+	if (cb->next != NULL) {
+		cs->cmdbuf = cb->next;
 		cs->cmdbuf->prev = NULL;
 		cs->curlen = cs->cmdbuf->len;
 	} else {
+		cs->cmdbuf = NULL;
 		cs->lastcmdbuf = NULL;
 		cs->curlen = 0;
 	}
@@ -1833,7 +1841,7 @@ static int atwrite_submit(struct cardstate *cs, unsigned char *buf, int len)
 	ucs->dr_cmd_out.wLength = cpu_to_le16(len);
 	usb_fill_control_urb(ucs->urb_cmd_out, ucs->udev,
 			     usb_sndctrlpipe(ucs->udev, 0),
-			     (unsigned char*) &ucs->dr_cmd_out, buf, len,
+			     (unsigned char *) &ucs->dr_cmd_out, buf, len,
 			     write_command_callback, cs);
 	rc = usb_submit_urb(ucs->urb_cmd_out, GFP_ATOMIC);
 	if (unlikely(rc)) {
@@ -1953,7 +1961,8 @@ static int gigaset_write_cmd(struct cardstate *cs,
 
 	if (len > IF_WRITEBUF)
 		len = IF_WRITEBUF;
-	if (!(cb = kmalloc(sizeof(struct cmdbuf_t) + len, GFP_ATOMIC))) {
+	cb = kmalloc(sizeof(struct cmdbuf_t) + len, GFP_ATOMIC);
+	if (!cb) {
 		dev_err(cs->dev, "%s: out of memory\n", __func__);
 		rc = -ENOMEM;
 		goto notqueued;
@@ -2100,7 +2109,8 @@ static int gigaset_initbcshw(struct bc_state *bcs)
 	}
 	ubc->isooutdone = ubc->isooutfree = ubc->isooutovfl = NULL;
 	ubc->numsub = 0;
-	if (!(ubc->isooutbuf = kmalloc(sizeof(struct isowbuf_t), GFP_KERNEL))) {
+	ubc->isooutbuf = kmalloc(sizeof(struct isowbuf_t), GFP_KERNEL);
+	if (!ubc->isooutbuf) {
 		pr_err("out of memory\n");
 		kfree(ubc);
 		bcs->hw.bas = NULL;
@@ -2252,7 +2262,8 @@ static int gigaset_probe(struct usb_interface *interface,
 		gig_dbg(DEBUG_ANY,
 			"%s: wrong alternate setting %d - trying to switch",
 			__func__, hostif->desc.bAlternateSetting);
-		if (usb_set_interface(udev, hostif->desc.bInterfaceNumber, 3) < 0) {
+		if (usb_set_interface(udev, hostif->desc.bInterfaceNumber, 3)
+		    < 0) {
 			dev_warn(&udev->dev, "usb_set_interface failed, "
 				 "device %d interface %d altsetting %d\n",
 				 udev->devnum, hostif->desc.bInterfaceNumber,
@@ -2321,14 +2332,16 @@ static int gigaset_probe(struct usb_interface *interface,
 					(endpoint->bEndpointAddress) & 0x0f),
 			 ucs->int_in_buf, IP_MSGSIZE, read_int_callback, cs,
 			 endpoint->bInterval);
-	if ((rc = usb_submit_urb(ucs->urb_int_in, GFP_KERNEL)) != 0) {
+	rc = usb_submit_urb(ucs->urb_int_in, GFP_KERNEL);
+	if (rc != 0) {
 		dev_err(cs->dev, "could not submit interrupt URB: %s\n",
 			get_usb_rcmsg(rc));
 		goto error;
 	}
 
 	/* tell the device that the driver is ready */
-	if ((rc = req_submit(cs->bcs, HD_DEVICE_INIT_ACK, 0, 0)) != 0)
+	rc = req_submit(cs->bcs, HD_DEVICE_INIT_ACK, 0, 0);
+	if (rc != 0)
 		goto error;
 
 	/* tell common part that the device is ready */
@@ -2524,9 +2537,10 @@ static int __init bas_gigaset_init(void)
 	int result;
 
 	/* allocate memory for our driver state and intialize it */
-	if ((driver = gigaset_initdriver(GIGASET_MINOR, GIGASET_MINORS,
-				       GIGASET_MODULENAME, GIGASET_DEVNAME,
-				       &gigops, THIS_MODULE)) == NULL)
+	driver = gigaset_initdriver(GIGASET_MINOR, GIGASET_MINORS,
+				    GIGASET_MODULENAME, GIGASET_DEVNAME,
+				    &gigops, THIS_MODULE);
+	if (driver == NULL)
 		goto error;
 
 	/* register this driver with the USB subsystem */
diff --git a/drivers/isdn/gigaset/isocdata.c b/drivers/isdn/gigaset/isocdata.c
index bc41611..d15cfcb 100644
--- a/drivers/isdn/gigaset/isocdata.c
+++ b/drivers/isdn/gigaset/isocdata.c
@@ -41,7 +41,8 @@ static inline int isowbuf_freebytes(struct isowbuf_t *iwb)
 
 	read = iwb->read;
 	write = iwb->write;
-	if ((freebytes = read - write) > 0) {
+	freebytes = read - write;
+	if (freebytes > 0) {
 		/* no wraparound: need padding space within regular area */
 		return freebytes - BAS_OUTBUFPAD;
 	} else if (read < BAS_OUTBUFPAD) {
@@ -53,29 +54,6 @@ static inline int isowbuf_freebytes(struct isowbuf_t *iwb)
 	}
 }
 
-/* compare two offsets within the buffer
- * The buffer is seen as circular, with the read position as start
- * returns -1/0/1 if position a </=/> position b without crossing 'read'
- */
-static inline int isowbuf_poscmp(struct isowbuf_t *iwb, int a, int b)
-{
-	int read;
-	if (a == b)
-		return 0;
-	read = iwb->read;
-	if (a < b) {
-		if (a < read && read <= b)
-			return +1;
-		else
-			return -1;
-	} else {
-		if (b < read && read <= a)
-			return -1;
-		else
-			return +1;
-	}
-}
-
 /* start writing
  * acquire the write semaphore
  * return true if acquired, false if busy
@@ -271,7 +249,7 @@ static inline void dump_bytes(enum debuglevel level, const char *tag,
  *        bit 14..13 = number of bits added by stuffing
  */
 static const u16 stufftab[5 * 256] = {
-// previous 1s = 0:
+/* previous 1s = 0: */
  0x0000, 0x0001, 0x0002, 0x0003, 0x0004, 0x0005, 0x0006, 0x0007, 0x0008, 0x0009, 0x000a, 0x000b, 0x000c, 0x000d, 0x000e, 0x000f,
  0x0010, 0x0011, 0x0012, 0x0013, 0x0014, 0x0015, 0x0016, 0x0017, 0x0018, 0x0019, 0x001a, 0x001b, 0x001c, 0x001d, 0x001e, 0x201f,
  0x0020, 0x0021, 0x0022, 0x0023, 0x0024, 0x0025, 0x0026, 0x0027, 0x0028, 0x0029, 0x002a, 0x002b, 0x002c, 0x002d, 0x002e, 0x002f,
@@ -289,7 +267,7 @@ static const u16 stufftab[5 * 256] = {
  0x0ce0, 0x0ce1, 0x0ce2, 0x0ce3, 0x0ce4, 0x0ce5, 0x0ce6, 0x0ce7, 0x0ce8, 0x0ce9, 0x0cea, 0x0ceb, 0x0cec, 0x0ced, 0x0cee, 0x0cef,
  0x10f0, 0x10f1, 0x10f2, 0x10f3, 0x10f4, 0x10f5, 0x10f6, 0x10f7, 0x20f8, 0x20f9, 0x20fa, 0x20fb, 0x257c, 0x257d, 0x29be, 0x2ddf,
 
-// previous 1s = 1:
+/* previous 1s = 1: */
  0x0000, 0x0001, 0x0002, 0x0003, 0x0004, 0x0005, 0x0006, 0x0007, 0x0008, 0x0009, 0x000a, 0x000b, 0x000c, 0x000d, 0x000e, 0x200f,
  0x0010, 0x0011, 0x0012, 0x0013, 0x0014, 0x0015, 0x0016, 0x0017, 0x0018, 0x0019, 0x001a, 0x001b, 0x001c, 0x001d, 0x001e, 0x202f,
  0x0020, 0x0021, 0x0022, 0x0023, 0x0024, 0x0025, 0x0026, 0x0027, 0x0028, 0x0029, 0x002a, 0x002b, 0x002c, 0x002d, 0x002e, 0x204f,
@@ -307,7 +285,7 @@ static const u16 stufftab[5 * 256] = {
  0x0ce0, 0x0ce1, 0x0ce2, 0x0ce3, 0x0ce4, 0x0ce5, 0x0ce6, 0x0ce7, 0x0ce8, 0x0ce9, 0x0cea, 0x0ceb, 0x0cec, 0x0ced, 0x0cee, 0x2dcf,
  0x10f0, 0x10f1, 0x10f2, 0x10f3, 0x10f4, 0x10f5, 0x10f6, 0x10f7, 0x20f8, 0x20f9, 0x20fa, 0x20fb, 0x257c, 0x257d, 0x29be, 0x31ef,
 
-// previous 1s = 2:
+/* previous 1s = 2: */
  0x0000, 0x0001, 0x0002, 0x0003, 0x0004, 0x0005, 0x0006, 0x2007, 0x0008, 0x0009, 0x000a, 0x000b, 0x000c, 0x000d, 0x000e, 0x2017,
  0x0010, 0x0011, 0x0012, 0x0013, 0x0014, 0x0015, 0x0016, 0x2027, 0x0018, 0x0019, 0x001a, 0x001b, 0x001c, 0x001d, 0x001e, 0x2037,
  0x0020, 0x0021, 0x0022, 0x0023, 0x0024, 0x0025, 0x0026, 0x2047, 0x0028, 0x0029, 0x002a, 0x002b, 0x002c, 0x002d, 0x002e, 0x2057,
@@ -325,7 +303,7 @@ static const u16 stufftab[5 * 256] = {
  0x0ce0, 0x0ce1, 0x0ce2, 0x0ce3, 0x0ce4, 0x0ce5, 0x0ce6, 0x2dc7, 0x0ce8, 0x0ce9, 0x0cea, 0x0ceb, 0x0cec, 0x0ced, 0x0cee, 0x2dd7,
  0x10f0, 0x10f1, 0x10f2, 0x10f3, 0x10f4, 0x10f5, 0x10f6, 0x31e7, 0x20f8, 0x20f9, 0x20fa, 0x20fb, 0x257c, 0x257d, 0x29be, 0x41f7,
 
-// previous 1s = 3:
+/* previous 1s = 3: */
  0x0000, 0x0001, 0x0002, 0x2003, 0x0004, 0x0005, 0x0006, 0x200b, 0x0008, 0x0009, 0x000a, 0x2013, 0x000c, 0x000d, 0x000e, 0x201b,
  0x0010, 0x0011, 0x0012, 0x2023, 0x0014, 0x0015, 0x0016, 0x202b, 0x0018, 0x0019, 0x001a, 0x2033, 0x001c, 0x001d, 0x001e, 0x203b,
  0x0020, 0x0021, 0x0022, 0x2043, 0x0024, 0x0025, 0x0026, 0x204b, 0x0028, 0x0029, 0x002a, 0x2053, 0x002c, 0x002d, 0x002e, 0x205b,
@@ -343,7 +321,7 @@ static const u16 stufftab[5 * 256] = {
  0x0ce0, 0x0ce1, 0x0ce2, 0x2dc3, 0x0ce4, 0x0ce5, 0x0ce6, 0x2dcb, 0x0ce8, 0x0ce9, 0x0cea, 0x2dd3, 0x0cec, 0x0ced, 0x0cee, 0x2ddb,
  0x10f0, 0x10f1, 0x10f2, 0x31e3, 0x10f4, 0x10f5, 0x10f6, 0x31eb, 0x20f8, 0x20f9, 0x20fa, 0x41f3, 0x257c, 0x257d, 0x29be, 0x46fb,
 
-// previous 1s = 4:
+/* previous 1s = 4: */
  0x0000, 0x2001, 0x0002, 0x2005, 0x0004, 0x2009, 0x0006, 0x200d, 0x0008, 0x2011, 0x000a, 0x2015, 0x000c, 0x2019, 0x000e, 0x201d,
  0x0010, 0x2021, 0x0012, 0x2025, 0x0014, 0x2029, 0x0016, 0x202d, 0x0018, 0x2031, 0x001a, 0x2035, 0x001c, 0x2039, 0x001e, 0x203d,
  0x0020, 0x2041, 0x0022, 0x2045, 0x0024, 0x2049, 0x0026, 0x204d, 0x0028, 0x2051, 0x002a, 0x2055, 0x002c, 0x2059, 0x002e, 0x205d,
@@ -367,7 +345,8 @@ static const u16 stufftab[5 * 256] = {
  * parameters:
  *	cin	input byte
  *	ones	number of trailing '1' bits in result before this step
- *	iwb	pointer to output buffer structure (write semaphore must be held)
+ *	iwb	pointer to output buffer structure
+ *		(write semaphore must be held)
  * return value:
  *	number of trailing '1' bits in result after this step
  */
@@ -408,7 +387,8 @@ static inline int hdlc_bitstuff_byte(struct isowbuf_t *iwb, unsigned char cin,
  * parameters:
  *	in	input buffer
  *	count	number of bytes in input buffer
- *	iwb	pointer to output buffer structure (write semaphore must be held)
+ *	iwb	pointer to output buffer structure
+ *		(write semaphore must be held)
  * return value:
  *	position of end of packet in output buffer on success,
  *	-EAGAIN if write semaphore busy or buffer full
@@ -440,7 +420,8 @@ static inline int hdlc_buildframe(struct isowbuf_t *iwb,
 		fcs = crc_ccitt_byte(fcs, c);
 	}
 
-	/* bitstuff and append FCS (complemented, least significant byte first) */
+	/* bitstuff and append FCS
+	 * (complemented, least significant byte first) */
 	fcs ^= 0xffff;
 	ones = hdlc_bitstuff_byte(iwb, fcs & 0x00ff, ones);
 	ones = hdlc_bitstuff_byte(iwb, (fcs >> 8) & 0x00ff, ones);
@@ -459,7 +440,8 @@ static inline int hdlc_buildframe(struct isowbuf_t *iwb,
  * parameters:
  *	in	input buffer
  *	count	number of bytes in input buffer
- *	iwb	pointer to output buffer structure (write semaphore must be held)
+ *	iwb	pointer to output buffer structure
+ *		(write semaphore must be held)
  * return value:
  *	position of end of packet in output buffer on success,
  *	-EAGAIN if write semaphore busy or buffer full
@@ -567,8 +549,8 @@ static inline void hdlc_done(struct bc_state *bcs)
 		hdlc_flush(bcs);
 		return;
 	}
-
-	if ((procskb = bcs->skb) == NULL) {
+	procskb = bcs->skb;
+	if (procskb == NULL) {
 		/* previous error */
 		gig_dbg(DEBUG_ISO, "%s: skb=NULL", __func__);
 		gigaset_isdn_rcv_err(bcs);
@@ -646,8 +628,8 @@ static const unsigned char bitcounts[256] = {
 };
 
 /* hdlc_unpack
- * perform HDLC frame processing (bit unstuffing, flag detection, FCS calculation)
- * on a sequence of received data bytes (8 bits each, LSB first)
+ * perform HDLC frame processing (bit unstuffing, flag detection, FCS
+ * calculation) on a sequence of received data bytes (8 bits each, LSB first)
  * pass on successfully received, complete frames as SKBs via gigaset_skb_rcvd
  * notify of errors via gigaset_isdn_rcv_err
  * tally frames, errors etc. in BC structure counters
@@ -665,9 +647,12 @@ static inline void hdlc_unpack(unsigned char *src, unsigned count,
 
 	/* load previous state:
 	 * inputstate = set of flag bits:
-	 * - INS_flag_hunt: no complete opening flag received since connection setup or last abort
-	 * - INS_have_data: at least one complete data byte received since last flag
-	 * seqlen = number of consecutive '1' bits in last 7 input stream bits (0..7)
+	 * - INS_flag_hunt: no complete opening flag received since connection
+	 *                  setup or last abort
+	 * - INS_have_data: at least one complete data byte received since last
+	 *                  flag
+	 * seqlen = number of consecutive '1' bits in last 7 input stream bits
+	 *          (0..7)
 	 * inbyte = accumulated partial data byte (if !INS_flag_hunt)
 	 * inbits = number of valid bits in inbyte, starting at LSB (0..6)
 	 */
@@ -701,9 +686,11 @@ static inline void hdlc_unpack(unsigned char *src, unsigned count,
 				inbyte = c >> (lead1 + 1);
 				inbits = 7 - lead1;
 				if (trail1 >= 8) {
-					/* interior stuffing: omitting the MSB handles most cases */
+					/* interior stuffing:
+					 * omitting the MSB handles most cases,
+					 * correct the incorrectly handled
+					 * cases individually */
 					inbits--;
-					/* correct the incorrectly handled cases individually */
 					switch (c) {
 					case 0xbe:
 						inbyte = 0x3f;
@@ -729,13 +716,14 @@ static inline void hdlc_unpack(unsigned char *src, unsigned count,
 			hdlc_flush(bcs);
 			inputstate |= INS_flag_hunt;
 		} else if (seqlen == 6) {
-			/* closing flag, including (6 - lead1) '1's and one '0' from inbits */
+			/* closing flag, including (6 - lead1) '1's
+			 * and one '0' from inbits */
 			if (inbits > 7 - lead1) {
 				hdlc_frag(bcs, inbits + lead1 - 7);
 				inputstate &= ~INS_have_data;
 			} else {
 				if (inbits < 7 - lead1)
-					ubc->stolen0s ++;
+					ubc->stolen0s++;
 				if (inputstate & INS_have_data) {
 					hdlc_done(bcs);
 					inputstate &= ~INS_have_data;
@@ -744,7 +732,7 @@ static inline void hdlc_unpack(unsigned char *src, unsigned count,
 
 			if (c == PPP_FLAG) {
 				/* complete flag, LSB overlaps preceding flag */
-				ubc->shared0s ++;
+				ubc->shared0s++;
 				inbits = 0;
 				inbyte = 0;
 			} else if (trail1 != 7) {
@@ -752,9 +740,11 @@ static inline void hdlc_unpack(unsigned char *src, unsigned count,
 				inbyte = c >> (lead1 + 1);
 				inbits = 7 - lead1;
 				if (trail1 >= 8) {
-					/* interior stuffing: omitting the MSB handles most cases */
+					/* interior stuffing:
+					 * omitting the MSB handles most cases,
+					 * correct the incorrectly handled
+					 * cases individually */
 					inbits--;
-					/* correct the incorrectly handled cases individually */
 					switch (c) {
 					case 0xbe:
 						inbyte = 0x3f;
@@ -762,7 +752,8 @@ static inline void hdlc_unpack(unsigned char *src, unsigned count,
 					}
 				}
 			} else {
-				/* abort sequence follows, skb already empty anyway */
+				/* abort sequence follows,
+				 * skb already empty anyway */
 				ubc->aborts++;
 				inputstate |= INS_flag_hunt;
 			}
@@ -787,14 +778,17 @@ static inline void hdlc_unpack(unsigned char *src, unsigned count,
 			} else {
 				/* stuffed data */
 				if (trail1 < 7) { /* => seqlen == 5 */
-					/* stuff bit at position lead1, no interior stuffing */
+					/* stuff bit at position lead1,
+					 * no interior stuffing */
 					unsigned char mask = (1 << lead1) - 1;
 					c = (c & mask) | ((c & ~mask) >> 1);
 					inbyte |= c << inbits;
 					inbits += 7;
 				} else if (seqlen < 5) { /* trail1 >= 8 */
-					/* interior stuffing: omitting the MSB handles most cases */
-					/* correct the incorrectly handled cases individually */
+					/* interior stuffing:
+					 * omitting the MSB handles most cases,
+					 * correct the incorrectly handled
+					 * cases individually */
 					switch (c) {
 					case 0xbe:
 						c = 0x7e;
@@ -804,8 +798,9 @@ static inline void hdlc_unpack(unsigned char *src, unsigned count,
 					inbits += 7;
 				} else { /* seqlen == 5 && trail1 >= 8 */
 
-					/* stuff bit at lead1 *and* interior stuffing */
-					switch (c) {	/* unstuff individually */
+					/* stuff bit at lead1 *and* interior
+					 * stuffing -- unstuff individually */
+					switch (c) {
 					case 0x7d:
 						c = 0x3f;
 						break;
@@ -862,7 +857,8 @@ static inline void trans_receive(unsigned char *src, unsigned count,
 		hdlc_flush(bcs);
 		return;
 	}
-	if (unlikely((skb = bcs->skb) == NULL)) {
+	skb = bcs->skb;
+	if (unlikely(skb == NULL)) {
 		bcs->skb = skb = dev_alloc_skb(SBUFSIZE + cs->hw_hdr_len);
 		if (!skb) {
 			dev_err(cs->dev, "could not allocate skb\n");
@@ -895,7 +891,8 @@ static inline void trans_receive(unsigned char *src, unsigned count,
 	}
 }
 
-void gigaset_isoc_receive(unsigned char *src, unsigned count, struct bc_state *bcs)
+void gigaset_isoc_receive(unsigned char *src, unsigned count,
+			  struct bc_state *bcs)
 {
 	switch (bcs->proto2) {
 	case L2_HDLC:
-- 
1.6.2.1.214.ge986c


From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 09/12] gigaset: add kerneldoc comments
Date: Sun,  6 Sep 2009 20:58:52 +0200 (CEST)
Message-ID: <20090906-patch-gigaset-09.tilman@imap.cc>
References: <20090906-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758293AbZIFTAK@vger.kernel.org>
In-Reply-To: <20090906-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add kerneldoc comments to some functions in the Gigaset driver.

Impact: documentation
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/asyncdata.c |   28 ++++++---
 drivers/isdn/gigaset/common.c    |  126 +++++++++++++++++++++++++++++++-------
 drivers/isdn/gigaset/ev-layer.c  |    9 ++-
 drivers/isdn/gigaset/i4l.c       |   17 +++++
 drivers/isdn/gigaset/interface.c |    9 +++
 drivers/isdn/gigaset/isocdata.c  |   21 +++---
 6 files changed, 166 insertions(+), 44 deletions(-)

diff --git a/drivers/isdn/gigaset/asyncdata.c b/drivers/isdn/gigaset/asyncdata.c
index 234cc5d..44a58e6 100644
--- a/drivers/isdn/gigaset/asyncdata.c
+++ b/drivers/isdn/gigaset/asyncdata.c
@@ -334,7 +334,14 @@ static inline int iraw_loop(unsigned char c, unsigned char *src, int numbytes,
 	return startbytes - numbytes;
 }
 
-/* process a block of data received from the device
+/**
+ * gigaset_m10x_input() - process a block of data received from the device
+ * @inbuf:	received data and device descriptor structure.
+ *
+ * Called by hardware module {ser,usb}_gigaset with a block of received
+ * bytes. Separates the bytes received over the serial data channel into
+ * user data and command replies (locked/unlocked) according to the
+ * current state of the interface.
  */
 void gigaset_m10x_input(struct inbuf_t *inbuf)
 {
@@ -543,16 +550,17 @@ static struct sk_buff *iraw_encode(struct sk_buff *skb, int head, int tail)
 	return iraw_skb;
 }
 
-/* gigaset_send_skb
- * called by common.c to queue an skb for sending
- * and start transmission if necessary
- * parameters:
- *	B Channel control structure
- *	skb
+/**
+ * gigaset_m10x_send_skb() - queue an skb for sending
+ * @bcs:	B channel descriptor structure.
+ * @skb:	data to send.
+ *
+ * Called by i4l.c to encode and queue an skb for sending, and start
+ * transmission if necessary.
+ *
  * Return value:
- *	number of bytes accepted for sending
- *	(skb->len if ok, 0 if out of buffer space)
- *	or error code (< 0, eg. -EINVAL)
+ *	number of bytes accepted for sending (skb->len) if ok,
+ *	error code < 0 (eg. -ENOMEM) on error
  */
 int gigaset_m10x_send_skb(struct bc_state *bcs, struct sk_buff *skb)
 {
diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index edbcaa3..33dcd8d 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -38,6 +38,17 @@ MODULE_PARM_DESC(debug, "debug level");
 #define VALID_MINOR	0x01
 #define VALID_ID	0x02
 
+/**
+ * gigaset_dbg_buffer() - dump data in ASCII and hex for debugging
+ * @level:	debugging level.
+ * @msg:	message prefix.
+ * @len:	number of bytes to dump.
+ * @buf:	data to dump.
+ *
+ * If the current debugging level includes one of the bits set in @level,
+ * @len bytes starting at @buf are logged to dmesg at KERN_DEBUG prio,
+ * prefixed by the text @msg.
+ */
 void gigaset_dbg_buffer(enum debuglevel level, const unsigned char *msg,
 			size_t len, const unsigned char *buf)
 {
@@ -280,6 +291,20 @@ static void clear_events(struct cardstate *cs)
 	spin_unlock_irqrestore(&cs->ev_lock, flags);
 }
 
+/**
+ * gigaset_add_event() - add event to device event queue
+ * @cs:		device descriptor structure.
+ * @at_state:	connection state structure.
+ * @type:	event type.
+ * @ptr:	pointer parameter for event.
+ * @parameter:	integer parameter for event.
+ * @arg:	pointer parameter for event.
+ *
+ * Allocate an event queue entry from the device's event queue, and set it up
+ * with the parameters given.
+ *
+ * Return value: added event
+ */
 struct event_t *gigaset_add_event(struct cardstate *cs,
 				  struct at_state_t *at_state, int type,
 				  void *ptr, int parameter, void *arg)
@@ -404,6 +429,15 @@ static void make_invalid(struct cardstate *cs, unsigned mask)
 	spin_unlock_irqrestore(&drv->lock, flags);
 }
 
+/**
+ * gigaset_freecs() - free all associated ressources of a device
+ * @cs:		device descriptor structure.
+ *
+ * Stops all tasklets and timers, unregisters the device from all
+ * subsystems it was registered to, deallocates the device structure
+ * @cs and all structures referenced from it.
+ * Operations on the device should be stopped before calling this.
+ */
 void gigaset_freecs(struct cardstate *cs)
 {
 	int i;
@@ -512,7 +546,12 @@ static void gigaset_inbuf_init(struct inbuf_t *inbuf, struct bc_state *bcs,
 	inbuf->inputstate = inputstate;
 }
 
-/* append received bytes to inbuf */
+/**
+ * gigaset_fill_inbuf() - append received data to input buffer
+ * @inbuf:	buffer structure.
+ * @src:	received data.
+ * @numbytes:	number of bytes received.
+ */
 int gigaset_fill_inbuf(struct inbuf_t *inbuf, const unsigned char *src,
 		       unsigned numbytes)
 {
@@ -612,20 +651,22 @@ static struct bc_state *gigaset_initbcs(struct bc_state *bcs,
 	return NULL;
 }
 
-/* gigaset_initcs
+/**
+ * gigaset_initcs() - initialize device structure
+ * @drv:	hardware driver the device belongs to
+ * @channels:	number of B channels supported by device
+ * @onechannel:	!=0 if B channel data and AT commands share one
+ *		    communication channel (M10x),
+ *		==0 if B channels have separate communication channels (base)
+ * @ignoreframes:	number of frames to ignore after setting up B channel
+ * @cidmode:	!=0: start in CallID mode
+ * @modulename:	name of driver module for LL registration
+ *
  * Allocate and initialize cardstate structure for Gigaset driver
  * Calls hardware dependent gigaset_initcshw() function
  * Calls B channel initialization function gigaset_initbcs() for each B channel
- * parameters:
- *	drv		hardware driver the device belongs to
- *	channels	number of B channels supported by device
- *	onechannel	!=0: B channel data and AT commands share one
- *			     communication channel
- *			==0: B channels have separate communication channels
- *	ignoreframes	number of frames to ignore after setting up B channel
- *	cidmode		!=0: start in CallID mode
- *	modulename	name of driver module (used for I4L registration)
- * return value:
+ *
+ * Return value:
  *	pointer to cardstate structure
  */
 struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
@@ -843,6 +884,17 @@ static void cleanup_cs(struct cardstate *cs)
 }
 
 
+/**
+ * gigaset_start() - start device operations
+ * @cs:		device descriptor structure.
+ *
+ * Prepares the device for use by setting up communication parameters,
+ * scheduling an EV_START event to initiate device initialization, and
+ * waiting for completion of the initialization.
+ *
+ * Return value:
+ *	1 - success, 0 - error
+ */
 int gigaset_start(struct cardstate *cs)
 {
 	unsigned long flags;
@@ -885,9 +937,15 @@ error:
 }
 EXPORT_SYMBOL_GPL(gigaset_start);
 
-/* gigaset_shutdown
- * check if a device is associated to the cardstate structure and stop it
- * return value: 0 if ok, -1 if no device was associated
+/**
+ * gigaset_shutdown() - shut down device operations
+ * @cs:		device descriptor structure.
+ *
+ * Deactivates the device by scheduling an EV_SHUTDOWN event and
+ * waiting for completion of the shutdown.
+ *
+ * Return value:
+ *	0 - success, -1 - error (no device associated)
  */
 int gigaset_shutdown(struct cardstate *cs)
 {
@@ -918,6 +976,13 @@ exit:
 }
 EXPORT_SYMBOL_GPL(gigaset_shutdown);
 
+/**
+ * gigaset_stop() - stop device operations
+ * @cs:		device descriptor structure.
+ *
+ * Stops operations on the device by scheduling an EV_STOP event and
+ * waiting for completion of the shutdown.
+ */
 void gigaset_stop(struct cardstate *cs)
 {
 	mutex_lock(&cs->mutex);
@@ -1026,6 +1091,14 @@ struct cardstate *gigaset_get_cs_by_tty(struct tty_struct *tty)
 	return gigaset_get_cs_by_minor(tty->index + tty->driver->minor_start);
 }
 
+/**
+ * gigaset_freedriver() - free all associated ressources of a driver
+ * @drv:	driver descriptor structure.
+ *
+ * Unregisters the driver from the system and deallocates the driver
+ * structure @drv and all structures referenced from it.
+ * All devices should be shut down before calling this.
+ */
 void gigaset_freedriver(struct gigaset_driver *drv)
 {
 	unsigned long flags;
@@ -1041,14 +1114,16 @@ void gigaset_freedriver(struct gigaset_driver *drv)
 }
 EXPORT_SYMBOL_GPL(gigaset_freedriver);
 
-/* gigaset_initdriver
+/**
+ * gigaset_initdriver() - initialize driver structure
+ * @minor:	First minor number
+ * @minors:	Number of minors this driver can handle
+ * @procname:	Name of the driver
+ * @devname:	Name of the device files (prefix without minor number)
+ *
  * Allocate and initialize gigaset_driver structure. Initialize interface.
- * parameters:
- *	minor		First minor number
- *	minors		Number of minors this driver can handle
- *	procname	Name of the driver
- *	devname		Name of the device files (prefix without minor number)
- * return value:
+ *
+ * Return value:
  *	Pointer to the gigaset_driver structure on success, NULL on failure.
  */
 struct gigaset_driver *gigaset_initdriver(unsigned minor, unsigned minors,
@@ -1101,6 +1176,13 @@ error:
 }
 EXPORT_SYMBOL_GPL(gigaset_initdriver);
 
+/**
+ * gigaset_blockdriver() - block driver
+ * @drv:	driver descriptor structure.
+ *
+ * Prevents the driver from attaching new devices, in preparation for
+ * deregistration.
+ */
 void gigaset_blockdriver(struct gigaset_driver *drv)
 {
 	drv->blocked = 1;
diff --git a/drivers/isdn/gigaset/ev-layer.c b/drivers/isdn/gigaset/ev-layer.c
index 2d47ff4..c12f6fd 100644
--- a/drivers/isdn/gigaset/ev-layer.c
+++ b/drivers/isdn/gigaset/ev-layer.c
@@ -473,8 +473,13 @@ static int cid_of_response(char *s)
 	//FIXME is ;<digit>+ at end of non-CID response really impossible?
 }
 
-/* This function will be called via task queue from the callback handler.
- * We received a modem response and have to handle it..
+/**
+ * gigaset_handle_modem_response() - process received modem response
+ * @cs:		device descriptor structure.
+ *
+ * Called by asyncdata/isocdata if a block of data received from the
+ * device must be processed as a modem command response. The data is
+ * already in the cs structure.
  */
 void gigaset_handle_modem_response(struct cardstate *cs)
 {
diff --git a/drivers/isdn/gigaset/i4l.c b/drivers/isdn/gigaset/i4l.c
index 322f16e..654489d 100644
--- a/drivers/isdn/gigaset/i4l.c
+++ b/drivers/isdn/gigaset/i4l.c
@@ -85,6 +85,14 @@ static int writebuf_from_LL(int driverID, int channel, int ack,
 	return cs->ops->send_skb(bcs, skb);
 }
 
+/**
+ * gigaset_skb_sent() - acknowledge sending an skb
+ * @bcs:	B channel descriptor structure.
+ * @skb:	sent data.
+ *
+ * Called by hardware module {bas,ser,usb}_gigaset when the data in a
+ * skb has been successfully sent, for signalling completion to the LL.
+ */
 void gigaset_skb_sent(struct bc_state *bcs, struct sk_buff *skb)
 {
 	unsigned len;
@@ -461,6 +469,15 @@ int gigaset_isdn_setup_accept(struct at_state_t *at_state)
 	return 0;
 }
 
+/**
+ * gigaset_isdn_icall() - signal incoming call
+ * @at_state:	connection state structure.
+ *
+ * Called by main module to notify the LL that an incoming call has been
+ * received. @at_state contains the parameters of the call.
+ *
+ * Return value: call disposition (ICALL_*)
+ */
 int gigaset_isdn_icall(struct at_state_t *at_state)
 {
 	struct cardstate *cs = at_state->cs;
diff --git a/drivers/isdn/gigaset/interface.c b/drivers/isdn/gigaset/interface.c
index f33ac27..6a8e138 100644
--- a/drivers/isdn/gigaset/interface.c
+++ b/drivers/isdn/gigaset/interface.c
@@ -616,6 +616,15 @@ void gigaset_if_free(struct cardstate *cs)
 	tty_unregister_device(drv->tty, cs->minor_index);
 }
 
+/**
+ * gigaset_if_receive() - pass a received block of data to the tty device
+ * @cs:		device descriptor structure.
+ * @buffer:	received data.
+ * @len:	number of bytes received.
+ *
+ * Called by asyncdata/isocdata if a block of data received from the
+ * device must be sent to userspace through the ttyG* device.
+ */
 void gigaset_if_receive(struct cardstate *cs,
 			unsigned char *buffer, size_t len)
 {
diff --git a/drivers/isdn/gigaset/isocdata.c b/drivers/isdn/gigaset/isocdata.c
index 7fd32f0..9f3ef7b 100644
--- a/drivers/isdn/gigaset/isocdata.c
+++ b/drivers/isdn/gigaset/isocdata.c
@@ -976,16 +976,17 @@ void gigaset_isoc_input(struct inbuf_t *inbuf)
 
 /* == data output ========================================================== */
 
-/* gigaset_send_skb
- * called by common.c to queue an skb for sending
- * and start transmission if necessary
- * parameters:
- *	B Channel control structure
- *	skb
- * return value:
- *	number of bytes accepted for sending
- *	(skb->len if ok, 0 if out of buffer space)
- *	or error code (< 0, eg. -EINVAL)
+/**
+ * gigaset_isoc_send_skb() - queue an skb for sending
+ * @bcs:	B channel descriptor structure.
+ * @skb:	data to send.
+ *
+ * Called by i4l.c to queue an skb for sending, and start transmission if
+ * necessary.
+ *
+ * Return value:
+ *	number of bytes accepted for sending (skb->len) if ok,
+ *	error code < 0 (eg. -ENODEV) on error
  */
 int gigaset_isoc_send_skb(struct bc_state *bcs, struct sk_buff *skb)
 {
-- 
1.6.2.1.214.ge986c

From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 1/2] gigaset: use pr_err() and pr_info()
Date: Tue, 23 Dec 2008 10:27:16 +0100
Message-ID: <200812230927.mBN9RG9k028586@mail.pxnet.com>
References: <20081223-patch-00.tilman@imap.cc>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([195.227.45.7]:41259 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753421AbYLWJhO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Dec 2008 04:37:14 -0500
In-Reply-To: <20081223-patch-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch from private printk wrapper macros to using pr_err() and
pr_info() from linux/kernel.h, at the same time unifying a few
error messages.

Impact: some changed printk messages, no functional change

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/bas-gigaset.c |   12 +++++++-----
 drivers/isdn/gigaset/common.c      |   20 +++++++++-----------
 drivers/isdn/gigaset/gigaset.h     |   14 +++-----------
 drivers/isdn/gigaset/i4l.c         |    4 ++--
 drivers/isdn/gigaset/interface.c   |   26 +++++++++++++-------------
 drivers/isdn/gigaset/isocdata.c    |    4 ++--
 drivers/isdn/gigaset/ser-gigaset.c |   16 ++++++++--------
 drivers/isdn/gigaset/usb-gigaset.c |   13 +++++++------
 8 files changed, 51 insertions(+), 58 deletions(-)

diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index 3eca9c8..18dd8aa 100644
--- a/drivers/isdn/gigaset/bas-gigaset.c
+++ b/drivers/isdn/gigaset/bas-gigaset.c
@@ -2067,7 +2067,7 @@ static int gigaset_initbcshw(struct bc_state *bcs)
 
 	bcs->hw.bas = ubc = kmalloc(sizeof(struct bas_bc_state), GFP_KERNEL);
 	if (!ubc) {
-		err("could not allocate bas_bc_state");
+		pr_err("out of memory\n");
 		return 0;
 	}
 
@@ -2081,7 +2081,7 @@ static int gigaset_initbcshw(struct bc_state *bcs)
 	ubc->isooutdone = ubc->isooutfree = ubc->isooutovfl = NULL;
 	ubc->numsub = 0;
 	if (!(ubc->isooutbuf = kmalloc(sizeof(struct isowbuf_t), GFP_KERNEL))) {
-		err("could not allocate isochronous output buffer");
+		pr_err("out of memory\n");
 		kfree(ubc);
 		bcs->hw.bas = NULL;
 		return 0;
@@ -2136,8 +2136,10 @@ static int gigaset_initcshw(struct cardstate *cs)
 	struct bas_cardstate *ucs;
 
 	cs->hw.bas = ucs = kmalloc(sizeof *ucs, GFP_KERNEL);
-	if (!ucs)
+	if (!ucs) {
+		pr_err("out of memory\n");
 		return 0;
+	}
 
 	ucs->urb_cmd_in = NULL;
 	ucs->urb_cmd_out = NULL;
@@ -2503,11 +2505,11 @@ static int __init bas_gigaset_init(void)
 	/* register this driver with the USB subsystem */
 	result = usb_register(&gigaset_usb_driver);
 	if (result < 0) {
-		err("usb_register failed (error %d)", -result);
+		pr_err("error %d registering USB driver\n", -result);
 		goto error;
 	}
 
-	printk(KERN_INFO KBUILD_MODNAME ": " DRIVER_DESC "\n");
+	pr_info(DRIVER_DESC "\n");
 	return 0;
 
 error:
diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index 1664e31..0048ce9 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -580,7 +580,7 @@ static struct bc_state *gigaset_initbcs(struct bc_state *bcs,
 	} else if ((bcs->skb = dev_alloc_skb(SBUFSIZE + HW_HDR_LEN)) != NULL)
 		skb_reserve(bcs->skb, HW_HDR_LEN);
 	else {
-		err("could not allocate skb");
+		pr_err("out of memory\n");
 		bcs->inputstate |= INS_skip_frame;
 	}
 
@@ -634,20 +634,20 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
 
 	gig_dbg(DEBUG_INIT, "allocating cs");
 	if (!(cs = alloc_cs(drv))) {
-		err("maximum number of devices exceeded");
+		pr_err("maximum number of devices exceeded\n");
 		return NULL;
 	}
 
 	gig_dbg(DEBUG_INIT, "allocating bcs[0..%d]", channels - 1);
 	cs->bcs = kmalloc(channels * sizeof(struct bc_state), GFP_KERNEL);
 	if (!cs->bcs) {
-		err("out of memory");
+		pr_err("out of memory\n");
 		goto error;
 	}
 	gig_dbg(DEBUG_INIT, "allocating inbuf");
 	cs->inbuf = kmalloc(sizeof(struct inbuf_t), GFP_KERNEL);
 	if (!cs->inbuf) {
-		err("out of memory");
+		pr_err("out of memory\n");
 		goto error;
 	}
 
@@ -690,7 +690,7 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
 	for (i = 0; i < channels; ++i) {
 		gig_dbg(DEBUG_INIT, "setting up bcs[%d].read", i);
 		if (!gigaset_initbcs(cs->bcs + i, cs, i)) {
-			err("could not allocate channel %d data", i);
+			pr_err("could not allocate channel %d data\n", i);
 			goto error;
 		}
 	}
@@ -720,17 +720,15 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
 
 	gig_dbg(DEBUG_INIT, "setting up iif");
 	if (!gigaset_register_to_LL(cs, modulename)) {
-		err("register_isdn failed");
+		pr_err("error registering ISDN device\n");
 		goto error;
 	}
 
 	make_valid(cs, VALID_ID);
 	++cs->cs_init;
 	gig_dbg(DEBUG_INIT, "setting up hw");
-	if (!cs->ops->initcshw(cs)) {
-		err("could not allocate device specific data");
+	if (!cs->ops->initcshw(cs))
 		goto error;
-	}
 
 	++cs->cs_init;
 
@@ -836,7 +834,7 @@ static void cleanup_cs(struct cardstate *cs)
 	for (i = 0; i < cs->channels; ++i) {
 		gigaset_freebcs(cs->bcs + i);
 		if (!gigaset_initbcs(cs->bcs + i, cs, i))
-			break;			//FIXME error handling
+			pr_err("could not allocate channel %d data\n", i);
 	}
 
 	if (cs->waiting) {
@@ -1120,7 +1118,7 @@ static int __init gigaset_init_module(void)
 	if (gigaset_debuglevel == 1)
 		gigaset_debuglevel = DEBUG_DEFAULT;
 
-	printk(KERN_INFO KBUILD_MODNAME ": " DRIVER_DESC "\n");
+	pr_info(DRIVER_DESC "\n");
 	return 0;
 }
 
diff --git a/drivers/isdn/gigaset/gigaset.h b/drivers/isdn/gigaset/gigaset.h
index 901ff43..747178f 100644
--- a/drivers/isdn/gigaset/gigaset.h
+++ b/drivers/isdn/gigaset/gigaset.h
@@ -16,6 +16,9 @@
 #ifndef GIGASET_H
 #define GIGASET_H
 
+/* define global prefix for pr_ macros in linux/kernel.h */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/compiler.h>
 #include <linux/types.h>
@@ -97,17 +100,6 @@ enum debuglevel {
 					 activated */
 };
 
-/* Kernel message macros for situations where dev_printk and friends cannot be
- * used for lack of reliable access to a device structure.
- * linux/usb.h already contains these but in an obsolete form which clutters
- * the log needlessly, and according to the USB maintainer those should be
- * removed rather than fixed anyway.
- */
-#undef err
-
-#define err(format, arg...) printk(KERN_ERR KBUILD_MODNAME ": " \
-	format "\n" , ## arg)
-
 #ifdef CONFIG_GIGASET_DEBUG
 
 #define gig_dbg(level, format, arg...) \
diff --git a/drivers/isdn/gigaset/i4l.c b/drivers/isdn/gigaset/i4l.c
index 3c127a8..69a702f 100644
--- a/drivers/isdn/gigaset/i4l.c
+++ b/drivers/isdn/gigaset/i4l.c
@@ -42,7 +42,7 @@ static int writebuf_from_LL(int driverID, int channel, int ack,
 	unsigned skblen;
 
 	if (!(cs = gigaset_get_cs_by_id(driverID))) {
-		err("%s: invalid driver ID (%d)", __func__, driverID);
+		pr_err("%s: invalid driver ID (%d)\n", __func__, driverID);
 		return -ENODEV;
 	}
 	if (channel < 0 || channel >= cs->channels) {
@@ -119,7 +119,7 @@ static int command_from_LL(isdn_ctrl *cntrl)
 	gigaset_debugdrivers();
 
 	if (!cs) {
-		err("%s: invalid driver ID (%d)", __func__, cntrl->driver);
+		pr_err("%s: invalid driver ID (%d)\n", __func__, cntrl->driver);
 		return -ENODEV;
 	}
 
diff --git a/drivers/isdn/gigaset/interface.c b/drivers/isdn/gigaset/interface.c
index 956381c..94fa84b 100644
--- a/drivers/isdn/gigaset/interface.c
+++ b/drivers/isdn/gigaset/interface.c
@@ -107,7 +107,7 @@ static int if_config(struct cardstate *cs, int *arg)
 		return -EBUSY;
 
 	if (!cs->connected) {
-		err("not connected!");
+		pr_err("%s: not connected\n", __func__);
 		return -ENODEV;
 	}
 
@@ -188,7 +188,7 @@ static void if_close(struct tty_struct *tty, struct file *filp)
 
 	cs = (struct cardstate *) tty->driver_data;
 	if (!cs) {
-		err("cs==NULL in %s", __func__);
+		pr_err("%s: no cardstate\n", __func__);
 		return;
 	}
 
@@ -222,7 +222,7 @@ static int if_ioctl(struct tty_struct *tty, struct file *file,
 
 	cs = (struct cardstate *) tty->driver_data;
 	if (!cs) {
-		err("cs==NULL in %s", __func__);
+		pr_err("%s: no cardstate\n", __func__);
 		return -ENODEV;
 	}
 
@@ -297,7 +297,7 @@ static int if_tiocmget(struct tty_struct *tty, struct file *file)
 
 	cs = (struct cardstate *) tty->driver_data;
 	if (!cs) {
-		err("cs==NULL in %s", __func__);
+		pr_err("%s: no cardstate\n", __func__);
 		return -ENODEV;
 	}
 
@@ -323,7 +323,7 @@ static int if_tiocmset(struct tty_struct *tty, struct file *file,
 
 	cs = (struct cardstate *) tty->driver_data;
 	if (!cs) {
-		err("cs==NULL in %s", __func__);
+		pr_err("%s: no cardstate\n", __func__);
 		return -ENODEV;
 	}
 
@@ -354,7 +354,7 @@ static int if_write(struct tty_struct *tty, const unsigned char *buf, int count)
 
 	cs = (struct cardstate *) tty->driver_data;
 	if (!cs) {
-		err("cs==NULL in %s", __func__);
+		pr_err("%s: no cardstate\n", __func__);
 		return -ENODEV;
 	}
 
@@ -388,7 +388,7 @@ static int if_write_room(struct tty_struct *tty)
 
 	cs = (struct cardstate *) tty->driver_data;
 	if (!cs) {
-		err("cs==NULL in %s", __func__);
+		pr_err("%s: no cardstate\n", __func__);
 		return -ENODEV;
 	}
 
@@ -420,7 +420,7 @@ static int if_chars_in_buffer(struct tty_struct *tty)
 
 	cs = (struct cardstate *) tty->driver_data;
 	if (!cs) {
-		err("cs==NULL in %s", __func__);
+		pr_err("%s: no cardstate\n", __func__);
 		return -ENODEV;
 	}
 
@@ -451,7 +451,7 @@ static void if_throttle(struct tty_struct *tty)
 
 	cs = (struct cardstate *) tty->driver_data;
 	if (!cs) {
-		err("cs==NULL in %s", __func__);
+		pr_err("%s: no cardstate\n", __func__);
 		return;
 	}
 
@@ -474,7 +474,7 @@ static void if_unthrottle(struct tty_struct *tty)
 
 	cs = (struct cardstate *) tty->driver_data;
 	if (!cs) {
-		err("cs==NULL in %s", __func__);
+		pr_err("%s: no cardstate\n", __func__);
 		return;
 	}
 
@@ -501,7 +501,7 @@ static void if_set_termios(struct tty_struct *tty, struct ktermios *old)
 
 	cs = (struct cardstate *) tty->driver_data;
 	if (!cs) {
-		err("cs==NULL in %s", __func__);
+		pr_err("%s: no cardstate\n", __func__);
 		return;
 	}
 
@@ -701,7 +701,7 @@ void gigaset_if_initdriver(struct gigaset_driver *drv, const char *procname,
 
 	ret = tty_register_driver(tty);
 	if (ret < 0) {
-		err("failed to register tty driver (error %d)", ret);
+		pr_err("error %d registering tty driver\n", ret);
 		goto error;
 	}
 	gig_dbg(DEBUG_IF, "tty driver initialized");
@@ -709,7 +709,7 @@ void gigaset_if_initdriver(struct gigaset_driver *drv, const char *procname,
 	return;
 
 enomem:
-	err("could not allocate tty structures");
+	pr_err("out of memory\n");
 error:
 	if (drv->tty)
 		put_tty_driver(drv->tty);
diff --git a/drivers/isdn/gigaset/isocdata.c b/drivers/isdn/gigaset/isocdata.c
index fbce522..4b8b585 100644
--- a/drivers/isdn/gigaset/isocdata.c
+++ b/drivers/isdn/gigaset/isocdata.c
@@ -173,13 +173,13 @@ int gigaset_isowbuf_getbytes(struct isowbuf_t *iwb, int size)
 		__func__, read, write, limit);
 #ifdef CONFIG_GIGASET_DEBUG
 	if (unlikely(size < 0 || size > BAS_OUTBUFPAD)) {
-		err("invalid size %d", size);
+		pr_err("invalid size %d\n", size);
 		return -EINVAL;
 	}
 	src = iwb->read;
 	if (unlikely(limit > BAS_OUTBUFSIZE + BAS_OUTBUFPAD ||
 		     (read < src && limit >= src))) {
-		err("isoc write buffer frame reservation violated");
+		pr_err("isoc write buffer frame reservation violated\n");
 		return -EFAULT;
 	}
 #endif
diff --git a/drivers/isdn/gigaset/ser-gigaset.c b/drivers/isdn/gigaset/ser-gigaset.c
index b306a2f..ac245e7 100644
--- a/drivers/isdn/gigaset/ser-gigaset.c
+++ b/drivers/isdn/gigaset/ser-gigaset.c
@@ -407,7 +407,7 @@ static int gigaset_initcshw(struct cardstate *cs)
 	int rc;
 
 	if (!(cs->hw.ser = kzalloc(sizeof(struct ser_cardstate), GFP_KERNEL))) {
-		err("%s: out of memory!", __func__);
+		pr_err("out of memory\n");
 		return 0;
 	}
 
@@ -415,7 +415,7 @@ static int gigaset_initcshw(struct cardstate *cs)
 	cs->hw.ser->dev.id = cs->minor_index;
 	cs->hw.ser->dev.dev.release = gigaset_device_release;
 	if ((rc = platform_device_register(&cs->hw.ser->dev)) != 0) {
-		err("error %d registering platform device", rc);
+		pr_err("error %d registering platform device\n", rc);
 		kfree(cs->hw.ser);
 		cs->hw.ser = NULL;
 		return 0;
@@ -513,10 +513,10 @@ gigaset_tty_open(struct tty_struct *tty)
 
 	gig_dbg(DEBUG_INIT, "Starting HLL for Gigaset M101");
 
-	printk(KERN_INFO KBUILD_MODNAME ": " DRIVER_DESC "\n");
+	pr_info(DRIVER_DESC "\n");
 
 	if (!driver) {
-		err("%s: no driver structure", __func__);
+		pr_err("%s: no driver structure\n", __func__);
 		return -ENODEV;
 	}
 
@@ -572,7 +572,7 @@ gigaset_tty_close(struct tty_struct *tty)
 	tty->disc_data = NULL;
 
 	if (!cs->hw.ser)
-		err("%s: no hw cardstate", __func__);
+		pr_err("%s: no hw cardstate\n", __func__);
 	else {
 		/* wait for running methods to finish */
 		if (!atomic_dec_and_test(&cs->hw.ser->refcnt))
@@ -772,7 +772,7 @@ static int __init ser_gigaset_init(void)
 
 	gig_dbg(DEBUG_INIT, "%s", __func__);
 	if ((rc = platform_driver_register(&device_driver)) != 0) {
-		err("error %d registering platform driver", rc);
+		pr_err("error %d registering platform driver\n", rc);
 		return rc;
 	}
 
@@ -783,7 +783,7 @@ static int __init ser_gigaset_init(void)
 		goto error;
 
 	if ((rc = tty_register_ldisc(N_GIGASET_M101, &gigaset_ldisc)) != 0) {
-		err("error %d registering line discipline", rc);
+		pr_err("error %d registering line discipline\n", rc);
 		goto error;
 	}
 
@@ -810,7 +810,7 @@ static void __exit ser_gigaset_exit(void)
 	}
 
 	if ((rc = tty_unregister_ldisc(N_GIGASET_M101)) != 0)
-		err("error %d unregistering line discipline", rc);
+		pr_err("error %d unregistering line discipline\n", rc);
 
 	platform_driver_unregister(&device_driver);
 }
diff --git a/drivers/isdn/gigaset/usb-gigaset.c b/drivers/isdn/gigaset/usb-gigaset.c
index e847c6e..fba61f6 100644
--- a/drivers/isdn/gigaset/usb-gigaset.c
+++ b/drivers/isdn/gigaset/usb-gigaset.c
@@ -407,7 +407,7 @@ static void gigaset_read_int_callback(struct urb *urb)
 	spin_lock_irqsave(&cs->lock, flags);
 	if (!cs->connected) {
 		spin_unlock_irqrestore(&cs->lock, flags);
-		err("%s: disconnected", __func__);
+		pr_err("%s: disconnected\n", __func__);
 		return;
 	}
 	r = usb_submit_urb(urb, GFP_ATOMIC);
@@ -440,7 +440,7 @@ static void gigaset_write_bulk_callback(struct urb *urb)
 
 	spin_lock_irqsave(&cs->lock, flags);
 	if (!cs->connected) {
-		err("%s: not connected", __func__);
+		pr_err("%s: disconnected\n", __func__);
 	} else {
 		cs->hw.usb->busy = 0;
 		tasklet_schedule(&cs->write_tasklet);
@@ -612,8 +612,10 @@ static int gigaset_initcshw(struct cardstate *cs)
 
 	cs->hw.usb = ucs =
 		kmalloc(sizeof(struct usb_cardstate), GFP_KERNEL);
-	if (!ucs)
+	if (!ucs) {
+		pr_err("out of memory\n");
 		return 0;
+	}
 
 	ucs->bchars[0] = 0;
 	ucs->bchars[1] = 0;
@@ -936,12 +938,11 @@ static int __init usb_gigaset_init(void)
 	/* register this driver with the USB subsystem */
 	result = usb_register(&gigaset_usb_driver);
 	if (result < 0) {
-		err("usb_gigaset: usb_register failed (error %d)",
-		    -result);
+		pr_err("error %d registering USB driver\n", -result);
 		goto error;
 	}
 
-	printk(KERN_INFO KBUILD_MODNAME ": " DRIVER_DESC "\n");
+	pr_info(DRIVER_DESC "\n");
 	return 0;
 
 error:
-- 
1.6.1.rc2


From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 6/8] isdn/gigaset: unify function return values
Date: Thu, 26 Apr 2012 01:02:20 +0200 (CEST)
Message-ID: <20120425-patch-gigaset-06.tilman@imap.cc>
References: <20120425-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([89.1.7.7]:36352 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932517Ab2DYXDc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 19:03:32 -0400
In-Reply-To: <20120425-patch-gigaset-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Various functions in the Gigaset driver were using different
conventions for the meaning of their int return values.
Align them to the usual negative error numbers convention.

Inspired-by: Julia Lawall <julia.lawall@lip6.fr>
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/bas-gigaset.c |   33 ++++++++++++++++-----------
 drivers/isdn/gigaset/capi.c        |    8 +++---
 drivers/isdn/gigaset/common.c      |   43 ++++++++++++++++-------------------
 drivers/isdn/gigaset/dummyll.c     |    2 +-
 drivers/isdn/gigaset/ev-layer.c    |   16 ++++++------
 drivers/isdn/gigaset/gigaset.h     |    2 +-
 drivers/isdn/gigaset/i4l.c         |   12 +++++-----
 drivers/isdn/gigaset/isocdata.c    |   12 +++++-----
 drivers/isdn/gigaset/ser-gigaset.c |   21 ++++++++++-------
 drivers/isdn/gigaset/usb-gigaset.c |   19 ++++++++-------
 10 files changed, 87 insertions(+), 81 deletions(-)

diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index d651523..3b9278b 100644
--- a/drivers/isdn/gigaset/bas-gigaset.c
+++ b/drivers/isdn/gigaset/bas-gigaset.c
@@ -2077,16 +2077,14 @@ static int gigaset_brkchars(struct cardstate *cs, const unsigned char buf[6])
 /* Free hardware dependent part of the B channel structure
  * parameter:
  *	bcs	B channel structure
- * return value:
- *	!=0 on success
  */
-static int gigaset_freebcshw(struct bc_state *bcs)
+static void gigaset_freebcshw(struct bc_state *bcs)
 {
 	struct bas_bc_state *ubc = bcs->hw.bas;
 	int i;
 
 	if (!ubc)
-		return 0;
+		return;
 
 	/* kill URBs and tasklets before freeing - better safe than sorry */
 	ubc->running = 0;
@@ -2104,14 +2102,13 @@ static int gigaset_freebcshw(struct bc_state *bcs)
 	kfree(ubc->isooutbuf);
 	kfree(ubc);
 	bcs->hw.bas = NULL;
-	return 1;
 }
 
 /* Initialize hardware dependent part of the B channel structure
  * parameter:
  *	bcs	B channel structure
  * return value:
- *	!=0 on success
+ *	0 on success, error code < 0 on failure
  */
 static int gigaset_initbcshw(struct bc_state *bcs)
 {
@@ -2121,7 +2118,7 @@ static int gigaset_initbcshw(struct bc_state *bcs)
 	bcs->hw.bas = ubc = kmalloc(sizeof(struct bas_bc_state), GFP_KERNEL);
 	if (!ubc) {
 		pr_err("out of memory\n");
-		return 0;
+		return -ENOMEM;
 	}
 
 	ubc->running = 0;
@@ -2138,7 +2135,7 @@ static int gigaset_initbcshw(struct bc_state *bcs)
 		pr_err("out of memory\n");
 		kfree(ubc);
 		bcs->hw.bas = NULL;
-		return 0;
+		return -ENOMEM;
 	}
 	tasklet_init(&ubc->sent_tasklet,
 		     write_iso_tasklet, (unsigned long) bcs);
@@ -2163,7 +2160,7 @@ static int gigaset_initbcshw(struct bc_state *bcs)
 	ubc->stolen0s = 0;
 	tasklet_init(&ubc->rcvd_tasklet,
 		     read_iso_tasklet, (unsigned long) bcs);
-	return 1;
+	return 0;
 }
 
 static void gigaset_reinitbcshw(struct bc_state *bcs)
@@ -2186,6 +2183,12 @@ static void gigaset_freecshw(struct cardstate *cs)
 	cs->hw.bas = NULL;
 }
 
+/* Initialize hardware dependent part of the cardstate structure
+ * parameter:
+ *	cs	cardstate structure
+ * return value:
+ *	0 on success, error code < 0 on failure
+ */
 static int gigaset_initcshw(struct cardstate *cs)
 {
 	struct bas_cardstate *ucs;
@@ -2193,13 +2196,13 @@ static int gigaset_initcshw(struct cardstate *cs)
 	cs->hw.bas = ucs = kmalloc(sizeof *ucs, GFP_KERNEL);
 	if (!ucs) {
 		pr_err("out of memory\n");
-		return 0;
+		return -ENOMEM;
 	}
 	ucs->int_in_buf = kmalloc(IP_MSGSIZE, GFP_KERNEL);
 	if (!ucs->int_in_buf) {
 		kfree(ucs);
 		pr_err("out of memory\n");
-		return 0;
+		return -ENOMEM;
 	}
 
 	ucs->urb_cmd_in = NULL;
@@ -2218,7 +2221,7 @@ static int gigaset_initcshw(struct cardstate *cs)
 	init_waitqueue_head(&ucs->waitqueue);
 	INIT_WORK(&ucs->int_in_wq, int_in_work);
 
-	return 1;
+	return 0;
 }
 
 /* freeurbs
@@ -2378,18 +2381,20 @@ static int gigaset_probe(struct usb_interface *interface,
 	/* save address of controller structure */
 	usb_set_intfdata(interface, cs);
 
-	if (!gigaset_start(cs))
+	rc = gigaset_start(cs);
+	if (rc < 0)
 		goto error;
 
 	return 0;
 
 allocerr:
 	dev_err(cs->dev, "could not allocate URBs\n");
+	rc = -ENOMEM;
 error:
 	freeurbs(cs);
 	usb_set_intfdata(interface, NULL);
 	gigaset_freecs(cs);
-	return -ENODEV;
+	return rc;
 }
 
 /* gigaset_disconnect
diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index 86cee65..27e4a3e 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -2346,7 +2346,7 @@ static const struct file_operations gigaset_proc_fops = {
  * @cs:		device descriptor structure.
  * @isdnid:	device name.
  *
- * Return value: 1 for success, 0 for failure
+ * Return value: 0 on success, error code < 0 on failure
  */
 int gigaset_isdn_regdev(struct cardstate *cs, const char *isdnid)
 {
@@ -2356,7 +2356,7 @@ int gigaset_isdn_regdev(struct cardstate *cs, const char *isdnid)
 	iif = kmalloc(sizeof(*iif), GFP_KERNEL);
 	if (!iif) {
 		pr_err("%s: out of memory\n", __func__);
-		return 0;
+		return -ENOMEM;
 	}
 
 	/* prepare controller structure */
@@ -2380,12 +2380,12 @@ int gigaset_isdn_regdev(struct cardstate *cs, const char *isdnid)
 	if (rc) {
 		pr_err("attach_capi_ctr failed (%d)\n", rc);
 		kfree(iif);
-		return 0;
+		return rc;
 	}
 
 	cs->iif = iif;
 	cs->hw_hdr_len = CAPI_DATA_B3_REQ_LEN;
-	return 1;
+	return 0;
 }
 
 /**
diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index 6c306d4..aa41485 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -194,13 +194,13 @@ int gigaset_get_channel(struct bc_state *bcs)
 		gig_dbg(DEBUG_CHANNEL, "could not allocate channel %d",
 			bcs->channel);
 		spin_unlock_irqrestore(&bcs->cs->lock, flags);
-		return 0;
+		return -EBUSY;
 	}
 	++bcs->use_count;
 	bcs->busy = 1;
 	gig_dbg(DEBUG_CHANNEL, "allocated channel %d", bcs->channel);
 	spin_unlock_irqrestore(&bcs->cs->lock, flags);
-	return 1;
+	return 0;
 }
 
 struct bc_state *gigaset_get_free_channel(struct cardstate *cs)
@@ -258,7 +258,7 @@ int gigaset_get_channels(struct cardstate *cs)
 			spin_unlock_irqrestore(&cs->lock, flags);
 			gig_dbg(DEBUG_CHANNEL,
 				"could not allocate all channels");
-			return 0;
+			return -EBUSY;
 		}
 	for (i = 0; i < cs->channels; ++i)
 		++cs->bcs[i].use_count;
@@ -266,7 +266,7 @@ int gigaset_get_channels(struct cardstate *cs)
 
 	gig_dbg(DEBUG_CHANNEL, "allocated all channels");
 
-	return 1;
+	return 0;
 }
 
 void gigaset_free_channels(struct cardstate *cs)
@@ -388,8 +388,7 @@ static void gigaset_freebcs(struct bc_state *bcs)
 	int i;
 
 	gig_dbg(DEBUG_INIT, "freeing bcs[%d]->hw", bcs->channel);
-	if (!bcs->cs->ops->freebcshw(bcs))
-		gig_dbg(DEBUG_INIT, "failed");
+	bcs->cs->ops->freebcshw(bcs);
 
 	gig_dbg(DEBUG_INIT, "clearing bcs[%d]->at_state", bcs->channel);
 	clear_at_state(&bcs->at_state);
@@ -566,6 +565,8 @@ static void gigaset_inbuf_init(struct inbuf_t *inbuf, struct cardstate *cs)
  * @inbuf:	buffer structure.
  * @src:	received data.
  * @numbytes:	number of bytes received.
+ *
+ * Return value: !=0 if some data was appended
  */
 int gigaset_fill_inbuf(struct inbuf_t *inbuf, const unsigned char *src,
 		       unsigned numbytes)
@@ -609,8 +610,8 @@ int gigaset_fill_inbuf(struct inbuf_t *inbuf, const unsigned char *src,
 EXPORT_SYMBOL_GPL(gigaset_fill_inbuf);
 
 /* Initialize the b-channel structure */
-static struct bc_state *gigaset_initbcs(struct bc_state *bcs,
-					struct cardstate *cs, int channel)
+static int gigaset_initbcs(struct bc_state *bcs, struct cardstate *cs,
+			   int channel)
 {
 	int i;
 
@@ -649,11 +650,7 @@ static struct bc_state *gigaset_initbcs(struct bc_state *bcs,
 	bcs->apconnstate = 0;
 
 	gig_dbg(DEBUG_INIT, "  setting up bcs[%d]->hw", channel);
-	if (cs->ops->initbcshw(bcs))
-		return bcs;
-
-	gig_dbg(DEBUG_INIT, "  failed");
-	return NULL;
+	return cs->ops->initbcshw(bcs);
 }
 
 /**
@@ -752,7 +749,7 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
 	cs->cmdbytes = 0;
 
 	gig_dbg(DEBUG_INIT, "setting up iif");
-	if (!gigaset_isdn_regdev(cs, modulename)) {
+	if (gigaset_isdn_regdev(cs, modulename) < 0) {
 		pr_err("error registering ISDN device\n");
 		goto error;
 	}
@@ -760,7 +757,7 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
 	make_valid(cs, VALID_ID);
 	++cs->cs_init;
 	gig_dbg(DEBUG_INIT, "setting up hw");
-	if (!cs->ops->initcshw(cs))
+	if (cs->ops->initcshw(cs) < 0)
 		goto error;
 
 	++cs->cs_init;
@@ -774,7 +771,7 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
 	/* set up channel data structures */
 	for (i = 0; i < channels; ++i) {
 		gig_dbg(DEBUG_INIT, "setting up bcs[%d]", i);
-		if (!gigaset_initbcs(cs->bcs + i, cs, i)) {
+		if (gigaset_initbcs(cs->bcs + i, cs, i) < 0) {
 			pr_err("could not allocate channel %d data\n", i);
 			goto error;
 		}
@@ -869,7 +866,7 @@ static void cleanup_cs(struct cardstate *cs)
 
 	for (i = 0; i < cs->channels; ++i) {
 		gigaset_freebcs(cs->bcs + i);
-		if (!gigaset_initbcs(cs->bcs + i, cs, i))
+		if (gigaset_initbcs(cs->bcs + i, cs, i) < 0)
 			pr_err("could not allocate channel %d data\n", i);
 	}
 
@@ -890,14 +887,14 @@ static void cleanup_cs(struct cardstate *cs)
  * waiting for completion of the initialization.
  *
  * Return value:
- *	1 - success, 0 - error
+ *	0 on success, error code < 0 on failure
  */
 int gigaset_start(struct cardstate *cs)
 {
 	unsigned long flags;
 
 	if (mutex_lock_interruptible(&cs->mutex))
-		return 0;
+		return -EBUSY;
 
 	spin_lock_irqsave(&cs->lock, flags);
 	cs->connected = 1;
@@ -921,11 +918,11 @@ int gigaset_start(struct cardstate *cs)
 	wait_event(cs->waitqueue, !cs->waiting);
 
 	mutex_unlock(&cs->mutex);
-	return 1;
+	return 0;
 
 error:
 	mutex_unlock(&cs->mutex);
-	return 0;
+	return -ENOMEM;
 }
 EXPORT_SYMBOL_GPL(gigaset_start);
 
@@ -937,7 +934,7 @@ EXPORT_SYMBOL_GPL(gigaset_start);
  * waiting for completion of the shutdown.
  *
  * Return value:
- *	0 - success, -1 - error (no device associated)
+ *	0 - success, -ENODEV - error (no device associated)
  */
 int gigaset_shutdown(struct cardstate *cs)
 {
@@ -945,7 +942,7 @@ int gigaset_shutdown(struct cardstate *cs)
 
 	if (!(cs->flags & VALID_MINOR)) {
 		mutex_unlock(&cs->mutex);
-		return -1;
+		return -ENODEV;
 	}
 
 	cs->waiting = 1;
diff --git a/drivers/isdn/gigaset/dummyll.c b/drivers/isdn/gigaset/dummyll.c
index 19b1c77..570c2d5 100644
--- a/drivers/isdn/gigaset/dummyll.c
+++ b/drivers/isdn/gigaset/dummyll.c
@@ -60,7 +60,7 @@ void gigaset_isdn_stop(struct cardstate *cs)
 
 int gigaset_isdn_regdev(struct cardstate *cs, const char *isdnid)
 {
-	return 1;
+	return 0;
 }
 
 void gigaset_isdn_unregdev(struct cardstate *cs)
diff --git a/drivers/isdn/gigaset/ev-layer.c b/drivers/isdn/gigaset/ev-layer.c
index 8391e09..2e6963d 100644
--- a/drivers/isdn/gigaset/ev-layer.c
+++ b/drivers/isdn/gigaset/ev-layer.c
@@ -658,7 +658,7 @@ static inline struct at_state_t *get_free_channel(struct cardstate *cs,
 	struct at_state_t *ret;
 
 	for (i = 0; i < cs->channels; ++i)
-		if (gigaset_get_channel(cs->bcs + i)) {
+		if (gigaset_get_channel(cs->bcs + i) >= 0) {
 			ret = &cs->bcs[i].at_state;
 			ret->cid = cid;
 			return ret;
@@ -923,18 +923,18 @@ static void do_stop(struct cardstate *cs)
  * channel >= 0: getting cid for the channel failed
  * channel < 0:  entering cid mode failed
  *
- * returns 0 on failure
+ * returns 0 on success, <0 on failure
  */
 static int reinit_and_retry(struct cardstate *cs, int channel)
 {
 	int i;
 
 	if (--cs->retry_count <= 0)
-		return 0;
+		return -EFAULT;
 
 	for (i = 0; i < cs->channels; ++i)
 		if (cs->bcs[i].at_state.cid > 0)
-			return 0;
+			return -EBUSY;
 
 	if (channel < 0)
 		dev_warn(cs->dev,
@@ -945,7 +945,7 @@ static int reinit_and_retry(struct cardstate *cs, int channel)
 		cs->bcs[channel].at_state.pending_commands |= PC_CID;
 	}
 	schedule_init(cs, MS_INIT);
-	return 1;
+	return 0;
 }
 
 static int at_state_invalid(struct cardstate *cs,
@@ -1016,7 +1016,7 @@ static int do_lock(struct cardstate *cs)
 			if (cs->bcs[i].at_state.pending_commands)
 				return -EBUSY;
 
-		if (!gigaset_get_channels(cs))
+		if (gigaset_get_channels(cs) < 0)
 			return -EBUSY;
 
 		break;
@@ -1125,7 +1125,7 @@ static void do_action(int action, struct cardstate *cs,
 			init_failed(cs, M_UNKNOWN);
 			break;
 		}
-		if (!reinit_and_retry(cs, -1))
+		if (reinit_and_retry(cs, -1) < 0)
 			schedule_init(cs, MS_RECOVER);
 		break;
 	case ACT_FAILUMODE:
@@ -1268,7 +1268,7 @@ static void do_action(int action, struct cardstate *cs,
 	case ACT_FAILCID:
 		cs->cur_at_seq = SEQ_NONE;
 		channel = cs->curchannel;
-		if (!reinit_and_retry(cs, channel)) {
+		if (reinit_and_retry(cs, channel) < 0) {
 			dev_warn(cs->dev,
 				 "Could not get a call ID. Cannot dial.\n");
 			at_state2 = &cs->bcs[channel].at_state;
diff --git a/drivers/isdn/gigaset/gigaset.h b/drivers/isdn/gigaset/gigaset.h
index eae7351..8e2fc8f 100644
--- a/drivers/isdn/gigaset/gigaset.h
+++ b/drivers/isdn/gigaset/gigaset.h
@@ -583,7 +583,7 @@ struct gigaset_ops {
 	int (*initbcshw)(struct bc_state *bcs);
 
 	/* Called by gigaset_freecs() for freeing bcs->hw.xxx */
-	int (*freebcshw)(struct bc_state *bcs);
+	void (*freebcshw)(struct bc_state *bcs);
 
 	/* Called by gigaset_bchannel_down() for resetting bcs->hw.xxx */
 	void (*reinitbcshw)(struct bc_state *bcs);
diff --git a/drivers/isdn/gigaset/i4l.c b/drivers/isdn/gigaset/i4l.c
index 0f13eb1..2d75329 100644
--- a/drivers/isdn/gigaset/i4l.c
+++ b/drivers/isdn/gigaset/i4l.c
@@ -229,7 +229,7 @@ static int command_from_LL(isdn_ctrl *cntrl)
 			return -EINVAL;
 		}
 		bcs = cs->bcs + ch;
-		if (!gigaset_get_channel(bcs)) {
+		if (gigaset_get_channel(bcs) < 0) {
 			dev_err(cs->dev, "ISDN_CMD_DIAL: channel not free\n");
 			return -EBUSY;
 		}
@@ -618,7 +618,7 @@ void gigaset_isdn_stop(struct cardstate *cs)
  * @cs:		device descriptor structure.
  * @isdnid:	device name.
  *
- * Return value: 1 for success, 0 for failure
+ * Return value: 0 on success, error code < 0 on failure
  */
 int gigaset_isdn_regdev(struct cardstate *cs, const char *isdnid)
 {
@@ -627,14 +627,14 @@ int gigaset_isdn_regdev(struct cardstate *cs, const char *isdnid)
 	iif = kmalloc(sizeof *iif, GFP_KERNEL);
 	if (!iif) {
 		pr_err("out of memory\n");
-		return 0;
+		return -ENOMEM;
 	}
 
 	if (snprintf(iif->id, sizeof iif->id, "%s_%u", isdnid, cs->minor_index)
 	    >= sizeof iif->id) {
 		pr_err("ID too long: %s\n", isdnid);
 		kfree(iif);
-		return 0;
+		return -EINVAL;
 	}
 
 	iif->owner = THIS_MODULE;
@@ -656,13 +656,13 @@ int gigaset_isdn_regdev(struct cardstate *cs, const char *isdnid)
 	if (!register_isdn(iif)) {
 		pr_err("register_isdn failed\n");
 		kfree(iif);
-		return 0;
+		return -EINVAL;
 	}
 
 	cs->iif = iif;
 	cs->myid = iif->channels;		/* Set my device id */
 	cs->hw_hdr_len = HW_HDR_LEN;
-	return 1;
+	return 0;
 }
 
 /**
diff --git a/drivers/isdn/gigaset/isocdata.c b/drivers/isdn/gigaset/isocdata.c
index a351c16..bc29f1d 100644
--- a/drivers/isdn/gigaset/isocdata.c
+++ b/drivers/isdn/gigaset/isocdata.c
@@ -56,7 +56,7 @@ static inline int isowbuf_freebytes(struct isowbuf_t *iwb)
 
 /* start writing
  * acquire the write semaphore
- * return true if acquired, false if busy
+ * return 0 if acquired, <0 if busy
  */
 static inline int isowbuf_startwrite(struct isowbuf_t *iwb)
 {
@@ -64,12 +64,12 @@ static inline int isowbuf_startwrite(struct isowbuf_t *iwb)
 		atomic_inc(&iwb->writesem);
 		gig_dbg(DEBUG_ISO, "%s: couldn't acquire iso write semaphore",
 			__func__);
-		return 0;
+		return -EBUSY;
 	}
 	gig_dbg(DEBUG_ISO,
 		"%s: acquired iso write semaphore, data[write]=%02x, nbits=%d",
 		__func__, iwb->data[iwb->write], iwb->wbits);
-	return 1;
+	return 0;
 }
 
 /* finish writing
@@ -158,7 +158,7 @@ int gigaset_isowbuf_getbytes(struct isowbuf_t *iwb, int size)
 		/* no wraparound in valid data */
 		if (limit >= write) {
 			/* append idle frame */
-			if (!isowbuf_startwrite(iwb))
+			if (isowbuf_startwrite(iwb) < 0)
 				return -EBUSY;
 			/* write position could have changed */
 			write = iwb->write;
@@ -403,7 +403,7 @@ static inline int hdlc_buildframe(struct isowbuf_t *iwb,
 	unsigned char c;
 
 	if (isowbuf_freebytes(iwb) < count + count / 5 + 6 ||
-	    !isowbuf_startwrite(iwb)) {
+	    isowbuf_startwrite(iwb) < 0) {
 		gig_dbg(DEBUG_ISO, "%s: %d bytes free -> -EAGAIN",
 			__func__, isowbuf_freebytes(iwb));
 		return -EAGAIN;
@@ -457,7 +457,7 @@ static inline int trans_buildframe(struct isowbuf_t *iwb,
 		return iwb->write;
 
 	if (isowbuf_freebytes(iwb) < count ||
-	    !isowbuf_startwrite(iwb)) {
+	    isowbuf_startwrite(iwb) < 0) {
 		gig_dbg(DEBUG_ISO, "can't put %d bytes", count);
 		return -EAGAIN;
 	}
diff --git a/drivers/isdn/gigaset/ser-gigaset.c b/drivers/isdn/gigaset/ser-gigaset.c
index 6f3fd4c..8c91fd5 100644
--- a/drivers/isdn/gigaset/ser-gigaset.c
+++ b/drivers/isdn/gigaset/ser-gigaset.c
@@ -340,17 +340,16 @@ static int gigaset_initbcshw(struct bc_state *bcs)
 {
 	/* unused */
 	bcs->hw.ser = NULL;
-	return 1;
+	return 0;
 }
 
 /*
  * Free B channel structure
  * Called by "gigaset_freebcs" in common.c
  */
-static int gigaset_freebcshw(struct bc_state *bcs)
+static void gigaset_freebcshw(struct bc_state *bcs)
 {
 	/* unused */
-	return 1;
 }
 
 /*
@@ -398,7 +397,7 @@ static int gigaset_initcshw(struct cardstate *cs)
 	scs = kzalloc(sizeof(struct ser_cardstate), GFP_KERNEL);
 	if (!scs) {
 		pr_err("out of memory\n");
-		return 0;
+		return -ENOMEM;
 	}
 	cs->hw.ser = scs;
 
@@ -410,13 +409,13 @@ static int gigaset_initcshw(struct cardstate *cs)
 		pr_err("error %d registering platform device\n", rc);
 		kfree(cs->hw.ser);
 		cs->hw.ser = NULL;
-		return 0;
+		return rc;
 	}
 	dev_set_drvdata(&cs->hw.ser->dev.dev, cs);
 
 	tasklet_init(&cs->write_tasklet,
 		     gigaset_modem_fill, (unsigned long) cs);
-	return 1;
+	return 0;
 }
 
 /*
@@ -503,6 +502,7 @@ static int
 gigaset_tty_open(struct tty_struct *tty)
 {
 	struct cardstate *cs;
+	int rc;
 
 	gig_dbg(DEBUG_INIT, "Starting HLL for Gigaset M101");
 
@@ -515,8 +515,10 @@ gigaset_tty_open(struct tty_struct *tty)
 
 	/* allocate memory for our device state and initialize it */
 	cs = gigaset_initcs(driver, 1, 1, 0, cidmode, GIGASET_MODULENAME);
-	if (!cs)
+	if (!cs) {
+		rc = -ENODEV;
 		goto error;
+	}
 
 	cs->dev = &cs->hw.ser->dev.dev;
 	cs->hw.ser->tty = tty;
@@ -530,7 +532,8 @@ gigaset_tty_open(struct tty_struct *tty)
 	 */
 	if (startmode == SM_LOCKED)
 		cs->mstate = MS_LOCKED;
-	if (!gigaset_start(cs)) {
+	rc = gigaset_start(cs);
+	if (rc < 0) {
 		tasklet_kill(&cs->write_tasklet);
 		goto error;
 	}
@@ -542,7 +545,7 @@ error:
 	gig_dbg(DEBUG_INIT, "Startup of HLL failed");
 	tty->disc_data = NULL;
 	gigaset_freecs(cs);
-	return -ENODEV;
+	return rc;
 }
 
 /*
diff --git a/drivers/isdn/gigaset/usb-gigaset.c b/drivers/isdn/gigaset/usb-gigaset.c
index 049da67..bb12d80 100644
--- a/drivers/isdn/gigaset/usb-gigaset.c
+++ b/drivers/isdn/gigaset/usb-gigaset.c
@@ -549,10 +549,9 @@ static int gigaset_brkchars(struct cardstate *cs, const unsigned char buf[6])
 			       0, 0, &buf, 6, 2000);
 }
 
-static int gigaset_freebcshw(struct bc_state *bcs)
+static void gigaset_freebcshw(struct bc_state *bcs)
 {
 	/* unused */
-	return 1;
 }
 
 /* Initialize the b-channel structure */
@@ -560,7 +559,7 @@ static int gigaset_initbcshw(struct bc_state *bcs)
 {
 	/* unused */
 	bcs->hw.usb = NULL;
-	return 1;
+	return 0;
 }
 
 static void gigaset_reinitbcshw(struct bc_state *bcs)
@@ -582,7 +581,7 @@ static int gigaset_initcshw(struct cardstate *cs)
 		kmalloc(sizeof(struct usb_cardstate), GFP_KERNEL);
 	if (!ucs) {
 		pr_err("out of memory\n");
-		return 0;
+		return -ENOMEM;
 	}
 
 	ucs->bchars[0] = 0;
@@ -597,7 +596,7 @@ static int gigaset_initcshw(struct cardstate *cs)
 	tasklet_init(&cs->write_tasklet,
 		     gigaset_modem_fill, (unsigned long) cs);
 
-	return 1;
+	return 0;
 }
 
 /* Send data from current skb to the device. */
@@ -766,9 +765,9 @@ static int gigaset_probe(struct usb_interface *interface,
 	if (startmode == SM_LOCKED)
 		cs->mstate = MS_LOCKED;
 
-	if (!gigaset_start(cs)) {
+	retval = gigaset_start(cs);
+	if (retval < 0) {
 		tasklet_kill(&cs->write_tasklet);
-		retval = -ENODEV;
 		goto error;
 	}
 	return 0;
@@ -898,8 +897,10 @@ static int __init usb_gigaset_init(void)
 	driver = gigaset_initdriver(GIGASET_MINOR, GIGASET_MINORS,
 				    GIGASET_MODULENAME, GIGASET_DEVNAME,
 				    &ops, THIS_MODULE);
-	if (driver == NULL)
+	if (driver == NULL) {
+		result = -ENOMEM;
 		goto error;
+	}
 
 	/* register this driver with the USB subsystem */
 	result = usb_register(&gigaset_usb_driver);
@@ -915,7 +916,7 @@ error:
 	if (driver)
 		gigaset_freedriver(driver);
 	driver = NULL;
-	return -1;
+	return result;
 }
 
 /*
-- 
1.7.3.4

From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 5/9] gigaset: checkpatch cleanup
Date: Sun, 25 Oct 2009 20:30:17 +0100 (CET)
Message-ID: <20091023-patch-gigaset-05.tilman@imap.cc>
References: <20091023-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754164AbZJYTbu@vger.kernel.org>
In-Reply-To: <20091023-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dum sanctis checkpatch.pl'ae legibus obsequimur.

Impact: cosmetic
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/common.c    |   33 +++++++++------------
 drivers/isdn/gigaset/gigaset.h   |   60 ++++++++++++++++++-------------------
 drivers/isdn/gigaset/i4l.c       |   29 +++++++-----------
 drivers/isdn/gigaset/interface.c |   39 +++++++++++-------------
 drivers/isdn/gigaset/proc.c      |    2 +-
 5 files changed, 74 insertions(+), 89 deletions(-)

diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index 690ac74..c438cfc 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -108,7 +108,7 @@ int gigaset_enterconfigmode(struct cardstate *cs)
 {
 	int i, r;
 
-	cs->control_state = TIOCM_RTS; //FIXME
+	cs->control_state = TIOCM_RTS;
 
 	r = setflags(cs, TIOCM_DTR, 200);
 	if (r < 0)
@@ -132,10 +132,10 @@ int gigaset_enterconfigmode(struct cardstate *cs)
 
 error:
 	dev_err(cs->dev, "error %d on setuartbits\n", -r);
-	cs->control_state = TIOCM_RTS|TIOCM_DTR; // FIXME is this a good value?
+	cs->control_state = TIOCM_RTS|TIOCM_DTR;
 	cs->ops->set_modem_ctrl(cs, 0, TIOCM_RTS|TIOCM_DTR);
 
-	return -1; //r
+	return -1;
 }
 
 static int test_timeout(struct at_state_t *at_state)
@@ -150,10 +150,9 @@ static int test_timeout(struct at_state_t *at_state)
 	}
 
 	if (!gigaset_add_event(at_state->cs, at_state, EV_TIMEOUT, NULL,
-			       at_state->timer_index, NULL)) {
-		//FIXME what should we do?
-	}
-
+			       at_state->timer_index, NULL))
+			dev_err(at_state->cs->dev, "%s: out of memory\n",
+				__func__);
 	return 1;
 }
 
@@ -393,9 +392,8 @@ static void gigaset_freebcs(struct bc_state *bcs)
 	int i;
 
 	gig_dbg(DEBUG_INIT, "freeing bcs[%d]->hw", bcs->channel);
-	if (!bcs->cs->ops->freebcshw(bcs)) {
+	if (!bcs->cs->ops->freebcshw(bcs))
 		gig_dbg(DEBUG_INIT, "failed");
-	}
 
 	gig_dbg(DEBUG_INIT, "clearing bcs[%d]->at_state", bcs->channel);
 	clear_at_state(&bcs->at_state);
@@ -503,8 +501,6 @@ void gigaset_freecs(struct cardstate *cs)
 		gig_dbg(DEBUG_INIT, "clearing hw");
 		cs->ops->freecshw(cs);
 
-		//FIXME cmdbuf
-
 		/* fall through */
 	case 2: /* error in initcshw */
 		/* Deregister from LL */
@@ -622,7 +618,7 @@ static struct bc_state *gigaset_initbcs(struct bc_state *bcs,
 {
 	int i;
 
-	bcs->tx_skb = NULL; //FIXME -> hw part
+	bcs->tx_skb = NULL;
 
 	skb_queue_head_init(&bcs->squeue);
 
@@ -696,12 +692,13 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
 				 int onechannel, int ignoreframes,
 				 int cidmode, const char *modulename)
 {
-	struct cardstate *cs = NULL;
+	struct cardstate *cs;
 	unsigned long flags;
 	int i;
 
 	gig_dbg(DEBUG_INIT, "allocating cs");
-	if (!(cs = alloc_cs(drv))) {
+	cs = alloc_cs(drv);
+	if (!cs) {
 		pr_err("maximum number of devices exceeded\n");
 		return NULL;
 	}
@@ -931,15 +928,13 @@ int gigaset_start(struct cardstate *cs)
 		cs->ops->baud_rate(cs, B115200);
 		cs->ops->set_line_ctrl(cs, CS8);
 		cs->control_state = TIOCM_DTR|TIOCM_RTS;
-	} else {
-		//FIXME use some saved values?
 	}
 
 	cs->waiting = 1;
 
 	if (!gigaset_add_event(cs, &cs->at_state, EV_START, NULL, 0, NULL)) {
 		cs->waiting = 0;
-		//FIXME what should we do?
+		dev_err(cs->dev, "%s: out of memory\n", __func__);
 		goto error;
 	}
 
@@ -979,7 +974,7 @@ int gigaset_shutdown(struct cardstate *cs)
 	cs->waiting = 1;
 
 	if (!gigaset_add_event(cs, &cs->at_state, EV_SHUTDOWN, NULL, 0, NULL)) {
-		//FIXME what should we do?
+		dev_err(cs->dev, "%s: out of memory\n", __func__);
 		goto exit;
 	}
 
@@ -1010,7 +1005,7 @@ void gigaset_stop(struct cardstate *cs)
 	cs->waiting = 1;
 
 	if (!gigaset_add_event(cs, &cs->at_state, EV_STOP, NULL, 0, NULL)) {
-		//FIXME what should we do?
+		dev_err(cs->dev, "%s: out of memory\n", __func__);
 		goto exit;
 	}
 
diff --git a/drivers/isdn/gigaset/gigaset.h b/drivers/isdn/gigaset/gigaset.h
index 18bff9f..3c74cd1 100644
--- a/drivers/isdn/gigaset/gigaset.h
+++ b/drivers/isdn/gigaset/gigaset.h
@@ -34,8 +34,8 @@
 #include <linux/list.h>
 #include <asm/atomic.h>
 
-#define GIG_VERSION {0,5,0,0}
-#define GIG_COMPAT  {0,4,0,0}
+#define GIG_VERSION {0, 5, 0, 0}
+#define GIG_COMPAT  {0, 4, 0, 0}
 
 #define MAX_REC_PARAMS 10	/* Max. number of params in response string */
 #define MAX_RESP_SIZE 512	/* Max. size of a response string */
@@ -133,35 +133,32 @@ void gigaset_dbg_buffer(enum debuglevel level, const unsigned char *msg,
 #define OUT_VENDOR_REQ	(USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_ENDPOINT)
 #define IN_VENDOR_REQ	(USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_ENDPOINT)
 
-/* int-in-events 3070 */
+/* interrupt pipe messages */
 #define HD_B1_FLOW_CONTROL		0x80
 #define HD_B2_FLOW_CONTROL		0x81
-#define HD_RECEIVEATDATA_ACK		(0x35)		// 3070
-						// att: HD_RECEIVE>>AT<<DATA_ACK
-#define HD_READY_SEND_ATDATA		(0x36)		// 3070
-#define HD_OPEN_ATCHANNEL_ACK		(0x37)		// 3070
-#define HD_CLOSE_ATCHANNEL_ACK		(0x38)		// 3070
-#define HD_DEVICE_INIT_OK		(0x11)		// ISurf USB + 3070
-#define HD_OPEN_B1CHANNEL_ACK		(0x51)		// ISurf USB + 3070
-#define HD_OPEN_B2CHANNEL_ACK		(0x52)		// ISurf USB + 3070
-#define HD_CLOSE_B1CHANNEL_ACK		(0x53)		// ISurf USB + 3070
-#define HD_CLOSE_B2CHANNEL_ACK		(0x54)		// ISurf USB + 3070
-// 	 Powermangment
-#define HD_SUSPEND_END			(0x61)		// ISurf USB
-//   Configuration
-#define HD_RESET_INTERRUPT_PIPE_ACK	(0xFF)		// ISurf USB + 3070
-
-/* control requests 3070 */
-#define	HD_OPEN_B1CHANNEL		(0x23)		// ISurf USB + 3070
-#define	HD_CLOSE_B1CHANNEL		(0x24)		// ISurf USB + 3070
-#define	HD_OPEN_B2CHANNEL		(0x25)		// ISurf USB + 3070
-#define	HD_CLOSE_B2CHANNEL		(0x26)		// ISurf USB + 3070
-#define HD_RESET_INTERRUPT_PIPE		(0x27)		// ISurf USB + 3070
-#define	HD_DEVICE_INIT_ACK		(0x34)		// ISurf USB + 3070
-#define	HD_WRITE_ATMESSAGE		(0x12)		// 3070
-#define	HD_READ_ATMESSAGE		(0x13)		// 3070
-#define	HD_OPEN_ATCHANNEL		(0x28)		// 3070
-#define	HD_CLOSE_ATCHANNEL		(0x29)		// 3070
+#define HD_RECEIVEATDATA_ACK		(0x35)		/* 3070 */
+#define HD_READY_SEND_ATDATA		(0x36)		/* 3070 */
+#define HD_OPEN_ATCHANNEL_ACK		(0x37)		/* 3070 */
+#define HD_CLOSE_ATCHANNEL_ACK		(0x38)		/* 3070 */
+#define HD_DEVICE_INIT_OK		(0x11)		/* ISurf USB + 3070 */
+#define HD_OPEN_B1CHANNEL_ACK		(0x51)		/* ISurf USB + 3070 */
+#define HD_OPEN_B2CHANNEL_ACK		(0x52)		/* ISurf USB + 3070 */
+#define HD_CLOSE_B1CHANNEL_ACK		(0x53)		/* ISurf USB + 3070 */
+#define HD_CLOSE_B2CHANNEL_ACK		(0x54)		/* ISurf USB + 3070 */
+#define HD_SUSPEND_END			(0x61)		/* ISurf USB */
+#define HD_RESET_INTERRUPT_PIPE_ACK	(0xFF)		/* ISurf USB + 3070 */
+
+/* control requests */
+#define	HD_OPEN_B1CHANNEL		(0x23)		/* ISurf USB + 3070 */
+#define	HD_CLOSE_B1CHANNEL		(0x24)		/* ISurf USB + 3070 */
+#define	HD_OPEN_B2CHANNEL		(0x25)		/* ISurf USB + 3070 */
+#define	HD_CLOSE_B2CHANNEL		(0x26)		/* ISurf USB + 3070 */
+#define HD_RESET_INTERRUPT_PIPE		(0x27)		/* ISurf USB + 3070 */
+#define	HD_DEVICE_INIT_ACK		(0x34)		/* ISurf USB + 3070 */
+#define	HD_WRITE_ATMESSAGE		(0x12)		/* 3070 */
+#define	HD_READ_ATMESSAGE		(0x13)		/* 3070 */
+#define	HD_OPEN_ATCHANNEL		(0x28)		/* 3070 */
+#define	HD_CLOSE_ATCHANNEL		(0x29)		/* 3070 */
 
 /* number of B channels supported by base driver */
 #define BAS_CHANNELS	2
@@ -631,7 +628,8 @@ struct gigaset_ops {
 
 };
 
-/* = Common structures and definitions ======================================= */
+/* = Common structures and definitions =======================================
+ */
 
 /* Parser states for DLE-Event:
  * <DLE-EVENT>: <DLE_FLAG> "X" <EVENT> <DLE_FLAG> "."
@@ -776,7 +774,7 @@ struct event_t *gigaset_add_event(struct cardstate *cs,
 				  void *ptr, int parameter, void *arg);
 
 /* Called on CONFIG1 command from frontend. */
-int gigaset_enterconfigmode(struct cardstate *cs); //0: success <0: errorcode
+int gigaset_enterconfigmode(struct cardstate *cs);
 
 /* cs->lock must not be locked */
 static inline void gigaset_schedule_event(struct cardstate *cs)
diff --git a/drivers/isdn/gigaset/i4l.c b/drivers/isdn/gigaset/i4l.c
index 828824f..c129ee4 100644
--- a/drivers/isdn/gigaset/i4l.c
+++ b/drivers/isdn/gigaset/i4l.c
@@ -39,12 +39,12 @@
 static int writebuf_from_LL(int driverID, int channel, int ack,
 			    struct sk_buff *skb)
 {
-	struct cardstate *cs;
+	struct cardstate *cs = gigaset_get_cs_by_id(driverID);
 	struct bc_state *bcs;
 	unsigned char *ack_header;
 	unsigned len;
 
-	if (!(cs = gigaset_get_cs_by_id(driverID))) {
+	if (!cs) {
 		pr_err("%s: invalid driver ID (%d)\n", __func__, driverID);
 		return -ENODEV;
 	}
@@ -391,22 +391,19 @@ static int command_from_LL(isdn_ctrl *cntrl)
 
 		break;
 	case ISDN_CMD_PROCEED:
-		gig_dbg(DEBUG_ANY, "ISDN_CMD_PROCEED"); //FIXME
+		gig_dbg(DEBUG_ANY, "ISDN_CMD_PROCEED");
 		break;
 	case ISDN_CMD_ALERT:
-		gig_dbg(DEBUG_ANY, "ISDN_CMD_ALERT"); //FIXME
+		gig_dbg(DEBUG_ANY, "ISDN_CMD_ALERT");
 		if (cntrl->arg >= cs->channels) {
 			dev_err(cs->dev,
 				"ISDN_CMD_ALERT: invalid channel (%d)\n",
 				(int) cntrl->arg);
 			return -EINVAL;
 		}
-		//bcs = cs->bcs + cntrl->arg;
-		//bcs->proto2 = -1;
-		// FIXME
 		break;
 	case ISDN_CMD_REDIR:
-		gig_dbg(DEBUG_ANY, "ISDN_CMD_REDIR"); //FIXME
+		gig_dbg(DEBUG_ANY, "ISDN_CMD_REDIR");
 		break;
 	case ISDN_CMD_PROT_IO:
 		gig_dbg(DEBUG_ANY, "ISDN_CMD_PROT_IO");
@@ -486,7 +483,7 @@ int gigaset_isdn_icall(struct at_state_t *at_state)
 	/* fill ICALL structure */
 	response.parm.setup.si1 = 0;	/* default: unknown */
 	response.parm.setup.si2 = 0;
-	response.parm.setup.screen = 0;	//FIXME how to set these?
+	response.parm.setup.screen = 0;
 	response.parm.setup.plan = 0;
 	if (!at_state->str_var[STR_ZBC]) {
 		/* no BC (internal call): assume speech, A-law */
@@ -507,26 +504,24 @@ int gigaset_isdn_icall(struct at_state_t *at_state)
 		return ICALL_IGNORE;
 	}
 	if (at_state->str_var[STR_NMBR]) {
-		strncpy(response.parm.setup.phone, at_state->str_var[STR_NMBR],
-			sizeof response.parm.setup.phone - 1);
-		response.parm.setup.phone[sizeof response.parm.setup.phone - 1] = 0;
+		strlcpy(response.parm.setup.phone, at_state->str_var[STR_NMBR],
+			sizeof response.parm.setup.phone);
 	} else
 		response.parm.setup.phone[0] = 0;
 	if (at_state->str_var[STR_ZCPN]) {
-		strncpy(response.parm.setup.eazmsn, at_state->str_var[STR_ZCPN],
-			sizeof response.parm.setup.eazmsn - 1);
-		response.parm.setup.eazmsn[sizeof response.parm.setup.eazmsn - 1] = 0;
+		strlcpy(response.parm.setup.eazmsn, at_state->str_var[STR_ZCPN],
+			sizeof response.parm.setup.eazmsn);
 	} else
 		response.parm.setup.eazmsn[0] = 0;
 
 	if (!bcs) {
 		dev_notice(cs->dev, "no channel for incoming call\n");
 		response.command = ISDN_STAT_ICALLW;
-		response.arg = 0; //FIXME
+		response.arg = 0;
 	} else {
 		gig_dbg(DEBUG_CMD, "Sending ICALL");
 		response.command = ISDN_STAT_ICALL;
-		response.arg = bcs->channel; //FIXME
+		response.arg = bcs->channel;
 	}
 	response.driver = cs->myid;
 	retval = iif->statcallb(&response);
diff --git a/drivers/isdn/gigaset/interface.c b/drivers/isdn/gigaset/interface.c
index 6a8e138..577809c 100644
--- a/drivers/isdn/gigaset/interface.c
+++ b/drivers/isdn/gigaset/interface.c
@@ -162,7 +162,7 @@ static int if_open(struct tty_struct *tty, struct file *filp)
 		return -ENODEV;
 
 	if (mutex_lock_interruptible(&cs->mutex))
-		return -ERESTARTSYS; // FIXME -EINTR?
+		return -ERESTARTSYS;
 	tty->driver_data = cs;
 
 	++cs->open_count;
@@ -171,7 +171,7 @@ static int if_open(struct tty_struct *tty, struct file *filp)
 		spin_lock_irqsave(&cs->lock, flags);
 		cs->tty = tty;
 		spin_unlock_irqrestore(&cs->lock, flags);
-		tty->low_latency = 1; //FIXME test
+		tty->low_latency = 1;
 	}
 
 	mutex_unlock(&cs->mutex);
@@ -228,7 +228,7 @@ static int if_ioctl(struct tty_struct *tty, struct file *file,
 	gig_dbg(DEBUG_IF, "%u: %s(0x%x)", cs->minor_index, __func__, cmd);
 
 	if (mutex_lock_interruptible(&cs->mutex))
-		return -ERESTARTSYS; // FIXME -EINTR?
+		return -ERESTARTSYS;
 
 	if (!cs->connected) {
 		gig_dbg(DEBUG_IF, "not connected");
@@ -299,9 +299,8 @@ static int if_tiocmget(struct tty_struct *tty, struct file *file)
 	gig_dbg(DEBUG_IF, "%u: %s()", cs->minor_index, __func__);
 
 	if (mutex_lock_interruptible(&cs->mutex))
-		return -ERESTARTSYS; // FIXME -EINTR?
+		return -ERESTARTSYS;
 
-	// FIXME read from device?
 	retval = cs->control_state & (TIOCM_RTS|TIOCM_DTR);
 
 	mutex_unlock(&cs->mutex);
@@ -326,7 +325,7 @@ static int if_tiocmset(struct tty_struct *tty, struct file *file,
 		cs->minor_index, __func__, set, clear);
 
 	if (mutex_lock_interruptible(&cs->mutex))
-		return -ERESTARTSYS; // FIXME -EINTR?
+		return -ERESTARTSYS;
 
 	if (!cs->connected) {
 		gig_dbg(DEBUG_IF, "not connected");
@@ -356,7 +355,7 @@ static int if_write(struct tty_struct *tty, const unsigned char *buf, int count)
 	gig_dbg(DEBUG_IF, "%u: %s()", cs->minor_index, __func__);
 
 	if (mutex_lock_interruptible(&cs->mutex))
-		return -ERESTARTSYS; // FIXME -EINTR?
+		return -ERESTARTSYS;
 
 	if (!cs->connected) {
 		gig_dbg(DEBUG_IF, "not connected");
@@ -390,7 +389,7 @@ static int if_write_room(struct tty_struct *tty)
 	gig_dbg(DEBUG_IF, "%u: %s()", cs->minor_index, __func__);
 
 	if (mutex_lock_interruptible(&cs->mutex))
-		return -ERESTARTSYS; // FIXME -EINTR?
+		return -ERESTARTSYS;
 
 	if (!cs->connected) {
 		gig_dbg(DEBUG_IF, "not connected");
@@ -455,9 +454,8 @@ static void if_throttle(struct tty_struct *tty)
 		gig_dbg(DEBUG_IF, "not connected");	/* nothing to do */
 	else if (!cs->open_count)
 		dev_warn(cs->dev, "%s: device not opened\n", __func__);
-	else {
-		//FIXME
-	}
+	else
+		gig_dbg(DEBUG_ANY, "%s: not implemented\n", __func__);
 
 	mutex_unlock(&cs->mutex);
 }
@@ -480,9 +478,8 @@ static void if_unthrottle(struct tty_struct *tty)
 		gig_dbg(DEBUG_IF, "not connected");	/* nothing to do */
 	else if (!cs->open_count)
 		dev_warn(cs->dev, "%s: device not opened\n", __func__);
-	else {
-		//FIXME
-	}
+	else
+		gig_dbg(DEBUG_ANY, "%s: not implemented\n", __func__);
 
 	mutex_unlock(&cs->mutex);
 }
@@ -515,10 +512,9 @@ static void if_set_termios(struct tty_struct *tty, struct ktermios *old)
 		goto out;
 	}
 
-	// stolen from mct_u232.c
 	iflag = tty->termios->c_iflag;
 	cflag = tty->termios->c_cflag;
-	old_cflag = old ? old->c_cflag : cflag; //FIXME?
+	old_cflag = old ? old->c_cflag : cflag;
 	gig_dbg(DEBUG_IF, "%u: iflag %x cflag %x old %x",
 		cs->minor_index, iflag, cflag, old_cflag);
 
@@ -632,7 +628,8 @@ void gigaset_if_receive(struct cardstate *cs,
 	struct tty_struct *tty;
 
 	spin_lock_irqsave(&cs->lock, flags);
-	if ((tty = cs->tty) == NULL)
+	tty = cs->tty;
+	if (tty == NULL)
 		gig_dbg(DEBUG_ANY, "receive on closed device");
 	else {
 		tty_buffer_request_room(tty, len);
@@ -659,9 +656,9 @@ void gigaset_if_initdriver(struct gigaset_driver *drv, const char *procname,
 
 	drv->have_tty = 0;
 
-	if ((drv->tty = alloc_tty_driver(minors)) == NULL)
+	drv->tty = tty = alloc_tty_driver(minors);
+	if (tty == NULL)
 		goto enomem;
-	tty = drv->tty;
 
 	tty->magic =		TTY_DRIVER_MAGIC,
 	tty->major =		GIG_MAJOR,
@@ -676,8 +673,8 @@ void gigaset_if_initdriver(struct gigaset_driver *drv, const char *procname,
 
 	tty->owner =		THIS_MODULE;
 
-	tty->init_termios          = tty_std_termios; //FIXME
-	tty->init_termios.c_cflag  = B9600 | CS8 | CREAD | HUPCL | CLOCAL; //FIXME
+	tty->init_termios          = tty_std_termios;
+	tty->init_termios.c_cflag  = B9600 | CS8 | CREAD | HUPCL | CLOCAL;
 	tty_set_operations(tty, &if_ops);
 
 	ret = tty_register_driver(tty);
diff --git a/drivers/isdn/gigaset/proc.c b/drivers/isdn/gigaset/proc.c
index 9715aad..758a00c 100644
--- a/drivers/isdn/gigaset/proc.c
+++ b/drivers/isdn/gigaset/proc.c
@@ -39,7 +39,7 @@ static ssize_t set_cidmode(struct device *dev, struct device_attribute *attr,
 			return -EINVAL;
 
 	if (mutex_lock_interruptible(&cs->mutex))
-		return -ERESTARTSYS; // FIXME -EINTR?
+		return -ERESTARTSYS;
 
 	cs->waiting = 1;
 	if (!gigaset_add_event(cs, &cs->at_state, EV_PROC_CIDMODE,
-- 
1.6.2.1.214.ge986c

From: akpm@linux-foundation.org
Subject: [patch 6/8] gigaset: use dev_ macros for messages
Date: Wed, 14 May 2008 16:19:44 -0700
Message-ID: <200805142319.m4ENJj0l026566@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, tilman@imap.cc
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34437 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754134AbYENXUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 19:20:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tilman Schmidt <tilman@imap.cc>

The info() / warn() / err() macros from usb.h for generating kernel
messages are considered inferior to dev_info() / dev_warn() / dev_err()
from device.h.  Replace them where possible.  Also correct the severity
level and improve the text of one message.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/gigaset/asyncdata.c   |    3 -
 drivers/isdn/gigaset/common.c      |    2 
 drivers/isdn/gigaset/gigaset.h     |    3 -
 drivers/isdn/gigaset/i4l.c         |   56 +++++++++++++++------------
 drivers/isdn/gigaset/interface.c   |   25 ++++++------
 drivers/isdn/gigaset/usb-gigaset.c |    7 +--
 6 files changed, 53 insertions(+), 43 deletions(-)

diff -puN drivers/isdn/gigaset/asyncdata.c~gigaset-use-dev_-macros-for-messages drivers/isdn/gigaset/asyncdata.c
--- a/drivers/isdn/gigaset/asyncdata.c~gigaset-use-dev_-macros-for-messages
+++ a/drivers/isdn/gigaset/asyncdata.c
@@ -575,7 +575,8 @@ int gigaset_m10x_send_skb(struct bc_stat
 	else
 		skb = iraw_encode(skb, HW_HDR_LEN, 0);
 	if (!skb) {
-		err("unable to allocate memory for encoding!\n");
+		dev_err(bcs->cs->dev,
+			"unable to allocate memory for encoding!\n");
 		return -ENOMEM;
 	}
 
diff -puN drivers/isdn/gigaset/common.c~gigaset-use-dev_-macros-for-messages drivers/isdn/gigaset/common.c
--- a/drivers/isdn/gigaset/common.c~gigaset-use-dev_-macros-for-messages
+++ a/drivers/isdn/gigaset/common.c
@@ -287,7 +287,7 @@ struct event_t *gigaset_add_event(struct
 	tail = cs->ev_tail;
 	next = (tail + 1) % MAX_EVENTS;
 	if (unlikely(next == cs->ev_head))
-		err("event queue full");
+		dev_err(cs->dev, "event queue full\n");
 	else {
 		event = cs->events + tail;
 		event->type = type;
diff -puN drivers/isdn/gigaset/gigaset.h~gigaset-use-dev_-macros-for-messages drivers/isdn/gigaset/gigaset.h
--- a/drivers/isdn/gigaset/gigaset.h~gigaset-use-dev_-macros-for-messages
+++ a/drivers/isdn/gigaset/gigaset.h
@@ -106,7 +106,6 @@ enum debuglevel {
 #undef err
 #undef info
 #undef warn
-#undef notice
 
 #define err(format, arg...) printk(KERN_ERR KBUILD_MODNAME ": " \
 	format "\n" , ## arg)
@@ -114,8 +113,6 @@ enum debuglevel {
 	format "\n" , ## arg)
 #define warn(format, arg...) printk(KERN_WARNING KBUILD_MODNAME ": " \
 	format "\n" , ## arg)
-#define notice(format, arg...) printk(KERN_NOTICE KBUILD_MODNAME ": " \
-	format "\n" , ## arg)
 
 #ifdef CONFIG_GIGASET_DEBUG
 
diff -puN drivers/isdn/gigaset/i4l.c~gigaset-use-dev_-macros-for-messages drivers/isdn/gigaset/i4l.c
--- a/drivers/isdn/gigaset/i4l.c~gigaset-use-dev_-macros-for-messages
+++ a/drivers/isdn/gigaset/i4l.c
@@ -46,7 +46,8 @@ static int writebuf_from_LL(int driverID
 		return -ENODEV;
 	}
 	if (channel < 0 || channel >= cs->channels) {
-		err("%s: invalid channel ID (%d)", __func__, channel);
+		dev_err(cs->dev, "%s: invalid channel ID (%d)\n",
+			__func__, channel);
 		return -ENODEV;
 	}
 	bcs = &cs->bcs[channel];
@@ -58,11 +59,13 @@ static int writebuf_from_LL(int driverID
 
 	if (!len) {
 		if (ack)
-			notice("%s: not ACKing empty packet", __func__);
+			dev_notice(cs->dev, "%s: not ACKing empty packet\n",
+				   __func__);
 		return 0;
 	}
 	if (len > MAX_BUF_SIZE) {
-		err("%s: packet too large (%d bytes)", __func__, len);
+		dev_err(cs->dev, "%s: packet too large (%d bytes)\n",
+			__func__, len);
 		return -EINVAL;
 	}
 
@@ -116,8 +119,7 @@ static int command_from_LL(isdn_ctrl *cn
 	gigaset_debugdrivers();
 
 	if (!cs) {
-		warn("LL tried to access unknown device with nr. %d",
-		     cntrl->driver);
+		err("%s: invalid driver ID (%d)", __func__, cntrl->driver);
 		return -ENODEV;
 	}
 
@@ -126,7 +128,7 @@ static int command_from_LL(isdn_ctrl *cn
 		gig_dbg(DEBUG_ANY, "ISDN_CMD_IOCTL (driver: %d, arg: %ld)",
 			cntrl->driver, cntrl->arg);
 
-		warn("ISDN_CMD_IOCTL is not supported.");
+		dev_warn(cs->dev, "ISDN_CMD_IOCTL not supported\n");
 		return -EINVAL;
 
 	case ISDN_CMD_DIAL:
@@ -138,22 +140,23 @@ static int command_from_LL(isdn_ctrl *cn
 			cntrl->parm.setup.si1, cntrl->parm.setup.si2);
 
 		if (cntrl->arg >= cs->channels) {
-			err("ISDN_CMD_DIAL: invalid channel (%d)",
-			    (int) cntrl->arg);
+			dev_err(cs->dev,
+				"ISDN_CMD_DIAL: invalid channel (%d)\n",
+				(int) cntrl->arg);
 			return -EINVAL;
 		}
 
 		bcs = cs->bcs + cntrl->arg;
 
 		if (!gigaset_get_channel(bcs)) {
-			err("ISDN_CMD_DIAL: channel not free");
+			dev_err(cs->dev, "ISDN_CMD_DIAL: channel not free\n");
 			return -EBUSY;
 		}
 
 		sp = kmalloc(sizeof *sp, GFP_ATOMIC);
 		if (!sp) {
 			gigaset_free_channel(bcs);
-			err("ISDN_CMD_DIAL: out of memory");
+			dev_err(cs->dev, "ISDN_CMD_DIAL: out of memory\n");
 			return -ENOMEM;
 		}
 		*sp = cntrl->parm.setup;
@@ -173,8 +176,9 @@ static int command_from_LL(isdn_ctrl *cn
 		gig_dbg(DEBUG_ANY, "ISDN_CMD_ACCEPTD");
 
 		if (cntrl->arg >= cs->channels) {
-			err("ISDN_CMD_ACCEPTD: invalid channel (%d)",
-			    (int) cntrl->arg);
+			dev_err(cs->dev,
+				"ISDN_CMD_ACCEPTD: invalid channel (%d)\n",
+				(int) cntrl->arg);
 			return -EINVAL;
 		}
 
@@ -196,8 +200,9 @@ static int command_from_LL(isdn_ctrl *cn
 			(int) cntrl->arg);
 
 		if (cntrl->arg >= cs->channels) {
-			err("ISDN_CMD_HANGUP: invalid channel (%u)",
-			    (unsigned) cntrl->arg);
+			dev_err(cs->dev,
+				"ISDN_CMD_HANGUP: invalid channel (%d)\n",
+				(int) cntrl->arg);
 			return -EINVAL;
 		}
 
@@ -224,8 +229,9 @@ static int command_from_LL(isdn_ctrl *cn
 			cntrl->arg & 0xff, (cntrl->arg >> 8));
 
 		if ((cntrl->arg & 0xff) >= cs->channels) {
-			err("ISDN_CMD_SETL2: invalid channel (%u)",
-			    (unsigned) cntrl->arg & 0xff);
+			dev_err(cs->dev,
+				"ISDN_CMD_SETL2: invalid channel (%d)\n",
+				(int) cntrl->arg & 0xff);
 			return -EINVAL;
 		}
 
@@ -244,14 +250,16 @@ static int command_from_LL(isdn_ctrl *cn
 			cntrl->arg & 0xff, (cntrl->arg >> 8));
 
 		if ((cntrl->arg & 0xff) >= cs->channels) {
-			err("ISDN_CMD_SETL3: invalid channel (%u)",
-			    (unsigned) cntrl->arg & 0xff);
+			dev_err(cs->dev,
+				"ISDN_CMD_SETL3: invalid channel (%d)\n",
+				(int) cntrl->arg & 0xff);
 			return -EINVAL;
 		}
 
 		if (cntrl->arg >> 8 != ISDN_PROTO_L3_TRANS) {
-			err("ISDN_CMD_SETL3: invalid protocol %lu",
-			    cntrl->arg >> 8);
+			dev_err(cs->dev,
+				"ISDN_CMD_SETL3: invalid protocol %lu\n",
+				cntrl->arg >> 8);
 			return -EINVAL;
 		}
 
@@ -262,8 +270,9 @@ static int command_from_LL(isdn_ctrl *cn
 	case ISDN_CMD_ALERT:
 		gig_dbg(DEBUG_ANY, "ISDN_CMD_ALERT"); //FIXME
 		if (cntrl->arg >= cs->channels) {
-			err("ISDN_CMD_ALERT: invalid channel (%d)",
-			    (int) cntrl->arg);
+			dev_err(cs->dev,
+				"ISDN_CMD_ALERT: invalid channel (%d)\n",
+				(int) cntrl->arg);
 			return -EINVAL;
 		}
 		//bcs = cs->bcs + cntrl->arg;
@@ -295,7 +304,8 @@ static int command_from_LL(isdn_ctrl *cn
 		gig_dbg(DEBUG_ANY, "ISDN_CMD_GETSIL");
 		break;
 	default:
-		err("unknown command %d from LL", cntrl->command);
+		dev_err(cs->dev, "unknown command %d from LL\n",
+			cntrl->command);
 		return -EINVAL;
 	}
 
diff -puN drivers/isdn/gigaset/interface.c~gigaset-use-dev_-macros-for-messages drivers/isdn/gigaset/interface.c
--- a/drivers/isdn/gigaset/interface.c~gigaset-use-dev_-macros-for-messages
+++ a/drivers/isdn/gigaset/interface.c
@@ -197,7 +197,7 @@ static void if_close(struct tty_struct *
 	mutex_lock(&cs->mutex);
 
 	if (!cs->open_count)
-		warn("%s: device not opened", __func__);
+		dev_warn(cs->dev, "%s: device not opened\n", __func__);
 	else {
 		if (!--cs->open_count) {
 			spin_lock_irqsave(&cs->lock, flags);
@@ -232,7 +232,7 @@ static int if_ioctl(struct tty_struct *t
 		return -ERESTARTSYS; // FIXME -EINTR?
 
 	if (!cs->open_count)
-		warn("%s: device not opened", __func__);
+		dev_warn(cs->dev, "%s: device not opened\n", __func__);
 	else {
 		retval = 0;
 		switch (cmd) {
@@ -364,9 +364,9 @@ static int if_write(struct tty_struct *t
 		return -ERESTARTSYS; // FIXME -EINTR?
 
 	if (!cs->open_count)
-		warn("%s: device not opened", __func__);
+		dev_warn(cs->dev, "%s: device not opened\n", __func__);
 	else if (cs->mstate != MS_LOCKED) {
-		warn("can't write to unlocked device");
+		dev_warn(cs->dev, "can't write to unlocked device\n");
 		retval = -EBUSY;
 	} else if (!cs->connected) {
 		gig_dbg(DEBUG_ANY, "can't write to unplugged device");
@@ -398,9 +398,9 @@ static int if_write_room(struct tty_stru
 		return -ERESTARTSYS; // FIXME -EINTR?
 
 	if (!cs->open_count)
-		warn("%s: device not opened", __func__);
+		dev_warn(cs->dev, "%s: device not opened\n", __func__);
 	else if (cs->mstate != MS_LOCKED) {
-		warn("can't write to unlocked device");
+		dev_warn(cs->dev, "can't write to unlocked device\n");
 		retval = -EBUSY;
 	} else if (!cs->connected) {
 		gig_dbg(DEBUG_ANY, "can't write to unplugged device");
@@ -430,9 +430,9 @@ static int if_chars_in_buffer(struct tty
 		return -ERESTARTSYS; // FIXME -EINTR?
 
 	if (!cs->open_count)
-		warn("%s: device not opened", __func__);
+		dev_warn(cs->dev, "%s: device not opened\n", __func__);
 	else if (cs->mstate != MS_LOCKED) {
-		warn("can't write to unlocked device");
+		dev_warn(cs->dev, "can't write to unlocked device\n");
 		retval = -EBUSY;
 	} else if (!cs->connected) {
 		gig_dbg(DEBUG_ANY, "can't write to unplugged device");
@@ -460,7 +460,7 @@ static void if_throttle(struct tty_struc
 	mutex_lock(&cs->mutex);
 
 	if (!cs->open_count)
-		warn("%s: device not opened", __func__);
+		dev_warn(cs->dev, "%s: device not opened\n", __func__);
 	else {
 		//FIXME
 	}
@@ -483,7 +483,7 @@ static void if_unthrottle(struct tty_str
 	mutex_lock(&cs->mutex);
 
 	if (!cs->open_count)
-		warn("%s: device not opened", __func__);
+		dev_warn(cs->dev, "%s: device not opened\n", __func__);
 	else {
 		//FIXME
 	}
@@ -510,7 +510,7 @@ static void if_set_termios(struct tty_st
 	mutex_lock(&cs->mutex);
 
 	if (!cs->open_count) {
-		warn("%s: device not opened", __func__);
+		dev_warn(cs->dev, "%s: device not opened\n", __func__);
 		goto out;
 	}
 
@@ -623,7 +623,8 @@ void gigaset_if_init(struct cardstate *c
 	if (!IS_ERR(cs->tty_dev))
 		dev_set_drvdata(cs->tty_dev, cs);
 	else {
-		warn("could not register device to the tty subsystem");
+		dev_warn(cs->dev,
+			 "could not register device to the tty subsystem\n");
 		cs->tty_dev = NULL;
 	}
 	mutex_unlock(&cs->mutex);
diff -puN drivers/isdn/gigaset/usb-gigaset.c~gigaset-use-dev_-macros-for-messages drivers/isdn/gigaset/usb-gigaset.c
--- a/drivers/isdn/gigaset/usb-gigaset.c~gigaset-use-dev_-macros-for-messages
+++ a/drivers/isdn/gigaset/usb-gigaset.c
@@ -498,8 +498,9 @@ static int send_cb(struct cardstate *cs,
 
 			if (status) {
 				ucs->busy = 0;
-				err("could not submit urb (error %d)\n",
-				    -status);
+				dev_err(cs->dev,
+					"could not submit urb (error %d)\n",
+					-status);
 				cb->len = 0; /* skip urb => remove cb+wakeup
 						in next loop cycle */
 			}
@@ -670,7 +671,7 @@ static int write_modem(struct cardstate 
 	spin_unlock_irqrestore(&cs->lock, flags);
 
 	if (ret) {
-		err("could not submit urb (error %d)\n", -ret);
+		dev_err(cs->dev, "could not submit urb (error %d)\n", -ret);
 		ucs->busy = 0;
 	}
 
_

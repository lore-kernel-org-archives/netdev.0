From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 02/11] isdn/gigaset: avoid copying AT commands twice
Date: Tue,  6 Jul 2010 02:18:43 +0200 (CEST)
Message-ID: <20100705-patch-gigaset-02.tilman@imap.cc>
References: <20100705-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100705-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change the Gigaset driver's internal write_cmd interface to accept a
cmdbuf structure instead of a string. This avoids copying formatted
AT commands a second time.

Impact: optimization
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/bas-gigaset.c |   51 +++++-------------------
 drivers/isdn/gigaset/ev-layer.c    |   75 ++++++++++++++++-------------------
 drivers/isdn/gigaset/gigaset.h     |    4 +-
 drivers/isdn/gigaset/interface.c   |   36 ++++++++++++++---
 drivers/isdn/gigaset/ser-gigaset.c |   27 ++----------
 drivers/isdn/gigaset/usb-gigaset.c |   26 ++----------
 6 files changed, 85 insertions(+), 134 deletions(-)

diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index 47a5ffe..2dab531 100644
--- a/drivers/isdn/gigaset/bas-gigaset.c
+++ b/drivers/isdn/gigaset/bas-gigaset.c
@@ -1913,65 +1913,41 @@ static int start_cbsend(struct cardstate *cs)
  * USB transmission is started if necessary.
  * parameters:
  *	cs		controller state structure
- *	buf		command string to send
- *	len		number of bytes to send (max. IF_WRITEBUF)
- *	wake_tasklet	tasklet to run when transmission is completed
- *			(NULL if none)
+ *	cb		command buffer structure
  * return value:
  *	number of bytes queued on success
  *	error code < 0 on error
  */
-static int gigaset_write_cmd(struct cardstate *cs,
-			     const unsigned char *buf, int len,
-			     struct tasklet_struct *wake_tasklet)
+static int gigaset_write_cmd(struct cardstate *cs, struct cmdbuf_t *cb)
 {
-	struct cmdbuf_t *cb;
 	unsigned long flags;
 	int rc;
 
 	gigaset_dbg_buffer(cs->mstate != MS_LOCKED ?
 			     DEBUG_TRANSCMD : DEBUG_LOCKCMD,
-			   "CMD Transmit", len, buf);
-
-	if (len <= 0) {
-		/* nothing to do */
-		rc = 0;
-		goto notqueued;
-	}
+			   "CMD Transmit", cb->len, cb->buf);
 
 	/* translate "+++" escape sequence sent as a single separate command
 	 * into "close AT channel" command for error recovery
 	 * The next command will reopen the AT channel automatically.
 	 */
-	if (len == 3 && !memcmp(buf, "+++", 3)) {
+	if (cb->len == 3 && !memcmp(cb->buf, "+++", 3)) {
+		kfree(cb);
 		rc = req_submit(cs->bcs, HD_CLOSE_ATCHANNEL, 0, BAS_TIMEOUT);
-		goto notqueued;
-	}
-
-	if (len > IF_WRITEBUF)
-		len = IF_WRITEBUF;
-	cb = kmalloc(sizeof(struct cmdbuf_t) + len, GFP_ATOMIC);
-	if (!cb) {
-		dev_err(cs->dev, "%s: out of memory\n", __func__);
-		rc = -ENOMEM;
-		goto notqueued;
+		if (cb->wake_tasklet)
+			tasklet_schedule(cb->wake_tasklet);
+		return rc < 0 ? rc : cb->len;
 	}
 
-	memcpy(cb->buf, buf, len);
-	cb->len = len;
-	cb->offset = 0;
-	cb->next = NULL;
-	cb->wake_tasklet = wake_tasklet;
-
 	spin_lock_irqsave(&cs->cmdlock, flags);
 	cb->prev = cs->lastcmdbuf;
 	if (cs->lastcmdbuf)
 		cs->lastcmdbuf->next = cb;
 	else {
 		cs->cmdbuf = cb;
-		cs->curlen = len;
+		cs->curlen = cb->len;
 	}
-	cs->cmdbytes += len;
+	cs->cmdbytes += cb->len;
 	cs->lastcmdbuf = cb;
 	spin_unlock_irqrestore(&cs->cmdlock, flags);
 
@@ -1988,12 +1964,7 @@ static int gigaset_write_cmd(struct cardstate *cs,
 	}
 	rc = start_cbsend(cs);
 	spin_unlock_irqrestore(&cs->lock, flags);
-	return rc < 0 ? rc : len;
-
-notqueued:			/* request handled without queuing */
-	if (wake_tasklet)
-		tasklet_schedule(wake_tasklet);
-	return rc;
+	return rc < 0 ? rc : cb->len;
 }
 
 /* gigaset_write_room
diff --git a/drivers/isdn/gigaset/ev-layer.c b/drivers/isdn/gigaset/ev-layer.c
index ceaef9a..0d5984a 100644
--- a/drivers/isdn/gigaset/ev-layer.c
+++ b/drivers/isdn/gigaset/ev-layer.c
@@ -797,48 +797,27 @@ static void schedule_init(struct cardstate *cs, int state)
 static void send_command(struct cardstate *cs, const char *cmd, int cid,
 			 int dle, gfp_t kmallocflags)
 {
-	size_t cmdlen, buflen;
-	char *cmdpos, *cmdbuf, *cmdtail;
+	struct cmdbuf_t *cb;
+	size_t buflen;
 
-	cmdlen = strlen(cmd);
-	buflen = 11 + cmdlen;
-	if (unlikely(buflen <= cmdlen)) {
-		dev_err(cs->dev, "integer overflow in buflen\n");
+	buflen = strlen(cmd) + 12; /* DLE ( A T 1 2 3 4 5 <cmd> DLE ) \0 */
+	cb = kmalloc(sizeof(struct cmdbuf_t) + buflen, kmallocflags);
+	if (!cb) {
+		dev_err(cs->dev, "%s: out of memory\n", __func__);
 		return;
 	}
-
-	cmdbuf = kmalloc(buflen, kmallocflags);
-	if (unlikely(!cmdbuf)) {
-		dev_err(cs->dev, "out of memory\n");
-		return;
-	}
-
-	cmdpos = cmdbuf + 9;
-	cmdtail = cmdpos + cmdlen;
-	memcpy(cmdpos, cmd, cmdlen);
-
-	if (cid > 0 && cid <= 65535) {
-		do {
-			*--cmdpos = '0' + cid % 10;
-			cid /= 10;
-			++cmdlen;
-		} while (cid);
-	}
-
-	cmdlen += 2;
-	*--cmdpos = 'T';
-	*--cmdpos = 'A';
-
-	if (dle) {
-		cmdlen += 4;
-		*--cmdpos = '(';
-		*--cmdpos = 0x10;
-		*cmdtail++ = 0x10;
-		*cmdtail++ = ')';
-	}
-
-	cs->ops->write_cmd(cs, cmdpos, cmdlen, NULL);
-	kfree(cmdbuf);
+	if (cid > 0 && cid <= 65535)
+		cb->len = snprintf(cb->buf, buflen,
+				  dle ? "\020(AT%d%s\020)" : "AT%d%s",
+				  cid, cmd);
+	else
+		cb->len = snprintf(cb->buf, buflen,
+				  dle ? "\020(AT%s\020)" : "AT%s",
+				  cmd);
+	cb->offset = 0;
+	cb->next = NULL;
+	cb->wake_tasklet = NULL;
+	cs->ops->write_cmd(cs, cb);
 }
 
 static struct at_state_t *at_state_from_cid(struct cardstate *cs, int cid)
@@ -1240,8 +1219,22 @@ static void do_action(int action, struct cardstate *cs,
 		break;
 	case ACT_HUPMODEM:
 		/* send "+++" (hangup in unimodem mode) */
-		if (cs->connected)
-			cs->ops->write_cmd(cs, "+++", 3, NULL);
+		if (cs->connected) {
+			struct cmdbuf_t *cb;
+
+			cb = kmalloc(sizeof(struct cmdbuf_t) + 3, GFP_ATOMIC);
+			if (!cb) {
+				dev_err(cs->dev, "%s: out of memory\n",
+					__func__);
+				return;
+			}
+			memcpy(cb->buf, "+++", 3);
+			cb->len = 3;
+			cb->offset = 0;
+			cb->next = NULL;
+			cb->wake_tasklet = NULL;
+			cs->ops->write_cmd(cs, cb);
+		}
 		break;
 	case ACT_RING:
 		/* get fresh AT state structure for new CID */
diff --git a/drivers/isdn/gigaset/gigaset.h b/drivers/isdn/gigaset/gigaset.h
index 8738b08..904c947 100644
--- a/drivers/isdn/gigaset/gigaset.h
+++ b/drivers/isdn/gigaset/gigaset.h
@@ -574,9 +574,7 @@ struct bas_bc_state {
 struct gigaset_ops {
 	/* Called from ev-layer.c/interface.c for sending AT commands to the
 	   device */
-	int (*write_cmd)(struct cardstate *cs,
-			 const unsigned char *buf, int len,
-			 struct tasklet_struct *wake_tasklet);
+	int (*write_cmd)(struct cardstate *cs, struct cmdbuf_t *cb);
 
 	/* Called from interface.c for additional device control */
 	int (*write_room)(struct cardstate *cs);
diff --git a/drivers/isdn/gigaset/interface.c b/drivers/isdn/gigaset/interface.c
index c9f28dd..f45d686 100644
--- a/drivers/isdn/gigaset/interface.c
+++ b/drivers/isdn/gigaset/interface.c
@@ -339,7 +339,8 @@ static int if_tiocmset(struct tty_struct *tty, struct file *file,
 static int if_write(struct tty_struct *tty, const unsigned char *buf, int count)
 {
 	struct cardstate *cs;
-	int retval = -ENODEV;
+	struct cmdbuf_t *cb;
+	int retval;
 
 	cs = (struct cardstate *) tty->driver_data;
 	if (!cs) {
@@ -355,18 +356,39 @@ static int if_write(struct tty_struct *tty, const unsigned char *buf, int count)
 	if (!cs->connected) {
 		gig_dbg(DEBUG_IF, "not connected");
 		retval = -ENODEV;
-	} else if (!cs->open_count)
+		goto done;
+	}
+	if (!cs->open_count) {
 		dev_warn(cs->dev, "%s: device not opened\n", __func__);
-	else if (cs->mstate != MS_LOCKED) {
+		retval = -ENODEV;
+		goto done;
+	}
+	if (cs->mstate != MS_LOCKED) {
 		dev_warn(cs->dev, "can't write to unlocked device\n");
 		retval = -EBUSY;
-	} else {
-		retval = cs->ops->write_cmd(cs, buf, count,
-					    &cs->if_wake_tasklet);
+		goto done;
+	}
+	if (count <= 0) {
+		/* nothing to do */
+		retval = 0;
+		goto done;
 	}
 
-	mutex_unlock(&cs->mutex);
+	cb = kmalloc(sizeof(struct cmdbuf_t) + count, GFP_KERNEL);
+	if (!cb) {
+		dev_err(cs->dev, "%s: out of memory\n", __func__);
+		retval = -ENOMEM;
+		goto done;
+	}
 
+	memcpy(cb->buf, buf, count);
+	cb->len = count;
+	cb->offset = 0;
+	cb->next = NULL;
+	cb->wake_tasklet = &cs->if_wake_tasklet;
+	retval = cs->ops->write_cmd(cs, cb);
+done:
+	mutex_unlock(&cs->mutex);
 	return retval;
 }
 
diff --git a/drivers/isdn/gigaset/ser-gigaset.c b/drivers/isdn/gigaset/ser-gigaset.c
index e96c058..d151dcb 100644
--- a/drivers/isdn/gigaset/ser-gigaset.c
+++ b/drivers/isdn/gigaset/ser-gigaset.c
@@ -241,30 +241,13 @@ static void flush_send_queue(struct cardstate *cs)
  * return value:
  *	number of bytes queued, or error code < 0
  */
-static int gigaset_write_cmd(struct cardstate *cs, const unsigned char *buf,
-			     int len, struct tasklet_struct *wake_tasklet)
+static int gigaset_write_cmd(struct cardstate *cs, struct cmdbuf_t *cb)
 {
-	struct cmdbuf_t *cb;
 	unsigned long flags;
 
 	gigaset_dbg_buffer(cs->mstate != MS_LOCKED ?
 				DEBUG_TRANSCMD : DEBUG_LOCKCMD,
-			   "CMD Transmit", len, buf);
-
-	if (len <= 0)
-		return 0;
-
-	cb = kmalloc(sizeof(struct cmdbuf_t) + len, GFP_ATOMIC);
-	if (!cb) {
-		dev_err(cs->dev, "%s: out of memory!\n", __func__);
-		return -ENOMEM;
-	}
-
-	memcpy(cb->buf, buf, len);
-	cb->len = len;
-	cb->offset = 0;
-	cb->next = NULL;
-	cb->wake_tasklet = wake_tasklet;
+			   "CMD Transmit", cb->len, cb->buf);
 
 	spin_lock_irqsave(&cs->cmdlock, flags);
 	cb->prev = cs->lastcmdbuf;
@@ -272,9 +255,9 @@ static int gigaset_write_cmd(struct cardstate *cs, const unsigned char *buf,
 		cs->lastcmdbuf->next = cb;
 	else {
 		cs->cmdbuf = cb;
-		cs->curlen = len;
+		cs->curlen = cb->len;
 	}
-	cs->cmdbytes += len;
+	cs->cmdbytes += cb->len;
 	cs->lastcmdbuf = cb;
 	spin_unlock_irqrestore(&cs->cmdlock, flags);
 
@@ -282,7 +265,7 @@ static int gigaset_write_cmd(struct cardstate *cs, const unsigned char *buf,
 	if (cs->connected)
 		tasklet_schedule(&cs->write_tasklet);
 	spin_unlock_irqrestore(&cs->lock, flags);
-	return len;
+	return cb->len;
 }
 
 /*
diff --git a/drivers/isdn/gigaset/usb-gigaset.c b/drivers/isdn/gigaset/usb-gigaset.c
index f65cf7d..4a66338 100644
--- a/drivers/isdn/gigaset/usb-gigaset.c
+++ b/drivers/isdn/gigaset/usb-gigaset.c
@@ -494,29 +494,13 @@ static int send_cb(struct cardstate *cs, struct cmdbuf_t *cb)
 }
 
 /* Send command to device. */
-static int gigaset_write_cmd(struct cardstate *cs, const unsigned char *buf,
-			     int len, struct tasklet_struct *wake_tasklet)
+static int gigaset_write_cmd(struct cardstate *cs, struct cmdbuf_t *cb)
 {
-	struct cmdbuf_t *cb;
 	unsigned long flags;
 
 	gigaset_dbg_buffer(cs->mstate != MS_LOCKED ?
 			     DEBUG_TRANSCMD : DEBUG_LOCKCMD,
-			   "CMD Transmit", len, buf);
-
-	if (len <= 0)
-		return 0;
-	cb = kmalloc(sizeof(struct cmdbuf_t) + len, GFP_ATOMIC);
-	if (!cb) {
-		dev_err(cs->dev, "%s: out of memory\n", __func__);
-		return -ENOMEM;
-	}
-
-	memcpy(cb->buf, buf, len);
-	cb->len = len;
-	cb->offset = 0;
-	cb->next = NULL;
-	cb->wake_tasklet = wake_tasklet;
+			   "CMD Transmit", cb->len, cb->buf);
 
 	spin_lock_irqsave(&cs->cmdlock, flags);
 	cb->prev = cs->lastcmdbuf;
@@ -524,9 +508,9 @@ static int gigaset_write_cmd(struct cardstate *cs, const unsigned char *buf,
 		cs->lastcmdbuf->next = cb;
 	else {
 		cs->cmdbuf = cb;
-		cs->curlen = len;
+		cs->curlen = cb->len;
 	}
-	cs->cmdbytes += len;
+	cs->cmdbytes += cb->len;
 	cs->lastcmdbuf = cb;
 	spin_unlock_irqrestore(&cs->cmdlock, flags);
 
@@ -534,7 +518,7 @@ static int gigaset_write_cmd(struct cardstate *cs, const unsigned char *buf,
 	if (cs->connected)
 		tasklet_schedule(&cs->write_tasklet);
 	spin_unlock_irqrestore(&cs->lock, flags);
-	return len;
+	return cb->len;
 }
 
 static int gigaset_write_room(struct cardstate *cs)
-- 
1.6.5.3.298.g39add

From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 2/3] gigaset: in file ops, check for device disconnect before anything else
Date: Sun,  5 Apr 2009 18:39:33 +0200 (CEST)
Message-ID: <20090404-patch-02.tilman@imap.cc>
References: <20090404-patch-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([195.227.45.7]:56704 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751531AbZDEQjv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Apr 2009 12:39:51 -0400
In-Reply-To: <20090404-patch-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the device is disconnected, the dev structure goes away, so
trying to report another error via dev_printk is bound to oops.
To avoid that, first check whether the device is still connected
and return quietly if it isn't.

Impact: error handling

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
Reported-by: Paul Bolle <pebolle@tiscali.nl>
Tested-by: Paul Bolle <pebolle@tiscali.nl>
---
 drivers/isdn/gigaset/interface.c |   58 +++++++++++++++++++------------------
 1 files changed, 30 insertions(+), 28 deletions(-)

diff --git a/drivers/isdn/gigaset/interface.c b/drivers/isdn/gigaset/interface.c
index 311e7ca..820a309 100644
--- a/drivers/isdn/gigaset/interface.c
+++ b/drivers/isdn/gigaset/interface.c
@@ -193,7 +193,9 @@ static void if_close(struct tty_struct *tty, struct file *filp)
 
 	mutex_lock(&cs->mutex);
 
-	if (!cs->open_count)
+	if (!cs->connected)
+		gig_dbg(DEBUG_IF, "not connected");	/* nothing to do */
+	else if (!cs->open_count)
 		dev_warn(cs->dev, "%s: device not opened\n", __func__);
 	else {
 		if (!--cs->open_count) {
@@ -228,7 +230,10 @@ static int if_ioctl(struct tty_struct *tty, struct file *file,
 	if (mutex_lock_interruptible(&cs->mutex))
 		return -ERESTARTSYS; // FIXME -EINTR?
 
-	if (!cs->open_count)
+	if (!cs->connected) {
+		gig_dbg(DEBUG_IF, "not connected");
+		retval = -ENODEV;
+	} else if (!cs->open_count)
 		dev_warn(cs->dev, "%s: device not opened\n", __func__);
 	else {
 		retval = 0;
@@ -248,13 +253,6 @@ static int if_ioctl(struct tty_struct *tty, struct file *file,
 				retval = put_user(int_arg, (int __user *) arg);
 			break;
 		case GIGASET_BRKCHARS:
-			//FIXME test if MS_LOCKED
-			if (!cs->connected) {
-				gig_dbg(DEBUG_ANY,
-				    "can't communicate with unplugged device");
-				retval = -ENODEV;
-				break;
-			}
 			retval = copy_from_user(&buf,
 					(const unsigned char __user *) arg, 6)
 				? -EFAULT : 0;
@@ -331,7 +329,7 @@ static int if_tiocmset(struct tty_struct *tty, struct file *file,
 		return -ERESTARTSYS; // FIXME -EINTR?
 
 	if (!cs->connected) {
-		gig_dbg(DEBUG_ANY, "can't communicate with unplugged device");
+		gig_dbg(DEBUG_IF, "not connected");
 		retval = -ENODEV;
 	} else {
 		mc = (cs->control_state | set) & ~clear & (TIOCM_RTS|TIOCM_DTR);
@@ -360,14 +358,14 @@ static int if_write(struct tty_struct *tty, const unsigned char *buf, int count)
 	if (mutex_lock_interruptible(&cs->mutex))
 		return -ERESTARTSYS; // FIXME -EINTR?
 
-	if (!cs->open_count)
+	if (!cs->connected) {
+		gig_dbg(DEBUG_IF, "not connected");
+		retval = -ENODEV;
+	} else if (!cs->open_count)
 		dev_warn(cs->dev, "%s: device not opened\n", __func__);
 	else if (cs->mstate != MS_LOCKED) {
 		dev_warn(cs->dev, "can't write to unlocked device\n");
 		retval = -EBUSY;
-	} else if (!cs->connected) {
-		gig_dbg(DEBUG_ANY, "can't write to unplugged device");
-		retval = -EBUSY; //FIXME
 	} else {
 		retval = cs->ops->write_cmd(cs, buf, count,
 					    &cs->if_wake_tasklet);
@@ -394,14 +392,14 @@ static int if_write_room(struct tty_struct *tty)
 	if (mutex_lock_interruptible(&cs->mutex))
 		return -ERESTARTSYS; // FIXME -EINTR?
 
-	if (!cs->open_count)
+	if (!cs->connected) {
+		gig_dbg(DEBUG_IF, "not connected");
+		retval = -ENODEV;
+	} else if (!cs->open_count)
 		dev_warn(cs->dev, "%s: device not opened\n", __func__);
 	else if (cs->mstate != MS_LOCKED) {
 		dev_warn(cs->dev, "can't write to unlocked device\n");
 		retval = -EBUSY;
-	} else if (!cs->connected) {
-		gig_dbg(DEBUG_ANY, "can't write to unplugged device");
-		retval = -EBUSY; //FIXME
 	} else
 		retval = cs->ops->write_room(cs);
 
@@ -426,14 +424,14 @@ static int if_chars_in_buffer(struct tty_struct *tty)
 	if (mutex_lock_interruptible(&cs->mutex))
 		return -ERESTARTSYS; // FIXME -EINTR?
 
-	if (!cs->open_count)
+	if (!cs->connected) {
+		gig_dbg(DEBUG_IF, "not connected");
+		retval = -ENODEV;
+	} else if (!cs->open_count)
 		dev_warn(cs->dev, "%s: device not opened\n", __func__);
 	else if (cs->mstate != MS_LOCKED) {
 		dev_warn(cs->dev, "can't write to unlocked device\n");
 		retval = -EBUSY;
-	} else if (!cs->connected) {
-		gig_dbg(DEBUG_ANY, "can't write to unplugged device");
-		retval = -EBUSY; //FIXME
 	} else
 		retval = cs->ops->chars_in_buffer(cs);
 
@@ -456,7 +454,9 @@ static void if_throttle(struct tty_struct *tty)
 
 	mutex_lock(&cs->mutex);
 
-	if (!cs->open_count)
+	if (!cs->connected)
+		gig_dbg(DEBUG_IF, "not connected");	/* nothing to do */
+	else if (!cs->open_count)
 		dev_warn(cs->dev, "%s: device not opened\n", __func__);
 	else {
 		//FIXME
@@ -479,7 +479,9 @@ static void if_unthrottle(struct tty_struct *tty)
 
 	mutex_lock(&cs->mutex);
 
-	if (!cs->open_count)
+	if (!cs->connected)
+		gig_dbg(DEBUG_IF, "not connected");	/* nothing to do */
+	else if (!cs->open_count)
 		dev_warn(cs->dev, "%s: device not opened\n", __func__);
 	else {
 		//FIXME
@@ -506,13 +508,13 @@ static void if_set_termios(struct tty_struct *tty, struct ktermios *old)
 
 	mutex_lock(&cs->mutex);
 
-	if (!cs->open_count) {
-		dev_warn(cs->dev, "%s: device not opened\n", __func__);
+	if (!cs->connected) {
+		gig_dbg(DEBUG_IF, "not connected");
 		goto out;
 	}
 
-	if (!cs->connected) {
-		gig_dbg(DEBUG_ANY, "can't communicate with unplugged device");
+	if (!cs->open_count) {
+		dev_warn(cs->dev, "%s: device not opened\n", __func__);
 		goto out;
 	}
 
-- 
1.6.2.1.214.ge986c


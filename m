From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 08/24] TTY: ircomm, define local tty_port
Date: Mon,  4 Jun 2012 13:35:22 +0200
Message-ID: <1338809738-18967-9-git-send-email-jslaby@suse.cz>
References: <1338809738-18967-1-git-send-email-jslaby@suse.cz>
Cc: alan@linux.intel.com, linux-kernel@vger.kernel.org,
	jirislaby@gmail.com, Samuel Ortiz <samuel@sortiz.org>,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pripojeni.net ([178.22.112.14]:45036 "EHLO
	smtp.pripojeni.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756557Ab2FDLfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 07:35:53 -0400
In-Reply-To: <1338809738-18967-1-git-send-email-jslaby@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some functions we use tty_port heavily. So let us have a local
pointer to that variable instead of having self->port all over the
code.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Samuel Ortiz <samuel@sortiz.org>
Cc: netdev@vger.kernel.org
---
 net/irda/ircomm/ircomm_tty.c |  109 ++++++++++++++++++++++--------------------
 1 file changed, 56 insertions(+), 53 deletions(-)

diff --git a/net/irda/ircomm/ircomm_tty.c b/net/irda/ircomm/ircomm_tty.c
index 03acc07..199d9cb 100644
--- a/net/irda/ircomm/ircomm_tty.c
+++ b/net/irda/ircomm/ircomm_tty.c
@@ -244,6 +244,7 @@ err:
 static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 		struct tty_struct *tty, struct file *filp)
 {
+	struct tty_port *port = &self->port;
 	DECLARE_WAITQUEUE(wait, current);
 	int		retval;
 	int		do_clocal = 0, extra_count = 0;
@@ -257,7 +258,7 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 	 */
 	if (filp->f_flags & O_NONBLOCK || tty->flags & (1 << TTY_IO_ERROR)){
 		/* nonblock mode is set or port is not enabled */
-		self->port.flags |= ASYNC_NORMAL_ACTIVE;
+		port->flags |= ASYNC_NORMAL_ACTIVE;
 		IRDA_DEBUG(1, "%s(), O_NONBLOCK requested!\n", __func__ );
 		return 0;
 	}
@@ -269,24 +270,24 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 
 	/* Wait for carrier detect and the line to become
 	 * free (i.e., not in use by the callout).  While we are in
-	 * this loop, self->port.count is dropped by one, so that
+	 * this loop, port->count is dropped by one, so that
 	 * mgsl_close() knows when to free things.  We restore it upon
 	 * exit, either normal or abnormal.
 	 */
 
 	retval = 0;
-	add_wait_queue(&self->port.open_wait, &wait);
+	add_wait_queue(&port->open_wait, &wait);
 
 	IRDA_DEBUG(2, "%s(%d):block_til_ready before block on %s open_count=%d\n",
-	      __FILE__, __LINE__, tty->driver->name, self->port.count);
+	      __FILE__, __LINE__, tty->driver->name, port->count);
 
-	spin_lock_irqsave(&self->port.lock, flags);
+	spin_lock_irqsave(&port->lock, flags);
 	if (!tty_hung_up_p(filp)) {
 		extra_count = 1;
-		self->port.count--;
+		port->count--;
 	}
-	spin_unlock_irqrestore(&self->port.lock, flags);
-	self->port.blocked_open++;
+	spin_unlock_irqrestore(&port->lock, flags);
+	port->blocked_open++;
 
 	while (1) {
 		if (tty->termios->c_cflag & CBAUD) {
@@ -302,8 +303,8 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 		current->state = TASK_INTERRUPTIBLE;
 
 		if (tty_hung_up_p(filp) ||
-		    !test_bit(ASYNCB_INITIALIZED, &self->port.flags)) {
-			retval = (self->port.flags & ASYNC_HUP_NOTIFY) ?
+		    !test_bit(ASYNCB_INITIALIZED, &port->flags)) {
+			retval = (port->flags & ASYNC_HUP_NOTIFY) ?
 					-EAGAIN : -ERESTARTSYS;
 			break;
 		}
@@ -313,7 +314,7 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 		 * specified, we cannot return before the IrCOMM link is
 		 * ready
 		 */
-		if (!test_bit(ASYNCB_CLOSING, &self->port.flags) &&
+		if (!test_bit(ASYNCB_CLOSING, &port->flags) &&
 		    (do_clocal || (self->settings.dce & IRCOMM_CD)) &&
 		    self->state == IRCOMM_TTY_READY)
 		{
@@ -326,27 +327,27 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 		}
 
 		IRDA_DEBUG(1, "%s(%d):block_til_ready blocking on %s open_count=%d\n",
-		      __FILE__, __LINE__, tty->driver->name, self->port.count);
+		      __FILE__, __LINE__, tty->driver->name, port->count);
 
 		schedule();
 	}
 
 	__set_current_state(TASK_RUNNING);
-	remove_wait_queue(&self->port.open_wait, &wait);
+	remove_wait_queue(&port->open_wait, &wait);
 
 	if (extra_count) {
 		/* ++ is not atomic, so this should be protected - Jean II */
-		spin_lock_irqsave(&self->port.lock, flags);
-		self->port.count++;
-		spin_unlock_irqrestore(&self->port.lock, flags);
+		spin_lock_irqsave(&port->lock, flags);
+		port->count++;
+		spin_unlock_irqrestore(&port->lock, flags);
 	}
-	self->port.blocked_open--;
+	port->blocked_open--;
 
 	IRDA_DEBUG(1, "%s(%d):block_til_ready after blocking on %s open_count=%d\n",
-	      __FILE__, __LINE__, tty->driver->name, self->port.count);
+	      __FILE__, __LINE__, tty->driver->name, port->count);
 
 	if (!retval)
-		self->port.flags |= ASYNC_NORMAL_ACTIVE;
+		port->flags |= ASYNC_NORMAL_ACTIVE;
 
 	return retval;
 }
@@ -484,6 +485,7 @@ static int ircomm_tty_open(struct tty_struct *tty, struct file *filp)
 static void ircomm_tty_close(struct tty_struct *tty, struct file *filp)
 {
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) tty->driver_data;
+	struct tty_port *port = &self->port;
 	unsigned long flags;
 
 	IRDA_DEBUG(0, "%s()\n", __func__ );
@@ -491,16 +493,16 @@ static void ircomm_tty_close(struct tty_struct *tty, struct file *filp)
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
 
-	spin_lock_irqsave(&self->port.lock, flags);
+	spin_lock_irqsave(&port->lock, flags);
 
 	if (tty_hung_up_p(filp)) {
-		spin_unlock_irqrestore(&self->port.lock, flags);
+		spin_unlock_irqrestore(&port->lock, flags);
 
 		IRDA_DEBUG(0, "%s(), returning 1\n", __func__ );
 		return;
 	}
 
-	if ((tty->count == 1) && (self->port.count != 1)) {
+	if ((tty->count == 1) && (port->count != 1)) {
 		/*
 		 * Uh, oh.  tty->count is 1, which means that the tty
 		 * structure will be freed.  state->count should always
@@ -510,55 +512,55 @@ static void ircomm_tty_close(struct tty_struct *tty, struct file *filp)
 		 */
 		IRDA_DEBUG(0, "%s(), bad serial port count; "
 			   "tty->count is 1, state->count is %d\n", __func__ ,
-			   self->port.count);
-		self->port.count = 1;
+			   port->count);
+		port->count = 1;
 	}
 
-	if (--self->port.count < 0) {
+	if (--port->count < 0) {
 		IRDA_ERROR("%s(), bad serial port count for ttys%d: %d\n",
-			   __func__, self->line, self->port.count);
-		self->port.count = 0;
+			   __func__, self->line, port->count);
+		port->count = 0;
 	}
-	if (self->port.count) {
-		spin_unlock_irqrestore(&self->port.lock, flags);
+	if (port->count) {
+		spin_unlock_irqrestore(&port->lock, flags);
 
 		IRDA_DEBUG(0, "%s(), open count > 0\n", __func__ );
 		return;
 	}
 
-	set_bit(ASYNCB_CLOSING, &self->port.flags);
+	set_bit(ASYNCB_CLOSING, &port->flags);
 
-	spin_unlock_irqrestore(&self->port.lock, flags);
+	spin_unlock_irqrestore(&port->lock, flags);
 
 	/*
 	 * Now we wait for the transmit buffer to clear; and we notify
 	 * the line discipline to only process XON/XOFF characters.
 	 */
 	tty->closing = 1;
-	if (self->port.closing_wait != ASYNC_CLOSING_WAIT_NONE)
-		tty_wait_until_sent_from_close(tty, self->port.closing_wait);
+	if (port->closing_wait != ASYNC_CLOSING_WAIT_NONE)
+		tty_wait_until_sent_from_close(tty, port->closing_wait);
 
 	ircomm_tty_shutdown(self);
 
 	tty_driver_flush_buffer(tty);
 	tty_ldisc_flush(tty);
 
-	spin_lock_irqsave(&self->port.lock, flags);
+	spin_lock_irqsave(&port->lock, flags);
 	tty->closing = 0;
 
-	if (self->port.blocked_open) {
-		if (self->port.close_delay) {
-			spin_unlock_irqrestore(&self->port.lock, flags);
-			schedule_timeout_interruptible(self->port.close_delay);
-			spin_lock_irqsave(&self->port.lock, flags);
+	if (port->blocked_open) {
+		if (port->close_delay) {
+			spin_unlock_irqrestore(&port->lock, flags);
+			schedule_timeout_interruptible(port->close_delay);
+			spin_lock_irqsave(&port->lock, flags);
 		}
-		wake_up_interruptible(&self->port.open_wait);
+		wake_up_interruptible(&port->open_wait);
 	}
 
-	self->port.flags &= ~(ASYNC_NORMAL_ACTIVE|ASYNC_CLOSING);
-	spin_unlock_irqrestore(&self->port.lock, flags);
-	wake_up_interruptible(&self->port.close_wait);
-	tty_port_tty_set(&self->port, NULL);
+	port->flags &= ~(ASYNC_NORMAL_ACTIVE|ASYNC_CLOSING);
+	spin_unlock_irqrestore(&port->lock, flags);
+	wake_up_interruptible(&port->close_wait);
+	tty_port_tty_set(port, NULL);
 }
 
 /*
@@ -991,6 +993,7 @@ static void ircomm_tty_shutdown(struct ircomm_tty_cb *self)
 static void ircomm_tty_hangup(struct tty_struct *tty)
 {
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) tty->driver_data;
+	struct tty_port *port = &self->port;
 	unsigned long	flags;
 
 	IRDA_DEBUG(0, "%s()\n", __func__ );
@@ -1001,17 +1004,17 @@ static void ircomm_tty_hangup(struct tty_struct *tty)
 	/* ircomm_tty_flush_buffer(tty); */
 	ircomm_tty_shutdown(self);
 
-	spin_lock_irqsave(&self->port.lock, flags);
-	self->port.flags &= ~ASYNC_NORMAL_ACTIVE;
-	if (self->port.tty) {
-		set_bit(TTY_IO_ERROR, &self->port.tty->flags);
-		tty_kref_put(self->port.tty);
+	spin_lock_irqsave(&port->lock, flags);
+	port->flags &= ~ASYNC_NORMAL_ACTIVE;
+	if (port->tty) {
+		set_bit(TTY_IO_ERROR, &port->tty->flags);
+		tty_kref_put(port->tty);
 	}
-	self->port.tty = NULL;
-	self->port.count = 0;
-	spin_unlock_irqrestore(&self->port.lock, flags);
+	port->tty = NULL;
+	port->count = 0;
+	spin_unlock_irqrestore(&port->lock, flags);
 
-	wake_up_interruptible(&self->port.open_wait);
+	wake_up_interruptible(&port->open_wait);
 }
 
 /*
-- 
1.7.10.3

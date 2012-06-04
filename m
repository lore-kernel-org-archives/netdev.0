From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 05/24] TTY: ircomm, use flags from tty_port
Date: Mon,  4 Jun 2012 13:35:19 +0200
Message-ID: <1338809738-18967-6-git-send-email-jslaby@suse.cz>
References: <1338809738-18967-1-git-send-email-jslaby@suse.cz>
Cc: alan@linux.intel.com, linux-kernel@vger.kernel.org,
	jirislaby@gmail.com, Samuel Ortiz <samuel@sortiz.org>,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1338809738-18967-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Switch to tty_port->flags. And while at it, remove redefined flags for
them.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Samuel Ortiz <samuel@sortiz.org>
Cc: netdev@vger.kernel.org
---
 include/net/irda/ircomm_tty.h       |    6 -----
 net/irda/ircomm/ircomm_tty.c        |   46 +++++++++++++++++------------------
 net/irda/ircomm/ircomm_tty_attach.c |    5 ++--
 net/irda/ircomm/ircomm_tty_ioctl.c  |   10 ++++----
 4 files changed, 31 insertions(+), 36 deletions(-)

diff --git a/include/net/irda/ircomm_tty.h b/include/net/irda/ircomm_tty.h
index 5e94bad..e4db3b5 100644
--- a/include/net/irda/ircomm_tty.h
+++ b/include/net/irda/ircomm_tty.h
@@ -52,11 +52,6 @@
 /* Same for payload size. See qos.c for the smallest max data size */
 #define IRCOMM_TTY_DATA_UNINITIALISED	(64 - IRCOMM_TTY_HDR_UNINITIALISED)
 
-/* Those are really defined in include/linux/serial.h - Jean II */
-#define ASYNC_B_INITIALIZED	31	/* Serial port was initialized */
-#define ASYNC_B_NORMAL_ACTIVE	29	/* Normal device is active */
-#define ASYNC_B_CLOSING		27	/* Serial port is closing */
-
 /*
  * IrCOMM TTY driver state
  */
@@ -81,7 +76,6 @@ struct ircomm_tty_cb {
 	LOCAL_FLOW flow;          /* IrTTP flow status */
 
 	int line;
-	unsigned long flags;
 
 	__u8 dlsap_sel;
 	__u8 slsap_sel;
diff --git a/net/irda/ircomm/ircomm_tty.c b/net/irda/ircomm/ircomm_tty.c
index 787578f..8e61026 100644
--- a/net/irda/ircomm/ircomm_tty.c
+++ b/net/irda/ircomm/ircomm_tty.c
@@ -194,7 +194,7 @@ static int ircomm_tty_startup(struct ircomm_tty_cb *self)
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return -1;);
 
 	/* Check if already open */
-	if (test_and_set_bit(ASYNC_B_INITIALIZED, &self->flags)) {
+	if (test_and_set_bit(ASYNCB_INITIALIZED, &self->port.flags)) {
 		IRDA_DEBUG(2, "%s(), already open so break out!\n", __func__ );
 		return 0;
 	}
@@ -231,7 +231,7 @@ static int ircomm_tty_startup(struct ircomm_tty_cb *self)
 
 	return 0;
 err:
-	clear_bit(ASYNC_B_INITIALIZED, &self->flags);
+	clear_bit(ASYNCB_INITIALIZED, &self->port.flags);
 	return ret;
 }
 
@@ -260,7 +260,7 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 	 */
 	if (filp->f_flags & O_NONBLOCK || tty->flags & (1 << TTY_IO_ERROR)){
 		/* nonblock mode is set or port is not enabled */
-		self->flags |= ASYNC_NORMAL_ACTIVE;
+		self->port.flags |= ASYNC_NORMAL_ACTIVE;
 		IRDA_DEBUG(1, "%s(), O_NONBLOCK requested!\n", __func__ );
 		return 0;
 	}
@@ -306,8 +306,8 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 		current->state = TASK_INTERRUPTIBLE;
 
 		if (tty_hung_up_p(filp) ||
-		    !test_bit(ASYNC_B_INITIALIZED, &self->flags)) {
-			retval = (self->flags & ASYNC_HUP_NOTIFY) ?
+		    !test_bit(ASYNCB_INITIALIZED, &self->port.flags)) {
+			retval = (self->port.flags & ASYNC_HUP_NOTIFY) ?
 					-EAGAIN : -ERESTARTSYS;
 			break;
 		}
@@ -317,7 +317,7 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 		 * specified, we cannot return before the IrCOMM link is
 		 * ready
 		 */
-		if (!test_bit(ASYNC_B_CLOSING, &self->flags) &&
+		if (!test_bit(ASYNCB_CLOSING, &self->port.flags) &&
 		    (do_clocal || (self->settings.dce & IRCOMM_CD)) &&
 		    self->state == IRCOMM_TTY_READY)
 		{
@@ -350,7 +350,7 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 	      __FILE__, __LINE__, tty->driver->name, self->port.count);
 
 	if (!retval)
-		self->flags |= ASYNC_NORMAL_ACTIVE;
+		self->port.flags |= ASYNC_NORMAL_ACTIVE;
 
 	return retval;
 }
@@ -420,13 +420,13 @@ static int ircomm_tty_open(struct tty_struct *tty, struct file *filp)
 		   self->line, self->port.count);
 
 	/* Not really used by us, but lets do it anyway */
-	self->tty->low_latency = (self->flags & ASYNC_LOW_LATENCY) ? 1 : 0;
+	tty->low_latency = (self->port.flags & ASYNC_LOW_LATENCY) ? 1 : 0;
 
 	/*
 	 * If the port is the middle of closing, bail out now
 	 */
 	if (tty_hung_up_p(filp) ||
-	    test_bit(ASYNC_B_CLOSING, &self->flags)) {
+	    test_bit(ASYNCB_CLOSING, &self->port.flags)) {
 
 		/* Hm, why are we blocking on ASYNC_CLOSING if we
 		 * do return -EAGAIN/-ERESTARTSYS below anyway?
@@ -437,14 +437,14 @@ static int ircomm_tty_open(struct tty_struct *tty, struct file *filp)
 		 */
 
 		if (wait_event_interruptible(self->port.close_wait,
-				!test_bit(ASYNC_B_CLOSING, &self->flags))) {
+				!test_bit(ASYNCB_CLOSING, &self->port.flags))) {
 			IRDA_WARNING("%s - got signal while blocking on ASYNC_CLOSING!\n",
 				     __func__);
 			return -ERESTARTSYS;
 		}
 
 #ifdef SERIAL_DO_RESTART
-		return (self->flags & ASYNC_HUP_NOTIFY) ?
+		return (self->port.flags & ASYNC_HUP_NOTIFY) ?
 			-EAGAIN : -ERESTARTSYS;
 #else
 		return -EAGAIN;
@@ -531,7 +531,7 @@ static void ircomm_tty_close(struct tty_struct *tty, struct file *filp)
 	}
 
 	/* Hum... Should be test_and_set_bit ??? - Jean II */
-	set_bit(ASYNC_B_CLOSING, &self->flags);
+	set_bit(ASYNCB_CLOSING, &self->port.flags);
 
 	/* We need to unlock here (we were unlocking at the end of this
 	 * function), because tty_wait_until_sent() may schedule.
@@ -561,7 +561,7 @@ static void ircomm_tty_close(struct tty_struct *tty, struct file *filp)
 		wake_up_interruptible(&self->port.open_wait);
 	}
 
-	self->flags &= ~(ASYNC_NORMAL_ACTIVE|ASYNC_CLOSING);
+	self->port.flags &= ~(ASYNC_NORMAL_ACTIVE|ASYNC_CLOSING);
 	wake_up_interruptible(&self->port.close_wait);
 }
 
@@ -954,7 +954,7 @@ static void ircomm_tty_shutdown(struct ircomm_tty_cb *self)
 
 	IRDA_DEBUG(0, "%s()\n", __func__ );
 
-	if (!test_and_clear_bit(ASYNC_B_INITIALIZED, &self->flags))
+	if (!test_and_clear_bit(ASYNCB_INITIALIZED, &self->port.flags))
 		return;
 
 	ircomm_tty_detach_cable(self);
@@ -1005,7 +1005,7 @@ static void ircomm_tty_hangup(struct tty_struct *tty)
 
 	/* I guess we need to lock here - Jean II */
 	spin_lock_irqsave(&self->spinlock, flags);
-	self->flags &= ~ASYNC_NORMAL_ACTIVE;
+	self->port.flags &= ~ASYNC_NORMAL_ACTIVE;
 	self->tty = NULL;
 	self->port.count = 0;
 	spin_unlock_irqrestore(&self->spinlock, flags);
@@ -1077,7 +1077,7 @@ void ircomm_tty_check_modem_status(struct ircomm_tty_cb *self)
 	if (status & IRCOMM_DCE_DELTA_ANY) {
 		/*wake_up_interruptible(&self->delta_msr_wait);*/
 	}
-	if ((self->flags & ASYNC_CHECK_CD) && (status & IRCOMM_DELTA_CD)) {
+	if ((self->port.flags & ASYNC_CHECK_CD) && (status & IRCOMM_DELTA_CD)) {
 		IRDA_DEBUG(2,
 			   "%s(), ircomm%d CD now %s...\n", __func__ , self->line,
 			   (status & IRCOMM_CD) ? "on" : "off");
@@ -1094,7 +1094,7 @@ void ircomm_tty_check_modem_status(struct ircomm_tty_cb *self)
 			return;
 		}
 	}
-	if (self->flags & ASYNC_CTS_FLOW) {
+	if (self->port.flags & ASYNC_CTS_FLOW) {
 		if (tty->hw_stopped) {
 			if (status & IRCOMM_CTS) {
 				IRDA_DEBUG(2,
@@ -1327,27 +1327,27 @@ static void ircomm_tty_line_info(struct ircomm_tty_cb *self, struct seq_file *m)
 
 	seq_puts(m, "Flags:");
 	sep = ' ';
-	if (self->flags & ASYNC_CTS_FLOW) {
+	if (self->port.flags & ASYNC_CTS_FLOW) {
 		seq_printf(m, "%cASYNC_CTS_FLOW", sep);
 		sep = '|';
 	}
-	if (self->flags & ASYNC_CHECK_CD) {
+	if (self->port.flags & ASYNC_CHECK_CD) {
 		seq_printf(m, "%cASYNC_CHECK_CD", sep);
 		sep = '|';
 	}
-	if (self->flags & ASYNC_INITIALIZED) {
+	if (self->port.flags & ASYNC_INITIALIZED) {
 		seq_printf(m, "%cASYNC_INITIALIZED", sep);
 		sep = '|';
 	}
-	if (self->flags & ASYNC_LOW_LATENCY) {
+	if (self->port.flags & ASYNC_LOW_LATENCY) {
 		seq_printf(m, "%cASYNC_LOW_LATENCY", sep);
 		sep = '|';
 	}
-	if (self->flags & ASYNC_CLOSING) {
+	if (self->port.flags & ASYNC_CLOSING) {
 		seq_printf(m, "%cASYNC_CLOSING", sep);
 		sep = '|';
 	}
-	if (self->flags & ASYNC_NORMAL_ACTIVE) {
+	if (self->port.flags & ASYNC_NORMAL_ACTIVE) {
 		seq_printf(m, "%cASYNC_NORMAL_ACTIVE", sep);
 		sep = '|';
 	}
diff --git a/net/irda/ircomm/ircomm_tty_attach.c b/net/irda/ircomm/ircomm_tty_attach.c
index bb1e935..bed311a 100644
--- a/net/irda/ircomm/ircomm_tty_attach.c
+++ b/net/irda/ircomm/ircomm_tty_attach.c
@@ -566,7 +566,8 @@ void ircomm_tty_link_established(struct ircomm_tty_cb *self)
 	 * will have to wait for the peer device (DCE) to raise the CTS
 	 * line.
 	 */
-	if ((self->flags & ASYNC_CTS_FLOW) && ((self->settings.dce & IRCOMM_CTS) == 0)) {
+	if ((self->port.flags & ASYNC_CTS_FLOW) &&
+			((self->settings.dce & IRCOMM_CTS) == 0)) {
 		IRDA_DEBUG(0, "%s(), waiting for CTS ...\n", __func__ );
 		return;
 	} else {
@@ -977,7 +978,7 @@ static int ircomm_tty_state_ready(struct ircomm_tty_cb *self,
 		ircomm_tty_next_state(self, IRCOMM_TTY_SEARCH);
 		ircomm_tty_start_watchdog_timer(self, 3*HZ);
 
-		if (self->flags & ASYNC_CHECK_CD) {
+		if (self->port.flags & ASYNC_CHECK_CD) {
 			/* Drop carrier */
 			self->settings.dce = IRCOMM_DELTA_CD;
 			ircomm_tty_check_modem_status(self);
diff --git a/net/irda/ircomm/ircomm_tty_ioctl.c b/net/irda/ircomm/ircomm_tty_ioctl.c
index a6d25e3..31b917e 100644
--- a/net/irda/ircomm/ircomm_tty_ioctl.c
+++ b/net/irda/ircomm/ircomm_tty_ioctl.c
@@ -90,19 +90,19 @@ static void ircomm_tty_change_speed(struct ircomm_tty_cb *self)
 
 	/* CTS flow control flag and modem status interrupts */
 	if (cflag & CRTSCTS) {
-		self->flags |= ASYNC_CTS_FLOW;
+		self->port.flags |= ASYNC_CTS_FLOW;
 		self->settings.flow_control |= IRCOMM_RTS_CTS_IN;
 		/* This got me. Bummer. Jean II */
 		if (self->service_type == IRCOMM_3_WIRE_RAW)
 			IRDA_WARNING("%s(), enabling RTS/CTS on link that doesn't support it (3-wire-raw)\n", __func__);
 	} else {
-		self->flags &= ~ASYNC_CTS_FLOW;
+		self->port.flags &= ~ASYNC_CTS_FLOW;
 		self->settings.flow_control &= ~IRCOMM_RTS_CTS_IN;
 	}
 	if (cflag & CLOCAL)
-		self->flags &= ~ASYNC_CHECK_CD;
+		self->port.flags &= ~ASYNC_CHECK_CD;
 	else
-		self->flags |= ASYNC_CHECK_CD;
+		self->port.flags |= ASYNC_CHECK_CD;
 #if 0
 	/*
 	 * Set up parity check flag
@@ -270,7 +270,7 @@ static int ircomm_tty_get_serial_info(struct ircomm_tty_cb *self,
 
 	memset(&info, 0, sizeof(info));
 	info.line = self->line;
-	info.flags = self->flags;
+	info.flags = self->port.flags;
 	info.baud_base = self->settings.data_rate;
 	info.close_delay = self->port.close_delay;
 	info.closing_wait = self->port.closing_wait;
-- 
1.7.10.3

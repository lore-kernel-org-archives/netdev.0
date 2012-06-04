From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 07/24] TTY: ircomm, use tty from tty_port
Date: Mon,  4 Jun 2012 13:35:21 +0200
Message-ID: <1338809738-18967-8-git-send-email-jslaby@suse.cz>
References: <1338809738-18967-1-git-send-email-jslaby@suse.cz>
Cc: alan@linux.intel.com, linux-kernel@vger.kernel.org,
	jirislaby@gmail.com, Samuel Ortiz <samuel@sortiz.org>,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1338809738-18967-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This also includes a switch to tty refcounting. It makes sure, the
code no longer can access a freed TTY struct.

Sometimes the only thing needed is to pass tty down to the callies.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Samuel Ortiz <samuel@sortiz.org>
Cc: netdev@vger.kernel.org
---
 include/net/irda/ircomm_tty.h       |    1 -
 net/irda/ircomm/ircomm_param.c      |    5 ---
 net/irda/ircomm/ircomm_tty.c        |   62 ++++++++++++++++++++++-------------
 net/irda/ircomm/ircomm_tty_attach.c |   33 ++++++++++++++-----
 net/irda/ircomm/ircomm_tty_ioctl.c  |   11 ++++---
 5 files changed, 70 insertions(+), 42 deletions(-)

diff --git a/include/net/irda/ircomm_tty.h b/include/net/irda/ircomm_tty.h
index a9027d8..80ffde3 100644
--- a/include/net/irda/ircomm_tty.h
+++ b/include/net/irda/ircomm_tty.h
@@ -62,7 +62,6 @@ struct ircomm_tty_cb {
 
 	int state;                /* Connect state */
 
-	struct tty_struct *tty;
 	struct ircomm_cb *ircomm; /* IrCOMM layer instance */
 
 	struct sk_buff *tx_skb;   /* Transmit buffer */
diff --git a/net/irda/ircomm/ircomm_param.c b/net/irda/ircomm/ircomm_param.c
index 8b915f3..3089391 100644
--- a/net/irda/ircomm/ircomm_param.c
+++ b/net/irda/ircomm/ircomm_param.c
@@ -99,7 +99,6 @@ pi_param_info_t ircomm_param_info = { pi_major_call_table, 3, 0x0f, 4 };
  */
 int ircomm_param_request(struct ircomm_tty_cb *self, __u8 pi, int flush)
 {
-	struct tty_struct *tty;
 	unsigned long flags;
 	struct sk_buff *skb;
 	int count;
@@ -109,10 +108,6 @@ int ircomm_param_request(struct ircomm_tty_cb *self, __u8 pi, int flush)
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return -1;);
 
-	tty = self->tty;
-	if (!tty)
-		return 0;
-
 	/* Make sure we don't send parameters for raw mode */
 	if (self->service_type == IRCOMM_3_WIRE_RAW)
 		return 0;
diff --git a/net/irda/ircomm/ircomm_tty.c b/net/irda/ircomm/ircomm_tty.c
index 7b2152c..03acc07 100644
--- a/net/irda/ircomm/ircomm_tty.c
+++ b/net/irda/ircomm/ircomm_tty.c
@@ -242,18 +242,15 @@ err:
  *
  */
 static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
-				      struct file *filp)
+		struct tty_struct *tty, struct file *filp)
 {
 	DECLARE_WAITQUEUE(wait, current);
 	int		retval;
 	int		do_clocal = 0, extra_count = 0;
 	unsigned long	flags;
-	struct tty_struct *tty;
 
 	IRDA_DEBUG(2, "%s()\n", __func__ );
 
-	tty = self->tty;
-
 	/*
 	 * If non-blocking mode is set, or the port is not enabled,
 	 * then make the check up front and then exit.
@@ -412,8 +409,8 @@ static int ircomm_tty_open(struct tty_struct *tty, struct file *filp)
 	self->port.count++;
 
 	tty->driver_data = self;
-	self->tty = tty;
 	spin_unlock_irqrestore(&self->port.lock, flags);
+	tty_port_tty_set(&self->port, tty);
 
 	IRDA_DEBUG(1, "%s(), %s%d, count = %d\n", __func__ , tty->driver->name,
 		   self->line, self->port.count);
@@ -467,7 +464,7 @@ static int ircomm_tty_open(struct tty_struct *tty, struct file *filp)
 	if (ret)
 		return ret;
 
-	ret = ircomm_tty_block_til_ready(self, filp);
+	ret = ircomm_tty_block_til_ready(self, tty, filp);
 	if (ret) {
 		IRDA_DEBUG(2,
 		      "%s(), returning after block_til_ready with %d\n", __func__ ,
@@ -548,7 +545,6 @@ static void ircomm_tty_close(struct tty_struct *tty, struct file *filp)
 
 	spin_lock_irqsave(&self->port.lock, flags);
 	tty->closing = 0;
-	self->tty = NULL;
 
 	if (self->port.blocked_open) {
 		if (self->port.close_delay) {
@@ -562,6 +558,7 @@ static void ircomm_tty_close(struct tty_struct *tty, struct file *filp)
 	self->port.flags &= ~(ASYNC_NORMAL_ACTIVE|ASYNC_CLOSING);
 	spin_unlock_irqrestore(&self->port.lock, flags);
 	wake_up_interruptible(&self->port.close_wait);
+	tty_port_tty_set(&self->port, NULL);
 }
 
 /*
@@ -604,7 +601,7 @@ static void ircomm_tty_do_softint(struct work_struct *work)
 	if (!self || self->magic != IRCOMM_TTY_MAGIC)
 		return;
 
-	tty = self->tty;
+	tty = tty_port_tty_get(&self->port);
 	if (!tty)
 		return;
 
@@ -625,7 +622,7 @@ static void ircomm_tty_do_softint(struct work_struct *work)
 	}
 
 	if (tty->hw_stopped)
-		return;
+		goto put;
 
 	/* Unlink transmit buffer */
 	spin_lock_irqsave(&self->spinlock, flags);
@@ -644,6 +641,8 @@ static void ircomm_tty_do_softint(struct work_struct *work)
 
 	/* Check if user (still) wants to be waken up */
 	tty_wakeup(tty);
+put:
+	tty_kref_put(tty);
 }
 
 /*
@@ -1004,7 +1003,11 @@ static void ircomm_tty_hangup(struct tty_struct *tty)
 
 	spin_lock_irqsave(&self->port.lock, flags);
 	self->port.flags &= ~ASYNC_NORMAL_ACTIVE;
-	self->tty = NULL;
+	if (self->port.tty) {
+		set_bit(TTY_IO_ERROR, &self->port.tty->flags);
+		tty_kref_put(self->port.tty);
+	}
+	self->port.tty = NULL;
 	self->port.count = 0;
 	spin_unlock_irqrestore(&self->port.lock, flags);
 
@@ -1068,7 +1071,7 @@ void ircomm_tty_check_modem_status(struct ircomm_tty_cb *self)
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
 
-	tty = self->tty;
+	tty = tty_port_tty_get(&self->port);
 
 	status = self->settings.dce;
 
@@ -1089,10 +1092,10 @@ void ircomm_tty_check_modem_status(struct ircomm_tty_cb *self)
 				tty_hangup(tty);
 
 			/* Hangup will remote the tty, so better break out */
-			return;
+			goto put;
 		}
 	}
-	if (self->port.flags & ASYNC_CTS_FLOW) {
+	if (tty && self->port.flags & ASYNC_CTS_FLOW) {
 		if (tty->hw_stopped) {
 			if (status & IRCOMM_CTS) {
 				IRDA_DEBUG(2,
@@ -1103,7 +1106,7 @@ void ircomm_tty_check_modem_status(struct ircomm_tty_cb *self)
 				wake_up_interruptible(&self->port.open_wait);
 
 				schedule_work(&self->tqueue);
-				return;
+				goto put;
 			}
 		} else {
 			if (!(status & IRCOMM_CTS)) {
@@ -1113,6 +1116,8 @@ void ircomm_tty_check_modem_status(struct ircomm_tty_cb *self)
 			}
 		}
 	}
+put:
+	tty_kref_put(tty);
 }
 
 /*
@@ -1125,6 +1130,7 @@ static int ircomm_tty_data_indication(void *instance, void *sap,
 				      struct sk_buff *skb)
 {
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) instance;
+	struct tty_struct *tty;
 
 	IRDA_DEBUG(2, "%s()\n", __func__ );
 
@@ -1132,7 +1138,8 @@ static int ircomm_tty_data_indication(void *instance, void *sap,
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return -1;);
 	IRDA_ASSERT(skb != NULL, return -1;);
 
-	if (!self->tty) {
+	tty = tty_port_tty_get(&self->port);
+	if (!tty) {
 		IRDA_DEBUG(0, "%s(), no tty!\n", __func__ );
 		return 0;
 	}
@@ -1143,7 +1150,7 @@ static int ircomm_tty_data_indication(void *instance, void *sap,
 	 * Devices like WinCE can do this, and since they don't send any
 	 * params, we can just as well declare the hardware for running.
 	 */
-	if (self->tty->hw_stopped && (self->flow == FLOW_START)) {
+	if (tty->hw_stopped && (self->flow == FLOW_START)) {
 		IRDA_DEBUG(0, "%s(), polling for line settings!\n", __func__ );
 		ircomm_param_request(self, IRCOMM_POLL, TRUE);
 
@@ -1156,8 +1163,9 @@ static int ircomm_tty_data_indication(void *instance, void *sap,
 	 * Use flip buffer functions since the code may be called from interrupt
 	 * context
 	 */
-	tty_insert_flip_string(self->tty, skb->data, skb->len);
-	tty_flip_buffer_push(self->tty);
+	tty_insert_flip_string(tty, skb->data, skb->len);
+	tty_flip_buffer_push(tty);
+	tty_kref_put(tty);
 
 	/* No need to kfree_skb - see ircomm_ttp_data_indication() */
 
@@ -1208,12 +1216,13 @@ static void ircomm_tty_flow_indication(void *instance, void *sap,
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
 
-	tty = self->tty;
+	tty = tty_port_tty_get(&self->port);
 
 	switch (cmd) {
 	case FLOW_START:
 		IRDA_DEBUG(2, "%s(), hw start!\n", __func__ );
-		tty->hw_stopped = 0;
+		if (tty)
+			tty->hw_stopped = 0;
 
 		/* ircomm_tty_do_softint will take care of the rest */
 		schedule_work(&self->tqueue);
@@ -1221,15 +1230,19 @@ static void ircomm_tty_flow_indication(void *instance, void *sap,
 	default:  /* If we get here, something is very wrong, better stop */
 	case FLOW_STOP:
 		IRDA_DEBUG(2, "%s(), hw stopped!\n", __func__ );
-		tty->hw_stopped = 1;
+		if (tty)
+			tty->hw_stopped = 1;
 		break;
 	}
+
+	tty_kref_put(tty);
 	self->flow = cmd;
 }
 
 #ifdef CONFIG_PROC_FS
 static void ircomm_tty_line_info(struct ircomm_tty_cb *self, struct seq_file *m)
 {
+	struct tty_struct *tty;
 	char sep;
 
 	seq_printf(m, "State: %s\n", ircomm_tty_state[self->state]);
@@ -1356,9 +1369,12 @@ static void ircomm_tty_line_info(struct ircomm_tty_cb *self, struct seq_file *m)
 	seq_printf(m, "Max data size: %d\n", self->max_data_size);
 	seq_printf(m, "Max header size: %d\n", self->max_header_size);
 
-	if (self->tty)
+	tty = tty_port_tty_get(&self->port);
+	if (tty) {
 		seq_printf(m, "Hardware: %s\n",
-			       self->tty->hw_stopped ? "Stopped" : "Running");
+			       tty->hw_stopped ? "Stopped" : "Running");
+		tty_kref_put(tty);
+	}
 }
 
 static int ircomm_tty_proc_show(struct seq_file *m, void *v)
diff --git a/net/irda/ircomm/ircomm_tty_attach.c b/net/irda/ircomm/ircomm_tty_attach.c
index bed311a..3ab70e7 100644
--- a/net/irda/ircomm/ircomm_tty_attach.c
+++ b/net/irda/ircomm/ircomm_tty_attach.c
@@ -130,6 +130,8 @@ static int (*state[])(struct ircomm_tty_cb *self, IRCOMM_TTY_EVENT event,
  */
 int ircomm_tty_attach_cable(struct ircomm_tty_cb *self)
 {
+	struct tty_struct *tty;
+
 	IRDA_DEBUG(0, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return -1;);
@@ -142,7 +144,11 @@ int ircomm_tty_attach_cable(struct ircomm_tty_cb *self)
 	}
 
 	/* Make sure nobody tries to write before the link is up */
-	self->tty->hw_stopped = 1;
+	tty = tty_port_tty_get(&self->port);
+	if (tty) {
+		tty->hw_stopped = 1;
+		tty_kref_put(tty);
+	}
 
 	ircomm_tty_ias_register(self);
 
@@ -398,23 +404,26 @@ void ircomm_tty_disconnect_indication(void *instance, void *sap,
 				      struct sk_buff *skb)
 {
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) instance;
+	struct tty_struct *tty;
 
 	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
 
-	if (!self->tty)
+	tty = tty_port_tty_get(&self->port);
+	if (!tty)
 		return;
 
 	/* This will stop control data transfers */
 	self->flow = FLOW_STOP;
 
 	/* Stop data transfers */
-	self->tty->hw_stopped = 1;
+	tty->hw_stopped = 1;
 
 	ircomm_tty_do_event(self, IRCOMM_TTY_DISCONNECT_INDICATION, NULL,
 			    NULL);
+	tty_kref_put(tty);
 }
 
 /*
@@ -550,12 +559,15 @@ void ircomm_tty_connect_indication(void *instance, void *sap,
  */
 void ircomm_tty_link_established(struct ircomm_tty_cb *self)
 {
+	struct tty_struct *tty;
+
 	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
 
-	if (!self->tty)
+	tty = tty_port_tty_get(&self->port);
+	if (!tty)
 		return;
 
 	del_timer(&self->watchdog_timer);
@@ -569,17 +581,19 @@ void ircomm_tty_link_established(struct ircomm_tty_cb *self)
 	if ((self->port.flags & ASYNC_CTS_FLOW) &&
 			((self->settings.dce & IRCOMM_CTS) == 0)) {
 		IRDA_DEBUG(0, "%s(), waiting for CTS ...\n", __func__ );
-		return;
+		goto put;
 	} else {
 		IRDA_DEBUG(1, "%s(), starting hardware!\n", __func__ );
 
-		self->tty->hw_stopped = 0;
+		tty->hw_stopped = 0;
 
 		/* Wake up processes blocked on open */
 		wake_up_interruptible(&self->port.open_wait);
 	}
 
 	schedule_work(&self->tqueue);
+put:
+	tty_kref_put(tty);
 }
 
 /*
@@ -983,9 +997,12 @@ static int ircomm_tty_state_ready(struct ircomm_tty_cb *self,
 			self->settings.dce = IRCOMM_DELTA_CD;
 			ircomm_tty_check_modem_status(self);
 		} else {
+			struct tty_struct *tty = tty_port_tty_get(&self->port);
 			IRDA_DEBUG(0, "%s(), hanging up!\n", __func__ );
-			if (self->tty)
-				tty_hangup(self->tty);
+			if (tty) {
+				tty_hangup(tty);
+				tty_kref_put(tty);
+			}
 		}
 		break;
 	default:
diff --git a/net/irda/ircomm/ircomm_tty_ioctl.c b/net/irda/ircomm/ircomm_tty_ioctl.c
index 31b917e..0eab650 100644
--- a/net/irda/ircomm/ircomm_tty_ioctl.c
+++ b/net/irda/ircomm/ircomm_tty_ioctl.c
@@ -52,17 +52,18 @@
  *    Change speed of the driver. If the remote device is a DCE, then this
  *    should make it change the speed of its serial port
  */
-static void ircomm_tty_change_speed(struct ircomm_tty_cb *self)
+static void ircomm_tty_change_speed(struct ircomm_tty_cb *self,
+		struct tty_struct *tty)
 {
 	unsigned int cflag, cval;
 	int baud;
 
 	IRDA_DEBUG(2, "%s()\n", __func__ );
 
-	if (!self->tty || !self->tty->termios || !self->ircomm)
+	if (!self->ircomm)
 		return;
 
-	cflag = self->tty->termios->c_cflag;
+	cflag = tty->termios->c_cflag;
 
 	/*  byte size and parity */
 	switch (cflag & CSIZE) {
@@ -81,7 +82,7 @@ static void ircomm_tty_change_speed(struct ircomm_tty_cb *self)
 		cval |= IRCOMM_PARITY_EVEN;
 
 	/* Determine divisor based on baud rate */
-	baud = tty_get_baud_rate(self->tty);
+	baud = tty_get_baud_rate(tty);
 	if (!baud)
 		baud = 9600;	/* B0 transition handled in rs_set_termios */
 
@@ -159,7 +160,7 @@ void ircomm_tty_set_termios(struct tty_struct *tty,
 		return;
 	}
 
-	ircomm_tty_change_speed(self);
+	ircomm_tty_change_speed(self, tty);
 
 	/* Handle transition to B0 status */
 	if ((old_termios->c_cflag & CBAUD) &&
-- 
1.7.10.3

From: Peter Hurley <peter@hurleysoftware.com>
Subject: [PATCH 3/4] tty: Abstract and encapsulate tty->closing behavior
Date: Sun,  8 Nov 2015 17:02:52 -0500
Message-ID: <1447020173-32207-4-git-send-email-peter@hurleysoftware.com>
References: <1447020173-32207-1-git-send-email-peter@hurleysoftware.com>
Cc: Jiri Slaby <jslaby@suse.cz>, linux-kernel@vger.kernel.org,
	linux-serial@vger.kernel.org, netdev@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Jesper Nilsson <jesper.nilsson@axis.com>,
	Mikael Starvik <starvik@axis.com>,
	Jiri Kosina <jikos@kernel.org>,
	David Sterba <dsterba@suse.com>,
	Mark Hounschell <markh@compro.net>,
	Peter Hurley <peter@hurleysoftware.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447020173-32207-1-git-send-email-peter@hurleysoftware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tty->closing is exclusively used to cause the N_TTY line discipline
to drop further input on final tty close (except XON/XOFF output flow
control changes). In turn, this prevents the line discipline from
generating new tty driver i/o requests (eg., when echoing) after the tty
driver has performed h/w shutdown.

Abstract this notification with new ldisc api function,
tty_ldisc_closing(), which invokes the new line discipline method,
ops->closing(). Define this method for N_TTY line discipline and
localize closing state to n_tty private data. Remove tty->closing.

Note that resetting tty->closing to 0 (and thus allowing the
line discipline to resume normal input processing) is unnecessary
and undesirable: since the tty is in final close, both the line
discipline instance and the tty are being destroyed, so resuming normal
input processing after h/w shutdown is counter-productive.

NB: ipwireless_tty_free() is completely bogus; freeing the tty (?!) with
open, in-use file descriptors is laughable.

Signed-off-by: Peter Hurley <peter@hurleysoftware.com>
---
 drivers/isdn/i4l/isdn_tty.c      |  2 +-
 drivers/s390/char/con3215.c      |  3 +--
 drivers/staging/dgap/dgap.c      |  4 +---
 drivers/staging/dgnc/dgnc_tty.c  |  4 +---
 drivers/tty/hvc/hvsi.c           |  2 +-
 drivers/tty/ipwireless/tty.c     |  1 -
 drivers/tty/n_tty.c              | 13 +++++++++++--
 drivers/tty/rocket.c             |  1 -
 drivers/tty/serial/68328serial.c |  3 +--
 drivers/tty/serial/crisv10.c     |  3 +--
 drivers/tty/serial/serial_core.c |  1 -
 drivers/tty/tty_ldisc.c          | 19 +++++++++++++++++++
 drivers/tty/tty_port.c           |  3 +--
 include/linux/tty.h              |  2 +-
 include/linux/tty_ldisc.h        |  9 +++++++++
 15 files changed, 48 insertions(+), 22 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_tty.c b/drivers/isdn/i4l/isdn_tty.c
index 2175225..cddba25 100644
--- a/drivers/isdn/i4l/isdn_tty.c
+++ b/drivers/isdn/i4l/isdn_tty.c
@@ -1574,7 +1574,7 @@ isdn_tty_close(struct tty_struct *tty, struct file *filp)
 	}
 	port->flags |= ASYNC_CLOSING;
 
-	tty->closing = 1;
+	tty_ldisc_closing(tty);
 	/*
 	 * At this point we stop accepting input.  To do this, we
 	 * disable the receive line status interrupts, and tell the
diff --git a/drivers/s390/char/con3215.c b/drivers/s390/char/con3215.c
index 0fc3fe5..715251d 100644
--- a/drivers/s390/char/con3215.c
+++ b/drivers/s390/char/con3215.c
@@ -1006,11 +1006,10 @@ static void tty3215_close(struct tty_struct *tty, struct file * filp)
 	raw = (struct raw3215_info *) tty->driver_data;
 	if (raw == NULL || tty->count > 1)
 		return;
-	tty->closing = 1;
+	tty_ldisc_closing(tty);
 	/* Shutdown the terminal */
 	raw3215_shutdown(raw);
 	tasklet_kill(&raw->tlet);
-	tty->closing = 0;
 	tty_port_tty_set(&raw->port, NULL);
 }
 
diff --git a/drivers/staging/dgap/dgap.c b/drivers/staging/dgap/dgap.c
index 9112dd2..0456e28 100644
--- a/drivers/staging/dgap/dgap.c
+++ b/drivers/staging/dgap/dgap.c
@@ -4622,7 +4622,7 @@ static void dgap_tty_close(struct tty_struct *tty, struct file *file)
 
 	un->un_flags |= UN_CLOSING;
 
-	tty->closing = 1;
+	tty_ldisc_closing(tty);
 
 	/*
 	 * Only officially close channel if count is 0 and
@@ -4645,8 +4645,6 @@ static void dgap_tty_close(struct tty_struct *tty, struct file *file)
 
 		spin_lock_irqsave(&ch->ch_lock, lock_flags);
 
-		tty->closing = 0;
-
 		/*
 		 * If we have HUPCL set, lower DTR and RTS
 		 */
diff --git a/drivers/staging/dgnc/dgnc_tty.c b/drivers/staging/dgnc/dgnc_tty.c
index fbfe79a..96960d8 100644
--- a/drivers/staging/dgnc/dgnc_tty.c
+++ b/drivers/staging/dgnc/dgnc_tty.c
@@ -1410,7 +1410,7 @@ static void dgnc_tty_close(struct tty_struct *tty, struct file *file)
 	/* OK, its the last close on the unit */
 	un->un_flags |= UN_CLOSING;
 
-	tty->closing = 1;
+	tty_ldisc_closing(tty);
 
 
 	/*
@@ -1441,8 +1441,6 @@ static void dgnc_tty_close(struct tty_struct *tty, struct file *file)
 
 		spin_lock_irqsave(&ch->ch_lock, flags);
 
-		tty->closing = 0;
-
 		/*
 		 * If we have HUPCL set, lower DTR and RTS
 		 */
diff --git a/drivers/tty/hvc/hvsi.c b/drivers/tty/hvc/hvsi.c
index a75146f..fbaa6ab 100644
--- a/drivers/tty/hvc/hvsi.c
+++ b/drivers/tty/hvc/hvsi.c
@@ -796,7 +796,7 @@ static void hvsi_close(struct tty_struct *tty, struct file *filp)
 			 * any data delivered to the tty layer after this will be
 			 * discarded (except for XON/XOFF)
 			 */
-			tty->closing = 1;
+			tty_ldisc_closing(tty);
 
 			spin_unlock_irqrestore(&hp->lock, flags);
 
diff --git a/drivers/tty/ipwireless/tty.c b/drivers/tty/ipwireless/tty.c
index 345cebb..2ed8831 100644
--- a/drivers/tty/ipwireless/tty.c
+++ b/drivers/tty/ipwireless/tty.c
@@ -536,7 +536,6 @@ void ipwireless_tty_free(struct ipw_tty *tty)
 				printk(KERN_INFO IPWIRELESS_PCCARD_NAME
 				       ": deregistering %s device ttyIPWp%d\n",
 				       tty_type_name(ttyj->tty_type), j);
-			ttyj->closing = 1;
 			if (ttyj->port.tty != NULL) {
 				mutex_unlock(&ttyj->ipw_tty_mutex);
 				tty_vhangup(ttyj->port.tty);
diff --git a/drivers/tty/n_tty.c b/drivers/tty/n_tty.c
index 2de0283..6342b37 100644
--- a/drivers/tty/n_tty.c
+++ b/drivers/tty/n_tty.c
@@ -114,6 +114,7 @@ struct n_tty_data {
 	unsigned char echo_buf[N_TTY_BUF_SIZE];
 
 	int minimum_to_wake;
+	int closing;
 
 	/* consumer-published */
 	size_t read_tail;
@@ -1637,7 +1638,7 @@ static void __receive_buf(struct tty_struct *tty, const unsigned char *cp,
 		n_tty_receive_buf_real_raw(tty, cp, fp, count);
 	else if (ldata->raw || (L_EXTPROC(tty) && !preops))
 		n_tty_receive_buf_raw(tty, cp, fp, count);
-	else if (tty->closing && !L_EXTPROC(tty))
+	else if (ldata->closing && !L_EXTPROC(tty))
 		n_tty_receive_buf_closing(tty, cp, fp, count);
 	else {
 		if (ldata->lnext) {
@@ -1942,7 +1943,7 @@ static int n_tty_open(struct tty_struct *tty)
 	ldata->num_overrun = 0;
 	ldata->no_room = 0;
 	ldata->lnext = 0;
-	tty->closing = 0;
+	ldata->closing = 0;
 	/* indicate buffer work may resume */
 	clear_bit(TTY_LDISC_HALTED, &tty->flags);
 	n_tty_set_termios(tty, NULL);
@@ -2525,6 +2526,13 @@ static void n_tty_fasync(struct tty_struct *tty, int on)
 	}
 }
 
+static void n_tty_closing(struct tty_struct *tty)
+{
+	struct n_tty_data *ldata = tty->disc_data;
+
+	ldata->closing = 1;
+}
+
 struct tty_ldisc_ops tty_ldisc_N_TTY = {
 	.magic           = TTY_LDISC_MAGIC,
 	.name            = "n_tty",
@@ -2541,6 +2549,7 @@ struct tty_ldisc_ops tty_ldisc_N_TTY = {
 	.write_wakeup    = n_tty_write_wakeup,
 	.fasync		 = n_tty_fasync,
 	.receive_buf2	 = n_tty_receive_buf2,
+	.closing	 = n_tty_closing,
 };
 
 /**
diff --git a/drivers/tty/rocket.c b/drivers/tty/rocket.c
index c5179f8..a6b5ce0 100644
--- a/drivers/tty/rocket.c
+++ b/drivers/tty/rocket.c
@@ -1043,7 +1043,6 @@ static void rp_close(struct tty_struct *tty, struct file *filp)
 	}
 	spin_lock_irq(&port->lock);
 	info->port.flags &= ~(ASYNC_INITIALIZED | ASYNC_CLOSING | ASYNC_NORMAL_ACTIVE);
-	tty->closing = 0;
 	spin_unlock_irq(&port->lock);
 	mutex_unlock(&port->mutex);
 	tty_port_tty_set(port, NULL);
diff --git a/drivers/tty/serial/68328serial.c b/drivers/tty/serial/68328serial.c
index 0140ba4..9a6aaf0 100644
--- a/drivers/tty/serial/68328serial.c
+++ b/drivers/tty/serial/68328serial.c
@@ -1035,7 +1035,7 @@ static void rs_close(struct tty_struct *tty, struct file * filp)
 	 * Now we wait for the transmit buffer to clear; and we notify 
 	 * the line discipline to only process XON/XOFF characters.
 	 */
-	tty->closing = 1;
+	tty_ldisc_closing(tty);
 	if (port->closing_wait != ASYNC_CLOSING_WAIT_NONE)
 		tty_wait_until_sent(tty, port->closing_wait);
 	/*
@@ -1052,7 +1052,6 @@ static void rs_close(struct tty_struct *tty, struct file * filp)
 	rs_flush_buffer(tty);
 		
 	tty_ldisc_flush(tty);
-	tty->closing = 0;
 	tty_port_tty_set(&info->tport, NULL);
 #warning "This is not and has never been valid so fix it"	
 #if 0
diff --git a/drivers/tty/serial/crisv10.c b/drivers/tty/serial/crisv10.c
index f13f2eb..0100410 100644
--- a/drivers/tty/serial/crisv10.c
+++ b/drivers/tty/serial/crisv10.c
@@ -3620,7 +3620,7 @@ rs_close(struct tty_struct *tty, struct file * filp)
 	 * Now we wait for the transmit buffer to clear; and we notify
 	 * the line discipline to only process XON/XOFF characters.
 	 */
-	tty->closing = 1;
+	tty_ldisc_closing(tty);
 	if (info->port.closing_wait != ASYNC_CLOSING_WAIT_NONE)
 		tty_wait_until_sent(tty, info->port.closing_wait);
 	/*
@@ -3646,7 +3646,6 @@ rs_close(struct tty_struct *tty, struct file * filp)
 	shutdown(info);
 	rs_flush_buffer(tty);
 	tty_ldisc_flush(tty);
-	tty->closing = 0;
 	info->event = 0;
 	info->port.tty = NULL;
 	if (info->port.blocked_open) {
diff --git a/drivers/tty/serial/serial_core.c b/drivers/tty/serial/serial_core.c
index def5199..db27a40 100644
--- a/drivers/tty/serial/serial_core.c
+++ b/drivers/tty/serial/serial_core.c
@@ -1441,7 +1441,6 @@ static void uart_close(struct tty_struct *tty, struct file *filp)
 	mutex_unlock(&port->mutex);
 
 	tty_ldisc_flush(tty);
-	tty->closing = 0;
 }
 
 static void uart_wait_until_sent(struct tty_struct *tty, int timeout)
diff --git a/drivers/tty/tty_ldisc.c b/drivers/tty/tty_ldisc.c
index b776f2e..ef6af5f 100644
--- a/drivers/tty/tty_ldisc.c
+++ b/drivers/tty/tty_ldisc.c
@@ -407,6 +407,25 @@ void tty_ldisc_flush(struct tty_struct *tty)
 EXPORT_SYMBOL_GPL(tty_ldisc_flush);
 
 /**
+ *	tty_ldisc_closing	-	notify line discipline of final close
+ *	@tty: tty
+ *
+ *	Notify the line discipline the driver has begun final close of the tty.
+ *	The N_TTY line discipline uses this notification to ignore new input
+ */
+
+void tty_ldisc_closing(struct tty_struct *tty)
+{
+	struct tty_ldisc *ld = tty_ldisc_ref(tty);
+
+	if (ld->ops->closing)
+		ld->ops->closing(tty);
+	if (ld)
+		tty_ldisc_deref(ld);
+}
+EXPORT_SYMBOL_GPL(tty_ldisc_closing);
+
+/**
  *	tty_set_termios_ldisc		-	set ldisc field
  *	@tty: tty structure
  *	@num: line discipline number
diff --git a/drivers/tty/tty_port.c b/drivers/tty/tty_port.c
index a76aec2..ecb6435 100644
--- a/drivers/tty/tty_port.c
+++ b/drivers/tty/tty_port.c
@@ -479,7 +479,7 @@ int tty_port_close_start(struct tty_port *port,
 	set_bit(ASYNCB_CLOSING, &port->flags);
 	spin_unlock_irqrestore(&port->lock, flags);
 
-	tty->closing = 1;
+	tty_ldisc_closing(tty);
 
 	if (test_bit(ASYNCB_INITIALIZED, &port->flags)) {
 		/* Don't block on a stalled port, just pull the chain */
@@ -504,7 +504,6 @@ void tty_port_close_end(struct tty_port *port, struct tty_struct *tty)
 	unsigned long flags;
 
 	tty_ldisc_flush(tty);
-	tty->closing = 0;
 
 	spin_lock_irqsave(&port->lock, flags);
 
diff --git a/include/linux/tty.h b/include/linux/tty.h
index 4b6c62e..70f3a9c1 100644
--- a/include/linux/tty.h
+++ b/include/linux/tty.h
@@ -306,7 +306,6 @@ struct tty_struct {
 
 #define N_TTY_BUF_SIZE 4096
 
-	int closing;
 	unsigned char *write_buf;
 	int write_cnt;
 	/* If the tty has a pending do_SAK, queue it here - akpm */
@@ -498,6 +497,7 @@ extern const struct file_operations tty_ldiscs_proc_fops;
 
 extern void tty_wakeup(struct tty_struct *tty);
 extern void tty_ldisc_flush(struct tty_struct *tty);
+extern void tty_ldisc_closing(struct tty_struct *tty);
 
 extern long tty_ioctl(struct file *file, unsigned int cmd, unsigned long arg);
 extern int tty_mode_ioctl(struct tty_struct *tty, struct file *file,
diff --git a/include/linux/tty_ldisc.h b/include/linux/tty_ldisc.h
index 00c9d68..0f3b19f 100644
--- a/include/linux/tty_ldisc.h
+++ b/include/linux/tty_ldisc.h
@@ -125,6 +125,14 @@
  *	received with a parity error, etc. <fp> may be NULL to indicate
  *	all data received is TTY_NORMAL.
  *	If assigned, prefer this function for automatic flow control.
+ *
+ * void	(*closing)(struct tty_struct *);
+ *
+ *	This function notifies the line discipline the driver is
+ *	starting final close for this tty; tty and ldisc destruction
+ *	is imminent. The N_TTY line discipline uses this notification
+ *	to ignore new input other than IXON flow control changes.
+ *	This notification is not received for ptys or vts.
  */
 
 #include <linux/fs.h>
@@ -212,6 +220,7 @@ struct tty_ldisc_ops {
 	void	(*fasync)(struct tty_struct *tty, int on);
 	int	(*receive_buf2)(struct tty_struct *, const unsigned char *cp,
 				char *fp, int count);
+	void	(*closing)(struct tty_struct *tty);
 
 	struct  module *owner;
 
-- 
2.6.3

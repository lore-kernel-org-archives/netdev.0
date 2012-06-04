From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 04/24] TTY: ircomm, use open counts from tty_port
Date: Mon,  4 Jun 2012 13:35:18 +0200
Message-ID: <1338809738-18967-5-git-send-email-jslaby@suse.cz>
References: <1338809738-18967-1-git-send-email-jslaby@suse.cz>
Cc: alan@linux.intel.com, linux-kernel@vger.kernel.org,
	jirislaby@gmail.com, Samuel Ortiz <samuel@sortiz.org>,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1338809738-18967-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Switch to tty_port->count and blocked_open.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Samuel Ortiz <samuel@sortiz.org>
Cc: netdev@vger.kernel.org
---
 include/net/irda/ircomm_tty.h |    3 ---
 net/irda/ircomm/ircomm_tty.c  |   42 ++++++++++++++++++++---------------------
 2 files changed, 21 insertions(+), 24 deletions(-)

diff --git a/include/net/irda/ircomm_tty.h b/include/net/irda/ircomm_tty.h
index b4184d0..5e94bad 100644
--- a/include/net/irda/ircomm_tty.h
+++ b/include/net/irda/ircomm_tty.h
@@ -101,9 +101,6 @@ struct ircomm_tty_cb {
 	struct timer_list watchdog_timer;
 	struct work_struct  tqueue;
 
-	int  open_count;
-	int  blocked_open;	/* # of blocked opens */
-
 	/* Protect concurent access to :
 	 *	o self->open_count
 	 *	o self->ctrl_skb
diff --git a/net/irda/ircomm/ircomm_tty.c b/net/irda/ircomm/ircomm_tty.c
index 61e0adc..787578f 100644
--- a/net/irda/ircomm/ircomm_tty.c
+++ b/net/irda/ircomm/ircomm_tty.c
@@ -272,7 +272,7 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 
 	/* Wait for carrier detect and the line to become
 	 * free (i.e., not in use by the callout).  While we are in
-	 * this loop, self->open_count is dropped by one, so that
+	 * this loop, self->port.count is dropped by one, so that
 	 * mgsl_close() knows when to free things.  We restore it upon
 	 * exit, either normal or abnormal.
 	 */
@@ -281,16 +281,16 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 	add_wait_queue(&self->port.open_wait, &wait);
 
 	IRDA_DEBUG(2, "%s(%d):block_til_ready before block on %s open_count=%d\n",
-	      __FILE__,__LINE__, tty->driver->name, self->open_count );
+	      __FILE__, __LINE__, tty->driver->name, self->port.count);
 
-	/* As far as I can see, we protect open_count - Jean II */
+	/* As far as I can see, we protect port.count - Jean II */
 	spin_lock_irqsave(&self->spinlock, flags);
 	if (!tty_hung_up_p(filp)) {
 		extra_count = 1;
-		self->open_count--;
+		self->port.count--;
 	}
 	spin_unlock_irqrestore(&self->spinlock, flags);
-	self->blocked_open++;
+	self->port.blocked_open++;
 
 	while (1) {
 		if (tty->termios->c_cflag & CBAUD) {
@@ -330,7 +330,7 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 		}
 
 		IRDA_DEBUG(1, "%s(%d):block_til_ready blocking on %s open_count=%d\n",
-		      __FILE__,__LINE__, tty->driver->name, self->open_count );
+		      __FILE__, __LINE__, tty->driver->name, self->port.count);
 
 		schedule();
 	}
@@ -341,13 +341,13 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 	if (extra_count) {
 		/* ++ is not atomic, so this should be protected - Jean II */
 		spin_lock_irqsave(&self->spinlock, flags);
-		self->open_count++;
+		self->port.count++;
 		spin_unlock_irqrestore(&self->spinlock, flags);
 	}
-	self->blocked_open--;
+	self->port.blocked_open--;
 
 	IRDA_DEBUG(1, "%s(%d):block_til_ready after blocking on %s open_count=%d\n",
-	      __FILE__,__LINE__, tty->driver->name, self->open_count);
+	      __FILE__, __LINE__, tty->driver->name, self->port.count);
 
 	if (!retval)
 		self->flags |= ASYNC_NORMAL_ACTIVE;
@@ -410,14 +410,14 @@ static int ircomm_tty_open(struct tty_struct *tty, struct file *filp)
 	}
 	/* ++ is not atomic, so this should be protected - Jean II */
 	spin_lock_irqsave(&self->spinlock, flags);
-	self->open_count++;
+	self->port.count++;
 
 	tty->driver_data = self;
 	self->tty = tty;
 	spin_unlock_irqrestore(&self->spinlock, flags);
 
 	IRDA_DEBUG(1, "%s(), %s%d, count = %d\n", __func__ , tty->driver->name,
-		   self->line, self->open_count);
+		   self->line, self->port.count);
 
 	/* Not really used by us, but lets do it anyway */
 	self->tty->low_latency = (self->flags & ASYNC_LOW_LATENCY) ? 1 : 0;
@@ -504,7 +504,7 @@ static void ircomm_tty_close(struct tty_struct *tty, struct file *filp)
 		return;
 	}
 
-	if ((tty->count == 1) && (self->open_count != 1)) {
+	if ((tty->count == 1) && (self->port.count != 1)) {
 		/*
 		 * Uh, oh.  tty->count is 1, which means that the tty
 		 * structure will be freed.  state->count should always
@@ -514,16 +514,16 @@ static void ircomm_tty_close(struct tty_struct *tty, struct file *filp)
 		 */
 		IRDA_DEBUG(0, "%s(), bad serial port count; "
 			   "tty->count is 1, state->count is %d\n", __func__ ,
-			   self->open_count);
-		self->open_count = 1;
+			   self->port.count);
+		self->port.count = 1;
 	}
 
-	if (--self->open_count < 0) {
+	if (--self->port.count < 0) {
 		IRDA_ERROR("%s(), bad serial port count for ttys%d: %d\n",
-			   __func__, self->line, self->open_count);
-		self->open_count = 0;
+			   __func__, self->line, self->port.count);
+		self->port.count = 0;
 	}
-	if (self->open_count) {
+	if (self->port.count) {
 		spin_unlock_irqrestore(&self->spinlock, flags);
 
 		IRDA_DEBUG(0, "%s(), open count > 0\n", __func__ );
@@ -555,7 +555,7 @@ static void ircomm_tty_close(struct tty_struct *tty, struct file *filp)
 	tty->closing = 0;
 	self->tty = NULL;
 
-	if (self->blocked_open) {
+	if (self->port.blocked_open) {
 		if (self->port.close_delay)
 			schedule_timeout_interruptible(self->port.close_delay);
 		wake_up_interruptible(&self->port.open_wait);
@@ -1007,7 +1007,7 @@ static void ircomm_tty_hangup(struct tty_struct *tty)
 	spin_lock_irqsave(&self->spinlock, flags);
 	self->flags &= ~ASYNC_NORMAL_ACTIVE;
 	self->tty = NULL;
-	self->open_count = 0;
+	self->port.count = 0;
 	spin_unlock_irqrestore(&self->spinlock, flags);
 
 	wake_up_interruptible(&self->port.open_wait);
@@ -1354,7 +1354,7 @@ static void ircomm_tty_line_info(struct ircomm_tty_cb *self, struct seq_file *m)
 	seq_putc(m, '\n');
 
 	seq_printf(m, "Role: %s\n", self->client ? "client" : "server");
-	seq_printf(m, "Open count: %d\n", self->open_count);
+	seq_printf(m, "Open count: %d\n", self->port.count);
 	seq_printf(m, "Max data size: %d\n", self->max_data_size);
 	seq_printf(m, "Max header size: %d\n", self->max_header_size);
 
-- 
1.7.10.3

From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 02/24] TTY: ircomm, add tty_port
Date: Mon,  4 Jun 2012 13:35:16 +0200
Message-ID: <1338809738-18967-3-git-send-email-jslaby@suse.cz>
References: <1338809738-18967-1-git-send-email-jslaby@suse.cz>
Cc: alan@linux.intel.com, linux-kernel@vger.kernel.org,
	jirislaby@gmail.com, Samuel Ortiz <samuel@sortiz.org>,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1338809738-18967-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

And use close/open_wait from there.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Samuel Ortiz <samuel@sortiz.org>
Cc: netdev@vger.kernel.org
---
 include/net/irda/ircomm_tty.h       |    3 +--
 net/irda/ircomm/ircomm_tty.c        |   21 +++++++++++----------
 net/irda/ircomm/ircomm_tty_attach.c |    2 +-
 3 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/net/irda/ircomm_tty.h b/include/net/irda/ircomm_tty.h
index 59ba38bc..365fa6e 100644
--- a/include/net/irda/ircomm_tty.h
+++ b/include/net/irda/ircomm_tty.h
@@ -62,6 +62,7 @@
  */
 struct ircomm_tty_cb {
 	irda_queue_t queue;            /* Must be first */
+	struct tty_port port;
 	magic_t magic;
 
 	int state;                /* Connect state */
@@ -97,8 +98,6 @@ struct ircomm_tty_cb {
 	void *skey;
 	void *ckey;
 
-	wait_queue_head_t open_wait;
-	wait_queue_head_t close_wait;
 	struct timer_list watchdog_timer;
 	struct work_struct  tqueue;
 
diff --git a/net/irda/ircomm/ircomm_tty.c b/net/irda/ircomm/ircomm_tty.c
index 6b9d5a0..8eeaa8b 100644
--- a/net/irda/ircomm/ircomm_tty.c
+++ b/net/irda/ircomm/ircomm_tty.c
@@ -278,7 +278,7 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 	 */
 
 	retval = 0;
-	add_wait_queue(&self->open_wait, &wait);
+	add_wait_queue(&self->port.open_wait, &wait);
 
 	IRDA_DEBUG(2, "%s(%d):block_til_ready before block on %s open_count=%d\n",
 	      __FILE__,__LINE__, tty->driver->name, self->open_count );
@@ -336,7 +336,7 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 	}
 
 	__set_current_state(TASK_RUNNING);
-	remove_wait_queue(&self->open_wait, &wait);
+	remove_wait_queue(&self->port.open_wait, &wait);
 
 	if (extra_count) {
 		/* ++ is not atomic, so this should be protected - Jean II */
@@ -381,6 +381,7 @@ static int ircomm_tty_open(struct tty_struct *tty, struct file *filp)
 			return -ENOMEM;
 		}
 
+		tty_port_init(&self->port);
 		self->magic = IRCOMM_TTY_MAGIC;
 		self->flow = FLOW_STOP;
 
@@ -393,8 +394,6 @@ static int ircomm_tty_open(struct tty_struct *tty, struct file *filp)
 
 		/* Init some important stuff */
 		init_timer(&self->watchdog_timer);
-		init_waitqueue_head(&self->open_wait);
-		init_waitqueue_head(&self->close_wait);
 		spin_lock_init(&self->spinlock);
 
 		/*
@@ -408,6 +407,7 @@ static int ircomm_tty_open(struct tty_struct *tty, struct file *filp)
 		tty->termios->c_oflag = 0;
 
 		/* Insert into hash */
+		/* FIXME there is a window from find to here */
 		hashbin_insert(ircomm_tty, (irda_queue_t *) self, line, NULL);
 	}
 	/* ++ is not atomic, so this should be protected - Jean II */
@@ -438,7 +438,8 @@ static int ircomm_tty_open(struct tty_struct *tty, struct file *filp)
 		 * probably better sleep uninterruptible?
 		 */
 
-		if (wait_event_interruptible(self->close_wait, !test_bit(ASYNC_B_CLOSING, &self->flags))) {
+		if (wait_event_interruptible(self->port.close_wait,
+				!test_bit(ASYNC_B_CLOSING, &self->flags))) {
 			IRDA_WARNING("%s - got signal while blocking on ASYNC_CLOSING!\n",
 				     __func__);
 			return -ERESTARTSYS;
@@ -559,11 +560,11 @@ static void ircomm_tty_close(struct tty_struct *tty, struct file *filp)
 	if (self->blocked_open) {
 		if (self->close_delay)
 			schedule_timeout_interruptible(self->close_delay);
-		wake_up_interruptible(&self->open_wait);
+		wake_up_interruptible(&self->port.open_wait);
 	}
 
 	self->flags &= ~(ASYNC_NORMAL_ACTIVE|ASYNC_CLOSING);
-	wake_up_interruptible(&self->close_wait);
+	wake_up_interruptible(&self->port.close_wait);
 }
 
 /*
@@ -1011,7 +1012,7 @@ static void ircomm_tty_hangup(struct tty_struct *tty)
 	self->open_count = 0;
 	spin_unlock_irqrestore(&self->spinlock, flags);
 
-	wake_up_interruptible(&self->open_wait);
+	wake_up_interruptible(&self->port.open_wait);
 }
 
 /*
@@ -1084,7 +1085,7 @@ void ircomm_tty_check_modem_status(struct ircomm_tty_cb *self)
 			   (status & IRCOMM_CD) ? "on" : "off");
 
 		if (status & IRCOMM_CD) {
-			wake_up_interruptible(&self->open_wait);
+			wake_up_interruptible(&self->port.open_wait);
 		} else {
 			IRDA_DEBUG(2,
 				   "%s(), Doing serial hangup..\n", __func__ );
@@ -1103,7 +1104,7 @@ void ircomm_tty_check_modem_status(struct ircomm_tty_cb *self)
 				tty->hw_stopped = 0;
 
 				/* Wake up processes blocked on open */
-				wake_up_interruptible(&self->open_wait);
+				wake_up_interruptible(&self->port.open_wait);
 
 				schedule_work(&self->tqueue);
 				return;
diff --git a/net/irda/ircomm/ircomm_tty_attach.c b/net/irda/ircomm/ircomm_tty_attach.c
index b65d66e..bb1e935 100644
--- a/net/irda/ircomm/ircomm_tty_attach.c
+++ b/net/irda/ircomm/ircomm_tty_attach.c
@@ -575,7 +575,7 @@ void ircomm_tty_link_established(struct ircomm_tty_cb *self)
 		self->tty->hw_stopped = 0;
 
 		/* Wake up processes blocked on open */
-		wake_up_interruptible(&self->open_wait);
+		wake_up_interruptible(&self->port.open_wait);
 	}
 
 	schedule_work(&self->tqueue);
-- 
1.7.10.3

From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 06/24] TTY: ircomm, revamp locking
Date: Mon,  4 Jun 2012 13:35:20 +0200
Message-ID: <1338809738-18967-7-git-send-email-jslaby@suse.cz>
References: <1338809738-18967-1-git-send-email-jslaby@suse.cz>
Cc: alan@linux.intel.com, linux-kernel@vger.kernel.org,
	jirislaby@gmail.com, Samuel Ortiz <samuel@sortiz.org>,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1338809738-18967-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use self->spinlock only for ctrl_skb and tx_skb. TTY stuff is now
protected by tty_port->lock. This is needed for further cleanup (and
conversion to tty_port helpers).

This also closes the race in the end of close.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Samuel Ortiz <samuel@sortiz.org>
Cc: netdev@vger.kernel.org
---
 include/net/irda/ircomm_tty.h |    1 -
 net/irda/ircomm/ircomm_tty.c  |   38 ++++++++++++++++++--------------------
 2 files changed, 18 insertions(+), 21 deletions(-)

diff --git a/include/net/irda/ircomm_tty.h b/include/net/irda/ircomm_tty.h
index e4db3b5..a9027d8 100644
--- a/include/net/irda/ircomm_tty.h
+++ b/include/net/irda/ircomm_tty.h
@@ -96,7 +96,6 @@ struct ircomm_tty_cb {
 	struct work_struct  tqueue;
 
 	/* Protect concurent access to :
-	 *	o self->open_count
 	 *	o self->ctrl_skb
 	 *	o self->tx_skb
 	 * Maybe other things may gain to be protected as well...
diff --git a/net/irda/ircomm/ircomm_tty.c b/net/irda/ircomm/ircomm_tty.c
index 8e61026..7b2152c 100644
--- a/net/irda/ircomm/ircomm_tty.c
+++ b/net/irda/ircomm/ircomm_tty.c
@@ -283,13 +283,12 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 	IRDA_DEBUG(2, "%s(%d):block_til_ready before block on %s open_count=%d\n",
 	      __FILE__, __LINE__, tty->driver->name, self->port.count);
 
-	/* As far as I can see, we protect port.count - Jean II */
-	spin_lock_irqsave(&self->spinlock, flags);
+	spin_lock_irqsave(&self->port.lock, flags);
 	if (!tty_hung_up_p(filp)) {
 		extra_count = 1;
 		self->port.count--;
 	}
-	spin_unlock_irqrestore(&self->spinlock, flags);
+	spin_unlock_irqrestore(&self->port.lock, flags);
 	self->port.blocked_open++;
 
 	while (1) {
@@ -340,9 +339,9 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 
 	if (extra_count) {
 		/* ++ is not atomic, so this should be protected - Jean II */
-		spin_lock_irqsave(&self->spinlock, flags);
+		spin_lock_irqsave(&self->port.lock, flags);
 		self->port.count++;
-		spin_unlock_irqrestore(&self->spinlock, flags);
+		spin_unlock_irqrestore(&self->port.lock, flags);
 	}
 	self->port.blocked_open--;
 
@@ -409,12 +408,12 @@ static int ircomm_tty_open(struct tty_struct *tty, struct file *filp)
 		hashbin_insert(ircomm_tty, (irda_queue_t *) self, line, NULL);
 	}
 	/* ++ is not atomic, so this should be protected - Jean II */
-	spin_lock_irqsave(&self->spinlock, flags);
+	spin_lock_irqsave(&self->port.lock, flags);
 	self->port.count++;
 
 	tty->driver_data = self;
 	self->tty = tty;
-	spin_unlock_irqrestore(&self->spinlock, flags);
+	spin_unlock_irqrestore(&self->port.lock, flags);
 
 	IRDA_DEBUG(1, "%s(), %s%d, count = %d\n", __func__ , tty->driver->name,
 		   self->line, self->port.count);
@@ -495,10 +494,10 @@ static void ircomm_tty_close(struct tty_struct *tty, struct file *filp)
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
 
-	spin_lock_irqsave(&self->spinlock, flags);
+	spin_lock_irqsave(&self->port.lock, flags);
 
 	if (tty_hung_up_p(filp)) {
-		spin_unlock_irqrestore(&self->spinlock, flags);
+		spin_unlock_irqrestore(&self->port.lock, flags);
 
 		IRDA_DEBUG(0, "%s(), returning 1\n", __func__ );
 		return;
@@ -524,20 +523,15 @@ static void ircomm_tty_close(struct tty_struct *tty, struct file *filp)
 		self->port.count = 0;
 	}
 	if (self->port.count) {
-		spin_unlock_irqrestore(&self->spinlock, flags);
+		spin_unlock_irqrestore(&self->port.lock, flags);
 
 		IRDA_DEBUG(0, "%s(), open count > 0\n", __func__ );
 		return;
 	}
 
-	/* Hum... Should be test_and_set_bit ??? - Jean II */
 	set_bit(ASYNCB_CLOSING, &self->port.flags);
 
-	/* We need to unlock here (we were unlocking at the end of this
-	 * function), because tty_wait_until_sent() may schedule.
-	 * I don't know if the rest should be protected somehow,
-	 * so someone should check. - Jean II */
-	spin_unlock_irqrestore(&self->spinlock, flags);
+	spin_unlock_irqrestore(&self->port.lock, flags);
 
 	/*
 	 * Now we wait for the transmit buffer to clear; and we notify
@@ -552,16 +546,21 @@ static void ircomm_tty_close(struct tty_struct *tty, struct file *filp)
 	tty_driver_flush_buffer(tty);
 	tty_ldisc_flush(tty);
 
+	spin_lock_irqsave(&self->port.lock, flags);
 	tty->closing = 0;
 	self->tty = NULL;
 
 	if (self->port.blocked_open) {
-		if (self->port.close_delay)
+		if (self->port.close_delay) {
+			spin_unlock_irqrestore(&self->port.lock, flags);
 			schedule_timeout_interruptible(self->port.close_delay);
+			spin_lock_irqsave(&self->port.lock, flags);
+		}
 		wake_up_interruptible(&self->port.open_wait);
 	}
 
 	self->port.flags &= ~(ASYNC_NORMAL_ACTIVE|ASYNC_CLOSING);
+	spin_unlock_irqrestore(&self->port.lock, flags);
 	wake_up_interruptible(&self->port.close_wait);
 }
 
@@ -1003,12 +1002,11 @@ static void ircomm_tty_hangup(struct tty_struct *tty)
 	/* ircomm_tty_flush_buffer(tty); */
 	ircomm_tty_shutdown(self);
 
-	/* I guess we need to lock here - Jean II */
-	spin_lock_irqsave(&self->spinlock, flags);
+	spin_lock_irqsave(&self->port.lock, flags);
 	self->port.flags &= ~ASYNC_NORMAL_ACTIVE;
 	self->tty = NULL;
 	self->port.count = 0;
-	spin_unlock_irqrestore(&self->spinlock, flags);
+	spin_unlock_irqrestore(&self->port.lock, flags);
 
 	wake_up_interruptible(&self->port.open_wait);
 }
-- 
1.7.10.3

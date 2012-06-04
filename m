From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 11/24] TTY: ircomm, use tty_port_close_start helper
Date: Mon,  4 Jun 2012 13:35:25 +0200
Message-ID: <1338809738-18967-12-git-send-email-jslaby@suse.cz>
References: <1338809738-18967-1-git-send-email-jslaby@suse.cz>
Cc: alan@linux.intel.com, linux-kernel@vger.kernel.org,
	jirislaby@gmail.com, Samuel Ortiz <samuel@sortiz.org>,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1338809738-18967-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Again, the code is identical, so leverage the helper code.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Samuel Ortiz <samuel@sortiz.org>
Cc: netdev@vger.kernel.org
---
 net/irda/ircomm/ircomm_tty.c |   48 +-----------------------------------------
 1 file changed, 1 insertion(+), 47 deletions(-)

diff --git a/net/irda/ircomm/ircomm_tty.c b/net/irda/ircomm/ircomm_tty.c
index cfe352d..4e35b45 100644
--- a/net/irda/ircomm/ircomm_tty.c
+++ b/net/irda/ircomm/ircomm_tty.c
@@ -509,64 +509,18 @@ static void ircomm_tty_close(struct tty_struct *tty, struct file *filp)
 {
 	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) tty->driver_data;
 	struct tty_port *port = &self->port;
-	unsigned long flags;
 
 	IRDA_DEBUG(0, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
 
-	spin_lock_irqsave(&port->lock, flags);
-
-	if (tty_hung_up_p(filp)) {
-		spin_unlock_irqrestore(&port->lock, flags);
-
-		IRDA_DEBUG(0, "%s(), returning 1\n", __func__ );
-		return;
-	}
-
-	if ((tty->count == 1) && (port->count != 1)) {
-		/*
-		 * Uh, oh.  tty->count is 1, which means that the tty
-		 * structure will be freed.  state->count should always
-		 * be one in these conditions.  If it's greater than
-		 * one, we've got real problems, since it means the
-		 * serial port won't be shutdown.
-		 */
-		IRDA_DEBUG(0, "%s(), bad serial port count; "
-			   "tty->count is 1, state->count is %d\n", __func__ ,
-			   port->count);
-		port->count = 1;
-	}
-
-	if (--port->count < 0) {
-		IRDA_ERROR("%s(), bad serial port count for ttys%d: %d\n",
-			   __func__, self->line, port->count);
-		port->count = 0;
-	}
-	if (port->count) {
-		spin_unlock_irqrestore(&port->lock, flags);
-
-		IRDA_DEBUG(0, "%s(), open count > 0\n", __func__ );
+	if (tty_port_close_start(port, tty, filp) == 0)
 		return;
-	}
-
-	set_bit(ASYNCB_CLOSING, &port->flags);
-
-	spin_unlock_irqrestore(&port->lock, flags);
-
-	/*
-	 * Now we wait for the transmit buffer to clear; and we notify
-	 * the line discipline to only process XON/XOFF characters.
-	 */
-	tty->closing = 1;
-	if (port->closing_wait != ASYNC_CLOSING_WAIT_NONE)
-		tty_wait_until_sent_from_close(tty, port->closing_wait);
 
 	ircomm_tty_shutdown(self);
 
 	tty_driver_flush_buffer(tty);
-	tty_ldisc_flush(tty);
 
 	tty_port_close_end(port, tty);
 	tty_port_tty_set(port, NULL);
-- 
1.7.10.3

From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 09/24] TTY: ircomm, define carrier routines
Date: Mon,  4 Jun 2012 13:35:23 +0200
Message-ID: <1338809738-18967-10-git-send-email-jslaby@suse.cz>
References: <1338809738-18967-1-git-send-email-jslaby@suse.cz>
Cc: alan@linux.intel.com, linux-kernel@vger.kernel.org,
	jirislaby@gmail.com, Samuel Ortiz <samuel@sortiz.org>,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1338809738-18967-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These will be used by the tty_port wait_til_ready later. (Now they are
used by our code.)

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Samuel Ortiz <samuel@sortiz.org>
Cc: netdev@vger.kernel.org
---
 net/irda/ircomm/ircomm_tty.c |   43 ++++++++++++++++++++++++++++++++----------
 1 file changed, 33 insertions(+), 10 deletions(-)

diff --git a/net/irda/ircomm/ircomm_tty.c b/net/irda/ircomm/ircomm_tty.c
index 199d9cb..3fdce18 100644
--- a/net/irda/ircomm/ircomm_tty.c
+++ b/net/irda/ircomm/ircomm_tty.c
@@ -104,6 +104,35 @@ static const struct tty_operations ops = {
 #endif /* CONFIG_PROC_FS */
 };
 
+static void ircomm_port_raise_dtr_rts(struct tty_port *port, int raise)
+{
+	struct ircomm_tty_cb *self = container_of(port, struct ircomm_tty_cb,
+			port);
+	/*
+	 * Here, we use to lock those two guys, but as ircomm_param_request()
+	 * does it itself, I don't see the point (and I see the deadlock).
+	 * Jean II
+	 */
+	if (raise)
+		self->settings.dte |= IRCOMM_RTS | IRCOMM_DTR;
+	else
+		self->settings.dte &= ~(IRCOMM_RTS | IRCOMM_DTR);
+
+	ircomm_param_request(self, IRCOMM_DTE, TRUE);
+}
+
+static int ircomm_port_carrier_raised(struct tty_port *port)
+{
+	struct ircomm_tty_cb *self = container_of(port, struct ircomm_tty_cb,
+			port);
+	return self->settings.dce & IRCOMM_CD;
+}
+
+static const struct tty_port_operations ircomm_port_ops = {
+	.dtr_rts = ircomm_port_raise_dtr_rts,
+	.carrier_raised = ircomm_port_carrier_raised,
+};
+
 /*
  * Function ircomm_tty_init()
  *
@@ -290,15 +319,8 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 	port->blocked_open++;
 
 	while (1) {
-		if (tty->termios->c_cflag & CBAUD) {
-			/* Here, we use to lock those two guys, but
-			 * as ircomm_param_request() does it itself,
-			 * I don't see the point (and I see the deadlock).
-			 * Jean II */
-			self->settings.dte |= IRCOMM_RTS + IRCOMM_DTR;
-
-			ircomm_param_request(self, IRCOMM_DTE, TRUE);
-		}
+		if (tty->termios->c_cflag & CBAUD)
+			tty_port_raise_dtr_rts(port);
 
 		current->state = TASK_INTERRUPTIBLE;
 
@@ -315,7 +337,7 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 		 * ready
 		 */
 		if (!test_bit(ASYNCB_CLOSING, &port->flags) &&
-		    (do_clocal || (self->settings.dce & IRCOMM_CD)) &&
+		    (do_clocal || tty_port_carrier_raised(port)) &&
 		    self->state == IRCOMM_TTY_READY)
 		{
 			break;
@@ -379,6 +401,7 @@ static int ircomm_tty_open(struct tty_struct *tty, struct file *filp)
 		}
 
 		tty_port_init(&self->port);
+		self->port.ops = &ircomm_port_ops;
 		self->magic = IRCOMM_TTY_MAGIC;
 		self->flow = FLOW_STOP;
 
-- 
1.7.10.3

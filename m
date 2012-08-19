From: Huang Shijie <shijie8@gmail.com>
Subject: [PATCH] serial: add a new helper function
Date: Sun, 19 Aug 2012 14:27:12 -0400
Message-ID: <1345400832-23572-1-git-send-email-shijie8@gmail.com>
Cc: alan@linux.intel.com, jirislaby@gmail.com,
	linux-kernel@vger.kernel.org, linux-serial@vger.kernel.org,
	netdev@vger.kernel.org, Huang Shijie <shijie8@gmail.com>
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In most of the time, the driver needs to check if the cts flow control
is enabled. But now, the driver checks the ASYNC_CTS_FLOW flag manually,
which is not a grace way. So add a new wraper function to make the code
tidy and clean.

Signed-off-by: Huang Shijie <shijie8@gmail.com>
---
 drivers/char/pcmcia/synclink_cs.c   |    2 +-
 drivers/tty/amiserial.c             |    2 +-
 drivers/tty/cyclades.c              |    2 +-
 drivers/tty/isicom.c                |    2 +-
 drivers/tty/mxser.c                 |    2 +-
 drivers/tty/serial/mxs-auart.c      |    2 +-
 drivers/tty/serial/serial_core.c    |    4 ++--
 drivers/tty/synclink.c              |    2 +-
 drivers/tty/synclink_gt.c           |    2 +-
 drivers/tty/synclinkmp.c            |    2 +-
 include/linux/tty.h                 |    7 +++++++
 net/irda/ircomm/ircomm_tty.c        |    4 ++--
 net/irda/ircomm/ircomm_tty_attach.c |    2 +-
 13 files changed, 21 insertions(+), 14 deletions(-)

diff --git a/drivers/char/pcmcia/synclink_cs.c b/drivers/char/pcmcia/synclink_cs.c
index 5db08c7..3f57d5de 100644
--- a/drivers/char/pcmcia/synclink_cs.c
+++ b/drivers/char/pcmcia/synclink_cs.c
@@ -1050,7 +1050,7 @@ static void cts_change(MGSLPC_INFO *info, struct tty_struct *tty)
 	wake_up_interruptible(&info->status_event_wait_q);
 	wake_up_interruptible(&info->event_wait_q);
 
-	if (info->port.flags & ASYNC_CTS_FLOW) {
+	if (tty_port_cts_enabled(&info->port)) {
 		if (tty->hw_stopped) {
 			if (info->serial_signals & SerialSignal_CTS) {
 				if (debug_level >= DEBUG_LEVEL_ISR)
diff --git a/drivers/tty/amiserial.c b/drivers/tty/amiserial.c
index 2b7535d..42d0a25 100644
--- a/drivers/tty/amiserial.c
+++ b/drivers/tty/amiserial.c
@@ -420,7 +420,7 @@ static void check_modem_status(struct serial_state *info)
 				tty_hangup(port->tty);
 		}
 	}
-	if (port->flags & ASYNC_CTS_FLOW) {
+	if (tty_port_cts_enabled(port)) {
 		if (port->tty->hw_stopped) {
 			if (!(status & SER_CTS)) {
 #if (defined(SERIAL_DEBUG_INTR) || defined(SERIAL_DEBUG_FLOW))
diff --git a/drivers/tty/cyclades.c b/drivers/tty/cyclades.c
index e3954da..0a6a0bc 100644
--- a/drivers/tty/cyclades.c
+++ b/drivers/tty/cyclades.c
@@ -727,7 +727,7 @@ static void cyy_chip_modem(struct cyclades_card *cinfo, int chip,
 		else
 			tty_hangup(tty);
 	}
-	if ((mdm_change & CyCTS) && (info->port.flags & ASYNC_CTS_FLOW)) {
+	if ((mdm_change & CyCTS) && tty_port_cts_enabled(&info->port)) {
 		if (tty->hw_stopped) {
 			if (mdm_status & CyCTS) {
 				/* cy_start isn't used
diff --git a/drivers/tty/isicom.c b/drivers/tty/isicom.c
index 99cf22e..d7492e1 100644
--- a/drivers/tty/isicom.c
+++ b/drivers/tty/isicom.c
@@ -600,7 +600,7 @@ static irqreturn_t isicom_interrupt(int irq, void *dev_id)
 					port->status &= ~ISI_DCD;
 			}
 
-			if (port->port.flags & ASYNC_CTS_FLOW) {
+			if (tty_port_cts_enabled(&port->port)) {
 				if (tty->hw_stopped) {
 					if (header & ISI_CTS) {
 						port->port.tty->hw_stopped = 0;
diff --git a/drivers/tty/mxser.c b/drivers/tty/mxser.c
index bb2da4c..cfda47d 100644
--- a/drivers/tty/mxser.c
+++ b/drivers/tty/mxser.c
@@ -830,7 +830,7 @@ static void mxser_check_modem_status(struct tty_struct *tty,
 			wake_up_interruptible(&port->port.open_wait);
 	}
 
-	if (port->port.flags & ASYNC_CTS_FLOW) {
+	if (tty_port_cts_enabled(&port->port)) {
 		if (tty->hw_stopped) {
 			if (status & UART_MSR_CTS) {
 				tty->hw_stopped = 0;
diff --git a/drivers/tty/serial/mxs-auart.c b/drivers/tty/serial/mxs-auart.c
index 3a667ee..dafeef2 100644
--- a/drivers/tty/serial/mxs-auart.c
+++ b/drivers/tty/serial/mxs-auart.c
@@ -262,7 +262,7 @@ static void mxs_auart_set_mctrl(struct uart_port *u, unsigned mctrl)
 
 	ctrl &= ~AUART_CTRL2_RTSEN;
 	if (mctrl & TIOCM_RTS) {
-		if (u->state->port.flags & ASYNC_CTS_FLOW)
+		if (tty_port_cts_enabled(&u->state->port))
 			ctrl |= AUART_CTRL2_RTSEN;
 	}
 
diff --git a/drivers/tty/serial/serial_core.c b/drivers/tty/serial/serial_core.c
index 5b308c8..1920e5c 100644
--- a/drivers/tty/serial/serial_core.c
+++ b/drivers/tty/serial/serial_core.c
@@ -176,7 +176,7 @@ static int uart_port_startup(struct tty_struct *tty, struct uart_state *state,
 				uart_set_mctrl(uport, TIOCM_RTS | TIOCM_DTR);
 		}
 
-		if (port->flags & ASYNC_CTS_FLOW) {
+		if (tty_port_cts_enabled(port)) {
 			spin_lock_irq(&uport->lock);
 			if (!(uport->ops->get_mctrl(uport) & TIOCM_CTS))
 				tty->hw_stopped = 1;
@@ -2493,7 +2493,7 @@ void uart_handle_cts_change(struct uart_port *uport, unsigned int status)
 
 	uport->icount.cts++;
 
-	if (port->flags & ASYNC_CTS_FLOW) {
+	if (tty_port_cts_enabled(port)) {
 		if (tty->hw_stopped) {
 			if (status) {
 				tty->hw_stopped = 0;
diff --git a/drivers/tty/synclink.c b/drivers/tty/synclink.c
index 666aa14..70e3a52 100644
--- a/drivers/tty/synclink.c
+++ b/drivers/tty/synclink.c
@@ -1359,7 +1359,7 @@ static void mgsl_isr_io_pin( struct mgsl_struct *info )
 			}
 		}
 	
-		if ( (info->port.flags & ASYNC_CTS_FLOW) && 
+		if (tty_port_cts_enabled(&info->port) &&
 		     (status & MISCSTATUS_CTS_LATCHED) ) {
 			if (info->port.tty->hw_stopped) {
 				if (status & MISCSTATUS_CTS) {
diff --git a/drivers/tty/synclink_gt.c b/drivers/tty/synclink_gt.c
index 45f6136..b38e954 100644
--- a/drivers/tty/synclink_gt.c
+++ b/drivers/tty/synclink_gt.c
@@ -2053,7 +2053,7 @@ static void cts_change(struct slgt_info *info, unsigned short status)
 	wake_up_interruptible(&info->event_wait_q);
 	info->pending_bh |= BH_STATUS;
 
-	if (info->port.flags & ASYNC_CTS_FLOW) {
+	if (tty_port_cts_enabled(&info->port)) {
 		if (info->port.tty) {
 			if (info->port.tty->hw_stopped) {
 				if (info->signals & SerialSignal_CTS) {
diff --git a/drivers/tty/synclinkmp.c b/drivers/tty/synclinkmp.c
index 53429c8..f17d9f3 100644
--- a/drivers/tty/synclinkmp.c
+++ b/drivers/tty/synclinkmp.c
@@ -2500,7 +2500,7 @@ static void isr_io_pin( SLMP_INFO *info, u16 status )
 			}
 		}
 
-		if ( (info->port.flags & ASYNC_CTS_FLOW) &&
+		if (tty_port_cts_enabled(&info->port) &&
 		     (status & MISCSTATUS_CTS_LATCHED) ) {
 			if ( info->port.tty ) {
 				if (info->port.tty->hw_stopped) {
diff --git a/include/linux/tty.h b/include/linux/tty.h
index 69a787f..e0b4871 100644
--- a/include/linux/tty.h
+++ b/include/linux/tty.h
@@ -43,6 +43,7 @@
 #include <linux/tty_driver.h>
 #include <linux/tty_ldisc.h>
 #include <linux/mutex.h>
+#include <linux/serial.h>
 
 
 
@@ -513,6 +514,12 @@ static inline struct tty_port *tty_port_get(struct tty_port *port)
 	return port;
 }
 
+/* If the cts flow control is enabled, return true. */
+static inline bool tty_port_cts_enabled(struct tty_port *port)
+{
+	return port->flags & ASYNC_CTS_FLOW;
+}
+
 extern struct tty_struct *tty_port_tty_get(struct tty_port *port);
 extern void tty_port_tty_set(struct tty_port *port, struct tty_struct *tty);
 extern int tty_port_carrier_raised(struct tty_port *port);
diff --git a/net/irda/ircomm/ircomm_tty.c b/net/irda/ircomm/ircomm_tty.c
index 9668990..95a3a7a 100644
--- a/net/irda/ircomm/ircomm_tty.c
+++ b/net/irda/ircomm/ircomm_tty.c
@@ -1070,7 +1070,7 @@ void ircomm_tty_check_modem_status(struct ircomm_tty_cb *self)
 			goto put;
 		}
 	}
-	if (tty && self->port.flags & ASYNC_CTS_FLOW) {
+	if (tty && tty_port_cts_enabled(&self->port)) {
 		if (tty->hw_stopped) {
 			if (status & IRCOMM_CTS) {
 				IRDA_DEBUG(2,
@@ -1313,7 +1313,7 @@ static void ircomm_tty_line_info(struct ircomm_tty_cb *self, struct seq_file *m)
 
 	seq_puts(m, "Flags:");
 	sep = ' ';
-	if (self->port.flags & ASYNC_CTS_FLOW) {
+	if (tty_port_cts_enabled(&self->port)) {
 		seq_printf(m, "%cASYNC_CTS_FLOW", sep);
 		sep = '|';
 	}
diff --git a/net/irda/ircomm/ircomm_tty_attach.c b/net/irda/ircomm/ircomm_tty_attach.c
index 3ab70e7..edab393 100644
--- a/net/irda/ircomm/ircomm_tty_attach.c
+++ b/net/irda/ircomm/ircomm_tty_attach.c
@@ -578,7 +578,7 @@ void ircomm_tty_link_established(struct ircomm_tty_cb *self)
 	 * will have to wait for the peer device (DCE) to raise the CTS
 	 * line.
 	 */
-	if ((self->port.flags & ASYNC_CTS_FLOW) &&
+	if (tty_port_cts_enabled(&self->port) &&
 			((self->settings.dce & IRCOMM_CTS) == 0)) {
 		IRDA_DEBUG(0, "%s(), waiting for CTS ...\n", __func__ );
 		goto put;
-- 
1.7.4.4

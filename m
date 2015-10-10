From: Peter Hurley <peter@hurleysoftware.com>
Subject: [PATCH 2/7] tty: Remove ASYNC_CLOSING checks in open()/hangup() methods
Date: Sat, 10 Oct 2015 16:00:52 -0400
Message-ID: <1444507257-7513-3-git-send-email-peter@hurleysoftware.com>
References: <1444507257-7513-1-git-send-email-peter@hurleysoftware.com>
Cc: Jiri Slaby <jslaby@suse.cz>, Alan Cox <alan@linux.intel.com>,
	David Laight <David.Laight@aculab.com>,
	Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org,
	linux-serial@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Peter Hurley <peter@hurleysoftware.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444507257-7513-1-git-send-email-peter@hurleysoftware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since at least before 2.6.30, tty drivers that do not drop the tty lock
while closing cannot observe ASYNC_CLOSING set while holding the
tty lock; this includes the tty driver's open() and hangup() methods,
since the tty core calls these methods holding the tty lock.

For these drivers, waiting for ASYNC_CLOSING to clear while opening
is not required, since this condition cannot occur. Similarly, even
when the open() method drops and reacquires the tty lock after
blocking, ASYNC_CLOSING cannot be set (again, for drivers that
do not drop the tty lock while closing).

Now that tty port drivers no longer drop the tty lock while closing
(since 'tty: Remove tty_wait_until_sent_from_close()'), the same
conditions apply: waiting for ASYNC_CLOSING to clear while opening
is not required, nor is re-checking ASYNC_CLOSING after dropping and
reacquiring the tty lock while blocking (eg., in *_block_til_ready()).

Note: The ASYNC_CLOSING flag state is still maintained since several
bitrotting drivers use it for (dubious) other purposes.

Signed-off-by: Peter Hurley <peter@hurleysoftware.com>
---
 drivers/char/pcmcia/synclink_cs.c |  9 ---------
 drivers/tty/cyclades.c            |  9 ---------
 drivers/tty/rocket.c              | 12 ------------
 drivers/tty/serial/crisv10.c      | 33 +--------------------------------
 drivers/tty/synclink.c            | 18 ++++--------------
 drivers/tty/synclink_gt.c         | 14 ++------------
 drivers/tty/synclinkmp.c          | 14 ++------------
 drivers/tty/tty_port.c            | 13 +------------
 net/irda/ircomm/ircomm_tty.c      | 31 +------------------------------
 9 files changed, 11 insertions(+), 142 deletions(-)

diff --git a/drivers/char/pcmcia/synclink_cs.c b/drivers/char/pcmcia/synclink_cs.c
index 7680d52..45df4bf 100644
--- a/drivers/char/pcmcia/synclink_cs.c
+++ b/drivers/char/pcmcia/synclink_cs.c
@@ -2507,15 +2507,6 @@ static int mgslpc_open(struct tty_struct *tty, struct file * filp)
 		printk("%s(%d):mgslpc_open(%s), old ref count = %d\n",
 			 __FILE__, __LINE__, tty->driver->name, port->count);
 
-	/* If port is closing, signal caller to try again */
-	if (port->flags & ASYNC_CLOSING){
-		wait_event_interruptible_tty(tty, port->close_wait,
-					     !(port->flags & ASYNC_CLOSING));
-		retval = ((port->flags & ASYNC_HUP_NOTIFY) ?
-			-EAGAIN : -ERESTARTSYS);
-		goto cleanup;
-	}
-
 	port->low_latency = (port->flags & ASYNC_LOW_LATENCY) ? 1 : 0;
 
 	spin_lock_irqsave(&info->netlock, flags);
diff --git a/drivers/tty/cyclades.c b/drivers/tty/cyclades.c
index 87f6578..d4a1331 100644
--- a/drivers/tty/cyclades.c
+++ b/drivers/tty/cyclades.c
@@ -1577,15 +1577,6 @@ static int cy_open(struct tty_struct *tty, struct file *filp)
 #endif
 
 	/*
-	 * If the port is the middle of closing, bail out now
-	 */
-	if (info->port.flags & ASYNC_CLOSING) {
-		wait_event_interruptible_tty(tty, info->port.close_wait,
-				!(info->port.flags & ASYNC_CLOSING));
-		return (info->port.flags & ASYNC_HUP_NOTIFY) ? -EAGAIN: -ERESTARTSYS;
-	}
-
-	/*
 	 * Start up serial port
 	 */
 	retval = cy_startup(info, tty);
diff --git a/drivers/tty/rocket.c b/drivers/tty/rocket.c
index c8dd8dc..69c72d1 100644
--- a/drivers/tty/rocket.c
+++ b/drivers/tty/rocket.c
@@ -895,14 +895,6 @@ static int rp_open(struct tty_struct *tty, struct file *filp)
 	if (!page)
 		return -ENOMEM;
 
-	if (port->flags & ASYNC_CLOSING) {
-		retval = wait_for_completion_interruptible(&info->close_wait);
-		free_page(page);
-		if (retval)
-			return retval;
-		return ((port->flags & ASYNC_HUP_NOTIFY) ? -EAGAIN : -ERESTARTSYS);
-	}
-
 	/*
 	 * We must not sleep from here until the port is marked fully in use.
 	 */
@@ -1511,10 +1503,6 @@ static void rp_hangup(struct tty_struct *tty)
 #endif
 	rp_flush_buffer(tty);
 	spin_lock_irqsave(&info->port.lock, flags);
-	if (info->port.flags & ASYNC_CLOSING) {
-		spin_unlock_irqrestore(&info->port.lock, flags);
-		return;
-	}
 	if (info->port.count)
 		atomic_dec(&rp_num_ports_open);
 	clear_bit((info->aiop * 8) + info->chan, (void *) &xmit_flags[info->board]);
diff --git a/drivers/tty/serial/crisv10.c b/drivers/tty/serial/crisv10.c
index 3e4470a..06f4fe9 100644
--- a/drivers/tty/serial/crisv10.c
+++ b/drivers/tty/serial/crisv10.c
@@ -3759,23 +3759,6 @@ block_til_ready(struct tty_struct *tty, struct file * filp,
 	int		do_clocal = 0;
 
 	/*
-	 * If the device is in the middle of being closed, then block
-	 * until it's done, and then try again.
-	 */
-	if (info->port.flags & ASYNC_CLOSING) {
-		wait_event_interruptible_tty(tty, info->port.close_wait,
-			!(info->port.flags & ASYNC_CLOSING));
-#ifdef SERIAL_DO_RESTART
-		if (info->port.flags & ASYNC_HUP_NOTIFY)
-			return -EAGAIN;
-		else
-			return -ERESTARTSYS;
-#else
-		return -EAGAIN;
-#endif
-	}
-
-	/*
 	 * If non-blocking mode is set, or the port is not enabled,
 	 * then make the check up front and then exit.
 	 */
@@ -3825,7 +3808,7 @@ block_til_ready(struct tty_struct *tty, struct file * filp,
 #endif
 			break;
 		}
-		if (!(info->port.flags & ASYNC_CLOSING) && do_clocal)
+		if (do_clocal)
 			/* && (do_clocal || DCD_IS_ASSERTED) */
 			break;
 		if (signal_pending(current)) {
@@ -3895,20 +3878,6 @@ rs_open(struct tty_struct *tty, struct file * filp)
 	info->port.low_latency = !!(info->port.flags & ASYNC_LOW_LATENCY);
 
 	/*
-	 * If the port is in the middle of closing, bail out now
-	 */
-	if (info->port.flags & ASYNC_CLOSING) {
-		wait_event_interruptible_tty(tty, info->port.close_wait,
-			!(info->port.flags & ASYNC_CLOSING));
-#ifdef SERIAL_DO_RESTART
-		return ((info->port.flags & ASYNC_HUP_NOTIFY) ?
-			-EAGAIN : -ERESTARTSYS);
-#else
-		return -EAGAIN;
-#endif
-	}
-
-	/*
 	 * If DMA is enabled try to allocate the irq's.
 	 */
 	if (info->port.count == 1) {
diff --git a/drivers/tty/synclink.c b/drivers/tty/synclink.c
index 2fac712..11d322b 100644
--- a/drivers/tty/synclink.c
+++ b/drivers/tty/synclink.c
@@ -3314,12 +3314,11 @@ static int block_til_ready(struct tty_struct *tty, struct file * filp,
 					-EAGAIN : -ERESTARTSYS;
 			break;
 		}
-		
+
 		dcd = tty_port_carrier_raised(&info->port);
-		
- 		if (!(port->flags & ASYNC_CLOSING) && (do_clocal || dcd))
- 			break;
-			
+		if (do_clocal || dcd)
+			break;
+
 		if (signal_pending(current)) {
 			retval = -ERESTARTSYS;
 			break;
@@ -3398,15 +3397,6 @@ static int mgsl_open(struct tty_struct *tty, struct file * filp)
 		printk("%s(%d):mgsl_open(%s), old ref count = %d\n",
 			 __FILE__,__LINE__,tty->driver->name, info->port.count);
 
-	/* If port is closing, signal caller to try again */
-	if (info->port.flags & ASYNC_CLOSING){
-		wait_event_interruptible_tty(tty, info->port.close_wait,
-				     !(info->port.flags & ASYNC_CLOSING));
-		retval = ((info->port.flags & ASYNC_HUP_NOTIFY) ?
-			-EAGAIN : -ERESTARTSYS);
-		goto cleanup;
-	}
-	
 	info->port.low_latency = (info->port.flags & ASYNC_LOW_LATENCY) ? 1 : 0;
 
 	spin_lock_irqsave(&info->netlock, flags);
diff --git a/drivers/tty/synclink_gt.c b/drivers/tty/synclink_gt.c
index 0ea8eee..6fc39fb 100644
--- a/drivers/tty/synclink_gt.c
+++ b/drivers/tty/synclink_gt.c
@@ -672,15 +672,6 @@ static int open(struct tty_struct *tty, struct file *filp)
 
 	DBGINFO(("%s open, old ref count = %d\n", info->device_name, info->port.count));
 
-	/* If port is closing, signal caller to try again */
-	if (info->port.flags & ASYNC_CLOSING){
-		wait_event_interruptible_tty(tty, info->port.close_wait,
-					     !(info->port.flags & ASYNC_CLOSING));
-		retval = ((info->port.flags & ASYNC_HUP_NOTIFY) ?
-			-EAGAIN : -ERESTARTSYS);
-		goto cleanup;
-	}
-
 	mutex_lock(&info->port.mutex);
 	info->port.low_latency = (info->port.flags & ASYNC_LOW_LATENCY) ? 1 : 0;
 
@@ -3320,9 +3311,8 @@ static int block_til_ready(struct tty_struct *tty, struct file *filp,
 		}
 
 		cd = tty_port_carrier_raised(port);
-
- 		if (!(port->flags & ASYNC_CLOSING) && (do_clocal || cd ))
- 			break;
+		if (do_clocal || cd)
+			break;
 
 		if (signal_pending(current)) {
 			retval = -ERESTARTSYS;
diff --git a/drivers/tty/synclinkmp.c b/drivers/tty/synclinkmp.c
index 08633a8..fb00a06 100644
--- a/drivers/tty/synclinkmp.c
+++ b/drivers/tty/synclinkmp.c
@@ -752,15 +752,6 @@ static int open(struct tty_struct *tty, struct file *filp)
 		printk("%s(%d):%s open(), old ref count = %d\n",
 			 __FILE__,__LINE__,tty->driver->name, info->port.count);
 
-	/* If port is closing, signal caller to try again */
-	if (info->port.flags & ASYNC_CLOSING){
-		wait_event_interruptible_tty(tty, info->port.close_wait,
-					     !(info->port.flags & ASYNC_CLOSING));
-		retval = ((info->port.flags & ASYNC_HUP_NOTIFY) ?
-			-EAGAIN : -ERESTARTSYS);
-		goto cleanup;
-	}
-
 	info->port.low_latency = (info->port.flags & ASYNC_LOW_LATENCY) ? 1 : 0;
 
 	spin_lock_irqsave(&info->netlock, flags);
@@ -3341,9 +3332,8 @@ static int block_til_ready(struct tty_struct *tty, struct file *filp,
 		}
 
 		cd = tty_port_carrier_raised(port);
-
- 		if (!(port->flags & ASYNC_CLOSING) && (do_clocal || cd))
- 			break;
+		if (do_clocal || cd)
+			break;
 
 		if (signal_pending(current)) {
 			retval = -ERESTARTSYS;
diff --git a/drivers/tty/tty_port.c b/drivers/tty/tty_port.c
index d7d9f9c..0e1cf04 100644
--- a/drivers/tty/tty_port.c
+++ b/drivers/tty/tty_port.c
@@ -363,16 +363,6 @@ int tty_port_block_til_ready(struct tty_port *port,
 	unsigned long flags;
 	DEFINE_WAIT(wait);
 
-	/* block if port is in the process of being closed */
-	if (port->flags & ASYNC_CLOSING) {
-		wait_event_interruptible_tty(tty, port->close_wait,
-				!(port->flags & ASYNC_CLOSING));
-		if (port->flags & ASYNC_HUP_NOTIFY)
-			return -EAGAIN;
-		else
-			return -ERESTARTSYS;
-	}
-
 	/* if non-blocking mode is set we can pass directly to open unless
 	   the port has just hung up or is in another error state */
 	if (tty->flags & (1 << TTY_IO_ERROR)) {
@@ -423,8 +413,7 @@ int tty_port_block_til_ready(struct tty_port *port,
 		 * Never ask drivers if CLOCAL is set, this causes troubles
 		 * on some hardware.
 		 */
-		if (!(port->flags & ASYNC_CLOSING) &&
-				(do_clocal || tty_port_carrier_raised(port)))
+		if (do_clocal || tty_port_carrier_raised(port))
 			break;
 		if (signal_pending(current)) {
 			retval = -ERESTARTSYS;
diff --git a/net/irda/ircomm/ircomm_tty.c b/net/irda/ircomm/ircomm_tty.c
index 683346d..a423770 100644
--- a/net/irda/ircomm/ircomm_tty.c
+++ b/net/irda/ircomm/ircomm_tty.c
@@ -335,8 +335,7 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 		 * specified, we cannot return before the IrCOMM link is
 		 * ready
 		 */
-		if (!test_bit(ASYNCB_CLOSING, &port->flags) &&
-		    (do_clocal || tty_port_carrier_raised(port)) &&
+		if ((do_clocal || tty_port_carrier_raised(port)) &&
 		    self->state == IRCOMM_TTY_READY)
 		{
 			break;
@@ -443,34 +442,6 @@ static int ircomm_tty_open(struct tty_struct *tty, struct file *filp)
 	/* Not really used by us, but lets do it anyway */
 	self->port.low_latency = (self->port.flags & ASYNC_LOW_LATENCY) ? 1 : 0;
 
-	/*
-	 * If the port is the middle of closing, bail out now
-	 */
-	if (test_bit(ASYNCB_CLOSING, &self->port.flags)) {
-
-		/* Hm, why are we blocking on ASYNC_CLOSING if we
-		 * do return -EAGAIN/-ERESTARTSYS below anyway?
-		 * IMHO it's either not needed in the first place
-		 * or for some reason we need to make sure the async
-		 * closing has been finished - if so, wouldn't we
-		 * probably better sleep uninterruptible?
-		 */
-
-		if (wait_event_interruptible(self->port.close_wait,
-				!test_bit(ASYNCB_CLOSING, &self->port.flags))) {
-			net_warn_ratelimited("%s - got signal while blocking on ASYNC_CLOSING!\n",
-					     __func__);
-			return -ERESTARTSYS;
-		}
-
-#ifdef SERIAL_DO_RESTART
-		return (self->port.flags & ASYNC_HUP_NOTIFY) ?
-			-EAGAIN : -ERESTARTSYS;
-#else
-		return -EAGAIN;
-#endif
-	}
-
 	/* Check if this is a "normal" ircomm device, or an irlpt device */
 	if (self->line < 0x10) {
 		self->service_type = IRCOMM_3_WIRE | IRCOMM_9_WIRE;
-- 
2.6.1

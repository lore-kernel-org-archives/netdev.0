From: Peter Hurley <peter@hurleysoftware.com>
Subject: [PATCH 4/7] tty: Remove tty_port::close_wait
Date: Sat, 10 Oct 2015 16:00:54 -0400
Message-ID: <1444507257-7513-5-git-send-email-peter@hurleysoftware.com>
References: <1444507257-7513-1-git-send-email-peter@hurleysoftware.com>
Cc: Jiri Slaby <jslaby@suse.cz>, Alan Cox <alan@linux.intel.com>,
	David Laight <David.Laight@aculab.com>,
	Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org,
	linux-serial@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Peter Hurley <peter@hurleysoftware.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:36050 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485AbbJJUB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2015 16:01:27 -0400
Received: by qgx61 with SMTP id 61so94628295qgx.3
        for <netdev@vger.kernel.org>; Sat, 10 Oct 2015 13:01:26 -0700 (PDT)
In-Reply-To: <1444507257-7513-1-git-send-email-peter@hurleysoftware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the removal of tty_wait_until_sent_from_close(), tty drivers
no longer wait during open for parallel closes to complete (instead,
the tty core waits before calling the driver open() method). Thus,
the close_wait waitqueue is no longer used for waiting.

Remove struct tty_port::close_wait.

Signed-off-by: Peter Hurley <peter@hurleysoftware.com>
---
 drivers/tty/rocket.c             | 1 -
 drivers/tty/serial/68328serial.c | 1 -
 drivers/tty/serial/crisv10.c     | 1 -
 drivers/tty/serial/serial_core.c | 1 -
 drivers/tty/tty_port.c           | 2 --
 include/linux/tty.h              | 1 -
 6 files changed, 7 deletions(-)

diff --git a/drivers/tty/rocket.c b/drivers/tty/rocket.c
index 69c72d1..802eac7 100644
--- a/drivers/tty/rocket.c
+++ b/drivers/tty/rocket.c
@@ -1049,7 +1049,6 @@ static void rp_close(struct tty_struct *tty, struct file *filp)
 	mutex_unlock(&port->mutex);
 	tty_port_tty_set(port, NULL);
 
-	wake_up_interruptible(&port->close_wait);
 	complete_all(&info->close_wait);
 	atomic_dec(&rp_num_ports_open);
 
diff --git a/drivers/tty/serial/68328serial.c b/drivers/tty/serial/68328serial.c
index 9ba0c93..0140ba4 100644
--- a/drivers/tty/serial/68328serial.c
+++ b/drivers/tty/serial/68328serial.c
@@ -1071,7 +1071,6 @@ static void rs_close(struct tty_struct *tty, struct file * filp)
 		wake_up_interruptible(&port->open_wait);
 	}
 	port->flags &= ~(ASYNC_NORMAL_ACTIVE|ASYNC_CLOSING);
-	wake_up_interruptible(&port->close_wait);
 	local_irq_restore(flags);
 }
 
diff --git a/drivers/tty/serial/crisv10.c b/drivers/tty/serial/crisv10.c
index 06f4fe9..f13f2eb 100644
--- a/drivers/tty/serial/crisv10.c
+++ b/drivers/tty/serial/crisv10.c
@@ -3655,7 +3655,6 @@ rs_close(struct tty_struct *tty, struct file * filp)
 		wake_up_interruptible(&info->port.open_wait);
 	}
 	info->port.flags &= ~(ASYNC_NORMAL_ACTIVE|ASYNC_CLOSING);
-	wake_up_interruptible(&info->port.close_wait);
 	local_irq_restore(flags);
 
 	/* port closed */
diff --git a/drivers/tty/serial/serial_core.c b/drivers/tty/serial/serial_core.c
index df4271a..def5199 100644
--- a/drivers/tty/serial/serial_core.c
+++ b/drivers/tty/serial/serial_core.c
@@ -1437,7 +1437,6 @@ static void uart_close(struct tty_struct *tty, struct file *filp)
 	clear_bit(ASYNCB_CLOSING, &port->flags);
 	spin_unlock_irq(&port->lock);
 	wake_up_interruptible(&port->open_wait);
-	wake_up_interruptible(&port->close_wait);
 
 	mutex_unlock(&port->mutex);
 
diff --git a/drivers/tty/tty_port.c b/drivers/tty/tty_port.c
index 0e1cf04..e04a8cf 100644
--- a/drivers/tty/tty_port.c
+++ b/drivers/tty/tty_port.c
@@ -22,7 +22,6 @@ void tty_port_init(struct tty_port *port)
 	memset(port, 0, sizeof(*port));
 	tty_buffer_init(port);
 	init_waitqueue_head(&port->open_wait);
-	init_waitqueue_head(&port->close_wait);
 	init_waitqueue_head(&port->delta_msr_wait);
 	mutex_init(&port->mutex);
 	mutex_init(&port->buf_mutex);
@@ -520,7 +519,6 @@ void tty_port_close_end(struct tty_port *port, struct tty_struct *tty)
 		wake_up_interruptible(&port->open_wait);
 	}
 	port->flags &= ~(ASYNC_NORMAL_ACTIVE | ASYNC_CLOSING);
-	wake_up_interruptible(&port->close_wait);
 	spin_unlock_irqrestore(&port->lock, flags);
 }
 EXPORT_SYMBOL(tty_port_close_end);
diff --git a/include/linux/tty.h b/include/linux/tty.h
index 614c822..090ce2a 100644
--- a/include/linux/tty.h
+++ b/include/linux/tty.h
@@ -227,7 +227,6 @@ struct tty_port {
 	int			blocked_open;	/* Waiting to open */
 	int			count;		/* Usage count */
 	wait_queue_head_t	open_wait;	/* Open waiters */
-	wait_queue_head_t	close_wait;	/* Close waiters */
 	wait_queue_head_t	delta_msr_wait;	/* Modem status change */
 	unsigned long		flags;		/* TTY flags ASY_*/
 	unsigned char		console:1,	/* port is a console */
-- 
2.6.1

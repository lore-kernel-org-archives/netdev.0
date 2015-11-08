From: Peter Hurley <peter@hurleysoftware.com>
Subject: [PATCH 4/4] tty: Remove drivers' extra tty_ldisc_flush()
Date: Sun,  8 Nov 2015 17:02:53 -0500
Message-ID: <1447020173-32207-5-git-send-email-peter@hurleysoftware.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:33395 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793AbbKHWDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2015 17:03:13 -0500
Received: by igvi2 with SMTP id i2so64157168igv.0
        for <netdev@vger.kernel.org>; Sun, 08 Nov 2015 14:03:13 -0800 (PST)
In-Reply-To: <1447020173-32207-1-git-send-email-peter@hurleysoftware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tty_port_close_start() helper already flushes the tty and ldisc
buffers on final close; tty drivers which use this helper need not
repeat tty_ldisc_flush().

Signed-off-by: Peter Hurley <peter@hurleysoftware.com>
---
 drivers/char/pcmcia/synclink_cs.c | 3 ---
 drivers/tty/amiserial.c           | 2 --
 drivers/tty/rocket.c              | 2 --
 drivers/tty/serial/serial_core.c  | 2 --
 drivers/tty/synclink.c            | 1 -
 drivers/tty/synclink_gt.c         | 1 -
 drivers/tty/synclinkmp.c          | 1 -
 drivers/tty/tty_port.c            | 2 --
 8 files changed, 14 deletions(-)

diff --git a/drivers/char/pcmcia/synclink_cs.c b/drivers/char/pcmcia/synclink_cs.c
index 45df4bf..3f74677 100644
--- a/drivers/char/pcmcia/synclink_cs.c
+++ b/drivers/char/pcmcia/synclink_cs.c
@@ -2354,10 +2354,7 @@ static void mgslpc_close(struct tty_struct *tty, struct file * filp)
 		mgslpc_wait_until_sent(tty, info->timeout);
 
 	mgslpc_flush_buffer(tty);
-
-	tty_ldisc_flush(tty);
 	shutdown(info, tty);
-	
 	tty_port_close_end(port, tty);
 	tty_port_tty_set(port, NULL);
 cleanup:
diff --git a/drivers/tty/amiserial.c b/drivers/tty/amiserial.c
index 2caaf5a..bffc0a4 100644
--- a/drivers/tty/amiserial.c
+++ b/drivers/tty/amiserial.c
@@ -1420,8 +1420,6 @@ static void rs_close(struct tty_struct *tty, struct file * filp)
 	}
 	shutdown(tty, state);
 	rs_flush_buffer(tty);
-		
-	tty_ldisc_flush(tty);
 	port->tty = NULL;
 
 	tty_port_close_end(port, tty);
diff --git a/drivers/tty/rocket.c b/drivers/tty/rocket.c
index a6b5ce0..5905200 100644
--- a/drivers/tty/rocket.c
+++ b/drivers/tty/rocket.c
@@ -1022,8 +1022,6 @@ static void rp_close(struct tty_struct *tty, struct file *filp)
 		sClrDTR(cp);
 
 	rp_flush_buffer(tty);
-		
-	tty_ldisc_flush(tty);
 
 	clear_bit((info->aiop * 8) + info->chan, (void *) &xmit_flags[info->board]);
 
diff --git a/drivers/tty/serial/serial_core.c b/drivers/tty/serial/serial_core.c
index db27a40..418587f 100644
--- a/drivers/tty/serial/serial_core.c
+++ b/drivers/tty/serial/serial_core.c
@@ -1439,8 +1439,6 @@ static void uart_close(struct tty_struct *tty, struct file *filp)
 	wake_up_interruptible(&port->open_wait);
 
 	mutex_unlock(&port->mutex);
-
-	tty_ldisc_flush(tty);
 }
 
 static void uart_wait_until_sent(struct tty_struct *tty, int timeout)
diff --git a/drivers/tty/synclink.c b/drivers/tty/synclink.c
index 6188059..1334498 100644
--- a/drivers/tty/synclink.c
+++ b/drivers/tty/synclink.c
@@ -3099,7 +3099,6 @@ static void mgsl_close(struct tty_struct *tty, struct file * filp)
  	if (info->port.flags & ASYNC_INITIALIZED)
  		mgsl_wait_until_sent(tty, info->timeout);
 	mgsl_flush_buffer(tty);
-	tty_ldisc_flush(tty);
 	shutdown(info);
 	mutex_unlock(&info->port.mutex);
 
diff --git a/drivers/tty/synclink_gt.c b/drivers/tty/synclink_gt.c
index 5505ea8..1987fb4 100644
--- a/drivers/tty/synclink_gt.c
+++ b/drivers/tty/synclink_gt.c
@@ -729,7 +729,6 @@ static void close(struct tty_struct *tty, struct file *filp)
  	if (info->port.flags & ASYNC_INITIALIZED)
  		wait_until_sent(tty, info->timeout);
 	flush_buffer(tty);
-	tty_ldisc_flush(tty);
 
 	shutdown(info);
 	mutex_unlock(&info->port.mutex);
diff --git a/drivers/tty/synclinkmp.c b/drivers/tty/synclinkmp.c
index fb00a06..fb17dac 100644
--- a/drivers/tty/synclinkmp.c
+++ b/drivers/tty/synclinkmp.c
@@ -816,7 +816,6 @@ static void close(struct tty_struct *tty, struct file *filp)
  		wait_until_sent(tty, info->timeout);
 
 	flush_buffer(tty);
-	tty_ldisc_flush(tty);
 	shutdown(info);
 	mutex_unlock(&info->port.mutex);
 
diff --git a/drivers/tty/tty_port.c b/drivers/tty/tty_port.c
index ecb6435..c30525a 100644
--- a/drivers/tty/tty_port.c
+++ b/drivers/tty/tty_port.c
@@ -503,8 +503,6 @@ void tty_port_close_end(struct tty_port *port, struct tty_struct *tty)
 {
 	unsigned long flags;
 
-	tty_ldisc_flush(tty);
-
 	spin_lock_irqsave(&port->lock, flags);
 
 	if (port->blocked_open) {
-- 
2.6.3

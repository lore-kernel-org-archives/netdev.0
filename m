From: Peter Hurley <peter@hurleysoftware.com>
Subject: [PATCH 3/7] usb: gadget: gserial: Privatize close_wait
Date: Sat, 10 Oct 2015 16:00:53 -0400
Message-ID: <1444507257-7513-4-git-send-email-peter@hurleysoftware.com>
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

close_wait is no longer needed or provided by the tty core.
Move close_wait to struct gs_port.

Signed-off-by: Peter Hurley <peter@hurleysoftware.com>
---
 drivers/usb/gadget/function/u_serial.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/usb/gadget/function/u_serial.c b/drivers/usb/gadget/function/u_serial.c
index 7ee0579..42894f5 100644
--- a/drivers/usb/gadget/function/u_serial.c
+++ b/drivers/usb/gadget/function/u_serial.c
@@ -114,6 +114,7 @@ struct gs_port {
 	struct gs_buf		port_write_buf;
 	wait_queue_head_t	drain_wait;	/* wait while writes drain */
 	bool                    write_busy;
+	wait_queue_head_t	close_wait;
 
 	/* REVISIT this state ... */
 	struct usb_cdc_line_coding port_line_coding;	/* 8-N-1 etc */
@@ -884,7 +885,7 @@ static void gs_close(struct tty_struct *tty, struct file *file)
 	pr_debug("gs_close: ttyGS%d (%p,%p) done!\n",
 			port->port_num, tty, file);
 
-	wake_up(&port->port.close_wait);
+	wake_up(&port->close_wait);
 exit:
 	spin_unlock_irq(&port->port_lock);
 }
@@ -1044,6 +1045,7 @@ gs_port_alloc(unsigned port_num, struct usb_cdc_line_coding *coding)
 	tty_port_init(&port->port);
 	spin_lock_init(&port->port_lock);
 	init_waitqueue_head(&port->drain_wait);
+	init_waitqueue_head(&port->close_wait);
 
 	tasklet_init(&port->push, gs_rx_push, (unsigned long) port);
 
@@ -1074,7 +1076,7 @@ static void gserial_free_port(struct gs_port *port)
 {
 	tasklet_kill(&port->push);
 	/* wait for old opens to finish */
-	wait_event(port->port.close_wait, gs_closed(port));
+	wait_event(port->close_wait, gs_closed(port));
 	WARN_ON(port->port_usb != NULL);
 	tty_port_destroy(&port->port);
 	kfree(port);
-- 
2.6.1

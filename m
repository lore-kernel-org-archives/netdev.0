From: akepner@sgi.com
Subject: [PATCH 2/2] net/tg3.c: use mmiowb in tg3_poll
Date: Tue, 12 Oct 2004 16:39:32 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0410121634350.31839-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Returning from tg3_poll() without flushing the PIO write which 
reenables interrupts can result in lower cpu utilization and higher 
throughput. So use a memory barrier, mmiowb(), instead of flushing the 
write with a PIO read.

Signed-off-by: Arthur Kepner <akepner@sgi.com>
---

--- linux.2/drivers/net/tg3.c	2004-10-12 14:00:40.000000000 -0700
+++ linux/drivers/net/tg3.c	2004-10-12 14:13:02.000000000 -0700
@@ -417,6 +417,20 @@
 	tg3_cond_int(tp);
 }
 
+/* tg3_restart_ints
+ *  similar to tg3_enable_ints, but it can return without flushing the 
+ *  PIO write which reenables interrupts
+ */
+static void tg3_restart_ints(struct tg3 *tp)
+{
+	tw32(TG3PCI_MISC_HOST_CTRL,
+		(tp->misc_host_ctrl & ~MISC_HOST_CTRL_MASK_PCI_INT));
+	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000000);
+	mmiowb();
+
+	tg3_cond_int(tp);
+}
+
 static inline void tg3_netif_stop(struct tg3 *tp)
 {
 	netif_poll_disable(tp->dev);
@@ -2788,7 +2802,7 @@
 	if (done) {
 		spin_lock_irqsave(&tp->lock, flags);
 		__netif_rx_complete(netdev);
-		tg3_enable_ints(tp);
+		tg3_restart_ints(tp);
 		spin_unlock_irqrestore(&tp->lock, flags);
 	}
 
 

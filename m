From: <akepner@sgi.com>
Subject: [PATCH] use mmiowb in tg3_poll
Date: Fri, 22 Oct 2004 13:51:01 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0410221345400.392-100000@localhost.localdomain>
References: <200410211628.06906.jbarnes@engr.sgi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>, <jgarzik@pobox.com>, <davem@davemloft.net>,
        <jbarnes@engr.sgi.com>, <gnb@sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <akpm@osdl.org>, <linux-kernel@vger.kernel.org>
In-Reply-To: <200410211628.06906.jbarnes@engr.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Returning from tg3_poll() without flushing the PIO write which
reenables interrupts can result in lower cpu utilization and higher
throughput. So use a memory barrier, mmiowb(), instead of flushing the
write with a PIO read.

Signed-off-by: Arthur Kepner <akepner@sgi.com>
---

--- linux-2.6.9-rc4-mm1.orig/drivers/net/tg3.c	2004-10-22 13:51:10.000000000 -0700
+++ linux-2.6.9-rc4-mm1/drivers/net/tg3.c	2004-10-22 13:53:36.000000000 -0700
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
@@ -2787,7 +2801,7 @@
 	if (done) {
 		spin_lock_irqsave(&tp->lock, flags);
 		__netif_rx_complete(netdev);
-		tg3_enable_ints(tp);
+		tg3_restart_ints(tp);
 		spin_unlock_irqrestore(&tp->lock, flags);
 	}
 


-- 
Arthur

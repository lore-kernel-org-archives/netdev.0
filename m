From: akpm@osdl.org
Subject: [patch 3/9] use mmiowb in tg3_poll
Date: Thu, 28 Oct 2004 00:19:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410280721.i9S7Le907988@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, akepner@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: <akepner@sgi.com>

Returning from tg3_poll() without flushing the PIO write which reenables
interrupts can result in lower cpu utilization and higher throughput.  So
use a memory barrier, mmiowb(), instead of flushing the write with a PIO
read.

Signed-off-by: Arthur Kepner <akepner@sgi.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/tg3.c |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletion(-)

diff -puN drivers/net/tg3.c~use-mmiowb-in-tg3_poll drivers/net/tg3.c
--- 25/drivers/net/tg3.c~use-mmiowb-in-tg3_poll	2004-10-28 00:17:07.705632552 -0700
+++ 25-akpm/drivers/net/tg3.c	2004-10-28 00:17:07.715631032 -0700
@@ -418,6 +418,20 @@ static void tg3_enable_ints(struct tg3 *
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
@@ -2789,7 +2803,7 @@ static int tg3_poll(struct net_device *n
 	if (done) {
 		spin_lock_irqsave(&tp->lock, flags);
 		__netif_rx_complete(netdev);
-		tg3_enable_ints(tp);
+		tg3_restart_ints(tp);
 		spin_unlock_irqrestore(&tp->lock, flags);
 	}
 
_

From: akepner@sgi.com
Subject: [RFC] using mmiowb() in dev->poll() method
Date: Wed, 6 Oct 2004 11:24:19 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0410061116160.15729-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <davem@redhat.com>, <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


A recent patch which defines an I/O space memory write barrier 
(http://marc.theaimsgroup.com/?l=linux-kernel&m=109649911100740&w=2.)
allows for significant performance improvement in the tg3 driver. 
Although I've only experimented with tg3, the same thing should work 
for other drivers which use NAPI. 

This would mean a slight change to the semantics of the driver's 
polling method, however, which is why I'm sending this patch for 
comments now. The patch below is only an example, and it's not 
intended to be applied in its present form. But once the mmiowb() 
patch gets in, something similar to the following patch could be 
considered. 

Currently, returning 0 from "dev->poll()" indicates that the 
PIO write which enables interrupts has been flushed to the NIC 
(or at least that's my understanding.) The change below allows 
"dev->poll()" to return with that PIO write pending, but not 
necessarily flushed. This allows a potentially expensive PIO 
flush to be avoided. I've found that this can significantly 
reduce CPU utilization and improve throughput. 

On my test system (Altix - using only 1 of 4 CPUs, 1GHz Itanium 2, 
Broadcom 5704 NIC) I got the following the results for one workload 
with and without this patch:

                   CPU Utilization [%]        Throughput [MB/sec]
                   -------------------        -------------------
2.6.5                     100                       110
2.6.5+patch                80                       124

That's the best case performance improvement, but there's no case 
where performance suffers from this change.

8<--------------------- tg3_poll.mmiowb.patch ---------------------

--- linux.orig/drivers/net/tg3.c	2004-10-06 09:26:04.000000000 -0700
+++ linux/drivers/net/tg3.c	2004-10-06 10:22:38.000000000 -0700
@@ -345,6 +345,9 @@
 #define tr16(reg)		readw(tp->regs + (reg))
 #define tr8(reg)		readb(tp->regs + (reg))
 
+#define mmiowb()		sn_mmiob() /* XXX this goes away once mmiowb() 
+				            * is available for all arches */
+
 static void tg3_write_mem(struct tg3 *tp, u32 off, u32 val)
 {
 	unsigned long flags;
@@ -395,6 +398,20 @@
 	tg3_cond_int(tp);
 }
 
+/* tg3_restart_ints()
+ * similar to tg3_enable_ints(), but it can return before the write which 
+ * will enable interrupts has reached the card.
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
@@ -2489,7 +2506,7 @@
 	if (done) {
 		spin_lock_irqsave(&tp->lock, flags);
 		__netif_rx_complete(netdev);
-		tg3_enable_ints(tp);
+		tg3_restart_ints(tp);
 		spin_unlock_irqrestore(&tp->lock, flags);
 	}
 

8<-----------------------------------------------------------------

Comments?

-- 
Arthur

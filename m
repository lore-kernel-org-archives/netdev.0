From: Vinay K Nallamothu <vinay-rc@naturesoft.net>
Subject: [PATCH 2.6.0-test4][NET] ni5010.c: remove cli/sti
Date: 24 Aug 2003 20:37:04 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1061737624.1288.9.camel@lima.royalchallenge.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

drivers/net/ni5010.c:
This patch replaces cli/sti with spinlocks. Compiles fine though
untested.

Vinay

--- linux-2.6.0-test4/drivers/net/ni5010.c	2003-07-15 17:22:18.000000000 +0530
+++ linux-2.6.0-test4-nvk/drivers/net/ni5010.c	2003-08-24 20:29:35.000000000 +0530
@@ -96,6 +96,7 @@
 	struct net_device_stats stats;
 	int o_pkt_size;
 	int i_pkt_size;
+	spinlock_t tx_lock;
 };
 
 /* Index to functions, as function prototypes. */
@@ -280,11 +281,16 @@
 	/* DMA is not supported (yet?), so no use detecting it */
 
 	if (dev->priv == NULL) {
+		struct ni5010_local* lp;
+
 		dev->priv = kmalloc(sizeof(struct ni5010_local), GFP_KERNEL|GFP_DMA);
 		if (dev->priv == NULL) {
 			printk(KERN_WARNING "%s: Failed to allocate private memory\n", dev->name);
 			return -ENOMEM;
 		}
+
+		lp = (struct ni5010_local*)dev->priv;
+		spin_lock_init(&lp->tx_lock);
 	}
 
 	PRINTK2((KERN_DEBUG "%s: I/O #10 passed!\n", dev->name));
@@ -693,8 +699,7 @@
         buf_offs = NI5010_BUFSIZE - length - pad;
         lp->o_pkt_size = length + pad;
 
-	save_flags(flags);	
-	cli();
+	spin_lock_irqsave(&lp->tx_lock, flags);
 
 	outb(0, EDLC_RMASK);	/* Mask all receive interrupts */
 	outb(0, IE_MMODE);	/* Put Xmit buffer on system bus */
@@ -712,7 +717,7 @@
 	outb(MM_EN_XMT | MM_MUX, IE_MMODE); /* Begin transmission */
 	outb(XM_ALL, EDLC_XMASK); /* Cause interrupt after completion or fail */
 
-	restore_flags(flags);
+	spin_unlock_irqrestore(&lp->tx_lock, flags);
 
 	netif_wake_queue(dev);
 	

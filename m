From: Michele 'mydecay' Marchetto <smarchetto1@tin.it>
Subject: 3c59x 2.6 napi patch
Date: 21 Sep 2003 17:22:54 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <1064157774.942.3.camel@localhost>
Reply-To: smarchetto1@tin.it
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-IibwKLao1tB7u9ri9T2x"
Return-path: <linux-net-owner@vger.kernel.org>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-IibwKLao1tB7u9ri9T2x
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

hi all

this is the trivial patch to get napi work on 2.6.
it is designed for 3com 3c59x nic series.

regards

-- 
Michele 'mydecay' Marchetto
S.P.I.N.E. Group - www.spine-group.org


--=-IibwKLao1tB7u9ri9T2x
Content-Disposition: attachment; filename=3c59x.diff
Content-Type: text/plain; name=3c59x.diff; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 7bit

--- 3c59x.c.old	2003-09-08 20:29:52.000000000 +0200
+++ 3c59x.c	2003-09-21 16:58:40.451344112 +0200
@@ -204,7 +204,7 @@
 /* A few values that may be tweaked. */
 /* Keep the ring sizes a power of two for efficiency. */
 #define TX_RING_SIZE	16
-#define RX_RING_SIZE	32
+#define RX_RING_SIZE	128
 #define PKT_BUF_SZ		1536			/* Size of each temporary Rx buffer.*/
 
 /* "Knobs" that adjust features and parameters. */
@@ -889,7 +889,7 @@
 static int vortex_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static int boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static int vortex_rx(struct net_device *dev);
-static int boomerang_rx(struct net_device *dev);
+static int boomerang_poll(struct net_device *dev, int *budget);
 static irqreturn_t vortex_interrupt(int irq, void *dev_id, struct pt_regs *regs);
 static irqreturn_t boomerang_interrupt(int irq, void *dev_id, struct pt_regs *regs);
 static int vortex_close(struct net_device *dev);
@@ -1419,6 +1419,8 @@
 		}
 		vp->full_bus_master_rx = (vp->info2 & 1) ? 1 : 2;
 		vp->bus_master = 0;		/* AKPM: vortex only */
+		dev->poll = boomerang_poll;
+		dev->weight = 16;
 	}
 
 	/* The 3c59x-specific entries in the device structure. */
@@ -2004,7 +2006,7 @@
 			printk(KERN_WARNING "%s: Updating statistics failed, disabling "
 				   "stats as an interrupt source.\n", dev->name);
 			EL3WINDOW(5);
-			outw(SetIntrEnb | (inw(ioaddr + 10) & ~StatsFull), ioaddr + EL3_CMD);
+			outw(vp->intr_enable, ioaddr + EL3_CMD);			
 			vp->intr_enable &= ~StatsFull;
 			EL3WINDOW(7);
 			DoneDidThat++;
@@ -2306,6 +2308,57 @@
 	return IRQ_RETVAL(handled);
 }
 
+inline int tx_ring_free(struct net_device *dev)
+{
+       struct vortex_private *vp = (struct vortex_private *)dev->priv;
+       int tx = 0;
+       unsigned int dirty_tx = vp->dirty_tx;
+       long ioaddr = dev->base_addr;
+
+       while (vp->cur_tx - dirty_tx > 0) {
+               int entry = dirty_tx % TX_RING_SIZE;
+#if 1  /* AKPM: the latter is faster, but cyclone-only */
+               if (inl(ioaddr + DownListPtr) ==
+                       vp->tx_ring_dma + entry * sizeof(struct boom_tx_desc))
+                       break;                  /* It still hasn't been processed. */
+#else
+               if ((vp->tx_ring[entry].status & DN_COMPLETE) == 0)
+                       break;                  /* It still hasn't been processed. */
+#endif
+                       
+               if (vp->tx_skbuff[entry]) {
+                       struct sk_buff *skb = vp->tx_skbuff[entry];
+#if DO_ZEROCOPY                                        
+                       int i;
+                       for (i=0; i<=skb_shinfo(skb)->nr_frags; i++)
+                                       pci_unmap_single(VORTEX_PCI(vp),
+                                                                        le32_to_cpu(vp->tx_ring[entry].frag[i].addr),
+                                                                        le32_to_cpu(vp->tx_ring[entry].frag[i].length)&0xFFF,
+                                                                        PCI_DMA_TODEVICE);
+#else
+                       pci_unmap_single(vp->pdev,
+                               le32_to_cpu(vp->tx_ring[entry].addr), skb->len, PCI_DMA_TODEVICE);
+#endif
+                       dev_kfree_skb_irq(skb);
+                       vp->tx_skbuff[entry] = 0;
+               } else {
+                       printk(KERN_DEBUG "boomerang_interrupt: no skb!\n");
+               }
+               /* vp->stats.tx_packets++;  Counted below. */
+               dirty_tx++;
+               tx++;
+       }
+
+       if (vp->cur_tx - dirty_tx <= TX_RING_SIZE - 1) {
+               if (vortex_debug > 6)
+                       printk(KERN_DEBUG "boomerang_interrupt: wake queue\n");
+               netif_wake_queue (dev);
+       }
+
+       vp->dirty_tx = dirty_tx;
+       return tx;
+}
+
 /*
  * This is the ISR for the boomerang series chips.
  * full_bus_master_tx == 1 && full_bus_master_rx == 1
@@ -2352,57 +2405,24 @@
 			   dev->name, status, inb(ioaddr + Timer));
 	do {
 		if (vortex_debug > 5)
-				printk(KERN_DEBUG "%s: In interrupt loop, status %4.4x.\n",
-					   dev->name, status);
+                       printk(KERN_DEBUG "%s: In interrupt loop, status %4.4x.\n",
+                                  dev->name, status);
+
 		if (status & UpComplete) {
 			outw(AckIntr | UpComplete, ioaddr + EL3_CMD);
-			if (vortex_debug > 5)
-				printk(KERN_DEBUG "boomerang_interrupt->boomerang_rx\n");
-			boomerang_rx(dev);
+                       if (netif_rx_schedule_prep(dev)) {
+                               /* Do masking under poll protection. */
+                               vp->intr_enable &= ~(UpComplete | StatsFull);
+                               outw(vp->intr_enable, ioaddr + EL3_CMD);
+                               if (vortex_debug > 5)
+                                       printk(KERN_DEBUG "boomerang_interrupt->boomerang_rx\n");
+                               __netif_rx_schedule(dev);
+                       }
 		}
 
 		if (status & DownComplete) {
-			unsigned int dirty_tx = vp->dirty_tx;
-
 			outw(AckIntr | DownComplete, ioaddr + EL3_CMD);
-			while (vp->cur_tx - dirty_tx > 0) {
-				int entry = dirty_tx % TX_RING_SIZE;
-#if 1	/* AKPM: the latter is faster, but cyclone-only */
-				if (inl(ioaddr + DownListPtr) ==
-					vp->tx_ring_dma + entry * sizeof(struct boom_tx_desc))
-					break;			/* It still hasn't been processed. */
-#else
-				if ((vp->tx_ring[entry].status & DN_COMPLETE) == 0)
-					break;			/* It still hasn't been processed. */
-#endif
-					
-				if (vp->tx_skbuff[entry]) {
-					struct sk_buff *skb = vp->tx_skbuff[entry];
-#if DO_ZEROCOPY					
-					int i;
-					for (i=0; i<=skb_shinfo(skb)->nr_frags; i++)
-							pci_unmap_single(VORTEX_PCI(vp),
-											 le32_to_cpu(vp->tx_ring[entry].frag[i].addr),
-											 le32_to_cpu(vp->tx_ring[entry].frag[i].length)&0xFFF,
-											 PCI_DMA_TODEVICE);
-#else
-					pci_unmap_single(VORTEX_PCI(vp),
-						le32_to_cpu(vp->tx_ring[entry].addr), skb->len, PCI_DMA_TODEVICE);
-#endif
-					dev_kfree_skb_irq(skb);
-					vp->tx_skbuff[entry] = 0;
-				} else {
-					printk(KERN_DEBUG "boomerang_interrupt: no skb!\n");
-				}
-				/* vp->stats.tx_packets++;  Counted below. */
-				dirty_tx++;
-			}
-			vp->dirty_tx = dirty_tx;
-			if (vp->cur_tx - dirty_tx <= TX_RING_SIZE - 1) {
-				if (vortex_debug > 6)
-					printk(KERN_DEBUG "boomerang_interrupt: wake queue\n");
-				netif_wake_queue (dev);
-			}
+			tx_ring_free(dev);
 		}
 
 		/* Check for all uncommon interrupts at once. */
@@ -2508,20 +2528,62 @@
 }
 
 static int
-boomerang_rx(struct net_device *dev)
+boomerang_refill_rx(struct net_device *dev)
+{
+       struct vortex_private *vp = (struct vortex_private *)dev->priv;
+       long ioaddr = dev->base_addr;
+       int entry;
+       int refilled = 0;
+
+       /* Refill the Rx ring buffers. */
+       for (; vp->cur_rx - vp->dirty_rx > 0; vp->dirty_rx++) {
+               struct sk_buff *skb;
+               entry = vp->dirty_rx % RX_RING_SIZE;
+               if (vp->rx_skbuff[entry] == NULL) {
+                       skb = dev_alloc_skb(PKT_BUF_SZ);
+                       if (skb == NULL)
+                               break;
+
+                       skb->dev = dev;                 /* Mark as being used by this device. */
+                       skb_reserve(skb, 2);    /* Align IP on 16 byte boundaries */
+               vp->rx_ring[entry].addr = cpu_to_le32(pci_map_single(VORTEX_PCI(vp), skb->tail, PKT_BUF_SZ, PCI_DMA_FROMDEVICE));
+                       vp->rx_skbuff[entry] = skb;
+
+                       refilled++;
+               }
+               vp->rx_ring[entry].status = 0;  /* Clear complete bit. */
+               outw(UpUnstall, ioaddr + EL3_CMD);
+       }
+
+       /* @@@ restart RX ? */
+
+       return refilled;
+}
+
+static int
+boomerang_poll(struct net_device *dev, int *budget)
 {
 	struct vortex_private *vp = (struct vortex_private *)dev->priv;
 	int entry = vp->cur_rx % RX_RING_SIZE;
 	long ioaddr = dev->base_addr;
 	int rx_status;
-	int rx_work_limit = vp->dirty_rx + RX_RING_SIZE - vp->cur_rx;
+        int rx_work_limit = *budget;
+        int received = 0;
+
 
 	if (vortex_debug > 5)
 		printk(KERN_DEBUG "boomerang_rx(): status %4.4x\n", inw(ioaddr+EL3_STATUS));
 
+        if (rx_work_limit > dev->quota)
+                rx_work_limit = dev->quota;
+ 
+restart:
+
 	while ((rx_status = le32_to_cpu(vp->rx_ring[entry].status)) & RxDComplete){
-		if (--rx_work_limit < 0)
+                if (vp->dirty_rx + RX_RING_SIZE == vp->cur_rx)
 			break;
+                if (--rx_work_limit < 0)
+                        goto not_done;
 		if (rx_status & RxDError) { /* Error, update stats. */
 			unsigned char rx_error = rx_status >> 16;
 			if (vortex_debug > 2)
@@ -2571,38 +2633,111 @@
 					vp->rx_csumhits++;
 				}
 			}
-			netif_rx(skb);
+			netif_receive_skb(skb);
 			dev->last_rx = jiffies;
 			vp->stats.rx_packets++;
 		}
+		received++;
+		
 		entry = (++vp->cur_rx) % RX_RING_SIZE;
+		                if (vp->cur_rx - vp->dirty_rx > RX_RING_SIZE/4)
+		                        boomerang_refill_rx(dev);
 	}
-	/* Refill the Rx ring buffers. */
-	for (; vp->cur_rx - vp->dirty_rx > 0; vp->dirty_rx++) {
-		struct sk_buff *skb;
-		entry = vp->dirty_rx % RX_RING_SIZE;
-		if (vp->rx_skbuff[entry] == NULL) {
-			skb = dev_alloc_skb(PKT_BUF_SZ);
-			if (skb == NULL) {
-				static unsigned long last_jif;
-				if ((jiffies - last_jif) > 10 * HZ) {
-					printk(KERN_WARNING "%s: memory shortage\n", dev->name);
-					last_jif = jiffies;
-				}
-				if ((vp->cur_rx - vp->dirty_rx) == RX_RING_SIZE)
-					mod_timer(&vp->rx_oom_timer, RUN_AT(HZ * 1));
-				break;			/* Bad news!  */
-			}
-			skb->dev = dev;			/* Mark as being used by this device. */
-			skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
-			vp->rx_ring[entry].addr = cpu_to_le32(pci_map_single(VORTEX_PCI(vp), skb->tail, PKT_BUF_SZ, PCI_DMA_FROMDEVICE));
-			vp->rx_skbuff[entry] = skb;
-		}
-		vp->rx_ring[entry].status = 0;	/* Clear complete bit. */
-		outw(UpUnstall, ioaddr + EL3_CMD);
+
+        boomerang_refill_rx(dev);
+        if (vp->rx_skbuff[vp->dirty_rx % RX_RING_SIZE] == NULL)
+                goto oom;
+ 
+ #if 0
+        /* @@@ disable receive interrupt */
+        if (jiffies - dev->last_rx == 0) {
+                vp->intr_enable &= ~(UpComplete | StatsFull);
+                outw(vp->intr_enable, ioaddr + EL3_CMD);
+                goto not_done;
 	}
-	return 0;
-}
+#endif
+
+/* MAJOR QUESTION: I see this driver uses vp->lock even around __RX__ intrs!
+ * If this is really necessary, it is fatal flaw. I am afraid such device
+ * cannot be handled with NAPI at all. Or for beginning this funny lock
+ * is to be removed for normal irq driven case.
+ */
+
+/* So, I assume that 3c95x loses irqs when being with disabled intrs
+ * (but still hope that the assumption is wrong and this is not required.
+ * Lennert, did you really try the scheme exactly matching tulip?
+ * Actually, I see one place where boomerang could lose irq even if semantics
+ * of its irq mask is right i.e. tulip-like. It is vp->intr_enable.
+ * Tulip does _not_ hold mirror of irq mask in a state variable. See?
+ * 3com does and hence can occasionally corrupt it while concurrent ands/ors.
+ * If you remove clearing of rx bits in vp->intr_enable, it can be repaired
+ * without ugly tricks).
+ *
+ * OK. Assume the worst variant.
+ */
+
+        /* ALL THE STATE UPDATES MUST be done before netif_rx_complete(),
+         * which releases the device for another contexts. */
+ 
+         dev->quota -= received;
+ 
+        /* Change intr_enable in context serialized wrt irq. See also above.
+         * However look at vortex_error... intr_enable is changed there too... */
+
+        vp->intr_enable |= UpComplete | StatsFull;              /* @@@ */
+        outw(vp->intr_enable, ioaddr + EL3_CMD);
+
+        netif_rx_complete(dev);
+        /* ---< now this function can be reentered on another cpu. */
+
+        /* In the case of misfortune (packet arrived in race window), we
+         * try to reschedule poll. If the irq already arrived and this happened
+         * after netif_rx_complete() released device poll is already scheduled
+         * (on this or on another cpu) and we just return. Otherwise, we undo
+         * state changes and return to ring processing until quota exhausts.
+         *
+         * WARNING. IRQ status cannot be checked here, because irq handler
+         * has to reset it before exit from irq handler no matter poll is
+         * scheduled or it did not.
+         */
+
+        if ((le32_to_cpu(vp->rx_ring[vp->cur_rx % RX_RING_SIZE].status) & RxDComplete)
+                && vp->dirty_rx + RX_RING_SIZE != vp->cur_rx
+                && netif_rx_reschedule(dev, received)) {
+                /* ACK may be pure loss of time. */ 
+                outw(AckIntr | UpComplete, ioaddr + EL3_CMD);
+                vp->intr_enable &= ~(UpComplete | StatsFull);
+                outw(vp->intr_enable, ioaddr + EL3_CMD);
+                entry = vp->cur_rx % RX_RING_SIZE;
+                goto restart;
+        }
+ 
+        *budget -= received;
+ 
+        return 0;
+
+not_done:
+        if (vp->cur_rx - vp->dirty_rx > RX_RING_SIZE/2 ||
+            vp->rx_skbuff[vp->dirty_rx % RX_RING_SIZE] == NULL)
+                boomerang_refill_rx(dev);
+
+        if (!received)
+                received = dev->quota;
+
+        dev->quota -= received;
+        *budget -= received;
+
+        return 1;
+
+oom:
+        if (vortex_debug > 1)
+                printk(KERN_WARNING "%s: in rx suspend mode\n", dev->name);
+
+        mod_timer(&vp->rx_oom_timer, RUN_AT(HZ * 1));
+        netif_rx_complete(dev);
+
+        return 0;
+ }
 
 /*
  * If we've hit a total OOM refilling the Rx ring we poll once a second
@@ -2612,16 +2747,35 @@
 rx_oom_timer(unsigned long arg)
 {
 	struct net_device *dev = (struct net_device *)arg;
+#if 0
 	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	int budget = 1;
+	
+/********************* FULL SHIT!!! ***********************************
+ boomerang_poll cannot be called with vp->lock held, it is 100% deadlock.
+ Also, it cannot be called with irq disabled, it is 100% crash.
+ BTW: no doubts it is the case when Lennert saw BUG() asserting
+ unscheduled poll, this boomerang_poll is surely unscheduled.
+ **********************************************************************/ 
+        spin_lock_irq(&vp->lock);
 
-	spin_lock_irq(&vp->lock);
 	if ((vp->cur_rx - vp->dirty_rx) == RX_RING_SIZE)	/* This test is redundant, but makes me feel good */
-		boomerang_rx(dev);
+		boomerang_poll(dev, &budget);
 	if (vortex_debug > 1) {
 		printk(KERN_DEBUG "%s: rx_oom_timer %s\n", dev->name,
 			((vp->cur_rx - vp->dirty_rx) != RX_RING_SIZE) ? "succeeded" : "retrying");
 	}
 	spin_unlock_irq(&vp->lock);
+#else
+        /* Essentially, this is all, which is possible to make here. */
+        netif_rx_schedule(dev);
+ 
+        /* Robert, oom_timer in tilip of 011015 suffers of similar desease.
+         * We _cannot_ refill ring from timer not serializing it wrt refill from
+         * poll and/or irq. So, either add necessary locking bits f.e. like
+         * it is made in acenic or return to tulip's internal timer.
+      */
+#endif
 }
 
 static void

--=-IibwKLao1tB7u9ri9T2x--


From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Fw: [BUG/PATCH] CONFIG_NET_HW_FLOWCONTROL and SMP
Date: Thu, 2 Oct 2003 17:31:30 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16252.17618.866515.952549@robur.slu.se>
References: <20030929123734.5bd97a47.akpm@osdl.org>
	<16248.41796.797321.700866@robur.slu.se>
	<3F78A691.1040406@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, Andrew Morton <akpm@osdl.org>,
        netdev@oss.sgi.com, dfages@arkoon.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F78A691.1040406@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Jeff Garzik writes:
 > 
 > If someone had a NAPI patch for tulip, we could remove HW_FLOWCONTROL 
 > option altogether :)

Hello!
Here is something for 2.6.0-test6:

* ifdef's to keep current non-NAPI tulip intact

* Port based on Alexey's orig NAPI tulip design
  (Only RX handled by dev->poll)

* tulip HW_FLOW removed

* NAPI and HW-mitigation options in Kconfig

Cheers
						--ro


--- drivers/net/tulip.orig/Kconfig	2003-09-28 02:50:39.000000000 +0200
+++ drivers/net/tulip/Kconfig	2003-09-30 14:34:39.000000000 +0200
@@ -68,6 +68,26 @@
 	  obscure bugs if your mainboard has memory controller timing issues.
 	  If in doubt, say N.
 
+config TULIP_NAPI
+	bool "Use NAPI RX polling "
+	depends on TULIP
+	---help---
+	  This is of useful for servers and routers dealing with high network loads.
+ 
+	  See <file:Documentation/networking/NAPI_HOWTO.txt>.
+
+	  If in doubt, say N.
+
+config TULIP_NAPI_HW_MITIGATION
+	bool "Use Interrupt Mitigation "
+	depends on TULIP_NAPI
+	---help---
+	  Use HW to reduce RX interrupts. Not strict necessary since NAPI reduces
+	  RX interrupts but itself. Although this reduces RX interrupts even at
+	  low levels traffic at the cost of a small latency.
+
+	  If in doubt, say Y.
+
 config DE4X5
 	tristate "Generic DECchip & DIGITAL EtherWORKS PCI/EISA"
 	depends on NET_TULIP && (PCI || EISA)
--- drivers/net/tulip.orig/tulip.h	2003-09-28 02:51:02.000000000 +0200
+++ drivers/net/tulip/tulip.h	2003-09-30 14:22:08.000000000 +0200
@@ -126,6 +126,7 @@
 	CFDD_Snooze = (1 << 30),
 };
 
+#define RxPollInt (RxIntr|RxNoBuf|RxDied|RxJabber)
 
 /* The bits in the CSR5 status registers, mostly interrupt sources. */
 enum status_bits {
@@ -251,9 +252,9 @@
    Making the Tx ring too large decreases the effectiveness of channel
    bonding and packet priority.
    There are no ill effects from too-large receive rings. */
-#define TX_RING_SIZE	16
-#define RX_RING_SIZE	32
 
+#define TX_RING_SIZE	32
+#define RX_RING_SIZE	128 
 #define MEDIA_MASK     31
 
 #define PKT_BUF_SZ		1536	/* Size of each temporary Rx buffer. */
@@ -343,17 +344,15 @@
 	int flags;
 	struct net_device_stats stats;
 	struct timer_list timer;	/* Media selection timer. */
+	struct timer_list oom_timer;    /* Out of memory timer. */
 	u32 mc_filter[2];
 	spinlock_t lock;
 	spinlock_t mii_lock;
 	unsigned int cur_rx, cur_tx;	/* The next free ring entry */
 	unsigned int dirty_rx, dirty_tx;	/* The ring entries to be free()ed. */
 
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-#define RX_A_NBF_STOP 0xffffff3f /* To disable RX and RX-NOBUF ints. */
-        int fc_bit;
-        int mit_sel;
-        int mit_change; /* Signal for Interrupt Mitigtion */
+#ifdef 	CONFIG_TULIP_NAPI_HW_MITIGATION
+        int mit_on;
 #endif
 	unsigned int full_duplex:1;	/* Full-duplex operation requested. */
 	unsigned int full_duplex_lock:1;
@@ -415,6 +414,10 @@
 extern int tulip_rx_copybreak;
 irqreturn_t tulip_interrupt(int irq, void *dev_instance, struct pt_regs *regs);
 int tulip_refill_rx(struct net_device *dev);
+#ifdef CONFIG_TULIP_NAPI
+int tulip_poll(struct net_device *dev, int *budget);
+#endif
+
 
 /* media.c */
 int tulip_mdio_read(struct net_device *dev, int phy_id, int location);
@@ -438,6 +441,7 @@
 extern const char * const medianame[];
 extern const char tulip_media_cap[];
 extern struct tulip_chip_table tulip_tbl[];
+void oom_timer(unsigned long data);
 extern u8 t21040_csr13[];
 
 #ifndef USE_IO_OPS
--- drivers/net/tulip.orig/tulip_core.c	2003-09-28 02:50:29.000000000 +0200
+++ drivers/net/tulip/tulip_core.c	2003-09-30 14:29:11.000000000 +0200
@@ -14,11 +14,17 @@
 
 */
 
+#include <linux/config.h>
+
 #define DRV_NAME	"tulip"
+#ifdef CONFIG_TULIP_NAPI
+#define DRV_VERSION    "1.1.13-NAPI" /* Keep at least for test */
+#else
 #define DRV_VERSION	"1.1.13"
+#endif
 #define DRV_RELDATE	"May 11, 2002"
 
-#include <linux/config.h>
+
 #include <linux/module.h>
 #include "tulip.h"
 #include <linux/pci.h>
@@ -465,29 +471,16 @@
 	   to an alternate media type. */
 	tp->timer.expires = RUN_AT(next_tick);
 	add_timer(&tp->timer);
-}
-
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-/* Enable receiver */
-void tulip_xon(struct net_device *dev)
-{
-        struct tulip_private *tp = (struct tulip_private *)dev->priv;
-
-        clear_bit(tp->fc_bit, &netdev_fc_xoff);
-        if (netif_running(dev)){
-
-                tulip_refill_rx(dev);
-                outl(tulip_tbl[tp->chip_id].valid_intrs,  dev->base_addr+CSR7);
-        }
-}
+#ifdef CONFIG_TULIP_NAPI
+	init_timer(&tp->oom_timer);
+        tp->oom_timer.data = (unsigned long)dev;
+        tp->oom_timer.function = oom_timer;
 #endif
+}
 
 static int
 tulip_open(struct net_device *dev)
 {
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-        struct tulip_private *tp = (struct tulip_private *)dev->priv;
-#endif
 	int retval;
 
 	if ((retval = request_irq(dev->irq, &tulip_interrupt, SA_SHIRQ, dev->name, dev)))
@@ -497,10 +490,6 @@
 
 	tulip_up (dev);
 
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-        tp->fc_bit = netdev_register_fc(dev, tulip_xon);
-#endif
-
 	netif_start_queue (dev);
 
 	return 0;
@@ -581,10 +570,7 @@
 #endif
 
 	/* Stop and restart the chip's Tx processes . */
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-        if (tp->fc_bit && test_bit(tp->fc_bit,&netdev_fc_xoff))
-                printk("BUG tx_timeout restarting rx when fc on\n");
-#endif
+
 	tulip_restart_rxtx(tp);
 	/* Trigger an immediate transmit demand. */
 	outl(0, ioaddr + CSR1);
@@ -741,7 +727,9 @@
 	unsigned long flags;
 
 	del_timer_sync (&tp->timer);
-
+#ifdef CONFIG_TULIP_NAPI
+	del_timer_sync (&tp->oom_timer);
+#endif
 	spin_lock_irqsave (&tp->lock, flags);
 
 	/* Disable interrupts by clearing the interrupt mask. */
@@ -780,13 +768,6 @@
 
 	netif_stop_queue (dev);
 
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-        if (tp->fc_bit) {
-                int bit = tp->fc_bit;
-                tp->fc_bit = 0;
-                netdev_unregister_fc(bit);
-        }
-#endif
 	tulip_down (dev);
 
 	if (tulip_debug > 1)
@@ -1627,6 +1608,10 @@
 	dev->hard_start_xmit = tulip_start_xmit;
 	dev->tx_timeout = tulip_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
+#ifdef CONFIG_TULIP_NAPI
+	dev->poll = tulip_poll;
+	dev->weight = 16;
+#endif
 	dev->stop = tulip_close;
 	dev->get_stats = tulip_get_stats;
 	dev->do_ioctl = private_ioctl;
--- drivers/net/tulip.orig/interrupt.c	2003-09-28 02:50:14.000000000 +0200
+++ drivers/net/tulip/interrupt.c	2003-09-30 17:47:12.000000000 +0200
@@ -19,13 +19,13 @@
 #include <linux/etherdevice.h>
 #include <linux/pci.h>
 
-
 int tulip_rx_copybreak;
 unsigned int tulip_max_interrupt_work;
 
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-
+#ifdef CONFIG_TULIP_NAPI_HW_MITIGATION
 #define MIT_SIZE 15
+#define MIT_TABLE 15 /* We use 0 or max */
+
 unsigned int mit_table[MIT_SIZE+1] =
 {
         /*  CRS11 21143 hardware Mitigation Control Interrupt
@@ -99,16 +99,25 @@
 	return refilled;
 }
 
+#ifdef CONFIG_TULIP_NAPI
 
-static int tulip_rx(struct net_device *dev)
+void oom_timer(unsigned long data)
+{
+        struct net_device *dev = (struct net_device *)data;
+	netif_rx_schedule(dev);
+}
+
+int tulip_poll(struct net_device *dev, int *budget)
 {
 	struct tulip_private *tp = (struct tulip_private *)dev->priv;
 	int entry = tp->cur_rx % RX_RING_SIZE;
-	int rx_work_limit = tp->dirty_rx + RX_RING_SIZE - tp->cur_rx;
+	int rx_work_limit = *budget;
 	int received = 0;
 
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-        int drop = 0, mit_sel = 0;
+	if (rx_work_limit > dev->quota)
+		rx_work_limit = dev->quota;
+
+#ifdef CONFIG_TULIP_NAPI_HW_MITIGATION
 
 /* that one buffer is needed for mit activation; or might be a
    bug in the ring buffer code; check later -- JHS*/
@@ -119,6 +128,237 @@
 	if (tulip_debug > 4)
 		printk(KERN_DEBUG " In tulip_rx(), entry %d %8.8x.\n", entry,
 			   tp->rx_ring[entry].status);
+
+       do {
+               /* Acknowledge current RX interrupt sources. */
+               outl((RxIntr | RxNoBuf), dev->base_addr + CSR5);
+ 
+ 
+               /* If we own the next entry, it is a new packet. Send it up. */
+               while ( ! (tp->rx_ring[entry].status & cpu_to_le32(DescOwned))) {
+                       s32 status = le32_to_cpu(tp->rx_ring[entry].status);
+ 
+ 
+                       if (tp->dirty_rx + RX_RING_SIZE == tp->cur_rx)
+                               break;
+ 
+                       if (tulip_debug > 5)
+                               printk(KERN_DEBUG "%s: In tulip_rx(), entry %d %8.8x.\n",
+                                      dev->name, entry, status);
+                       if (--rx_work_limit < 0)
+                               goto not_done;
+ 
+                       if ((status & 0x38008300) != 0x0300) {
+                               if ((status & 0x38000300) != 0x0300) {
+                                /* Ingore earlier buffers. */
+                                       if ((status & 0xffff) != 0x7fff) {
+                                               if (tulip_debug > 1)
+                                                       printk(KERN_WARNING "%s: Oversized Ethernet frame "
+                                                              "spanned multiple buffers, status %8.8x!\n",
+                                                              dev->name, status);
+                                               tp->stats.rx_length_errors++;
+                                       }
+                               } else if (status & RxDescFatalErr) {
+                                /* There was a fatal error. */
+                                       if (tulip_debug > 2)
+                                               printk(KERN_DEBUG "%s: Receive error, Rx status %8.8x.\n",
+                                                      dev->name, status);
+                                       tp->stats.rx_errors++; /* end of a packet.*/
+                                       if (status & 0x0890) tp->stats.rx_length_errors++;
+                                       if (status & 0x0004) tp->stats.rx_frame_errors++;
+                                       if (status & 0x0002) tp->stats.rx_crc_errors++;
+                                       if (status & 0x0001) tp->stats.rx_fifo_errors++;
+                               }
+                       } else {
+                               /* Omit the four octet CRC from the length. */
+                               short pkt_len = ((status >> 16) & 0x7ff) - 4;
+                               struct sk_buff *skb;
+  
+#ifndef final_version
+                               if (pkt_len > 1518) {
+                                       printk(KERN_WARNING "%s: Bogus packet size of %d (%#x).\n",
+                                              dev->name, pkt_len, pkt_len);
+                                       pkt_len = 1518;
+                                       tp->stats.rx_length_errors++;
+                               }
+#endif
+                               /* Check if the packet is long enough to accept without copying
+                                  to a minimally-sized skbuff. */
+                               if (pkt_len < tulip_rx_copybreak
+                                   && (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+                                       skb->dev = dev;
+                                       skb_reserve(skb, 2);    /* 16 byte align the IP header */
+                                       pci_dma_sync_single(tp->pdev,
+                                                           tp->rx_buffers[entry].mapping,
+                                                           pkt_len, PCI_DMA_FROMDEVICE);
+#if ! defined(__alpha__)
+                                       eth_copy_and_sum(skb, tp->rx_buffers[entry].skb->tail,
+                                                        pkt_len, 0);
+                                       skb_put(skb, pkt_len);
+#else
+                                       memcpy(skb_put(skb, pkt_len),
+                                              tp->rx_buffers[entry].skb->tail,
+                                              pkt_len);
+#endif
+                               } else {        /* Pass up the skb already on the Rx ring. */
+                                       char *temp = skb_put(skb = tp->rx_buffers[entry].skb,
+                                                            pkt_len);
+  
+#ifndef final_version
+                                       if (tp->rx_buffers[entry].mapping !=
+                                           le32_to_cpu(tp->rx_ring[entry].buffer1)) {
+                                               printk(KERN_ERR "%s: Internal fault: The skbuff addresses "
+                                                      "do not match in tulip_rx: %08x vs. %08x %p / %p.\n",
+                                                      dev->name,
+                                                      le32_to_cpu(tp->rx_ring[entry].buffer1),
+                                                      tp->rx_buffers[entry].mapping,
+                                                      skb->head, temp);
+                                       }
+#endif
+  
+                                       pci_unmap_single(tp->pdev, tp->rx_buffers[entry].mapping,
+                                                        PKT_BUF_SZ, PCI_DMA_FROMDEVICE);
+  
+                                       tp->rx_buffers[entry].skb = NULL;
+                                       tp->rx_buffers[entry].mapping = 0;
+                               }
+                               skb->protocol = eth_type_trans(skb, dev);
+  
+                               netif_receive_skb(skb);
+ 
+                               dev->last_rx = jiffies;
+                               tp->stats.rx_packets++;
+                               tp->stats.rx_bytes += pkt_len;
+                       }
+                       received++;
+
+                       entry = (++tp->cur_rx) % RX_RING_SIZE;
+                       if (tp->cur_rx - tp->dirty_rx > RX_RING_SIZE/4)
+                               tulip_refill_rx(dev);
+ 
+                }
+ 
+               /* New ack strategy... irq does not ack Rx any longer
+                  hopefully this helps */
+ 
+               /* Really bad things can happen here... If new packet arrives
+                * and an irq arrives (tx or just due to occasionally unset
+                * mask), it will be acked by irq handler, but new thread
+                * is not scheduled. It is major hole in design.
+                * No idea how to fix this if "playing with fire" will fail
+                * tomorrow (night 011029). If it will not fail, we won
+                * finally: amount of IO did not increase at all. */
+       } while ((inl(dev->base_addr + CSR5) & RxIntr));
+ 
+ /* done: */
+ 
+ #ifdef CONFIG_TULIP_NAPI_HW_MITIGATION
+  
+          /* We use this simplistic scheme for IM. It's proven by
+             real life installations. We can have IM enabled
+            continuesly but this would cause unnecessary latency. 
+            Unfortunely we can't use all the NET_RX_* feedback here. 
+            This would turn on IM for devices that is not contributing 
+            to backlog congestion with unnecessary latency. 
+  
+             We monitor the the device RX-ring and have:
+  
+             HW Interrupt Mitigation either ON or OFF.
+  
+            ON:  More then 1 pkt received (per intr.) OR we are dropping 
+             OFF: Only 1 pkt received
+            
+             Note. We only use min and max (0, 15) settings from mit_table */
+  
+  
+          if( tp->flags &  HAS_INTR_MITIGATION) {
+                 if( received > 1 ) {
+                         if( ! tp->mit_on ) {
+                                 tp->mit_on = 1;
+                                 outl(mit_table[MIT_TABLE], dev->base_addr + CSR11);
+                         }
+                  }
+                 else {
+                         if( tp->mit_on ) {
+                                 tp->mit_on = 0;
+                                 outl(0, dev->base_addr + CSR11);
+                         }
+                  }
+          }
+
+#endif /* CONFIG_TULIP_NAPI_HW_MITIGATION */
+ 
+         dev->quota -= received;
+         *budget -= received;
+ 
+         tulip_refill_rx(dev);
+         
+         /* If RX ring is not full we are out of memory. */
+         if (tp->rx_buffers[tp->dirty_rx % RX_RING_SIZE].skb == NULL) goto oom;
+ 
+         /* Remove us from polling list and enable RX intr. */
+ 
+         netif_rx_complete(dev);
+         outl(tulip_tbl[tp->chip_id].valid_intrs, dev->base_addr+CSR7);
+ 
+         /* The last op happens after poll completion. Which means the following:
+          * 1. it can race with disabling irqs in irq handler
+          * 2. it can race with dise/enabling irqs in other poll threads
+          * 3. if an irq raised after beginning loop, it will be immediately
+          *    triggered here.
+          *
+          * Summarizing: the logic results in some redundant irqs both
+          * due to races in masking and due to too late acking of already
+          * processed irqs. But it must not result in losing events.
+          */
+ 
+         return 0;
+ 
+ not_done:
+         if (!received) {
+
+                 received = dev->quota; /* Not to happen */
+         }
+         dev->quota -= received;
+         *budget -= received;
+ 
+         if (tp->cur_rx - tp->dirty_rx > RX_RING_SIZE/2 ||
+             tp->rx_buffers[tp->dirty_rx % RX_RING_SIZE].skb == NULL)
+                 tulip_refill_rx(dev);
+ 
+         if (tp->rx_buffers[tp->dirty_rx % RX_RING_SIZE].skb == NULL) goto oom;
+ 
+         return 1;
+ 
+ 
+ oom:    /* Executed with RX ints disabled */
+ 
+         
+         /* Start timer, stop polling, but do not enable rx interrupts. */
+         mod_timer(&tp->oom_timer, jiffies+1);
+       
+         /* Think: timer_pending() was an explicit signature of bug.
+          * Timer can be pending now but fired and completed
+          * before we did netif_rx_complete(). See? We would lose it. */
+ 
+         /* remove ourselves from the polling list */
+         netif_rx_complete(dev);
+ 
+         return 0;
+}
+
+#else /* CONFIG_TULIP_NAPI */
+
+static int tulip_rx(struct net_device *dev)
+{
+	struct tulip_private *tp = (struct tulip_private *)dev->priv;
+	int entry = tp->cur_rx % RX_RING_SIZE;
+	int rx_work_limit = tp->dirty_rx + RX_RING_SIZE - tp->cur_rx;
+	int received = 0;
+
+	if (tulip_debug > 4)
+		printk(KERN_DEBUG " In tulip_rx(), entry %d %8.8x.\n", entry,
+			   tp->rx_ring[entry].status);
 	/* If we own the next entry, it is a new packet. Send it up. */
 	while ( ! (tp->rx_ring[entry].status & cpu_to_le32(DescOwned))) {
 		s32 status = le32_to_cpu(tp->rx_ring[entry].status);
@@ -163,11 +403,6 @@
 			}
 #endif
 
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-                        drop = atomic_read(&netdev_dropping);
-                        if (drop)
-                                goto throttle;
-#endif
 			/* Check if the packet is long enough to accept without copying
 			   to a minimally-sized skbuff. */
 			if (pkt_len < tulip_rx_copybreak
@@ -209,44 +444,9 @@
 				tp->rx_buffers[entry].mapping = 0;
 			}
 			skb->protocol = eth_type_trans(skb, dev);
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-                        mit_sel =
-#endif
-			netif_rx(skb);
 
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-                        switch (mit_sel) {
-                        case NET_RX_SUCCESS:
-                        case NET_RX_CN_LOW:
-                        case NET_RX_CN_MOD:
-                                break;
-
-                        case NET_RX_CN_HIGH:
-                                rx_work_limit -= NET_RX_CN_HIGH; /* additional*/
-                                break;
-                        case NET_RX_DROP:
-                                rx_work_limit = -1;
-                                break;
-                        default:
-                                printk("unknown feedback return code %d\n", mit_sel);
-                                break;
-                        }
+			netif_rx(skb);
 
-                        drop = atomic_read(&netdev_dropping);
-                        if (drop) {
-throttle:
-                                rx_work_limit = -1;
-                                mit_sel = NET_RX_DROP;
-
-                                if (tp->fc_bit) {
-                                        long ioaddr = dev->base_addr;
-
-                                        /* disable Rx & RxNoBuf ints. */
-                                        outl(tulip_tbl[tp->chip_id].valid_intrs&RX_A_NBF_STOP, ioaddr + CSR7);
-                                        set_bit(tp->fc_bit, &netdev_fc_xoff);
-                                }
-                        }
-#endif
 			dev->last_rx = jiffies;
 			tp->stats.rx_packets++;
 			tp->stats.rx_bytes += pkt_len;
@@ -254,42 +454,9 @@
 		received++;
 		entry = (++tp->cur_rx) % RX_RING_SIZE;
 	}
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-
-        /* We use this simplistic scheme for IM. It's proven by
-           real life installations. We can have IM enabled
-           continuesly but this would cause unnecessary latency.
-           Unfortunely we can't use all the NET_RX_* feedback here.
-           This would turn on IM for devices that is not contributing
-           to backlog congestion with unnecessary latency.
-
-           We monitor the device RX-ring and have:
-
-           HW Interrupt Mitigation either ON or OFF.
-
-           ON:  More then 1 pkt received (per intr.) OR we are dropping
-           OFF: Only 1 pkt received
-
-           Note. We only use min and max (0, 15) settings from mit_table */
-
-
-        if( tp->flags &  HAS_INTR_MITIGATION) {
-                if((received > 1 || mit_sel == NET_RX_DROP)
-                   && tp->mit_sel != 15 ) {
-                        tp->mit_sel = 15;
-                        tp->mit_change = 1; /* Force IM change */
-                }
-                if((received <= 1 && mit_sel != NET_RX_DROP) && tp->mit_sel != 0 ) {
-                        tp->mit_sel = 0;
-                        tp->mit_change = 1; /* Force IM change */
-                }
-        }
-
-        return RX_RING_SIZE+1; /* maxrx+1 */
-#else
 	return received;
-#endif
 }
+#endif  /* CONFIG_TULIP_NAPI */
 
 static inline unsigned int phy_interrupt (struct net_device *dev)
 {
@@ -323,7 +490,6 @@
 	struct tulip_private *tp = (struct tulip_private *)dev->priv;
 	long ioaddr = dev->base_addr;
 	int csr5;
-	int entry;
 	int missed;
 	int rx = 0;
 	int tx = 0;
@@ -331,6 +497,11 @@
 	int maxrx = RX_RING_SIZE;
 	int maxtx = TX_RING_SIZE;
 	int maxoi = TX_RING_SIZE;
+#ifdef CONFIG_TULIP_NAPI
+	int rxd = 0;
+#else
+	int entry;
+#endif
 	unsigned int work_count = tulip_max_interrupt_work;
 	unsigned int handled = 0;
 
@@ -346,22 +517,41 @@
 	tp->nir++;
 
 	do {
+
+#ifdef CONFIG_TULIP_NAPI
+
+		if (!rxd && (csr5 & (RxIntr | RxNoBuf))) {
+			rxd++;
+			/* Mask RX intrs and add the device to poll list. */
+			outl(tulip_tbl[tp->chip_id].valid_intrs&~RxPollInt, ioaddr + CSR7);
+			netif_rx_schedule(dev);
+			
+			if (!(csr5&~(AbnormalIntr|NormalIntr|RxPollInt|TPLnkPass)))
+                               break;
+		}
+		
+               /* Acknowledge the interrupt sources we handle here ASAP
+                  the poll function does Rx and RxNoBuf acking */
+		
+		outl(csr5 & 0x0001ff3f, ioaddr + CSR5);
+
+#else 
 		/* Acknowledge all of the current interrupt sources ASAP. */
 		outl(csr5 & 0x0001ffff, ioaddr + CSR5);
 
-		if (tulip_debug > 4)
-			printk(KERN_DEBUG "%s: interrupt  csr5=%#8.8x new csr5=%#8.8x.\n",
-				   dev->name, csr5, inl(dev->base_addr + CSR5));
 
 		if (csr5 & (RxIntr | RxNoBuf)) {
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-                        if ((!tp->fc_bit) ||
-			    (!test_bit(tp->fc_bit, &netdev_fc_xoff)))
-#endif
 				rx += tulip_rx(dev);
 			tulip_refill_rx(dev);
 		}
 
+#endif /*  CONFIG_TULIP_NAPI */
+		
+		if (tulip_debug > 4)
+			printk(KERN_DEBUG "%s: interrupt  csr5=%#8.8x new csr5=%#8.8x.\n",
+			       dev->name, csr5, inl(dev->base_addr + CSR5));
+		
+
 		if (csr5 & (TxNoBuf | TxDied | TxIntr | TimerInt)) {
 			unsigned int dirty_tx;
 
@@ -462,15 +652,8 @@
 			}
 			if (csr5 & RxDied) {		/* Missed a Rx frame. */
                                 tp->stats.rx_missed_errors += inl(ioaddr + CSR8) & 0xffff;
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-				if (tp->fc_bit && !test_bit(tp->fc_bit, &netdev_fc_xoff)) {
-					tp->stats.rx_errors++;
-					tulip_start_rxtx(tp);
-				}
-#else
 				tp->stats.rx_errors++;
 				tulip_start_rxtx(tp);
-#endif
 			}
 			/*
 			 * NB: t21142_lnk_change() does a del_timer_sync(), so be careful if this
@@ -504,10 +687,6 @@
 			if (tulip_debug > 2)
 				printk(KERN_ERR "%s: Re-enabling interrupts, %8.8x.\n",
 					   dev->name, csr5);
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-                        if (tp->fc_bit && (test_bit(tp->fc_bit, &netdev_fc_xoff)))
-                          if (net_ratelimit()) printk("BUG!! enabling interrupt when FC off (timerintr.) \n");
-#endif
 			outl(tulip_tbl[tp->chip_id].valid_intrs, ioaddr + CSR7);
 			tp->ttimer = 0;
 			oi++;
@@ -520,16 +699,9 @@
                        /* Acknowledge all interrupt sources. */
                         outl(0x8001ffff, ioaddr + CSR5);
                         if (tp->flags & HAS_INTR_MITIGATION) {
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-                                if(tp->mit_change) {
-                                        outl(mit_table[tp->mit_sel], ioaddr + CSR11);
-                                        tp->mit_change = 0;
-                                }
-#else
                      /* Josip Loncaric at ICASE did extensive experimentation
 			to develop a good interrupt mitigation setting.*/
                                 outl(0x8b240000, ioaddr + CSR11);
-#endif
                         } else if (tp->chip_id == LC82C168) {
 				/* the LC82C168 doesn't have a hw timer.*/
 				outl(0x00, ioaddr + CSR7);
@@ -537,10 +709,8 @@
 			} else {
                           /* Mask all interrupting sources, set timer to
 				re-enable. */
-#ifndef CONFIG_NET_HW_FLOWCONTROL
                                 outl(((~csr5) & 0x0001ebef) | AbnormalIntr | TimerInt, ioaddr + CSR7);
                                 outl(0x0012, ioaddr + CSR11);
-#endif
                         }
 			break;
 		}
@@ -550,6 +720,21 @@
 			break;
 
 		csr5 = inl(ioaddr + CSR5);
+
+#ifdef CONFIG_TULIP_NAPI
+		if (rxd)
+			csr5 &= ~RxPollInt;
+	} while ((csr5 & (TxNoBuf | 
+			  TxDied | 
+			  TxIntr | 
+			  TimerInt |
+			  /* Abnormal intr. */
+			  RxDied | 
+			  TxFIFOUnderflow | 
+			  TxJabber | 
+			  TPLnkFail |  
+			  SytemError )) != 0);
+#else 
 	} while ((csr5 & (NormalIntr|AbnormalIntr)) != 0);
 
 	tulip_refill_rx(dev);
@@ -574,6 +759,7 @@
 			}
 		}
 	}
+#endif /* CONFIG_TULIP_NAPI */
 
 	if ((missed = inl(ioaddr + CSR8) & 0x1ffff)) {
 		tp->stats.rx_dropped += missed & 0x10000 ? 0x10000 : missed;

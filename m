From: Jon D Mason <jonmason@us.ibm.com>
Subject: [PATCH] r8169 NAPI addition
Date: Mon, 19 Apr 2004 13:10:09 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFDB678E23.389CBC51-ON87256E7B.00620100-86256E7B.00637457@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: romieu@fr.zoreil.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Bonjour Francois,
Below is my implementation of NAPI for the r8169 driver.  I wrote and 
tested it on an x86_64 box running the 2.6.6-rc1 kernel, and it appears to 
work well.  Let me know if you see anything you do not like in it, and 
I'll be happy to change it.

Thanks,
Jon


#diff -Narup Kconfig.orig Kconfig
--- Kconfig.orig        2004-04-19 13:01:05.594735288 -0500
+++ Kconfig     2004-04-18 09:23:40.000000000 -0500
@@ -1976,6 +1962,10 @@ config R8169
          To compile this driver as a module, choose M here: the module
          will be called r8169.  This is recommended.

+config R8169_NAPI
+       bool "Use Rx Polling (NAPI) (EXPERIMENTAL)"
+       depends on R8169 && EXPERIMENTAL
+
 config SK98LIN
        tristate "Marvell Yukon Chipset / SysKonnect SK-98xx Support"
        depends on PCI



# diff -Narup r8169.c.orig r8169.c
--- r8169.c.orig        2004-04-18 22:51:33.000000000 -0500
+++ r8169.c     2004-04-19 07:47:13.679621544 -0500
@@ -111,6 +111,9 @@ static int multicast_filter_limit = 32;
 #define RTL_R16(reg)           readw (ioaddr + (reg))
 #define RTL_R32(reg)           ((unsigned long) readl (ioaddr + (reg)))

+/* The number of Rx iterations processed (if NAPI enabled) */
+#define R8169_NAPI_WEIGHT      16
+
 enum mac_version {
        RTL_GIGA_MAC_VER_B = 0x00,
        /* RTL_GIGA_MAC_VER_C = 0x03, */
@@ -347,6 +350,9 @@ static int rtl8169_close(struct net_devi
 static void rtl8169_set_rx_mode(struct net_device *dev);
 static void rtl8169_tx_timeout(struct net_device *dev);
 static struct net_device_stats *rtl8169_get_stats(struct net_device 
*netdev);
+#ifdef CONFIG_R8169_NAPI
+static int rtl8169_poll(struct net_device *dev, int *budget);
+#endif

 static const u16 rtl8169_intr_mask =
     RxUnderrun | RxOverflow | RxFIFOOver | TxErr | TxOK | RxErr | RxOK;
@@ -840,6 +846,11 @@ rtl8169_init_one(struct pci_dev *pdev, c
        dev->irq = pdev->irq;
        dev->base_addr = (unsigned long) ioaddr;
 //      dev->do_ioctl           = mii_ioctl;
+#ifdef CONFIG_R8169_NAPI
+       dev->poll = rtl8169_poll;
+       dev->weight = R8169_NAPI_WEIGHT;
+       printk(KERN_INFO "r8169 NAPI enabled\n");
+#endif

        tp = dev->priv;         // private data //
        tp->pci_dev = pdev;
@@ -990,7 +1001,10 @@ rtl8169_remove_one(struct pci_dev *pdev)
        assert(dev != NULL);
        assert(tp != NULL);

+       printk(KERN_INFO "Before unregister_netdev %d\n", 
atomic_read(&dev->refcnt));
        unregister_netdev(dev);
+       printk(KERN_INFO "After unregister_netdev\n");
+
        iounmap(tp->mmio_addr);
        pci_release_regions(pdev);

@@ -1309,6 +1323,7 @@ rtl8169_tx_timeout(struct net_device *de
        void *ioaddr = tp->mmio_addr;
        u8 tmp8;

+       printk(KERN_INFO "%s: TX Timeout\n", dev->name);
        /* disable Tx, if not already */
        tmp8 = RTL_R8(ChipCmd);
        if (tmp8 & CmdTxEnb)
@@ -1445,12 +1460,13 @@ static inline int rtl8169_try_rx_copy(st
        return ret;
 }

-static void
+static int
 rtl8169_rx_interrupt(struct net_device *dev, struct rtl8169_private *tp,
                     void *ioaddr)
 {
        unsigned long cur_rx, rx_left;
        int delta;
+       uint32_t count = 0;

        assert(dev != NULL);
        assert(tp != NULL);
@@ -1497,7 +1513,11 @@ rtl8169_rx_interrupt(struct net_device *

                        skb_put(skb, pkt_size);
                        skb->protocol = eth_type_trans(skb, dev);
+#ifdef CONFIG_R8169_NAPI
+                       netif_receive_skb(skb);
+#else
                        netif_rx(skb);
+#endif

                        dev->last_rx = jiffies;
                        tp->stats.rx_bytes += pkt_size;
@@ -1506,15 +1526,17 @@ rtl8169_rx_interrupt(struct net_device *

                cur_rx++;
                rx_left--;
+               count++;
        }

        tp->cur_rx = cur_rx;

        delta = rtl8169_rx_fill(tp, dev, tp->dirty_rx, tp->cur_rx);
-       if (delta > 0)
-               tp->dirty_rx += delta;
-       else if (delta < 0)
+       if (delta < 0) {
                printk(KERN_INFO "%s: no Rx buffer allocated\n", 
dev->name);
+               delta = 0;
+       }
+       tp->dirty_rx += delta;

        /*
         * FIXME: until there is periodic timer to try and refill the 
ring,
@@ -1525,6 +1547,8 @@ rtl8169_rx_interrupt(struct net_device *
         */
        if (tp->dirty_rx + NUM_RX_DESC == tp->cur_rx)
                printk(KERN_EMERG "%s: Rx buffers exhausted\n", 
dev->name);
+
+       return count;
 }

 /* The interrupt handler does all of the Rx thread work and cleans up 
after the Tx thread. */
@@ -1558,7 +1582,19 @@ rtl8169_interrupt(int irq, void *dev_ins

                // Rx interrupt
                if (status & (RxOK | RxUnderrun | RxOverflow | 
RxFIFOOver)) {
+#ifdef CONFIG_R8169_NAPI
+                       if(netif_rx_schedule_prep(dev)) {
+                               RTL_W16(IntrMask, rtl8169_intr_mask |
+                                       ~(RxOK | RxUnderrun | RxOverflow | 
RxFIFOOver));
+                               __netif_rx_schedule(dev);
+                       } else {
+                               printk(KERN_INFO "driver bug! interrupt 
while in poll\n");
+                               RTL_W16(IntrMask, rtl8169_intr_mask |
+                                       ~(RxOK | RxUnderrun | RxOverflow | 
RxFIFOOver));
+                       }
+#else
                        rtl8169_rx_interrupt(dev, tp, ioaddr);
+#endif
                }
                // Tx interrupt
                if (status & (TxOK | TxErr)) {
@@ -1692,6 +1728,28 @@ static struct net_device_stats *rtl8169_
        return &tp->stats;
 }

+#ifdef CONFIG_R8169_NAPI
+static int rtl8169_poll(struct net_device *dev, int *budget)
+{
+       uint32_t work_done = 0,
+               work_to_do = min(*budget, dev->quota);
+       struct rtl8169_private *tp = (struct rtl8169_private *)dev->priv;
+       void *ioaddr = tp->mmio_addr;
+
+       work_done = rtl8169_rx_interrupt(dev, tp, ioaddr);
+
+       *budget -= work_done;
+       dev->quota -= work_done;
+
+       if (!work_done || !netif_running(dev)) {
+               netif_rx_complete(dev);
+               RTL_W16(IntrMask, rtl8169_intr_mask);
+       }
+
+       return (work_done >= work_to_do);
+}
+#endif
+
 static struct pci_driver rtl8169_pci_driver = {
        .name           = MODULENAME,
        .id_table       = rtl8169_pci_tbl

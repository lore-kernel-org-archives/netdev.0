From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates for .27
Date: Fri, 4 Jul 2008 08:54:46 -0400
Message-ID: <20080704125446.GA30300@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:34273 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751955AbYGDMys (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 08:54:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull from 'davem-next' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-next

to receive the following updates:

 drivers/char/pcmcia/synclink_cs.c |   28 ++---
 drivers/char/synclink.c           |   33 +++---
 drivers/char/synclink_gt.c        |   28 ++---
 drivers/char/synclinkmp.c         |   31 ++---
 drivers/net/3c503.c               |   14 +-
 drivers/net/8390.h                |   18 +++-
 drivers/net/8390p.c               |   66 ++++++++++
 drivers/net/Kconfig               |   16 +---
 drivers/net/Makefile              |   10 +-
 drivers/net/hp.c                  |   14 +-
 drivers/net/igb/e1000_82575.c     |  240 +++++++++++++++++++++++--------------
 drivers/net/igb/e1000_82575.h     |    8 +-
 drivers/net/igb/e1000_defines.h   |   28 ++---
 drivers/net/igb/e1000_hw.h        |    8 +-
 drivers/net/igb/e1000_mac.c       |  141 +++++++++++-----------
 drivers/net/igb/e1000_nvm.c       |   52 ++++----
 drivers/net/igb/e1000_phy.c       |  138 ++++++++++-----------
 drivers/net/igb/igb.h             |    2 +
 drivers/net/igb/igb_main.c        |  243 ++++++++++++++++---------------------
 drivers/net/ipg.c                 |  105 ++++++++++------
 drivers/net/ipg.h                 |   83 +------------
 drivers/net/ne.c                  |   14 +-
 drivers/net/ne2.c                 |   16 ++--
 drivers/net/r8169.c               |  145 +++++++---------------
 drivers/net/wan/c101.c            |    6 +-
 drivers/net/wan/dscc4.c           |   22 ++--
 drivers/net/wan/farsync.c         |   70 +++++------
 drivers/net/wan/hd6457x.c         |   33 +++---
 drivers/net/wan/hdlc.c            |    2 +-
 drivers/net/wan/hdlc_cisco.c      |    4 +-
 drivers/net/wan/hdlc_fr.c         |   54 +++------
 drivers/net/wan/hdlc_raw_eth.c    |    2 +-
 drivers/net/wan/hdlc_x25.c        |    6 +-
 drivers/net/wan/pc300_drv.c       |   71 +++++------
 drivers/net/wan/pc300_tty.c       |    6 +-
 drivers/net/wan/wanxl.c           |   26 ++--
 include/linux/hdlc.h              |    7 -
 37 files changed, 846 insertions(+), 944 deletions(-)
 create mode 100644 drivers/net/8390p.c

Alan Cox (1):
      8390: Split 8390 support into a pausing and a non pausing driver core

Alexander Duyck (2):
      igb: fix parameter options
      igb: fix init on 82575 with MNG enabled

Auke Kok (1):
      igb: eliminate hw from the hw_dbg macro arguments

Francois Romieu (2):
      r8169: multicast register update (sync with Realtek's 8.004.00 8168 driver)
      r8169: remove non-napi code

Jeff Kirsher (2):
      igb: limit EEPROM access
      igb: cleanup function header comments

Krzysztof Halasa (2):
      WAN: convert drivers to use built-in netdev_stats
      WAN: Remove no longer needed pvc_desc in FR code.

Mitch Williams (1):
      igb: Remove adapter struct from these function call parameters

PJ Waskiewicz (1):
      igb: add NAPI Rx queue support

Pekka Enberg (6):
      ipg: always compile in jumbo frame support
      ipg: remove jumbo frame #ifdef from mtu
      ipg: per-device rxfrag_size
      ipg: per-device rxsupport_size
      ipg: per-device max_rxframe_size
      ipg: run-time configurable jumbo frame support

diff --git a/drivers/char/pcmcia/synclink_cs.c b/drivers/char/pcmcia/synclink_cs.c
index 1dd0e99..fb2fb15 100644
--- a/drivers/char/pcmcia/synclink_cs.c
+++ b/drivers/char/pcmcia/synclink_cs.c
@@ -3886,9 +3886,8 @@ static bool rx_get_frame(MGSLPC_INFO *info)
 		framesize = 0;
 #if SYNCLINK_GENERIC_HDLC
 		{
-			struct net_device_stats *stats = hdlc_stats(info->netdev);
-			stats->rx_errors++;
-			stats->rx_frame_errors++;
+			info->netdev->stats.rx_errors++;
+			info->netdev->stats.rx_frame_errors++;
 		}
 #endif
 	} else
@@ -4144,7 +4143,6 @@ static int hdlcdev_attach(struct net_device *dev, unsigned short encoding,
 static int hdlcdev_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	MGSLPC_INFO *info = dev_to_port(dev);
-	struct net_device_stats *stats = hdlc_stats(dev);
 	unsigned long flags;
 
 	if (debug_level >= DEBUG_LEVEL_INFO)
@@ -4159,8 +4157,8 @@ static int hdlcdev_xmit(struct sk_buff *skb, struct net_device *dev)
 	info->tx_put = info->tx_count = skb->len;
 
 	/* update network statistics */
-	stats->tx_packets++;
-	stats->tx_bytes += skb->len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
 
 	/* done with socket buffer, so free it */
 	dev_kfree_skb(skb);
@@ -4376,14 +4374,13 @@ static int hdlcdev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 static void hdlcdev_tx_timeout(struct net_device *dev)
 {
 	MGSLPC_INFO *info = dev_to_port(dev);
-	struct net_device_stats *stats = hdlc_stats(dev);
 	unsigned long flags;
 
 	if (debug_level >= DEBUG_LEVEL_INFO)
 		printk("hdlcdev_tx_timeout(%s)\n",dev->name);
 
-	stats->tx_errors++;
-	stats->tx_aborted_errors++;
+	dev->stats.tx_errors++;
+	dev->stats.tx_aborted_errors++;
 
 	spin_lock_irqsave(&info->lock,flags);
 	tx_stop(info);
@@ -4416,27 +4413,26 @@ static void hdlcdev_rx(MGSLPC_INFO *info, char *buf, int size)
 {
 	struct sk_buff *skb = dev_alloc_skb(size);
 	struct net_device *dev = info->netdev;
-	struct net_device_stats *stats = hdlc_stats(dev);
 
 	if (debug_level >= DEBUG_LEVEL_INFO)
 		printk("hdlcdev_rx(%s)\n",dev->name);
 
 	if (skb == NULL) {
 		printk(KERN_NOTICE "%s: can't alloc skb, dropping packet\n", dev->name);
-		stats->rx_dropped++;
+		dev->stats.rx_dropped++;
 		return;
 	}
 
-	memcpy(skb_put(skb, size),buf,size);
+	memcpy(skb_put(skb, size), buf, size);
 
-	skb->protocol = hdlc_type_trans(skb, info->netdev);
+	skb->protocol = hdlc_type_trans(skb, dev);
 
-	stats->rx_packets++;
-	stats->rx_bytes += size;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += size;
 
 	netif_rx(skb);
 
-	info->netdev->last_rx = jiffies;
+	dev->last_rx = jiffies;
 }
 
 /**
diff --git a/drivers/char/synclink.c b/drivers/char/synclink.c
index ac5080d..9d247d8 100644
--- a/drivers/char/synclink.c
+++ b/drivers/char/synclink.c
@@ -6640,9 +6640,8 @@ static bool mgsl_get_rx_frame(struct mgsl_struct *info)
 		framesize = 0;
 #if SYNCLINK_GENERIC_HDLC
 		{
-			struct net_device_stats *stats = hdlc_stats(info->netdev);
-			stats->rx_errors++;
-			stats->rx_frame_errors++;
+			info->netdev->stats.rx_errors++;
+			info->netdev->stats.rx_frame_errors++;
 		}
 #endif
 	} else
@@ -7753,7 +7752,6 @@ static int hdlcdev_attach(struct net_device *dev, unsigned short encoding,
 static int hdlcdev_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct mgsl_struct *info = dev_to_port(dev);
-	struct net_device_stats *stats = hdlc_stats(dev);
 	unsigned long flags;
 
 	if (debug_level >= DEBUG_LEVEL_INFO)
@@ -7767,8 +7765,8 @@ static int hdlcdev_xmit(struct sk_buff *skb, struct net_device *dev)
 	mgsl_load_tx_dma_buffer(info, skb->data, skb->len);
 
 	/* update network statistics */
-	stats->tx_packets++;
-	stats->tx_bytes += skb->len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
 
 	/* done with socket buffer, so free it */
 	dev_kfree_skb(skb);
@@ -7984,14 +7982,13 @@ static int hdlcdev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 static void hdlcdev_tx_timeout(struct net_device *dev)
 {
 	struct mgsl_struct *info = dev_to_port(dev);
-	struct net_device_stats *stats = hdlc_stats(dev);
 	unsigned long flags;
 
 	if (debug_level >= DEBUG_LEVEL_INFO)
 		printk("hdlcdev_tx_timeout(%s)\n",dev->name);
 
-	stats->tx_errors++;
-	stats->tx_aborted_errors++;
+	dev->stats.tx_errors++;
+	dev->stats.tx_aborted_errors++;
 
 	spin_lock_irqsave(&info->irq_spinlock,flags);
 	usc_stop_transmitter(info);
@@ -8024,27 +8021,27 @@ static void hdlcdev_rx(struct mgsl_struct *info, char *buf, int size)
 {
 	struct sk_buff *skb = dev_alloc_skb(size);
 	struct net_device *dev = info->netdev;
-	struct net_device_stats *stats = hdlc_stats(dev);
 
 	if (debug_level >= DEBUG_LEVEL_INFO)
-		printk("hdlcdev_rx(%s)\n",dev->name);
+		printk("hdlcdev_rx(%s)\n", dev->name);
 
 	if (skb == NULL) {
-		printk(KERN_NOTICE "%s: can't alloc skb, dropping packet\n", dev->name);
-		stats->rx_dropped++;
+		printk(KERN_NOTICE "%s: can't alloc skb, dropping packet\n",
+		       dev->name);
+		dev->stats.rx_dropped++;
 		return;
 	}
 
-	memcpy(skb_put(skb, size),buf,size);
+	memcpy(skb_put(skb, size), buf, size);
 
-	skb->protocol = hdlc_type_trans(skb, info->netdev);
+	skb->protocol = hdlc_type_trans(skb, dev);
 
-	stats->rx_packets++;
-	stats->rx_bytes += size;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += size;
 
 	netif_rx(skb);
 
-	info->netdev->last_rx = jiffies;
+	dev->last_rx = jiffies;
 }
 
 /**
diff --git a/drivers/char/synclink_gt.c b/drivers/char/synclink_gt.c
index 55c1653..d88a607 100644
--- a/drivers/char/synclink_gt.c
+++ b/drivers/char/synclink_gt.c
@@ -1544,7 +1544,6 @@ static int hdlcdev_attach(struct net_device *dev, unsigned short encoding,
 static int hdlcdev_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct slgt_info *info = dev_to_port(dev);
-	struct net_device_stats *stats = hdlc_stats(dev);
 	unsigned long flags;
 
 	DBGINFO(("%s hdlc_xmit\n", dev->name));
@@ -1557,8 +1556,8 @@ static int hdlcdev_xmit(struct sk_buff *skb, struct net_device *dev)
 	tx_load(info, skb->data, skb->len);
 
 	/* update network statistics */
-	stats->tx_packets++;
-	stats->tx_bytes += skb->len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
 
 	/* done with socket buffer, so free it */
 	dev_kfree_skb(skb);
@@ -1775,13 +1774,12 @@ static int hdlcdev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 static void hdlcdev_tx_timeout(struct net_device *dev)
 {
 	struct slgt_info *info = dev_to_port(dev);
-	struct net_device_stats *stats = hdlc_stats(dev);
 	unsigned long flags;
 
 	DBGINFO(("%s hdlcdev_tx_timeout\n", dev->name));
 
-	stats->tx_errors++;
-	stats->tx_aborted_errors++;
+	dev->stats.tx_errors++;
+	dev->stats.tx_aborted_errors++;
 
 	spin_lock_irqsave(&info->lock,flags);
 	tx_stop(info);
@@ -1814,26 +1812,25 @@ static void hdlcdev_rx(struct slgt_info *info, char *buf, int size)
 {
 	struct sk_buff *skb = dev_alloc_skb(size);
 	struct net_device *dev = info->netdev;
-	struct net_device_stats *stats = hdlc_stats(dev);
 
 	DBGINFO(("%s hdlcdev_rx\n", dev->name));
 
 	if (skb == NULL) {
 		DBGERR(("%s: can't alloc skb, drop packet\n", dev->name));
-		stats->rx_dropped++;
+		dev->stats.rx_dropped++;
 		return;
 	}
 
-	memcpy(skb_put(skb, size),buf,size);
+	memcpy(skb_put(skb, size), buf, size);
 
-	skb->protocol = hdlc_type_trans(skb, info->netdev);
+	skb->protocol = hdlc_type_trans(skb, dev);
 
-	stats->rx_packets++;
-	stats->rx_bytes += size;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += size;
 
 	netif_rx(skb);
 
-	info->netdev->last_rx = jiffies;
+	dev->last_rx = jiffies;
 }
 
 /**
@@ -4577,9 +4574,8 @@ check_again:
 
 #if SYNCLINK_GENERIC_HDLC
 	if (framesize == 0) {
-		struct net_device_stats *stats = hdlc_stats(info->netdev);
-		stats->rx_errors++;
-		stats->rx_frame_errors++;
+		info->netdev->stats.rx_errors++;
+		info->netdev->stats.rx_frame_errors++;
 	}
 #endif
 
diff --git a/drivers/char/synclinkmp.c b/drivers/char/synclinkmp.c
index bec5486..10241ed 100644
--- a/drivers/char/synclinkmp.c
+++ b/drivers/char/synclinkmp.c
@@ -1678,7 +1678,6 @@ static int hdlcdev_attach(struct net_device *dev, unsigned short encoding,
 static int hdlcdev_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	SLMP_INFO *info = dev_to_port(dev);
-	struct net_device_stats *stats = hdlc_stats(dev);
 	unsigned long flags;
 
 	if (debug_level >= DEBUG_LEVEL_INFO)
@@ -1692,8 +1691,8 @@ static int hdlcdev_xmit(struct sk_buff *skb, struct net_device *dev)
 	tx_load_dma_buffer(info, skb->data, skb->len);
 
 	/* update network statistics */
-	stats->tx_packets++;
-	stats->tx_bytes += skb->len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
 
 	/* done with socket buffer, so free it */
 	dev_kfree_skb(skb);
@@ -1909,14 +1908,13 @@ static int hdlcdev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 static void hdlcdev_tx_timeout(struct net_device *dev)
 {
 	SLMP_INFO *info = dev_to_port(dev);
-	struct net_device_stats *stats = hdlc_stats(dev);
 	unsigned long flags;
 
 	if (debug_level >= DEBUG_LEVEL_INFO)
 		printk("hdlcdev_tx_timeout(%s)\n",dev->name);
 
-	stats->tx_errors++;
-	stats->tx_aborted_errors++;
+	dev->stats.tx_errors++;
+	dev->stats.tx_aborted_errors++;
 
 	spin_lock_irqsave(&info->lock,flags);
 	tx_stop(info);
@@ -1949,27 +1947,27 @@ static void hdlcdev_rx(SLMP_INFO *info, char *buf, int size)
 {
 	struct sk_buff *skb = dev_alloc_skb(size);
 	struct net_device *dev = info->netdev;
-	struct net_device_stats *stats = hdlc_stats(dev);
 
 	if (debug_level >= DEBUG_LEVEL_INFO)
 		printk("hdlcdev_rx(%s)\n",dev->name);
 
 	if (skb == NULL) {
-		printk(KERN_NOTICE "%s: can't alloc skb, dropping packet\n", dev->name);
-		stats->rx_dropped++;
+		printk(KERN_NOTICE "%s: can't alloc skb, dropping packet\n",
+		       dev->name);
+		dev->stats.rx_dropped++;
 		return;
 	}
 
-	memcpy(skb_put(skb, size),buf,size);
+	memcpy(skb_put(skb, size), buf, size);
 
-	skb->protocol = hdlc_type_trans(skb, info->netdev);
+	skb->protocol = hdlc_type_trans(skb, dev);
 
-	stats->rx_packets++;
-	stats->rx_bytes += size;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += size;
 
 	netif_rx(skb);
 
-	info->netdev->last_rx = jiffies;
+	dev->last_rx = jiffies;
 }
 
 /**
@@ -4983,9 +4981,8 @@ CheckAgain:
 		framesize = 0;
 #if SYNCLINK_GENERIC_HDLC
 		{
-			struct net_device_stats *stats = hdlc_stats(info->netdev);
-			stats->rx_errors++;
-			stats->rx_frame_errors++;
+			info->netdev->stats.rx_errors++;
+			info->netdev->stats.rx_frame_errors++;
 		}
 #endif
 	}
diff --git a/drivers/net/3c503.c b/drivers/net/3c503.c
index 9c23336..900b0ff 100644
--- a/drivers/net/3c503.c
+++ b/drivers/net/3c503.c
@@ -149,7 +149,7 @@ el2_pio_probe(struct net_device *dev)
 #ifndef MODULE
 struct net_device * __init el2_probe(int unit)
 {
-	struct net_device *dev = alloc_ei_netdev();
+	struct net_device *dev = alloc_eip_netdev();
 	int err;
 
 	if (!dev)
@@ -340,7 +340,7 @@ el2_probe1(struct net_device *dev, int ioaddr)
     dev->stop = &el2_close;
     dev->ethtool_ops = &netdev_ethtool_ops;
 #ifdef CONFIG_NET_POLL_CONTROLLER
-    dev->poll_controller = ei_poll;
+    dev->poll_controller = eip_poll;
 #endif
 
     retval = register_netdev(dev);
@@ -386,7 +386,7 @@ el2_open(struct net_device *dev)
 		outb_p(0x00, E33G_IDCFR);
 		if (*irqp == probe_irq_off(cookie)	/* It's a good IRQ line! */
 		    && ((retval = request_irq(dev->irq = *irqp,
-		    ei_interrupt, 0, dev->name, dev)) == 0))
+		    eip_interrupt, 0, dev->name, dev)) == 0))
 		    break;
 	    }
 	} while (*++irqp);
@@ -395,13 +395,13 @@ el2_open(struct net_device *dev)
 	    return retval;
 	}
     } else {
-	if ((retval = request_irq(dev->irq, ei_interrupt, 0, dev->name, dev))) {
+	if ((retval = request_irq(dev->irq, eip_interrupt, 0, dev->name, dev))) {
 	    return retval;
 	}
     }
 
     el2_init_card(dev);
-    ei_open(dev);
+    eip_open(dev);
     return 0;
 }
 
@@ -412,7 +412,7 @@ el2_close(struct net_device *dev)
     dev->irq = ei_status.saved_irq;
     outb(EGACFR_IRQOFF, E33G_GACFR);	/* disable interrupts. */
 
-    ei_close(dev);
+    eip_close(dev);
     return 0;
 }
 
@@ -698,7 +698,7 @@ init_module(void)
 			if (this_dev != 0) break; /* only autoprobe 1st one */
 			printk(KERN_NOTICE "3c503.c: Presently autoprobing (not recommended) for a single card.\n");
 		}
-		dev = alloc_ei_netdev();
+		dev = alloc_eip_netdev();
 		if (!dev)
 			break;
 		dev->irq = irq[this_dev];
diff --git a/drivers/net/8390.h b/drivers/net/8390.h
index cf020d4..8e209f5 100644
--- a/drivers/net/8390.h
+++ b/drivers/net/8390.h
@@ -30,8 +30,10 @@ extern int ei_debug;
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 extern void ei_poll(struct net_device *dev);
+extern void eip_poll(struct net_device *dev);
 #endif
 
+/* Without I/O delay - non ISA or later chips */
 extern void NS8390_init(struct net_device *dev, int startp);
 extern int ei_open(struct net_device *dev);
 extern int ei_close(struct net_device *dev);
@@ -42,6 +44,17 @@ static inline struct net_device *alloc_ei_netdev(void)
 	return __alloc_ei_netdev(0);
 }
 
+/* With I/O delay form */
+extern void NS8390p_init(struct net_device *dev, int startp);
+extern int eip_open(struct net_device *dev);
+extern int eip_close(struct net_device *dev);
+extern irqreturn_t eip_interrupt(int irq, void *dev_id);
+extern struct net_device *__alloc_eip_netdev(int size);
+static inline struct net_device *alloc_eip_netdev(void)
+{
+	return __alloc_eip_netdev(0);
+}
+
 /* You have one of these per-board */
 struct ei_device {
 	const char *name;
@@ -115,13 +128,14 @@ struct ei_device {
 /*
  *	Only generate indirect loads given a machine that needs them.
  *      - removed AMIGA_PCMCIA from this list, handled as ISA io now
+ *	- the _p for generates no delay by default 8390p.c overrides this.
  */
 
 #ifndef ei_inb
 #define ei_inb(_p)	inb(_p)
 #define ei_outb(_v,_p)	outb(_v,_p)
-#define ei_inb_p(_p)	inb_p(_p)
-#define ei_outb_p(_v,_p) outb_p(_v,_p)
+#define ei_inb_p(_p)	inb(_p)
+#define ei_outb_p(_v,_p) outb(_v,_p)
 #endif
 
 #ifndef EI_SHIFT
diff --git a/drivers/net/8390p.c b/drivers/net/8390p.c
new file mode 100644
index 0000000..71f1988
--- /dev/null
+++ b/drivers/net/8390p.c
@@ -0,0 +1,66 @@
+/* 8390 core for ISA devices needing bus delays */
+
+static const char version[] =
+    "8390p.c:v1.10cvs 9/23/94 Donald Becker (becker@cesdis.gsfc.nasa.gov)\n";
+
+#define ei_inb(_p)	inb(_p)
+#define ei_outb(_v,_p)	outb(_v,_p)
+#define ei_inb_p(_p)	inb_p(_p)
+#define ei_outb_p(_v,_p) outb_p(_v,_p)
+
+#include "lib8390.c"
+
+int eip_open(struct net_device *dev)
+{
+	return __ei_open(dev);
+}
+
+int eip_close(struct net_device *dev)
+{
+	return __ei_close(dev);
+}
+
+irqreturn_t eip_interrupt(int irq, void *dev_id)
+{
+	return __ei_interrupt(irq, dev_id);
+}
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+void eip_poll(struct net_device *dev)
+{
+	__ei_poll(dev);
+}
+#endif
+
+struct net_device *__alloc_eip_netdev(int size)
+{
+	return ____alloc_ei_netdev(size);
+}
+
+void NS8390p_init(struct net_device *dev, int startp)
+{
+	return __NS8390_init(dev, startp);
+}
+
+EXPORT_SYMBOL(eip_open);
+EXPORT_SYMBOL(eip_close);
+EXPORT_SYMBOL(eip_interrupt);
+#ifdef CONFIG_NET_POLL_CONTROLLER
+EXPORT_SYMBOL(eip_poll);
+#endif
+EXPORT_SYMBOL(NS8390p_init);
+EXPORT_SYMBOL(__alloc_eip_netdev);
+
+#if defined(MODULE)
+
+int init_module(void)
+{
+	return 0;
+}
+
+void cleanup_module(void)
+{
+}
+
+#endif /* MODULE */
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index d85b9d0..8492591 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2122,27 +2122,13 @@ config R8169
 	  To compile this driver as a module, choose M here: the module
 	  will be called r8169.  This is recommended.
 
-config R8169_NAPI
-	bool "Use Rx Polling (NAPI) (EXPERIMENTAL)"
-	depends on R8169 && EXPERIMENTAL
-	help
-	  NAPI is a new driver API designed to reduce CPU and interrupt load
-	  when the driver is receiving lots of packets from the card. It is
-	  still somewhat experimental and thus not yet enabled by default.
-
-	  If your estimated Rx load is 10kpps or more, or if the card will be
-	  deployed on potentially unfriendly networks (e.g. in a firewall),
-	  then say Y here.
-
-	  If in doubt, say N.
-
 config R8169_VLAN
 	bool "VLAN support"
 	depends on R8169 && VLAN_8021Q
 	---help---
 	  Say Y here for the r8169 driver to support the functions required
 	  by the kernel 802.1Q code.
-	  
+
 	  If in doubt, say Y.
 
 config SB1250_MAC
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 87703ff..4beb043 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -106,11 +106,11 @@ ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
 endif
 obj-$(CONFIG_68360_ENET) += 68360enet.o
 obj-$(CONFIG_WD80x3) += wd.o 8390.o
-obj-$(CONFIG_EL2) += 3c503.o 8390.o
-obj-$(CONFIG_NE2000) += ne.o 8390.o
-obj-$(CONFIG_NE2_MCA) += ne2.o 8390.o
-obj-$(CONFIG_HPLAN) += hp.o 8390.o
-obj-$(CONFIG_HPLAN_PLUS) += hp-plus.o 8390.o
+obj-$(CONFIG_EL2) += 3c503.o 8390p.o
+obj-$(CONFIG_NE2000) += ne.o 8390p.o
+obj-$(CONFIG_NE2_MCA) += ne2.o 8390p.o
+obj-$(CONFIG_HPLAN) += hp.o 8390p.o
+obj-$(CONFIG_HPLAN_PLUS) += hp-plus.o 8390p.o
 obj-$(CONFIG_ULTRA) += smc-ultra.o 8390.o
 obj-$(CONFIG_ULTRAMCA) += smc-mca.o 8390.o
 obj-$(CONFIG_ULTRA32) += smc-ultra32.o 8390.o
diff --git a/drivers/net/hp.c b/drivers/net/hp.c
index c649a80..8281209 100644
--- a/drivers/net/hp.c
+++ b/drivers/net/hp.c
@@ -103,7 +103,7 @@ static int __init do_hp_probe(struct net_device *dev)
 #ifndef MODULE
 struct net_device * __init hp_probe(int unit)
 {
-	struct net_device *dev = alloc_ei_netdev();
+	struct net_device *dev = alloc_eip_netdev();
 	int err;
 
 	if (!dev)
@@ -176,7 +176,7 @@ static int __init hp_probe1(struct net_device *dev, int ioaddr)
 				outb_p(irqmap[irq] | HP_RUN, ioaddr + HP_CONFIGURE);
 				outb_p( 0x00 | HP_RUN, ioaddr + HP_CONFIGURE);
 				if (irq == probe_irq_off(cookie)		 /* It's a good IRQ line! */
-					&& request_irq (irq, ei_interrupt, 0, DRV_NAME, dev) == 0) {
+					&& request_irq (irq, eip_interrupt, 0, DRV_NAME, dev) == 0) {
 					printk(" selecting IRQ %d.\n", irq);
 					dev->irq = *irqp;
 					break;
@@ -191,7 +191,7 @@ static int __init hp_probe1(struct net_device *dev, int ioaddr)
 	} else {
 		if (dev->irq == 2)
 			dev->irq = 9;
-		if ((retval = request_irq(dev->irq, ei_interrupt, 0, DRV_NAME, dev))) {
+		if ((retval = request_irq(dev->irq, eip_interrupt, 0, DRV_NAME, dev))) {
 			printk (" unable to get IRQ %d.\n", dev->irq);
 			goto out;
 		}
@@ -202,7 +202,7 @@ static int __init hp_probe1(struct net_device *dev, int ioaddr)
 	dev->open = &hp_open;
 	dev->stop = &hp_close;
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = ei_poll;
+	dev->poll_controller = eip_poll;
 #endif
 
 	ei_status.name = name;
@@ -231,14 +231,14 @@ out:
 static int
 hp_open(struct net_device *dev)
 {
-	ei_open(dev);
+	eip_open(dev);
 	return 0;
 }
 
 static int
 hp_close(struct net_device *dev)
 {
-	ei_close(dev);
+	eip_close(dev);
 	return 0;
 }
 
@@ -421,7 +421,7 @@ init_module(void)
 			if (this_dev != 0) break; /* only autoprobe 1st one */
 			printk(KERN_NOTICE "hp.c: Presently autoprobing (not recommended) for a single card.\n");
 		}
-		dev = alloc_ei_netdev();
+		dev = alloc_eip_netdev();
 		if (!dev)
 			break;
 		dev->irq = irq[this_dev];
diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index cda3ec8..2c8b910 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007 Intel Corporation.
+  Copyright(c) 2007 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -171,6 +171,10 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 	 * for setting word_size.
 	 */
 	size += NVM_WORD_SIZE_BASE_SHIFT;
+
+	/* EEPROM access above 16k is unsupported */
+	if (size > 14)
+		size = 14;
 	nvm->word_size = 1 << size;
 
 	/* setup PHY parameters */
@@ -222,7 +226,7 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_acquire_phy_82575 - Acquire rights to access PHY
+ *  igb_acquire_phy_82575 - Acquire rights to access PHY
  *  @hw: pointer to the HW structure
  *
  *  Acquire access rights to the correct PHY.  This is a
@@ -238,7 +242,7 @@ static s32 igb_acquire_phy_82575(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_release_phy_82575 - Release rights to access PHY
+ *  igb_release_phy_82575 - Release rights to access PHY
  *  @hw: pointer to the HW structure
  *
  *  A wrapper to release access rights to the correct PHY.  This is a
@@ -253,7 +257,7 @@ static void igb_release_phy_82575(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_read_phy_reg_sgmii_82575 - Read PHY register using sgmii
+ *  igb_read_phy_reg_sgmii_82575 - Read PHY register using sgmii
  *  @hw: pointer to the HW structure
  *  @offset: register offset to be read
  *  @data: pointer to the read data
@@ -268,7 +272,7 @@ static s32 igb_read_phy_reg_sgmii_82575(struct e1000_hw *hw, u32 offset,
 	u32 i, i2ccmd = 0;
 
 	if (offset > E1000_MAX_SGMII_PHY_REG_ADDR) {
-		hw_dbg(hw, "PHY Address %u is out of range\n", offset);
+		hw_dbg("PHY Address %u is out of range\n", offset);
 		return -E1000_ERR_PARAM;
 	}
 
@@ -291,11 +295,11 @@ static s32 igb_read_phy_reg_sgmii_82575(struct e1000_hw *hw, u32 offset,
 			break;
 	}
 	if (!(i2ccmd & E1000_I2CCMD_READY)) {
-		hw_dbg(hw, "I2CCMD Read did not complete\n");
+		hw_dbg("I2CCMD Read did not complete\n");
 		return -E1000_ERR_PHY;
 	}
 	if (i2ccmd & E1000_I2CCMD_ERROR) {
-		hw_dbg(hw, "I2CCMD Error bit set\n");
+		hw_dbg("I2CCMD Error bit set\n");
 		return -E1000_ERR_PHY;
 	}
 
@@ -306,7 +310,7 @@ static s32 igb_read_phy_reg_sgmii_82575(struct e1000_hw *hw, u32 offset,
 }
 
 /**
- *  e1000_write_phy_reg_sgmii_82575 - Write PHY register using sgmii
+ *  igb_write_phy_reg_sgmii_82575 - Write PHY register using sgmii
  *  @hw: pointer to the HW structure
  *  @offset: register offset to write to
  *  @data: data to write at register offset
@@ -322,7 +326,7 @@ static s32 igb_write_phy_reg_sgmii_82575(struct e1000_hw *hw, u32 offset,
 	u16 phy_data_swapped;
 
 	if (offset > E1000_MAX_SGMII_PHY_REG_ADDR) {
-		hw_dbg(hw, "PHY Address %d is out of range\n", offset);
+		hw_dbg("PHY Address %d is out of range\n", offset);
 		return -E1000_ERR_PARAM;
 	}
 
@@ -349,11 +353,11 @@ static s32 igb_write_phy_reg_sgmii_82575(struct e1000_hw *hw, u32 offset,
 			break;
 	}
 	if (!(i2ccmd & E1000_I2CCMD_READY)) {
-		hw_dbg(hw, "I2CCMD Write did not complete\n");
+		hw_dbg("I2CCMD Write did not complete\n");
 		return -E1000_ERR_PHY;
 	}
 	if (i2ccmd & E1000_I2CCMD_ERROR) {
-		hw_dbg(hw, "I2CCMD Error bit set\n");
+		hw_dbg("I2CCMD Error bit set\n");
 		return -E1000_ERR_PHY;
 	}
 
@@ -361,10 +365,10 @@ static s32 igb_write_phy_reg_sgmii_82575(struct e1000_hw *hw, u32 offset,
 }
 
 /**
- *  e1000_get_phy_id_82575 - Retreive PHY addr and id
+ *  igb_get_phy_id_82575 - Retrieve PHY addr and id
  *  @hw: pointer to the HW structure
  *
- *  Retreives the PHY address and ID for both PHY's which do and do not use
+ *  Retrieves the PHY address and ID for both PHY's which do and do not use
  *  sgmi interface.
  **/
 static s32 igb_get_phy_id_82575(struct e1000_hw *hw)
@@ -393,9 +397,8 @@ static s32 igb_get_phy_id_82575(struct e1000_hw *hw)
 	for (phy->addr = 1; phy->addr < 8; phy->addr++) {
 		ret_val = igb_read_phy_reg_sgmii_82575(hw, PHY_ID1, &phy_id);
 		if (ret_val == 0) {
-			hw_dbg(hw, "Vendor ID 0x%08X read at address %u\n",
-				  phy_id,
-				  phy->addr);
+			hw_dbg("Vendor ID 0x%08X read at address %u\n",
+			       phy_id, phy->addr);
 			/*
 			 * At the time of this writing, The M88 part is
 			 * the only supported SGMII PHY product.
@@ -403,8 +406,7 @@ static s32 igb_get_phy_id_82575(struct e1000_hw *hw)
 			if (phy_id == M88_VENDOR)
 				break;
 		} else {
-			hw_dbg(hw, "PHY address %u was unreadable\n",
-				  phy->addr);
+			hw_dbg("PHY address %u was unreadable\n", phy->addr);
 		}
 	}
 
@@ -422,7 +424,7 @@ out:
 }
 
 /**
- *  e1000_phy_hw_reset_sgmii_82575 - Performs a PHY reset
+ *  igb_phy_hw_reset_sgmii_82575 - Performs a PHY reset
  *  @hw: pointer to the HW structure
  *
  *  Resets the PHY using the serial gigabit media independent interface.
@@ -436,7 +438,7 @@ static s32 igb_phy_hw_reset_sgmii_82575(struct e1000_hw *hw)
 	 * available to us at this time.
 	 */
 
-	hw_dbg(hw, "Soft resetting SGMII attached PHY...\n");
+	hw_dbg("Soft resetting SGMII attached PHY...\n");
 
 	/*
 	 * SFP documentation requires the following to configure the SPF module
@@ -453,7 +455,7 @@ out:
 }
 
 /**
- *  e1000_set_d0_lplu_state_82575 - Set Low Power Linkup D0 state
+ *  igb_set_d0_lplu_state_82575 - Set Low Power Linkup D0 state
  *  @hw: pointer to the HW structure
  *  @active: true to enable LPLU, false to disable
  *
@@ -471,34 +473,29 @@ static s32 igb_set_d0_lplu_state_82575(struct e1000_hw *hw, bool active)
 	s32 ret_val;
 	u16 data;
 
-	ret_val = hw->phy.ops.read_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT,
-					   &data);
+	ret_val = phy->ops.read_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT, &data);
 	if (ret_val)
 		goto out;
 
 	if (active) {
 		data |= IGP02E1000_PM_D0_LPLU;
-		ret_val = hw->phy.ops.write_phy_reg(hw,
-					      IGP02E1000_PHY_POWER_MGMT,
-					      data);
+		ret_val = phy->ops.write_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT,
+						 data);
 		if (ret_val)
 			goto out;
 
 		/* When LPLU is enabled, we should disable SmartSpeed */
-		ret_val = hw->phy.ops.read_phy_reg(hw,
-					     IGP01E1000_PHY_PORT_CONFIG,
-					     &data);
+		ret_val = phy->ops.read_phy_reg(hw, IGP01E1000_PHY_PORT_CONFIG,
+						&data);
 		data &= ~IGP01E1000_PSCFR_SMART_SPEED;
-		ret_val = hw->phy.ops.write_phy_reg(hw,
-					      IGP01E1000_PHY_PORT_CONFIG,
-					      data);
+		ret_val = phy->ops.write_phy_reg(hw, IGP01E1000_PHY_PORT_CONFIG,
+						 data);
 		if (ret_val)
 			goto out;
 	} else {
 		data &= ~IGP02E1000_PM_D0_LPLU;
-		ret_val = hw->phy.ops.write_phy_reg(hw,
-					      IGP02E1000_PHY_POWER_MGMT,
-					      data);
+		ret_val = phy->ops.write_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT,
+						 data);
 		/*
 		 * LPLU and SmartSpeed are mutually exclusive.  LPLU is used
 		 * during Dx states where the power conservation is most
@@ -506,29 +503,25 @@ static s32 igb_set_d0_lplu_state_82575(struct e1000_hw *hw, bool active)
 		 * SmartSpeed, so performance is maintained.
 		 */
 		if (phy->smart_speed == e1000_smart_speed_on) {
-			ret_val = hw->phy.ops.read_phy_reg(hw,
-						     IGP01E1000_PHY_PORT_CONFIG,
-						     &data);
+			ret_val = phy->ops.read_phy_reg(hw,
+					IGP01E1000_PHY_PORT_CONFIG, &data);
 			if (ret_val)
 				goto out;
 
 			data |= IGP01E1000_PSCFR_SMART_SPEED;
-			ret_val = hw->phy.ops.write_phy_reg(hw,
-						     IGP01E1000_PHY_PORT_CONFIG,
-						     data);
+			ret_val = phy->ops.write_phy_reg(hw,
+					IGP01E1000_PHY_PORT_CONFIG, data);
 			if (ret_val)
 				goto out;
 		} else if (phy->smart_speed == e1000_smart_speed_off) {
-			ret_val = hw->phy.ops.read_phy_reg(hw,
-						     IGP01E1000_PHY_PORT_CONFIG,
-						     &data);
+			ret_val = phy->ops.read_phy_reg(hw,
+					IGP01E1000_PHY_PORT_CONFIG, &data);
 			if (ret_val)
 				goto out;
 
 			data &= ~IGP01E1000_PSCFR_SMART_SPEED;
-			ret_val = hw->phy.ops.write_phy_reg(hw,
-						     IGP01E1000_PHY_PORT_CONFIG,
-						     data);
+			ret_val = phy->ops.write_phy_reg(hw,
+					IGP01E1000_PHY_PORT_CONFIG, data);
 			if (ret_val)
 				goto out;
 		}
@@ -539,10 +532,10 @@ out:
 }
 
 /**
- *  e1000_acquire_nvm_82575 - Request for access to EEPROM
+ *  igb_acquire_nvm_82575 - Request for access to EEPROM
  *  @hw: pointer to the HW structure
  *
- *  Acquire the necessary semaphores for exclussive access to the EEPROM.
+ *  Acquire the necessary semaphores for exclusive access to the EEPROM.
  *  Set the EEPROM access request bit and wait for EEPROM access grant bit.
  *  Return successful if access grant bit set, else clear the request for
  *  EEPROM access and return -E1000_ERR_NVM (-1).
@@ -565,7 +558,7 @@ out:
 }
 
 /**
- *  e1000_release_nvm_82575 - Release exclusive access to EEPROM
+ *  igb_release_nvm_82575 - Release exclusive access to EEPROM
  *  @hw: pointer to the HW structure
  *
  *  Stop any current commands to the EEPROM and clear the EEPROM request bit,
@@ -578,7 +571,7 @@ static void igb_release_nvm_82575(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_acquire_swfw_sync_82575 - Acquire SW/FW semaphore
+ *  igb_acquire_swfw_sync_82575 - Acquire SW/FW semaphore
  *  @hw: pointer to the HW structure
  *  @mask: specifies which semaphore to acquire
  *
@@ -613,7 +606,7 @@ static s32 igb_acquire_swfw_sync_82575(struct e1000_hw *hw, u16 mask)
 	}
 
 	if (i == timeout) {
-		hw_dbg(hw, "Can't access resource, SW_FW_SYNC timeout.\n");
+		hw_dbg("Driver can't access resource, SW_FW_SYNC timeout.\n");
 		ret_val = -E1000_ERR_SWFW_SYNC;
 		goto out;
 	}
@@ -628,7 +621,7 @@ out:
 }
 
 /**
- *  e1000_release_swfw_sync_82575 - Release SW/FW semaphore
+ *  igb_release_swfw_sync_82575 - Release SW/FW semaphore
  *  @hw: pointer to the HW structure
  *  @mask: specifies which semaphore to acquire
  *
@@ -650,7 +643,7 @@ static void igb_release_swfw_sync_82575(struct e1000_hw *hw, u16 mask)
 }
 
 /**
- *  e1000_get_cfg_done_82575 - Read config done bit
+ *  igb_get_cfg_done_82575 - Read config done bit
  *  @hw: pointer to the HW structure
  *
  *  Read the management control register for the config done bit for
@@ -675,7 +668,7 @@ static s32 igb_get_cfg_done_82575(struct e1000_hw *hw)
 		timeout--;
 	}
 	if (!timeout)
-		hw_dbg(hw, "MNG configuration cycle has not completed.\n");
+		hw_dbg("MNG configuration cycle has not completed.\n");
 
 	/* If EEPROM is not marked present, init the PHY manually */
 	if (((rd32(E1000_EECD) & E1000_EECD_PRES) == 0) &&
@@ -686,7 +679,7 @@ static s32 igb_get_cfg_done_82575(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_check_for_link_82575 - Check for link
+ *  igb_check_for_link_82575 - Check for link
  *  @hw: pointer to the HW structure
  *
  *  If sgmii is enabled, then use the pcs register to determine link, otherwise
@@ -709,12 +702,12 @@ static s32 igb_check_for_link_82575(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_get_pcs_speed_and_duplex_82575 - Retrieve current speed/duplex
+ *  igb_get_pcs_speed_and_duplex_82575 - Retrieve current speed/duplex
  *  @hw: pointer to the HW structure
  *  @speed: stores the current speed
  *  @duplex: stores the current duplex
  *
- *  Using the physical coding sub-layer (PCS), retreive the current speed and
+ *  Using the physical coding sub-layer (PCS), retrieve the current speed and
  *  duplex, then store the values in the pointers provided.
  **/
 static s32 igb_get_pcs_speed_and_duplex_82575(struct e1000_hw *hw, u16 *speed,
@@ -764,7 +757,7 @@ static s32 igb_get_pcs_speed_and_duplex_82575(struct e1000_hw *hw, u16 *speed,
 }
 
 /**
- *  e1000_rar_set_82575 - Set receive address register
+ *  igb_rar_set_82575 - Set receive address register
  *  @hw: pointer to the HW structure
  *  @addr: pointer to the receive address
  *  @index: receive address array register
@@ -781,7 +774,7 @@ static void igb_rar_set_82575(struct e1000_hw *hw, u8 *addr, u32 index)
 }
 
 /**
- *  e1000_reset_hw_82575 - Reset hardware
+ *  igb_reset_hw_82575 - Reset hardware
  *  @hw: pointer to the HW structure
  *
  *  This resets the hardware into a known state.  This is a
@@ -798,9 +791,9 @@ static s32 igb_reset_hw_82575(struct e1000_hw *hw)
 	 */
 	ret_val = igb_disable_pcie_master(hw);
 	if (ret_val)
-		hw_dbg(hw, "PCI-E Master disable polling has failed.\n");
+		hw_dbg("PCI-E Master disable polling has failed.\n");
 
-	hw_dbg(hw, "Masking off all interrupts\n");
+	hw_dbg("Masking off all interrupts\n");
 	wr32(E1000_IMC, 0xffffffff);
 
 	wr32(E1000_RCTL, 0);
@@ -811,7 +804,7 @@ static s32 igb_reset_hw_82575(struct e1000_hw *hw)
 
 	ctrl = rd32(E1000_CTRL);
 
-	hw_dbg(hw, "Issuing a global reset to MAC\n");
+	hw_dbg("Issuing a global reset to MAC\n");
 	wr32(E1000_CTRL, ctrl | E1000_CTRL_RST);
 
 	ret_val = igb_get_auto_rd_done(hw);
@@ -821,7 +814,7 @@ static s32 igb_reset_hw_82575(struct e1000_hw *hw)
 		 * return with an error. This can happen in situations
 		 * where there is no eeprom and prevents getting link.
 		 */
-		hw_dbg(hw, "Auto Read Done did not complete\n");
+		hw_dbg("Auto Read Done did not complete\n");
 	}
 
 	/* If EEPROM is not present, run manual init scripts */
@@ -838,7 +831,7 @@ static s32 igb_reset_hw_82575(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_init_hw_82575 - Initialize hardware
+ *  igb_init_hw_82575 - Initialize hardware
  *  @hw: pointer to the HW structure
  *
  *  This inits the hardware readying it for operation.
@@ -852,18 +845,18 @@ static s32 igb_init_hw_82575(struct e1000_hw *hw)
 	/* Initialize identification LED */
 	ret_val = igb_id_led_init(hw);
 	if (ret_val) {
-		hw_dbg(hw, "Error initializing identification LED\n");
+		hw_dbg("Error initializing identification LED\n");
 		/* This is not fatal and we should not stop init due to this */
 	}
 
 	/* Disabling VLAN filtering */
-	hw_dbg(hw, "Initializing the IEEE VLAN\n");
+	hw_dbg("Initializing the IEEE VLAN\n");
 	igb_clear_vfta(hw);
 
 	/* Setup the receive address */
 	igb_init_rx_addrs(hw, rar_count);
 	/* Zero out the Multicast HASH table */
-	hw_dbg(hw, "Zeroing the MTA\n");
+	hw_dbg("Zeroing the MTA\n");
 	for (i = 0; i < mac->mta_reg_count; i++)
 		array_wr32(E1000_MTA, i, 0);
 
@@ -882,7 +875,7 @@ static s32 igb_init_hw_82575(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_setup_copper_link_82575 - Configure copper link settings
+ *  igb_setup_copper_link_82575 - Configure copper link settings
  *  @hw: pointer to the HW structure
  *
  *  Configures the link for auto-neg or forced speed and duplex.  Then we check
@@ -933,10 +926,10 @@ static s32 igb_setup_copper_link_82575(struct e1000_hw *hw)
 		 * PHY will be set to 10H, 10F, 100H or 100F
 		 * depending on user settings.
 		 */
-		hw_dbg(hw, "Forcing Speed and Duplex\n");
+		hw_dbg("Forcing Speed and Duplex\n");
 		ret_val = igb_phy_force_speed_duplex(hw);
 		if (ret_val) {
-			hw_dbg(hw, "Error Forcing Speed and Duplex\n");
+			hw_dbg("Error Forcing Speed and Duplex\n");
 			goto out;
 		}
 	}
@@ -949,20 +942,17 @@ static s32 igb_setup_copper_link_82575(struct e1000_hw *hw)
 	 * Check link status. Wait up to 100 microseconds for link to become
 	 * valid.
 	 */
-	ret_val = igb_phy_has_link(hw,
-					     COPPER_LINK_UP_LIMIT,
-					     10,
-					     &link);
+	ret_val = igb_phy_has_link(hw, COPPER_LINK_UP_LIMIT, 10, &link);
 	if (ret_val)
 		goto out;
 
 	if (link) {
-		hw_dbg(hw, "Valid link established!!!\n");
+		hw_dbg("Valid link established!!!\n");
 		/* Config the MAC and PHY after link is up */
 		igb_config_collision_dist(hw);
 		ret_val = igb_config_fc_after_link_up(hw);
 	} else {
-		hw_dbg(hw, "Unable to establish link!!!\n");
+		hw_dbg("Unable to establish link!!!\n");
 	}
 
 out:
@@ -970,7 +960,7 @@ out:
 }
 
 /**
- *  e1000_setup_fiber_serdes_link_82575 - Setup link for fiber/serdes
+ *  igb_setup_fiber_serdes_link_82575 - Setup link for fiber/serdes
  *  @hw: pointer to the HW structure
  *
  *  Configures speed and duplex for fiber and serdes links.
@@ -1018,7 +1008,7 @@ static s32 igb_setup_fiber_serdes_link_82575(struct e1000_hw *hw)
 		       E1000_PCS_LCTL_FDV_FULL |      /* SerDes Full duplex */
 		       E1000_PCS_LCTL_AN_ENABLE |     /* Enable Autoneg */
 		       E1000_PCS_LCTL_AN_RESTART;     /* Restart autoneg */
-		hw_dbg(hw, "Configuring Autoneg; PCS_LCTL = 0x%08X\n", reg);
+		hw_dbg("Configuring Autoneg; PCS_LCTL = 0x%08X\n", reg);
 	} else {
 		/* Set PCS register for forced speed */
 		reg |= E1000_PCS_LCTL_FLV_LINK_UP |   /* Force link up */
@@ -1026,7 +1016,7 @@ static s32 igb_setup_fiber_serdes_link_82575(struct e1000_hw *hw)
 		       E1000_PCS_LCTL_FDV_FULL |      /* SerDes Full duplex */
 		       E1000_PCS_LCTL_FSD |           /* Force Speed */
 		       E1000_PCS_LCTL_FORCE_LINK;     /* Force Link */
-		hw_dbg(hw, "Configuring Forced Link; PCS_LCTL = 0x%08X\n", reg);
+		hw_dbg("Configuring Forced Link; PCS_LCTL = 0x%08X\n", reg);
 	}
 	wr32(E1000_PCS_LCTL, reg);
 
@@ -1034,7 +1024,7 @@ static s32 igb_setup_fiber_serdes_link_82575(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_configure_pcs_link_82575 - Configure PCS link
+ *  igb_configure_pcs_link_82575 - Configure PCS link
  *  @hw: pointer to the HW structure
  *
  *  Configure the physical coding sub-layer (PCS) link.  The PCS link is
@@ -1067,7 +1057,7 @@ static s32 igb_configure_pcs_link_82575(struct e1000_hw *hw)
 		 */
 		reg |= E1000_PCS_LCTL_AN_RESTART | E1000_PCS_LCTL_AN_ENABLE;
 	} else {
-		/* Set PCS regiseter for forced speed */
+		/* Set PCS register for forced speed */
 
 		/* Turn off bits for full duplex, speed, and autoneg */
 		reg &= ~(E1000_PCS_LCTL_FSV_1000 |
@@ -1088,8 +1078,7 @@ static s32 igb_configure_pcs_link_82575(struct e1000_hw *hw)
 		       E1000_PCS_LCTL_FORCE_LINK |
 		       E1000_PCS_LCTL_FLV_LINK_UP;
 
-		hw_dbg(hw,
-		       "Wrote 0x%08X to PCS_LCTL to configure forced link\n",
+		hw_dbg("Wrote 0x%08X to PCS_LCTL to configure forced link\n",
 		       reg);
 	}
 	wr32(E1000_PCS_LCTL, reg);
@@ -1099,7 +1088,7 @@ out:
 }
 
 /**
- *  e1000_sgmii_active_82575 - Return sgmii state
+ *  igb_sgmii_active_82575 - Return sgmii state
  *  @hw: pointer to the HW structure
  *
  *  82575 silicon has a serialized gigabit media independent interface (sgmii)
@@ -1125,7 +1114,7 @@ out:
 }
 
 /**
- *  e1000_reset_init_script_82575 - Inits HW defaults after reset
+ *  igb_reset_init_script_82575 - Inits HW defaults after reset
  *  @hw: pointer to the HW structure
  *
  *  Inits recommended HW defaults after a reset when there is no EEPROM
@@ -1134,7 +1123,7 @@ out:
 static s32 igb_reset_init_script_82575(struct e1000_hw *hw)
 {
 	if (hw->mac.type == e1000_82575) {
-		hw_dbg(hw, "Running reset init script for 82575\n");
+		hw_dbg("Running reset init script for 82575\n");
 		/* SerDes configuration via SERDESCTRL */
 		igb_write_8bit_ctrl_reg(hw, E1000_SCTL, 0x00, 0x0C);
 		igb_write_8bit_ctrl_reg(hw, E1000_SCTL, 0x01, 0x78);
@@ -1161,7 +1150,7 @@ static s32 igb_reset_init_script_82575(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_read_mac_addr_82575 - Read device MAC address
+ *  igb_read_mac_addr_82575 - Read device MAC address
  *  @hw: pointer to the HW structure
  **/
 static s32 igb_read_mac_addr_82575(struct e1000_hw *hw)
@@ -1175,7 +1164,7 @@ static s32 igb_read_mac_addr_82575(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_clear_hw_cntrs_82575 - Clear device specific hardware counters
+ *  igb_clear_hw_cntrs_82575 - Clear device specific hardware counters
  *  @hw: pointer to the HW structure
  *
  *  Clears the hardware counters by reading the counter registers.
@@ -1238,6 +1227,79 @@ static void igb_clear_hw_cntrs_82575(struct e1000_hw *hw)
 		temp = rd32(E1000_SCVPC);
 }
 
+/**
+ *  igb_rx_fifo_flush_82575 - Clean rx fifo after RX enable
+ *  @hw: pointer to the HW structure
+ *
+ *  After rx enable if managability is enabled then there is likely some
+ *  bad data at the start of the fifo and possibly in the DMA fifo.  This
+ *  function clears the fifos and flushes any packets that came in as rx was
+ *  being enabled.
+ **/
+void igb_rx_fifo_flush_82575(struct e1000_hw *hw)
+{
+	u32 rctl, rlpml, rxdctl[4], rfctl, temp_rctl, rx_enabled;
+	int i, ms_wait;
+
+	if (hw->mac.type != e1000_82575 ||
+	    !(rd32(E1000_MANC) & E1000_MANC_RCV_TCO_EN))
+		return;
+
+	/* Disable all RX queues */
+	for (i = 0; i < 4; i++) {
+		rxdctl[i] = rd32(E1000_RXDCTL(i));
+		wr32(E1000_RXDCTL(i),
+		     rxdctl[i] & ~E1000_RXDCTL_QUEUE_ENABLE);
+	}
+	/* Poll all queues to verify they have shut down */
+	for (ms_wait = 0; ms_wait < 10; ms_wait++) {
+		msleep(1);
+		rx_enabled = 0;
+		for (i = 0; i < 4; i++)
+			rx_enabled |= rd32(E1000_RXDCTL(i));
+		if (!(rx_enabled & E1000_RXDCTL_QUEUE_ENABLE))
+			break;
+	}
+
+	if (ms_wait == 10)
+		hw_dbg("Queue disable timed out after 10ms\n");
+
+	/* Clear RLPML, RCTL.SBP, RFCTL.LEF, and set RCTL.LPE so that all
+	 * incoming packets are rejected.  Set enable and wait 2ms so that
+	 * any packet that was coming in as RCTL.EN was set is flushed
+	 */
+	rfctl = rd32(E1000_RFCTL);
+	wr32(E1000_RFCTL, rfctl & ~E1000_RFCTL_LEF);
+
+	rlpml = rd32(E1000_RLPML);
+	wr32(E1000_RLPML, 0);
+
+	rctl = rd32(E1000_RCTL);
+	temp_rctl = rctl & ~(E1000_RCTL_EN | E1000_RCTL_SBP);
+	temp_rctl |= E1000_RCTL_LPE;
+
+	wr32(E1000_RCTL, temp_rctl);
+	wr32(E1000_RCTL, temp_rctl | E1000_RCTL_EN);
+	wrfl();
+	msleep(2);
+
+	/* Enable RX queues that were previously enabled and restore our
+	 * previous state
+	 */
+	for (i = 0; i < 4; i++)
+		wr32(E1000_RXDCTL(i), rxdctl[i]);
+	wr32(E1000_RCTL, rctl);
+	wrfl();
+
+	wr32(E1000_RLPML, rlpml);
+	wr32(E1000_RFCTL, rfctl);
+
+	/* Flush receive errors generated by workaround */
+	rd32(E1000_ROC);
+	rd32(E1000_RNBC);
+	rd32(E1000_MPC);
+}
+
 static struct e1000_mac_operations e1000_mac_ops_82575 = {
 	.reset_hw             = igb_reset_hw_82575,
 	.init_hw              = igb_init_hw_82575,
diff --git a/drivers/net/igb/e1000_82575.h b/drivers/net/igb/e1000_82575.h
index 76ea846..d78ad33 100644
--- a/drivers/net/igb/e1000_82575.h
+++ b/drivers/net/igb/e1000_82575.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007 Intel Corporation.
+  Copyright(c) 2007 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -28,6 +28,8 @@
 #ifndef _E1000_82575_H_
 #define _E1000_82575_H_
 
+extern void igb_rx_fifo_flush_82575(struct e1000_hw *hw);
+
 #define E1000_RAR_ENTRIES_82575   16
 
 /* SRRCTL bit definitions */
@@ -56,7 +58,7 @@
 #define E1000_EIMS_RX_QUEUE E1000_EICR_RX_QUEUE
 #define E1000_EIMS_TX_QUEUE E1000_EICR_TX_QUEUE
 
-/* Immediate Interrupt RX (A.K.A. Low Latency Interrupt) */
+/* Immediate Interrupt Rx (A.K.A. Low Latency Interrupt) */
 
 /* Receive Descriptor - Advanced */
 union e1000_adv_rx_desc {
@@ -145,6 +147,6 @@ struct e1000_adv_tx_context_desc {
 
 
 
-#define E1000_DCA_TXCTRL_TX_WB_RO_EN (1 << 11) /* TX Desc writeback RO bit */
+#define E1000_DCA_TXCTRL_TX_WB_RO_EN (1 << 11) /* Tx Desc writeback RO bit */
 
 #endif
diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index 8da9ffe..ed748dc 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007 Intel Corporation.
+  Copyright(c) 2007 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -91,12 +91,12 @@
 #define E1000_MAX_SGMII_PHY_REG_ADDR  255
 #define E1000_I2CCMD_PHY_TIMEOUT      200
 
-/* Receive Decriptor bit definitions */
+/* Receive Descriptor bit definitions */
 #define E1000_RXD_STAT_DD       0x01    /* Descriptor Done */
 #define E1000_RXD_STAT_EOP      0x02    /* End of Packet */
 #define E1000_RXD_STAT_IXSM     0x04    /* Ignore checksum */
 #define E1000_RXD_STAT_VP       0x08    /* IEEE VLAN Packet */
-#define E1000_RXD_STAT_UDPCS    0x10    /* UDP xsum caculated */
+#define E1000_RXD_STAT_UDPCS    0x10    /* UDP xsum calculated */
 #define E1000_RXD_STAT_TCPCS    0x20    /* TCP xsum calculated */
 #define E1000_RXD_STAT_DYNINT   0x800   /* Pkt caused INT via DYNINT */
 #define E1000_RXD_ERR_CE        0x01    /* CRC Error */
@@ -340,6 +340,7 @@
 #define E1000_RXCSUM_PCSD      0x00002000   /* packet checksum disabled */
 
 /* Header split receive */
+#define E1000_RFCTL_LEF        0x00040000
 
 /* Collision related configuration parameters */
 #define E1000_COLLISION_THRESHOLD       15
@@ -379,7 +380,7 @@
 #define E1000_ICR_RXO           0x00000040 /* rx overrun */
 #define E1000_ICR_RXT0          0x00000080 /* rx timer intr (ring 0) */
 #define E1000_ICR_MDAC          0x00000200 /* MDIO access complete */
-#define E1000_ICR_RXCFG         0x00000400 /* RX /c/ ordered set */
+#define E1000_ICR_RXCFG         0x00000400 /* Rx /c/ ordered set */
 #define E1000_ICR_GPI_EN0       0x00000800 /* GP Int 0 */
 #define E1000_ICR_GPI_EN1       0x00001000 /* GP Int 1 */
 #define E1000_ICR_GPI_EN2       0x00002000 /* GP Int 2 */
@@ -443,12 +444,6 @@
 #define E1000_IMS_RXSEQ     E1000_ICR_RXSEQ     /* rx sequence error */
 #define E1000_IMS_RXDMT0    E1000_ICR_RXDMT0    /* rx desc min. threshold */
 #define E1000_IMS_RXT0      E1000_ICR_RXT0      /* rx timer intr */
-/* queue 0 Rx descriptor FIFO parity error */
-/* queue 0 Tx descriptor FIFO parity error */
-/* host arb read buffer parity error */
-/* packet buffer parity error */
-/* queue 1 Rx descriptor FIFO parity error */
-/* queue 1 Tx descriptor FIFO parity error */
 
 /* Extended Interrupt Mask Set */
 #define E1000_EIMS_TCP_TIMER    E1000_EICR_TCP_TIMER /* TCP Timer */
@@ -457,12 +452,6 @@
 /* Interrupt Cause Set */
 #define E1000_ICS_LSC       E1000_ICR_LSC       /* Link Status Change */
 #define E1000_ICS_RXDMT0    E1000_ICR_RXDMT0    /* rx desc min. threshold */
-/* queue 0 Rx descriptor FIFO parity error */
-/* queue 0 Tx descriptor FIFO parity error */
-/* host arb read buffer parity error */
-/* packet buffer parity error */
-/* queue 1 Rx descriptor FIFO parity error */
-/* queue 1 Tx descriptor FIFO parity error */
 
 /* Extended Interrupt Cause Set */
 
@@ -567,7 +556,6 @@
 /* 1000BASE-T Control Register */
 #define CR_1000T_HD_CAPS         0x0100 /* Advertise 1000T HD capability */
 #define CR_1000T_FD_CAPS         0x0200 /* Advertise 1000T FD capability  */
-					/* 0=DTE device */
 #define CR_1000T_MS_VALUE        0x0800 /* 1=Configure PHY as Master */
 					/* 0=Configure PHY as Slave */
 #define CR_1000T_MS_ENABLE       0x1000 /* 1=Master/Slave manual config value */
@@ -581,7 +569,7 @@
 /* PHY 1000 MII Register/Bit Definitions */
 /* PHY Registers defined by IEEE */
 #define PHY_CONTROL      0x00 /* Control Register */
-#define PHY_STATUS       0x01 /* Status Regiser */
+#define PHY_STATUS       0x01 /* Status Register */
 #define PHY_ID1          0x02 /* Phy Id Reg (word 1) */
 #define PHY_ID2          0x03 /* Phy Id Reg (word 2) */
 #define PHY_AUTONEG_ADV  0x04 /* Autoneg Advertisement */
@@ -708,8 +696,8 @@
 /* Auto crossover enabled all speeds */
 #define M88E1000_PSCR_AUTO_X_MODE      0x0060
 /*
- * 1=Enable Extended 10BASE-T distance (Lower 10BASE-T RX Threshold
- * 0=Normal 10BASE-T RX Threshold
+ * 1=Enable Extended 10BASE-T distance (Lower 10BASE-T Rx Threshold
+ * 0=Normal 10BASE-T Rx Threshold
  */
 /* 1=5-bit interface in 100BASE-TX, 0=MII interface in 100BASE-TX */
 #define M88E1000_PSCR_ASSERT_CRS_ON_TX     0x0800 /* 1=Assert CRS on Transmit */
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index 7b2c70a..746c3ea 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -586,14 +586,10 @@ struct e1000_hw {
 
 #ifdef DEBUG
 extern char *igb_get_hw_dev_name(struct e1000_hw *hw);
-#define hw_dbg(hw, format, arg...) \
+#define hw_dbg(format, arg...) \
 	printk(KERN_DEBUG "%s: " format, igb_get_hw_dev_name(hw), ##arg)
 #else
-static inline int __attribute__ ((format (printf, 2, 3)))
-hw_dbg(struct e1000_hw *hw, const char *format, ...)
-{
-	return 0;
-}
+#define hw_dbg(format, arg...)
 #endif
 
 #endif
diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index 3e84a3f..47ad2c4 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -39,7 +39,7 @@ static s32 igb_set_fc_watermarks(struct e1000_hw *hw);
 static u32 igb_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr);
 
 /**
- *  e1000_remove_device - Free device specific structure
+ *  igb_remove_device - Free device specific structure
  *  @hw: pointer to the HW structure
  *
  *  If a device specific structure was allocated, this function will
@@ -73,7 +73,7 @@ static s32 igb_read_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value)
 }
 
 /**
- *  e1000_get_bus_info_pcie - Get PCIe bus information
+ *  igb_get_bus_info_pcie - Get PCIe bus information
  *  @hw: pointer to the HW structure
  *
  *  Determines and stores the system bus information for a particular
@@ -113,7 +113,7 @@ s32 igb_get_bus_info_pcie(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_clear_vfta - Clear VLAN filter table
+ *  igb_clear_vfta - Clear VLAN filter table
  *  @hw: pointer to the HW structure
  *
  *  Clears the register array which contains the VLAN filter table by
@@ -130,7 +130,7 @@ void igb_clear_vfta(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_write_vfta - Write value to VLAN filter table
+ *  igb_write_vfta - Write value to VLAN filter table
  *  @hw: pointer to the HW structure
  *  @offset: register offset in VLAN filter table
  *  @value: register value written to VLAN filter table
@@ -145,7 +145,7 @@ void igb_write_vfta(struct e1000_hw *hw, u32 offset, u32 value)
 }
 
 /**
- *  e1000_init_rx_addrs - Initialize receive address's
+ *  igb_init_rx_addrs - Initialize receive address's
  *  @hw: pointer to the HW structure
  *  @rar_count: receive address registers
  *
@@ -158,12 +158,12 @@ void igb_init_rx_addrs(struct e1000_hw *hw, u16 rar_count)
 	u32 i;
 
 	/* Setup the receive address */
-	hw_dbg(hw, "Programming MAC Address into RAR[0]\n");
+	hw_dbg("Programming MAC Address into RAR[0]\n");
 
 	hw->mac.ops.rar_set(hw, hw->mac.addr, 0);
 
 	/* Zero out the other (rar_entry_count - 1) receive addresses */
-	hw_dbg(hw, "Clearing RAR[1-%u]\n", rar_count-1);
+	hw_dbg("Clearing RAR[1-%u]\n", rar_count-1);
 	for (i = 1; i < rar_count; i++) {
 		array_wr32(E1000_RA, (i << 1), 0);
 		wrfl();
@@ -173,7 +173,7 @@ void igb_init_rx_addrs(struct e1000_hw *hw, u16 rar_count)
 }
 
 /**
- *  e1000_check_alt_mac_addr - Check for alternate MAC addr
+ *  igb_check_alt_mac_addr - Check for alternate MAC addr
  *  @hw: pointer to the HW structure
  *
  *  Checks the nvm for an alternate MAC address.  An alternate MAC address
@@ -193,7 +193,7 @@ s32 igb_check_alt_mac_addr(struct e1000_hw *hw)
 	ret_val = hw->nvm.ops.read_nvm(hw, NVM_ALT_MAC_ADDR_PTR, 1,
 				 &nvm_alt_mac_addr_offset);
 	if (ret_val) {
-		hw_dbg(hw, "NVM Read Error\n");
+		hw_dbg("NVM Read Error\n");
 		goto out;
 	}
 
@@ -209,7 +209,7 @@ s32 igb_check_alt_mac_addr(struct e1000_hw *hw)
 		offset = nvm_alt_mac_addr_offset + (i >> 1);
 		ret_val = hw->nvm.ops.read_nvm(hw, offset, 1, &nvm_data);
 		if (ret_val) {
-			hw_dbg(hw, "NVM Read Error\n");
+			hw_dbg("NVM Read Error\n");
 			goto out;
 		}
 
@@ -233,7 +233,7 @@ out:
 }
 
 /**
- *  e1000_rar_set - Set receive address register
+ *  igb_rar_set - Set receive address register
  *  @hw: pointer to the HW structure
  *  @addr: pointer to the receive address
  *  @index: receive address array register
@@ -263,7 +263,7 @@ void igb_rar_set(struct e1000_hw *hw, u8 *addr, u32 index)
 }
 
 /**
- *  e1000_mta_set - Set multicast filter table address
+ *  igb_mta_set - Set multicast filter table address
  *  @hw: pointer to the HW structure
  *  @hash_value: determines the MTA register and bit to set
  *
@@ -298,7 +298,7 @@ static void igb_mta_set(struct e1000_hw *hw, u32 hash_value)
 }
 
 /**
- *  e1000_update_mc_addr_list - Update Multicast addresses
+ *  igb_update_mc_addr_list - Update Multicast addresses
  *  @hw: pointer to the HW structure
  *  @mc_addr_list: array of multicast addresses to program
  *  @mc_addr_count: number of multicast addresses to program
@@ -336,7 +336,7 @@ void igb_update_mc_addr_list(struct e1000_hw *hw,
 	}
 
 	/* Clear the old settings from the MTA */
-	hw_dbg(hw, "Clearing MTA\n");
+	hw_dbg("Clearing MTA\n");
 	for (i = 0; i < hw->mac.mta_reg_count; i++) {
 		array_wr32(E1000_MTA, i, 0);
 		wrfl();
@@ -345,14 +345,14 @@ void igb_update_mc_addr_list(struct e1000_hw *hw,
 	/* Load any remaining multicast addresses into the hash table. */
 	for (; mc_addr_count > 0; mc_addr_count--) {
 		hash_value = igb_hash_mc_addr(hw, mc_addr_list);
-		hw_dbg(hw, "Hash value = 0x%03X\n", hash_value);
+		hw_dbg("Hash value = 0x%03X\n", hash_value);
 		igb_mta_set(hw, hash_value);
 		mc_addr_list += ETH_ALEN;
 	}
 }
 
 /**
- *  e1000_hash_mc_addr - Generate a multicast hash value
+ *  igb_hash_mc_addr - Generate a multicast hash value
  *  @hw: pointer to the HW structure
  *  @mc_addr: pointer to a multicast address
  *
@@ -423,7 +423,7 @@ static u32 igb_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr)
 }
 
 /**
- *  e1000_clear_hw_cntrs_base - Clear base hardware counters
+ *  igb_clear_hw_cntrs_base - Clear base hardware counters
  *  @hw: pointer to the HW structure
  *
  *  Clears the base hardware counters by reading the counter registers.
@@ -472,7 +472,7 @@ void igb_clear_hw_cntrs_base(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_check_for_copper_link - Check for link (Copper)
+ *  igb_check_for_copper_link - Check for link (Copper)
  *  @hw: pointer to the HW structure
  *
  *  Checks to see of the link status of the hardware has changed.  If a
@@ -540,14 +540,14 @@ s32 igb_check_for_copper_link(struct e1000_hw *hw)
 	 */
 	ret_val = igb_config_fc_after_link_up(hw);
 	if (ret_val)
-		hw_dbg(hw, "Error configuring flow control\n");
+		hw_dbg("Error configuring flow control\n");
 
 out:
 	return ret_val;
 }
 
 /**
- *  e1000_setup_link - Setup flow control and link settings
+ *  igb_setup_link - Setup flow control and link settings
  *  @hw: pointer to the HW structure
  *
  *  Determines which flow control settings to use, then configures flow
@@ -578,7 +578,7 @@ s32 igb_setup_link(struct e1000_hw *hw)
 	 */
 	hw->fc.original_type = hw->fc.type;
 
-	hw_dbg(hw, "After fix-ups FlowControl is now = %x\n", hw->fc.type);
+	hw_dbg("After fix-ups FlowControl is now = %x\n", hw->fc.type);
 
 	/* Call the necessary media_type subroutine to configure the link. */
 	ret_val = hw->mac.ops.setup_physical_interface(hw);
@@ -591,8 +591,7 @@ s32 igb_setup_link(struct e1000_hw *hw)
 	 * control is disabled, because it does not hurt anything to
 	 * initialize these registers.
 	 */
-	hw_dbg(hw,
-	       "Initializing the Flow Control address, type and timer regs\n");
+	hw_dbg("Initializing the Flow Control address, type and timer regs\n");
 	wr32(E1000_FCT, FLOW_CONTROL_TYPE);
 	wr32(E1000_FCAH, FLOW_CONTROL_ADDRESS_HIGH);
 	wr32(E1000_FCAL, FLOW_CONTROL_ADDRESS_LOW);
@@ -606,7 +605,7 @@ out:
 }
 
 /**
- *  e1000_config_collision_dist - Configure collision distance
+ *  igb_config_collision_dist - Configure collision distance
  *  @hw: pointer to the HW structure
  *
  *  Configures the collision distance to the default value and is used
@@ -627,7 +626,7 @@ void igb_config_collision_dist(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_set_fc_watermarks - Set flow control high/low watermarks
+ *  igb_set_fc_watermarks - Set flow control high/low watermarks
  *  @hw: pointer to the HW structure
  *
  *  Sets the flow control high/low threshold (watermark) registers.  If
@@ -665,7 +664,7 @@ static s32 igb_set_fc_watermarks(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_set_default_fc - Set flow control default values
+ *  igb_set_default_fc - Set flow control default values
  *  @hw: pointer to the HW structure
  *
  *  Read the EEPROM for the default values for flow control and store the
@@ -689,7 +688,7 @@ static s32 igb_set_default_fc(struct e1000_hw *hw)
 				       &nvm_data);
 
 	if (ret_val) {
-		hw_dbg(hw, "NVM Read Error\n");
+		hw_dbg("NVM Read Error\n");
 		goto out;
 	}
 
@@ -706,7 +705,7 @@ out:
 }
 
 /**
- *  e1000_force_mac_fc - Force the MAC's flow control settings
+ *  igb_force_mac_fc - Force the MAC's flow control settings
  *  @hw: pointer to the HW structure
  *
  *  Force the MAC's flow control settings.  Sets the TFCE and RFCE bits in the
@@ -740,7 +739,7 @@ s32 igb_force_mac_fc(struct e1000_hw *hw)
 	 *      3:  Both Rx and TX flow control (symmetric) is enabled.
 	 *  other:  No other values should be possible at this point.
 	 */
-	hw_dbg(hw, "hw->fc.type = %u\n", hw->fc.type);
+	hw_dbg("hw->fc.type = %u\n", hw->fc.type);
 
 	switch (hw->fc.type) {
 	case e1000_fc_none:
@@ -758,7 +757,7 @@ s32 igb_force_mac_fc(struct e1000_hw *hw)
 		ctrl |= (E1000_CTRL_TFCE | E1000_CTRL_RFCE);
 		break;
 	default:
-		hw_dbg(hw, "Flow control param set incorrectly\n");
+		hw_dbg("Flow control param set incorrectly\n");
 		ret_val = -E1000_ERR_CONFIG;
 		goto out;
 	}
@@ -770,7 +769,7 @@ out:
 }
 
 /**
- *  e1000_config_fc_after_link_up - Configures flow control after link
+ *  igb_config_fc_after_link_up - Configures flow control after link
  *  @hw: pointer to the HW structure
  *
  *  Checks the status of auto-negotiation after link up to ensure that the
@@ -801,7 +800,7 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 	}
 
 	if (ret_val) {
-		hw_dbg(hw, "Error forcing flow control settings\n");
+		hw_dbg("Error forcing flow control settings\n");
 		goto out;
 	}
 
@@ -827,7 +826,7 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 			goto out;
 
 		if (!(mii_status_reg & MII_SR_AUTONEG_COMPLETE)) {
-			hw_dbg(hw, "Copper PHY and Auto Neg "
+			hw_dbg("Copper PHY and Auto Neg "
 				 "has not completed.\n");
 			goto out;
 		}
@@ -893,11 +892,11 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 			 */
 			if (hw->fc.original_type == e1000_fc_full) {
 				hw->fc.type = e1000_fc_full;
-				hw_dbg(hw, "Flow Control = FULL.\r\n");
+				hw_dbg("Flow Control = FULL.\r\n");
 			} else {
 				hw->fc.type = e1000_fc_rx_pause;
-				hw_dbg(hw, "Flow Control = "
-					 "RX PAUSE frames only.\r\n");
+				hw_dbg("Flow Control = "
+				       "RX PAUSE frames only.\r\n");
 			}
 		}
 		/*
@@ -913,7 +912,7 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 			  (mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE) &&
 			  (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
 			hw->fc.type = e1000_fc_tx_pause;
-			hw_dbg(hw, "Flow Control = TX PAUSE frames only.\r\n");
+			hw_dbg("Flow Control = TX PAUSE frames only.\r\n");
 		}
 		/*
 		 * For transmitting PAUSE frames ONLY.
@@ -928,7 +927,7 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 			 !(mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE) &&
 			 (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
 			hw->fc.type = e1000_fc_rx_pause;
-			hw_dbg(hw, "Flow Control = RX PAUSE frames only.\r\n");
+			hw_dbg("Flow Control = RX PAUSE frames only.\r\n");
 		}
 		/*
 		 * Per the IEEE spec, at this point flow control should be
@@ -955,10 +954,10 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 			  hw->fc.original_type == e1000_fc_tx_pause) ||
 			 hw->fc.strict_ieee) {
 			hw->fc.type = e1000_fc_none;
-			hw_dbg(hw, "Flow Control = NONE.\r\n");
+			hw_dbg("Flow Control = NONE.\r\n");
 		} else {
 			hw->fc.type = e1000_fc_rx_pause;
-			hw_dbg(hw, "Flow Control = RX PAUSE frames only.\r\n");
+			hw_dbg("Flow Control = RX PAUSE frames only.\r\n");
 		}
 
 		/*
@@ -968,7 +967,7 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 		 */
 		ret_val = hw->mac.ops.get_speed_and_duplex(hw, &speed, &duplex);
 		if (ret_val) {
-			hw_dbg(hw, "Error getting link speed and duplex\n");
+			hw_dbg("Error getting link speed and duplex\n");
 			goto out;
 		}
 
@@ -981,7 +980,7 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 		 */
 		ret_val = igb_force_mac_fc(hw);
 		if (ret_val) {
-			hw_dbg(hw, "Error forcing flow control settings\n");
+			hw_dbg("Error forcing flow control settings\n");
 			goto out;
 		}
 	}
@@ -991,7 +990,7 @@ out:
 }
 
 /**
- *  e1000_get_speed_and_duplex_copper - Retreive current speed/duplex
+ *  igb_get_speed_and_duplex_copper - Retreive current speed/duplex
  *  @hw: pointer to the HW structure
  *  @speed: stores the current speed
  *  @duplex: stores the current duplex
@@ -1007,28 +1006,28 @@ s32 igb_get_speed_and_duplex_copper(struct e1000_hw *hw, u16 *speed,
 	status = rd32(E1000_STATUS);
 	if (status & E1000_STATUS_SPEED_1000) {
 		*speed = SPEED_1000;
-		hw_dbg(hw, "1000 Mbs, ");
+		hw_dbg("1000 Mbs, ");
 	} else if (status & E1000_STATUS_SPEED_100) {
 		*speed = SPEED_100;
-		hw_dbg(hw, "100 Mbs, ");
+		hw_dbg("100 Mbs, ");
 	} else {
 		*speed = SPEED_10;
-		hw_dbg(hw, "10 Mbs, ");
+		hw_dbg("10 Mbs, ");
 	}
 
 	if (status & E1000_STATUS_FD) {
 		*duplex = FULL_DUPLEX;
-		hw_dbg(hw, "Full Duplex\n");
+		hw_dbg("Full Duplex\n");
 	} else {
 		*duplex = HALF_DUPLEX;
-		hw_dbg(hw, "Half Duplex\n");
+		hw_dbg("Half Duplex\n");
 	}
 
 	return 0;
 }
 
 /**
- *  e1000_get_hw_semaphore - Acquire hardware semaphore
+ *  igb_get_hw_semaphore - Acquire hardware semaphore
  *  @hw: pointer to the HW structure
  *
  *  Acquire the HW semaphore to access the PHY or NVM
@@ -1051,7 +1050,7 @@ s32 igb_get_hw_semaphore(struct e1000_hw *hw)
 	}
 
 	if (i == timeout) {
-		hw_dbg(hw, "Driver can't access device - SMBI bit is set.\n");
+		hw_dbg("Driver can't access device - SMBI bit is set.\n");
 		ret_val = -E1000_ERR_NVM;
 		goto out;
 	}
@@ -1071,7 +1070,7 @@ s32 igb_get_hw_semaphore(struct e1000_hw *hw)
 	if (i == timeout) {
 		/* Release semaphores */
 		igb_put_hw_semaphore(hw);
-		hw_dbg(hw, "Driver can't access the NVM\n");
+		hw_dbg("Driver can't access the NVM\n");
 		ret_val = -E1000_ERR_NVM;
 		goto out;
 	}
@@ -1081,7 +1080,7 @@ out:
 }
 
 /**
- *  e1000_put_hw_semaphore - Release hardware semaphore
+ *  igb_put_hw_semaphore - Release hardware semaphore
  *  @hw: pointer to the HW structure
  *
  *  Release hardware semaphore used to access the PHY or NVM
@@ -1098,7 +1097,7 @@ void igb_put_hw_semaphore(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_get_auto_rd_done - Check for auto read completion
+ *  igb_get_auto_rd_done - Check for auto read completion
  *  @hw: pointer to the HW structure
  *
  *  Check EEPROM for Auto Read done bit.
@@ -1117,7 +1116,7 @@ s32 igb_get_auto_rd_done(struct e1000_hw *hw)
 	}
 
 	if (i == AUTO_READ_DONE_TIMEOUT) {
-		hw_dbg(hw, "Auto read by HW from NVM has not completed.\n");
+		hw_dbg("Auto read by HW from NVM has not completed.\n");
 		ret_val = -E1000_ERR_RESET;
 		goto out;
 	}
@@ -1127,7 +1126,7 @@ out:
 }
 
 /**
- *  e1000_valid_led_default - Verify a valid default LED config
+ *  igb_valid_led_default - Verify a valid default LED config
  *  @hw: pointer to the HW structure
  *  @data: pointer to the NVM (EEPROM)
  *
@@ -1140,7 +1139,7 @@ static s32 igb_valid_led_default(struct e1000_hw *hw, u16 *data)
 
 	ret_val = hw->nvm.ops.read_nvm(hw, NVM_ID_LED_SETTINGS, 1, data);
 	if (ret_val) {
-		hw_dbg(hw, "NVM Read Error\n");
+		hw_dbg("NVM Read Error\n");
 		goto out;
 	}
 
@@ -1152,7 +1151,7 @@ out:
 }
 
 /**
- *  e1000_id_led_init -
+ *  igb_id_led_init -
  *  @hw: pointer to the HW structure
  *
  **/
@@ -1217,7 +1216,7 @@ out:
 }
 
 /**
- *  e1000_cleanup_led - Set LED config to default operation
+ *  igb_cleanup_led - Set LED config to default operation
  *  @hw: pointer to the HW structure
  *
  *  Remove the current LED configuration and set the LED configuration
@@ -1230,7 +1229,7 @@ s32 igb_cleanup_led(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_blink_led - Blink LED
+ *  igb_blink_led - Blink LED
  *  @hw: pointer to the HW structure
  *
  *  Blink the led's which are set to be on.
@@ -1263,7 +1262,7 @@ s32 igb_blink_led(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_led_off - Turn LED off
+ *  igb_led_off - Turn LED off
  *  @hw: pointer to the HW structure
  *
  *  Turn LED off.
@@ -1290,7 +1289,7 @@ s32 igb_led_off(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_disable_pcie_master - Disables PCI-express master access
+ *  igb_disable_pcie_master - Disables PCI-express master access
  *  @hw: pointer to the HW structure
  *
  *  Returns 0 (0) if successful, else returns -10
@@ -1322,7 +1321,7 @@ s32 igb_disable_pcie_master(struct e1000_hw *hw)
 	}
 
 	if (!timeout) {
-		hw_dbg(hw, "Master requests are pending.\n");
+		hw_dbg("Master requests are pending.\n");
 		ret_val = -E1000_ERR_MASTER_REQUESTS_PENDING;
 		goto out;
 	}
@@ -1332,7 +1331,7 @@ out:
 }
 
 /**
- *  e1000_reset_adaptive - Reset Adaptive Interframe Spacing
+ *  igb_reset_adaptive - Reset Adaptive Interframe Spacing
  *  @hw: pointer to the HW structure
  *
  *  Reset the Adaptive Interframe Spacing throttle to default values.
@@ -1342,7 +1341,7 @@ void igb_reset_adaptive(struct e1000_hw *hw)
 	struct e1000_mac_info *mac = &hw->mac;
 
 	if (!mac->adaptive_ifs) {
-		hw_dbg(hw, "Not in Adaptive IFS mode!\n");
+		hw_dbg("Not in Adaptive IFS mode!\n");
 		goto out;
 	}
 
@@ -1361,7 +1360,7 @@ out:
 }
 
 /**
- *  e1000_update_adaptive - Update Adaptive Interframe Spacing
+ *  igb_update_adaptive - Update Adaptive Interframe Spacing
  *  @hw: pointer to the HW structure
  *
  *  Update the Adaptive Interframe Spacing Throttle value based on the
@@ -1372,7 +1371,7 @@ void igb_update_adaptive(struct e1000_hw *hw)
 	struct e1000_mac_info *mac = &hw->mac;
 
 	if (!mac->adaptive_ifs) {
-		hw_dbg(hw, "Not in Adaptive IFS mode!\n");
+		hw_dbg("Not in Adaptive IFS mode!\n");
 		goto out;
 	}
 
@@ -1402,7 +1401,7 @@ out:
 }
 
 /**
- *  e1000_validate_mdi_setting - Verify MDI/MDIx settings
+ *  igb_validate_mdi_setting - Verify MDI/MDIx settings
  *  @hw: pointer to the HW structure
  *
  *  Verify that when not using auto-negotitation that MDI/MDIx is correctly
@@ -1413,7 +1412,7 @@ s32 igb_validate_mdi_setting(struct e1000_hw *hw)
 	s32 ret_val = 0;
 
 	if (!hw->mac.autoneg && (hw->phy.mdix == 0 || hw->phy.mdix == 3)) {
-		hw_dbg(hw, "Invalid MDI setting detected\n");
+		hw_dbg("Invalid MDI setting detected\n");
 		hw->phy.mdix = 1;
 		ret_val = -E1000_ERR_CONFIG;
 		goto out;
@@ -1424,7 +1423,7 @@ out:
 }
 
 /**
- *  e1000_write_8bit_ctrl_reg - Write a 8bit CTRL register
+ *  igb_write_8bit_ctrl_reg - Write a 8bit CTRL register
  *  @hw: pointer to the HW structure
  *  @reg: 32bit register offset such as E1000_SCTL
  *  @offset: register offset to write to
@@ -1452,7 +1451,7 @@ s32 igb_write_8bit_ctrl_reg(struct e1000_hw *hw, u32 reg,
 			break;
 	}
 	if (!(regvalue & E1000_GEN_CTL_READY)) {
-		hw_dbg(hw, "Reg %08x did not indicate ready\n", reg);
+		hw_dbg("Reg %08x did not indicate ready\n", reg);
 		ret_val = -E1000_ERR_PHY;
 		goto out;
 	}
@@ -1462,7 +1461,7 @@ out:
 }
 
 /**
- *  e1000_enable_mng_pass_thru - Enable processing of ARP's
+ *  igb_enable_mng_pass_thru - Enable processing of ARP's
  *  @hw: pointer to the HW structure
  *
  *  Verifies the hardware needs to allow ARPs to be processed by the host.
diff --git a/drivers/net/igb/e1000_nvm.c b/drivers/net/igb/e1000_nvm.c
index 2897106..a84e4e4 100644
--- a/drivers/net/igb/e1000_nvm.c
+++ b/drivers/net/igb/e1000_nvm.c
@@ -32,7 +32,7 @@
 #include "e1000_nvm.h"
 
 /**
- *  e1000_raise_eec_clk - Raise EEPROM clock
+ *  igb_raise_eec_clk - Raise EEPROM clock
  *  @hw: pointer to the HW structure
  *  @eecd: pointer to the EEPROM
  *
@@ -47,7 +47,7 @@ static void igb_raise_eec_clk(struct e1000_hw *hw, u32 *eecd)
 }
 
 /**
- *  e1000_lower_eec_clk - Lower EEPROM clock
+ *  igb_lower_eec_clk - Lower EEPROM clock
  *  @hw: pointer to the HW structure
  *  @eecd: pointer to the EEPROM
  *
@@ -62,7 +62,7 @@ static void igb_lower_eec_clk(struct e1000_hw *hw, u32 *eecd)
 }
 
 /**
- *  e1000_shift_out_eec_bits - Shift data bits our to the EEPROM
+ *  igb_shift_out_eec_bits - Shift data bits our to the EEPROM
  *  @hw: pointer to the HW structure
  *  @data: data to send to the EEPROM
  *  @count: number of bits to shift out
@@ -105,7 +105,7 @@ static void igb_shift_out_eec_bits(struct e1000_hw *hw, u16 data, u16 count)
 }
 
 /**
- *  e1000_shift_in_eec_bits - Shift data bits in from the EEPROM
+ *  igb_shift_in_eec_bits - Shift data bits in from the EEPROM
  *  @hw: pointer to the HW structure
  *  @count: number of bits to shift in
  *
@@ -143,7 +143,7 @@ static u16 igb_shift_in_eec_bits(struct e1000_hw *hw, u16 count)
 }
 
 /**
- *  e1000_poll_eerd_eewr_done - Poll for EEPROM read/write completion
+ *  igb_poll_eerd_eewr_done - Poll for EEPROM read/write completion
  *  @hw: pointer to the HW structure
  *  @ee_reg: EEPROM flag for polling
  *
@@ -174,7 +174,7 @@ static s32 igb_poll_eerd_eewr_done(struct e1000_hw *hw, int ee_reg)
 }
 
 /**
- *  e1000_acquire_nvm - Generic request for access to EEPROM
+ *  igb_acquire_nvm - Generic request for access to EEPROM
  *  @hw: pointer to the HW structure
  *
  *  Set the EEPROM access request bit and wait for EEPROM access grant bit.
@@ -202,7 +202,7 @@ s32 igb_acquire_nvm(struct e1000_hw *hw)
 	if (!timeout) {
 		eecd &= ~E1000_EECD_REQ;
 		wr32(E1000_EECD, eecd);
-		hw_dbg(hw, "Could not acquire NVM grant\n");
+		hw_dbg("Could not acquire NVM grant\n");
 		ret_val = -E1000_ERR_NVM;
 	}
 
@@ -210,7 +210,7 @@ s32 igb_acquire_nvm(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_standby_nvm - Return EEPROM to standby state
+ *  igb_standby_nvm - Return EEPROM to standby state
  *  @hw: pointer to the HW structure
  *
  *  Return the EEPROM to a standby state.
@@ -273,7 +273,7 @@ static void e1000_stop_nvm(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_release_nvm - Release exclusive access to EEPROM
+ *  igb_release_nvm - Release exclusive access to EEPROM
  *  @hw: pointer to the HW structure
  *
  *  Stop any current commands to the EEPROM and clear the EEPROM request bit.
@@ -290,7 +290,7 @@ void igb_release_nvm(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_ready_nvm_eeprom - Prepares EEPROM for read/write
+ *  igb_ready_nvm_eeprom - Prepares EEPROM for read/write
  *  @hw: pointer to the HW structure
  *
  *  Setups the EEPROM for reading and writing.
@@ -337,7 +337,7 @@ static s32 igb_ready_nvm_eeprom(struct e1000_hw *hw)
 		}
 
 		if (!timeout) {
-			hw_dbg(hw, "SPI NVM Status error\n");
+			hw_dbg("SPI NVM Status error\n");
 			ret_val = -E1000_ERR_NVM;
 			goto out;
 		}
@@ -348,7 +348,7 @@ out:
 }
 
 /**
- *  e1000_read_nvm_eerd - Reads EEPROM using EERD register
+ *  igb_read_nvm_eerd - Reads EEPROM using EERD register
  *  @hw: pointer to the HW structure
  *  @offset: offset of word in the EEPROM to read
  *  @words: number of words to read
@@ -368,7 +368,7 @@ s32 igb_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 	 */
 	if ((offset >= nvm->word_size) || (words > (nvm->word_size - offset)) ||
 	    (words == 0)) {
-		hw_dbg(hw, "nvm parameter(s) out of bounds\n");
+		hw_dbg("nvm parameter(s) out of bounds\n");
 		ret_val = -E1000_ERR_NVM;
 		goto out;
 	}
@@ -391,7 +391,7 @@ out:
 }
 
 /**
- *  e1000_write_nvm_spi - Write to EEPROM using SPI
+ *  igb_write_nvm_spi - Write to EEPROM using SPI
  *  @hw: pointer to the HW structure
  *  @offset: offset within the EEPROM to be written to
  *  @words: number of words to write
@@ -414,7 +414,7 @@ s32 igb_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 	 */
 	if ((offset >= nvm->word_size) || (words > (nvm->word_size - offset)) ||
 	    (words == 0)) {
-		hw_dbg(hw, "nvm parameter(s) out of bounds\n");
+		hw_dbg("nvm parameter(s) out of bounds\n");
 		ret_val = -E1000_ERR_NVM;
 		goto out;
 	}
@@ -475,7 +475,7 @@ out:
 }
 
 /**
- *  e1000_read_part_num - Read device part number
+ *  igb_read_part_num - Read device part number
  *  @hw: pointer to the HW structure
  *  @part_num: pointer to device part number
  *
@@ -489,14 +489,14 @@ s32 igb_read_part_num(struct e1000_hw *hw, u32 *part_num)
 
 	ret_val = hw->nvm.ops.read_nvm(hw, NVM_PBA_OFFSET_0, 1, &nvm_data);
 	if (ret_val) {
-		hw_dbg(hw, "NVM Read Error\n");
+		hw_dbg("NVM Read Error\n");
 		goto out;
 	}
 	*part_num = (u32)(nvm_data << 16);
 
 	ret_val = hw->nvm.ops.read_nvm(hw, NVM_PBA_OFFSET_1, 1, &nvm_data);
 	if (ret_val) {
-		hw_dbg(hw, "NVM Read Error\n");
+		hw_dbg("NVM Read Error\n");
 		goto out;
 	}
 	*part_num |= nvm_data;
@@ -506,7 +506,7 @@ out:
 }
 
 /**
- *  e1000_read_mac_addr - Read device MAC address
+ *  igb_read_mac_addr - Read device MAC address
  *  @hw: pointer to the HW structure
  *
  *  Reads the device MAC address from the EEPROM and stores the value.
@@ -522,7 +522,7 @@ s32 igb_read_mac_addr(struct e1000_hw *hw)
 		offset = i >> 1;
 		ret_val = hw->nvm.ops.read_nvm(hw, offset, 1, &nvm_data);
 		if (ret_val) {
-			hw_dbg(hw, "NVM Read Error\n");
+			hw_dbg("NVM Read Error\n");
 			goto out;
 		}
 		hw->mac.perm_addr[i] = (u8)(nvm_data & 0xFF);
@@ -541,7 +541,7 @@ out:
 }
 
 /**
- *  e1000_validate_nvm_checksum - Validate EEPROM checksum
+ *  igb_validate_nvm_checksum - Validate EEPROM checksum
  *  @hw: pointer to the HW structure
  *
  *  Calculates the EEPROM checksum by reading/adding each word of the EEPROM
@@ -556,14 +556,14 @@ s32 igb_validate_nvm_checksum(struct e1000_hw *hw)
 	for (i = 0; i < (NVM_CHECKSUM_REG + 1); i++) {
 		ret_val = hw->nvm.ops.read_nvm(hw, i, 1, &nvm_data);
 		if (ret_val) {
-			hw_dbg(hw, "NVM Read Error\n");
+			hw_dbg("NVM Read Error\n");
 			goto out;
 		}
 		checksum += nvm_data;
 	}
 
 	if (checksum != (u16) NVM_SUM) {
-		hw_dbg(hw, "NVM Checksum Invalid\n");
+		hw_dbg("NVM Checksum Invalid\n");
 		ret_val = -E1000_ERR_NVM;
 		goto out;
 	}
@@ -573,7 +573,7 @@ out:
 }
 
 /**
- *  e1000_update_nvm_checksum - Update EEPROM checksum
+ *  igb_update_nvm_checksum - Update EEPROM checksum
  *  @hw: pointer to the HW structure
  *
  *  Updates the EEPROM checksum by reading/adding each word of the EEPROM
@@ -589,7 +589,7 @@ s32 igb_update_nvm_checksum(struct e1000_hw *hw)
 	for (i = 0; i < NVM_CHECKSUM_REG; i++) {
 		ret_val = hw->nvm.ops.read_nvm(hw, i, 1, &nvm_data);
 		if (ret_val) {
-			hw_dbg(hw, "NVM Read Error while updating checksum.\n");
+			hw_dbg("NVM Read Error while updating checksum.\n");
 			goto out;
 		}
 		checksum += nvm_data;
@@ -597,7 +597,7 @@ s32 igb_update_nvm_checksum(struct e1000_hw *hw)
 	checksum = (u16) NVM_SUM - checksum;
 	ret_val = hw->nvm.ops.write_nvm(hw, NVM_CHECKSUM_REG, 1, &checksum);
 	if (ret_val)
-		hw_dbg(hw, "NVM Write Error while updating checksum.\n");
+		hw_dbg("NVM Write Error while updating checksum.\n");
 
 out:
 	return ret_val;
diff --git a/drivers/net/igb/e1000_phy.c b/drivers/net/igb/e1000_phy.c
index 08a86b1..17fddb9 100644
--- a/drivers/net/igb/e1000_phy.c
+++ b/drivers/net/igb/e1000_phy.c
@@ -61,7 +61,7 @@ static const u16 e1000_igp_2_cable_length_table[] =
 		 sizeof(e1000_igp_2_cable_length_table[0]))
 
 /**
- *  e1000_check_reset_block - Check if PHY reset is blocked
+ *  igb_check_reset_block - Check if PHY reset is blocked
  *  @hw: pointer to the HW structure
  *
  *  Read the PHY management control register and check whether a PHY reset
@@ -79,7 +79,7 @@ s32 igb_check_reset_block(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_get_phy_id - Retrieve the PHY ID and revision
+ *  igb_get_phy_id - Retrieve the PHY ID and revision
  *  @hw: pointer to the HW structure
  *
  *  Reads the PHY registers and stores the PHY ID and possibly the PHY
@@ -109,7 +109,7 @@ out:
 }
 
 /**
- *  e1000_phy_reset_dsp - Reset PHY DSP
+ *  igb_phy_reset_dsp - Reset PHY DSP
  *  @hw: pointer to the HW structure
  *
  *  Reset the digital signal processor.
@@ -129,7 +129,7 @@ out:
 }
 
 /**
- *  e1000_read_phy_reg_mdic - Read MDI control register
+ *  igb_read_phy_reg_mdic - Read MDI control register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to be read
  *  @data: pointer to the read data
@@ -144,7 +144,7 @@ static s32 igb_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
 	s32 ret_val = 0;
 
 	if (offset > MAX_PHY_REG_ADDRESS) {
-		hw_dbg(hw, "PHY Address %d is out of range\n", offset);
+		hw_dbg("PHY Address %d is out of range\n", offset);
 		ret_val = -E1000_ERR_PARAM;
 		goto out;
 	}
@@ -172,12 +172,12 @@ static s32 igb_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
 			break;
 	}
 	if (!(mdic & E1000_MDIC_READY)) {
-		hw_dbg(hw, "MDI Read did not complete\n");
+		hw_dbg("MDI Read did not complete\n");
 		ret_val = -E1000_ERR_PHY;
 		goto out;
 	}
 	if (mdic & E1000_MDIC_ERROR) {
-		hw_dbg(hw, "MDI Error\n");
+		hw_dbg("MDI Error\n");
 		ret_val = -E1000_ERR_PHY;
 		goto out;
 	}
@@ -188,7 +188,7 @@ out:
 }
 
 /**
- *  e1000_write_phy_reg_mdic - Write MDI control register
+ *  igb_write_phy_reg_mdic - Write MDI control register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to write to
  *  @data: data to write to register at offset
@@ -202,7 +202,7 @@ static s32 igb_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
 	s32 ret_val = 0;
 
 	if (offset > MAX_PHY_REG_ADDRESS) {
-		hw_dbg(hw, "PHY Address %d is out of range\n", offset);
+		hw_dbg("PHY Address %d is out of range\n", offset);
 		ret_val = -E1000_ERR_PARAM;
 		goto out;
 	}
@@ -231,12 +231,12 @@ static s32 igb_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
 			break;
 	}
 	if (!(mdic & E1000_MDIC_READY)) {
-		hw_dbg(hw, "MDI Write did not complete\n");
+		hw_dbg("MDI Write did not complete\n");
 		ret_val = -E1000_ERR_PHY;
 		goto out;
 	}
 	if (mdic & E1000_MDIC_ERROR) {
-		hw_dbg(hw, "MDI Error\n");
+		hw_dbg("MDI Error\n");
 		ret_val = -E1000_ERR_PHY;
 		goto out;
 	}
@@ -246,7 +246,7 @@ out:
 }
 
 /**
- *  e1000_read_phy_reg_igp - Read igp PHY register
+ *  igb_read_phy_reg_igp - Read igp PHY register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to be read
  *  @data: pointer to the read data
@@ -284,7 +284,7 @@ out:
 }
 
 /**
- *  e1000_write_phy_reg_igp - Write igp PHY register
+ *  igb_write_phy_reg_igp - Write igp PHY register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to write to
  *  @data: data to write at register offset
@@ -321,7 +321,7 @@ out:
 }
 
 /**
- *  e1000_copper_link_setup_m88 - Setup m88 PHY's for copper link
+ *  igb_copper_link_setup_m88 - Setup m88 PHY's for copper link
  *  @hw: pointer to the HW structure
  *
  *  Sets up MDI/MDI-X and polarity for m88 PHY's.  If necessary, transmit clock
@@ -423,7 +423,7 @@ s32 igb_copper_link_setup_m88(struct e1000_hw *hw)
 	/* Commit the changes. */
 	ret_val = igb_phy_sw_reset(hw);
 	if (ret_val) {
-		hw_dbg(hw, "Error committing the PHY changes\n");
+		hw_dbg("Error committing the PHY changes\n");
 		goto out;
 	}
 
@@ -432,7 +432,7 @@ out:
 }
 
 /**
- *  e1000_copper_link_setup_igp - Setup igp PHY's for copper link
+ *  igb_copper_link_setup_igp - Setup igp PHY's for copper link
  *  @hw: pointer to the HW structure
  *
  *  Sets up LPLU, MDI/MDI-X, polarity, Smartspeed and Master/Slave config for
@@ -451,7 +451,7 @@ s32 igb_copper_link_setup_igp(struct e1000_hw *hw)
 
 	ret_val = hw->phy.ops.reset_phy(hw);
 	if (ret_val) {
-		hw_dbg(hw, "Error resetting the PHY.\n");
+		hw_dbg("Error resetting the PHY.\n");
 		goto out;
 	}
 
@@ -467,7 +467,7 @@ s32 igb_copper_link_setup_igp(struct e1000_hw *hw)
 		if (hw->phy.ops.set_d3_lplu_state)
 			ret_val = hw->phy.ops.set_d3_lplu_state(hw, false);
 		if (ret_val) {
-			hw_dbg(hw, "Error Disabling LPLU D3\n");
+			hw_dbg("Error Disabling LPLU D3\n");
 			goto out;
 		}
 	}
@@ -475,7 +475,7 @@ s32 igb_copper_link_setup_igp(struct e1000_hw *hw)
 	/* disable lplu d0 during driver init */
 	ret_val = hw->phy.ops.set_d0_lplu_state(hw, false);
 	if (ret_val) {
-		hw_dbg(hw, "Error Disabling LPLU D0\n");
+		hw_dbg("Error Disabling LPLU D0\n");
 		goto out;
 	}
 	/* Configure mdi-mdix settings */
@@ -570,7 +570,7 @@ out:
 }
 
 /**
- *  e1000_copper_link_autoneg - Setup/Enable autoneg for copper link
+ *  igb_copper_link_autoneg - Setup/Enable autoneg for copper link
  *  @hw: pointer to the HW structure
  *
  *  Performs initial bounds checking on autoneg advertisement parameter, then
@@ -597,13 +597,13 @@ s32 igb_copper_link_autoneg(struct e1000_hw *hw)
 	if (phy->autoneg_advertised == 0)
 		phy->autoneg_advertised = phy->autoneg_mask;
 
-	hw_dbg(hw, "Reconfiguring auto-neg advertisement params\n");
+	hw_dbg("Reconfiguring auto-neg advertisement params\n");
 	ret_val = igb_phy_setup_autoneg(hw);
 	if (ret_val) {
-		hw_dbg(hw, "Error Setting up Auto-Negotiation\n");
+		hw_dbg("Error Setting up Auto-Negotiation\n");
 		goto out;
 	}
-	hw_dbg(hw, "Restarting Auto-Neg\n");
+	hw_dbg("Restarting Auto-Neg\n");
 
 	/*
 	 * Restart auto-negotiation by setting the Auto Neg Enable bit and
@@ -625,8 +625,8 @@ s32 igb_copper_link_autoneg(struct e1000_hw *hw)
 	if (phy->autoneg_wait_to_complete) {
 		ret_val = igb_wait_autoneg(hw);
 		if (ret_val) {
-			hw_dbg(hw, "Error while waiting for "
-				 "autoneg to complete\n");
+			hw_dbg("Error while waiting for "
+			       "autoneg to complete\n");
 			goto out;
 		}
 	}
@@ -638,7 +638,7 @@ out:
 }
 
 /**
- *  e1000_phy_setup_autoneg - Configure PHY for auto-negotiation
+ *  igb_phy_setup_autoneg - Configure PHY for auto-negotiation
  *  @hw: pointer to the HW structure
  *
  *  Reads the MII auto-neg advertisement register and/or the 1000T control
@@ -689,39 +689,39 @@ static s32 igb_phy_setup_autoneg(struct e1000_hw *hw)
 				 NWAY_AR_10T_HD_CAPS);
 	mii_1000t_ctrl_reg &= ~(CR_1000T_HD_CAPS | CR_1000T_FD_CAPS);
 
-	hw_dbg(hw, "autoneg_advertised %x\n", phy->autoneg_advertised);
+	hw_dbg("autoneg_advertised %x\n", phy->autoneg_advertised);
 
 	/* Do we want to advertise 10 Mb Half Duplex? */
 	if (phy->autoneg_advertised & ADVERTISE_10_HALF) {
-		hw_dbg(hw, "Advertise 10mb Half duplex\n");
+		hw_dbg("Advertise 10mb Half duplex\n");
 		mii_autoneg_adv_reg |= NWAY_AR_10T_HD_CAPS;
 	}
 
 	/* Do we want to advertise 10 Mb Full Duplex? */
 	if (phy->autoneg_advertised & ADVERTISE_10_FULL) {
-		hw_dbg(hw, "Advertise 10mb Full duplex\n");
+		hw_dbg("Advertise 10mb Full duplex\n");
 		mii_autoneg_adv_reg |= NWAY_AR_10T_FD_CAPS;
 	}
 
 	/* Do we want to advertise 100 Mb Half Duplex? */
 	if (phy->autoneg_advertised & ADVERTISE_100_HALF) {
-		hw_dbg(hw, "Advertise 100mb Half duplex\n");
+		hw_dbg("Advertise 100mb Half duplex\n");
 		mii_autoneg_adv_reg |= NWAY_AR_100TX_HD_CAPS;
 	}
 
 	/* Do we want to advertise 100 Mb Full Duplex? */
 	if (phy->autoneg_advertised & ADVERTISE_100_FULL) {
-		hw_dbg(hw, "Advertise 100mb Full duplex\n");
+		hw_dbg("Advertise 100mb Full duplex\n");
 		mii_autoneg_adv_reg |= NWAY_AR_100TX_FD_CAPS;
 	}
 
 	/* We do not allow the Phy to advertise 1000 Mb Half Duplex */
 	if (phy->autoneg_advertised & ADVERTISE_1000_HALF)
-		hw_dbg(hw, "Advertise 1000mb Half duplex request denied!\n");
+		hw_dbg("Advertise 1000mb Half duplex request denied!\n");
 
 	/* Do we want to advertise 1000 Mb Full Duplex? */
 	if (phy->autoneg_advertised & ADVERTISE_1000_FULL) {
-		hw_dbg(hw, "Advertise 1000mb Full duplex\n");
+		hw_dbg("Advertise 1000mb Full duplex\n");
 		mii_1000t_ctrl_reg |= CR_1000T_FD_CAPS;
 	}
 
@@ -780,7 +780,7 @@ static s32 igb_phy_setup_autoneg(struct e1000_hw *hw)
 		mii_autoneg_adv_reg |= (NWAY_AR_ASM_DIR | NWAY_AR_PAUSE);
 		break;
 	default:
-		hw_dbg(hw, "Flow control param set incorrectly\n");
+		hw_dbg("Flow control param set incorrectly\n");
 		ret_val = -E1000_ERR_CONFIG;
 		goto out;
 	}
@@ -790,7 +790,7 @@ static s32 igb_phy_setup_autoneg(struct e1000_hw *hw)
 	if (ret_val)
 		goto out;
 
-	hw_dbg(hw, "Auto-Neg Advertising %x\n", mii_autoneg_adv_reg);
+	hw_dbg("Auto-Neg Advertising %x\n", mii_autoneg_adv_reg);
 
 	if (phy->autoneg_mask & ADVERTISE_1000_FULL) {
 		ret_val = hw->phy.ops.write_phy_reg(hw,
@@ -805,7 +805,7 @@ out:
 }
 
 /**
- *  e1000_phy_force_speed_duplex_igp - Force speed/duplex for igp PHY
+ *  igb_phy_force_speed_duplex_igp - Force speed/duplex for igp PHY
  *  @hw: pointer to the HW structure
  *
  *  Calls the PHY setup function to force speed and duplex.  Clears the
@@ -846,13 +846,12 @@ s32 igb_phy_force_speed_duplex_igp(struct e1000_hw *hw)
 	if (ret_val)
 		goto out;
 
-	hw_dbg(hw, "IGP PSCR: %X\n", phy_data);
+	hw_dbg("IGP PSCR: %X\n", phy_data);
 
 	udelay(1);
 
 	if (phy->autoneg_wait_to_complete) {
-		hw_dbg(hw,
-		       "Waiting for forced speed/duplex link on IGP phy.\n");
+		hw_dbg("Waiting for forced speed/duplex link on IGP phy.\n");
 
 		ret_val = igb_phy_has_link(hw,
 						     PHY_FORCE_LIMIT,
@@ -862,7 +861,7 @@ s32 igb_phy_force_speed_duplex_igp(struct e1000_hw *hw)
 			goto out;
 
 		if (!link)
-			hw_dbg(hw, "Link taking longer than expected.\n");
+			hw_dbg("Link taking longer than expected.\n");
 
 		/* Try once more */
 		ret_val = igb_phy_has_link(hw,
@@ -878,7 +877,7 @@ out:
 }
 
 /**
- *  e1000_phy_force_speed_duplex_m88 - Force speed/duplex for m88 PHY
+ *  igb_phy_force_speed_duplex_m88 - Force speed/duplex for m88 PHY
  *  @hw: pointer to the HW structure
  *
  *  Calls the PHY setup function to force speed and duplex.  Clears the
@@ -909,7 +908,7 @@ s32 igb_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 	if (ret_val)
 		goto out;
 
-	hw_dbg(hw, "M88E1000 PSCR: %X\n", phy_data);
+	hw_dbg("M88E1000 PSCR: %X\n", phy_data);
 
 	ret_val = hw->phy.ops.read_phy_reg(hw, PHY_CONTROL, &phy_data);
 	if (ret_val)
@@ -927,8 +926,7 @@ s32 igb_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 	udelay(1);
 
 	if (phy->autoneg_wait_to_complete) {
-		hw_dbg(hw,
-		       "Waiting for forced speed/duplex link on M88 phy.\n");
+		hw_dbg("Waiting for forced speed/duplex link on M88 phy.\n");
 
 		ret_val = igb_phy_has_link(hw,
 						     PHY_FORCE_LIMIT,
@@ -993,7 +991,7 @@ out:
 }
 
 /**
- *  e1000_phy_force_speed_duplex_setup - Configure forced PHY speed/duplex
+ *  igb_phy_force_speed_duplex_setup - Configure forced PHY speed/duplex
  *  @hw: pointer to the HW structure
  *  @phy_ctrl: pointer to current value of PHY_CONTROL
  *
@@ -1028,11 +1026,11 @@ static void igb_phy_force_speed_duplex_setup(struct e1000_hw *hw,
 	if (mac->forced_speed_duplex & E1000_ALL_HALF_DUPLEX) {
 		ctrl &= ~E1000_CTRL_FD;
 		*phy_ctrl &= ~MII_CR_FULL_DUPLEX;
-		hw_dbg(hw, "Half Duplex\n");
+		hw_dbg("Half Duplex\n");
 	} else {
 		ctrl |= E1000_CTRL_FD;
 		*phy_ctrl |= MII_CR_FULL_DUPLEX;
-		hw_dbg(hw, "Full Duplex\n");
+		hw_dbg("Full Duplex\n");
 	}
 
 	/* Forcing 10mb or 100mb? */
@@ -1040,12 +1038,12 @@ static void igb_phy_force_speed_duplex_setup(struct e1000_hw *hw,
 		ctrl |= E1000_CTRL_SPD_100;
 		*phy_ctrl |= MII_CR_SPEED_100;
 		*phy_ctrl &= ~(MII_CR_SPEED_1000 | MII_CR_SPEED_10);
-		hw_dbg(hw, "Forcing 100mb\n");
+		hw_dbg("Forcing 100mb\n");
 	} else {
 		ctrl &= ~(E1000_CTRL_SPD_1000 | E1000_CTRL_SPD_100);
 		*phy_ctrl |= MII_CR_SPEED_10;
 		*phy_ctrl &= ~(MII_CR_SPEED_1000 | MII_CR_SPEED_100);
-		hw_dbg(hw, "Forcing 10mb\n");
+		hw_dbg("Forcing 10mb\n");
 	}
 
 	igb_config_collision_dist(hw);
@@ -1054,7 +1052,7 @@ static void igb_phy_force_speed_duplex_setup(struct e1000_hw *hw,
 }
 
 /**
- *  e1000_set_d3_lplu_state - Sets low power link up state for D3
+ *  igb_set_d3_lplu_state - Sets low power link up state for D3
  *  @hw: pointer to the HW structure
  *  @active: boolean used to enable/disable lplu
  *
@@ -1146,7 +1144,7 @@ out:
 }
 
 /**
- *  e1000_check_downshift - Checks whether a downshift in speed occured
+ *  igb_check_downshift - Checks whether a downshift in speed occured
  *  @hw: pointer to the HW structure
  *
  *  Success returns 0, Failure returns 1
@@ -1188,7 +1186,7 @@ out:
 }
 
 /**
- *  e1000_check_polarity_m88 - Checks the polarity.
+ *  igb_check_polarity_m88 - Checks the polarity.
  *  @hw: pointer to the HW structure
  *
  *  Success returns 0, Failure returns -E1000_ERR_PHY (-2)
@@ -1212,7 +1210,7 @@ static s32 igb_check_polarity_m88(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_check_polarity_igp - Checks the polarity.
+ *  igb_check_polarity_igp - Checks the polarity.
  *  @hw: pointer to the HW structure
  *
  *  Success returns 0, Failure returns -E1000_ERR_PHY (-2)
@@ -1260,7 +1258,7 @@ out:
 }
 
 /**
- *  e1000_wait_autoneg - Wait for auto-neg compeletion
+ *  igb_wait_autoneg - Wait for auto-neg compeletion
  *  @hw: pointer to the HW structure
  *
  *  Waits for auto-negotiation to complete or for the auto-negotiation time
@@ -1292,7 +1290,7 @@ static s32 igb_wait_autoneg(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_phy_has_link - Polls PHY for link
+ *  igb_phy_has_link - Polls PHY for link
  *  @hw: pointer to the HW structure
  *  @iterations: number of times to poll for link
  *  @usec_interval: delay between polling attempts
@@ -1332,7 +1330,7 @@ s32 igb_phy_has_link(struct e1000_hw *hw, u32 iterations,
 }
 
 /**
- *  e1000_get_cable_length_m88 - Determine cable length for m88 PHY
+ *  igb_get_cable_length_m88 - Determine cable length for m88 PHY
  *  @hw: pointer to the HW structure
  *
  *  Reads the PHY specific status register to retrieve the cable length
@@ -1369,7 +1367,7 @@ out:
 }
 
 /**
- *  e1000_get_cable_length_igp_2 - Determine cable length for igp2 PHY
+ *  igb_get_cable_length_igp_2 - Determine cable length for igp2 PHY
  *  @hw: pointer to the HW structure
  *
  *  The automatic gain control (agc) normalizes the amplitude of the
@@ -1442,7 +1440,7 @@ out:
 }
 
 /**
- *  e1000_get_phy_info_m88 - Retrieve PHY information
+ *  igb_get_phy_info_m88 - Retrieve PHY information
  *  @hw: pointer to the HW structure
  *
  *  Valid for only copper links.  Read the PHY status register (sticky read)
@@ -1459,7 +1457,7 @@ s32 igb_get_phy_info_m88(struct e1000_hw *hw)
 	bool link;
 
 	if (hw->phy.media_type != e1000_media_type_copper) {
-		hw_dbg(hw, "Phy info is only valid for copper media\n");
+		hw_dbg("Phy info is only valid for copper media\n");
 		ret_val = -E1000_ERR_CONFIG;
 		goto out;
 	}
@@ -1469,7 +1467,7 @@ s32 igb_get_phy_info_m88(struct e1000_hw *hw)
 		goto out;
 
 	if (!link) {
-		hw_dbg(hw, "Phy info is only valid if link is up\n");
+		hw_dbg("Phy info is only valid if link is up\n");
 		ret_val = -E1000_ERR_CONFIG;
 		goto out;
 	}
@@ -1523,7 +1521,7 @@ out:
 }
 
 /**
- *  e1000_get_phy_info_igp - Retrieve igp PHY information
+ *  igb_get_phy_info_igp - Retrieve igp PHY information
  *  @hw: pointer to the HW structure
  *
  *  Read PHY status to determine if link is up.  If link is up, then
@@ -1543,7 +1541,7 @@ s32 igb_get_phy_info_igp(struct e1000_hw *hw)
 		goto out;
 
 	if (!link) {
-		hw_dbg(hw, "Phy info is only valid if link is up\n");
+		hw_dbg("Phy info is only valid if link is up\n");
 		ret_val = -E1000_ERR_CONFIG;
 		goto out;
 	}
@@ -1590,7 +1588,7 @@ out:
 }
 
 /**
- *  e1000_phy_sw_reset - PHY software reset
+ *  igb_phy_sw_reset - PHY software reset
  *  @hw: pointer to the HW structure
  *
  *  Does a software reset of the PHY by reading the PHY control register and
@@ -1617,7 +1615,7 @@ out:
 }
 
 /**
- *  e1000_phy_hw_reset - PHY hardware reset
+ *  igb_phy_hw_reset - PHY hardware reset
  *  @hw: pointer to the HW structure
  *
  *  Verify the reset block is not blocking us from resetting.  Acquire
@@ -1663,7 +1661,7 @@ out:
 /* Internal function pointers */
 
 /**
- *  e1000_get_phy_cfg_done - Generic PHY configuration done
+ *  igb_get_phy_cfg_done - Generic PHY configuration done
  *  @hw: pointer to the HW structure
  *
  *  Return success if silicon family did not implement a family specific
@@ -1678,7 +1676,7 @@ static s32 igb_get_phy_cfg_done(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_release_phy - Generic release PHY
+ *  igb_release_phy - Generic release PHY
  *  @hw: pointer to the HW structure
  *
  *  Return if silicon family does not require a semaphore when accessing the
@@ -1691,7 +1689,7 @@ static void igb_release_phy(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_acquire_phy - Generic acquire PHY
+ *  igb_acquire_phy - Generic acquire PHY
  *  @hw: pointer to the HW structure
  *
  *  Return success if silicon family does not require a semaphore when
@@ -1706,7 +1704,7 @@ static s32 igb_acquire_phy(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_phy_force_speed_duplex - Generic force PHY speed/duplex
+ *  igb_phy_force_speed_duplex - Generic force PHY speed/duplex
  *  @hw: pointer to the HW structure
  *
  *  When the silicon family has not implemented a forced speed/duplex
@@ -1721,14 +1719,14 @@ s32 igb_phy_force_speed_duplex(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_phy_init_script_igp3 - Inits the IGP3 PHY
+ *  igb_phy_init_script_igp3 - Inits the IGP3 PHY
  *  @hw: pointer to the HW structure
  *
  *  Initializes a Intel Gigabit PHY3 when an EEPROM is not present.
  **/
 s32 igb_phy_init_script_igp3(struct e1000_hw *hw)
 {
-	hw_dbg(hw, "Running IGP 3 PHY init script\n");
+	hw_dbg("Running IGP 3 PHY init script\n");
 
 	/* PHY init IGP 3 */
 	/* Enable rise/fall, 10-mode work in class-A */
diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 0eecb8b..2c48eec 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -150,6 +150,7 @@ struct igb_ring {
 	u16 itr_register;
 	u16 cpu;
 
+	int queue_index;
 	unsigned int total_bytes;
 	unsigned int total_packets;
 
@@ -265,6 +266,7 @@ struct igb_adapter {
 	int msg_enable;
 	struct msix_entry *msix_entries;
 	u32 eims_enable_mask;
+	u32 eims_other;
 
 	/* to not mess up cache alignment, always add to the bottom */
 	unsigned long state;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 171d1fc..7bc6fae 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -71,8 +71,8 @@ static int igb_setup_all_tx_resources(struct igb_adapter *);
 static int igb_setup_all_rx_resources(struct igb_adapter *);
 static void igb_free_all_tx_resources(struct igb_adapter *);
 static void igb_free_all_rx_resources(struct igb_adapter *);
-static void igb_free_tx_resources(struct igb_adapter *, struct igb_ring *);
-static void igb_free_rx_resources(struct igb_adapter *, struct igb_ring *);
+static void igb_free_tx_resources(struct igb_ring *);
+static void igb_free_rx_resources(struct igb_ring *);
 void igb_update_stats(struct igb_adapter *);
 static int igb_probe(struct pci_dev *, const struct pci_device_id *);
 static void __devexit igb_remove(struct pci_dev *pdev);
@@ -84,8 +84,8 @@ static void igb_configure_rx(struct igb_adapter *);
 static void igb_setup_rctl(struct igb_adapter *);
 static void igb_clean_all_tx_rings(struct igb_adapter *);
 static void igb_clean_all_rx_rings(struct igb_adapter *);
-static void igb_clean_tx_ring(struct igb_adapter *, struct igb_ring *);
-static void igb_clean_rx_ring(struct igb_adapter *, struct igb_ring *);
+static void igb_clean_tx_ring(struct igb_ring *);
+static void igb_clean_rx_ring(struct igb_ring *);
 static void igb_set_multi(struct net_device *);
 static void igb_update_phy_info(unsigned long);
 static void igb_watchdog(unsigned long);
@@ -102,12 +102,10 @@ static irqreturn_t igb_msix_other(int irq, void *);
 static irqreturn_t igb_msix_rx(int irq, void *);
 static irqreturn_t igb_msix_tx(int irq, void *);
 static int igb_clean_rx_ring_msix(struct napi_struct *, int);
-static bool igb_clean_tx_irq(struct igb_adapter *, struct igb_ring *);
+static bool igb_clean_tx_irq(struct igb_ring *);
 static int igb_clean(struct napi_struct *, int);
-static bool igb_clean_rx_irq_adv(struct igb_adapter *,
-				 struct igb_ring *, int *, int);
-static void igb_alloc_rx_buffers_adv(struct igb_adapter *,
-				     struct igb_ring *, int);
+static bool igb_clean_rx_irq_adv(struct igb_ring *, int *, int);
+static void igb_alloc_rx_buffers_adv(struct igb_ring *, int);
 static int igb_ioctl(struct net_device *, struct ifreq *, int cmd);
 static void igb_tx_timeout(struct net_device *);
 static void igb_reset_task(struct work_struct *);
@@ -229,12 +227,11 @@ static int igb_alloc_queues(struct igb_adapter *adapter)
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		struct igb_ring *ring = &(adapter->rx_ring[i]);
 		ring->adapter = adapter;
+		ring->queue_index = i;
 		ring->itr_register = E1000_ITR;
 
-		if (!ring->napi.poll)
-			netif_napi_add(adapter->netdev, &ring->napi, igb_clean,
-				       adapter->napi.weight /
-				       adapter->num_rx_queues);
+		/* set a default napi handler for each rx_ring */
+		netif_napi_add(adapter->netdev, &ring->napi, igb_clean, 64);
 	}
 	return 0;
 }
@@ -302,9 +299,6 @@ static void igb_configure_msix(struct igb_adapter *adapter)
 		array_wr32(E1000_MSIXBM(0), vector++,
 				      E1000_EIMS_OTHER);
 
-		/* disable IAM for ICR interrupt bits */
-		wr32(E1000_IAM, 0);
-
 		tmp = rd32(E1000_CTRL_EXT);
 		/* enable MSI-X PBA support*/
 		tmp |= E1000_CTRL_EXT_PBA_CLR;
@@ -315,6 +309,7 @@ static void igb_configure_msix(struct igb_adapter *adapter)
 
 		wr32(E1000_CTRL_EXT, tmp);
 		adapter->eims_enable_mask |= E1000_EIMS_OTHER;
+		adapter->eims_other = E1000_EIMS_OTHER;
 
 	wrfl();
 }
@@ -357,6 +352,9 @@ static int igb_request_msix(struct igb_adapter *adapter)
 			goto out;
 		ring->itr_register = E1000_EITR(0) + (vector << 2);
 		ring->itr_val = adapter->itr;
+		/* overwrite the poll routine for MSIX, we've already done
+		 * netif_napi_add */
+		ring->napi.poll = &igb_clean_rx_ring_msix;
 		vector++;
 	}
 
@@ -365,9 +363,6 @@ static int igb_request_msix(struct igb_adapter *adapter)
 	if (err)
 		goto out;
 
-	adapter->napi.poll = igb_clean_rx_ring_msix;
-	for (i = 0; i < adapter->num_rx_queues; i++)
-		adapter->rx_ring[i].napi.poll = adapter->napi.poll;
 	igb_configure_msix(adapter);
 	return 0;
 out:
@@ -436,12 +431,8 @@ static int igb_request_irq(struct igb_adapter *adapter)
 
 	if (adapter->msix_entries) {
 		err = igb_request_msix(adapter);
-		if (!err) {
-			/* enable IAM, auto-mask,
-			 * DO NOT USE EIAM or IAM in legacy mode */
-			wr32(E1000_IAM, IMS_ENABLE_MASK);
+		if (!err)
 			goto request_done;
-		}
 		/* fall back to MSI */
 		igb_reset_interrupt_capability(adapter);
 		if (!pci_enable_msi(adapter->pdev))
@@ -450,7 +441,11 @@ static int igb_request_irq(struct igb_adapter *adapter)
 		igb_free_all_rx_resources(adapter);
 		adapter->num_rx_queues = 1;
 		igb_alloc_queues(adapter);
+	} else {
+		wr32(E1000_MSIXBM(0), (E1000_EICR_RX_QUEUE0 |
+		                       E1000_EIMS_OTHER));
 	}
+
 	if (adapter->msi_enabled) {
 		err = request_irq(adapter->pdev->irq, &igb_intr_msi, 0,
 				  netdev->name, netdev);
@@ -502,9 +497,12 @@ static void igb_irq_disable(struct igb_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 
 	if (adapter->msix_entries) {
+		wr32(E1000_EIAM, 0);
 		wr32(E1000_EIMC, ~0);
 		wr32(E1000_EIAC, 0);
 	}
+
+	wr32(E1000_IAM, 0);
 	wr32(E1000_IMC, ~0);
 	wrfl();
 	synchronize_irq(adapter->pdev->irq);
@@ -519,13 +517,14 @@ static void igb_irq_enable(struct igb_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 
 	if (adapter->msix_entries) {
-		wr32(E1000_EIMS,
-				adapter->eims_enable_mask);
-		wr32(E1000_EIAC,
-				adapter->eims_enable_mask);
+		wr32(E1000_EIAC, adapter->eims_enable_mask);
+		wr32(E1000_EIAM, adapter->eims_enable_mask);
+		wr32(E1000_EIMS, adapter->eims_enable_mask);
 		wr32(E1000_IMS, E1000_IMS_LSC);
-	} else
-	wr32(E1000_IMS, IMS_ENABLE_MASK);
+	} else {
+		wr32(E1000_IMS, IMS_ENABLE_MASK);
+		wr32(E1000_IAM, IMS_ENABLE_MASK);
+	}
 }
 
 static void igb_update_mng_vlan(struct igb_adapter *adapter)
@@ -632,12 +631,15 @@ static void igb_configure(struct igb_adapter *adapter)
 	igb_configure_tx(adapter);
 	igb_setup_rctl(adapter);
 	igb_configure_rx(adapter);
+
+	igb_rx_fifo_flush_82575(&adapter->hw);
+
 	/* call IGB_DESC_UNUSED which always leaves
 	 * at least 1 descriptor unused to make sure
 	 * next_to_use != next_to_clean */
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		struct igb_ring *ring = &adapter->rx_ring[i];
-		igb_alloc_rx_buffers_adv(adapter, ring, IGB_DESC_UNUSED(ring));
+		igb_alloc_rx_buffers_adv(ring, IGB_DESC_UNUSED(ring));
 	}
 
 
@@ -660,13 +662,10 @@ int igb_up(struct igb_adapter *adapter)
 
 	clear_bit(__IGB_DOWN, &adapter->state);
 
-	napi_enable(&adapter->napi);
-
-	if (adapter->msix_entries) {
-		for (i = 0; i < adapter->num_rx_queues; i++)
-			napi_enable(&adapter->rx_ring[i].napi);
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		napi_enable(&adapter->rx_ring[i].napi);
+	if (adapter->msix_entries)
 		igb_configure_msix(adapter);
-	}
 
 	/* Clear any pending interrupts. */
 	rd32(E1000_ICR);
@@ -703,11 +702,9 @@ void igb_down(struct igb_adapter *adapter)
 	wrfl();
 	msleep(10);
 
-	napi_disable(&adapter->napi);
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		napi_disable(&adapter->rx_ring[i].napi);
 
-	if (adapter->msix_entries)
-		for (i = 0; i < adapter->num_rx_queues; i++)
-			napi_disable(&adapter->rx_ring[i].napi);
 	igb_irq_disable(adapter);
 
 	del_timer_sync(&adapter->watchdog_timer);
@@ -854,7 +851,6 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	struct e1000_hw *hw;
 	const struct e1000_info *ei = igb_info_tbl[ent->driver_data];
 	unsigned long mmio_start, mmio_len;
-	static int cards_found;
 	int i, err, pci_using_dac;
 	u16 eeprom_data = 0;
 	u16 eeprom_apme_mask = IGB_EEPROM_APME;
@@ -933,7 +929,6 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	igb_set_ethtool_ops(netdev);
 	netdev->tx_timeout = &igb_tx_timeout;
 	netdev->watchdog_timeo = 5 * HZ;
-	netif_napi_add(netdev, &adapter->napi, igb_clean, 64);
 	netdev->vlan_rx_register = igb_vlan_rx_register;
 	netdev->vlan_rx_add_vid = igb_vlan_rx_add_vid;
 	netdev->vlan_rx_kill_vid = igb_vlan_rx_kill_vid;
@@ -947,8 +942,6 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	netdev->mem_start = mmio_start;
 	netdev->mem_end = mmio_start + mmio_len;
 
-	adapter->bd_number = cards_found;
-
 	/* PCI config space info */
 	hw->vendor_id = pdev->vendor;
 	hw->device_id = pdev->device;
@@ -1133,7 +1126,6 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 		adapter->msi_enabled ? "MSI" : "legacy",
 		adapter->num_rx_queues, adapter->num_tx_queues);
 
-	cards_found++;
 	return 0;
 
 err_register:
@@ -1301,15 +1293,14 @@ static int igb_open(struct net_device *netdev)
 	/* From here on the code is the same as igb_up() */
 	clear_bit(__IGB_DOWN, &adapter->state);
 
-	napi_enable(&adapter->napi);
-	if (adapter->msix_entries)
-		for (i = 0; i < adapter->num_rx_queues; i++)
-			napi_enable(&adapter->rx_ring[i].napi);
-
-	igb_irq_enable(adapter);
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		napi_enable(&adapter->rx_ring[i].napi);
 
 	/* Clear any pending interrupts. */
 	rd32(E1000_ICR);
+
+	igb_irq_enable(adapter);
+
 	/* Fire a link status change interrupt to start the watchdog. */
 	wr32(E1000_ICS, E1000_ICS_LSC);
 
@@ -1423,8 +1414,7 @@ static int igb_setup_all_tx_resources(struct igb_adapter *adapter)
 			dev_err(&adapter->pdev->dev,
 				"Allocation for Tx Queue %u failed\n", i);
 			for (i--; i >= 0; i--)
-				igb_free_tx_resources(adapter,
-							&adapter->tx_ring[i]);
+				igb_free_tx_resources(&adapter->tx_ring[i]);
 			break;
 		}
 	}
@@ -1538,8 +1528,6 @@ int igb_setup_rx_resources(struct igb_adapter *adapter,
 	rx_ring->pending_skb = NULL;
 
 	rx_ring->adapter = adapter;
-	/* FIXME: do we want to setup ring->napi->poll here? */
-	rx_ring->napi.poll = adapter->napi.poll;
 
 	return 0;
 
@@ -1567,8 +1555,7 @@ static int igb_setup_all_rx_resources(struct igb_adapter *adapter)
 			dev_err(&adapter->pdev->dev,
 				"Allocation for Rx Queue %u failed\n", i);
 			for (i--; i >= 0; i--)
-				igb_free_rx_resources(adapter,
-							&adapter->rx_ring[i]);
+				igb_free_rx_resources(&adapter->rx_ring[i]);
 			break;
 		}
 	}
@@ -1796,12 +1783,11 @@ static void igb_configure_rx(struct igb_adapter *adapter)
  *
  * Free all transmit software resources
  **/
-static void igb_free_tx_resources(struct igb_adapter *adapter,
-				  struct igb_ring *tx_ring)
+static void igb_free_tx_resources(struct igb_ring *tx_ring)
 {
-	struct pci_dev *pdev = adapter->pdev;
+	struct pci_dev *pdev = tx_ring->adapter->pdev;
 
-	igb_clean_tx_ring(adapter, tx_ring);
+	igb_clean_tx_ring(tx_ring);
 
 	vfree(tx_ring->buffer_info);
 	tx_ring->buffer_info = NULL;
@@ -1822,7 +1808,7 @@ static void igb_free_all_tx_resources(struct igb_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_tx_queues; i++)
-		igb_free_tx_resources(adapter, &adapter->tx_ring[i]);
+		igb_free_tx_resources(&adapter->tx_ring[i]);
 }
 
 static void igb_unmap_and_free_tx_resource(struct igb_adapter *adapter,
@@ -1848,9 +1834,9 @@ static void igb_unmap_and_free_tx_resource(struct igb_adapter *adapter,
  * @adapter: board private structure
  * @tx_ring: ring to be cleaned
  **/
-static void igb_clean_tx_ring(struct igb_adapter *adapter,
-			      struct igb_ring *tx_ring)
+static void igb_clean_tx_ring(struct igb_ring *tx_ring)
 {
+	struct igb_adapter *adapter = tx_ring->adapter;
 	struct igb_buffer *buffer_info;
 	unsigned long size;
 	unsigned int i;
@@ -1887,7 +1873,7 @@ static void igb_clean_all_tx_rings(struct igb_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_tx_queues; i++)
-		igb_clean_tx_ring(adapter, &adapter->tx_ring[i]);
+		igb_clean_tx_ring(&adapter->tx_ring[i]);
 }
 
 /**
@@ -1897,12 +1883,11 @@ static void igb_clean_all_tx_rings(struct igb_adapter *adapter)
  *
  * Free all receive software resources
  **/
-static void igb_free_rx_resources(struct igb_adapter *adapter,
-				  struct igb_ring *rx_ring)
+static void igb_free_rx_resources(struct igb_ring *rx_ring)
 {
-	struct pci_dev *pdev = adapter->pdev;
+	struct pci_dev *pdev = rx_ring->adapter->pdev;
 
-	igb_clean_rx_ring(adapter, rx_ring);
+	igb_clean_rx_ring(rx_ring);
 
 	vfree(rx_ring->buffer_info);
 	rx_ring->buffer_info = NULL;
@@ -1923,7 +1908,7 @@ static void igb_free_all_rx_resources(struct igb_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_rx_queues; i++)
-		igb_free_rx_resources(adapter, &adapter->rx_ring[i]);
+		igb_free_rx_resources(&adapter->rx_ring[i]);
 }
 
 /**
@@ -1931,9 +1916,9 @@ static void igb_free_all_rx_resources(struct igb_adapter *adapter)
  * @adapter: board private structure
  * @rx_ring: ring to free buffers from
  **/
-static void igb_clean_rx_ring(struct igb_adapter *adapter,
-			      struct igb_ring *rx_ring)
+static void igb_clean_rx_ring(struct igb_ring *rx_ring)
 {
+	struct igb_adapter *adapter = rx_ring->adapter;
 	struct igb_buffer *buffer_info;
 	struct pci_dev *pdev = adapter->pdev;
 	unsigned long size;
@@ -1997,7 +1982,7 @@ static void igb_clean_all_rx_rings(struct igb_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_rx_queues; i++)
-		igb_clean_rx_ring(adapter, &adapter->rx_ring[i]);
+		igb_clean_rx_ring(&adapter->rx_ring[i]);
 }
 
 /**
@@ -3041,26 +3026,19 @@ static irqreturn_t igb_msix_other(int irq, void *data)
 	struct net_device *netdev = data;
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	u32 eicr;
-	/* disable interrupts from the "other" bit, avoid re-entry */
-	wr32(E1000_EIMC, E1000_EIMS_OTHER);
-
-	eicr = rd32(E1000_EICR);
+	u32 icr = rd32(E1000_ICR);
 
-	if (eicr & E1000_EIMS_OTHER) {
-		u32 icr = rd32(E1000_ICR);
-		/* reading ICR causes bit 31 of EICR to be cleared */
-		if (!(icr & E1000_ICR_LSC))
-			goto no_link_interrupt;
-		hw->mac.get_link_status = 1;
-		/* guard against interrupt when we're going down */
-		if (!test_bit(__IGB_DOWN, &adapter->state))
-			mod_timer(&adapter->watchdog_timer, jiffies + 1);
-	}
+	/* reading ICR causes bit 31 of EICR to be cleared */
+	if (!(icr & E1000_ICR_LSC))
+		goto no_link_interrupt;
+	hw->mac.get_link_status = 1;
+	/* guard against interrupt when we're going down */
+	if (!test_bit(__IGB_DOWN, &adapter->state))
+		mod_timer(&adapter->watchdog_timer, jiffies + 1);
 
 no_link_interrupt:
 	wr32(E1000_IMS, E1000_IMS_LSC);
-	wr32(E1000_EIMS, E1000_EIMS_OTHER);
+	wr32(E1000_EIMS, adapter->eims_other);
 
 	return IRQ_HANDLED;
 }
@@ -3076,7 +3054,7 @@ static irqreturn_t igb_msix_tx(int irq, void *data)
 
 	tx_ring->total_bytes = 0;
 	tx_ring->total_packets = 0;
-	if (!igb_clean_tx_irq(adapter, tx_ring))
+	if (!igb_clean_tx_irq(tx_ring))
 		/* Ring was not completely cleaned, so fire another interrupt */
 		wr32(E1000_EICS, tx_ring->eims_value);
 
@@ -3091,21 +3069,19 @@ static irqreturn_t igb_msix_rx(int irq, void *data)
 	struct igb_adapter *adapter = rx_ring->adapter;
 	struct e1000_hw *hw = &adapter->hw;
 
-	if (!rx_ring->itr_val)
-		wr32(E1000_EIMC, rx_ring->eims_value);
+	/* Write the ITR value calculated at the end of the
+	 * previous interrupt.
+	 */
 
-	if (netif_rx_schedule_prep(adapter->netdev, &rx_ring->napi)) {
-		rx_ring->total_bytes = 0;
-		rx_ring->total_packets = 0;
-		rx_ring->no_itr_adjust = 0;
-		__netif_rx_schedule(adapter->netdev, &rx_ring->napi);
-	} else {
-		if (!rx_ring->no_itr_adjust) {
-			igb_lower_rx_eitr(adapter, rx_ring);
-			rx_ring->no_itr_adjust = 1;
-		}
+	if (adapter->set_itr) {
+		wr32(rx_ring->itr_register,
+		     1000000000 / (rx_ring->itr_val * 256));
+		adapter->set_itr = 0;
 	}
 
+	if (netif_rx_schedule_prep(adapter->netdev, &rx_ring->napi))
+		__netif_rx_schedule(adapter->netdev, &rx_ring->napi);
+
 	return IRQ_HANDLED;
 }
 
@@ -3119,7 +3095,6 @@ static irqreturn_t igb_intr_msi(int irq, void *data)
 {
 	struct net_device *netdev = data;
 	struct igb_adapter *adapter = netdev_priv(netdev);
-	struct napi_struct *napi = &adapter->napi;
 	struct e1000_hw *hw = &adapter->hw;
 	/* read ICR disables interrupts using IAM */
 	u32 icr = rd32(E1000_ICR);
@@ -3128,25 +3103,17 @@ static irqreturn_t igb_intr_msi(int irq, void *data)
 	 * previous interrupt.
 	 */
 	if (adapter->set_itr) {
-		wr32(E1000_ITR,
-			1000000000 / (adapter->itr * 256));
+		wr32(E1000_ITR, 1000000000 / (adapter->itr * 256));
 		adapter->set_itr = 0;
 	}
 
-	/* read ICR disables interrupts using IAM */
 	if (icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {
 		hw->mac.get_link_status = 1;
 		if (!test_bit(__IGB_DOWN, &adapter->state))
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
 
-	if (netif_rx_schedule_prep(netdev, napi)) {
-		adapter->tx_ring->total_bytes = 0;
-		adapter->tx_ring->total_packets = 0;
-		adapter->rx_ring->total_bytes = 0;
-		adapter->rx_ring->total_packets = 0;
-		__netif_rx_schedule(netdev, napi);
-	}
+	netif_rx_schedule(netdev, &adapter->rx_ring[0].napi);
 
 	return IRQ_HANDLED;
 }
@@ -3160,7 +3127,6 @@ static irqreturn_t igb_intr(int irq, void *data)
 {
 	struct net_device *netdev = data;
 	struct igb_adapter *adapter = netdev_priv(netdev);
-	struct napi_struct *napi = &adapter->napi;
 	struct e1000_hw *hw = &adapter->hw;
 	/* Interrupt Auto-Mask...upon reading ICR, interrupts are masked.  No
 	 * need for the IMC write */
@@ -3173,8 +3139,7 @@ static irqreturn_t igb_intr(int irq, void *data)
 	 * previous interrupt.
 	 */
 	if (adapter->set_itr) {
-		wr32(E1000_ITR,
-			1000000000 / (adapter->itr * 256));
+		wr32(E1000_ITR, 1000000000 / (adapter->itr * 256));
 		adapter->set_itr = 0;
 	}
 
@@ -3192,13 +3157,7 @@ static irqreturn_t igb_intr(int irq, void *data)
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
 
-	if (netif_rx_schedule_prep(netdev, napi)) {
-		adapter->tx_ring->total_bytes = 0;
-		adapter->rx_ring->total_bytes = 0;
-		adapter->tx_ring->total_packets = 0;
-		adapter->rx_ring->total_packets = 0;
-		__netif_rx_schedule(netdev, napi);
-	}
+	netif_rx_schedule(netdev, &adapter->rx_ring[0].napi);
 
 	return IRQ_HANDLED;
 }
@@ -3227,14 +3186,13 @@ static int igb_clean(struct napi_struct *napi, int budget)
 	 * the lock means tx_ring[i] is currently being cleaned anyway. */
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		if (spin_trylock(&adapter->tx_ring[i].tx_clean_lock)) {
-			tx_clean_complete &= igb_clean_tx_irq(adapter,
-							&adapter->tx_ring[i]);
+			tx_clean_complete &= igb_clean_tx_irq(&adapter->tx_ring[i]);
 			spin_unlock(&adapter->tx_ring[i].tx_clean_lock);
 		}
 	}
 
 	for (i = 0; i < adapter->num_rx_queues; i++)
-		igb_clean_rx_irq_adv(adapter, &adapter->rx_ring[i], &work_done,
+		igb_clean_rx_irq_adv(&adapter->rx_ring[i], &work_done,
 				     adapter->rx_ring[i].napi.weight);
 
 	/* If no Tx and not enough Rx work done, exit the polling mode */
@@ -3264,7 +3222,7 @@ static int igb_clean_rx_ring_msix(struct napi_struct *napi, int budget)
 	if (!netif_carrier_ok(netdev))
 		goto quit_polling;
 
-	igb_clean_rx_irq_adv(adapter, rx_ring, &work_done, budget);
+	igb_clean_rx_irq_adv(rx_ring, &work_done, budget);
 
 
 	/* If not enough Rx work done, exit the polling mode */
@@ -3282,6 +3240,10 @@ quit_polling:
 			else if (mean_size > IGB_DYN_ITR_LENGTH_HIGH)
 				igb_lower_rx_eitr(adapter, rx_ring);
 		}
+
+		if (!test_bit(__IGB_DOWN, &adapter->state))
+			wr32(E1000_EIMS, rx_ring->eims_value);
+
 		return 0;
 	}
 
@@ -3299,11 +3261,11 @@ static inline u32 get_head(struct igb_ring *tx_ring)
  * @adapter: board private structure
  * returns true if ring is completely cleaned
  **/
-static bool igb_clean_tx_irq(struct igb_adapter *adapter,
-				  struct igb_ring *tx_ring)
+static bool igb_clean_tx_irq(struct igb_ring *tx_ring)
 {
-	struct net_device *netdev = adapter->netdev;
+	struct igb_adapter *adapter = tx_ring->adapter;
 	struct e1000_hw *hw = &adapter->hw;
+	struct net_device *netdev = adapter->netdev;
 	struct e1000_tx_desc *tx_desc;
 	struct igb_buffer *buffer_info;
 	struct sk_buff *skb;
@@ -3458,10 +3420,10 @@ static inline void igb_rx_checksum_adv(struct igb_adapter *adapter,
 	adapter->hw_csum_good++;
 }
 
-static bool igb_clean_rx_irq_adv(struct igb_adapter *adapter,
-				      struct igb_ring *rx_ring,
-				      int *work_done, int budget)
+static bool igb_clean_rx_irq_adv(struct igb_ring *rx_ring,
+				 int *work_done, int budget)
 {
+	struct igb_adapter *adapter = rx_ring->adapter;
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 	union e1000_adv_rx_desc *rx_desc , *next_rxd;
@@ -3584,8 +3546,7 @@ next_desc:
 
 		/* return some buffers to hardware, one at a time is too slow */
 		if (cleaned_count >= IGB_RX_BUFFER_WRITE) {
-			igb_alloc_rx_buffers_adv(adapter, rx_ring,
-						 cleaned_count);
+			igb_alloc_rx_buffers_adv(rx_ring, cleaned_count);
 			cleaned_count = 0;
 		}
 
@@ -3600,7 +3561,7 @@ out:
 	cleaned_count = IGB_DESC_UNUSED(rx_ring);
 
 	if (cleaned_count)
-		igb_alloc_rx_buffers_adv(adapter, rx_ring, cleaned_count);
+		igb_alloc_rx_buffers_adv(rx_ring, cleaned_count);
 
 	rx_ring->total_packets += total_packets;
 	rx_ring->total_bytes += total_bytes;
@@ -3616,10 +3577,10 @@ out:
  * igb_alloc_rx_buffers_adv - Replace used receive buffers; packet split
  * @adapter: address of board private structure
  **/
-static void igb_alloc_rx_buffers_adv(struct igb_adapter *adapter,
-				     struct igb_ring *rx_ring,
+static void igb_alloc_rx_buffers_adv(struct igb_ring *rx_ring,
 				     int cleaned_count)
 {
+	struct igb_adapter *adapter = rx_ring->adapter;
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 	union e1000_adv_rx_desc *rx_desc;
@@ -4062,10 +4023,10 @@ static void igb_netpoll(struct net_device *netdev)
 
 	igb_irq_disable(adapter);
 	for (i = 0; i < adapter->num_tx_queues; i++)
-		igb_clean_tx_irq(adapter, &adapter->tx_ring[i]);
+		igb_clean_tx_irq(&adapter->tx_ring[i]);
 
 	for (i = 0; i < adapter->num_rx_queues; i++)
-		igb_clean_rx_irq_adv(adapter, &adapter->rx_ring[i],
+		igb_clean_rx_irq_adv(&adapter->rx_ring[i],
 				     &work_done,
 				     adapter->rx_ring[i].napi.weight);
 
diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index 2c03f4e..7373daf 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -42,7 +42,6 @@
 #define ipg_r16(reg)		ioread16(ioaddr + (reg))
 #define ipg_r8(reg)		ioread8(ioaddr + (reg))
 
-#define JUMBO_FRAME_4k_ONLY
 enum {
 	netdev_io_size = 128
 };
@@ -55,6 +54,14 @@ MODULE_DESCRIPTION("IC Plus IP1000 Gigabit Ethernet Adapter Linux Driver");
 MODULE_LICENSE("GPL");
 
 /*
+ * Defaults
+ */
+#define IPG_MAX_RXFRAME_SIZE	0x0600
+#define IPG_RXFRAG_SIZE		0x0600
+#define IPG_RXSUPPORT_SIZE	0x0600
+#define IPG_IS_JUMBO		false
+
+/*
  * Variable record -- index by leading revision/length
  * Revision/Length(=N*4), Address1, Data1, Address2, Data2,...,AddressN,DataN
  */
@@ -631,6 +638,7 @@ static void ipg_nic_set_multicast_list(struct net_device *dev)
 
 static int ipg_io_config(struct net_device *dev)
 {
+	struct ipg_nic_private *sp = netdev_priv(dev);
 	void __iomem *ioaddr = ipg_ioaddr(dev);
 	u32 origmacctrl;
 	u32 restoremacctrl;
@@ -670,7 +678,7 @@ static int ipg_io_config(struct net_device *dev)
 	/* Set RECEIVEMODE register. */
 	ipg_nic_set_multicast_list(dev);
 
-	ipg_w16(IPG_MAX_RXFRAME_SIZE, MAX_FRAME_SIZE);
+	ipg_w16(sp->max_rxframe_size, MAX_FRAME_SIZE);
 
 	ipg_w8(IPG_RXDMAPOLLPERIOD_VALUE,   RX_DMA_POLL_PERIOD);
 	ipg_w8(IPG_RXDMAURGENTTHRESH_VALUE, RX_DMA_URGENT_THRESH);
@@ -730,7 +738,7 @@ static int ipg_get_rxbuff(struct net_device *dev, int entry)
 
 	IPG_DEBUG_MSG("_get_rxbuff\n");
 
-	skb = netdev_alloc_skb(dev, IPG_RXSUPPORT_SIZE + NET_IP_ALIGN);
+	skb = netdev_alloc_skb(dev, sp->rxsupport_size + NET_IP_ALIGN);
 	if (!skb) {
 		sp->rx_buff[entry] = NULL;
 		return -ENOMEM;
@@ -751,7 +759,7 @@ static int ipg_get_rxbuff(struct net_device *dev, int entry)
 		sp->rx_buf_sz, PCI_DMA_FROMDEVICE));
 
 	/* Set the RFD fragment length. */
-	rxfragsize = IPG_RXFRAG_SIZE;
+	rxfragsize = sp->rxfrag_size;
 	rxfd->frag_info |= cpu_to_le64((rxfragsize << 48) & IPG_RFI_FRAGLEN);
 
 	return 0;
@@ -1076,8 +1084,6 @@ static int ipg_nic_rxrestore(struct net_device *dev)
 	return 0;
 }
 
-#ifdef JUMBO_FRAME
-
 /* use jumboindex and jumbosize to control jumbo frame status
  * initial status is jumboindex=-1 and jumbosize=0
  * 1. jumboindex = -1 and jumbosize=0 : previous jumbo frame has been done.
@@ -1097,7 +1103,7 @@ enum {
 	FRAME_WITH_START_WITH_END = 11
 };
 
-inline void ipg_nic_rx_free_skb(struct net_device *dev)
+static void ipg_nic_rx_free_skb(struct net_device *dev)
 {
 	struct ipg_nic_private *sp = netdev_priv(dev);
 	unsigned int entry = sp->rx_current % IPG_RFDLIST_LENGTH;
@@ -1113,7 +1119,7 @@ inline void ipg_nic_rx_free_skb(struct net_device *dev)
 	}
 }
 
-inline int ipg_nic_rx_check_frame_type(struct net_device *dev)
+static int ipg_nic_rx_check_frame_type(struct net_device *dev)
 {
 	struct ipg_nic_private *sp = netdev_priv(dev);
 	struct ipg_rx *rxfd = sp->rxd + (sp->rx_current % IPG_RFDLIST_LENGTH);
@@ -1126,7 +1132,7 @@ inline int ipg_nic_rx_check_frame_type(struct net_device *dev)
 	return type;
 }
 
-inline int ipg_nic_rx_check_error(struct net_device *dev)
+static int ipg_nic_rx_check_error(struct net_device *dev)
 {
 	struct ipg_nic_private *sp = netdev_priv(dev);
 	unsigned int entry = sp->rx_current % IPG_RFDLIST_LENGTH;
@@ -1209,8 +1215,8 @@ static void ipg_nic_rx_with_start_and_end(struct net_device *dev,
 
 	/* accept this frame and send to upper layer */
 	framelen = le64_to_cpu(rxfd->rfs) & IPG_RFS_RXFRAMELEN;
-	if (framelen > IPG_RXFRAG_SIZE)
-		framelen = IPG_RXFRAG_SIZE;
+	if (framelen > sp->rxfrag_size)
+		framelen = sp->rxfrag_size;
 
 	skb_put(skb, framelen);
 	skb->protocol = eth_type_trans(skb, dev);
@@ -1243,10 +1249,10 @@ static void ipg_nic_rx_with_start(struct net_device *dev,
 	pci_unmap_single(pdev, le64_to_cpu(rxfd->frag_info & ~IPG_RFI_FRAGLEN),
 			 sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
 
-	skb_put(skb, IPG_RXFRAG_SIZE);
+	skb_put(skb, sp->rxfrag_size);
 
 	jumbo->found_start = 1;
-	jumbo->current_size = IPG_RXFRAG_SIZE;
+	jumbo->current_size = sp->rxfrag_size;
 	jumbo->skb = skb;
 
 	sp->rx_buff[entry] = NULL;
@@ -1272,11 +1278,7 @@ static void ipg_nic_rx_with_end(struct net_device *dev,
 			framelen = le64_to_cpu(rxfd->rfs) & IPG_RFS_RXFRAMELEN;
 
 			endframelen = framelen - jumbo->current_size;
-			/*
-			if (framelen > IPG_RXFRAG_SIZE)
-				framelen=IPG_RXFRAG_SIZE;
-			 */
-			if (framelen > IPG_RXSUPPORT_SIZE)
+			if (framelen > sp->rxsupport_size)
 				dev_kfree_skb_irq(jumbo->skb);
 			else {
 				memcpy(skb_put(jumbo->skb, endframelen),
@@ -1316,11 +1318,11 @@ static void ipg_nic_rx_no_start_no_end(struct net_device *dev,
 
 		if (skb) {
 			if (jumbo->found_start) {
-				jumbo->current_size += IPG_RXFRAG_SIZE;
-				if (jumbo->current_size <= IPG_RXSUPPORT_SIZE) {
+				jumbo->current_size += sp->rxfrag_size;
+				if (jumbo->current_size <= sp->rxsupport_size) {
 					memcpy(skb_put(jumbo->skb,
-						       IPG_RXFRAG_SIZE),
-					       skb->data, IPG_RXFRAG_SIZE);
+						       sp->rxfrag_size),
+					       skb->data, sp->rxfrag_size);
 				}
 			}
 			dev->last_rx = jiffies;
@@ -1334,7 +1336,7 @@ static void ipg_nic_rx_no_start_no_end(struct net_device *dev,
 	}
 }
 
-static int ipg_nic_rx(struct net_device *dev)
+static int ipg_nic_rx_jumbo(struct net_device *dev)
 {
 	struct ipg_nic_private *sp = netdev_priv(dev);
 	unsigned int curr = sp->rx_current;
@@ -1382,7 +1384,6 @@ static int ipg_nic_rx(struct net_device *dev)
 	return 0;
 }
 
-#else
 static int ipg_nic_rx(struct net_device *dev)
 {
 	/* Transfer received Ethernet frames to higher network layers. */
@@ -1413,11 +1414,11 @@ static int ipg_nic_rx(struct net_device *dev)
 		/* Check for jumbo frame arrival with too small
 		 * RXFRAG_SIZE.
 		 */
-		if (framelen > IPG_RXFRAG_SIZE) {
+		if (framelen > sp->rxfrag_size) {
 			IPG_DEBUG_MSG
 			    ("RFS FrameLen > allocated fragment size.\n");
 
-			framelen = IPG_RXFRAG_SIZE;
+			framelen = sp->rxfrag_size;
 		}
 
 		if ((IPG_DROP_ON_RX_ETH_ERRORS && (le64_to_cpu(rxfd->rfs) &
@@ -1556,7 +1557,6 @@ static int ipg_nic_rx(struct net_device *dev)
 
 	return 0;
 }
-#endif
 
 static void ipg_reset_after_host_error(struct work_struct *work)
 {
@@ -1592,9 +1592,9 @@ static irqreturn_t ipg_interrupt_handler(int irq, void *dev_inst)
 
 	IPG_DEBUG_MSG("_interrupt_handler\n");
 
-#ifdef JUMBO_FRAME
-	ipg_nic_rxrestore(dev);
-#endif
+	if (sp->is_jumbo)
+		ipg_nic_rxrestore(dev);
+
 	spin_lock(&sp->lock);
 
 	/* Get interrupt source information, and acknowledge
@@ -1650,7 +1650,10 @@ static irqreturn_t ipg_interrupt_handler(int irq, void *dev_inst)
 			sp->RFDListCheckedCount++;
 #endif
 
-		ipg_nic_rx(dev);
+		if (sp->is_jumbo)
+			ipg_nic_rx_jumbo(dev);
+		else
+			ipg_nic_rx(dev);
 	}
 
 	/* If TxDMAComplete interrupt, free used TFDs. */
@@ -1749,7 +1752,7 @@ static int ipg_nic_open(struct net_device *dev)
 
 	IPG_DEBUG_MSG("_nic_open\n");
 
-	sp->rx_buf_sz = IPG_RXSUPPORT_SIZE;
+	sp->rx_buf_sz = sp->rxsupport_size;
 
 	/* Check for interrupt line conflicts, and request interrupt
 	 * line for IPG.
@@ -1804,13 +1807,10 @@ static int ipg_nic_open(struct net_device *dev)
 	if (ipg_config_autoneg(dev) < 0)
 		printk(KERN_INFO "%s: Auto-negotiation error.\n", dev->name);
 
-#ifdef JUMBO_FRAME
 	/* initialize JUMBO Frame control variable */
 	sp->jumbo.found_start = 0;
 	sp->jumbo.current_size = 0;
 	sp->jumbo.skb = NULL;
-	dev->mtu = IPG_TXFRAG_SIZE;
-#endif
 
 	/* Enable transmit and receive operation of the IPG. */
 	ipg_w32((ipg_r32(MAC_CTRL) | IPG_MC_RX_ENABLE | IPG_MC_TX_ENABLE) &
@@ -2119,6 +2119,9 @@ static int ipg_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 static int ipg_nic_change_mtu(struct net_device *dev, int new_mtu)
 {
+	struct ipg_nic_private *sp = netdev_priv(dev);
+	int err;
+
 	/* Function to accomodate changes to Maximum Transfer Unit
 	 * (or MTU) of IPG NIC. Cannot use default function since
 	 * the default will not allow for MTU > 1500 bytes.
@@ -2126,16 +2129,33 @@ static int ipg_nic_change_mtu(struct net_device *dev, int new_mtu)
 
 	IPG_DEBUG_MSG("_nic_change_mtu\n");
 
-	/* Check that the new MTU value is between 68 (14 byte header, 46
-	 * byte payload, 4 byte FCS) and IPG_MAX_RXFRAME_SIZE, which
-	 * corresponds to the MAXFRAMESIZE register in the IPG.
+	/*
+	 * Check that the new MTU value is between 68 (14 byte header, 46 byte
+	 * payload, 4 byte FCS) and 10 KB, which is the largest supported MTU.
 	 */
-	if ((new_mtu < 68) || (new_mtu > IPG_MAX_RXFRAME_SIZE))
+	if (new_mtu < 68 || new_mtu > 10240)
 		return -EINVAL;
 
+	err = ipg_nic_stop(dev);
+	if (err)
+		return err;
+
 	dev->mtu = new_mtu;
 
-	return 0;
+	sp->max_rxframe_size = new_mtu;
+
+	sp->rxfrag_size = new_mtu;
+	if (sp->rxfrag_size > 4088)
+		sp->rxfrag_size = 4088;
+
+	sp->rxsupport_size = sp->max_rxframe_size;
+
+	if (new_mtu > 0x0600)
+		sp->is_jumbo = true;
+	else
+		sp->is_jumbo = false;
+
+	return ipg_nic_open(dev);
 }
 
 static int ipg_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
@@ -2240,6 +2260,11 @@ static int __devinit ipg_probe(struct pci_dev *pdev,
 	spin_lock_init(&sp->lock);
 	mutex_init(&sp->mii_mutex);
 
+	sp->is_jumbo = IPG_IS_JUMBO;
+	sp->rxfrag_size = IPG_RXFRAG_SIZE;
+	sp->rxsupport_size = IPG_RXSUPPORT_SIZE;
+	sp->max_rxframe_size = IPG_MAX_RXFRAME_SIZE;
+
 	/* Declare IPG NIC functions for Ethernet device methods.
 	 */
 	dev->open = &ipg_nic_open;
diff --git a/drivers/net/ipg.h b/drivers/net/ipg.h
index cda5388..e0e718a 100644
--- a/drivers/net/ipg.h
+++ b/drivers/net/ipg.h
@@ -536,83 +536,6 @@ enum ipg_regs {
  */
 #define		IPG_FRAMESBETWEENTXDMACOMPLETES 0x1
 
-#ifdef JUMBO_FRAME
-
-# ifdef JUMBO_FRAME_SIZE_2K
-# define JUMBO_FRAME_SIZE 2048
-# define __IPG_RXFRAG_SIZE 2048
-# else
-#  ifdef JUMBO_FRAME_SIZE_3K
-#  define JUMBO_FRAME_SIZE 3072
-#  define __IPG_RXFRAG_SIZE 3072
-#  else
-#   ifdef JUMBO_FRAME_SIZE_4K
-#   define JUMBO_FRAME_SIZE 4096
-#   define __IPG_RXFRAG_SIZE 4088
-#   else
-#    ifdef JUMBO_FRAME_SIZE_5K
-#    define JUMBO_FRAME_SIZE 5120
-#    define __IPG_RXFRAG_SIZE 4088
-#    else
-#     ifdef JUMBO_FRAME_SIZE_6K
-#     define JUMBO_FRAME_SIZE 6144
-#     define __IPG_RXFRAG_SIZE 4088
-#     else
-#      ifdef JUMBO_FRAME_SIZE_7K
-#      define JUMBO_FRAME_SIZE 7168
-#      define __IPG_RXFRAG_SIZE 4088
-#      else
-#       ifdef JUMBO_FRAME_SIZE_8K
-#       define JUMBO_FRAME_SIZE 8192
-#       define __IPG_RXFRAG_SIZE 4088
-#       else
-#        ifdef JUMBO_FRAME_SIZE_9K
-#        define JUMBO_FRAME_SIZE 9216
-#        define __IPG_RXFRAG_SIZE 4088
-#        else
-#         ifdef JUMBO_FRAME_SIZE_10K
-#         define JUMBO_FRAME_SIZE 10240
-#         define __IPG_RXFRAG_SIZE 4088
-#         else
-#         define JUMBO_FRAME_SIZE 4096
-#         endif
-#        endif
-#       endif
-#      endif
-#     endif
-#    endif
-#   endif
-#  endif
-# endif
-#endif
-
-/* Size of allocated received buffers. Nominally 0x0600.
- * Define larger if expecting jumbo frames.
- */
-#ifdef JUMBO_FRAME
-/* IPG_TXFRAG_SIZE must <= 0x2b00, or TX will crash */
-#define		IPG_TXFRAG_SIZE		JUMBO_FRAME_SIZE
-#endif
-
-/* Size of allocated received buffers. Nominally 0x0600.
- * Define larger if expecting jumbo frames.
- */
-#ifdef JUMBO_FRAME
-/* 4088 = 4096 - 8 */
-#define		IPG_RXFRAG_SIZE		__IPG_RXFRAG_SIZE
-#define     IPG_RXSUPPORT_SIZE   IPG_MAX_RXFRAME_SIZE
-#else
-#define		IPG_RXFRAG_SIZE		0x0600
-#define     IPG_RXSUPPORT_SIZE   IPG_RXFRAG_SIZE
-#endif
-
-/* IPG_MAX_RXFRAME_SIZE <= IPG_RXFRAG_SIZE */
-#ifdef JUMBO_FRAME
-#define		IPG_MAX_RXFRAME_SIZE		JUMBO_FRAME_SIZE
-#else
-#define		IPG_MAX_RXFRAME_SIZE		0x0600
-#endif
-
 #define		IPG_RFDLIST_LENGTH		0x100
 
 /* Maximum number of RFDs to process per interrupt.
@@ -786,9 +709,11 @@ struct ipg_nic_private {
 	unsigned int tx_dirty;
 	unsigned int rx_current;
 	unsigned int rx_dirty;
-#ifdef JUMBO_FRAME
+	bool is_jumbo;
 	struct ipg_jumbo jumbo;
-#endif
+	unsigned long rxfrag_size;
+	unsigned long rxsupport_size;
+	unsigned long max_rxframe_size;
 	unsigned int rx_buf_sz;
 	struct pci_dev *pdev;
 	struct net_device *dev;
diff --git a/drivers/net/ne.c b/drivers/net/ne.c
index 874d291..1412697 100644
--- a/drivers/net/ne.c
+++ b/drivers/net/ne.c
@@ -217,7 +217,7 @@ static int __init do_ne_probe(struct net_device *dev)
 #ifndef MODULE
 struct net_device * __init ne_probe(int unit)
 {
-	struct net_device *dev = alloc_ei_netdev();
+	struct net_device *dev = alloc_eip_netdev();
 	int err;
 
 	if (!dev)
@@ -490,7 +490,7 @@ static int __init ne_probe1(struct net_device *dev, unsigned long ioaddr)
 
 	/* Snarf the interrupt now.  There's no point in waiting since we cannot
 	   share and the board will usually be enabled. */
-	ret = request_irq(dev->irq, ei_interrupt, 0, name, dev);
+	ret = request_irq(dev->irq, eip_interrupt, 0, name, dev);
 	if (ret) {
 		printk (" unable to get IRQ %d (errno=%d).\n", dev->irq, ret);
 		goto err_out;
@@ -534,7 +534,7 @@ static int __init ne_probe1(struct net_device *dev, unsigned long ioaddr)
 	dev->open = &ne_open;
 	dev->stop = &ne_close;
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = ei_poll;
+	dev->poll_controller = eip_poll;
 #endif
 	NS8390_init(dev, 0);
 
@@ -554,7 +554,7 @@ err_out:
 
 static int ne_open(struct net_device *dev)
 {
-	ei_open(dev);
+	eip_open(dev);
 	return 0;
 }
 
@@ -562,7 +562,7 @@ static int ne_close(struct net_device *dev)
 {
 	if (ei_debug > 1)
 		printk(KERN_DEBUG "%s: Shutting down ethercard.\n", dev->name);
-	ei_close(dev);
+	eip_close(dev);
 	return 0;
 }
 
@@ -814,7 +814,7 @@ static int __init ne_drv_probe(struct platform_device *pdev)
 	if (!res || irq < 0)
 		return -ENODEV;
 
-	dev = alloc_ei_netdev();
+	dev = alloc_eip_netdev();
 	if (!dev)
 		return -ENOMEM;
 	dev->irq = irq;
@@ -912,7 +912,7 @@ int __init init_module(void)
 	int plat_found = !ne_init();
 
 	for (this_dev = 0; this_dev < MAX_NE_CARDS; this_dev++) {
-		struct net_device *dev = alloc_ei_netdev();
+		struct net_device *dev = alloc_eip_netdev();
 		if (!dev)
 			break;
 		dev->irq = irq[this_dev];
diff --git a/drivers/net/ne2.c b/drivers/net/ne2.c
index f4cd8c7..8f72563 100644
--- a/drivers/net/ne2.c
+++ b/drivers/net/ne2.c
@@ -280,7 +280,7 @@ static int __init do_ne2_probe(struct net_device *dev)
 #ifndef MODULE
 struct net_device * __init ne2_probe(int unit)
 {
-	struct net_device *dev = alloc_ei_netdev();
+	struct net_device *dev = alloc_eip_netdev();
 	int err;
 
 	if (!dev)
@@ -457,7 +457,7 @@ static int __init ne2_probe1(struct net_device *dev, int slot)
 
 	/* Snarf the interrupt now.  There's no point in waiting since we cannot
 	   share and the board will usually be enabled. */
-	retval = request_irq(dev->irq, ei_interrupt, 0, DRV_NAME, dev);
+	retval = request_irq(dev->irq, eip_interrupt, 0, DRV_NAME, dev);
 	if (retval) {
 		printk (" unable to get IRQ %d (irqval=%d).\n",
 				dev->irq, retval);
@@ -497,9 +497,9 @@ static int __init ne2_probe1(struct net_device *dev, int slot)
 	dev->open = &ne_open;
 	dev->stop = &ne_close;
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = ei_poll;
+	dev->poll_controller = eip_poll;
 #endif
-	NS8390_init(dev, 0);
+	NS8390p_init(dev, 0);
 
 	retval = register_netdev(dev);
 	if (retval)
@@ -515,7 +515,7 @@ out:
 
 static int ne_open(struct net_device *dev)
 {
-	ei_open(dev);
+	eip_open(dev);
 	return 0;
 }
 
@@ -523,7 +523,7 @@ static int ne_close(struct net_device *dev)
 {
 	if (ei_debug > 1)
 		printk("%s: Shutting down ethercard.\n", dev->name);
-	ei_close(dev);
+	eip_close(dev);
 	return 0;
 }
 
@@ -748,7 +748,7 @@ retry:
 		if (time_after(jiffies, dma_start + 2*HZ/100)) {		/* 20ms */
 			printk("%s: timeout waiting for Tx RDC.\n", dev->name);
 			ne_reset_8390(dev);
-			NS8390_init(dev,1);
+			NS8390p_init(dev, 1);
 			break;
 		}
 
@@ -781,7 +781,7 @@ int __init init_module(void)
 	int this_dev, found = 0;
 
 	for (this_dev = 0; this_dev < MAX_NE_CARDS; this_dev++) {
-		dev = alloc_ei_netdev();
+		dev = alloc_eip_netdev();
 		if (!dev)
 			break;
 		dev->irq = irq[this_dev];
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 6572425..cfe8829 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -28,13 +28,7 @@
 #include <asm/io.h>
 #include <asm/irq.h>
 
-#ifdef CONFIG_R8169_NAPI
-#define NAPI_SUFFIX	"-NAPI"
-#else
-#define NAPI_SUFFIX	""
-#endif
-
-#define RTL8169_VERSION "2.2LK" NAPI_SUFFIX
+#define RTL8169_VERSION "2.3LK-NAPI"
 #define MODULENAME "r8169"
 #define PFX MODULENAME ": "
 
@@ -57,16 +51,6 @@
 #define TX_BUFFS_AVAIL(tp) \
 	(tp->dirty_tx + NUM_TX_DESC - tp->cur_tx - 1)
 
-#ifdef CONFIG_R8169_NAPI
-#define rtl8169_rx_skb			netif_receive_skb
-#define rtl8169_rx_hwaccel_skb		vlan_hwaccel_receive_skb
-#define rtl8169_rx_quota(count, quota)	min(count, quota)
-#else
-#define rtl8169_rx_skb			netif_rx
-#define rtl8169_rx_hwaccel_skb		vlan_hwaccel_rx
-#define rtl8169_rx_quota(count, quota)	count
-#endif
-
 /* Maximum events (Rx packets, etc.) to handle at each interrupt. */
 static const int max_interrupt_work = 20;
 
@@ -394,9 +378,7 @@ struct rtl8169_private {
 	void __iomem *mmio_addr;	/* memory map physical address */
 	struct pci_dev *pci_dev;	/* Index of PCI device */
 	struct net_device *dev;
-#ifdef CONFIG_R8169_NAPI
 	struct napi_struct napi;
-#endif
 	spinlock_t lock;		/* spin lock flag */
 	u32 msg_enable;
 	int chipset;
@@ -458,10 +440,7 @@ static int rtl8169_rx_interrupt(struct net_device *, struct rtl8169_private *,
 static int rtl8169_change_mtu(struct net_device *dev, int new_mtu);
 static void rtl8169_down(struct net_device *dev);
 static void rtl8169_rx_clear(struct rtl8169_private *tp);
-
-#ifdef CONFIG_R8169_NAPI
 static int rtl8169_poll(struct napi_struct *napi, int budget);
-#endif
 
 static const unsigned int rtl8169_rx_config =
 	(RX_FIFO_THRESH << RxCfgFIFOShift) | (RX_DMA_BURST << RxCfgDMAShift);
@@ -843,10 +822,11 @@ static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp, struct RxDesc *desc,
 			       struct sk_buff *skb)
 {
 	u32 opts2 = le32_to_cpu(desc->opts2);
+	struct vlan_group *vlgrp = tp->vlgrp;
 	int ret;
 
-	if (tp->vlgrp && (opts2 & RxVlanTag)) {
-		rtl8169_rx_hwaccel_skb(skb, tp->vlgrp, swab16(opts2 & 0xffff));
+	if (vlgrp && (opts2 & RxVlanTag)) {
+		vlan_hwaccel_receive_skb(skb, vlgrp, swab16(opts2 & 0xffff));
 		ret = 0;
 	} else
 		ret = -1;
@@ -1764,9 +1744,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->change_mtu = rtl8169_change_mtu;
 	dev->set_mac_address = rtl_set_mac_address;
 
-#ifdef CONFIG_R8169_NAPI
 	netif_napi_add(dev, &tp->napi, rtl8169_poll, R8169_NAPI_WEIGHT);
-#endif
 
 #ifdef CONFIG_R8169_VLAN
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
@@ -1887,9 +1865,7 @@ static int rtl8169_open(struct net_device *dev)
 	if (retval < 0)
 		goto err_release_ring_2;
 
-#ifdef CONFIG_R8169_NAPI
 	napi_enable(&tp->napi);
-#endif
 
 	rtl_hw_start(dev);
 
@@ -2197,9 +2173,7 @@ static int rtl8169_change_mtu(struct net_device *dev, int new_mtu)
 	if (ret < 0)
 		goto out;
 
-#ifdef CONFIG_R8169_NAPI
 	napi_enable(&tp->napi);
-#endif
 
 	rtl_hw_start(dev);
 
@@ -2391,17 +2365,13 @@ static void rtl8169_wait_for_quiescence(struct net_device *dev)
 	synchronize_irq(dev->irq);
 
 	/* Wait for any pending NAPI task to complete */
-#ifdef CONFIG_R8169_NAPI
 	napi_disable(&tp->napi);
-#endif
 
 	rtl8169_irq_mask_and_ack(ioaddr);
 
-#ifdef CONFIG_R8169_NAPI
 	tp->intr_mask = 0xffff;
 	RTL_W16(IntrMask, tp->intr_event);
 	napi_enable(&tp->napi);
-#endif
 }
 
 static void rtl8169_reinit_task(struct work_struct *work)
@@ -2767,7 +2737,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 
 	cur_rx = tp->cur_rx;
 	rx_left = NUM_RX_DESC + tp->dirty_rx - cur_rx;
-	rx_left = rtl8169_rx_quota(rx_left, budget);
+	rx_left = min(rx_left, budget);
 
 	for (; rx_left > 0; rx_left--, cur_rx++) {
 		unsigned int entry = cur_rx % NUM_RX_DESC;
@@ -2829,7 +2799,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 			skb->protocol = eth_type_trans(skb, dev);
 
 			if (rtl8169_rx_vlan_skb(tp, desc, skb) < 0)
-				rtl8169_rx_skb(skb);
+				netif_receive_skb(skb);
 
 			dev->last_rx = jiffies;
 			dev->stats.rx_bytes += pkt_size;
@@ -2869,87 +2839,61 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev = dev_instance;
 	struct rtl8169_private *tp = netdev_priv(dev);
-	int boguscnt = max_interrupt_work;
 	void __iomem *ioaddr = tp->mmio_addr;
-	int status;
 	int handled = 0;
+	int status;
 
-	do {
-		status = RTL_R16(IntrStatus);
+	status = RTL_R16(IntrStatus);
 
-		/* hotplug/major error/no more work/shared irq */
-		if ((status == 0xFFFF) || !status)
-			break;
+	/* hotplug/major error/no more work/shared irq */
+	if ((status == 0xffff) || !status)
+		goto out;
 
-		handled = 1;
+	handled = 1;
 
-		if (unlikely(!netif_running(dev))) {
-			rtl8169_asic_down(ioaddr);
-			goto out;
-		}
+	if (unlikely(!netif_running(dev))) {
+		rtl8169_asic_down(ioaddr);
+		goto out;
+	}
 
-		status &= tp->intr_mask;
-		RTL_W16(IntrStatus,
-			(status & RxFIFOOver) ? (status | RxOverflow) : status);
+	status &= tp->intr_mask;
+	RTL_W16(IntrStatus,
+		(status & RxFIFOOver) ? (status | RxOverflow) : status);
 
-		if (!(status & tp->intr_event))
-			break;
+	if (!(status & tp->intr_event))
+		goto out;
 
-                /* Work around for rx fifo overflow */
-                if (unlikely(status & RxFIFOOver) &&
-		    (tp->mac_version == RTL_GIGA_MAC_VER_11)) {
-			netif_stop_queue(dev);
-			rtl8169_tx_timeout(dev);
-			break;
-		}
+	/* Work around for rx fifo overflow */
+	if (unlikely(status & RxFIFOOver) &&
+	    (tp->mac_version == RTL_GIGA_MAC_VER_11)) {
+		netif_stop_queue(dev);
+		rtl8169_tx_timeout(dev);
+		goto out;
+	}
 
-		if (unlikely(status & SYSErr)) {
-			rtl8169_pcierr_interrupt(dev);
-			break;
-		}
+	if (unlikely(status & SYSErr)) {
+		rtl8169_pcierr_interrupt(dev);
+		goto out;
+	}
 
-		if (status & LinkChg)
-			rtl8169_check_link_status(dev, tp, ioaddr);
+	if (status & LinkChg)
+		rtl8169_check_link_status(dev, tp, ioaddr);
 
-#ifdef CONFIG_R8169_NAPI
-		if (status & tp->napi_event) {
-			RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
-			tp->intr_mask = ~tp->napi_event;
+	if (status & tp->napi_event) {
+		RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
+		tp->intr_mask = ~tp->napi_event;
 
 		if (likely(netif_rx_schedule_prep(dev, &tp->napi)))
 			__netif_rx_schedule(dev, &tp->napi);
-			else if (netif_msg_intr(tp)) {
-				printk(KERN_INFO "%s: interrupt %04x in poll\n",
-				       dev->name, status);
-			}
+		else if (netif_msg_intr(tp)) {
+			printk(KERN_INFO "%s: interrupt %04x in poll\n",
+			       dev->name, status);
 		}
-		break;
-#else
-		/* Rx interrupt */
-		if (status & (RxOK | RxOverflow | RxFIFOOver))
-			rtl8169_rx_interrupt(dev, tp, ioaddr, ~(u32)0);
-
-		/* Tx interrupt */
-		if (status & (TxOK | TxErr))
-			rtl8169_tx_interrupt(dev, tp, ioaddr);
-#endif
-
-		boguscnt--;
-	} while (boguscnt > 0);
-
-	if (boguscnt <= 0) {
-		if (netif_msg_intr(tp) && net_ratelimit() ) {
-			printk(KERN_WARNING
-			       "%s: Too much work at interrupt!\n", dev->name);
-		}
-		/* Clear all interrupt sources. */
-		RTL_W16(IntrStatus, 0xffff);
 	}
 out:
 	return IRQ_RETVAL(handled);
 }
 
-#ifdef CONFIG_R8169_NAPI
 static int rtl8169_poll(struct napi_struct *napi, int budget)
 {
 	struct rtl8169_private *tp = container_of(napi, struct rtl8169_private, napi);
@@ -2975,7 +2919,6 @@ static int rtl8169_poll(struct napi_struct *napi, int budget)
 
 	return work_done;
 }
-#endif
 
 static void rtl8169_down(struct net_device *dev)
 {
@@ -2987,9 +2930,7 @@ static void rtl8169_down(struct net_device *dev)
 
 	netif_stop_queue(dev);
 
-#ifdef CONFIG_R8169_NAPI
 	napi_disable(&tp->napi);
-#endif
 
 core_down:
 	spin_lock_irq(&tp->lock);
@@ -3098,8 +3039,10 @@ static void rtl_set_rx_mode(struct net_device *dev)
 	    (tp->mac_version == RTL_GIGA_MAC_VER_15) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_16) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_17)) {
-		mc_filter[0] = 0xffffffff;
-		mc_filter[1] = 0xffffffff;
+		u32 data = mc_filter[0];
+
+		mc_filter[0] = swab32(mc_filter[1]);
+		mc_filter[1] = swab32(data);
 	}
 
 	RTL_W32(MAR0 + 0, mc_filter[0]);
diff --git a/drivers/net/wan/c101.c b/drivers/net/wan/c101.c
index c2cc42f..c8e5631 100644
--- a/drivers/net/wan/c101.c
+++ b/drivers/net/wan/c101.c
@@ -133,9 +133,9 @@ static void sca_msci_intr(port_t *port)
 	sca_out(stat & (ST1_UDRN | ST1_CDCD), MSCI0_OFFSET + ST1, port);
 
 	if (stat & ST1_UDRN) {
-		struct net_device_stats *stats = hdlc_stats(port_to_dev(port));
-		stats->tx_errors++; /* TX Underrun error detected */
-		stats->tx_fifo_errors++;
+		/* TX Underrun error detected */
+		port_to_dev(port)->stats.tx_errors++;
+		port_to_dev(port)->stats.tx_fifo_errors++;
 	}
 
 	stat = sca_in(MSCI1_OFFSET + ST1, port); /* read MSCI1 ST1 status */
diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index c6f26e2..50ef5b4 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -642,7 +642,6 @@ static inline void dscc4_rx_skb(struct dscc4_dev_priv *dpriv,
 				struct net_device *dev)
 {
 	struct RxFD *rx_fd = dpriv->rx_fd + dpriv->rx_current%RX_RING_SIZE;
-	struct net_device_stats *stats = hdlc_stats(dev);
 	struct pci_dev *pdev = dpriv->pci_priv->pdev;
 	struct sk_buff *skb;
 	int pkt_len;
@@ -656,8 +655,8 @@ static inline void dscc4_rx_skb(struct dscc4_dev_priv *dpriv,
 	pci_unmap_single(pdev, le32_to_cpu(rx_fd->data),
 			 RX_MAX(HDLC_MAX_MRU), PCI_DMA_FROMDEVICE);
 	if ((skb->data[--pkt_len] & FrameOk) == FrameOk) {
-		stats->rx_packets++;
-		stats->rx_bytes += pkt_len;
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += pkt_len;
 		skb_put(skb, pkt_len);
 		if (netif_running(dev))
 			skb->protocol = hdlc_type_trans(skb, dev);
@@ -665,13 +664,13 @@ static inline void dscc4_rx_skb(struct dscc4_dev_priv *dpriv,
 		netif_rx(skb);
 	} else {
 		if (skb->data[pkt_len] & FrameRdo)
-			stats->rx_fifo_errors++;
+			dev->stats.rx_fifo_errors++;
 		else if (!(skb->data[pkt_len] | ~FrameCrc))
-			stats->rx_crc_errors++;
+			dev->stats.rx_crc_errors++;
 		else if (!(skb->data[pkt_len] | ~(FrameVfr | FrameRab)))
-			stats->rx_length_errors++;
+			dev->stats.rx_length_errors++;
 		else
-			stats->rx_errors++;
+			dev->stats.rx_errors++;
 		dev_kfree_skb_irq(skb);
 	}
 refill:
@@ -1569,7 +1568,6 @@ try:
 
 	if (state & SccEvt) {
 		if (state & Alls) {
-			struct net_device_stats *stats = hdlc_stats(dev);
 			struct sk_buff *skb;
 			struct TxFD *tx_fd;
 
@@ -1586,8 +1584,8 @@ try:
 				pci_unmap_single(ppriv->pdev, le32_to_cpu(tx_fd->data),
 						 skb->len, PCI_DMA_TODEVICE);
 				if (tx_fd->state & FrameEnd) {
-					stats->tx_packets++;
-					stats->tx_bytes += skb->len;
+					dev->stats.tx_packets++;
+					dev->stats.tx_bytes += skb->len;
 				}
 				dev_kfree_skb_irq(skb);
 				dpriv->tx_skbuff[cur] = NULL;
@@ -1698,7 +1696,7 @@ try:
 		}
 		if (state & Err) {
 			printk(KERN_INFO "%s: Tx ERR\n", dev->name);
-			hdlc_stats(dev)->tx_errors++;
+			dev->stats.tx_errors++;
 			state &= ~Err;
 		}
 	}
@@ -1834,7 +1832,7 @@ try:
 				if (!(rx_fd->state2 & DataComplete))
 					break;
 				if (rx_fd->state2 & FrameAborted) {
-					hdlc_stats(dev)->rx_over_errors++;
+					dev->stats.rx_over_errors++;
 					rx_fd->state1 |= Hold;
 					rx_fd->state2 = 0x00000000;
 					rx_fd->end = cpu_to_le32(0xbabeface);
diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index 547368e..754f008 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -845,7 +845,6 @@ fst_tx_dma_complete(struct fst_card_info *card, struct fst_port_info *port,
 		    int len, int txpos)
 {
 	struct net_device *dev = port_to_dev(port);
-	struct net_device_stats *stats = hdlc_stats(dev);
 
 	/*
 	 * Everything is now set, just tell the card to go
@@ -853,8 +852,8 @@ fst_tx_dma_complete(struct fst_card_info *card, struct fst_port_info *port,
 	dbg(DBG_TX, "fst_tx_dma_complete\n");
 	FST_WRB(card, txDescrRing[port->index][txpos].bits,
 		DMA_OWN | TX_STP | TX_ENP);
-	stats->tx_packets++;
-	stats->tx_bytes += len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += len;
 	dev->trans_start = jiffies;
 }
 
@@ -876,7 +875,6 @@ fst_rx_dma_complete(struct fst_card_info *card, struct fst_port_info *port,
 		    int len, struct sk_buff *skb, int rxp)
 {
 	struct net_device *dev = port_to_dev(port);
-	struct net_device_stats *stats = hdlc_stats(dev);
 	int pi;
 	int rx_status;
 
@@ -888,8 +886,8 @@ fst_rx_dma_complete(struct fst_card_info *card, struct fst_port_info *port,
 	FST_WRB(card, rxDescrRing[pi][rxp].bits, DMA_OWN);
 
 	/* Update stats */
-	stats->rx_packets++;
-	stats->rx_bytes += len;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += len;
 
 	/* Push upstream */
 	dbg(DBG_RX, "Pushing the frame up the stack\n");
@@ -900,7 +898,7 @@ fst_rx_dma_complete(struct fst_card_info *card, struct fst_port_info *port,
 	rx_status = netif_rx(skb);
 	fst_process_rx_status(rx_status, port_to_dev(port)->name);
 	if (rx_status == NET_RX_DROP)
-		stats->rx_dropped++;
+		dev->stats.rx_dropped++;
 	dev->last_rx = jiffies;
 }
 
@@ -1163,29 +1161,28 @@ fst_log_rx_error(struct fst_card_info *card, struct fst_port_info *port,
 		 unsigned char dmabits, int rxp, unsigned short len)
 {
 	struct net_device *dev = port_to_dev(port);
-	struct net_device_stats *stats = hdlc_stats(dev);
 
-	/* 
+	/*
 	 * Increment the appropriate error counter
 	 */
-	stats->rx_errors++;
+	dev->stats.rx_errors++;
 	if (dmabits & RX_OFLO) {
-		stats->rx_fifo_errors++;
+		dev->stats.rx_fifo_errors++;
 		dbg(DBG_ASS, "Rx fifo error on card %d port %d buffer %d\n",
 		    card->card_no, port->index, rxp);
 	}
 	if (dmabits & RX_CRC) {
-		stats->rx_crc_errors++;
+		dev->stats.rx_crc_errors++;
 		dbg(DBG_ASS, "Rx crc error on card %d port %d\n",
 		    card->card_no, port->index);
 	}
 	if (dmabits & RX_FRAM) {
-		stats->rx_frame_errors++;
+		dev->stats.rx_frame_errors++;
 		dbg(DBG_ASS, "Rx frame error on card %d port %d\n",
 		    card->card_no, port->index);
 	}
 	if (dmabits == (RX_STP | RX_ENP)) {
-		stats->rx_length_errors++;
+		dev->stats.rx_length_errors++;
 		dbg(DBG_ASS, "Rx length error (%d) on card %d port %d\n",
 		    len, card->card_no, port->index);
 	}
@@ -1242,7 +1239,6 @@ fst_intr_rx(struct fst_card_info *card, struct fst_port_info *port)
 	unsigned short len;
 	struct sk_buff *skb;
 	struct net_device *dev = port_to_dev(port);
-	struct net_device_stats *stats = hdlc_stats(dev);
 
 	/* Check we have a buffer to process */
 	pi = port->index;
@@ -1291,7 +1287,7 @@ fst_intr_rx(struct fst_card_info *card, struct fst_port_info *port)
 	if ((skb = dev_alloc_skb(len)) == NULL) {
 		dbg(DBG_RX, "intr_rx: can't allocate buffer\n");
 
-		stats->rx_dropped++;
+		dev->stats.rx_dropped++;
 
 		/* Return descriptor to card */
 		FST_WRB(card, rxDescrRing[pi][rxp].bits, DMA_OWN);
@@ -1316,8 +1312,8 @@ fst_intr_rx(struct fst_card_info *card, struct fst_port_info *port)
 		FST_WRB(card, rxDescrRing[pi][rxp].bits, DMA_OWN);
 
 		/* Update stats */
-		stats->rx_packets++;
-		stats->rx_bytes += len;
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += len;
 
 		/* Push upstream */
 		dbg(DBG_RX, "Pushing frame up the stack\n");
@@ -1327,9 +1323,8 @@ fst_intr_rx(struct fst_card_info *card, struct fst_port_info *port)
 			skb->protocol = hdlc_type_trans(skb, dev);
 		rx_status = netif_rx(skb);
 		fst_process_rx_status(rx_status, port_to_dev(port)->name);
-		if (rx_status == NET_RX_DROP) {
-			stats->rx_dropped++;
-		}
+		if (rx_status == NET_RX_DROP)
+			dev->stats.rx_dropped++;
 		dev->last_rx = jiffies;
 	} else {
 		card->dma_skb_rx = skb;
@@ -1361,7 +1356,6 @@ do_bottom_half_tx(struct fst_card_info *card)
 	struct sk_buff *skb;
 	unsigned long flags;
 	struct net_device *dev;
-	struct net_device_stats *stats;
 
 	/*
 	 *  Find a free buffer for the transmit
@@ -1373,12 +1367,10 @@ do_bottom_half_tx(struct fst_card_info *card)
 		if (!port->run)
 			continue;
 
-                dev = port_to_dev(port);
-                stats = hdlc_stats(dev);
-		while (!
-		       (FST_RDB(card, txDescrRing[pi][port->txpos].bits) &
-			DMA_OWN)
-                       && !(card->dmatx_in_progress)) {
+		dev = port_to_dev(port);
+		while (!(FST_RDB(card, txDescrRing[pi][port->txpos].bits) &
+			 DMA_OWN)
+		       && !(card->dmatx_in_progress)) {
 			/*
 			 * There doesn't seem to be a txdone event per-se
 			 * We seem to have to deduce it, by checking the DMA_OWN
@@ -1422,8 +1414,8 @@ do_bottom_half_tx(struct fst_card_info *card)
 						txDescrRing[pi][port->txpos].
 						bits,
 						DMA_OWN | TX_STP | TX_ENP);
-					stats->tx_packets++;
-					stats->tx_bytes += skb->len;
+					dev->stats.tx_packets++;
+					dev->stats.tx_bytes += skb->len;
 					dev->trans_start = jiffies;
 				} else {
 					/* Or do it through dma */
@@ -1628,8 +1620,8 @@ fst_intr(int dummy, void *dev_id)
 			 * always load up the entire packet for DMA.
 			 */
 			dbg(DBG_TX, "Tx underflow port %d\n", port->index);
-                        hdlc_stats(port_to_dev(port))->tx_errors++;
-                        hdlc_stats(port_to_dev(port))->tx_fifo_errors++;
+			port_to_dev(port)->stats.tx_errors++;
+			port_to_dev(port)->stats.tx_fifo_errors++;
 			dbg(DBG_ASS, "Tx underflow on card %d port %d\n",
 			    card->card_no, port->index);
 			break;
@@ -2292,12 +2284,11 @@ fst_tx_timeout(struct net_device *dev)
 {
 	struct fst_port_info *port;
 	struct fst_card_info *card;
-	struct net_device_stats *stats = hdlc_stats(dev);
 
 	port = dev_to_port(dev);
 	card = port->card;
-	stats->tx_errors++;
-	stats->tx_aborted_errors++;
+	dev->stats.tx_errors++;
+	dev->stats.tx_aborted_errors++;
 	dbg(DBG_ASS, "Tx timeout card %d port %d\n",
 	    card->card_no, port->index);
 	fst_issue_cmd(port, ABORTTX);
@@ -2312,7 +2303,6 @@ fst_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct fst_card_info *card;
 	struct fst_port_info *port;
-	struct net_device_stats *stats = hdlc_stats(dev);
 	unsigned long flags;
 	int txq_length;
 
@@ -2323,8 +2313,8 @@ fst_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Drop packet with error if we don't have carrier */
 	if (!netif_carrier_ok(dev)) {
 		dev_kfree_skb(skb);
-		stats->tx_errors++;
-		stats->tx_carrier_errors++;
+		dev->stats.tx_errors++;
+		dev->stats.tx_carrier_errors++;
 		dbg(DBG_ASS,
 		    "Tried to transmit but no carrier on card %d port %d\n",
 		    card->card_no, port->index);
@@ -2336,7 +2326,7 @@ fst_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		dbg(DBG_ASS, "Packet too large %d vs %d\n", skb->len,
 		    LEN_TX_BUFFER);
 		dev_kfree_skb(skb);
-		stats->tx_errors++;
+		dev->stats.tx_errors++;
 		return 0;
 	}
 
@@ -2368,7 +2358,7 @@ fst_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		 * This shouldn't have happened but such is life
 		 */
 		dev_kfree_skb(skb);
-		stats->tx_errors++;
+		dev->stats.tx_errors++;
 		dbg(DBG_ASS, "Tx queue overflow card %d port %d\n",
 		    card->card_no, port->index);
 		return 0;
diff --git a/drivers/net/wan/hd6457x.c b/drivers/net/wan/hd6457x.c
index 8d0a1f2..591fb45 100644
--- a/drivers/net/wan/hd6457x.c
+++ b/drivers/net/wan/hd6457x.c
@@ -271,9 +271,9 @@ static inline void sca_msci_intr(port_t *port)
 	sca_out(stat & (ST1_UDRN | ST1_CDCD), msci + ST1, card);
 
 	if (stat & ST1_UDRN) {
-		struct net_device_stats *stats = hdlc_stats(port_to_dev(port));
-		stats->tx_errors++; /* TX Underrun error detected */
-		stats->tx_fifo_errors++;
+		/* TX Underrun error detected */
+		port_to_dev(port)->stats.tx_errors++;
+		port_to_dev(port)->stats.tx_fifo_errors++;
 	}
 
 	if (stat & ST1_CDCD)
@@ -286,7 +286,6 @@ static inline void sca_msci_intr(port_t *port)
 static inline void sca_rx(card_t *card, port_t *port, pkt_desc __iomem *desc, u16 rxin)
 {
 	struct net_device *dev = port_to_dev(port);
-	struct net_device_stats *stats = hdlc_stats(dev);
 	struct sk_buff *skb;
 	u16 len;
 	u32 buff;
@@ -298,7 +297,7 @@ static inline void sca_rx(card_t *card, port_t *port, pkt_desc __iomem *desc, u1
 	len = readw(&desc->len);
 	skb = dev_alloc_skb(len);
 	if (!skb) {
-		stats->rx_dropped++;
+		dev->stats.rx_dropped++;
 		return;
 	}
 
@@ -327,8 +326,8 @@ static inline void sca_rx(card_t *card, port_t *port, pkt_desc __iomem *desc, u1
 	printk(KERN_DEBUG "%s RX(%i):", dev->name, skb->len);
 	debug_frame(skb);
 #endif
-	stats->rx_packets++;
-	stats->rx_bytes += skb->len;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += skb->len;
 	dev->last_rx = jiffies;
 	skb->protocol = hdlc_type_trans(skb, dev);
 	netif_rx(skb);
@@ -339,17 +338,18 @@ static inline void sca_rx(card_t *card, port_t *port, pkt_desc __iomem *desc, u1
 /* Receive DMA interrupt service */
 static inline void sca_rx_intr(port_t *port)
 {
+	struct net_device *dev = port_to_dev(port);
 	u16 dmac = get_dmac_rx(port);
 	card_t *card = port_to_card(port);
 	u8 stat = sca_in(DSR_RX(phy_node(port)), card); /* read DMA Status */
-	struct net_device_stats *stats = hdlc_stats(port_to_dev(port));
 
 	/* Reset DSR status bits */
 	sca_out((stat & (DSR_EOT | DSR_EOM | DSR_BOF | DSR_COF)) | DSR_DWE,
 		DSR_RX(phy_node(port)), card);
 
 	if (stat & DSR_BOF)
-		stats->rx_over_errors++; /* Dropped one or more frames */
+		/* Dropped one or more frames */
+		dev->stats.rx_over_errors++;
 
 	while (1) {
 		u32 desc_off = desc_offset(port, port->rxin, 0);
@@ -364,12 +364,14 @@ static inline void sca_rx_intr(port_t *port)
 		if (!(stat & ST_RX_EOM))
 			port->rxpart = 1; /* partial frame received */
 		else if ((stat & ST_ERROR_MASK) || port->rxpart) {
-			stats->rx_errors++;
-			if (stat & ST_RX_OVERRUN) stats->rx_fifo_errors++;
+			dev->stats.rx_errors++;
+			if (stat & ST_RX_OVERRUN)
+				dev->stats.rx_fifo_errors++;
 			else if ((stat & (ST_RX_SHORT | ST_RX_ABORT |
 					  ST_RX_RESBIT)) || port->rxpart)
-				stats->rx_frame_errors++;
-			else if (stat & ST_RX_CRC) stats->rx_crc_errors++;
+				dev->stats.rx_frame_errors++;
+			else if (stat & ST_RX_CRC)
+				dev->stats.rx_crc_errors++;
 			if (stat & ST_RX_EOM)
 				port->rxpart = 0; /* received last fragment */
 		} else
@@ -390,7 +392,6 @@ static inline void sca_rx_intr(port_t *port)
 static inline void sca_tx_intr(port_t *port)
 {
 	struct net_device *dev = port_to_dev(port);
-	struct net_device_stats *stats = hdlc_stats(dev);
 	u16 dmac = get_dmac_tx(port);
 	card_t* card = port_to_card(port);
 	u8 stat;
@@ -412,8 +413,8 @@ static inline void sca_tx_intr(port_t *port)
 			break;	/* Transmitter is/will_be sending this frame */
 
 		desc = desc_address(port, port->txlast, 1);
-		stats->tx_packets++;
-		stats->tx_bytes += readw(&desc->len);
+		dev->stats.tx_packets++;
+		dev->stats.tx_bytes += readw(&desc->len);
 		writeb(0, &desc->stat);	/* Free descriptor */
 		port->txlast = next_desc(port, port->txlast, 1);
 	}
diff --git a/drivers/net/wan/hdlc.c b/drivers/net/wan/hdlc.c
index 7f98489..e3a5364 100644
--- a/drivers/net/wan/hdlc.c
+++ b/drivers/net/wan/hdlc.c
@@ -57,7 +57,7 @@ static int hdlc_change_mtu(struct net_device *dev, int new_mtu)
 
 static struct net_device_stats *hdlc_get_stats(struct net_device *dev)
 {
-	return hdlc_stats(dev);
+	return &dev->stats;
 }
 
 
diff --git a/drivers/net/wan/hdlc_cisco.c b/drivers/net/wan/hdlc_cisco.c
index 762d21c..849819c 100644
--- a/drivers/net/wan/hdlc_cisco.c
+++ b/drivers/net/wan/hdlc_cisco.c
@@ -252,8 +252,8 @@ static int cisco_rx(struct sk_buff *skb)
 	dev_kfree_skb_any(skb);
 	return NET_RX_DROP;
 
- rx_error:
-	dev_to_hdlc(dev)->stats.rx_errors++; /* Mark error */
+rx_error:
+	dev->stats.rx_errors++; /* Mark error */
 	dev_kfree_skb_any(skb);
 	return NET_RX_DROP;
 }
diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index 520bb0b..109bab3 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -135,11 +135,6 @@ typedef struct pvc_device_struct {
 	}state;
 }pvc_device;
 
-struct pvc_desc {
-	struct net_device_stats stats;
-	pvc_device *pvc;
-};
-
 struct frad_state {
 	fr_proto settings;
 	pvc_device *first_pvc;
@@ -179,15 +174,6 @@ static inline struct frad_state* state(hdlc_device *hdlc)
 	return(struct frad_state *)(hdlc->state);
 }
 
-static inline struct pvc_desc* pvcdev_to_desc(struct net_device *dev)
-{
-	return dev->priv;
-}
-
-static inline struct net_device_stats* pvc_get_stats(struct net_device *dev)
-{
-	return &pvcdev_to_desc(dev)->stats;
-}
 
 static inline pvc_device* find_pvc(hdlc_device *hdlc, u16 dlci)
 {
@@ -357,7 +343,7 @@ static int fr_hard_header(struct sk_buff **skb_p, u16 dlci)
 
 static int pvc_open(struct net_device *dev)
 {
-	pvc_device *pvc = pvcdev_to_desc(dev)->pvc;
+	pvc_device *pvc = dev->priv;
 
 	if ((pvc->frad->flags & IFF_UP) == 0)
 		return -EIO;  /* Frad must be UP in order to activate PVC */
@@ -377,7 +363,7 @@ static int pvc_open(struct net_device *dev)
 
 static int pvc_close(struct net_device *dev)
 {
-	pvc_device *pvc = pvcdev_to_desc(dev)->pvc;
+	pvc_device *pvc = dev->priv;
 
 	if (--pvc->open_count == 0) {
 		hdlc_device *hdlc = dev_to_hdlc(pvc->frad);
@@ -396,7 +382,7 @@ static int pvc_close(struct net_device *dev)
 
 static int pvc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	pvc_device *pvc = pvcdev_to_desc(dev)->pvc;
+	pvc_device *pvc = dev->priv;
 	fr_proto_pvc_info info;
 
 	if (ifr->ifr_settings.type == IF_GET_PROTO) {
@@ -424,8 +410,7 @@ static int pvc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 static int pvc_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	pvc_device *pvc = pvcdev_to_desc(dev)->pvc;
-	struct net_device_stats *stats = pvc_get_stats(dev);
+	pvc_device *pvc = dev->priv;
 
 	if (pvc->state.active) {
 		if (dev->type == ARPHRD_ETHER) {
@@ -435,7 +420,7 @@ static int pvc_xmit(struct sk_buff *skb, struct net_device *dev)
 				if (skb_tailroom(skb) < pad)
 					if (pskb_expand_head(skb, 0, pad,
 							     GFP_ATOMIC)) {
-						stats->tx_dropped++;
+						dev->stats.tx_dropped++;
 						dev_kfree_skb(skb);
 						return 0;
 					}
@@ -445,17 +430,17 @@ static int pvc_xmit(struct sk_buff *skb, struct net_device *dev)
 			skb->protocol = __constant_htons(ETH_P_802_3);
 		}
 		if (!fr_hard_header(&skb, pvc->dlci)) {
-			stats->tx_bytes += skb->len;
-			stats->tx_packets++;
+			dev->stats.tx_bytes += skb->len;
+			dev->stats.tx_packets++;
 			if (pvc->state.fecn) /* TX Congestion counter */
-				stats->tx_compressed++;
+				dev->stats.tx_compressed++;
 			skb->dev = pvc->frad;
 			dev_queue_xmit(skb);
 			return 0;
 		}
 	}
 
-	stats->tx_dropped++;
+	dev->stats.tx_dropped++;
 	dev_kfree_skb(skb);
 	return 0;
 }
@@ -955,7 +940,7 @@ static int fr_rx(struct sk_buff *skb)
 
 
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL) {
-		dev_to_hdlc(frad)->stats.rx_dropped++;
+		frad->stats.rx_dropped++;
 		return NET_RX_DROP;
 	}
 
@@ -1003,11 +988,10 @@ static int fr_rx(struct sk_buff *skb)
 	}
 
 	if (dev) {
-		struct net_device_stats *stats = pvc_get_stats(dev);
-		stats->rx_packets++; /* PVC traffic */
-		stats->rx_bytes += skb->len;
+		dev->stats.rx_packets++; /* PVC traffic */
+		dev->stats.rx_bytes += skb->len;
 		if (pvc->state.becn)
-			stats->rx_compressed++;
+			dev->stats.rx_compressed++;
 		netif_rx(skb);
 		return NET_RX_SUCCESS;
 	} else {
@@ -1016,7 +1000,7 @@ static int fr_rx(struct sk_buff *skb)
 	}
 
  rx_error:
-	dev_to_hdlc(frad)->stats.rx_errors++; /* Mark error */
+	frad->stats.rx_errors++; /* Mark error */
 	dev_kfree_skb_any(skb);
 	return NET_RX_DROP;
 }
@@ -1087,7 +1071,7 @@ static void pvc_setup(struct net_device *dev)
 static int fr_add_pvc(struct net_device *frad, unsigned int dlci, int type)
 {
 	hdlc_device *hdlc = dev_to_hdlc(frad);
-	pvc_device *pvc = NULL;
+	pvc_device *pvc;
 	struct net_device *dev;
 	int result, used;
 
@@ -1103,10 +1087,9 @@ static int fr_add_pvc(struct net_device *frad, unsigned int dlci, int type)
 	used = pvc_is_used(pvc);
 
 	if (type == ARPHRD_ETHER)
-		dev = alloc_netdev(sizeof(struct pvc_desc), "pvceth%d",
-				   ether_setup);
+		dev = alloc_netdev(0, "pvceth%d", ether_setup);
 	else
-		dev = alloc_netdev(sizeof(struct pvc_desc), "pvc%d", pvc_setup);
+		dev = alloc_netdev(0, "pvc%d", pvc_setup);
 
 	if (!dev) {
 		printk(KERN_WARNING "%s: Memory squeeze on fr_pvc()\n",
@@ -1122,14 +1105,13 @@ static int fr_add_pvc(struct net_device *frad, unsigned int dlci, int type)
 		dlci_to_q922(dev->broadcast, dlci);
 	}
 	dev->hard_start_xmit = pvc_xmit;
-	dev->get_stats = pvc_get_stats;
 	dev->open = pvc_open;
 	dev->stop = pvc_close;
 	dev->do_ioctl = pvc_ioctl;
 	dev->change_mtu = pvc_change_mtu;
 	dev->mtu = HDLC_MAX_MTU;
 	dev->tx_queue_len = 0;
-	pvcdev_to_desc(dev)->pvc = pvc;
+	dev->priv = pvc;
 
 	result = dev_alloc_name(dev, dev->name);
 	if (result < 0) {
diff --git a/drivers/net/wan/hdlc_raw_eth.c b/drivers/net/wan/hdlc_raw_eth.c
index d20c685..26dee60 100644
--- a/drivers/net/wan/hdlc_raw_eth.c
+++ b/drivers/net/wan/hdlc_raw_eth.c
@@ -33,7 +33,7 @@ static int eth_tx(struct sk_buff *skb, struct net_device *dev)
 		int len = skb->len;
 		if (skb_tailroom(skb) < pad)
 			if (pskb_expand_head(skb, 0, pad, GFP_ATOMIC)) {
-				hdlc_stats(dev)->tx_dropped++;
+				dev->stats.tx_dropped++;
 				dev_kfree_skb(skb);
 				return 0;
 			}
diff --git a/drivers/net/wan/hdlc_x25.c b/drivers/net/wan/hdlc_x25.c
index c15cc11..e808720 100644
--- a/drivers/net/wan/hdlc_x25.c
+++ b/drivers/net/wan/hdlc_x25.c
@@ -164,17 +164,15 @@ static void x25_close(struct net_device *dev)
 
 static int x25_rx(struct sk_buff *skb)
 {
-	struct hdlc_device *hdlc = dev_to_hdlc(skb->dev);
-
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL) {
-		hdlc->stats.rx_dropped++;
+		skb->dev->stats.rx_dropped++;
 		return NET_RX_DROP;
 	}
 
 	if (lapb_data_received(skb->dev, skb) == LAPB_OK)
 		return NET_RX_SUCCESS;
 
-	hdlc->stats.rx_errors++;
+	skb->dev->stats.rx_errors++;
 	dev_kfree_skb_any(skb);
 	return NET_RX_DROP;
 }
diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index 57914fb..3341705 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -285,7 +285,6 @@ static void rx_dma_buf_init(pc300_t *, int);
 static void tx_dma_buf_check(pc300_t *, int);
 static void rx_dma_buf_check(pc300_t *, int);
 static irqreturn_t cpc_intr(int, void *);
-static struct net_device_stats *cpc_get_stats(struct net_device *);
 static int clock_rate_calc(uclong, uclong, int *);
 static uclong detect_ram(pc300_t *);
 static void plx_init(pc300_t *);
@@ -1775,13 +1774,12 @@ static void cpc_tx_timeout(struct net_device *dev)
 	pc300dev_t *d = (pc300dev_t *) dev->priv;
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
-	struct net_device_stats *stats = hdlc_stats(dev);
 	int ch = chan->channel;
 	unsigned long flags;
 	ucchar ilar;
 
-	stats->tx_errors++;
-	stats->tx_aborted_errors++;
+	dev->stats.tx_errors++;
+	dev->stats.tx_aborted_errors++;
 	CPC_LOCK(card, flags);
 	if ((ilar = cpc_readb(card->hw.scabase + ILAR)) != 0) {
 		printk("%s: ILAR=0x%x\n", dev->name, ilar);
@@ -1803,7 +1801,6 @@ static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 	pc300dev_t *d = (pc300dev_t *) dev->priv;
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
-	struct net_device_stats *stats = hdlc_stats(dev);
 	int ch = chan->channel;
 	unsigned long flags;
 #ifdef PC300_DEBUG_TX
@@ -1817,13 +1814,13 @@ static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 	} else if (!netif_carrier_ok(dev)) {
 		/* DCD must be OFF: drop packet */
 		dev_kfree_skb(skb);
-		stats->tx_errors++;
-		stats->tx_carrier_errors++;
+		dev->stats.tx_errors++;
+		dev->stats.tx_carrier_errors++;
 		return 0;
 	} else if (cpc_readb(card->hw.scabase + M_REG(ST3, ch)) & ST3_DCD) {
 		printk("%s: DCD is OFF. Going administrative down.\n", dev->name);
-		stats->tx_errors++;
-		stats->tx_carrier_errors++;
+		dev->stats.tx_errors++;
+		dev->stats.tx_carrier_errors++;
 		dev_kfree_skb(skb);
 		netif_carrier_off(dev);
 		CPC_LOCK(card, flags);
@@ -1843,8 +1840,8 @@ static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 //		printk("%s: write error. Dropping TX packet.\n", dev->name);
 		netif_stop_queue(dev);
 		dev_kfree_skb(skb);
-		stats->tx_errors++;
-		stats->tx_dropped++;
+		dev->stats.tx_errors++;
+		dev->stats.tx_dropped++;
 		return 0;
 	}
 #ifdef PC300_DEBUG_TX
@@ -1886,7 +1883,6 @@ static void cpc_net_rx(struct net_device *dev)
 	pc300dev_t *d = (pc300dev_t *) dev->priv;
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
-	struct net_device_stats *stats = hdlc_stats(dev);
 	int ch = chan->channel;
 #ifdef PC300_DEBUG_RX
 	int i;
@@ -1922,24 +1918,24 @@ static void cpc_net_rx(struct net_device *dev)
 #endif
 			if ((skb == NULL) && (rxb > 0)) {
 				/* rxb > dev->mtu */
-				stats->rx_errors++;
-				stats->rx_length_errors++;
+				dev->stats.rx_errors++;
+				dev->stats.rx_length_errors++;
 				continue;
 			}
 
 			if (rxb < 0) {	/* Invalid frame */
 				rxb = -rxb;
 				if (rxb & DST_OVR) {
-					stats->rx_errors++;
-					stats->rx_fifo_errors++;
+					dev->stats.rx_errors++;
+					dev->stats.rx_fifo_errors++;
 				}
 				if (rxb & DST_CRC) {
-					stats->rx_errors++;
-					stats->rx_crc_errors++;
+					dev->stats.rx_errors++;
+					dev->stats.rx_crc_errors++;
 				}
 				if (rxb & (DST_RBIT | DST_SHRT | DST_ABT)) {
-					stats->rx_errors++;
-					stats->rx_frame_errors++;
+					dev->stats.rx_errors++;
+					dev->stats.rx_frame_errors++;
 				}
 			}
 			if (skb) {
@@ -1948,7 +1944,7 @@ static void cpc_net_rx(struct net_device *dev)
 			continue;
 		}
 
-		stats->rx_bytes += rxb;
+		dev->stats.rx_bytes += rxb;
 
 #ifdef PC300_DEBUG_RX
 		printk("%s R:", dev->name);
@@ -1959,7 +1955,7 @@ static void cpc_net_rx(struct net_device *dev)
 		if (d->trace_on) {
 			cpc_trace(dev, skb, 'R');
 		}
-		stats->rx_packets++;
+		dev->stats.rx_packets++;
 		skb->protocol = hdlc_type_trans(skb, dev);
 		netif_rx(skb);
 	}
@@ -1974,16 +1970,15 @@ static void sca_tx_intr(pc300dev_t *dev)
 	pc300_t *card = (pc300_t *)chan->card; 
 	int ch = chan->channel; 
 	volatile pcsca_bd_t __iomem * ptdescr; 
-	struct net_device_stats *stats = hdlc_stats(dev->dev);
 
     /* Clean up descriptors from previous transmission */
 	ptdescr = (card->hw.rambase +
 						TX_BD_ADDR(ch,chan->tx_first_bd));
-	while ((cpc_readl(card->hw.scabase + DTX_REG(CDAL,ch)) != 
-							TX_BD_ADDR(ch,chan->tx_first_bd)) && 
-			(cpc_readb(&ptdescr->status) & DST_OSB)) {
-		stats->tx_packets++;
-		stats->tx_bytes += cpc_readw(&ptdescr->len);
+	while ((cpc_readl(card->hw.scabase + DTX_REG(CDAL,ch)) !=
+		TX_BD_ADDR(ch,chan->tx_first_bd)) &&
+	       (cpc_readb(&ptdescr->status) & DST_OSB)) {
+		dev->dev->stats.tx_packets++;
+		dev->dev->stats.tx_bytes += cpc_readw(&ptdescr->len);
 		cpc_writeb(&ptdescr->status, DST_OSB);
 		cpc_writew(&ptdescr->len, 0);
 		chan->nfree_tx_bd++;
@@ -2048,8 +2043,8 @@ static void sca_intr(pc300_t * card)
 							}
 							cpc_net_rx(dev);
 							/* Discard invalid frames */
-							hdlc_stats(dev)->rx_errors++;
-							hdlc_stats(dev)->rx_over_errors++;
+							dev->stats.rx_errors++;
+							dev->stats.rx_over_errors++;
 							chan->rx_first_bd = 0;
 							chan->rx_last_bd = N_DMA_RX_BUF - 1;
 							rx_dma_start(card, ch);
@@ -2115,8 +2110,8 @@ static void sca_intr(pc300_t * card)
 										   card->hw.cpld_reg2) &
 								   ~ (CPLD_REG2_FALC_LED1 << (2 * ch)));
 						}
-						hdlc_stats(dev)->tx_errors++;
-						hdlc_stats(dev)->tx_fifo_errors++;
+						dev->stats.tx_errors++;
+						dev->stats.tx_fifo_errors++;
 						sca_tx_intr(d);
 					}
 				}
@@ -2604,7 +2599,7 @@ static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		case SIOCGPC300UTILSTATS:
 			{
 				if (!arg) {	/* clear statistics */
-					memset(hdlc_stats(dev), 0, sizeof(struct net_device_stats));
+					memset(&dev->stats, 0, sizeof(dev->stats));
 					if (card->hw.type == PC300_TE) {
 						memset(&chan->falc, 0, sizeof(falc_t));
 					}
@@ -2615,8 +2610,8 @@ static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 					pc300stats.hw_type = card->hw.type;
 					pc300stats.line_on = card->chan[ch].d.line_on;
 					pc300stats.line_off = card->chan[ch].d.line_off;
-					memcpy(&pc300stats.gen_stats, hdlc_stats(dev),
-					       sizeof(struct net_device_stats));
+					memcpy(&pc300stats.gen_stats, &dev->stats,
+					       sizeof(dev->stats));
 					if (card->hw.type == PC300_TE)
 						memcpy(&pc300stats.te_stats,&chan->falc,sizeof(falc_t));
 				    	if (copy_to_user(arg, &pc300stats, sizeof(pc300stats_t)))
@@ -2823,11 +2818,6 @@ static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	}
 }
 
-static struct net_device_stats *cpc_get_stats(struct net_device *dev)
-{
-	return hdlc_stats(dev);
-}
-
 static int clock_rate_calc(uclong rate, uclong clock, int *br_io)
 {
 	int br, tc;
@@ -3394,7 +3384,6 @@ static void cpc_init_card(pc300_t * card)
 		dev->stop = cpc_close;
 		dev->tx_timeout = cpc_tx_timeout;
 		dev->watchdog_timeo = PC300_TX_TIMEOUT;
-		dev->get_stats = cpc_get_stats;
 		dev->set_multicast_list = NULL;
 		dev->set_mac_address = NULL;
 		dev->change_mtu = cpc_change_mtu;
diff --git a/drivers/net/wan/pc300_tty.c b/drivers/net/wan/pc300_tty.c
index e03eef2..eae94ab 100644
--- a/drivers/net/wan/pc300_tty.c
+++ b/drivers/net/wan/pc300_tty.c
@@ -458,7 +458,7 @@ static int cpc_tty_write(struct tty_struct *tty, const unsigned char *buf, int c
 	CPC_TTY_DBG("%s: cpc_tty_write data len=%i\n",cpc_tty->name,count);
 	
 	pc300chan = (pc300ch_t *)((pc300dev_t*)cpc_tty->pc300dev)->chan; 
-	stats = hdlc_stats(((pc300dev_t*)cpc_tty->pc300dev)->dev);
+	stats = &cpc_tty->pc300dev->dev->stats;
 	card = (pc300_t *) pc300chan->card;
 	ch = pc300chan->channel; 
 
@@ -743,7 +743,7 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
 	pc300_t *card = (pc300_t *)pc300chan->card; 
 	int ch = pc300chan->channel; 
 	volatile pcsca_bd_t  __iomem * ptdescr; 
-	struct net_device_stats *stats = hdlc_stats(pc300dev->dev);
+	struct net_device_stats *stats = &pc300dev->dev->stats;
 	int rx_len, rx_aux; 
 	volatile unsigned char status; 
 	unsigned short first_bd = pc300chan->rx_first_bd;
@@ -917,7 +917,7 @@ static int cpc_tty_send_to_card(pc300dev_t *dev,void* buf, int len)
 	pc300ch_t *chan = (pc300ch_t *)dev->chan; 
 	pc300_t *card = (pc300_t *)chan->card; 
 	int ch = chan->channel; 
-	struct net_device_stats *stats = hdlc_stats(dev->dev);
+	struct net_device_stats *stats = &dev->dev->stats;
 	unsigned long flags; 
 	volatile pcsca_bd_t __iomem *ptdescr; 
 	int i, nchar;
diff --git a/drivers/net/wan/wanxl.c b/drivers/net/wan/wanxl.c
index d4aab8a..a8a5ca0 100644
--- a/drivers/net/wan/wanxl.c
+++ b/drivers/net/wan/wanxl.c
@@ -161,7 +161,6 @@ static inline void wanxl_cable_intr(port_t *port)
 static inline void wanxl_tx_intr(port_t *port)
 {
 	struct net_device *dev = port->dev;
-	struct net_device_stats *stats = hdlc_stats(dev);
 	while (1) {
                 desc_t *desc = &get_status(port)->tx_descs[port->tx_in];
 		struct sk_buff *skb = port->tx_skbs[port->tx_in];
@@ -173,13 +172,13 @@ static inline void wanxl_tx_intr(port_t *port)
 			return;
 
 		case PACKET_UNDERRUN:
-			stats->tx_errors++;
-			stats->tx_fifo_errors++;
+			dev->stats.tx_errors++;
+			dev->stats.tx_fifo_errors++;
 			break;
 
 		default:
-			stats->tx_packets++;
-			stats->tx_bytes += skb->len;
+			dev->stats.tx_packets++;
+			dev->stats.tx_bytes += skb->len;
 		}
                 desc->stat = PACKET_EMPTY; /* Free descriptor */
 		pci_unmap_single(port->card->pdev, desc->address, skb->len,
@@ -205,10 +204,9 @@ static inline void wanxl_rx_intr(card_t *card)
 			port_t *port = &card->ports[desc->stat &
 						    PACKET_PORT_MASK];
 			struct net_device *dev = port->dev;
-			struct net_device_stats *stats = hdlc_stats(dev);
 
 			if (!skb)
-				stats->rx_dropped++;
+				dev->stats.rx_dropped++;
 			else {
 				pci_unmap_single(card->pdev, desc->address,
 						 BUFFER_LENGTH,
@@ -220,8 +218,8 @@ static inline void wanxl_rx_intr(card_t *card)
 				       skb->len);
 				debug_frame(skb);
 #endif
-				stats->rx_packets++;
-				stats->rx_bytes += skb->len;
+				dev->stats.rx_packets++;
+				dev->stats.rx_bytes += skb->len;
 				dev->last_rx = jiffies;
 				skb->protocol = hdlc_type_trans(skb, dev);
 				netif_rx(skb);
@@ -468,13 +466,13 @@ static int wanxl_close(struct net_device *dev)
 
 static struct net_device_stats *wanxl_get_stats(struct net_device *dev)
 {
-	struct net_device_stats *stats = hdlc_stats(dev);
 	port_t *port = dev_to_port(dev);
 
-	stats->rx_over_errors = get_status(port)->rx_overruns;
-	stats->rx_frame_errors = get_status(port)->rx_frame_errors;
-	stats->rx_errors = stats->rx_over_errors + stats->rx_frame_errors;
-        return stats;
+	dev->stats.rx_over_errors = get_status(port)->rx_overruns;
+	dev->stats.rx_frame_errors = get_status(port)->rx_frame_errors;
+	dev->stats.rx_errors = dev->stats.rx_over_errors +
+		dev->stats.rx_frame_errors;
+	return &dev->stats;
 }
 
 
diff --git a/include/linux/hdlc.h b/include/linux/hdlc.h
index 6115545..c597696 100644
--- a/include/linux/hdlc.h
+++ b/include/linux/hdlc.h
@@ -45,7 +45,6 @@ struct hdlc_proto {
 
 /* Pointed to by dev->priv */
 typedef struct hdlc_device {
-	struct net_device_stats stats;
 	/* used by HDLC layer to take control over HDLC device from hw driver*/
 	int (*attach)(struct net_device *dev,
 		      unsigned short encoding, unsigned short parity);
@@ -109,12 +108,6 @@ int attach_hdlc_protocol(struct net_device *dev, struct hdlc_proto *proto,
 /* May be used by hardware driver to gain control over HDLC device */
 void detach_hdlc_protocol(struct net_device *dev);
 
-static __inline__ struct net_device_stats *hdlc_stats(struct net_device *dev)
-{
-	return &dev_to_hdlc(dev)->stats;
-}
-
-
 static __inline__ __be16 hdlc_type_trans(struct sk_buff *skb,
 					 struct net_device *dev)
 {

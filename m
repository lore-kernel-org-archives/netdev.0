From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Tue, 14 Aug 2007 02:10:35 -0400
Message-ID: <20070814061035.GA9657@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:60150 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936950AbXHNGMA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 02:12:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Minor stuff except for the xen-netfront fix.  e1000 change is an
adds-pci-ids-only change.

Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 MAINTAINERS                       |    6 ++++++
 drivers/net/3c59x.c               |    1 +
 drivers/net/ax88796.c             |    5 +++--
 drivers/net/e1000/e1000_ethtool.c |    2 ++
 drivers/net/e1000/e1000_hw.c      |    5 +++++
 drivers/net/e1000/e1000_hw.h      |    3 +++
 drivers/net/e1000/e1000_main.c    |    4 ++++
 drivers/net/myri10ge/myri10ge.c   |   25 ++++++++++++++++++-------
 drivers/net/natsemi.c             |    3 +++
 drivers/net/via-rhine.c           |    6 ++++++
 drivers/net/xen-netfront.c        |    7 ++++---
 11 files changed, 55 insertions(+), 12 deletions(-)

Andrew Morton (2):
      ax88796 printk fixes
      natsemi: fix netdev error acounting

Auke Kok (1):
      e1000: Add device IDs of new 82571 board variants

Brice Goglin (1):
      myri10ge: Use the pause counter to avoid a needless device reset

Dustin Marquess (1):
      via-rhine: disable rx_copybreak on archs that don't allow unaligned DMA access

Jeremy Fitzhardinge (1):
      xen-netfront: Avoid deref'ing skbafter it is potentially freed.

Steffen Klassert (2):
      3c59x: fix duplex configuration
      3c59x maintainer

diff --git a/MAINTAINERS b/MAINTAINERS
index d3a0684..e4dde7f 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -97,6 +97,12 @@ M:	philb@gnu.org
 L:	netdev@vger.kernel.org
 S:	Maintained
 
+3C59X NETWORK DRIVER
+P:	Steffen Klassert
+M:	klassert@mathematik.tu-chemnitz.de
+L:	netdev@vger.kernel.org
+S:	Maintained
+
 3CR990 NETWORK DRIVER
 P:	David Dillow
 M:	dave@thedillows.org
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 001c66d..a8c0f43 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -1555,6 +1555,7 @@ vortex_up(struct net_device *dev)
 		mii_reg1 = mdio_read(dev, vp->phys[0], MII_BMSR);
 		mii_reg5 = mdio_read(dev, vp->phys[0], MII_LPA);
 		vp->partner_flow_ctrl = ((mii_reg5 & 0x0400) != 0);
+		vp->mii.full_duplex = vp->full_duplex;
 
 		vortex_check_media(dev, 1);
 	}
diff --git a/drivers/net/ax88796.c b/drivers/net/ax88796.c
index 83da177..90e0734 100644
--- a/drivers/net/ax88796.c
+++ b/drivers/net/ax88796.c
@@ -821,8 +821,9 @@ static int ax_probe(struct platform_device *pdev)
 	dev->base_addr = (unsigned long)ei_status.mem;
 
 	if (ei_status.mem == NULL) {
-		dev_err(&pdev->dev, "Cannot ioremap area (%08zx,%08zx)\n",
-			res->start, res->end);
+		dev_err(&pdev->dev, "Cannot ioremap area (%08llx,%08llx)\n",
+			(unsigned long long)res->start,
+			(unsigned long long)res->end);
 
  		ret = -ENXIO;
 		goto exit_req;
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index c90c92e..4c3785c 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -1706,6 +1706,7 @@ static int e1000_wol_exclusion(struct e1000_adapter *adapter, struct ethtool_wol
 	case E1000_DEV_ID_82545EM_COPPER:
 	case E1000_DEV_ID_82546GB_QUAD_COPPER:
 	case E1000_DEV_ID_82546GB_PCIE:
+	case E1000_DEV_ID_82571EB_SERDES_QUAD:
 		/* these don't support WoL at all */
 		wol->supported = 0;
 		break;
@@ -1723,6 +1724,7 @@ static int e1000_wol_exclusion(struct e1000_adapter *adapter, struct ethtool_wol
 		retval = 0;
 		break;
 	case E1000_DEV_ID_82571EB_QUAD_COPPER:
+	case E1000_DEV_ID_82571EB_QUAD_FIBER:
 	case E1000_DEV_ID_82571EB_QUAD_COPPER_LOWPROFILE:
 	case E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3:
 		/* quad port adapters only support WoL on port A */
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 9be4469..ba120f7 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -384,7 +384,10 @@ e1000_set_mac_type(struct e1000_hw *hw)
 	case E1000_DEV_ID_82571EB_COPPER:
 	case E1000_DEV_ID_82571EB_FIBER:
 	case E1000_DEV_ID_82571EB_SERDES:
+	case E1000_DEV_ID_82571EB_SERDES_DUAL:
+	case E1000_DEV_ID_82571EB_SERDES_QUAD:
 	case E1000_DEV_ID_82571EB_QUAD_COPPER:
+	case E1000_DEV_ID_82571EB_QUAD_FIBER:
 	case E1000_DEV_ID_82571EB_QUAD_COPPER_LOWPROFILE:
 		hw->mac_type = e1000_82571;
 		break;
@@ -485,6 +488,8 @@ e1000_set_media_type(struct e1000_hw *hw)
     case E1000_DEV_ID_82545GM_SERDES:
     case E1000_DEV_ID_82546GB_SERDES:
     case E1000_DEV_ID_82571EB_SERDES:
+    case E1000_DEV_ID_82571EB_SERDES_DUAL:
+    case E1000_DEV_ID_82571EB_SERDES_QUAD:
     case E1000_DEV_ID_82572EI_SERDES:
     case E1000_DEV_ID_80003ES2LAN_SERDES_DPT:
         hw->media_type = e1000_media_type_internal_serdes;
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index bd000b8..fe87146 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -475,7 +475,10 @@ int32_t e1000_check_phy_reset_block(struct e1000_hw *hw);
 #define E1000_DEV_ID_82571EB_FIBER       0x105F
 #define E1000_DEV_ID_82571EB_SERDES      0x1060
 #define E1000_DEV_ID_82571EB_QUAD_COPPER 0x10A4
+#define E1000_DEV_ID_82571EB_QUAD_FIBER  0x10A5
 #define E1000_DEV_ID_82571EB_QUAD_COPPER_LOWPROFILE  0x10BC
+#define E1000_DEV_ID_82571EB_SERDES_DUAL 0x10D9
+#define E1000_DEV_ID_82571EB_SERDES_QUAD 0x10DA
 #define E1000_DEV_ID_82572EI_COPPER      0x107D
 #define E1000_DEV_ID_82572EI_FIBER       0x107E
 #define E1000_DEV_ID_82572EI_SERDES      0x107F
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index f48b659..4a22595 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -100,6 +100,7 @@ static struct pci_device_id e1000_pci_tbl[] = {
 	INTEL_E1000_ETHERNET_DEVICE(0x1099),
 	INTEL_E1000_ETHERNET_DEVICE(0x109A),
 	INTEL_E1000_ETHERNET_DEVICE(0x10A4),
+	INTEL_E1000_ETHERNET_DEVICE(0x10A5),
 	INTEL_E1000_ETHERNET_DEVICE(0x10B5),
 	INTEL_E1000_ETHERNET_DEVICE(0x10B9),
 	INTEL_E1000_ETHERNET_DEVICE(0x10BA),
@@ -107,6 +108,8 @@ static struct pci_device_id e1000_pci_tbl[] = {
 	INTEL_E1000_ETHERNET_DEVICE(0x10BC),
 	INTEL_E1000_ETHERNET_DEVICE(0x10C4),
 	INTEL_E1000_ETHERNET_DEVICE(0x10C5),
+	INTEL_E1000_ETHERNET_DEVICE(0x10D9),
+	INTEL_E1000_ETHERNET_DEVICE(0x10DA),
 	/* required last entry */
 	{0,}
 };
@@ -1096,6 +1099,7 @@ e1000_probe(struct pci_dev *pdev,
 		break;
 	case E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3:
 	case E1000_DEV_ID_82571EB_QUAD_COPPER:
+	case E1000_DEV_ID_82571EB_QUAD_FIBER:
 	case E1000_DEV_ID_82571EB_QUAD_COPPER_LOWPROFILE:
 		/* if quad port adapter, disable WoL on all but port A */
 		if (global_quad_port_a != 0)
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index deca653..ae9bb7b 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -191,6 +191,7 @@ struct myri10ge_priv {
 	struct timer_list watchdog_timer;
 	int watchdog_tx_done;
 	int watchdog_tx_req;
+	int watchdog_pause;
 	int watchdog_resets;
 	int tx_linearized;
 	int pause;
@@ -2800,6 +2801,7 @@ static void myri10ge_watchdog(struct work_struct *work)
 static void myri10ge_watchdog_timer(unsigned long arg)
 {
 	struct myri10ge_priv *mgp;
+	u32 rx_pause_cnt;
 
 	mgp = (struct myri10ge_priv *)arg;
 
@@ -2816,19 +2818,28 @@ static void myri10ge_watchdog_timer(unsigned long arg)
 		    myri10ge_fill_thresh)
 			mgp->rx_big.watchdog_needed = 0;
 	}
+	rx_pause_cnt = ntohl(mgp->fw_stats->dropped_pause);
 
 	if (mgp->tx.req != mgp->tx.done &&
 	    mgp->tx.done == mgp->watchdog_tx_done &&
-	    mgp->watchdog_tx_req != mgp->watchdog_tx_done)
+	    mgp->watchdog_tx_req != mgp->watchdog_tx_done) {
 		/* nic seems like it might be stuck.. */
-		schedule_work(&mgp->watchdog_work);
-	else
-		/* rearm timer */
-		mod_timer(&mgp->watchdog_timer,
-			  jiffies + myri10ge_watchdog_timeout * HZ);
-
+		if (rx_pause_cnt != mgp->watchdog_pause) {
+			if (net_ratelimit())
+				printk(KERN_WARNING "myri10ge %s:"
+				       "TX paused, check link partner\n",
+				       mgp->dev->name);
+		} else {
+			schedule_work(&mgp->watchdog_work);
+			return;
+		}
+	}
+	/* rearm timer */
+	mod_timer(&mgp->watchdog_timer,
+		  jiffies + myri10ge_watchdog_timeout * HZ);
 	mgp->watchdog_tx_done = mgp->tx.done;
 	mgp->watchdog_tx_req = mgp->tx.req;
+	mgp->watchdog_pause = rx_pause_cnt;
 }
 
 static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index 6bb48ba..b47a12d 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -2438,13 +2438,16 @@ static void netdev_error(struct net_device *dev, int intr_status)
 				dev->name);
 		}
 		np->stats.rx_fifo_errors++;
+		np->stats.rx_errors++;
 	}
 	/* Hmmmmm, it's not clear how to recover from PCI faults. */
 	if (intr_status & IntrPCIErr) {
 		printk(KERN_NOTICE "%s: PCI error %#08x\n", dev->name,
 			intr_status & IntrPCIErr);
 		np->stats.tx_fifo_errors++;
+		np->stats.tx_errors++;
 		np->stats.rx_fifo_errors++;
+		np->stats.rx_errors++;
 	}
 	spin_unlock(&np->lock);
 }
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index c3fe230..b56dff2 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -42,7 +42,13 @@ static int max_interrupt_work = 20;
 
 /* Set the copy breakpoint for the copy-only-tiny-frames scheme.
    Setting to > 1518 effectively disables this feature. */
+#if defined(__alpha__) || defined(__arm__) || defined(__hppa__) \
+       || defined(CONFIG_SPARC) || defined(__ia64__) \
+       || defined(__sh__) || defined(__mips__)
+static int rx_copybreak = 1518;
+#else
 static int rx_copybreak;
+#endif
 
 /* Work-around for broken BIOSes: they are unable to get the chip back out of
    power state D3 so PXE booting fails. bootparam(7): via-rhine.avoid_D3=1 */
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 489f69c..4445810 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -566,6 +566,10 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (notify)
 		notify_remote_via_irq(np->netdev->irq);
 
+	np->stats.tx_bytes += skb->len;
+	np->stats.tx_packets++;
+
+	/* Note: It is not safe to access skb after xennet_tx_buf_gc()! */
 	xennet_tx_buf_gc(dev);
 
 	if (!netfront_tx_slot_available(np))
@@ -573,9 +577,6 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_unlock_irq(&np->tx_lock);
 
-	np->stats.tx_bytes += skb->len;
-	np->stats.tx_packets++;
-
 	return 0;
 
  drop:

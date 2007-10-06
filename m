From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH 4/5] forcedeth: internal simplification and cleanups
Date: Sat, 6 Oct 2007 11:14:59 -0400
Message-ID: <20071006151459.GD17488@havoc.gtf.org>
References: <20071006151250.GA17020@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: netdev@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:44594 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764689AbXJFPPA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Oct 2007 11:15:00 -0400
Content-Disposition: inline
In-Reply-To: <20071006151250.GA17020@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


commit 39572457a4dfe9a9dc1efd6641e7a6467e5658a1
Author: Jeff Garzik <jeff@garzik.org>
Date:   Sat Oct 6 01:21:01 2007 -0400

    [netdrvr] forcedeth: internal simplification and cleanups
    
    * remove changelog from source; its kept in git repository
    
    * split guts of RX/TX DMA engine disable into disable portion,
      and wait/etc. portions.
    
    * consolidate descriptor version tests using nv_optimized()
    
    * consolidate NIC DMA start, stop and drain into
      nv_start_txrx(), nv_stop_txrx(), nv_drain_txrx()
    
    * change nv_poll_controller() to call interrupt handling function
    
    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

 drivers/net/forcedeth.c |  228 +++++++++++++++++-------------------------------
 1 file changed, 84 insertions(+), 144 deletions(-)

39572457a4dfe9a9dc1efd6641e7a6467e5658a1
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 1c236e6..d6eacd7 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -29,89 +29,7 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  *
- * Changelog:
- * 	0.01: 05 Oct 2003: First release that compiles without warnings.
- * 	0.02: 05 Oct 2003: Fix bug for nv_drain_tx: do not try to free NULL skbs.
- * 			   Check all PCI BARs for the register window.
- * 			   udelay added to mii_rw.
- * 	0.03: 06 Oct 2003: Initialize dev->irq.
- * 	0.04: 07 Oct 2003: Initialize np->lock, reduce handled irqs, add printks.
- * 	0.05: 09 Oct 2003: printk removed again, irq status print tx_timeout.
- * 	0.06: 10 Oct 2003: MAC Address read updated, pff flag generation updated,
- * 			   irq mask updated
- * 	0.07: 14 Oct 2003: Further irq mask updates.
- * 	0.08: 20 Oct 2003: rx_desc.Length initialization added, nv_alloc_rx refill
- * 			   added into irq handler, NULL check for drain_ring.
- * 	0.09: 20 Oct 2003: Basic link speed irq implementation. Only handle the
- * 			   requested interrupt sources.
- * 	0.10: 20 Oct 2003: First cleanup for release.
- * 	0.11: 21 Oct 2003: hexdump for tx added, rx buffer sizes increased.
- * 			   MAC Address init fix, set_multicast cleanup.
- * 	0.12: 23 Oct 2003: Cleanups for release.
- * 	0.13: 25 Oct 2003: Limit for concurrent tx packets increased to 10.
- * 			   Set link speed correctly. start rx before starting
- * 			   tx (nv_start_rx sets the link speed).
- * 	0.14: 25 Oct 2003: Nic dependant irq mask.
- * 	0.15: 08 Nov 2003: fix smp deadlock with set_multicast_list during
- * 			   open.
- * 	0.16: 15 Nov 2003: include file cleanup for ppc64, rx buffer size
- * 			   increased to 1628 bytes.
- * 	0.17: 16 Nov 2003: undo rx buffer size increase. Substract 1 from
- * 			   the tx length.
- * 	0.18: 17 Nov 2003: fix oops due to late initialization of dev_stats
- * 	0.19: 29 Nov 2003: Handle RxNoBuf, detect & handle invalid mac
- * 			   addresses, really stop rx if already running
- * 			   in nv_start_rx, clean up a bit.
- * 	0.20: 07 Dec 2003: alloc fixes
- * 	0.21: 12 Jan 2004: additional alloc fix, nic polling fix.
- *	0.22: 19 Jan 2004: reprogram timer to a sane rate, avoid lockup
- *			   on close.
- *	0.23: 26 Jan 2004: various small cleanups
- *	0.24: 27 Feb 2004: make driver even less anonymous in backtraces
- *	0.25: 09 Mar 2004: wol support
- *	0.26: 03 Jun 2004: netdriver specific annotation, sparse-related fixes
- *	0.27: 19 Jun 2004: Gigabit support, new descriptor rings,
- *			   added CK804/MCP04 device IDs, code fixes
- *			   for registers, link status and other minor fixes.
- *	0.28: 21 Jun 2004: Big cleanup, making driver mostly endian safe
- *	0.29: 31 Aug 2004: Add backup timer for link change notification.
- *	0.30: 25 Sep 2004: rx checksum support for nf 250 Gb. Add rx reset
- *			   into nv_close, otherwise reenabling for wol can
- *			   cause DMA to kfree'd memory.
- *	0.31: 14 Nov 2004: ethtool support for getting/setting link
- *			   capabilities.
- *	0.32: 16 Apr 2005: RX_ERROR4 handling added.
- *	0.33: 16 May 2005: Support for MCP51 added.
- *	0.34: 18 Jun 2005: Add DEV_NEED_LINKTIMER to all nForce nics.
- *	0.35: 26 Jun 2005: Support for MCP55 added.
- *	0.36: 28 Jun 2005: Add jumbo frame support.
- *	0.37: 10 Jul 2005: Additional ethtool support, cleanup of pci id list
- *	0.38: 16 Jul 2005: tx irq rewrite: Use global flags instead of
- *			   per-packet flags.
- *	0.39: 18 Jul 2005: Add 64bit descriptor support.
- *	0.40: 19 Jul 2005: Add support for mac address change.
- *	0.41: 30 Jul 2005: Write back original MAC in nv_close instead
- *			   of nv_remove
- *	0.42: 06 Aug 2005: Fix lack of link speed initialization
- *			   in the second (and later) nv_open call
- *	0.43: 10 Aug 2005: Add support for tx checksum.
- *	0.44: 20 Aug 2005: Add support for scatter gather and segmentation.
- *	0.45: 18 Sep 2005: Remove nv_stop/start_rx from every link check
- *	0.46: 20 Oct 2005: Add irq optimization modes.
- *	0.47: 26 Oct 2005: Add phyaddr 0 in phy scan.
- *	0.48: 24 Dec 2005: Disable TSO, bugfix for pci_map_single
- *	0.49: 10 Dec 2005: Fix tso for large buffers.
- *	0.50: 20 Jan 2006: Add 8021pq tagging support.
- *	0.51: 20 Jan 2006: Add 64bit consistent memory allocation for rings.
- *	0.52: 20 Jan 2006: Add MSI/MSIX support.
- *	0.53: 19 Mar 2006: Fix init from low power mode and add hw reset.
- *	0.54: 21 Mar 2006: Fix spin locks for multi irqs and cleanup.
- *	0.55: 22 Mar 2006: Add flow control (pause frame).
- *	0.56: 22 Mar 2006: Additional ethtool config and moduleparam support.
- *	0.57: 14 May 2006: Mac address set in probe/remove and order corrections.
- *	0.58: 30 Oct 2006: Added support for sideband management unit.
- *	0.59: 30 Oct 2006: Added support for recoverable error.
- *	0.60: 20 Jan 2007: Code optimizations for rings, rx & tx data paths, and stats.
+ ****************************************************************************
  *
  * Known bugs:
  * We suspect that on some hardware no TX done interrupts are generated.
@@ -122,7 +40,9 @@
  * DEV_NEED_TIMERIRQ from the driver_data flags.
  * DEV_NEED_TIMERIRQ will not harm you on sane hardware, only generating a few
  * superfluous timer interrupts from the nic.
+ *
  */
+
 #define FORCEDETH_VERSION		"1.00"
 #define DRV_NAME			"forcedeth"
 
@@ -893,6 +813,12 @@ static inline void pci_push(u8 __iomem *base)
 	readl(base);
 }
 
+static bool nv_optimized(struct fe_priv *np)
+{
+	return (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) ?
+		false : true;
+}
+
 static inline u32 nv_descr_getlength(struct ring_desc *prd, u32 v)
 {
 	return le32_to_cpu(prd->flaglen)
@@ -1342,18 +1268,28 @@ static void nv_start_rx(struct net_device *dev)
 	pci_push(base);
 }
 
-static void nv_stop_rx(struct net_device *dev)
+static void __nv_stop_rx(struct net_device *dev)
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 	u32 rx_ctrl = readl(base + NvRegReceiverControl);
 
-	dprintk(KERN_DEBUG "%s: nv_stop_rx\n", dev->name);
 	if (!np->mac_in_use)
 		rx_ctrl &= ~NVREG_RCVCTL_START;
 	else
 		rx_ctrl |= NVREG_RCVCTL_RX_PATH_EN;
 	writel(rx_ctrl, base + NvRegReceiverControl);
+}
+
+static void nv_stop_rx(struct net_device *dev)
+{
+	struct fe_priv *np = netdev_priv(dev);
+	u8 __iomem *base = get_hwbase(dev);
+
+	dprintk(KERN_DEBUG "%s: nv_stop_rx\n", dev->name);
+
+	__nv_stop_rx(dev);
+
 	reg_delay(dev, NvRegReceiverStatus, NVREG_RCVSTAT_BUSY, 0,
 			NV_RXSTOP_DELAY1, NV_RXSTOP_DELAY1MAX,
 			KERN_INFO "nv_stop_rx: ReceiverStatus remained busy");
@@ -1377,18 +1313,28 @@ static void nv_start_tx(struct net_device *dev)
 	pci_push(base);
 }
 
-static void nv_stop_tx(struct net_device *dev)
+static void __nv_stop_tx(struct net_device *dev)
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 	u32 tx_ctrl = readl(base + NvRegTransmitterControl);
 
-	dprintk(KERN_DEBUG "%s: nv_stop_tx\n", dev->name);
 	if (!np->mac_in_use)
 		tx_ctrl &= ~NVREG_XMITCTL_START;
 	else
 		tx_ctrl |= NVREG_XMITCTL_TX_PATH_EN;
 	writel(tx_ctrl, base + NvRegTransmitterControl);
+}
+
+static void nv_stop_tx(struct net_device *dev)
+{
+	struct fe_priv *np = netdev_priv(dev);
+	u8 __iomem *base = get_hwbase(dev);
+
+	dprintk(KERN_DEBUG "%s: nv_stop_tx\n", dev->name);
+
+	__nv_stop_tx(dev);
+
 	reg_delay(dev, NvRegTransmitterStatus, NVREG_XMITSTAT_BUSY, 0,
 			NV_TXSTOP_DELAY1, NV_TXSTOP_DELAY1MAX,
 			KERN_INFO "nv_stop_tx: TransmitterStatus remained busy");
@@ -1399,6 +1345,18 @@ static void nv_stop_tx(struct net_device *dev)
 		       base + NvRegTransmitPoll);
 }
 
+static void nv_stop_txrx(struct net_device *dev)
+{
+	nv_stop_rx(dev);
+	nv_stop_tx(dev);
+}
+
+static void nv_start_txrx(struct net_device *dev)
+{
+	nv_start_rx(dev);
+	nv_start_tx(dev);
+}
+
 static void nv_txrx_reset(struct net_device *dev)
 {
 	struct fe_priv *np = netdev_priv(dev);
@@ -1651,7 +1609,7 @@ static int nv_init_ring(struct net_device *dev)
 
 	nv_init_tx(dev);
 	nv_init_rx(dev);
-	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+	if (!nv_optimized(np))
 		return nv_alloc_rx(dev);
 	else
 		return nv_alloc_rx_optimized(dev);
@@ -1723,7 +1681,7 @@ static void nv_drain_rx(struct net_device *dev)
 	}
 }
 
-static void drain_ring(struct net_device *dev)
+static void nv_drain_txrx(struct net_device *dev)
 {
 	nv_drain_tx(dev);
 	nv_drain_rx(dev);
@@ -2158,7 +2116,7 @@ static void nv_tx_timeout(struct net_device *dev)
 	nv_stop_tx(dev);
 
 	/* 2) process all pending tx completions */
-	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+	if (!nv_optimized(np))
 		nv_tx_done(dev, np->tx_ring_size);
 	else
 		nv_tx_done_optimized(dev, np->tx_ring_size);
@@ -2514,12 +2472,10 @@ static int nv_change_mtu(struct net_device *dev, int new_mtu)
 		netif_tx_lock_bh(dev);
 		spin_lock(&np->lock);
 		/* stop engines */
-		nv_stop_rx(dev);
-		nv_stop_tx(dev);
+		nv_stop_txrx(dev);
 		nv_txrx_reset(dev);
 		/* drain rx queue */
-		nv_drain_rx(dev);
-		nv_drain_tx(dev);
+		nv_drain_txrx(dev);
 		/* reinit driver view of the rx queue */
 		set_bufsize(dev);
 		if (nv_init_ring(dev)) {
@@ -2536,8 +2492,7 @@ static int nv_change_mtu(struct net_device *dev, int new_mtu)
 		pci_push(base);
 
 		/* restart rx engine */
-		nv_start_rx(dev);
-		nv_start_tx(dev);
+		nv_start_txrx(dev);
 		spin_unlock(&np->lock);
 		netif_tx_unlock_bh(dev);
 		nv_enable_irq(dev);
@@ -3067,7 +3022,7 @@ static int nv_napi_tx_poll(struct napi_struct *napi, int budget)
 
 	spin_lock_irqsave(&np->lock, flags);
 
-	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+	if (!nv_optimized(np))
 		pkts = nv_tx_done(dev, budget);
 	else
 		pkts = nv_tx_done_optimized(dev, budget);
@@ -3096,7 +3051,7 @@ static int nv_napi_poll(struct napi_struct *napi, int budget)
 	unsigned long flags;
 	int pkts, retcode;
 
-	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+	if (!nv_optimized(np)) {
 		pkts = nv_rx_process(dev, budget);
 		retcode = nv_alloc_rx(dev);
 	} else {
@@ -3214,7 +3169,7 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 	if (intr_test) {
 		handler = nv_nic_irq_test;
 	} else {
-		if (np->desc_ver == DESC_VER_3)
+		if (nv_optimized(np))
 			handler = nv_nic_irq_optimized;
 		else
 			handler = nv_nic_irq;
@@ -3363,12 +3318,10 @@ static void nv_do_nic_poll(unsigned long data)
 			netif_tx_lock_bh(dev);
 			spin_lock(&np->lock);
 			/* stop engines */
-			nv_stop_rx(dev);
-			nv_stop_tx(dev);
+			nv_stop_txrx(dev);
 			nv_txrx_reset(dev);
 			/* drain rx queue */
-			nv_drain_rx(dev);
-			nv_drain_tx(dev);
+			nv_drain_txrx(dev);
 			/* reinit driver view of the rx queue */
 			set_bufsize(dev);
 			if (nv_init_ring(dev)) {
@@ -3385,8 +3338,7 @@ static void nv_do_nic_poll(unsigned long data)
 			pci_push(base);
 
 			/* restart rx engine */
-			nv_start_rx(dev);
-			nv_start_tx(dev);
+			nv_start_txrx(dev);
 			spin_unlock(&np->lock);
 			netif_tx_unlock_bh(dev);
 		}
@@ -3398,7 +3350,7 @@ static void nv_do_nic_poll(unsigned long data)
 	pci_push(base);
 
 	if (!using_multi_irqs(dev)) {
-		if (np->desc_ver == DESC_VER_3)
+		if (nv_optimized(np))
 			nv_nic_irq_optimized(0, dev);
 		else
 			nv_nic_irq(0, dev);
@@ -3425,7 +3377,12 @@ static void nv_do_nic_poll(unsigned long data)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void nv_poll_controller(struct net_device *dev)
 {
-	nv_do_nic_poll((unsigned long) dev);
+	struct fe_priv *np = netdev_priv(dev);
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__nv_nic_irq(dev, nv_optimized(np));
+	local_irq_restore(flags);
 }
 #endif
 
@@ -3595,8 +3552,7 @@ static int nv_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		netif_tx_lock_bh(dev);
 		spin_lock(&np->lock);
 		/* stop engines */
-		nv_stop_rx(dev);
-		nv_stop_tx(dev);
+		nv_stop_txrx(dev);
 		spin_unlock(&np->lock);
 		netif_tx_unlock_bh(dev);
 	}
@@ -3702,8 +3658,7 @@ static int nv_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	}
 
 	if (netif_running(dev)) {
-		nv_start_rx(dev);
-		nv_start_tx(dev);
+		nv_start_txrx(dev);
 		nv_enable_irq(dev);
 	}
 
@@ -3746,8 +3701,7 @@ static int nv_nway_reset(struct net_device *dev)
 			netif_tx_lock_bh(dev);
 			spin_lock(&np->lock);
 			/* stop engines */
-			nv_stop_rx(dev);
-			nv_stop_tx(dev);
+			nv_stop_txrx(dev);
 			spin_unlock(&np->lock);
 			netif_tx_unlock_bh(dev);
 			printk(KERN_INFO "%s: link down.\n", dev->name);
@@ -3767,8 +3721,7 @@ static int nv_nway_reset(struct net_device *dev)
 		}
 
 		if (netif_running(dev)) {
-			nv_start_rx(dev);
-			nv_start_tx(dev);
+			nv_start_txrx(dev);
 			nv_enable_irq(dev);
 		}
 		ret = 0;
@@ -3859,12 +3812,10 @@ static int nv_set_ringparam(struct net_device *dev, struct ethtool_ringparam* ri
 		netif_tx_lock_bh(dev);
 		spin_lock(&np->lock);
 		/* stop engines */
-		nv_stop_rx(dev);
-		nv_stop_tx(dev);
+		nv_stop_txrx(dev);
 		nv_txrx_reset(dev);
 		/* drain queues */
-		nv_drain_rx(dev);
-		nv_drain_tx(dev);
+		nv_drain_txrx(dev);
 		/* delete queues */
 		free_rings(dev);
 	}
@@ -3904,8 +3855,7 @@ static int nv_set_ringparam(struct net_device *dev, struct ethtool_ringparam* ri
 		pci_push(base);
 
 		/* restart engines */
-		nv_start_rx(dev);
-		nv_start_tx(dev);
+		nv_start_txrx(dev);
 		spin_unlock(&np->lock);
 		netif_tx_unlock_bh(dev);
 		nv_enable_irq(dev);
@@ -3946,8 +3896,7 @@ static int nv_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam*
 		netif_tx_lock_bh(dev);
 		spin_lock(&np->lock);
 		/* stop engines */
-		nv_stop_rx(dev);
-		nv_stop_tx(dev);
+		nv_stop_txrx(dev);
 		spin_unlock(&np->lock);
 		netif_tx_unlock_bh(dev);
 	}
@@ -3988,8 +3937,7 @@ static int nv_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam*
 	}
 
 	if (netif_running(dev)) {
-		nv_start_rx(dev);
-		nv_start_tx(dev);
+		nv_start_txrx(dev);
 		nv_enable_irq(dev);
 	}
 	return 0;
@@ -4225,8 +4173,7 @@ static int nv_loopback_test(struct net_device *dev)
 	pci_push(base);
 
 	/* restart rx engine */
-	nv_start_rx(dev);
-	nv_start_tx(dev);
+	nv_start_txrx(dev);
 
 	/* setup packet for tx */
 	pkt_len = ETH_DATA_LEN;
@@ -4304,12 +4251,10 @@ static int nv_loopback_test(struct net_device *dev)
 	dev_kfree_skb_any(tx_skb);
  out:
 	/* stop engines */
-	nv_stop_rx(dev);
-	nv_stop_tx(dev);
+	nv_stop_txrx(dev);
 	nv_txrx_reset(dev);
 	/* drain rx queue */
-	nv_drain_rx(dev);
-	nv_drain_tx(dev);
+	nv_drain_txrx(dev);
 
 	if (netif_running(dev)) {
 		writel(misc1_flags, base + NvRegMisc1);
@@ -4346,12 +4291,10 @@ static void nv_self_test(struct net_device *dev, struct ethtool_test *test, u64
 				writel(NVREG_IRQSTAT_MASK, base + NvRegMSIXIrqStatus);
 			}
 			/* stop engines */
-			nv_stop_rx(dev);
-			nv_stop_tx(dev);
+			nv_stop_txrx(dev);
 			nv_txrx_reset(dev);
 			/* drain rx queue */
-			nv_drain_rx(dev);
-			nv_drain_tx(dev);
+			nv_drain_txrx(dev);
 			spin_unlock_irq(&np->lock);
 			netif_tx_unlock_bh(dev);
 		}
@@ -4392,8 +4335,7 @@ static void nv_self_test(struct net_device *dev, struct ethtool_test *test, u64
 			writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
 			pci_push(base);
 			/* restart rx engine */
-			nv_start_rx(dev);
-			nv_start_tx(dev);
+			nv_start_txrx(dev);
 			napi_enable(&np->napi);
 			napi_enable(&np->tx_napi);
 			netif_start_queue(dev);
@@ -4621,8 +4563,7 @@ static int nv_open(struct net_device *dev)
 	 * to init hw */
 	np->linkspeed = 0;
 	ret = nv_update_linkspeed(dev);
-	nv_start_rx(dev);
-	nv_start_tx(dev);
+	nv_start_txrx(dev);
 	napi_enable(&np->napi);
 	napi_enable(&np->tx_napi);
 	netif_start_queue(dev);
@@ -4644,7 +4585,7 @@ static int nv_open(struct net_device *dev)
 
 	return 0;
 out_drain:
-	drain_ring(dev);
+	nv_drain_txrx(dev);
 	return ret;
 }
 
@@ -4666,8 +4607,7 @@ static int nv_close(struct net_device *dev)
 	del_timer_sync(&np->stats_poll);
 
 	spin_lock_irq(&np->lock);
-	nv_stop_tx(dev);
-	nv_stop_rx(dev);
+	nv_stop_txrx(dev);
 	nv_txrx_reset(dev);
 
 	/* disable interrupts on the nic or we will lock up */
@@ -4680,7 +4620,7 @@ static int nv_close(struct net_device *dev)
 
 	nv_free_irq(dev);
 
-	drain_ring(dev);
+	nv_drain_txrx(dev);
 
 	if (np->wolenabled) {
 		writel(NVREG_PFF_ALWAYS|NVREG_PFF_MYADDR, base + NvRegPacketFilterFlags);
@@ -4860,7 +4800,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 
 	dev->open = nv_open;
 	dev->stop = nv_close;
-	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+	if (!nv_optimized(np))
 		dev->hard_start_xmit = nv_start_xmit;
 	else
 		dev->hard_start_xmit = nv_start_xmit_optimized;

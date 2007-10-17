From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH 1/6] forcedeth: internal simplifications; changelog removal
Date: Wed, 17 Oct 2007 01:53:20 -0400
Message-ID: <20071017055320.GB20534@havoc.gtf.org>
References: <20071017055251.GA19972@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Ingo Molnar <mingo@elte.hu>, Ayaz Abdulla <aabdulla@nvidia.com>
To: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:49777 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752629AbXJQFxW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 01:53:22 -0400
Content-Disposition: inline
In-Reply-To: <20071017055251.GA19972@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


commit 0aeb1f867bc76029f599f73ac757a50f7641ccc5
Author: Jeff Garzik <jeff@garzik.org>
Date:   Tue Oct 16 01:40:30 2007 -0400

    [netdrvr] forcedeth: internal simplifications; changelog removal
    
    * remove changelog from source; its kept in git repository
    
    * consolidate descriptor version tests using nv_optimized()
    
    * consolidate NIC DMA start, stop and drain into
      nv_start_txrx(), nv_stop_txrx(), nv_drain_txrx()
    
    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

 drivers/net/forcedeth.c |  234 +++++++++++++++---------------------------------
 1 file changed, 74 insertions(+), 160 deletions(-)

0aeb1f867bc76029f599f73ac757a50f7641ccc5
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index cfbb7aa..2d518fc 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -29,90 +29,6 @@
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
- *
  * Known bugs:
  * We suspect that on some hardware no TX done interrupts are generated.
  * This means recovery from netif_stop_queue only happens if the hw timer
@@ -123,11 +39,6 @@
  * DEV_NEED_TIMERIRQ will not harm you on sane hardware, only generating a few
  * superfluous timer interrupts from the nic.
  */
-#ifdef CONFIG_FORCEDETH_NAPI
-#define DRIVERNAPI "-NAPI"
-#else
-#define DRIVERNAPI
-#endif
 #define FORCEDETH_VERSION		"0.61"
 #define DRV_NAME			"forcedeth"
 
@@ -908,6 +819,13 @@ static inline u32 nv_descr_getlength_ex(struct ring_desc_ex *prd, u32 v)
 	return le32_to_cpu(prd->flaglen) & LEN_MASK_V2;
 }
 
+static bool nv_optimized(struct fe_priv *np)
+{
+	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+		return false;
+	return true;
+}
+
 static int reg_delay(struct net_device *dev, int offset, u32 mask, u32 target,
 				int delay, int delaymax, const char *msg)
 {
@@ -934,7 +852,7 @@ static void setup_hw_rings(struct net_device *dev, int rxtx_flags)
 	struct fe_priv *np = get_nvpriv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 
-	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+	if (!nv_optimized(np)) {
 		if (rxtx_flags & NV_SETUP_RX_RING) {
 			writel((u32) cpu_to_le64(np->ring_addr), base + NvRegRxRingPhysAddr);
 		}
@@ -957,7 +875,7 @@ static void free_rings(struct net_device *dev)
 {
 	struct fe_priv *np = get_nvpriv(dev);
 
-	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+	if (!nv_optimized(np)) {
 		if (np->rx_ring.orig)
 			pci_free_consistent(np->pci_dev, sizeof(struct ring_desc) * (np->rx_ring_size + np->tx_ring_size),
 					    np->rx_ring.orig, np->ring_addr);
@@ -1403,6 +1321,18 @@ static void nv_stop_tx(struct net_device *dev)
 		       base + NvRegTransmitPoll);
 }
 
+static void nv_start_rxtx(struct net_device *dev)
+{
+	nv_start_rx(dev);
+	nv_start_tx(dev);
+}
+
+static void nv_stop_rxtx(struct net_device *dev)
+{
+	nv_stop_rx(dev);
+	nv_stop_tx(dev);
+}
+
 static void nv_txrx_reset(struct net_device *dev)
 {
 	struct fe_priv *np = netdev_priv(dev);
@@ -1611,7 +1541,7 @@ static void nv_do_rx_refill(unsigned long data)
 	} else {
 		disable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector);
 	}
-	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+	if (!nv_optimized(np))
 		retcode = nv_alloc_rx(dev);
 	else
 		retcode = nv_alloc_rx_optimized(dev);
@@ -1636,8 +1566,10 @@ static void nv_init_rx(struct net_device *dev)
 {
 	struct fe_priv *np = netdev_priv(dev);
 	int i;
+
 	np->get_rx = np->put_rx = np->first_rx = np->rx_ring;
-	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+
+	if (!nv_optimized(np))
 		np->last_rx.orig = &np->rx_ring.orig[np->rx_ring_size-1];
 	else
 		np->last_rx.ex = &np->rx_ring.ex[np->rx_ring_size-1];
@@ -1645,7 +1577,7 @@ static void nv_init_rx(struct net_device *dev)
 	np->last_rx_ctx = &np->rx_skb[np->rx_ring_size-1];
 
 	for (i = 0; i < np->rx_ring_size; i++) {
-		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+		if (!nv_optimized(np)) {
 			np->rx_ring.orig[i].flaglen = 0;
 			np->rx_ring.orig[i].buf = 0;
 		} else {
@@ -1663,8 +1595,10 @@ static void nv_init_tx(struct net_device *dev)
 {
 	struct fe_priv *np = netdev_priv(dev);
 	int i;
+
 	np->get_tx = np->put_tx = np->first_tx = np->tx_ring;
-	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+
+	if (!nv_optimized(np))
 		np->last_tx.orig = &np->tx_ring.orig[np->tx_ring_size-1];
 	else
 		np->last_tx.ex = &np->tx_ring.ex[np->tx_ring_size-1];
@@ -1672,7 +1606,7 @@ static void nv_init_tx(struct net_device *dev)
 	np->last_tx_ctx = &np->tx_skb[np->tx_ring_size-1];
 
 	for (i = 0; i < np->tx_ring_size; i++) {
-		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+		if (!nv_optimized(np)) {
 			np->tx_ring.orig[i].flaglen = 0;
 			np->tx_ring.orig[i].buf = 0;
 		} else {
@@ -1692,7 +1626,8 @@ static int nv_init_ring(struct net_device *dev)
 
 	nv_init_tx(dev);
 	nv_init_rx(dev);
-	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+
+	if (!nv_optimized(np))
 		return nv_alloc_rx(dev);
 	else
 		return nv_alloc_rx_optimized(dev);
@@ -1723,7 +1658,7 @@ static void nv_drain_tx(struct net_device *dev)
 	unsigned int i;
 
 	for (i = 0; i < np->tx_ring_size; i++) {
-		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+		if (!nv_optimized(np)) {
 			np->tx_ring.orig[i].flaglen = 0;
 			np->tx_ring.orig[i].buf = 0;
 		} else {
@@ -1743,7 +1678,7 @@ static void nv_drain_rx(struct net_device *dev)
 	int i;
 
 	for (i = 0; i < np->rx_ring_size; i++) {
-		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+		if (!nv_optimized(np)) {
 			np->rx_ring.orig[i].flaglen = 0;
 			np->rx_ring.orig[i].buf = 0;
 		} else {
@@ -1764,7 +1699,7 @@ static void nv_drain_rx(struct net_device *dev)
 	}
 }
 
-static void drain_ring(struct net_device *dev)
+static void nv_drain_rxtx(struct net_device *dev)
 {
 	nv_drain_tx(dev);
 	nv_drain_rx(dev);
@@ -2155,7 +2090,7 @@ static void nv_tx_timeout(struct net_device *dev)
 		}
 		printk(KERN_INFO "%s: Dumping tx ring\n", dev->name);
 		for (i=0;i<np->tx_ring_size;i+= 4) {
-			if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+			if (!nv_optimized(np)) {
 				printk(KERN_INFO "%03x: %08x %08x // %08x %08x // %08x %08x // %08x %08x\n",
 				       i,
 				       le32_to_cpu(np->tx_ring.orig[i].buf),
@@ -2191,7 +2126,7 @@ static void nv_tx_timeout(struct net_device *dev)
 	nv_stop_tx(dev);
 
 	/* 2) check that the packets were not sent already: */
-	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+	if (!nv_optimized(np))
 		nv_tx_done(dev);
 	else
 		nv_tx_done_optimized(dev, np->tx_ring_size);
@@ -2566,12 +2501,10 @@ static int nv_change_mtu(struct net_device *dev, int new_mtu)
 		netif_tx_lock_bh(dev);
 		spin_lock(&np->lock);
 		/* stop engines */
-		nv_stop_rx(dev);
-		nv_stop_tx(dev);
+		nv_stop_rxtx(dev);
 		nv_txrx_reset(dev);
 		/* drain rx queue */
-		nv_drain_rx(dev);
-		nv_drain_tx(dev);
+		nv_drain_rxtx(dev);
 		/* reinit driver view of the rx queue */
 		set_bufsize(dev);
 		if (nv_init_ring(dev)) {
@@ -2588,8 +2521,7 @@ static int nv_change_mtu(struct net_device *dev, int new_mtu)
 		pci_push(base);
 
 		/* restart rx engine */
-		nv_start_rx(dev);
-		nv_start_tx(dev);
+		nv_start_rxtx(dev);
 		spin_unlock(&np->lock);
 		netif_tx_unlock_bh(dev);
 		nv_enable_irq(dev);
@@ -3259,7 +3191,7 @@ static int nv_napi_poll(struct napi_struct *napi, int budget)
 	unsigned long flags;
 	int pkts, retcode;
 
-	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+	if (!nv_optimized(np)) {
 		pkts = nv_rx_process(dev, budget);
 		retcode = nv_alloc_rx(dev);
 	} else {
@@ -3500,7 +3432,7 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 	if (intr_test) {
 		handler = nv_nic_irq_test;
 	} else {
-		if (np->desc_ver == DESC_VER_3)
+		if (nv_optimized(np))
 			handler = nv_nic_irq_optimized;
 		else
 			handler = nv_nic_irq;
@@ -3649,12 +3581,10 @@ static void nv_do_nic_poll(unsigned long data)
 			netif_tx_lock_bh(dev);
 			spin_lock(&np->lock);
 			/* stop engines */
-			nv_stop_rx(dev);
-			nv_stop_tx(dev);
+			nv_stop_rxtx(dev);
 			nv_txrx_reset(dev);
 			/* drain rx queue */
-			nv_drain_rx(dev);
-			nv_drain_tx(dev);
+			nv_drain_rxtx(dev);
 			/* reinit driver view of the rx queue */
 			set_bufsize(dev);
 			if (nv_init_ring(dev)) {
@@ -3671,8 +3601,7 @@ static void nv_do_nic_poll(unsigned long data)
 			pci_push(base);
 
 			/* restart rx engine */
-			nv_start_rx(dev);
-			nv_start_tx(dev);
+			nv_start_rxtx(dev);
 			spin_unlock(&np->lock);
 			netif_tx_unlock_bh(dev);
 		}
@@ -3684,7 +3613,7 @@ static void nv_do_nic_poll(unsigned long data)
 	pci_push(base);
 
 	if (!using_multi_irqs(dev)) {
-		if (np->desc_ver == DESC_VER_3)
+		if (nv_optimized(np))
 			nv_nic_irq_optimized(0, dev);
 		else
 			nv_nic_irq(0, dev);
@@ -3881,8 +3810,7 @@ static int nv_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		netif_tx_lock_bh(dev);
 		spin_lock(&np->lock);
 		/* stop engines */
-		nv_stop_rx(dev);
-		nv_stop_tx(dev);
+		nv_stop_rxtx(dev);
 		spin_unlock(&np->lock);
 		netif_tx_unlock_bh(dev);
 	}
@@ -3988,8 +3916,7 @@ static int nv_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	}
 
 	if (netif_running(dev)) {
-		nv_start_rx(dev);
-		nv_start_tx(dev);
+		nv_start_rxtx(dev);
 		nv_enable_irq(dev);
 	}
 
@@ -4032,8 +3959,7 @@ static int nv_nway_reset(struct net_device *dev)
 			netif_tx_lock_bh(dev);
 			spin_lock(&np->lock);
 			/* stop engines */
-			nv_stop_rx(dev);
-			nv_stop_tx(dev);
+			nv_stop_rxtx(dev);
 			spin_unlock(&np->lock);
 			netif_tx_unlock_bh(dev);
 			printk(KERN_INFO "%s: link down.\n", dev->name);
@@ -4053,8 +3979,7 @@ static int nv_nway_reset(struct net_device *dev)
 		}
 
 		if (netif_running(dev)) {
-			nv_start_rx(dev);
-			nv_start_tx(dev);
+			nv_start_rxtx(dev);
 			nv_enable_irq(dev);
 		}
 		ret = 0;
@@ -4111,7 +4036,7 @@ static int nv_set_ringparam(struct net_device *dev, struct ethtool_ringparam* ri
 	}
 
 	/* allocate new rings */
-	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+	if (!nv_optimized(np)) {
 		rxtx_ring = pci_alloc_consistent(np->pci_dev,
 					    sizeof(struct ring_desc) * (ring->rx_pending + ring->tx_pending),
 					    &ring_addr);
@@ -4124,7 +4049,7 @@ static int nv_set_ringparam(struct net_device *dev, struct ethtool_ringparam* ri
 	tx_skbuff = kmalloc(sizeof(struct nv_skb_map) * ring->tx_pending, GFP_KERNEL);
 	if (!rxtx_ring || !rx_skbuff || !tx_skbuff) {
 		/* fall back to old rings */
-		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+		if (!nv_optimized(np)) {
 			if (rxtx_ring)
 				pci_free_consistent(np->pci_dev, sizeof(struct ring_desc) * (ring->rx_pending + ring->tx_pending),
 						    rxtx_ring, ring_addr);
@@ -4145,12 +4070,10 @@ static int nv_set_ringparam(struct net_device *dev, struct ethtool_ringparam* ri
 		netif_tx_lock_bh(dev);
 		spin_lock(&np->lock);
 		/* stop engines */
-		nv_stop_rx(dev);
-		nv_stop_tx(dev);
+		nv_stop_rxtx(dev);
 		nv_txrx_reset(dev);
 		/* drain queues */
-		nv_drain_rx(dev);
-		nv_drain_tx(dev);
+		nv_drain_rxtx(dev);
 		/* delete queues */
 		free_rings(dev);
 	}
@@ -4158,7 +4081,8 @@ static int nv_set_ringparam(struct net_device *dev, struct ethtool_ringparam* ri
 	/* set new values */
 	np->rx_ring_size = ring->rx_pending;
 	np->tx_ring_size = ring->tx_pending;
-	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+
+	if (!nv_optimized(np)) {
 		np->rx_ring.orig = (struct ring_desc*)rxtx_ring;
 		np->tx_ring.orig = &np->rx_ring.orig[np->rx_ring_size];
 	} else {
@@ -4190,8 +4114,7 @@ static int nv_set_ringparam(struct net_device *dev, struct ethtool_ringparam* ri
 		pci_push(base);
 
 		/* restart engines */
-		nv_start_rx(dev);
-		nv_start_tx(dev);
+		nv_start_rxtx(dev);
 		spin_unlock(&np->lock);
 		netif_tx_unlock_bh(dev);
 		nv_enable_irq(dev);
@@ -4232,8 +4155,7 @@ static int nv_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam*
 		netif_tx_lock_bh(dev);
 		spin_lock(&np->lock);
 		/* stop engines */
-		nv_stop_rx(dev);
-		nv_stop_tx(dev);
+		nv_stop_rxtx(dev);
 		spin_unlock(&np->lock);
 		netif_tx_unlock_bh(dev);
 	}
@@ -4274,8 +4196,7 @@ static int nv_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam*
 	}
 
 	if (netif_running(dev)) {
-		nv_start_rx(dev);
-		nv_start_tx(dev);
+		nv_start_rxtx(dev);
 		nv_enable_irq(dev);
 	}
 	return 0;
@@ -4511,8 +4432,7 @@ static int nv_loopback_test(struct net_device *dev)
 	pci_push(base);
 
 	/* restart rx engine */
-	nv_start_rx(dev);
-	nv_start_tx(dev);
+	nv_start_rxtx(dev);
 
 	/* setup packet for tx */
 	pkt_len = ETH_DATA_LEN;
@@ -4530,7 +4450,7 @@ static int nv_loopback_test(struct net_device *dev)
 	for (i = 0; i < pkt_len; i++)
 		pkt_data[i] = (u8)(i & 0xff);
 
-	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+	if (!nv_optimized(np)) {
 		np->tx_ring.orig[0].buf = cpu_to_le32(test_dma_addr);
 		np->tx_ring.orig[0].flaglen = cpu_to_le32((pkt_len-1) | np->tx_flags | tx_flags_extra);
 	} else {
@@ -4544,7 +4464,7 @@ static int nv_loopback_test(struct net_device *dev)
 	msleep(500);
 
 	/* check for rx of the packet */
-	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+	if (!nv_optimized(np)) {
 		flags = le32_to_cpu(np->rx_ring.orig[0].flaglen);
 		len = nv_descr_getlength(&np->rx_ring.orig[0], np->desc_ver);
 
@@ -4590,12 +4510,10 @@ static int nv_loopback_test(struct net_device *dev)
 	dev_kfree_skb_any(tx_skb);
  out:
 	/* stop engines */
-	nv_stop_rx(dev);
-	nv_stop_tx(dev);
+	nv_stop_rxtx(dev);
 	nv_txrx_reset(dev);
 	/* drain rx queue */
-	nv_drain_rx(dev);
-	nv_drain_tx(dev);
+	nv_drain_rxtx(dev);
 
 	if (netif_running(dev)) {
 		writel(misc1_flags, base + NvRegMisc1);
@@ -4633,12 +4551,10 @@ static void nv_self_test(struct net_device *dev, struct ethtool_test *test, u64
 				writel(NVREG_IRQSTAT_MASK, base + NvRegMSIXIrqStatus);
 			}
 			/* stop engines */
-			nv_stop_rx(dev);
-			nv_stop_tx(dev);
+			nv_stop_rxtx(dev);
 			nv_txrx_reset(dev);
 			/* drain rx queue */
-			nv_drain_rx(dev);
-			nv_drain_tx(dev);
+			nv_drain_rxtx(dev);
 			spin_unlock_irq(&np->lock);
 			netif_tx_unlock_bh(dev);
 		}
@@ -4679,8 +4595,7 @@ static void nv_self_test(struct net_device *dev, struct ethtool_test *test, u64
 			writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
 			pci_push(base);
 			/* restart rx engine */
-			nv_start_rx(dev);
-			nv_start_tx(dev);
+			nv_start_rxtx(dev);
 			netif_start_queue(dev);
 #ifdef CONFIG_FORCEDETH_NAPI
 			napi_enable(&np->napi);
@@ -4909,8 +4824,7 @@ static int nv_open(struct net_device *dev)
 	 * to init hw */
 	np->linkspeed = 0;
 	ret = nv_update_linkspeed(dev);
-	nv_start_rx(dev);
-	nv_start_tx(dev);
+	nv_start_rxtx(dev);
 	netif_start_queue(dev);
 #ifdef CONFIG_FORCEDETH_NAPI
 	napi_enable(&np->napi);
@@ -4933,7 +4847,7 @@ static int nv_open(struct net_device *dev)
 
 	return 0;
 out_drain:
-	drain_ring(dev);
+	nv_drain_rxtx(dev);
 	return ret;
 }
 
@@ -4956,8 +4870,7 @@ static int nv_close(struct net_device *dev)
 
 	netif_stop_queue(dev);
 	spin_lock_irq(&np->lock);
-	nv_stop_tx(dev);
-	nv_stop_rx(dev);
+	nv_stop_rxtx(dev);
 	nv_txrx_reset(dev);
 
 	/* disable interrupts on the nic or we will lock up */
@@ -4970,7 +4883,7 @@ static int nv_close(struct net_device *dev)
 
 	nv_free_irq(dev);
 
-	drain_ring(dev);
+	nv_drain_rxtx(dev);
 
 	if (np->wolenabled) {
 		writel(NVREG_PFF_ALWAYS|NVREG_PFF_MYADDR, base + NvRegPacketFilterFlags);
@@ -5128,7 +5041,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	np->rx_ring_size = RX_RING_DEFAULT;
 	np->tx_ring_size = TX_RING_DEFAULT;
 
-	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+	if (!nv_optimized(np)) {
 		np->rx_ring.orig = pci_alloc_consistent(pci_dev,
 					sizeof(struct ring_desc) * (np->rx_ring_size + np->tx_ring_size),
 					&np->ring_addr);
@@ -5150,7 +5063,8 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 
 	dev->open = nv_open;
 	dev->stop = nv_close;
-	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+
+	if (!nv_optimized(np))
 		dev->hard_start_xmit = nv_start_xmit;
 	else
 		dev->hard_start_xmit = nv_start_xmit_optimized;

From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Tue, 30 Jan 2007 09:46:24 -0500
Message-ID: <20070130144624.GA26643@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:42528 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965543AbXA3Oq0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jan 2007 09:46:26 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/82596.c           |    7 +++--
 drivers/net/b44.c             |   52 ++++++++++++++++++++++++++--------------
 drivers/net/bonding/bonding.h |    7 +++--
 drivers/net/e100.c            |    2 +
 drivers/net/ehea/ehea.h       |    2 +-
 drivers/net/ehea/ehea_main.c  |   31 +++++++++++++++++++-----
 drivers/net/fs_enet/mac-fec.c |   13 +++++++---
 drivers/net/fs_enet/mac-scc.c |    6 +++-
 drivers/net/ifb.c             |    3 +-
 drivers/net/phy/fixed.c       |    2 +-
 10 files changed, 84 insertions(+), 41 deletions(-)

Al Viro (1):
      b44: src_desc->addr is little-endian

Andrew Morton (1):
      82596 warning fixes

Andy Gospodarek (1):
      bonding: ARP monitoring broken on x86_64

Auke Kok (1):
      e100: fix irq leak on suspend/resume

Dmitriy Monakhov (1):
      Broadcom 4400 resume small fix

Mariusz Kozlowski (1):
      net: ifb error path loop fix

Michael Chan (1):
      b44: Fix frequent link changes

Thomas Klein (2):
      ehea: Fixed wrong jumbo frames status query
      ehea: Fixed missing tasklet_kill() call

Vitaly Bordug (1):
      FS_ENET: OF-related fixup for FEC and SCC MAC's

diff --git a/drivers/net/82596.c b/drivers/net/82596.c
index 8236f26..640d7ca 100644
--- a/drivers/net/82596.c
+++ b/drivers/net/82596.c
@@ -1066,8 +1066,8 @@ static int i596_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	short length = skb->len;
 	dev->trans_start = jiffies;
 
-	DEB(DEB_STARTTX,printk(KERN_DEBUG "%s: i596_start_xmit(%x,%x) called\n", dev->name,
-				skb->len, (unsigned int)skb->data));
+	DEB(DEB_STARTTX,printk(KERN_DEBUG "%s: i596_start_xmit(%x,%p) called\n",
+				dev->name, skb->len, skb->data));
 
 	if (skb->len < ETH_ZLEN) {
 		if (skb_padto(skb, ETH_ZLEN))
@@ -1246,7 +1246,8 @@ struct net_device * __init i82596_probe(int unit)
 	dev->priv = (void *)(dev->mem_start);
 
 	lp = dev->priv;
-	DEB(DEB_INIT,printk(KERN_DEBUG "%s: lp at 0x%08lx (%d bytes), lp->scb at 0x%08lx\n",
+	DEB(DEB_INIT,printk(KERN_DEBUG "%s: lp at 0x%08lx (%zd bytes), "
+			"lp->scb at 0x%08lx\n",
 			dev->name, (unsigned long)lp,
 			sizeof(struct i596_private), (unsigned long)&lp->scb));
 	memset((void *) lp, 0, sizeof(struct i596_private));
diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 5eb2ec6..303a8d9 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -110,6 +110,11 @@ MODULE_DEVICE_TABLE(pci, b44_pci_tbl);
 
 static void b44_halt(struct b44 *);
 static void b44_init_rings(struct b44 *);
+
+#define B44_FULL_RESET		1
+#define B44_FULL_RESET_SKIP_PHY	2
+#define B44_PARTIAL_RESET	3
+
 static void b44_init_hw(struct b44 *, int);
 
 static int dma_desc_align_mask;
@@ -752,7 +757,7 @@ static void b44_recycle_rx(struct b44 *bp, int src_idx, u32 dest_idx_unmasked)
 		                             dest_idx * sizeof(dest_desc),
 		                             DMA_BIDIRECTIONAL);
 
-	pci_dma_sync_single_for_device(bp->pdev, src_desc->addr,
+	pci_dma_sync_single_for_device(bp->pdev, le32_to_cpu(src_desc->addr),
 				       RX_PKT_BUF_SZ,
 				       PCI_DMA_FROMDEVICE);
 }
@@ -884,7 +889,7 @@ static int b44_poll(struct net_device *netdev, int *budget)
 		spin_lock_irqsave(&bp->lock, flags);
 		b44_halt(bp);
 		b44_init_rings(bp);
-		b44_init_hw(bp, 1);
+		b44_init_hw(bp, B44_FULL_RESET_SKIP_PHY);
 		netif_wake_queue(bp->dev);
 		spin_unlock_irqrestore(&bp->lock, flags);
 		done = 1;
@@ -954,7 +959,7 @@ static void b44_tx_timeout(struct net_device *dev)
 
 	b44_halt(bp);
 	b44_init_rings(bp);
-	b44_init_hw(bp, 1);
+	b44_init_hw(bp, B44_FULL_RESET);
 
 	spin_unlock_irq(&bp->lock);
 
@@ -1071,7 +1076,7 @@ static int b44_change_mtu(struct net_device *dev, int new_mtu)
 	b44_halt(bp);
 	dev->mtu = new_mtu;
 	b44_init_rings(bp);
-	b44_init_hw(bp, 1);
+	b44_init_hw(bp, B44_FULL_RESET);
 	spin_unlock_irq(&bp->lock);
 
 	b44_enable_ints(bp);
@@ -1368,12 +1373,12 @@ static int b44_set_mac_addr(struct net_device *dev, void *p)
  * packet processing.  Invoked with bp->lock held.
  */
 static void __b44_set_rx_mode(struct net_device *);
-static void b44_init_hw(struct b44 *bp, int full_reset)
+static void b44_init_hw(struct b44 *bp, int reset_kind)
 {
 	u32 val;
 
 	b44_chip_reset(bp);
-	if (full_reset) {
+	if (reset_kind == B44_FULL_RESET) {
 		b44_phy_reset(bp);
 		b44_setup_phy(bp);
 	}
@@ -1390,7 +1395,10 @@ static void b44_init_hw(struct b44 *bp, int full_reset)
 	bw32(bp, B44_TXMAXLEN, bp->dev->mtu + ETH_HLEN + 8 + RX_HEADER_LEN);
 
 	bw32(bp, B44_TX_WMARK, 56); /* XXX magic */
-	if (full_reset) {
+	if (reset_kind == B44_PARTIAL_RESET) {
+		bw32(bp, B44_DMARX_CTRL, (DMARX_CTRL_ENABLE |
+				      (bp->rx_offset << DMARX_CTRL_ROSHIFT)));
+	} else {
 		bw32(bp, B44_DMATX_CTRL, DMATX_CTRL_ENABLE);
 		bw32(bp, B44_DMATX_ADDR, bp->tx_ring_dma + bp->dma_offset);
 		bw32(bp, B44_DMARX_CTRL, (DMARX_CTRL_ENABLE |
@@ -1401,9 +1409,6 @@ static void b44_init_hw(struct b44 *bp, int full_reset)
 		bp->rx_prod = bp->rx_pending;
 
 		bw32(bp, B44_MIB_CTRL, MIB_CTRL_CLR_ON_READ);
-	} else {
-		bw32(bp, B44_DMARX_CTRL, (DMARX_CTRL_ENABLE |
-				      (bp->rx_offset << DMARX_CTRL_ROSHIFT)));
 	}
 
 	val = br32(bp, B44_ENET_CTRL);
@@ -1420,7 +1425,7 @@ static int b44_open(struct net_device *dev)
 		goto out;
 
 	b44_init_rings(bp);
-	b44_init_hw(bp, 1);
+	b44_init_hw(bp, B44_FULL_RESET);
 
 	b44_check_phy(bp);
 
@@ -1629,7 +1634,7 @@ static int b44_close(struct net_device *dev)
 	netif_poll_enable(dev);
 
 	if (bp->flags & B44_FLAG_WOL_ENABLE) {
-		b44_init_hw(bp, 0);
+		b44_init_hw(bp, B44_PARTIAL_RESET);
 		b44_setup_wol(bp);
 	}
 
@@ -1905,7 +1910,7 @@ static int b44_set_ringparam(struct net_device *dev,
 
 	b44_halt(bp);
 	b44_init_rings(bp);
-	b44_init_hw(bp, 1);
+	b44_init_hw(bp, B44_FULL_RESET);
 	netif_wake_queue(bp->dev);
 	spin_unlock_irq(&bp->lock);
 
@@ -1948,7 +1953,7 @@ static int b44_set_pauseparam(struct net_device *dev,
 	if (bp->flags & B44_FLAG_PAUSE_AUTO) {
 		b44_halt(bp);
 		b44_init_rings(bp);
-		b44_init_hw(bp, 1);
+		b44_init_hw(bp, B44_FULL_RESET);
 	} else {
 		__b44_set_flow_ctrl(bp, bp->flags);
 	}
@@ -2304,7 +2309,7 @@ static int b44_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	free_irq(dev->irq, dev);
 	if (bp->flags & B44_FLAG_WOL_ENABLE) {
-		b44_init_hw(bp, 0);
+		b44_init_hw(bp, B44_PARTIAL_RESET);
 		b44_setup_wol(bp);
 	}
 	pci_disable_device(pdev);
@@ -2315,21 +2320,32 @@ static int b44_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct b44 *bp = netdev_priv(dev);
+	int rc = 0;
 
 	pci_restore_state(pdev);
-	pci_enable_device(pdev);
+	rc = pci_enable_device(pdev);
+	if (rc) {
+		printk(KERN_ERR PFX "%s: pci_enable_device failed\n",
+			dev->name);
+		return rc;
+	}
+
 	pci_set_master(pdev);
 
 	if (!netif_running(dev))
 		return 0;
 
-	if (request_irq(dev->irq, b44_interrupt, IRQF_SHARED, dev->name, dev))
+	rc = request_irq(dev->irq, b44_interrupt, IRQF_SHARED, dev->name, dev);
+	if (rc) {
 		printk(KERN_ERR PFX "%s: request_irq failed\n", dev->name);
+		pci_disable_device(pdev);
+		return rc;
+	}
 
 	spin_lock_irq(&bp->lock);
 
 	b44_init_rings(bp);
-	b44_init_hw(bp, 1);
+	b44_init_hw(bp, B44_FULL_RESET);
 	netif_device_attach(bp->dev);
 	spin_unlock_irq(&bp->lock);
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index dc434fb..0978c9a 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -151,8 +151,8 @@ struct slave {
 	struct slave *next;
 	struct slave *prev;
 	int    delay;
-	u32    jiffies;
-	u32    last_arp_rx;
+	unsigned long jiffies;
+	unsigned long last_arp_rx;
 	s8     link;    /* one of BOND_LINK_XXXX */
 	s8     state;   /* one of BOND_STATE_XXXX */
 	u32    original_flags;
@@ -242,7 +242,8 @@ extern inline int slave_do_arp_validate(struct bonding *bond, struct slave *slav
 	return bond->params.arp_validate & (1 << slave->state);
 }
 
-extern inline u32 slave_last_rx(struct bonding *bond, struct slave *slave)
+extern inline unsigned long slave_last_rx(struct bonding *bond,
+					struct slave *slave)
 {
 	if (slave_do_arp_validate(bond, slave))
 		return slave->last_arp_rx;
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index c2ae2a2..3208dac 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2725,6 +2725,7 @@ static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
 	del_timer_sync(&nic->watchdog);
 	netif_carrier_off(nic->netdev);
 
+	netif_device_detach(netdev);
 	pci_save_state(pdev);
 
 	if ((nic->flags & wol_magic) | e100_asf(nic)) {
@@ -2736,6 +2737,7 @@ static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
 	}
 
 	pci_disable_device(pdev);
+	free_irq(pdev->irq, netdev);
 	pci_set_power_state(pdev, PCI_D3hot);
 
 	return 0;
diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index be10a3a..272e1ec 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -39,7 +39,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0044"
+#define DRV_VERSION	"EHEA_0045"
 
 #define EHEA_MSG_DEFAULT (NETIF_MSG_LINK | NETIF_MSG_TIMER \
 	| NETIF_MSG_RX_ERR | NETIF_MSG_TX_ERR)
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 1072e69..9de2d38 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -2316,6 +2316,7 @@ static int ehea_setup_single_port(struct ehea_port *port,
 	struct ehea_adapter *adapter = port->adapter;
 	struct hcp_ehea_port_cb4 *cb4;
 	u32 *dn_log_port_id;
+	int jumbo = 0;
 
 	sema_init(&port->port_lock, 1);
 	port->state = EHEA_PORT_DOWN;
@@ -2357,13 +2358,25 @@ static int ehea_setup_single_port(struct ehea_port *port,
 	if (!cb4) {
 		ehea_error("no mem for cb4");
 	} else {
-		cb4->jumbo_frame = 1;
-		hret = ehea_h_modify_ehea_port(adapter->handle,
-					       port->logical_port_id,
-					       H_PORT_CB4, H_PORT_CB4_JUMBO,
-					       cb4);
-		if (hret != H_SUCCESS) {
-			ehea_info("Jumbo frames not activated");
+		hret = ehea_h_query_ehea_port(adapter->handle,
+					      port->logical_port_id,
+					      H_PORT_CB4,
+					      H_PORT_CB4_JUMBO, cb4);
+
+		if (hret == H_SUCCESS) {
+			if (cb4->jumbo_frame)
+				jumbo = 1;
+			else {
+				cb4->jumbo_frame = 1;
+				hret = ehea_h_modify_ehea_port(adapter->handle,
+							       port->
+							        logical_port_id,
+							       H_PORT_CB4,
+							       H_PORT_CB4_JUMBO,
+							       cb4);
+				if (hret == H_SUCCESS)
+					jumbo = 1;
+			}
 		}
 		kfree(cb4);
 	}
@@ -2402,6 +2415,9 @@ static int ehea_setup_single_port(struct ehea_port *port,
 		goto out_free;
 	}
 
+	ehea_info("%s: Jumbo frames are %sabled", dev->name,
+		  jumbo == 1 ? "en" : "dis");
+
 	port->netdev = dev;
 	ret = 0;
 	goto out;
@@ -2582,6 +2598,7 @@ static int __devexit ehea_remove(struct ibmebus_dev *dev)
 	destroy_workqueue(adapter->ehea_wq);
 
 	ibmebus_free_irq(NULL, adapter->neq->attr.ist1, adapter);
+	tasklet_kill(&adapter->neq_tasklet);
 
 	ehea_destroy_eq(adapter->neq);
 
diff --git a/drivers/net/fs_enet/mac-fec.c b/drivers/net/fs_enet/mac-fec.c
index c2c5fd4..ff68394 100644
--- a/drivers/net/fs_enet/mac-fec.c
+++ b/drivers/net/fs_enet/mac-fec.c
@@ -104,9 +104,9 @@ static int do_pd_setup(struct fs_enet_private *fep)
 	fep->interrupt = platform_get_irq_byname(pdev,"interrupt");
 	if (fep->interrupt < 0)
 		return -EINVAL;
-	
+
 	r = platform_get_resource_byname(pdev, IORESOURCE_MEM, "regs");
-	fep->fec.fecp =(void*)r->start;
+	fep->fec.fecp = ioremap(r->start, r->end - r->start + 1);
 
 	if(fep->fec.fecp == NULL)
 		return -EINVAL;
@@ -319,11 +319,14 @@ static void restart(struct net_device *dev)
 	 * Clear any outstanding interrupt.
 	 */
 	FW(fecp, ievent, 0xffc0);
+#ifndef CONFIG_PPC_MERGE
 	FW(fecp, ivec, (fep->interrupt / 2) << 29);
-	
+#else
+	FW(fecp, ivec, (virq_to_hw(fep->interrupt) / 2) << 29);
+#endif
 
 	/*
-	 * adjust to speed (only for DUET & RMII) 
+	 * adjust to speed (only for DUET & RMII)
 	 */
 #ifdef CONFIG_DUET
 	if (fpi->use_rmii) {
@@ -418,6 +421,7 @@ static void stop(struct net_device *dev)
 
 static void pre_request_irq(struct net_device *dev, int irq)
 {
+#ifndef CONFIG_PPC_MERGE
 	immap_t *immap = fs_enet_immap;
 	u32 siel;
 
@@ -431,6 +435,7 @@ static void pre_request_irq(struct net_device *dev, int irq)
 			siel &= ~(0x80000000 >> (irq & ~1));
 		out_be32(&immap->im_siu_conf.sc_siel, siel);
 	}
+#endif
 }
 
 static void post_free_irq(struct net_device *dev, int irq)
diff --git a/drivers/net/fs_enet/mac-scc.c b/drivers/net/fs_enet/mac-scc.c
index 95ec587..afd7fca 100644
--- a/drivers/net/fs_enet/mac-scc.c
+++ b/drivers/net/fs_enet/mac-scc.c
@@ -121,13 +121,13 @@ static int do_pd_setup(struct fs_enet_private *fep)
 		return -EINVAL;
 
 	r = platform_get_resource_byname(pdev, IORESOURCE_MEM, "regs");
-	fep->scc.sccp = (void *)r->start;
+	fep->scc.sccp = ioremap(r->start, r->end - r->start + 1);
 
 	if (fep->scc.sccp == NULL)
 		return -EINVAL;
 
 	r = platform_get_resource_byname(pdev, IORESOURCE_MEM, "pram");
-	fep->scc.ep = (void *)r->start;
+	fep->scc.ep = ioremap(r->start, r->end - r->start + 1);
 
 	if (fep->scc.ep == NULL)
 		return -EINVAL;
@@ -397,6 +397,7 @@ static void stop(struct net_device *dev)
 
 static void pre_request_irq(struct net_device *dev, int irq)
 {
+#ifndef CONFIG_PPC_MERGE
 	immap_t *immap = fs_enet_immap;
 	u32 siel;
 
@@ -410,6 +411,7 @@ static void pre_request_irq(struct net_device *dev, int irq)
 			siel &= ~(0x80000000 >> (irq & ~1));
 		out_be32(&immap->im_siu_conf.sc_siel, siel);
 	}
+#endif
 }
 
 static void post_free_irq(struct net_device *dev, int irq)
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index ca2b21f..c4ca7c9 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -271,8 +271,7 @@ static int __init ifb_init_module(void)
 	for (i = 0; i < numifbs && !err; i++)
 		err = ifb_init_one(i);
 	if (err) {
-		i--;
-		while (--i >= 0)
+		while (i--)
 			ifb_free_one(i);
 	}
 
diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
index 096d4a1..8613539 100644
--- a/drivers/net/phy/fixed.c
+++ b/drivers/net/phy/fixed.c
@@ -349,7 +349,7 @@ static int __init fixed_init(void)
 	fixed_mdio_register_device(0, 100, 1);
 #endif
 
-#ifdef CONFIX_FIXED_MII_10_FDX
+#ifdef CONFIG_FIXED_MII_10_FDX
 	fixed_mdio_register_device(0, 10, 1);
 #endif
 	return 0;

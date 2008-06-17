From: John Rigby <jrigby@freescale.com>
Subject: [PATCH 1/2] fs_enet: fix checkpatch.pl problems
Date: Tue, 17 Jun 2008 17:03:13 -0600
Message-ID: <1213743794-3537-2-git-send-email-jrigby@freescale.com>
References: <1213743794-3537-1-git-send-email-jrigby@freescale.com>
Cc: netdev@vger.kernel.org
To: Scott Wood <scottwood@freescale.com>, linuxppc-dev@ozlabs.org,
	jeff@garzik.org, Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:49644 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760908AbYFQXDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 19:03:43 -0400
In-Reply-To: <1213743794-3537-1-git-send-email-jrigby@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed all errors and warnings that checkpatch.pl
reports if this was a new submission.
Also changed instances of fec_t to struct fec in
mac-fec.c and mii-fec.c.

This is in preparation of adding MPC5121 support.

Signed-off-by: John Rigby <jrigby@freescale.com>
---
 drivers/net/fs_enet/fs_enet-main.c |   70 ++++++++++++++++++++---------------
 drivers/net/fs_enet/fs_enet.h      |   15 +++++---
 drivers/net/fs_enet/mac-fcc.c      |    7 ++--
 drivers/net/fs_enet/mac-fec.c      |   40 ++++++++++----------
 drivers/net/fs_enet/mac-scc.c      |   13 ++++---
 drivers/net/fs_enet/mii-bitbang.c  |    4 +-
 drivers/net/fs_enet/mii-fec.c      |   23 +++++++-----
 7 files changed, 95 insertions(+), 77 deletions(-)

diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index a9f9aae..8ebf388 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -41,7 +41,7 @@
 #include <linux/vmalloc.h>
 #include <asm/pgtable.h>
 #include <asm/irq.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 
 
 #include "fs_enet.h"
@@ -80,7 +80,8 @@ static void skb_align(struct sk_buff *skb, int align)
 /* NAPI receive function */
 static int fs_enet_rx_napi(struct napi_struct *napi, int budget)
 {
-	struct fs_enet_private *fep = container_of(napi, struct fs_enet_private, napi);
+	struct fs_enet_private *fep =
+		container_of(napi, struct fs_enet_private, napi);
 	struct net_device *dev = fep->ndev;
 	const struct fs_platform_info *fpi = fep->fpi;
 	cbd_t __iomem *bdp;
@@ -155,7 +156,8 @@ static int fs_enet_rx_napi(struct napi_struct *napi, int budget)
 				/* +2 to make IP header L1 cache aligned */
 				skbn = dev_alloc_skb(pkt_len + 2);
 				if (skbn != NULL) {
-					skb_reserve(skbn, 2);	/* align IP header */
+					/* align IP header */
+					skb_reserve(skbn, 2);
 					skb_copy_from_linear_data(skb,
 						      skbn->data, pkt_len);
 					/* swap */
@@ -177,7 +179,8 @@ static int fs_enet_rx_napi(struct napi_struct *napi, int budget)
 				netif_receive_skb(skb);
 			} else {
 				printk(KERN_WARNING DRV_MODULE_NAME
-				       ": %s Memory squeeze, dropping packet.\n",
+				       ": %s Memory squeeze, "
+				       "dropping packet.\n",
 				       dev->name);
 				fep->stats.rx_dropped++;
 				skbn = skb;
@@ -290,7 +293,8 @@ static int fs_enet_rx_non_napi(struct net_device *dev)
 				/* +2 to make IP header L1 cache aligned */
 				skbn = dev_alloc_skb(pkt_len + 2);
 				if (skbn != NULL) {
-					skb_reserve(skbn, 2);	/* align IP header */
+					/* align IP header */
+					skb_reserve(skbn, 2);
 					skb_copy_from_linear_data(skb,
 						      skbn->data, pkt_len);
 					/* swap */
@@ -312,7 +316,8 @@ static int fs_enet_rx_non_napi(struct net_device *dev)
 				netif_rx(skb);
 			} else {
 				printk(KERN_WARNING DRV_MODULE_NAME
-				       ": %s Memory squeeze, dropping packet.\n",
+				       ": %s Memory squeeze, "
+				       "dropping packet.\n",
 				       dev->name);
 				fep->stats.rx_dropped++;
 				skbn = skb;
@@ -379,7 +384,8 @@ static void fs_enet_tx(struct net_device *dev)
 			if (sc & BD_ENET_TX_CSL)	/* Carrier lost */
 				fep->stats.tx_carrier_errors++;
 
-			if (sc & (BD_ENET_TX_LC | BD_ENET_TX_RL | BD_ENET_TX_UN)) {
+			if (sc & (BD_ENET_TX_LC | BD_ENET_TX_RL
+				    | BD_ENET_TX_UN)) {
 				fep->stats.tx_errors++;
 				do_restart = 1;
 			}
@@ -473,10 +479,14 @@ fs_enet_interrupt(int irq, void *dev_id)
 				napi_ok = napi_schedule_prep(&fep->napi);
 
 				(*fep->ops->napi_disable_rx)(dev);
-				(*fep->ops->clear_int_events)(dev, fep->ev_napi_rx);
-
-				/* NOTE: it is possible for FCCs in NAPI mode    */
-				/* to submit a spurious interrupt while in poll  */
+				(*fep->ops->clear_int_events)(dev,
+						    fep->ev_napi_rx);
+
+				/*
+				 * NOTE: It is possible for FCCs
+				 * in NAPI mode to submit a spurious
+				 * interrupt while in poll
+				 */
 				if (napi_ok)
 					__netif_rx_schedule(dev, &fep->napi);
 			}
@@ -554,7 +564,8 @@ void fs_cleanup_bds(struct net_device *dev)
 	 * Reset SKB transmit buffers.
 	 */
 	for (i = 0, bdp = fep->tx_bd_base; i < fep->tx_ring; i++, bdp++) {
-		if ((skb = fep->tx_skbuff[i]) == NULL)
+		skb = fep->tx_skbuff[i];
+		if (!skb)
 			continue;
 
 		/* unmap */
@@ -569,7 +580,8 @@ void fs_cleanup_bds(struct net_device *dev)
 	 * Reset SKB receive buffers
 	 */
 	for (i = 0, bdp = fep->rx_bd_base; i < fep->rx_ring; i++, bdp++) {
-		if ((skb = fep->rx_skbuff[i]) == NULL)
+		skb = fep->rx_skbuff[i];
+		if (!skb)
 			continue;
 
 		/* unmap */
@@ -583,7 +595,7 @@ void fs_cleanup_bds(struct net_device *dev)
 	}
 }
 
-/**********************************************************************************/
+/*******************************************************************************/
 
 static int fs_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
@@ -708,7 +720,7 @@ static void fs_timeout(struct net_device *dev)
 
 /*-----------------------------------------------------------------------------
  *  generic link-change handler - should be sufficient for most cases
- *-----------------------------------------------------------------------------*/
+ *---------------------------------------------------------------------------*/
 static void generic_adjust_link(struct  net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
@@ -758,7 +770,7 @@ static void fs_adjust_link(struct net_device *dev)
 
 	spin_lock_irqsave(&fep->lock, flags);
 
-	if(fep->ops->adjust_link)
+	if (fep->ops->adjust_link)
 		fep->ops->adjust_link(dev);
 	else
 		generic_adjust_link(dev);
@@ -774,7 +786,7 @@ static int fs_init_phy(struct net_device *dev)
 	fep->oldlink = 0;
 	fep->oldspeed = 0;
 	fep->oldduplex = -1;
-	if(fep->fpi->bus_id)
+	if (fep->fpi->bus_id)
 		phydev = phy_connect(dev, fep->fpi->bus_id, &fs_adjust_link, 0,
 				PHY_INTERFACE_MODE_MII);
 	else {
@@ -801,7 +813,8 @@ static int fs_enet_open(struct net_device *dev)
 		napi_enable(&fep->napi);
 
 	/* Install our interrupt handler. */
-	r = fs_request_irq(dev, fep->interrupt, "fs_enet-mac", fs_enet_interrupt);
+	r = fs_request_irq(dev, fep->interrupt, "fs_enet-mac",
+		    fs_enet_interrupt);
 	if (r != 0) {
 		printk(KERN_ERR DRV_MODULE_NAME
 		       ": %s Could not allocate FS_ENET IRQ!", dev->name);
@@ -947,13 +960,10 @@ static int fs_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	return phy_mii_ioctl(fep->phydev, mii, cmd);
 }
 
-extern int fs_mii_connect(struct net_device *dev);
-extern void fs_mii_disconnect(struct net_device *dev);
-
-/**************************************************************************************/
+/******************************************************************************/
 
 /* handy pointer to the immap */
-void __iomem *fs_enet_immap = NULL;
+void __iomem *fs_enet_immap;
 
 static int setup_immap(void)
 {
@@ -974,10 +984,10 @@ static void cleanup_immap(void)
 #endif
 }
 
-/**************************************************************************************/
+/******************************************************************************/
 
 static int __devinit find_phy(struct device_node *np,
-                              struct fs_platform_info *fpi)
+			      struct fs_platform_info *fpi)
 {
 	struct device_node *phynode, *mdionode;
 	struct resource res;
@@ -1026,7 +1036,7 @@ out_put_phy:
 #endif
 
 static int __devinit fs_enet_probe(struct of_device *ofdev,
-                                   const struct of_device_id *match)
+				   const struct of_device_id *match)
 {
 	struct net_device *ndev;
 	struct fs_enet_private *fep;
@@ -1058,8 +1068,8 @@ static int __devinit fs_enet_probe(struct of_device *ofdev,
 		goto out_free_fpi;
 
 	privsize = sizeof(*fep) +
-	           sizeof(struct sk_buff **) *
-	           (fpi->rx_ring + fpi->tx_ring);
+		   sizeof(struct sk_buff **) *
+		   (fpi->rx_ring + fpi->tx_ring);
 
 	ndev = alloc_etherdev(privsize);
 	if (!ndev) {
@@ -1109,7 +1119,7 @@ static int __devinit fs_enet_probe(struct of_device *ofdev,
 
 	if (fpi->use_napi)
 		netif_napi_add(ndev, &fep->napi, fs_enet_rx_napi,
-		               fpi->napi_weight);
+			       fpi->napi_weight);
 
 	ndev->ethtool_ops = &fs_ethtool_ops;
 	ndev->do_ioctl = fs_ioctl;
@@ -1217,7 +1227,7 @@ static void fs_enet_netpoll(struct net_device *dev)
 }
 #endif
 
-/**************************************************************************************/
+/******************************************************************************/
 
 module_init(fs_init);
 module_exit(fs_cleanup);
diff --git a/drivers/net/fs_enet/fs_enet.h b/drivers/net/fs_enet/fs_enet.h
index db46d2e..7bf779a 100644
--- a/drivers/net/fs_enet/fs_enet.h
+++ b/drivers/net/fs_enet/fs_enet.h
@@ -52,9 +52,9 @@ struct fs_ops {
 struct phy_info {
 	unsigned int id;
 	const char *name;
-	void (*startup) (struct net_device * dev);
-	void (*shutdown) (struct net_device * dev);
-	void (*ack_int) (struct net_device * dev);
+	void (*startup) (struct net_device *dev);
+	void (*shutdown) (struct net_device *dev);
+	void (*ack_int) (struct net_device *dev);
 };
 
 /* The FEC stores dest/src/type, data, and checksum for receive packets.
@@ -74,7 +74,8 @@ struct phy_info {
 
 struct fs_enet_private {
 	struct napi_struct napi;
-	struct device *dev;	/* pointer back to the device (must be initialized first) */
+	struct device *dev;	/* pointer back to the device
+				   (must be initialized first) */
 	struct net_device *ndev;
 	spinlock_t lock;	/* during all ops except TX pckt processing */
 	spinlock_t tx_lock;	/* during fs_start_xmit and fs_tx         */
@@ -174,8 +175,10 @@ void fs_enet_platform_cleanup(void);
 
 /* write */
 #define CBDW_SC(_cbd, _sc) 		__cbd_out16(&(_cbd)->cbd_sc, (_sc))
-#define CBDW_DATLEN(_cbd, _datlen)	__cbd_out16(&(_cbd)->cbd_datlen, (_datlen))
-#define CBDW_BUFADDR(_cbd, _bufaddr)	__cbd_out32(&(_cbd)->cbd_bufaddr, (_bufaddr))
+#define CBDW_DATLEN(_cbd, _datlen)	\
+	__cbd_out16(&(_cbd)->cbd_datlen, (_datlen))
+#define CBDW_BUFADDR(_cbd, _bufaddr)	\
+	__cbd_out32(&(_cbd)->cbd_bufaddr, (_bufaddr))
 
 /* read */
 #define CBDR_SC(_cbd) 			__cbd_in16(&(_cbd)->cbd_sc)
diff --git a/drivers/net/fs_enet/mac-fcc.c b/drivers/net/fs_enet/mac-fcc.c
index 133125f..ee21f46 100644
--- a/drivers/net/fs_enet/mac-fcc.c
+++ b/drivers/net/fs_enet/mac-fcc.c
@@ -70,7 +70,8 @@
 #define FCC_MAX_MULTICAST_ADDRS	64
 
 #define mk_mii_read(REG)	(0x60020000 | ((REG & 0x1f) << 18))
-#define mk_mii_write(REG, VAL)	(0x50020000 | ((REG & 0x1f) << 18) | (VAL & 0xffff))
+#define mk_mii_write(REG, VAL) \
+	(0x50020000 | ((REG & 0x1f) << 18) | (VAL & 0xffff))
 #define mk_mii_end		0
 
 #define MAX_CR_CMD_LOOPS	10000
@@ -323,8 +324,8 @@ static void restart(struct net_device *dev)
 	W16(ep, fen_tfclen, 0);
 	W32(ep, fen_tfcptr, 0);
 
-	W16(ep, fen_mflr, PKT_MAXBUF_SIZE);	/* maximum frame length register */
-	W16(ep, fen_minflr, PKT_MINBUF_SIZE);	/* minimum frame length register */
+	W16(ep, fen_mflr, PKT_MAXBUF_SIZE);	/* max frame length register */
+	W16(ep, fen_minflr, PKT_MINBUF_SIZE);	/* min frame length register */
 
 	/* set address */
 	mac = dev->dev_addr;
diff --git a/drivers/net/fs_enet/mac-fec.c b/drivers/net/fs_enet/mac-fec.c
index 0a7d1c5..cac51b1 100644
--- a/drivers/net/fs_enet/mac-fec.c
+++ b/drivers/net/fs_enet/mac-fec.c
@@ -33,9 +33,9 @@
 #include <linux/fs.h>
 #include <linux/platform_device.h>
 #include <linux/of_device.h>
+#include <linux/uaccess.h>
 
 #include <asm/irq.h>
-#include <asm/uaccess.h>
 
 #ifdef CONFIG_8xx
 #include <asm/8xx_immap.h>
@@ -80,7 +80,7 @@
  */
 #define FEC_RESET_DELAY		50
 
-static int whack_reset(fec_t __iomem *fecp)
+static int whack_reset(struct fec __iomem *fecp)
 {
 	int i;
 
@@ -153,7 +153,7 @@ static void free_bd(struct net_device *dev)
 	struct fs_enet_private *fep = netdev_priv(dev);
 	const struct fs_platform_info *fpi = fep->fpi;
 
-	if(fep->ring_base)
+	if (fep->ring_base)
 		dma_free_coherent(fep->dev, (fpi->tx_ring + fpi->rx_ring)
 					* sizeof(cbd_t),
 					(void __force *)fep->ring_base,
@@ -168,7 +168,7 @@ static void cleanup_data(struct net_device *dev)
 static void set_promiscuous_mode(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
 	FS(fecp, r_cntrl, FEC_RCNTRL_PROM);
 }
@@ -216,7 +216,7 @@ static void set_multicast_one(struct net_device *dev, const u8 *mac)
 static void set_multicast_finish(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
 	/* if all multi or too many multicasts; just enable all */
 	if ((dev->flags & IFF_ALLMULTI) != 0 ||
@@ -250,14 +250,14 @@ static void restart(struct net_device *dev)
 	u32 cptr;
 #endif
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 	const struct fs_platform_info *fpi = fep->fpi;
 	dma_addr_t rx_bd_base_phys, tx_bd_base_phys;
 	int r;
 	u32 addrhi, addrlo;
 
-	struct mii_bus* mii = fep->phydev->bus;
-	struct fec_info* fec_inf = mii->priv;
+	struct mii_bus *mii = fep->phydev->bus;
+	struct fec_info *fec_inf = mii->priv;
 
 	r = whack_reset(fep->fec.fecp);
 	if (r != 0)
@@ -378,9 +378,9 @@ static void stop(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 	const struct fs_platform_info *fpi = fep->fpi;
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
-	struct fec_info* feci= fep->phydev->bus->priv;
+	struct fec_info *feci = fep->phydev->bus->priv;
 
 	int i;
 
@@ -440,7 +440,7 @@ static void post_free_irq(struct net_device *dev, int irq)
 static void napi_clear_rx_event(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
 	FW(fecp, ievent, FEC_NAPI_RX_EVENT_MSK);
 }
@@ -448,7 +448,7 @@ static void napi_clear_rx_event(struct net_device *dev)
 static void napi_enable_rx(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
 	FS(fecp, imask, FEC_NAPI_RX_EVENT_MSK);
 }
@@ -456,7 +456,7 @@ static void napi_enable_rx(struct net_device *dev)
 static void napi_disable_rx(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
 	FC(fecp, imask, FEC_NAPI_RX_EVENT_MSK);
 }
@@ -464,7 +464,7 @@ static void napi_disable_rx(struct net_device *dev)
 static void rx_bd_done(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
 	FW(fecp, r_des_active, 0x01000000);
 }
@@ -472,7 +472,7 @@ static void rx_bd_done(struct net_device *dev)
 static void tx_kickstart(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
 	FW(fecp, x_des_active, 0x01000000);
 }
@@ -480,7 +480,7 @@ static void tx_kickstart(struct net_device *dev)
 static u32 get_int_events(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
 	return FR(fecp, ievent) & FR(fecp, imask);
 }
@@ -488,7 +488,7 @@ static u32 get_int_events(struct net_device *dev)
 static void clear_int_events(struct net_device *dev, u32 int_events)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
-	fec_t __iomem *fecp = fep->fec.fecp;
+	struct fec __iomem *fecp = fep->fec.fecp;
 
 	FW(fecp, ievent, int_events);
 }
@@ -503,17 +503,17 @@ static int get_regs(struct net_device *dev, void *p, int *sizep)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 
-	if (*sizep < sizeof(fec_t))
+	if (*sizep < sizeof(struct fec))
 		return -EINVAL;
 
-	memcpy_fromio(p, fep->fec.fecp, sizeof(fec_t));
+	memcpy_fromio(p, fep->fec.fecp, sizeof(struct fec));
 
 	return 0;
 }
 
 static int get_regs_len(struct net_device *dev)
 {
-	return sizeof(fec_t);
+	return sizeof(struct fec);
 }
 
 static void tx_restart(struct net_device *dev)
diff --git a/drivers/net/fs_enet/mac-scc.c b/drivers/net/fs_enet/mac-scc.c
index 029b3c7..c8f47ad 100644
--- a/drivers/net/fs_enet/mac-scc.c
+++ b/drivers/net/fs_enet/mac-scc.c
@@ -1,5 +1,6 @@
 /*
- * Ethernet on Serial Communications Controller (SCC) driver for Motorola MPC8xx and MPC82xx.
+ * Ethernet on Serial Communications Controller (SCC) driver for Motorola
+ * MPC8xx and MPC82xx.
  *
  * Copyright (c) 2003 Intracom S.A.
  *  by Pantelis Antoniou <panto@intracom.gr>
@@ -33,9 +34,9 @@
 #include <linux/fs.h>
 #include <linux/platform_device.h>
 #include <linux/of_platform.h>
+#include <linux/uaccess.h>
 
 #include <asm/irq.h>
-#include <asm/uaccess.h>
 
 #ifdef CONFIG_8xx
 #include <asm/8xx_immap.h>
@@ -147,7 +148,7 @@ static int allocate_bd(struct net_device *dev)
 	if (IS_ERR_VALUE(fep->ring_mem_addr))
 		return -ENOMEM;
 
-	fep->ring_base = (void __iomem __force*)
+	fep->ring_base = (void __iomem __force *)
 		cpm_dpram_addr(fep->ring_mem_addr);
 
 	return 0;
@@ -185,7 +186,7 @@ static void set_multicast_start(struct net_device *dev)
 	W16(ep, sen_gaddr4, 0);
 }
 
-static void set_multicast_one(struct net_device *dev, const u8 * mac)
+static void set_multicast_one(struct net_device *dev, const u8 *mac)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 	scc_enet_t __iomem *ep = fep->scc.ep;
@@ -283,9 +284,9 @@ static void restart(struct net_device *dev)
 	W16(ep, sen_pads, 0x8888);	/* Tx short frame pad character */
 	W16(ep, sen_retlim, 15);	/* Retry limit threshold */
 
-	W16(ep, sen_maxflr, 0x5ee);	/* maximum frame length register */
+	W16(ep, sen_maxflr, 0x5ee);	/* max frame length register */
 
-	W16(ep, sen_minflr, PKT_MINBUF_SIZE);	/* minimum frame length register */
+	W16(ep, sen_minflr, PKT_MINBUF_SIZE);	/* min frame length register */
 
 	W16(ep, sen_maxd1, 0x000005f0);	/* maximum DMA1 length */
 	W16(ep, sen_maxd2, 0x000005f0);	/* maximum DMA2 length */
diff --git a/drivers/net/fs_enet/mii-bitbang.c b/drivers/net/fs_enet/mii-bitbang.c
index be4b72f..daa76d0 100644
--- a/drivers/net/fs_enet/mii-bitbang.c
+++ b/drivers/net/fs_enet/mii-bitbang.c
@@ -108,7 +108,7 @@ static struct mdiobb_ops bb_ops = {
 };
 
 static int __devinit fs_mii_bitbang_init(struct mii_bus *bus,
-                                         struct device_node *np)
+					 struct device_node *np)
 {
 	struct resource res;
 	const u32 *data;
@@ -167,7 +167,7 @@ static void __devinit add_phy(struct mii_bus *bus, struct device_node *np)
 }
 
 static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
-                                        const struct of_device_id *match)
+					const struct of_device_id *match)
 {
 	struct device_node *np = NULL;
 	struct mii_bus *new_bus;
diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-fec.c
index 695f74c..5079dcf 100644
--- a/drivers/net/fs_enet/mii-fec.c
+++ b/drivers/net/fs_enet/mii-fec.c
@@ -32,10 +32,10 @@
 #include <linux/bitops.h>
 #include <linux/platform_device.h>
 #include <linux/of_platform.h>
+#include <linux/uaccess.h>
 
 #include <asm/pgtable.h>
 #include <asm/irq.h>
-#include <asm/uaccess.h>
 
 #include "fs_enet.h"
 #include "fec.h"
@@ -43,15 +43,16 @@
 /* Make MII read/write commands for the FEC.
 */
 #define mk_mii_read(REG)	(0x60020000 | ((REG & 0x1f) << 18))
-#define mk_mii_write(REG, VAL)	(0x50020000 | ((REG & 0x1f) << 18) | (VAL & 0xffff))
+#define mk_mii_write(REG, VAL) \
+	(0x50020000 | ((REG & 0x1f) << 18) | (VAL & 0xffff))
 #define mk_mii_end		0
 
 #define FEC_MII_LOOPS	10000
 
 static int fs_enet_fec_mii_read(struct mii_bus *bus , int phy_id, int location)
 {
-	struct fec_info* fec = bus->priv;
-	fec_t __iomem *fecp = fec->fecp;
+	struct fec_info *fec = bus->priv;
+	struct fec __iomem *fecp = fec->fecp;
 	int i, ret = -1;
 
 	if ((in_be32(&fecp->fec_r_cntrl) & FEC_RCNTRL_MII_MODE) == 0)
@@ -72,10 +73,11 @@ static int fs_enet_fec_mii_read(struct mii_bus *bus , int phy_id, int location)
 	return ret;
 }
 
-static int fs_enet_fec_mii_write(struct mii_bus *bus, int phy_id, int location, u16 val)
+static int fs_enet_fec_mii_write(struct mii_bus *bus, int phy_id, int location,
+				 u16 val)
 {
-	struct fec_info* fec = bus->priv;
-	fec_t __iomem *fecp = fec->fecp;
+	struct fec_info *fec = bus->priv;
+	struct fec __iomem *fecp = fec->fecp;
 	int i;
 
 	/* this must never happen */
@@ -83,7 +85,8 @@ static int fs_enet_fec_mii_write(struct mii_bus *bus, int phy_id, int location,
 		BUG();
 
 	/* Add PHY address to register command.  */
-	out_be32(&fecp->fec_mii_data, (phy_id << 23) | mk_mii_write(location, val));
+	out_be32(&fecp->fec_mii_data,
+			(phy_id << 23) | mk_mii_write(location, val));
 
 	for (i = 0; i < FEC_MII_LOOPS; i++)
 		if ((in_be32(&fecp->fec_ievent) & FEC_ENET_MII) != 0)
@@ -120,7 +123,7 @@ static void __devinit add_phy(struct mii_bus *bus, struct device_node *np)
 }
 
 static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
-                                        const struct of_device_id *match)
+					const struct of_device_id *match)
 {
 	struct device_node *np = NULL;
 	struct resource res;
@@ -156,7 +159,7 @@ static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
 
 	setbits32(&fec->fecp->fec_r_cntrl, FEC_RCNTRL_MII_MODE);
 	setbits32(&fec->fecp->fec_ecntrl, FEC_ECNTRL_PINMUX |
-	                                  FEC_ECNTRL_ETHER_EN);
+					  FEC_ECNTRL_ETHER_EN);
 	out_be32(&fec->fecp->fec_ievent, FEC_ENET_MII);
 	out_be32(&fec->fecp->fec_mii_speed, fec->mii_speed);
 
-- 
1.5.6.rc0.46.gd2b3


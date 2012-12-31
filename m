From: Andreas Mohr <andi@lisas.de>
Subject: [PATCH RFC 14/15] via-rhine: The Great Deduplication.
Date: Mon, 31 Dec 2012 16:25:48 +0100
Message-ID: <1356967549-5056-15-git-send-email-andi@lisas.de>
References: <1356967549-5056-1-git-send-email-andi@lisas.de>
Cc: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: andim2@users.sf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:54074 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011Ab2LaPen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2012 10:34:43 -0500
In-Reply-To: <1356967549-5056-1-git-send-email-andi@lisas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Mohr <andim2@users.sf.net>

- remove descriptor call duplication into helper
- remove duplication into a helper variable
- remove force_media log duplication into helper
- remove IRQ unmask duplication into helper

Signed-off-by: Andreas Mohr <andim2@users.sf.net>
---
 drivers/net/ethernet/via/via-rhine.c |   67 ++++++++++++++++++++++------------
 1 files changed, 43 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 984f056..051bb95 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -426,6 +426,9 @@ struct tx_desc {
 	__le32 next_desc;
 };
 
+/* An invalid address. */
+static const __le32 invalid_ring_address = cpu_to_le32(0xBADF00D0);
+
 /* Initial value for tx_desc.desc_length, Buffer size goes to bits 0-10 */
 #define TXDESC		0x00e08000
 
@@ -786,6 +789,19 @@ static void rhine_reload_eeprom(long pioaddr, struct net_device *dev)
 
 }
 
+static inline void
+rhine_irq_unmask(struct rhine_private *rp, u16 mask)
+{
+	iowrite16(mask, rp->base + IntrEnable);
+	mmiowb();
+}
+
+static void
+rhine_irq_disable(struct rhine_private *rp)
+{
+	rhine_irq_unmask(rp, 0x0000);
+}
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void rhine_poll(struct net_device *dev)
 {
@@ -930,8 +946,7 @@ static int rhine_napipoll(struct napi_struct *napi, int budget)
 
 	if (work_done < budget) {
 		napi_complete(napi);
-		iowrite16(enable_mask, ioaddr + IntrEnable);
-		mmiowb();
+		rhine_irq_unmask(rp, enable_mask);
 	}
 	return work_done;
 }
@@ -1287,7 +1302,7 @@ static void free_rbufs(struct net_device* dev)
 	/* Free all the skbuffs in the Rx queue. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
 		rp->rx_ring[i].rx_status = 0;
-		rp->rx_ring[i].addr = cpu_to_le32(0xBADF00D0); /* An invalid address. */
+		rp->rx_ring[i].addr = invalid_ring_address;
 		if (rp->rx_skbuff[i]) {
 			pci_unmap_single(rp->pdev,
 					 rp->rx_skbuff_dma[i],
@@ -1327,7 +1342,7 @@ static void free_tbufs(struct net_device* dev)
 	for (i = 0; i < TX_RING_SIZE; i++) {
 		rp->tx_ring[i].tx_status = 0;
 		rp->tx_ring[i].desc_length = cpu_to_le32(TXDESC);
-		rp->tx_ring[i].addr = cpu_to_le32(0xBADF00D0); /* An invalid address. */
+		rp->tx_ring[i].addr = invalid_ring_address;
 		if (rp->tx_skbuff[i]) {
 			if (rp->tx_skbuff_dma[i]) {
 				pci_unmap_single(rp->pdev,
@@ -1342,6 +1357,25 @@ static void free_tbufs(struct net_device* dev)
 	}
 }
 
+static inline void
+rhine_realloc_all_descriptors(struct net_device *dev)
+{
+	free_tbufs(dev);
+	free_rbufs(dev);
+	alloc_tbufs(dev);
+	alloc_rbufs(dev);
+}
+
+static void
+rhine_force_media_log(struct mii_if_info *mii)
+{
+	struct net_device *dev = mii->dev;
+	struct rhine_private *rp = netdev_priv(dev);
+
+	netif_info(rp, link, dev, "force_media %d, carrier %d\n",
+		   mii->force_media, netif_carrier_ok(dev));
+}
+
 static void rhine_check_media(struct net_device *dev, unsigned int init_media)
 {
 	struct rhine_private *rp = netdev_priv(dev);
@@ -1356,15 +1390,13 @@ static void rhine_check_media(struct net_device *dev, unsigned int init_media)
 	    iowrite8(ioread8(ioaddr + ChipCmd1) & ~Cmd1FDuplex,
 		   ioaddr + ChipCmd1);
 
-	netif_info(rp, link, dev, "force_media %d, carrier %d\n",
-		   rp->mii_if.force_media, netif_carrier_ok(dev));
+	rhine_force_media_log(&rp->mii_if);
 }
 
 /* Called after status of force_media possibly changed */
 static void rhine_set_carrier(struct mii_if_info *mii)
 {
 	struct net_device *dev = mii->dev;
-	struct rhine_private *rp = netdev_priv(dev);
 
 	if (mii->force_media) {
 		/* autoneg is off: Link is always assumed to be up */
@@ -1373,8 +1405,7 @@ static void rhine_set_carrier(struct mii_if_info *mii)
 	} else	/* Let MII library update carrier status */
 		rhine_check_media(dev, 0);
 
-	netif_info(rp, link, dev, "force_media %d, carrier %d\n",
-		   mii->force_media, netif_carrier_ok(dev));
+	rhine_force_media_log(mii);
 }
 
 /**
@@ -1568,7 +1599,7 @@ static void init_registers(struct net_device *dev)
 
 	napi_enable(&rp->napi);
 
-	iowrite16(RHINE_EVENT & 0xffff, ioaddr + IntrEnable);
+	rhine_irq_unmask(rp, RHINE_EVENT & 0xffff);
 
 	iowrite16(CmdStart | CmdTxOn | CmdRxOn | (Cmd1NoTxPoll << 8),
 	       ioaddr + ChipCmd);
@@ -1717,10 +1748,7 @@ static void rhine_reset_task(struct work_struct *work)
 	spin_lock_bh(&rp->lock);
 
 	/* clear all descriptors */
-	free_tbufs(dev);
-	free_rbufs(dev);
-	alloc_tbufs(dev);
-	alloc_rbufs(dev);
+	rhine_realloc_all_descriptors(dev);
 
 	/* Reinitialize the hardware. */
 	rhine_chip_reset(dev);
@@ -1831,12 +1859,6 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 }
 
-static void rhine_irq_disable(struct rhine_private *rp)
-{
-	iowrite16(0x0000, rp->base + IntrEnable);
-	mmiowb();
-}
-
 /* The interrupt handler does all of the Rx thread work and cleans up
    after the Tx thread. */
 static irqreturn_t rhine_interrupt(int irq, void *dev_instance)
@@ -2524,10 +2546,7 @@ static int rhine_resume(struct device *device)
 	if (!netif_running(dev))
 		return 0;
 
-	free_tbufs(dev);
-	free_rbufs(dev);
-	alloc_tbufs(dev);
-	alloc_rbufs(dev);
+	rhine_realloc_all_descriptors(dev);
 	rhine_task_enable(rp);
 	spin_lock_bh(&rp->lock);
 	init_registers(dev);
-- 
1.7.2.5

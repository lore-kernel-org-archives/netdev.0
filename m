From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH 02/12] fec: switch to writel/readl
Date: Wed, 15 Apr 2009 15:11:30 +0200
Message-ID: <20090415131130.GW14383@pengutronix.de>
References: <1239795145-27558-1-git-send-email-s.hauer@pengutronix.de> <1239795145-27558-2-git-send-email-s.hauer@pengutronix.de> <1239795145-27558-3-git-send-email-s.hauer@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Ungerer <gerg@snapgear.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:51843 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760077AbZDONLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 09:11:33 -0400
Content-Disposition: inline
In-Reply-To: <1239795145-27558-3-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the second register set is used for M5272 we cannot remove it.
Here is an updated version.

Sascha


>From 4330c85a8902007a6fb726333a85b9e981579992 Mon Sep 17 00:00:00 2001
From: Sascha Hauer <s.hauer@pengutronix.de>
Date: Wed, 15 Apr 2009 09:51:34 +0200
Subject: [PATCH 01/11] fec: switch to writel/readl

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/fec.c |  279 ++++++++++++++++++++++-------------------------------
 drivers/net/fec.h |  119 +++++++++--------------
 2 files changed, 161 insertions(+), 237 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 682e7f0..3fa3fe4 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -165,7 +165,7 @@ typedef struct {
  */
 struct fec_enet_private {
 	/* Hardware registers of the FEC device */
-	volatile fec_t	*hwp;
+	void __iomem *hwp;
 
 	struct net_device *netdev;
 
@@ -288,15 +288,11 @@ static int	mii_queue(struct net_device *dev, int request,
 static int
 fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct fec_enet_private *fep;
-	volatile fec_t	*fecp;
+	struct fec_enet_private *fep = netdev_priv(dev);
 	volatile cbd_t	*bdp;
 	unsigned short	status;
 	unsigned long flags;
 
-	fep = netdev_priv(dev);
-	fecp = (volatile fec_t*)dev->base_addr;
-
 	if (!fep->link) {
 		/* Link is down or autonegotiation is in progress. */
 		return 1;
@@ -363,7 +359,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev->trans_start = jiffies;
 
 	/* Trigger transmission start */
-	fecp->fec_x_des_active = 0;
+	writel(0, fep->hwp + FEC_X_DES_ACTIVE);
 
 	/* If this was the last BD in the ring, start at the beginning again.
 	*/
@@ -436,29 +432,25 @@ static irqreturn_t
 fec_enet_interrupt(int irq, void * dev_id)
 {
 	struct	net_device *dev = dev_id;
-	volatile fec_t	*fecp;
+	struct fec_enet_private *fep = netdev_priv(dev);
 	uint	int_events;
 	irqreturn_t ret = IRQ_NONE;
 
-	fecp = (volatile fec_t*)dev->base_addr;
-
-	/* Get the interrupt events that caused us to be here.
-	*/
+	/* Get the interrupt events that caused us to be here. */
 	do {
-		int_events = fecp->fec_ievent;
-		fecp->fec_ievent = int_events;
+		int_events = readl(fep->hwp + FEC_IEVENT);
+		writel(int_events, fep->hwp + FEC_IEVENT);
 
-		/* Handle receive event in its own function.
-		 */
+		/* Handle receive event in its own function. */
 		if (int_events & FEC_ENET_RXF) {
 			ret = IRQ_HANDLED;
 			fec_enet_rx(dev);
 		}
 
 		/* Transmit OK, or non-fatal error. Update the buffer
-		   descriptors. FEC handles all errors, we just discover
-		   them as part of the transmit process.
-		*/
+		 * descriptors. FEC handles all errors, we just discover
+		 * them as part of the transmit process.
+		 */
 		if (int_events & FEC_ENET_TXF) {
 			ret = IRQ_HANDLED;
 			fec_enet_tx(dev);
@@ -555,8 +547,7 @@ fec_enet_tx(struct net_device *dev)
 static void
 fec_enet_rx(struct net_device *dev)
 {
-	struct	fec_enet_private *fep;
-	volatile fec_t	*fecp;
+	struct	fec_enet_private *fep = netdev_priv(dev);
 	volatile cbd_t *bdp;
 	unsigned short status;
 	struct	sk_buff	*skb;
@@ -567,9 +558,6 @@ fec_enet_rx(struct net_device *dev)
 	flush_cache_all();
 #endif
 
-	fep = netdev_priv(dev);
-	fecp = (volatile fec_t*)dev->base_addr;
-
 	spin_lock_irq(&fep->hw_lock);
 
 	/* First, grab all of the stats for the incoming packet.
@@ -665,7 +653,7 @@ while (!((status = bdp->cbd_sc) & BD_ENET_RX_EMPTY)) {
 	 * incoming frames.  On a heavily loaded network, we should be
 	 * able to keep up at the expense of system resources.
 	 */
-	fecp->fec_r_des_active = 0;
+	writel(0, fep->hwp + FEC_R_DES_ACTIVE);
 #endif
    } /* while (!((status = bdp->cbd_sc) & BD_ENET_RX_EMPTY)) */
 	fep->cur_rx = (cbd_t *)bdp;
@@ -690,30 +678,25 @@ static void
 fec_enet_mii(struct net_device *dev)
 {
 	struct	fec_enet_private *fep;
-	volatile fec_t	*ep;
 	mii_list_t	*mip;
-	uint		mii_reg;
 
 	fep = netdev_priv(dev);
 	spin_lock_irq(&fep->mii_lock);
 
-	ep = fep->hwp;
-	mii_reg = ep->fec_mii_data;
-
 	if ((mip = mii_head) == NULL) {
 		printk("MII and no head!\n");
 		goto unlock;
 	}
 
 	if (mip->mii_func != NULL)
-		(*(mip->mii_func))(mii_reg, dev);
+		(*(mip->mii_func))(readl(fep->hwp + FEC_MII_DATA), dev);
 
 	mii_head = mip->mii_next;
 	mip->mii_next = mii_free;
 	mii_free = mip;
 
 	if ((mip = mii_head) != NULL)
-		ep->fec_mii_data = mip->mii_regval;
+		writel(mip->mii_regval, fep->hwp + FEC_MII_DATA);
 
 unlock:
 	spin_unlock_irq(&fep->mii_lock);
@@ -745,7 +728,7 @@ mii_queue(struct net_device *dev, int regval, void (*func)(uint, struct net_devi
 			mii_tail = mip;
 		} else {
 			mii_head = mii_tail = mip;
-			fep->hwp->fec_mii_data = regval;
+			writel(regval, fep->hwp + FEC_MII_DATA);
 		}
 	} else {
 		retval = 1;
@@ -1246,11 +1229,8 @@ static void __inline__ fec_phy_ack_intr(void)
 static void __inline__ fec_get_mac(struct net_device *dev)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
-	volatile fec_t *fecp;
 	unsigned char *iap, tmpaddr[ETH_ALEN];
 
-	fecp = fep->hwp;
-
 	if (FEC_FLASHMAC) {
 		/*
 		 * Get MAC address from FLASH.
@@ -1264,8 +1244,8 @@ static void __inline__ fec_get_mac(struct net_device *dev)
 		    (iap[3] == 0xff) && (iap[4] == 0xff) && (iap[5] == 0xff))
 			iap = fec_mac_default;
 	} else {
-		*((unsigned long *) &tmpaddr[0]) = fecp->fec_addr_low;
-		*((unsigned short *) &tmpaddr[4]) = (fecp->fec_addr_high >> 16);
+		*((unsigned long *) &tmpaddr[0]) = readl(fep->hwp + FEC_ADDR_LOW);
+		*((unsigned short *) &tmpaddr[4]) = (readl(fep->hwp + FEC_ADDR_HIGH) >> 16);
 		iap = &tmpaddr[0];
 	}
 
@@ -1457,11 +1437,9 @@ static void
 mii_discover_phy(uint mii_reg, struct net_device *dev)
 {
 	struct fec_enet_private *fep;
-	volatile fec_t *fecp;
 	uint phytype;
 
 	fep = netdev_priv(dev);
-	fecp = fep->hwp;
 
 	if (fep->phy_addr < 32) {
 		if ((phytype = (mii_reg & 0xffff)) != 0xffff && phytype != 0) {
@@ -1479,7 +1457,8 @@ mii_discover_phy(uint mii_reg, struct net_device *dev)
 	} else {
 		printk("FEC: No PHY device found.\n");
 		/* Disable external MII interface */
-		fecp->fec_mii_speed = fep->phy_speed = 0;
+		writel(0, fep->hwp + FEC_MII_SPEED);
+		fep->phy_speed = 0;
 #ifdef HAVE_mii_link_interrupt
 		fec_disable_phy_intr();
 #endif
@@ -1583,32 +1562,31 @@ fec_enet_close(struct net_device *dev)
 
 static void set_multicast_list(struct net_device *dev)
 {
-	struct fec_enet_private *fep;
-	volatile fec_t *ep;
+	struct fec_enet_private *fep = netdev_priv(dev);
 	struct dev_mc_list *dmi;
-	unsigned int i, j, bit, data, crc;
+	unsigned int i, j, bit, data, crc, tmp;
 	unsigned char hash;
 
-	fep = netdev_priv(dev);
-	ep = fep->hwp;
-
 	if (dev->flags&IFF_PROMISC) {
-		ep->fec_r_cntrl |= 0x0008;
+		tmp = readl(fep->hwp + FEC_R_CNTRL);
+		tmp |= 0x8;
+		writel(tmp, fep->hwp + FEC_R_CNTRL);
 	} else {
-
-		ep->fec_r_cntrl &= ~0x0008;
+		tmp = readl(fep->hwp + FEC_R_CNTRL);
+		tmp &= ~0x8;
+		writel(tmp, fep->hwp + FEC_R_CNTRL);
 
 		if (dev->flags & IFF_ALLMULTI) {
 			/* Catch all multicast addresses, so set the
 			 * filter to all 1's.
 			 */
-			ep->fec_grp_hash_table_high = 0xffffffff;
-			ep->fec_grp_hash_table_low = 0xffffffff;
+			writel(0xffffffff, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
+			writel(0xffffffff, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
 		} else {
 			/* Clear filter and add the addresses in hash register.
 			*/
-			ep->fec_grp_hash_table_high = 0;
-			ep->fec_grp_hash_table_low = 0;
+			writel(0, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
+			writel(0, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
 
 			dmi = dev->mc_list;
 
@@ -1638,10 +1616,15 @@ static void set_multicast_list(struct net_device *dev)
 				*/
 				hash = (crc >> (32 - HASH_BITS)) & 0x3f;
 
-				if (hash > 31)
-					ep->fec_grp_hash_table_high |= 1 << (hash - 32);
-				else
-					ep->fec_grp_hash_table_low |= 1 << hash;
+				if (hash > 31) {
+					tmp = readl(fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
+					tmp |= 1 << (hash - 32);
+					writel(tmp, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
+				} else {
+					tmp = readl(fep->hwp + FEC_GRP_HASH_TABLE_LOW);
+					tmp |= 1 << hash;
+					writel(tmp, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
+				}
 			}
 		}
 	}
@@ -1652,16 +1635,14 @@ static void set_multicast_list(struct net_device *dev)
 static void
 fec_set_mac_address(struct net_device *dev)
 {
-	volatile fec_t *fecp;
-
-	fecp = ((struct fec_enet_private *)netdev_priv(dev))->hwp;
+	struct fec_enet_private *fep = netdev_priv(dev);
 
 	/* Set station address. */
-	fecp->fec_addr_low = dev->dev_addr[3] | (dev->dev_addr[2] << 8) |
-		(dev->dev_addr[1] << 16) | (dev->dev_addr[0] << 24);
-	fecp->fec_addr_high = (dev->dev_addr[5] << 16) |
-		(dev->dev_addr[4] << 24);
-
+	writel(dev->dev_addr[3] | (dev->dev_addr[2] << 8) |
+		(dev->dev_addr[1] << 16) | (dev->dev_addr[0] << 24),
+		fep->hwp + FEC_ADDR_LOW);
+	writel((dev->dev_addr[5] << 16) | (dev->dev_addr[4] << 24),
+		fep + FEC_ADDR_HIGH);
 }
 
  /*
@@ -1675,7 +1656,6 @@ int __init fec_enet_init(struct net_device *dev, int index)
 	unsigned long	mem_addr;
 	volatile cbd_t	*bdp;
 	cbd_t		*cbd_base;
-	volatile fec_t	*fecp;
 	int 		i, j;
 
 	/* Allocate memory for buffer descriptors.
@@ -1690,17 +1670,13 @@ int __init fec_enet_init(struct net_device *dev, int index)
 	spin_lock_init(&fep->hw_lock);
 	spin_lock_init(&fep->mii_lock);
 
-	/* Create an Ethernet device instance.
-	*/
-	fecp = (volatile fec_t *)dev->base_addr;
-
 	fep->index = index;
-	fep->hwp = fecp;
+	fep->hwp = (void __iomem *)dev->base_addr;
 	fep->netdev = dev;
 
 	/* Whack a reset.  We should wait for this.
 	*/
-	fecp->fec_ecntrl = 1;
+	writel(1, fep->hwp + FEC_ECNTRL);
 	udelay(10);
 
 	/* Set the Ethernet address */
@@ -1709,12 +1685,12 @@ int __init fec_enet_init(struct net_device *dev, int index)
 #else
 	{
 		unsigned long l;
-		l = fecp->fec_addr_low;
+		l = readl(fep->hwp + FEC_ADDR_LOW);
 		dev->dev_addr[0] = (unsigned char)((l & 0xFF000000) >> 24);
 		dev->dev_addr[1] = (unsigned char)((l & 0x00FF0000) >> 16);
 		dev->dev_addr[2] = (unsigned char)((l & 0x0000FF00) >> 8);
 		dev->dev_addr[3] = (unsigned char)((l & 0x000000FF) >> 0);
-		l = fecp->fec_addr_high;
+		l = readl(fep->hwp + FEC_ADDR_HIGH);
 		dev->dev_addr[4] = (unsigned char)((l & 0xFF000000) >> 24);
 		dev->dev_addr[5] = (unsigned char)((l & 0x00FF0000) >> 16);
 	}
@@ -1784,22 +1760,22 @@ int __init fec_enet_init(struct net_device *dev, int index)
 
 	/* Set receive and transmit descriptor base.
 	*/
-	fecp->fec_r_des_start = fep->bd_dma;
-	fecp->fec_x_des_start = (unsigned long)fep->bd_dma + sizeof(cbd_t)
-				* RX_RING_SIZE;
+	writel(fep->bd_dma, fep->hwp + FEC_R_DES_START);
+	writel((unsigned long)fep->bd_dma + sizeof(cbd_t) * RX_RING_SIZE,
+			fep->hwp + FEC_X_DES_START);
 
 #ifdef HAVE_mii_link_interrupt
 	fec_request_mii_intr(dev);
 #endif
 
-	fecp->fec_grp_hash_table_high = 0;
-	fecp->fec_grp_hash_table_low = 0;
-	fecp->fec_r_buff_size = PKT_MAXBLR_SIZE;
-	fecp->fec_ecntrl = 2;
-	fecp->fec_r_des_active = 0;
+	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
+	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
+	writel(PKT_MAXBLR_SIZE, fep->hwp + FEC_R_BUFF_SIZE);
+	writel(2, fep->hwp + FEC_ECNTRL);
+	writel(0, fep->hwp + FEC_R_DES_ACTIVE);
 #ifndef CONFIG_M5272
-	fecp->fec_hash_table_high = 0;
-	fecp->fec_hash_table_low = 0;
+	writel(0, fep->hwp + FEC_HASH_TABLE_HIGH);
+	writel(0, fep->hwp + FEC_HASH_TABLE_LOW);
 #endif
 
 	/* The FEC Ethernet specific entries in the device structure. */
@@ -1815,20 +1791,21 @@ int __init fec_enet_init(struct net_device *dev, int index)
 	mii_free = mii_cmds;
 
 	/* setup MII interface */
-	fecp->fec_r_cntrl = OPT_FRAME_SIZE | 0x04;
-	fecp->fec_x_cntrl = 0x00;
+	writel(OPT_FRAME_SIZE | 0x04, fep->hwp + FEC_R_CNTRL);
+	writel(0, fep->hwp + FEC_X_CNTRL);
 
 	/*
 	 * Set MII speed to 2.5 MHz
 	 */
 	fep->phy_speed = ((((clk_get_rate(fep->clk) / 2 + 4999999)
 					/ 2500000) / 2) & 0x3F) << 1;
-	fecp->fec_mii_speed = fep->phy_speed;
+	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
 	fec_restart(dev, 0);
 
 	/* Clear and enable interrupts */
-	fecp->fec_ievent = 0xffc00000;
-	fecp->fec_imask = (FEC_ENET_TXF | FEC_ENET_RXF | FEC_ENET_MII);
+	writel(0xffc00000, fep->hwp + FEC_IEVENT);
+	writel(FEC_ENET_TXF | FEC_ENET_RXF | FEC_ENET_MII,
+			fep->hwp + FEC_IMASK);
 
 	/* Queue up command to detect the PHY and initialize the
 	 * remainder of the interface.
@@ -1847,47 +1824,36 @@ int __init fec_enet_init(struct net_device *dev, int index)
 static void
 fec_restart(struct net_device *dev, int duplex)
 {
-	struct fec_enet_private *fep;
+	struct fec_enet_private *fep = netdev_priv(dev);
 	volatile cbd_t *bdp;
-	volatile fec_t *fecp;
 	int i;
 
-	fep = netdev_priv(dev);
-	fecp = fep->hwp;
-
-	/* Whack a reset.  We should wait for this.
-	*/
-	fecp->fec_ecntrl = 1;
+	/* Whack a reset.  We should wait for this. */
+	writel(1, fep->hwp + FEC_ECNTRL);
 	udelay(10);
 
-	/* Clear any outstanding interrupt.
-	*/
-	fecp->fec_ievent = 0xffc00000;
+	/* Clear any outstanding interrupt. */
+	writel(0xffc00000, fep->hwp + FEC_IEVENT);
 
-	/* Set station address.
-	*/
+	/* Set station address.	*/
 	fec_set_mac_address(dev);
 
-	/* Reset all multicast.
-	*/
-	fecp->fec_grp_hash_table_high = 0;
-	fecp->fec_grp_hash_table_low = 0;
+	/* Reset all multicast.	*/
+	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
+	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
 
-	/* Set maximum receive buffer size.
-	*/
-	fecp->fec_r_buff_size = PKT_MAXBLR_SIZE;
+	/* Set maximum receive buffer size. */
+	writel(PKT_MAXBLR_SIZE, fep->hwp + FEC_R_BUFF_SIZE);
 
-	/* Set receive and transmit descriptor base.
-	*/
-	fecp->fec_r_des_start = fep->bd_dma;
-	fecp->fec_x_des_start = (unsigned long)fep->bd_dma + sizeof(cbd_t)
-				* RX_RING_SIZE;
+	/* Set receive and transmit descriptor base. */
+	writel(fep->bd_dma, fep->hwp + FEC_R_DES_START);
+	writel((unsigned long)fep->bd_dma + sizeof(cbd_t) * RX_RING_SIZE,
+			fep->hwp + FEC_X_DES_START);
 
 	fep->dirty_tx = fep->cur_tx = fep->tx_bd_base;
 	fep->cur_rx = fep->rx_bd_base;
 
-	/* Reset SKB transmit buffers.
-	*/
+	/* Reset SKB transmit buffers. */
 	fep->skb_cur = fep->skb_dirty = 0;
 	for (i=0; i<=TX_RING_MOD_MASK; i++) {
 		if (fep->tx_skbuff[i] != NULL) {
@@ -1896,96 +1862,81 @@ fec_restart(struct net_device *dev, int duplex)
 		}
 	}
 
-	/* Initialize the receive buffer descriptors.
-	*/
+	/* Initialize the receive buffer descriptors. */
 	bdp = fep->rx_bd_base;
 	for (i=0; i<RX_RING_SIZE; i++) {
 
-		/* Initialize the BD for every fragment in the page.
-		*/
+		/* Initialize the BD for every fragment in the page. */
 		bdp->cbd_sc = BD_ENET_RX_EMPTY;
 		bdp++;
 	}
 
-	/* Set the last buffer to wrap.
-	*/
+	/* Set the last buffer to wrap. */
 	bdp--;
 	bdp->cbd_sc |= BD_SC_WRAP;
 
-	/* ...and the same for transmmit.
-	*/
+	/* ...and the same for transmmit. */
 	bdp = fep->tx_bd_base;
 	for (i=0; i<TX_RING_SIZE; i++) {
 
-		/* Initialize the BD for every fragment in the page.
-		*/
+		/* Initialize the BD for every fragment in the page. */
 		bdp->cbd_sc = 0;
 		bdp->cbd_bufaddr = 0;
 		bdp++;
 	}
 
-	/* Set the last buffer to wrap.
-	*/
+	/* Set the last buffer to wrap. */
 	bdp--;
 	bdp->cbd_sc |= BD_SC_WRAP;
 
-	/* Enable MII mode.
-	*/
+	/* Enable MII mode. */
 	if (duplex) {
-		fecp->fec_r_cntrl = OPT_FRAME_SIZE | 0x04;/* MII enable */
-		fecp->fec_x_cntrl = 0x04;		  /* FD enable */
+		/* MII enable / FD enable */
+		writel(OPT_FRAME_SIZE | 0x04, fep->hwp + FEC_R_CNTRL);
+		writel(0x04, fep->hwp + FEC_X_CNTRL);
 	} else {
-		/* MII enable|No Rcv on Xmit */
-		fecp->fec_r_cntrl = OPT_FRAME_SIZE | 0x06;
-		fecp->fec_x_cntrl = 0x00;
+		/* MII enable / No Rcv on Xmit */
+		writel(OPT_FRAME_SIZE | 0x06, fep->hwp + FEC_R_CNTRL);
+		writel(0x0, fep->hwp + FEC_X_CNTRL);
 	}
 	fep->full_duplex = duplex;
 
-	/* Set MII speed.
-	*/
-	fecp->fec_mii_speed = fep->phy_speed;
+	/* Set MII speed. */
+	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
 
-	/* And last, enable the transmit and receive processing.
-	*/
-	fecp->fec_ecntrl = 2;
-	fecp->fec_r_des_active = 0;
+	/* And last, enable the transmit and receive processing. */
+	writel(2, fep->hwp + FEC_ECNTRL);
+	writel(0, fep->hwp + FEC_R_DES_ACTIVE);
 
-	/* Enable interrupts we wish to service.
-	*/
-	fecp->fec_imask = (FEC_ENET_TXF | FEC_ENET_RXF | FEC_ENET_MII);
+	/* Enable interrupts we wish to service. */
+	writel(FEC_ENET_TXF | FEC_ENET_RXF | FEC_ENET_MII,
+			fep->hwp + FEC_IMASK);
 }
 
 static void
 fec_stop(struct net_device *dev)
 {
-	volatile fec_t *fecp;
-	struct fec_enet_private *fep;
-
-	fep = netdev_priv(dev);
-	fecp = fep->hwp;
+	struct fec_enet_private *fep = netdev_priv(dev);
 
 	/*
 	** We cannot expect a graceful transmit stop without link !!!
 	*/
-	if (fep->link)
-		{
-		fecp->fec_x_cntrl = 0x01;	/* Graceful transmit stop */
+	if (fep->link) {
+		writel(1, fep->hwp + FEC_X_CNTRL); /* Graceful transmit stop */
 		udelay(10);
-		if (!(fecp->fec_ievent & FEC_ENET_GRA))
+		if (!(readl(fep->hwp + FEC_IEVENT) & FEC_ENET_GRA))
 			printk("fec_stop : Graceful transmit stop did not complete !\n");
-		}
+	}
 
-	/* Whack a reset.  We should wait for this.
-	*/
-	fecp->fec_ecntrl = 1;
+	/* Whack a reset.  We should wait for this. */
+	writel(1, fep->hwp + FEC_ECNTRL);
 	udelay(10);
 
-	/* Clear outstanding MII command interrupts.
-	*/
-	fecp->fec_ievent = FEC_ENET_MII;
+	/* Clear outstanding MII command interrupts. */
+	writel(FEC_ENET_MII, fep->hwp + FEC_IEVENT);
 
-	fecp->fec_imask = FEC_ENET_MII;
-	fecp->fec_mii_speed = fep->phy_speed;
+	writel(FEC_ENET_MII, fep->hwp + FEC_IMASK);
+	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
 }
 
 static int __devinit
diff --git a/drivers/net/fec.h b/drivers/net/fec.h
index 76c64c9..5474ba3 100644
--- a/drivers/net/fec.h
+++ b/drivers/net/fec.h
@@ -20,82 +20,55 @@
  *	registers in the same peripheral device on different models
  *	of the ColdFire!
  */
-typedef struct fec {
-	unsigned long	fec_reserved0;
-	unsigned long	fec_ievent;		/* Interrupt event reg */
-	unsigned long	fec_imask;		/* Interrupt mask reg */
-	unsigned long	fec_reserved1;
-	unsigned long	fec_r_des_active;	/* Receive descriptor reg */
-	unsigned long	fec_x_des_active;	/* Transmit descriptor reg */
-	unsigned long	fec_reserved2[3];
-	unsigned long	fec_ecntrl;		/* Ethernet control reg */
-	unsigned long	fec_reserved3[6];
-	unsigned long	fec_mii_data;		/* MII manage frame reg */
-	unsigned long	fec_mii_speed;		/* MII speed control reg */
-	unsigned long	fec_reserved4[7];
-	unsigned long	fec_mib_ctrlstat;	/* MIB control/status reg */
-	unsigned long	fec_reserved5[7];
-	unsigned long	fec_r_cntrl;		/* Receive control reg */
-	unsigned long	fec_reserved6[15];
-	unsigned long	fec_x_cntrl;		/* Transmit Control reg */
-	unsigned long	fec_reserved7[7];
-	unsigned long	fec_addr_low;		/* Low 32bits MAC address */
-	unsigned long	fec_addr_high;		/* High 16bits MAC address */
-	unsigned long	fec_opd;		/* Opcode + Pause duration */
-	unsigned long	fec_reserved8[10];
-	unsigned long	fec_hash_table_high;	/* High 32bits hash table */
-	unsigned long	fec_hash_table_low;	/* Low 32bits hash table */
-	unsigned long	fec_grp_hash_table_high;/* High 32bits hash table */
-	unsigned long	fec_grp_hash_table_low;	/* Low 32bits hash table */
-	unsigned long	fec_reserved9[7];
-	unsigned long	fec_x_wmrk;		/* FIFO transmit water mark */
-	unsigned long	fec_reserved10;
-	unsigned long	fec_r_bound;		/* FIFO receive bound reg */
-	unsigned long	fec_r_fstart;		/* FIFO receive start reg */
-	unsigned long	fec_reserved11[11];
-	unsigned long	fec_r_des_start;	/* Receive descriptor ring */
-	unsigned long	fec_x_des_start;	/* Transmit descriptor ring */
-	unsigned long	fec_r_buff_size;	/* Maximum receive buff size */
-} fec_t;
+#define FEC_IEVENT		0x004 /* Interrupt event reg */
+#define FEC_IMASK		0x008 /* Interrupt mask reg */
+#define FEC_R_DES_ACTIVE	0x010 /* Receive descriptor reg */
+#define FEC_X_DES_ACTIVE	0x014 /* Transmit descriptor reg */
+#define FEC_ECNTRL		0x024 /* Ethernet control reg */
+#define FEC_MII_DATA		0x040 /* MII manage frame reg */
+#define FEC_MII_SPEED		0x044 /* MII speed control reg */
+#define FEC_MIB_CTRLSTAT	0x064 /* MIB control/status reg */
+#define FEC_R_CNTRL		0x084 /* Receive control reg */
+#define FEC_X_CNTRL		0x0c4 /* Transmit Control reg */
+#define FEC_ADDR_LOW		0x0e4 /* Low 32bits MAC address */
+#define FEC_ADDR_HIGH		0x0e8 /* High 16bits MAC address */
+#define FEC_OPD			0x0ec /* Opcode + Pause duration */
+#define FEC_HASH_TABLE_HIGH	0x118 /* High 32bits hash table */
+#define FEC_HASH_TABLE_LOW	0x11c /* Low 32bits hash table */
+#define FEC_GRP_HASH_TABLE_HIGH	0x120 /* High 32bits hash table */
+#define FEC_GRP_HASH_TABLE_LOW	0x124 /* Low 32bits hash table */
+#define FEC_X_WMRK		0x144 /* FIFO transmit water mark */
+#define FEC_R_BOUND		0x14c /* FIFO receive bound reg */
+#define FEC_R_FSTART		0x150 /* FIFO receive start reg */
+#define FEC_R_DES_START		0x180 /* Receive descriptor ring */
+#define FEC_X_DES_START		0x184 /* Transmit descriptor ring */
+#define FEC_R_BUFF_SIZE		0x188 /* Maximum receive buff size */
 
 #else
 
-/*
- *	Define device register set address map.
- */
-typedef struct fec {
-	unsigned long	fec_ecntrl;		/* Ethernet control reg */
-	unsigned long	fec_ievent;		/* Interrupt even reg */
-	unsigned long	fec_imask;		/* Interrupt mask reg */
-	unsigned long	fec_ivec;		/* Interrupt vec status reg */
-	unsigned long	fec_r_des_active;	/* Receive descriptor reg */
-	unsigned long	fec_x_des_active;	/* Transmit descriptor reg */
-	unsigned long	fec_reserved1[10];
-	unsigned long	fec_mii_data;		/* MII manage frame reg */
-	unsigned long	fec_mii_speed;		/* MII speed control reg */
-	unsigned long	fec_reserved2[17];
-	unsigned long	fec_r_bound;		/* FIFO receive bound reg */
-	unsigned long	fec_r_fstart;		/* FIFO receive start reg */
-	unsigned long	fec_reserved3[4];
-	unsigned long	fec_x_wmrk;		/* FIFO transmit water mark */
-	unsigned long	fec_reserved4;
-	unsigned long	fec_x_fstart;		/* FIFO transmit start reg */
-	unsigned long	fec_reserved5[21];
-	unsigned long	fec_r_cntrl;		/* Receive control reg */
-	unsigned long	fec_max_frm_len;	/* Maximum frame length reg */
-	unsigned long	fec_reserved6[14];
-	unsigned long	fec_x_cntrl;		/* Transmit Control reg */
-	unsigned long	fec_reserved7[158];
-	unsigned long	fec_addr_low;		/* Low 32bits MAC address */
-	unsigned long	fec_addr_high;		/* High 16bits MAC address */
-	unsigned long	fec_grp_hash_table_high;/* High 32bits hash table */
-	unsigned long	fec_grp_hash_table_low;	/* Low 32bits hash table */
-	unsigned long	fec_r_des_start;	/* Receive descriptor ring */
-	unsigned long	fec_x_des_start;	/* Transmit descriptor ring */
-	unsigned long	fec_r_buff_size;	/* Maximum receive buff size */
-	unsigned long	reserved8[9];
-	unsigned long	fec_fifo_ram[112];	/* FIFO RAM buffer */
-} fec_t;
+#define FEC_ECNTRL;		0x000 /* Ethernet control reg */
+#define FEC_IEVENT;		0x004 /* Interrupt even reg */
+#define FEC_IMASK;		0x008 /* Interrupt mask reg */
+#define FEC_IVEC;		0x00c /* Interrupt vec status reg */
+#define FEC_R_DES_ACTIVE;	0x010 /* Receive descriptor reg */
+#define FEC_X_DES_ACTIVE;	0x01c /* Transmit descriptor reg */
+#define FEC_MII_DATA		0x040 /* MII manage frame reg */
+#define FEC_MII_SPEED		0x044 /* MII speed control reg */
+#define FEC_R_BOUND		0x08c /* FIFO receive bound reg */
+#define FEC_R_FSTART		0x090 /* FIFO receive start reg */
+#define FEC_X_WMRK		0x0a4 /* FIFO transmit water mark */
+#define FEC_X_FSTART		0x0ac /* FIFO transmit start reg */
+#define FEC_R_CNTRL		0x104 /* Receive control reg */
+#define FEC_MAX_FRM_LEN		0x108 /* Maximum frame length reg */
+#define FEC_X_CNTRL		0x144 /* Transmit Control reg */
+#define FEC_ADDR_LOW		0x3c0 /* Low 32bits MAC address */
+#define FEC_ADDR_HIGH		0x3c4 /* High 16bits MAC address */
+#define FEC_GRP_HASH_TABLE_HIGH	0x3c8 /* High 32bits hash table */
+#define FEC_GRP_HASH_TABLE_LOW	0x3cc /* Low 32bits hash table */
+#define FEC_R_DES_START		0x3d0 /* Receive descriptor ring */
+#define FEC_X_DES_START		0x3d4 /* Transmit descriptor ring */
+#define FEC_R_BUFF_SIZE		0x3d8 /* Maximum receive buff size */
+#define FEC_FIFO_RAM		0x400 /* FIFO RAM buffer */
 
 #endif /* CONFIG_M5272 */
 
-- 
1.6.2.1

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |

From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] gianfar:don't add FCB length to hard_header_len
Date: Thu, 24 May 2012 09:16:50 -0700
Message-ID: <1337876210.5070.4.camel@joe2Laptop>
References: <1337677248-27792-1-git-send-email-b06378@freescale.com>
	 <20120522.151830.2018953337014839778.davem@davemloft.net>
	 <4FBE4E02.1070306@computer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, b06378@freescale.com,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: Jan Ceuleers <jan.ceuleers@computer.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:51917 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752761Ab2EXQQx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2012 12:16:53 -0400
In-Reply-To: <4FBE4E02.1070306@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-24 at 17:04 +0200, Jan Ceuleers wrote:
> On 05/22/2012 09:18 PM, David Miller wrote:
> > From: Jiajun Wu <b06378@freescale.com>
> > Date: Tue, 22 May 2012 17:00:48 +0800
> > 
> >> FCB(Frame Control Block) isn't the part of netdev hard header.
> >> Add FCB to hard_header_len will make GRO fail at MAC comparision stage.
> >>
> >> Signed-off-by: Jiajun Wu <b06378@freescale.com>
> > 
> > Applied, thanks.
> > 
> > Someone needs to go through this driver when net-next opens up
> > and fix all of the indentation in this driver.
> 
> May I give that a go?

I have scripts that automate most of this.
I don't have the card though.

Maybe this is a starting point?
It doesn't fix most 80 column warnings.

 drivers/net/ethernet/freescale/gianfar.c         |  299 +++++++++++-----------
 drivers/net/ethernet/freescale/gianfar_ethtool.c |  131 +++++-----
 drivers/net/ethernet/freescale/gianfar_ptp.c     |    8 +-
 drivers/net/ethernet/freescale/gianfar_sysfs.c   |    2 +-
 4 files changed, 225 insertions(+), 215 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 1adb024..b1985aa 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -87,10 +87,10 @@
 #include <linux/in.h>
 #include <linux/net_tstamp.h>
 
-#include <asm/io.h>
+#include <linux/io.h>
 #include <asm/reg.h>
 #include <asm/irq.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 #include <linux/module.h>
 #include <linux/dma-mapping.h>
 #include <linux/crc32.h>
@@ -114,7 +114,7 @@ static void gfar_timeout(struct net_device *dev);
 static int gfar_close(struct net_device *dev);
 struct sk_buff *gfar_new_skb(struct net_device *dev);
 static void gfar_new_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
-		struct sk_buff *skb);
+			   struct sk_buff *skb);
 static int gfar_set_mac_address(struct net_device *dev);
 static int gfar_change_mtu(struct net_device *dev, int new_mtu);
 static irqreturn_t gfar_error(int irq, void *dev_id);
@@ -251,9 +251,9 @@ static int gfar_alloc_skb_resources(struct net_device *ndev)
 
 	/* Allocate memory for the buffer descriptors */
 	vaddr = dma_alloc_coherent(dev,
-			sizeof(struct txbd8) * priv->total_tx_ring_size +
-			sizeof(struct rxbd8) * priv->total_rx_ring_size,
-			&addr, GFP_KERNEL);
+				   sizeof(struct txbd8) * priv->total_tx_ring_size +
+				   sizeof(struct rxbd8) * priv->total_rx_ring_size,
+				   &addr, GFP_KERNEL);
 	if (!vaddr) {
 		netif_err(priv, ifup, ndev,
 			  "Could not allocate buffer descriptors!\n");
@@ -266,8 +266,8 @@ static int gfar_alloc_skb_resources(struct net_device *ndev)
 		tx_queue->tx_bd_dma_base = addr;
 		tx_queue->dev = ndev;
 		/* enet DMA only understands physical addresses */
-		addr    += sizeof(struct txbd8) *tx_queue->tx_ring_size;
-		vaddr   += sizeof(struct txbd8) *tx_queue->tx_ring_size;
+		addr    += sizeof(struct txbd8) * tx_queue->tx_ring_size;
+		vaddr   += sizeof(struct txbd8) * tx_queue->tx_ring_size;
 	}
 
 	/* Start the rx descriptor ring where the tx ring leaves off */
@@ -276,15 +276,16 @@ static int gfar_alloc_skb_resources(struct net_device *ndev)
 		rx_queue->rx_bd_base = vaddr;
 		rx_queue->rx_bd_dma_base = addr;
 		rx_queue->dev = ndev;
-		addr    += sizeof (struct rxbd8) * rx_queue->rx_ring_size;
-		vaddr   += sizeof (struct rxbd8) * rx_queue->rx_ring_size;
+		addr    += sizeof(struct rxbd8) * rx_queue->rx_ring_size;
+		vaddr   += sizeof(struct rxbd8) * rx_queue->rx_ring_size;
 	}
 
 	/* Setup the skbuff rings */
 	for (i = 0; i < priv->num_tx_queues; i++) {
 		tx_queue = priv->tx_queue[i];
 		tx_queue->tx_skbuff = kmalloc(sizeof(*tx_queue->tx_skbuff) *
-				  tx_queue->tx_ring_size, GFP_KERNEL);
+					      tx_queue->tx_ring_size,
+					      GFP_KERNEL);
 		if (!tx_queue->tx_skbuff) {
 			netif_err(priv, ifup, ndev,
 				  "Could not allocate tx_skbuff\n");
@@ -298,7 +299,8 @@ static int gfar_alloc_skb_resources(struct net_device *ndev)
 	for (i = 0; i < priv->num_rx_queues; i++) {
 		rx_queue = priv->rx_queue[i];
 		rx_queue->rx_skbuff = kmalloc(sizeof(*rx_queue->rx_skbuff) *
-				  rx_queue->rx_ring_size, GFP_KERNEL);
+					      rx_queue->rx_ring_size,
+					      GFP_KERNEL);
 
 		if (!rx_queue->rx_skbuff) {
 			netif_err(priv, ifup, ndev,
@@ -327,13 +329,13 @@ static void gfar_init_tx_rx_base(struct gfar_private *priv)
 	int i;
 
 	baddr = &regs->tbase0;
-	for(i = 0; i < priv->num_tx_queues; i++) {
+	for (i = 0; i < priv->num_tx_queues; i++) {
 		gfar_write(baddr, priv->tx_queue[i]->tx_bd_dma_base);
 		baddr	+= 2;
 	}
 
 	baddr = &regs->rbase0;
-	for(i = 0; i < priv->num_rx_queues; i++) {
+	for (i = 0; i < priv->num_rx_queues; i++) {
 		gfar_write(baddr, priv->rx_queue[i]->rx_bd_dma_base);
 		baddr   += 2;
 	}
@@ -501,7 +503,7 @@ void unlock_tx_qs(struct gfar_private *priv)
 static bool gfar_is_vlan_on(struct gfar_private *priv)
 {
 	return (priv->ndev->features & NETIF_F_HW_VLAN_RX) ||
-	       (priv->ndev->features & NETIF_F_HW_VLAN_TX);
+		(priv->ndev->features & NETIF_F_HW_VLAN_TX);
 }
 
 /* Returns 1 if incoming frames use an FCB */
@@ -554,7 +556,7 @@ static void enable_napi(struct gfar_private *priv)
 }
 
 static int gfar_parse_group(struct device_node *np,
-		struct gfar_private *priv, const char *model)
+			    struct gfar_private *priv, const char *model)
 {
 	u32 *queue_mask;
 
@@ -563,14 +565,14 @@ static int gfar_parse_group(struct device_node *np,
 		return -ENOMEM;
 
 	priv->gfargrp[priv->num_grps].interruptTransmit =
-			irq_of_parse_and_map(np, 0);
+		irq_of_parse_and_map(np, 0);
 
 	/* If we aren't the FEC we have multiple interrupts */
 	if (model && strcasecmp(model, "FEC")) {
 		priv->gfargrp[priv->num_grps].interruptReceive =
 			irq_of_parse_and_map(np, 1);
 		priv->gfargrp[priv->num_grps].interruptError =
-			irq_of_parse_and_map(np,2);
+			irq_of_parse_and_map(np, 2);
 		if (priv->gfargrp[priv->num_grps].interruptTransmit == NO_IRQ ||
 		    priv->gfargrp[priv->num_grps].interruptReceive  == NO_IRQ ||
 		    priv->gfargrp[priv->num_grps].interruptError    == NO_IRQ)
@@ -580,15 +582,15 @@ static int gfar_parse_group(struct device_node *np,
 	priv->gfargrp[priv->num_grps].grp_id = priv->num_grps;
 	priv->gfargrp[priv->num_grps].priv = priv;
 	spin_lock_init(&priv->gfargrp[priv->num_grps].grplock);
-	if(priv->mode == MQ_MG_MODE) {
-		queue_mask = (u32 *)of_get_property(np,
-					"fsl,rx-bit-map", NULL);
+	if (priv->mode == MQ_MG_MODE) {
+		queue_mask = (u32 *)of_get_property(np, "fsl,rx-bit-map", NULL);
 		priv->gfargrp[priv->num_grps].rx_bit_map =
-			queue_mask ?  *queue_mask :(DEFAULT_MAPPING >> priv->num_grps);
-		queue_mask = (u32 *)of_get_property(np,
-					"fsl,tx-bit-map", NULL);
+			queue_mask ? *queue_mask
+				   : (DEFAULT_MAPPING >> priv->num_grps);
+		queue_mask = (u32 *)of_get_property(np, "fsl,tx-bit-map", NULL);
 		priv->gfargrp[priv->num_grps].tx_bit_map =
-			queue_mask ? *queue_mask : (DEFAULT_MAPPING >> priv->num_grps);
+			queue_mask ? *queue_mask
+				   : (DEFAULT_MAPPING >> priv->num_grps);
 	} else {
 		priv->gfargrp[priv->num_grps].rx_bit_map = 0xFF;
 		priv->gfargrp[priv->num_grps].tx_bit_map = 0xFF;
@@ -673,12 +675,12 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 	} else {
 		priv->mode = SQ_SG_MODE;
 		err = gfar_parse_group(np, priv, model);
-		if(err)
+		if (err)
 			goto err_grp_init;
 	}
 
 	for (i = 0; i < priv->num_tx_queues; i++)
-	       priv->tx_queue[i] = NULL;
+		priv->tx_queue[i] = NULL;
 	for (i = 0; i < priv->num_rx_queues; i++)
 		priv->rx_queue[i] = NULL;
 
@@ -781,7 +783,7 @@ err_grp_init:
 }
 
 static int gfar_hwtstamp_ioctl(struct net_device *netdev,
-			struct ifreq *ifr, int cmd)
+			       struct ifreq *ifr, int cmd)
 {
 	struct hwtstamp_config config;
 	struct gfar_private *priv = netdev_priv(netdev);
@@ -936,22 +938,22 @@ static void gfar_detect_errata(struct gfar_private *priv)
 
 	/* MPC8313 Rev 2.0 and higher; All MPC837x */
 	if ((pvr == 0x80850010 && mod == 0x80b0 && rev >= 0x0020) ||
-			(pvr == 0x80861010 && (mod & 0xfff9) == 0x80c0))
+	    (pvr == 0x80861010 && (mod & 0xfff9) == 0x80c0))
 		priv->errata |= GFAR_ERRATA_74;
 
 	/* MPC8313 and MPC837x all rev */
 	if ((pvr == 0x80850010 && mod == 0x80b0) ||
-			(pvr == 0x80861010 && (mod & 0xfff9) == 0x80c0))
+	    (pvr == 0x80861010 && (mod & 0xfff9) == 0x80c0))
 		priv->errata |= GFAR_ERRATA_76;
 
 	/* MPC8313 and MPC837x all rev */
 	if ((pvr == 0x80850010 && mod == 0x80b0) ||
-			(pvr == 0x80861010 && (mod & 0xfff9) == 0x80c0))
+	    (pvr == 0x80861010 && (mod & 0xfff9) == 0x80c0))
 		priv->errata |= GFAR_ERRATA_A002;
 
 	/* MPC8313 Rev < 2.0, MPC8548 rev 2.0 */
 	if ((pvr == 0x80850010 && mod == 0x80b0 && rev < 0x0020) ||
-			(pvr == 0x80210020 && mod == 0x8030 && rev == 0x0020))
+	    (pvr == 0x80210020 && mod == 0x8030 && rev == 0x0020))
 		priv->errata |= GFAR_ERRATA_12;
 
 	if (priv->errata)
@@ -1026,7 +1028,8 @@ static int gfar_probe(struct platform_device *ofdev)
 
 	/* Register for napi ...We are registering NAPI for each grp */
 	for (i = 0; i < priv->num_grps; i++)
-		netif_napi_add(dev, &priv->gfargrp[i].napi, gfar_poll, GFAR_DEV_WEIGHT);
+		netif_napi_add(dev, &priv->gfargrp[i].napi,
+			       gfar_poll, GFAR_DEV_WEIGHT);
 
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_CSUM) {
 		dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_SG |
@@ -1081,7 +1084,7 @@ static int gfar_probe(struct platform_device *ofdev)
 		priv->padding = 0;
 
 	if (dev->features & NETIF_F_IP_CSUM ||
-			priv->device_flags & FSL_GIANFAR_DEV_HAS_TIMER)
+	    priv->device_flags & FSL_GIANFAR_DEV_HAS_TIMER)
 		dev->hard_header_len += GMAC_FCB_LEN;
 
 	/* Program the isrg regs only if number of grps > 1 */
@@ -1099,11 +1102,11 @@ static int gfar_probe(struct platform_device *ofdev)
 	/* Need to reverse the bit maps as  bit_map's MSB is q0
 	 * but, for_each_set_bit parses from right to left, which
 	 * basically reverses the queue numbers */
-	for (i = 0; i< priv->num_grps; i++) {
+	for (i = 0; i < priv->num_grps; i++) {
 		priv->gfargrp[i].tx_bit_map = reverse_bitmap(
-				priv->gfargrp[i].tx_bit_map, MAX_TX_QS);
+			priv->gfargrp[i].tx_bit_map, MAX_TX_QS);
 		priv->gfargrp[i].rx_bit_map = reverse_bitmap(
-				priv->gfargrp[i].rx_bit_map, MAX_RX_QS);
+			priv->gfargrp[i].rx_bit_map, MAX_RX_QS);
 	}
 
 	/* Calculate RSTAT, TSTAT, RQUEUE and TQUEUE values,
@@ -1111,7 +1114,7 @@ static int gfar_probe(struct platform_device *ofdev)
 	for (grp_idx = 0; grp_idx < priv->num_grps; grp_idx++) {
 		priv->gfargrp[grp_idx].num_rx_queues = 0x0;
 		for_each_set_bit(i, &priv->gfargrp[grp_idx].rx_bit_map,
-				priv->num_rx_queues) {
+				 priv->num_rx_queues) {
 			priv->gfargrp[grp_idx].num_rx_queues++;
 			priv->rx_queue[i]->grp = &priv->gfargrp[grp_idx];
 			rstat = rstat | (RSTAT_CLEAR_RHALT >> i);
@@ -1119,7 +1122,7 @@ static int gfar_probe(struct platform_device *ofdev)
 		}
 		priv->gfargrp[grp_idx].num_tx_queues = 0x0;
 		for_each_set_bit(i, &priv->gfargrp[grp_idx].tx_bit_map,
-				priv->num_tx_queues) {
+				 priv->num_tx_queues) {
 			priv->gfargrp[grp_idx].num_tx_queues++;
 			priv->tx_queue[i]->grp = &priv->gfargrp[grp_idx];
 			tstat = tstat | (TSTAT_CLEAR_THALT >> i);
@@ -1127,7 +1130,7 @@ static int gfar_probe(struct platform_device *ofdev)
 		}
 		priv->gfargrp[grp_idx].rstat = rstat;
 		priv->gfargrp[grp_idx].tstat = tstat;
-		rstat = tstat =0;
+		rstat = tstat = 0;
 	}
 
 	gfar_write(&regs->rqueue, rqueue);
@@ -1152,7 +1155,7 @@ static int gfar_probe(struct platform_device *ofdev)
 	/* always enable rx filer*/
 	priv->rx_filer_enable = 1;
 	/* Enable most messages by default */
-	priv->msg_enable = (NETIF_MSG_IFUP << 1 ) - 1;
+	priv->msg_enable = (NETIF_MSG_IFUP << 1) - 1;
 
 	/* Carrier starts down, phylib will bring it up */
 	netif_carrier_off(dev);
@@ -1165,7 +1168,7 @@ static int gfar_probe(struct platform_device *ofdev)
 	}
 
 	device_init_wakeup(&dev->dev,
-		priv->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
+			   priv->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
 
 	/* fill out IRQ number and name fields */
 	for (i = 0; i < priv->num_grps; i++) {
@@ -1176,8 +1179,9 @@ static int gfar_probe(struct platform_device *ofdev)
 				dev->name, "_g", '0' + i, "_rx");
 			sprintf(priv->gfargrp[i].int_name_er, "%s%s%c%s",
 				dev->name, "_g", '0' + i, "_er");
-		} else
+		} else {
 			strcpy(priv->gfargrp[i].int_name_tx, dev->name);
+		}
 	}
 
 	/* Initialize the filer table */
@@ -1195,7 +1199,7 @@ static int gfar_probe(struct platform_device *ofdev)
 	for (i = 0; i < priv->num_rx_queues; i++)
 		netdev_info(dev, "RX BD ring size for Q[%d]: %d\n",
 			    i, priv->rx_queue[i]->rx_ring_size);
-	for(i = 0; i < priv->num_tx_queues; i++)
+	for (i = 0; i < priv->num_tx_queues; i++)
 		netdev_info(dev, "TX BD ring size for Q[%d]: %d\n",
 			    i, priv->tx_queue[i]->tx_ring_size);
 
@@ -1355,7 +1359,7 @@ static int gfar_restore(struct device *dev)
 	return 0;
 }
 
-static struct dev_pm_ops gfar_pm_ops = {
+static const struct dev_pm_ops gfar_pm_ops = {
 	.suspend = gfar_suspend,
 	.resume = gfar_resume,
 	.freeze = gfar_suspend,
@@ -1393,9 +1397,9 @@ static phy_interface_t gfar_get_interface(struct net_device *dev)
 	}
 
 	if (ecntrl & ECNTRL_REDUCED_MODE) {
-		if (ecntrl & ECNTRL_REDUCED_MII_MODE)
+		if (ecntrl & ECNTRL_REDUCED_MII_MODE) {
 			return PHY_INTERFACE_MODE_RMII;
-		else {
+		} else {
 			phy_interface_t interface = priv->interface;
 
 			/*
@@ -1468,8 +1472,7 @@ static void gfar_configure_serdes(struct net_device *dev)
 	struct phy_device *tbiphy;
 
 	if (!priv->tbi_node) {
-		dev_warn(&dev->dev, "error: SGMII mode requires that the "
-				    "device tree specify a tbi-handle\n");
+		dev_warn(&dev->dev, "error: SGMII mode requires that the device tree specify a tbi-handle\n");
 		return;
 	}
 
@@ -1492,11 +1495,11 @@ static void gfar_configure_serdes(struct net_device *dev)
 	phy_write(tbiphy, MII_TBICON, TBICON_CLK_SELECT);
 
 	phy_write(tbiphy, MII_ADVERTISE,
-			ADVERTISE_1000XFULL | ADVERTISE_1000XPAUSE |
-			ADVERTISE_1000XPSE_ASYM);
+		  ADVERTISE_1000XFULL | ADVERTISE_1000XPAUSE |
+		  ADVERTISE_1000XPSE_ASYM);
 
 	phy_write(tbiphy, MII_BMCR, BMCR_ANENABLE |
-			BMCR_ANRESTART | BMCR_FULLDPLX | BMCR_SPEED1000);
+		  BMCR_ANRESTART | BMCR_FULLDPLX | BMCR_SPEED1000);
 }
 
 static void init_registers(struct net_device *dev)
@@ -1536,7 +1539,7 @@ static void init_registers(struct net_device *dev)
 
 	/* Zero out the rmon mib registers if it has them */
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_RMON) {
-		memset_io(&(regs->rmon), 0, sizeof (struct rmon_mib));
+		memset_io(&(regs->rmon), 0, sizeof(struct rmon_mib));
 
 		/* Mask off the CAM interrupts */
 		gfar_write(&regs->rmon.cam1, 0xffffffff);
@@ -1602,8 +1605,9 @@ static void gfar_halt_nodisable(struct net_device *dev)
 		gfar_write(&regs->dmactrl, tempval);
 
 		do {
-			ret = spin_event_timeout(((gfar_read(&regs->ievent) &
-				 (IEVENT_GRSC | IEVENT_GTSC)) ==
+			ret = spin_event_timeout(
+				((gfar_read(&regs->ievent) &
+				  (IEVENT_GRSC | IEVENT_GTSC)) ==
 				 (IEVENT_GRSC | IEVENT_GTSC)), 1000000, 0);
 			if (!ret && !(gfar_read(&regs->ievent) & IEVENT_GRSC))
 				ret = __gfar_is_rx_idle(priv);
@@ -1660,7 +1664,7 @@ void stop_gfar(struct net_device *dev)
 	} else {
 		for (i = 0; i < priv->num_grps; i++)
 			free_irq(priv->gfargrp[i].interruptTransmit,
-					&priv->gfargrp[i]);
+				 &priv->gfargrp[i]);
 	}
 
 	free_skb_resources(priv);
@@ -1679,13 +1683,13 @@ static void free_skb_tx_queue(struct gfar_priv_tx_q *tx_queue)
 			continue;
 
 		dma_unmap_single(&priv->ofdev->dev, txbdp->bufPtr,
-				txbdp->length, DMA_TO_DEVICE);
+				 txbdp->length, DMA_TO_DEVICE);
 		txbdp->lstatus = 0;
 		for (j = 0; j < skb_shinfo(tx_queue->tx_skbuff[i])->nr_frags;
-				j++) {
+		     j++) {
 			txbdp++;
 			dma_unmap_page(&priv->ofdev->dev, txbdp->bufPtr,
-					txbdp->length, DMA_TO_DEVICE);
+				       txbdp->length, DMA_TO_DEVICE);
 		}
 		txbdp++;
 		dev_kfree_skb_any(tx_queue->tx_skbuff[i]);
@@ -1705,8 +1709,8 @@ static void free_skb_rx_queue(struct gfar_priv_rx_q *rx_queue)
 	for (i = 0; i < rx_queue->rx_ring_size; i++) {
 		if (rx_queue->rx_skbuff[i]) {
 			dma_unmap_single(&priv->ofdev->dev,
-					rxbdp->bufPtr, priv->rx_buffer_size,
-					DMA_FROM_DEVICE);
+					 rxbdp->bufPtr, priv->rx_buffer_size,
+					 DMA_FROM_DEVICE);
 			dev_kfree_skb_any(rx_queue->rx_skbuff[i]);
 			rx_queue->rx_skbuff[i] = NULL;
 		}
@@ -1730,22 +1734,22 @@ static void free_skb_resources(struct gfar_private *priv)
 		struct netdev_queue *txq;
 		tx_queue = priv->tx_queue[i];
 		txq = netdev_get_tx_queue(tx_queue->dev, tx_queue->qindex);
-		if(tx_queue->tx_skbuff)
+		if (tx_queue->tx_skbuff)
 			free_skb_tx_queue(tx_queue);
 		netdev_tx_reset_queue(txq);
 	}
 
 	for (i = 0; i < priv->num_rx_queues; i++) {
 		rx_queue = priv->rx_queue[i];
-		if(rx_queue->rx_skbuff)
+		if (rx_queue->rx_skbuff)
 			free_skb_rx_queue(rx_queue);
 	}
 
 	dma_free_coherent(&priv->ofdev->dev,
-			sizeof(struct txbd8) * priv->total_tx_ring_size +
-			sizeof(struct rxbd8) * priv->total_rx_ring_size,
-			priv->tx_queue[0]->tx_bd_base,
-			priv->tx_queue[0]->tx_bd_dma_base);
+			  sizeof(struct txbd8) * priv->total_tx_ring_size +
+			  sizeof(struct rxbd8) * priv->total_rx_ring_size,
+			  priv->tx_queue[0]->tx_bd_base,
+			  priv->tx_queue[0]->tx_bd_dma_base);
 	skb_queue_purge(&priv->rx_recycle);
 }
 
@@ -1784,7 +1788,7 @@ void gfar_start(struct net_device *dev)
 }
 
 void gfar_configure_coalescing(struct gfar_private *priv,
-	unsigned long tx_mask, unsigned long rx_mask)
+			       unsigned long tx_mask, unsigned long rx_mask)
 {
 	struct gfar __iomem *regs = priv->gfargrp[0].regs;
 	u32 __iomem *baddr;
@@ -1794,11 +1798,11 @@ void gfar_configure_coalescing(struct gfar_private *priv,
 	 * multiple queues, there's only single reg to program
 	 */
 	gfar_write(&regs->txic, 0);
-	if(likely(priv->tx_queue[0]->txcoalescing))
+	if (likely(priv->tx_queue[0]->txcoalescing))
 		gfar_write(&regs->txic, priv->tx_queue[0]->txic);
 
 	gfar_write(&regs->rxic, 0);
-	if(unlikely(priv->rx_queue[0]->rxcoalescing))
+	if (unlikely(priv->rx_queue[0]->rxcoalescing))
 		gfar_write(&regs->rxic, priv->rx_queue[0]->rxic);
 
 	if (priv->mode == MQ_MG_MODE) {
@@ -1831,30 +1835,34 @@ static int register_grp_irqs(struct gfar_priv_grp *grp)
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
 		/* Install our interrupt handlers for Error,
 		 * Transmit, and Receive */
-		if ((err = request_irq(grp->interruptError, gfar_error, 0,
-				grp->int_name_er,grp)) < 0) {
+		err = request_irq(grp->interruptError, gfar_error, 0,
+				  grp->int_name_er, grp);
+		if (err < 0) {
 			netif_err(priv, intr, dev, "Can't get IRQ %d\n",
 				  grp->interruptError);
 
 			goto err_irq_fail;
 		}
 
-		if ((err = request_irq(grp->interruptTransmit, gfar_transmit,
-				0, grp->int_name_tx, grp)) < 0) {
+		err = request_irq(grp->interruptTransmit, gfar_transmit,
+				  0, grp->int_name_tx, grp);
+		if (err < 0) {
 			netif_err(priv, intr, dev, "Can't get IRQ %d\n",
 				  grp->interruptTransmit);
 			goto tx_irq_fail;
 		}
 
-		if ((err = request_irq(grp->interruptReceive, gfar_receive, 0,
-				grp->int_name_rx, grp)) < 0) {
+		err = request_irq(grp->interruptReceive, gfar_receive, 0,
+				  grp->int_name_rx, grp);
+		if (err < 0) {
 			netif_err(priv, intr, dev, "Can't get IRQ %d\n",
 				  grp->interruptReceive);
 			goto rx_irq_fail;
 		}
 	} else {
-		if ((err = request_irq(grp->interruptTransmit, gfar_interrupt, 0,
-				grp->int_name_tx, grp)) < 0) {
+		err = request_irq(grp->interruptTransmit, gfar_interrupt, 0,
+				  grp->int_name_tx, grp);
+		if (err < 0) {
 			netif_err(priv, intr, dev, "Can't get IRQ %d\n",
 				  grp->interruptTransmit);
 			goto err_irq_fail;
@@ -1880,11 +1888,11 @@ int startup_gfar(struct net_device *ndev)
 	int err, i, j;
 
 	for (i = 0; i < priv->num_grps; i++) {
-		regs= priv->gfargrp[i].regs;
+		regs = priv->gfargrp[i].regs;
 		gfar_write(&regs->imask, IMASK_INIT_CLEAR);
 	}
 
-	regs= priv->gfargrp[0].regs;
+	regs = priv->gfargrp[0].regs;
 	err = gfar_alloc_skb_resources(ndev);
 	if (err)
 		return err;
@@ -1960,7 +1968,7 @@ static inline struct txfcb *gfar_add_fcb(struct sk_buff *skb)
 }
 
 static inline void gfar_tx_checksum(struct sk_buff *skb, struct txfcb *fcb,
-		int fcb_length)
+				    int fcb_length)
 {
 	u8 flags = 0;
 
@@ -1975,8 +1983,9 @@ static inline void gfar_tx_checksum(struct sk_buff *skb, struct txfcb *fcb,
 	if (ip_hdr(skb)->protocol == IPPROTO_UDP) {
 		flags |= TXFCB_UDP;
 		fcb->phcs = udp_hdr(skb)->check;
-	} else
+	} else {
 		fcb->phcs = tcp_hdr(skb)->check;
+	}
 
 	/* l3os is the distance between the start of the
 	 * frame (skb->data) and the start of the IP hdr.
@@ -1988,14 +1997,14 @@ static inline void gfar_tx_checksum(struct sk_buff *skb, struct txfcb *fcb,
 	fcb->flags = flags;
 }
 
-void inline gfar_tx_vlan(struct sk_buff *skb, struct txfcb *fcb)
+inline void gfar_tx_vlan(struct sk_buff *skb, struct txfcb *fcb)
 {
 	fcb->flags |= TXFCB_VLN;
 	fcb->vlctl = vlan_tx_tag_get(skb);
 }
 
 static inline struct txbd8 *skip_txbd(struct txbd8 *bdp, int stride,
-			       struct txbd8 *base, int ring_size)
+				      struct txbd8 *base, int ring_size)
 {
 	struct txbd8 *new_bd = bdp + stride;
 
@@ -2003,7 +2012,7 @@ static inline struct txbd8 *skip_txbd(struct txbd8 *bdp, int stride,
 }
 
 static inline struct txbd8 *next_txbd(struct txbd8 *bdp, struct txbd8 *base,
-		int ring_size)
+				      int ring_size)
 {
 	return skip_txbd(bdp, 1, base, ring_size);
 }
@@ -2029,8 +2038,8 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * before start of transmission.
 	 */
 	if (unlikely(gfar_has_errata(priv, GFAR_ERRATA_76) &&
-			skb->ip_summed == CHECKSUM_PARTIAL &&
-			skb->len > 2500)) {
+		     skb->ip_summed == CHECKSUM_PARTIAL &&
+		     skb->len > 2500)) {
 		int ret;
 
 		ret = skb_checksum_help(skb);
@@ -2046,16 +2055,16 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* check if time stamp should be generated */
 	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP &&
-			priv->hwts_tx_en)) {
+		     priv->hwts_tx_en)) {
 		do_tstamp = 1;
 		fcb_length = GMAC_FCB_LEN + GMAC_TXPAL_LEN;
 	}
 
 	/* make space for additional header when fcb is needed */
 	if (((skb->ip_summed == CHECKSUM_PARTIAL) ||
-			vlan_tx_tag_present(skb) ||
-			unlikely(do_tstamp)) &&
-			(skb_headroom(skb) < fcb_length)) {
+	     vlan_tx_tag_present(skb) ||
+	     unlikely(do_tstamp)) &&
+	    (skb_headroom(skb) < fcb_length)) {
 		struct sk_buff *skb_new;
 
 		skb_new = skb_realloc_headroom(skb, fcb_length);
@@ -2099,12 +2108,12 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Time stamp insertion requires one additional TxBD */
 	if (unlikely(do_tstamp))
 		txbdp_tstamp = txbdp = next_txbd(txbdp, base,
-				tx_queue->tx_ring_size);
+						 tx_queue->tx_ring_size);
 
 	if (nr_frags == 0) {
 		if (unlikely(do_tstamp))
 			txbdp_tstamp->lstatus |= BD_LFLAG(TXBD_LAST |
-					TXBD_INTERRUPT);
+							  TXBD_INTERRUPT);
 		else
 			lstatus |= BD_LFLAG(TXBD_LAST | TXBD_INTERRUPT);
 	} else {
@@ -2146,8 +2155,8 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (CHECKSUM_PARTIAL == skb->ip_summed) {
 		fcb = gfar_add_fcb(skb);
 		/* as specified by errata */
-		if (unlikely(gfar_has_errata(priv, GFAR_ERRATA_12)
-			     && ((unsigned long)fcb % 0x20) > 0x18)) {
+		if (unlikely(gfar_has_errata(priv, GFAR_ERRATA_12) &&
+			     ((unsigned long)fcb % 0x20) > 0x18)) {
 			__skb_pull(skb, GMAC_FCB_LEN);
 			skb_checksum_help(skb);
 		} else {
@@ -2175,7 +2184,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	txbdp_start->bufPtr = dma_map_single(&priv->ofdev->dev, skb->data,
-			skb_headlen(skb), DMA_TO_DEVICE);
+					     skb_headlen(skb), DMA_TO_DEVICE);
 
 	/*
 	 * If time stamping is requested one additional TxBD must be set up. The
@@ -2186,7 +2195,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(do_tstamp)) {
 		txbdp_tstamp->bufPtr = txbdp_start->bufPtr + fcb_length;
 		txbdp_tstamp->lstatus |= BD_LFLAG(TXBD_READY) |
-				(skb_headlen(skb) - fcb_length);
+			(skb_headlen(skb) - fcb_length);
 		lstatus |= BD_LFLAG(TXBD_CRC | TXBD_READY) | GMAC_FCB_LEN;
 	} else {
 		lstatus |= BD_LFLAG(TXBD_CRC | TXBD_READY) | skb_headlen(skb);
@@ -2361,8 +2370,8 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
 	frame_size += priv->padding;
 
 	tempsize =
-	    (frame_size & ~(INCREMENTAL_BUFFER_SIZE - 1)) +
-	    INCREMENTAL_BUFFER_SIZE;
+		(frame_size & ~(INCREMENTAL_BUFFER_SIZE - 1)) +
+		INCREMENTAL_BUFFER_SIZE;
 
 	/* Only stop and start the controller if it isn't already
 	 * stopped, and we changed something */
@@ -2382,7 +2391,7 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
 	tempval = gfar_read(&regs->maccfg2);
 
 	if (priv->rx_buffer_size > DEFAULT_RX_BUFFER_SIZE ||
-			gfar_has_errata(priv, GFAR_ERRATA_74))
+	    gfar_has_errata(priv, GFAR_ERRATA_74))
 		tempval |= (MACCFG2_HUGEFRAME | MACCFG2_LENGTHCHECK);
 	else
 		tempval &= ~(MACCFG2_HUGEFRAME | MACCFG2_LENGTHCHECK);
@@ -2403,7 +2412,7 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
 static void gfar_reset_task(struct work_struct *work)
 {
 	struct gfar_private *priv = container_of(work, struct gfar_private,
-			reset_task);
+						 reset_task);
 	struct net_device *dev = priv->ndev;
 
 	if (dev->flags & IFF_UP) {
@@ -2430,7 +2439,7 @@ static void gfar_align_skb(struct sk_buff *skb)
 	 * as many bytes as needed to align the data properly
 	 */
 	skb_reserve(skb, RXBUF_ALIGNMENT -
-		(((unsigned long) skb->data) & (RXBUF_ALIGNMENT - 1)));
+		    (((unsigned long) skb->data) & (RXBUF_ALIGNMENT - 1)));
 }
 
 /* Interrupt Handler for Transmit complete */
@@ -2479,21 +2488,22 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 
 		/* Only clean completed frames */
 		if ((lstatus & BD_LFLAG(TXBD_READY)) &&
-				(lstatus & BD_LENGTH_MASK))
+		    (lstatus & BD_LENGTH_MASK))
 			break;
 
 		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS)) {
 			next = next_txbd(bdp, base, tx_ring_size);
 			buflen = next->length + GMAC_FCB_LEN + GMAC_TXPAL_LEN;
-		} else
+		} else {
 			buflen = bdp->length;
+		}
 
 		dma_unmap_single(&priv->ofdev->dev, bdp->bufPtr,
-				buflen, DMA_TO_DEVICE);
+				 buflen, DMA_TO_DEVICE);
 
 		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS)) {
 			struct skb_shared_hwtstamps shhwtstamps;
-			u64 *ns = (u64*) (((u32)skb->data + 0x10) & ~0x7);
+			u64 *ns = (u64 *)(((u32)skb->data + 0x10) & ~0x7);
 			memset(&shhwtstamps, 0, sizeof(shhwtstamps));
 			shhwtstamps.hwtstamp = ns_to_ktime(*ns);
 			skb_pull(skb, GMAC_FCB_LEN + GMAC_TXPAL_LEN);
@@ -2507,9 +2517,9 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 
 		for (i = 0; i < frags; i++) {
 			dma_unmap_page(&priv->ofdev->dev,
-					bdp->bufPtr,
-					bdp->length,
-					DMA_TO_DEVICE);
+				       bdp->bufPtr,
+				       bdp->length,
+				       DMA_TO_DEVICE);
 			bdp->lstatus &= BD_LFLAG(TXBD_WRAP);
 			bdp = next_txbd(bdp, base, tx_ring_size);
 		}
@@ -2521,12 +2531,13 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 		 * we add this skb back into the pool, if it's the right size
 		 */
 		if (skb_queue_len(&priv->rx_recycle) < rx_queue->rx_ring_size &&
-				skb_recycle_check(skb, priv->rx_buffer_size +
-					RXBUF_ALIGNMENT)) {
+		    skb_recycle_check(skb, priv->rx_buffer_size +
+				      RXBUF_ALIGNMENT)) {
 			gfar_align_skb(skb);
 			skb_queue_head(&priv->rx_recycle, skb);
-		} else
+		} else {
 			dev_kfree_skb_any(skb);
+		}
 
 		tx_queue->tx_skbuff[skb_dirtytx] = NULL;
 
@@ -2579,7 +2590,7 @@ static irqreturn_t gfar_transmit(int irq, void *grp_id)
 }
 
 static void gfar_new_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
-		struct sk_buff *skb)
+			   struct sk_buff *skb)
 {
 	struct net_device *dev = rx_queue->dev;
 	struct gfar_private *priv = netdev_priv(dev);
@@ -2590,7 +2601,7 @@ static void gfar_new_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
 	gfar_init_rxbdp(rx_queue, bdp, buf);
 }
 
-static struct sk_buff * gfar_alloc_skb(struct net_device *dev)
+static struct sk_buff *gfar_alloc_skb(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct sk_buff *skb = NULL;
@@ -2604,7 +2615,7 @@ static struct sk_buff * gfar_alloc_skb(struct net_device *dev)
 	return skb;
 }
 
-struct sk_buff * gfar_new_skb(struct net_device *dev)
+struct sk_buff *gfar_new_skb(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct sk_buff *skb = NULL;
@@ -2695,7 +2706,7 @@ static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 	/* Get receive timestamp from the skb */
 	if (priv->hwts_rx_en) {
 		struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
-		u64 *ns = (u64 *) skb->data;
+		u64 *ns = (u64 *)skb->data;
 		memset(shhwtstamps, 0, sizeof(*shhwtstamps));
 		shhwtstamps->hwtstamp = ns_to_ktime(*ns);
 	}
@@ -2757,15 +2768,15 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 		skb = rx_queue->rx_skbuff[rx_queue->skb_currx];
 
 		dma_unmap_single(&priv->ofdev->dev, bdp->bufPtr,
-				priv->rx_buffer_size, DMA_FROM_DEVICE);
+				 priv->rx_buffer_size, DMA_FROM_DEVICE);
 
 		if (unlikely(!(bdp->status & RXBD_ERR) &&
-				bdp->length > priv->rx_buffer_size))
+			     bdp->length > priv->rx_buffer_size))
 			bdp->status = RXBD_LARGE;
 
 		/* We drop the frame if we failed to allocate a new buffer */
 		if (unlikely(!newskb || !(bdp->status & RXBD_LAST) ||
-				 bdp->status & RXBD_ERR)) {
+			     bdp->status & RXBD_ERR)) {
 			count_errors(bdp->status, dev);
 
 			if (unlikely(!newskb))
@@ -2784,7 +2795,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 				rx_queue->stats.rx_bytes += pkt_len;
 				skb_record_rx_queue(skb, rx_queue->qindex);
 				gfar_process_frame(dev, skb, amount_pull,
-						&rx_queue->grp->napi);
+						   &rx_queue->grp->napi);
 
 			} else {
 				netif_warn(priv, rx_err, dev, "Missing skb!\n");
@@ -2804,8 +2815,8 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 
 		/* update to point at the next skb */
 		rx_queue->skb_currx =
-		    (rx_queue->skb_currx + 1) &
-		    RX_RING_MOD_MASK(rx_queue->rx_ring_size);
+			(rx_queue->skb_currx + 1) &
+			RX_RING_MOD_MASK(rx_queue->rx_ring_size);
 	}
 
 	/* Update the current rxbd pointer to be the next one */
@@ -2816,8 +2827,8 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 
 static int gfar_poll(struct napi_struct *napi, int budget)
 {
-	struct gfar_priv_grp *gfargrp = container_of(napi,
-			struct gfar_priv_grp, napi);
+	struct gfar_priv_grp *gfargrp =
+		container_of(napi, struct gfar_priv_grp, napi);
 	struct gfar_private *priv = gfargrp->priv;
 	struct gfar __iomem *regs = gfargrp->regs;
 	struct gfar_priv_tx_q *tx_queue = NULL;
@@ -2847,11 +2858,11 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 
 			tx_cleaned += gfar_clean_tx_ring(tx_queue);
 			rx_cleaned_per_queue = gfar_clean_rx_ring(rx_queue,
-							budget_per_queue);
+								  budget_per_queue);
 			rx_cleaned += rx_cleaned_per_queue;
-			if(rx_cleaned_per_queue < budget_per_queue) {
-				left_over_budget = left_over_budget +
-					(budget_per_queue - rx_cleaned_per_queue);
+			if (rx_cleaned_per_queue < budget_per_queue) {
+				left_over_budget += (budget_per_queue -
+						     rx_cleaned_per_queue);
 				set_bit(i, &serviced_queues);
 				num_queues--;
 			}
@@ -2871,8 +2882,8 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 
 		/* If we are coalescing interrupts, update the timer */
 		/* Otherwise, clear it */
-		gfar_configure_coalescing(priv,
-				gfargrp->rx_bit_map, gfargrp->tx_bit_map);
+		gfar_configure_coalescing(priv, gfargrp->rx_bit_map,
+					  gfargrp->tx_bit_map);
 	}
 
 	return rx_cleaned;
@@ -2896,7 +2907,7 @@ static void gfar_netpoll(struct net_device *dev)
 			disable_irq(priv->gfargrp[i].interruptReceive);
 			disable_irq(priv->gfargrp[i].interruptError);
 			gfar_interrupt(priv->gfargrp[i].interruptTransmit,
-						&priv->gfargrp[i]);
+				       &priv->gfargrp[i]);
 			enable_irq(priv->gfargrp[i].interruptError);
 			enable_irq(priv->gfargrp[i].interruptReceive);
 			enable_irq(priv->gfargrp[i].interruptTransmit);
@@ -2905,7 +2916,7 @@ static void gfar_netpoll(struct net_device *dev)
 		for (i = 0; i < priv->num_grps; i++) {
 			disable_irq(priv->gfargrp[i].interruptTransmit);
 			gfar_interrupt(priv->gfargrp[i].interruptTransmit,
-						&priv->gfargrp[i]);
+				       &priv->gfargrp[i]);
 			enable_irq(priv->gfargrp[i].interruptTransmit);
 		}
 	}
@@ -2972,15 +2983,15 @@ static void adjust_link(struct net_device *dev)
 			new_state = 1;
 			switch (phydev->speed) {
 			case 1000:
-				tempval =
-				    ((tempval & ~(MACCFG2_IF)) | MACCFG2_GMII);
+				tempval = ((tempval & ~(MACCFG2_IF)) |
+					   MACCFG2_GMII);
 
 				ecntrl &= ~(ECNTRL_R100);
 				break;
 			case 100:
 			case 10:
-				tempval =
-				    ((tempval & ~(MACCFG2_IF)) | MACCFG2_MII);
+				tempval = ((tempval & ~(MACCFG2_IF)) |
+					   MACCFG2_MII);
 
 				/* Reduced mode distinguishes
 				 * between 10 and 100 */
@@ -3102,8 +3113,9 @@ static void gfar_set_multi(struct net_device *dev)
 			if (idx < em_num) {
 				gfar_set_mac_for_addr(dev, idx, ha->addr);
 				idx++;
-			} else
+			} else {
 				gfar_set_hash_for_addr(dev, ha->addr);
+			}
 		}
 	}
 }
@@ -3116,7 +3128,7 @@ static void gfar_clear_exact_match(struct net_device *dev)
 	int idx;
 	static const u8 zero_arr[ETH_ALEN] = {0, 0, 0, 0, 0, 0};
 
-	for(idx = 1;idx < GFAR_EM_NUM + 1;idx++)
+	for (idx = 1; idx < GFAR_EM_NUM + 1; idx++)
 		gfar_set_mac_for_addr(dev, idx, zero_arr);
 }
 
@@ -3169,11 +3181,11 @@ static void gfar_set_mac_for_addr(struct net_device *dev, int num,
 	for (idx = 0; idx < ETH_ALEN; idx++)
 		tmpbuf[ETH_ALEN - 1 - idx] = addr[idx];
 
-	gfar_write(macptr, *((u32 *) (tmpbuf)));
+	gfar_write(macptr, *((u32 *)(tmpbuf)));
 
-	tempval = *((u32 *) (tmpbuf + 4));
+	tempval = *((u32 *)(tmpbuf + 4));
 
-	gfar_write(macptr+1, tempval);
+	gfar_write(macptr + 1, tempval);
 }
 
 /* GFAR error interrupt handler */
@@ -3181,7 +3193,7 @@ static irqreturn_t gfar_error(int irq, void *grp_id)
 {
 	struct gfar_priv_grp *gfargrp = grp_id;
 	struct gfar __iomem *regs = gfargrp->regs;
-	struct gfar_private *priv= gfargrp->priv;
+	struct gfar_private *priv = gfargrp->priv;
 	struct net_device *dev = priv->ndev;
 
 	/* Save ievent for future reference */
@@ -3256,8 +3268,7 @@ static irqreturn_t gfar_error(int irq, void *grp_id)
 	return IRQ_HANDLED;
 }
 
-static struct of_device_id gfar_match[] =
-{
+static struct of_device_id gfar_match[] = {
 	{
 		.type = "network",
 		.compatible = "gianfar",
diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 8a02557..26a2fa2 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -31,12 +31,12 @@
 #include <linux/spinlock.h>
 #include <linux/mm.h>
 
-#include <asm/io.h>
+#include <linux/io.h>
 #include <asm/irq.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 #include <linux/module.h>
 #include <linux/crc32.h>
-#include <asm/types.h>
+#include <linux/types.h>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
@@ -51,8 +51,8 @@ extern int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit
 #define GFAR_MAX_COAL_USECS 0xffff
 #define GFAR_MAX_COAL_FRAMES 0xff
 static void gfar_fill_stats(struct net_device *dev, struct ethtool_stats *dummy,
-		     u64 * buf);
-static void gfar_gstrings(struct net_device *dev, u32 stringset, u8 * buf);
+		     u64 *buf);
+static void gfar_gstrings(struct net_device *dev, u32 stringset, u8 *buf);
 static int gfar_gcoalesce(struct net_device *dev, struct ethtool_coalesce *cvals);
 static int gfar_scoalesce(struct net_device *dev, struct ethtool_coalesce *cvals);
 static void gfar_gringparam(struct net_device *dev, struct ethtool_ringparam *rvals);
@@ -122,7 +122,7 @@ static const char stat_gstrings[][ETH_GSTRING_LEN] = {
 
 /* Fill in a buffer with the strings which correspond to the
  * stats */
-static void gfar_gstrings(struct net_device *dev, u32 stringset, u8 * buf)
+static void gfar_gstrings(struct net_device *dev, u32 stringset, u8 *buf)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 
@@ -130,23 +130,23 @@ static void gfar_gstrings(struct net_device *dev, u32 stringset, u8 * buf)
 		memcpy(buf, stat_gstrings, GFAR_STATS_LEN * ETH_GSTRING_LEN);
 	else
 		memcpy(buf, stat_gstrings,
-				GFAR_EXTRA_STATS_LEN * ETH_GSTRING_LEN);
+		       GFAR_EXTRA_STATS_LEN * ETH_GSTRING_LEN);
 }
 
 /* Fill in an array of 64-bit statistics from various sources.
  * This array will be appended to the end of the ethtool_stats
  * structure, and returned to user space
  */
-static void gfar_fill_stats(struct net_device *dev, struct ethtool_stats *dummy, u64 * buf)
+static void gfar_fill_stats(struct net_device *dev, struct ethtool_stats *dummy, u64 *buf)
 {
 	int i;
 	struct gfar_private *priv = netdev_priv(dev);
 	struct gfar __iomem *regs = priv->gfargrp[0].regs;
-	u64 *extra = (u64 *) & priv->extra_stats;
+	u64 *extra = (u64 *)&priv->extra_stats;
 
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_RMON) {
-		u32 __iomem *rmon = (u32 __iomem *) &regs->rmon;
-		struct gfar_stats *stats = (struct gfar_stats *) buf;
+		u32 __iomem *rmon = (u32 __iomem *)&regs->rmon;
+		struct gfar_stats *stats = (struct gfar_stats *)buf;
 
 		for (i = 0; i < GFAR_RMON_LEN; i++)
 			stats->rmon[i] = (u64) gfar_read(&rmon[i]);
@@ -174,8 +174,8 @@ static int gfar_sset_count(struct net_device *dev, int sset)
 }
 
 /* Fills in the drvinfo structure with some basic info */
-static void gfar_gdrvinfo(struct net_device *dev, struct
-	      ethtool_drvinfo *drvinfo)
+static void gfar_gdrvinfo(struct net_device *dev,
+			  struct ethtool_drvinfo *drvinfo)
 {
 	strncpy(drvinfo->driver, DRV_NAME, GFAR_INFOSTR_LEN);
 	strncpy(drvinfo->version, gfar_driver_version, GFAR_INFOSTR_LEN);
@@ -222,7 +222,7 @@ static int gfar_gsettings(struct net_device *dev, struct ethtool_cmd *cmd)
 /* Return the length of the register structure */
 static int gfar_reglen(struct net_device *dev)
 {
-	return sizeof (struct gfar);
+	return sizeof(struct gfar);
 }
 
 /* Return a dump of the GFAR register space */
@@ -230,10 +230,10 @@ static void gfar_get_regs(struct net_device *dev, struct ethtool_regs *regs, voi
 {
 	int i;
 	struct gfar_private *priv = netdev_priv(dev);
-	u32 __iomem *theregs = (u32 __iomem *) priv->gfargrp[0].regs;
-	u32 *buf = (u32 *) regbuf;
+	u32 __iomem *theregs = (u32 __iomem *)priv->gfargrp[0].regs;
+	u32 *buf = (u32 *)regbuf;
 
-	for (i = 0; i < sizeof (struct gfar) / sizeof (u32); i++)
+	for (i = 0; i < sizeof(struct gfar) / sizeof(u32); i++)
 		buf[i] = gfar_read(&theregs[i]);
 }
 
@@ -499,7 +499,7 @@ static int gfar_sringparam(struct net_device *dev, struct ethtool_ringparam *rva
 
 		for (i = 0; i < priv->num_rx_queues; i++)
 			gfar_clean_rx_ring(priv->rx_queue[i],
-					priv->rx_queue[i]->rx_ring_size);
+					   priv->rx_queue[i]->rx_ring_size);
 
 		/* Now we take down the rings to rebuild them */
 		stop_gfar(dev);
@@ -548,7 +548,7 @@ int gfar_set_features(struct net_device *dev, netdev_features_t features)
 
 		for (i = 0; i < priv->num_rx_queues; i++)
 			gfar_clean_rx_ring(priv->rx_queue[i],
-					priv->rx_queue[i]->rx_ring_size);
+					   priv->rx_queue[i]->rx_ring_size);
 
 		/* Now we take down the rings to rebuild them */
 		stop_gfar(dev);
@@ -608,12 +608,12 @@ static int gfar_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 }
 #endif
 
-static void ethflow_to_filer_rules (struct gfar_private *priv, u64 ethflow)
+static void ethflow_to_filer_rules(struct gfar_private *priv, u64 ethflow)
 {
 	u32 fcr = 0x0, fpr = FPR_FILER_MASK;
 
 	if (ethflow & RXH_L2DA) {
-		fcr = RQFCR_PID_DAH |RQFCR_CMP_NOMATCH |
+		fcr = RQFCR_PID_DAH | RQFCR_CMP_NOMATCH |
 			RQFCR_HASH | RQFCR_AND | RQFCR_HASHTBL_0;
 		priv->ftp_rqfpr[priv->cur_filer_idx] = fpr;
 		priv->ftp_rqfcr[priv->cur_filer_idx] = fcr;
@@ -705,16 +705,16 @@ static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow, u
 
 	switch (class) {
 	case TCP_V4_FLOW:
-		cmp_rqfpr = RQFPR_IPV4 |RQFPR_TCP;
+		cmp_rqfpr = RQFPR_IPV4 | RQFPR_TCP;
 		break;
 	case UDP_V4_FLOW:
-		cmp_rqfpr = RQFPR_IPV4 |RQFPR_UDP;
+		cmp_rqfpr = RQFPR_IPV4 | RQFPR_UDP;
 		break;
 	case TCP_V6_FLOW:
-		cmp_rqfpr = RQFPR_IPV6 |RQFPR_TCP;
+		cmp_rqfpr = RQFPR_IPV6 | RQFPR_TCP;
 		break;
 	case UDP_V6_FLOW:
-		cmp_rqfpr = RQFPR_IPV6 |RQFPR_UDP;
+		cmp_rqfpr = RQFPR_IPV6 | RQFPR_UDP;
 		break;
 	default:
 		pr_err("Right now this class is not supported\n");
@@ -727,7 +727,7 @@ static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow, u
 		local_rqfcr[j] = priv->ftp_rqfcr[i];
 		j--;
 		if ((priv->ftp_rqfcr[i] == (RQFCR_PID_PARSE |
-			RQFCR_CLE |RQFCR_AND)) &&
+			RQFCR_CLE | RQFCR_AND)) &&
 			(priv->ftp_rqfpr[i] == cmp_rqfpr))
 			break;
 	}
@@ -743,17 +743,17 @@ static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow, u
 	 */
 	for (l = i+1; l < MAX_FILER_IDX; l++) {
 		if ((priv->ftp_rqfcr[l] & RQFCR_CLE) &&
-			!(priv->ftp_rqfcr[l] & RQFCR_AND)) {
+		    !(priv->ftp_rqfcr[l] & RQFCR_AND)) {
 			priv->ftp_rqfcr[l] = RQFCR_CLE | RQFCR_CMP_EXACT |
 				RQFCR_HASHTBL_0 | RQFCR_PID_MASK;
 			priv->ftp_rqfpr[l] = FPR_FILER_MASK;
 			gfar_write_filer(priv, l, priv->ftp_rqfcr[l],
-				priv->ftp_rqfpr[l]);
+					 priv->ftp_rqfpr[l]);
 			break;
 		}
 
 		if (!(priv->ftp_rqfcr[l] & RQFCR_CLE) &&
-			(priv->ftp_rqfcr[l] & RQFCR_AND))
+		    (priv->ftp_rqfcr[l] & RQFCR_AND))
 			continue;
 		else {
 			local_rqfpr[j] = priv->ftp_rqfpr[l];
@@ -773,7 +773,7 @@ static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow, u
 		priv->ftp_rqfpr[priv->cur_filer_idx] = local_rqfpr[k];
 		priv->ftp_rqfcr[priv->cur_filer_idx] = local_rqfcr[k];
 		gfar_write_filer(priv, priv->cur_filer_idx,
-				local_rqfcr[k], local_rqfpr[k]);
+				 local_rqfcr[k], local_rqfpr[k]);
 		if (!priv->cur_filer_idx)
 			break;
 		priv->cur_filer_idx = priv->cur_filer_idx - 1;
@@ -810,10 +810,10 @@ static int gfar_check_filer_hardware(struct gfar_private *priv)
 		i &= RCTRL_PRSDEP_MASK | RCTRL_PRSFM;
 		if (i == (RCTRL_PRSDEP_MASK | RCTRL_PRSFM)) {
 			netdev_info(priv->ndev,
-					"Receive Queue Filtering enabled\n");
+				    "Receive Queue Filtering enabled\n");
 		} else {
 			netdev_warn(priv->ndev,
-					"Receive Queue Filtering disabled\n");
+				    "Receive Queue Filtering disabled\n");
 			return -EOPNOTSUPP;
 		}
 	}
@@ -823,10 +823,10 @@ static int gfar_check_filer_hardware(struct gfar_private *priv)
 		i &= RCTRL_PRSDEP_MASK;
 		if (i == RCTRL_PRSDEP_MASK) {
 			netdev_info(priv->ndev,
-					"Receive Queue Filtering enabled\n");
+				    "Receive Queue Filtering enabled\n");
 		} else {
 			netdev_warn(priv->ndev,
-					"Receive Queue Filtering disabled\n");
+				    "Receive Queue Filtering disabled\n");
 			return -EOPNOTSUPP;
 		}
 	}
@@ -977,7 +977,7 @@ static void gfar_set_user_ip(struct ethtool_usrip4_spec *value,
 	gfar_set_attribute(value->tos, mask->tos, RQFCR_PID_TOS, tab);
 	gfar_set_attribute(value->proto, mask->proto, RQFCR_PID_L4P, tab);
 	gfar_set_attribute(value->l4_4_bytes, mask->l4_4_bytes, RQFCR_PID_ARB,
-			tab);
+			   tab);
 
 }
 
@@ -1016,8 +1016,8 @@ static void gfar_set_ether(struct ethhdr *value, struct ethhdr *mask,
 	if (!is_broadcast_ether_addr(mask->h_dest)) {
 
 		/* Special for destination is limited broadcast */
-		if ((is_broadcast_ether_addr(value->h_dest)
-				&& is_zero_ether_addr(mask->h_dest))) {
+		if (is_broadcast_ether_addr(value->h_dest) &&
+		    is_zero_ether_addr(mask->h_dest)) {
 			gfar_set_parse_bits(RQFPR_EBC, RQFPR_EBC, tab);
 		} else {
 
@@ -1090,34 +1090,34 @@ static int gfar_convert_to_filer(struct ethtool_rx_flow_spec *rule,
 	switch (rule->flow_type & ~FLOW_EXT) {
 	case TCP_V4_FLOW:
 		gfar_set_parse_bits(RQFPR_IPV4 | RQFPR_TCP | vlan,
-				RQFPR_IPV4 | RQFPR_TCP | vlan_mask, tab);
+				    RQFPR_IPV4 | RQFPR_TCP | vlan_mask, tab);
 		gfar_set_basic_ip(&rule->h_u.tcp_ip4_spec,
-				&rule->m_u.tcp_ip4_spec, tab);
+				  &rule->m_u.tcp_ip4_spec, tab);
 		break;
 	case UDP_V4_FLOW:
 		gfar_set_parse_bits(RQFPR_IPV4 | RQFPR_UDP | vlan,
-				RQFPR_IPV4 | RQFPR_UDP | vlan_mask, tab);
+				    RQFPR_IPV4 | RQFPR_UDP | vlan_mask, tab);
 		gfar_set_basic_ip(&rule->h_u.udp_ip4_spec,
-				&rule->m_u.udp_ip4_spec, tab);
+				  &rule->m_u.udp_ip4_spec, tab);
 		break;
 	case SCTP_V4_FLOW:
 		gfar_set_parse_bits(RQFPR_IPV4 | vlan, RQFPR_IPV4 | vlan_mask,
-				tab);
+				    tab);
 		gfar_set_attribute(132, 0, RQFCR_PID_L4P, tab);
-		gfar_set_basic_ip((struct ethtool_tcpip4_spec *) &rule->h_u,
-				(struct ethtool_tcpip4_spec *) &rule->m_u, tab);
+		gfar_set_basic_ip((struct ethtool_tcpip4_spec *)&rule->h_u,
+				  (struct ethtool_tcpip4_spec *)&rule->m_u, tab);
 		break;
 	case IP_USER_FLOW:
 		gfar_set_parse_bits(RQFPR_IPV4 | vlan, RQFPR_IPV4 | vlan_mask,
-				tab);
-		gfar_set_user_ip((struct ethtool_usrip4_spec *) &rule->h_u,
-				(struct ethtool_usrip4_spec *) &rule->m_u, tab);
+				    tab);
+		gfar_set_user_ip((struct ethtool_usrip4_spec *)&rule->h_u,
+				 (struct ethtool_usrip4_spec *)&rule->m_u, tab);
 		break;
 	case ETHER_FLOW:
 		if (vlan)
 			gfar_set_parse_bits(vlan, vlan_mask, tab);
-		gfar_set_ether((struct ethhdr *) &rule->h_u,
-				(struct ethhdr *) &rule->m_u, tab);
+		gfar_set_ether((struct ethhdr *)&rule->h_u,
+			       (struct ethhdr *)&rule->m_u, tab);
 		break;
 	default:
 		return -1;
@@ -1207,7 +1207,7 @@ static int gfar_expand_filer_entries(u32 begin, u32 length,
 		return -EINVAL;
 
 	gfar_copy_filer_entries(&(tab->fe[begin + length]), &(tab->fe[begin]),
-			tab->index - length + 1);
+				tab->index - length + 1);
 
 	tab->index += length;
 	return 0;
@@ -1271,10 +1271,10 @@ static void gfar_cluster_filer(struct filer_table *tab)
 				break;
 
 			gfar_copy_filer_entries(&(tab->fe[iend + 1]),
-					&(tab->fe[jend + 1]), jend - j);
+						&(tab->fe[jend + 1]), jend - j);
 
 			if (gfar_trim_filer_entries(jend - 1,
-					jend + (jend - j), tab) == -EINVAL)
+						    jend + (jend - j), tab) == -EINVAL)
 				return;
 
 			/* Mask out cluster bit */
@@ -1364,8 +1364,8 @@ static void gfar_sort_mask_table(struct gfar_mask_entry *mask_table,
 			old_first = mask_table[start].start + 1;
 			old_last = mask_table[i - 1].end;
 			sort(mask_table + start, size,
-					sizeof(struct gfar_mask_entry),
-					gfar_comp, &gfar_swap);
+			     sizeof(struct gfar_mask_entry),
+			     gfar_comp, &gfar_swap);
 
 			/* Toggle order for every block. This makes the
 			 * thing more efficient! */
@@ -1378,12 +1378,11 @@ static void gfar_sort_mask_table(struct gfar_mask_entry *mask_table,
 			new_last = mask_table[i - 1].end;
 
 			gfar_swap_bits(&temp_table->fe[new_first],
-					&temp_table->fe[old_first],
-					&temp_table->fe[new_last],
-					&temp_table->fe[old_last],
-					RQFCR_QUEUE | RQFCR_CLE |
-						RQFCR_RJE | RQFCR_AND
-					);
+				       &temp_table->fe[old_first],
+				       &temp_table->fe[new_last],
+				       &temp_table->fe[old_last],
+				       RQFCR_QUEUE | RQFCR_CLE |
+				       RQFCR_RJE | RQFCR_AND);
 
 			start = i;
 			size = 0;
@@ -1432,7 +1431,7 @@ static int gfar_optimize_filer_masks(struct filer_table *tab)
 	for (i = 0; i < and_index; i++) {
 		size = mask_table[i].end - mask_table[i].start + 1;
 		gfar_copy_filer_entries(&(tab->fe[j]),
-				&(temp_table->fe[mask_table[i].start]), size);
+					&(temp_table->fe[mask_table[i].start]), size);
 		j += size;
 	}
 
@@ -1494,15 +1493,15 @@ static int gfar_check_capability(struct ethtool_rx_flow_spec *flow,
 	if (flow->flow_type & FLOW_EXT)	{
 		if (~flow->m_ext.data[0] || ~flow->m_ext.data[1])
 			netdev_warn(priv->ndev,
-					"User-specific data not supported!\n");
+				    "User-specific data not supported!\n");
 		if (~flow->m_ext.vlan_etype)
 			netdev_warn(priv->ndev,
-					"VLAN-etype not supported!\n");
+				    "VLAN-etype not supported!\n");
 	}
 	if (flow->flow_type == IP_USER_FLOW)
 		if (flow->h_u.usr_ip4_spec.ip_ver != ETH_RX_NFC_IP4)
 			netdev_warn(priv->ndev,
-					"IP-Version differing from IPv4 not supported!\n");
+				    "IP-Version differing from IPv4 not supported!\n");
 
 	return 0;
 }
@@ -1599,8 +1598,8 @@ static int gfar_add_cls(struct gfar_private *priv,
 			}
 			if (comp->fs.location == flow->location) {
 				netdev_err(priv->ndev,
-						"Rule not added: ID %d not free!\n",
-					flow->location);
+					   "Rule not added: ID %d not free!\n",
+					   flow->location);
 				ret = -EBUSY;
 				goto clean_mem;
 			}
diff --git a/drivers/net/ethernet/freescale/gianfar_ptp.c b/drivers/net/ethernet/freescale/gianfar_ptp.c
index c08e5d4..3f7b81d 100644
--- a/drivers/net/ethernet/freescale/gianfar_ptp.c
+++ b/drivers/net/ethernet/freescale/gianfar_ptp.c
@@ -268,11 +268,11 @@ static irqreturn_t isr(int irq, void *priv)
 		ptp_clock_event(etsects->clock, &event);
 	}
 
-	if (ack) {
-		gfar_write(&etsects->regs->tmr_tevent, ack);
-		return IRQ_HANDLED;
-	} else
+	if (!ack)
 		return IRQ_NONE;
+
+	gfar_write(&etsects->regs->tmr_tevent, ack);
+	return IRQ_HANDLED;
 }
 
 /*
diff --git a/drivers/net/ethernet/freescale/gianfar_sysfs.c b/drivers/net/ethernet/freescale/gianfar_sysfs.c
index cd14a4d..3a1fa70 100644
--- a/drivers/net/ethernet/freescale/gianfar_sysfs.c
+++ b/drivers/net/ethernet/freescale/gianfar_sysfs.c
@@ -31,7 +31,7 @@
 #include <linux/mm.h>
 #include <linux/device.h>
 
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 #include <linux/module.h>
 
 #include "gianfar.h"

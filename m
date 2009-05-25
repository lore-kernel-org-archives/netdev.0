From: Yoshihiro Shimoda <shimoda.yoshihiro@renesas.com>
Subject: [PATCH 4/5] net: sh_eth: CPU dependency code collect to
 "struct sh_eth_cpu_data"
Date: Mon, 25 May 2009 18:54:21 +0900
Message-ID: <4A1A6ACD.1020502@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SH-Linux <linux-sh@vger.kernel.org>,
	Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This improves readability by collecting CPU dependency code.

Signed-off-by: Yoshihiro Shimoda <shimoda.yoshihiro@renesas.com>
Signed-off-by: Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>
---
 drivers/net/sh_eth.c |  411 ++++++++++++++++++++++++++++++++------------------
 drivers/net/sh_eth.h |  226 +++++++++++++++-------------
 2 files changed, 386 insertions(+), 251 deletions(-)

diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 728c419..19571f7 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -2,7 +2,7 @@
  *  SuperH Ethernet device driver
  *
  *  Copyright (C) 2006-2008 Nobuhiro Iwamatsu
- *  Copyright (C) 2008 Renesas Solutions Corp.
+ *  Copyright (C) 2008-2009 Renesas Solutions Corp.
  *
  *  This program is free software; you can redistribute it and/or modify it
  *  under the terms and conditions of the GNU General Public License,
@@ -33,6 +33,176 @@

 #include "sh_eth.h"

+/* There is CPU dependent code */
+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
+#define SH_ETH_HAS_TSU	1
+static void sh_eth_chip_reset(struct net_device *ndev)
+{
+	/* reset device */
+	ctrl_outl(ARSTR_ARSTR, ARSTR);
+	mdelay(1);
+}
+
+static void sh_eth_reset(struct net_device *ndev)
+{
+	u32 ioaddr = ndev->base_addr;
+	int cnt = 100;
+
+	ctrl_outl(EDSR_ENALL, ioaddr + EDSR);
+	ctrl_outl(ctrl_inl(ioaddr + EDMR) | EDMR_SRST, ioaddr + EDMR);
+	while (cnt > 0) {
+		if (!(ctrl_inl(ioaddr + EDMR) & 0x3))
+			break;
+		mdelay(1);
+		cnt--;
+	}
+	if (cnt < 0)
+		printk(KERN_ERR "Device reset fail\n");
+
+	/* Table Init */
+	ctrl_outl(0x0, ioaddr + TDLAR);
+	ctrl_outl(0x0, ioaddr + TDFAR);
+	ctrl_outl(0x0, ioaddr + TDFXR);
+	ctrl_outl(0x0, ioaddr + TDFFR);
+	ctrl_outl(0x0, ioaddr + RDLAR);
+	ctrl_outl(0x0, ioaddr + RDFAR);
+	ctrl_outl(0x0, ioaddr + RDFXR);
+	ctrl_outl(0x0, ioaddr + RDFFR);
+}
+
+static void sh_eth_set_duplex(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	u32 ioaddr = ndev->base_addr;
+
+	if (mdp->duplex) /* Full */
+		ctrl_outl(ctrl_inl(ioaddr + ECMR) | ECMR_DM, ioaddr + ECMR);
+	else		/* Half */
+		ctrl_outl(ctrl_inl(ioaddr + ECMR) & ~ECMR_DM, ioaddr + ECMR);
+}
+
+static void sh_eth_set_rate(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	u32 ioaddr = ndev->base_addr;
+
+	switch (mdp->speed) {
+	case 10: /* 10BASE */
+		ctrl_outl(GECMR_10, ioaddr + GECMR);
+		break;
+	case 100:/* 100BASE */
+		ctrl_outl(GECMR_100, ioaddr + GECMR);
+		break;
+	case 1000: /* 1000BASE */
+		ctrl_outl(GECMR_1000, ioaddr + GECMR);
+		break;
+	default:
+		break;
+	}
+}
+
+/* sh7763 */
+static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
+	.chip_reset	= sh_eth_chip_reset,
+	.set_duplex	= sh_eth_set_duplex,
+	.set_rate	= sh_eth_set_rate,
+
+	.ecsr_value	= ECSR_ICD | ECSR_MPD,
+	.ecsipr_value	= ECSIPR_LCHNGIP | ECSIPR_ICDIP | ECSIPR_MPDIP,
+	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
+
+	.tx_check	= EESR_TC1 | EESR_FTC,
+	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT | \
+			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE | \
+			  EESR_ECI,
+	.tx_error_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_TDE | \
+			  EESR_TFE,
+
+	.apr		= 1,
+	.mpr		= 1,
+	.tpauser	= 1,
+	.bculr		= 1,
+	.hw_swap	= 1,
+	.rpadir		= 1,
+	.no_trimd	= 1,
+	.no_ade		= 1,
+};
+
+#elif defined(CONFIG_CPU_SUBTYPE_SH7619)
+#define SH_ETH_RESET_DEFAULT	1
+static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
+	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
+
+	.apr		= 1,
+	.mpr		= 1,
+	.tpauser	= 1,
+	.hw_swap	= 1,
+};
+#elif defined(CONFIG_CPU_SUBTYPE_SH7710) || defined(CONFIG_CPU_SUBTYPE_SH7712)
+#define SH_ETH_RESET_DEFAULT	1
+#define SH_ETH_HAS_TSU	1
+static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
+	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
+};
+#endif
+
+static void sh_eth_set_default_cpu_data(struct sh_eth_cpu_data *cd)
+{
+	if (!cd->ecsr_value)
+		cd->ecsr_value = DEFAULT_ECSR_INIT;
+
+	if (!cd->ecsipr_value)
+		cd->ecsipr_value = DEFAULT_ECSIPR_INIT;
+
+	if (!cd->fcftr_value)
+		cd->fcftr_value = DEFAULT_FIFO_F_D_RFF | \
+				  DEFAULT_FIFO_F_D_RFD;
+
+	if (!cd->fdr_value)
+		cd->fdr_value = DEFAULT_FDR_INIT;
+
+	if (!cd->rmcr_value)
+		cd->rmcr_value = DEFAULT_RMCR_VALUE;
+
+	if (!cd->tx_check)
+		cd->tx_check = DEFAULT_TX_CHECK;
+
+	if (!cd->eesr_err_check)
+		cd->eesr_err_check = DEFAULT_EESR_ERR_CHECK;
+
+	if (!cd->tx_error_check)
+		cd->tx_error_check = DEFAULT_TX_ERROR_CHECK;
+}
+
+#if defined(SH_ETH_RESET_DEFAULT)
+/* Chip Reset */
+static void sh_eth_reset(struct net_device *ndev)
+{
+	u32 ioaddr = ndev->base_addr;
+
+	ctrl_outl(ctrl_inl(ioaddr + EDMR) | EDMR_SRST, ioaddr + EDMR);
+	mdelay(3);
+	ctrl_outl(ctrl_inl(ioaddr + EDMR) & ~EDMR_SRST, ioaddr + EDMR);
+}
+#endif
+
+#if defined(CONFIG_CPU_SH4)
+static void sh_eth_set_receive_align(struct sk_buff *skb)
+{
+	int reserve;
+
+	reserve = SH4_SKB_RX_ALIGN - ((u32)skb->data & (SH4_SKB_RX_ALIGN - 1));
+	if (reserve)
+		skb_reserve(skb, reserve);
+}
+#else
+static void sh_eth_set_receive_align(struct sk_buff *skb)
+{
+	skb_reserve(skb, SH2_SH3_SKB_RX_ALIGN);
+}
+#endif
+
+
 /* CPU <-> EDMAC endian convert */
 static inline __u32 cpu_to_edmac(struct sh_eth_private *mdp, u32 x)
 {
@@ -165,41 +335,6 @@ static struct mdiobb_ops bb_ops = {
 	.get_mdio_data = sh_get_mdio,
 };

-/* Chip Reset */
-static void sh_eth_reset(struct net_device *ndev)
-{
-	u32 ioaddr = ndev->base_addr;
-
-#if defined(CONFIG_CPU_SUBTYPE_SH7763)
-	int cnt = 100;
-
-	ctrl_outl(EDSR_ENALL, ioaddr + EDSR);
-	ctrl_outl(ctrl_inl(ioaddr + EDMR) | EDMR_SRST, ioaddr + EDMR);
-	while (cnt > 0) {
-		if (!(ctrl_inl(ioaddr + EDMR) & 0x3))
-			break;
-		mdelay(1);
-		cnt--;
-	}
-	if (cnt < 0)
-		printk(KERN_ERR "Device reset fail\n");
-
-	/* Table Init */
-	ctrl_outl(0x0, ioaddr + TDLAR);
-	ctrl_outl(0x0, ioaddr + TDFAR);
-	ctrl_outl(0x0, ioaddr + TDFXR);
-	ctrl_outl(0x0, ioaddr + TDFFR);
-	ctrl_outl(0x0, ioaddr + RDLAR);
-	ctrl_outl(0x0, ioaddr + RDFAR);
-	ctrl_outl(0x0, ioaddr + RDFXR);
-	ctrl_outl(0x0, ioaddr + RDFFR);
-#else
-	ctrl_outl(ctrl_inl(ioaddr + EDMR) | EDMR_SRST, ioaddr + EDMR);
-	mdelay(3);
-	ctrl_outl(ctrl_inl(ioaddr + EDMR) & ~EDMR_SRST, ioaddr + EDMR);
-#endif
-}
-
 /* free skb and descriptor buffer */
 static void sh_eth_ring_free(struct net_device *ndev)
 {
@@ -228,7 +363,7 @@ static void sh_eth_ring_free(struct net_device *ndev)
 /* format skb and descriptor buffer */
 static void sh_eth_ring_format(struct net_device *ndev)
 {
-	u32 ioaddr = ndev->base_addr, reserve = 0;
+	u32 ioaddr = ndev->base_addr;
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	int i;
 	struct sk_buff *skb;
@@ -253,14 +388,8 @@ static void sh_eth_ring_format(struct net_device *ndev)
 		dma_map_single(&ndev->dev, skb->tail, mdp->rx_buf_sz,
 				DMA_FROM_DEVICE);
 		skb->dev = ndev; /* Mark as being used by this device. */
-#if defined(CONFIG_CPU_SUBTYPE_SH7763)
-		reserve = SH7763_SKB_ALIGN
-			- ((uint32_t)skb->data & (SH7763_SKB_ALIGN-1));
-		if (reserve)
-			skb_reserve(skb, reserve);
-#else
-		skb_reserve(skb, RX_OFFSET);
-#endif
+		sh_eth_set_receive_align(skb);
+
 		/* RX descriptor */
 		rxdesc = &mdp->rx_ring[i];
 		rxdesc->addr = virt_to_phys(PTR_ALIGN(skb->data, 4));
@@ -321,7 +450,7 @@ static int sh_eth_ring_init(struct net_device *ndev)
 	mdp->rx_skbuff = kmalloc(sizeof(*mdp->rx_skbuff) * RX_RING_SIZE,
 				GFP_KERNEL);
 	if (!mdp->rx_skbuff) {
-		printk(KERN_ERR "%s: Cannot allocate Rx skb\n", ndev->name);
+		dev_err(&ndev->dev, "Cannot allocate Rx skb\n");
 		ret = -ENOMEM;
 		return ret;
 	}
@@ -329,7 +458,7 @@ static int sh_eth_ring_init(struct net_device *ndev)
 	mdp->tx_skbuff = kmalloc(sizeof(*mdp->tx_skbuff) * TX_RING_SIZE,
 				GFP_KERNEL);
 	if (!mdp->tx_skbuff) {
-		printk(KERN_ERR "%s: Cannot allocate Tx skb\n", ndev->name);
+		dev_err(&ndev->dev, "Cannot allocate Tx skb\n");
 		ret = -ENOMEM;
 		goto skb_ring_free;
 	}
@@ -340,8 +469,8 @@ static int sh_eth_ring_init(struct net_device *ndev)
 			GFP_KERNEL);

 	if (!mdp->rx_ring) {
-		printk(KERN_ERR "%s: Cannot allocate Rx Ring (size %d bytes)\n",
-			ndev->name, rx_ringsize);
+		dev_err(&ndev->dev, "Cannot allocate Rx Ring (size %d bytes)\n",
+			rx_ringsize);
 		ret = -ENOMEM;
 		goto desc_ring_free;
 	}
@@ -353,8 +482,8 @@ static int sh_eth_ring_init(struct net_device *ndev)
 	mdp->tx_ring = dma_alloc_coherent(NULL, tx_ringsize, &mdp->tx_desc_dma,
 			GFP_KERNEL);
 	if (!mdp->tx_ring) {
-		printk(KERN_ERR "%s: Cannot allocate Tx Ring (size %d bytes)\n",
-			ndev->name, tx_ringsize);
+		dev_err(&ndev->dev, "Cannot allocate Tx Ring (size %d bytes)\n",
+			tx_ringsize);
 		ret = -ENOMEM;
 		goto desc_ring_free;
 	}
@@ -384,44 +513,43 @@ static int sh_eth_dev_init(struct net_device *ndev)

 	/* Descriptor format */
 	sh_eth_ring_format(ndev);
-	ctrl_outl(RPADIR_INIT, ioaddr + RPADIR);
+	if (mdp->cd->rpadir)
+		ctrl_outl(mdp->cd->rpadir_value, ioaddr + RPADIR);

 	/* all sh_eth int mask */
 	ctrl_outl(0, ioaddr + EESIPR);

-#if defined(CONFIG_CPU_SUBTYPE_SH7763)
-	ctrl_outl(EDMR_EL, ioaddr + EDMR);
-#else
-	ctrl_outl(0, ioaddr + EDMR);	/* Endian change */
+#if defined(__LITTLE_ENDIAN__)
+	if (mdp->cd->hw_swap)
+		ctrl_outl(EDMR_EL, ioaddr + EDMR);
+	else
 #endif
+		ctrl_outl(0, ioaddr + EDMR);

 	/* FIFO size set */
-	ctrl_outl((FIFO_SIZE_T | FIFO_SIZE_R), ioaddr + FDR);
+	ctrl_outl(mdp->cd->fdr_value, ioaddr + FDR);
 	ctrl_outl(0, ioaddr + TFTR);

 	/* Frame recv control */
-	ctrl_outl(0, ioaddr + RMCR);
+	ctrl_outl(mdp->cd->rmcr_value, ioaddr + RMCR);

 	rx_int_var = mdp->rx_int_var = DESC_I_RINT8 | DESC_I_RINT5;
 	tx_int_var = mdp->tx_int_var = DESC_I_TINT2;
 	ctrl_outl(rx_int_var | tx_int_var, ioaddr + TRSCER);

-#if defined(CONFIG_CPU_SUBTYPE_SH7763)
-	/* Burst sycle set */
-	ctrl_outl(0x800, ioaddr + BCULR);
-#endif
+	if (mdp->cd->bculr)
+		ctrl_outl(0x800, ioaddr + BCULR);	/* Burst sycle set */

-	ctrl_outl((FIFO_F_D_RFF | FIFO_F_D_RFD), ioaddr + FCFTR);
+	ctrl_outl(mdp->cd->fcftr_value, ioaddr + FCFTR);

-#if !defined(CONFIG_CPU_SUBTYPE_SH7763)
-	ctrl_outl(0, ioaddr + TRIMD);
-#endif
+	if (!mdp->cd->no_trimd)
+		ctrl_outl(0, ioaddr + TRIMD);

 	/* Recv frame limit set register */
 	ctrl_outl(RFLR_VALUE, ioaddr + RFLR);

 	ctrl_outl(ctrl_inl(ioaddr + EESR), ioaddr + EESR);
-	ctrl_outl((DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff), ioaddr + EESIPR);
+	ctrl_outl(mdp->cd->eesipr_value, ioaddr + EESIPR);

 	/* PAUSE Prohibition */
 	val = (ctrl_inl(ioaddr + ECMR) & ECMR_DM) |
@@ -429,24 +557,25 @@ static int sh_eth_dev_init(struct net_device *ndev)

 	ctrl_outl(val, ioaddr + ECMR);

+	if (mdp->cd->set_rate)
+		mdp->cd->set_rate(ndev);
+
 	/* E-MAC Status Register clear */
-	ctrl_outl(ECSR_INIT, ioaddr + ECSR);
+	ctrl_outl(mdp->cd->ecsr_value, ioaddr + ECSR);

 	/* E-MAC Interrupt Enable register */
-	ctrl_outl(ECSIPR_INIT, ioaddr + ECSIPR);
+	ctrl_outl(mdp->cd->ecsipr_value, ioaddr + ECSIPR);

 	/* Set MAC address */
 	update_mac_address(ndev);

 	/* mask reset */
-#if defined(CONFIG_CPU_SUBTYPE_SH7710) || defined(CONFIG_CPU_SUBTYPE_SH7763)
-	ctrl_outl(APR_AP, ioaddr + APR);
-	ctrl_outl(MPR_MP, ioaddr + MPR);
-	ctrl_outl(TPAUSER_UNLIMITED, ioaddr + TPAUSER);
-#endif
-#if defined(CONFIG_CPU_SUBTYPE_SH7710)
-	ctrl_outl(BCFR_UNLIMITED, ioaddr + BCFR);
-#endif
+	if (mdp->cd->apr)
+		ctrl_outl(APR_AP, ioaddr + APR);
+	if (mdp->cd->mpr)
+		ctrl_outl(MPR_MP, ioaddr + MPR);
+	if (mdp->cd->tpauser)
+		ctrl_outl(TPAUSER_UNLIMITED, ioaddr + TPAUSER);

 	/* Setting the Rx mode will start the Rx process. */
 	ctrl_outl(EDRRR_R, ioaddr + EDRRR);
@@ -495,7 +624,7 @@ static int sh_eth_rx(struct net_device *ndev)
 	int boguscnt = (mdp->dirty_rx + RX_RING_SIZE) - mdp->cur_rx;
 	struct sk_buff *skb;
 	u16 pkt_len = 0;
-	u32 desc_status, reserve = 0;
+	u32 desc_status;

 	rxdesc = &mdp->rx_ring[entry];
 	while (!(rxdesc->status & cpu_to_edmac(mdp, RD_RACT))) {
@@ -524,8 +653,10 @@ static int sh_eth_rx(struct net_device *ndev)
 			if (desc_status & RD_RFS10)
 				mdp->stats.rx_over_errors++;
 		} else {
-			swaps(phys_to_virt(ALIGN(rxdesc->addr, 4)),
-				pkt_len + 2);
+			if (!mdp->cd->hw_swap)
+				sh_eth_soft_swap(
+					phys_to_virt(ALIGN(rxdesc->addr, 4)),
+					pkt_len + 2);
 			skb = mdp->rx_skbuff[entry];
 			mdp->rx_skbuff[entry] = NULL;
 			skb_put(skb, pkt_len);
@@ -554,14 +685,8 @@ static int sh_eth_rx(struct net_device *ndev)
 			dma_map_single(&ndev->dev, skb->tail, mdp->rx_buf_sz,
 					DMA_FROM_DEVICE);
 			skb->dev = ndev;
-#if defined(CONFIG_CPU_SUBTYPE_SH7763)
-			reserve = SH7763_SKB_ALIGN
-				- ((uint32_t)skb->data & (SH7763_SKB_ALIGN-1));
-			if (reserve)
-				skb_reserve(skb, reserve);
-#else
-			skb_reserve(skb, RX_OFFSET);
-#endif
+			sh_eth_set_receive_align(skb);
+
 			skb->ip_summed = CHECKSUM_NONE;
 			rxdesc->addr = virt_to_phys(PTR_ALIGN(skb->data, 4));
 		}
@@ -587,6 +712,8 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	u32 ioaddr = ndev->base_addr;
 	u32 felic_stat;
+	u32 link_stat;
+	u32 mask;

 	if (intr_status & EESR_ECI) {
 		felic_stat = ctrl_inl(ioaddr + ECSR);
@@ -595,7 +722,14 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 			mdp->stats.tx_carrier_errors++;
 		if (felic_stat & ECSR_LCHNG) {
 			/* Link Changed */
-			u32 link_stat = (ctrl_inl(ioaddr + PSR));
+			if (mdp->cd->no_psr) {
+				if (mdp->link == PHY_DOWN)
+					link_stat = 0;
+				else
+					link_stat = PHY_ST_LINK;
+			} else {
+				link_stat = (ctrl_inl(ioaddr + PSR));
+			}
 			if (!(link_stat & PHY_ST_LINK)) {
 				/* Link Down : disable tx and rx */
 				ctrl_outl(ctrl_inl(ioaddr + ECMR) &
@@ -627,17 +761,15 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 		if (intr_status & EESR_RFRMER) {
 			/* Receive Frame Overflow int */
 			mdp->stats.rx_frame_errors++;
-			printk(KERN_ERR "Receive Frame Overflow\n");
+			dev_err(&ndev->dev, "Receive Frame Overflow\n");
 		}
 	}
-#if !defined(CONFIG_CPU_SUBTYPE_SH7763)
-	if (intr_status & EESR_ADE) {
-		if (intr_status & EESR_TDE) {
-			if (intr_status & EESR_TFE)
-				mdp->stats.tx_fifo_errors++;
-		}
+
+	if (!mdp->cd->no_ade) {
+		if (intr_status & EESR_ADE && intr_status & EESR_TDE &&
+		    intr_status & EESR_TFE)
+			mdp->stats.tx_fifo_errors++;
 	}
-#endif

 	if (intr_status & EESR_RDE) {
 		/* Receive Descriptor Empty int */
@@ -645,24 +777,24 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)

 		if (ctrl_inl(ioaddr + EDRRR) ^ EDRRR_R)
 			ctrl_outl(EDRRR_R, ioaddr + EDRRR);
-		printk(KERN_ERR "Receive Descriptor Empty\n");
+		dev_err(&ndev->dev, "Receive Descriptor Empty\n");
 	}
 	if (intr_status & EESR_RFE) {
 		/* Receive FIFO Overflow int */
 		mdp->stats.rx_fifo_errors++;
-		printk(KERN_ERR "Receive FIFO Overflow\n");
+		dev_err(&ndev->dev, "Receive FIFO Overflow\n");
 	}
-	if (intr_status & (EESR_TWB | EESR_TABT |
-#if !defined(CONFIG_CPU_SUBTYPE_SH7763)
-			EESR_ADE |
-#endif
-			EESR_TDE | EESR_TFE)) {
+
+	mask = EESR_TWB | EESR_TABT | EESR_ADE | EESR_TDE | EESR_TFE;
+	if (mdp->cd->no_ade)
+		mask &= ~EESR_ADE;
+	if (intr_status & mask) {
 		/* Tx error */
 		u32 edtrr = ctrl_inl(ndev->base_addr + EDTRR);
 		/* dmesg */
-		printk(KERN_ERR "%s:TX error. status=%8.8x cur_tx=%8.8x ",
-				ndev->name, intr_status, mdp->cur_tx);
-		printk(KERN_ERR "dirty_tx=%8.8x state=%8.8x EDTRR=%8.8x.\n",
+		dev_err(&ndev->dev, "TX error. status=%8.8x cur_tx=%8.8x ",
+				intr_status, mdp->cur_tx);
+		dev_err(&ndev->dev, "dirty_tx=%8.8x state=%8.8x EDTRR=%8.8x.\n",
 				mdp->dirty_tx, (u32) ndev->state, edtrr);
 		/* dirty buffer free */
 		sh_eth_txfree(ndev);
@@ -681,6 +813,7 @@ static irqreturn_t sh_eth_interrupt(int irq, void *netdev)
 {
 	struct net_device *ndev = netdev;
 	struct sh_eth_private *mdp = netdev_priv(ndev);
+	struct sh_eth_cpu_data *cd = mdp->cd;
 	irqreturn_t ret = IRQ_NONE;
 	u32 ioaddr, boguscnt = RX_RING_SIZE;
 	u32 intr_status = 0;
@@ -693,7 +826,7 @@ static irqreturn_t sh_eth_interrupt(int irq, void *netdev)
 	/* Clear interrupt */
 	if (intr_status & (EESR_FRC | EESR_RMAF | EESR_RRF |
 			EESR_RTLF | EESR_RTSF | EESR_PRE | EESR_CERF |
-			TX_CHECK | EESR_ERR_CHECK)) {
+			cd->tx_check | cd->eesr_err_check)) {
 		ctrl_outl(intr_status, ioaddr + EESR);
 		ret = IRQ_HANDLED;
 	} else
@@ -710,12 +843,12 @@ static irqreturn_t sh_eth_interrupt(int irq, void *netdev)
 	}

 	/* Tx Check */
-	if (intr_status & TX_CHECK) {
+	if (intr_status & cd->tx_check) {
 		sh_eth_txfree(ndev);
 		netif_wake_queue(ndev);
 	}

-	if (intr_status & EESR_ERR_CHECK)
+	if (intr_status & cd->eesr_err_check)
 		sh_eth_error(ndev, intr_status);

 	if (--boguscnt < 0) {
@@ -750,32 +883,15 @@ static void sh_eth_adjust_link(struct net_device *ndev)
 		if (phydev->duplex != mdp->duplex) {
 			new_state = 1;
 			mdp->duplex = phydev->duplex;
-#if defined(CONFIG_CPU_SUBTYPE_SH7763)
-			if (mdp->duplex) { /*  FULL */
-				ctrl_outl(ctrl_inl(ioaddr + ECMR) | ECMR_DM,
-						ioaddr + ECMR);
-			} else {	/* Half */
-				ctrl_outl(ctrl_inl(ioaddr + ECMR) & ~ECMR_DM,
-						ioaddr + ECMR);
-			}
-#endif
+			if (mdp->cd->set_duplex)
+				mdp->cd->set_duplex(ndev);
 		}

 		if (phydev->speed != mdp->speed) {
 			new_state = 1;
 			mdp->speed = phydev->speed;
-#if defined(CONFIG_CPU_SUBTYPE_SH7763)
-			switch (mdp->speed) {
-			case 10: /* 10BASE */
-				ctrl_outl(GECMR_10, ioaddr + GECMR); break;
-			case 100:/* 100BASE */
-				ctrl_outl(GECMR_100, ioaddr + GECMR); break;
-			case 1000: /* 1000BASE */
-				ctrl_outl(GECMR_1000, ioaddr + GECMR); break;
-			default:
-				break;
-			}
-#endif
+			if (mdp->cd->set_rate)
+				mdp->cd->set_rate(ndev);
 		}
 		if (mdp->link == PHY_DOWN) {
 			ctrl_outl((ctrl_inl(ioaddr + ECMR) & ~ECMR_TXF)
@@ -815,8 +931,9 @@ static int sh_eth_phy_init(struct net_device *ndev)
 		dev_err(&ndev->dev, "phy_connect failed\n");
 		return PTR_ERR(phydev);
 	}
+
 	dev_info(&ndev->dev, "attached phy %i to driver %s\n",
-	phydev->addr, phydev->drv->name);
+		phydev->addr, phydev->drv->name);

 	mdp->phydev = phydev;

@@ -854,7 +971,7 @@ static int sh_eth_open(struct net_device *ndev)
 #endif
 				ndev->name, ndev);
 	if (ret) {
-		printk(KERN_ERR "Can not assign IRQ number to %s\n", CARDNAME);
+		dev_err(&ndev->dev, "Can not assign IRQ number\n");
 		return ret;
 	}

@@ -951,7 +1068,9 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	txdesc = &mdp->tx_ring[entry];
 	txdesc->addr = virt_to_phys(skb->data);
 	/* soft swap. */
-	swaps(phys_to_virt(ALIGN(txdesc->addr, 4)), skb->len + 2);
+	if (!mdp->cd->hw_swap)
+		sh_eth_soft_swap(phys_to_virt(ALIGN(txdesc->addr, 4)),
+				 skb->len + 2);
 	/* write back */
 	__flush_purge_region(skb->data, skb->len);
 	if (skb->len < ETHERSMALL)
@@ -1053,7 +1172,7 @@ static int sh_eth_do_ioctl(struct net_device *ndev, struct ifreq *rq,
 	return phy_mii_ioctl(phydev, if_mii(rq), cmd);
 }

-
+#if defined(SH_ETH_HAS_TSU)
 /* Multicast reception directions set */
 static void sh_eth_set_multicast_list(struct net_device *ndev)
 {
@@ -1098,6 +1217,7 @@ static void sh_eth_tsu_init(u32 ioaddr)
 	ctrl_outl(0, ioaddr + TSU_POST3);	/* Disable CAM entry [16-23] */
 	ctrl_outl(0, ioaddr + TSU_POST4);	/* Disable CAM entry [24-31] */
 }
+#endif /* SH_ETH_HAS_TSU */

 /* MDIO bus release function */
 static int sh_mdio_release(struct net_device *ndev)
@@ -1187,7 +1307,9 @@ static const struct net_device_ops sh_eth_netdev_ops = {
 	.ndo_stop		= sh_eth_close,
 	.ndo_start_xmit		= sh_eth_start_xmit,
 	.ndo_get_stats		= sh_eth_get_stats,
+#if defined(SH_ETH_HAS_TSU)
 	.ndo_set_multicast_list	= sh_eth_set_multicast_list,
+#endif
 	.ndo_tx_timeout		= sh_eth_tx_timeout,
 	.ndo_do_ioctl		= sh_eth_do_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -1213,7 +1335,7 @@ static int sh_eth_drv_probe(struct platform_device *pdev)

 	ndev = alloc_etherdev(sizeof(struct sh_eth_private));
 	if (!ndev) {
-		printk(KERN_ERR "%s: could not allocate device.\n", CARDNAME);
+		dev_err(&pdev->dev, "Could not allocate device.\n");
 		ret = -ENOMEM;
 		goto out;
 	}
@@ -1246,6 +1368,10 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	/* EDMAC endian */
 	mdp->edmac_endian = pd->edmac_endian;

+	/* set cpu data */
+	mdp->cd = &sh_eth_my_cpu_data;
+	sh_eth_set_default_cpu_data(mdp->cd);
+
 	/* set function */
 	ndev->netdev_ops = &sh_eth_netdev_ops;
 	ndev->watchdog_timeo = TX_TIMEOUT;
@@ -1258,13 +1384,10 @@ static int sh_eth_drv_probe(struct platform_device *pdev)

 	/* First device only init */
 	if (!devno) {
-#if defined(ARSTR)
-		/* reset device */
-		ctrl_outl(ARSTR_ARSTR, ARSTR);
-		mdelay(1);
-#endif
+		if (mdp->cd->chip_reset)
+			mdp->cd->chip_reset(ndev);

-#if defined(SH_TSU_ADDR)
+#if defined(SH_ETH_HAS_TSU)
 		/* TSU init (Init only)*/
 		sh_eth_tsu_init(SH_TSU_ADDR);
 #endif
@@ -1281,8 +1404,8 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 		goto out_unregister;

 	/* pritnt device infomation */
-	printk(KERN_INFO "%s: %s at 0x%x, ",
-	       ndev->name, CARDNAME, (u32) ndev->base_addr);
+	pr_info("Base address at 0x%x, ",
+	       (u32)ndev->base_addr);

 	for (i = 0; i < 5; i++)
 		printk("%02X:", ndev->dev_addr[i]);
diff --git a/drivers/net/sh_eth.h b/drivers/net/sh_eth.h
index 1537e13..eec6c4a 100644
--- a/drivers/net/sh_eth.h
+++ b/drivers/net/sh_eth.h
@@ -2,7 +2,7 @@
  *  SuperH Ethernet device driver
  *
  *  Copyright (C) 2006-2008 Nobuhiro Iwamatsu
- *  Copyright (C) 2008 Renesas Solutions Corp.
+ *  Copyright (C) 2008-2009 Renesas Solutions Corp.
  *
  *  This program is free software; you can redistribute it and/or modify it
  *  under the terms and conditions of the GNU General Public License,
@@ -39,12 +39,10 @@
 #define ETHERSMALL		60
 #define PKT_BUF_SZ		1538

-#ifdef CONFIG_CPU_SUBTYPE_SH7763
-
-#define SH7763_SKB_ALIGN 32
+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
 /* Chip Base Address */
 # define SH_TSU_ADDR	0xFEE01800
-# define ARSTR			SH_TSU_ADDR
+# define ARSTR		SH_TSU_ADDR

 /* Chip Registers */
 /* E-DMAC */
@@ -143,8 +141,8 @@
 # define FWNLCR1         0xB0
 # define FWALCR1         0x40

-#else /* CONFIG_CPU_SUBTYPE_SH7763 */
-# define RX_OFFSET 2	/* skb offset */
+#else /* #elif defined(CONFIG_CPU_SUBTYPE_SH7763) */
+/* This section is SH3 or SH2 */
 #ifndef CONFIG_CPU_SUBTYPE_SH7619
 /* Chip base address */
 # define SH_TSU_ADDR  0xA7000804
@@ -243,6 +241,30 @@

 #endif /* CONFIG_CPU_SUBTYPE_SH7763 */

+/* There are avoid compile error... */
+#if !defined(BCULR)
+#define BCULR	0x0fc
+#endif
+#if !defined(TRIMD)
+#define TRIMD	0x0fc
+#endif
+#if !defined(APR)
+#define APR	0x0fc
+#endif
+#if !defined(MPR)
+#define MPR	0x0fc
+#endif
+#if !defined(TPAUSER)
+#define TPAUSER	0x0fc
+#endif
+
+/* Driver's parameters */
+#if defined(CONFIG_CPU_SH4)
+#define SH4_SKB_RX_ALIGN	32
+#else
+#define SH2_SH3_SKB_RX_ALIGN	2
+#endif
+
 /*
  * Register's bits
  */
@@ -261,11 +283,10 @@ enum GECMR_BIT {

 /* EDMR */
 enum DMAC_M_BIT {
+	EDMR_EL = 0x40, /* Litte endian */
 	EDMR_DL1 = 0x20, EDMR_DL0 = 0x10,
 #ifdef CONFIG_CPU_SUBTYPE_SH7763
-	EDMR_SRST	= 0x03,
-	EMDR_DESC_R	= 0x30, /* Descriptor reserve size */
-	EDMR_EL		= 0x40, /* Litte endian */
+	EDMR_SRST = 0x03,
 #else /* CONFIG_CPU_SUBTYPE_SH7763 */
 	EDMR_SRST = 0x01,
 #endif
@@ -307,47 +328,43 @@ enum PHY_STATUS_BIT { PHY_ST_LINK = 0x01, };

 /* EESR */
 enum EESR_BIT {
-#ifndef CONFIG_CPU_SUBTYPE_SH7763
-	EESR_TWB  = 0x40000000,
-#else
-	EESR_TWB  = 0xC0000000,
-	EESR_TC1  = 0x20000000,
-	EESR_TUC  = 0x10000000,
-	EESR_ROC  = 0x80000000,
-#endif
-	EESR_TABT = 0x04000000,
-	EESR_RABT = 0x02000000, EESR_RFRMER = 0x01000000,
-#ifndef CONFIG_CPU_SUBTYPE_SH7763
-	EESR_ADE  = 0x00800000,
-#endif
-	EESR_ECI  = 0x00400000,
-	EESR_FTC  = 0x00200000, EESR_TDE  = 0x00100000,
-	EESR_TFE  = 0x00080000, EESR_FRC  = 0x00040000,
-	EESR_RDE  = 0x00020000, EESR_RFE  = 0x00010000,
-#ifndef CONFIG_CPU_SUBTYPE_SH7763
-	EESR_CND  = 0x00000800,
-#endif
-	EESR_DLC  = 0x00000400,
-	EESR_CD   = 0x00000200, EESR_RTO  = 0x00000100,
-	EESR_RMAF = 0x00000080, EESR_CEEF = 0x00000040,
-	EESR_CELF = 0x00000020, EESR_RRF  = 0x00000010,
-	EESR_RTLF = 0x00000008, EESR_RTSF = 0x00000004,
-	EESR_PRE  = 0x00000002, EESR_CERF = 0x00000001,
-};
-
-
-#ifdef CONFIG_CPU_SUBTYPE_SH7763
-# define TX_CHECK (EESR_TC1 | EESR_FTC)
-# define EESR_ERR_CHECK	(EESR_TWB | EESR_TABT | EESR_RABT | EESR_RDE \
-		| EESR_RFRMER | EESR_TFE | EESR_TDE | EESR_ECI)
-# define TX_ERROR_CEHCK (EESR_TWB | EESR_TABT | EESR_TDE | EESR_TFE)
-
-#else
-# define TX_CHECK (EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO)
-# define EESR_ERR_CHECK	(EESR_TWB | EESR_TABT | EESR_RABT | EESR_RDE \
-		| EESR_RFRMER | EESR_ADE | EESR_TFE | EESR_TDE | EESR_ECI)
-# define TX_ERROR_CEHCK (EESR_TWB | EESR_TABT | EESR_ADE | EESR_TDE | EESR_TFE)
-#endif
+	EESR_TWB1	= 0x80000000,
+	EESR_TWB	= 0x40000000,	/* same as TWB0 */
+	EESR_TC1	= 0x20000000,
+	EESR_TUC	= 0x10000000,
+	EESR_ROC	= 0x08000000,
+	EESR_TABT	= 0x04000000,
+	EESR_RABT	= 0x02000000,
+	EESR_RFRMER	= 0x01000000,	/* same as RFCOF */
+	EESR_ADE	= 0x00800000,
+	EESR_ECI	= 0x00400000,
+	EESR_FTC	= 0x00200000,	/* same as TC or TC0 */
+	EESR_TDE	= 0x00100000,
+	EESR_TFE	= 0x00080000,	/* same as TFUF */
+	EESR_FRC	= 0x00040000,	/* same as FR */
+	EESR_RDE	= 0x00020000,
+	EESR_RFE	= 0x00010000,
+	EESR_CND	= 0x00000800,
+	EESR_DLC	= 0x00000400,
+	EESR_CD		= 0x00000200,
+	EESR_RTO	= 0x00000100,
+	EESR_RMAF	= 0x00000080,
+	EESR_CEEF	= 0x00000040,
+	EESR_CELF	= 0x00000020,
+	EESR_RRF	= 0x00000010,
+	EESR_RTLF	= 0x00000008,
+	EESR_RTSF	= 0x00000004,
+	EESR_PRE	= 0x00000002,
+	EESR_CERF	= 0x00000001,
+};
+
+#define DEFAULT_TX_CHECK	(EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | \
+				 EESR_RTO)
+#define DEFAULT_EESR_ERR_CHECK	(EESR_TWB | EESR_TABT | EESR_RABT | \
+				 EESR_RDE | EESR_RFRMER | EESR_ADE | \
+				 EESR_TFE | EESR_TDE | EESR_ECI)
+#define DEFAULT_TX_ERROR_CHECK	(EESR_TWB | EESR_TABT | EESR_ADE | EESR_TDE | \
+				 EESR_TFE)

 /* EESIPR */
 enum DMAC_IM_BIT {
@@ -386,12 +403,8 @@ enum FCFTR_BIT {
 	FCFTR_RFF0 = 0x00010000, FCFTR_RFD2 = 0x00000004,
 	FCFTR_RFD1 = 0x00000002, FCFTR_RFD0 = 0x00000001,
 };
-#define FIFO_F_D_RFF	(FCFTR_RFF2|FCFTR_RFF1|FCFTR_RFF0)
-#ifndef CONFIG_CPU_SUBTYPE_SH7619
-#define FIFO_F_D_RFD	(FCFTR_RFD2|FCFTR_RFD1|FCFTR_RFD0)
-#else
-#define FIFO_F_D_RFD	(FCFTR_RFD0)
-#endif
+#define DEFAULT_FIFO_F_D_RFF	(FCFTR_RFF2 | FCFTR_RFF1 | FCFTR_RFF0)
+#define DEFAULT_FIFO_F_D_RFD	(FCFTR_RFD2 | FCFTR_RFD1 | FCFTR_RFD0)

 /* Transfer descriptor bit */
 enum TD_STS_BIT {
@@ -404,60 +417,38 @@ enum TD_STS_BIT {
 #define TD_TFP	(TD_TFP1|TD_TFP0)

 /* RMCR */
-enum RECV_RST_BIT { RMCR_RST = 0x01, };
+#define DEFAULT_RMCR_VALUE	0x00000000
+
 /* ECMR */
 enum FELIC_MODE_BIT {
-#ifdef CONFIG_CPU_SUBTYPE_SH7763
 	ECMR_TRCCM = 0x04000000, ECMR_RCSC = 0x00800000,
 	ECMR_DPAD = 0x00200000, ECMR_RZPF = 0x00100000,
-#endif
 	ECMR_ZPF = 0x00080000, ECMR_PFR = 0x00040000, ECMR_RXF = 0x00020000,
 	ECMR_TXF = 0x00010000, ECMR_MCT = 0x00002000, ECMR_PRCEF = 0x00001000,
 	ECMR_PMDE = 0x00000200, ECMR_RE = 0x00000040, ECMR_TE = 0x00000020,
-	ECMR_ILB = 0x00000008, ECMR_ELB = 0x00000004, ECMR_DM = 0x00000002,
-	ECMR_PRM = 0x00000001,
+	ECMR_ILB = 0x00000008, ECMR_ELB = 0x00000004,
+	ECMR_DM = 0x00000002, ECMR_PRM = 0x00000001,
 };

-#ifdef CONFIG_CPU_SUBTYPE_SH7763
-#define ECMR_CHG_DM	(ECMR_TRCCM | ECMR_RZPF | ECMR_ZPF |\
-			ECMR_PFR | ECMR_RXF | ECMR_TXF | ECMR_MCT)
-#elif CONFIG_CPU_SUBTYPE_SH7619
-#define ECMR_CHG_DM	(ECMR_ZPF | ECMR_PFR | ECMR_RXF | ECMR_TXF)
-#else
-#define ECMR_CHG_DM	(ECMR_ZPF | ECMR_PFR | ECMR_RXF | ECMR_TXF | ECMR_MCT)
-#endif
-
 /* ECSR */
 enum ECSR_STATUS_BIT {
-#ifndef CONFIG_CPU_SUBTYPE_SH7763
 	ECSR_BRCRX = 0x20, ECSR_PSRTO = 0x10,
-#endif
 	ECSR_LCHNG = 0x04,
 	ECSR_MPD = 0x02, ECSR_ICD = 0x01,
 };

-#ifdef CONFIG_CPU_SUBTYPE_SH7763
-# define ECSR_INIT (ECSR_ICD | ECSIPR_MPDIP)
-#else
-# define ECSR_INIT (ECSR_BRCRX | ECSR_PSRTO | \
-			ECSR_LCHNG | ECSR_ICD | ECSIPR_MPDIP)
-#endif
+#define DEFAULT_ECSR_INIT	(ECSR_BRCRX | ECSR_PSRTO | ECSR_LCHNG | \
+				 ECSR_ICD | ECSIPR_MPDIP)

 /* ECSIPR */
 enum ECSIPR_STATUS_MASK_BIT {
-#ifndef CONFIG_CPU_SUBTYPE_SH7763
 	ECSIPR_BRCRXIP = 0x20, ECSIPR_PSRTOIP = 0x10,
-#endif
 	ECSIPR_LCHNGIP = 0x04,
 	ECSIPR_MPDIP = 0x02, ECSIPR_ICDIP = 0x01,
 };

-#ifdef CONFIG_CPU_SUBTYPE_SH7763
-# define ECSIPR_INIT (ECSIPR_LCHNGIP | ECSIPR_ICDIP | ECSIPR_MPDIP)
-#else
-# define ECSIPR_INIT (ECSIPR_BRCRXIP | ECSIPR_PSRTOIP | ECSIPR_LCHNGIP | \
-				ECSIPR_ICDIP | ECSIPR_MPDIP)
-#endif
+#define DEFAULT_ECSIPR_INIT	(ECSIPR_BRCRXIP | ECSIPR_PSRTOIP | \
+				 ECSIPR_LCHNGIP | ECSIPR_ICDIP | ECSIPR_MPDIP)

 /* APR */
 enum APR_BIT {
@@ -483,23 +474,12 @@ enum RPADIR_BIT {
 	RPADIR_PADR = 0x0003f,
 };

-#if defined(CONFIG_CPU_SUBTYPE_SH7763)
-# define RPADIR_INIT (0x00)
-#else
-# define RPADIR_INIT (RPADIR_PADS1)
-#endif
-
 /* RFLR */
 #define RFLR_VALUE 0x1000

 /* FDR */
-enum FIFO_SIZE_BIT {
-#ifndef CONFIG_CPU_SUBTYPE_SH7619
-	FIFO_SIZE_T = 0x00000700, FIFO_SIZE_R = 0x00000007,
-#else
-	FIFO_SIZE_T = 0x00000100, FIFO_SIZE_R = 0x00000001,
-#endif
-};
+#define DEFAULT_FDR_INIT	0x00000707
+
 enum phy_offsets {
 	PHY_CTRL = 0, PHY_STAT = 1, PHY_IDT1 = 2, PHY_IDT2 = 3,
 	PHY_ANA = 4, PHY_ANL = 5, PHY_ANE = 6,
@@ -633,7 +613,43 @@ struct sh_eth_rxdesc {
 	u32 pad0;		/* padding data */
 } __attribute__((aligned(2), packed));

+/* This structure is used by each CPU dependency handling. */
+struct sh_eth_cpu_data {
+	/* optional functions */
+	void (*chip_reset)(struct net_device *ndev);
+	void (*set_duplex)(struct net_device *ndev);
+	void (*set_rate)(struct net_device *ndev);
+
+	/* mandatory initialize value */
+	unsigned long eesipr_value;
+
+	/* optional initialize value */
+	unsigned long ecsr_value;
+	unsigned long ecsipr_value;
+	unsigned long fdr_value;
+	unsigned long fcftr_value;
+	unsigned long rpadir_value;
+	unsigned long rmcr_value;
+
+	/* interrupt checking mask */
+	unsigned long tx_check;
+	unsigned long eesr_err_check;
+	unsigned long tx_error_check;
+
+	/* hardware features */
+	unsigned no_psr:1;		/* EtherC DO NOT have PSR */
+	unsigned apr:1;			/* EtherC have APR */
+	unsigned mpr:1;			/* EtherC have MPR */
+	unsigned tpauser:1;		/* EtherC have TPAUSER */
+	unsigned bculr:1;		/* EtherC have BCULR */
+	unsigned hw_swap:1;		/* E-DMAC have DE bit in EDMR */
+	unsigned rpadir:1;		/* E-DMAC have RPADIR */
+	unsigned no_trimd:1;		/* E-DMAC DO NOT have TRIMD */
+	unsigned no_ade:1;	/* E-DMAC DO NOT have ADE bit in EESR */
+};
+
 struct sh_eth_private {
+	struct sh_eth_cpu_data *cd;
 	dma_addr_t rx_desc_dma;
 	dma_addr_t tx_desc_dma;
 	struct sh_eth_rxdesc *rx_ring;
@@ -661,11 +677,7 @@ struct sh_eth_private {
 	struct net_device_stats tsu_stats;	/* TSU forward status */
 };

-#ifdef CONFIG_CPU_SUBTYPE_SH7763
-/* SH7763 has endian control register */
-#define swaps(x, y)
-#else
-static void swaps(char *src, int len)
+static inline void sh_eth_soft_swap(char *src, int len)
 {
 #ifdef __LITTLE_ENDIAN__
 	u32 *p = (u32 *)src;
@@ -676,5 +688,5 @@ static void swaps(char *src, int len)
 		*p = swab32(*p);
 #endif
 }
-#endif /* CONFIG_CPU_SUBTYPE_SH7763 */
-#endif
+
+#endif	/* #ifndef __SH_ETH_H__ */
-- 
1.5.5


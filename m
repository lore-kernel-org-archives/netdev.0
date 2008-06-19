From: Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>
Subject: [PATCH] net: sh_eth: Add support of SH7763 to sh_eth
Date: Thu, 19 Jun 2008 19:25:59 +0900
Message-ID: <485A3437.4010902@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, Linux-sh <linux-sh@vger.kernel.org>,
	Paul Mundt <lethal@linux-sh.org>
To: netdev <netdev@vger.kernel.org>,
	Nobuhiro Iwamatsu <iwamatsu@nigauri.org>
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SH7763 has Ethernet core same as SH7710/SH7712.
Positions of some registry are different, but the basic part is the same.
I add support of ethernet of sh7763 to sh_eth.

Signed-off-by: Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>
---
 drivers/net/Kconfig  |    4 +-
 drivers/net/sh_eth.c |  202 ++++++++++++++++++++-----
 drivers/net/sh_eth.h |  425 +++++++++++++++++++++++++++++++++++++-------------
 3 files changed, 482 insertions(+), 149 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 0e0f669..012d1cd 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -527,14 +527,14 @@ config STNIC
 config SH_ETH
 	tristate "Renesas SuperH Ethernet support"
 	depends on SUPERH && \
-		(CPU_SUBTYPE_SH7710 || CPU_SUBTYPE_SH7712)
+		(CPU_SUBTYPE_SH7710 || CPU_SUBTYPE_SH7712 || CPU_SUBTYPE_SH7763)
 	select CRC32
 	select MII
 	select MDIO_BITBANG
 	select PHYLIB
 	help
 	  Renesas SuperH Ethernet device driver.
-	  This driver support SH7710 and SH7712.
+	  This driver support SH7710, SH7712 and SH7763.

 config SUNLANCE
 	tristate "Sun LANCE support"
diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 37f3116..99557ea 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -1,7 +1,7 @@
 /*
  *  SuperH Ethernet device driver
  *
- *  Copyright (C) 2006,2007 Nobuhiro Iwamatsu
+ *  Copyright (C) 2006-2008 Nobuhiro Iwamatsu
  *  Copyright (C) 2008 Renesas Solutions Corp.
  *
  *  This program is free software; you can redistribute it and/or modify it
@@ -143,13 +143,39 @@ static struct mdiobb_ops bb_ops = {
 	.get_mdio_data = sh_get_mdio,
 };

+/* Chip Reset */
 static void sh_eth_reset(struct net_device *ndev)
 {
 	u32 ioaddr = ndev->base_addr;

+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
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
+#else
 	ctrl_outl(ctrl_inl(ioaddr + EDMR) | EDMR_SRST, ioaddr + EDMR);
 	mdelay(3);
 	ctrl_outl(ctrl_inl(ioaddr + EDMR) & ~EDMR_SRST, ioaddr + EDMR);
+#endif
 }

 /* free skb and descriptor buffer */
@@ -180,6 +206,7 @@ static void sh_eth_ring_free(struct net_device *ndev)
 /* format skb and descriptor buffer */
 static void sh_eth_ring_format(struct net_device *ndev)
 {
+	u32 ioaddr = ndev->base_addr, reserve = 0;
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	int i;
 	struct sk_buff *skb;
@@ -201,9 +228,15 @@ static void sh_eth_ring_format(struct net_device *ndev)
 		mdp->rx_skbuff[i] = skb;
 		if (skb == NULL)
 			break;
-		skb->dev = ndev;	/* Mark as being used by this device. */
+		skb->dev = ndev; /* Mark as being used by this device. */
+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
+		reserve = SH7763_SKB_ALIGN
+			- ((uint32_t)skb->data & (SH7763_SKB_ALIGN-1));
+		if (reserve)
+			skb_reserve(skb, reserve);
+#else
 		skb_reserve(skb, RX_OFFSET);
-
+#endif
 		/* RX descriptor */
 		rxdesc = &mdp->rx_ring[i];
 		rxdesc->addr = (u32)skb->data & ~0x3UL;
@@ -211,12 +244,25 @@ static void sh_eth_ring_format(struct net_device *ndev)

 		/* The size of the buffer is 16 byte boundary. */
 		rxdesc->buffer_length = (mdp->rx_buf_sz + 16) & ~0x0F;
+		/* Rx descriptor address set */
+		if (i == 0) {
+			ctrl_outl((u32)rxdesc, ioaddr + RDLAR);
+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
+			ctrl_outl((u32)rxdesc, ioaddr + RDFAR);
+#endif
+		}
 	}

+	/* Rx descriptor address set */
+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
+	ctrl_outl((u32)rxdesc, ioaddr + RDFXR);
+	ctrl_outl(0x1, ioaddr + RDFFR);
+#endif
+
 	mdp->dirty_rx = (u32) (i - RX_RING_SIZE);

 	/* Mark the last entry as wrapping the ring. */
-	rxdesc->status |= cpu_to_le32(RC_RDEL);
+	rxdesc->status |= cpu_to_le32(RD_RDEL);

 	memset(mdp->tx_ring, 0, tx_ringsize);

@@ -226,8 +272,21 @@ static void sh_eth_ring_format(struct net_device *ndev)
 		txdesc = &mdp->tx_ring[i];
 		txdesc->status = cpu_to_le32(TD_TFP);
 		txdesc->buffer_length = 0;
+		if (i == 0) {
+			/* Rx descriptor address set */
+			ctrl_outl((u32)txdesc, ioaddr + TDLAR);
+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
+			ctrl_outl((u32)txdesc, ioaddr + TDFAR);
+#endif
+		}
 	}

+	/* Rx descriptor address set */
+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
+	ctrl_outl((u32)txdesc, ioaddr + TDFXR);
+	ctrl_outl(0x1, ioaddr + TDFFR);
+#endif
+
 	txdesc->status |= cpu_to_le32(TD_TDLE);
 }

@@ -311,31 +370,43 @@ static int sh_eth_dev_init(struct net_device *ndev)
 	/* Soft Reset */
 	sh_eth_reset(ndev);

-	ctrl_outl(RPADIR_PADS1, ioaddr + RPADIR);	/* SH7712-DMA-RX-PAD2 */
+	/* Descriptor format */
+	sh_eth_ring_format(ndev);
+	ctrl_outl(RPADIR_INIT, ioaddr + RPADIR);

 	/* all sh_eth int mask */
 	ctrl_outl(0, ioaddr + EESIPR);

-	/* FIFO size set */
+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
+	ctrl_outl(EDMR_EL, ioaddr + EDMR);
+#else
 	ctrl_outl(0, ioaddr + EDMR);	/* Endian change */
+#endif

+	/* FIFO size set */
 	ctrl_outl((FIFO_SIZE_T | FIFO_SIZE_R), ioaddr + FDR);
 	ctrl_outl(0, ioaddr + TFTR);

+	/* Frame recv control */
 	ctrl_outl(0, ioaddr + RMCR);

 	rx_int_var = mdp->rx_int_var = DESC_I_RINT8 | DESC_I_RINT5;
 	tx_int_var = mdp->tx_int_var = DESC_I_TINT2;
 	ctrl_outl(rx_int_var | tx_int_var, ioaddr + TRSCER);

+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
+	/* Burst sycle set */
+	ctrl_outl(0x800, ioaddr + BCULR);
+#endif
+
 	ctrl_outl((FIFO_F_D_RFF | FIFO_F_D_RFD), ioaddr + FCFTR);
-	ctrl_outl(0, ioaddr + TRIMD);

-	/* Descriptor format */
-	sh_eth_ring_format(ndev);
+#if !defined(CONFIG_CPU_SUBTYPE_SH7763)
+	ctrl_outl(0, ioaddr + TRIMD);
+#endif

-	ctrl_outl((u32)mdp->rx_ring, ioaddr + RDLAR);
-	ctrl_outl((u32)mdp->tx_ring, ioaddr + TDLAR);
+	/* Recv frame limit set register */
+	ctrl_outl(RFLR_VALUE, ioaddr + RFLR);

 	ctrl_outl(ctrl_inl(ioaddr + EESR), ioaddr + EESR);
 	ctrl_outl((DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff), ioaddr + EESIPR);
@@ -345,21 +416,26 @@ static int sh_eth_dev_init(struct net_device *ndev)
 		ECMR_ZPF | (mdp->duplex ? ECMR_DM : 0) | ECMR_TE | ECMR_RE;

 	ctrl_outl(val, ioaddr + ECMR);
-	ctrl_outl(ECSR_BRCRX | ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD |
-		  ECSIPR_MPDIP, ioaddr + ECSR);
-	ctrl_outl(ECSIPR_BRCRXIP | ECSIPR_PSRTOIP | ECSIPR_LCHNGIP |
-		  ECSIPR_ICDIP | ECSIPR_MPDIP, ioaddr + ECSIPR);
+
+	/* E-MAC Status Register clear */
+	ctrl_outl(ECSR_INIT, ioaddr + ECSR);
+
+	/* E-MAC Interrupt Enable register */
+	ctrl_outl(ECSIPR_INIT, ioaddr + ECSIPR);

 	/* Set MAC address */
 	update_mac_address(ndev);

 	/* mask reset */
-#if defined(CONFIG_CPU_SUBTYPE_SH7710)
+#if defined(CONFIG_CPU_SUBTYPE_SH7710) || defined(CONFIG_CPU_SUBTYPE_SH7763)
 	ctrl_outl(APR_AP, ioaddr + APR);
 	ctrl_outl(MPR_MP, ioaddr + MPR);
 	ctrl_outl(TPAUSER_UNLIMITED, ioaddr + TPAUSER);
+#endif
+#if defined(CONFIG_CPU_SUBTYPE_SH7710)
 	ctrl_outl(BCFR_UNLIMITED, ioaddr + BCFR);
 #endif
+
 	/* Setting the Rx mode will start the Rx process. */
 	ctrl_outl(EDRRR_R, ioaddr + EDRRR);

@@ -407,7 +483,7 @@ static int sh_eth_rx(struct net_device *ndev)
 	int boguscnt = (mdp->dirty_rx + RX_RING_SIZE) - mdp->cur_rx;
 	struct sk_buff *skb;
 	u16 pkt_len = 0;
-	u32 desc_status;
+	u32 desc_status, reserve = 0;

 	rxdesc = &mdp->rx_ring[entry];
 	while (!(rxdesc->status & cpu_to_le32(RD_RACT))) {
@@ -454,28 +530,38 @@ static int sh_eth_rx(struct net_device *ndev)
 	for (; mdp->cur_rx - mdp->dirty_rx > 0; mdp->dirty_rx++) {
 		entry = mdp->dirty_rx % RX_RING_SIZE;
 		rxdesc = &mdp->rx_ring[entry];
+		/* The size of the buffer is 16 byte boundary. */
+		rxdesc->buffer_length = (mdp->rx_buf_sz + 16) & ~0x0F;
+
 		if (mdp->rx_skbuff[entry] == NULL) {
 			skb = dev_alloc_skb(mdp->rx_buf_sz);
 			mdp->rx_skbuff[entry] = skb;
 			if (skb == NULL)
 				break;	/* Better luck next round. */
 			skb->dev = ndev;
+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
+			reserve = SH7763_SKB_ALIGN
+				- ((uint32_t)skb->data & (SH7763_SKB_ALIGN-1));
+			if (reserve)
+				skb_reserve(skb, reserve);
+#else
 			skb_reserve(skb, RX_OFFSET);
+#endif
+			skb->ip_summed = CHECKSUM_NONE;
 			rxdesc->addr = (u32)skb->data & ~0x3UL;
 		}
-		/* The size of the buffer is 16 byte boundary. */
-		rxdesc->buffer_length = (mdp->rx_buf_sz + 16) & ~0x0F;
 		if (entry >= RX_RING_SIZE - 1)
 			rxdesc->status |=
-			cpu_to_le32(RD_RACT | RD_RFP | RC_RDEL);
+				cpu_to_le32(RD_RACT | RD_RFP | RD_RDEL);
 		else
 			rxdesc->status |=
-			cpu_to_le32(RD_RACT | RD_RFP);
+				cpu_to_le32(RD_RACT | RD_RFP);
 	}

 	/* Restart Rx engine if stopped. */
 	/* If we don't need to check status, don't. -KDU */
-	ctrl_outl(EDRRR_R, ndev->base_addr + EDRRR);
+	if (!(ctrl_inl(ndev->base_addr + EDRRR) & EDRRR_R))
+		ctrl_outl(EDRRR_R, ndev->base_addr + EDRRR);

 	return 0;
 }
@@ -529,13 +615,14 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 			printk(KERN_ERR "Receive Frame Overflow\n");
 		}
 	}
-
+#if !defined(CONFIG_CPU_SUBTYPE_SH7763)
 	if (intr_status & EESR_ADE) {
 		if (intr_status & EESR_TDE) {
 			if (intr_status & EESR_TFE)
 				mdp->stats.tx_fifo_errors++;
 		}
 	}
+#endif

 	if (intr_status & EESR_RDE) {
 		/* Receive Descriptor Empty int */
@@ -550,8 +637,11 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 		mdp->stats.rx_fifo_errors++;
 		printk(KERN_ERR "Receive FIFO Overflow\n");
 	}
-	if (intr_status &
-	    (EESR_TWB | EESR_TABT | EESR_ADE | EESR_TDE | EESR_TFE)) {
+	if (intr_status & (EESR_TWB | EESR_TABT |
+#if !defined(CONFIG_CPU_SUBTYPE_SH7763)
+			EESR_ADE |
+#endif
+			EESR_TDE | EESR_TFE)) {
 		/* Tx error */
 		u32 edtrr = ctrl_inl(ndev->base_addr + EDTRR);
 		/* dmesg */
@@ -582,17 +672,23 @@ static irqreturn_t sh_eth_interrupt(int irq, void *netdev)
 	ioaddr = ndev->base_addr;
 	spin_lock(&mdp->lock);

+	/* Get interrpt stat */
 	intr_status = ctrl_inl(ioaddr + EESR);
 	/* Clear interrupt */
 	ctrl_outl(intr_status, ioaddr + EESR);

-	if (intr_status & (EESR_FRC | EESR_RINT8 |
-			   EESR_RINT5 | EESR_RINT4 | EESR_RINT3 | EESR_RINT2 |
-			   EESR_RINT1))
+	if (intr_status & (EESR_FRC | /* Frame recv*/
+			EESR_RMAF | /* Multi cast address recv*/
+			EESR_RRF  | /* Bit frame recv */
+			EESR_RTLF | /* Long frame recv*/
+			EESR_RTSF | /* short frame recv */
+			EESR_PRE  | /* PHY-LSI recv error */
+			EESR_CERF)){ /* recv frame CRC error */
 		sh_eth_rx(ndev);
-	if (intr_status & (EESR_FTC |
-			   EESR_TINT4 | EESR_TINT3 | EESR_TINT2 | EESR_TINT1)) {
+	}

+	/* Tx Check */
+	if (intr_status & TX_CHECK) {
 		sh_eth_txfree(ndev);
 		netif_wake_queue(ndev);
 	}
@@ -631,11 +727,32 @@ static void sh_eth_adjust_link(struct net_device *ndev)
 		if (phydev->duplex != mdp->duplex) {
 			new_state = 1;
 			mdp->duplex = phydev->duplex;
+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
+			if (mdp->duplex) { /*  FULL */
+				ctrl_outl(ctrl_inl(ioaddr + ECMR) | ECMR_DM,
+						ioaddr + ECMR);
+			} else {	/* Half */
+				ctrl_outl(ctrl_inl(ioaddr + ECMR) & ~ECMR_DM,
+						ioaddr + ECMR);
+			}
+#endif
 		}

 		if (phydev->speed != mdp->speed) {
 			new_state = 1;
 			mdp->speed = phydev->speed;
+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
+			switch (mdp->speed) {
+			case 10: /* 10BASE */
+				ctrl_outl(GECMR_10, ioaddr + GECMR); break;
+			case 100:/* 100BASE */
+				ctrl_outl(GECMR_100, ioaddr + GECMR); break;
+			case 1000: /* 1000BASE */
+				ctrl_outl(GECMR_1000, ioaddr + GECMR); break;
+			default:
+				break;
+			}
+#endif
 		}
 		if (mdp->link == PHY_DOWN) {
 			ctrl_outl((ctrl_inl(ioaddr + ECMR) & ~ECMR_TXF)
@@ -735,7 +852,7 @@ static int sh_eth_open(struct net_device *ndev)
 	/* Set the timer to check for link beat. */
 	init_timer(&mdp->timer);
 	mdp->timer.expires = (jiffies + (24 * HZ)) / 10;/* 2.4 sec. */
-	setup_timer(&mdp->timer, sh_eth_timer, ndev);
+	setup_timer(&mdp->timer, sh_eth_timer, (unsigned long)ndev);

 	return ret;

@@ -825,7 +942,9 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)

 	mdp->cur_tx++;

-	ctrl_outl(EDTRR_TRNS, ndev->base_addr + EDTRR);
+	if (!(ctrl_inl(ndev->base_addr + EDTRR) & EDTRR_TRNS))
+		ctrl_outl(EDTRR_TRNS, ndev->base_addr + EDTRR);
+
 	ndev->trans_start = jiffies;

 	return 0;
@@ -882,9 +1001,15 @@ static struct net_device_stats *sh_eth_get_stats(struct net_device *ndev)
 	ctrl_outl(0, ioaddr + CDCR);	/* (write clear) */
 	mdp->stats.tx_carrier_errors += ctrl_inl(ioaddr + LCCR);
 	ctrl_outl(0, ioaddr + LCCR);	/* (write clear) */
+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
+	mdp->stats.tx_carrier_errors += ctrl_inl(ioaddr + CERCR);/* CERCR */
+	ctrl_outl(0, ioaddr + CERCR);	/* (write clear) */
+	mdp->stats.tx_carrier_errors += ctrl_inl(ioaddr + CEECR);/* CEECR */
+	ctrl_outl(0, ioaddr + CEECR);	/* (write clear) */
+#else
 	mdp->stats.tx_carrier_errors += ctrl_inl(ioaddr + CNDCR);
 	ctrl_outl(0, ioaddr + CNDCR);	/* (write clear) */
-
+#endif
 	return &mdp->stats;
 }

@@ -934,8 +1059,13 @@ static void sh_eth_tsu_init(u32 ioaddr)
 	ctrl_outl(0, ioaddr + TSU_FWSL0);
 	ctrl_outl(0, ioaddr + TSU_FWSL1);
 	ctrl_outl(TSU_FWSLC_POSTENU | TSU_FWSLC_POSTENL, ioaddr + TSU_FWSLC);
+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
+	ctrl_outl(0, ioaddr + TSU_QTAG0);	/* Disable QTAG(0->1) */
+	ctrl_outl(0, ioaddr + TSU_QTAG1);	/* Disable QTAG(1->0) */
+#else
 	ctrl_outl(0, ioaddr + TSU_QTAGM0);	/* Disable QTAG(0->1) */
 	ctrl_outl(0, ioaddr + TSU_QTAGM1);	/* Disable QTAG(1->0) */
+#endif
 	ctrl_outl(0, ioaddr + TSU_FWSR);	/* all interrupt status clear */
 	ctrl_outl(0, ioaddr + TSU_FWINMK);	/* Disable all interrupt */
 	ctrl_outl(0, ioaddr + TSU_TEN);	/* Disable all CAM entry */
@@ -1093,7 +1223,7 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	/* First device only init */
 	if (!devno) {
 		/* reset device */
-		ctrl_outl(ARSTR_ARSTR, ndev->base_addr + ARSTR);
+		ctrl_outl(ARSTR_ARSTR, ARSTR);
 		mdelay(1);

 		/* TSU init (Init only)*/
@@ -1115,8 +1245,8 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	       ndev->name, CARDNAME, (u32) ndev->base_addr);

 	for (i = 0; i < 5; i++)
-		printk(KERN_INFO "%2.2x:", ndev->dev_addr[i]);
-	printk(KERN_INFO "%2.2x, IRQ %d.\n", ndev->dev_addr[i], ndev->irq);
+		printk(KERN_INFO "%02X:", ndev->dev_addr[i]);
+	printk(KERN_INFO "%02X, IRQ %d.\n", ndev->dev_addr[i], ndev->irq);

 	platform_set_drvdata(pdev, ndev);

diff --git a/drivers/net/sh_eth.h b/drivers/net/sh_eth.h
index 6cfff92..45ad1b0 100644
--- a/drivers/net/sh_eth.h
+++ b/drivers/net/sh_eth.h
@@ -32,118 +32,249 @@

 #define CARDNAME	"sh-eth"
 #define TX_TIMEOUT	(5*HZ)
-
-#define TX_RING_SIZE	128	/* Tx ring size */
-#define RX_RING_SIZE	128	/* Rx ring size */
-#define RX_OFFSET		2	/* skb offset */
+#define TX_RING_SIZE	64	/* Tx ring size */
+#define RX_RING_SIZE	64	/* Rx ring size */
 #define ETHERSMALL		60
 #define PKT_BUF_SZ		1538

+#ifdef CONFIG_CPU_SUBTYPE_SH7763
+
+#define SH7763_SKB_ALIGN 32
 /* Chip Base Address */
-#define SH_TSU_ADDR 0xA7000804
+# define SH_TSU_ADDR  0xFFE01800
+# define ARSTR 		  0xFFE01800
+
+/* Chip Registers */
+/* E-DMAC */
+# define EDSR    0x000
+# define EDMR    0x400
+# define EDTRR   0x408
+# define EDRRR   0x410
+# define EESR    0x428
+# define EESIPR  0x430
+# define TDLAR   0x010
+# define TDFAR   0x014
+# define TDFXR   0x018
+# define TDFFR   0x01C
+# define RDLAR   0x030
+# define RDFAR   0x034
+# define RDFXR   0x038
+# define RDFFR   0x03C
+# define TRSCER  0x438
+# define RMFCR   0x440
+# define TFTR    0x448
+# define FDR     0x450
+# define RMCR    0x458
+# define RPADIR  0x460
+# define FCFTR   0x468
+
+/* Ether Register */
+# define ECMR    0x500
+# define ECSR    0x510
+# define ECSIPR  0x518
+# define PIR     0x520
+# define PSR     0x528
+# define PIPR    0x52C
+# define RFLR    0x508
+# define APR     0x554
+# define MPR     0x558
+# define PFTCR	 0x55C
+# define PFRCR	 0x560
+# define TPAUSER 0x564
+# define GECMR   0x5B0
+# define BCULR   0x5B4
+# define MAHR    0x5C0
+# define MALR    0x5C8
+# define TROCR   0x700
+# define CDCR    0x708
+# define LCCR    0x710
+# define CEFCR   0x740
+# define FRECR   0x748
+# define TSFRCR  0x750
+# define TLFRCR  0x758
+# define RFCR    0x760
+# define CERCR   0x768
+# define CEECR   0x770
+# define MAFCR   0x778
+
+/* TSU Absolute Address */
+# define TSU_CTRST       0x004
+# define TSU_FWEN0       0x010
+# define TSU_FWEN1       0x014
+# define TSU_FCM         0x18
+# define TSU_BSYSL0      0x20
+# define TSU_BSYSL1      0x24
+# define TSU_PRISL0      0x28
+# define TSU_PRISL1      0x2C
+# define TSU_FWSL0       0x30
+# define TSU_FWSL1       0x34
+# define TSU_FWSLC       0x38
+# define TSU_QTAG0       0x40
+# define TSU_QTAG1       0x44
+# define TSU_FWSR        0x50
+# define TSU_FWINMK      0x54
+# define TSU_ADQT0       0x48
+# define TSU_ADQT1       0x4C
+# define TSU_VTAG0       0x58
+# define TSU_VTAG1       0x5C
+# define TSU_ADSBSY      0x60
+# define TSU_TEN         0x64
+# define TSU_POST1       0x70
+# define TSU_POST2       0x74
+# define TSU_POST3       0x78
+# define TSU_POST4       0x7C
+# define TSU_ADRH0       0x100
+# define TSU_ADRL0       0x104
+# define TSU_ADRH31      0x1F8
+# define TSU_ADRL31      0x1FC
+
+# define TXNLCR0         0x80
+# define TXALCR0         0x84
+# define RXNLCR0         0x88
+# define RXALCR0         0x8C
+# define FWNLCR0         0x90
+# define FWALCR0         0x94
+# define TXNLCR1         0xA0
+# define TXALCR1         0xA4
+# define RXNLCR1         0xA8
+# define RXALCR1         0xAC
+# define FWNLCR1         0xB0
+# define FWALCR1         0x40
+
+#else /* CONFIG_CPU_SUBTYPE_SH7763 */
+# define RX_OFFSET 2	/* skb offset */
+/* Chip base address */
+# define SH_TSU_ADDR  0xA7000804
+# define ARSTR		  0xA7000800

 /* Chip Registers */
 /* E-DMAC */
-#define EDMR	0x0000
-#define EDTRR	0x0004
-#define EDRRR	0x0008
-#define TDLAR	0x000C
-#define RDLAR	0x0010
-#define EESR	0x0014
-#define EESIPR	0x0018
-#define TRSCER	0x001C
-#define RMFCR	0x0020
-#define TFTR	0x0024
-#define FDR		0x0028
-#define RMCR	0x002C
-#define EDOCR	0x0030
-#define FCFTR	0x0034
-#define RPADIR	0x0038
-#define TRIMD	0x003C
-#define RBWAR	0x0040
-#define RDFAR	0x0044
-#define TBRAR	0x004C
-#define TDFAR	0x0050
+# define EDMR	0x0000
+# define EDTRR	0x0004
+# define EDRRR	0x0008
+# define TDLAR	0x000C
+# define RDLAR	0x0010
+# define EESR	0x0014
+# define EESIPR	0x0018
+# define TRSCER	0x001C
+# define RMFCR	0x0020
+# define TFTR	0x0024
+# define FDR	0x0028
+# define RMCR	0x002C
+# define EDOCR	0x0030
+# define FCFTR	0x0034
+# define RPADIR	0x0038
+# define TRIMD	0x003C
+# define RBWAR	0x0040
+# define RDFAR	0x0044
+# define TBRAR	0x004C
+# define TDFAR	0x0050
+
 /* Ether Register */
-#define ECMR	0x0160
-#define ECSR	0x0164
-#define ECSIPR	0x0168
-#define PIR		0x016C
-#define MAHR	0x0170
-#define MALR	0x0174
-#define RFLR	0x0178
-#define PSR		0x017C
-#define TROCR	0x0180
-#define CDCR	0x0184
-#define LCCR	0x0188
-#define CNDCR	0x018C
-#define CEFCR	0x0194
-#define FRECR	0x0198
-#define TSFRCR	0x019C
-#define TLFRCR	0x01A0
-#define RFCR	0x01A4
-#define MAFCR	0x01A8
-#define IPGR	0x01B4
-#if defined(CONFIG_CPU_SUBTYPE_SH7710)
-#define APR		0x01B8
-#define MPR 	0x01BC
-#define TPAUSER 0x1C4
-#define BCFR	0x1CC
-#endif /* CONFIG_CPU_SH7710 */
-
-#define ARSTR	0x0800
+# define ECMR	0x0160
+# define ECSR	0x0164
+# define ECSIPR	0x0168
+# define PIR	0x016C
+# define MAHR	0x0170
+# define MALR	0x0174
+# define RFLR	0x0178
+# define PSR	0x017C
+# define TROCR	0x0180
+# define CDCR	0x0184
+# define LCCR	0x0188
+# define CNDCR	0x018C
+# define CEFCR	0x0194
+# define FRECR	0x0198
+# define TSFRCR	0x019C
+# define TLFRCR	0x01A0
+# define RFCR	0x01A4
+# define MAFCR	0x01A8
+# define IPGR	0x01B4
+# if defined(CONFIG_CPU_SUBTYPE_SH7710)
+# define APR	0x01B8
+# define MPR 	0x01BC
+# define TPAUSER 0x1C4
+# define BCFR	0x1CC
+# endif /* CONFIG_CPU_SH7710 */

 /* TSU */
-#define TSU_CTRST	0x004
-#define TSU_FWEN0	0x010
-#define TSU_FWEN1	0x014
-#define TSU_FCM		0x018
-#define TSU_BSYSL0	0x020
-#define TSU_BSYSL1	0x024
-#define TSU_PRISL0	0x028
-#define TSU_PRISL1	0x02C
-#define TSU_FWSL0	0x030
-#define TSU_FWSL1	0x034
-#define TSU_FWSLC	0x038
-#define TSU_QTAGM0	0x040
-#define TSU_QTAGM1	0x044
-#define TSU_ADQT0 	0x048
-#define TSU_ADQT1	0x04C
-#define TSU_FWSR	0x050
-#define TSU_FWINMK	0x054
-#define TSU_ADSBSY	0x060
-#define TSU_TEN		0x064
-#define TSU_POST1	0x070
-#define TSU_POST2	0x074
-#define TSU_POST3	0x078
-#define TSU_POST4	0x07C
-#define TXNLCR0		0x080
-#define TXALCR0		0x084
-#define RXNLCR0		0x088
-#define RXALCR0		0x08C
-#define FWNLCR0		0x090
-#define FWALCR0		0x094
-#define TXNLCR1		0x0A0
-#define TXALCR1		0x0A4
-#define RXNLCR1		0x0A8
-#define RXALCR1		0x0AC
-#define FWNLCR1		0x0B0
-#define FWALCR1		0x0B4
+# define TSU_CTRST	0x004
+# define TSU_FWEN0	0x010
+# define TSU_FWEN1	0x014
+# define TSU_FCM	0x018
+# define TSU_BSYSL0	0x020
+# define TSU_BSYSL1	0x024
+# define TSU_PRISL0	0x028
+# define TSU_PRISL1	0x02C
+# define TSU_FWSL0	0x030
+# define TSU_FWSL1	0x034
+# define TSU_FWSLC	0x038
+# define TSU_QTAGM0	0x040
+# define TSU_QTAGM1	0x044
+# define TSU_ADQT0 	0x048
+# define TSU_ADQT1	0x04C
+# define TSU_FWSR	0x050
+# define TSU_FWINMK	0x054
+# define TSU_ADSBSY	0x060
+# define TSU_TEN	0x064
+# define TSU_POST1	0x070
+# define TSU_POST2	0x074
+# define TSU_POST3	0x078
+# define TSU_POST4	0x07C
+# define TXNLCR0	0x080
+# define TXALCR0	0x084
+# define RXNLCR0	0x088
+# define RXALCR0	0x08C
+# define FWNLCR0	0x090
+# define FWALCR0	0x094
+# define TXNLCR1	0x0A0
+# define TXALCR1	0x0A4
+# define RXNLCR1	0x0A8
+# define RXALCR1	0x0AC
+# define FWNLCR1	0x0B0
+# define FWALCR1	0x0B4

 #define TSU_ADRH0	0x0100
 #define TSU_ADRL0	0x0104
 #define TSU_ADRL31	0x01FC

-/* Register's bits */
+#endif /* CONFIG_CPU_SUBTYPE_SH7763 */
+
+/*
+ * Register's bits
+ */
+#ifdef CONFIG_CPU_SUBTYPE_SH7763
+/* EDSR */
+enum EDSR_BIT {
+	EDSR_ENT = 0x01, EDSR_ENR = 0x02,
+};
+#define EDSR_ENALL (EDSR_ENT|EDSR_ENR)
+
+/* GECMR */
+enum GECMR_BIT {
+	GECMR_10 = 0x0, GECMR_100 = 0x04, GECMR_1000 = 0x01,
+};
+#endif

 /* EDMR */
 enum DMAC_M_BIT {
-	EDMR_DL1 = 0x20, EDMR_DL0 = 0x10, EDMR_SRST = 0x01,
+	EDMR_DL1 = 0x20, EDMR_DL0 = 0x10,
+#ifdef CONFIG_CPU_SUBTYPE_SH7763
+	EDMR_SRST	= 0x03,
+	EMDR_DESC_R	= 0x30, /* Descriptor reserve size */
+	EDMR_EL		= 0x40, /* Litte endian */
+#else /* CONFIG_CPU_SUBTYPE_SH7763 */
+	EDMR_SRST = 0x01,
+#endif
 };

 /* EDTRR */
 enum DMAC_T_BIT {
+#ifdef CONFIG_CPU_SUBTYPE_SH7763
+	EDTRR_TRNS = 0x03,
+#else
 	EDTRR_TRNS = 0x01,
+#endif
 };

 /* EDRRR*/
@@ -173,21 +304,47 @@ enum PHY_STATUS_BIT { PHY_ST_LINK = 0x01, };

 /* EESR */
 enum EESR_BIT {
-	EESR_TWB = 0x40000000, EESR_TABT = 0x04000000,
+#ifndef CONFIG_CPU_SUBTYPE_SH7763
+	EESR_TWB  = 0x40000000,
+#else
+	EESR_TWB  = 0xC0000000,
+	EESR_TC1  = 0x20000000,
+	EESR_TUC  = 0x10000000,
+	EESR_ROC  = 0x80000000,
+#endif
+	EESR_TABT = 0x04000000,
 	EESR_RABT = 0x02000000, EESR_RFRMER = 0x01000000,
-	EESR_ADE = 0x00800000, EESR_ECI = 0x00400000,
-	EESR_FTC = 0x00200000, EESR_TDE = 0x00100000,
-	EESR_TFE = 0x00080000, EESR_FRC = 0x00040000,
-	EESR_RDE = 0x00020000, EESR_RFE = 0x00010000,
-	EESR_TINT4 = 0x00000800, EESR_TINT3 = 0x00000400,
-	EESR_TINT2 = 0x00000200, EESR_TINT1 = 0x00000100,
-	EESR_RINT8 = 0x00000080, EESR_RINT5 = 0x00000010,
-	EESR_RINT4 = 0x00000008, EESR_RINT3 = 0x00000004,
-	EESR_RINT2 = 0x00000002, EESR_RINT1 = 0x00000001,
-};
-
-#define EESR_ERR_CHECK	(EESR_TWB | EESR_TABT | EESR_RABT | EESR_RDE \
+#ifndef CONFIG_CPU_SUBTYPE_SH7763
+	EESR_ADE  = 0x00800000,
+#endif
+	EESR_ECI  = 0x00400000,
+	EESR_FTC  = 0x00200000, EESR_TDE  = 0x00100000,
+	EESR_TFE  = 0x00080000, EESR_FRC  = 0x00040000,
+	EESR_RDE  = 0x00020000, EESR_RFE  = 0x00010000,
+#ifndef CONFIG_CPU_SUBTYPE_SH7763
+	EESR_CND  = 0x00000800,
+#endif
+	EESR_DLC  = 0x00000400,
+	EESR_CD   = 0x00000200, EESR_RTO  = 0x00000100,
+	EESR_RMAF = 0x00000080, EESR_CEEF = 0x00000040,
+	EESR_CELF = 0x00000020, EESR_RRF  = 0x00000010,
+	EESR_RTLF = 0x00000008, EESR_RTSF = 0x00000004,
+	EESR_PRE  = 0x00000002, EESR_CERF = 0x00000001,
+};
+
+
+#ifdef CONFIG_CPU_SUBTYPE_SH7763
+# define TX_CHECK (EESR_TC1 | EESR_FTC)
+# define EESR_ERR_CHECK	(EESR_TWB | EESR_TABT | EESR_RABT | EESR_RDE \
+		| EESR_RFRMER | EESR_TFE | EESR_TDE | EESR_ECI)
+# define TX_ERROR_CEHCK (EESR_TWB | EESR_TABT | EESR_TDE | EESR_TFE)
+
+#else
+# define TX_CHECK (EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO)
+# define EESR_ERR_CHECK	(EESR_TWB | EESR_TABT | EESR_RABT | EESR_RDE \
 		| EESR_RFRMER | EESR_ADE | EESR_TFE | EESR_TDE | EESR_ECI)
+# define TX_ERROR_CEHCK (EESR_TWB | EESR_TABT | EESR_ADE | EESR_TDE | EESR_TFE)
+#endif

 /* EESIPR */
 enum DMAC_IM_BIT {
@@ -207,8 +364,8 @@ enum DMAC_IM_BIT {

 /* Receive descriptor bit */
 enum RD_STS_BIT {
-	RD_RACT = 0x80000000, RC_RDEL = 0x40000000,
-	RC_RFP1 = 0x20000000, RC_RFP0 = 0x10000000,
+	RD_RACT = 0x80000000, RD_RDEL = 0x40000000,
+	RD_RFP1 = 0x20000000, RD_RFP0 = 0x10000000,
 	RD_RFE = 0x08000000, RD_RFS10 = 0x00000200,
 	RD_RFS9 = 0x00000100, RD_RFS8 = 0x00000080,
 	RD_RFS7 = 0x00000040, RD_RFS6 = 0x00000020,
@@ -216,9 +373,9 @@ enum RD_STS_BIT {
 	RD_RFS3 = 0x00000004, RD_RFS2 = 0x00000002,
 	RD_RFS1 = 0x00000001,
 };
-#define RDF1ST	RC_RFP1
-#define RDFEND	RC_RFP0
-#define RD_RFP	(RC_RFP1|RC_RFP0)
+#define RDF1ST	RD_RFP1
+#define RDFEND	RD_RFP0
+#define RD_RFP	(RD_RFP1|RD_RFP0)

 /* FCFTR */
 enum FCFTR_BIT {
@@ -231,7 +388,8 @@ enum FCFTR_BIT {

 /* Transfer descriptor bit */
 enum TD_STS_BIT {
-	TD_TACT = 0x80000000, TD_TDLE = 0x40000000, TD_TFP1 = 0x20000000,
+	TD_TACT = 0x80000000,
+	TD_TDLE = 0x40000000, TD_TFP1 = 0x20000000,
 	TD_TFP0 = 0x10000000,
 };
 #define TDF1ST	TD_TFP1
@@ -242,6 +400,10 @@ enum TD_STS_BIT {
 enum RECV_RST_BIT { RMCR_RST = 0x01, };
 /* ECMR */
 enum FELIC_MODE_BIT {
+#ifdef CONFIG_CPU_SUBTYPE_SH7763
+	ECMR_TRCCM = 0x04000000, ECMR_RCSC = 0x00800000,
+	ECMR_DPAD = 0x00200000, ECMR_RZPF = 0x00100000,
+#endif
 	ECMR_ZPF = 0x00080000, ECMR_PFR = 0x00040000, ECMR_RXF = 0x00020000,
 	ECMR_TXF = 0x00010000, ECMR_MCT = 0x00002000, ECMR_PRCEF = 0x00001000,
 	ECMR_PMDE = 0x00000200, ECMR_RE = 0x00000040, ECMR_TE = 0x00000020,
@@ -249,18 +411,45 @@ enum FELIC_MODE_BIT {
 	ECMR_PRM = 0x00000001,
 };

+#ifdef CONFIG_CPU_SUBTYPE_SH7763
+#define ECMR_CHG_DM	(ECMR_TRCCM | ECMR_RZPF | ECMR_ZPF |\
+			ECMR_PFR | ECMR_RXF | ECMR_TXF | ECMR_MCT)
+#else
+#define ECMR_CHG_DM	(ECMR_ZPF | ECMR_PFR ECMR_RXF | ECMR_TXF | ECMR_MCT)
+#endif
+
 /* ECSR */
 enum ECSR_STATUS_BIT {
-	ECSR_BRCRX = 0x20, ECSR_PSRTO = 0x10, ECSR_LCHNG = 0x04,
+#ifndef CONFIG_CPU_SUBTYPE_SH7763
+	ECSR_BRCRX = 0x20, ECSR_PSRTO = 0x10,
+#endif
+	ECSR_LCHNG = 0x04,
 	ECSR_MPD = 0x02, ECSR_ICD = 0x01,
 };

+#ifdef CONFIG_CPU_SUBTYPE_SH7763
+# define ECSR_INIT (ECSR_ICD | ECSIPR_MPDIP)
+#else
+# define ECSR_INIT (ECSR_BRCRX | ECSR_PSRTO | \
+			ECSR_LCHNG | ECSR_ICD | ECSIPR_MPDIP)
+#endif
+
 /* ECSIPR */
 enum ECSIPR_STATUS_MASK_BIT {
-	ECSIPR_BRCRXIP = 0x20, ECSIPR_PSRTOIP = 0x10, ECSIPR_LCHNGIP = 0x04,
+#ifndef CONFIG_CPU_SUBTYPE_SH7763
+	ECSIPR_BRCRXIP = 0x20, ECSIPR_PSRTOIP = 0x10,
+#endif
+	ECSIPR_LCHNGIP = 0x04,
 	ECSIPR_MPDIP = 0x02, ECSIPR_ICDIP = 0x01,
 };

+#ifdef CONFIG_CPU_SUBTYPE_SH7763
+# define ECSIPR_INIT (ECSIPR_LCHNGIP | ECSIPR_ICDIP | ECSIPR_MPDIP)
+#else
+# define ECSIPR_INIT (ECSIPR_BRCRXIP | ECSIPR_PSRTOIP | ECSIPR_LCHNGIP | \
+				ECSIPR_ICDIP | ECSIPR_MPDIP)
+#endif
+
 /* APR */
 enum APR_BIT {
 	APR_AP = 0x00000001,
@@ -285,6 +474,15 @@ enum RPADIR_BIT {
 	RPADIR_PADR = 0x0003f,
 };

+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
+# define RPADIR_INIT (0x00)
+#else
+# define RPADIR_INIT (RPADIR_PADS1)
+#endif
+
+/* RFLR */
+#define RFLR_VALUE 0x1000
+
 /* FDR */
 enum FIFO_SIZE_BIT {
 	FIFO_SIZE_T = 0x00000700, FIFO_SIZE_R = 0x00000007,
@@ -316,7 +514,7 @@ enum PHY_ANA_BIT {
 	PHY_A_NP = 0x8000, PHY_A_ACK = 0x4000, PHY_A_RF = 0x2000,
 	PHY_A_FCS = 0x0400, PHY_A_T4 = 0x0200, PHY_A_FDX = 0x0100,
 	PHY_A_HDX = 0x0080, PHY_A_10FDX = 0x0040, PHY_A_10HDX = 0x0020,
-	PHY_A_SEL = 0x001f,
+	PHY_A_SEL = 0x001e,
 };
 /* PHY_ANL */
 enum PHY_ANL_BIT {
@@ -449,6 +647,10 @@ struct sh_eth_private {
 	struct net_device_stats tsu_stats;	/* TSU forward status */
 };

+#ifdef CONFIG_CPU_SUBTYPE_SH7763
+/* SH7763 has endian control register */
+#define swaps(x, y)
+#else
 static void swaps(char *src, int len)
 {
 #ifdef __LITTLE_ENDIAN__
@@ -460,4 +662,5 @@ static void swaps(char *src, int len)
 		*p = swab32(*p);
 #endif
 }
+#endif /* CONFIG_CPU_SUBTYPE_SH7763 */
 #endif
-- 
1.5.5.1


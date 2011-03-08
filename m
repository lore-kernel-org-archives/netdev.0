From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: [PATCH v2 1/6] net: sh_eth: modify the definitions of register
Date: Tue, 08 Mar 2011 16:59:26 +0900
Message-ID: <4D75E1DE.3030408@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SH-Linux <linux-sh@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The previous code cannot handle the ETHER and GETHER both as same time
because the definitions of register was hardcoded.

Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
---
 This patch are based on net-next-2.6.git.

 about v2:
  - remove SH_ETH_REG_DEFAULT

 arch/sh/include/asm/sh_eth.h |    6 +
 drivers/net/sh_eth.c         |  326 +++++++++++-----------
 drivers/net/sh_eth.h         |  623 ++++++++++++++++++++++++------------------
 3 files changed, 533 insertions(+), 422 deletions(-)

diff --git a/arch/sh/include/asm/sh_eth.h b/arch/sh/include/asm/sh_eth.h
index f739061..1557696 100644
--- a/arch/sh/include/asm/sh_eth.h
+++ b/arch/sh/include/asm/sh_eth.h
@@ -2,10 +2,16 @@
 #define __ASM_SH_ETH_H__

 enum {EDMAC_LITTLE_ENDIAN, EDMAC_BIG_ENDIAN};
+enum {
+	SH_ETH_REG_GIGABIT,
+	SH_ETH_REG_FAST_SH4,
+	SH_ETH_REG_FAST_SH3_SH2
+};

 struct sh_eth_plat_data {
 	int phy;
 	int edmac_endian;
+	int register_type;

 	unsigned char mac_addr[6];
 	unsigned no_ether_link:1;
diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 095e525..51268f5 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -49,25 +49,23 @@
 static void sh_eth_set_duplex(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
-	u32 ioaddr = ndev->base_addr;

 	if (mdp->duplex) /* Full */
-		writel(readl(ioaddr + ECMR) | ECMR_DM, ioaddr + ECMR);
+		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) | ECMR_DM, ECMR);
 	else		/* Half */
-		writel(readl(ioaddr + ECMR) & ~ECMR_DM, ioaddr + ECMR);
+		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) & ~ECMR_DM, ECMR);
 }

 static void sh_eth_set_rate(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
-	u32 ioaddr = ndev->base_addr;

 	switch (mdp->speed) {
 	case 10: /* 10BASE */
-		writel(readl(ioaddr + ECMR) & ~ECMR_RTM, ioaddr + ECMR);
+		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) & ~ECMR_RTM, ECMR);
 		break;
 	case 100:/* 100BASE */
-		writel(readl(ioaddr + ECMR) | ECMR_RTM, ioaddr + ECMR);
+		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) | ECMR_RTM, ECMR);
 		break;
 	default:
 		break;
@@ -100,25 +98,23 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 static void sh_eth_set_duplex(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
-	u32 ioaddr = ndev->base_addr;

 	if (mdp->duplex) /* Full */
-		writel(readl(ioaddr + ECMR) | ECMR_DM, ioaddr + ECMR);
+		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) | ECMR_DM, ECMR);
 	else		/* Half */
-		writel(readl(ioaddr + ECMR) & ~ECMR_DM, ioaddr + ECMR);
+		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) & ~ECMR_DM, ECMR);
 }

 static void sh_eth_set_rate(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
-	u32 ioaddr = ndev->base_addr;

 	switch (mdp->speed) {
 	case 10: /* 10BASE */
-		writel(0, ioaddr + RTRATE);
+		sh_eth_write(ndev, 0, RTRATE);
 		break;
 	case 100:/* 100BASE */
-		writel(1, ioaddr + RTRATE);
+		sh_eth_write(ndev, 1, RTRATE);
 		break;
 	default:
 		break;
@@ -156,13 +152,12 @@ static void sh_eth_chip_reset(struct net_device *ndev)

 static void sh_eth_reset(struct net_device *ndev)
 {
-	u32 ioaddr = ndev->base_addr;
 	int cnt = 100;

-	writel(EDSR_ENALL, ioaddr + EDSR);
-	writel(readl(ioaddr + EDMR) | EDMR_SRST, ioaddr + EDMR);
+	sh_eth_write(ndev, EDSR_ENALL, EDSR);
+	sh_eth_write(ndev, sh_eth_read(ndev, EDMR) | EDMR_SRST, EDMR);
 	while (cnt > 0) {
-		if (!(readl(ioaddr + EDMR) & 0x3))
+		if (!(sh_eth_read(ndev, EDMR) & 0x3))
 			break;
 		mdelay(1);
 		cnt--;
@@ -171,41 +166,39 @@ static void sh_eth_reset(struct net_device *ndev)
 		printk(KERN_ERR "Device reset fail\n");

 	/* Table Init */
-	writel(0x0, ioaddr + TDLAR);
-	writel(0x0, ioaddr + TDFAR);
-	writel(0x0, ioaddr + TDFXR);
-	writel(0x0, ioaddr + TDFFR);
-	writel(0x0, ioaddr + RDLAR);
-	writel(0x0, ioaddr + RDFAR);
-	writel(0x0, ioaddr + RDFXR);
-	writel(0x0, ioaddr + RDFFR);
+	sh_eth_write(ndev, 0x0, TDLAR);
+	sh_eth_write(ndev, 0x0, TDFAR);
+	sh_eth_write(ndev, 0x0, TDFXR);
+	sh_eth_write(ndev, 0x0, TDFFR);
+	sh_eth_write(ndev, 0x0, RDLAR);
+	sh_eth_write(ndev, 0x0, RDFAR);
+	sh_eth_write(ndev, 0x0, RDFXR);
+	sh_eth_write(ndev, 0x0, RDFFR);
 }

 static void sh_eth_set_duplex(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
-	u32 ioaddr = ndev->base_addr;

 	if (mdp->duplex) /* Full */
-		writel(readl(ioaddr + ECMR) | ECMR_DM, ioaddr + ECMR);
+		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) | ECMR_DM, ECMR);
 	else		/* Half */
-		writel(readl(ioaddr + ECMR) & ~ECMR_DM, ioaddr + ECMR);
+		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) & ~ECMR_DM, ECMR);
 }

 static void sh_eth_set_rate(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
-	u32 ioaddr = ndev->base_addr;

 	switch (mdp->speed) {
 	case 10: /* 10BASE */
-		writel(GECMR_10, ioaddr + GECMR);
+		sh_eth_write(ndev, GECMR_10, GECMR);
 		break;
 	case 100:/* 100BASE */
-		writel(GECMR_100, ioaddr + GECMR);
+		sh_eth_write(ndev, GECMR_100, GECMR);
 		break;
 	case 1000: /* 1000BASE */
-		writel(GECMR_1000, ioaddr + GECMR);
+		sh_eth_write(ndev, GECMR_1000, GECMR);
 		break;
 	default:
 		break;
@@ -288,11 +281,9 @@ static void sh_eth_set_default_cpu_data(struct sh_eth_cpu_data *cd)
 /* Chip Reset */
 static void sh_eth_reset(struct net_device *ndev)
 {
-	u32 ioaddr = ndev->base_addr;
-
-	writel(readl(ioaddr + EDMR) | EDMR_SRST, ioaddr + EDMR);
+	sh_eth_write(ndev, sh_eth_read(ndev, EDMR) | EDMR_SRST, EDMR);
 	mdelay(3);
-	writel(readl(ioaddr + EDMR) & ~EDMR_SRST, ioaddr + EDMR);
+	sh_eth_write(ndev, sh_eth_read(ndev, EDMR) & ~EDMR_SRST, EDMR);
 }
 #endif

@@ -341,13 +332,11 @@ static inline __u32 edmac_to_cpu(struct sh_eth_private *mdp, u32 x)
  */
 static void update_mac_address(struct net_device *ndev)
 {
-	u32 ioaddr = ndev->base_addr;
-
-	writel((ndev->dev_addr[0] << 24) | (ndev->dev_addr[1] << 16) |
-		  (ndev->dev_addr[2] << 8) | (ndev->dev_addr[3]),
-		  ioaddr + MAHR);
-	writel((ndev->dev_addr[4] << 8) | (ndev->dev_addr[5]),
-		  ioaddr + MALR);
+	sh_eth_write(ndev,
+		(ndev->dev_addr[0] << 24) | (ndev->dev_addr[1] << 16) |
+		(ndev->dev_addr[2] << 8) | (ndev->dev_addr[3]), MAHR);
+	sh_eth_write(ndev,
+		(ndev->dev_addr[4] << 8) | (ndev->dev_addr[5]), MALR);
 }

 /*
@@ -360,17 +349,15 @@ static void update_mac_address(struct net_device *ndev)
  */
 static void read_mac_address(struct net_device *ndev, unsigned char *mac)
 {
-	u32 ioaddr = ndev->base_addr;
-
 	if (mac[0] || mac[1] || mac[2] || mac[3] || mac[4] || mac[5]) {
 		memcpy(ndev->dev_addr, mac, 6);
 	} else {
-		ndev->dev_addr[0] = (readl(ioaddr + MAHR) >> 24);
-		ndev->dev_addr[1] = (readl(ioaddr + MAHR) >> 16) & 0xFF;
-		ndev->dev_addr[2] = (readl(ioaddr + MAHR) >> 8) & 0xFF;
-		ndev->dev_addr[3] = (readl(ioaddr + MAHR) & 0xFF);
-		ndev->dev_addr[4] = (readl(ioaddr + MALR) >> 8) & 0xFF;
-		ndev->dev_addr[5] = (readl(ioaddr + MALR) & 0xFF);
+		ndev->dev_addr[0] = (sh_eth_read(ndev, MAHR) >> 24);
+		ndev->dev_addr[1] = (sh_eth_read(ndev, MAHR) >> 16) & 0xFF;
+		ndev->dev_addr[2] = (sh_eth_read(ndev, MAHR) >> 8) & 0xFF;
+		ndev->dev_addr[3] = (sh_eth_read(ndev, MAHR) & 0xFF);
+		ndev->dev_addr[4] = (sh_eth_read(ndev, MALR) >> 8) & 0xFF;
+		ndev->dev_addr[5] = (sh_eth_read(ndev, MALR) & 0xFF);
 	}
 }

@@ -477,7 +464,6 @@ static void sh_eth_ring_free(struct net_device *ndev)
 /* format skb and descriptor buffer */
 static void sh_eth_ring_format(struct net_device *ndev)
 {
-	u32 ioaddr = ndev->base_addr;
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	int i;
 	struct sk_buff *skb;
@@ -513,9 +499,9 @@ static void sh_eth_ring_format(struct net_device *ndev)
 		rxdesc->buffer_length = ALIGN(mdp->rx_buf_sz, 16);
 		/* Rx descriptor address set */
 		if (i == 0) {
-			writel(mdp->rx_desc_dma, ioaddr + RDLAR);
+			sh_eth_write(ndev, mdp->rx_desc_dma, RDLAR);
 #if defined(CONFIG_CPU_SUBTYPE_SH7763)
-			writel(mdp->rx_desc_dma, ioaddr + RDFAR);
+			sh_eth_write(ndev, mdp->rx_desc_dma, RDFAR);
 #endif
 		}
 	}
@@ -535,9 +521,9 @@ static void sh_eth_ring_format(struct net_device *ndev)
 		txdesc->buffer_length = 0;
 		if (i == 0) {
 			/* Tx descriptor address set */
-			writel(mdp->tx_desc_dma, ioaddr + TDLAR);
+			sh_eth_write(ndev, mdp->tx_desc_dma, TDLAR);
 #if defined(CONFIG_CPU_SUBTYPE_SH7763)
-			writel(mdp->tx_desc_dma, ioaddr + TDFAR);
+			sh_eth_write(ndev, mdp->tx_desc_dma, TDFAR);
 #endif
 		}
 	}
@@ -620,7 +606,6 @@ static int sh_eth_dev_init(struct net_device *ndev)
 {
 	int ret = 0;
 	struct sh_eth_private *mdp = netdev_priv(ndev);
-	u32 ioaddr = ndev->base_addr;
 	u_int32_t rx_int_var, tx_int_var;
 	u32 val;

@@ -630,71 +615,71 @@ static int sh_eth_dev_init(struct net_device *ndev)
 	/* Descriptor format */
 	sh_eth_ring_format(ndev);
 	if (mdp->cd->rpadir)
-		writel(mdp->cd->rpadir_value, ioaddr + RPADIR);
+		sh_eth_write(ndev, mdp->cd->rpadir_value, RPADIR);

 	/* all sh_eth int mask */
-	writel(0, ioaddr + EESIPR);
+	sh_eth_write(ndev, 0, EESIPR);

 #if defined(__LITTLE_ENDIAN__)
 	if (mdp->cd->hw_swap)
-		writel(EDMR_EL, ioaddr + EDMR);
+		sh_eth_write(ndev, EDMR_EL, EDMR);
 	else
 #endif
-		writel(0, ioaddr + EDMR);
+		sh_eth_write(ndev, 0, EDMR);

 	/* FIFO size set */
-	writel(mdp->cd->fdr_value, ioaddr + FDR);
-	writel(0, ioaddr + TFTR);
+	sh_eth_write(ndev, mdp->cd->fdr_value, FDR);
+	sh_eth_write(ndev, 0, TFTR);

 	/* Frame recv control */
-	writel(mdp->cd->rmcr_value, ioaddr + RMCR);
+	sh_eth_write(ndev, mdp->cd->rmcr_value, RMCR);

 	rx_int_var = mdp->rx_int_var = DESC_I_RINT8 | DESC_I_RINT5;
 	tx_int_var = mdp->tx_int_var = DESC_I_TINT2;
-	writel(rx_int_var | tx_int_var, ioaddr + TRSCER);
+	sh_eth_write(ndev, rx_int_var | tx_int_var, TRSCER);

 	if (mdp->cd->bculr)
-		writel(0x800, ioaddr + BCULR);	/* Burst sycle set */
+		sh_eth_write(ndev, 0x800, BCULR);	/* Burst sycle set */

-	writel(mdp->cd->fcftr_value, ioaddr + FCFTR);
+	sh_eth_write(ndev, mdp->cd->fcftr_value, FCFTR);

 	if (!mdp->cd->no_trimd)
-		writel(0, ioaddr + TRIMD);
+		sh_eth_write(ndev, 0, TRIMD);

 	/* Recv frame limit set register */
-	writel(RFLR_VALUE, ioaddr + RFLR);
+	sh_eth_write(ndev, RFLR_VALUE, RFLR);

-	writel(readl(ioaddr + EESR), ioaddr + EESR);
-	writel(mdp->cd->eesipr_value, ioaddr + EESIPR);
+	sh_eth_write(ndev, sh_eth_read(ndev, EESR), EESR);
+	sh_eth_write(ndev, mdp->cd->eesipr_value, EESIPR);

 	/* PAUSE Prohibition */
-	val = (readl(ioaddr + ECMR) & ECMR_DM) |
+	val = (sh_eth_read(ndev, ECMR) & ECMR_DM) |
 		ECMR_ZPF | (mdp->duplex ? ECMR_DM : 0) | ECMR_TE | ECMR_RE;

-	writel(val, ioaddr + ECMR);
+	sh_eth_write(ndev, val, ECMR);

 	if (mdp->cd->set_rate)
 		mdp->cd->set_rate(ndev);

 	/* E-MAC Status Register clear */
-	writel(mdp->cd->ecsr_value, ioaddr + ECSR);
+	sh_eth_write(ndev, mdp->cd->ecsr_value, ECSR);

 	/* E-MAC Interrupt Enable register */
-	writel(mdp->cd->ecsipr_value, ioaddr + ECSIPR);
+	sh_eth_write(ndev, mdp->cd->ecsipr_value, ECSIPR);

 	/* Set MAC address */
 	update_mac_address(ndev);

 	/* mask reset */
 	if (mdp->cd->apr)
-		writel(APR_AP, ioaddr + APR);
+		sh_eth_write(ndev, APR_AP, APR);
 	if (mdp->cd->mpr)
-		writel(MPR_MP, ioaddr + MPR);
+		sh_eth_write(ndev, MPR_MP, MPR);
 	if (mdp->cd->tpauser)
-		writel(TPAUSER_UNLIMITED, ioaddr + TPAUSER);
+		sh_eth_write(ndev, TPAUSER_UNLIMITED, TPAUSER);

 	/* Setting the Rx mode will start the Rx process. */
-	writel(EDRRR_R, ioaddr + EDRRR);
+	sh_eth_write(ndev, EDRRR_R, EDRRR);

 	netif_start_queue(ndev);

@@ -818,38 +803,37 @@ static int sh_eth_rx(struct net_device *ndev)

 	/* Restart Rx engine if stopped. */
 	/* If we don't need to check status, don't. -KDU */
-	if (!(readl(ndev->base_addr + EDRRR) & EDRRR_R))
-		writel(EDRRR_R, ndev->base_addr + EDRRR);
+	if (!(sh_eth_read(ndev, EDRRR) & EDRRR_R))
+		sh_eth_write(ndev, EDRRR_R, EDRRR);

 	return 0;
 }

-static void sh_eth_rcv_snd_disable(u32 ioaddr)
+static void sh_eth_rcv_snd_disable(struct net_device *ndev)
 {
 	/* disable tx and rx */
-	writel(readl(ioaddr + ECMR) &
-		~(ECMR_RE | ECMR_TE), ioaddr + ECMR);
+	sh_eth_write(ndev, sh_eth_read(ndev, ECMR) &
+		~(ECMR_RE | ECMR_TE), ECMR);
 }

-static void sh_eth_rcv_snd_enable(u32 ioaddr)
+static void sh_eth_rcv_snd_enable(struct net_device *ndev)
 {
 	/* enable tx and rx */
-	writel(readl(ioaddr + ECMR) |
-		(ECMR_RE | ECMR_TE), ioaddr + ECMR);
+	sh_eth_write(ndev, sh_eth_read(ndev, ECMR) |
+		(ECMR_RE | ECMR_TE), ECMR);
 }

 /* error control function */
 static void sh_eth_error(struct net_device *ndev, int intr_status)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
-	u32 ioaddr = ndev->base_addr;
 	u32 felic_stat;
 	u32 link_stat;
 	u32 mask;

 	if (intr_status & EESR_ECI) {
-		felic_stat = readl(ioaddr + ECSR);
-		writel(felic_stat, ioaddr + ECSR);	/* clear int */
+		felic_stat = sh_eth_read(ndev, ECSR);
+		sh_eth_write(ndev, felic_stat, ECSR);	/* clear int */
 		if (felic_stat & ECSR_ICD)
 			mdp->stats.tx_carrier_errors++;
 		if (felic_stat & ECSR_LCHNG) {
@@ -860,23 +844,23 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 				else
 					link_stat = PHY_ST_LINK;
 			} else {
-				link_stat = (readl(ioaddr + PSR));
+				link_stat = (sh_eth_read(ndev, PSR));
 				if (mdp->ether_link_active_low)
 					link_stat = ~link_stat;
 			}
 			if (!(link_stat & PHY_ST_LINK))
-				sh_eth_rcv_snd_disable(ioaddr);
+				sh_eth_rcv_snd_disable(ndev);
 			else {
 				/* Link Up */
-				writel(readl(ioaddr + EESIPR) &
-					  ~DMAC_M_ECI, ioaddr + EESIPR);
+				sh_eth_write(ndev, sh_eth_read(ndev, EESIPR) &
+					  ~DMAC_M_ECI, EESIPR);
 				/*clear int */
-				writel(readl(ioaddr + ECSR),
-					  ioaddr + ECSR);
-				writel(readl(ioaddr + EESIPR) |
-					  DMAC_M_ECI, ioaddr + EESIPR);
+				sh_eth_write(ndev, sh_eth_read(ndev, ECSR),
+					  ECSR);
+				sh_eth_write(ndev, sh_eth_read(ndev, EESIPR) |
+					  DMAC_M_ECI, EESIPR);
 				/* enable tx and rx */
-				sh_eth_rcv_snd_enable(ioaddr);
+				sh_eth_rcv_snd_enable(ndev);
 			}
 		}
 	}
@@ -917,8 +901,8 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 		/* Receive Descriptor Empty int */
 		mdp->stats.rx_over_errors++;

-		if (readl(ioaddr + EDRRR) ^ EDRRR_R)
-			writel(EDRRR_R, ioaddr + EDRRR);
+		if (sh_eth_read(ndev, EDRRR) ^ EDRRR_R)
+			sh_eth_write(ndev, EDRRR_R, EDRRR);
 		if (netif_msg_rx_err(mdp))
 			dev_err(&ndev->dev, "Receive Descriptor Empty\n");
 	}
@@ -942,7 +926,7 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 		mask &= ~EESR_ADE;
 	if (intr_status & mask) {
 		/* Tx error */
-		u32 edtrr = readl(ndev->base_addr + EDTRR);
+		u32 edtrr = sh_eth_read(ndev, EDTRR);
 		/* dmesg */
 		dev_err(&ndev->dev, "TX error. status=%8.8x cur_tx=%8.8x ",
 				intr_status, mdp->cur_tx);
@@ -954,7 +938,7 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 		/* SH7712 BUG */
 		if (edtrr ^ EDTRR_TRNS) {
 			/* tx dma start */
-			writel(EDTRR_TRNS, ndev->base_addr + EDTRR);
+			sh_eth_write(ndev, EDTRR_TRNS, EDTRR);
 		}
 		/* wakeup */
 		netif_wake_queue(ndev);
@@ -967,18 +951,17 @@ static irqreturn_t sh_eth_interrupt(int irq, void *netdev)
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	struct sh_eth_cpu_data *cd = mdp->cd;
 	irqreturn_t ret = IRQ_NONE;
-	u32 ioaddr, intr_status = 0;
+	u32 intr_status = 0;

-	ioaddr = ndev->base_addr;
 	spin_lock(&mdp->lock);

 	/* Get interrpt stat */
-	intr_status = readl(ioaddr + EESR);
+	intr_status = sh_eth_read(ndev, EESR);
 	/* Clear interrupt */
 	if (intr_status & (EESR_FRC | EESR_RMAF | EESR_RRF |
 			EESR_RTLF | EESR_RTSF | EESR_PRE | EESR_CERF |
 			cd->tx_check | cd->eesr_err_check)) {
-		writel(intr_status, ioaddr + EESR);
+		sh_eth_write(ndev, intr_status, EESR);
 		ret = IRQ_HANDLED;
 	} else
 		goto other_irq;
@@ -1021,7 +1004,6 @@ static void sh_eth_adjust_link(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	struct phy_device *phydev = mdp->phydev;
-	u32 ioaddr = ndev->base_addr;
 	int new_state = 0;

 	if (phydev->link != PHY_DOWN) {
@@ -1039,8 +1021,8 @@ static void sh_eth_adjust_link(struct net_device *ndev)
 				mdp->cd->set_rate(ndev);
 		}
 		if (mdp->link == PHY_DOWN) {
-			writel((readl(ioaddr + ECMR) & ~ECMR_TXF)
-					| ECMR_DM, ioaddr + ECMR);
+			sh_eth_write(ndev, (sh_eth_read(ndev, ECMR) & ~ECMR_TXF)
+					| ECMR_DM, ECMR);
 			new_state = 1;
 			mdp->link = phydev->link;
 		}
@@ -1122,12 +1104,11 @@ static int sh_eth_set_settings(struct net_device *ndev,
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	unsigned long flags;
 	int ret;
-	u32 ioaddr = ndev->base_addr;

 	spin_lock_irqsave(&mdp->lock, flags);

 	/* disable tx and rx */
-	sh_eth_rcv_snd_disable(ioaddr);
+	sh_eth_rcv_snd_disable(ndev);

 	ret = phy_ethtool_sset(mdp->phydev, ecmd);
 	if (ret)
@@ -1145,7 +1126,7 @@ error_exit:
 	mdelay(1);

 	/* enable tx and rx */
-	sh_eth_rcv_snd_enable(ioaddr);
+	sh_eth_rcv_snd_enable(ndev);

 	spin_unlock_irqrestore(&mdp->lock, flags);

@@ -1282,7 +1263,6 @@ out_free_irq:
 static void sh_eth_tx_timeout(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
-	u32 ioaddr = ndev->base_addr;
 	struct sh_eth_rxdesc *rxdesc;
 	int i;

@@ -1290,7 +1270,7 @@ static void sh_eth_tx_timeout(struct net_device *ndev)

 	if (netif_msg_timer(mdp))
 		dev_err(&ndev->dev, "%s: transmit timed out, status %8.8x,"
-	       " resetting...\n", ndev->name, (int)readl(ioaddr + EESR));
+	       " resetting...\n", ndev->name, (int)sh_eth_read(ndev, EESR));

 	/* tx_errors count up */
 	mdp->stats.tx_errors++;
@@ -1363,8 +1343,8 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)

 	mdp->cur_tx++;

-	if (!(readl(ndev->base_addr + EDTRR) & EDTRR_TRNS))
-		writel(EDTRR_TRNS, ndev->base_addr + EDTRR);
+	if (!(sh_eth_read(ndev, EDTRR) & EDTRR_TRNS))
+		sh_eth_write(ndev, EDTRR_TRNS, EDTRR);

 	return NETDEV_TX_OK;
 }
@@ -1373,17 +1353,16 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 static int sh_eth_close(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
-	u32 ioaddr = ndev->base_addr;
 	int ringsize;

 	netif_stop_queue(ndev);

 	/* Disable interrupts by clearing the interrupt mask. */
-	writel(0x0000, ioaddr + EESIPR);
+	sh_eth_write(ndev, 0x0000, EESIPR);

 	/* Stop the chip's Tx and Rx processes. */
-	writel(0, ioaddr + EDTRR);
-	writel(0, ioaddr + EDRRR);
+	sh_eth_write(ndev, 0, EDTRR);
+	sh_eth_write(ndev, 0, EDRRR);

 	/* PHY Disconnect */
 	if (mdp->phydev) {
@@ -1414,24 +1393,23 @@ static int sh_eth_close(struct net_device *ndev)
 static struct net_device_stats *sh_eth_get_stats(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
-	u32 ioaddr = ndev->base_addr;

 	pm_runtime_get_sync(&mdp->pdev->dev);

-	mdp->stats.tx_dropped += readl(ioaddr + TROCR);
-	writel(0, ioaddr + TROCR);	/* (write clear) */
-	mdp->stats.collisions += readl(ioaddr + CDCR);
-	writel(0, ioaddr + CDCR);	/* (write clear) */
-	mdp->stats.tx_carrier_errors += readl(ioaddr + LCCR);
-	writel(0, ioaddr + LCCR);	/* (write clear) */
+	mdp->stats.tx_dropped += sh_eth_read(ndev, TROCR);
+	sh_eth_write(ndev, 0, TROCR);	/* (write clear) */
+	mdp->stats.collisions += sh_eth_read(ndev, CDCR);
+	sh_eth_write(ndev, 0, CDCR);	/* (write clear) */
+	mdp->stats.tx_carrier_errors += sh_eth_read(ndev, LCCR);
+	sh_eth_write(ndev, 0, LCCR);	/* (write clear) */
 #if defined(CONFIG_CPU_SUBTYPE_SH7763)
-	mdp->stats.tx_carrier_errors += readl(ioaddr + CERCR);/* CERCR */
-	writel(0, ioaddr + CERCR);	/* (write clear) */
-	mdp->stats.tx_carrier_errors += readl(ioaddr + CEECR);/* CEECR */
-	writel(0, ioaddr + CEECR);	/* (write clear) */
+	mdp->stats.tx_carrier_errors += sh_eth_read(ndev, CERCR);/* CERCR */
+	sh_eth_write(ndev, 0, CERCR);	/* (write clear) */
+	mdp->stats.tx_carrier_errors += sh_eth_read(ndev, CEECR);/* CEECR */
+	sh_eth_write(ndev, 0, CEECR);	/* (write clear) */
 #else
-	mdp->stats.tx_carrier_errors += readl(ioaddr + CNDCR);
-	writel(0, ioaddr + CNDCR);	/* (write clear) */
+	mdp->stats.tx_carrier_errors += sh_eth_read(ndev, CNDCR);
+	sh_eth_write(ndev, 0, CNDCR);	/* (write clear) */
 #endif
 	pm_runtime_put_sync(&mdp->pdev->dev);

@@ -1458,46 +1436,44 @@ static int sh_eth_do_ioctl(struct net_device *ndev, struct ifreq *rq,
 /* Multicast reception directions set */
 static void sh_eth_set_multicast_list(struct net_device *ndev)
 {
-	u32 ioaddr = ndev->base_addr;
-
 	if (ndev->flags & IFF_PROMISC) {
 		/* Set promiscuous. */
-		writel((readl(ioaddr + ECMR) & ~ECMR_MCT) | ECMR_PRM,
-			  ioaddr + ECMR);
+		sh_eth_write(ndev, (sh_eth_read(ndev, ECMR) & ~ECMR_MCT) |
+				ECMR_PRM, ECMR);
 	} else {
 		/* Normal, unicast/broadcast-only mode. */
-		writel((readl(ioaddr + ECMR) & ~ECMR_PRM) | ECMR_MCT,
-			  ioaddr + ECMR);
+		sh_eth_write(ndev, (sh_eth_read(ndev, ECMR) & ~ECMR_PRM) |
+				ECMR_MCT, ECMR);
 	}
 }

 /* SuperH's TSU register init function */
-static void sh_eth_tsu_init(u32 ioaddr)
+static void sh_eth_tsu_init(struct sh_eth_private *mdp)
 {
-	writel(0, ioaddr + TSU_FWEN0);	/* Disable forward(0->1) */
-	writel(0, ioaddr + TSU_FWEN1);	/* Disable forward(1->0) */
-	writel(0, ioaddr + TSU_FCM);	/* forward fifo 3k-3k */
-	writel(0xc, ioaddr + TSU_BSYSL0);
-	writel(0xc, ioaddr + TSU_BSYSL1);
-	writel(0, ioaddr + TSU_PRISL0);
-	writel(0, ioaddr + TSU_PRISL1);
-	writel(0, ioaddr + TSU_FWSL0);
-	writel(0, ioaddr + TSU_FWSL1);
-	writel(TSU_FWSLC_POSTENU | TSU_FWSLC_POSTENL, ioaddr + TSU_FWSLC);
+	sh_eth_tsu_write(mdp, 0, TSU_FWEN0);	/* Disable forward(0->1) */
+	sh_eth_tsu_write(mdp, 0, TSU_FWEN1);	/* Disable forward(1->0) */
+	sh_eth_tsu_write(mdp, 0, TSU_FCM);	/* forward fifo 3k-3k */
+	sh_eth_tsu_write(mdp, 0xc, TSU_BSYSL0);
+	sh_eth_tsu_write(mdp, 0xc, TSU_BSYSL1);
+	sh_eth_tsu_write(mdp, 0, TSU_PRISL0);
+	sh_eth_tsu_write(mdp, 0, TSU_PRISL1);
+	sh_eth_tsu_write(mdp, 0, TSU_FWSL0);
+	sh_eth_tsu_write(mdp, 0, TSU_FWSL1);
+	sh_eth_tsu_write(mdp, TSU_FWSLC_POSTENU | TSU_FWSLC_POSTENL, TSU_FWSLC);
 #if defined(CONFIG_CPU_SUBTYPE_SH7763)
-	writel(0, ioaddr + TSU_QTAG0);	/* Disable QTAG(0->1) */
-	writel(0, ioaddr + TSU_QTAG1);	/* Disable QTAG(1->0) */
+	sh_eth_tsu_write(mdp, 0, TSU_QTAG0);	/* Disable QTAG(0->1) */
+	sh_eth_tsu_write(mdp, 0, TSU_QTAG1);	/* Disable QTAG(1->0) */
 #else
-	writel(0, ioaddr + TSU_QTAGM0);	/* Disable QTAG(0->1) */
-	writel(0, ioaddr + TSU_QTAGM1);	/* Disable QTAG(1->0) */
+	sh_eth_tsu_write(mdp, 0, TSU_QTAGM0);	/* Disable QTAG(0->1) */
+	sh_eth_tsu_write(mdp, 0, TSU_QTAGM1);	/* Disable QTAG(1->0) */
 #endif
-	writel(0, ioaddr + TSU_FWSR);	/* all interrupt status clear */
-	writel(0, ioaddr + TSU_FWINMK);	/* Disable all interrupt */
-	writel(0, ioaddr + TSU_TEN);	/* Disable all CAM entry */
-	writel(0, ioaddr + TSU_POST1);	/* Disable CAM entry [ 0- 7] */
-	writel(0, ioaddr + TSU_POST2);	/* Disable CAM entry [ 8-15] */
-	writel(0, ioaddr + TSU_POST3);	/* Disable CAM entry [16-23] */
-	writel(0, ioaddr + TSU_POST4);	/* Disable CAM entry [24-31] */
+	sh_eth_tsu_write(mdp, 0, TSU_FWSR);	/* all interrupt status clear */
+	sh_eth_tsu_write(mdp, 0, TSU_FWINMK);	/* Disable all interrupt */
+	sh_eth_tsu_write(mdp, 0, TSU_TEN);	/* Disable all CAM entry */
+	sh_eth_tsu_write(mdp, 0, TSU_POST1);	/* Disable CAM entry [ 0- 7] */
+	sh_eth_tsu_write(mdp, 0, TSU_POST2);	/* Disable CAM entry [ 8-15] */
+	sh_eth_tsu_write(mdp, 0, TSU_POST3);	/* Disable CAM entry [16-23] */
+	sh_eth_tsu_write(mdp, 0, TSU_POST4);	/* Disable CAM entry [24-31] */
 }
 #endif /* SH_ETH_HAS_TSU */

@@ -1536,7 +1512,7 @@ static int sh_mdio_init(struct net_device *ndev, int id)
 	}

 	/* bitbang init */
-	bitbang->addr = ndev->base_addr + PIR;
+	bitbang->addr = ndev->base_addr + mdp->reg_offset[PIR];
 	bitbang->mdi_msk = 0x08;
 	bitbang->mdo_msk = 0x04;
 	bitbang->mmd_msk = 0x02;/* MMD */
@@ -1587,6 +1563,28 @@ out:
 	return ret;
 }

+static const u16 *sh_eth_get_register_offset(int register_type)
+{
+	const u16 *reg_offset = NULL;
+
+	switch (register_type) {
+	case SH_ETH_REG_GIGABIT:
+		reg_offset = sh_eth_offset_gigabit;
+		break;
+	case SH_ETH_REG_FAST_SH4:
+		reg_offset = sh_eth_offset_fast_sh4;
+		break;
+	case SH_ETH_REG_FAST_SH3_SH2:
+		reg_offset = sh_eth_offset_fast_sh3_sh2;
+		break;
+	default:
+		printk(KERN_ERR "Unknown register type (%d)\n", register_type);
+		break;
+	}
+
+	return reg_offset;
+}
+
 static const struct net_device_ops sh_eth_netdev_ops = {
 	.ndo_open		= sh_eth_open,
 	.ndo_stop		= sh_eth_close,
@@ -1657,6 +1655,7 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	mdp->edmac_endian = pd->edmac_endian;
 	mdp->no_ether_link = pd->no_ether_link;
 	mdp->ether_link_active_low = pd->ether_link_active_low;
+	mdp->reg_offset = sh_eth_get_register_offset(pd->register_type);

 	/* set cpu data */
 	mdp->cd = &sh_eth_my_cpu_data;
@@ -1682,7 +1681,8 @@ static int sh_eth_drv_probe(struct platform_device *pdev)

 #if defined(SH_ETH_HAS_TSU)
 		/* TSU init (Init only)*/
-		sh_eth_tsu_init(SH_TSU_ADDR);
+		mdp->tsu_addr = SH_TSU_ADDR;
+		sh_eth_tsu_init(mdp);
 #endif
 	}

diff --git a/drivers/net/sh_eth.h b/drivers/net/sh_eth.h
index efa6422..1510a7c 100644
--- a/drivers/net/sh_eth.h
+++ b/drivers/net/sh_eth.h
@@ -2,7 +2,7 @@
  *  SuperH Ethernet device driver
  *
  *  Copyright (C) 2006-2008 Nobuhiro Iwamatsu
- *  Copyright (C) 2008-2009 Renesas Solutions Corp.
+ *  Copyright (C) 2008-2011 Renesas Solutions Corp.
  *
  *  This program is free software; you can redistribute it and/or modify it
  *  under the terms and conditions of the GNU General Public License,
@@ -38,162 +38,345 @@
 #define ETHERSMALL		60
 #define PKT_BUF_SZ		1538

+enum {
+	/* E-DMAC registers */
+	EDSR = 0,
+	EDMR,
+	EDTRR,
+	EDRRR,
+	EESR,
+	EESIPR,
+	TDLAR,
+	TDFAR,
+	TDFXR,
+	TDFFR,
+	RDLAR,
+	RDFAR,
+	RDFXR,
+	RDFFR,
+	TRSCER,
+	RMFCR,
+	TFTR,
+	FDR,
+	RMCR,
+	EDOCR,
+	TFUCR,
+	RFOCR,
+	FCFTR,
+	RPADIR,
+	TRIMD,
+	RBWAR,
+	TBRAR,
+
+	/* Ether registers */
+	ECMR,
+	ECSR,
+	ECSIPR,
+	PIR,
+	PSR,
+	RDMLR,
+	PIPR,
+	RFLR,
+	IPGR,
+	APR,
+	MPR,
+	PFTCR,
+	PFRCR,
+	RFCR,
+	RFCF,
+	TPAUSER,
+	TPAUSECR,
+	BCFR,
+	BCFRR,
+	GECMR,
+	BCULR,
+	MAHR,
+	MALR,
+	TROCR,
+	CDCR,
+	LCCR,
+	CNDCR,
+	CEFCR,
+	FRECR,
+	TSFRCR,
+	TLFRCR,
+	CERCR,
+	CEECR,
+	MAFCR,
+	RTRATE,
+
+	/* TSU Absolute address */
+	ARSTR,
+	TSU_CTRST,
+	TSU_FWEN0,
+	TSU_FWEN1,
+	TSU_FCM,
+	TSU_BSYSL0,
+	TSU_BSYSL1,
+	TSU_PRISL0,
+	TSU_PRISL1,
+	TSU_FWSL0,
+	TSU_FWSL1,
+	TSU_FWSLC,
+	TSU_QTAG0,
+	TSU_QTAG1,
+	TSU_QTAGM0,
+	TSU_QTAGM1,
+	TSU_FWSR,
+	TSU_FWINMK,
+	TSU_ADQT0,
+	TSU_ADQT1,
+	TSU_VTAG0,
+	TSU_VTAG1,
+	TSU_ADSBSY,
+	TSU_TEN,
+	TSU_POST1,
+	TSU_POST2,
+	TSU_POST3,
+	TSU_POST4,
+	TSU_ADRH0,
+	TSU_ADRL0,
+	TSU_ADRH31,
+	TSU_ADRL31,
+
+	TXNLCR0,
+	TXALCR0,
+	RXNLCR0,
+	RXALCR0,
+	FWNLCR0,
+	FWALCR0,
+	TXNLCR1,
+	TXALCR1,
+	RXNLCR1,
+	RXALCR1,
+	FWNLCR1,
+	FWALCR1,
+
+	/* This value must be written at last. */
+	SH_ETH_MAX_REGISTER_OFFSET,
+};
+
+static const u16 sh_eth_offset_gigabit[SH_ETH_MAX_REGISTER_OFFSET] = {
+	[EDSR]	= 0x0000,
+	[EDMR]	= 0x0400,
+	[EDTRR]	= 0x0408,
+	[EDRRR]	= 0x0410,
+	[EESR]	= 0x0428,
+	[EESIPR]	= 0x0430,
+	[TDLAR]	= 0x0010,
+	[TDFAR]	= 0x0014,
+	[TDFXR]	= 0x0018,
+	[TDFFR]	= 0x001c,
+	[RDLAR]	= 0x0030,
+	[RDFAR]	= 0x0034,
+	[RDFXR]	= 0x0038,
+	[RDFFR]	= 0x003c,
+	[TRSCER]	= 0x0438,
+	[RMFCR]	= 0x0440,
+	[TFTR]	= 0x0448,
+	[FDR]	= 0x0450,
+	[RMCR]	= 0x0458,
+	[RPADIR]	= 0x0460,
+	[FCFTR]	= 0x0468,
+
+	[ECMR]	= 0x0500,
+	[ECSR]	= 0x0510,
+	[ECSIPR]	= 0x0518,
+	[PIR]	= 0x0520,
+	[PSR]	= 0x0528,
+	[PIPR]	= 0x052c,
+	[RFLR]	= 0x0508,
+	[APR]	= 0x0554,
+	[MPR]	= 0x0558,
+	[PFTCR]	= 0x055c,
+	[PFRCR]	= 0x0560,
+	[TPAUSER]	= 0x0564,
+	[GECMR]	= 0x05b0,
+	[BCULR]	= 0x05b4,
+	[MAHR]	= 0x05c0,
+	[MALR]	= 0x05c8,
+	[TROCR]	= 0x0700,
+	[CDCR]	= 0x0708,
+	[LCCR]	= 0x0710,
+	[CEFCR]	= 0x0740,
+	[FRECR]	= 0x0748,
+	[TSFRCR]	= 0x0750,
+	[TLFRCR]	= 0x0758,
+	[RFCR]	= 0x0760,
+	[CERCR]	= 0x0768,
+	[CEECR]	= 0x0770,
+	[MAFCR]	= 0x0778,
+
+	[TSU_CTRST]	= 0x0004,
+	[TSU_FWEN0]	= 0x0010,
+	[TSU_FWEN1]	= 0x0014,
+	[TSU_FCM]	= 0x0018,
+	[TSU_BSYSL0]	= 0x0020,
+	[TSU_BSYSL1]	= 0x0024,
+	[TSU_PRISL0]	= 0x0028,
+	[TSU_PRISL1]	= 0x002c,
+	[TSU_FWSL0]	= 0x0030,
+	[TSU_FWSL1]	= 0x0034,
+	[TSU_FWSLC]	= 0x0038,
+	[TSU_QTAG0]	= 0x0040,
+	[TSU_QTAG1]	= 0x0044,
+	[TSU_FWSR]	= 0x0050,
+	[TSU_FWINMK]	= 0x0054,
+	[TSU_ADQT0]	= 0x0048,
+	[TSU_ADQT1]	= 0x004c,
+	[TSU_VTAG0]	= 0x0058,
+	[TSU_VTAG1]	= 0x005c,
+	[TSU_ADSBSY]	= 0x0060,
+	[TSU_TEN]	= 0x0064,
+	[TSU_POST1]	= 0x0070,
+	[TSU_POST2]	= 0x0074,
+	[TSU_POST3]	= 0x0078,
+	[TSU_POST4]	= 0x007c,
+	[TSU_ADRH0]	= 0x0100,
+	[TSU_ADRL0]	= 0x0104,
+	[TSU_ADRH31]	= 0x01f8,
+	[TSU_ADRL31]	= 0x01fc,
+
+	[TXNLCR0]	= 0x0080,
+	[TXALCR0]	= 0x0084,
+	[RXNLCR0]	= 0x0088,
+	[RXALCR0]	= 0x008c,
+	[FWNLCR0]	= 0x0090,
+	[FWALCR0]	= 0x0094,
+	[TXNLCR1]	= 0x00a0,
+	[TXALCR1]	= 0x00a0,
+	[RXNLCR1]	= 0x00a8,
+	[RXALCR1]	= 0x00ac,
+	[FWNLCR1]	= 0x00b0,
+	[FWALCR1]	= 0x00b4,
+};
+
+static const u16 sh_eth_offset_fast_sh4[SH_ETH_MAX_REGISTER_OFFSET] = {
+	[ECMR]	= 0x0100,
+	[RFLR]	= 0x0108,
+	[ECSR]	= 0x0110,
+	[ECSIPR]	= 0x0118,
+	[PIR]	= 0x0120,
+	[PSR]	= 0x0128,
+	[RDMLR]	= 0x0140,
+	[IPGR]	= 0x0150,
+	[APR]	= 0x0154,
+	[MPR]	= 0x0158,
+	[TPAUSER]	= 0x0164,
+	[RFCF]	= 0x0160,
+	[TPAUSECR]	= 0x0168,
+	[BCFRR]	= 0x016c,
+	[MAHR]	= 0x01c0,
+	[MALR]	= 0x01c8,
+	[TROCR]	= 0x01d0,
+	[CDCR]	= 0x01d4,
+	[LCCR]	= 0x01d8,
+	[CNDCR]	= 0x01dc,
+	[CEFCR]	= 0x01e4,
+	[FRECR]	= 0x01e8,
+	[TSFRCR]	= 0x01ec,
+	[TLFRCR]	= 0x01f0,
+	[RFCR]	= 0x01f4,
+	[MAFCR]	= 0x01f8,
+	[RTRATE]	= 0x01fc,
+
+	[EDMR]	= 0x0000,
+	[EDTRR]	= 0x0008,
+	[EDRRR]	= 0x0010,
+	[TDLAR]	= 0x0018,
+	[RDLAR]	= 0x0020,
+	[EESR]	= 0x0028,
+	[EESIPR]	= 0x0030,
+	[TRSCER]	= 0x0038,
+	[RMFCR]	= 0x0040,
+	[TFTR]	= 0x0048,
+	[FDR]	= 0x0050,
+	[RMCR]	= 0x0058,
+	[TFUCR]	= 0x0064,
+	[RFOCR]	= 0x0068,
+	[FCFTR]	= 0x0070,
+	[RPADIR]	= 0x0078,
+	[TRIMD]	= 0x007c,
+	[RBWAR]	= 0x00c8,
+	[RDFAR]	= 0x00cc,
+	[TBRAR]	= 0x00d4,
+	[TDFAR]	= 0x00d8,
+};
+
+static const u16 sh_eth_offset_fast_sh3_sh2[SH_ETH_MAX_REGISTER_OFFSET] = {
+	[ECMR]	= 0x0160,
+	[ECSR]	= 0x0164,
+	[ECSIPR]	= 0x0168,
+	[PIR]	= 0x016c,
+	[MAHR]	= 0x0170,
+	[MALR]	= 0x0174,
+	[RFLR]	= 0x0178,
+	[PSR]	= 0x017c,
+	[TROCR]	= 0x0180,
+	[CDCR]	= 0x0184,
+	[LCCR]	= 0x0188,
+	[CNDCR]	= 0x018c,
+	[CEFCR]	= 0x0194,
+	[FRECR]	= 0x0198,
+	[TSFRCR]	= 0x019c,
+	[TLFRCR]	= 0x01a0,
+	[RFCR]	= 0x01a4,
+	[MAFCR]	= 0x01a8,
+	[IPGR]	= 0x01b4,
+	[APR]	= 0x01b8,
+	[MPR]	= 0x01bc,
+	[TPAUSER]	= 0x01c4,
+	[BCFR]	= 0x01cc,
+
+	[TSU_CTRST]	= 0x0004,
+	[TSU_FWEN0]	= 0x0010,
+	[TSU_FWEN1]	= 0x0014,
+	[TSU_FCM]	= 0x0018,
+	[TSU_BSYSL0]	= 0x0020,
+	[TSU_BSYSL1]	= 0x0024,
+	[TSU_PRISL0]	= 0x0028,
+	[TSU_PRISL1]	= 0x002c,
+	[TSU_FWSL0]	= 0x0030,
+	[TSU_FWSL1]	= 0x0034,
+	[TSU_FWSLC]	= 0x0038,
+	[TSU_QTAGM0]	= 0x0040,
+	[TSU_QTAGM1]	= 0x0044,
+	[TSU_ADQT0]	= 0x0048,
+	[TSU_ADQT1]	= 0x004c,
+	[TSU_FWSR]	= 0x0050,
+	[TSU_FWINMK]	= 0x0054,
+	[TSU_ADSBSY]	= 0x0060,
+	[TSU_TEN]	= 0x0064,
+	[TSU_POST1]	= 0x0070,
+	[TSU_POST2]	= 0x0074,
+	[TSU_POST3]	= 0x0078,
+	[TSU_POST4]	= 0x007c,
+
+	[TXNLCR0]	= 0x0080,
+	[TXALCR0]	= 0x0084,
+	[RXNLCR0]	= 0x0088,
+	[RXALCR0]	= 0x008c,
+	[FWNLCR0]	= 0x0090,
+	[FWALCR0]	= 0x0094,
+	[TXNLCR1]	= 0x00a0,
+	[TXALCR1]	= 0x00a0,
+	[RXNLCR1]	= 0x00a8,
+	[RXALCR1]	= 0x00ac,
+	[FWNLCR1]	= 0x00b0,
+	[FWALCR1]	= 0x00b4,
+
+	[TSU_ADRH0]	= 0x0100,
+	[TSU_ADRL0]	= 0x0104,
+	[TSU_ADRL31]	= 0x01fc,
+
+};
+
 #if defined(CONFIG_CPU_SUBTYPE_SH7763)
 /* This CPU register maps is very difference by other SH4 CPU */
-
 /* Chip Base Address */
 # define SH_TSU_ADDR	0xFEE01800
 # define ARSTR		SH_TSU_ADDR
-
-/* Chip Registers */
-/* E-DMAC */
-# define EDSR    0x000
-# define EDMR    0x400
-# define EDTRR   0x408
-# define EDRRR   0x410
-# define EESR    0x428
-# define EESIPR  0x430
-# define TDLAR   0x010
-# define TDFAR   0x014
-# define TDFXR   0x018
-# define TDFFR   0x01C
-# define RDLAR   0x030
-# define RDFAR   0x034
-# define RDFXR   0x038
-# define RDFFR   0x03C
-# define TRSCER  0x438
-# define RMFCR   0x440
-# define TFTR    0x448
-# define FDR     0x450
-# define RMCR    0x458
-# define RPADIR  0x460
-# define FCFTR   0x468
-
-/* Ether Register */
-# define ECMR    0x500
-# define ECSR    0x510
-# define ECSIPR  0x518
-# define PIR     0x520
-# define PSR     0x528
-# define PIPR    0x52C
-# define RFLR    0x508
-# define APR     0x554
-# define MPR     0x558
-# define PFTCR	 0x55C
-# define PFRCR	 0x560
-# define TPAUSER 0x564
-# define GECMR   0x5B0
-# define BCULR   0x5B4
-# define MAHR    0x5C0
-# define MALR    0x5C8
-# define TROCR   0x700
-# define CDCR    0x708
-# define LCCR    0x710
-# define CEFCR   0x740
-# define FRECR   0x748
-# define TSFRCR  0x750
-# define TLFRCR  0x758
-# define RFCR    0x760
-# define CERCR   0x768
-# define CEECR   0x770
-# define MAFCR   0x778
-
-/* TSU Absolute Address */
-# define TSU_CTRST       0x004
-# define TSU_FWEN0       0x010
-# define TSU_FWEN1       0x014
-# define TSU_FCM         0x18
-# define TSU_BSYSL0      0x20
-# define TSU_BSYSL1      0x24
-# define TSU_PRISL0      0x28
-# define TSU_PRISL1      0x2C
-# define TSU_FWSL0       0x30
-# define TSU_FWSL1       0x34
-# define TSU_FWSLC       0x38
-# define TSU_QTAG0       0x40
-# define TSU_QTAG1       0x44
-# define TSU_FWSR        0x50
-# define TSU_FWINMK      0x54
-# define TSU_ADQT0       0x48
-# define TSU_ADQT1       0x4C
-# define TSU_VTAG0       0x58
-# define TSU_VTAG1       0x5C
-# define TSU_ADSBSY      0x60
-# define TSU_TEN         0x64
-# define TSU_POST1       0x70
-# define TSU_POST2       0x74
-# define TSU_POST3       0x78
-# define TSU_POST4       0x7C
-# define TSU_ADRH0       0x100
-# define TSU_ADRL0       0x104
-# define TSU_ADRH31      0x1F8
-# define TSU_ADRL31      0x1FC
-
-# define TXNLCR0         0x80
-# define TXALCR0         0x84
-# define RXNLCR0         0x88
-# define RXALCR0         0x8C
-# define FWNLCR0         0x90
-# define FWALCR0         0x94
-# define TXNLCR1         0xA0
-# define TXALCR1         0xA4
-# define RXNLCR1         0xA8
-# define RXALCR1         0xAC
-# define FWNLCR1         0xB0
-# define FWALCR1         0x40
-
 #elif defined(CONFIG_CPU_SH4)	/* #if defined(CONFIG_CPU_SUBTYPE_SH7763) */
-/* EtherC */
-#define ECMR		0x100
-#define RFLR		0x108
-#define ECSR		0x110
-#define ECSIPR		0x118
-#define PIR		0x120
-#define PSR		0x128
-#define RDMLR		0x140
-#define IPGR		0x150
-#define APR		0x154
-#define MPR		0x158
-#define TPAUSER		0x164
-#define RFCF		0x160
-#define TPAUSECR	0x168
-#define BCFRR		0x16c
-#define MAHR		0x1c0
-#define MALR		0x1c8
-#define TROCR		0x1d0
-#define CDCR		0x1d4
-#define LCCR		0x1d8
-#define CNDCR		0x1dc
-#define CEFCR		0x1e4
-#define FRECR		0x1e8
-#define TSFRCR		0x1ec
-#define TLFRCR		0x1f0
-#define RFCR		0x1f4
-#define MAFCR		0x1f8
-#define RTRATE		0x1fc
-
-/* E-DMAC */
-#define EDMR		0x000
-#define EDTRR		0x008
-#define EDRRR		0x010
-#define TDLAR		0x018
-#define RDLAR		0x020
-#define EESR		0x028
-#define EESIPR		0x030
-#define TRSCER		0x038
-#define RMFCR		0x040
-#define TFTR		0x048
-#define FDR		0x050
-#define RMCR		0x058
-#define TFUCR		0x064
-#define RFOCR		0x068
-#define FCFTR		0x070
-#define RPADIR		0x078
-#define TRIMD		0x07c
-#define RBWAR		0x0c8
-#define RDFAR		0x0cc
-#define TBRAR		0x0d4
-#define TDFAR		0x0d8
 #else /* #elif defined(CONFIG_CPU_SH4) */
 /* This section is SH3 or SH2 */
 #ifndef CONFIG_CPU_SUBTYPE_SH7619
@@ -201,116 +384,8 @@
 # define SH_TSU_ADDR  0xA7000804
 # define ARSTR		  0xA7000800
 #endif
-/* Chip Registers */
-/* E-DMAC */
-# define EDMR	0x0000
-# define EDTRR	0x0004
-# define EDRRR	0x0008
-# define TDLAR	0x000C
-# define RDLAR	0x0010
-# define EESR	0x0014
-# define EESIPR	0x0018
-# define TRSCER	0x001C
-# define RMFCR	0x0020
-# define TFTR	0x0024
-# define FDR	0x0028
-# define RMCR	0x002C
-# define EDOCR	0x0030
-# define FCFTR	0x0034
-# define RPADIR	0x0038
-# define TRIMD	0x003C
-# define RBWAR	0x0040
-# define RDFAR	0x0044
-# define TBRAR	0x004C
-# define TDFAR	0x0050
-
-/* Ether Register */
-# define ECMR	0x0160
-# define ECSR	0x0164
-# define ECSIPR	0x0168
-# define PIR	0x016C
-# define MAHR	0x0170
-# define MALR	0x0174
-# define RFLR	0x0178
-# define PSR	0x017C
-# define TROCR	0x0180
-# define CDCR	0x0184
-# define LCCR	0x0188
-# define CNDCR	0x018C
-# define CEFCR	0x0194
-# define FRECR	0x0198
-# define TSFRCR	0x019C
-# define TLFRCR	0x01A0
-# define RFCR	0x01A4
-# define MAFCR	0x01A8
-# define IPGR	0x01B4
-# if defined(CONFIG_CPU_SUBTYPE_SH7710)
-# define APR	0x01B8
-# define MPR 	0x01BC
-# define TPAUSER 0x1C4
-# define BCFR	0x1CC
-# endif /* CONFIG_CPU_SH7710 */
-
-/* TSU */
-# define TSU_CTRST	0x004
-# define TSU_FWEN0	0x010
-# define TSU_FWEN1	0x014
-# define TSU_FCM	0x018
-# define TSU_BSYSL0	0x020
-# define TSU_BSYSL1	0x024
-# define TSU_PRISL0	0x028
-# define TSU_PRISL1	0x02C
-# define TSU_FWSL0	0x030
-# define TSU_FWSL1	0x034
-# define TSU_FWSLC	0x038
-# define TSU_QTAGM0	0x040
-# define TSU_QTAGM1	0x044
-# define TSU_ADQT0 	0x048
-# define TSU_ADQT1	0x04C
-# define TSU_FWSR	0x050
-# define TSU_FWINMK	0x054
-# define TSU_ADSBSY	0x060
-# define TSU_TEN	0x064
-# define TSU_POST1	0x070
-# define TSU_POST2	0x074
-# define TSU_POST3	0x078
-# define TSU_POST4	0x07C
-# define TXNLCR0	0x080
-# define TXALCR0	0x084
-# define RXNLCR0	0x088
-# define RXALCR0	0x08C
-# define FWNLCR0	0x090
-# define FWALCR0	0x094
-# define TXNLCR1	0x0A0
-# define TXALCR1	0x0A4
-# define RXNLCR1	0x0A8
-# define RXALCR1	0x0AC
-# define FWNLCR1	0x0B0
-# define FWALCR1	0x0B4
-
-#define TSU_ADRH0	0x0100
-#define TSU_ADRL0	0x0104
-#define TSU_ADRL31	0x01FC
-
 #endif /* CONFIG_CPU_SUBTYPE_SH7763 */

-/* There are avoid compile error... */
-#if !defined(BCULR)
-#define BCULR	0x0fc
-#endif
-#if !defined(TRIMD)
-#define TRIMD	0x0fc
-#endif
-#if !defined(APR)
-#define APR	0x0fc
-#endif
-#if !defined(MPR)
-#define MPR	0x0fc
-#endif
-#if !defined(TPAUSER)
-#define TPAUSER	0x0fc
-#endif
-
 /* Driver's parameters */
 #if defined(CONFIG_CPU_SH4)
 #define SH4_SKB_RX_ALIGN	32
@@ -704,6 +779,8 @@ struct sh_eth_cpu_data {
 struct sh_eth_private {
 	struct platform_device *pdev;
 	struct sh_eth_cpu_data *cd;
+	const u16 *reg_offset;
+	void __iomem *tsu_addr;
 	dma_addr_t rx_desc_dma;
 	dma_addr_t tx_desc_dma;
 	struct sh_eth_rxdesc *rx_ring;
@@ -746,4 +823,32 @@ static inline void sh_eth_soft_swap(char *src, int len)
 #endif
 }

+static inline void sh_eth_write(struct net_device *ndev, unsigned long data,
+				int enum_index)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+
+	writel(data, ndev->base_addr + mdp->reg_offset[enum_index]);
+}
+
+static inline unsigned long sh_eth_read(struct net_device *ndev,
+					int enum_index)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+
+	return readl(ndev->base_addr + mdp->reg_offset[enum_index]);
+}
+
+static inline void sh_eth_tsu_write(struct sh_eth_private *mdp,
+				unsigned long data, int enum_index)
+{
+	writel(data, mdp->tsu_addr + mdp->reg_offset[enum_index]);
+}
+
+static inline unsigned long sh_eth_tsu_read(struct sh_eth_private *mdp,
+					int enum_index)
+{
+	return readl(mdp->tsu_addr + mdp->reg_offset[enum_index]);
+}
+
 #endif	/* #ifndef __SH_ETH_H__ */
-- 
1.7.1

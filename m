From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH net-next 1/3] net: stmmac: add gmac autoneg set for SGMII,
 TBI, and RTBI
Date: Fri, 22 Feb 2013 14:17:56 +0100
Message-ID: <51277004.20702@st.com>
References: <00c001cdf369$9b25bdf0$d17139d0$@samsung.com> <50F6568D.3060703@st.com> <01e201cdf5a3$1f3e1890$5dba49b0$@samsung.com> <50FFB094.5000100@st.com> <013e01cdfb47$8f5d2b30$ae178190$@samsung.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090907080700060704020909"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	kgene.kim@samsung.com, cpgs@samsung.com
To: Byungho An <bh74.an@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:38745 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756890Ab3BVNTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 08:19:03 -0500
In-Reply-To: <013e01cdfb47$8f5d2b30$ae178190$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090907080700060704020909
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hello Byungho

sorry for my late reply. I'm attaching two patches built for net-next
as we had clarified. I had written the first patch long time ago
and on top of it I have added some part of your code below with some
fixes (see also the comments inline below).

This work is not yet completed but I do hope these two patches will
help you to complete all. Unfortunately, I cannot do any tests
because I have no HW that supports PCS. :-(

In the second patch, take a look at the comment that reports
the missing parts. For example, ethtool, SGMII etc.

I wonder if you could review/test the two patches on your side.
Also I hope you can improve all adding the missing features (that is
what you were already doing).

If you agree, you could also re-send *all* to the mailing list to
be finally reviewed.

On 1/25/2013 11:01 PM, Byungho An wrote:
>
> On 1/23/2013 1:43 PM, Giuseppe CAVALLARO write:

[snip]

>>
> I modified this part like below
>
> @@ -1044,12 +1046,8 @@ static int stmmac_open(struct net_device *dev)
>          priv->hw->mac->core_init(priv->ioaddr);
>
>          /* Enable auto-negotiation for SGMII, TBI or RTBI */
> -       if (interface == PHY_INTERFACE_MODE_SGMII ||
> -           interface == PHY_INTERFACE_MODE_TBI ||
> -           interface == PHY_INTERFACE_MODE_RTBI) {
> -               if (priv->phydev->autoneg)
> -                       priv->hw->mac->set_autoneg(priv->ioaddr);
> -       }
> +       if (priv->dma_cap.pcs)
> +               priv->hw->mac->ctrl_ane(priv->ioaddr, 0);
>
>          /* Request the IRQ lines */
>          ret = request_irq(dev->irq, stmmac_interrupt,
>
> As you may know, auto-negotiation is essential for SGMII, TBI, or RTBI
> interface.
>

good, add it on top of the second patch.

> And ctrl_ane funciont is like that
>
> @@ -311,6 +317,18 @@ static void dwmac1000_set_autoneg(void __iomem *ioaddr)
>          writel(value, ioaddr + GMAC_AN_CTRL);
>   }
>
> +static void dwmac1000_ctrl_ane(void __iomem *ioaddr, bool restart)
> +{
> +       u32 value;
> +
> +       value = readl(ioaddr + GMAC_AN_CTRL);
> +     /* auto negotiation enable and External Loopback enable */
> +       value = GMAC_AN_CTRL__ANE | GMAC_AN_CTRL__ELE;
> +
> +       if (restart)
> +               value |= GMAC_AN_CTRL_RAN;
> +
> +       writel(value, ioaddr + GMAC_AN_CTRL);
> +}
>
>   static const struct stmmac_ops dwmac1000_ops = {
>          .core_init = dwmac1000_core_init,

well done and added in the second patch.

[snip]
> I've  changed restart AN like below.
>
> @@ -610,6 +607,27 @@ static int stmmac_set_coalesce(struct net_device *dev,
>          return 0;
>   }
>
> +static int
> +stmmac_nway_reset(struct net_device *netdev)
> +{
> +       struct stmmac_priv *priv = netdev_priv(netdev);
> +       struct phy_device *phy = priv->phydev;
> +       int ret = 0;
> +
> +       spin_lock(&priv->lock);
> +
> +       if (netif_running(netdev)) {
> +               phy_stop(phy);
> +               phy_start(phy);
> +               ret = phy_start_aneg(phy);
> +               if (priv->dma_cap.pcs)
> +                       priv->hw->mac->ctrl_ane(priv->ioaddr, true);
> +       }
> +
> +       spin_unlock(&priv->lock);
> +       return ret;
> +}
> +
>   static const struct ethtool_ops stmmac_ethtool_ops = {
>          .begin = stmmac_check_if_running,
>          .get_drvinfo = stmmac_ethtool_getdrvinfo,
>
>

we have to review this. I expect to have a new patch that includes the
ethtool support but, at first glance, the stmmac_nway_reset should only
call the ctrl_ane.

pay attention that also some other ethtool functions have to be fixed
for this support.

[snip]

> I think whenever link is changed, phy->state is changed and call
> stmmac_adjust_link. It would update gmac's link.
> I can get autonegotiation complete and link change irqs if we need something
> we can add code in the handler but I'm not sure which one is need yet.
> As of now I just added phy_state = PHY_CHANGELINK as a test code in the link
> change irq handler.
>
> @@ -1624,8 +1629,43 @@ static irqreturn_t stmmac_interrupt(int irq, void
> *dev_id)
>                                  priv->xstats.mmc_rx_csum_offload_irq_n++;
>                          if (status & core_irq_receive_pmt_irq)
>                                  priv->xstats.irq_receive_pmt_irq_n++;
> +                       if (status & core_irq_pcs_autoneg_complete)
> +                                priv->core_pcs_an = true;
> +                       if (status & core_irq_pcs_link_status_change) {
> +                               priv->core_pcs_link_change = true;
> +                               status = readl(priv->ioaddr +
> GMAC_AN_STATUS);
> +                               if (status & GMAC_AN_STATUS_LS)
> +                                       if ((priv->speed != phy->speed) ||
> (priv->oldduplex != phy->duplex))
> +                                       phy->state = PHY_CHANGELINK;  /* for
> test */
> +                       }
>
>                          /* For LPI we need to save the tx status */
>                          if (status & core_irq_tx_path_in_lpi_mode) {
>
> I have a question, how to hand over phy's irq number, as I analyzed
> phydev->irq is irqlist and irqlist is like below but I can not find a way to
> set phy's irq number.
> How to register or set priv->mii_irq or mdio_bus_data->irqs.
>
>          if (mdio_bus_data->irqs)
>                  irqlist = mdio_bus_data->irqs;
>          else
>                  irqlist = priv->mii_irq;

I had added something in my first patch that should be ok.

> I added some defines for AN like below
> @@ -97,6 +97,20 @@ enum power_event {
>   #define GMAC_TBI       0x000000d4      /* TBI extend status */
>   #define GMAC_GMII_STATUS 0x000000d8    /* S/R-GMII status */
>
> +/* AN Configuration defines */
> +#define GMAC_AN_CTRL_RAN       0x00000200      /* Restart Auto-Negotiation
> */
> +#define GMAC_AN_CTRL_ANE       0x00001000      /* Auto-Negotiation Enable
> */
> +#define GMAC_AN_CTRL_ELE       0x00004000      /* External Loopback Enable
> */
> +#define GMAC_AN_CTRL_ECD       0x00010000      /* Enable Comma Detect */
> +#define GMAC_AN_CTRL_LR        0x00020000      /* Lock to Reference */
> +#define GMAC_AN_CTRL_SGMRAL    0x00040000      /* SGMII RAL Control */
> +
> +/* AN Status defines */
> +#define GMAC_AN_STATUS_LS      0x00000004      /* Link Status 0:down 1:up
> */
> +#define GMAC_AN_STATUS_ANA     0x00000008      /* Auto-Negotiation Ability
> */
> +#define GMAC_AN_STATUS_ANC     0x00000020      /* Auto-Negotiation Complete
> */
> +#define GMAC_AN_STATUS_ES      0x00000100      /* Extended Status */
> +
>   /* GMAC Configuration defines */
>   #define GMAC_CONTROL_TC        0x01000000      /* Transmit Conf. in
> RGMII/SGMII */
>   #define GMAC_CONTROL_WD        0x00800000      /* Disable Watchdog on
> receive */

ok, these are in the second patch

--------------090907080700060704020909
Content-Type: text/x-patch;
 name="0001-stmmac-start-adding-pcs-and-rgmii-core-irq.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-stmmac-start-adding-pcs-and-rgmii-core-irq.patch"

>From 13a4be74f7a4a7d180cae25f4528dc0a78bf5d7c Mon Sep 17 00:00:00 2001
From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Mon, 17 Dec 2012 07:22:18 +0100
Subject: [net-next.git 1/2] stmmac: start adding pcs and rgmii core irq

This patch starts adding in the main ISR the management of the PCS and
RGMII/SGMII core interrupts. This is to help further development
on this area. Currently the core irq handler only clears the
PCS and S-R_MII interrupts and reports the event in the ethtool stats.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Udit Kumar <udit-dlh.kumar@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |   25 ++++++-----
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |    5 +-
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |   44 ++++++++++++-------
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |    3 +-
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |    3 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   24 ++---------
 6 files changed, 54 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 186d148..1db761c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -117,6 +117,10 @@ struct stmmac_extra_stats {
 	unsigned long irq_rx_path_in_lpi_mode_n;
 	unsigned long irq_rx_path_exit_lpi_mode_n;
 	unsigned long phy_eee_wakeup_error_n;
+	/* PCS */
+	unsigned long irq_pcs_ane_n;
+	unsigned long irq_pcs_link_n;
+	unsigned long irq_rgmii_n;
 };
 
 /* CSR Frequency Access Defines*/
@@ -194,16 +198,14 @@ enum dma_irq_status {
 	handle_tx = 0x8,
 };
 
-enum core_specific_irq_mask {
-	core_mmc_tx_irq = 1,
-	core_mmc_rx_irq = 2,
-	core_mmc_rx_csum_offload_irq = 4,
-	core_irq_receive_pmt_irq = 8,
-	core_irq_tx_path_in_lpi_mode = 16,
-	core_irq_tx_path_exit_lpi_mode = 32,
-	core_irq_rx_path_in_lpi_mode = 64,
-	core_irq_rx_path_exit_lpi_mode = 128,
-};
+#define	CORE_IRQ_TX_PATH_IN_LPI_MODE	(1 << 1)
+#define	CORE_IRQ_TX_PATH_EXIT_LPI_MODE	(1 << 2)
+#define	CORE_IRQ_RX_PATH_IN_LPI_MODE	(1 << 3)
+#define	CORE_IRQ_RX_PATH_EXIT_LPI_MODE	(1 << 4)
+
+#define	CORE_PCS_ANE_COMPLETE		(1 << 5)
+#define	CORE_PCS_LINK_STATUS		(1 << 6)
+#define	CORE_RGMII_IRQ			(1 << 7)
 
 /* DMA HW capabilities */
 struct dma_features {
@@ -327,7 +329,8 @@ struct stmmac_ops {
 	/* Dump MAC registers */
 	void (*dump_regs) (void __iomem *ioaddr);
 	/* Handle extra events on specific interrupts hw dependent */
-	int (*host_irq_status) (void __iomem *ioaddr);
+	int (*host_irq_status) (void __iomem *ioaddr,
+				struct stmmac_extra_stats *x);
 	/* Multicast filter setting */
 	void (*set_filter) (struct net_device *dev, int id);
 	/* Flow control setting */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
index 7ad56af..8a8c39f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
@@ -89,13 +89,14 @@ enum power_event {
 				(reg * 8))
 #define GMAC_MAX_PERFECT_ADDRESSES	32
 
+/* PCS registers (AN/TBI/SGMII/RGMII) offset */
 #define GMAC_AN_CTRL	0x000000c0	/* AN control */
 #define GMAC_AN_STATUS	0x000000c4	/* AN status */
 #define GMAC_ANE_ADV	0x000000c8	/* Auto-Neg. Advertisement */
-#define GMAC_ANE_LINK	0x000000cc	/* Auto-Neg. link partener ability */
+#define GMAC_ANE_LPA	0x000000cc	/* Auto-Neg. link partener ability */
 #define GMAC_ANE_EXP	0x000000d0	/* ANE expansion */
 #define GMAC_TBI	0x000000d4	/* TBI extend status */
-#define GMAC_GMII_STATUS 0x000000d8	/* S/R-GMII status */
+#define GMAC_S_R_GMII	0x000000d8	/* SGMII RGMII status */
 
 /* GMAC Configuration defines */
 #define GMAC_CONTROL_TC	0x01000000	/* Transmit Conf. in RGMII/SGMII */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index bfe0226..ff4c79e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -194,58 +194,70 @@ static void dwmac1000_pmt(void __iomem *ioaddr, unsigned long mode)
 }
 
 
-static int dwmac1000_irq_status(void __iomem *ioaddr)
+static int dwmac1000_irq_status(void __iomem *ioaddr,
+				struct stmmac_extra_stats *x)
 {
 	u32 intr_status = readl(ioaddr + GMAC_INT_STATUS);
-	int status = 0;
+	int ret = 0;
 
 	/* Not used events (e.g. MMC interrupts) are not handled. */
 	if ((intr_status & mmc_tx_irq)) {
 		CHIP_DBG(KERN_INFO "GMAC: MMC tx interrupt: 0x%08x\n",
 		    readl(ioaddr + GMAC_MMC_TX_INTR));
-		status |= core_mmc_tx_irq;
+		x->mmc_tx_irq_n++;
 	}
 	if (unlikely(intr_status & mmc_rx_irq)) {
 		CHIP_DBG(KERN_INFO "GMAC: MMC rx interrupt: 0x%08x\n",
 		    readl(ioaddr + GMAC_MMC_RX_INTR));
-		status |= core_mmc_rx_irq;
+		x->mmc_rx_irq_n++;
 	}
 	if (unlikely(intr_status & mmc_rx_csum_offload_irq)) {
 		CHIP_DBG(KERN_INFO "GMAC: MMC rx csum offload: 0x%08x\n",
 		    readl(ioaddr + GMAC_MMC_RX_CSUM_OFFLOAD));
-		status |= core_mmc_rx_csum_offload_irq;
+		x->mmc_rx_csum_offload_irq_n++;
 	}
 	if (unlikely(intr_status & pmt_irq)) {
 		CHIP_DBG(KERN_INFO "GMAC: received Magic frame\n");
 		/* clear the PMT bits 5 and 6 by reading the PMT
 		 * status register. */
 		readl(ioaddr + GMAC_PMT);
-		status |= core_irq_receive_pmt_irq;
+		x->irq_receive_pmt_irq_n++;
 	}
 	/* MAC trx/rx EEE LPI entry/exit interrupts */
 	if (intr_status & lpiis_irq) {
 		/* Clean LPI interrupt by reading the Reg 12 */
-		u32 lpi_status = readl(ioaddr + LPI_CTRL_STATUS);
+		ret = readl(ioaddr + LPI_CTRL_STATUS);
 
-		if (lpi_status & LPI_CTRL_STATUS_TLPIEN) {
+		if (ret & LPI_CTRL_STATUS_TLPIEN) {
 			CHIP_DBG(KERN_INFO "GMAC TX entered in LPI\n");
-			status |= core_irq_tx_path_in_lpi_mode;
+			x->irq_tx_path_in_lpi_mode_n++;
 		}
-		if (lpi_status & LPI_CTRL_STATUS_TLPIEX) {
+		if (ret & LPI_CTRL_STATUS_TLPIEX) {
 			CHIP_DBG(KERN_INFO "GMAC TX exit from LPI\n");
-			status |= core_irq_tx_path_exit_lpi_mode;
+			x->irq_tx_path_exit_lpi_mode_n++;
 		}
-		if (lpi_status & LPI_CTRL_STATUS_RLPIEN) {
+		if (ret & LPI_CTRL_STATUS_RLPIEN) {
 			CHIP_DBG(KERN_INFO "GMAC RX entered in LPI\n");
-			status |= core_irq_rx_path_in_lpi_mode;
+			x->irq_rx_path_in_lpi_mode_n++;
 		}
-		if (lpi_status & LPI_CTRL_STATUS_RLPIEX) {
+		if (ret & LPI_CTRL_STATUS_RLPIEX) {
 			CHIP_DBG(KERN_INFO "GMAC RX exit from LPI\n");
-			status |= core_irq_rx_path_exit_lpi_mode;
+			x->irq_rx_path_exit_lpi_mode_n++;
 		}
 	}
 
-	return status;
+	if ((intr_status & pcs_ane_irq) || (intr_status & pcs_link_irq)) {
+		CHIP_DBG(KERN_INFO "GMAC PCS ANE IRQ\n");
+		readl(ioaddr + GMAC_AN_STATUS);
+		x->irq_pcs_ane_n++;
+	}
+	if (intr_status & rgmii_irq) {
+		CHIP_DBG(KERN_INFO "GMAC RGMII IRQ status\n");
+		readl(ioaddr + GMAC_S_R_GMII);
+		x->irq_rgmii_n++;
+	}
+
+	return ret;
 }
 
 static void  dwmac1000_set_eee_mode(void __iomem *ioaddr)
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
index f83210e..cb86a58 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
@@ -72,7 +72,8 @@ static int dwmac100_rx_ipc_enable(void __iomem *ioaddr)
 	return 0;
 }
 
-static int dwmac100_irq_status(void __iomem *ioaddr)
+static int dwmac100_irq_status(void __iomem *ioaddr,
+			       struct stmmac_extra_stats *x)
 {
 	return 0;
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index d1ac39c..e15004f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -108,6 +108,9 @@ static const struct stmmac_stats stmmac_gstrings_stats[] = {
 	STMMAC_STAT(irq_rx_path_in_lpi_mode_n),
 	STMMAC_STAT(irq_rx_path_exit_lpi_mode_n),
 	STMMAC_STAT(phy_eee_wakeup_error_n),
+	/* PCS */
+	STMMAC_STAT(irq_pcs_ane_n),
+	STMMAC_STAT(irq_rgmii_n),
 };
 #define STMMAC_STATS_LEN ARRAY_SIZE(stmmac_gstrings_stats)
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 39c6c55..1f2f349 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1604,30 +1604,14 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
 	/* To handle GMAC own interrupts */
 	if (priv->plat->has_gmac) {
 		int status = priv->hw->mac->host_irq_status((void __iomem *)
-							    dev->base_addr);
+							    dev->base_addr,
+							    &priv->xstats);
 		if (unlikely(status)) {
-			if (status & core_mmc_tx_irq)
-				priv->xstats.mmc_tx_irq_n++;
-			if (status & core_mmc_rx_irq)
-				priv->xstats.mmc_rx_irq_n++;
-			if (status & core_mmc_rx_csum_offload_irq)
-				priv->xstats.mmc_rx_csum_offload_irq_n++;
-			if (status & core_irq_receive_pmt_irq)
-				priv->xstats.irq_receive_pmt_irq_n++;
-
 			/* For LPI we need to save the tx status */
-			if (status & core_irq_tx_path_in_lpi_mode) {
-				priv->xstats.irq_tx_path_in_lpi_mode_n++;
+			if (status & CORE_IRQ_TX_PATH_IN_LPI_MODE)
 				priv->tx_path_in_lpi_mode = true;
-			}
-			if (status & core_irq_tx_path_exit_lpi_mode) {
-				priv->xstats.irq_tx_path_exit_lpi_mode_n++;
+			if (status & CORE_IRQ_TX_PATH_EXIT_LPI_MODE)
 				priv->tx_path_in_lpi_mode = false;
-			}
-			if (status & core_irq_rx_path_in_lpi_mode)
-				priv->xstats.irq_rx_path_in_lpi_mode_n++;
-			if (status & core_irq_rx_path_exit_lpi_mode)
-				priv->xstats.irq_rx_path_exit_lpi_mode_n++;
 		}
 	}
 
-- 
1.7.4.4


--------------090907080700060704020909
Content-Type: text/x-patch;
 name="0002-stmmac-start-managing-pcs-RGMII-modes-and-restart-AN.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0002-stmmac-start-managing-pcs-RGMII-modes-and-restart-AN.pa";
 filename*1="tch"

>From 952f89212446f3f346d2ade62aada1d7c06842b0 Mon Sep 17 00:00:00 2001
From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Fri, 22 Feb 2013 12:24:00 +0100
Subject: [net-next.git 2/2] stmmac: start managing pcs  RGMII modes and
 restart ANE

This patch adds the minimal support to manage the PCS
modes (RGMII) and restart the ANE when the interface is
opened.

Currently the following main things are missing:

o SGMII/TBI support
o manage the advertisement register (e.g. reg 50)
o manage pause via ADV.
o manage the Auto-Nogotiation Ability Register (51)
o improve the ethtool.

Thanks to Byungho that wrote some part of this code.

Signed-off-by: Byungho An <bh74.an@samsung.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |    7 +++
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |   20 +++++++
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |   15 +++++
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    1 +
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   13 +++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   55 +++++++++++++++----
 6 files changed, 99 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 1db761c..04134ad 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -142,6 +142,12 @@ struct stmmac_extra_stats {
 #define FLOW_TX		2
 #define FLOW_AUTO	(FLOW_TX | FLOW_RX)
 
+/* PCS defines */
+#define STMMAC_PCS_RGMII	(1<<0)
+#define STMMAC_PCS_SGMII	(1<<1)
+#define STMMAC_PCS_TBI		(1<<2)
+#define STMMAC_PCS_RTBI		(1<<1)
+
 #define SF_DMA_MODE 1 /* DMA STORE-AND-FORWARD Operation Mode */
 
 /* DAM HW feature register fields */
@@ -347,6 +353,7 @@ struct stmmac_ops {
 	void (*reset_eee_mode) (void __iomem *ioaddr);
 	void (*set_eee_timer) (void __iomem *ioaddr, int ls, int tw);
 	void (*set_eee_pls) (void __iomem *ioaddr, int link);
+	void (*ctrl_ane) (void __iomem *ioaddr, bool restart);
 };
 
 struct mac_link {
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
index 8a8c39f..5cfd4d2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
@@ -98,6 +98,24 @@ enum power_event {
 #define GMAC_TBI	0x000000d4	/* TBI extend status */
 #define GMAC_S_R_GMII	0x000000d8	/* SGMII RGMII status */
 
+/* AN Configuration defines */
+#define GMAC_AN_CTRL_RAN	0x00000200 /* Restart Auto-Negotiation */
+#define GMAC_AN_CTRL_ANE	0x00001000 /* Auto-Negotiation Enable */
+#define GMAC_AN_CTRL_ELE	0x00004000 /* External Loopback Enable */
+#define GMAC_AN_CTRL_ECD	0x00010000 /* Enable Comma Detect */
+#define GMAC_AN_CTRL_LR		0x00020000 /* Lock to Reference */
+#define GMAC_AN_CTRL_SGMRAL	0x00040000 /* SGMII RAL Control */
+
+/* AN Status defines */
+#define GMAC_AN_STATUS_LS	0x00000004 /* Link Status 0:down 1:up */
+#define GMAC_AN_STATUS_ANA	0x00000008 /* Auto-Negotiation Ability */
+#define GMAC_AN_STATUS_ANC	0x00000020 /* Auto-Negotiation Complete */
+#define GMAC_AN_STATUS_ES	0x00000100 /* Extended Status */
+
+ /* GMAC Configuration defines */
+#define GMAC_CONTROL_TC	0x01000000 /* Transmit Conf. in RGMII/SGMII */
+#define GMAC_CONTROL_WD	0x00800000 /* Disable Watchdog on receive */
+
 /* GMAC Configuration defines */
 #define GMAC_CONTROL_TC	0x01000000	/* Transmit Conf. in RGMII/SGMII */
 #define GMAC_CONTROL_WD	0x00800000	/* Disable Watchdog on receive */
@@ -231,5 +249,7 @@ enum rtc_control {
 #define GMAC_MMC_TX_INTR   0x108
 #define GMAC_MMC_RX_CSUM_OFFLOAD   0x208
 
+
+
 extern const struct stmmac_dma_ops dwmac1000_dma_ops;
 #endif /* __DWMAC1000_H__ */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index ff4c79e..f59366d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -309,6 +309,20 @@ static void  dwmac1000_set_eee_timer(void __iomem *ioaddr, int ls, int tw)
 	writel(value, ioaddr + LPI_TIMER_CTRL);
 }
 
+static void dwmac1000_ctrl_ane(void __iomem *ioaddr, bool restart)
+{
+	u32 value;
+
+	value = readl(ioaddr + GMAC_AN_CTRL);
+	/* auto negotiation enable and External Loopback enable */
+	value = GMAC_AN_CTRL_ANE | GMAC_AN_CTRL_ELE;
+
+	if (restart)
+		value |= GMAC_AN_CTRL_RAN;
+
+	writel(value, ioaddr + GMAC_AN_CTRL);
+}
+
 static const struct stmmac_ops dwmac1000_ops = {
 	.core_init = dwmac1000_core_init,
 	.rx_ipc = dwmac1000_rx_ipc_enable,
@@ -323,6 +337,7 @@ static const struct stmmac_ops dwmac1000_ops = {
 	.reset_eee_mode =  dwmac1000_reset_eee_mode,
 	.set_eee_timer =  dwmac1000_set_eee_timer,
 	.set_eee_pls =  dwmac1000_set_eee_pls,
+	.ctrl_ane = dwmac1000_ctrl_ane,
 };
 
 struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index b05df89..197497c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -93,6 +93,7 @@ struct stmmac_priv {
 	u32 tx_coal_timer;
 	int use_riwt;
 	u32 rx_riwt;
+	int pcs;
 };
 
 extern int phyaddr;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index e15004f..71b58ea 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -222,6 +222,10 @@ static int stmmac_ethtool_getsettings(struct net_device *dev,
 	struct stmmac_priv *priv = netdev_priv(dev);
 	struct phy_device *phy = priv->phydev;
 	int rc;
+
+	if (priv->pcs) /* FIXME */
+		return -EOPNOTSUPP;
+
 	if (phy == NULL) {
 		pr_err("%s: %s: PHY is not registered\n",
 		       __func__, dev->name);
@@ -246,6 +250,9 @@ static int stmmac_ethtool_setsettings(struct net_device *dev,
 	struct phy_device *phy = priv->phydev;
 	int rc;
 
+	if (priv->pcs) /* FIXME */
+		return -EOPNOTSUPP;
+
 	spin_lock(&priv->lock);
 	rc = phy_ethtool_sset(phy, cmd);
 	spin_unlock(&priv->lock);
@@ -317,6 +324,9 @@ stmmac_get_pauseparam(struct net_device *netdev,
 
 	spin_lock(&priv->lock);
 
+	if (priv->pcs)
+		return -EOPNOTSUPP;
+
 	pause->rx_pause = 0;
 	pause->tx_pause = 0;
 	pause->autoneg = priv->phydev->autoneg;
@@ -338,6 +348,9 @@ stmmac_set_pauseparam(struct net_device *netdev,
 	int new_pause = FLOW_OFF;
 	int ret = 0;
 
+	if (priv->pcs)
+		return -EOPNOTSUPP;
+
 	spin_lock(&priv->lock);
 
 	if (pause->rx_pause)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 1f2f349..6366266 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -398,6 +398,21 @@ static void stmmac_adjust_link(struct net_device *dev)
 	DBG(probe, DEBUG, "stmmac_adjust_link: exiting\n");
 }
 
+static void stmmac_check_pcs_mode(struct stmmac_priv *priv)
+{
+	int interface = priv->plat->interface;
+
+	if (priv->dma_cap.pcs) {
+		if ((interface & PHY_INTERFACE_MODE_RGMII) ||
+		    (interface & PHY_INTERFACE_MODE_RGMII_ID) ||
+		    (interface & PHY_INTERFACE_MODE_RGMII_RXID) ||
+		    (interface & PHY_INTERFACE_MODE_RGMII_TXID)) {
+			pr_debug("STMMAC: PCS RGMII support enable\n");
+			priv->pcs = STMMAC_PCS_RGMII;
+		}
+	}
+}
+
 /**
  * stmmac_init_phy - PHY initialization
  * @dev: net device structure
@@ -1012,10 +1027,13 @@ static int stmmac_open(struct net_device *dev)
 
 	stmmac_check_ether_addr(priv);
 
-	ret = stmmac_init_phy(dev);
-	if (unlikely(ret)) {
-		pr_err("%s: Cannot attach to PHY (error: %d)\n", __func__, ret);
-		goto open_error;
+	if (!priv->pcs) {
+		ret = stmmac_init_phy(dev);
+		if (unlikely(ret)) {
+			pr_err("%s: Cannot attach to PHY (error: %d)\n",
+			       __func__, ret);
+			goto open_error;
+		}
 	}
 
 	/* Create and initialize the TX/RX descriptors chains. */
@@ -1104,7 +1122,12 @@ static int stmmac_open(struct net_device *dev)
 		phy_start(priv->phydev);
 
 	priv->tx_lpi_timer = STMMAC_DEFAULT_TWT_LS_TIMER;
-	priv->eee_enabled = stmmac_eee_init(priv);
+
+	/* Using PCS we cannot dial with the phy registers at this stage
+	 * so we do not support extra feature like EEE.
+	 */
+	if (!priv->pcs)
+		priv->eee_enabled = stmmac_eee_init(priv);
 
 	stmmac_init_tx_coalesce(priv);
 
@@ -1113,6 +1136,9 @@ static int stmmac_open(struct net_device *dev)
 		priv->hw->dma->rx_watchdog(priv->ioaddr, MAX_DMA_RIWT);
 	}
 
+	if (priv->pcs && priv->hw->mac->ctrl_ane)
+		priv->hw->mac->ctrl_ane(priv->ioaddr, 1);
+
 	napi_enable(&priv->napi);
 	netif_start_queue(dev);
 
@@ -2028,12 +2054,16 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 	else
 		priv->clk_csr = priv->plat->clk_csr;
 
-	/* MDIO bus Registration */
-	ret = stmmac_mdio_register(ndev);
-	if (ret < 0) {
-		pr_debug("%s: MDIO bus (id: %d) registration failed",
-			 __func__, priv->plat->bus_id);
-		goto error_mdio_register;
+	stmmac_check_pcs_mode(priv);
+
+	if (!priv->pcs) {
+		/* MDIO bus Registration */
+		ret = stmmac_mdio_register(ndev);
+		if (ret < 0) {
+			pr_debug("%s: MDIO bus (id: %d) registration failed",
+				 __func__, priv->plat->bus_id);
+			goto error_mdio_register;
+		}
 	}
 
 	return priv;
@@ -2065,7 +2095,8 @@ int stmmac_dvr_remove(struct net_device *ndev)
 	priv->hw->dma->stop_tx(priv->ioaddr);
 
 	stmmac_set_mac(priv->ioaddr, false);
-	stmmac_mdio_unregister(ndev);
+	if (!priv->pcs)
+		stmmac_mdio_unregister(ndev);
 	netif_carrier_off(ndev);
 	unregister_netdev(ndev);
 	free_netdev(ndev);
-- 
1.7.4.4


--------------090907080700060704020909--

From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH next 0/7] Pull request for 'davem-next.misc' branch (#2)
Date: Fri, 30 Sep 2011 12:36:04 +0200
Message-ID: <20110930103604.GA26727@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54214 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754105Ab1I3Khr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2011 06:37:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'davem-next.misc' in repository

git://violet.fr.zoreil.com/romieu/linux davem-next.misc

to get the changes below.

Since first request:
- silence __devinit annotations warnings (bnx2)
- removed spurious eol space from modified line (iphase)

Original request:
I have tested (and fixed) the iphase driver changes with a pair of
back-to-back oc3 cards. The bnx2 firmware changes have been rebased
against -next as suggested by Michael Chan.

Distance from 'davem-next' (56fd49e399ce1d82200fad5b8924d4e35a587809)
---------------------------------------------------------------------

66cd4c84a6901f99f973ad5931ddcaed8a9f18c6
2c29dc5512d84374595896374484ed4e271d7b5b
044e981c9e6461b698322c185aebb8a6eb5e74e8
99d68bf70e9e371005ae8113409135a157b84440
40e078ed5586f289bd89eebc223205ac80d31605
c1dbbf703ebddf73f5a801f93fc594f1bf0113cb
39bc30d36989834ba5bebce6f50bf1f6328da512

Diffstat
--------

 drivers/atm/iphase.c                   |  265 ++++++++++++----------
 drivers/atm/iphase.h                   |  391 ++++++++++++++++----------------
 drivers/net/ethernet/amd/depca.h       |    2 -
 drivers/net/ethernet/broadcom/bnx2.c   |   67 ++++--
 drivers/net/ethernet/dec/tulip/de4x5.h |    2 -
 drivers/net/ethernet/jme.h             |    1 -
 drivers/net/ethernet/realtek/8139cp.c  |    5 -
 drivers/net/ethernet/realtek/sc92031.c |    8 +-
 drivers/net/ethernet/tehuti/tehuti.c   |    8 +-
 drivers/net/usb/rtl8150.c              |  111 ++++-----
 10 files changed, 431 insertions(+), 429 deletions(-)

Shortlog
--------

Francois Romieu (7):
      bnx2: don't request firmware when there's no userspace.
      8139cp : removal of headers.
      atm/iphase : removal of PCI space dereferences.
      sc92031: use standard #defines from mii.h.
      rtl8150: removal of forward declarations.
      drivers/net/ethernet: remove unused #define.
      tehuti: shorten PCI device table.

Patch
-----

diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index cb90f7a..3d0c2b0 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -818,127 +818,152 @@ static void ia_hw_type(IADEV *iadev) {
 
 }
 
-static void IaFrontEndIntr(IADEV *iadev) {
-  volatile IA_SUNI *suni;
-  volatile ia_mb25_t *mb25;
-  volatile suni_pm7345_t *suni_pm7345;
-
-  if(iadev->phy_type & FE_25MBIT_PHY) {
-     mb25 = (ia_mb25_t*)iadev->phy;
-     iadev->carrier_detect =  Boolean(mb25->mb25_intr_status & MB25_IS_GSB);
-  } else if (iadev->phy_type & FE_DS3_PHY) {
-     suni_pm7345 = (suni_pm7345_t *)iadev->phy;
-     /* clear FRMR interrupts */
-     (void) suni_pm7345->suni_ds3_frm_intr_stat; 
-     iadev->carrier_detect =  
-           Boolean(!(suni_pm7345->suni_ds3_frm_stat & SUNI_DS3_LOSV));
-  } else if (iadev->phy_type & FE_E3_PHY ) {
-     suni_pm7345 = (suni_pm7345_t *)iadev->phy;
-     (void) suni_pm7345->suni_e3_frm_maint_intr_ind;
-     iadev->carrier_detect =
-           Boolean(!(suni_pm7345->suni_e3_frm_fram_intr_ind_stat&SUNI_E3_LOS));
-  }
-  else { 
-     suni = (IA_SUNI *)iadev->phy;
-     (void) suni->suni_rsop_status;
-     iadev->carrier_detect = Boolean(!(suni->suni_rsop_status & SUNI_LOSV));
-  }
-  if (iadev->carrier_detect)
-    printk("IA: SUNI carrier detected\n");
-  else
-    printk("IA: SUNI carrier lost signal\n"); 
-  return;
+static u32 ia_phy_read32(struct iadev_priv *ia, unsigned int reg)
+{
+	return readl(ia->phy + (reg >> 2));
+}
+
+static void ia_phy_write32(struct iadev_priv *ia, unsigned int reg, u32 val)
+{
+	writel(val, ia->phy + (reg >> 2));
+}
+
+static void ia_frontend_intr(struct iadev_priv *iadev)
+{
+	u32 status;
+
+	if (iadev->phy_type & FE_25MBIT_PHY) {
+		status = ia_phy_read32(iadev, MB25_INTR_STATUS);
+		iadev->carrier_detect = (status & MB25_IS_GSB) ? 1 : 0;
+	} else if (iadev->phy_type & FE_DS3_PHY) {
+		ia_phy_read32(iadev, SUNI_DS3_FRM_INTR_STAT);
+		status = ia_phy_read32(iadev, SUNI_DS3_FRM_STAT);
+		iadev->carrier_detect = (status & SUNI_DS3_LOSV) ? 0 : 1;
+	} else if (iadev->phy_type & FE_E3_PHY) {
+		ia_phy_read32(iadev, SUNI_E3_FRM_MAINT_INTR_IND);
+		status = ia_phy_read32(iadev, SUNI_E3_FRM_FRAM_INTR_IND_STAT);
+		iadev->carrier_detect = (status & SUNI_E3_LOS) ? 0 : 1;
+	} else {
+		status = ia_phy_read32(iadev, SUNI_RSOP_STATUS);
+		iadev->carrier_detect = (status & SUNI_LOSV) ? 0 : 1;
+	}
+
+	printk(KERN_INFO "IA: SUNI carrier %s\n",
+		iadev->carrier_detect ? "detected" : "lost signal");
 }
 
-static void ia_mb25_init (IADEV *iadev)
+static void ia_mb25_init(struct iadev_priv *iadev)
 {
-   volatile ia_mb25_t  *mb25 = (ia_mb25_t*)iadev->phy;
 #if 0
    mb25->mb25_master_ctrl = MB25_MC_DRIC | MB25_MC_DREC | MB25_MC_ENABLED;
 #endif
-   mb25->mb25_master_ctrl = MB25_MC_DRIC | MB25_MC_DREC;
-   mb25->mb25_diag_control = 0;
-   /*
-    * Initialize carrier detect state
-    */
-   iadev->carrier_detect =  Boolean(mb25->mb25_intr_status & MB25_IS_GSB);
-   return;
-}                   
+	ia_phy_write32(iadev, MB25_MASTER_CTRL, MB25_MC_DRIC | MB25_MC_DREC);
+	ia_phy_write32(iadev, MB25_DIAG_CONTROL, 0);
+
+	iadev->carrier_detect =
+		(ia_phy_read32(iadev, MB25_INTR_STATUS) & MB25_IS_GSB) ? 1 : 0;
+}
 
-static void ia_suni_pm7345_init (IADEV *iadev)
+struct ia_reg {
+	u16 reg;
+	u16 val;
+};
+
+static void ia_phy_write(struct iadev_priv *iadev,
+			 const struct ia_reg *regs, int len)
 {
-   volatile suni_pm7345_t *suni_pm7345 = (suni_pm7345_t *)iadev->phy;
-   if (iadev->phy_type & FE_DS3_PHY)
-   {
-      iadev->carrier_detect = 
-          Boolean(!(suni_pm7345->suni_ds3_frm_stat & SUNI_DS3_LOSV)); 
-      suni_pm7345->suni_ds3_frm_intr_enbl = 0x17;
-      suni_pm7345->suni_ds3_frm_cfg = 1;
-      suni_pm7345->suni_ds3_tran_cfg = 1;
-      suni_pm7345->suni_config = 0;
-      suni_pm7345->suni_splr_cfg = 0;
-      suni_pm7345->suni_splt_cfg = 0;
-   }
-   else 
-   {
-      iadev->carrier_detect = 
-          Boolean(!(suni_pm7345->suni_e3_frm_fram_intr_ind_stat & SUNI_E3_LOS));
-      suni_pm7345->suni_e3_frm_fram_options = 0x4;
-      suni_pm7345->suni_e3_frm_maint_options = 0x20;
-      suni_pm7345->suni_e3_frm_fram_intr_enbl = 0x1d;
-      suni_pm7345->suni_e3_frm_maint_intr_enbl = 0x30;
-      suni_pm7345->suni_e3_tran_stat_diag_options = 0x0;
-      suni_pm7345->suni_e3_tran_fram_options = 0x1;
-      suni_pm7345->suni_config = SUNI_PM7345_E3ENBL;
-      suni_pm7345->suni_splr_cfg = 0x41;
-      suni_pm7345->suni_splt_cfg = 0x41;
-   } 
-   /*
-    * Enable RSOP loss of signal interrupt.
-    */
-   suni_pm7345->suni_intr_enbl = 0x28;
- 
-   /*
-    * Clear error counters
-    */
-   suni_pm7345->suni_id_reset = 0;
-
-   /*
-    * Clear "PMCTST" in master test register.
-    */
-   suni_pm7345->suni_master_test = 0;
-
-   suni_pm7345->suni_rxcp_ctrl = 0x2c;
-   suni_pm7345->suni_rxcp_fctrl = 0x81;
- 
-   suni_pm7345->suni_rxcp_idle_pat_h1 =
-   	suni_pm7345->suni_rxcp_idle_pat_h2 =
-   	suni_pm7345->suni_rxcp_idle_pat_h3 = 0;
-   suni_pm7345->suni_rxcp_idle_pat_h4 = 1;
- 
-   suni_pm7345->suni_rxcp_idle_mask_h1 = 0xff;
-   suni_pm7345->suni_rxcp_idle_mask_h2 = 0xff;
-   suni_pm7345->suni_rxcp_idle_mask_h3 = 0xff;
-   suni_pm7345->suni_rxcp_idle_mask_h4 = 0xfe;
- 
-   suni_pm7345->suni_rxcp_cell_pat_h1 =
-   	suni_pm7345->suni_rxcp_cell_pat_h2 =
-   	suni_pm7345->suni_rxcp_cell_pat_h3 = 0;
-   suni_pm7345->suni_rxcp_cell_pat_h4 = 1;
- 
-   suni_pm7345->suni_rxcp_cell_mask_h1 =
-   	suni_pm7345->suni_rxcp_cell_mask_h2 =
-   	suni_pm7345->suni_rxcp_cell_mask_h3 =
-   	suni_pm7345->suni_rxcp_cell_mask_h4 = 0xff;
- 
-   suni_pm7345->suni_txcp_ctrl = 0xa4;
-   suni_pm7345->suni_txcp_intr_en_sts = 0x10;
-   suni_pm7345->suni_txcp_idle_pat_h5 = 0x55;
- 
-   suni_pm7345->suni_config &= ~(SUNI_PM7345_LLB |
-                                 SUNI_PM7345_CLB |
-                                 SUNI_PM7345_DLB |
-                                  SUNI_PM7345_PLB);
+	while (len--) {
+		ia_phy_write32(iadev, regs->reg, regs->val);
+		regs++;
+	}
+}
+
+static void ia_suni_pm7345_init_ds3(struct iadev_priv *iadev)
+{
+	static const struct ia_reg suni_ds3_init [] = {
+		{ SUNI_DS3_FRM_INTR_ENBL,	0x17 },
+		{ SUNI_DS3_FRM_CFG,		0x01 },
+		{ SUNI_DS3_TRAN_CFG,		0x01 },
+		{ SUNI_CONFIG,			0 },
+		{ SUNI_SPLR_CFG,		0 },
+		{ SUNI_SPLT_CFG,		0 }
+	};
+	u32 status;
+
+	status = ia_phy_read32(iadev, SUNI_DS3_FRM_STAT);
+	iadev->carrier_detect = (status & SUNI_DS3_LOSV) ? 0 : 1;
+
+	ia_phy_write(iadev, suni_ds3_init, ARRAY_SIZE(suni_ds3_init));
+}
+
+static void ia_suni_pm7345_init_e3(struct iadev_priv *iadev)
+{
+	static const struct ia_reg suni_e3_init [] = {
+		{ SUNI_E3_FRM_FRAM_OPTIONS,		0x04 },
+		{ SUNI_E3_FRM_MAINT_OPTIONS,		0x20 },
+		{ SUNI_E3_FRM_FRAM_INTR_ENBL,		0x1d },
+		{ SUNI_E3_FRM_MAINT_INTR_ENBL,		0x30 },
+		{ SUNI_E3_TRAN_STAT_DIAG_OPTIONS,	0 },
+		{ SUNI_E3_TRAN_FRAM_OPTIONS,		0x01 },
+		{ SUNI_CONFIG,				SUNI_PM7345_E3ENBL },
+		{ SUNI_SPLR_CFG,			0x41 },
+		{ SUNI_SPLT_CFG,			0x41 }
+	};
+	u32 status;
+
+	status = ia_phy_read32(iadev, SUNI_E3_FRM_FRAM_INTR_IND_STAT);
+	iadev->carrier_detect = (status & SUNI_E3_LOS) ? 0 : 1;
+	ia_phy_write(iadev, suni_e3_init, ARRAY_SIZE(suni_e3_init));
+}
+
+static void ia_suni_pm7345_init(struct iadev_priv *iadev)
+{
+	static const struct ia_reg suni_init [] = {
+		/* Enable RSOP loss of signal interrupt. */
+		{ SUNI_INTR_ENBL,		0x28 },
+		/* Clear error counters. */
+		{ SUNI_ID_RESET,		0 },
+		/* Clear "PMCTST" in master test register. */
+		{ SUNI_MASTER_TEST,		0 },
+
+		{ SUNI_RXCP_CTRL,		0x2c },
+		{ SUNI_RXCP_FCTRL,		0x81 },
+
+		{ SUNI_RXCP_IDLE_PAT_H1,	0 },
+		{ SUNI_RXCP_IDLE_PAT_H2,	0 },
+		{ SUNI_RXCP_IDLE_PAT_H3,	0 },
+		{ SUNI_RXCP_IDLE_PAT_H4,	0x01 },
+
+		{ SUNI_RXCP_IDLE_MASK_H1,	0xff },
+		{ SUNI_RXCP_IDLE_MASK_H2,	0xff },
+		{ SUNI_RXCP_IDLE_MASK_H3,	0xff },
+		{ SUNI_RXCP_IDLE_MASK_H4,	0xfe },
+
+		{ SUNI_RXCP_CELL_PAT_H1,	0 },
+		{ SUNI_RXCP_CELL_PAT_H2,	0 },
+		{ SUNI_RXCP_CELL_PAT_H3,	0 },
+		{ SUNI_RXCP_CELL_PAT_H4,	0x01 },
+
+		{ SUNI_RXCP_CELL_MASK_H1,	0xff },
+		{ SUNI_RXCP_CELL_MASK_H2,	0xff },
+		{ SUNI_RXCP_CELL_MASK_H3,	0xff },
+		{ SUNI_RXCP_CELL_MASK_H4,	0xff },
+
+		{ SUNI_TXCP_CTRL,		0xa4 },
+		{ SUNI_TXCP_INTR_EN_STS,	0x10 },
+		{ SUNI_TXCP_IDLE_PAT_H5,	0x55 }
+	};
+
+	if (iadev->phy_type & FE_DS3_PHY)
+		ia_suni_pm7345_init_ds3(iadev);
+	else
+		ia_suni_pm7345_init_e3(iadev);
+
+	ia_phy_write(iadev, suni_init, ARRAY_SIZE(suni_init));
+
+	ia_phy_write32(iadev, SUNI_CONFIG, ia_phy_read32(iadev, SUNI_CONFIG) &
+		~(SUNI_PM7345_LLB | SUNI_PM7345_CLB |
+		  SUNI_PM7345_DLB | SUNI_PM7345_PLB));
 #ifdef __SNMP__
    suni_pm7345->suni_rxcp_intr_en_sts |= SUNI_OOCDE;
 #endif /* __SNMP__ */
@@ -1425,10 +1450,10 @@ static int rx_init(struct atm_dev *dev)
 	       iadev->dma + IPHASE5575_RX_LIST_ADDR);  
 	IF_INIT(printk("Tx Dle list addr: 0x%p value: 0x%0x\n",
                       iadev->dma+IPHASE5575_TX_LIST_ADDR,
-                      *(u32*)(iadev->dma+IPHASE5575_TX_LIST_ADDR));  
+                      readl(iadev->dma + IPHASE5575_TX_LIST_ADDR));
 	printk("Rx Dle list addr: 0x%p value: 0x%0x\n",
                       iadev->dma+IPHASE5575_RX_LIST_ADDR,
-                      *(u32*)(iadev->dma+IPHASE5575_RX_LIST_ADDR));)  
+                      readl(iadev->dma + IPHASE5575_RX_LIST_ADDR));)
   
 	writew(0xffff, iadev->reass_reg+REASS_MASK_REG);  
 	writew(0, iadev->reass_reg+MODE_REG);  
@@ -2208,7 +2233,7 @@ static irqreturn_t ia_int(int irq, void *dev_id)
 	if (status & STAT_DLERINT)  
 	{  
 	   /* Clear this bit by writing a 1 to it. */  
-	   *(u_int *)(iadev->reg+IPHASE5575_BUS_STATUS_REG) = STAT_DLERINT;
+	   writel(STAT_DLERINT, iadev->reg + IPHASE5575_BUS_STATUS_REG);
 	   rx_dle_intr(dev);  
 	}  
 	if (status & STAT_SEGINT)  
@@ -2219,13 +2244,13 @@ static irqreturn_t ia_int(int irq, void *dev_id)
 	}  
 	if (status & STAT_DLETINT)  
 	{  
-	   *(u_int *)(iadev->reg+IPHASE5575_BUS_STATUS_REG) = STAT_DLETINT;  
+	   writel(STAT_DLETINT, iadev->reg + IPHASE5575_BUS_STATUS_REG);
 	   tx_dle_intr(dev);  
 	}  
 	if (status & (STAT_FEINT | STAT_ERRINT | STAT_MARKINT))  
 	{  
            if (status & STAT_FEINT) 
-               IaFrontEndIntr(iadev);
+               ia_frontend_intr(iadev);
 	}  
    }
    return IRQ_RETVAL(handled);
@@ -2556,7 +2581,7 @@ static int __devinit ia_start(struct atm_dev *dev)
 				goto err_free_rx;
 		}
 		/* Get iadev->carrier_detect status */
-		IaFrontEndIntr(iadev);
+		ia_frontend_intr(iadev);
 	}
 	return 0;
 
@@ -2827,7 +2852,7 @@ static int ia_ioctl(struct atm_dev *dev, unsigned int cmd, void __user *arg)
 
          case 0xb:
 	    if (!capable(CAP_NET_ADMIN)) return -EPERM;
-            IaFrontEndIntr(iadev);
+            ia_frontend_intr(iadev);
             break;
          case 0xa:
 	    if (!capable(CAP_NET_ADMIN)) return -EPERM;
diff --git a/drivers/atm/iphase.h b/drivers/atm/iphase.h
index 077735e..6a0955e 100644
--- a/drivers/atm/iphase.h
+++ b/drivers/atm/iphase.h
@@ -889,79 +889,71 @@ typedef struct ia_rtn_q {
 } IARTN_Q;
 
 #define SUNI_LOSV   	0x04
-typedef struct {
-        u32   suni_master_reset;      /* SUNI Master Reset and Identity     */
-        u32   suni_master_config;     /* SUNI Master Configuration          */
-        u32   suni_master_intr_stat;  /* SUNI Master Interrupt Status       */
-        u32   suni_reserved1;         /* Reserved                           */
-        u32   suni_master_clk_monitor;/* SUNI Master Clock Monitor          */
-        u32   suni_master_control;    /* SUNI Master Clock Monitor          */
-        u32   suni_reserved2[10];     /* Reserved                           */
-
-        u32   suni_rsop_control;      /* RSOP Control/Interrupt Enable      */
-        u32   suni_rsop_status;       /* RSOP Status/Interrupt States       */
-        u32   suni_rsop_section_bip8l;/* RSOP Section BIP-8 LSB             */
-        u32   suni_rsop_section_bip8m;/* RSOP Section BIP-8 MSB             */
-
-        u32   suni_tsop_control;      /* TSOP Control                       */
-        u32   suni_tsop_diag;         /* TSOP Disgnostics                   */
-        u32   suni_tsop_reserved[2];  /* TSOP Reserved                      */
-
-        u32   suni_rlop_cs;           /* RLOP Control/Status                */
-        u32   suni_rlop_intr;         /* RLOP Interrupt Enable/Status       */
-        u32   suni_rlop_line_bip24l;  /* RLOP Line BIP-24 LSB               */
-        u32   suni_rlop_line_bip24;   /* RLOP Line BIP-24                   */
-        u32   suni_rlop_line_bip24m;  /* RLOP Line BIP-24 MSB               */
-        u32   suni_rlop_line_febel;   /* RLOP Line FEBE LSB                 */
-        u32   suni_rlop_line_febe;    /* RLOP Line FEBE                     */
-        u32   suni_rlop_line_febem;   /* RLOP Line FEBE MSB                 */
-
-        u32   suni_tlop_control;      /* TLOP Control                       */
-        u32   suni_tlop_disg;         /* TLOP Disgnostics                   */
-        u32   suni_tlop_reserved[14]; /* TLOP Reserved                      */
-
-        u32   suni_rpop_cs;           /* RPOP Status/Control                */
-        u32   suni_rpop_intr;         /* RPOP Interrupt/Status              */
-        u32   suni_rpop_reserved;     /* RPOP Reserved                      */
-        u32   suni_rpop_intr_ena;     /* RPOP Interrupt Enable              */
-        u32   suni_rpop_reserved1[3]; /* RPOP Reserved                      */
-        u32   suni_rpop_path_sig;     /* RPOP Path Signal Label             */
-        u32   suni_rpop_bip8l;        /* RPOP Path BIP-8 LSB                */
-        u32   suni_rpop_bip8m;        /* RPOP Path BIP-8 MSB                */
-        u32   suni_rpop_febel;        /* RPOP Path FEBE LSB                 */
-        u32   suni_rpop_febem;        /* RPOP Path FEBE MSB                 */
-        u32   suni_rpop_reserved2[4]; /* RPOP Reserved                      */
-
-        u32   suni_tpop_cntrl_daig;   /* TPOP Control/Disgnostics           */
-        u32   suni_tpop_pointer_ctrl; /* TPOP Pointer Control               */
-        u32   suni_tpop_sourcer_ctrl; /* TPOP Source Control                */
-        u32   suni_tpop_reserved1[2]; /* TPOP Reserved                      */
-        u32   suni_tpop_arb_prtl;     /* TPOP Arbitrary Pointer LSB         */
-        u32   suni_tpop_arb_prtm;     /* TPOP Arbitrary Pointer MSB         */
-        u32   suni_tpop_reserved2;    /* TPOP Reserved                      */
-        u32   suni_tpop_path_sig;     /* TPOP Path Signal Lable             */
-        u32   suni_tpop_path_status;  /* TPOP Path Status                   */
-        u32   suni_tpop_reserved3[6]; /* TPOP Reserved                      */              
-
-        u32   suni_racp_cs;           /* RACP Control/Status                */
-        u32   suni_racp_intr;         /* RACP Interrupt Enable/Status       */
-        u32   suni_racp_hdr_pattern;  /* RACP Match Header Pattern          */
-        u32   suni_racp_hdr_mask;     /* RACP Match Header Mask             */
-        u32   suni_racp_corr_hcs;     /* RACP Correctable HCS Error Count   */
-        u32   suni_racp_uncorr_hcs;   /* RACP Uncorrectable HCS Error Count */
-        u32   suni_racp_reserved[10]; /* RACP Reserved                      */
-
-        u32   suni_tacp_control;      /* TACP Control                       */
-        u32   suni_tacp_idle_hdr_pat; /* TACP Idle Cell Header Pattern      */
-        u32   suni_tacp_idle_pay_pay; /* TACP Idle Cell Payld Octet Pattern */
-        u32   suni_tacp_reserved[5];  /* TACP Reserved                      */
-
-        u32   suni_reserved3[24];     /* Reserved                           */
-
-        u32   suni_master_test;       /* SUNI Master Test                   */
-        u32   suni_reserved_test;     /* SUNI Reserved for Test             */
-} IA_SUNI;
-
+enum ia_suni {
+	SUNI_MASTER_RESET	= 0x000, /* SUNI Master Reset and Identity   */
+	SUNI_MASTER_CONFIG	= 0x004, /* SUNI Master Configuration        */
+	SUNI_MASTER_INTR_STAT	= 0x008, /* SUNI Master Interrupt Status     */
+	SUNI_RESERVED1		= 0x00c, /* Reserved                         */
+	SUNI_MASTER_CLK_MONITOR	= 0x010, /* SUNI Master Clock Monitor        */
+	SUNI_MASTER_CONTROL	= 0x014, /* SUNI Master Clock Monitor        */
+					 /* Reserved (10)                    */
+	SUNI_RSOP_CONTROL	= 0x040, /* RSOP Control/Interrupt Enable    */
+	SUNI_RSOP_STATUS	= 0x044, /* RSOP Status/Interrupt States     */
+	SUNI_RSOP_SECTION_BIP8L	= 0x048, /* RSOP Section BIP-8 LSB           */
+	SUNI_RSOP_SECTION_BIP8M	= 0x04c, /* RSOP Section BIP-8 MSB           */
+
+	SUNI_TSOP_CONTROL	= 0x050, /* TSOP Control                     */
+	SUNI_TSOP_DIAG		= 0x054, /* TSOP Disgnostics                 */
+					 /* Reserved (2)                     */
+	SUNI_RLOP_CS		= 0x060, /* RLOP Control/Status              */
+	SUNI_RLOP_INTR		= 0x064, /* RLOP Interrupt Enable/Status     */
+	SUNI_RLOP_LINE_BIP24L	= 0x068, /* RLOP Line BIP-24 LSB             */
+	SUNI_RLOP_LINE_BIP24	= 0x06c, /* RLOP Line BIP-24                 */
+	SUNI_RLOP_LINE_BIP24M	= 0x070, /* RLOP Line BIP-24 MSB             */
+	SUNI_RLOP_LINE_FEBEL	= 0x074, /* RLOP Line FEBE LSB               */
+	SUNI_RLOP_LINE_FEBE	= 0x078, /* RLOP Line FEBE                   */
+	SUNI_RLOP_LINE_FEBEM	= 0x07c, /* RLOP Line FEBE MSB               */
+
+	SUNI_TLOP_CONTROL	= 0x080, /* TLOP Control                     */
+	SUNI_TLOP_DISG		= 0x084, /* TLOP Disgnostics                 */
+					 /* Reserved (14)                    */
+	SUNI_RPOP_CS		= 0x0c0, /* RPOP Status/Control              */
+	SUNI_RPOP_INTR		= 0x0c4, /* RPOP Interrupt/Status            */
+	SUNI_RPOP_RESERVED	= 0x0c8, /* RPOP Reserved                    */
+	SUNI_RPOP_INTR_ENA	= 0x0cc, /* RPOP Interrupt Enable            */
+					 /* Reserved (3)                     */
+	SUNI_RPOP_PATH_SIG	= 0x0dc, /* RPOP Path Signal Label           */
+	SUNI_RPOP_BIP8L		= 0x0e0, /* RPOP Path BIP-8 LSB              */
+	SUNI_RPOP_BIP8M		= 0x0e4, /* RPOP Path BIP-8 MSB              */
+	SUNI_RPOP_FEBEL		= 0x0e8, /* RPOP Path FEBE LSB               */
+	SUNI_RPOP_FEBEM		= 0x0ec, /* RPOP Path FEBE MSB               */
+					 /* Reserved (4)                     */
+	SUNI_TPOP_CNTRL_DAIG	= 0x100, /* TPOP Control/Disgnostics         */
+	SUNI_TPOP_POINTER_CTRL	= 0x104, /* TPOP Pointer Control             */
+	SUNI_TPOP_SOURCER_CTRL	= 0x108, /* TPOP Source Control              */
+					 /* Reserved (2)                     */
+	SUNI_TPOP_ARB_PRTL	= 0x114, /* TPOP Arbitrary Pointer LSB       */
+	SUNI_TPOP_ARB_PRTM	= 0x118, /* TPOP Arbitrary Pointer MSB       */
+	SUNI_TPOP_RESERVED2	= 0x11c, /* TPOP Reserved                    */
+	SUNI_TPOP_PATH_SIG	= 0x120, /* TPOP Path Signal Lable           */
+	SUNI_TPOP_PATH_STATUS	= 0x124, /* TPOP Path Status                 */
+					 /* Reserved (6)                     */
+	SUNI_RACP_CS		= 0x140, /* RACP Control/Status              */
+	SUNI_RACP_INTR		= 0x144, /* RACP Interrupt Enable/Status     */
+	SUNI_RACP_HDR_PATTERN	= 0x148, /* RACP Match Header Pattern        */
+	SUNI_RACP_HDR_MASK	= 0x14c, /* RACP Match Header Mask           */
+	SUNI_RACP_CORR_HCS	= 0x150, /* RACP Correctable HCS Error Count */
+	SUNI_RACP_UNCORR_HCS	= 0x154, /* RACP Uncorrectable HCS Err Count */
+					 /* Reserved (10)                    */
+	SUNI_TACP_CONTROL	= 0x180, /* TACP Control                     */
+	SUNI_TACP_IDLE_HDR_PAT	= 0x184, /* TACP Idle Cell Header Pattern    */
+	SUNI_TACP_IDLE_PAY_PAY	= 0x188, /* TACP Idle Cell Payld Octet Patrn */
+					 /* Reserved (5)                     */
+					 /* Reserved (24)                    */
+	/* FIXME: unused but name conflicts.
+	 * SUNI_MASTER_TEST	= 0x200,    SUNI Master Test                 */
+	SUNI_RESERVED_TEST	= 0x204  /* SUNI Reserved for Test           */
+};
 
 typedef struct _SUNI_STATS_
 {
@@ -993,13 +985,11 @@ typedef struct _SUNI_STATS_
    u32 racp_uchcs_count;            // uncorrectable HCS error count
 } IA_SUNI_STATS; 
 
-typedef struct iadev_t {  
+typedef struct iadev_priv {
 	/*-----base pointers into (i)chipSAR+ address space */   
-	u32 __iomem *phy;		/* base pointer into phy(SUNI) */  
-	u32 __iomem *dma;		/* base pointer into DMA control   
-						registers */  
-	u32 __iomem *reg;		/* base pointer to SAR registers  
-					   - Bus Interface Control Regs */  
+	u32 __iomem *phy;	/* Base pointer into phy (SUNI). */
+	u32 __iomem *dma;	/* Base pointer into DMA control registers. */
+	u32 __iomem *reg;	/* Base pointer to SAR registers. */
 	u32 __iomem *seg_reg;		/* base pointer to segmentation engine  
 						internal registers */  
 	u32 __iomem *reass_reg;		/* base pointer to reassemble engine  
@@ -1071,14 +1061,14 @@ typedef struct iadev_t {
 #define INPH_IA_VCC(v) ((struct ia_vcc *) (v)->dev_data)  
 
 /******************* IDT77105 25MB/s PHY DEFINE *****************************/
-typedef struct {
-	u_int	mb25_master_ctrl;	/* Master control		     */
-	u_int	mb25_intr_status;	/* Interrupt status		     */
-	u_int	mb25_diag_control;	/* Diagnostic control		     */
-	u_int	mb25_led_hec;		/* LED driver and HEC status/control */
-	u_int	mb25_low_byte_counter;	/* Low byte counter		     */
-	u_int	mb25_high_byte_counter;	/* High byte counter		     */
-} ia_mb25_t;
+enum ia_mb25 {
+	MB25_MASTER_CTRL	= 0x00, /* Master control		     */
+	MB25_INTR_STATUS	= 0x04,	/* Interrupt status		     */
+	MB25_DIAG_CONTROL	= 0x08,	/* Diagnostic control		     */
+	MB25_LED_HEC		= 0x0c,	/* LED driver and HEC status/control */
+	MB25_LOW_BYTE_COUNTER	= 0x10,
+	MB25_HIGH_BYTE_COUNTER	= 0x14
+};
 
 /*
  * Master Control
@@ -1127,122 +1117,121 @@ typedef struct {
 #define FE_E3_PHY       0x0090          /* E3 */
 		     
 /*********************** SUNI_PM7345 PHY DEFINE HERE *********************/
-typedef struct _suni_pm7345_t
-{
-    u_int suni_config;     /* SUNI Configuration */
-    u_int suni_intr_enbl;  /* SUNI Interrupt Enable */
-    u_int suni_intr_stat;  /* SUNI Interrupt Status */
-    u_int suni_control;    /* SUNI Control */
-    u_int suni_id_reset;   /* SUNI Reset and Identity */
-    u_int suni_data_link_ctrl;
-    u_int suni_rboc_conf_intr_enbl;
-    u_int suni_rboc_stat;
-    u_int suni_ds3_frm_cfg;
-    u_int suni_ds3_frm_intr_enbl;
-    u_int suni_ds3_frm_intr_stat;
-    u_int suni_ds3_frm_stat;
-    u_int suni_rfdl_cfg;
-    u_int suni_rfdl_enbl_stat;
-    u_int suni_rfdl_stat;
-    u_int suni_rfdl_data;
-    u_int suni_pmon_chng;
-    u_int suni_pmon_intr_enbl_stat;
-    u_int suni_reserved1[0x13-0x11];
-    u_int suni_pmon_lcv_evt_cnt_lsb;
-    u_int suni_pmon_lcv_evt_cnt_msb;
-    u_int suni_pmon_fbe_evt_cnt_lsb;
-    u_int suni_pmon_fbe_evt_cnt_msb;
-    u_int suni_pmon_sez_det_cnt_lsb;
-    u_int suni_pmon_sez_det_cnt_msb;
-    u_int suni_pmon_pe_evt_cnt_lsb;
-    u_int suni_pmon_pe_evt_cnt_msb;
-    u_int suni_pmon_ppe_evt_cnt_lsb;
-    u_int suni_pmon_ppe_evt_cnt_msb;
-    u_int suni_pmon_febe_evt_cnt_lsb;
-    u_int suni_pmon_febe_evt_cnt_msb;
-    u_int suni_ds3_tran_cfg;
-    u_int suni_ds3_tran_diag;
-    u_int suni_reserved2[0x23-0x21];
-    u_int suni_xfdl_cfg;
-    u_int suni_xfdl_intr_st;
-    u_int suni_xfdl_xmit_data;
-    u_int suni_xboc_code;
-    u_int suni_splr_cfg;
-    u_int suni_splr_intr_en;
-    u_int suni_splr_intr_st;
-    u_int suni_splr_status;
-    u_int suni_splt_cfg;
-    u_int suni_splt_cntl;
-    u_int suni_splt_diag_g1;
-    u_int suni_splt_f1;
-    u_int suni_cppm_loc_meters;
-    u_int suni_cppm_chng_of_cppm_perf_meter;
-    u_int suni_cppm_b1_err_cnt_lsb;
-    u_int suni_cppm_b1_err_cnt_msb;
-    u_int suni_cppm_framing_err_cnt_lsb;
-    u_int suni_cppm_framing_err_cnt_msb;
-    u_int suni_cppm_febe_cnt_lsb;
-    u_int suni_cppm_febe_cnt_msb;
-    u_int suni_cppm_hcs_err_cnt_lsb;
-    u_int suni_cppm_hcs_err_cnt_msb;
-    u_int suni_cppm_idle_un_cell_cnt_lsb;
-    u_int suni_cppm_idle_un_cell_cnt_msb;
-    u_int suni_cppm_rcv_cell_cnt_lsb;
-    u_int suni_cppm_rcv_cell_cnt_msb;
-    u_int suni_cppm_xmit_cell_cnt_lsb;
-    u_int suni_cppm_xmit_cell_cnt_msb;
-    u_int suni_rxcp_ctrl;
-    u_int suni_rxcp_fctrl;
-    u_int suni_rxcp_intr_en_sts;
-    u_int suni_rxcp_idle_pat_h1;
-    u_int suni_rxcp_idle_pat_h2;
-    u_int suni_rxcp_idle_pat_h3;
-    u_int suni_rxcp_idle_pat_h4;
-    u_int suni_rxcp_idle_mask_h1;
-    u_int suni_rxcp_idle_mask_h2;
-    u_int suni_rxcp_idle_mask_h3;
-    u_int suni_rxcp_idle_mask_h4;
-    u_int suni_rxcp_cell_pat_h1;
-    u_int suni_rxcp_cell_pat_h2;
-    u_int suni_rxcp_cell_pat_h3;
-    u_int suni_rxcp_cell_pat_h4;
-    u_int suni_rxcp_cell_mask_h1;
-    u_int suni_rxcp_cell_mask_h2;
-    u_int suni_rxcp_cell_mask_h3;
-    u_int suni_rxcp_cell_mask_h4;
-    u_int suni_rxcp_hcs_cs;
-    u_int suni_rxcp_lcd_cnt_threshold;
-    u_int suni_reserved3[0x57-0x54];
-    u_int suni_txcp_ctrl;
-    u_int suni_txcp_intr_en_sts;
-    u_int suni_txcp_idle_pat_h1;
-    u_int suni_txcp_idle_pat_h2;
-    u_int suni_txcp_idle_pat_h3;
-    u_int suni_txcp_idle_pat_h4;
-    u_int suni_txcp_idle_pat_h5;
-    u_int suni_txcp_idle_payload;
-    u_int suni_e3_frm_fram_options;
-    u_int suni_e3_frm_maint_options;
-    u_int suni_e3_frm_fram_intr_enbl;
-    u_int suni_e3_frm_fram_intr_ind_stat;
-    u_int suni_e3_frm_maint_intr_enbl;
-    u_int suni_e3_frm_maint_intr_ind;
-    u_int suni_e3_frm_maint_stat;
-    u_int suni_reserved4;
-    u_int suni_e3_tran_fram_options;
-    u_int suni_e3_tran_stat_diag_options;
-    u_int suni_e3_tran_bip_8_err_mask;
-    u_int suni_e3_tran_maint_adapt_options;
-    u_int suni_ttb_ctrl;
-    u_int suni_ttb_trail_trace_id_stat;
-    u_int suni_ttb_ind_addr;
-    u_int suni_ttb_ind_data;
-    u_int suni_ttb_exp_payload_type;
-    u_int suni_ttb_payload_type_ctrl_stat;
-    u_int suni_pad5[0x7f-0x71];
-    u_int suni_master_test;
-    u_int suni_pad6[0xff-0x80];
-}suni_pm7345_t;
+enum suni_pm7345 {
+	SUNI_CONFIG			= 0x000, /* SUNI Configuration */
+	SUNI_INTR_ENBL			= 0x004, /* SUNI Interrupt Enable */
+	SUNI_INTR_STAT			= 0x008, /* SUNI Interrupt Status */
+	SUNI_CONTROL			= 0x00c, /* SUNI Control */
+	SUNI_ID_RESET			= 0x010, /* SUNI Reset and Identity */
+	SUNI_DATA_LINK_CTRL		= 0x014,
+	SUNI_RBOC_CONF_INTR_ENBL	= 0x018,
+	SUNI_RBOC_STAT			= 0x01c,
+	SUNI_DS3_FRM_CFG		= 0x020,
+	SUNI_DS3_FRM_INTR_ENBL		= 0x024,
+	SUNI_DS3_FRM_INTR_STAT		= 0x028,
+	SUNI_DS3_FRM_STAT		= 0x02c,
+	SUNI_RFDL_CFG			= 0x030,
+	SUNI_RFDL_ENBL_STAT		= 0x034,
+	SUNI_RFDL_STAT			= 0x038,
+	SUNI_RFDL_DATA			= 0x03c,
+	SUNI_PMON_CHNG			= 0x040,
+	SUNI_PMON_INTR_ENBL_STAT	= 0x044,
+	/* SUNI_RESERVED1 (0x13 - 0x11) */
+	SUNI_PMON_LCV_EVT_CNT_LSB	= 0x050,
+	SUNI_PMON_LCV_EVT_CNT_MSB	= 0x054,
+	SUNI_PMON_FBE_EVT_CNT_LSB	= 0x058,
+	SUNI_PMON_FBE_EVT_CNT_MSB	= 0x05c,
+	SUNI_PMON_SEZ_DET_CNT_LSB	= 0x060,
+	SUNI_PMON_SEZ_DET_CNT_MSB	= 0x064,
+	SUNI_PMON_PE_EVT_CNT_LSB	= 0x068,
+	SUNI_PMON_PE_EVT_CNT_MSB	= 0x06c,
+	SUNI_PMON_PPE_EVT_CNT_LSB	= 0x070,
+	SUNI_PMON_PPE_EVT_CNT_MSB	= 0x074,
+	SUNI_PMON_FEBE_EVT_CNT_LSB	= 0x078,
+	SUNI_PMON_FEBE_EVT_CNT_MSB	= 0x07c,
+	SUNI_DS3_TRAN_CFG		= 0x080,
+	SUNI_DS3_TRAN_DIAG		= 0x084,
+	/* SUNI_RESERVED2 (0x23 - 0x21) */
+	SUNI_XFDL_CFG			= 0x090,
+	SUNI_XFDL_INTR_ST		= 0x094,
+	SUNI_XFDL_XMIT_DATA		= 0x098,
+	SUNI_XBOC_CODE			= 0x09c,
+	SUNI_SPLR_CFG			= 0x0a0,
+	SUNI_SPLR_INTR_EN		= 0x0a4,
+	SUNI_SPLR_INTR_ST		= 0x0a8,
+	SUNI_SPLR_STATUS		= 0x0ac,
+	SUNI_SPLT_CFG			= 0x0b0,
+	SUNI_SPLT_CNTL			= 0x0b4,
+	SUNI_SPLT_DIAG_G1		= 0x0b8,
+	SUNI_SPLT_F1			= 0x0bc,
+	SUNI_CPPM_LOC_METERS		= 0x0c0,
+	SUNI_CPPM_CHG_OF_CPPM_PERF_METR	= 0x0c4,
+	SUNI_CPPM_B1_ERR_CNT_LSB	= 0x0c8,
+	SUNI_CPPM_B1_ERR_CNT_MSB	= 0x0cc,
+	SUNI_CPPM_FRAMING_ERR_CNT_LSB	= 0x0d0,
+	SUNI_CPPM_FRAMING_ERR_CNT_MSB	= 0x0d4,
+	SUNI_CPPM_FEBE_CNT_LSB		= 0x0d8,
+	SUNI_CPPM_FEBE_CNT_MSB		= 0x0dc,
+	SUNI_CPPM_HCS_ERR_CNT_LSB	= 0x0e0,
+	SUNI_CPPM_HCS_ERR_CNT_MSB	= 0x0e4,
+	SUNI_CPPM_IDLE_UN_CELL_CNT_LSB	= 0x0e8,
+	SUNI_CPPM_IDLE_UN_CELL_CNT_MSB	= 0x0ec,
+	SUNI_CPPM_RCV_CELL_CNT_LSB	= 0x0f0,
+	SUNI_CPPM_RCV_CELL_CNT_MSB	= 0x0f4,
+	SUNI_CPPM_XMIT_CELL_CNT_LSB	= 0x0f8,
+	SUNI_CPPM_XMIT_CELL_CNT_MSB	= 0x0fc,
+	SUNI_RXCP_CTRL			= 0x100,
+	SUNI_RXCP_FCTRL			= 0x104,
+	SUNI_RXCP_INTR_EN_STS		= 0x108,
+	SUNI_RXCP_IDLE_PAT_H1		= 0x10c,
+	SUNI_RXCP_IDLE_PAT_H2		= 0x110,
+	SUNI_RXCP_IDLE_PAT_H3		= 0x114,
+	SUNI_RXCP_IDLE_PAT_H4		= 0x118,
+	SUNI_RXCP_IDLE_MASK_H1		= 0x11c,
+	SUNI_RXCP_IDLE_MASK_H2		= 0x120,
+	SUNI_RXCP_IDLE_MASK_H3		= 0x124,
+	SUNI_RXCP_IDLE_MASK_H4		= 0x128,
+	SUNI_RXCP_CELL_PAT_H1		= 0x12c,
+	SUNI_RXCP_CELL_PAT_H2		= 0x130,
+	SUNI_RXCP_CELL_PAT_H3		= 0x134,
+	SUNI_RXCP_CELL_PAT_H4		= 0x138,
+	SUNI_RXCP_CELL_MASK_H1		= 0x13c,
+	SUNI_RXCP_CELL_MASK_H2		= 0x140,
+	SUNI_RXCP_CELL_MASK_H3		= 0x144,
+	SUNI_RXCP_CELL_MASK_H4		= 0x148,
+	SUNI_RXCP_HCS_CS		= 0x14c,
+	SUNI_RXCP_LCD_CNT_THRESHOLD	= 0x150,
+	/* SUNI_RESERVED3 (0x57 - 0x54) */
+	SUNI_TXCP_CTRL			= 0x160,
+	SUNI_TXCP_INTR_EN_STS		= 0x164,
+	SUNI_TXCP_IDLE_PAT_H1		= 0x168,
+	SUNI_TXCP_IDLE_PAT_H2		= 0x16c,
+	SUNI_TXCP_IDLE_PAT_H3		= 0x170,
+	SUNI_TXCP_IDLE_PAT_H4		= 0x174,
+	SUNI_TXCP_IDLE_PAT_H5		= 0x178,
+	SUNI_TXCP_IDLE_PAYLOAD		= 0x17c,
+	SUNI_E3_FRM_FRAM_OPTIONS	= 0x180,
+	SUNI_E3_FRM_MAINT_OPTIONS	= 0x184,
+	SUNI_E3_FRM_FRAM_INTR_ENBL	= 0x188,
+	SUNI_E3_FRM_FRAM_INTR_IND_STAT	= 0x18c,
+	SUNI_E3_FRM_MAINT_INTR_ENBL	= 0x190,
+	SUNI_E3_FRM_MAINT_INTR_IND	= 0x194,
+	SUNI_E3_FRM_MAINT_STAT		= 0x198,
+	SUNI_RESERVED4			= 0x19c,
+	SUNI_E3_TRAN_FRAM_OPTIONS	= 0x1a0,
+	SUNI_E3_TRAN_STAT_DIAG_OPTIONS	= 0x1a4,
+	SUNI_E3_TRAN_BIP_8_ERR_MASK	= 0x1a8,
+	SUNI_E3_TRAN_MAINT_ADAPT_OPTS	= 0x1ac,
+	SUNI_TTB_CTRL			= 0x1b0,
+	SUNI_TTB_TRAIL_TRACE_ID_STAT	= 0x1b4,
+	SUNI_TTB_IND_ADDR		= 0x1b8,
+	SUNI_TTB_IND_DATA		= 0x1bc,
+	SUNI_TTB_EXP_PAYLOAD_TYPE	= 0x1c0,
+	SUNI_TTB_PAYLOAD_TYPE_CTRL_STAT	= 0x1c4,
+	/* SUNI_PAD5 (0x7f - 0x71) */
+	SUNI_MASTER_TEST		= 0x200,
+	/* SUNI_PAD6 (0xff - 0x80) */
+};
 
 #define SUNI_PM7345_T suni_pm7345_t
 #define SUNI_PM7345     0x20            /* Suni chip type */
diff --git a/drivers/net/ethernet/amd/depca.h b/drivers/net/ethernet/amd/depca.h
index ee42648..cdcfe42 100644
--- a/drivers/net/ethernet/amd/depca.h
+++ b/drivers/net/ethernet/amd/depca.h
@@ -157,8 +157,6 @@
 */
 #include <linux/sockios.h>
 
-#define	DEPCAIOCTL	SIOCDEVPRIVATE
-
 struct depca_ioctl {
 	unsigned short cmd;                /* Command to run */
 	unsigned short len;                /* Length of the data buffer */
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 9afb653..21bdda3 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -3623,7 +3623,7 @@ bnx2_set_rx_mode(struct net_device *dev)
 	spin_unlock_bh(&bp->phy_lock);
 }
 
-static int __devinit
+static int
 check_fw_section(const struct firmware *fw,
 		 const struct bnx2_fw_file_section *section,
 		 u32 alignment, bool non_empty)
@@ -3639,7 +3639,7 @@ check_fw_section(const struct firmware *fw,
 	return 0;
 }
 
-static int __devinit
+static int
 check_mips_fw_entry(const struct firmware *fw,
 		    const struct bnx2_mips_fw_file_entry *entry)
 {
@@ -3650,8 +3650,16 @@ check_mips_fw_entry(const struct firmware *fw,
 	return 0;
 }
 
-static int __devinit
-bnx2_request_firmware(struct bnx2 *bp)
+static void bnx2_release_firmware(struct bnx2 *bp)
+{
+	if (bp->rv2p_firmware) {
+		release_firmware(bp->mips_firmware);
+		release_firmware(bp->rv2p_firmware);
+		bp->rv2p_firmware = NULL;
+	}
+}
+
+static int bnx2_request_uncached_firmware(struct bnx2 *bp)
 {
 	const char *mips_fw_file, *rv2p_fw_file;
 	const struct bnx2_mips_fw_file *mips_fw;
@@ -3673,13 +3681,13 @@ bnx2_request_firmware(struct bnx2 *bp)
 	rc = request_firmware(&bp->mips_firmware, mips_fw_file, &bp->pdev->dev);
 	if (rc) {
 		pr_err("Can't load firmware file \"%s\"\n", mips_fw_file);
-		return rc;
+		goto out;
 	}
 
 	rc = request_firmware(&bp->rv2p_firmware, rv2p_fw_file, &bp->pdev->dev);
 	if (rc) {
 		pr_err("Can't load firmware file \"%s\"\n", rv2p_fw_file);
-		return rc;
+		goto err_release_mips_firmware;
 	}
 	mips_fw = (const struct bnx2_mips_fw_file *) bp->mips_firmware->data;
 	rv2p_fw = (const struct bnx2_rv2p_fw_file *) bp->rv2p_firmware->data;
@@ -3690,16 +3698,30 @@ bnx2_request_firmware(struct bnx2 *bp)
 	    check_mips_fw_entry(bp->mips_firmware, &mips_fw->tpat) ||
 	    check_mips_fw_entry(bp->mips_firmware, &mips_fw->txp)) {
 		pr_err("Firmware file \"%s\" is invalid\n", mips_fw_file);
-		return -EINVAL;
+		rc = -EINVAL;
+		goto err_release_firmware;
 	}
 	if (bp->rv2p_firmware->size < sizeof(*rv2p_fw) ||
 	    check_fw_section(bp->rv2p_firmware, &rv2p_fw->proc1.rv2p, 8, true) ||
 	    check_fw_section(bp->rv2p_firmware, &rv2p_fw->proc2.rv2p, 8, true)) {
 		pr_err("Firmware file \"%s\" is invalid\n", rv2p_fw_file);
-		return -EINVAL;
+		rc = -EINVAL;
+		goto err_release_firmware;
 	}
+out:
+	return rc;
 
-	return 0;
+err_release_firmware:
+	release_firmware(bp->rv2p_firmware);
+	bp->rv2p_firmware = NULL;
+err_release_mips_firmware:
+	release_firmware(bp->mips_firmware);
+	goto out;
+}
+
+static int bnx2_request_firmware(struct bnx2 *bp)
+{
+	return bp->rv2p_firmware ? 0 : bnx2_request_uncached_firmware(bp);
 }
 
 static u32
@@ -6267,6 +6289,10 @@ bnx2_open(struct net_device *dev)
 	struct bnx2 *bp = netdev_priv(dev);
 	int rc;
 
+	rc = bnx2_request_firmware(bp);
+	if (rc < 0)
+		goto out;
+
 	netif_carrier_off(dev);
 
 	bnx2_set_power_state(bp, PCI_D0);
@@ -6327,8 +6353,8 @@ bnx2_open(struct net_device *dev)
 		netdev_info(dev, "using MSIX\n");
 
 	netif_tx_start_all_queues(dev);
-
-	return 0;
+out:
+	return rc;
 
 open_err:
 	bnx2_napi_disable(bp);
@@ -6336,7 +6362,8 @@ open_err:
 	bnx2_free_irq(bp);
 	bnx2_free_mem(bp);
 	bnx2_del_napi(bp);
-	return rc;
+	bnx2_release_firmware(bp);
+	goto out;
 }
 
 static void
@@ -8354,10 +8381,6 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	pci_set_drvdata(pdev, dev);
 
-	rc = bnx2_request_firmware(bp);
-	if (rc)
-		goto error;
-
 	memcpy(dev->dev_addr, bp->mac_addr, 6);
 	memcpy(dev->perm_addr, bp->mac_addr, 6);
 
@@ -8389,11 +8412,6 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	return 0;
 
 error:
-	if (bp->mips_firmware)
-		release_firmware(bp->mips_firmware);
-	if (bp->rv2p_firmware)
-		release_firmware(bp->rv2p_firmware);
-
 	if (bp->regview)
 		iounmap(bp->regview);
 	pci_release_regions(pdev);
@@ -8414,11 +8432,6 @@ bnx2_remove_one(struct pci_dev *pdev)
 	del_timer_sync(&bp->timer);
 	cancel_work_sync(&bp->reset_task);
 
-	if (bp->mips_firmware)
-		release_firmware(bp->mips_firmware);
-	if (bp->rv2p_firmware)
-		release_firmware(bp->rv2p_firmware);
-
 	if (bp->regview)
 		iounmap(bp->regview);
 
@@ -8429,6 +8442,8 @@ bnx2_remove_one(struct pci_dev *pdev)
 		bp->flags &= ~BNX2_FLAG_AER_ENABLED;
 	}
 
+	bnx2_release_firmware(bp);
+
 	free_netdev(dev);
 
 	pci_release_regions(pdev);
diff --git a/drivers/net/ethernet/dec/tulip/de4x5.h b/drivers/net/ethernet/dec/tulip/de4x5.h
index 9f28774..ec756eb 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.h
+++ b/drivers/net/ethernet/dec/tulip/de4x5.h
@@ -991,8 +991,6 @@
 */
 #include <linux/sockios.h>
 
-#define	DE4X5IOCTL	SIOCDEVPRIVATE
-
 struct de4x5_ioctl {
 	unsigned short cmd;                /* Command to run */
 	unsigned short len;                /* Length of the data buffer */
diff --git a/drivers/net/ethernet/jme.h b/drivers/net/ethernet/jme.h
index c1f8b89..02ea27c 100644
--- a/drivers/net/ethernet/jme.h
+++ b/drivers/net/ethernet/jme.h
@@ -102,7 +102,6 @@ enum jme_spi_op_bits {
 };
 
 #define HALF_US 500	/* 500 ns */
-#define JMESPIIOCTL	SIOCDEVPRIVATE
 
 #define PCI_PRIV_PE1		0xE4
 
diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index c77d5af..60c8de5 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -55,8 +55,6 @@
 
 #include <linux/module.h>
 #include <linux/moduleparam.h>
-#include <linux/kernel.h>
-#include <linux/compiler.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/init.h>
@@ -65,7 +63,6 @@
 #include <linux/dma-mapping.h>
 #include <linux/delay.h>
 #include <linux/ethtool.h>
-#include <linux/gfp.h>
 #include <linux/mii.h>
 #include <linux/if_vlan.h>
 #include <linux/crc32.h>
@@ -73,10 +70,8 @@
 #include <linux/ip.h>
 #include <linux/tcp.h>
 #include <linux/udp.h>
-#include <linux/cache.h>
 #include <asm/io.h>
 #include <asm/irq.h>
-#include <asm/uaccess.h>
 
 /* These identify the driver base version and may not be removed. */
 static char version[] =
diff --git a/drivers/net/ethernet/realtek/sc92031.c b/drivers/net/ethernet/realtek/sc92031.c
index 128f8eb..a284d64 100644
--- a/drivers/net/ethernet/realtek/sc92031.c
+++ b/drivers/net/ethernet/realtek/sc92031.c
@@ -31,6 +31,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
+#include <linux/mii.h>
 #include <linux/crc32.h>
 
 #include <asm/irq.h>
@@ -116,16 +117,9 @@ enum  silan_registers {
    TestD8     = 0xD8,
 };
 
-#define MII_BMCR            0        // Basic mode control register
-#define MII_BMSR            1        // Basic mode status register
 #define MII_JAB             16
 #define MII_OutputStatus    24
 
-#define BMCR_FULLDPLX       0x0100    // Full duplex
-#define BMCR_ANRESTART      0x0200    // Auto negotiation restart
-#define BMCR_ANENABLE       0x1000    // Enable auto negotiation
-#define BMCR_SPEED100       0x2000    // Select 100Mbps
-#define BMSR_LSTATUS        0x0004    // Link status
 #define PHY_16_JAB_ENB      0x1000
 #define PHY_16_PORT_ENB     0x1
 
diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index 371ab7a..1151cf9 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -67,10 +67,10 @@
 #include "tehuti.h"
 
 static DEFINE_PCI_DEVICE_TABLE(bdx_pci_tbl) = {
-	{0x1FC9, 0x3009, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x1FC9, 0x3010, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x1FC9, 0x3014, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0}
+	{ PCI_VDEVICE(TEHUTI, 0x3009), },
+	{ PCI_VDEVICE(TEHUTI, 0x3010), },
+	{ PCI_VDEVICE(TEHUTI, 0x3014), },
+	{ 0 }
 };
 
 MODULE_DEVICE_TABLE(pci, bdx_pci_tbl);
diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index b00d692..bf8c84d 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -169,26 +169,8 @@ struct rtl8150 {
 
 typedef struct rtl8150 rtl8150_t;
 
-static void fill_skb_pool(rtl8150_t *);
-static void free_skb_pool(rtl8150_t *);
-static inline struct sk_buff *pull_skb(rtl8150_t *);
-static void rtl8150_disconnect(struct usb_interface *intf);
-static int rtl8150_probe(struct usb_interface *intf,
-			   const struct usb_device_id *id);
-static int rtl8150_suspend(struct usb_interface *intf, pm_message_t message);
-static int rtl8150_resume(struct usb_interface *intf);
-
 static const char driver_name [] = "rtl8150";
 
-static struct usb_driver rtl8150_driver = {
-	.name =		driver_name,
-	.probe =	rtl8150_probe,
-	.disconnect =	rtl8150_disconnect,
-	.id_table =	rtl8150_table,
-	.suspend =	rtl8150_suspend,
-	.resume =	rtl8150_resume
-};
-
 /*
 **
 **	device related part of the code
@@ -333,7 +315,7 @@ static int rtl8150_set_mac_address(struct net_device *netdev, void *p)
 	/* Write the MAC address into eeprom. Eeprom writes must be word-sized,
 	   so we need to split them up. */
 	for (i = 0; i * 2 < netdev->addr_len; i++) {
-		set_registers(dev, IDR_EEPROM + (i * 2), 2, 
+		set_registers(dev, IDR_EEPROM + (i * 2), 2,
 		netdev->dev_addr + (i * 2));
 	}
 	/* Clear the WEPROM bit (preventing accidental eeprom writes). */
@@ -490,44 +472,6 @@ resched:
 	tasklet_schedule(&dev->tl);
 }
 
-static void rx_fixup(unsigned long data)
-{
-	rtl8150_t *dev;
-	struct sk_buff *skb;
-	int status;
-
-	dev = (rtl8150_t *)data;
-
-	spin_lock_irq(&dev->rx_pool_lock);
-	fill_skb_pool(dev);
-	spin_unlock_irq(&dev->rx_pool_lock);
-	if (test_bit(RX_URB_FAIL, &dev->flags))
-		if (dev->rx_skb)
-			goto try_again;
-	spin_lock_irq(&dev->rx_pool_lock);
-	skb = pull_skb(dev);
-	spin_unlock_irq(&dev->rx_pool_lock);
-	if (skb == NULL)
-		goto tlsched;
-	dev->rx_skb = skb;
-	usb_fill_bulk_urb(dev->rx_urb, dev->udev, usb_rcvbulkpipe(dev->udev, 1),
-		      dev->rx_skb->data, RTL8150_MTU, read_bulk_callback, dev);
-try_again:
-	status = usb_submit_urb(dev->rx_urb, GFP_ATOMIC);
-	if (status == -ENODEV) {
-		netif_device_detach(dev->netdev);
-	} else if (status) {
-		set_bit(RX_URB_FAIL, &dev->flags);
-		goto tlsched;
-	} else {
-		clear_bit(RX_URB_FAIL, &dev->flags);
-	}
-
-	return;
-tlsched:
-	tasklet_schedule(&dev->tl);
-}
-
 static void write_bulk_callback(struct urb *urb)
 {
 	rtl8150_t *dev;
@@ -665,6 +609,42 @@ static void free_skb_pool(rtl8150_t *dev)
 			dev_kfree_skb(dev->rx_skb_pool[i]);
 }
 
+static void rx_fixup(unsigned long data)
+{
+	struct rtl8150 *dev = (struct rtl8150 *)data;
+	struct sk_buff *skb;
+	int status;
+
+	spin_lock_irq(&dev->rx_pool_lock);
+	fill_skb_pool(dev);
+	spin_unlock_irq(&dev->rx_pool_lock);
+	if (test_bit(RX_URB_FAIL, &dev->flags))
+		if (dev->rx_skb)
+			goto try_again;
+	spin_lock_irq(&dev->rx_pool_lock);
+	skb = pull_skb(dev);
+	spin_unlock_irq(&dev->rx_pool_lock);
+	if (skb == NULL)
+		goto tlsched;
+	dev->rx_skb = skb;
+	usb_fill_bulk_urb(dev->rx_urb, dev->udev, usb_rcvbulkpipe(dev->udev, 1),
+		      dev->rx_skb->data, RTL8150_MTU, read_bulk_callback, dev);
+try_again:
+	status = usb_submit_urb(dev->rx_urb, GFP_ATOMIC);
+	if (status == -ENODEV) {
+		netif_device_detach(dev->netdev);
+	} else if (status) {
+		set_bit(RX_URB_FAIL, &dev->flags);
+		goto tlsched;
+	} else {
+		clear_bit(RX_URB_FAIL, &dev->flags);
+	}
+
+	return;
+tlsched:
+	tasklet_schedule(&dev->tl);
+}
+
 static int enable_net_traffic(rtl8150_t * dev)
 {
 	u8 cr, tcr, rcr, msr;
@@ -778,7 +758,7 @@ static int rtl8150_open(struct net_device *netdev)
 		return -ENOMEM;
 
 	set_registers(dev, IDR, 6, netdev->dev_addr);
-	
+
 	usb_fill_bulk_urb(dev->rx_urb, dev->udev, usb_rcvbulkpipe(dev->udev, 1),
 		      dev->rx_skb->data, RTL8150_MTU, read_bulk_callback, dev);
 	if ((res = usb_submit_urb(dev->rx_urb, GFP_KERNEL))) {
@@ -898,7 +878,7 @@ static const struct net_device_ops rtl8150_netdev_ops = {
 	.ndo_stop		= rtl8150_close,
 	.ndo_do_ioctl		= rtl8150_ioctl,
 	.ndo_start_xmit		= rtl8150_start_xmit,
-	.ndo_tx_timeout 	= rtl8150_tx_timeout,
+	.ndo_tx_timeout		= rtl8150_tx_timeout,
 	.ndo_set_rx_mode	= rtl8150_set_multicast,
 	.ndo_set_mac_address	= rtl8150_set_mac_address,
 
@@ -929,7 +909,7 @@ static int rtl8150_probe(struct usb_interface *intf,
 
 	tasklet_init(&dev->tl, rx_fixup, (unsigned long)dev);
 	spin_lock_init(&dev->rx_pool_lock);
-	
+
 	dev->udev = udev;
 	dev->netdev = netdev;
 	netdev->netdev_ops = &rtl8150_netdev_ops;
@@ -947,7 +927,7 @@ static int rtl8150_probe(struct usb_interface *intf,
 	}
 	fill_skb_pool(dev);
 	set_ethernet_addr(dev);
-	
+
 	usb_set_intfdata(intf, dev);
 	SET_NETDEV_DEV(netdev, &intf->dev);
 	if (register_netdev(netdev) != 0) {
@@ -989,6 +969,15 @@ static void rtl8150_disconnect(struct usb_interface *intf)
 	}
 }
 
+static struct usb_driver rtl8150_driver = {
+	.name		= driver_name,
+	.probe		= rtl8150_probe,
+	.disconnect	= rtl8150_disconnect,
+	.id_table	= rtl8150_table,
+	.suspend	= rtl8150_suspend,
+	.resume		= rtl8150_resume
+};
+
 static int __init usb_rtl8150_init(void)
 {
 	printk(KERN_INFO KBUILD_MODNAME ": " DRIVER_VERSION ":"
-- 
Ueimor

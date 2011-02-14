From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-next-2.6 2/9] jme: PHY Power control for new chip
Date: Mon, 14 Feb 2011 12:27:35 +0800
Message-ID: <1297657662-30289-2-git-send-email-cooldavid@cooldavid.org>
References: <1297657662-30289-1-git-send-email-cooldavid@cooldavid.org>
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"linux-netdev" <netdev@vger.kernel.org>,
	"Aries Lee" <arieslee@jmicron.com>,
	"Devinchiu" <devinchiu@jmicron.com>,
	"Ethan Hsiao" <ethanhsiao@jmicron.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:48719 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755461Ab1BNE2L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Feb 2011 23:28:11 -0500
In-Reply-To: <1297657662-30289-1-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guo-Fu Tseng <cooldavid@cooldavid.org>

After main chip rev 5, the hardware support more power saving
control registers.
Some Non-Linux drivers might turn off the phy power with new
interfaces, this patch makes it possible for Linux to turn it
on again.

Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/jme.c |   68 ++++++++++++++++++++++++++++++++++++++++++-----------
 drivers/net/jme.h |   52 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 106 insertions(+), 14 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index d44716e..d446fdb 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -1577,6 +1577,38 @@ jme_free_irq(struct jme_adapter *jme)
 }
 
 static inline void
+jme_new_phy_on(struct jme_adapter *jme)
+{
+	u32 reg;
+
+	reg = jread32(jme, JME_PHY_PWR);
+	reg &= ~(PHY_PWR_DWN1SEL | PHY_PWR_DWN1SW |
+		 PHY_PWR_DWN2 | PHY_PWR_CLKSEL);
+	jwrite32(jme, JME_PHY_PWR, reg);
+
+	pci_read_config_dword(jme->pdev, PCI_PRIV_PE1, &reg);
+	reg &= ~PE1_GPREG0_PBG;
+	reg |= PE1_GPREG0_ENBG;
+	pci_write_config_dword(jme->pdev, PCI_PRIV_PE1, reg);
+}
+
+static inline void
+jme_new_phy_off(struct jme_adapter *jme)
+{
+	u32 reg;
+
+	reg = jread32(jme, JME_PHY_PWR);
+	reg |= PHY_PWR_DWN1SEL | PHY_PWR_DWN1SW |
+	       PHY_PWR_DWN2 | PHY_PWR_CLKSEL;
+	jwrite32(jme, JME_PHY_PWR, reg);
+
+	pci_read_config_dword(jme->pdev, PCI_PRIV_PE1, &reg);
+	reg &= ~PE1_GPREG0_PBG;
+	reg |= PE1_GPREG0_PDD3COLD;
+	pci_write_config_dword(jme->pdev, PCI_PRIV_PE1, reg);
+}
+
+static inline void
 jme_phy_on(struct jme_adapter *jme)
 {
 	u32 bmcr;
@@ -1584,6 +1616,22 @@ jme_phy_on(struct jme_adapter *jme)
 	bmcr = jme_mdio_read(jme->dev, jme->mii_if.phy_id, MII_BMCR);
 	bmcr &= ~BMCR_PDOWN;
 	jme_mdio_write(jme->dev, jme->mii_if.phy_id, MII_BMCR, bmcr);
+
+	if (new_phy_power_ctrl(jme->chip_main_rev))
+		jme_new_phy_on(jme);
+}
+
+static inline void
+jme_phy_off(struct jme_adapter *jme)
+{
+	u32 bmcr;
+
+	bmcr = jme_mdio_read(jme->dev, jme->mii_if.phy_id, MII_BMCR);
+	bmcr |= BMCR_PDOWN;
+	jme_mdio_write(jme->dev, jme->mii_if.phy_id, MII_BMCR, bmcr);
+
+	if (new_phy_power_ctrl(jme->chip_main_rev))
+		jme_new_phy_off(jme);
 }
 
 static int
@@ -1606,12 +1654,11 @@ jme_open(struct net_device *netdev)
 
 	jme_start_irq(jme);
 
-	if (test_bit(JME_FLAG_SSET, &jme->flags)) {
-		jme_phy_on(jme);
+	jme_phy_on(jme);
+	if (test_bit(JME_FLAG_SSET, &jme->flags))
 		jme_set_settings(netdev, &jme->old_ecmd);
-	} else {
+	else
 		jme_reset_phy_processor(jme);
-	}
 
 	jme_reset_link(jme);
 
@@ -1657,12 +1704,6 @@ jme_wait_link(struct jme_adapter *jme)
 	}
 }
 
-static inline void
-jme_phy_off(struct jme_adapter *jme)
-{
-	jme_mdio_write(jme->dev, jme->mii_if.phy_id, MII_BMCR, BMCR_PDOWN);
-}
-
 static void
 jme_powersave_phy(struct jme_adapter *jme)
 {
@@ -3068,12 +3109,11 @@ jme_resume(struct pci_dev *pdev)
 	jme_clear_pm(jme);
 	pci_restore_state(pdev);
 
-	if (test_bit(JME_FLAG_SSET, &jme->flags)) {
-		jme_phy_on(jme);
+	jme_phy_on(jme);
+	if (test_bit(JME_FLAG_SSET, &jme->flags))
 		jme_set_settings(netdev, &jme->old_ecmd);
-	} else {
+	else
 		jme_reset_phy_processor(jme);
-	}
 
 	jme_start_irq(jme);
 	netif_device_attach(netdev);
diff --git a/drivers/net/jme.h b/drivers/net/jme.h
index 32b2a9d..c3764fc 100644
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -103,6 +103,37 @@ enum jme_spi_op_bits {
 #define HALF_US 500	/* 500 ns */
 #define JMESPIIOCTL	SIOCDEVPRIVATE
 
+#define PCI_PRIV_PE1		0xE4
+
+enum pci_priv_pe1_bit_masks {
+	PE1_ASPMSUPRT	= 0x00000003, /*
+				       * RW:
+				       * Aspm_support[1:0]
+				       * (R/W Port of 5C[11:10])
+				       */
+	PE1_MULTIFUN	= 0x00000004, /* RW: Multi_fun_bit */
+	PE1_RDYDMA	= 0x00000008, /* RO: ~link.rdy_for_dma */
+	PE1_ASPMOPTL	= 0x00000030, /* RW: link.rx10s_option[1:0] */
+	PE1_ASPMOPTH	= 0x000000C0, /* RW: 10_req=[3]?HW:[2] */
+	PE1_GPREG0	= 0x0000FF00, /*
+				       * SRW:
+				       * Cfg_gp_reg0
+				       * [7:6] phy_giga BG control
+				       * [5] CREQ_N as CREQ_N1 (CPPE# as CREQ#)
+				       * [4:0] Reserved
+				       */
+	PE1_GPREG0_PBG	= 0x0000C000, /* phy_giga BG control */
+	PE1_GPREG1	= 0x00FF0000, /* RW: Cfg_gp_reg1 */
+	PE1_REVID	= 0xFF000000, /* RO: Rev ID */
+};
+
+enum pci_priv_pe1_values {
+	PE1_GPREG0_ENBG		= 0x00000000, /* en BG */
+	PE1_GPREG0_PDD3COLD	= 0x00004000, /* giga_PD + d3cold */
+	PE1_GPREG0_PDPCIESD	= 0x00008000, /* giga_PD + pcie_shutdown */
+	PE1_GPREG0_PDPCIEIDDQ	= 0x0000C000, /* giga_PD + pcie_iddq */
+};
+
 /*
  * Dynamic(adaptive)/Static PCC values
  */
@@ -499,6 +530,7 @@ enum jme_iomap_regs {
 	JME_PMCS	= JME_MAC | 0x60, /* Power Management Control/Stat */
 
 
+	JME_PHY_PWR	= JME_PHY | 0x24, /* New PHY Power Ctrl Register */
 	JME_PHY_CS	= JME_PHY | 0x28, /* PHY Ctrl and Status Register */
 	JME_PHY_LINK	= JME_PHY | 0x30, /* PHY Link Status Register */
 	JME_SMBCSR	= JME_PHY | 0x40, /* SMB Control and Status */
@@ -835,6 +867,21 @@ enum jme_pmcs_bit_masks {
 };
 
 /*
+ * New PHY Power Control Register
+ */
+enum jme_phy_pwr_bit_masks {
+	PHY_PWR_DWN1SEL	= 0x01000000, /* Phy_giga.p_PWR_DOWN1_SEL */
+	PHY_PWR_DWN1SW	= 0x02000000, /* Phy_giga.p_PWR_DOWN1_SW */
+	PHY_PWR_DWN2	= 0x04000000, /* Phy_giga.p_PWR_DOWN2 */
+	PHY_PWR_CLKSEL	= 0x08000000, /*
+				       * XTL_OUT Clock select
+				       * (an internal free-running clock)
+				       * 0: xtl_out = phy_giga.A_XTL25_O
+				       * 1: xtl_out = phy_giga.PD_OSC
+				       */
+};
+
+/*
  * Giga PHY Status Registers
  */
 enum jme_phy_link_bit_mask {
@@ -1191,6 +1238,11 @@ static inline int is_buggy250(unsigned short device, u8 chiprev)
 	return device == PCI_DEVICE_ID_JMICRON_JMC250 && chiprev == 0x11;
 }
 
+static inline int new_phy_power_ctrl(u8 chip_main_rev)
+{
+	return chip_main_rev >= 5;
+}
+
 /*
  * Function prototypes
  */
-- 
1.7.2.2


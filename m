From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 03/10] tg3: Prevent corruption at 10 / 100Mbps w CLKREQ
Date: Fri, 21 Nov 2008 11:00:42 -0800
Message-ID: <1227295575.5616@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4667 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751641AbYKUT0Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 14:26:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch disables CLKREQ at 10Mbps and 100Mbps to workaround a TX BD
corruption issue.  This problem only affects the 5784 and 5761 (and
57780 AX) ASIC revisions.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   77 +++++++++++++++++++++++++++++++++++++++++++---------
 drivers/net/tg3.h |    4 +++
 2 files changed, 67 insertions(+), 14 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 821e381..659fb99 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -2154,6 +2154,20 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 			tp->dev->name, state);
 		return -EINVAL;
 	}
+
+	/* Restore the CLKREQ setting. */
+	if (tp->tg3_flags3 & TG3_FLG3_CLKREQ_BUG) {
+		u16 lnkctl;
+
+		pci_read_config_word(tp->pdev,
+				     tp->pcie_cap + PCI_EXP_LNKCTL,
+				     &lnkctl);
+		lnkctl |= PCI_EXP_LNKCTL_CLKREQ_EN;
+		pci_write_config_word(tp->pdev,
+				      tp->pcie_cap + PCI_EXP_LNKCTL,
+				      lnkctl);
+	}
+
 	misc_host_ctrl = tr32(TG3PCI_MISC_HOST_CTRL);
 	tw32(TG3PCI_MISC_HOST_CTRL,
 	     misc_host_ctrl | MISC_HOST_CTRL_MASK_PCI_INT);
@@ -2923,6 +2937,24 @@ relink:
 			      NIC_SRAM_FIRMWARE_MBOX_MAGIC2);
 	}
 
+	/* Prevent send BD corruption. */
+	if (tp->tg3_flags3 & TG3_FLG3_CLKREQ_BUG) {
+		u16 oldlnkctl, newlnkctl;
+
+		pci_read_config_word(tp->pdev,
+				     tp->pcie_cap + PCI_EXP_LNKCTL,
+				     &oldlnkctl);
+		if (tp->link_config.active_speed == SPEED_100 ||
+		    tp->link_config.active_speed == SPEED_10)
+			newlnkctl = oldlnkctl & ~PCI_EXP_LNKCTL_CLKREQ_EN;
+		else
+			newlnkctl = oldlnkctl | PCI_EXP_LNKCTL_CLKREQ_EN;
+		if (newlnkctl != oldlnkctl)
+			pci_write_config_word(tp->pdev,
+					      tp->pcie_cap + PCI_EXP_LNKCTL,
+					      newlnkctl);
+	}
+
 	if (current_link_up != netif_carrier_ok(tp->dev)) {
 		if (current_link_up)
 			netif_carrier_on(tp->dev);
@@ -6016,7 +6048,7 @@ static int tg3_chip_reset(struct tg3 *tp)
 
 	udelay(120);
 
-	if (tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) {
+	if ((tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) && tp->pcie_cap) {
 		if (tp->pci_chip_rev_id == CHIPREV_ID_5750_A0) {
 			int i;
 			u32 cfg_val;
@@ -6029,9 +6061,23 @@ static int tg3_chip_reset(struct tg3 *tp)
 			pci_write_config_dword(tp->pdev, 0xc4,
 					       cfg_val | (1 << 15));
 		}
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785)
-			/* Set PCIE max payload size and clear error status.  */
-			pci_write_config_dword(tp->pdev, 0xd8, 0xf5000);
+
+		/* Set PCIE max payload size to 128 bytes and
+		 * clear the "no snoop" and "relaxed ordering" bits.
+		 */
+		pci_write_config_word(tp->pdev,
+				      tp->pcie_cap + PCI_EXP_DEVCTL,
+				      0);
+
+		pcie_set_readrq(tp->pdev, 4096);
+
+		/* Clear error status */
+		pci_write_config_word(tp->pdev,
+				      tp->pcie_cap + PCI_EXP_DEVSTA,
+				      PCI_EXP_DEVSTA_CED |
+				      PCI_EXP_DEVSTA_NFED |
+				      PCI_EXP_DEVSTA_FED |
+				      PCI_EXP_DEVSTA_URD);
 	}
 
 	tg3_restore_pci_state(tp);
@@ -11967,7 +12013,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	u32 pci_state_reg, grc_misc_cfg;
 	u32 val;
 	u16 pci_cmd;
-	int err, pcie_cap;
+	int err;
 
 	/* Force memory write invalidate off.  If we leave it on,
 	 * then on 5700_BX chips we have to enable a workaround.
@@ -12193,20 +12239,23 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	pci_read_config_dword(tp->pdev, TG3PCI_PCISTATE,
 			      &pci_state_reg);
 
-	pcie_cap = pci_find_capability(tp->pdev, PCI_CAP_ID_EXP);
-	if (pcie_cap != 0) {
+	tp->pcie_cap = pci_find_capability(tp->pdev, PCI_CAP_ID_EXP);
+	if (tp->pcie_cap != 0) {
+		u16 lnkctl;
+
 		tp->tg3_flags2 |= TG3_FLG2_PCI_EXPRESS;
 
 		pcie_set_readrq(tp->pdev, 4096);
 
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
-			u16 lnkctl;
-
-			pci_read_config_word(tp->pdev,
-					     pcie_cap + PCI_EXP_LNKCTL,
-					     &lnkctl);
-			if (lnkctl & PCI_EXP_LNKCTL_CLKREQ_EN)
+		pci_read_config_word(tp->pdev,
+				     tp->pcie_cap + PCI_EXP_LNKCTL,
+				     &lnkctl);
+		if (lnkctl & PCI_EXP_LNKCTL_CLKREQ_EN) {
+			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 				tp->tg3_flags2 &= ~TG3_FLG2_HW_TSO_2;
+			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
+			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761)
+				tp->tg3_flags3 |= TG3_FLG3_CLKREQ_BUG;
 		}
 	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785) {
 		tp->tg3_flags2 |= TG3_FLG2_PCI_EXPRESS;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 599e490..53684b9 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2618,6 +2618,7 @@ struct tg3 {
 #define TG3_FLG3_RGMII_STD_IBND_DISABLE	0x00000100
 #define TG3_FLG3_RGMII_EXT_IBND_RX_EN	0x00000200
 #define TG3_FLG3_RGMII_EXT_IBND_TX_EN	0x00000400
+#define TG3_FLG3_CLKREQ_BUG		0x00000800
 
 	struct timer_list		timer;
 	u16				timer_counter;
@@ -2656,7 +2657,10 @@ struct tg3 {
 
 	int				pm_cap;
 	int				msi_cap;
+	union {
 	int				pcix_cap;
+	int				pcie_cap;
+	};
 
 	struct mii_bus			*mdio_bus;
 	int				mdio_irq[PHY_MAX_ADDR];
-- 
1.5.6.4




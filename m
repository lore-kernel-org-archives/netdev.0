From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/4][TG3]: Walk PCI capability lists.
Date: Fri, 05 Oct 2007 20:37:02 -0700
Message-ID: <1191641822.17453.6.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4563 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750833AbXJFChy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2007 22:37:54 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Walk PCI capability lists.

Newer tg3 devices shuffle around the registers in PCI configuration
space.  This patch changes the way the driver accesses the PCI
capabilities registers.  Hardcoded register locations are replaced with
offsets from pci_find_capability() return values.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index d4ac6e9..4f9fbe2 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4865,9 +4865,15 @@ static void tg3_restore_pci_state(struct tg3 *tp)
 	pci_write_config_dword(tp->pdev, TG3PCI_COMMAND, tp->pci_cmd);
 
 	/* Make sure PCI-X relaxed ordering bit is clear. */
-	pci_read_config_dword(tp->pdev, TG3PCI_X_CAPS, &val);
-	val &= ~PCIX_CAPS_RELAXED_ORDERING;
-	pci_write_config_dword(tp->pdev, TG3PCI_X_CAPS, val);
+	if (tp->pcix_cap) {
+		u16 pcix_cmd;
+
+		pci_read_config_word(tp->pdev, tp->pcix_cap + PCI_X_CMD,
+				     &pcix_cmd);
+		pcix_cmd &= ~PCI_X_CMD_ERO;
+		pci_write_config_word(tp->pdev, tp->pcix_cap + PCI_X_CMD,
+				      pcix_cmd);
+	}
 
 	if (tp->tg3_flags2 & TG3_FLG2_5780_CLASS) {
 
@@ -6574,16 +6580,20 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	tw32_f(WDMAC_MODE, val);
 	udelay(40);
 
-	if ((tp->tg3_flags & TG3_FLAG_PCIX_MODE) != 0) {
-		val = tr32(TG3PCI_X_CAPS);
+	if (tp->tg3_flags & TG3_FLAG_PCIX_MODE) {
+		u16 pcix_cmd;
+
+		pci_read_config_word(tp->pdev, tp->pcix_cap + PCI_X_CMD,
+				     &pcix_cmd);
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5703) {
-			val &= ~PCIX_CAPS_BURST_MASK;
-			val |= (PCIX_CAPS_MAX_BURST_CPIOB << PCIX_CAPS_BURST_SHIFT);
+			pcix_cmd &= ~PCI_X_CMD_MAX_READ;
+			pcix_cmd |= PCI_X_CMD_READ_2K;
 		} else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704) {
-			val &= ~(PCIX_CAPS_SPLIT_MASK | PCIX_CAPS_BURST_MASK);
-			val |= (PCIX_CAPS_MAX_BURST_CPIOB << PCIX_CAPS_BURST_SHIFT);
+			pcix_cmd &= ~(PCI_X_CMD_MAX_SPLIT | PCI_X_CMD_MAX_READ);
+			pcix_cmd |= PCI_X_CMD_READ_2K;
 		}
-		tw32(TG3PCI_X_CAPS, val);
+		pci_write_config_word(tp->pdev, tp->pcix_cap + PCI_X_CMD,
+				      pcix_cmd);
 	}
 
 	tw32_f(RDMAC_MODE, rdmac_mode);
@@ -10712,10 +10722,20 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 				       cacheline_sz_reg);
 	}
 
+	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS) ||
+	    (tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) {
+		tp->pcix_cap = pci_find_capability(tp->pdev, PCI_CAP_ID_PCIX);
+		if (!tp->pcix_cap) {
+			printk(KERN_ERR PFX "Cannot find PCI-X "
+					    "capability, aborting.\n");
+			return -EIO;
+		}
+	}
+
 	pci_read_config_dword(tp->pdev, TG3PCI_PCISTATE,
 			      &pci_state_reg);
 
-	if ((pci_state_reg & PCISTATE_CONV_PCI_MODE) == 0) {
+	if (tp->pcix_cap && (pci_state_reg & PCISTATE_CONV_PCI_MODE) == 0) {
 		tp->tg3_flags |= TG3_FLAG_PCIX_MODE;
 
 		/* If this is a 5700 BX chipset, and we are in PCI-X
@@ -10733,11 +10753,13 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 			 * space registers clobbered due to this bug.
 			 * So explicitly force the chip into D0 here.
 			 */
-			pci_read_config_dword(tp->pdev, TG3PCI_PM_CTRL_STAT,
+			pci_read_config_dword(tp->pdev,
+					      tp->pm_cap + PCI_PM_CTRL,
 					      &pm_reg);
 			pm_reg &= ~PCI_PM_CTRL_STATE_MASK;
 			pm_reg |= PCI_PM_CTRL_PME_ENABLE | 0 /* D0 */;
-			pci_write_config_dword(tp->pdev, TG3PCI_PM_CTRL_STAT,
+			pci_write_config_dword(tp->pdev,
+					       tp->pm_cap + PCI_PM_CTRL,
 					       pm_reg);
 
 			/* Also, force SERR#/PERR# in PCI command. */
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index a6a23bb..c4f845d 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -57,32 +57,7 @@
 #define TG3PCI_IRQ_PIN			0x0000003d
 #define TG3PCI_MIN_GNT			0x0000003e
 #define TG3PCI_MAX_LAT			0x0000003f
-#define TG3PCI_X_CAPS			0x00000040
-#define  PCIX_CAPS_RELAXED_ORDERING	 0x00020000
-#define  PCIX_CAPS_SPLIT_MASK		 0x00700000
-#define  PCIX_CAPS_SPLIT_SHIFT		 20
-#define  PCIX_CAPS_BURST_MASK		 0x000c0000
-#define  PCIX_CAPS_BURST_SHIFT		 18
-#define  PCIX_CAPS_MAX_BURST_CPIOB	 2
-#define TG3PCI_PM_CAP_PTR		0x00000041
-#define TG3PCI_X_COMMAND		0x00000042
-#define TG3PCI_X_STATUS			0x00000044
-#define TG3PCI_PM_CAP_ID		0x00000048
-#define TG3PCI_VPD_CAP_PTR		0x00000049
-#define TG3PCI_PM_CAPS			0x0000004a
-#define TG3PCI_PM_CTRL_STAT		0x0000004c
-#define TG3PCI_BR_SUPP_EXT		0x0000004e
-#define TG3PCI_PM_DATA			0x0000004f
-#define TG3PCI_VPD_CAP_ID		0x00000050
-#define TG3PCI_MSI_CAP_PTR		0x00000051
-#define TG3PCI_VPD_ADDR_FLAG		0x00000052
-#define  VPD_ADDR_FLAG_WRITE		0x00008000
-#define TG3PCI_VPD_DATA			0x00000054
-#define TG3PCI_MSI_CAP_ID		0x00000058
-#define TG3PCI_NXT_CAP_PTR		0x00000059
-#define TG3PCI_MSI_CTRL			0x0000005a
-#define TG3PCI_MSI_ADDR_LOW		0x0000005c
-#define TG3PCI_MSI_ADDR_HIGH		0x00000060
+/* 0x40 --> 0x64 unused */
 #define TG3PCI_MSI_DATA			0x00000064
 /* 0x66 --> 0x68 unused */
 #define TG3PCI_MISC_HOST_CTRL		0x00000068
@@ -2318,6 +2293,7 @@ struct tg3 {
 
 	int				pm_cap;
 	int				msi_cap;
+	int				pcix_cap;
 
 	/* PHY info */
 	u32				phy_id;
diff --git a/include/linux/pci_regs.h b/include/linux/pci_regs.h
index 495d368..423d592 100644
--- a/include/linux/pci_regs.h
+++ b/include/linux/pci_regs.h
@@ -316,7 +316,20 @@
 #define PCI_X_CMD		2	/* Modes & Features */
 #define  PCI_X_CMD_DPERR_E	0x0001	/* Data Parity Error Recovery Enable */
 #define  PCI_X_CMD_ERO		0x0002	/* Enable Relaxed Ordering */
+#define  PCI_X_CMD_READ_512	0x0000	/* 512 byte maximum read byte count */
+#define  PCI_X_CMD_READ_1K	0x0004	/* 1Kbyte maximum read byte count */
+#define  PCI_X_CMD_READ_2K	0x0008	/* 2Kbyte maximum read byte count */
+#define  PCI_X_CMD_READ_4K	0x000c	/* 4Kbyte maximum read byte count */
 #define  PCI_X_CMD_MAX_READ	0x000c	/* Max Memory Read Byte Count */
+				/* Max # of outstanding split transactions */
+#define  PCI_X_CMD_SPLIT_1	0x0000	/* Max 1 */
+#define  PCI_X_CMD_SPLIT_2	0x0010	/* Max 2 */
+#define  PCI_X_CMD_SPLIT_3	0x0020	/* Max 3 */
+#define  PCI_X_CMD_SPLIT_4	0x0030	/* Max 4 */
+#define  PCI_X_CMD_SPLIT_8	0x0040	/* Max 8 */
+#define  PCI_X_CMD_SPLIT_12	0x0050	/* Max 12 */
+#define  PCI_X_CMD_SPLIT_16	0x0060	/* Max 16 */
+#define  PCI_X_CMD_SPLIT_32	0x0070	/* Max 32 */
 #define  PCI_X_CMD_MAX_SPLIT	0x0070	/* Max Outstanding Split Transactions */
 #define  PCI_X_CMD_VERSION(x) 	(((x) >> 12) & 3) /* Version */
 #define PCI_X_STATUS		4	/* PCI-X capabilities */



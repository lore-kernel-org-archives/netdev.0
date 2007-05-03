From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH v2 15/16][BNX2]: Print bus information for PCIE devices.
Date: Thu, 03 May 2007 00:31:49 -0700
Message-ID: <1178177509.4909.78.camel@dell>
References: <1178068303.4820.35.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3776 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030973AbXECGop (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2007 02:44:45 -0400
In-Reply-To: <1178068303.4820.35.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Print bus information for PCIE devices.

Fix the code to print PCI or PCIE bus information for all devices.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 97ed400..85760f7 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6040,6 +6040,58 @@ bnx2_get_5709_media(struct bnx2 *bp)
 	}
 }
 
+static void __devinit
+bnx2_get_pci_speed(struct bnx2 *bp)
+{
+	u32 reg;
+
+	reg = REG_RD(bp, BNX2_PCICFG_MISC_STATUS);
+	if (reg & BNX2_PCICFG_MISC_STATUS_PCIX_DET) {
+		u32 clkreg;
+
+		bp->flags |= PCIX_FLAG;
+
+		clkreg = REG_RD(bp, BNX2_PCICFG_PCI_CLOCK_CONTROL_BITS);
+
+		clkreg &= BNX2_PCICFG_PCI_CLOCK_CONTROL_BITS_PCI_CLK_SPD_DET;
+		switch (clkreg) {
+		case BNX2_PCICFG_PCI_CLOCK_CONTROL_BITS_PCI_CLK_SPD_DET_133MHZ:
+			bp->bus_speed_mhz = 133;
+			break;
+
+		case BNX2_PCICFG_PCI_CLOCK_CONTROL_BITS_PCI_CLK_SPD_DET_95MHZ:
+			bp->bus_speed_mhz = 100;
+			break;
+
+		case BNX2_PCICFG_PCI_CLOCK_CONTROL_BITS_PCI_CLK_SPD_DET_66MHZ:
+		case BNX2_PCICFG_PCI_CLOCK_CONTROL_BITS_PCI_CLK_SPD_DET_80MHZ:
+			bp->bus_speed_mhz = 66;
+			break;
+
+		case BNX2_PCICFG_PCI_CLOCK_CONTROL_BITS_PCI_CLK_SPD_DET_48MHZ:
+		case BNX2_PCICFG_PCI_CLOCK_CONTROL_BITS_PCI_CLK_SPD_DET_55MHZ:
+			bp->bus_speed_mhz = 50;
+			break;
+
+		case BNX2_PCICFG_PCI_CLOCK_CONTROL_BITS_PCI_CLK_SPD_DET_LOW:
+		case BNX2_PCICFG_PCI_CLOCK_CONTROL_BITS_PCI_CLK_SPD_DET_32MHZ:
+		case BNX2_PCICFG_PCI_CLOCK_CONTROL_BITS_PCI_CLK_SPD_DET_38MHZ:
+			bp->bus_speed_mhz = 33;
+			break;
+		}
+	}
+	else {
+		if (reg & BNX2_PCICFG_MISC_STATUS_M66EN)
+			bp->bus_speed_mhz = 66;
+		else
+			bp->bus_speed_mhz = 33;
+	}
+
+	if (reg & BNX2_PCICFG_MISC_STATUS_32BIT_DET)
+		bp->flags |= PCI_32BIT_FLAG;
+
+}
+
 static int __devinit
 bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 {
@@ -6118,7 +6170,15 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 
 	bp->chip_id = REG_RD(bp, BNX2_MISC_ID);
 
-	if (CHIP_NUM(bp) != CHIP_NUM_5709) {
+	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+		if (pci_find_capability(pdev, PCI_CAP_ID_EXP) == 0) {
+			dev_err(&pdev->dev,
+				"Cannot find PCIE capability, aborting.\n");
+			rc = -EIO;
+			goto err_out_unmap;
+		}
+		bp->flags |= PCIE_FLAG;
+	} else {
 		bp->pcix_cap = pci_find_capability(pdev, PCI_CAP_ID_PCIX);
 		if (bp->pcix_cap == 0) {
 			dev_err(&pdev->dev,
@@ -6153,51 +6213,8 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		goto err_out_unmap;
 	}
 
-	/* Get bus information. */
-	reg = REG_RD(bp, BNX2_PCICFG_MISC_STATUS);
-	if (reg & BNX2_PCICFG_MISC_STATUS_PCIX_DET) {
-		u32 clkreg;
-
-		bp->flags |= PCIX_FLAG;
-
-		clkreg = REG_RD(bp, BNX2_PCICFG_PCI_CLOCK_CONTROL_BITS);
-
-		clkreg &= BNX2_PCICFG_PCI_CLOCK_CONTROL_BITS_PCI_CLK_SPD_DET;
-		switch (clkreg) {
-		case BNX2_PCICFG_PCI_CLOCK_CONTROL_BITS_PCI_CLK_SPD_DET_133MHZ:
-			bp->bus_speed_mhz = 133;
-			break;
-
-		case BNX2_PCICFG_PCI_CLOCK_CONTROL_BITS_PCI_CLK_SPD_DET_95MHZ:
-			bp->bus_speed_mhz = 100;
-			break;
-
-		case BNX2_PCICFG_PCI_CLOCK_CONTROL_BITS_PCI_CLK_SPD_DET_66MHZ:
-		case BNX2_PCICFG_PCI_CLOCK_CONTROL_BITS_PCI_CLK_SPD_DET_80MHZ:
-			bp->bus_speed_mhz = 66;
-			break;
-
-		case BNX2_PCICFG_PCI_CLOCK_CONTROL_BITS_PCI_CLK_SPD_DET_48MHZ:
-		case BNX2_PCICFG_PCI_CLOCK_CONTROL_BITS_PCI_CLK_SPD_DET_55MHZ:
-			bp->bus_speed_mhz = 50;
-			break;
-
-		case BNX2_PCICFG_PCI_CLOCK_CONTROL_BITS_PCI_CLK_SPD_DET_LOW:
-		case BNX2_PCICFG_PCI_CLOCK_CONTROL_BITS_PCI_CLK_SPD_DET_32MHZ:
-		case BNX2_PCICFG_PCI_CLOCK_CONTROL_BITS_PCI_CLK_SPD_DET_38MHZ:
-			bp->bus_speed_mhz = 33;
-			break;
-		}
-	}
-	else {
-		if (reg & BNX2_PCICFG_MISC_STATUS_M66EN)
-			bp->bus_speed_mhz = 66;
-		else
-			bp->bus_speed_mhz = 33;
-	}
-
-	if (reg & BNX2_PCICFG_MISC_STATUS_32BIT_DET)
-		bp->flags |= PCI_32BIT_FLAG;
+	if (!(bp->flags & PCIE_FLAG))
+		bnx2_get_pci_speed(bp);
 
 	/* 5706A0 may falsely detect SERR and PERR. */
 	if (CHIP_ID(bp) == CHIP_ID_5706_A0) {
@@ -6381,6 +6398,26 @@ err_out:
 	return rc;
 }
 
+static char * __devinit
+bnx2_bus_string(struct bnx2 *bp, char *str)
+{
+	char *s = str;
+
+	if (bp->flags & PCIE_FLAG) {
+		s += sprintf(s, "PCI Express");
+	} else {
+		s += sprintf(s, "PCI");
+		if (bp->flags & PCIX_FLAG)
+			s += sprintf(s, "-X");
+		if (bp->flags & PCI_32BIT_FLAG)
+			s += sprintf(s, " 32-bit");
+		else
+			s += sprintf(s, " 64-bit");
+		s += sprintf(s, " %dMHz", bp->bus_speed_mhz);
+	}
+	return str;
+}
+
 static int __devinit
 bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -6388,6 +6425,7 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct net_device *dev = NULL;
 	struct bnx2 *bp;
 	int rc, i;
+	char str[40];
 
 	if (version_printed++ == 0)
 		printk(KERN_INFO "%s", version);
@@ -6456,15 +6494,13 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		return rc;
 	}
 
-	printk(KERN_INFO "%s: %s (%c%d) PCI%s %s %dMHz found at mem %lx, "
+	printk(KERN_INFO "%s: %s (%c%d) %s found at mem %lx, "
 		"IRQ %d, ",
 		dev->name,
 		bp->name,
 		((CHIP_ID(bp) & 0xf000) >> 12) + 'A',
 		((CHIP_ID(bp) & 0x0ff0) >> 4),
-		((bp->flags & PCIX_FLAG) ? "-X" : ""),
-		((bp->flags & PCI_32BIT_FLAG) ? "32-bit" : "64-bit"),
-		bp->bus_speed_mhz,
+		bnx2_bus_string(bp, str),
 		dev->base_addr,
 		bp->pdev->irq);
 
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 121576d..322153c 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6476,6 +6476,7 @@ struct bnx2 {
 #define ASF_ENABLE_FLAG			0x00000040
 #define MSI_CAP_FLAG			0x00000080
 #define ONE_SHOT_MSI_FLAG		0x00000100
+#define PCIE_FLAG			0x00000200
 
 	/* Put tx producer and consumer fields in separate cache lines. */
 



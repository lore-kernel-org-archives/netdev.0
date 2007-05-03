From: Andrew Victor <andrew@sanpeople.com>
Subject: [PATCH 2.6.21] AT91RM9200 Ethernet: Support additional PHYs
Date: 03 May 2007 09:17:15 +0200
Message-ID: <1178176634.14657.153.camel@fuzzie.sanpeople.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from za-gw.sanpeople.com ([196.211.225.226]:3731 "EHLO
	za-gw.sanpeople.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964796AbXECHbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 03:31:16 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for a number of new PHY's in the AT91RM9200 Ethernet driver.
- Teridian 78Q21x3
- SMSC LAN83C185
  (Patch from Luca Gamma)
- National Semiconductor DP83848
  (Patches from Ivan Kuten & Thomas Foldesi)

Signed-off-by: Andrew Victor <andrew@sanpeople.com>


diff -urN linux-2.6.21.new/drivers/net/arm/at91_ether.c linux-2.6.21/drivers/net/arm/at91_ether.c
--- linux-2.6.21.new/drivers/net/arm/at91_ether.c	Thu May  3 08:32:10 2007
+++ linux-2.6.21/drivers/net/arm/at91_ether.c	Thu May  3 08:58:34 2007
@@ -225,6 +225,16 @@
 		if (!(phy & ((1 << 2) | 1)))
 			goto done;
 	}
+	else if (lp->phy_type == MII_T78Q21x3_ID) {			/* ack interrupt in Teridian PHY */
+		read_phy(lp->phy_address, MII_T78Q21INT_REG, &phy);
+		if (!(phy & ((1 << 2) | 1)))
+			goto done;
+	}
+	else if (lp->phy_type == MII_DP83848_ID) {
+		read_phy(lp->phy_address, MII_DPPHYSTS_REG, &phy);	/* ack interrupt in DP83848 PHY */
+		if (!(phy & (1 << 7)))
+			goto done;
+	}
 
 	update_linkspeed(dev, 0);
 
@@ -280,6 +290,19 @@
 		dsintr = (1 << 10) | ( 1 << 8);
 		write_phy(lp->phy_address, MII_TPISTATUS, dsintr);
 	}
+	else if (lp->phy_type == MII_T78Q21x3_ID) {	/* for Teridian PHY */
+		read_phy(lp->phy_address, MII_T78Q21INT_REG, &dsintr);
+		dsintr = dsintr | 0x500;		/* set bits 8, 10 */
+		write_phy(lp->phy_address, MII_T78Q21INT_REG, dsintr);
+	}
+	else if (lp->phy_type == MII_DP83848_ID) {	/* National Semiconductor DP83848 PHY */
+		read_phy(lp->phy_address, MII_DPMISR_REG, &dsintr);
+		dsintr = dsintr | 0x3c;			/* set bits 2..5 */
+		write_phy(lp->phy_address, MII_DPMISR_REG, dsintr);
+		read_phy(lp->phy_address, MII_DPMICR_REG, &dsintr);
+		dsintr = dsintr | 0x3;			/* set bits 0,1 */
+		write_phy(lp->phy_address, MII_DPMICR_REG, dsintr);
+	}
 
 	disable_mdi();
 	spin_unlock_irq(&lp->lock);
@@ -323,6 +346,19 @@
 		dsintr = ~((1 << 10) | (1 << 8));
 		write_phy(lp->phy_address, MII_TPISTATUS, dsintr);
 	}
+	else if (lp->phy_type == MII_T78Q21x3_ID) {	/* for Teridian PHY */
+		read_phy(lp->phy_address, MII_T78Q21INT_REG, &dsintr);
+		dsintr = dsintr & ~0x500;			/* clear bits 8, 10 */
+		write_phy(lp->phy_address, MII_T78Q21INT_REG, dsintr);
+	}
+	else if (lp->phy_type == MII_DP83848_ID) {	/* National Semiconductor DP83848 PHY */
+		read_phy(lp->phy_address, MII_DPMICR_REG, &dsintr);
+		dsintr = dsintr & ~0x3;				/* clear bits 0, 1 */
+		write_phy(lp->phy_address, MII_DPMICR_REG, dsintr);
+		read_phy(lp->phy_address, MII_DPMISR_REG, &dsintr);
+		dsintr = dsintr & ~0x3c;			/* clear bits 2..5 */
+		write_phy(lp->phy_address, MII_DPMISR_REG, dsintr);
+	}
 
 	disable_mdi();
 	spin_unlock_irq(&lp->lock);
@@ -1063,10 +1099,16 @@
 		printk(KERN_INFO "%s: Broadcom BCM5221 PHY\n", dev->name);
 	else if (phy_type == MII_DP83847_ID)
 		printk(KERN_INFO "%s: National Semiconductor DP83847 PHY\n", dev->name);
+	else if (phy_type == MII_DP83848_ID)
+		printk(KERN_INFO "%s: National Semiconductor DP83848 PHY\n", dev->name);
 	else if (phy_type == MII_AC101L_ID)
 		printk(KERN_INFO "%s: Altima AC101L PHY\n", dev->name);
 	else if (phy_type == MII_KS8721_ID)
 		printk(KERN_INFO "%s: Micrel KS8721 PHY\n", dev->name);
+	else if (phy_type == MII_T78Q21x3_ID)
+		printk(KERN_INFO "%s: Teridian 78Q21x3 PHY\n", dev->name);
+	else if (phy_type == MII_LAN83C185_ID)
+		printk(KERN_INFO "%s: SMSC LAN83C185 PHY\n", dev->name);
 
 	return 0;
 }
@@ -1104,8 +1146,11 @@
 			case MII_RTL8201_ID:		/* Realtek RTL8201: PHY_ID1 = 0, PHY_ID2 = 0x8201 */
 			case MII_BCM5221_ID:		/* Broadcom BCM5221: PHY_ID1 = 0x40, PHY_ID2 = 0x61e0 */
 			case MII_DP83847_ID:		/* National Semiconductor DP83847:  */
+			case MII_DP83848_ID:		/* National Semiconductor DP83848:  */
 			case MII_AC101L_ID:		/* Altima AC101L: PHY_ID1 = 0x22, PHY_ID2 = 0x5520 */
 			case MII_KS8721_ID:		/* Micrel KS8721: PHY_ID1 = 0x22, PHY_ID2 = 0x1610 */
+			case MII_T78Q21x3_ID:		/* Teridian 78Q21x3: PHY_ID1 = 0x0E, PHY_ID2 = 7237 */
+			case MII_LAN83C185_ID:		/* SMSC LAN83C185: PHY_ID1 = 0x0007, PHY_ID2 = 0xC0A1 */
 				detected = at91ether_setup(phy_id, phy_address, pdev, ether_clk);
 				break;
 		}
diff -urN linux-2.6.21.new/drivers/net/arm/at91_ether.h linux-2.6.21/drivers/net/arm/at91_ether.h
--- linux-2.6.21.new/drivers/net/arm/at91_ether.h	Thu Apr 26 05:08:32 2007
+++ linux-2.6.21/drivers/net/arm/at91_ether.h	Thu May  3 08:58:01 2007
@@ -17,39 +17,46 @@
 
 
 /* Davicom 9161 PHY */
-#define MII_DM9161_ID	0x0181b880
-#define MII_DM9161A_ID	0x0181b8a0
-
-/* Davicom specific registers */
-#define MII_DSCR_REG	16
-#define MII_DSCSR_REG	17
-#define MII_DSINTR_REG	21
+#define MII_DM9161_ID		0x0181b880
+#define MII_DM9161A_ID		0x0181b8a0
+#define MII_DSCR_REG		16
+#define MII_DSCSR_REG		17
+#define MII_DSINTR_REG		21
 
 /* Intel LXT971A PHY */
-#define MII_LXT971A_ID	0x001378E0
-
-/* Intel specific registers */
-#define MII_ISINTE_REG	18
-#define MII_ISINTS_REG	19
-#define MII_LEDCTRL_REG	20
+#define MII_LXT971A_ID		0x001378E0
+#define MII_ISINTE_REG		18
+#define MII_ISINTS_REG		19
+#define MII_LEDCTRL_REG		20
 
 /* Realtek RTL8201 PHY */
-#define MII_RTL8201_ID	0x00008200
+#define MII_RTL8201_ID		0x00008200
 
 /* Broadcom BCM5221 PHY */
-#define MII_BCM5221_ID	0x004061e0
-
-/* Broadcom specific registers */
-#define MII_BCMINTR_REG	26
+#define MII_BCM5221_ID		0x004061e0
+#define MII_BCMINTR_REG		26
 
 /* National Semiconductor DP83847 */
-#define MII_DP83847_ID	0x20005c30
+#define MII_DP83847_ID		0x20005c30
+
+/* National Semiconductor DP83848 */
+#define MII_DP83848_ID		0x20005c90
+#define MII_DPPHYSTS_REG	16
+#define MII_DPMICR_REG		17
+#define MII_DPMISR_REG		18
 
 /* Altima AC101L PHY */
-#define MII_AC101L_ID	0x00225520
+#define MII_AC101L_ID		0x00225520
 
 /* Micrel KS8721 PHY */
-#define MII_KS8721_ID	0x00221610
+#define MII_KS8721_ID		0x00221610
+
+/* Teridian 78Q2123/78Q2133 */
+#define MII_T78Q21x3_ID		0x000e7230
+#define MII_T78Q21INT_REG	17
+
+/* SMSC LAN83C185 */
+#define MII_LAN83C185_ID	0x0007C0A0
 
 /* ........................................................................ */
 




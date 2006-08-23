From: Jason Borg <jcborg@somanetworks.com>
Subject: [PATCH 5/5] smc911x: Fix a soft reset timeout on module reload
Date: Wed, 23 Aug 2006 15:16:50 -0400
Message-ID: <1156360610.15824.75.camel@borg.yyz.somanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: dustin@sensoria.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhost.somanetworks.com ([216.126.67.42]:930 "EHLO
	mail.somanetworks.com") by vger.kernel.org with ESMTP
	id S965124AbWHWTQw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 15:16:52 -0400
Received: from borg.yyz.somanetworks.com ([10.11.11.252])
          (envelope-sender <jcborg@somanetworks.com>)
          by mail.somanetworks.com (qmail-ldap-1.03) with SMTP
          for <netdev@vger.kernel.org>; 23 Aug 2006 19:16:50 -0000
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes a soft reset timeout that occurs when the driver is
built as a module and gets reloaded.  On module unload the
phy gets put into power down mode, on a reload the soft
reset fails if the internal phy is in power down mode.
Also put a fix in to revert to using the internal phy
if the search for an external phy failed.

Signed-off-by: Jason Borg <jcborg@somanetworks.com>
---

diff -uprN linux-2.6.18-rc4-orig/drivers/net/smc911x.c linux-2.6.18-rc4/drivers/net/smc911x.c
--- linux-2.6.18-rc4-orig/drivers/net/smc911x.c	2006-08-22 15:57:41.972128970 -0400
+++ linux-2.6.18-rc4/drivers/net/smc911x.c	2006-08-22 15:58:28.210813025 -0400
@@ -231,6 +231,86 @@ static void PRINT_PKT(u_char *buf, int l
 	spin_unlock_irqrestore(&lp->lock, __flags);	\
 } while (0)
 
+static void smc911x_connect_int_phy (struct net_device *dev)
+{
+	unsigned long ioaddr = dev->base_addr;
+	unsigned int cfg;
+
+	cfg = SMC_GET_HW_CFG();
+
+	cfg &= ~HW_CFG_PHY_CLK_SEL_;
+	cfg |= HW_CFG_PHY_CLK_SEL_CLK_DIS_;
+	SMC_SET_HW_CFG(cfg);
+	udelay(10); /* Wait for clocks to stop */
+
+	cfg &= ~HW_CFG_EXT_PHY_EN_;
+	SMC_SET_HW_CFG(cfg);
+	udelay(10); /* Wait for clocks to stop */
+
+	cfg &= ~HW_CFG_PHY_CLK_SEL_;
+	cfg |= HW_CFG_PHY_CLK_SEL_INT_PHY_;
+	SMC_SET_HW_CFG(cfg);
+	udelay(10); /* Wait for clocks to stop */
+
+	cfg &= ~HW_CFG_SMI_SEL_;
+	SMC_SET_HW_CFG(cfg);
+}
+
+static void smc911x_connect_ext_phy (struct net_device *dev)
+{
+	unsigned long ioaddr = dev->base_addr;
+	unsigned int cfg;
+
+	cfg = SMC_GET_HW_CFG();
+
+	cfg &= ~HW_CFG_PHY_CLK_SEL_;
+	cfg |= HW_CFG_PHY_CLK_SEL_CLK_DIS_;
+	SMC_SET_HW_CFG(cfg);
+	udelay(10); /* Wait for clocks to stop */
+
+	cfg |= HW_CFG_EXT_PHY_EN_;
+	SMC_SET_HW_CFG(cfg);
+	udelay(10); /* Wait for clocks to stop */
+
+	cfg &= ~HW_CFG_PHY_CLK_SEL_;
+	cfg |= HW_CFG_PHY_CLK_SEL_EXT_PHY_;
+	SMC_SET_HW_CFG(cfg);
+	udelay(10); /* Wait for clocks to stop */
+
+	cfg |= HW_CFG_SMI_SEL_;
+	SMC_SET_HW_CFG(cfg);
+}
+
+/*
+ * Called before doing a soft reset.  If the internal phy is in
+ * power down mode, the soft reset will fail and timeout.
+ * The internal phy being in power down mode will not prevent
+ * the Device Ready bit (bit 0) of the PMT_CONTROL register
+ * from reading 1 (device is ready), so a specific check must
+ * be carried out.
+ */
+static void smc911x_srst_phy_pdown_check(struct net_device *dev)
+{
+	unsigned long ioaddr = dev->base_addr;
+	unsigned int bmcr;
+
+	/*
+	 * Make sure the internal phy is connected, don't need to worry
+	 * about checking for and reconnecting the external phy if it
+	 * was connected, since the soft reset will clear the phy
+	 * selection bits anyway.
+	 */
+	smc911x_connect_int_phy(dev);
+
+	SMC_GET_PHY_BMCR(LAN911X_INTERNAL_PHY_ADDR, bmcr);
+
+	if (bmcr & BMCR_PDOWN) {
+		bmcr &= ~BMCR_PDOWN;
+		SMC_SET_PHY_BMCR(LAN911X_INTERNAL_PHY_ADDR, bmcr);
+		udelay(500); /* give it time to get up and running */
+	}
+}
+
 /*
  * this does a soft reset on the device
  */
@@ -258,6 +338,9 @@ static void smc911x_reset(struct net_dev
 		}
 	}
 
+	/* Ensure the internal phy is not in power down mode */
+	smc911x_srst_phy_pdown_check(dev);
+
 	/* Disable all interrupts */
 	spin_lock_irqsave(&lp->lock, flags);
 	SMC_SET_INT_EN(0);
@@ -755,22 +838,7 @@ static void smc911x_phy_detect(struct ne
 		case 0x117:
 			cfg = SMC_GET_HW_CFG();
 			if (cfg & HW_CFG_EXT_PHY_DET_) {
-				cfg &= ~HW_CFG_PHY_CLK_SEL_;
-				cfg |= HW_CFG_PHY_CLK_SEL_CLK_DIS_;
-				SMC_SET_HW_CFG(cfg);
-				udelay(10); /* Wait for clocks to stop */
-
-				cfg |= HW_CFG_EXT_PHY_EN_;
-				SMC_SET_HW_CFG(cfg);
-				udelay(10); /* Wait for clocks to stop */
-
-				cfg &= ~HW_CFG_PHY_CLK_SEL_;
-				cfg |= HW_CFG_PHY_CLK_SEL_EXT_PHY_;
-				SMC_SET_HW_CFG(cfg);
-				udelay(10); /* Wait for clocks to stop */
-
-				cfg |= HW_CFG_SMI_SEL_;
-				SMC_SET_HW_CFG(cfg);
+				smc911x_connect_ext_phy(dev);
 
 				for (phyaddr = 1; phyaddr < 32; ++phyaddr) {
 
@@ -788,13 +856,18 @@ static void smc911x_phy_detect(struct ne
 						break;
 					}
 				}
+
+				PRINTK ("%s: No external phy found, using internal\n", dev->name);
+                                
+				/* Revert to the internal phy settings */
+				smc911x_connect_int_phy(dev);
 			}
 		default:
 			/* Internal media only */
 			SMC_GET_PHY_ID1(1, id1);
 			SMC_GET_PHY_ID2(1, id2);
 			/* Save the PHY's address */
-			lp->mii.phy_id = 1;
+			lp->mii.phy_id = LAN911X_INTERNAL_PHY_ADDR;
 			lp->phy_type = id1 << 16 | id2;
 	}
 
diff -uprN linux-2.6.18-rc4-orig/drivers/net/smc911x.h linux-2.6.18-rc4/drivers/net/smc911x.h
--- linux-2.6.18-rc4-orig/drivers/net/smc911x.h	2006-08-22 12:02:50.000000000 -0400
+++ linux-2.6.18-rc4/drivers/net/smc911x.h	2006-08-22 16:21:24.951247991 -0400
@@ -596,6 +596,7 @@ smc_pxa_dma_outsw(struct device *dev, u_
 #define PHY_SPECIAL_SPD_100FULL_		((u16)0x0018)
 
 #define LAN911X_INTERNAL_PHY_ID		(0x0007C000)
+#define LAN911X_INTERNAL_PHY_ADDR	1
 
 /* Chip ID values */
 #define CHIP_9115	0x115



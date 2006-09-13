From: bora.sahin@ttnet.net.tr
Subject: [PATCH 8/12] smc911x: Fix external phy detect routine
Date: Wed, 13 Sep 2006 21:19:18 +0300
Message-ID: <200609132119.18888.bora.sahin@ttnet.net.tr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Dustin McIntire <dustin@sensoria.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ttnet.net.tr ([212.175.13.129]:22908 "EHLO
	fep03.ttnet.net.tr") by vger.kernel.org with ESMTP id S1751059AbWIMSfI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 14:35:08 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



9115-an1212.pdf, page 23 -> http://www.smsc.com/main/anpdf/an1212.pdf

"The existence of external PHYs is determined by reading 
the same two PHY registers at PHY addresses 0x02 through 0x30. If values of 
0xFFFF and 0xFFFF are obtained, there is no PHY at the given PHY address".

And according to the datasheet, waiting is needed when disabling clocks.

Signed-off-by: Bora Sahin <bora.sahin@ttnet.net.tr>

Index: linux-2.6.18-rc4/drivers/net/smc911x.c
===================================================================
--- linux-2.6.18-rc4.orig/drivers/net/smc911x.c	2006-08-06 21:20:11.000000000 +0300
+++ linux-2.6.18-rc4/drivers/net/smc911x.c	2006-09-04 13:54:26.621458832 +0300
@@ -725,7 +724,7 @@
 {
 	unsigned long ioaddr = dev->base_addr;
 
-	DBG(SMC_DEBUG_MISC, "%s: phyaddr=0x%x, phyreg=0x%x, phydata=0x%x\n",
+	DBG(SMC_DEBUG_MISC, "%s: phyaddr=0x%x, phyreg=0x%02x, phydata=0x%04x\n",
 		__FUNCTION__, phyaddr, phyreg, phydata);
 
 	SMC_SET_MII(phyreg, phyaddr, phydata);
@@ -748,7 +747,7 @@
 
 	/*
 	 * Scan all 32 PHY addresses if necessary, starting at
-	 * PHY#1 to PHY#31, and then PHY#0 last.
+	 * PHY#2 to PHY#30, and then PHY#0 last.
 	 */
 	switch(lp->version) {
 		case 0x115:
@@ -762,7 +761,6 @@
 
 				cfg |= HW_CFG_EXT_PHY_EN_;
 				SMC_SET_HW_CFG(cfg);
-				udelay(10); /* Wait for clocks to stop */
 
 				cfg &= ~HW_CFG_PHY_CLK_SEL_;
 				cfg |= HW_CFG_PHY_CLK_SEL_EXT_PHY_;
@@ -772,16 +770,14 @@
 				cfg |= HW_CFG_SMI_SEL_;
 				SMC_SET_HW_CFG(cfg);
 
-				for (phyaddr = 1; phyaddr < 32; ++phyaddr) {
+				for (phyaddr = 2; phyaddr < 30; ++phyaddr) {
 
 					/* Read the PHY identifiers */
 					SMC_GET_PHY_ID1(phyaddr & 31, id1);
 					SMC_GET_PHY_ID2(phyaddr & 31, id2);
 
 					/* Make sure it is a valid identifier */
-					if (id1 != 0x0000 && id1 != 0xffff &&
-					    id1 != 0x8000 && id2 != 0x0000 &&
-					    id2 != 0xffff && id2 != 0x8000) {
+					if (id1 != 0xffff && id2 != 0xffff) {
 						/* Save the PHY's address */
 						lp->mii.phy_id = phyaddr & 31;
 						lp->phy_type = id1 << 16 | id2;
@@ -798,7 +794,7 @@
 			lp->phy_type = id1 << 16 | id2;
 	}
 
-	DBG(SMC_DEBUG_MISC, "%s: phy_id1=0x%x, phy_id2=0x%x phyaddr=0x%d\n",
+	DBG(SMC_DEBUG_MISC, "%s: phy_id1=0x%x, phy_id2=0x%x phyaddr=%d\n",
 		dev->name, id1, id2, lp->mii.phy_id);
 }

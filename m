From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/6] sky2: workarounds for Yukon-2 supreme
Date: Thu, 29 Oct 2009 09:37:08 -0700
Message-ID: <20091029163849.423705149@vyatta.com>
References: <20091029163704.793246334@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57323 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755502AbZJ2QjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2009 12:39:23 -0400
Content-Disposition: inline; filename=sky2-supr2.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes related to support of Yukon supreme chip.
Don't have this chip version to test on,
these are reverse engineered from the vendor (GPL) driver.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sky2.c	2009-10-29 08:52:37.995315808 -0700
+++ b/drivers/net/sky2.c	2009-10-29 08:55:47.116003224 -0700
@@ -787,8 +787,7 @@ static void sky2_set_tx_stfwd(struct sky
 
 	if ( (hw->chip_id == CHIP_ID_YUKON_EX &&
 	      hw->chip_rev != CHIP_REV_YU_EX_A0) ||
-	     hw->chip_id == CHIP_ID_YUKON_FE_P ||
-	     hw->chip_id == CHIP_ID_YUKON_SUPR) {
+	     hw->chip_id >= CHIP_ID_YUKON_FE_P) {
 		/* Yukon-Extreme B0 and further Extreme devices */
 		/* enable Store & Forward mode for TX */
 
@@ -1404,6 +1403,31 @@ static int sky2_rx_start(struct sky2_por
 
 	/* Tell chip about available buffers */
 	sky2_rx_update(sky2, rxq);
+
+	if (hw->chip_id == CHIP_ID_YUKON_EX ||
+	    hw->chip_id == CHIP_ID_YUKON_SUPR) {
+		/*
+		 * Disable flushing of non ASF packets;
+		 * must be done after initializing the BMUs;
+		 * drivers without ASF support should do this too, otherwise
+		 * it may happen that they cannot run on ASF devices;
+		 * remember that the MAC FIFO isn't reset during initialization.
+		 */
+		sky2_write32(hw, SK_REG(sky2->port, RX_GMF_CTRL_T), RX_MACSEC_FLUSH_OFF);
+	}
+
+	if (hw->chip_id >= CHIP_ID_YUKON_SUPR) {
+		/* Enable RX Home Address & Routing Header checksum fix */
+		sky2_write16(hw, SK_REG(sky2->port, RX_GMF_FL_CTRL),
+			     RX_IPV6_SA_MOB_ENA | RX_IPV6_DA_MOB_ENA);
+
+		/* Enable TX Home Address & Routing Header checksum fix */
+		sky2_write32(hw, Q_ADDR(txqaddr[sky2->port], Q_TEST),
+			     TBMU_TEST_HOME_ADD_FIX_EN | TBMU_TEST_ROUTING_ADD_FIX_EN);
+	}
+
+
+
 	return 0;
 nomem:
 	sky2_rx_clean(sky2);
@@ -2993,6 +3017,12 @@ static void sky2_reset(struct sky2_hw *h
 			sky2_write16(hw, SK_REG(i, GMAC_CTRL),
 				     GMC_BYP_MACSECRX_ON | GMC_BYP_MACSECTX_ON
 				     | GMC_BYP_RETR_ON);
+
+	}
+
+	if (hw->chip_id == CHIP_ID_YUKON_SUPR && hw->chip_rev > CHIP_REV_YU_SU_B0) {
+		/* enable MACSec clock gating */
+		sky2_pci_write32(hw, PCI_DEV_REG3, P_CLK_MACSEC_DIS);
 	}
 
 	/* Clear I2C IRQ noise */

-- 


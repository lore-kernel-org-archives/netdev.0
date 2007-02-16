From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/6] sky2: flow control negotiation for Yukon-FE
Date: Thu, 15 Feb 2007 16:40:32 -0800
Message-ID: <20070216004141.980915000@linux-foundation.org>
References: <20070216004028.943889000@linux-foundation.org>
Cc: netdev@vger.kernel.org, sk-drivers@lists.linux-foundation.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40574 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422931AbXBPAnV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Feb 2007 19:43:21 -0500
Content-Disposition: inline; filename=sky2-fe-fc.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Yukon-FE chip doesn't do gigabit and has a differen PHY internally.
On this chip, phy status register doesn't properly reflect the result
of flow control negotiation. To workaround the problem and avoid having
to have so much chip dependent code; compute the result of flow control
by looking at the local and remote advertised bits.

Signed-off-by: Stephen Hemmminger <shemminger@linux-foundation.org>

--- sky2-dev.orig/drivers/net/sky2.c	2007-02-14 10:01:41.000000000 -0800
+++ sky2-dev/drivers/net/sky2.c	2007-02-14 13:32:00.000000000 -0800
@@ -1766,10 +1766,10 @@
 {
 	struct sky2_hw *hw = sky2->hw;
 	unsigned port = sky2->port;
-	u16 lpa;
+	u16 advert, lpa;
 
+	advert = gm_phy_read(hw, port, PHY_MARV_AUNE_ADV);
 	lpa = gm_phy_read(hw, port, PHY_MARV_AUNE_LP);
-
 	if (lpa & PHY_M_AN_RF) {
 		printk(KERN_ERR PFX "%s: remote fault", sky2->netdev->name);
 		return -1;
@@ -1784,20 +1784,40 @@
 	sky2->speed = sky2_phy_speed(hw, aux);
 	sky2->duplex = (aux & PHY_M_PS_FULL_DUP) ? DUPLEX_FULL : DUPLEX_HALF;
 
-	/* Pause bits are offset (9..8) */
-	if (hw->chip_id == CHIP_ID_YUKON_XL
-	    || hw->chip_id == CHIP_ID_YUKON_EC_U
-	    || hw->chip_id == CHIP_ID_YUKON_EX)
-		aux >>= 6;
-
-	sky2->flow_status = sky2_flow(aux & PHY_M_PS_RX_P_EN,
-				      aux & PHY_M_PS_TX_P_EN);
+	/* Since the pause result bits seem to in different positions on
+	 * different chips. look at registers.
+	 */
+	if (!sky2_is_copper(hw)) {
+		/* Shift for bits in fiber PHY */
+		advert &= ~(ADVERTISE_PAUSE_CAP|ADVERTISE_PAUSE_ASYM);
+		lpa &= ~(LPA_PAUSE_CAP|LPA_PAUSE_ASYM);
+
+		if (advert & ADVERTISE_1000XPAUSE)
+			advert |= ADVERTISE_PAUSE_CAP;
+		if (advert & ADVERTISE_1000XPSE_ASYM)
+			advert |= ADVERTISE_PAUSE_ASYM;
+		if (lpa & LPA_1000XPAUSE)
+			lpa |= LPA_PAUSE_CAP;
+		if (lpa & LPA_1000XPAUSE_ASYM)
+			lpa |= LPA_PAUSE_ASYM;
+	}
+
+	sky2->flow_status = FC_NONE;
+	if (advert & ADVERTISE_PAUSE_CAP) {
+		if (lpa & LPA_PAUSE_CAP)
+			sky2->flow_status = FC_BOTH;
+		else if (advert & ADVERTISE_PAUSE_ASYM)
+			sky2->flow_status = FC_RX;
+	} else if (advert & ADVERTISE_PAUSE_ASYM) {
+		if ((lpa & LPA_PAUSE_CAP) && (lpa & LPA_PAUSE_ASYM))
+			sky2->flow_status = FC_TX;
+	}
 
 	if (sky2->duplex == DUPLEX_HALF && sky2->speed < SPEED_1000
 	    && !(hw->chip_id == CHIP_ID_YUKON_EC_U || hw->chip_id == CHIP_ID_YUKON_EX))
 		sky2->flow_status = FC_NONE;
 
-	if (aux & PHY_M_PS_RX_P_EN)
+	if (sky2->flow_status & FC_TX)
 		sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_ON);
 	else
 		sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_OFF);

--
Stephen Hemminger <shemminger@linux-foundation.org>


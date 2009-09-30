From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/5] ixgbe: Fix backplane flow control autoneg
Date: Wed, 30 Sep 2009 15:07:38 -0700
Message-ID: <20090930220737.27479.88721.stgit@localhost.localdomain>
References: <20090930220705.27479.62694.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.westchester.pa.mail.comcast.net ([76.96.62.56]:40643
	"EHLO QMTA06.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754849AbZI3WIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 18:08:40 -0400
In-Reply-To: <20090930220705.27479.62694.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

Backplane flow control autonegotiation is currently broken for
ixgbe devices.  This patch fixes the flow control issues
with clause 37 autoneg.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82598.c  |    2 
 drivers/net/ixgbe/ixgbe_common.c |  228 ++++++++++++++++++++++++++++++--------
 drivers/net/ixgbe/ixgbe_type.h   |    9 ++
 3 files changed, 187 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 56b12f3..e2d5343 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -425,7 +425,7 @@ static s32 ixgbe_fc_enable_82598(struct ixgbe_hw *hw, s32 packetbuf_num)
 #endif /* CONFIG_DCB */
 	default:
 		hw_dbg(hw, "Flow control param set incorrectly\n");
-		ret_val = -IXGBE_ERR_CONFIG;
+		ret_val = IXGBE_ERR_CONFIG;
 		goto out;
 		break;
 	}
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 6621e17..143b0fc 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1663,7 +1663,7 @@ s32 ixgbe_fc_enable_generic(struct ixgbe_hw *hw, s32 packetbuf_num)
 #endif /* CONFIG_DCB */
 	default:
 		hw_dbg(hw, "Flow control param set incorrectly\n");
-		ret_val = -IXGBE_ERR_CONFIG;
+		ret_val = IXGBE_ERR_CONFIG;
 		goto out;
 		break;
 	}
@@ -1734,75 +1734,140 @@ s32 ixgbe_fc_autoneg(struct ixgbe_hw *hw)
 	s32 ret_val = 0;
 	ixgbe_link_speed speed;
 	u32 pcs_anadv_reg, pcs_lpab_reg, linkstat;
+	u32 links2, anlp1_reg, autoc_reg, links;
 	bool link_up;
 
 	/*
 	 * AN should have completed when the cable was plugged in.
 	 * Look for reasons to bail out.  Bail out if:
 	 * - FC autoneg is disabled, or if
-	 * - we don't have multispeed fiber, or if
-	 * - we're not running at 1G, or if
-	 * - link is not up, or if
-	 * - link is up but AN did not complete, or if
-	 * - link is up and AN completed but timed out
+	 * - link is not up.
 	 *
-	 * Since we're being called from an LSC, link is already know to be up.
+	 * Since we're being called from an LSC, link is already known to be up.
 	 * So use link_up_wait_to_complete=false.
 	 */
 	hw->mac.ops.check_link(hw, &speed, &link_up, false);
-	linkstat = IXGBE_READ_REG(hw, IXGBE_PCS1GLSTA);
-
-	if (hw->fc.disable_fc_autoneg ||
-	    !hw->phy.multispeed_fiber ||
-	    (speed != IXGBE_LINK_SPEED_1GB_FULL) ||
-	    !link_up ||
-	    ((linkstat & IXGBE_PCS1GLSTA_AN_COMPLETE) == 0) ||
-	    ((linkstat & IXGBE_PCS1GLSTA_AN_TIMED_OUT) == 1)) {
+
+	if (hw->fc.disable_fc_autoneg || (!link_up)) {
 		hw->fc.fc_was_autonegged = false;
 		hw->fc.current_mode = hw->fc.requested_mode;
-		hw_dbg(hw, "Autoneg FC was skipped.\n");
 		goto out;
 	}
 
 	/*
+	 * On backplane, bail out if
+	 * - backplane autoneg was not completed, or if
+	 * - link partner is not AN enabled
+	 */
+	if (hw->phy.media_type == ixgbe_media_type_backplane) {
+		links = IXGBE_READ_REG(hw, IXGBE_LINKS);
+		links2 = IXGBE_READ_REG(hw, IXGBE_LINKS2);
+		if (((links & IXGBE_LINKS_KX_AN_COMP) == 0) ||
+		    ((links2 & IXGBE_LINKS2_AN_SUPPORTED) == 0)) {
+			hw->fc.fc_was_autonegged = false;
+			hw->fc.current_mode = hw->fc.requested_mode;
+			goto out;
+		}
+	}
+
+	/*
+	 * On multispeed fiber at 1g, bail out if
+	 * - link is up but AN did not complete, or if
+	 * - link is up and AN completed but timed out
+	 */
+	if (hw->phy.multispeed_fiber && (speed == IXGBE_LINK_SPEED_1GB_FULL)) {
+		linkstat = IXGBE_READ_REG(hw, IXGBE_PCS1GLSTA);
+		if (((linkstat & IXGBE_PCS1GLSTA_AN_COMPLETE) == 0) ||
+		    ((linkstat & IXGBE_PCS1GLSTA_AN_TIMED_OUT) == 1)) {
+			hw->fc.fc_was_autonegged = false;
+			hw->fc.current_mode = hw->fc.requested_mode;
+			goto out;
+		}
+	}
+
+	/*
 	 * Read the AN advertisement and LP ability registers and resolve
 	 * local flow control settings accordingly
 	 */
-	pcs_anadv_reg = IXGBE_READ_REG(hw, IXGBE_PCS1GANA);
-	pcs_lpab_reg = IXGBE_READ_REG(hw, IXGBE_PCS1GANLP);
-	if ((pcs_anadv_reg & IXGBE_PCS1GANA_SYM_PAUSE) &&
-		(pcs_lpab_reg & IXGBE_PCS1GANA_SYM_PAUSE)) {
+	if ((speed == IXGBE_LINK_SPEED_1GB_FULL) &&
+	    (hw->phy.media_type != ixgbe_media_type_backplane)) {
+		pcs_anadv_reg = IXGBE_READ_REG(hw, IXGBE_PCS1GANA);
+		pcs_lpab_reg = IXGBE_READ_REG(hw, IXGBE_PCS1GANLP);
+		if ((pcs_anadv_reg & IXGBE_PCS1GANA_SYM_PAUSE) &&
+		    (pcs_lpab_reg & IXGBE_PCS1GANA_SYM_PAUSE)) {
+			/*
+			 * Now we need to check if the user selected Rx ONLY
+			 * of pause frames.  In this case, we had to advertise
+			 * FULL flow control because we could not advertise RX
+			 * ONLY. Hence, we must now check to see if we need to
+			 * turn OFF the TRANSMISSION of PAUSE frames.
+			 */
+			if (hw->fc.requested_mode == ixgbe_fc_full) {
+				hw->fc.current_mode = ixgbe_fc_full;
+				hw_dbg(hw, "Flow Control = FULL.\n");
+			} else {
+				hw->fc.current_mode = ixgbe_fc_rx_pause;
+				hw_dbg(hw, "Flow Control=RX PAUSE only\n");
+			}
+		} else if (!(pcs_anadv_reg & IXGBE_PCS1GANA_SYM_PAUSE) &&
+			   (pcs_anadv_reg & IXGBE_PCS1GANA_ASM_PAUSE) &&
+			   (pcs_lpab_reg & IXGBE_PCS1GANA_SYM_PAUSE) &&
+			   (pcs_lpab_reg & IXGBE_PCS1GANA_ASM_PAUSE)) {
+			hw->fc.current_mode = ixgbe_fc_tx_pause;
+			hw_dbg(hw, "Flow Control = TX PAUSE frames only.\n");
+		} else if ((pcs_anadv_reg & IXGBE_PCS1GANA_SYM_PAUSE) &&
+			   (pcs_anadv_reg & IXGBE_PCS1GANA_ASM_PAUSE) &&
+			   !(pcs_lpab_reg & IXGBE_PCS1GANA_SYM_PAUSE) &&
+			   (pcs_lpab_reg & IXGBE_PCS1GANA_ASM_PAUSE)) {
+			hw->fc.current_mode = ixgbe_fc_rx_pause;
+			hw_dbg(hw, "Flow Control = RX PAUSE frames only.\n");
+		} else {
+			hw->fc.current_mode = ixgbe_fc_none;
+			hw_dbg(hw, "Flow Control = NONE.\n");
+		}
+	}
+
+	if (hw->phy.media_type == ixgbe_media_type_backplane) {
 		/*
-		 * Now we need to check if the user selected Rx ONLY
-		 * of pause frames.  In this case, we had to advertise
-		 * FULL flow control because we could not advertise RX
-		 * ONLY. Hence, we must now check to see if we need to
-		 * turn OFF the TRANSMISSION of PAUSE frames.
+		 * Read the 10g AN autoc and LP ability registers and resolve
+		 * local flow control settings accordingly
 		 */
-		if (hw->fc.requested_mode == ixgbe_fc_full) {
-			hw->fc.current_mode = ixgbe_fc_full;
-			hw_dbg(hw, "Flow Control = FULL.\n");
-		} else {
+		autoc_reg = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+		anlp1_reg = IXGBE_READ_REG(hw, IXGBE_ANLP1);
+
+		if ((autoc_reg & IXGBE_AUTOC_SYM_PAUSE) &&
+		    (anlp1_reg & IXGBE_ANLP1_SYM_PAUSE)) {
+			/*
+			 * Now we need to check if the user selected Rx ONLY
+			 * of pause frames.  In this case, we had to advertise
+			 * FULL flow control because we could not advertise RX
+			 * ONLY. Hence, we must now check to see if we need to
+			 * turn OFF the TRANSMISSION of PAUSE frames.
+			 */
+			if (hw->fc.requested_mode == ixgbe_fc_full) {
+				hw->fc.current_mode = ixgbe_fc_full;
+				hw_dbg(hw, "Flow Control = FULL.\n");
+			} else {
+				hw->fc.current_mode = ixgbe_fc_rx_pause;
+				hw_dbg(hw, "Flow Control=RX PAUSE only\n");
+			}
+		} else if (!(autoc_reg & IXGBE_AUTOC_SYM_PAUSE) &&
+			   (autoc_reg & IXGBE_AUTOC_ASM_PAUSE) &&
+			   (anlp1_reg & IXGBE_ANLP1_SYM_PAUSE) &&
+			   (anlp1_reg & IXGBE_ANLP1_ASM_PAUSE)) {
+			hw->fc.current_mode = ixgbe_fc_tx_pause;
+			hw_dbg(hw, "Flow Control = TX PAUSE frames only.\n");
+		} else if ((autoc_reg & IXGBE_AUTOC_SYM_PAUSE) &&
+			   (autoc_reg & IXGBE_AUTOC_ASM_PAUSE) &&
+			   !(anlp1_reg & IXGBE_ANLP1_SYM_PAUSE) &&
+			   (anlp1_reg & IXGBE_ANLP1_ASM_PAUSE)) {
 			hw->fc.current_mode = ixgbe_fc_rx_pause;
 			hw_dbg(hw, "Flow Control = RX PAUSE frames only.\n");
+		} else {
+			hw->fc.current_mode = ixgbe_fc_none;
+			hw_dbg(hw, "Flow Control = NONE.\n");
 		}
-	} else if (!(pcs_anadv_reg & IXGBE_PCS1GANA_SYM_PAUSE) &&
-		   (pcs_anadv_reg & IXGBE_PCS1GANA_ASM_PAUSE) &&
-		   (pcs_lpab_reg & IXGBE_PCS1GANA_SYM_PAUSE) &&
-		   (pcs_lpab_reg & IXGBE_PCS1GANA_ASM_PAUSE)) {
-		hw->fc.current_mode = ixgbe_fc_tx_pause;
-		hw_dbg(hw, "Flow Control = TX PAUSE frames only.\n");
-	} else if ((pcs_anadv_reg & IXGBE_PCS1GANA_SYM_PAUSE) &&
-		   (pcs_anadv_reg & IXGBE_PCS1GANA_ASM_PAUSE) &&
-		   !(pcs_lpab_reg & IXGBE_PCS1GANA_SYM_PAUSE) &&
-		   (pcs_lpab_reg & IXGBE_PCS1GANA_ASM_PAUSE)) {
-		hw->fc.current_mode = ixgbe_fc_rx_pause;
-		hw_dbg(hw, "Flow Control = RX PAUSE frames only.\n");
-	} else {
-		hw->fc.current_mode = ixgbe_fc_none;
-		hw_dbg(hw, "Flow Control = NONE.\n");
 	}
-
 	/* Record that current_mode is the result of a successful autoneg */
 	hw->fc.fc_was_autonegged = true;
 
@@ -1919,7 +1984,7 @@ static s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num)
 #endif /* CONFIG_DCB */
 	default:
 		hw_dbg(hw, "Flow control param set incorrectly\n");
-		ret_val = -IXGBE_ERR_CONFIG;
+		ret_val = IXGBE_ERR_CONFIG;
 		goto out;
 		break;
 	}
@@ -1927,9 +1992,6 @@ static s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num)
 	IXGBE_WRITE_REG(hw, IXGBE_PCS1GANA, reg);
 	reg = IXGBE_READ_REG(hw, IXGBE_PCS1GLCTL);
 
-	/* Enable and restart autoneg to inform the link partner */
-	reg |= IXGBE_PCS1GLCTL_AN_ENABLE | IXGBE_PCS1GLCTL_AN_RESTART;
-
 	/* Disable AN timeout */
 	if (hw->fc.strict_ieee)
 		reg &= ~IXGBE_PCS1GLCTL_AN_1G_TIMEOUT_EN;
@@ -1937,6 +1999,70 @@ static s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num)
 	IXGBE_WRITE_REG(hw, IXGBE_PCS1GLCTL, reg);
 	hw_dbg(hw, "Set up FC; PCS1GLCTL = 0x%08X\n", reg);
 
+	/*
+	 * Set up the 10G flow control advertisement registers so the HW
+	 * can do fc autoneg once the cable is plugged in.  If we end up
+	 * using 1g instead, this is harmless.
+	 */
+	reg = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+
+	/*
+	 * The possible values of fc.requested_mode are:
+	 * 0: Flow control is completely disabled
+	 * 1: Rx flow control is enabled (we can receive pause frames,
+	 *    but not send pause frames).
+	 * 2: Tx flow control is enabled (we can send pause frames but
+	 *    we do not support receiving pause frames).
+	 * 3: Both Rx and Tx flow control (symmetric) are enabled.
+	 * other: Invalid.
+	 */
+	switch (hw->fc.requested_mode) {
+	case ixgbe_fc_none:
+		/* Flow control completely disabled by software override. */
+		reg &= ~(IXGBE_AUTOC_SYM_PAUSE | IXGBE_AUTOC_ASM_PAUSE);
+		break;
+	case ixgbe_fc_rx_pause:
+		/*
+		 * Rx Flow control is enabled and Tx Flow control is
+		 * disabled by software override. Since there really
+		 * isn't a way to advertise that we are capable of RX
+		 * Pause ONLY, we will advertise that we support both
+		 * symmetric and asymmetric Rx PAUSE.  Later, we will
+		 * disable the adapter's ability to send PAUSE frames.
+		 */
+		reg |= (IXGBE_AUTOC_SYM_PAUSE | IXGBE_AUTOC_ASM_PAUSE);
+		break;
+	case ixgbe_fc_tx_pause:
+		/*
+		 * Tx Flow control is enabled, and Rx Flow control is
+		 * disabled by software override.
+		 */
+		reg |= (IXGBE_AUTOC_ASM_PAUSE);
+		reg &= ~(IXGBE_AUTOC_SYM_PAUSE);
+		break;
+	case ixgbe_fc_full:
+		/* Flow control (both Rx and Tx) is enabled by SW override. */
+		reg |= (IXGBE_AUTOC_SYM_PAUSE | IXGBE_AUTOC_ASM_PAUSE);
+		break;
+#ifdef CONFIG_DCB
+	case ixgbe_fc_pfc:
+		goto out;
+		break;
+#endif /* CONFIG_DCB */
+	default:
+		hw_dbg(hw, "Flow control param set incorrectly\n");
+		ret_val = IXGBE_ERR_CONFIG;
+		goto out;
+		break;
+	}
+	/*
+	 * AUTOC restart handles negotiation of 1G and 10G. There is
+	 * no need to set the PCS1GCTL register.
+	 */
+	reg |= IXGBE_AUTOC_AN_RESTART;
+	IXGBE_WRITE_REG(hw, IXGBE_AUTOC, reg);
+	hw_dbg(hw, "Set up FC; IXGBE_AUTOC = 0x%08X\n", reg);
+
 out:
 	return ret_val;
 }
@@ -2000,7 +2126,7 @@ s32 ixgbe_acquire_swfw_sync(struct ixgbe_hw *hw, u16 mask)
 
 	while (timeout) {
 		if (ixgbe_get_eeprom_semaphore(hw))
-			return -IXGBE_ERR_SWFW_SYNC;
+			return IXGBE_ERR_SWFW_SYNC;
 
 		gssr = IXGBE_READ_REG(hw, IXGBE_GSSR);
 		if (!(gssr & (fwmask | swmask)))
@@ -2017,7 +2143,7 @@ s32 ixgbe_acquire_swfw_sync(struct ixgbe_hw *hw, u16 mask)
 
 	if (!timeout) {
 		hw_dbg(hw, "Driver can't access resource, GSSR timeout.\n");
-		return -IXGBE_ERR_SWFW_SYNC;
+		return IXGBE_ERR_SWFW_SYNC;
 	}
 
 	gssr |= swmask;
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 8761d78..7c93e92 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1336,6 +1336,8 @@
 #define IXGBE_AUTOC_KX4_SUPP    0x80000000
 #define IXGBE_AUTOC_KX_SUPP     0x40000000
 #define IXGBE_AUTOC_PAUSE       0x30000000
+#define IXGBE_AUTOC_ASM_PAUSE   0x20000000
+#define IXGBE_AUTOC_SYM_PAUSE   0x10000000
 #define IXGBE_AUTOC_RF          0x08000000
 #define IXGBE_AUTOC_PD_TMR      0x06000000
 #define IXGBE_AUTOC_AN_RX_LOOSE 0x01000000
@@ -1404,6 +1406,8 @@
 #define IXGBE_LINK_UP_TIME      90 /* 9.0 Seconds */
 #define IXGBE_AUTO_NEG_TIME     45 /* 4.5 Seconds */
 
+#define IXGBE_LINKS2_AN_SUPPORTED   0x00000040
+
 /* PCS1GLSTA Bit Masks */
 #define IXGBE_PCS1GLSTA_LINK_OK         1
 #define IXGBE_PCS1GLSTA_SYNK_OK         0x10
@@ -1424,6 +1428,11 @@
 #define IXGBE_PCS1GLCTL_AN_ENABLE       0x10000
 #define IXGBE_PCS1GLCTL_AN_RESTART      0x20000
 
+/* ANLP1 Bit Masks */
+#define IXGBE_ANLP1_PAUSE               0x0C00
+#define IXGBE_ANLP1_SYM_PAUSE           0x0400
+#define IXGBE_ANLP1_ASM_PAUSE           0x0800
+
 /* SW Semaphore Register bitmasks */
 #define IXGBE_SWSM_SMBI 0x00000001 /* Driver Semaphore bit */
 #define IXGBE_SWSM_SWESMBI 0x00000002 /* FW Semaphore bit */


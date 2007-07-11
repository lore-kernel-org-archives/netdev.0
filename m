From: "Michael Chan" <mchan@broadcom.com>
Subject: [2/5][TG3]: Fix the polarity bit.
Date: Wed, 11 Jul 2007 16:32:07 -0700
Message-ID: <1184196727.5211.9.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, mcarlson@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3413 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934416AbXGKWj6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2007 18:39:58 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Fix the polarity bit.

For most pre-5705 devices, multiple link interrupts were being generated
for a single physical link change.  The source of the interrupts was
determined to be unnecessary toggling of the MAC link polarity bit.

This patch changes the way the link polarity bit gets configured.  Where
possible, code that dynamically configures the bit in response to link
changes has been replaced by code that configures the bit once during
initialization time and then leaves the bit alone.

For correctness, this patch also limits the use of the bit to those
devices where it is defined, namely devices before the 5705.  This patch
also corrects the link polarity configurations for 5700 devices when
paired against a bcm5411 phy.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 314f5cf..1df129a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1162,6 +1162,19 @@ static void tg3_frob_aux_power(struct tg3 *tp)
 	}
 }
 
+static int tg3_5700_link_polarity(struct tg3 *tp, u32 speed)
+{
+	if (tp->led_ctrl == LED_CTRL_MODE_PHY_2)
+		return 1;
+	else if ((tp->phy_id & PHY_ID_MASK) == PHY_ID_BCM5411) {
+		if (speed != SPEED_10)
+			return 1;
+	} else if (speed == SPEED_10)
+		return 1;
+
+	return 0;
+}
+
 static int tg3_setup_phy(struct tg3 *, int);
 
 #define RESET_KIND_SHUTDOWN	0
@@ -1320,9 +1333,17 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 			else
 				mac_mode = MAC_MODE_PORT_MODE_MII;
 
-			if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5700 ||
-			    !(tp->tg3_flags & TG3_FLAG_WOL_SPEED_100MB))
-				mac_mode |= MAC_MODE_LINK_POLARITY;
+			mac_mode |= tp->mac_mode & MAC_MODE_LINK_POLARITY;
+			if (GET_ASIC_REV(tp->pci_chip_rev_id) ==
+			    ASIC_REV_5700) {
+				u32 speed = (tp->tg3_flags &
+					     TG3_FLAG_WOL_SPEED_100MB) ?
+					     SPEED_100 : SPEED_10;
+				if (tg3_5700_link_polarity(tp, speed))
+					mac_mode |= MAC_MODE_LINK_POLARITY;
+				else
+					mac_mode &= ~MAC_MODE_LINK_POLARITY;
+			}
 		} else {
 			mac_mode = MAC_MODE_PORT_MODE_TBI;
 		}
@@ -1990,15 +2011,12 @@ relink:
 	if (tp->link_config.active_duplex == DUPLEX_HALF)
 		tp->mac_mode |= MAC_MODE_HALF_DUPLEX;
 
-	tp->mac_mode &= ~MAC_MODE_LINK_POLARITY;
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700) {
-		if ((tp->led_ctrl == LED_CTRL_MODE_PHY_2) ||
-		    (current_link_up == 1 &&
-		     tp->link_config.active_speed == SPEED_10))
-			tp->mac_mode |= MAC_MODE_LINK_POLARITY;
-	} else {
-		if (current_link_up == 1)
+		if (current_link_up == 1 &&
+		    tg3_5700_link_polarity(tp, tp->link_config.active_speed))
 			tp->mac_mode |= MAC_MODE_LINK_POLARITY;
+		else
+			tp->mac_mode &= ~MAC_MODE_LINK_POLARITY;
 	}
 
 	/* ??? Without this setting Netgear GA302T PHY does not
@@ -2639,6 +2657,9 @@ static int tg3_setup_fiber_by_hand(struct tg3 *tp, u32 mac_status)
 
 		tw32_f(MAC_MODE, (tp->mac_mode | MAC_MODE_SEND_CONFIGS));
 		udelay(40);
+
+		tw32_f(MAC_MODE, tp->mac_mode);
+		udelay(40);
 	}
 
 out:
@@ -2698,10 +2719,6 @@ static int tg3_setup_fiber_phy(struct tg3 *tp, int force_reset)
 	else
 		current_link_up = tg3_setup_fiber_by_hand(tp, mac_status);
 
-	tp->mac_mode &= ~MAC_MODE_LINK_POLARITY;
-	tw32_f(MAC_MODE, tp->mac_mode);
-	udelay(40);
-
 	tp->hw_status->status =
 		(SD_STATUS_UPDATED |
 		 (tp->hw_status->status & ~SD_STATUS_LINK_CHG));
@@ -6444,6 +6461,10 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 
 	tp->mac_mode = MAC_MODE_TXSTAT_ENABLE | MAC_MODE_RXSTAT_ENABLE |
 		MAC_MODE_TDE_ENABLE | MAC_MODE_RDE_ENABLE | MAC_MODE_FHDE_ENABLE;
+	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS) &&
+	    !(tp->tg3_flags2 & TG3_FLG2_PHY_SERDES) &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5700)
+		tp->mac_mode |= MAC_MODE_LINK_POLARITY;
 	tw32_f(MAC_MODE, tp->mac_mode | MAC_MODE_RXSTAT_CLEAR | MAC_MODE_TXSTAT_CLEAR);
 	udelay(40);
 
@@ -8805,7 +8826,9 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 			return 0;
 
 		mac_mode = (tp->mac_mode & ~MAC_MODE_PORT_MODE_MASK) |
-			   MAC_MODE_PORT_INT_LPBACK | MAC_MODE_LINK_POLARITY;
+			   MAC_MODE_PORT_INT_LPBACK;
+		if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
+			mac_mode |= MAC_MODE_LINK_POLARITY;
 		if (tp->tg3_flags & TG3_FLAG_10_100_ONLY)
 			mac_mode |= MAC_MODE_PORT_MODE_MII;
 		else
@@ -8835,8 +8858,7 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 		tg3_writephy(tp, MII_BMCR, val);
 		udelay(40);
 
-		mac_mode = (tp->mac_mode & ~MAC_MODE_PORT_MODE_MASK) |
-			   MAC_MODE_LINK_POLARITY;
+		mac_mode = tp->mac_mode & ~MAC_MODE_PORT_MODE_MASK;
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
 			tg3_writephy(tp, MII_TG3_EPHY_PTEST, 0x1800);
 			mac_mode |= MAC_MODE_PORT_MODE_MII;
@@ -8849,8 +8871,11 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 			udelay(10);
 			tw32_f(MAC_RX_MODE, tp->rx_mode);
 		}
-		if ((tp->phy_id & PHY_ID_MASK) == PHY_ID_BCM5401) {
-			mac_mode &= ~MAC_MODE_LINK_POLARITY;
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700) {
+			if ((tp->phy_id & PHY_ID_MASK) == PHY_ID_BCM5401)
+				mac_mode &= ~MAC_MODE_LINK_POLARITY;
+			else if ((tp->phy_id & PHY_ID_MASK) == PHY_ID_BCM5411)
+				mac_mode |= MAC_MODE_LINK_POLARITY;
 			tg3_writephy(tp, MII_TG3_EXT_CTRL,
 				     MII_TG3_EXT_CTRL_LNK3_LED_MODE);
 		}



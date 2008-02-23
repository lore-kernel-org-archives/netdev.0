From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] sky2: fix LED management
Date: Fri, 22 Feb 2008 16:00:33 -0800
Message-ID: <20080222160033.79649405@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:58428 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758435AbYBWABa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2008 19:01:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix problems in LED management, so ethtool -p works correctly on Yukon-EC
and other chips. The driver was incorrectly setting the PHY LED overide bits.
Moral: read the spec sheet, not the vendor driver.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 drivers/net/sky2.c |   99 +++++++++++++++++------------------------------------
 drivers/net/sky2.h |   21 +++++------
 2 files changed, 44 insertions(+), 76 deletions(-)

--- a/drivers/net/sky2.h	2008-02-22 14:02:58.000000000 -0800
+++ b/drivers/net/sky2.h	2008-02-22 14:06:17.000000000 -0800
@@ -1318,18 +1318,21 @@ enum {
 	BLINK_670MS	= 4,/* 670 ms */
 };
 
-/**** PHY_MARV_LED_OVER    16 bit r/w LED control */
-enum {
-	PHY_M_LED_MO_DUP  = 3<<10,/* Bit 11..10:  Duplex */
-	PHY_M_LED_MO_10	  = 3<<8, /* Bit  9.. 8:  Link 10 */
-	PHY_M_LED_MO_100  = 3<<6, /* Bit  7.. 6:  Link 100 */
-	PHY_M_LED_MO_1000 = 3<<4, /* Bit  5.. 4:  Link 1000 */
-	PHY_M_LED_MO_RX	  = 3<<2, /* Bit  3.. 2:  Rx */
-	PHY_M_LED_MO_TX	  = 3<<0, /* Bit  1.. 0:  Tx */
-
-	PHY_M_LED_ALL	  = PHY_M_LED_MO_DUP | PHY_M_LED_MO_10 
-			    | PHY_M_LED_MO_100 | PHY_M_LED_MO_1000
-			    | PHY_M_LED_MO_RX,
+/*****  PHY_MARV_LED_OVER	16 bit r/w	Manual LED Override Reg *****/
+#define PHY_M_LED_MO_SGMII(x)	((x)<<14)	/* Bit 15..14:  SGMII AN Timer */
+
+#define PHY_M_LED_MO_DUP(x)	((x)<<10)	/* Bit 11..10:  Duplex */
+#define PHY_M_LED_MO_10(x)	((x)<<8)	/* Bit  9.. 8:  Link 10 */
+#define PHY_M_LED_MO_100(x)	((x)<<6)	/* Bit  7.. 6:  Link 100 */
+#define PHY_M_LED_MO_1000(x)	((x)<<4)	/* Bit  5.. 4:  Link 1000 */
+#define PHY_M_LED_MO_RX(x)	((x)<<2)	/* Bit  3.. 2:  Rx */
+#define PHY_M_LED_MO_TX(x)	((x)<<0)	/* Bit  1.. 0:  Tx */
+
+enum led_mode {
+	MO_LED_NORM  = 0,
+	MO_LED_BLINK = 1,
+	MO_LED_OFF   = 2,
+	MO_LED_ON    = 3,
 };
 
 /*****  PHY_MARV_EXT_CTRL_2	16 bit r/w	Ext. PHY Specific Ctrl 2 *****/
--- a/drivers/net/sky2.c	2008-02-22 10:51:13.000000000 -0800
+++ b/drivers/net/sky2.c	2008-02-22 15:46:18.000000000 -0800
@@ -572,8 +572,9 @@ static void sky2_phy_init(struct sky2_hw
 	default:
 		/* set Tx LED (LED_TX) to blink mode on Rx OR Tx activity */
 		ledctrl |= PHY_M_LED_BLINK_RT(BLINK_84MS) | PHY_M_LEDC_TX_CTRL;
+
 		/* turn off the Rx LED (LED_RX) */
-		ledover &= ~PHY_M_LED_MO_RX;
+		ledover |= PHY_M_LED_MO_RX(MO_LED_OFF);
 	}
 
 	if (hw->chip_id == CHIP_ID_YUKON_EC_U &&
@@ -602,7 +603,7 @@ static void sky2_phy_init(struct sky2_hw
 
 		if (sky2->autoneg == AUTONEG_DISABLE || sky2->speed == SPEED_100) {
 			/* turn on 100 Mbps LED (LED_LINK100) */
-			ledover |= PHY_M_LED_MO_100;
+			ledover |= PHY_M_LED_MO_100(MO_LED_ON);
 		}
 
 		if (ledover)
@@ -3322,82 +3323,80 @@ static void sky2_set_multicast(struct ne
 /* Can have one global because blinking is controlled by
  * ethtool and that is always under RTNL mutex
  */
-static void sky2_led(struct sky2_hw *hw, unsigned port, int on)
+static void sky2_led(struct sky2_port *sky2, enum led_mode mode)
 {
-	u16 pg;
+	struct sky2_hw *hw = sky2->hw;
+	unsigned port = sky2->port;
 
-	switch (hw->chip_id) {
-	case CHIP_ID_YUKON_XL:
+	spin_lock_bh(&sky2->phy_lock);
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U ||
+	    hw->chip_id == CHIP_ID_YUKON_EX ||
+	    hw->chip_id == CHIP_ID_YUKON_SUPR) {
+		u16 pg;
 		pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
 		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 3);
-		gm_phy_write(hw, port, PHY_MARV_PHY_CTRL,
-			     on ? (PHY_M_LEDC_LOS_CTRL(1) |
-				   PHY_M_LEDC_INIT_CTRL(7) |
-				   PHY_M_LEDC_STA1_CTRL(7) |
-				   PHY_M_LEDC_STA0_CTRL(7))
-			     : 0);
 
-		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, pg);
-		break;
+		switch (mode) {
+		case MO_LED_OFF:
+			gm_phy_write(hw, port, PHY_MARV_PHY_CTRL,
+				     PHY_M_LEDC_LOS_CTRL(8) |
+				     PHY_M_LEDC_INIT_CTRL(8) |
+				     PHY_M_LEDC_STA1_CTRL(8) |
+				     PHY_M_LEDC_STA0_CTRL(8));
+			break;
+		case MO_LED_ON:
+			gm_phy_write(hw, port, PHY_MARV_PHY_CTRL,
+				     PHY_M_LEDC_LOS_CTRL(9) |
+				     PHY_M_LEDC_INIT_CTRL(9) |
+				     PHY_M_LEDC_STA1_CTRL(9) |
+				     PHY_M_LEDC_STA0_CTRL(9));
+			break;
+		case MO_LED_BLINK:
+			gm_phy_write(hw, port, PHY_MARV_PHY_CTRL,
+				     PHY_M_LEDC_LOS_CTRL(0xa) |
+				     PHY_M_LEDC_INIT_CTRL(0xa) |
+				     PHY_M_LEDC_STA1_CTRL(0xa) |
+				     PHY_M_LEDC_STA0_CTRL(0xa));
+			break;
+		case MO_LED_NORM:
+			gm_phy_write(hw, port, PHY_MARV_PHY_CTRL,
+				     PHY_M_LEDC_LOS_CTRL(1) |
+				     PHY_M_LEDC_INIT_CTRL(8) |
+				     PHY_M_LEDC_STA1_CTRL(7) |
+				     PHY_M_LEDC_STA0_CTRL(7));
+		}
 
-	default:
-		gm_phy_write(hw, port, PHY_MARV_LED_CTRL, 0);
+		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, pg);
+	} else
 		gm_phy_write(hw, port, PHY_MARV_LED_OVER, 
-			     on ? PHY_M_LED_ALL : 0);
-	}
+				     PHY_M_LED_MO_DUP(mode) |
+				     PHY_M_LED_MO_10(mode) |
+				     PHY_M_LED_MO_100(mode) |
+				     PHY_M_LED_MO_1000(mode) |
+				     PHY_M_LED_MO_RX(mode) |
+				     PHY_M_LED_MO_TX(mode));
+
+	spin_unlock_bh(&sky2->phy_lock);
 }
 
 /* blink LED's for finding board */
 static int sky2_phys_id(struct net_device *dev, u32 data)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
-	struct sky2_hw *hw = sky2->hw;
-	unsigned port = sky2->port;
-	u16 ledctrl, ledover = 0;
-	long ms;
-	int interrupted;
-	int onoff = 1;
+	unsigned int i;
 
-	if (!data || data > (u32) (MAX_SCHEDULE_TIMEOUT / HZ))
-		ms = jiffies_to_msecs(MAX_SCHEDULE_TIMEOUT);
-	else
-		ms = data * 1000;
-
-	/* save initial values */
-	spin_lock_bh(&sky2->phy_lock);
-	if (hw->chip_id == CHIP_ID_YUKON_XL) {
-		u16 pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
-		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 3);
-		ledctrl = gm_phy_read(hw, port, PHY_MARV_PHY_CTRL);
-		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, pg);
-	} else {
-		ledctrl = gm_phy_read(hw, port, PHY_MARV_LED_CTRL);
-		ledover = gm_phy_read(hw, port, PHY_MARV_LED_OVER);
-	}
-
-	interrupted = 0;
-	while (!interrupted && ms > 0) {
-		sky2_led(hw, port, onoff);
-		onoff = !onoff;
-
-		spin_unlock_bh(&sky2->phy_lock);
-		interrupted = msleep_interruptible(250);
-		spin_lock_bh(&sky2->phy_lock);
-
-		ms -= 250;
-	}
+	if (data == 0)
+		data = UINT_MAX;
 
-	/* resume regularly scheduled programming */
-	if (hw->chip_id == CHIP_ID_YUKON_XL) {
-		u16 pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
-		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 3);
-		gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, ledctrl);
-		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, pg);
-	} else {
-		gm_phy_write(hw, port, PHY_MARV_LED_CTRL, ledctrl);
-		gm_phy_write(hw, port, PHY_MARV_LED_OVER, ledover);
+	for (i = 0; i < data; i++) {
+		sky2_led(sky2, MO_LED_ON);
+		if (msleep_interruptible(500))
+			break;
+		sky2_led(sky2, MO_LED_OFF);
+		if (msleep_interruptible(500))
+			break;
 	}
-	spin_unlock_bh(&sky2->phy_lock);
+	sky2_led(sky2, MO_LED_NORM);
 
 	return 0;
 }

From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH 2/2 next] sky2: B0_Y2LED controls the LEDs for both ports
Date: Sun, 30 Aug 2009 12:58:46 +0900
Message-ID: <4A99F8F6.6040903@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Rene Mayrhofer <rene@mayrhofer.eu.org>,
	Richard Leitner <leitner@esys.at>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f204.google.com ([209.85.223.204]:47449 "EHLO
	mail-iw0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750817AbZH3ECi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 00:02:38 -0400
Received: by iwn42 with SMTP id 42so1408816iwn.33
        for <netdev@vger.kernel.org>; Sat, 29 Aug 2009 21:02:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only disable LED status control when both ports are disabled.
The previous code disabled LED status control unconditionally
 in sky2_down.

Tested with the limitation that my sky2 interface has no LEDs
 and a single port.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |   23 ++++++++++++++++++++---
 1 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 2827f0d..864b8dc 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -213,6 +213,22 @@ static inline u16 gm_phy_read(struct sky2_hw *hw, unsigned port, u16 reg)
 	return v;
 }
 
+static void sky2_disable_status_led(struct sky2_port *sky2)
+{
+	struct sky2_hw *hw = sky2->hw;
+	struct net_device *otherdev = hw->dev[sky2->port^1];
+
+	if (!(otherdev && netif_running(otherdev))) {
+		sky2_write8(hw, B0_Y2LED, LED_STAT_OFF);
+	}
+}
+
+static void sky2_enable_status_led(struct sky2_port *sky2)
+{
+	struct sky2_hw *hw = sky2->hw;
+
+	sky2_write8(hw, B0_Y2LED, LED_STAT_ON);
+}
 
 static void sky2_power_on(struct sky2_hw *hw)
 {
@@ -1530,6 +1546,8 @@ static int sky2_up(struct net_device *dev)
 	if (err)
 		goto err_out;
 
+	sky2_enable_status_led(sky2);
+
 	/* Enable interrupts from phy/mac for port */
 	imask = sky2_read32(hw, B0_IMSK);
 	imask |= portirq_msk[port];
@@ -1886,8 +1904,7 @@ static int sky2_down(struct net_device *dev)
 	sky2_phy_power_down(hw, port);
 	spin_unlock_bh(&sky2->phy_lock);
 
-	/* turn off LED's */
-	sky2_write16(hw, B0_Y2LED, LED_STAT_OFF);
+	sky2_disable_status_led(sky2);
 
 	sky2_tx_reset(hw, port);
 
@@ -2989,7 +3006,7 @@ static void sky2_reset(struct sky2_hw *hw)
 	sky2_write8(hw, B2_TI_CTRL, TIM_STOP);
 	sky2_write8(hw, B2_TI_CTRL, TIM_CLR_IRQ);
 
-	sky2_write8(hw, B0_Y2LED, LED_STAT_ON);
+	sky2_write8(hw, B0_Y2LED, LED_STAT_OFF);
 
 	/* Turn off descriptor polling */
 	sky2_write32(hw, B28_DPT_CTRL, DPT_STOP);
-- 
1.5.6.5


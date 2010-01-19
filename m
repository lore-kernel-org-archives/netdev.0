From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH] sky2: Enable/disable WOL per hardware device
Date: Tue, 19 Jan 2010 23:11:26 +0900
Message-ID: <4B55BD8E.2040705@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:46341 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750943Ab0ASOPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 09:15:49 -0500
Received: by pwj9 with SMTP id 9so2407186pwj.21
        for <netdev@vger.kernel.org>; Tue, 19 Jan 2010 06:15:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Y2_HW_WOL_ON/Y2_HW_WOL_OFF should be set and cleared per chip,
not per port.  On dual port cards, Y2_HW_WOL_ON should be
enabled if either sky2 port has WOL enabled.

Found while reviewing code for a WOL regression, though this is
probably not the cause of the regression.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |   29 ++++++++++++++++++++++-------
 1 files changed, 22 insertions(+), 7 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 4c06020..d86b7e8 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -3238,6 +3238,27 @@ static inline u8 sky2_wol_supported(const struct sky2_hw *hw)
 	return sky2_is_copper(hw) ? (WAKE_PHY | WAKE_MAGIC) : 0;
 }
 
+static void sky2_hw_set_wol(struct sky2_hw *hw)
+{
+	int wol = 0;
+	int i;
+
+	for (i = 0; i < hw->ports; i++) {
+		struct net_device *dev = hw->dev[i];
+		struct sky2_port *sky2 = netdev_priv(dev);
+
+		if (sky2->wol)
+			wol = 1;
+	}
+
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U ||
+	    hw->chip_id == CHIP_ID_YUKON_EX ||
+	    hw->chip_id == CHIP_ID_YUKON_FE_P)
+		sky2_write32(hw, B0_CTST, wol ? Y2_HW_WOL_ON : Y2_HW_WOL_OFF);
+
+	device_set_wakeup_enable(&hw->pdev->dev, wol);
+}
+
 static void sky2_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	const struct sky2_port *sky2 = netdev_priv(dev);
@@ -3257,13 +3278,7 @@ static int sky2_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 
 	sky2->wol = wol->wolopts;
 
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U ||
-	    hw->chip_id == CHIP_ID_YUKON_EX ||
-	    hw->chip_id == CHIP_ID_YUKON_FE_P)
-		sky2_write32(hw, B0_CTST, sky2->wol
-			     ? Y2_HW_WOL_ON : Y2_HW_WOL_OFF);
-
-	device_set_wakeup_enable(&hw->pdev->dev, sky2->wol);
+	sky2_hw_set_wol(hw);
 
 	if (!netif_running(dev))
 		sky2_wol_init(sky2);
-- 
1.5.6.5


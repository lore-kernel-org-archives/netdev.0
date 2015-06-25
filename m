From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net PATCH 1/1] net: phy: fix phy link up when limiting speed via device tree
Date: Thu, 25 Jun 2015 22:21:02 +0530
Message-ID: <1435251062-5287-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <f.fainelli@gmail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:59824 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751197AbbFYQvK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jun 2015 12:51:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When limiting phy link speed using "max-speed" to 100mbps or less on a
giga bit phy, phy never completes auto negotiation and phy state
machine is held in PHY_AN. Fixing this issue by comparing the giga
bit advertise though phydev->supported doesn't have it but phy has
BMSR_ESTATEN set. So that auto negotiation is restarted as old and
new advertise are different and link comes up fine.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/phy/phy_device.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index bdfe51f..d551df6 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -796,10 +796,11 @@ static int genphy_config_advert(struct phy_device *phydev)
 	if (phydev->supported & (SUPPORTED_1000baseT_Half |
 				 SUPPORTED_1000baseT_Full)) {
 		adv |= ethtool_adv_to_mii_ctrl1000_t(advertise);
-		if (adv != oldadv)
-			changed = 1;
 	}
 
+	if (adv != oldadv)
+		changed = 1;
+
 	err = phy_write(phydev, MII_CTRL1000, adv);
 	if (err < 0)
 		return err;
-- 
2.4.4.409.g5b1d901

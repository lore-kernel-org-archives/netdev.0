From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 6/9] net: mv643xx_eth: use phy_init_hw to reset PHY
Date: Thu, 5 Dec 2013 16:55:14 -0800
Message-ID: <1386291317-1202-7-git-send-email-f.fainelli@gmail.com>
References: <1386291317-1202-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <sebastian.hesselbarth@gmail.com>,
	<sergei.shtylyov@cogentembedded.com>, <afleming@gmail.com>,
	<kyle@moffetthome.net>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:64935 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752295Ab3LFBFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 20:05:01 -0500
In-Reply-To: <1386291317-1202-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of open-coding a PHY reset through the MII BMCR register, use
phy_init_hw() which does that for us and will also make sure that PHY
fixups are applied if required.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c | 21 +--------------------
 1 file changed, 1 insertion(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 61088a6..8d9bb6b 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -2067,23 +2067,6 @@ static inline void oom_timer_wrapper(unsigned long data)
 	napi_schedule(&mp->napi);
 }
 
-static void phy_reset(struct mv643xx_eth_private *mp)
-{
-	int data;
-
-	data = phy_read(mp->phy, MII_BMCR);
-	if (data < 0)
-		return;
-
-	data |= BMCR_RESET;
-	if (phy_write(mp->phy, MII_BMCR, data) < 0)
-		return;
-
-	do {
-		data = phy_read(mp->phy, MII_BMCR);
-	} while (data >= 0 && data & BMCR_RESET);
-}
-
 static void port_start(struct mv643xx_eth_private *mp)
 {
 	u32 pscr;
@@ -2096,7 +2079,7 @@ static void port_start(struct mv643xx_eth_private *mp)
 		struct ethtool_cmd cmd;
 
 		mv643xx_eth_get_settings(mp->dev, &cmd);
-		phy_reset(mp);
+		phy_init_hw(mp);
 		mv643xx_eth_set_settings(mp->dev, &cmd);
 	}
 
@@ -2764,8 +2747,6 @@ static void phy_init(struct mv643xx_eth_private *mp, int speed, int duplex)
 {
 	struct phy_device *phy = mp->phy;
 
-	phy_reset(mp);
-
 	if (speed == 0) {
 		phy->autoneg = AUTONEG_ENABLE;
 		phy->speed = 0;
-- 
1.8.3.2

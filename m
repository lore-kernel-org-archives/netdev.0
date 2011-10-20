From: Kyle Moffett <Kyle.D.Moffett@boeing.com>
Subject: [RFC PATCH 09/17] mv643xx_eth: Use standardized phy_init_hw() for PHY reset
Date: Thu, 20 Oct 2011 17:00:16 -0400
Message-ID: <1319144425-15547-10-git-send-email-Kyle.D.Moffett@boeing.com>
References: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
Cc: Kyle Moffett <Kyle.D.Moffett@boeing.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PHY does not need to be reset immediately before phy_attach(), as
that function will call phy_init_hw() properly on its own.  Furthermore,
the PHY should not be manually reset, as that will undo board-specific
PHY fixups and driver-specific phy->drv->config_init() register tweaks.

NOTE: Depends on earlier phy_init_hw() patch.

Not-yet-Signed-off-by: Kyle Moffett <Kyle.D.Moffett@boeing.com>
---
 drivers/net/mv643xx_eth.c |   22 +---------------------
 1 files changed, 1 insertions(+), 21 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 2596999..d3e223c 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2188,23 +2188,6 @@ static inline void oom_timer_wrapper(unsigned long data)
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
@@ -2217,7 +2200,7 @@ static void port_start(struct mv643xx_eth_private *mp)
 		struct ethtool_cmd cmd;
 
 		mv643xx_eth_get_settings(mp->dev, &cmd);
-		phy_reset(mp);
+		phy_init_hw(mp->phy);
 		mv643xx_eth_set_settings(mp->dev, &cmd);
 	}
 
@@ -2779,9 +2762,6 @@ static struct phy_device *phy_scan(struct mv643xx_eth_private *mp,
 static void phy_init(struct mv643xx_eth_private *mp, int speed, int duplex)
 {
 	struct phy_device *phy = mp->phy;
-
-	phy_reset(mp);
-
 	phy_attach(mp->dev, dev_name(&phy->dev), 0, PHY_INTERFACE_MODE_GMII);
 
 	if (speed == 0) {
-- 
1.7.2.5

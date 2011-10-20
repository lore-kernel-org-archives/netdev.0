From: Kyle Moffett <Kyle.D.Moffett@boeing.com>
Subject: [RFC PATCH 10/17] pxa186_eth: Use standardized phy_init_hw() for PHY reset
Date: Thu, 20 Oct 2011 17:00:17 -0400
Message-ID: <1319144425-15547-11-git-send-email-Kyle.D.Moffett@boeing.com>
References: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
Cc: Kyle Moffett <Kyle.D.Moffett@boeing.com>,
	"David S. Miller" <davem@davemloft.net>,
	Richard Cochran <richard.cochran@omicron.at>,
	Joe Perches <joe@perches.com>, Jon Mason <jdmason@kudzu.us>
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
 drivers/net/pxa168_eth.c |   21 +--------------------
 1 files changed, 1 insertions(+), 20 deletions(-)

diff --git a/drivers/net/pxa168_eth.c b/drivers/net/pxa168_eth.c
index d17d062..ab3bca9 100644
--- a/drivers/net/pxa168_eth.c
+++ b/drivers/net/pxa168_eth.c
@@ -323,23 +323,6 @@ static void ethernet_phy_set_addr(struct pxa168_eth_private *pep, int phy_addr)
 	wrl(pep, PHY_ADDRESS, reg_data);
 }
 
-static void ethernet_phy_reset(struct pxa168_eth_private *pep)
-{
-	int data;
-
-	data = phy_read(pep->phy, MII_BMCR);
-	if (data < 0)
-		return;
-
-	data |= BMCR_RESET;
-	if (phy_write(pep->phy, MII_BMCR, data) < 0)
-		return;
-
-	do {
-		data = phy_read(pep->phy, MII_BMCR);
-	} while (data >= 0 && data & BMCR_RESET);
-}
-
 static void rxq_refill(struct net_device *dev)
 {
 	struct pxa168_eth_private *pep = netdev_priv(dev);
@@ -647,7 +630,7 @@ static void eth_port_start(struct net_device *dev)
 		struct ethtool_cmd cmd;
 
 		pxa168_get_settings(pep->dev, &cmd);
-		ethernet_phy_reset(pep);
+		phy_init_hw(pep->phy);
 		pxa168_set_settings(pep->dev, &cmd);
 	}
 
@@ -1393,8 +1376,6 @@ static struct phy_device *phy_scan(struct pxa168_eth_private *pep, int phy_addr)
 static void phy_init(struct pxa168_eth_private *pep, int speed, int duplex)
 {
 	struct phy_device *phy = pep->phy;
-	ethernet_phy_reset(pep);
-
 	phy_attach(pep->dev, dev_name(&phy->dev), 0, PHY_INTERFACE_MODE_MII);
 
 	if (speed == 0) {
-- 
1.7.2.5

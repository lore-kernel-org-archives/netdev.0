From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH -next v2] net: bfin_mac: Fix build error due to missed API change
Date: Sun, 10 Jan 2016 07:08:04 -0800
Message-ID: <1452438484-29205-1-git-send-email-linux@roeck-us.net>
Cc: =adi-buildroot-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 7f854420fbfe ("phy: Add API for {un}registering an mdio device to
a bus") introduces an API to access mii_bus structures, but missed to
update the bfin_mac driver. This results in the following error message

drivers/net/ethernet/adi/bfin_mac.c: In function 'mii_probe':
drivers/net/ethernet/adi/bfin_mac.c:401:52: error:
	'struct mii_bus' has no member named 'phy_map'

Use phy_find_first() instead of open-coding it.

Fixes: 7f854420fbfe ("phy: Add API for {un}registering an mdio device to a bus")
Cc: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
v2: Use phy_find_first() instead of open-coding it.

Dave: Please ignore if you already applied the other patch.
      Alternatively, I'll be happy to submit it as separate patch
      on top of the actual bug fix.

 drivers/net/ethernet/adi/bfin_mac.c | 16 ++--------------
 1 file changed, 2 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index 8c5132624510..5dfa01fadda6 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -380,9 +380,8 @@ static void bfin_mac_adjust_link(struct net_device *dev)
 static int mii_probe(struct net_device *dev, int phy_mode)
 {
 	struct bfin_mac_local *lp = netdev_priv(dev);
-	struct phy_device *phydev = NULL;
+	struct phy_device *phydev;
 	unsigned short sysctl;
-	int i;
 	u32 sclk, mdc_div;
 
 	/* Enable PHY output early */
@@ -396,18 +395,7 @@ static int mii_probe(struct net_device *dev, int phy_mode)
 	sysctl = (sysctl & ~MDCDIV) | SET_MDCDIV(mdc_div);
 	bfin_write_EMAC_SYSCTL(sysctl);
 
-	/* search for connected PHY device */
-	for (i = 0; i < PHY_MAX_ADDR; ++i) {
-		struct phy_device *const tmp_phydev = lp->mii_bus->phy_map[i];
-
-		if (!tmp_phydev)
-			continue; /* no PHY here... */
-
-		phydev = tmp_phydev;
-		break; /* found it */
-	}
-
-	/* now we are supposed to have a proper phydev, to attach to... */
+	phydev = phy_find_first(lp->mii_bus);
 	if (!phydev) {
 		netdev_err(dev, "no phy device found\n");
 		return -ENODEV;
-- 
2.1.4

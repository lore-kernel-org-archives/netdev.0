From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: xgene: fix backward compatibility fix
Date: Mon, 29 Aug 2016 14:37:14 +0200
Message-ID: <20160829123740.3336010-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Iyappan Subramanian <isubramanian@apm.com>,
        Keyur Chudgar <kchudgar@apm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A bugfix for backward compatibility handling introduced undefined
behavior for the case that of_parse_phandle() does not return
a valid entry, as "gcc -Wmaybe-unused" reports:

drivers/net/ethernet/apm/xgene/xgene_enet_hw.c: In function 'xgene_enet_phy_connect':
drivers/net/ethernet/apm/xgene/xgene_enet_hw.c:776:6: error: 'phy_dev' may be used uninitialized in this function [-Werror=maybe-uninitialized]
drivers/net/ethernet/apm/xgene/xgene_enet_hw.c: In function 'xgene_enet_mdio_config':
drivers/net/ethernet/apm/xgene/xgene_enet_hw.c:776:6: error: 'phy_dev' may be used uninitialized in this function [-Werror=maybe-uninitialized]

We can work around this by removing the check for zero "np", as
of_phy_connect() will correctly handle a NULL argument so we fall
back into the normal error handling case.

Note that I had previously fixed another bug that resulted in the
exact same warning, but this is a different problem that was
introduced after my original fix.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 03377e381bf4 ("drivers: net: xgene: Fix backward compatibility")
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 321fb197621e..da413c8d3e19 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -761,10 +761,6 @@ int xgene_enet_phy_connect(struct net_device *ndev)
 	if (dev->of_node) {
 		for (i = 0 ; i < 2; i++) {
 			np = of_parse_phandle(dev->of_node, "phy-handle", i);
-
-			if (!np)
-				continue;
-
 			phy_dev = of_phy_connect(ndev, np,
 						 &xgene_enet_adjust_link,
 						 0, pdata->phy_mode);
-- 
2.9.0

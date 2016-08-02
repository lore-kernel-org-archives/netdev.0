From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: xgene: fix maybe-uninitialized variable
Date: Tue,  2 Aug 2016 12:23:29 +0200
Message-ID: <20160802102348.81986-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>,
	Tanmay Inamdar <tinamdar@apm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Iyappan Subramanian <isubramanian@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:59447 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbcHBKYl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2016 06:24:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Building with -Wmaybe-uninitialized shows a potential use of
an uninitialized variable:

drivers/net/ethernet/apm/xgene/xgene_enet_hw.c: In function 'xgene_enet_phy_connect':
drivers/net/ethernet/apm/xgene/xgene_enet_hw.c:802:23: warning: 'phy_dev' may be used uninitialized in this function [-Wmaybe-uninitialized]

Although the compiler correctly identified this based on the function,
the current code is still safe as long dev->of_node is non-NULL
for the case of CONFIG_ACPI=n, which is currently the case.

The warning is now disabled by default, but still appears when
building with W=1, and other build test tools should be able to
detect it as well. Adding an #else clause here makes the code
more robust and makes it clear to the compiler that this cannot
happen.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 8089a96f601b ("drivers: net: xgene: Add backward compatibility")
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 7714b7d4026a..98779fe2d558 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -792,6 +792,8 @@ int xgene_enet_phy_connect(struct net_device *ndev)
 			netdev_err(ndev, "Could not connect to PHY\n");
 			return  -ENODEV;
 		}
+#else
+		return -ENODEV;
 #endif
 	}
 
-- 
2.9.0

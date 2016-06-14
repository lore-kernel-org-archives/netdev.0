From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mdio: mux: avoid 'maybe-uninitialized' warning
Date: Tue, 14 Jun 2016 12:03:17 +0200
Message-ID: <1465898632-2248093-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Pramod Kumar <pramod.kumar@broadcom.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.135]:56808 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371AbcFNKCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 06:02:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The latest changes to the MDIO code introduced a false-positive
warning with gcc-6 (possibly others):

drivers/net/phy/mdio-mux.c: In function 'mdio_mux_init':
drivers/net/phy/mdio-mux.c:188:3: error: 'parent_bus_node' may be used uninitialized in this function [-Werror=maybe-uninitialized]

It's easy to avoid the warning by making sure the parent_bus_node
is initialized in both cases at the start of the function, since
the later 'of_node_put()' call is also valid for a NULL pointer
argument.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: f20e6657a875 ("mdio: mux: Enhanced MDIO mux framework for integrated multiplexers")
---
 drivers/net/phy/mdio-mux.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/mdio-mux.c b/drivers/net/phy/mdio-mux.c
index dbd4ecc205dc..963838d4fac1 100644
--- a/drivers/net/phy/mdio-mux.c
+++ b/drivers/net/phy/mdio-mux.c
@@ -115,6 +115,7 @@ int mdio_mux_init(struct device *dev,
 			goto err_parent_bus;
 		}
 	} else {
+		parent_bus_node = NULL;
 		parent_bus = mux_bus;
 	}
 
@@ -184,8 +185,7 @@ int mdio_mux_init(struct device *dev,
 	put_device(&pb->mii_bus->dev);
 
 err_parent_bus:
-	if (!mux_bus)
-		of_node_put(parent_bus_node);
+	of_node_put(parent_bus_node);
 	return ret_val;
 }
 EXPORT_SYMBOL_GPL(mdio_mux_init);
-- 
2.7.0

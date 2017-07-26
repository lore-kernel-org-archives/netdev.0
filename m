From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 1/2] net: phy: rework Kconfig settings for MDIO_BUS
Date: Wed, 26 Jul 2017 17:13:59 +0200
Message-ID: <20170726151442.3913622-1-arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org,
        Raviteja Garimella <raviteja.garimella@broadcom.com>,
        Arnd Bergmann <arnd@arndb.de>,
        Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: netdev@vger.kernel.org, Kishon Vijay Abraham I <kishon@ti.com>,
        "David S . Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I still see build errors in randconfig builds and have had this
patch for a while to locally work around it:

drivers/built-in.o: In function `xgene_mdio_probe':
mux-core.c:(.text+0x352154): undefined reference to `of_mdiobus_register'
mux-core.c:(.text+0x352168): undefined reference to `mdiobus_free'
mux-core.c:(.text+0x3521c0): undefined reference to `mdiobus_alloc_size'

The idea is that CONFIG_MDIO_BUS now reflects whether the mdio_bus
code is built-in or a module, and other drivers that use the core
code can simply depend on that, instead of having a complex
dependency line.

Fixes: 90eff9096c01 ("net: phy: Allow splitting MDIO bus/device support from PHYs")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
Submitted this version on June 22 2017 originally as RFC, resending
for inclusion this time.

Who should pick up the two patches? I guess they could go either
through netdev or the generic-phy tree, but they should stay together
as a series.
---
 drivers/net/phy/Kconfig | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 2dda72004a7d..928fd892f167 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -7,7 +7,16 @@ menuconfig MDIO_DEVICE
 	help
 	   MDIO devices and driver infrastructure code.
 
-if MDIO_DEVICE
+config MDIO_BUS
+	tristate
+	default m if PHYLIB=m
+	default MDIO_DEVICE
+	help
+	  This internal symbol is used for link time dependencies and it
+	  reflects whether the mdio_bus/mdio_device code is built as a
+	  loadable module or built-in.
+
+if MDIO_BUS
 
 config MDIO_BCM_IPROC
 	tristate "Broadcom iProc MDIO bus controller"
@@ -28,7 +37,6 @@ config MDIO_BCM_UNIMAC
 
 config MDIO_BITBANG
 	tristate "Bitbanged MDIO buses"
-	depends on !(MDIO_DEVICE=y && PHYLIB=m)
 	help
 	  This module implements the MDIO bus protocol in software,
 	  for use by low level drivers that export the ability to
@@ -127,7 +135,6 @@ config MDIO_THUNDER
 	tristate "ThunderX SOCs MDIO buses"
 	depends on 64BIT
 	depends on PCI
-	depends on !(MDIO_DEVICE=y && PHYLIB=m)
 	select MDIO_CAVIUM
 	help
 	  This driver supports the MDIO interfaces found on Cavium
-- 
2.9.0

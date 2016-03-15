From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: mvneta: bm: clarify dependencies
Date: Tue, 15 Mar 2016 22:47:14 +0100
Message-ID: <1458078449-635940-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Marcin Wojtas <mw@semihalf.com>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

MVNETA_BM has a dependency on MVNETA, so we can only select the former
if the latter is enabled. However, the code dependency is the reverse:
The mvneta module can call into the mvneta_bm module, so mvneta cannot
be a built-in if mvneta_bm is a module, or we get a link error:

drivers/net/built-in.o: In function `mvneta_remove':
drivers/net/ethernet/marvell/mvneta.c:4211: undefined reference to `mvneta_bm_pool_destroy'
drivers/net/built-in.o: In function `mvneta_bm_update_mtu':
drivers/net/ethernet/marvell/mvneta.c:1034: undefined reference to `mvneta_bm_bufs_free'

This avoids the problem by further clarifying the dependency so that
MVNETA_BM is a silent Kconfig option that gets turned on by the
new MVNETA_BM_ENABLE option. This way both the core HWBM module and
the MVNETA_BM code are always built-in when needed.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: dc35a10f68d3 ("net: mvneta: bm: add support for hardware buffer management")
---
 drivers/net/ethernet/marvell/Kconfig | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
index 62d80fddbe34..b5c6d42daa12 100644
--- a/drivers/net/ethernet/marvell/Kconfig
+++ b/drivers/net/ethernet/marvell/Kconfig
@@ -40,10 +40,9 @@ config MVMDIO
 
 	  This driver is used by the MV643XX_ETH and MVNETA drivers.
 
-config MVNETA_BM
+config MVNETA_BM_ENABLE
 	tristate "Marvell Armada 38x/XP network interface BM support"
 	depends on MVNETA
-	select HWBM
 	---help---
 	  This driver supports auxiliary block of the network
 	  interface units in the Marvell ARMADA XP and ARMADA 38x SoC
@@ -67,6 +66,15 @@ config MVNETA
 	  driver, which should be used for the older Marvell SoCs
 	  (Dove, Orion, Discovery, Kirkwood).
 
+config MVNETA_BM
+	tristate
+	default y if MVNETA=y && MVNETA_BM_ENABLE
+	default MVNETA_BM_ENABLE
+	select HWBM
+	help
+	  MVNETA_BM must not be 'm' if MVNETA=y, so this symbol ensures
+	  that all dependencies are met.
+
 config MVPP2
 	tristate "Marvell Armada 375 network interface support"
 	depends on MACH_ARMADA_375
-- 
2.7.0

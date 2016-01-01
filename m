From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] fsl/fman: allow modular build
Date: Fri, 01 Jan 2016 14:55:24 +0100
Message-ID: <4109142.02mezJXbJM@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Igal Liberman <Igal.Liberman@freescale.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

ARM allmodconfig fails because of the addition of the FMAN driver:

drivers/built-in.o: In function `dtsec_restart_autoneg':
binder.c:(.text+0x173328): undefined reference to `mdiobus_read'
binder.c:(.text+0x173348): undefined reference to `mdiobus_write'
drivers/built-in.o: In function `dtsec_config':
binder.c:(.text+0x173d24): undefined reference to `of_phy_find_device'
drivers/built-in.o: In function `init_phy':
binder.c:(.text+0x1763b0): undefined reference to `of_phy_connect'
drivers/built-in.o: In function `stop':
binder.c:(.text+0x176014): undefined reference to `phy_stop'
drivers/built-in.o: In function `start':
binder.c:(.text+0x176078): undefined reference to `phy_start'

The reason is that the driver uses PHYLIB, but that is a loadable
module here, and fman itself is built-in.

This patch makes it possible to configure fman as a module as well
so we don't change the status of PHYLIB in an allmodconfig kernel,
and it adds a 'select PHYLIB' statement to ensure that phylib is
always built-in when fman is.

The driver uses "builtin_platform_driver(fman_driver);", which means
it cannot be unloaded, but it's still possible to have it as a loadable
module that gets loaded once and never removed.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 5adae51a64b8 ("fsl/fman: Add FMan MURAM support")

diff --git a/drivers/net/ethernet/freescale/fman/Kconfig b/drivers/net/ethernet/freescale/fman/Kconfig
index 66b729692b48..79b7c84b7869 100644
--- a/drivers/net/ethernet/freescale/fman/Kconfig
+++ b/drivers/net/ethernet/freescale/fman/Kconfig
@@ -1,7 +1,8 @@
 config FSL_FMAN
-	bool "FMan support"
+	tristate "FMan support"
 	depends on FSL_SOC || COMPILE_TEST
 	select GENERIC_ALLOCATOR
+	select PHYLIB
 	default n
 	help
 		Freescale Data-Path Acceleration Architecture Frame Manager

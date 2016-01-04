From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: next-20160104 build: 3 failures 15 warnings (next-20160104)
Date: Mon, 04 Jan 2016 23:07:41 +0100
Message-ID: <3705737.6TGxRxdFzW@wuerfel>
References: <E1aG3zo-0000gt-2t@optimist> <20160104165025.GN16023@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Mark Brown <broonie@kernel.org>,
	Igal Liberman <igal.liberman@freescale.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linaro-kernel@lists.linaro.org, linux-next@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: kernel-build-reports@lists.linaro.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20160104165025.GN16023@sirena.org.uk>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 04 January 2016 16:50:25 Mark Brown wrote:
> On Mon, Jan 04, 2016 at 12:12:20PM +0000, Build bot for Mark Brown wrote:
> 
> Today's linux-next fails to build an arm allmodconfig (and probably also
> at least arm64 though other errors prevent that getting to linking
> currently) due to:
> 
> | drivers/built-in.o: In function `dtsec_restart_autoneg':
> | :(.text+0x30f86c): undefined reference to `mdiobus_read'
> | :(.text+0x30f89c): undefined reference to `mdiobus_write'
> | drivers/built-in.o: In function `dtsec_init':
> | :(.text+0x31008c): undefined reference to `mdiobus_write'
> | :(.text+0x3100b4): undefined reference to `mdiobus_write'
> | :(.text+0x3100dc): undefined reference to `mdiobus_write'
> | :(.text+0x310128): undefined reference to `mdiobus_write'
> | drivers/built-in.o::(.text+0x310150): more undefined references to `mdiobus_write' follow
> | drivers/built-in.o: In function `dtsec_config':
> | :(.text+0x310804): undefined reference to `of_phy_find_device'
> 
> and various other linker errors caused by the fact that the new fman
> driver uses PHYLIB but does not depend on or select it.

This is the patch I submitted for the problem. I don't think that simply
adding the 'select' would be a good idea because that would force PHYLIB
builtin for allmodconfig.

	Arnd

commit 609a5b98a4b703a4fba8becb7ffb2aa1859c4164
Author: Arnd Bergmann <arnd@arndb.de>
Date:   Fri Jan 1 13:24:03 2016 +0100

    [SUBMITTED] fsl/fman: allow modular build
    
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

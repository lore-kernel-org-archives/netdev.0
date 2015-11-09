From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mvneta: add FIXED_PHY dependency
Date: Mon, 09 Nov 2015 15:08:57 +0100
Message-ID: <4225885.EYXTHjRPmX@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Stas Sergeev <stsp@users.sourceforge.net>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The fixed_phy infrastructure is done in a way that is optional,
by providing 'static inline' helper functions doing nothing in
include/linux/phy_fixed.h for all its APIs. However, three out
of the four users (DSA, BCMGENET, and SYSTEMPORT) always
'select FIXED_PHY', presumably because they need that.
MVNETA is the fourth one, and if that is built-in but FIXED_PHY
is configured as a loadable module, we get a link error:

drivers/built-in.o: In function `mvneta_fixed_link_update':
fpga-mgr.c:(.text+0x33ed80): undefined reference to `fixed_phy_update_state'

Presumably this driver has the same dependency as the others,
so this patch also uses 'select' to ensure that the fixed-phy
support is built-in.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 898b2970e2c9 ("mvneta: implement SGMII-based in-band link state signaling")
---
Found using ARM randconfig tests. An alternative here would be
to use 'depends on FIXED_PHY || FIXED_PHY=n', I picked the 'select'
approach for consistency.

Should we perhaps make 'FIXED_PHY' a silent option and remove the
inline helpers, based on the assumption that a driver that wants these
will not work without them?

diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
index 80af9ffce5ea..a1c862b4664d 100644
--- a/drivers/net/ethernet/marvell/Kconfig
+++ b/drivers/net/ethernet/marvell/Kconfig
@@ -44,6 +44,7 @@ config MVNETA
 	tristate "Marvell Armada 370/38x/XP network interface support"
 	depends on PLAT_ORION
 	select MVMDIO
+	select FIXED_PHY
 	---help---
 	  This driver supports the network interface units in the
 	  Marvell ARMADA XP, ARMADA 370 and ARMADA 38x SoC family.

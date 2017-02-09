From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] [net-next] ARM: orion: fix PHYLIB dependency
Date: Thu,  9 Feb 2017 16:08:11 +0100
Message-ID: <20170209150834.1158193-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Florian Fainelli <f.fainelli@gmail.com>,
 Jason Cooper <jason@lakedaemon.net>, Arnd Bergmann <arnd@arndb.de>,
 netdev@vger.kernel.org, Russell King <linux@armlinux.org.uk>,
 linux-kernel@vger.kernel.org,
 Gregory Clement <gregory.clement@free-electrons.com>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
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

The newly introduced mdiobus_register_board_info() function is only available
as part of PHYLIB, so we get a link error when we call that from a board while
phylib is disabled:

arch/arm/plat-orion/common.o: In function `orion_ge00_switch_init':
common.c:(.init.text+0x6a4): undefined reference to `mdiobus_register_board_info'

This adds a workaround that is made up of three parts:

- in plat-orion, the function for declaring the switch is hidden without
  PHYLIB.
- in mach-orion5x, the caller conditionally stubs out the call to
  the removed function, so we can still build other orion5x boards
  without PHYLIB
- For the boards that actually declare the switch, we select PHYLIB
  explicitly from Kconfig if NETDEVICES is set. Without NETDEVICES,
  we cannot enable PHYLIB, but we also wouldn't need it.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/arm/mach-orion5x/Kconfig  | 5 +++++
 arch/arm/mach-orion5x/common.c | 4 ++--
 arch/arm/plat-orion/common.c   | 2 ++
 3 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/arch/arm/mach-orion5x/Kconfig b/arch/arm/mach-orion5x/Kconfig
index 468b8cb7fd5f..b98a0057ef66 100644
--- a/arch/arm/mach-orion5x/Kconfig
+++ b/arch/arm/mach-orion5x/Kconfig
@@ -107,6 +107,7 @@ config MACH_TS409
 
 config MACH_WRT350N_V2
 	bool "Linksys WRT350N v2"
+	select PHYLIB if NETDEVICES
 	help
 	  Say 'Y' here if you want your kernel to support the
 	  Linksys WRT350N v2 platform.
@@ -146,24 +147,28 @@ config MACH_MSS2_DT
 
 config MACH_WNR854T
 	bool "Netgear WNR854T"
+	select PHYLIB if NETDEVICES
 	help
 	  Say 'Y' here if you want your kernel to support the
 	  Netgear WNR854T platform.
 
 config MACH_RD88F5181L_GE
 	bool "Marvell Orion-VoIP GE Reference Design"
+	select PHYLIB if NETDEVICES
 	help
 	  Say 'Y' here if you want your kernel to support the
 	  Marvell Orion-VoIP GE (88F5181L) RD.
 
 config MACH_RD88F5181L_FXO
 	bool "Marvell Orion-VoIP FXO Reference Design"
+	select PHYLIB if NETDEVICES
 	help
 	  Say 'Y' here if you want your kernel to support the
 	  Marvell Orion-VoIP FXO (88F5181L) RD.
 
 config MACH_RD88F6183AP_GE
 	bool "Marvell Orion-1-90 AP GE Reference Design"
+	select PHYLIB if NETDEVICES
 	help
 	  Say 'Y' here if you want your kernel to support the
 	  Marvell Orion-1-90 (88F6183) AP GE RD.
diff --git a/arch/arm/mach-orion5x/common.c b/arch/arm/mach-orion5x/common.c
index 83a7ec4c16d0..e712c5adaf87 100644
--- a/arch/arm/mach-orion5x/common.c
+++ b/arch/arm/mach-orion5x/common.c
@@ -107,10 +107,10 @@ void __init orion5x_eth_init(struct mv643xx_eth_platform_data *eth_data)
  ****************************************************************************/
 void __init orion5x_eth_switch_init(struct dsa_chip_data *d)
 {
-	orion_ge00_switch_init(d);
+	if (IS_BUILTIN(CONFIG_PHYLIB))
+		orion_ge00_switch_init(d);
 }
 
-
 /*****************************************************************************
  * I2C
  ****************************************************************************/
diff --git a/arch/arm/plat-orion/common.c b/arch/arm/plat-orion/common.c
index 9255b6d67ba5..ab5af56f9b9d 100644
--- a/arch/arm/plat-orion/common.c
+++ b/arch/arm/plat-orion/common.c
@@ -471,6 +471,7 @@ void __init orion_ge11_init(struct mv643xx_eth_platform_data *eth_data,
 /*****************************************************************************
  * Ethernet switch
  ****************************************************************************/
+#if IS_BUILTIN(CONFIG_PHYLIB)
 static __initconst const char *orion_ge00_mvmdio_bus_name = "orion-mii";
 static __initdata struct mdio_board_info
 		  orion_ge00_switch_board_info;
@@ -493,6 +494,7 @@ void __init orion_ge00_switch_init(struct dsa_chip_data *d)
 
 	mdiobus_register_board_info(&orion_ge00_switch_board_info, 1);
 }
+#endif
 
 /*****************************************************************************
  * I2C
-- 
2.9.0

From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] [v2, -net] cpsw/netcp: work around reverse cpts dependency
Date: Mon, 20 Mar 2017 09:52:50 +0100
Message-ID: <20170320085339.1033988-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Thomas Gleixner <tglx@linutronix.de>,
        Richard Cochran <richardcochran@gmail.com>,
        =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
        <u.kleine-koenig@pengutronix.de>,
        Nicolas Pitre <nicolas.pitre@linaro.org>,
        WingMan Kwok <w-kwok2@ti.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Grygorii Strashko <grygorii.strashko@ti.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dependency is reversed: cpsw and netcp call into cpts,
but cpts depends on the other two in Kconfig. This can lead
to cpts being a loadable module and its callers built-in:

drivers/net/ethernet/ti/cpsw.o: In function `cpsw_remove':
cpsw.c:(.text.cpsw_remove+0xd0): undefined reference to `cpts_release'
drivers/net/ethernet/ti/cpsw.o: In function `cpsw_rx_handler':
cpsw.c:(.text.cpsw_rx_handler+0x2dc): undefined reference to `cpts_rx_timestamp'
drivers/net/ethernet/ti/cpsw.o: In function `cpsw_tx_handler':
cpsw.c:(.text.cpsw_tx_handler+0x7c): undefined reference to `cpts_tx_timestamp'
drivers/net/ethernet/ti/cpsw.o: In function `cpsw_ndo_stop':

As a workaround, I'm introducing another Kconfig symbol to
control the compilation of cpts, while making the actual
module controlled by a silent symbol that is =y when necessary.

Fixes: 6246168b4a38 ("net: ethernet: ti: netcp: add support of cpts")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Reviewed-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
v1: Originally submitted on Dec 16, still needed for v4.10 and v4.11-rc2
v2: change the symbol names to keep existing defconfigs working
---
 drivers/net/ethernet/ti/Kconfig  | 8 +++++++-
 drivers/net/ethernet/ti/Makefile | 2 +-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
index bd0af5974a75..9e631952b86f 100644
--- a/drivers/net/ethernet/ti/Kconfig
+++ b/drivers/net/ethernet/ti/Kconfig
@@ -74,7 +74,7 @@ config TI_CPSW
 	  will be called cpsw.
 
 config TI_CPTS
-	tristate "TI Common Platform Time Sync (CPTS) Support"
+	bool "TI Common Platform Time Sync (CPTS) Support"
 	depends on TI_CPSW || TI_KEYSTONE_NETCP
 	depends on PTP_1588_CLOCK
 	---help---
@@ -83,6 +83,12 @@ config TI_CPTS
 	  The unit can time stamp PTP UDP/IPv4 and Layer 2 packets, and the
 	  driver offers a PTP Hardware Clock.
 
+config TI_CPTS_MOD
+	tristate
+	depends on TI_CPTS
+	default y if TI_CPSW=y || TI_KEYSTONE_NETCP=y
+	default m
+
 config TI_KEYSTONE_NETCP
 	tristate "TI Keystone NETCP Core Support"
 	select TI_CPSW_ALE
diff --git a/drivers/net/ethernet/ti/Makefile b/drivers/net/ethernet/ti/Makefile
index 1e7c10bf8713..10e6b0ce51ba 100644
--- a/drivers/net/ethernet/ti/Makefile
+++ b/drivers/net/ethernet/ti/Makefile
@@ -12,7 +12,7 @@ obj-$(CONFIG_TI_DAVINCI_MDIO) += davinci_mdio.o
 obj-$(CONFIG_TI_DAVINCI_CPDMA) += davinci_cpdma.o
 obj-$(CONFIG_TI_CPSW_PHY_SEL) += cpsw-phy-sel.o
 obj-$(CONFIG_TI_CPSW_ALE) += cpsw_ale.o
-obj-$(CONFIG_TI_CPTS) += cpts.o
+obj-$(CONFIG_TI_CPTS_MOD) += cpts.o
 obj-$(CONFIG_TI_CPSW) += ti_cpsw.o
 ti_cpsw-y := cpsw.o
 
-- 
2.9.0

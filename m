From: Arnd Bergmann <arnd@arndb.de>
Subject: [RESEND PATCH -net] cpsw/netcp: work around reverse cpts dependency
Date: Mon, 13 Mar 2017 17:59:04 +0100
Message-ID: <20170313165927.1389014-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Richard Cochran <richardcochran@gmail.com>,
        WingMan Kwok <w-kwok2@ti.com>,
        Nicolas Pitre <nicolas.pitre@linaro.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
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
Originally submitted on Dec 16, still needed for v4.10 and v4.11-rc2
---
 drivers/net/ethernet/ti/Kconfig | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
index 296c8efd0038..d42257fbe9d9 100644
--- a/drivers/net/ethernet/ti/Kconfig
+++ b/drivers/net/ethernet/ti/Kconfig
@@ -73,8 +73,8 @@ config TI_CPSW
 	  To compile this driver as a module, choose M here: the module
 	  will be called cpsw.
 
-config TI_CPTS
-	tristate "TI Common Platform Time Sync (CPTS) Support"
+config TI_CPTS_ENABLE
+	bool "TI Common Platform Time Sync (CPTS) Support"
 	depends on TI_CPSW || TI_KEYSTONE_NETCP
 	imply PTP_1588_CLOCK
 	---help---
@@ -83,6 +83,12 @@ config TI_CPTS
 	  The unit can time stamp PTP UDP/IPv4 and Layer 2 packets, and the
 	  driver offers a PTP Hardware Clock.
 
+config TI_CPTS
+	tristate
+	depends on TI_CPTS_ENABLE
+	default y if TI_CPSW=y || TI_KEYSTONE_NETCP=y
+	default m
+
 config TI_KEYSTONE_NETCP
 	tristate "TI Keystone NETCP Core Support"
 	select TI_CPSW_ALE
-- 
2.9.0

From: Andy Green <andy.green@linaro.org>
Subject: [PATCH 5 2/2] OMAP4 PANDA register ethernet and wlan for automatic
 mac allocation
Date: Fri, 06 Jul 2012 12:09:48 +0800
Message-ID: <20120706040946.6669.1040.stgit@build.warmcat.com>
References: <20120706040938.6669.77083.stgit@build.warmcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: s-jan@ti.com, arnd@arndb.de, patches@linaro.org, tony@atomide.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	rostedt@goodmis.org, linux-arm-kernel@lists.infradead.org
To: linux-omap@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from warmcat.com ([87.106.134.80]:42661 "EHLO warmcat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750911Ab2GFEJx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 00:09:53 -0400
In-Reply-To: <20120706040938.6669.77083.stgit@build.warmcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Green <andy@warmcat.com>

This provides the board-specific device paths needed to get
the panda boardfile working with the eth-mac-platform api.

On Pandaboard / ES, neither the onboard Ethernet or onboard WLAN
module have onboard arrangements for MAC storage, without this
series yielding randomized MAC per-boot and consequent DHCP problems,
or in the case of wlan0 a MAC set by a firmware file in the rootfs
which unless customized yields a MAC of 00:00:00:00:00:00.  No
official MAC is reserved for either network device even if you do
take the approach to customize the firmware file.

This gets sane, consistent MAC addresses on both devices which
should stand a good probability of differing between PandaBoards.

Signed-off-by: Andy Green <andy.green@linaro.org>
---
 arch/arm/mach-omap2/Kconfig            |    1 +
 arch/arm/mach-omap2/board-omap4panda.c |   30 ++++++++++++++++++++++++++++++
 2 files changed, 31 insertions(+)

diff --git a/arch/arm/mach-omap2/Kconfig b/arch/arm/mach-omap2/Kconfig
index 83fb31c..61c6a3d 100644
--- a/arch/arm/mach-omap2/Kconfig
+++ b/arch/arm/mach-omap2/Kconfig
@@ -358,6 +358,7 @@ config MACH_OMAP4_PANDA
 	select OMAP_PACKAGE_CBL
 	select OMAP_PACKAGE_CBS
 	select REGULATOR_FIXED_VOLTAGE if REGULATOR
+	select ETH_MAC_PLATFORM
 
 config MACH_PCM049
 	bool "OMAP4 based phyCORE OMAP4"
diff --git a/arch/arm/mach-omap2/board-omap4panda.c b/arch/arm/mach-omap2/board-omap4panda.c
index 982fb26..75d93cc 100644
--- a/arch/arm/mach-omap2/board-omap4panda.c
+++ b/arch/arm/mach-omap2/board-omap4panda.c
@@ -32,7 +32,10 @@
 #include <linux/wl12xx.h>
 #include <linux/platform_data/omap-abe-twl6040.h>
 
+#include <net/eth-mac-platform.h>
+
 #include <mach/hardware.h>
+#include <mach/id.h>
 #include <asm/hardware/gic.h>
 #include <asm/mach-types.h>
 #include <asm/mach/arch.h>
@@ -486,16 +489,43 @@ static void omap4_panda_init_rev(void)
 	}
 }
 
+/*
+ * These device paths represent onboard network devices which have
+ * no MAC address set at boot, and need synthetic ones assigning
+ */
+static __initdata struct eth_mac_platform panda_eth_mac_platform[] = {
+
+	{ /* smsc USB <-> Ethernet bridge */
+		.device_path = "usb1/1-1/1-1.1/1-1.1:1.0",
+	},
+	{ /* wlan0 module */
+		.device_path = "wl12xx",
+	},
+	{ /* terminator */
+	}
+};
+
 static void __init omap4_panda_init(void)
 {
 	int package = OMAP_PACKAGE_CBS;
 	int ret;
+	int n;
 
 	if (omap_rev() == OMAP4430_REV_ES1_0)
 		package = OMAP_PACKAGE_CBL;
 	omap4_mux_init(board_mux, NULL, package);
 
 	omap_panda_wlan_data.irq = gpio_to_irq(GPIO_WIFI_IRQ);
+
+	/*
+	 * provide MAC addresses computed from device ID for network
+	 * devices that have no MAC address otherwise on Panda
+	 */
+	for (n = 0; n < ARRAY_SIZE(panda_eth_mac_platform) - 1; n++)
+		omap_die_id_to_ethernet_mac(panda_eth_mac_platform[n].mac, n);
+	if (eth_mac_platform_register_device_macs(panda_eth_mac_platform))
+		pr_err("Unable to register eth_mac_platform devices\n");
+
 	ret = wl12xx_set_platform_data(&omap_panda_wlan_data);
 	if (ret)
 		pr_err("error setting wl12xx data: %d\n", ret);

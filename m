From: Andy Green <andy.green@linaro.org>
Subject: [PATCH 4 3/4] OMAP4 PANDA register ethernet and wlan for automatic
 mac allocation
Date: Thu, 05 Jul 2012 10:44:56 +0800
Message-ID: <20120705024454.26317.96460.stgit@build.warmcat.com>
References: <20120705024259.26317.16000.stgit@build.warmcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: s-jan@ti.com, arnd@arndb.de, patches@linaro.org, tony@atomide.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	rostedt@goodmis.org, linux-arm-kernel@lists.infradead.org
To: linux-omap@vger.kernel.org
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <20120705024259.26317.16000.stgit@build.warmcat.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Green <andy@warmcat.com>

This provides the board-specific device paths needed to get
the panda boardfile working with the mac-platform api.

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
index 83fb31c..06fadf4 100644
--- a/arch/arm/mach-omap2/Kconfig
+++ b/arch/arm/mach-omap2/Kconfig
@@ -358,6 +358,7 @@ config MACH_OMAP4_PANDA
 	select OMAP_PACKAGE_CBL
 	select OMAP_PACKAGE_CBS
 	select REGULATOR_FIXED_VOLTAGE if REGULATOR
+	select MAC_PLATFORM
 
 config MACH_PCM049
 	bool "OMAP4 based phyCORE OMAP4"
diff --git a/arch/arm/mach-omap2/board-omap4panda.c b/arch/arm/mach-omap2/board-omap4panda.c
index 982fb26..b028141 100644
--- a/arch/arm/mach-omap2/board-omap4panda.c
+++ b/arch/arm/mach-omap2/board-omap4panda.c
@@ -32,7 +32,10 @@
 #include <linux/wl12xx.h>
 #include <linux/platform_data/omap-abe-twl6040.h>
 
+#include <net/mac-platform.h>
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
+static __initdata struct mac_platform panda_mac_platform[] = {
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
+	for (n = 0; n < ARRAY_SIZE(panda_mac_platform) - 1; n++)
+		omap_die_id_to_ethernet_mac(panda_mac_platform[n].mac, n);
+	if (mac_platform_register_device_macs(panda_mac_platform))
+		pr_err("Unable to register mac_platform devices\n");
+
 	ret = wl12xx_set_platform_data(&omap_panda_wlan_data);
 	if (ret)
 		pr_err("error setting wl12xx data: %d\n", ret);


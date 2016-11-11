From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: [PATCH v4 3/6] ptp_clock: allow for it to be optional
Date: Fri, 11 Nov 2016 00:10:07 -0500
Message-ID: <1478841010-28605-4-git-send-email-nicolas.pitre@linaro.org>
References: <1478841010-28605-1-git-send-email-nicolas.pitre@linaro.org>
Cc: Richard Cochran <richardcochran@gmail.com>,
        Paul Bolle <pebolle@tiscali.nl>,
        Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>,
        Edward Cree <ecree@solarflare.com>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: John Stultz <john.stultz@linaro.org>,
        Michal Marek <mmarek@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alt32.smtp-out.videotron.ca ([24.53.0.21]:18881 "EHLO
        alt32.smtp-out.videotron.ca" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751519AbcKKFKc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 00:10:32 -0500
In-Reply-To: <1478841010-28605-1-git-send-email-nicolas.pitre@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to break the hard dependency between the PTP clock subsystem and
ethernet drivers capable of being clock providers, this patch provides
simple PTP stub functions to allow linkage of those drivers into the
kernel even when the PTP subsystem is configured out. Drivers must be
ready to accept NULL from ptp_clock_register() in that case.

And to make it possible for PTP to be configured out, the select statement
in those driver's Kconfig menu entries is converted to the new "imply"
statement. This way the PTP subsystem may have Kconfig dependencies of
its own, such as POSIX_TIMERS, without having to make those ethernet
drivers unavailable if POSIX timers are cconfigured out. And when support
for POSIX timers is selected again then the default config option for PTP
clock support will automatically be adjusted accordingly.

The pch_gbe driver is a bit special as it relies on extra code in
drivers/ptp/ptp_pch.c. Therefore we let the make process descend into
drivers/ptp/ even if PTP_1588_CLOCK is unselected.

Signed-off-by: Nicolas Pitre <nico@linaro.org>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
Acked-by: Richard Cochran <richardcochran@gmail.com>
Acked-by: Edward Cree <ecree@solarflare.com>
Acked-by: Thomas Gleixner <tglx@linutronix.de>
---
 drivers/Makefile                                |  2 +-
 drivers/net/ethernet/adi/Kconfig                |  2 +-
 drivers/net/ethernet/amd/Kconfig                |  2 +-
 drivers/net/ethernet/amd/xgbe/xgbe-main.c       |  6 ++-
 drivers/net/ethernet/broadcom/Kconfig           |  4 +-
 drivers/net/ethernet/cavium/Kconfig             |  2 +-
 drivers/net/ethernet/freescale/Kconfig          |  2 +-
 drivers/net/ethernet/intel/Kconfig              | 10 ++--
 drivers/net/ethernet/mellanox/mlx4/Kconfig      |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig |  2 +-
 drivers/net/ethernet/renesas/Kconfig            |  2 +-
 drivers/net/ethernet/samsung/Kconfig            |  2 +-
 drivers/net/ethernet/sfc/Kconfig                |  2 +-
 drivers/net/ethernet/stmicro/stmmac/Kconfig     |  2 +-
 drivers/net/ethernet/ti/Kconfig                 |  2 +-
 drivers/net/ethernet/tile/Kconfig               |  2 +-
 drivers/ptp/Kconfig                             |  8 +--
 include/linux/ptp_clock_kernel.h                | 65 ++++++++++++++++---------
 18 files changed, 69 insertions(+), 50 deletions(-)

diff --git a/drivers/Makefile b/drivers/Makefile
index f0afdfb3c7..8cfa1ff8f6 100644
--- a/drivers/Makefile
+++ b/drivers/Makefile
@@ -107,7 +107,7 @@ obj-$(CONFIG_INPUT)		+= input/
 obj-$(CONFIG_RTC_LIB)		+= rtc/
 obj-y				+= i2c/ media/
 obj-$(CONFIG_PPS)		+= pps/
-obj-$(CONFIG_PTP_1588_CLOCK)	+= ptp/
+obj-y				+= ptp/
 obj-$(CONFIG_W1)		+= w1/
 obj-y				+= power/
 obj-$(CONFIG_HWMON)		+= hwmon/
diff --git a/drivers/net/ethernet/adi/Kconfig b/drivers/net/ethernet/adi/Kconfig
index 6b94ba6103..98cc8f5350 100644
--- a/drivers/net/ethernet/adi/Kconfig
+++ b/drivers/net/ethernet/adi/Kconfig
@@ -58,7 +58,7 @@ config BFIN_RX_DESC_NUM
 config BFIN_MAC_USE_HWSTAMP
 	bool "Use IEEE 1588 hwstamp"
 	depends on BFIN_MAC && BF518
-	select PTP_1588_CLOCK
+	imply PTP_1588_CLOCK
 	default y
 	---help---
 	  To support the IEEE 1588 Precision Time Protocol (PTP), select y here
diff --git a/drivers/net/ethernet/amd/Kconfig b/drivers/net/ethernet/amd/Kconfig
index 0038709fd3..713ea7ad22 100644
--- a/drivers/net/ethernet/amd/Kconfig
+++ b/drivers/net/ethernet/amd/Kconfig
@@ -177,7 +177,7 @@ config AMD_XGBE
 	depends on ARM64 || COMPILE_TEST
 	select BITREVERSE
 	select CRC32
-	select PTP_1588_CLOCK
+	imply PTP_1588_CLOCK
 	---help---
 	  This driver supports the AMD 10GbE Ethernet device found on an
 	  AMD SoC.
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index 9de078819a..e10e569c0d 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -773,7 +773,8 @@ static int xgbe_probe(struct platform_device *pdev)
 		goto err_wq;
 	}
 
-	xgbe_ptp_register(pdata);
+	if (IS_REACHABLE(CONFIG_PTP_1588_CLOCK))
+		xgbe_ptp_register(pdata);
 
 	xgbe_debugfs_init(pdata);
 
@@ -812,7 +813,8 @@ static int xgbe_remove(struct platform_device *pdev)
 
 	xgbe_debugfs_exit(pdata);
 
-	xgbe_ptp_unregister(pdata);
+	if (IS_REACHABLE(CONFIG_PTP_1588_CLOCK))
+		xgbe_ptp_unregister(pdata);
 
 	flush_workqueue(pdata->an_workqueue);
 	destroy_workqueue(pdata->an_workqueue);
diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index bd8c80c0b7..6a8d74aeb6 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -110,7 +110,7 @@ config TIGON3
 	depends on PCI
 	select PHYLIB
 	select HWMON
-	select PTP_1588_CLOCK
+	imply PTP_1588_CLOCK
 	---help---
 	  This driver supports Broadcom Tigon3 based gigabit Ethernet cards.
 
@@ -120,7 +120,7 @@ config TIGON3
 config BNX2X
 	tristate "Broadcom NetXtremeII 10Gb support"
 	depends on PCI
-	select PTP_1588_CLOCK
+	imply PTP_1588_CLOCK
 	select FW_LOADER
 	select ZLIB_INFLATE
 	select LIBCRC32C
diff --git a/drivers/net/ethernet/cavium/Kconfig b/drivers/net/ethernet/cavium/Kconfig
index 92f411c9f0..2e64a96661 100644
--- a/drivers/net/ethernet/cavium/Kconfig
+++ b/drivers/net/ethernet/cavium/Kconfig
@@ -53,7 +53,7 @@ config	THUNDER_NIC_RGX
 config LIQUIDIO
 	tristate "Cavium LiquidIO support"
 	depends on 64BIT
-	select PTP_1588_CLOCK
+	imply PTP_1588_CLOCK
 	select FW_LOADER
 	select LIBCRC32C
 	---help---
diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/ethernet/freescale/Kconfig
index d1ca45fbb1..5eb9280973 100644
--- a/drivers/net/ethernet/freescale/Kconfig
+++ b/drivers/net/ethernet/freescale/Kconfig
@@ -25,7 +25,7 @@ config FEC
 		   ARCH_MXC || SOC_IMX28)
 	default ARCH_MXC || SOC_IMX28 if ARM
 	select PHYLIB
-	select PTP_1588_CLOCK
+	imply PTP_1588_CLOCK
 	---help---
 	  Say Y here if you want to use the built-in 10/100 Fast ethernet
 	  controller on some Motorola ColdFire and Freescale i.MX processors.
diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index c0e17433f6..1349b45f01 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -58,7 +58,7 @@ config E1000E
 	tristate "Intel(R) PRO/1000 PCI-Express Gigabit Ethernet support"
 	depends on PCI && (!SPARC32 || BROKEN)
 	select CRC32
-	select PTP_1588_CLOCK
+	imply PTP_1588_CLOCK
 	---help---
 	  This driver supports the PCI-Express Intel(R) PRO/1000 gigabit
 	  ethernet family of adapters. For PCI or PCI-X e1000 adapters,
@@ -83,7 +83,7 @@ config E1000E_HWTS
 config IGB
 	tristate "Intel(R) 82575/82576 PCI-Express Gigabit Ethernet support"
 	depends on PCI
-	select PTP_1588_CLOCK
+	imply PTP_1588_CLOCK
 	select I2C
 	select I2C_ALGOBIT
 	---help---
@@ -156,7 +156,7 @@ config IXGBE
 	tristate "Intel(R) 10GbE PCI Express adapters support"
 	depends on PCI
 	select MDIO
-	select PTP_1588_CLOCK
+	imply PTP_1588_CLOCK
 	---help---
 	  This driver supports Intel(R) 10GbE PCI Express family of
 	  adapters.  For more information on how to identify your adapter, go
@@ -213,7 +213,7 @@ config IXGBEVF
 
 config I40E
 	tristate "Intel(R) Ethernet Controller XL710 Family support"
-	select PTP_1588_CLOCK
+	imply PTP_1588_CLOCK
 	depends on PCI
 	---help---
 	  This driver supports Intel(R) Ethernet Controller XL710 Family of
@@ -264,7 +264,7 @@ config FM10K
 	tristate "Intel(R) FM10000 Ethernet Switch Host Interface Support"
 	default n
 	depends on PCI_MSI
-	select PTP_1588_CLOCK
+	imply PTP_1588_CLOCK
 	---help---
 	  This driver supports Intel(R) FM10000 Ethernet Switch Host
 	  Interface.  For more information on how to identify your adapter,
diff --git a/drivers/net/ethernet/mellanox/mlx4/Kconfig b/drivers/net/ethernet/mellanox/mlx4/Kconfig
index 5098e7f219..22b1cc012b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx4/Kconfig
@@ -7,7 +7,7 @@ config MLX4_EN
 	depends on MAY_USE_DEVLINK
 	depends on PCI
 	select MLX4_CORE
-	select PTP_1588_CLOCK
+	imply PTP_1588_CLOCK
 	---help---
 	  This driver supports Mellanox Technologies ConnectX Ethernet
 	  devices.
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index aae46884bf..2cd841590e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -14,7 +14,7 @@ config MLX5_CORE
 config MLX5_CORE_EN
 	bool "Mellanox Technologies ConnectX-4 Ethernet support"
 	depends on NETDEVICES && ETHERNET && PCI && MLX5_CORE
-	select PTP_1588_CLOCK
+	imply PTP_1588_CLOCK
 	default n
 	---help---
 	  Ethernet support in Mellanox Technologies ConnectX-4 NIC.
diff --git a/drivers/net/ethernet/renesas/Kconfig b/drivers/net/ethernet/renesas/Kconfig
index 85ec447c2d..27be51f0a4 100644
--- a/drivers/net/ethernet/renesas/Kconfig
+++ b/drivers/net/ethernet/renesas/Kconfig
@@ -37,7 +37,7 @@ config RAVB
 	select MII
 	select MDIO_BITBANG
 	select PHYLIB
-	select PTP_1588_CLOCK
+	imply PTP_1588_CLOCK
 	help
 	  Renesas Ethernet AVB device driver.
 	  This driver supports the following SoCs:
diff --git a/drivers/net/ethernet/samsung/Kconfig b/drivers/net/ethernet/samsung/Kconfig
index 2360d81507..fbd5e06654 100644
--- a/drivers/net/ethernet/samsung/Kconfig
+++ b/drivers/net/ethernet/samsung/Kconfig
@@ -21,7 +21,7 @@ config SXGBE_ETH
 	depends on HAS_IOMEM && HAS_DMA
 	select PHYLIB
 	select CRC32
-	select PTP_1588_CLOCK
+	imply PTP_1588_CLOCK
 	---help---
 	  This is the driver for the SXGBE 10G Ethernet IP block found on
 	  Samsung platforms.
diff --git a/drivers/net/ethernet/sfc/Kconfig b/drivers/net/ethernet/sfc/Kconfig
index 4dd92b7b80..83f4766a1d 100644
--- a/drivers/net/ethernet/sfc/Kconfig
+++ b/drivers/net/ethernet/sfc/Kconfig
@@ -5,7 +5,7 @@ config SFC
 	select CRC32
 	select I2C
 	select I2C_ALGOBIT
-	select PTP_1588_CLOCK
+	imply PTP_1588_CLOCK
 	---help---
 	  This driver supports 10/40-gigabit Ethernet cards based on
 	  the Solarflare SFC4000, SFC9000-family and SFC9100-family
diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index 3818c5e06e..139c85fa6a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -4,7 +4,7 @@ config STMMAC_ETH
 	select MII
 	select PHYLIB
 	select CRC32
-	select PTP_1588_CLOCK
+	imply PTP_1588_CLOCK
 	select RESET_CONTROLLER
 	---help---
 	  This is the driver for the Ethernet IPs are built around a
diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
index 9904d740d5..61b835a7e6 100644
--- a/drivers/net/ethernet/ti/Kconfig
+++ b/drivers/net/ethernet/ti/Kconfig
@@ -76,7 +76,7 @@ config TI_CPSW
 config TI_CPTS
 	bool "TI Common Platform Time Sync (CPTS) Support"
 	depends on TI_CPSW
-	select PTP_1588_CLOCK
+	imply PTP_1588_CLOCK
 	---help---
 	  This driver supports the Common Platform Time Sync unit of
 	  the CPSW Ethernet Switch. The unit can time stamp PTP UDP/IPv4
diff --git a/drivers/net/ethernet/tile/Kconfig b/drivers/net/ethernet/tile/Kconfig
index f59a6c2653..bdfeaf3d4f 100644
--- a/drivers/net/ethernet/tile/Kconfig
+++ b/drivers/net/ethernet/tile/Kconfig
@@ -9,7 +9,7 @@ config TILE_NET
 	select CRC32
 	select TILE_GXIO_MPIPE if TILEGX
 	select HIGH_RES_TIMERS if TILEGX
-	select PTP_1588_CLOCK if TILEGX
+	imply PTP_1588_CLOCK if TILEGX
 	---help---
 	  This is a standard Linux network device driver for the
 	  on-chip Tilera Gigabit Ethernet and XAUI interfaces.
diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
index ee3de3421f..0f7492f8ea 100644
--- a/drivers/ptp/Kconfig
+++ b/drivers/ptp/Kconfig
@@ -28,7 +28,7 @@ config PTP_1588_CLOCK
 config PTP_1588_CLOCK_GIANFAR
 	tristate "Freescale eTSEC as PTP clock"
 	depends on GIANFAR
-	select PTP_1588_CLOCK
+	depends on PTP_1588_CLOCK
 	default y
 	help
 	  This driver adds support for using the eTSEC as a PTP
@@ -42,7 +42,7 @@ config PTP_1588_CLOCK_GIANFAR
 config PTP_1588_CLOCK_IXP46X
 	tristate "Intel IXP46x as PTP clock"
 	depends on IXP4XX_ETH
-	select PTP_1588_CLOCK
+	depends on PTP_1588_CLOCK
 	default y
 	help
 	  This driver adds support for using the IXP46X as a PTP
@@ -60,7 +60,7 @@ config DP83640_PHY
 	tristate "Driver for the National Semiconductor DP83640 PHYTER"
 	depends on NETWORK_PHY_TIMESTAMPING
 	depends on PHYLIB
-	select PTP_1588_CLOCK
+	depends on PTP_1588_CLOCK
 	---help---
 	  Supports the DP83640 PHYTER with IEEE 1588 features.
 
@@ -76,7 +76,7 @@ config PTP_1588_CLOCK_PCH
 	tristate "Intel PCH EG20T as PTP clock"
 	depends on X86_32 || COMPILE_TEST
 	depends on HAS_IOMEM && NET
-	select PTP_1588_CLOCK
+	imply PTP_1588_CLOCK
 	help
 	  This driver adds support for using the PCH EG20T as a PTP
 	  clock. The hardware supports time stamping of PTP packets
diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_kernel.h
index 5ad54fc66c..96699526d3 100644
--- a/include/linux/ptp_clock_kernel.h
+++ b/include/linux/ptp_clock_kernel.h
@@ -122,30 +122,6 @@ struct ptp_clock_info {
 
 struct ptp_clock;
 
-/**
- * ptp_clock_register() - register a PTP hardware clock driver
- *
- * @info:   Structure describing the new clock.
- * @parent: Pointer to the parent device of the new clock.
- *
- * Returns a valid pointer on success or PTR_ERR on failure.  If PHC
- * support is missing at the configuration level, this function
- * returns NULL, and drivers are expected to gracefully handle that
- * case separately.
- */
-
-extern struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info,
-					    struct device *parent);
-
-/**
- * ptp_clock_unregister() - unregister a PTP hardware clock driver
- *
- * @ptp:  The clock to remove from service.
- */
-
-extern int ptp_clock_unregister(struct ptp_clock *ptp);
-
-
 enum ptp_clock_events {
 	PTP_CLOCK_ALARM,
 	PTP_CLOCK_EXTTS,
@@ -171,6 +147,31 @@ struct ptp_clock_event {
 	};
 };
 
+#if IS_REACHABLE(CONFIG_PTP_1588_CLOCK)
+
+/**
+ * ptp_clock_register() - register a PTP hardware clock driver
+ *
+ * @info:   Structure describing the new clock.
+ * @parent: Pointer to the parent device of the new clock.
+ *
+ * Returns a valid pointer on success or PTR_ERR on failure.  If PHC
+ * support is missing at the configuration level, this function
+ * returns NULL, and drivers are expected to gracefully handle that
+ * case separately.
+ */
+
+extern struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info,
+					    struct device *parent);
+
+/**
+ * ptp_clock_unregister() - unregister a PTP hardware clock driver
+ *
+ * @ptp:  The clock to remove from service.
+ */
+
+extern int ptp_clock_unregister(struct ptp_clock *ptp);
+
 /**
  * ptp_clock_event() - notify the PTP layer about an event
  *
@@ -202,4 +203,20 @@ extern int ptp_clock_index(struct ptp_clock *ptp);
 int ptp_find_pin(struct ptp_clock *ptp,
 		 enum ptp_pin_function func, unsigned int chan);
 
+#else
+static inline struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info,
+						   struct device *parent)
+{ return NULL; }
+static inline int ptp_clock_unregister(struct ptp_clock *ptp)
+{ return 0; }
+static inline void ptp_clock_event(struct ptp_clock *ptp,
+				   struct ptp_clock_event *event)
+{ }
+static inline int ptp_clock_index(struct ptp_clock *ptp)
+{ return -1; }
+static inline int ptp_find_pin(struct ptp_clock *ptp,
+			       enum ptp_pin_function func, unsigned int chan)
+{ return -1; }
+#endif
+
 #endif
-- 
2.7.4

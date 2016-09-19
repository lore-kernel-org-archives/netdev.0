From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: [PATCH 1/2] ptp_clock: allow for it to be optional
Date: Sun, 18 Sep 2016 23:51:09 -0400
Message-ID: <1474257070-4255-2-git-send-email-nicolas.pitre@linaro.org>
References: <1474257070-4255-1-git-send-email-nicolas.pitre@linaro.org>
Cc: Thomas Gleixner <tglx@linutronix.de>,
        Richard Cochran <richardcochran@gmail.com>,
        Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: John Stultz <john.stultz@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474257070-4255-1-git-send-email-nicolas.pitre@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In order to break the hard dependency between the PTP clock subsystem and
ethernet drivers capable of being clock providers, this patch provides
simple PTP stub functions to allow linkage of those drivers into the
kernel even when the PTP subsystem is configured out.

And to make it possible for PTP to be configured out, the select statement
in the Kconfig entry for those ethernet drivers is changed from selecting
PTP_1588_CLOCK to PTP_1588_CLOCK_SELECTED whose purpose is to indicate the
default Kconfig value for the PTP subsystem.

This way the PTP subsystem may have Kconfig dependencies of its own, such
as POSIX_TIMERS, without making those ethernet drivers unavailable if
POSIX timers are cconfigured out. And when support for POSIX timers is
selected again then PTP clock support will also be selected accordingly.

Drivers must be ready to accept NULL from ptp_clock_register().
The pch_gbe driver is a bit special as it relies on extra code in
drivers/ptp/ptp_pch.c. Therefore we let the make process descend into
drivers/ptp/ even if PTP_1588_CLOCK is unselected.

Signed-off-by: Nicolas Pitre <nico@linaro.org>
Acked-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/Makefile                                   |  2 +-
 drivers/net/ethernet/adi/Kconfig                   |  8 ++-
 drivers/net/ethernet/amd/Kconfig                   |  2 +-
 drivers/net/ethernet/amd/xgbe/xgbe-main.c          |  6 ++-
 drivers/net/ethernet/broadcom/Kconfig              |  4 +-
 drivers/net/ethernet/cavium/Kconfig                |  2 +-
 drivers/net/ethernet/freescale/Kconfig             |  2 +-
 drivers/net/ethernet/intel/Kconfig                 | 10 ++--
 drivers/net/ethernet/intel/e1000e/ptp.c            |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_ptp.c         |  2 +-
 drivers/net/ethernet/intel/igb/igb_ptp.c           |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c       |  2 +-
 drivers/net/ethernet/mellanox/mlx4/Kconfig         |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_clock.c      |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c |  2 +-
 drivers/net/ethernet/renesas/Kconfig               |  2 +-
 drivers/net/ethernet/samsung/Kconfig               |  2 +-
 drivers/net/ethernet/sfc/Kconfig                   |  2 +-
 drivers/net/ethernet/sfc/ptp.c                     | 14 ++---
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |  2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c   |  2 +-
 drivers/net/ethernet/ti/Kconfig                    |  2 +-
 drivers/net/ethernet/tile/Kconfig                  |  2 +-
 drivers/ptp/Kconfig                                | 12 +++--
 include/linux/ptp_clock_kernel.h                   | 59 +++++++++++++++-------
 26 files changed, 92 insertions(+), 59 deletions(-)

diff --git a/drivers/Makefile b/drivers/Makefile
index 53abb4a5f7..8a538d0856 100644
--- a/drivers/Makefile
+++ b/drivers/Makefile
@@ -105,7 +105,7 @@ obj-$(CONFIG_INPUT)		+= input/
 obj-$(CONFIG_RTC_LIB)		+= rtc/
 obj-y				+= i2c/ media/
 obj-$(CONFIG_PPS)		+= pps/
-obj-$(CONFIG_PTP_1588_CLOCK)	+= ptp/
+obj-y				+= ptp/
 obj-$(CONFIG_W1)		+= w1/
 obj-y				+= power/
 obj-$(CONFIG_HWMON)		+= hwmon/
diff --git a/drivers/net/ethernet/adi/Kconfig b/drivers/net/ethernet/adi/Kconfig
index 6b94ba6103..67094a9cfe 100644
--- a/drivers/net/ethernet/adi/Kconfig
+++ b/drivers/net/ethernet/adi/Kconfig
@@ -55,10 +55,14 @@ config BFIN_RX_DESC_NUM
 	---help---
 	  Set the number of buffer packets used in driver.
 
+config BFIN_MAC_HAS_HWSTAMP
+	def_tristate BFIN_MAC
+	depends on BF518
+	select PTP_1588_CLOCK_SELECTED
+
 config BFIN_MAC_USE_HWSTAMP
 	bool "Use IEEE 1588 hwstamp"
-	depends on BFIN_MAC && BF518
-	select PTP_1588_CLOCK
+	depends on BFIN_MAC_HAS_HWSTAMP && PTP_1588_CLOCK
 	default y
 	---help---
 	  To support the IEEE 1588 Precision Time Protocol (PTP), select y here
diff --git a/drivers/net/ethernet/amd/Kconfig b/drivers/net/ethernet/amd/Kconfig
index 0038709fd3..327e71a554 100644
--- a/drivers/net/ethernet/amd/Kconfig
+++ b/drivers/net/ethernet/amd/Kconfig
@@ -177,7 +177,7 @@ config AMD_XGBE
 	depends on ARM64 || COMPILE_TEST
 	select BITREVERSE
 	select CRC32
-	select PTP_1588_CLOCK
+	select PTP_1588_CLOCK_SELECTED
 	---help---
 	  This driver supports the AMD 10GbE Ethernet device found on an
 	  AMD SoC.
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index 3eee3201b5..4aeeb018b6 100644
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
index bd8c80c0b7..3db7eca92c 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -110,7 +110,7 @@ config TIGON3
 	depends on PCI
 	select PHYLIB
 	select HWMON
-	select PTP_1588_CLOCK
+	select PTP_1588_CLOCK_SELECTED
 	---help---
 	  This driver supports Broadcom Tigon3 based gigabit Ethernet cards.
 
@@ -120,7 +120,7 @@ config TIGON3
 config BNX2X
 	tristate "Broadcom NetXtremeII 10Gb support"
 	depends on PCI
-	select PTP_1588_CLOCK
+	select PTP_1588_CLOCK_SELECTED
 	select FW_LOADER
 	select ZLIB_INFLATE
 	select LIBCRC32C
diff --git a/drivers/net/ethernet/cavium/Kconfig b/drivers/net/ethernet/cavium/Kconfig
index e1b78b5003..5dd86cf683 100644
--- a/drivers/net/ethernet/cavium/Kconfig
+++ b/drivers/net/ethernet/cavium/Kconfig
@@ -53,7 +53,7 @@ config	THUNDER_NIC_RGX
 config LIQUIDIO
 	tristate "Cavium LiquidIO support"
 	depends on 64BIT
-	select PTP_1588_CLOCK
+	select PTP_1588_CLOCK_SELECTED
 	select FW_LOADER
 	select LIBCRC32C
 	---help---
diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/ethernet/freescale/Kconfig
index d1ca45fbb1..775dbfeb7b 100644
--- a/drivers/net/ethernet/freescale/Kconfig
+++ b/drivers/net/ethernet/freescale/Kconfig
@@ -25,7 +25,7 @@ config FEC
 		   ARCH_MXC || SOC_IMX28)
 	default ARCH_MXC || SOC_IMX28 if ARM
 	select PHYLIB
-	select PTP_1588_CLOCK
+	select PTP_1588_CLOCK_SELECTED
 	---help---
 	  Say Y here if you want to use the built-in 10/100 Fast ethernet
 	  controller on some Motorola ColdFire and Freescale i.MX processors.
diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index c0e17433f6..8bbfb43f09 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -58,7 +58,7 @@ config E1000E
 	tristate "Intel(R) PRO/1000 PCI-Express Gigabit Ethernet support"
 	depends on PCI && (!SPARC32 || BROKEN)
 	select CRC32
-	select PTP_1588_CLOCK
+	select PTP_1588_CLOCK_SELECTED
 	---help---
 	  This driver supports the PCI-Express Intel(R) PRO/1000 gigabit
 	  ethernet family of adapters. For PCI or PCI-X e1000 adapters,
@@ -83,7 +83,7 @@ config E1000E_HWTS
 config IGB
 	tristate "Intel(R) 82575/82576 PCI-Express Gigabit Ethernet support"
 	depends on PCI
-	select PTP_1588_CLOCK
+	select PTP_1588_CLOCK_SELECTED
 	select I2C
 	select I2C_ALGOBIT
 	---help---
@@ -156,7 +156,7 @@ config IXGBE
 	tristate "Intel(R) 10GbE PCI Express adapters support"
 	depends on PCI
 	select MDIO
-	select PTP_1588_CLOCK
+	select PTP_1588_CLOCK_SELECTED
 	---help---
 	  This driver supports Intel(R) 10GbE PCI Express family of
 	  adapters.  For more information on how to identify your adapter, go
@@ -213,7 +213,7 @@ config IXGBEVF
 
 config I40E
 	tristate "Intel(R) Ethernet Controller XL710 Family support"
-	select PTP_1588_CLOCK
+	select PTP_1588_CLOCK_SELECTED
 	depends on PCI
 	---help---
 	  This driver supports Intel(R) Ethernet Controller XL710 Family of
@@ -264,7 +264,7 @@ config FM10K
 	tristate "Intel(R) FM10000 Ethernet Switch Host Interface Support"
 	default n
 	depends on PCI_MSI
-	select PTP_1588_CLOCK
+	select PTP_1588_CLOCK_SELECTED
 	---help---
 	  This driver supports Intel(R) FM10000 Ethernet Switch Host
 	  Interface.  For more information on how to identify your adapter,
diff --git a/drivers/net/ethernet/intel/e1000e/ptp.c b/drivers/net/ethernet/intel/e1000e/ptp.c
index 2e1b17ad52..ad03763e00 100644
--- a/drivers/net/ethernet/intel/e1000e/ptp.c
+++ b/drivers/net/ethernet/intel/e1000e/ptp.c
@@ -334,7 +334,7 @@ void e1000e_ptp_init(struct e1000_adapter *adapter)
 	if (IS_ERR(adapter->ptp_clock)) {
 		adapter->ptp_clock = NULL;
 		e_err("ptp_clock_register failed\n");
-	} else {
+	} else if (adapter->ptp_clock) {
 		e_info("registered PHC clock\n");
 	}
 }
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
index ed39cbad24..f1feceab75 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
@@ -669,7 +669,7 @@ void i40e_ptp_init(struct i40e_pf *pf)
 		pf->ptp_clock = NULL;
 		dev_err(&pf->pdev->dev, "%s: ptp_clock_register failed\n",
 			__func__);
-	} else {
+	} else if (pf->ptp_clock) {
 		struct timespec64 ts;
 		u32 regval;
 
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 66dfa2085c..1dd14e166d 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -1159,7 +1159,7 @@ void igb_ptp_init(struct igb_adapter *adapter)
 	if (IS_ERR(adapter->ptp_clock)) {
 		adapter->ptp_clock = NULL;
 		dev_err(&adapter->pdev->dev, "ptp_clock_register failed\n");
-	} else {
+	} else if (adapter->ptp_clock) {
 		dev_info(&adapter->pdev->dev, "added PHC on %s\n",
 			 adapter->netdev->name);
 		adapter->ptp_flags |= IGB_PTP_ENABLED;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index e5431bfe33..a92277683a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -1254,7 +1254,7 @@ static long ixgbe_ptp_create_clock(struct ixgbe_adapter *adapter)
 		adapter->ptp_clock = NULL;
 		e_dev_err("ptp_clock_register failed\n");
 		return err;
-	} else
+	} else if (adapter->ptp_clock)
 		e_dev_info("registered PHC device on %s\n", netdev->name);
 
 	/* set default timestamp mode to disabled here. We do this in
diff --git a/drivers/net/ethernet/mellanox/mlx4/Kconfig b/drivers/net/ethernet/mellanox/mlx4/Kconfig
index 5098e7f219..b2998bc5ab 100644
--- a/drivers/net/ethernet/mellanox/mlx4/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx4/Kconfig
@@ -7,7 +7,7 @@ config MLX4_EN
 	depends on MAY_USE_DEVLINK
 	depends on PCI
 	select MLX4_CORE
-	select PTP_1588_CLOCK
+	select PTP_1588_CLOCK_SELECTED
 	---help---
 	  This driver supports Mellanox Technologies ConnectX Ethernet
 	  devices.
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_clock.c b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
index 1494997c4f..08fc5fc56d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
@@ -298,7 +298,7 @@ void mlx4_en_init_timestamp(struct mlx4_en_dev *mdev)
 	if (IS_ERR(mdev->ptp_clock)) {
 		mdev->ptp_clock = NULL;
 		mlx4_err(mdev, "ptp_clock_register failed\n");
-	} else {
+	} else if (mdev->ptp_clock) {
 		mlx4_info(mdev, "registered PHC clock\n");
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index aae46884bf..0d679346dc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -14,7 +14,7 @@ config MLX5_CORE
 config MLX5_CORE_EN
 	bool "Mellanox Technologies ConnectX-4 Ethernet support"
 	depends on NETDEVICES && ETHERNET && PCI && MLX5_CORE
-	select PTP_1588_CLOCK
+	select PTP_1588_CLOCK_SELECTED
 	default n
 	---help---
 	  Ethernet support in Mellanox Technologies ConnectX-4 NIC.
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
index 847a8f3ac2..13dc388667 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
@@ -273,7 +273,7 @@ void mlx5e_timestamp_init(struct mlx5e_priv *priv)
 
 	tstamp->ptp = ptp_clock_register(&tstamp->ptp_info,
 					 &priv->mdev->pdev->dev);
-	if (IS_ERR_OR_NULL(tstamp->ptp)) {
+	if (IS_ERR(tstamp->ptp)) {
 		mlx5_core_warn(priv->mdev, "ptp_clock_register failed %ld\n",
 			       PTR_ERR(tstamp->ptp));
 		tstamp->ptp = NULL;
diff --git a/drivers/net/ethernet/renesas/Kconfig b/drivers/net/ethernet/renesas/Kconfig
index 4f132cf177..6862a9c1b6 100644
--- a/drivers/net/ethernet/renesas/Kconfig
+++ b/drivers/net/ethernet/renesas/Kconfig
@@ -37,7 +37,7 @@ config RAVB
 	select MII
 	select MDIO_BITBANG
 	select PHYLIB
-	select PTP_1588_CLOCK
+	select PTP_1588_CLOCK_SELECTED
 	help
 	  Renesas Ethernet AVB device driver.
 	  This driver supports the following SoCs:
diff --git a/drivers/net/ethernet/samsung/Kconfig b/drivers/net/ethernet/samsung/Kconfig
index 2360d81507..121b7e4426 100644
--- a/drivers/net/ethernet/samsung/Kconfig
+++ b/drivers/net/ethernet/samsung/Kconfig
@@ -21,7 +21,7 @@ config SXGBE_ETH
 	depends on HAS_IOMEM && HAS_DMA
 	select PHYLIB
 	select CRC32
-	select PTP_1588_CLOCK
+	select PTP_1588_CLOCK_SELECTED
 	---help---
 	  This is the driver for the SXGBE 10G Ethernet IP block found on
 	  Samsung platforms.
diff --git a/drivers/net/ethernet/sfc/Kconfig b/drivers/net/ethernet/sfc/Kconfig
index 4dd92b7b80..472152bd72 100644
--- a/drivers/net/ethernet/sfc/Kconfig
+++ b/drivers/net/ethernet/sfc/Kconfig
@@ -5,7 +5,7 @@ config SFC
 	select CRC32
 	select I2C
 	select I2C_ALGOBIT
-	select PTP_1588_CLOCK
+	select PTP_1588_CLOCK_SELECTED
 	---help---
 	  This driver supports 10/40-gigabit Ethernet cards based on
 	  the Solarflare SFC4000, SFC9000-family and SFC9100-family
diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index dd204d9704..77a5364f7a 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -1269,13 +1269,13 @@ int efx_ptp_probe(struct efx_nic *efx, struct efx_channel *channel)
 		if (IS_ERR(ptp->phc_clock)) {
 			rc = PTR_ERR(ptp->phc_clock);
 			goto fail3;
-		}
-
-		INIT_WORK(&ptp->pps_work, efx_ptp_pps_worker);
-		ptp->pps_workwq = create_singlethread_workqueue("sfc_pps");
-		if (!ptp->pps_workwq) {
-			rc = -ENOMEM;
-			goto fail4;
+		} else if (ptp->phc_clock) {
+			INIT_WORK(&ptp->pps_work, efx_ptp_pps_worker);
+			ptp->pps_workwq = create_singlethread_workqueue("sfc_pps");
+			if (!ptp->pps_workwq) {
+				rc = -ENOMEM;
+				goto fail4;
+			}
 		}
 	}
 	ptp->nic_ts_enabled = false;
diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index 8f06a6621a..578e5a15cb 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -4,7 +4,7 @@ config STMMAC_ETH
 	select MII
 	select PHYLIB
 	select CRC32
-	select PTP_1588_CLOCK
+	select PTP_1588_CLOCK_SELECTED
 	select RESET_CONTROLLER
 	---help---
 	  This is the driver for the Ethernet IPs are built around a
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
index 170a18b612..6e3b82972c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
@@ -187,7 +187,7 @@ int stmmac_ptp_register(struct stmmac_priv *priv)
 	if (IS_ERR(priv->ptp_clock)) {
 		priv->ptp_clock = NULL;
 		pr_err("ptp_clock_register() failed on %s\n", priv->dev->name);
-	} else
+	} else if (priv->ptp_clock)
 		pr_debug("Added PTP HW clock successfully on %s\n",
 			 priv->dev->name);
 
diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
index 9904d740d5..bc895114c9 100644
--- a/drivers/net/ethernet/ti/Kconfig
+++ b/drivers/net/ethernet/ti/Kconfig
@@ -76,7 +76,7 @@ config TI_CPSW
 config TI_CPTS
 	bool "TI Common Platform Time Sync (CPTS) Support"
 	depends on TI_CPSW
-	select PTP_1588_CLOCK
+	select PTP_1588_CLOCK_SELECTED
 	---help---
 	  This driver supports the Common Platform Time Sync unit of
 	  the CPSW Ethernet Switch. The unit can time stamp PTP UDP/IPv4
diff --git a/drivers/net/ethernet/tile/Kconfig b/drivers/net/ethernet/tile/Kconfig
index f59a6c2653..b6ba43c78c 100644
--- a/drivers/net/ethernet/tile/Kconfig
+++ b/drivers/net/ethernet/tile/Kconfig
@@ -9,7 +9,7 @@ config TILE_NET
 	select CRC32
 	select TILE_GXIO_MPIPE if TILEGX
 	select HIGH_RES_TIMERS if TILEGX
-	select PTP_1588_CLOCK if TILEGX
+	select PTP_1588_CLOCK_SELECTED if TILEGX
 	---help---
 	  This is a standard Linux network device driver for the
 	  on-chip Tilera Gigabit Ethernet and XAUI interfaces.
diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
index ee3de3421f..f34b3748c0 100644
--- a/drivers/ptp/Kconfig
+++ b/drivers/ptp/Kconfig
@@ -4,8 +4,12 @@
 
 menu "PTP clock support"
 
+config PTP_1588_CLOCK_SELECTED
+	tristate
+
 config PTP_1588_CLOCK
 	tristate "PTP clock support"
+	default PTP_1588_CLOCK_SELECTED
 	depends on NET
 	select PPS
 	select NET_PTP_CLASSIFY
@@ -28,7 +32,7 @@ config PTP_1588_CLOCK
 config PTP_1588_CLOCK_GIANFAR
 	tristate "Freescale eTSEC as PTP clock"
 	depends on GIANFAR
-	select PTP_1588_CLOCK
+	depends on PTP_1588_CLOCK
 	default y
 	help
 	  This driver adds support for using the eTSEC as a PTP
@@ -42,7 +46,7 @@ config PTP_1588_CLOCK_GIANFAR
 config PTP_1588_CLOCK_IXP46X
 	tristate "Intel IXP46x as PTP clock"
 	depends on IXP4XX_ETH
-	select PTP_1588_CLOCK
+	depends on PTP_1588_CLOCK
 	default y
 	help
 	  This driver adds support for using the IXP46X as a PTP
@@ -60,7 +64,7 @@ config DP83640_PHY
 	tristate "Driver for the National Semiconductor DP83640 PHYTER"
 	depends on NETWORK_PHY_TIMESTAMPING
 	depends on PHYLIB
-	select PTP_1588_CLOCK
+	depends on PTP_1588_CLOCK
 	---help---
 	  Supports the DP83640 PHYTER with IEEE 1588 features.
 
@@ -76,7 +80,7 @@ config PTP_1588_CLOCK_PCH
 	tristate "Intel PCH EG20T as PTP clock"
 	depends on X86_32 || COMPILE_TEST
 	depends on HAS_IOMEM && NET
-	select PTP_1588_CLOCK
+	select PTP_1588_CLOCK_SELECTED
 	help
 	  This driver adds support for using the PCH EG20T as a PTP
 	  clock. The hardware supports time stamping of PTP packets
diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_kernel.h
index 6b15e16814..4c29eb8e53 100644
--- a/include/linux/ptp_clock_kernel.h
+++ b/include/linux/ptp_clock_kernel.h
@@ -122,24 +122,6 @@ struct ptp_clock_info {
 
 struct ptp_clock;
 
-/**
- * ptp_clock_register() - register a PTP hardware clock driver
- *
- * @info:   Structure describing the new clock.
- * @parent: Pointer to the parent device of the new clock.
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
 
 enum ptp_clock_events {
 	PTP_CLOCK_ALARM,
@@ -166,6 +148,31 @@ struct ptp_clock_event {
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
@@ -197,4 +204,20 @@ extern int ptp_clock_index(struct ptp_clock *ptp);
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
+{ (void)event; }
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

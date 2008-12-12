From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 23/33] sfc: Add support for SFN4111T
Date: Fri, 12 Dec 2008 12:56:24 +0000
Message-ID: <20081212125623.GW10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:56202 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757729AbYLLM40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 07:56:26 -0500
Content-Disposition: inline
In-Reply-To: <20081212124622.GK32518@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support code for the SFN4111T 100/1000/10GBASE-T reference design,
based in part on the existing code for the SFE4001.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/boards.c        |    2 +
 drivers/net/sfc/boards.h        |    7 ++-
 drivers/net/sfc/falcon.c        |    7 ++
 drivers/net/sfc/falcon_hwdefs.h |    2 +
 drivers/net/sfc/selftest.c      |   11 +++-
 drivers/net/sfc/sfe4001.c       |  153 +++++++++++++++++++++++++++++++--------
 drivers/net/sfc/workarounds.h   |    3 +-
 7 files changed, 150 insertions(+), 35 deletions(-)

diff --git a/drivers/net/sfc/boards.c b/drivers/net/sfc/boards.c
index 08fa4e3..6490349 100644
--- a/drivers/net/sfc/boards.c
+++ b/drivers/net/sfc/boards.c
@@ -241,6 +241,8 @@ struct efx_board_data {
 static struct efx_board_data board_data[] = {
 	{ EFX_BOARD_SFE4001, "SFE4001", "10GBASE-T adapter", sfe4001_init },
 	{ EFX_BOARD_SFE4002, "SFE4002", "XFP adapter", sfe4002_init },
+	{ EFX_BOARD_SFN4111T, "SFN4111T", "100/1000/10GBASE-T adapter",
+	  sfn4111t_init },
 };
 
 void efx_set_board_info(struct efx_nic *efx, u16 revision_info)
diff --git a/drivers/net/sfc/boards.h b/drivers/net/sfc/boards.h
index 5e0dde5..d93c6c6 100644
--- a/drivers/net/sfc/boards.h
+++ b/drivers/net/sfc/boards.h
@@ -12,11 +12,16 @@
 
 /* Board IDs (must fit in 8 bits) */
 enum efx_board_type {
-	EFX_BOARD_SFE4001 = 1,   /* SFE4001 (10GBASE-T) */
+	EFX_BOARD_SFE4001 = 1,
 	EFX_BOARD_SFE4002 = 2,
+	EFX_BOARD_SFN4111T = 0x51,
 };
 
 extern void efx_set_board_info(struct efx_nic *efx, u16 revision_info);
+
+/* SFE4001 (10GBASE-T) */
 extern int sfe4001_init(struct efx_nic *efx);
+/* SFN4111T (100/1000/10GBASE-T) */
+extern int sfn4111t_init(struct efx_nic *efx);
 
 #endif
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 68747c8..2c53ef4 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2982,6 +2982,13 @@ int falcon_init_nic(struct efx_nic *efx)
 	EFX_SET_OWORD_FIELD(temp, ONCHIP_SRAM, 1);
 	falcon_write(efx, &temp, NIC_STAT_REG);
 
+	/* Set the source of the GMAC clock */
+	if (falcon_rev(efx) == FALCON_REV_B0) {
+		falcon_read(efx, &temp, GPIO_CTL_REG_KER);
+		EFX_SET_OWORD_FIELD(temp, GPIO_USE_NIC_CLK, true);
+		falcon_write(efx, &temp, GPIO_CTL_REG_KER);
+	}
+
 	/* Set buffer table mode */
 	EFX_POPULATE_OWORD_1(temp, BUF_TBL_MODE, BUF_TBL_MODE_FULL);
 	falcon_write(efx, &temp, BUF_TBL_CFG_REG_KER);
diff --git a/drivers/net/sfc/falcon_hwdefs.h b/drivers/net/sfc/falcon_hwdefs.h
index a58c627..bda8d5b 100644
--- a/drivers/net/sfc/falcon_hwdefs.h
+++ b/drivers/net/sfc/falcon_hwdefs.h
@@ -136,6 +136,8 @@
 
 /* GPIO control register */
 #define GPIO_CTL_REG_KER 0x0210
+#define GPIO_USE_NIC_CLK_LBN (30)
+#define GPIO_USE_NIC_CLK_WIDTH (1)
 #define GPIO_OUTPUTS_LBN   (16)
 #define GPIO_OUTPUTS_WIDTH (4)
 #define GPIO_INPUTS_LBN (8)
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 578b7f4..6bb09f2 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -702,8 +702,15 @@ int efx_offline_test(struct efx_nic *efx,
 	 */
 	mutex_lock(&efx->mac_lock);
 	efx->port_inhibited = true;
-	if (efx->loopback_modes)
-		efx->loopback_mode = __ffs(efx->loopback_modes);
+	if (efx->loopback_modes) {
+		/* We need the 312 clock from the PHY to test the XMAC
+		 * registers, so move into XGMII loopback if available */
+		if (efx->loopback_modes & (1 << LOOPBACK_XGMII))
+			efx->loopback_mode = LOOPBACK_XGMII;
+		else
+			efx->loopback_mode = __ffs(efx->loopback_modes);
+	}
+
 	__efx_reconfigure_port(efx);
 	mutex_unlock(&efx->mac_lock);
 
diff --git a/drivers/net/sfc/sfe4001.c b/drivers/net/sfc/sfe4001.c
index af65284..16b80ac 100644
--- a/drivers/net/sfc/sfe4001.c
+++ b/drivers/net/sfc/sfe4001.c
@@ -1,6 +1,6 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2007 Solarflare Communications Inc.
+ * Copyright 2007-2008 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
@@ -8,10 +8,21 @@
  */
 
 /*****************************************************************************
- * Support for the SFE4001 NIC: driver code for the PCA9539 I/O expander that
- * controls the PHY power rails, and for the MAX6647 temp. sensor used to check
- * the PHY
+ * Support for the SFE4001 and SFN4111T NICs.
+ *
+ * The SFE4001 does not power-up fully at reset due to its high power
+ * consumption.  We control its power via a PCA9539 I/O expander.
+ * Both boards have a MAX6647 temperature monitor which we expose to
+ * the lm90 driver.
+ *
+ * This also provides minimal support for reflashing the PHY, which is
+ * initiated by resetting it with the FLASH_CFG_1 pin pulled down.
+ * On SFE4001 rev A2 and later this is connected to the 3V3X output of
+ * the IO-expander; on the SFN4111T it is connected to Falcon's GPIO3.
+ * We represent reflash mode as PHY_MODE_SPECIAL and make it mutually
+ * exclusive with the network device being open.
  */
+
 #include <linux/delay.h>
 #include "net_driver.h"
 #include "efx.h"
@@ -171,39 +182,30 @@ fail_on:
 	return rc;
 }
 
-static int sfe4001_check_hw(struct efx_nic *efx)
+static int sfn4111t_reset(struct efx_nic *efx)
 {
-	s32 status;
+	efx_oword_t reg;
 
-	/* If XAUI link is up then do not monitor */
-	if (EFX_WORKAROUND_7884(efx) && efx->mac_up)
-		return 0;
+	/* GPIO pins are also used for I2C, so block that temporarily */
+	mutex_lock(&efx->i2c_adap.bus_lock);
 
-	/* Check the powered status of the PHY. Lack of power implies that
-	 * the MAX6647 has shut down power to it, probably due to a temp.
-	 * alarm. Reading the power status rather than the MAX6647 status
-	 * directly because the later is read-to-clear and would thus
-	 * start to power up the PHY again when polled, causing us to blip
-	 * the power undesirably.
-	 * We know we can read from the IO expander because we did
-	 * it during power-on. Assume failure now is bad news. */
-	status = i2c_smbus_read_byte_data(efx->board_info.ioexp_client, P1_IN);
-	if (status >= 0 &&
-	    (status & ((1 << P1_AFE_PWD_LBN) | (1 << P1_DSP_PWD25_LBN))) != 0)
-		return 0;
+	falcon_read(efx, &reg, GPIO_CTL_REG_KER);
+	EFX_SET_OWORD_FIELD(reg, GPIO2_OEN, true);
+	EFX_SET_OWORD_FIELD(reg, GPIO2_OUT, false);
+	falcon_write(efx, &reg, GPIO_CTL_REG_KER);
+	msleep(1000);
+	EFX_SET_OWORD_FIELD(reg, GPIO2_OUT, true);
+	EFX_SET_OWORD_FIELD(reg, GPIO3_OEN, true);
+	EFX_SET_OWORD_FIELD(reg, GPIO3_OUT,
+			    !(efx->phy_mode & PHY_MODE_SPECIAL));
+	falcon_write(efx, &reg, GPIO_CTL_REG_KER);
 
-	/* Use board power control, not PHY power control */
-	sfe4001_poweroff(efx);
-	efx->phy_mode = PHY_MODE_OFF;
+	mutex_unlock(&efx->i2c_adap.bus_lock);
 
-	return (status < 0) ? -EIO : -ERANGE;
+	ssleep(1);
+	return 0;
 }
 
-/* On SFE4001 rev A2 and later, we can control the FLASH_CFG_1 pin
- * using the 3V3X output of the IO-expander.  Allow the user to set
- * this when the device is stopped, and keep it stopped then.
- */
-
 static ssize_t show_phy_flash_cfg(struct device *dev,
 				  struct device_attribute *attr, char *buf)
 {
@@ -231,7 +233,10 @@ static ssize_t set_phy_flash_cfg(struct device *dev,
 		err = -EBUSY;
 	} else {
 		efx->phy_mode = new_mode;
-		err = sfe4001_poweron(efx);
+		if (efx->board_info.type == EFX_BOARD_SFE4001)
+			err = sfe4001_poweron(efx);
+		else
+			err = sfn4111t_reset(efx);
 		efx_reconfigure_port(efx);
 	}
 	rtnl_unlock();
@@ -251,6 +256,34 @@ static void sfe4001_fini(struct efx_nic *efx)
 	i2c_unregister_device(efx->board_info.hwmon_client);
 }
 
+static int sfe4001_check_hw(struct efx_nic *efx)
+{
+	s32 status;
+
+	/* If XAUI link is up then do not monitor */
+	if (EFX_WORKAROUND_7884(efx) && efx->mac_up)
+		return 0;
+
+	/* Check the powered status of the PHY. Lack of power implies that
+	 * the MAX6647 has shut down power to it, probably due to a temp.
+	 * alarm. Reading the power status rather than the MAX6647 status
+	 * directly because the later is read-to-clear and would thus
+	 * start to power up the PHY again when polled, causing us to blip
+	 * the power undesirably.
+	 * We know we can read from the IO expander because we did
+	 * it during power-on. Assume failure now is bad news. */
+	status = i2c_smbus_read_byte_data(efx->board_info.ioexp_client, P1_IN);
+	if (status >= 0 &&
+	    (status & ((1 << P1_AFE_PWD_LBN) | (1 << P1_DSP_PWD25_LBN))) != 0)
+		return 0;
+
+	/* Use board power control, not PHY power control */
+	sfe4001_poweroff(efx);
+	efx->phy_mode = PHY_MODE_OFF;
+
+	return (status < 0) ? -EIO : -ERANGE;
+}
+
 static struct i2c_board_info sfe4001_hwmon_info = {
 	I2C_BOARD_INFO("max6647", 0x4e),
 	.irq		= -1,
@@ -312,3 +345,61 @@ fail_hwmon:
 	i2c_unregister_device(efx->board_info.hwmon_client);
 	return rc;
 }
+
+static int sfn4111t_check_hw(struct efx_nic *efx)
+{
+	s32 status;
+
+	/* If XAUI link is up then do not monitor */
+	if (EFX_WORKAROUND_7884(efx) && efx->mac_up)
+		return 0;
+
+	/* Test LHIGH, RHIGH, FAULT, EOT and IOT alarms */
+	status = i2c_smbus_read_byte_data(efx->board_info.hwmon_client,
+					  MAX664X_REG_RSL);
+	if (status < 0)
+		return -EIO;
+	if (status & 0x57)
+		return -ERANGE;
+	return 0;
+}
+
+static void sfn4111t_fini(struct efx_nic *efx)
+{
+	EFX_INFO(efx, "%s\n", __func__);
+
+	device_remove_file(&efx->pci_dev->dev, &dev_attr_phy_flash_cfg);
+	i2c_unregister_device(efx->board_info.hwmon_client);
+}
+
+static struct i2c_board_info sfn4111t_hwmon_info = {
+	I2C_BOARD_INFO("max6647", 0x4e),
+	.irq		= -1,
+};
+
+int sfn4111t_init(struct efx_nic *efx)
+{
+	int rc;
+
+	efx->board_info.hwmon_client =
+		i2c_new_device(&efx->i2c_adap, &sfn4111t_hwmon_info);
+	if (!efx->board_info.hwmon_client)
+		return -EIO;
+
+	efx->board_info.blink = tenxpress_phy_blink;
+	efx->board_info.monitor = sfn4111t_check_hw;
+	efx->board_info.fini = sfn4111t_fini;
+
+	rc = device_create_file(&efx->pci_dev->dev, &dev_attr_phy_flash_cfg);
+	if (rc)
+		goto fail_hwmon;
+
+	if (efx->phy_mode & PHY_MODE_SPECIAL)
+		sfn4111t_reset(efx);
+
+	return 0;
+
+fail_hwmon:
+	i2c_unregister_device(efx->board_info.hwmon_client);
+	return rc;
+}
diff --git a/drivers/net/sfc/workarounds.h b/drivers/net/sfc/workarounds.h
index ecebff2..82e03e1 100644
--- a/drivers/net/sfc/workarounds.h
+++ b/drivers/net/sfc/workarounds.h
@@ -17,6 +17,7 @@
 
 #define EFX_WORKAROUND_ALWAYS(efx) 1
 #define EFX_WORKAROUND_FALCON_A(efx) (falcon_rev(efx) <= FALCON_REV_A1)
+#define EFX_WORKAROUND_10G(efx) EFX_IS10G(efx)
 #define EFX_WORKAROUND_SFX7101(efx) ((efx)->phy_type == PHY_TYPE_SFX7101)
 #define EFX_WORKAROUND_SFT9001A(efx) ((efx)->phy_type == PHY_TYPE_SFT9001A)
 
@@ -25,7 +26,7 @@
 /* RX PCIe double split performance issue */
 #define EFX_WORKAROUND_7575 EFX_WORKAROUND_ALWAYS
 /* Bit-bashed I2C reads cause performance drop */
-#define EFX_WORKAROUND_7884 EFX_WORKAROUND_ALWAYS
+#define EFX_WORKAROUND_7884 EFX_WORKAROUND_10G
 /* TX pkt parser problem with <= 16 byte TXes */
 #define EFX_WORKAROUND_9141 EFX_WORKAROUND_ALWAYS
 /* Low rate CRC errors require XAUI reset */
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

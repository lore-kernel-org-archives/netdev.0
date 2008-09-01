From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 30/52] sfc: Make PHY flash mode a device attribute, not a module parameter
Date: Mon, 1 Sep 2008 12:48:17 +0100
Message-ID: <20080901114816.GX7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:60946 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758566AbYIALsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:48:20 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows updating PHY firmware for one interface without removing
all other interfaces handled by the driver.

Replace tx_disabled flags and 10Xpress status enumeration with flags in
enum efx_phy_mode.

Prevent an interface from being brought up while in PHY flash mode.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/boards.h      |    2 -
 drivers/net/sfc/efx.c         |    3 +
 drivers/net/sfc/falcon_xmac.c |   15 ++--
 drivers/net/sfc/mdio_10g.c    |    4 +-
 drivers/net/sfc/net_driver.h  |   21 ++++-
 drivers/net/sfc/phy.h         |    8 --
 drivers/net/sfc/sfe4001.c     |  186 ++++++++++++++++++++++++++---------------
 drivers/net/sfc/tenxpress.c   |   46 ++++-------
 drivers/net/sfc/xfp_phy.c     |    9 +-
 9 files changed, 171 insertions(+), 123 deletions(-)

diff --git a/drivers/net/sfc/boards.h b/drivers/net/sfc/boards.h
index e5e8443..c6e01b6 100644
--- a/drivers/net/sfc/boards.h
+++ b/drivers/net/sfc/boards.h
@@ -21,7 +21,5 @@ enum efx_board_type {
 
 extern int efx_set_board_info(struct efx_nic *efx, u16 revision_info);
 extern int sfe4001_init(struct efx_nic *efx);
-/* Are we putting the PHY into flash config mode */
-extern unsigned int sfe4001_phy_flash_cfg;
 
 #endif
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 864095e..d41a6e3 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1296,6 +1296,9 @@ static int efx_net_open(struct net_device *net_dev)
 	EFX_LOG(efx, "opening device %s on CPU %d\n", net_dev->name,
 		raw_smp_processor_id());
 
+	if (efx->phy_mode & PHY_MODE_SPECIAL)
+		return -EBUSY;
+
 	efx_start_all(efx);
 	return 0;
 }
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index be5a86f..5620d9d 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -69,10 +69,6 @@ static int falcon_reset_xmac(struct efx_nic *efx)
 		udelay(10);
 	}
 
-	/* This often fails when DSP is disabled, ignore it */
-	if (sfe4001_phy_flash_cfg)
-		return 0;
-
 	EFX_ERR(efx, "timed out waiting for XMAC core reset\n");
 	return -ETIMEDOUT;
 }
@@ -444,7 +440,8 @@ static bool falcon_check_xaui_link_up(struct efx_nic *efx)
 	max_tries = tries;
 
 	if ((efx->loopback_mode == LOOPBACK_NETWORK) ||
-	    (efx->phy_type == PHY_TYPE_NONE))
+	    (efx->phy_type == PHY_TYPE_NONE) ||
+	    efx_phy_mode_disabled(efx->phy_mode))
 		return false;
 
 	while (tries) {
@@ -471,7 +468,11 @@ void falcon_reconfigure_xmac(struct efx_nic *efx)
 
 	falcon_deconfigure_mac_wrapper(efx);
 
-	efx->tx_disabled = LOOPBACK_INTERNAL(efx);
+	/* Reconfigure the PHY, disabling transmit in mac level loopback. */
+	if (LOOPBACK_INTERNAL(efx))
+		efx->phy_mode |= PHY_MODE_TX_DISABLED;
+	else
+		efx->phy_mode &= ~PHY_MODE_TX_DISABLED;
 	efx->phy_op->reconfigure(efx);
 
 	falcon_reconfigure_xgxs_core(efx);
@@ -566,7 +567,7 @@ int falcon_check_xmac(struct efx_nic *efx)
 	int rc;
 
 	if ((efx->loopback_mode == LOOPBACK_NETWORK) ||
-	    (efx->phy_type == PHY_TYPE_NONE))
+	    efx_phy_mode_disabled(efx->phy_mode))
 		return 0;
 
 	falcon_mask_status_intr(efx, false);
diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index 4064946..003e48d 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -172,6 +172,8 @@ bool mdio_clause45_links_ok(struct efx_nic *efx, unsigned int mmd_mask)
 		return true;
 	else if (efx->loopback_mode == LOOPBACK_NETWORK)
 		return false;
+	else if (efx_phy_mode_disabled(efx->phy_mode))
+		return false;
 	else if (efx->loopback_mode == LOOPBACK_PHYXS)
 		mmd_mask &= ~(MDIO_MMDREG_DEVS0_PHYXS |
 			      MDIO_MMDREG_DEVS0_PCS |
@@ -206,7 +208,7 @@ void mdio_clause45_transmit_disable(struct efx_nic *efx)
 
 	ctrl1 = ctrl2 = mdio_clause45_read(efx, phy_id, MDIO_MMD_PMAPMD,
 					   MDIO_MMDREG_TXDIS);
-	if (efx->tx_disabled)
+	if (efx->phy_mode & PHY_MODE_TX_DISABLED)
 		ctrl2 |= (1 << MDIO_MMDREG_TXDIS_GLOBAL_LBN);
 	else
 		ctrl1 &= ~(1 << MDIO_MMDREG_TXDIS_GLOBAL_LBN);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index e65d661..df863bc 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -519,6 +519,23 @@ struct efx_phy_operations {
 	unsigned loopbacks;
 };
 
+/**
+ * @enum efx_phy_mode - PHY operating mode flags
+ * @PHY_MODE_NORMAL: on and should pass traffic
+ * @PHY_MODE_TX_DISABLED: on with TX disabled
+ * @PHY_MODE_SPECIAL: on but will not pass traffic
+ */
+enum efx_phy_mode {
+	PHY_MODE_NORMAL		= 0,
+	PHY_MODE_TX_DISABLED	= 1,
+	PHY_MODE_SPECIAL	= 8,
+};
+
+static inline bool efx_phy_mode_disabled(enum efx_phy_mode mode)
+{
+	return (mode & ~PHY_MODE_TX_DISABLED) != 0;
+}
+
 /*
  * Efx extended statistics
  *
@@ -661,7 +678,7 @@ union efx_multicast_hash {
  * @phy_op: PHY interface
  * @phy_data: PHY private data (including PHY-specific stats)
  * @mii: PHY interface
- * @tx_disabled: PHY transmitter turned off
+ * @phy_mode: PHY operating mode
  * @link_up: Link status
  * @link_options: Link options (MII/GMII format)
  * @n_link_state_changes: Number of times the link has changed state
@@ -735,7 +752,7 @@ struct efx_nic {
 	struct efx_phy_operations *phy_op;
 	void *phy_data;
 	struct mii_if_info mii;
-	bool tx_disabled;
+	enum efx_phy_mode phy_mode;
 
 	bool link_up;
 	unsigned int link_options;
diff --git a/drivers/net/sfc/phy.h b/drivers/net/sfc/phy.h
index 25bd18e..f746536 100644
--- a/drivers/net/sfc/phy.h
+++ b/drivers/net/sfc/phy.h
@@ -15,14 +15,6 @@
  */
 extern struct efx_phy_operations falcon_tenxpress_phy_ops;
 
-enum tenxpress_state {
-	TENXPRESS_STATUS_OFF = 0,
-	TENXPRESS_STATUS_OTEMP = 1,
-	TENXPRESS_STATUS_NORMAL = 2,
-};
-
-extern void tenxpress_set_state(struct efx_nic *efx,
-				enum tenxpress_state state);
 extern void tenxpress_phy_blink(struct efx_nic *efx, bool blink);
 extern void tenxpress_crc_err(struct efx_nic *efx);
 
diff --git a/drivers/net/sfc/sfe4001.c b/drivers/net/sfc/sfe4001.c
index f927281..d90fab5 100644
--- a/drivers/net/sfc/sfe4001.c
+++ b/drivers/net/sfc/sfe4001.c
@@ -13,6 +13,7 @@
  * the PHY
  */
 #include <linux/delay.h>
+#include "net_driver.h"
 #include "efx.h"
 #include "phy.h"
 #include "boards.h"
@@ -120,52 +121,15 @@ static void sfe4001_poweroff(struct efx_nic *efx)
 	i2c_smbus_read_byte_data(hwmon_client, RSL);
 }
 
-static void sfe4001_fini(struct efx_nic *efx)
+static int sfe4001_poweron(struct efx_nic *efx)
 {
-	EFX_INFO(efx, "%s\n", __func__);
-
-	sfe4001_poweroff(efx);
- 	i2c_unregister_device(efx->board_info.ioexp_client);
- 	i2c_unregister_device(efx->board_info.hwmon_client);
-}
-
-/* The P0_EN_3V3X line on SFE4001 boards (from A2 onward) is connected
- * to the FLASH_CFG_1 input on the DSP.  We must keep it high at power-
- * up to allow writing the flash (done through MDIO from userland).
- */
-unsigned int sfe4001_phy_flash_cfg;
-module_param_named(phy_flash_cfg, sfe4001_phy_flash_cfg, uint, 0444);
-MODULE_PARM_DESC(phy_flash_cfg,
-		 "Force PHY to enter flash configuration mode");
-
-/* This board uses an I2C expander to provider power to the PHY, which needs to
- * be turned on before the PHY can be used.
- * Context: Process context, rtnl lock held
- */
-int sfe4001_init(struct efx_nic *efx)
-{
-	struct i2c_client *hwmon_client, *ioexp_client;
+	struct i2c_client *hwmon_client = efx->board_info.hwmon_client;
+	struct i2c_client *ioexp_client = efx->board_info.ioexp_client;
 	unsigned int i, j;
 	int rc;
 	u8 out;
 	efx_dword_t reg;
 
-	hwmon_client = i2c_new_dummy(&efx->i2c_adap, MAX6647);
-	if (!hwmon_client)
-		return -EIO;
-	efx->board_info.hwmon_client = hwmon_client;
-
-	ioexp_client = i2c_new_dummy(&efx->i2c_adap, PCA9539);
-	if (!ioexp_client) {
-		rc = -EIO;
-		goto fail_hwmon;
-	}
-	efx->board_info.ioexp_client = ioexp_client;
-
-	/* 10Xpress has fixed-function LED pins, so there is no board-specific
-	 * blink code. */
-	efx->board_info.blink = tenxpress_phy_blink;
-
 	/* Ensure that XGXS and XAUI SerDes are held in reset */
 	EFX_POPULATE_DWORD_7(reg, XX_PWRDNA_EN, 1,
 			     XX_PWRDNB_EN, 1,
@@ -177,33 +141,15 @@ int sfe4001_init(struct efx_nic *efx)
 	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
 	udelay(10);
 
-	efx->board_info.fini = sfe4001_fini;
-
-	/* Set DSP over-temperature alert threshold */
-	EFX_INFO(efx, "DSP cut-out at %dC\n", xgphy_max_temperature);
-	rc = i2c_smbus_write_byte_data(hwmon_client, WLHO,
-				       xgphy_max_temperature);
-	if (rc)
-		goto fail_ioexp;
-
-	/* Read it back and verify */
-	rc = i2c_smbus_read_byte_data(hwmon_client, RLHN);
-	if (rc < 0)
-		goto fail_ioexp;
-	if (rc != xgphy_max_temperature) {
-		rc = -EFAULT;
-		goto fail_ioexp;
-	}
-
 	/* Clear any previous over-temperature alert */
 	rc = i2c_smbus_read_byte_data(hwmon_client, RSL);
 	if (rc < 0)
-		goto fail_ioexp;
+		return rc;
 
 	/* Enable port 0 and port 1 outputs on IO expander */
 	rc = i2c_smbus_write_byte_data(ioexp_client, P0_CONFIG, 0x00);
 	if (rc)
-		goto fail_ioexp;
+		return rc;
 	rc = i2c_smbus_write_byte_data(ioexp_client, P1_CONFIG,
 				       0xff & ~(1 << P1_SPARE_LBN));
 	if (rc)
@@ -231,7 +177,7 @@ int sfe4001_init(struct efx_nic *efx)
 		out = 0xff & ~((1 << P0_EN_1V2_LBN) | (1 << P0_EN_2V5_LBN) |
 			       (1 << P0_EN_3V3X_LBN) | (1 << P0_EN_5V_LBN) |
 			       (1 << P0_X_TRST_LBN));
-		if (sfe4001_phy_flash_cfg)
+		if (efx->phy_mode & PHY_MODE_SPECIAL)
 			out |= 1 << P0_EN_3V3X_LBN;
 
 		rc = i2c_smbus_write_byte_data(ioexp_client, P0_OUT, out);
@@ -250,9 +196,9 @@ int sfe4001_init(struct efx_nic *efx)
 		/* In flash config mode, DSP does not turn on AFE, so
 		 * just wait 1 second.
 		 */
-		if (sfe4001_phy_flash_cfg) {
+		if (efx->phy_mode & PHY_MODE_SPECIAL) {
 			schedule_timeout_uninterruptible(HZ);
-			goto done;
+			return 0;
 		}
 
 		for (j = 0; j < 10; ++j) {
@@ -263,23 +209,127 @@ int sfe4001_init(struct efx_nic *efx)
 			if (rc < 0)
 				goto fail_on;
 			if (rc & (1 << P1_AFE_PWD_LBN))
-				goto done;
+				return 0;
 		}
 	}
 
 	EFX_INFO(efx, "timed out waiting for DSP boot\n");
 	rc = -ETIMEDOUT;
-	goto fail_on;
+fail_on:
+	sfe4001_poweroff(efx);
+	return rc;
+}
+
+/* On SFE4001 rev A2 and later, we can control the FLASH_CFG_1 pin
+ * using the 3V3X output of the IO-expander.  Allow the user to set
+ * this when the device is stopped, and keep it stopped then.
+ */
+
+static ssize_t show_phy_flash_cfg(struct device *dev,
+				  struct device_attribute *attr, char *buf)
+{
+	struct efx_nic *efx = pci_get_drvdata(to_pci_dev(dev));
+	return sprintf(buf, "%d\n", !!(efx->phy_mode & PHY_MODE_SPECIAL));
+}
+
+static ssize_t set_phy_flash_cfg(struct device *dev,
+				 struct device_attribute *attr,
+				 const char *buf, size_t count)
+{
+	struct efx_nic *efx = pci_get_drvdata(to_pci_dev(dev));
+	enum efx_phy_mode old_mode, new_mode;
+	int err;
+
+	rtnl_lock();
+	old_mode = efx->phy_mode;
+	if (count == 0 || *buf == '0')
+		new_mode = old_mode & ~PHY_MODE_SPECIAL;
+	else
+		new_mode = PHY_MODE_SPECIAL;
+	if (old_mode == new_mode) {
+		err = 0;
+	} else if (efx->state != STATE_RUNNING || netif_running(efx->net_dev)) {
+		err = -EBUSY;
+	} else {
+		efx->phy_mode = new_mode;
+		err = sfe4001_poweron(efx);
+		efx_reconfigure_port(efx);
+	}
+	rtnl_unlock();
+
+	return err ? err : count;
+}
+
+static DEVICE_ATTR(phy_flash_cfg, 0644, show_phy_flash_cfg, set_phy_flash_cfg);
+
+static void sfe4001_fini(struct efx_nic *efx)
+{
+	EFX_INFO(efx, "%s\n", __func__);
+
+	device_remove_file(&efx->pci_dev->dev, &dev_attr_phy_flash_cfg);
+	sfe4001_poweroff(efx);
+	i2c_unregister_device(efx->board_info.ioexp_client);
+	i2c_unregister_device(efx->board_info.hwmon_client);
+}
+
+/* This board uses an I2C expander to provider power to the PHY, which needs to
+ * be turned on before the PHY can be used.
+ * Context: Process context, rtnl lock held
+ */
+int sfe4001_init(struct efx_nic *efx)
+{
+	struct i2c_client *hwmon_client;
+	int rc;
+
+	hwmon_client = i2c_new_dummy(&efx->i2c_adap, MAX6647);
+	if (!hwmon_client)
+		return -EIO;
+	efx->board_info.hwmon_client = hwmon_client;
+
+	/* Set DSP over-temperature alert threshold */
+	EFX_INFO(efx, "DSP cut-out at %dC\n", xgphy_max_temperature);
+	rc = i2c_smbus_write_byte_data(hwmon_client, WLHO,
+				       xgphy_max_temperature);
+	if (rc)
+		goto fail_ioexp;
+
+	/* Read it back and verify */
+	rc = i2c_smbus_read_byte_data(hwmon_client, RLHN);
+	if (rc < 0)
+		goto fail_ioexp;
+	if (rc != xgphy_max_temperature) {
+		rc = -EFAULT;
+		goto fail_ioexp;
+	}
+
+	efx->board_info.ioexp_client = i2c_new_dummy(&efx->i2c_adap, PCA9539);
+	if (!efx->board_info.ioexp_client) {
+		rc = -EIO;
+		goto fail_hwmon;
+	}
+
+	/* 10Xpress has fixed-function LED pins, so there is no board-specific
+	 * blink code. */
+	efx->board_info.blink = tenxpress_phy_blink;
+
+	efx->board_info.fini = sfe4001_fini;
+
+	rc = sfe4001_poweron(efx);
+	if (rc)
+		goto fail_ioexp;
+
+	rc = device_create_file(&efx->pci_dev->dev, &dev_attr_phy_flash_cfg);
+	if (rc)
+		goto fail_on;
 
-done:
 	EFX_INFO(efx, "PHY is powered on\n");
 	return 0;
 
 fail_on:
 	sfe4001_poweroff(efx);
 fail_ioexp:
- 	i2c_unregister_device(ioexp_client);
+	i2c_unregister_device(efx->board_info.ioexp_client);
 fail_hwmon:
- 	i2c_unregister_device(hwmon_client);
+	i2c_unregister_device(hwmon_client);
 	return rc;
 }
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index b92b24b..499e127 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -119,27 +119,12 @@ MODULE_PARM_DESC(crc_error_reset_threshold,
 		 "Max number of CRC errors before XAUI reset");
 
 struct tenxpress_phy_data {
-	enum tenxpress_state state;
 	enum efx_loopback_mode loopback_mode;
 	atomic_t bad_crc_count;
-	bool tx_disabled;
+	enum efx_phy_mode phy_mode;
 	int bad_lp_tries;
 };
 
-static int tenxpress_state_is(struct efx_nic *efx, int state)
-{
-	struct tenxpress_phy_data *phy_data = efx->phy_data;
-	return (phy_data != NULL) && (state == phy_data->state);
-}
-
-void tenxpress_set_state(struct efx_nic *efx,
-				enum tenxpress_state state)
-{
-	struct tenxpress_phy_data *phy_data = efx->phy_data;
-	if (phy_data != NULL)
-		phy_data->state = state;
-}
-
 void tenxpress_crc_err(struct efx_nic *efx)
 {
 	struct tenxpress_phy_data *phy_data = efx->phy_data;
@@ -214,15 +199,12 @@ static int tenxpress_phy_init(struct efx_nic *efx)
 	if (!phy_data)
 		return -ENOMEM;
 	efx->phy_data = phy_data;
+	phy_data->phy_mode = efx->phy_mode;
 
-	tenxpress_set_state(efx, TENXPRESS_STATUS_NORMAL);
-
-	if (!sfe4001_phy_flash_cfg) {
-		rc = mdio_clause45_wait_reset_mmds(efx,
-						   TENXPRESS_REQUIRED_DEVS);
-		if (rc < 0)
-			goto fail;
-	}
+	rc = mdio_clause45_wait_reset_mmds(efx,
+					   TENXPRESS_REQUIRED_DEVS);
+	if (rc < 0)
+		goto fail;
 
 	rc = mdio_clause45_check_mmds(efx, TENXPRESS_REQUIRED_DEVS, 0);
 	if (rc < 0)
@@ -370,13 +352,16 @@ static void tenxpress_phy_reconfigure(struct efx_nic *efx)
 	bool loop_change = LOOPBACK_OUT_OF(phy_data, efx,
 					   TENXPRESS_LOOPBACKS);
 
-	if (!tenxpress_state_is(efx, TENXPRESS_STATUS_NORMAL))
+	if (efx->phy_mode & PHY_MODE_SPECIAL) {
+		phy_data->phy_mode = efx->phy_mode;
 		return;
+	}
 
 	/* When coming out of transmit disable, coming out of low power
 	 * mode, or moving out of any PHY internal loopback mode,
 	 * perform a special software reset */
-	if ((phy_data->tx_disabled && !efx->tx_disabled) ||
+	if ((efx->phy_mode == PHY_MODE_NORMAL &&
+	     phy_data->phy_mode != PHY_MODE_NORMAL) ||
 	    loop_change) {
 		tenxpress_special_reset(efx);
 		falcon_reset_xaui(efx);
@@ -386,8 +371,8 @@ static void tenxpress_phy_reconfigure(struct efx_nic *efx)
 	mdio_clause45_phy_reconfigure(efx);
 	tenxpress_phyxs_loopback(efx);
 
-	phy_data->tx_disabled = efx->tx_disabled;
 	phy_data->loopback_mode = efx->loopback_mode;
+	phy_data->phy_mode = efx->phy_mode;
 	efx->link_up = tenxpress_link_ok(efx, false);
 	efx->link_options = GM_LPA_10000FULL;
 }
@@ -402,16 +387,15 @@ static void tenxpress_phy_clear_interrupt(struct efx_nic *efx)
 static int tenxpress_phy_check_hw(struct efx_nic *efx)
 {
 	struct tenxpress_phy_data *phy_data = efx->phy_data;
-	bool phy_up = tenxpress_state_is(efx, TENXPRESS_STATUS_NORMAL);
 	bool link_ok;
 
-	link_ok = phy_up && tenxpress_link_ok(efx, true);
+	link_ok = (phy_data->phy_mode == PHY_MODE_NORMAL &&
+		   tenxpress_link_ok(efx, true));
 
 	if (link_ok != efx->link_up)
 		falcon_xmac_sim_phy_event(efx);
 
-	/* Nothing to check if we've already shut down the PHY */
-	if (!phy_up)
+	if (phy_data->phy_mode != PHY_MODE_NORMAL)
 		return 0;
 
 	if (atomic_read(&phy_data->bad_crc_count) > crc_error_reset_threshold) {
diff --git a/drivers/net/sfc/xfp_phy.c b/drivers/net/sfc/xfp_phy.c
index fd4045b..f6edecc 100644
--- a/drivers/net/sfc/xfp_phy.c
+++ b/drivers/net/sfc/xfp_phy.c
@@ -40,7 +40,7 @@ void xfp_set_led(struct efx_nic *p, int led, int mode)
 }
 
 struct xfp_phy_data {
-	bool tx_disabled;
+	enum efx_phy_mode phy_mode;
 };
 
 #define XFP_MAX_RESET_TIME 500
@@ -93,7 +93,7 @@ static int xfp_phy_init(struct efx_nic *efx)
 		 " %x)\n", devid, MDIO_ID_OUI(devid), MDIO_ID_MODEL(devid),
 		 MDIO_ID_REV(devid));
 
-	phy_data->tx_disabled = efx->tx_disabled;
+	phy_data->phy_mode = efx->phy_mode;
 
 	rc = xfp_reset_phy(efx);
 
@@ -136,13 +136,14 @@ static void xfp_phy_reconfigure(struct efx_nic *efx)
 	struct xfp_phy_data *phy_data = efx->phy_data;
 
 	/* Reset the PHY when moving from tx off to tx on */
-	if (phy_data->tx_disabled && !efx->tx_disabled)
+	if (!(efx->phy_mode & PHY_MODE_TX_DISABLED) &&
+	    (phy_data->phy_mode & PHY_MODE_TX_DISABLED))
 		xfp_reset_phy(efx);
 
 	mdio_clause45_transmit_disable(efx);
 	mdio_clause45_phy_reconfigure(efx);
 
-	phy_data->tx_disabled = efx->tx_disabled;
+	phy_data->phy_mode = efx->phy_mode;
 	efx->link_up = xfp_link_ok(efx);
 	efx->link_options = GM_LPA_10000FULL;
 }
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


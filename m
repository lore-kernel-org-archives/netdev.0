From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 4/6] sfc: Use lm87 and lm90 drivers for board temperature/power monitoring
Date: Tue, 4 Nov 2008 20:34:56 +0000
Message-ID: <20081104203455.GA7331@solarflare.com>
References: <20081104203117.GW7331@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:54255 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753794AbYKDUfB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 15:35:01 -0500
Content-Disposition: inline
In-Reply-To: <20081104203117.GW7331@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add board monitoring to periodic work whenever link is down.
For SFE4001, report when a fault has caused the PHY to turn off.
For SFE4002, switch XFP PHY into low-power state in case of a fault.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/boards.c      |  136 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/sfc/mdio_10g.c    |   35 +++++++++++
 drivers/net/sfc/mdio_10g.h    |    7 ++
 drivers/net/sfc/net_driver.h  |    6 ++
 drivers/net/sfc/sfe4001.c     |  116 ++++++++++++++++-------------------
 drivers/net/sfc/tenxpress.c   |   18 +++++-
 drivers/net/sfc/workarounds.h |    2 +
 drivers/net/sfc/xfp_phy.c     |    9 +++
 8 files changed, 265 insertions(+), 64 deletions(-)

diff --git a/drivers/net/sfc/boards.c b/drivers/net/sfc/boards.c
index 99e6023..edf0262 100644
--- a/drivers/net/sfc/boards.c
+++ b/drivers/net/sfc/boards.c
@@ -11,6 +11,7 @@
 #include "phy.h"
 #include "boards.h"
 #include "efx.h"
+#include "workarounds.h"
 
 /* Macros for unpacking the board revision */
 /* The revision info is in host byte order. */
@@ -52,9 +53,128 @@ static void board_blink(struct efx_nic *efx, bool blink)
 }
 
 /*****************************************************************************
+ * Support for LM87 sensor chip used on several boards
+ */
+#define LM87_REG_ALARMS1		0x41
+#define LM87_REG_ALARMS2		0x42
+#define LM87_IN_LIMITS(nr, _min, _max)			\
+	0x2B + (nr) * 2, _max, 0x2C + (nr) * 2, _min
+#define LM87_AIN_LIMITS(nr, _min, _max)			\
+	0x3B + (nr), _max, 0x1A + (nr), _min
+#define LM87_TEMP_INT_LIMITS(_min, _max)		\
+	0x39, _max, 0x3A, _min
+#define LM87_TEMP_EXT1_LIMITS(_min, _max)		\
+	0x37, _max, 0x38, _min
+
+#define LM87_ALARM_TEMP_INT		0x10
+#define LM87_ALARM_TEMP_EXT1		0x20
+
+#if defined(CONFIG_SENSORS_LM87) || defined(CONFIG_SENSORS_LM87_MODULE)
+
+static int efx_init_lm87(struct efx_nic *efx, struct i2c_board_info *info,
+			 const u8 *reg_values)
+{
+	struct i2c_client *client = i2c_new_device(&efx->i2c_adap, info);
+	int rc;
+
+	if (!client)
+		return -EIO;
+
+	while (*reg_values) {
+		u8 reg = *reg_values++;
+		u8 value = *reg_values++;
+		rc = i2c_smbus_write_byte_data(client, reg, value);
+		if (rc)
+			goto err;
+	}
+
+	efx->board_info.hwmon_client = client;
+	return 0;
+
+err:
+	i2c_unregister_device(client);
+	return rc;
+}
+
+static void efx_fini_lm87(struct efx_nic *efx)
+{
+	i2c_unregister_device(efx->board_info.hwmon_client);
+}
+
+static int efx_check_lm87(struct efx_nic *efx, unsigned mask)
+{
+	struct i2c_client *client = efx->board_info.hwmon_client;
+	s32 alarms1, alarms2;
+
+	/* If link is up then do not monitor temperature */
+	if (EFX_WORKAROUND_7884(efx) && efx->link_up)
+		return 0;
+
+	alarms1 = i2c_smbus_read_byte_data(client, LM87_REG_ALARMS1);
+	alarms2 = i2c_smbus_read_byte_data(client, LM87_REG_ALARMS2);
+	if (alarms1 < 0)
+		return alarms1;
+	if (alarms2 < 0)
+		return alarms2;
+	alarms1 &= mask;
+	alarms2 &= mask >> 8;
+	if (alarms1 || alarms2) {
+		EFX_ERR(efx,
+			"LM87 detected a hardware failure (status %02x:%02x)"
+			"%s%s\n",
+			alarms1, alarms2,
+			(alarms1 & LM87_ALARM_TEMP_INT) ? " INTERNAL" : "",
+			(alarms1 & LM87_ALARM_TEMP_EXT1) ? " EXTERNAL" : "");
+		return -ERANGE;
+	}
+
+	return 0;
+}
+
+#else /* !CONFIG_SENSORS_LM87 */
+
+static inline int
+efx_init_lm87(struct efx_nic *efx, struct i2c_board_info *info,
+	      const u8 *reg_values)
+{
+	return 0;
+}
+static inline void efx_fini_lm87(struct efx_nic *efx)
+{
+}
+static inline int efx_check_lm87(struct efx_nic *efx, unsigned mask)
+{
+	return 0;
+}
+
+#endif /* CONFIG_SENSORS_LM87 */
+
+/*****************************************************************************
  * Support for the SFE4002
  *
  */
+static u8 sfe4002_lm87_channel = 0x03; /* use AIN not FAN inputs */
+
+static const u8 sfe4002_lm87_regs[] = {
+	LM87_IN_LIMITS(0, 0x83, 0x91),		/* 2.5V:  1.8V +/- 5% */
+	LM87_IN_LIMITS(1, 0x51, 0x5a),		/* Vccp1: 1.2V +/- 5% */
+	LM87_IN_LIMITS(2, 0xb6, 0xca),		/* 3.3V:  3.3V +/- 5% */
+	LM87_IN_LIMITS(3, 0xb0, 0xc9),		/* 5V:    4.6-5.2V */
+	LM87_IN_LIMITS(4, 0xb0, 0xe0),		/* 12V:   11-14V */
+	LM87_IN_LIMITS(5, 0x44, 0x4b),		/* Vccp2: 1.0V +/- 5% */
+	LM87_AIN_LIMITS(0, 0xa0, 0xb2),		/* AIN1:  1.66V +/- 5% */
+	LM87_AIN_LIMITS(1, 0x91, 0xa1),		/* AIN2:  1.5V +/- 5% */
+	LM87_TEMP_INT_LIMITS(10, 60),		/* board */
+	LM87_TEMP_EXT1_LIMITS(10, 70),		/* Falcon */
+	0
+};
+
+static struct i2c_board_info sfe4002_hwmon_info = {
+	I2C_BOARD_INFO("lm87", 0x2e),
+	.platform_data	= &sfe4002_lm87_channel,
+	.irq		= -1,
+};
+
 /****************************************************************************/
 /* LED allocations. Note that on rev A0 boards the schematic and the reality
  * differ: red and green are swapped. Below is the fixed (A1) layout (there
@@ -84,11 +204,27 @@ static void sfe4002_fault_led(struct efx_nic *efx, bool state)
 			QUAKE_LED_OFF);
 }
 
+static int sfe4002_check_hw(struct efx_nic *efx)
+{
+	/* A0 board rev. 4002s report a temperature fault the whole time
+	 * (bad sensor) so we mask it out. */
+	unsigned alarm_mask =
+		(efx->board_info.major == 0 && efx->board_info.minor == 0) ?
+		~LM87_ALARM_TEMP_EXT1 : ~0;
+
+	return efx_check_lm87(efx, alarm_mask);
+}
+
 static int sfe4002_init(struct efx_nic *efx)
 {
+	int rc = efx_init_lm87(efx, &sfe4002_hwmon_info, sfe4002_lm87_regs);
+	if (rc)
+		return rc;
+	efx->board_info.monitor = sfe4002_check_hw;
 	efx->board_info.init_leds = sfe4002_init_leds;
 	efx->board_info.set_fault_led = sfe4002_fault_led;
 	efx->board_info.blink = board_blink;
+	efx->board_info.fini = efx_fini_lm87;
 	return 0;
 }
 
diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index 003e48d..19e2521 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -260,6 +260,41 @@ void mdio_clause45_phy_reconfigure(struct efx_nic *efx)
 				    MDIO_MMDREG_CTRL1, ctrl2);
 }
 
+static void mdio_clause45_set_mmd_lpower(struct efx_nic *efx,
+					 int lpower, int mmd)
+{
+	int phy = efx->mii.phy_id;
+	int stat = mdio_clause45_read(efx, phy, mmd, MDIO_MMDREG_STAT1);
+	int ctrl1, ctrl2;
+
+	EFX_TRACE(efx, "Setting low power mode for MMD %d to %d\n",
+		  mmd, lpower);
+
+	if (stat & (1 << MDIO_MMDREG_STAT1_LPABLE_LBN)) {
+		ctrl1 = ctrl2 = mdio_clause45_read(efx, phy,
+						   mmd, MDIO_MMDREG_CTRL1);
+		if (lpower)
+			ctrl2 |= (1 << MDIO_MMDREG_CTRL1_LPOWER_LBN);
+		else
+			ctrl2 &= ~(1 << MDIO_MMDREG_CTRL1_LPOWER_LBN);
+		if (ctrl1 != ctrl2)
+			mdio_clause45_write(efx, phy, mmd,
+					    MDIO_MMDREG_CTRL1, ctrl2);
+	}
+}
+
+void mdio_clause45_set_mmds_lpower(struct efx_nic *efx,
+				   int low_power, unsigned int mmd_mask)
+{
+	int mmd = 0;
+	while (mmd_mask) {
+		if (mmd_mask & 1)
+			mdio_clause45_set_mmd_lpower(efx, low_power, mmd);
+		mmd_mask = (mmd_mask >> 1);
+		mmd++;
+	}
+}
+
 /**
  * mdio_clause45_get_settings - Read (some of) the PHY settings over MDIO.
  * @efx:		Efx NIC
diff --git a/drivers/net/sfc/mdio_10g.h b/drivers/net/sfc/mdio_10g.h
index 19c42ea..db9f358 100644
--- a/drivers/net/sfc/mdio_10g.h
+++ b/drivers/net/sfc/mdio_10g.h
@@ -54,6 +54,9 @@
 /* Loopback bit for WIS, PCS, PHYSX and DTEXS */
 #define MDIO_MMDREG_CTRL1_LBACK_LBN	(14)
 #define MDIO_MMDREG_CTRL1_LBACK_WIDTH	(1)
+/* Low power */
+#define MDIO_MMDREG_CTRL1_LPOWER_LBN	(11)
+#define MDIO_MMDREG_CTRL1_LPOWER_WIDTH	(1)
 
 /* Bits in MMDREG_STAT1 */
 #define MDIO_MMDREG_STAT1_FAULT_LBN	(7)
@@ -240,6 +243,10 @@ extern void mdio_clause45_transmit_disable(struct efx_nic *efx);
 /* Generic part of reconfigure: set/clear loopback bits */
 extern void mdio_clause45_phy_reconfigure(struct efx_nic *efx);
 
+/* Set the power state of the specified MMDs */
+extern void mdio_clause45_set_mmds_lpower(struct efx_nic *efx,
+					  int low_power, unsigned int mmd_mask);
+
 /* Read (some of) the PHY settings over MDIO */
 extern void mdio_clause45_get_settings(struct efx_nic *efx,
 				       struct ethtool_cmd *ecmd);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index cdb11fa..9531ad6 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -414,6 +414,7 @@ struct efx_blinker {
  * @init_leds: Sets up board LEDs
  * @set_fault_led: Turns the fault LED on or off
  * @blink: Starts/stops blinking
+ * @monitor: Board-specific health check function
  * @fini: Cleanup function
  * @blinker: used to blink LEDs in software
  * @hwmon_client: I2C client for hardware monitor
@@ -428,6 +429,7 @@ struct efx_board {
 	 * have a separate init callback that happens later than
 	 * board init. */
 	int (*init_leds)(struct efx_nic *efx);
+	int (*monitor) (struct efx_nic *nic);
 	void (*set_fault_led) (struct efx_nic *efx, bool state);
 	void (*blink) (struct efx_nic *efx, bool start);
 	void (*fini) (struct efx_nic *nic);
@@ -525,11 +527,15 @@ struct efx_phy_operations {
  * @enum efx_phy_mode - PHY operating mode flags
  * @PHY_MODE_NORMAL: on and should pass traffic
  * @PHY_MODE_TX_DISABLED: on with TX disabled
+ * @PHY_MODE_LOW_POWER: set to low power through MDIO
+ * @PHY_MODE_OFF: switched off through external control
  * @PHY_MODE_SPECIAL: on but will not pass traffic
  */
 enum efx_phy_mode {
 	PHY_MODE_NORMAL		= 0,
 	PHY_MODE_TX_DISABLED	= 1,
+	PHY_MODE_LOW_POWER	= 2,
+	PHY_MODE_OFF		= 4,
 	PHY_MODE_SPECIAL	= 8,
 };
 
diff --git a/drivers/net/sfc/sfe4001.c b/drivers/net/sfc/sfe4001.c
index fe4e3fd..aa576c5 100644
--- a/drivers/net/sfc/sfe4001.c
+++ b/drivers/net/sfc/sfe4001.c
@@ -21,6 +21,7 @@
 #include "falcon_hwdefs.h"
 #include "falcon_io.h"
 #include "mac.h"
+#include "workarounds.h"
 
 /**************************************************************************
  *
@@ -65,48 +66,9 @@
 #define	P1_SPARE_LBN 4
 #define	P1_SPARE_WIDTH 4
 
-
-/**************************************************************************
- *
- * Temperature Sensor
- *
- **************************************************************************/
-#define	MAX6647	0x4e
-
-#define	RLTS	0x00
-#define	RLTE	0x01
-#define	RSL	0x02
-#define	RCL	0x03
-#define	RCRA	0x04
-#define	RLHN	0x05
-#define	RLLI	0x06
-#define	RRHI	0x07
-#define	RRLS	0x08
-#define	WCRW	0x0a
-#define	WLHO	0x0b
-#define	WRHA	0x0c
-#define	WRLN	0x0e
-#define	OSHT	0x0f
-#define	REET	0x10
-#define	RIET	0x11
-#define	RWOE	0x19
-#define	RWOI	0x20
-#define	HYS	0x21
-#define	QUEUE	0x22
-#define	MFID	0xfe
-#define	REVID	0xff
-
-/* Status bits */
-#define MAX6647_BUSY	(1 << 7)	/* ADC is converting */
-#define MAX6647_LHIGH	(1 << 6)	/* Local high temp. alarm */
-#define MAX6647_LLOW	(1 << 5)	/* Local low temp. alarm */
-#define MAX6647_RHIGH	(1 << 4)	/* Remote high temp. alarm */
-#define MAX6647_RLOW	(1 << 3)	/* Remote low temp. alarm */
-#define MAX6647_FAULT	(1 << 2)	/* DXN/DXP short/open circuit */
-#define MAX6647_EOT	(1 << 1)	/* Remote junction overtemp. */
-#define MAX6647_IOT	(1 << 0)	/* Local junction overtemp. */
-
-static const u8 xgphy_max_temperature = 90;
+/* Temperature Sensor */
+#define MAX664X_REG_RSL		0x02
+#define MAX664X_REG_WLHO	0x0B
 
 static void sfe4001_poweroff(struct efx_nic *efx)
 {
@@ -119,7 +81,7 @@ static void sfe4001_poweroff(struct efx_nic *efx)
 	i2c_smbus_write_byte_data(ioexp_client, P0_CONFIG, 0xff);
 
 	/* Clear any over-temperature alert */
-	i2c_smbus_read_byte_data(hwmon_client, RSL);
+	i2c_smbus_read_byte_data(hwmon_client, MAX664X_REG_RSL);
 }
 
 static int sfe4001_poweron(struct efx_nic *efx)
@@ -131,7 +93,7 @@ static int sfe4001_poweron(struct efx_nic *efx)
 	u8 out;
 
 	/* Clear any previous over-temperature alert */
-	rc = i2c_smbus_read_byte_data(hwmon_client, RSL);
+	rc = i2c_smbus_read_byte_data(hwmon_client, MAX664X_REG_RSL);
 	if (rc < 0)
 		return rc;
 
@@ -209,6 +171,34 @@ fail_on:
 	return rc;
 }
 
+static int sfe4001_check_hw(struct efx_nic *efx)
+{
+	s32 status;
+
+	/* If XAUI link is up then do not monitor */
+	if (EFX_WORKAROUND_7884(efx) && falcon_xaui_link_ok(efx))
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
 /* On SFE4001 rev A2 and later, we can control the FLASH_CFG_1 pin
  * using the 3V3X output of the IO-expander.  Allow the user to set
  * this when the device is stopped, and keep it stopped then.
@@ -261,35 +251,34 @@ static void sfe4001_fini(struct efx_nic *efx)
 	i2c_unregister_device(efx->board_info.hwmon_client);
 }
 
+static struct i2c_board_info sfe4001_hwmon_info = {
+	I2C_BOARD_INFO("max6647", 0x4e),
+	.irq		= -1,
+};
+
 /* This board uses an I2C expander to provider power to the PHY, which needs to
  * be turned on before the PHY can be used.
  * Context: Process context, rtnl lock held
  */
 int sfe4001_init(struct efx_nic *efx)
 {
-	struct i2c_client *hwmon_client;
 	int rc;
 
-	hwmon_client = i2c_new_dummy(&efx->i2c_adap, MAX6647);
-	if (!hwmon_client)
+#if defined(CONFIG_SENSORS_LM90) || defined(CONFIG_SENSORS_LM90_MODULE)
+	efx->board_info.hwmon_client =
+		i2c_new_device(&efx->i2c_adap, &sfe4001_hwmon_info);
+#else
+	efx->board_info.hwmon_client =
+		i2c_new_dummy(&efx->i2c_adap, sfe4001_hwmon_info.addr);
+#endif
+	if (!efx->board_info.hwmon_client)
 		return -EIO;
-	efx->board_info.hwmon_client = hwmon_client;
 
-	/* Set DSP over-temperature alert threshold */
-	EFX_INFO(efx, "DSP cut-out at %dC\n", xgphy_max_temperature);
-	rc = i2c_smbus_write_byte_data(hwmon_client, WLHO,
-				       xgphy_max_temperature);
+	/* Raise board/PHY high limit from 85 to 90 degrees Celsius */
+	rc = i2c_smbus_write_byte_data(efx->board_info.hwmon_client,
+				       MAX664X_REG_WLHO, 90);
 	if (rc)
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
+		goto fail_hwmon;
 
 	efx->board_info.ioexp_client = i2c_new_dummy(&efx->i2c_adap, PCA9539);
 	if (!efx->board_info.ioexp_client) {
@@ -301,6 +290,7 @@ int sfe4001_init(struct efx_nic *efx)
 	 * blink code. */
 	efx->board_info.blink = tenxpress_phy_blink;
 
+	efx->board_info.monitor = sfe4001_check_hw;
 	efx->board_info.fini = sfe4001_fini;
 
 	rc = sfe4001_poweron(efx);
@@ -319,6 +309,6 @@ fail_on:
 fail_ioexp:
 	i2c_unregister_device(efx->board_info.ioexp_client);
 fail_hwmon:
-	i2c_unregister_device(hwmon_client);
+	i2c_unregister_device(efx->board_info.hwmon_client);
 	return rc;
 }
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index d507c93..8d41c29 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -376,6 +376,7 @@ static int tenxpress_phy_check_hw(struct efx_nic *efx)
 {
 	struct tenxpress_phy_data *phy_data = efx->phy_data;
 	bool link_ok;
+	int rc = 0;
 
 	link_ok = tenxpress_link_ok(efx, true);
 
@@ -391,7 +392,22 @@ static int tenxpress_phy_check_hw(struct efx_nic *efx)
 		atomic_set(&phy_data->bad_crc_count, 0);
 	}
 
-	return 0;
+	rc = efx->board_info.monitor(efx);
+	if (rc) {
+		EFX_ERR(efx, "Board sensor %s; shutting down PHY\n",
+			(rc == -ERANGE) ? "reported fault" : "failed");
+		if (efx->phy_mode & PHY_MODE_OFF) {
+			/* Assume that board has shut PHY off */
+			phy_data->phy_mode = PHY_MODE_OFF;
+		} else {
+			efx->phy_mode |= PHY_MODE_LOW_POWER;
+			mdio_clause45_set_mmds_lpower(efx, true,
+						      efx->phy_op->mmds);
+			phy_data->phy_mode |= PHY_MODE_LOW_POWER;
+		}
+	}
+
+	return rc;
 }
 
 static void tenxpress_phy_fini(struct efx_nic *efx)
diff --git a/drivers/net/sfc/workarounds.h b/drivers/net/sfc/workarounds.h
index fa7b49d..ec50b90 100644
--- a/drivers/net/sfc/workarounds.h
+++ b/drivers/net/sfc/workarounds.h
@@ -22,6 +22,8 @@
 #define EFX_WORKAROUND_5147 EFX_WORKAROUND_ALWAYS
 /* RX PCIe double split performance issue */
 #define EFX_WORKAROUND_7575 EFX_WORKAROUND_ALWAYS
+/* Bit-bashed I2C reads cause performance drop */
+#define EFX_WORKAROUND_7884 EFX_WORKAROUND_ALWAYS
 /* TX pkt parser problem with <= 16 byte TXes */
 #define EFX_WORKAROUND_9141 EFX_WORKAROUND_ALWAYS
 /* Low rate CRC errors require XAUI reset */
diff --git a/drivers/net/sfc/xfp_phy.c b/drivers/net/sfc/xfp_phy.c
index 276151d..91f0246 100644
--- a/drivers/net/sfc/xfp_phy.c
+++ b/drivers/net/sfc/xfp_phy.c
@@ -128,6 +128,15 @@ static int xfp_phy_check_hw(struct efx_nic *efx)
 	if (link_up != efx->link_up)
 		falcon_xmac_sim_phy_event(efx);
 
+	rc = efx->board_info.monitor(efx);
+	if (rc) {
+		struct xfp_phy_data *phy_data = efx->phy_data;
+		EFX_ERR(efx, "XFP sensor alert; putting PHY into low power\n");
+		efx->phy_mode |= PHY_MODE_LOW_POWER;
+		mdio_clause45_set_mmds_lpower(efx, 1, XFP_REQUIRED_DEVS);
+		phy_data->phy_mode |= PHY_MODE_LOW_POWER;
+	}
+
 	return rc;
 }
 
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

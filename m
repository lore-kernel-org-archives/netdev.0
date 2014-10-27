From: Tony Lindgren <tony@atomide.com>
Subject: [PATCH] net: smc91x: Fix gpios for device tree based booting
Date: Mon, 27 Oct 2014 13:25:56 -0700
Message-ID: <20141027202556.GT2560@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-omap@vger.kernel.org, Kevin Hilman <khilman@linaro.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With legacy booting, the platform init code was taking care of
the configuring of GPIOs. With device tree based booting, things
may or may not work depending what bootloader has configured or
if the legacy platform code gets called.

Let's add support for the pwrdn and reset GPIOs to the smc91x
driver to fix the issues of smc91x not working properly when
booted in device tree mode.

And let's change n900 to use these settings as some versions
of the bootloader do not configure things properly causing
errors.

Reported-by: Kevin Hilman <khilman@linaro.org>
Signed-off-by: Tony Lindgren <tony@atomide.com>

--- a/Documentation/devicetree/bindings/net/smsc-lan91c111.txt
+++ b/Documentation/devicetree/bindings/net/smsc-lan91c111.txt
@@ -11,3 +11,5 @@ Optional properties:
   are supported on the device.  Valid value for SMSC LAN91c111 are
   1, 2 or 4.  If it's omitted or invalid, the size would be 2 meaning
   16-bit access only.
+- power-gpios: GPIO to control the PWRDWN pin
+- reset-gpios: GPIO to control the RESET pin
--- a/arch/arm/boot/dts/omap3-n900.dts
+++ b/arch/arm/boot/dts/omap3-n900.dts
@@ -697,6 +697,8 @@
 		bank-width = <2>;
 		pinctrl-names = "default";
 		pinctrl-0 = <&ethernet_pins>;
+		power-gpios = <&gpio3 22 GPIO_ACTIVE_HIGH>;	/* gpio86 */
+		reset-gpios = <&gpio6 4 GPIO_ACTIVE_HIGH>;	/* gpio164 */
 		gpmc,device-width = <2>;
 		gpmc,sync-clk-ps = <0>;
 		gpmc,cs-on-ns = <0>;
--- a/arch/arm/mach-omap2/pdata-quirks.c
+++ b/arch/arm/mach-omap2/pdata-quirks.c
@@ -253,9 +253,6 @@ static void __init nokia_n900_legacy_init(void)
 		platform_device_register(&omap3_rom_rng_device);
 
 	}
-
-	/* Only on some development boards */
-	gpio_request_one(164, GPIOF_OUT_INIT_LOW, "smc91x reset");
 }
 
 static void __init omap3_tao3530_legacy_init(void)
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -81,6 +81,7 @@ static const char version[] =
 #include <linux/workqueue.h>
 #include <linux/of.h>
 #include <linux/of_device.h>
+#include <linux/of_gpio.h>
 
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -2190,6 +2191,41 @@ static const struct of_device_id smc91x_match[] = {
 MODULE_DEVICE_TABLE(of, smc91x_match);
 #endif
 
+/**
+ * of_try_set_control_gpio - configure a gpio if it exists
+ */
+static int try_toggle_control_gpio(struct device *dev,
+				   struct gpio_desc **desc,
+				   const char *name, int index,
+				   int value, unsigned int nsdelay)
+{
+	struct gpio_desc *gpio = *desc;
+	int res;
+
+	gpio = devm_gpiod_get_index(dev, name, index);
+	if (IS_ERR(gpio)) {
+		if (PTR_ERR(gpio) == -ENOENT) {
+			*desc = NULL;
+			return 0;
+		}
+
+		return PTR_ERR(gpio);
+	}
+	res = gpiod_direction_output(gpio, !value);
+	if (res) {
+		dev_err(dev, "unable to toggle gpio %s: %i\n", name, res);
+		devm_gpiod_put(dev, gpio);
+		gpio = NULL;
+		return res;
+	}
+	if (nsdelay)
+		usleep_range(nsdelay, 2 * nsdelay);
+	gpiod_set_value_cansleep(gpio, value);
+	*desc = gpio;
+
+	return 0;
+}
+
 /*
  * smc_init(void)
  *   Input parameters:
@@ -2237,6 +2273,28 @@ static int smc_drv_probe(struct platform_device *pdev)
 		struct device_node *np = pdev->dev.of_node;
 		u32 val;
 
+		/* Optional pwrdwn GPIO configured? */
+		ret = try_toggle_control_gpio(&pdev->dev, &lp->power_gpio,
+					      "power", 0, 0, 100);
+		if (ret)
+			return ret;
+
+		/*
+		 * Optional reset GPIO configured? Minimum 100 ns reset needed
+		 * according to LAN91C96 datasheet page 14.
+		 */
+		ret = try_toggle_control_gpio(&pdev->dev, &lp->reset_gpio,
+					      "reset", 0, 0, 100);
+		if (ret)
+			return ret;
+
+		/*
+		 * Need to wait for optional EEPROM to load, max 750 us according
+		 * to LAN91C96 datasheet page 55.
+		 */
+		if (lp->reset_gpio)
+			usleep_range(750, 1000);
+
 		/* Combination of IO widths supported, default to 16-bit */
 		if (!of_property_read_u32(np, "reg-io-width", &val)) {
 			if (val & 1)
--- a/drivers/net/ethernet/smsc/smc91x.h
+++ b/drivers/net/ethernet/smsc/smc91x.h
@@ -298,6 +298,9 @@ struct smc_local {
 	struct sk_buff *pending_tx_skb;
 	struct tasklet_struct tx_task;
 
+	struct gpio_desc *power_gpio;
+	struct gpio_desc *reset_gpio;
+
 	/* version/revision of the SMC91x chip */
 	int	version;
 

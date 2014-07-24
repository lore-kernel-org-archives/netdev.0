From: Alexandre Courbot <acourbot@nvidia.com>
Subject: [PATCH] gpio: extend gpiod_get*() with flags parameter
Date: Fri, 25 Jul 2014 00:04:58 +0900
Message-ID: <1406214298-20062-1-git-send-email-acourbot@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-pwm@vger.kernel.org, linux-fbdev@vger.kernel.org,
 alsa-devel@alsa-project.org, linux-doc@vger.kernel.org,
 linux-iio@vger.kernel.org, netdev@vger.kernel.org, linux-pm@vger.kernel.org,
 linux-mmc@vger.kernel.org, linux-kernel@vger.kernel.org,
 dri-devel@lists.freedesktop.org, linux-gpio@vger.kernel.org,
 linux-i2c@vger.kernel.org, linux-serial@vger.kernel.org,
 linux-input@vger.kernel.org, linux-wireless@vger.kernel.org,
 linux-omap@vger.kernel.org, gnurou@gmail.com,
 linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org
To: Linus Walleij <linus.walleij@linaro.org>,
 Thierry Reding <thierry.reding@gmail.com>,
 Sebastian Reichel <sre@kernel.org>, Wolfram Sang <wsa@the-dreams.de>,
 Jonathan Cameron <jic23@kernel.org>,
 Dmitry Torokhov <dmitry.torokhov@gmail.com>,
 Alexander Shiyan <shc_work@mail.ru>, Hans Verkuil <hans.verkuil@cisco.com>,
 Mauro Carvalho Chehab <m.chehab@samsung.com>,
 Arnd Bergmann <arnd@arndb.de>, Samuel Ortiz <sameo@linux.intel.com>,
 Lee Jones <lee.jones@linaro.org>, Chris Ball <chris@printf.net>,
 Ulf Hansson <ulf.hansson@linaro.org>,
 Florian Fainelli <f.fainelli@gmail.com>,
 Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
 David Woodhouse <dwmw2@infradead.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Jiri Slaby <jslaby@suse.cz>, Jingoo Han <jg1.han@samsung.com>,
 Bryan Wu <cooloney@gmail.com>,
 Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
 Tomi Valkeinen <tom
Return-path: <dri-devel-bounces@lists.freedesktop.org>
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/dri-devel>
List-Post: <mailto:dri-devel@lists.freedesktop.org>
List-Help: <mailto:dri-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=subscribe>
Errors-To: dri-devel-bounces@lists.freedesktop.org
Sender: "dri-devel" <dri-devel-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

The huge majority of GPIOs have their direction and initial value set
right after being obtained by one of the gpiod_get() functions. The
integer GPIO API had gpio_request_one() that took a convenience flags
parameter allowing to specify an direction and value applied to the
returned GPIO. This feature greatly simplifies client code and ensures
errors are always handled properly.

A similar feature has been requested for the gpiod API. Since GPIOs need
a direction to be used anyway, we prefer to extend the existing
functions instead of introducing new functions that would raise the
number of gpiod getters to 16 (!).

The drawback of this approach is that all gpiod clients need to be
updated, but there aren't that many and the moment and this results in
smaller (and hopefully safer) code.

Signed-off-by: Alexandre Courbot <acourbot@nvidia.com>
---
This change will be difficult to apply without breaking things, but
let's try to do it right. Hopefully the benefit will outweight the
disturbance.

This is a patch against -next to list and update all current gpiod
consumers. Updates are trivial at first sight, but it would be nice to
get as many acks as possible from the respective subsystem maintainers.

I'm not sure how this could be applied harmlessly though - maybe through
a dedicated branch for -next? Problem is that a lot of new code is not
yet merged into mainline, and conflicts are very likely to occur. Linus,
do you have any suggestion as to how this can be done without blood being
spilled?

 Documentation/gpio/consumer.txt                    | 26 ++++++++---
 drivers/gpio/devres.c                              | 24 ++++++----
 drivers/gpio/gpiolib.c                             | 53 ++++++++++++++++------
 drivers/gpu/drm/panel/panel-ld9040.c               |  7 +--
 drivers/gpu/drm/panel/panel-s6e8aa0.c              |  7 +--
 drivers/gpu/drm/panel/panel-simple.c               | 16 ++-----
 drivers/hsi/clients/nokia-modem.c                  |  7 +--
 drivers/i2c/muxes/i2c-mux-pca954x.c                |  4 +-
 drivers/iio/accel/kxcjk-1013.c                     |  6 +--
 drivers/input/keyboard/clps711x-keypad.c           |  6 +--
 drivers/input/misc/gpio-beeper.c                   |  6 +--
 drivers/input/misc/soc_button_array.c              |  2 +-
 drivers/media/i2c/adv7604.c                        |  6 +--
 drivers/mfd/intel_soc_pmic_core.c                  |  2 +-
 drivers/mmc/core/slot-gpio.c                       |  6 +--
 drivers/net/phy/at803x.c                           |  4 +-
 drivers/power/reset/gpio-poweroff.c                | 21 ++-------
 drivers/tty/serial/serial_mctrl_gpio.c             |  2 +-
 drivers/video/backlight/pwm_bl.c                   |  6 +--
 drivers/video/fbdev/omap2/displays-new/panel-dpi.c | 12 ++---
 .../omap2/displays-new/panel-lgphilips-lb035q02.c  |  6 +--
 .../omap2/displays-new/panel-sharp-ls037v7dw01.c   |  7 +--
 include/linux/gpio/consumer.h                      | 38 ++++++++++++----
 net/rfkill/rfkill-gpio.c                           | 16 ++-----
 sound/soc/codecs/adau1977.c                        | 11 ++---
 sound/soc/codecs/cs4265.c                          |  5 +-
 sound/soc/codecs/sta350.c                          |  9 ++--
 sound/soc/codecs/tas2552.c                         |  4 +-
 sound/soc/jz4740/qi_lb60.c                         | 10 +---
 sound/soc/omap/rx51.c                              | 29 +++---------
 sound/soc/soc-jack.c                               |  9 ++--
 31 files changed, 160 insertions(+), 207 deletions(-)

diff --git a/Documentation/gpio/consumer.txt b/Documentation/gpio/consumer.txt
index 7ff30d2..a3fb1d7 100644
--- a/Documentation/gpio/consumer.txt
+++ b/Documentation/gpio/consumer.txt
@@ -29,13 +29,24 @@ gpiod_get() functions. Like many other kernel subsystems, gpiod_get() takes the
 device that will use the GPIO and the function the requested GPIO is supposed to
 fulfill:
 
-	struct gpio_desc *gpiod_get(struct device *dev, const char *con_id)
+	struct gpio_desc *gpiod_get(struct device *dev, const char *con_id,
+				    enum gpio_flags flags)
 
 If a function is implemented by using several GPIOs together (e.g. a simple LED
 device that displays digits), an additional index argument can be specified:
 
 	struct gpio_desc *gpiod_get_index(struct device *dev,
-					  const char *con_id, unsigned int idx)
+					  const char *con_id, unsigned int idx,
+					  enum gpio_flags flags)
+
+The flags parameter is used to optionally specify a direction and initial value
+for the GPIO. Values can be:
+
+* AS_IS or 0 to not initialize the GPIO at all. The direction must be set later
+  with one of the dedicated functions.
+* INPUT to initialize the GPIO as input.
+* OUTPUT_LOW to initialize the GPIO as output with a value of 0.
+* OUTPUT_HIGH to initialize the GPIO as output with a value of 1.
 
 Both functions return either a valid GPIO descriptor, or an error code checkable
 with IS_ERR() (they will never return a NULL pointer). -ENOENT will be returned
@@ -49,11 +60,13 @@ GPIO has been assigned to the requested function:
 
 Device-managed variants of these functions are also defined:
 
-	struct gpio_desc *devm_gpiod_get(struct device *dev, const char *con_id)
+	struct gpio_desc *devm_gpiod_get(struct device *dev, const char *con_id,
+					 enum gpio_flags flags)
 
 	struct gpio_desc *devm_gpiod_get_index(struct device *dev,
 					       const char *con_id,
-					       unsigned int idx)
+					       unsigned int idx,
+					       enum gpio_flags flags)
 
 devm_gpiod_get_optional() and devm_gpiod_get_index_optional() exist as well.
 
@@ -72,8 +85,9 @@ Using GPIOs
 
 Setting Direction
 -----------------
-The first thing a driver must do with a GPIO is setting its direction. This is
-done by invoking one of the gpiod_direction_*() functions:
+The first thing a driver must do with a GPIO is setting its direction. If no
+direction-setting flags as been given to one of the gpiod_get*() functions, this
+is done by invoking one of the gpiod_direction_*() functions:
 
 	int gpiod_direction_input(struct gpio_desc *desc)
 	int gpiod_direction_output(struct gpio_desc *desc, int value)
diff --git a/drivers/gpio/devres.c b/drivers/gpio/devres.c
index 65978cf..a8ce616 100644
--- a/drivers/gpio/devres.c
+++ b/drivers/gpio/devres.c
@@ -39,15 +39,17 @@ static int devm_gpiod_match(struct device *dev, void *res, void *data)
  * devm_gpiod_get - Resource-managed gpiod_get()
  * @dev:	GPIO consumer
  * @con_id:	function within the GPIO consumer
+ * @flags:	optional GPIO initialization flags
  *
  * Managed gpiod_get(). GPIO descriptors returned from this function are
  * automatically disposed on driver detach. See gpiod_get() for detailed
  * information about behavior and return values.
  */
 struct gpio_desc *__must_check devm_gpiod_get(struct device *dev,
-					      const char *con_id)
+					      const char *con_id,
+					      enum gpiod_flags flags)
 {
-	return devm_gpiod_get_index(dev, con_id, 0);
+	return devm_gpiod_get_index(dev, con_id, 0, flags);
 }
 EXPORT_SYMBOL(devm_gpiod_get);
 
@@ -55,15 +57,17 @@ EXPORT_SYMBOL(devm_gpiod_get);
  * devm_gpiod_get_optional - Resource-managed gpiod_get_optional()
  * @dev: GPIO consumer
  * @con_id: function within the GPIO consumer
+ * @flags: optional GPIO initialization flags
  *
  * Managed gpiod_get_optional(). GPIO descriptors returned from this function
  * are automatically disposed on driver detach. See gpiod_get_optional() for
  * detailed information about behavior and return values.
  */
 struct gpio_desc *__must_check devm_gpiod_get_optional(struct device *dev,
-						       const char *con_id)
+						       const char *con_id,
+						       enum gpiod_flags flags)
 {
-	return devm_gpiod_get_index_optional(dev, con_id, 0);
+	return devm_gpiod_get_index_optional(dev, con_id, 0, flags);
 }
 EXPORT_SYMBOL(devm_gpiod_get_optional);
 
@@ -72,6 +76,7 @@ EXPORT_SYMBOL(devm_gpiod_get_optional);
  * @dev:	GPIO consumer
  * @con_id:	function within the GPIO consumer
  * @idx:	index of the GPIO to obtain in the consumer
+ * @flags:	optional GPIO initialization flags
  *
  * Managed gpiod_get_index(). GPIO descriptors returned from this function are
  * automatically disposed on driver detach. See gpiod_get_index() for detailed
@@ -79,7 +84,8 @@ EXPORT_SYMBOL(devm_gpiod_get_optional);
  */
 struct gpio_desc *__must_check devm_gpiod_get_index(struct device *dev,
 						    const char *con_id,
-						    unsigned int idx)
+						    unsigned int idx,
+						    enum gpiod_flags flags)
 {
 	struct gpio_desc **dr;
 	struct gpio_desc *desc;
@@ -89,7 +95,7 @@ struct gpio_desc *__must_check devm_gpiod_get_index(struct device *dev,
 	if (!dr)
 		return ERR_PTR(-ENOMEM);
 
-	desc = gpiod_get_index(dev, con_id, idx);
+	desc = gpiod_get_index(dev, con_id, idx, flags);
 	if (IS_ERR(desc)) {
 		devres_free(dr);
 		return desc;
@@ -107,6 +113,7 @@ EXPORT_SYMBOL(devm_gpiod_get_index);
  * @dev: GPIO consumer
  * @con_id: function within the GPIO consumer
  * @index: index of the GPIO to obtain in the consumer
+ * @flags: optional GPIO initialization flags
  *
  * Managed gpiod_get_index_optional(). GPIO descriptors returned from this
  * function are automatically disposed on driver detach. See
@@ -115,11 +122,12 @@ EXPORT_SYMBOL(devm_gpiod_get_index);
  */
 struct gpio_desc *__must_check devm_gpiod_get_index_optional(struct device *dev,
 							     const char *con_id,
-							     unsigned int index)
+							     unsigned int index,
+							 enum gpiod_flags flags)
 {
 	struct gpio_desc *desc;
 
-	desc = devm_gpiod_get_index(dev, con_id, index);
+	desc = devm_gpiod_get_index(dev, con_id, index, flags);
 	if (IS_ERR(desc)) {
 		if (PTR_ERR(desc) == -ENOENT)
 			return NULL;
diff --git a/drivers/gpio/gpiolib.c b/drivers/gpio/gpiolib.c
index c550935..2727793 100644
--- a/drivers/gpio/gpiolib.c
+++ b/drivers/gpio/gpiolib.c
@@ -1695,14 +1695,16 @@ static struct gpio_desc *gpiod_find(struct device *dev, const char *con_id,
  * gpiod_get - obtain a GPIO for a given GPIO function
  * @dev:	GPIO consumer, can be NULL for system-global GPIOs
  * @con_id:	function within the GPIO consumer
+ * @flags:	optional GPIO initialization flags
  *
  * Return the GPIO descriptor corresponding to the function con_id of device
  * dev, -ENOENT if no GPIO has been assigned to the requested function, or
  * another IS_ERR() code if an error occured while trying to acquire the GPIO.
  */
-struct gpio_desc *__must_check gpiod_get(struct device *dev, const char *con_id)
+struct gpio_desc *__must_check gpiod_get(struct device *dev, const char *con_id,
+					 enum gpiod_flags flags)
 {
-	return gpiod_get_index(dev, con_id, 0);
+	return gpiod_get_index(dev, con_id, 0, flags);
 }
 EXPORT_SYMBOL_GPL(gpiod_get);
 
@@ -1710,15 +1712,17 @@ EXPORT_SYMBOL_GPL(gpiod_get);
  * gpiod_get_optional - obtain an optional GPIO for a given GPIO function
  * @dev: GPIO consumer, can be NULL for system-global GPIOs
  * @con_id: function within the GPIO consumer
+ * @flags: optional GPIO initialization flags
  *
  * This is equivalent to gpiod_get(), except that when no GPIO was assigned to
  * the requested function it will return NULL. This is convenient for drivers
  * that need to handle optional GPIOs.
  */
 struct gpio_desc *__must_check gpiod_get_optional(struct device *dev,
-						  const char *con_id)
+						  const char *con_id,
+						  enum gpiod_flags flags)
 {
-	return gpiod_get_index_optional(dev, con_id, 0);
+	return gpiod_get_index_optional(dev, con_id, 0, flags);
 }
 EXPORT_SYMBOL_GPL(gpiod_get_optional);
 
@@ -1727,6 +1731,7 @@ EXPORT_SYMBOL_GPL(gpiod_get_optional);
  * @dev:	GPIO consumer, can be NULL for system-global GPIOs
  * @con_id:	function within the GPIO consumer
  * @idx:	index of the GPIO to obtain in the consumer
+ * @flags:	optional GPIO initialization flags
  *
  * This variant of gpiod_get() allows to access GPIOs other than the first
  * defined one for functions that define several GPIOs.
@@ -1737,21 +1742,22 @@ EXPORT_SYMBOL_GPL(gpiod_get_optional);
  */
 struct gpio_desc *__must_check gpiod_get_index(struct device *dev,
 					       const char *con_id,
-					       unsigned int idx)
+					       unsigned int idx,
+					       enum gpiod_flags flags)
 {
 	struct gpio_desc *desc = NULL;
 	int status;
-	enum gpio_lookup_flags flags = 0;
+	enum gpio_lookup_flags lookupflags = 0;
 
 	dev_dbg(dev, "GPIO lookup for consumer %s\n", con_id);
 
 	/* Using device tree? */
 	if (IS_ENABLED(CONFIG_OF) && dev && dev->of_node) {
 		dev_dbg(dev, "using device tree for GPIO lookup\n");
-		desc = of_find_gpio(dev, con_id, idx, &flags);
+		desc = of_find_gpio(dev, con_id, idx, &lookupflags);
 	} else if (IS_ENABLED(CONFIG_ACPI) && dev && ACPI_HANDLE(dev)) {
 		dev_dbg(dev, "using ACPI for GPIO lookup\n");
-		desc = acpi_find_gpio(dev, con_id, idx, &flags);
+		desc = acpi_find_gpio(dev, con_id, idx, &lookupflags);
 	}
 
 	/*
@@ -1760,7 +1766,7 @@ struct gpio_desc *__must_check gpiod_get_index(struct device *dev,
 	 */
 	if (!desc || desc == ERR_PTR(-ENOENT)) {
 		dev_dbg(dev, "using lookup tables for GPIO lookup");
-		desc = gpiod_find(dev, con_id, idx, &flags);
+		desc = gpiod_find(dev, con_id, idx, &lookupflags);
 	}
 
 	if (IS_ERR(desc)) {
@@ -1773,13 +1779,30 @@ struct gpio_desc *__must_check gpiod_get_index(struct device *dev,
 	if (status < 0)
 		return ERR_PTR(status);
 
-	if (flags & GPIO_ACTIVE_LOW)
+	if (lookupflags & GPIO_ACTIVE_LOW)
 		set_bit(FLAG_ACTIVE_LOW, &desc->flags);
-	if (flags & GPIO_OPEN_DRAIN)
+	if (lookupflags & GPIO_OPEN_DRAIN)
 		set_bit(FLAG_OPEN_DRAIN, &desc->flags);
-	if (flags & GPIO_OPEN_SOURCE)
+	if (lookupflags & GPIO_OPEN_SOURCE)
 		set_bit(FLAG_OPEN_SOURCE, &desc->flags);
 
+	/* No particular flag request, return here... */
+	if (flags & GPIOD_FLAGS_BIT_USED)
+		return desc;
+
+	/* Process flags */
+	if (flags & GPIOD_FLAGS_BIT_OUTPUT)
+		status = gpiod_direction_output(desc,
+						flags & GPIOD_FLAGS_BIT_SET);
+	else
+		status = gpiod_direction_input(desc);
+
+	if (status < 0) {
+		dev_dbg(dev, "setup of GPIO %s failed\n", con_id);
+		gpiod_put(desc);
+		return ERR_PTR(status);
+	}
+
 	return desc;
 }
 EXPORT_SYMBOL_GPL(gpiod_get_index);
@@ -1790,6 +1813,7 @@ EXPORT_SYMBOL_GPL(gpiod_get_index);
  * @dev: GPIO consumer, can be NULL for system-global GPIOs
  * @con_id: function within the GPIO consumer
  * @index: index of the GPIO to obtain in the consumer
+ * @flags: optional GPIO initialization flags
  *
  * This is equivalent to gpiod_get_index(), except that when no GPIO with the
  * specified index was assigned to the requested function it will return NULL.
@@ -1797,11 +1821,12 @@ EXPORT_SYMBOL_GPL(gpiod_get_index);
  */
 struct gpio_desc *__must_check gpiod_get_index_optional(struct device *dev,
 							const char *con_id,
-							unsigned int index)
+							unsigned int index,
+							enum gpiod_flags flags)
 {
 	struct gpio_desc *desc;
 
-	desc = gpiod_get_index(dev, con_id, index);
+	desc = gpiod_get_index(dev, con_id, index, flags);
 	if (IS_ERR(desc)) {
 		if (PTR_ERR(desc) == -ENOENT)
 			return NULL;
diff --git a/drivers/gpu/drm/panel/panel-ld9040.c b/drivers/gpu/drm/panel/panel-ld9040.c
index db1601f..b9b7b2c 100644
--- a/drivers/gpu/drm/panel/panel-ld9040.c
+++ b/drivers/gpu/drm/panel/panel-ld9040.c
@@ -321,17 +321,12 @@ static int ld9040_probe(struct spi_device *spi)
 	if (ret < 0)
 		return ret;
 
-	ctx->reset_gpio = devm_gpiod_get(dev, "reset");
+	ctx->reset_gpio = devm_gpiod_get(dev, "reset", OUTPUT_HIGH);
 	if (IS_ERR(ctx->reset_gpio)) {
 		dev_err(dev, "cannot get reset-gpios %ld\n",
 			PTR_ERR(ctx->reset_gpio));
 		return PTR_ERR(ctx->reset_gpio);
 	}
-	ret = gpiod_direction_output(ctx->reset_gpio, 1);
-	if (ret < 0) {
-		dev_err(dev, "cannot configure reset-gpios %d\n", ret);
-		return ret;
-	}
 
 	spi->bits_per_word = 9;
 	ret = spi_setup(spi);
diff --git a/drivers/gpu/drm/panel/panel-s6e8aa0.c b/drivers/gpu/drm/panel/panel-s6e8aa0.c
index 4fe0bbb..290c910 100644
--- a/drivers/gpu/drm/panel/panel-s6e8aa0.c
+++ b/drivers/gpu/drm/panel/panel-s6e8aa0.c
@@ -1007,17 +1007,12 @@ static int s6e8aa0_probe(struct mipi_dsi_device *dsi)
 		return ret;
 	}
 
-	ctx->reset_gpio = devm_gpiod_get(dev, "reset");
+	ctx->reset_gpio = devm_gpiod_get(dev, "reset", OUTPUT_HIGH);
 	if (IS_ERR(ctx->reset_gpio)) {
 		dev_err(dev, "cannot get reset-gpios %ld\n",
 			PTR_ERR(ctx->reset_gpio));
 		return PTR_ERR(ctx->reset_gpio);
 	}
-	ret = gpiod_direction_output(ctx->reset_gpio, 1);
-	if (ret < 0) {
-		dev_err(dev, "cannot configure reset-gpios %d\n", ret);
-		return ret;
-	}
 
 	ctx->brightness = GAMMA_LEVEL_NUM - 1;
 
diff --git a/drivers/gpu/drm/panel/panel-simple.c b/drivers/gpu/drm/panel/panel-simple.c
index 357712c..4f742f6 100644
--- a/drivers/gpu/drm/panel/panel-simple.c
+++ b/drivers/gpu/drm/panel/panel-simple.c
@@ -185,21 +185,11 @@ static int panel_simple_probe(struct device *dev, const struct panel_desc *desc)
 	if (IS_ERR(panel->supply))
 		return PTR_ERR(panel->supply);
 
-	panel->enable_gpio = devm_gpiod_get(dev, "enable");
+	panel->enable_gpio = devm_gpiod_get_optional(dev, "enable", OUTPUT_LOW);
 	if (IS_ERR(panel->enable_gpio)) {
 		err = PTR_ERR(panel->enable_gpio);
-		if (err != -ENOENT) {
-			dev_err(dev, "failed to request GPIO: %d\n", err);
-			return err;
-		}
-
-		panel->enable_gpio = NULL;
-	} else {
-		err = gpiod_direction_output(panel->enable_gpio, 0);
-		if (err < 0) {
-			dev_err(dev, "failed to setup GPIO: %d\n", err);
-			return err;
-		}
+		dev_err(dev, "failed to request GPIO: %d\n", err);
+		return err;
 	}
 
 	backlight = of_parse_phandle(dev->of_node, "backlight", 0);
diff --git a/drivers/hsi/clients/nokia-modem.c b/drivers/hsi/clients/nokia-modem.c
index 363b780..d917f1e 100644
--- a/drivers/hsi/clients/nokia-modem.c
+++ b/drivers/hsi/clients/nokia-modem.c
@@ -111,7 +111,8 @@ static int nokia_modem_gpio_probe(struct device *dev)
 	modem->gpio_amount = gpio_count;
 
 	for (i = 0; i < gpio_count; i++) {
-		modem->gpios[i].gpio = devm_gpiod_get_index(dev, NULL, i);
+		modem->gpios[i].gpio = devm_gpiod_get_index(dev, NULL, i,
+							    OUTPUT_LOW);
 		if (IS_ERR(modem->gpios[i].gpio)) {
 			dev_err(dev, "Could not get gpio %d\n", i);
 			return PTR_ERR(modem->gpios[i].gpio);
@@ -124,10 +125,6 @@ static int nokia_modem_gpio_probe(struct device *dev)
 			return err;
 		}
 
-		err = gpiod_direction_output(modem->gpios[i].gpio, 0);
-		if (err)
-			return err;
-
 		err = gpiod_export(modem->gpios[i].gpio, 0);
 		if (err)
 			return err;
diff --git a/drivers/i2c/muxes/i2c-mux-pca954x.c b/drivers/i2c/muxes/i2c-mux-pca954x.c
index 9bd4212..b73888b 100644
--- a/drivers/i2c/muxes/i2c-mux-pca954x.c
+++ b/drivers/i2c/muxes/i2c-mux-pca954x.c
@@ -200,9 +200,7 @@ static int pca954x_probe(struct i2c_client *client,
 	i2c_set_clientdata(client, data);
 
 	/* Get the mux out of reset if a reset GPIO is specified. */
-	gpio = devm_gpiod_get(&client->dev, "reset");
-	if (!IS_ERR(gpio))
-		gpiod_direction_output(gpio, 0);
+	gpio = devm_gpiod_get(&client->dev, "reset", OUTPUT_LOW);
 
 	/* Write the mux register at addr to verify
 	 * that the mux is in fact present. This also
diff --git a/drivers/iio/accel/kxcjk-1013.c b/drivers/iio/accel/kxcjk-1013.c
index 72a6dbb..8d4014089 100644
--- a/drivers/iio/accel/kxcjk-1013.c
+++ b/drivers/iio/accel/kxcjk-1013.c
@@ -566,16 +566,12 @@ static int kxcjk1013_acpi_gpio_probe(struct i2c_client *client,
 		return -ENODEV;
 
 	/* data ready gpio interrupt pin */
-	gpio = devm_gpiod_get_index(dev, "kxcjk1013_int", 0);
+	gpio = devm_gpiod_get_index(dev, "kxcjk1013_int", 0, INPUT);
 	if (IS_ERR(gpio)) {
 		dev_err(dev, "acpi gpio get index failed\n");
 		return PTR_ERR(gpio);
 	}
 
-	ret = gpiod_direction_input(gpio);
-	if (ret)
-		return ret;
-
 	ret = gpiod_to_irq(gpio);
 
 	dev_dbg(dev, "GPIO resource, no:%d irq:%d\n", desc_to_gpio(gpio), ret);
diff --git a/drivers/input/keyboard/clps711x-keypad.c b/drivers/input/keyboard/clps711x-keypad.c
index 552b65c..f54f0d0 100644
--- a/drivers/input/keyboard/clps711x-keypad.c
+++ b/drivers/input/keyboard/clps711x-keypad.c
@@ -120,14 +120,10 @@ static int clps711x_keypad_probe(struct platform_device *pdev)
 	for (i = 0; i < priv->row_count; i++) {
 		struct clps711x_gpio_data *data = &priv->gpio_data[i];
 
-		data->desc = devm_gpiod_get_index(dev, "row", i);
-		if (!data->desc)
-			return -EINVAL;
+		data->desc = devm_gpiod_get_index(dev, "row", i, INPUT);
 
 		if (IS_ERR(data->desc))
 			return PTR_ERR(data->desc);
-
-		gpiod_direction_input(data->desc);
 	}
 
 	err = of_property_read_u32(np, "poll-interval", &poll_interval);
diff --git a/drivers/input/misc/gpio-beeper.c b/drivers/input/misc/gpio-beeper.c
index 8886af6..282804b 100644
--- a/drivers/input/misc/gpio-beeper.c
+++ b/drivers/input/misc/gpio-beeper.c
@@ -72,7 +72,7 @@ static int gpio_beeper_probe(struct platform_device *pdev)
 	if (!beep)
 		return -ENOMEM;
 
-	beep->desc = devm_gpiod_get(&pdev->dev, NULL);
+	beep->desc = devm_gpiod_get(&pdev->dev, NULL, OUTPUT_LOW);
 	if (IS_ERR(beep->desc))
 		return PTR_ERR(beep->desc);
 
@@ -92,10 +92,6 @@ static int gpio_beeper_probe(struct platform_device *pdev)
 
 	input_set_capability(input, EV_SND, SND_BELL);
 
-	err = gpiod_direction_output(beep->desc, 0);
-	if (err)
-		return err;
-
 	input_set_drvdata(input, beep);
 
 	return input_register_device(input);
diff --git a/drivers/input/misc/soc_button_array.c b/drivers/input/misc/soc_button_array.c
index 5a6334b..6553622 100644
--- a/drivers/input/misc/soc_button_array.c
+++ b/drivers/input/misc/soc_button_array.c
@@ -55,7 +55,7 @@ static int soc_button_lookup_gpio(struct device *dev, int acpi_index)
 	struct gpio_desc *desc;
 	int gpio;
 
-	desc = gpiod_get_index(dev, KBUILD_MODNAME, acpi_index);
+	desc = gpiod_get_index(dev, KBUILD_MODNAME, acpi_index, AS_IS);
 	if (IS_ERR(desc))
 		return PTR_ERR(desc);
 
diff --git a/drivers/media/i2c/adv7604.c b/drivers/media/i2c/adv7604.c
index d4fa213..a3d3c26 100644
--- a/drivers/media/i2c/adv7604.c
+++ b/drivers/media/i2c/adv7604.c
@@ -2796,13 +2796,11 @@ static int adv7604_probe(struct i2c_client *client,
 
 	/* Request GPIOs. */
 	for (i = 0; i < state->info->num_dv_ports; ++i) {
-		state->hpd_gpio[i] =
-			devm_gpiod_get_index(&client->dev, "hpd", i);
+		state->hpd_gpio[i] = devm_gpiod_get_index(&client->dev, "hpd",
+							  i, OUTPUT_LOW);
 		if (IS_ERR(state->hpd_gpio[i]))
 			continue;
 
-		gpiod_direction_output(state->hpd_gpio[i], 0);
-
 		v4l_info(client, "Handling HPD %u GPIO\n", i);
 	}
 
diff --git a/drivers/mfd/intel_soc_pmic_core.c b/drivers/mfd/intel_soc_pmic_core.c
index 2720922..c311a11 100644
--- a/drivers/mfd/intel_soc_pmic_core.c
+++ b/drivers/mfd/intel_soc_pmic_core.c
@@ -36,7 +36,7 @@ static int intel_soc_pmic_find_gpio_irq(struct device *dev)
 	struct gpio_desc *desc;
 	int irq;
 
-	desc = devm_gpiod_get_index(dev, "intel_soc_pmic", 0);
+	desc = devm_gpiod_get_index(dev, "intel_soc_pmic", 0, AS_IS);
 	if (IS_ERR(desc))
 		return -ENOENT;
 
diff --git a/drivers/mmc/core/slot-gpio.c b/drivers/mmc/core/slot-gpio.c
index 5f89cb8..d62ab76 100644
--- a/drivers/mmc/core/slot-gpio.c
+++ b/drivers/mmc/core/slot-gpio.c
@@ -308,14 +308,10 @@ int mmc_gpiod_request_cd(struct mmc_host *host, const char *con_id,
 	if (!con_id)
 		con_id = ctx->cd_label;
 
-	desc = devm_gpiod_get_index(host->parent, con_id, idx);
+	desc = devm_gpiod_get_index(host->parent, con_id, idx, INPUT);
 	if (IS_ERR(desc))
 		return PTR_ERR(desc);
 
-	ret = gpiod_direction_input(desc);
-	if (ret < 0)
-		return ret;
-
 	if (debounce) {
 		ret = gpiod_set_debounce(desc, debounce);
 		if (ret < 0)
diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index fdc1b41..6294d6c 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -197,11 +197,9 @@ static int at803x_probe(struct phy_device *phydev)
 	if (!priv)
 		return -ENOMEM;
 
-	priv->gpiod_reset = devm_gpiod_get(dev, "reset");
+	priv->gpiod_reset = devm_gpiod_get(dev, "reset", OUTPUT_HIGH);
 	if (IS_ERR(priv->gpiod_reset))
 		priv->gpiod_reset = NULL;
-	else
-		gpiod_direction_output(priv->gpiod_reset, 1);
 
 	phydev->priv = priv;
 
diff --git a/drivers/power/reset/gpio-poweroff.c b/drivers/power/reset/gpio-poweroff.c
index ce849bc..fd24e65 100644
--- a/drivers/power/reset/gpio-poweroff.c
+++ b/drivers/power/reset/gpio-poweroff.c
@@ -57,25 +57,12 @@ static int gpio_poweroff_probe(struct platform_device *pdev)
 		return -EBUSY;
 	}
 
-	reset_gpio = devm_gpiod_get(&pdev->dev, NULL);
-	if (IS_ERR(reset_gpio))
-		return PTR_ERR(reset_gpio);
-
 	input = of_property_read_bool(pdev->dev.of_node, "input");
 
-	if (input) {
-		if (gpiod_direction_input(reset_gpio)) {
-			dev_err(&pdev->dev,
-				"Could not set direction of reset GPIO to input\n");
-			return -ENODEV;
-		}
-	} else {
-		if (gpiod_direction_output(reset_gpio, 0)) {
-			dev_err(&pdev->dev,
-				"Could not set direction of reset GPIO\n");
-			return -ENODEV;
-		}
-	}
+	reset_gpio = devm_gpiod_get(&pdev->dev, NULL,
+				    input ? INPUT : OUTPUT_LOW);
+	if (IS_ERR(reset_gpio))
+		return PTR_ERR(reset_gpio);
 
 	pm_power_off = &gpio_poweroff_do_poweroff;
 	return 0;
diff --git a/drivers/tty/serial/serial_mctrl_gpio.c b/drivers/tty/serial/serial_mctrl_gpio.c
index bf9560f..a3cd7b2 100644
--- a/drivers/tty/serial/serial_mctrl_gpio.c
+++ b/drivers/tty/serial/serial_mctrl_gpio.c
@@ -103,7 +103,7 @@ struct mctrl_gpios *mctrl_gpio_init(struct device *dev, unsigned int idx)
 	for (i = 0; i < UART_GPIO_MAX; i++) {
 		gpios->gpio[i] = devm_gpiod_get_index(dev,
 						      mctrl_gpios_desc[i].name,
-						      idx);
+						      idx, AS_IS);
 
 		/*
 		 * The GPIOs are maybe not all filled,
diff --git a/drivers/video/backlight/pwm_bl.c b/drivers/video/backlight/pwm_bl.c
index d7a3d13..d574945 100644
--- a/drivers/video/backlight/pwm_bl.c
+++ b/drivers/video/backlight/pwm_bl.c
@@ -239,7 +239,8 @@ static int pwm_backlight_probe(struct platform_device *pdev)
 	pb->dev = &pdev->dev;
 	pb->enabled = false;
 
-	pb->enable_gpio = devm_gpiod_get_optional(&pdev->dev, "enable");
+	pb->enable_gpio = devm_gpiod_get_optional(&pdev->dev, "enable",
+						  OUTPUT_HIGH);
 	if (IS_ERR(pb->enable_gpio)) {
 		ret = PTR_ERR(pb->enable_gpio);
 		goto err_alloc;
@@ -261,9 +262,6 @@ static int pwm_backlight_probe(struct platform_device *pdev)
 		pb->enable_gpio = gpio_to_desc(data->enable_gpio);
 	}
 
-	if (pb->enable_gpio)
-		gpiod_direction_output(pb->enable_gpio, 1);
-
 	pb->power_supply = devm_regulator_get(&pdev->dev, "power");
 	if (IS_ERR(pb->power_supply)) {
 		ret = PTR_ERR(pb->power_supply);
diff --git a/drivers/video/fbdev/omap2/displays-new/panel-dpi.c b/drivers/video/fbdev/omap2/displays-new/panel-dpi.c
index 3636b61..437e18a 100644
--- a/drivers/video/fbdev/omap2/displays-new/panel-dpi.c
+++ b/drivers/video/fbdev/omap2/displays-new/panel-dpi.c
@@ -209,16 +209,10 @@ static int panel_dpi_probe_of(struct platform_device *pdev)
 	struct videomode vm;
 	struct gpio_desc *gpio;
 
-	gpio = devm_gpiod_get(&pdev->dev, "enable");
+	gpio = devm_gpiod_get_optional(&pdev->dev, "enable", OUTPUT_LOW);
 
-	if (IS_ERR(gpio)) {
-		if (PTR_ERR(gpio) != -ENOENT)
-			return PTR_ERR(gpio);
-		else
-			gpio = NULL;
-	} else {
-		gpiod_direction_output(gpio, 0);
-	}
+	if (IS_ERR(gpio))
+		return PTR_ERR(gpio);
 
 	ddata->enable_gpio = gpio;
 
diff --git a/drivers/video/fbdev/omap2/displays-new/panel-lgphilips-lb035q02.c b/drivers/video/fbdev/omap2/displays-new/panel-lgphilips-lb035q02.c
index cc5b512..71c0b26 100644
--- a/drivers/video/fbdev/omap2/displays-new/panel-lgphilips-lb035q02.c
+++ b/drivers/video/fbdev/omap2/displays-new/panel-lgphilips-lb035q02.c
@@ -285,14 +285,12 @@ static int lb035q02_probe_of(struct spi_device *spi)
 	struct omap_dss_device *in;
 	struct gpio_desc *gpio;
 
-	gpio = devm_gpiod_get(&spi->dev, "enable");
+	gpio = devm_gpiod_get(&spi->dev, "enable", OUTPUT_LOW);
 	if (IS_ERR(gpio)) {
 		dev_err(&spi->dev, "failed to parse enable gpio\n");
 		return PTR_ERR(gpio);
-	} else {
-		gpiod_direction_output(gpio, 0);
-		ddata->enable_gpio = gpio;
 	}
+	ddata->enable_gpio = gpio;
 
 	ddata->backlight_gpio = -ENOENT;
 
diff --git a/drivers/video/fbdev/omap2/displays-new/panel-sharp-ls037v7dw01.c b/drivers/video/fbdev/omap2/displays-new/panel-sharp-ls037v7dw01.c
index f1f72ce..afadc18 100644
--- a/drivers/video/fbdev/omap2/displays-new/panel-sharp-ls037v7dw01.c
+++ b/drivers/video/fbdev/omap2/displays-new/panel-sharp-ls037v7dw01.c
@@ -272,14 +272,11 @@ static  int sharp_ls_get_gpio_of(struct device *dev, int index, int val,
 
 	*gpiod = NULL;
 
-	gd = devm_gpiod_get_index(dev, desc, index);
+	gd = devm_gpiod_get_index(dev, desc, index,
+				  val ? OUTPUT_HIGH : OUTPUT);
 	if (IS_ERR(gd))
 		return PTR_ERR(gd) == -ENOENT ? 0 : PTR_ERR(gd);
 
-	r = gpiod_direction_output(gd, val);
-	if (r)
-		return r;
-
 	*gpiod = gd;
 	return 0;
 }
diff --git a/include/linux/gpio/consumer.h b/include/linux/gpio/consumer.h
index 05e53cc..3ae7c96 100644
--- a/include/linux/gpio/consumer.h
+++ b/include/linux/gpio/consumer.h
@@ -18,30 +18,52 @@ struct gpio_desc;
 
 #ifdef CONFIG_GPIOLIB
 
+#define GPIOD_FLAGS_BIT_USED	BIT(0)
+#define GPIOD_FLAGS_BIT_OUTPUT	BIT(1)
+#define GPIOD_FLAGS_BIT_SET	BIT(2)
+/**
+ * Optional flags that can be passed to one of gpiod_* to configure direction
+ * and output value. These values cannot be OR'd.
+ */
+enum gpiod_flags {
+	AS_IS		= 0,
+	INPUT		= GPIOD_FLAGS_BIT_USED,
+	OUTPUT_LOW	= GPIOD_FLAGS_BIT_USED | GPIOD_FLAGS_BIT_OUTPUT,
+	OUTPUT_HIGH	= GPIOD_FLAGS_BIT_USED | GPIOD_FLAGS_BIT_OUTPUT |
+			  GPIOD_FLAGS_BIT_SET,
+};
+
 /* Acquire and dispose GPIOs */
 struct gpio_desc *__must_check gpiod_get(struct device *dev,
-					 const char *con_id);
+					 const char *con_id,
+					 enum gpiod_flags flags);
 struct gpio_desc *__must_check gpiod_get_index(struct device *dev,
 					       const char *con_id,
-					       unsigned int idx);
+					       unsigned int idx,
+					       enum gpiod_flags flags);
 struct gpio_desc *__must_check gpiod_get_optional(struct device *dev,
-						  const char *con_id);
+						  const char *con_id,
+						  enum gpiod_flags flags);
 struct gpio_desc *__must_check gpiod_get_index_optional(struct device *dev,
 							const char *con_id,
-							unsigned int index);
+							unsigned int index,
+							enum gpiod_flags flags);
 
 void gpiod_put(struct gpio_desc *desc);
 
 struct gpio_desc *__must_check devm_gpiod_get(struct device *dev,
-					      const char *con_id);
+					      const char *con_id,
+					      enum gpiod_flags flags);
 struct gpio_desc *__must_check devm_gpiod_get_index(struct device *dev,
 						    const char *con_id,
-						    unsigned int idx);
+						    unsigned int idx,
+						    enum gpiod_flags flags);
 struct gpio_desc *__must_check devm_gpiod_get_optional(struct device *dev,
-						       const char *con_id);
+						       const char *con_id,
+						       enum gpiod_flags flags);
 struct gpio_desc *__must_check
 devm_gpiod_get_index_optional(struct device *dev, const char *con_id,
-			      unsigned int index);
+			      unsigned int index, enum gpiod_flags flags);
 
 void devm_gpiod_put(struct device *dev, struct gpio_desc *desc);
 
diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
index 14c98e4..c6fae77 100644
--- a/net/rfkill/rfkill-gpio.c
+++ b/net/rfkill/rfkill-gpio.c
@@ -102,21 +102,13 @@ static int rfkill_gpio_probe(struct platform_device *pdev)
 
 	rfkill->clk = devm_clk_get(&pdev->dev, NULL);
 
-	gpio = devm_gpiod_get_index(&pdev->dev, "reset", 0);
-	if (!IS_ERR(gpio)) {
-		ret = gpiod_direction_output(gpio, 0);
-		if (ret)
-			return ret;
+	gpio = devm_gpiod_get_index(&pdev->dev, "reset", 0, OUTPUT_LOW);
+	if (!IS_ERR(gpio))
 		rfkill->reset_gpio = gpio;
-	}
 
-	gpio = devm_gpiod_get_index(&pdev->dev, "shutdown", 1);
-	if (!IS_ERR(gpio)) {
-		ret = gpiod_direction_output(gpio, 0);
-		if (ret)
-			return ret;
+	gpio = devm_gpiod_get_index(&pdev->dev, "shutdown", 1, OUTPUT_LOW);
+	if (!IS_ERR(gpio))
 		rfkill->shutdown_gpio = gpio;
-	}
 
 	/* Make sure at-least one of the GPIO is defined and that
 	 * a name is specified for this instance
diff --git a/sound/soc/codecs/adau1977.c b/sound/soc/codecs/adau1977.c
index fd55da7..b120e9b 100644
--- a/sound/soc/codecs/adau1977.c
+++ b/sound/soc/codecs/adau1977.c
@@ -938,23 +938,18 @@ int adau1977_probe(struct device *dev, struct regmap *regmap,
 		adau1977->dvdd_reg = NULL;
 	}
 
-	adau1977->reset_gpio = devm_gpiod_get(dev, "reset");
+	adau1977->reset_gpio = devm_gpiod_get(dev, "reset", OUTPUT_LOW);
 	if (IS_ERR(adau1977->reset_gpio)) {
 		ret = PTR_ERR(adau1977->reset_gpio);
 		if (ret != -ENOENT && ret != -ENOSYS)
 			return PTR_ERR(adau1977->reset_gpio);
 		adau1977->reset_gpio = NULL;
+	} else {
+		ndelay(100);
 	}
 
 	dev_set_drvdata(dev, adau1977);
 
-	if (adau1977->reset_gpio) {
-		ret = gpiod_direction_output(adau1977->reset_gpio, 0);
-		if (ret)
-			return ret;
-		ndelay(100);
-	}
-
 	ret = adau1977_power_enable(adau1977);
 	if (ret)
 		return ret;
diff --git a/sound/soc/codecs/cs4265.c b/sound/soc/codecs/cs4265.c
index 4c4bf21..55e9c05 100644
--- a/sound/soc/codecs/cs4265.c
+++ b/sound/soc/codecs/cs4265.c
@@ -607,7 +607,7 @@ static int cs4265_i2c_probe(struct i2c_client *i2c_client,
 	}
 
 	cs4265->reset_gpio = devm_gpiod_get(&i2c_client->dev,
-		"reset-gpios");
+		"reset-gpios", OUTPUT_LOW);
 	if (IS_ERR(cs4265->reset_gpio)) {
 		ret = PTR_ERR(cs4265->reset_gpio);
 		if (ret != -ENOENT && ret != -ENOSYS)
@@ -615,9 +615,6 @@ static int cs4265_i2c_probe(struct i2c_client *i2c_client,
 
 		cs4265->reset_gpio = NULL;
 	} else {
-		ret = gpiod_direction_output(cs4265->reset_gpio, 0);
-		if (ret)
-			return ret;
 		mdelay(1);
 		gpiod_set_value_cansleep(cs4265->reset_gpio, 1);
 
diff --git a/sound/soc/codecs/sta350.c b/sound/soc/codecs/sta350.c
index cc97dd5..4745a51 100644
--- a/sound/soc/codecs/sta350.c
+++ b/sound/soc/codecs/sta350.c
@@ -1232,26 +1232,23 @@ static int sta350_i2c_probe(struct i2c_client *i2c,
 #endif
 
 	/* GPIOs */
-	sta350->gpiod_nreset = devm_gpiod_get(dev, "reset");
+	sta350->gpiod_nreset = devm_gpiod_get(dev, "reset", OUTPUT_LOW);
 	if (IS_ERR(sta350->gpiod_nreset)) {
 		ret = PTR_ERR(sta350->gpiod_nreset);
 		if (ret != -ENOENT && ret != -ENOSYS)
 			return ret;
 
 		sta350->gpiod_nreset = NULL;
-	} else {
-		gpiod_direction_output(sta350->gpiod_nreset, 0);
 	}
 
-	sta350->gpiod_power_down = devm_gpiod_get(dev, "power-down");
+	sta350->gpiod_power_down = devm_gpiod_get(dev, "power-down",
+						  OUTPUT_LOW);
 	if (IS_ERR(sta350->gpiod_power_down)) {
 		ret = PTR_ERR(sta350->gpiod_power_down);
 		if (ret != -ENOENT && ret != -ENOSYS)
 			return ret;
 
 		sta350->gpiod_power_down = NULL;
-	} else {
-		gpiod_direction_output(sta350->gpiod_power_down, 0);
 	}
 
 	/* regulators */
diff --git a/sound/soc/codecs/tas2552.c b/sound/soc/codecs/tas2552.c
index a3ae394..a958a86 100644
--- a/sound/soc/codecs/tas2552.c
+++ b/sound/soc/codecs/tas2552.c
@@ -457,15 +457,13 @@ static int tas2552_probe(struct i2c_client *client,
 	if (data == NULL)
 		return -ENOMEM;
 
-	data->enable_gpio = devm_gpiod_get(dev, "enable");
+	data->enable_gpio = devm_gpiod_get(dev, "enable", OUTPUT_LOW);
 	if (IS_ERR(data->enable_gpio)) {
 		ret = PTR_ERR(data->enable_gpio);
 		if (ret != -ENOENT && ret != -ENOSYS)
 			return ret;
 
 		data->enable_gpio = NULL;
-	} else {
-		gpiod_direction_output(data->enable_gpio, 0);
 	}
 
 	data->tas2552_client = client;
diff --git a/sound/soc/jz4740/qi_lb60.c b/sound/soc/jz4740/qi_lb60.c
index 5cb91f9..69696e6 100644
--- a/sound/soc/jz4740/qi_lb60.c
+++ b/sound/soc/jz4740/qi_lb60.c
@@ -83,19 +83,13 @@ static int qi_lb60_probe(struct platform_device *pdev)
 	if (!qi_lb60)
 		return -ENOMEM;
 
-	qi_lb60->snd_gpio = devm_gpiod_get(&pdev->dev, "snd");
+	qi_lb60->snd_gpio = devm_gpiod_get(&pdev->dev, "snd", OUTPUT_LOW);
 	if (IS_ERR(qi_lb60->snd_gpio))
 		return PTR_ERR(qi_lb60->snd_gpio);
-	ret = gpiod_direction_output(qi_lb60->snd_gpio, 0);
-	if (ret)
-		return ret;
 
-	qi_lb60->amp_gpio = devm_gpiod_get(&pdev->dev, "amp");
+	qi_lb60->amp_gpio = devm_gpiod_get(&pdev->dev, "amp", OUTPUT_LOW);
 	if (IS_ERR(qi_lb60->amp_gpio))
 		return PTR_ERR(qi_lb60->amp_gpio);
-	ret = gpiod_direction_output(qi_lb60->amp_gpio, 0);
-	if (ret)
-		return ret;
 
 	card->dev = &pdev->dev;
 
diff --git a/sound/soc/omap/rx51.c b/sound/soc/omap/rx51.c
index 943922c..a5b453b 100644
--- a/sound/soc/omap/rx51.c
+++ b/sound/soc/omap/rx51.c
@@ -455,50 +455,35 @@ static int rx51_soc_probe(struct platform_device *pdev)
 	snd_soc_card_set_drvdata(card, pdata);
 
 	pdata->tvout_selection_gpio = devm_gpiod_get(card->dev,
-						     "tvout-selection");
+						     "tvout-selection",
+						     OUTPUT_LOW);
 	if (IS_ERR(pdata->tvout_selection_gpio)) {
 		dev_err(card->dev, "could not get tvout selection gpio\n");
 		return PTR_ERR(pdata->tvout_selection_gpio);
 	}
 
-	err = gpiod_direction_output(pdata->tvout_selection_gpio, 0);
-	if (err) {
-		dev_err(card->dev, "could not setup tvout selection gpio\n");
-		return err;
-	}
-
 	pdata->jack_detection_gpio = devm_gpiod_get(card->dev,
-						    "jack-detection");
+						    "jack-detection", AS_IS);
 	if (IS_ERR(pdata->jack_detection_gpio)) {
 		dev_err(card->dev, "could not get jack detection gpio\n");
 		return PTR_ERR(pdata->jack_detection_gpio);
 	}
 
-	pdata->eci_sw_gpio = devm_gpiod_get(card->dev, "eci-switch");
+	pdata->eci_sw_gpio = devm_gpiod_get(card->dev, "eci-switch",
+					    OUTPUT_HIGH);
 	if (IS_ERR(pdata->eci_sw_gpio)) {
 		dev_err(card->dev, "could not get eci switch gpio\n");
 		return PTR_ERR(pdata->eci_sw_gpio);
 	}
 
-	err = gpiod_direction_output(pdata->eci_sw_gpio, 1);
-	if (err) {
-		dev_err(card->dev, "could not setup eci switch gpio\n");
-		return err;
-	}
-
 	pdata->speaker_amp_gpio = devm_gpiod_get(card->dev,
-						 "speaker-amplifier");
+						 "speaker-amplifier",
+						 OUTPUT_LOW);
 	if (IS_ERR(pdata->speaker_amp_gpio)) {
 		dev_err(card->dev, "could not get speaker enable gpio\n");
 		return PTR_ERR(pdata->speaker_amp_gpio);
 	}
 
-	err = gpiod_direction_output(pdata->speaker_amp_gpio, 0);
-	if (err) {
-		dev_err(card->dev, "could not setup speaker enable gpio\n");
-		return err;
-	}
-
 	err = devm_snd_soc_register_card(card->dev, card);
 	if (err) {
 		dev_err(&pdev->dev, "snd_soc_register_card failed (%d)\n", err);
diff --git a/sound/soc/soc-jack.c b/sound/soc/soc-jack.c
index ab47fea..08b88de 100644
--- a/sound/soc/soc-jack.c
+++ b/sound/soc/soc-jack.c
@@ -309,7 +309,7 @@ int snd_soc_jack_add_gpios(struct snd_soc_jack *jack, int count,
 			/* GPIO descriptor */
 			gpios[i].desc = gpiod_get_index(gpios[i].gpiod_dev,
 							gpios[i].name,
-							gpios[i].idx);
+							gpios[i].idx, INPUT);
 			if (IS_ERR(gpios[i].desc)) {
 				ret = PTR_ERR(gpios[i].desc);
 				dev_err(gpios[i].gpiod_dev,
@@ -327,17 +327,14 @@ int snd_soc_jack_add_gpios(struct snd_soc_jack *jack, int count,
 				goto undo;
 			}
 
-			ret = gpio_request(gpios[i].gpio, gpios[i].name);
+			ret = gpio_request_one(gpios[i].gpio, GPIOF_DIR_IN,
+					       gpios[i].name);
 			if (ret)
 				goto undo;
 
 			gpios[i].desc = gpio_to_desc(gpios[i].gpio);
 		}
 
-		ret = gpiod_direction_input(gpios[i].desc);
-		if (ret)
-			goto err;
-
 		INIT_DELAYED_WORK(&gpios[i].work, gpio_work);
 		gpios[i].jack = jack;
 
-- 
2.0.2

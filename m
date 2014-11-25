From: Rojhalat Ibrahim <imr@rtschenk.de>
Subject: [PATCH][v3] mdio-mux-gpio: Use GPIO descriptor interface and new gpiod_set_array function
Date: Tue, 25 Nov 2014 14:57:34 +0100
Message-ID: <1581158.UhESICdgeM@pcimr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Linus Walleij <linus.walleij@linaro.org>,
	Alexandre Courbot <acourbot@nvidia.com>,
	David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	David Daney <david.daney@cavium.com>
To: "linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-gpio-owner@vger.kernel.org>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert mdio-mux-gpio to the GPIO descriptor interface and use the new
gpiod_set_array function to set all output signals simultaneously.

Signed-off-by: Rojhalat Ibrahim <imr@rtschenk.de>
Acked-by: David S. Miller <davem@davemloft.net>
--
This patch depends on the gpiod_set_array function, which is available in
the linux-gpio devel tree.

Change log:
  v3: remove unnecessary braces
  v2: fix gpiod_get_index usage

 drivers/net/phy/mdio-mux-gpio.c |   37 +++++++++++++------------------------
 1 file changed, 13 insertions(+), 24 deletions(-)

diff --git a/drivers/net/phy/mdio-mux-gpio.c b/drivers/net/phy/mdio-mux-gpio.c
index 0966951..1eaf81e 100644
--- a/drivers/net/phy/mdio-mux-gpio.c
+++ b/drivers/net/phy/mdio-mux-gpio.c
@@ -14,13 +14,13 @@
 #include <linux/mdio-mux.h>
 #include <linux/of_gpio.h>
 
-#define DRV_VERSION "1.0"
+#define DRV_VERSION "1.1"
 #define DRV_DESCRIPTION "GPIO controlled MDIO bus multiplexer driver"
 
 #define MDIO_MUX_GPIO_MAX_BITS 8
 
 struct mdio_mux_gpio_state {
-	int gpio[MDIO_MUX_GPIO_MAX_BITS];
+	struct gpio_desc *gpio[MDIO_MUX_GPIO_MAX_BITS];
 	unsigned int num_gpios;
 	void *mux_handle;
 };
@@ -28,29 +28,23 @@ struct mdio_mux_gpio_state {
 static int mdio_mux_gpio_switch_fn(int current_child, int desired_child,
 				   void *data)
 {
-	int change;
+	int values[MDIO_MUX_GPIO_MAX_BITS];
 	unsigned int n;
 	struct mdio_mux_gpio_state *s = data;
 
 	if (current_child == desired_child)
 		return 0;
 
-	change = current_child == -1 ? -1 : current_child ^ desired_child;
-
 	for (n = 0; n < s->num_gpios; n++) {
-		if (change & 1)
-			gpio_set_value_cansleep(s->gpio[n],
-						(desired_child & 1) != 0);
-		change >>= 1;
-		desired_child >>= 1;
+		values[n] = (desired_child >> n) & 1;
 	}
+	gpiod_set_array_cansleep(s->num_gpios, s->gpio, values);
 
 	return 0;
 }
 
 static int mdio_mux_gpio_probe(struct platform_device *pdev)
 {
-	enum of_gpio_flags f;
 	struct mdio_mux_gpio_state *s;
 	int num_gpios;
 	unsigned int n;
@@ -70,22 +64,14 @@ static int mdio_mux_gpio_probe(struct platform_device *pdev)
 	s->num_gpios = num_gpios;
 
 	for (n = 0; n < num_gpios; ) {
-		int gpio = of_get_gpio_flags(pdev->dev.of_node, n, &f);
-		if (gpio < 0) {
-			r = (gpio == -ENODEV) ? -EPROBE_DEFER : gpio;
+		struct gpio_desc *gpio = gpiod_get_index(&pdev->dev, NULL, n,
+							 GPIOD_OUT_LOW);
+		if (IS_ERR(gpio)) {
+			r = PTR_ERR(gpio);
 			goto err;
 		}
 		s->gpio[n] = gpio;
-
 		n++;
-
-		r = gpio_request(gpio, "mdio_mux_gpio");
-		if (r)
-			goto err;
-
-		r = gpio_direction_output(gpio, 0);
-		if (r)
-			goto err;
 	}
 
 	r = mdio_mux_init(&pdev->dev,
@@ -98,15 +84,18 @@ static int mdio_mux_gpio_probe(struct platform_device *pdev)
 err:
 	while (n) {
 		n--;
-		gpio_free(s->gpio[n]);
+		gpiod_put(s->gpio[n]);
 	}
 	return r;
 }
 
 static int mdio_mux_gpio_remove(struct platform_device *pdev)
 {
+	unsigned int n;
 	struct mdio_mux_gpio_state *s = dev_get_platdata(&pdev->dev);
 	mdio_mux_uninit(s->mux_handle);
+	for (n = 0; n < s->num_gpios; n++)
+		gpiod_put(s->gpio[n]);
 	return 0;
 }
 
--
2.0.4


From: Rojhalat Ibrahim <imr@rtschenk.de>
Subject: [PATCH 3/3][v2] mdio-mux-gpio: use new gpiod_get_array and gpiod_put_array functions
Date: Wed, 21 Jan 2015 17:46:25 +0100
Message-ID: <2017147.PF4WHTmJS4@pcimr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Alexandre Courbot <acourbot@nvidia.com>,
	Linus Walleij <linus.walleij@linaro.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>
Return-path: <linux-gpio-owner@vger.kernel.org>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the new gpiod_get_array and gpiod_put_array functions for obtaining and
disposing of GPIO descriptors.

Cc: David Miller <davem@davemloft.net>
Signed-off-by: Rojhalat Ibrahim <imr@rtschenk.de>
---
This patch depends on my previous patch "gpiolib: add gpiod_get_array and
gpiod_put_array functions".

v2: use the new interface

Only compile-tested.

 drivers/net/phy/mdio-mux-gpio.c |   61 +++++++++++-----------------------------
 1 file changed, 18 insertions(+), 43 deletions(-)

diff --git a/drivers/net/phy/mdio-mux-gpio.c b/drivers/net/phy/mdio-mux-gpio.c
index 320eb15..3f6929c 100644
--- a/drivers/net/phy/mdio-mux-gpio.c
+++ b/drivers/net/phy/mdio-mux-gpio.c
@@ -12,33 +12,31 @@
 #include <linux/module.h>
 #include <linux/phy.h>
 #include <linux/mdio-mux.h>
-#include <linux/of_gpio.h>
+#include <linux/gpio/consumer.h>
 
 #define DRV_VERSION "1.1"
 #define DRV_DESCRIPTION "GPIO controlled MDIO bus multiplexer driver"
 
-#define MDIO_MUX_GPIO_MAX_BITS 8
-
 struct mdio_mux_gpio_state {
-	struct gpio_desc *gpio[MDIO_MUX_GPIO_MAX_BITS];
-	unsigned int num_gpios;
+	struct gpio_descs *gpios;
 	void *mux_handle;
 };
 
 static int mdio_mux_gpio_switch_fn(int current_child, int desired_child,
 				   void *data)
 {
-	int values[MDIO_MUX_GPIO_MAX_BITS];
-	unsigned int n;
 	struct mdio_mux_gpio_state *s = data;
+	int values[s->gpios->array_size];
+	unsigned int n;
 
 	if (current_child == desired_child)
 		return 0;
 
-	for (n = 0; n < s->num_gpios; n++) {
+	for (n = 0; n < s->gpios->array_size; n++)
 		values[n] = (desired_child >> n) & 1;
-	}
-	gpiod_set_array_cansleep(s->num_gpios, s->gpio, values);
+
+	gpiod_set_array_cansleep(s->gpios->array_size, s->gpios->desc_array,
+				 values);
 
 	return 0;
 }
@@ -46,56 +44,33 @@ static int mdio_mux_gpio_switch_fn(int current_child, int desired_child,
 static int mdio_mux_gpio_probe(struct platform_device *pdev)
 {
 	struct mdio_mux_gpio_state *s;
-	int num_gpios;
-	unsigned int n;
 	int r;
 
-	if (!pdev->dev.of_node)
-		return -ENODEV;
-
-	num_gpios = of_gpio_count(pdev->dev.of_node);
-	if (num_gpios <= 0 || num_gpios > MDIO_MUX_GPIO_MAX_BITS)
-		return -ENODEV;
-
 	s = devm_kzalloc(&pdev->dev, sizeof(*s), GFP_KERNEL);
 	if (!s)
 		return -ENOMEM;
 
-	s->num_gpios = num_gpios;
-
-	for (n = 0; n < num_gpios; ) {
-		struct gpio_desc *gpio = gpiod_get_index(&pdev->dev, NULL, n,
-							 GPIOD_OUT_LOW);
-		if (IS_ERR(gpio)) {
-			r = PTR_ERR(gpio);
-			goto err;
-		}
-		s->gpio[n] = gpio;
-		n++;
-	}
+	s->gpios = gpiod_get_array(&pdev->dev, NULL, GPIOD_OUT_LOW);
+	if (IS_ERR(s->gpios))
+		return PTR_ERR(s->gpios);
 
 	r = mdio_mux_init(&pdev->dev,
 			  mdio_mux_gpio_switch_fn, &s->mux_handle, s);
 
-	if (r == 0) {
-		pdev->dev.platform_data = s;
-		return 0;
-	}
-err:
-	while (n) {
-		n--;
-		gpiod_put(s->gpio[n]);
+	if (r != 0) {
+		gpiod_put_array(s->gpios);
+		return r;
 	}
-	return r;
+
+	pdev->dev.platform_data = s;
+	return 0;
 }
 
 static int mdio_mux_gpio_remove(struct platform_device *pdev)
 {
-	unsigned int n;
 	struct mdio_mux_gpio_state *s = dev_get_platdata(&pdev->dev);
 	mdio_mux_uninit(s->mux_handle);
-	for (n = 0; n < s->num_gpios; n++)
-		gpiod_put(s->gpio[n]);
+	gpiod_put_array(s->gpios);
 	return 0;
 }
 
--
2.0.5


From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: [PATCH 1/7] gpiolib: gpiolib-of: Implement device tree
 gpio-names based lookup
Date: Tue, 15 Apr 2014 14:41:35 +0800
Message-ID: <1397544101-18135-2-git-send-email-wens@csie.org>
References: <1397544101-18135-1-git-send-email-wens@csie.org>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Mika Westerberg <mika.westerberg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>,
	linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <linux-sunxi+bncBCMILY6JWQBBBYVJWONAKGQEJU2GRRI-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1397544101-18135-1-git-send-email-wens-jdAy2FN1RRM@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

This patch provides of_get_gpiod_flags_by_name(), which looks up GPIO
phandles by name only, through gpios/gpio-names, and not by index.

Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
---
 drivers/gpio/gpiolib-of.c | 48 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/of_gpio.h   |  3 +++
 2 files changed, 51 insertions(+)

diff --git a/drivers/gpio/gpiolib-of.c b/drivers/gpio/gpiolib-of.c
index 2024d45..5c586fa 100644
--- a/drivers/gpio/gpiolib-of.c
+++ b/drivers/gpio/gpiolib-of.c
@@ -97,6 +97,54 @@ struct gpio_desc *of_get_named_gpiod_flags(struct device_node *np,
 EXPORT_SYMBOL(of_get_named_gpiod_flags);
 
 /**
+ * of_get_gpiod_flags_by_name() - Get a GPIO descriptor and flags by name
+ * @np:		device node to get GPIO from
+ * @name:	matching name of gpio phandle
+ * @flags:	a flags pointer to fill in
+ *
+ * Returns GPIO descriptor to use with Linux GPIO API, or one of the errno
+ * value on the error condition. If @flags is not NULL the function also fills
+ * in flags for the GPIO.
+ */
+struct gpio_desc *of_get_gpiod_flags_by_name(struct device_node *np,
+		const char *name, enum of_gpio_flags *flags)
+{
+	/* Return -EPROBE_DEFER to support probe() functions to be called
+	 * later when the GPIO actually becomes available
+	 */
+	struct gg_data gg_data = {
+		.flags = flags,
+		.out_gpio = ERR_PTR(-EPROBE_DEFER)
+	};
+	int index = 0;
+	int ret;
+
+	/* exit if no name given */
+	if (!name)
+		return ERR_PTR(-EINVAL);
+
+	/* .of_xlate might decide to not fill in the flags, so clear it. */
+	if (flags)
+		*flags = 0;
+
+	if (name)
+		index = of_property_match_string(np, "gpio-names", name);
+
+	ret = of_parse_phandle_with_args(np, "gpios", "#gpio-cells", index,
+					 &gg_data.gpiospec);
+
+	if (ret)
+		return ERR_PTR(ret);
+
+	gpiochip_find(&gg_data, of_gpiochip_find_and_xlate);
+
+	of_node_put(gg_data.gpiospec.np);
+
+	return gg_data.out_gpio;
+}
+EXPORT_SYMBOL(of_get_gpiod_flags_by_names);
+
+/**
  * of_gpio_simple_xlate - translate gpio_spec to the GPIO number and flags
  * @gc:		pointer to the gpio_chip structure
  * @np:		device node of the GPIO chip
diff --git a/include/linux/of_gpio.h b/include/linux/of_gpio.h
index f14123a..134331f 100644
--- a/include/linux/of_gpio.h
+++ b/include/linux/of_gpio.h
@@ -51,6 +51,9 @@ static inline struct of_mm_gpio_chip *to_of_mm_gpio_chip(struct gpio_chip *gc)
 extern struct gpio_desc *of_get_named_gpiod_flags(struct device_node *np,
 		const char *list_name, int index, enum of_gpio_flags *flags);
 
+extern struct gpio_desc *of_get_gpiod_flags_by_name(struct device_node *np,
+		const char *name, enum of_gpio_flags *flags);
+
 extern int of_mm_gpiochip_add(struct device_node *np,
 			      struct of_mm_gpio_chip *mm_gc);
 
-- 
1.9.1

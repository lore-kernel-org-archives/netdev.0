From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: [PATCH 6/7] net: rfkill: gpio: add clock-frequency
 device tree property
Date: Tue, 15 Apr 2014 14:41:40 +0800
Message-ID: <1397544101-18135-7-git-send-email-wens@csie.org>
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
Return-path: <linux-sunxi+bncBCMILY6JWQBBBYFJWONAKGQEAZOCIUQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1397544101-18135-1-git-send-email-wens-jdAy2FN1RRM@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

Some devices, such as Broadcom Bluetooth devices, require a specific
clock rate for the clock tied to the rfkill device. Add a clock-frequency
property so we can specify this from the device tree.

Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
---
 Documentation/devicetree/bindings/rfkill/rfkill-gpio.txt | 2 ++
 net/rfkill/rfkill-gpio.c                                 | 5 +++++
 2 files changed, 7 insertions(+)

diff --git a/Documentation/devicetree/bindings/rfkill/rfkill-gpio.txt b/Documentation/devicetree/bindings/rfkill/rfkill-gpio.txt
index a23da65..67b5edb 100644
--- a/Documentation/devicetree/bindings/rfkill/rfkill-gpio.txt
+++ b/Documentation/devicetree/bindings/rfkill/rfkill-gpio.txt
@@ -11,6 +11,7 @@ Required properties:
 
 Optional properties:
 - clocks		: phandle to clock to enable/disable
+- clock-frequency	: desired clock rate for the given clock
 
 Example:
 
@@ -21,4 +22,5 @@ Example:
 		gpios = <&pio 7 18 0>;
 		gpio-names = "reset";
 		clocks = <&clk_out_a>;
+		clock-frequency = <32678>;
 	};
diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
index a174359..14ac8c1 100644
--- a/net/rfkill/rfkill-gpio.c
+++ b/net/rfkill/rfkill-gpio.c
@@ -38,6 +38,7 @@ struct rfkill_gpio_data {
 
 	struct rfkill		*rfkill_dev;
 	struct clk		*clk;
+	uint32_t		clk_frequency;
 
 	bool			clk_enabled;
 };
@@ -90,6 +91,7 @@ static int rfkill_gpio_dt_probe(struct device *dev,
 	rfkill->name = np->name;
 	of_property_read_string(np, "rfkill-name", &rfkill->name);
 	of_property_read_u32(np, "rfkill-type", &rfkill->type);
+	of_property_read_u32(np, "clock-frequency", &rfkill->clk_frequency);
 
 	return 0;
 }
@@ -122,6 +124,9 @@ static int rfkill_gpio_probe(struct platform_device *pdev)
 
 	rfkill->clk = devm_clk_get(&pdev->dev, NULL);
 
+	if (!IS_ERR(rfkill->clk) && rfkill->clk_frequency > 0)
+		clk_set_rate(rfkill->clk, rfkill->clk_frequency);
+
 	gpio = devm_gpiod_get_index(&pdev->dev, "reset", 0);
 	if (!IS_ERR(gpio)) {
 		ret = gpiod_direction_output(gpio, 0);
-- 
1.9.1

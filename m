From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: [PATCH 5/7] net: rfkill: gpio: add device tree support
Date: Tue, 15 Apr 2014 14:41:39 +0800
Message-ID: <1397544101-18135-6-git-send-email-wens@csie.org>
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

Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
---
 .../devicetree/bindings/rfkill/rfkill-gpio.txt     | 24 ++++++++++++++++++++++
 net/rfkill/rfkill-gpio.c                           | 23 +++++++++++++++++++++
 2 files changed, 47 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/rfkill/rfkill-gpio.txt

diff --git a/Documentation/devicetree/bindings/rfkill/rfkill-gpio.txt b/Documentation/devicetree/bindings/rfkill/rfkill-gpio.txt
new file mode 100644
index 0000000..a23da65
--- /dev/null
+++ b/Documentation/devicetree/bindings/rfkill/rfkill-gpio.txt
@@ -0,0 +1,24 @@
+GPIO controlled RFKILL devices
+
+Required properties:
+- compatible	: Must be "rfkill-gpio".
+- rfkill-name	: Name of RFKILL device
+- rfkill-type	: Type of RFKILL device: 1 for WiFi, 2 for BlueTooth, etc.
+		  See include/uapi/linux/rfkill.h for all valid values
+- gpios		: At most two GPIO phandles
+- gpio-names	: Shall be "reset" or "shutdown", matching gpios.
+		  If both are provided, the "reset" GPIO is toggled first.
+
+Optional properties:
+- clocks		: phandle to clock to enable/disable
+
+Example:
+
+	rfkill_bt {
+		compatible = "rfkill-gpio";
+		rfkill-name = "bluetooth";
+		rfkill-type = <2>;
+		gpios = <&pio 7 18 0>;
+		gpio-names = "reset";
+		clocks = <&clk_out_a>;
+	};
diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
index f46ddf7..a174359 100644
--- a/net/rfkill/rfkill-gpio.c
+++ b/net/rfkill/rfkill-gpio.c
@@ -26,6 +26,7 @@
 #include <linux/slab.h>
 #include <linux/acpi.h>
 #include <linux/gpio/consumer.h>
+#include <linux/of_gpio.h>
 
 #include <linux/rfkill-gpio.h>
 
@@ -81,6 +82,18 @@ static int rfkill_gpio_acpi_probe(struct device *dev,
 	return 0;
 }
 
+static int rfkill_gpio_dt_probe(struct device *dev,
+				struct rfkill_gpio_data *rfkill)
+{
+	struct device_node * np = dev->of_node;
+
+	rfkill->name = np->name;
+	of_property_read_string(np, "rfkill-name", &rfkill->name);
+	of_property_read_u32(np, "rfkill-type", &rfkill->type);
+
+	return 0;
+}
+
 static int rfkill_gpio_probe(struct platform_device *pdev)
 {
 	struct rfkill_gpio_platform_data *pdata = pdev->dev.platform_data;
@@ -96,6 +109,10 @@ static int rfkill_gpio_probe(struct platform_device *pdev)
 		ret = rfkill_gpio_acpi_probe(&pdev->dev, rfkill);
 		if (ret)
 			return ret;
+	} else if (&pdev->dev.of_node) {
+		ret = rfkill_gpio_dt_probe(&pdev->dev, rfkill);
+		if (ret)
+			return ret;
 	} else if (pdata) {
 		rfkill->name = pdata->name;
 		rfkill->type = pdata->type;
@@ -167,6 +184,11 @@ static const struct acpi_device_id rfkill_acpi_match[] = {
 };
 #endif
 
+static const struct of_device_id rfkill_of_match[] = {
+	{ .compatible = "rfkill-gpio", },
+	{},
+};
+
 static struct platform_driver rfkill_gpio_driver = {
 	.probe = rfkill_gpio_probe,
 	.remove = rfkill_gpio_remove,
@@ -174,6 +196,7 @@ static struct platform_driver rfkill_gpio_driver = {
 		.name = "rfkill_gpio",
 		.owner = THIS_MODULE,
 		.acpi_match_table = ACPI_PTR(rfkill_acpi_match),
+		.of_match_table = of_match_ptr(rfkill_of_match),
 	},
 };
 
-- 
1.9.1

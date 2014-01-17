From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: [PATCH RFC 4/6] net: rfkill: gpio: add device tree support
Date: Fri, 17 Jan 2014 14:47:29 +0800
Message-ID: <1389941251-32692-5-git-send-email-wens@csie.org>
References: <1389941251-32692-1-git-send-email-wens@csie.org>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-sunxi+bncBCMILY6JWQBBBCNE4OLAKGQEBKPUNCA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1389941251-32692-1-git-send-email-wens-jdAy2FN1RRM@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
---
 .../devicetree/bindings/rfkill/rfkill-gpio.txt     | 26 ++++++++++++++++++++++
 net/rfkill/rfkill-gpio.c                           | 23 +++++++++++++++++++
 2 files changed, 49 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/rfkill/rfkill-gpio.txt

diff --git a/Documentation/devicetree/bindings/rfkill/rfkill-gpio.txt b/Documentation/devicetree/bindings/rfkill/rfkill-gpio.txt
new file mode 100644
index 0000000..8a07ea4
--- /dev/null
+++ b/Documentation/devicetree/bindings/rfkill/rfkill-gpio.txt
@@ -0,0 +1,26 @@
+GPIO controlled RFKILL devices
+
+Required properties:
+- compatible	: Must be "rfkill-gpio".
+- rfkill-name	: Name of RFKILL device
+- rfkill-type	: Type of RFKILL device: 1 for WiFi, 2 for BlueTooth
+- NAME_shutdown-gpios	: GPIO phandle to shutdown control
+			  (phandle must be the second)
+- NAME_reset-gpios	: GPIO phandle to reset control
+
+NAME must match the rfkill-name property. NAME_shutdown-gpios or
+NAME_reset-gpios, or both, must be defined.
+
+Optional properties:
+- clocks		: phandle to clock to enable/disable
+
+Example:
+
+	rfkill_bt: rfkill@0 {
+		compatible = "rfkill-gpio";
+		rfkill-name = "bluetooth";
+		rfkill-type = <2>;
+		bluetooth_shutdown-gpios = <0>, <&pio 7 18 0>;
+		bluetooth_reset-gpios = <&pio 7 24 0>;
+		clocks = <&clk_out_a>;
+	};
diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
index 3084fa3..48381a8 100644
--- a/net/rfkill/rfkill-gpio.c
+++ b/net/rfkill/rfkill-gpio.c
@@ -26,6 +26,7 @@
 #include <linux/slab.h>
 #include <linux/acpi.h>
 #include <linux/gpio/consumer.h>
+#include <linux/of_gpio.h>
 
 #include <linux/rfkill-gpio.h>
 
@@ -83,6 +84,18 @@ static int rfkill_gpio_acpi_probe(struct device *dev,
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
@@ -100,6 +113,10 @@ static int rfkill_gpio_probe(struct platform_device *pdev)
 		ret = rfkill_gpio_acpi_probe(&pdev->dev, rfkill);
 		if (ret)
 			return ret;
+	} else if (&pdev->dev.of_node) {
+		ret = rfkill_gpio_dt_probe(&pdev->dev, rfkill);
+		if (ret)
+			return ret;
 	} else if (pdata) {
 		clk_name = pdata->power_clk_name;
 		rfkill->name = pdata->name;
@@ -189,6 +206,11 @@ static const struct acpi_device_id rfkill_acpi_match[] = {
 	{ },
 };
 
+static const struct of_device_id rfkill_of_match[] = {
+	{ .compatible = "rfkill-gpio", },
+	{},
+};
+
 static struct platform_driver rfkill_gpio_driver = {
 	.probe = rfkill_gpio_probe,
 	.remove = rfkill_gpio_remove,
@@ -196,6 +218,7 @@ static struct platform_driver rfkill_gpio_driver = {
 		.name = "rfkill_gpio",
 		.owner = THIS_MODULE,
 		.acpi_match_table = ACPI_PTR(rfkill_acpi_match),
+		.of_match_table = of_match_ptr(rfkill_of_match),
 	},
 };
 
-- 
1.8.5.2

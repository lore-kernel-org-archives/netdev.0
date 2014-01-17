From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: [PATCH RFC 5/6] net: rfkill: gpio: add clock-frequency
 device tree property
Date: Fri, 17 Jan 2014 14:47:30 +0800
Message-ID: <1389941251-32692-6-git-send-email-wens@csie.org>
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
Return-path: <linux-sunxi+bncBCMILY6JWQBBBCFE4OLAKGQE7VKJF7A-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1389941251-32692-1-git-send-email-wens-jdAy2FN1RRM@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

Some devices, such as Broadcom Bluetooth devices, require a specific
clock rate for the clock tied to the rfkill device. Add clock-frequency
property so we can specify this from the device tree.

Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
---
 Documentation/devicetree/bindings/rfkill/rfkill-gpio.txt | 2 ++
 net/rfkill/rfkill-gpio.c                                 | 4 ++++
 2 files changed, 6 insertions(+)

diff --git a/Documentation/devicetree/bindings/rfkill/rfkill-gpio.txt b/Documentation/devicetree/bindings/rfkill/rfkill-gpio.txt
index 8a07ea4..8b8db0a 100644
--- a/Documentation/devicetree/bindings/rfkill/rfkill-gpio.txt
+++ b/Documentation/devicetree/bindings/rfkill/rfkill-gpio.txt
@@ -13,6 +13,7 @@ NAME_reset-gpios, or both, must be defined.
 
 Optional properties:
 - clocks		: phandle to clock to enable/disable
+- clock-frequency	: clock rate to set for the given clock
 
 Example:
 
@@ -23,4 +24,5 @@ Example:
 		bluetooth_shutdown-gpios = <0>, <&pio 7 18 0>;
 		bluetooth_reset-gpios = <&pio 7 24 0>;
 		clocks = <&clk_out_a>;
+		clock-frequency = <32678>;
 	};
diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
index 48381a8..3092681 100644
--- a/net/rfkill/rfkill-gpio.c
+++ b/net/rfkill/rfkill-gpio.c
@@ -40,6 +40,7 @@ struct rfkill_gpio_data {
 	char			*reset_name;
 	char			*shutdown_name;
 	struct clk		*clk;
+	int			clk_frequency;
 
 	bool			clk_enabled;
 };
@@ -92,6 +93,7 @@ static int rfkill_gpio_dt_probe(struct device *dev,
 	rfkill->name = np->name;
 	of_property_read_string(np, "rfkill-name", &rfkill->name);
 	of_property_read_u32(np, "rfkill-type", &rfkill->type);
+	of_property_read_u32(np, "clock-frequency", &rfkill->clk_frequency);
 
 	return 0;
 }
@@ -138,6 +140,8 @@ static int rfkill_gpio_probe(struct platform_device *pdev)
 	snprintf(rfkill->shutdown_name, len + 10, "%s_shutdown", rfkill->name);
 
 	rfkill->clk = devm_clk_get(&pdev->dev, clk_name);
+	if (!IS_ERR(rfkill->clk) && rfkill->clk_frequency > 0)
+		clk_set_rate(rfkill->clk, rfkill->clk_frequency);
 
 	gpio = devm_gpiod_get_index(&pdev->dev, rfkill->reset_name, 0);
 	if (!IS_ERR(gpio)) {
-- 
1.8.5.2

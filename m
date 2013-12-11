From: Nishanth Menon <nm@ti.com>
Subject: [PATCH 1/2] net: smc91x: Read hardware behavior flags from device tree
Date: Wed, 11 Dec 2013 04:21:44 -0600
Message-ID: <1386757305-12545-2-git-send-email-nm@ti.com>
References: <1386757305-12545-1-git-send-email-nm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	=?UTF-8?q?Beno=C3=AEt=20Cousson?= <bcousson@baylibre.com>,
	Tony Lindgren <tony@atomide.com>, Nishanth Menon <nm@ti.com>
To: <devicetree@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	<netdev@vger.kernel.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1386757305-12545-1-git-send-email-nm@ti.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 682a169 (smc91x: add devicetree support) introduced basic
device tree support in the form of identifier match. However,
platform_data flags equivalent was not introduced, nor was an
appropriate bindings document introduced.

In many legacy platforms such as Texas Instrument's SDP2430,
platform_data flags have been used to describe the hardware behavior.

So, introduce the legacy equivalent flags and bindings document to
handle the transition to device tree enabled boot.

Signed-off-by: Nishanth Menon <nm@ti.com>
---
I am open to the suggestion to make smsc,leda|b macro based value instead of
the current string based option.

If it is prefered, i could move the bindings off to it's own patch as
well. Currently this is squashed as it makes more sense to read in
context.

 Documentation/devicetree/bindings/net/smsc91x.txt |   45 +++++++++
 drivers/net/ethernet/smsc/smc91x.c                |  106 ++++++++++++++++++++-
 2 files changed, 150 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/devicetree/bindings/net/smsc91x.txt

diff --git a/Documentation/devicetree/bindings/net/smsc91x.txt b/Documentation/devicetree/bindings/net/smsc91x.txt
new file mode 100644
index 0000000..389b807
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/smsc91x.txt
@@ -0,0 +1,45 @@
+* Smart Mixed-Signal Connectivity (SMSC) LAN91c94/91c111 Controller
+
+Required properties:
+- compatible : Should be one of:
+	"smsc,lan91c94"
+	"smsc,lan91c111"
+- reg : Address and length of the io space for SMSC LAN
+- interrupts : Should contain SMSC LAN interrupt line
+- interrupt-parent : Should be the phandle for the interrupt controller
+  that services interrupts for this device
+
+Optional properties:
+- reg-shift : Specify the quantity to shift the register offsets by
+- reg-io-width : Specify the size (in bytes) of the IO accesses that
+  should be performed on the device.  Valid value for SMSC LAN is
+  1, 2 or 4.
+- smsc,nowait : bool for fast accesses and no extra wait cycles
+- "smsc,leda" "smsc,ledb": string indicating when to glow led a or b, one of:
+	"100_10"	: 100Mbps OR's with 10Mbps link detect
+	"10"		: 10Mbps link detect
+	"100"		: 100Mbps link detect
+	"FD"		: Full Duplex Mode
+	"TX_RX"		: TX or RX packet occurred
+	"TX"		: TX packet occurred
+	"RX"		: RX packet occurred
+
+Examples:
+
+ethernet@gpmc {
+	compatible = "smsc,lan91c94";
+	reg = <5 0x300 0xf>;
+	reg-io-width = <2>;
+	interrupt-parent = <&gpio5>;
+	interrupts = <21 IRQ_TYPE_LEVEL_LOW>;	/* gpio149 */
+	smsc,nowait;
+	smsc,leda = "100_10";
+	smsc,ledb = "TX_RX";
+};
+
+ethernet@c8000000 {
+	compatible = "smsc,lan91c111";
+	reg = <0xc8000000 0x10>;
+	interrupt-parent = <&pic>;
+	interrupts = <27>;
+};
diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 0c9b5d9..98ed8c5 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -2184,6 +2184,101 @@ static void smc_release_datacs(struct platform_device *pdev, struct net_device *
 	}
 }
 
+#if ENABLED(CONFIG_OF)
+static int smc_of_led_string(const char *val)
+{
+	if (!strcmp(val, "100_10"))
+		return RPC_LED_100_10;
+	else if (!strcmp(val, "10"))
+		return RPC_LED_10;
+	else if (!strcmp(val, "100"))
+		return RPC_LED_100;
+	else if (!strcmp(val, "FD"))
+		return RPC_LED_FD;
+	else if (!strcmp(val, "TX_RX"))
+		return RPC_LED_TX_RX;
+	else if (!strcmp(val, "TX"))
+		return RPC_LED_TX;
+	else if (!strcmp(val, "RX"))
+		return RPC_LED_RX;
+
+	return -1;
+}
+
+static struct smc91x_platdata *smc_of_pdata(struct device *dev)
+{
+	struct device_node *np = dev->of_node;
+	unsigned long flags = 0;
+	int io_shift, io_width;
+	int led_a = -1, led_b = -1;
+	const char *led_prop;
+	struct smc91x_platdata *pd = NULL;
+
+	if (!of_property_read_u32(np, "reg-io-width", &io_width)) {
+		switch (io_width) {
+		case 1:
+			flags |= SMC91X_USE_8BIT;
+			break;
+		case 2:
+			flags |= SMC91X_USE_16BIT;
+			break;
+		case 4:
+			flags |= SMC91X_USE_32BIT;
+			break;
+		default:
+			dev_err(dev, "reg-io-width %d should be 1, 2 or 4\n",
+				io_width);
+			return ERR_PTR(-EINVAL);
+		}
+	}
+
+	if (!of_property_read_u32(np, "reg-shift", &io_shift)) {
+		if (io_shift > 3) {
+			dev_err(dev, "reg-shift %d should be <= 3\n",
+				io_shift);
+			return ERR_PTR(-EINVAL);
+		}
+		flags |= io_shift << 4;
+	}
+
+	flags |= of_property_read_bool(np, "smsc,nowait") ? SMC91X_NOWAIT : 0;
+
+	if (!of_property_read_string(np, "smsc,leda", &led_prop)) {
+		led_a = smc_of_led_string(led_prop);
+		if (led_a < 0) {
+			dev_err(dev, "smsc,leda %s unknown value\n", led_prop);
+			return ERR_PTR(-EINVAL);
+		}
+	}
+	if (!of_property_read_string(np, "smsc,ledb", &led_prop)) {
+		led_b = smc_of_led_string(led_prop);
+		if (led_a < 0) {
+			dev_err(dev, "smsc,ledb %s unknown value\n", led_prop);
+			return ERR_PTR(-EINVAL);
+		}
+	}
+
+	if (flags || led_a >= 0 || led_b >= 0) {
+		pd = devm_kzalloc(dev, sizeof(*pd), GFP_KERNEL);
+		if (!pd)
+			return ERR_PTR(-ENOMEM);
+
+		pd->flags = flags;
+		if (led_a >= 0)
+			pd->leda = led_a;
+		if (led_b >= 0)
+			pd->ledb = led_b;
+	}
+
+	return pd;
+}
+#else
+static inline struct smc91x_platdata *smc_of_pdata(struct device *dev)
+{
+	return NULL;
+}
+#endif
+
 /*
  * smc_init(void)
  *   Input parameters:
@@ -2197,7 +2292,8 @@ static void smc_release_datacs(struct platform_device *pdev, struct net_device *
  */
 static int smc_drv_probe(struct platform_device *pdev)
 {
-	struct smc91x_platdata *pd = dev_get_platdata(&pdev->dev);
+	struct device *dev = &pdev->dev;
+	struct smc91x_platdata *pd = dev_get_platdata(dev);
 	struct smc_local *lp;
 	struct net_device *ndev;
 	struct resource *res, *ires;
@@ -2205,6 +2301,14 @@ static int smc_drv_probe(struct platform_device *pdev)
 	unsigned long irq_flags = SMC_IRQ_FLAGS;
 	int ret;
 
+	if (dev->of_node) {
+		pd = smc_of_pdata(dev);
+		if (IS_ERR(pd)) {
+			ret = PTR_ERR(pd);
+			goto out;
+		}
+	}
+
 	ndev = alloc_etherdev(sizeof(struct smc_local));
 	if (!ndev) {
 		ret = -ENOMEM;
-- 
1.7.9.5


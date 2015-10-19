From: Heiko Schocher <hs@denx.de>
Subject: [PATCH] net, can, ti_hecc: add DT support for the ti,hecc controller
Date: Mon, 19 Oct 2015 08:39:17 +0200
Message-ID: <1445236757-29019-1-git-send-email-hs@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Heiko Schocher <hs@denx.de>,
	=?UTF-8?q?Beno=C3=AEt=20Cousson?= <bcousson@baylibre.com>,
	Anant Gole <anantgole@ti.com>, devicetree@vger.kernel.org,
	netdev@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-can@vger.kernel.org, Tony Lindgren <tony@atomide.com>,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-omap@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

add DT support for the ti hecc controller, used on
am3517 SoCs.

Signed-off-by: Heiko Schocher <hs@denx.de>
---

 .../devicetree/bindings/net/can/ti_hecc-can.txt    | 20 ++++++++++
 arch/arm/boot/dts/am3517.dtsi                      | 13 +++++++
 drivers/net/can/ti_hecc.c                          | 45 +++++++++++++++++++++-
 3 files changed, 76 insertions(+), 2 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/can/ti_hecc-can.txt

diff --git a/Documentation/devicetree/bindings/net/can/ti_hecc-can.txt b/Documentation/devicetree/bindings/net/can/ti_hecc-can.txt
new file mode 100644
index 0000000..09fab59
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/can/ti_hecc-can.txt
@@ -0,0 +1,20 @@
+* TI HECC CAN *
+
+Required properties:
+  - compatible: Should be "ti,hecc"
+  - reg: Should contain CAN controller registers location and length
+  - interrupts: Should contain IRQ line for the CAN controller
+
+Example:
+
+	can0: hecc@5c050000 {
+		compatible = "ti,hecc";
+		reg = <0x5c050000 0x4000>;
+		interrupts = <24>;
+		ti,hecc_scc_offset = <0>;
+		ti,hecc_scc_ram_offset = <0x3000>;
+		ti,hecc_ram_offset = <0x3000>;
+		ti,hecc_mbx_offset = <0x2000>;
+		ti,hecc_int_line = <0>;
+		ti,hecc_version = <1>;
+	};
diff --git a/arch/arm/boot/dts/am3517.dtsi b/arch/arm/boot/dts/am3517.dtsi
index 5e3f5e8..47bc429 100644
--- a/arch/arm/boot/dts/am3517.dtsi
+++ b/arch/arm/boot/dts/am3517.dtsi
@@ -25,6 +25,19 @@
 			interrupt-names = "mc";
 		};
 
+		can0: hecc@5c050000 {
+			compatible = "ti,hecc";
+			reg = <0x5c050000 0x4000>;
+			interrupts = <24>;
+			ti,hecc_scc_offset = <0>;
+			ti,hecc_scc_ram_offset = <0x3000>;
+			ti,hecc_ram_offset = <0x3000>;
+			ti,hecc_mbx_offset = <0x2000>;
+			ti,hecc_int_line = <0>;
+			ti,hecc_version = <1>;
+			status = "disabled";
+		};
+
 		davinci_emac: ethernet@0x5c000000 {
 			compatible = "ti,am3517-emac";
 			ti,hwmods = "davinci_emac";
diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
index c08e8ea..f1705d5 100644
--- a/drivers/net/can/ti_hecc.c
+++ b/drivers/net/can/ti_hecc.c
@@ -875,16 +875,56 @@ static const struct net_device_ops ti_hecc_netdev_ops = {
 	.ndo_change_mtu		= can_change_mtu,
 };
 
+#if defined(CONFIG_OF)
+static const struct of_device_id ti_hecc_can_dt_ids[] = {
+	{
+		.compatible = "ti,hecc",
+	}, {
+		/* sentinel */
+	}
+};
+MODULE_DEVICE_TABLE(of, ti_hecc_can_dt_ids);
+#endif
+
+static const struct ti_hecc_platform_data
+*ti_hecc_can_get_driver_data(struct platform_device *pdev)
+{
+	if (pdev->dev.of_node) {
+		struct ti_hecc_platform_data *data;
+		struct device_node *np = pdev->dev.of_node;
+
+		data = devm_kzalloc(&pdev->dev, sizeof(*data), GFP_KERNEL);
+		if (!data)
+			return NULL;
+
+		of_property_read_u32(np, "ti,hecc_scc_offset",
+				     &data->scc_hecc_offset);
+		of_property_read_u32(np, "ti,hecc_scc_ram_offset",
+				     &data->scc_ram_offset);
+		of_property_read_u32(np, "ti,hecc_ram_offset",
+				     &data->hecc_ram_offset);
+		of_property_read_u32(np, "ti,hecc_mbx_offset",
+				     &data->mbx_offset);
+		of_property_read_u32(np, "ti,hecc_int_line",
+				     &data->int_line);
+		of_property_read_u32(np, "ti,hecc_version",
+				     &data->version);
+		return data;
+	}
+	return (const struct ti_hecc_platform_data *)
+		dev_get_platdata(&pdev->dev);
+}
+
 static int ti_hecc_probe(struct platform_device *pdev)
 {
 	struct net_device *ndev = (struct net_device *)0;
 	struct ti_hecc_priv *priv;
-	struct ti_hecc_platform_data *pdata;
+	const struct ti_hecc_platform_data *pdata;
 	struct resource *mem, *irq;
 	void __iomem *addr;
 	int err = -ENODEV;
 
-	pdata = dev_get_platdata(&pdev->dev);
+	pdata = ti_hecc_can_get_driver_data(pdev);
 	if (!pdata) {
 		dev_err(&pdev->dev, "No platform data\n");
 		goto probe_exit;
@@ -1040,6 +1080,7 @@ static int ti_hecc_resume(struct platform_device *pdev)
 static struct platform_driver ti_hecc_driver = {
 	.driver = {
 		.name    = DRV_NAME,
+		.of_match_table = of_match_ptr(ti_hecc_can_dt_ids),
 	},
 	.probe = ti_hecc_probe,
 	.remove = ti_hecc_remove,
-- 
2.1.0


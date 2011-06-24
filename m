From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH v2 3/5] serial/imx: add device tree support
Date: Sat, 25 Jun 2011 02:04:34 +0800
Message-ID: <1308938676-31121-4-git-send-email-shawn.guo@linaro.org>
References: <1308938676-31121-1-git-send-email-shawn.guo@linaro.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-serial@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	patches@linaro.org, Shawn Guo <shawn.guo@linaro.org>,
	Jeremy Kerr <jeremy.kerr@canonical.com>,
	Jason Liu <jason.hui@linaro.org>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-serial-owner@vger.kernel.org>
In-Reply-To: <1308938676-31121-1-git-send-email-shawn.guo@linaro.org>
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It adds device tree data parsing support for imx tty/serial driver.

Signed-off-by: Jeremy Kerr <jeremy.kerr@canonical.com>
Signed-off-by: Jason Liu <jason.hui@linaro.org>
Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
Cc: Sascha Hauer <s.hauer@pengutronix.de>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
---
 .../bindings/tty/serial/fsl-imx-uart.txt           |   20 +++++
 drivers/tty/serial/imx.c                           |   82 +++++++++++++++++---
 2 files changed, 92 insertions(+), 10 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/tty/serial/fsl-imx-uart.txt

diff --git a/Documentation/devicetree/bindings/tty/serial/fsl-imx-uart.txt b/Documentation/devicetree/bindings/tty/serial/fsl-imx-uart.txt
new file mode 100644
index 0000000..9aafe0a
--- /dev/null
+++ b/Documentation/devicetree/bindings/tty/serial/fsl-imx-uart.txt
@@ -0,0 +1,20 @@
+* Freescale i.MX Universal Asynchronous Receiver/Transmitter (UART)
+
+Required properties:
+- compatible : should be "fsl,<soc>-uart"
+- reg : address and length of the register set for the device
+- interrupts : should contain uart interrupt
+- id : should be the port ID defined by soc
+
+Optional properties:
+- fsl,uart-has-rtscts : indicate the uart has rts and cts
+- fsl,irda-mode : support irda mode
+
+Example:
+
+uart@73fbc000 {
+	compatible = "fsl,imx51-uart", "fsl,imx21-uart";
+	reg = <0x73fbc000 0x4000>;
+	interrupts = <31>;
+	fsl,uart-has-rtscts;
+};
diff --git a/drivers/tty/serial/imx.c b/drivers/tty/serial/imx.c
index 8a6f4e1..bef27b3 100644
--- a/drivers/tty/serial/imx.c
+++ b/drivers/tty/serial/imx.c
@@ -45,6 +45,8 @@
 #include <linux/delay.h>
 #include <linux/rational.h>
 #include <linux/slab.h>
+#include <linux/of.h>
+#include <linux/of_device.h>
 
 #include <asm/io.h>
 #include <asm/irq.h>
@@ -227,6 +229,12 @@ static struct imx_uart_data imx_uart_devdata[] = {
 #define IS_IMX1_UART(sport) (sport->devdata->type == IMX1_UART)
 #define IS_IMX2_UART(sport) (sport->devdata->type == IMX2_UART)
 
+static struct of_device_id imx_uart_dt_ids[] = {
+	{ .compatible = "fsl,imx1-uart", .data = &imx_uart_devdata[IMX1_UART], },
+	{ .compatible = "fsl,imx21-uart", .data = &imx_uart_devdata[IMX2_UART], },
+	{ /* sentinel */ },
+};
+
 /*
  * Handle any change of modem status signal since we were last called.
  */
@@ -1250,6 +1258,58 @@ static int serial_imx_resume(struct platform_device *dev)
 	return 0;
 }
 
+#ifdef CONFIG_OF
+static int serial_imx_probe_dt(struct imx_port *sport,
+		struct platform_device *pdev)
+{
+	struct device_node *node = pdev->dev.of_node;
+	const struct of_device_id *of_id =
+			of_match_device(imx_uart_dt_ids, &pdev->dev);
+
+	if (!node)
+		return -ENODEV;
+
+	pdev->id = of_alias_get_id(node, "serial");
+	if (pdev->id < 0)
+		return -ENODEV;
+
+	if (of_get_property(node, "fsl,uart-has-rtscts", NULL))
+		sport->have_rtscts = 1;
+
+	if (of_get_property(node, "fsl,irda-mode", NULL))
+		sport->use_irda = 1;
+
+	sport->devdata = of_id->data;
+
+	return 0;
+}
+#else
+static int serial_imx_probe_dt(struct imx_port *sport,
+		struct platform_device *pdev)
+{
+	return -ENODEV;
+}
+#endif
+
+static int serial_imx_probe_pdata(struct imx_port *sport,
+		struct platform_device *pdev)
+{
+	struct imxuart_platform_data *pdata = pdev->dev.platform_data;
+
+	if (!pdata)
+		return 0;
+
+	if (pdata->flags & IMXUART_HAVE_RTSCTS)
+		sport->have_rtscts = 1;
+
+	if (pdata->flags & IMXUART_IRDA)
+		sport->use_irda = 1;
+
+	sport->devdata = &imx_uart_devdata[pdev->id_entry->driver_data];
+
+	return 0;
+}
+
 static int serial_imx_probe(struct platform_device *pdev)
 {
 	struct imx_port *sport;
@@ -1262,6 +1322,12 @@ static int serial_imx_probe(struct platform_device *pdev)
 	if (!sport)
 		return -ENOMEM;
 
+	ret = serial_imx_probe_dt(sport, pdev);
+	if (ret == -ENODEV)
+		ret = serial_imx_probe_pdata(sport, pdev);
+	if (ret)
+		goto free;
+
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (!res) {
 		ret = -ENODEV;
@@ -1290,7 +1356,6 @@ static int serial_imx_probe(struct platform_device *pdev)
 	init_timer(&sport->timer);
 	sport->timer.function = imx_timeout;
 	sport->timer.data     = (unsigned long)sport;
-	sport->devdata = &imx_uart_devdata[pdev->id_entry->driver_data];
 
 	sport->clk = clk_get(&pdev->dev, "uart");
 	if (IS_ERR(sport->clk)) {
@@ -1301,17 +1366,13 @@ static int serial_imx_probe(struct platform_device *pdev)
 
 	sport->port.uartclk = clk_get_rate(sport->clk);
 
-	imx_ports[pdev->id] = sport;
+	if (imx_ports[sport->port.line]) {
+		ret = -EBUSY;
+		goto clkput;
+	}
+	imx_ports[sport->port.line] = sport;
 
 	pdata = pdev->dev.platform_data;
-	if (pdata && (pdata->flags & IMXUART_HAVE_RTSCTS))
-		sport->have_rtscts = 1;
-
-#ifdef CONFIG_IRDA
-	if (pdata && (pdata->flags & IMXUART_IRDA))
-		sport->use_irda = 1;
-#endif
-
 	if (pdata && pdata->init) {
 		ret = pdata->init(pdev);
 		if (ret)
@@ -1386,6 +1447,7 @@ static struct platform_driver serial_imx_driver = {
 	.driver		= {
 		.name	= "imx-uart",
 		.owner	= THIS_MODULE,
+		.of_match_table = imx_uart_dt_ids,
 	},
 };
 
-- 
1.7.4.1


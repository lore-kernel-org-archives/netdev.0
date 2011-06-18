From: Shawn Guo <shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/3] serial/imx: add device tree support
Date: Sat, 18 Jun 2011 23:19:12 +0800
Message-ID: <1308410354-21387-2-git-send-email-shawn.guo@linaro.org>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Jason Liu <jason.hui-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jeremy Kerr <jeremy.kerr-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1308410354-21387-1-git-send-email-shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

It adds device tree data parsing support for imx tty/serial driver.

Signed-off-by: Jeremy Kerr <jeremy.kerr-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Jason Liu <jason.hui-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Signed-off-by: Shawn Guo <shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Cc: Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 .../bindings/tty/serial/fsl-imx-uart.txt           |   21 +++++
 drivers/tty/serial/imx.c                           |   81 +++++++++++++++++---
 2 files changed, 92 insertions(+), 10 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/tty/serial/fsl-imx-uart.txt

diff --git a/Documentation/devicetree/bindings/tty/serial/fsl-imx-uart.txt b/Documentation/devicetree/bindings/tty/serial/fsl-imx-uart.txt
new file mode 100644
index 0000000..7648e17
--- /dev/null
+++ b/Documentation/devicetree/bindings/tty/serial/fsl-imx-uart.txt
@@ -0,0 +1,21 @@
+* Freescale i.MX Universal Asynchronous Receiver/Transmitter (UART)
+
+Required properties:
+- compatible : should be "fsl,<soc>-uart", "fsl,imx-uart"
+- reg : address and length of the register set for the device
+- interrupts : should contain uart interrupt
+- id : should be the port ID defined by soc
+
+Optional properties:
+- fsl,has-rts-cts : indicate it has rts-cts
+- fsl,irda-mode : support irda mode
+
+Example:
+
+uart@73fbc000 {
+	compatible = "fsl,imx51-uart", "fsl,imx-uart";
+	reg = <0x73fbc000 0x4000>;
+	interrupts = <31>;
+	id = <1>;
+	fsl,has-rts-cts;
+};
diff --git a/drivers/tty/serial/imx.c b/drivers/tty/serial/imx.c
index a544731..2769353 100644
--- a/drivers/tty/serial/imx.c
+++ b/drivers/tty/serial/imx.c
@@ -45,6 +45,8 @@
 #include <linux/delay.h>
 #include <linux/rational.h>
 #include <linux/slab.h>
+#include <linux/of.h>
+#include <linux/of_address.h>
 
 #include <asm/io.h>
 #include <asm/irq.h>
@@ -1223,6 +1225,63 @@ static int serial_imx_resume(struct platform_device *dev)
 	return 0;
 }
 
+#ifdef CONFIG_OF
+static int serial_imx_probe_dt(struct imx_port *sport,
+		struct platform_device *pdev)
+{
+	struct device_node *node = pdev->dev.of_node;
+	const __be32 *line;
+
+	if (!node)
+		return -ENODEV;
+
+	line = of_get_property(node, "id", NULL);
+	if (!line)
+		return -ENODEV;
+
+	sport->port.line = be32_to_cpup(line) - 1;
+
+	if (of_get_property(node, "fsl,has-rts-cts", NULL))
+		sport->have_rtscts = 1;
+
+	if (of_get_property(node, "fsl,irda-mode", NULL))
+		sport->use_irda = 1;
+
+	return 0;
+}
+
+static struct of_device_id imx_uart_dt_ids[] = {
+	{ .compatible = "fsl,imx-uart" },
+	{},
+};
+#else
+static int serial_imx_probe_dt(struct imx_port *sport,
+		struct platform_device *pdev)
+{
+	return -ENODEV;
+}
+#define imx_uart_dt_ids NULL
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
+	sport->port.line = pdev->id;
+
+	return 0;
+}
+
 static int serial_imx_probe(struct platform_device *pdev)
 {
 	struct imx_port *sport;
@@ -1235,6 +1294,12 @@ static int serial_imx_probe(struct platform_device *pdev)
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
@@ -1259,7 +1324,6 @@ static int serial_imx_probe(struct platform_device *pdev)
 	sport->port.fifosize = 32;
 	sport->port.ops = &imx_pops;
 	sport->port.flags = UPF_BOOT_AUTOCONF;
-	sport->port.line = pdev->id;
 	init_timer(&sport->timer);
 	sport->timer.function = imx_timeout;
 	sport->timer.data     = (unsigned long)sport;
@@ -1273,17 +1337,13 @@ static int serial_imx_probe(struct platform_device *pdev)
 
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
@@ -1344,6 +1404,7 @@ static struct platform_driver serial_imx_driver = {
 	.driver		= {
 		.name	= "imx-uart",
 		.owner	= THIS_MODULE,
+		.of_match_table = imx_uart_dt_ids,
 	},
 };
 
-- 
1.7.4.1

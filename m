From: Shawn Guo <shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH v2 2/5] serial/imx: get rid of the use of cpu_is_mx1()
Date: Sat, 25 Jun 2011 02:04:33 +0800
Message-ID: <1308938676-31121-3-git-send-email-shawn.guo@linaro.org>
References: <1308938676-31121-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
To: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1308938676-31121-1-git-send-email-shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
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

The patch removes all the uses of cpu_is_mx1().  Instead, it uses
the .id_table of platform_driver to distinguish the uart device type.

Signed-off-by: Shawn Guo <shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Cc: Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Cc: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
---
 arch/arm/mach-imx/clock-imx1.c                |    6 +-
 arch/arm/plat-mxc/devices/platform-imx-uart.c |    2 +-
 drivers/tty/serial/imx.c                      |   52 ++++++++++++++++++++++--
 3 files changed, 51 insertions(+), 9 deletions(-)

diff --git a/arch/arm/mach-imx/clock-imx1.c b/arch/arm/mach-imx/clock-imx1.c
index dcc4172..4aabeb2 100644
--- a/arch/arm/mach-imx/clock-imx1.c
+++ b/arch/arm/mach-imx/clock-imx1.c
@@ -587,9 +587,9 @@ static struct clk_lookup lookups[] __initdata = {
 	_REGISTER_CLOCK(NULL, "mma", mma_clk)
 	_REGISTER_CLOCK("imx_udc.0", NULL, usbd_clk)
 	_REGISTER_CLOCK(NULL, "gpt", gpt_clk)
-	_REGISTER_CLOCK("imx-uart.0", NULL, uart_clk)
-	_REGISTER_CLOCK("imx-uart.1", NULL, uart_clk)
-	_REGISTER_CLOCK("imx-uart.2", NULL, uart_clk)
+	_REGISTER_CLOCK("imx1-uart.0", NULL, uart_clk)
+	_REGISTER_CLOCK("imx1-uart.1", NULL, uart_clk)
+	_REGISTER_CLOCK("imx1-uart.2", NULL, uart_clk)
 	_REGISTER_CLOCK("imx-i2c.0", NULL, i2c_clk)
 	_REGISTER_CLOCK("imx1-cspi.0", NULL, spi_clk)
 	_REGISTER_CLOCK("imx1-cspi.1", NULL, spi_clk)
diff --git a/arch/arm/plat-mxc/devices/platform-imx-uart.c b/arch/arm/plat-mxc/devices/platform-imx-uart.c
index 3c854c2..01982a1 100644
--- a/arch/arm/plat-mxc/devices/platform-imx-uart.c
+++ b/arch/arm/plat-mxc/devices/platform-imx-uart.c
@@ -150,7 +150,7 @@ struct platform_device *__init imx_add_imx_uart_3irq(
 		},
 	};
 
-	return imx_add_platform_device("imx-uart", data->id, res,
+	return imx_add_platform_device("imx1-uart", data->id, res,
 			ARRAY_SIZE(res), pdata, sizeof(*pdata));
 }
 
diff --git a/drivers/tty/serial/imx.c b/drivers/tty/serial/imx.c
index a544731..8a6f4e1 100644
--- a/drivers/tty/serial/imx.c
+++ b/drivers/tty/serial/imx.c
@@ -48,7 +48,6 @@
 
 #include <asm/io.h>
 #include <asm/irq.h>
-#include <mach/hardware.h>
 #include <mach/imx-uart.h>
 
 /* Register definitions */
@@ -67,7 +66,8 @@
 #define UBMR  0xa8 /* BRM Modulator Register */
 #define UBRC  0xac /* Baud Rate Count Register */
 #define MX2_ONEMS 0xb0 /* One Millisecond register */
-#define UTS (cpu_is_mx1() ? 0xd0 : 0xb4) /* UART Test Register */
+#define MX1_UTS 0xd0 /* UART Test Register on mx1 */
+#define MX2_UTS 0xb4 /* UART Test Register on mx2 and later */
 
 /* UART Control Register Bit Fields.*/
 #define  URXD_CHARRDY    (1<<15)
@@ -181,6 +181,17 @@
 
 #define UART_NR 8
 
+enum imx_uart_type {
+	IMX1_UART,
+	IMX2_UART,
+};
+
+/* device type dependent stuff */
+struct imx_uart_data {
+	unsigned uts_reg;
+	unsigned type;
+};
+
 struct imx_port {
 	struct uart_port	port;
 	struct timer_list	timer;
@@ -192,6 +203,7 @@ struct imx_port {
 	unsigned int		irda_inv_tx:1;
 	unsigned short		trcv_delay; /* transceiver delay */
 	struct clk		*clk;
+	struct imx_uart_data	*devdata;
 };
 
 #ifdef CONFIG_IRDA
@@ -200,6 +212,21 @@ struct imx_port {
 #define USE_IRDA(sport)	(0)
 #endif
 
+static struct imx_uart_data imx_uart_devdata[] = {
+	[IMX1_UART] = {
+		.uts_reg = MX1_UTS,
+		.type = IMX1_UART,
+	},
+	[IMX2_UART] = {
+		.uts_reg = MX2_UTS,
+		.type = IMX2_UART,
+	},
+};
+
+#define UTS (sport->devdata->uts_reg)
+#define IS_IMX1_UART(sport) (sport->devdata->type == IMX1_UART)
+#define IS_IMX2_UART(sport) (sport->devdata->type == IMX2_UART)
+
 /*
  * Handle any change of modem status signal since we were last called.
  */
@@ -689,7 +716,7 @@ static int imx_startup(struct uart_port *port)
 		}
 	}
 
-	if (!cpu_is_mx1()) {
+	if (IS_IMX2_UART(sport)) {
 		temp = readl(sport->port.membase + UCR3);
 		temp |= MX2_UCR3_RXDMUXSEL;
 		writel(temp, sport->port.membase + UCR3);
@@ -923,7 +950,7 @@ imx_set_termios(struct uart_port *port, struct ktermios *termios,
 	writel(num, sport->port.membase + UBIR);
 	writel(denom, sport->port.membase + UBMR);
 
-	if (!cpu_is_mx1())
+	if (IS_IMX2_UART(sport))
 		writel(sport->port.uartclk / div / 1000,
 				sport->port.membase + MX2_ONEMS);
 
@@ -1063,7 +1090,7 @@ imx_console_write(struct console *co, const char *s, unsigned int count)
 	ucr1 = old_ucr1 = readl(sport->port.membase + UCR1);
 	old_ucr2 = readl(sport->port.membase + UCR2);
 
-	if (cpu_is_mx1())
+	if (IS_IMX1_UART(sport))
 		ucr1 |= MX1_UCR1_UARTCLKEN;
 	ucr1 |= UCR1_UARTEN;
 	ucr1 &= ~(UCR1_TXMPTYEN | UCR1_RRDYEN | UCR1_RTSDEN);
@@ -1263,6 +1290,7 @@ static int serial_imx_probe(struct platform_device *pdev)
 	init_timer(&sport->timer);
 	sport->timer.function = imx_timeout;
 	sport->timer.data     = (unsigned long)sport;
+	sport->devdata = &imx_uart_devdata[pdev->id_entry->driver_data];
 
 	sport->clk = clk_get(&pdev->dev, "uart");
 	if (IS_ERR(sport->clk)) {
@@ -1335,12 +1363,26 @@ static int serial_imx_remove(struct platform_device *pdev)
 	return 0;
 }
 
+static struct platform_device_id imx_uart_devtype[] = {
+	{
+		.name = "imx1-uart",
+		.driver_data = IMX1_UART,
+	}, {
+		.name = "imx-uart",
+		.driver_data = IMX2_UART,
+	}, {
+		/* sentinel */
+	}
+};
+MODULE_DEVICE_TABLE(platform, imx_uart_devtype);
+
 static struct platform_driver serial_imx_driver = {
 	.probe		= serial_imx_probe,
 	.remove		= serial_imx_remove,
 
 	.suspend	= serial_imx_suspend,
 	.resume		= serial_imx_resume,
+	.id_table	= imx_uart_devtype,
 	.driver		= {
 		.name	= "imx-uart",
 		.owner	= THIS_MODULE,
-- 
1.7.4.1

From: Andres Salomon <dilinger-pFFUokh25LWsTnJN9+BGXg@public.gmane.org>
Subject: [PATCH 08/29] timberdale: mfd_cell is now implicitly available to
	drivers (v2)
Date: Thu, 17 Feb 2011 19:07:15 -0800
Message-ID: <1297998456-7615-9-git-send-email-dilinger@queued.net>
References: <1297998456-7615-1-git-send-email-dilinger@queued.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	richard.rojfors-gfIc91nka+FZroRs9YW3xA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Mark Brown <broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Mauro Carvalho Chehab <mchehab-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Ben Dooks \(embedded platforms\)" <ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org>,
	spi-devel-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	"Jean Delvare \(PC drivers, core\)" <khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org>,
	Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>,
	Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <spi-devel-general-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1297998456-7615-1-git-send-email-dilinger-pFFUokh25LWsTnJN9+BGXg@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/spi-devel-general>,
	<mailto:spi-devel-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=spi-devel-general>
List-Post: <mailto:spi-devel-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:spi-devel-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/spi-devel-general>,
	<mailto:spi-devel-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: spi-devel-general-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

The cell's platform_data is now accessed with a helper function;
change clients to use that, and remove the now-unused data_size.

Note that the mfd's platform_data is marked __devinitdata.  This
is still correct in all cases except for the timbgpio driver, whose
remove hook has been changed to no longer reference the pdata.

v2: add some missing mfd/core.h includes.

Signed-off-by: Andres Salomon <dilinger-pFFUokh25LWsTnJN9+BGXg@public.gmane.org>
---
 drivers/dma/timb_dma.c           |    3 ++-
 drivers/gpio/timbgpio.c          |    6 +++---
 drivers/i2c/busses/i2c-ocores.c  |    3 ++-
 drivers/i2c/busses/i2c-xiic.c    |    3 ++-
 drivers/media/radio/radio-timb.c |    3 ++-
 drivers/media/video/timblogiw.c  |    3 ++-
 drivers/mfd/timberdale.c         |   27 ---------------------------
 drivers/net/ks8842.c             |    3 ++-
 drivers/spi/xilinx_spi.c         |    3 ++-
 9 files changed, 17 insertions(+), 37 deletions(-)

diff --git a/drivers/dma/timb_dma.c b/drivers/dma/timb_dma.c
index 3b88a4e..ea8705b 100644
--- a/drivers/dma/timb_dma.c
+++ b/drivers/dma/timb_dma.c
@@ -27,6 +27,7 @@
 #include <linux/io.h>
 #include <linux/module.h>
 #include <linux/platform_device.h>
+#include <linux/mfd/core.h>
 #include <linux/slab.h>
 
 #include <linux/timb_dma.h>
@@ -684,7 +685,7 @@ static irqreturn_t td_irq(int irq, void *devid)
 
 static int __devinit td_probe(struct platform_device *pdev)
 {
-	struct timb_dma_platform_data *pdata = pdev->dev.platform_data;
+	struct timb_dma_platform_data *pdata = mfd_get_data(pdev);
 	struct timb_dma *td;
 	struct resource *iomem;
 	int irq;
diff --git a/drivers/gpio/timbgpio.c b/drivers/gpio/timbgpio.c
index 58c8f30..ffcd815 100644
--- a/drivers/gpio/timbgpio.c
+++ b/drivers/gpio/timbgpio.c
@@ -23,6 +23,7 @@
 #include <linux/module.h>
 #include <linux/gpio.h>
 #include <linux/platform_device.h>
+#include <linux/mfd/core.h>
 #include <linux/irq.h>
 #include <linux/io.h>
 #include <linux/timb_gpio.h>
@@ -228,7 +229,7 @@ static int __devinit timbgpio_probe(struct platform_device *pdev)
 	struct gpio_chip *gc;
 	struct timbgpio *tgpio;
 	struct resource *iomem;
-	struct timbgpio_platform_data *pdata = pdev->dev.platform_data;
+	struct timbgpio_platform_data *pdata = mfd_get_data(pdev);
 	int irq = platform_get_irq(pdev, 0);
 
 	if (!pdata || pdata->nr_pins > 32) {
@@ -319,14 +320,13 @@ err_mem:
 static int __devexit timbgpio_remove(struct platform_device *pdev)
 {
 	int err;
-	struct timbgpio_platform_data *pdata = pdev->dev.platform_data;
 	struct timbgpio *tgpio = platform_get_drvdata(pdev);
 	struct resource *iomem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	int irq = platform_get_irq(pdev, 0);
 
 	if (irq >= 0 && tgpio->irq_base > 0) {
 		int i;
-		for (i = 0; i < pdata->nr_pins; i++) {
+		for (i = 0; i < tgpio->gpio.ngpio; i++) {
 			set_irq_chip(tgpio->irq_base + i, NULL);
 			set_irq_chip_data(tgpio->irq_base + i, NULL);
 		}
diff --git a/drivers/i2c/busses/i2c-ocores.c b/drivers/i2c/busses/i2c-ocores.c
index ef3bcb1..a3f4799 100644
--- a/drivers/i2c/busses/i2c-ocores.c
+++ b/drivers/i2c/busses/i2c-ocores.c
@@ -49,6 +49,7 @@
 #include <linux/init.h>
 #include <linux/errno.h>
 #include <linux/platform_device.h>
+#include <linux/mfd/core.h>
 #include <linux/i2c.h>
 #include <linux/interrupt.h>
 #include <linux/wait.h>
@@ -305,7 +306,7 @@ static int __devinit ocores_i2c_probe(struct platform_device *pdev)
 		return -EIO;
 	}
 
-	pdata = pdev->dev.platform_data;
+	pdata = mfd_get_data(pdev);
 	if (pdata) {
 		i2c->regstep = pdata->regstep;
 		i2c->clock_khz = pdata->clock_khz;
diff --git a/drivers/i2c/busses/i2c-xiic.c b/drivers/i2c/busses/i2c-xiic.c
index a9c419e..9fbd7e6 100644
--- a/drivers/i2c/busses/i2c-xiic.c
+++ b/drivers/i2c/busses/i2c-xiic.c
@@ -34,6 +34,7 @@
 #include <linux/errno.h>
 #include <linux/delay.h>
 #include <linux/platform_device.h>
+#include <linux/mfd/core.h>
 #include <linux/i2c.h>
 #include <linux/interrupt.h>
 #include <linux/wait.h>
@@ -704,7 +705,7 @@ static int __devinit xiic_i2c_probe(struct platform_device *pdev)
 	if (irq < 0)
 		goto resource_missing;
 
-	pdata = (struct xiic_i2c_platform_data *) pdev->dev.platform_data;
+	pdata = mfd_get_data(pdev);
 	if (!pdata)
 		return -EINVAL;
 
diff --git a/drivers/media/radio/radio-timb.c b/drivers/media/radio/radio-timb.c
index a185610..1e3a8dd 100644
--- a/drivers/media/radio/radio-timb.c
+++ b/drivers/media/radio/radio-timb.c
@@ -21,6 +21,7 @@
 #include <media/v4l2-ioctl.h>
 #include <media/v4l2-device.h>
 #include <linux/platform_device.h>
+#include <linux/mfd/core.h>
 #include <linux/interrupt.h>
 #include <linux/slab.h>
 #include <linux/i2c.h>
@@ -148,7 +149,7 @@ static const struct v4l2_file_operations timbradio_fops = {
 
 static int __devinit timbradio_probe(struct platform_device *pdev)
 {
-	struct timb_radio_platform_data *pdata = pdev->dev.platform_data;
+	struct timb_radio_platform_data *pdata = mfd_get_data(pdev);
 	struct timbradio *tr;
 	int err;
 
diff --git a/drivers/media/video/timblogiw.c b/drivers/media/video/timblogiw.c
index fc611eb..84d4c7c 100644
--- a/drivers/media/video/timblogiw.c
+++ b/drivers/media/video/timblogiw.c
@@ -24,6 +24,7 @@
 #include <linux/platform_device.h>
 #include <linux/slab.h>
 #include <linux/dmaengine.h>
+#include <linux/mfd/core.h>
 #include <linux/scatterlist.h>
 #include <linux/interrupt.h>
 #include <linux/list.h>
@@ -790,7 +791,7 @@ static int __devinit timblogiw_probe(struct platform_device *pdev)
 {
 	int err;
 	struct timblogiw *lw = NULL;
-	struct timb_video_platform_data *pdata = pdev->dev.platform_data;
+	struct timb_video_platform_data *pdata = mfd_get_data(pdev);
 
 	if (!pdata) {
 		dev_err(&pdev->dev, "No platform data\n");
diff --git a/drivers/mfd/timberdale.c b/drivers/mfd/timberdale.c
index 6ad8a7f..6353921 100644
--- a/drivers/mfd/timberdale.c
+++ b/drivers/mfd/timberdale.c
@@ -385,7 +385,6 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg0[] = {
 		.num_resources = ARRAY_SIZE(timberdale_dma_resources),
 		.resources = timberdale_dma_resources,
 		.platform_data = &timb_dma_platform_data,
-		.data_size = sizeof(timb_dma_platform_data),
 	},
 	{
 		.name = "timb-uart",
@@ -397,42 +396,36 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg0[] = {
 		.num_resources = ARRAY_SIZE(timberdale_xiic_resources),
 		.resources = timberdale_xiic_resources,
 		.platform_data = &timberdale_xiic_platform_data,
-		.data_size = sizeof(timberdale_xiic_platform_data),
 	},
 	{
 		.name = "timb-gpio",
 		.num_resources = ARRAY_SIZE(timberdale_gpio_resources),
 		.resources = timberdale_gpio_resources,
 		.platform_data = &timberdale_gpio_platform_data,
-		.data_size = sizeof(timberdale_gpio_platform_data),
 	},
 	{
 		.name = "timb-video",
 		.num_resources = ARRAY_SIZE(timberdale_video_resources),
 		.resources = timberdale_video_resources,
 		.platform_data = &timberdale_video_platform_data,
-		.data_size = sizeof(timberdale_video_platform_data),
 	},
 	{
 		.name = "timb-radio",
 		.num_resources = ARRAY_SIZE(timberdale_radio_resources),
 		.resources = timberdale_radio_resources,
 		.platform_data = &timberdale_radio_platform_data,
-		.data_size = sizeof(timberdale_radio_platform_data),
 	},
 	{
 		.name = "xilinx_spi",
 		.num_resources = ARRAY_SIZE(timberdale_spi_resources),
 		.resources = timberdale_spi_resources,
 		.platform_data = &timberdale_xspi_platform_data,
-		.data_size = sizeof(timberdale_xspi_platform_data),
 	},
 	{
 		.name = "ks8842",
 		.num_resources = ARRAY_SIZE(timberdale_eth_resources),
 		.resources = timberdale_eth_resources,
 		.platform_data = &timberdale_ks8842_platform_data,
-		.data_size = sizeof(timberdale_ks8842_platform_data)
 	},
 };
 
@@ -442,7 +435,6 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg1[] = {
 		.num_resources = ARRAY_SIZE(timberdale_dma_resources),
 		.resources = timberdale_dma_resources,
 		.platform_data = &timb_dma_platform_data,
-		.data_size = sizeof(timb_dma_platform_data),
 	},
 	{
 		.name = "timb-uart",
@@ -459,14 +451,12 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg1[] = {
 		.num_resources = ARRAY_SIZE(timberdale_xiic_resources),
 		.resources = timberdale_xiic_resources,
 		.platform_data = &timberdale_xiic_platform_data,
-		.data_size = sizeof(timberdale_xiic_platform_data),
 	},
 	{
 		.name = "timb-gpio",
 		.num_resources = ARRAY_SIZE(timberdale_gpio_resources),
 		.resources = timberdale_gpio_resources,
 		.platform_data = &timberdale_gpio_platform_data,
-		.data_size = sizeof(timberdale_gpio_platform_data),
 	},
 	{
 		.name = "timb-mlogicore",
@@ -478,28 +468,24 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg1[] = {
 		.num_resources = ARRAY_SIZE(timberdale_video_resources),
 		.resources = timberdale_video_resources,
 		.platform_data = &timberdale_video_platform_data,
-		.data_size = sizeof(timberdale_video_platform_data),
 	},
 	{
 		.name = "timb-radio",
 		.num_resources = ARRAY_SIZE(timberdale_radio_resources),
 		.resources = timberdale_radio_resources,
 		.platform_data = &timberdale_radio_platform_data,
-		.data_size = sizeof(timberdale_radio_platform_data),
 	},
 	{
 		.name = "xilinx_spi",
 		.num_resources = ARRAY_SIZE(timberdale_spi_resources),
 		.resources = timberdale_spi_resources,
 		.platform_data = &timberdale_xspi_platform_data,
-		.data_size = sizeof(timberdale_xspi_platform_data),
 	},
 	{
 		.name = "ks8842",
 		.num_resources = ARRAY_SIZE(timberdale_eth_resources),
 		.resources = timberdale_eth_resources,
 		.platform_data = &timberdale_ks8842_platform_data,
-		.data_size = sizeof(timberdale_ks8842_platform_data)
 	},
 };
 
@@ -509,7 +495,6 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg2[] = {
 		.num_resources = ARRAY_SIZE(timberdale_dma_resources),
 		.resources = timberdale_dma_resources,
 		.platform_data = &timb_dma_platform_data,
-		.data_size = sizeof(timb_dma_platform_data),
 	},
 	{
 		.name = "timb-uart",
@@ -521,35 +506,30 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg2[] = {
 		.num_resources = ARRAY_SIZE(timberdale_xiic_resources),
 		.resources = timberdale_xiic_resources,
 		.platform_data = &timberdale_xiic_platform_data,
-		.data_size = sizeof(timberdale_xiic_platform_data),
 	},
 	{
 		.name = "timb-gpio",
 		.num_resources = ARRAY_SIZE(timberdale_gpio_resources),
 		.resources = timberdale_gpio_resources,
 		.platform_data = &timberdale_gpio_platform_data,
-		.data_size = sizeof(timberdale_gpio_platform_data),
 	},
 	{
 		.name = "timb-video",
 		.num_resources = ARRAY_SIZE(timberdale_video_resources),
 		.resources = timberdale_video_resources,
 		.platform_data = &timberdale_video_platform_data,
-		.data_size = sizeof(timberdale_video_platform_data),
 	},
 	{
 		.name = "timb-radio",
 		.num_resources = ARRAY_SIZE(timberdale_radio_resources),
 		.resources = timberdale_radio_resources,
 		.platform_data = &timberdale_radio_platform_data,
-		.data_size = sizeof(timberdale_radio_platform_data),
 	},
 	{
 		.name = "xilinx_spi",
 		.num_resources = ARRAY_SIZE(timberdale_spi_resources),
 		.resources = timberdale_spi_resources,
 		.platform_data = &timberdale_xspi_platform_data,
-		.data_size = sizeof(timberdale_xspi_platform_data),
 	},
 };
 
@@ -559,7 +539,6 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg3[] = {
 		.num_resources = ARRAY_SIZE(timberdale_dma_resources),
 		.resources = timberdale_dma_resources,
 		.platform_data = &timb_dma_platform_data,
-		.data_size = sizeof(timb_dma_platform_data),
 	},
 	{
 		.name = "timb-uart",
@@ -571,42 +550,36 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg3[] = {
 		.num_resources = ARRAY_SIZE(timberdale_ocores_resources),
 		.resources = timberdale_ocores_resources,
 		.platform_data = &timberdale_ocores_platform_data,
-		.data_size = sizeof(timberdale_ocores_platform_data),
 	},
 	{
 		.name = "timb-gpio",
 		.num_resources = ARRAY_SIZE(timberdale_gpio_resources),
 		.resources = timberdale_gpio_resources,
 		.platform_data = &timberdale_gpio_platform_data,
-		.data_size = sizeof(timberdale_gpio_platform_data),
 	},
 	{
 		.name = "timb-video",
 		.num_resources = ARRAY_SIZE(timberdale_video_resources),
 		.resources = timberdale_video_resources,
 		.platform_data = &timberdale_video_platform_data,
-		.data_size = sizeof(timberdale_video_platform_data),
 	},
 	{
 		.name = "timb-radio",
 		.num_resources = ARRAY_SIZE(timberdale_radio_resources),
 		.resources = timberdale_radio_resources,
 		.platform_data = &timberdale_radio_platform_data,
-		.data_size = sizeof(timberdale_radio_platform_data),
 	},
 	{
 		.name = "xilinx_spi",
 		.num_resources = ARRAY_SIZE(timberdale_spi_resources),
 		.resources = timberdale_spi_resources,
 		.platform_data = &timberdale_xspi_platform_data,
-		.data_size = sizeof(timberdale_xspi_platform_data),
 	},
 	{
 		.name = "ks8842",
 		.num_resources = ARRAY_SIZE(timberdale_eth_resources),
 		.resources = timberdale_eth_resources,
 		.platform_data = &timberdale_ks8842_platform_data,
-		.data_size = sizeof(timberdale_ks8842_platform_data)
 	},
 };
 
diff --git a/drivers/net/ks8842.c b/drivers/net/ks8842.c
index 928b2b8..efd44af 100644
--- a/drivers/net/ks8842.c
+++ b/drivers/net/ks8842.c
@@ -26,6 +26,7 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/platform_device.h>
+#include <linux/mfd/core.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
@@ -1145,7 +1146,7 @@ static int __devinit ks8842_probe(struct platform_device *pdev)
 	struct resource *iomem;
 	struct net_device *netdev;
 	struct ks8842_adapter *adapter;
-	struct ks8842_platform_data *pdata = pdev->dev.platform_data;
+	struct ks8842_platform_data *pdata = mfd_get_data(pdev);
 	u16 id;
 	unsigned i;
 
diff --git a/drivers/spi/xilinx_spi.c b/drivers/spi/xilinx_spi.c
index 7adaef6..c9bf074 100644
--- a/drivers/spi/xilinx_spi.c
+++ b/drivers/spi/xilinx_spi.c
@@ -18,6 +18,7 @@
 #include <linux/interrupt.h>
 #include <linux/of.h>
 #include <linux/platform_device.h>
+#include <linux/mfd/core.h>
 #include <linux/spi/spi.h>
 #include <linux/spi/spi_bitbang.h>
 #include <linux/spi/xilinx_spi.h>
@@ -474,7 +475,7 @@ static int __devinit xilinx_spi_probe(struct platform_device *dev)
 	struct spi_master *master;
 	u8 i;
 
-	pdata = dev->dev.platform_data;
+	pdata = mfd_get_data(dev);
 	if (pdata) {
 		num_cs = pdata->num_chipselect;
 		little_endian = pdata->little_endian;
-- 
1.7.2.3


------------------------------------------------------------------------------
The ultimate all-in-one performance toolkit: Intel(R) Parallel Studio XE:
Pinpoint memory and threading errors before they happen.
Find and fix more than 250 security defects in the development cycle.
Locate bottlenecks in serial and parallel code that limit performance.
http://p.sf.net/sfu/intel-dev2devfeb

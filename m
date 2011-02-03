From: Andres Salomon <dilinger-pFFUokh25LWsTnJN9+BGXg@public.gmane.org>
Subject: [PATCH 07/19] timberdale: mfd_cell is now implicitly available to
 drivers
Date: Wed, 2 Feb 2011 20:08:12 -0800
Message-ID: <20110202200812.3d8d6cba@queued.net>
References: <20110202195417.228e2656@queued.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Mark Brown <broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>,
	khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org, ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org,
	Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>,
	Mauro Carvalho Chehab <mchehab-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>,
	linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, spi-devel-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Mocean Laboratories <info-l7gf1WXxx3uGw+nKnLezzg@public.gmane.org>
To: Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110202195417.228e2656-pFFUokh25LWsTnJN9+BGXg@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


No need to explicitly set the cell's platform_data/data_size.

In this case, move the various platform_data pointers
to driver_data.  All of the clients which make use of it
are also changed.

Signed-off-by: Andres Salomon <dilinger-pFFUokh25LWsTnJN9+BGXg@public.gmane.org>
---
 drivers/dma/timb_dma.c           |    2 +-
 drivers/gpio/timbgpio.c          |    5 +-
 drivers/i2c/busses/i2c-ocores.c  |    2 +-
 drivers/i2c/busses/i2c-xiic.c    |    2 +-
 drivers/media/radio/radio-timb.c |    2 +-
 drivers/media/video/timblogiw.c  |    2 +-
 drivers/mfd/timberdale.c         |   81 +++++++++++++-------------------------
 drivers/net/ks8842.c             |    2 +-
 drivers/spi/xilinx_spi.c         |    2 +-
 9 files changed, 36 insertions(+), 64 deletions(-)

diff --git a/drivers/dma/timb_dma.c b/drivers/dma/timb_dma.c
index 3b88a4e..aa06ca4 100644
--- a/drivers/dma/timb_dma.c
+++ b/drivers/dma/timb_dma.c
@@ -684,7 +684,7 @@ static irqreturn_t td_irq(int irq, void *devid)
 
 static int __devinit td_probe(struct platform_device *pdev)
 {
-	struct timb_dma_platform_data *pdata = pdev->dev.platform_data;
+	struct timb_dma_platform_data *pdata = platform_get_drvdata(pdev);
 	struct timb_dma *td;
 	struct resource *iomem;
 	int irq;
diff --git a/drivers/gpio/timbgpio.c b/drivers/gpio/timbgpio.c
index 58c8f30..e404487 100644
--- a/drivers/gpio/timbgpio.c
+++ b/drivers/gpio/timbgpio.c
@@ -228,7 +228,7 @@ static int __devinit timbgpio_probe(struct platform_device *pdev)
 	struct gpio_chip *gc;
 	struct timbgpio *tgpio;
 	struct resource *iomem;
-	struct timbgpio_platform_data *pdata = pdev->dev.platform_data;
+	struct timbgpio_platform_data *pdata = platform_get_drvdata(pdev);
 	int irq = platform_get_irq(pdev, 0);
 
 	if (!pdata || pdata->nr_pins > 32) {
@@ -319,14 +319,13 @@ err_mem:
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
index ef3bcb1..dc203ec 100644
--- a/drivers/i2c/busses/i2c-ocores.c
+++ b/drivers/i2c/busses/i2c-ocores.c
@@ -305,7 +305,7 @@ static int __devinit ocores_i2c_probe(struct platform_device *pdev)
 		return -EIO;
 	}
 
-	pdata = pdev->dev.platform_data;
+	pdata = platform_get_drvdata(pdev);
 	if (pdata) {
 		i2c->regstep = pdata->regstep;
 		i2c->clock_khz = pdata->clock_khz;
diff --git a/drivers/i2c/busses/i2c-xiic.c b/drivers/i2c/busses/i2c-xiic.c
index a9c419e..830b8c1 100644
--- a/drivers/i2c/busses/i2c-xiic.c
+++ b/drivers/i2c/busses/i2c-xiic.c
@@ -704,7 +704,7 @@ static int __devinit xiic_i2c_probe(struct platform_device *pdev)
 	if (irq < 0)
 		goto resource_missing;
 
-	pdata = (struct xiic_i2c_platform_data *) pdev->dev.platform_data;
+	pdata = platform_get_drvdata(pdev);
 	if (!pdata)
 		return -EINVAL;
 
diff --git a/drivers/media/radio/radio-timb.c b/drivers/media/radio/radio-timb.c
index a185610..e7baf26 100644
--- a/drivers/media/radio/radio-timb.c
+++ b/drivers/media/radio/radio-timb.c
@@ -148,7 +148,7 @@ static const struct v4l2_file_operations timbradio_fops = {
 
 static int __devinit timbradio_probe(struct platform_device *pdev)
 {
-	struct timb_radio_platform_data *pdata = pdev->dev.platform_data;
+	struct timb_radio_platform_data *pdata = platform_get_drvdata(pdev);
 	struct timbradio *tr;
 	int err;
 
diff --git a/drivers/media/video/timblogiw.c b/drivers/media/video/timblogiw.c
index fc611eb..61aa67a 100644
--- a/drivers/media/video/timblogiw.c
+++ b/drivers/media/video/timblogiw.c
@@ -790,7 +790,7 @@ static int __devinit timblogiw_probe(struct platform_device *pdev)
 {
 	int err;
 	struct timblogiw *lw = NULL;
-	struct timb_video_platform_data *pdata = pdev->dev.platform_data;
+	struct timb_video_platform_data *pdata = platform_get_drvdata(pdev);
 
 	if (!pdata) {
 		dev_err(&pdev->dev, "No platform data\n");
diff --git a/drivers/mfd/timberdale.c b/drivers/mfd/timberdale.c
index 6ad8a7f..e9ae162 100644
--- a/drivers/mfd/timberdale.c
+++ b/drivers/mfd/timberdale.c
@@ -384,8 +384,7 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg0[] = {
 		.name = "timb-dma",
 		.num_resources = ARRAY_SIZE(timberdale_dma_resources),
 		.resources = timberdale_dma_resources,
-		.platform_data = &timb_dma_platform_data,
-		.data_size = sizeof(timb_dma_platform_data),
+		.driver_data = &timb_dma_platform_data,
 	},
 	{
 		.name = "timb-uart",
@@ -396,43 +395,37 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg0[] = {
 		.name = "xiic-i2c",
 		.num_resources = ARRAY_SIZE(timberdale_xiic_resources),
 		.resources = timberdale_xiic_resources,
-		.platform_data = &timberdale_xiic_platform_data,
-		.data_size = sizeof(timberdale_xiic_platform_data),
+		.driver_data = &timberdale_xiic_platform_data,
 	},
 	{
 		.name = "timb-gpio",
 		.num_resources = ARRAY_SIZE(timberdale_gpio_resources),
 		.resources = timberdale_gpio_resources,
-		.platform_data = &timberdale_gpio_platform_data,
-		.data_size = sizeof(timberdale_gpio_platform_data),
+		.driver_data = &timberdale_gpio_platform_data,
 	},
 	{
 		.name = "timb-video",
 		.num_resources = ARRAY_SIZE(timberdale_video_resources),
 		.resources = timberdale_video_resources,
-		.platform_data = &timberdale_video_platform_data,
-		.data_size = sizeof(timberdale_video_platform_data),
+		.driver_data = &timberdale_video_platform_data,
 	},
 	{
 		.name = "timb-radio",
 		.num_resources = ARRAY_SIZE(timberdale_radio_resources),
 		.resources = timberdale_radio_resources,
-		.platform_data = &timberdale_radio_platform_data,
-		.data_size = sizeof(timberdale_radio_platform_data),
+		.driver_data = &timberdale_radio_platform_data,
 	},
 	{
 		.name = "xilinx_spi",
 		.num_resources = ARRAY_SIZE(timberdale_spi_resources),
 		.resources = timberdale_spi_resources,
-		.platform_data = &timberdale_xspi_platform_data,
-		.data_size = sizeof(timberdale_xspi_platform_data),
+		.driver_data = &timberdale_xspi_platform_data,
 	},
 	{
 		.name = "ks8842",
 		.num_resources = ARRAY_SIZE(timberdale_eth_resources),
 		.resources = timberdale_eth_resources,
-		.platform_data = &timberdale_ks8842_platform_data,
-		.data_size = sizeof(timberdale_ks8842_platform_data)
+		.driver_data = &timberdale_ks8842_platform_data,
 	},
 };
 
@@ -441,8 +434,7 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg1[] = {
 		.name = "timb-dma",
 		.num_resources = ARRAY_SIZE(timberdale_dma_resources),
 		.resources = timberdale_dma_resources,
-		.platform_data = &timb_dma_platform_data,
-		.data_size = sizeof(timb_dma_platform_data),
+		.driver_data = &timb_dma_platform_data,
 	},
 	{
 		.name = "timb-uart",
@@ -458,15 +450,13 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg1[] = {
 		.name = "xiic-i2c",
 		.num_resources = ARRAY_SIZE(timberdale_xiic_resources),
 		.resources = timberdale_xiic_resources,
-		.platform_data = &timberdale_xiic_platform_data,
-		.data_size = sizeof(timberdale_xiic_platform_data),
+		.driver_data = &timberdale_xiic_platform_data,
 	},
 	{
 		.name = "timb-gpio",
 		.num_resources = ARRAY_SIZE(timberdale_gpio_resources),
 		.resources = timberdale_gpio_resources,
-		.platform_data = &timberdale_gpio_platform_data,
-		.data_size = sizeof(timberdale_gpio_platform_data),
+		.driver_data = &timberdale_gpio_platform_data,
 	},
 	{
 		.name = "timb-mlogicore",
@@ -477,29 +467,25 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg1[] = {
 		.name = "timb-video",
 		.num_resources = ARRAY_SIZE(timberdale_video_resources),
 		.resources = timberdale_video_resources,
-		.platform_data = &timberdale_video_platform_data,
-		.data_size = sizeof(timberdale_video_platform_data),
+		.driver_data = &timberdale_video_platform_data,
 	},
 	{
 		.name = "timb-radio",
 		.num_resources = ARRAY_SIZE(timberdale_radio_resources),
 		.resources = timberdale_radio_resources,
-		.platform_data = &timberdale_radio_platform_data,
-		.data_size = sizeof(timberdale_radio_platform_data),
+		.driver_data = &timberdale_radio_platform_data,
 	},
 	{
 		.name = "xilinx_spi",
 		.num_resources = ARRAY_SIZE(timberdale_spi_resources),
 		.resources = timberdale_spi_resources,
-		.platform_data = &timberdale_xspi_platform_data,
-		.data_size = sizeof(timberdale_xspi_platform_data),
+		.driver_data = &timberdale_xspi_platform_data,
 	},
 	{
 		.name = "ks8842",
 		.num_resources = ARRAY_SIZE(timberdale_eth_resources),
 		.resources = timberdale_eth_resources,
-		.platform_data = &timberdale_ks8842_platform_data,
-		.data_size = sizeof(timberdale_ks8842_platform_data)
+		.driver_data = &timberdale_ks8842_platform_data,
 	},
 };
 
@@ -508,8 +494,7 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg2[] = {
 		.name = "timb-dma",
 		.num_resources = ARRAY_SIZE(timberdale_dma_resources),
 		.resources = timberdale_dma_resources,
-		.platform_data = &timb_dma_platform_data,
-		.data_size = sizeof(timb_dma_platform_data),
+		.driver_data = &timb_dma_platform_data,
 	},
 	{
 		.name = "timb-uart",
@@ -520,36 +505,31 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg2[] = {
 		.name = "xiic-i2c",
 		.num_resources = ARRAY_SIZE(timberdale_xiic_resources),
 		.resources = timberdale_xiic_resources,
-		.platform_data = &timberdale_xiic_platform_data,
-		.data_size = sizeof(timberdale_xiic_platform_data),
+		.driver_data = &timberdale_xiic_platform_data,
 	},
 	{
 		.name = "timb-gpio",
 		.num_resources = ARRAY_SIZE(timberdale_gpio_resources),
 		.resources = timberdale_gpio_resources,
-		.platform_data = &timberdale_gpio_platform_data,
-		.data_size = sizeof(timberdale_gpio_platform_data),
+		.driver_data = &timberdale_gpio_platform_data,
 	},
 	{
 		.name = "timb-video",
 		.num_resources = ARRAY_SIZE(timberdale_video_resources),
 		.resources = timberdale_video_resources,
-		.platform_data = &timberdale_video_platform_data,
-		.data_size = sizeof(timberdale_video_platform_data),
+		.driver_data = &timberdale_video_platform_data,
 	},
 	{
 		.name = "timb-radio",
 		.num_resources = ARRAY_SIZE(timberdale_radio_resources),
 		.resources = timberdale_radio_resources,
-		.platform_data = &timberdale_radio_platform_data,
-		.data_size = sizeof(timberdale_radio_platform_data),
+		.driver_data = &timberdale_radio_platform_data,
 	},
 	{
 		.name = "xilinx_spi",
 		.num_resources = ARRAY_SIZE(timberdale_spi_resources),
 		.resources = timberdale_spi_resources,
-		.platform_data = &timberdale_xspi_platform_data,
-		.data_size = sizeof(timberdale_xspi_platform_data),
+		.driver_data = &timberdale_xspi_platform_data,
 	},
 };
 
@@ -558,8 +538,7 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg3[] = {
 		.name = "timb-dma",
 		.num_resources = ARRAY_SIZE(timberdale_dma_resources),
 		.resources = timberdale_dma_resources,
-		.platform_data = &timb_dma_platform_data,
-		.data_size = sizeof(timb_dma_platform_data),
+		.driver_data = &timb_dma_platform_data,
 	},
 	{
 		.name = "timb-uart",
@@ -570,43 +549,37 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg3[] = {
 		.name = "ocores-i2c",
 		.num_resources = ARRAY_SIZE(timberdale_ocores_resources),
 		.resources = timberdale_ocores_resources,
-		.platform_data = &timberdale_ocores_platform_data,
-		.data_size = sizeof(timberdale_ocores_platform_data),
+		.driver_data = &timberdale_ocores_platform_data,
 	},
 	{
 		.name = "timb-gpio",
 		.num_resources = ARRAY_SIZE(timberdale_gpio_resources),
 		.resources = timberdale_gpio_resources,
-		.platform_data = &timberdale_gpio_platform_data,
-		.data_size = sizeof(timberdale_gpio_platform_data),
+		.driver_data = &timberdale_gpio_platform_data,
 	},
 	{
 		.name = "timb-video",
 		.num_resources = ARRAY_SIZE(timberdale_video_resources),
 		.resources = timberdale_video_resources,
-		.platform_data = &timberdale_video_platform_data,
-		.data_size = sizeof(timberdale_video_platform_data),
+		.driver_data = &timberdale_video_platform_data,
 	},
 	{
 		.name = "timb-radio",
 		.num_resources = ARRAY_SIZE(timberdale_radio_resources),
 		.resources = timberdale_radio_resources,
-		.platform_data = &timberdale_radio_platform_data,
-		.data_size = sizeof(timberdale_radio_platform_data),
+		.driver_data = &timberdale_radio_platform_data,
 	},
 	{
 		.name = "xilinx_spi",
 		.num_resources = ARRAY_SIZE(timberdale_spi_resources),
 		.resources = timberdale_spi_resources,
-		.platform_data = &timberdale_xspi_platform_data,
-		.data_size = sizeof(timberdale_xspi_platform_data),
+		.driver_data = &timberdale_xspi_platform_data,
 	},
 	{
 		.name = "ks8842",
 		.num_resources = ARRAY_SIZE(timberdale_eth_resources),
 		.resources = timberdale_eth_resources,
-		.platform_data = &timberdale_ks8842_platform_data,
-		.data_size = sizeof(timberdale_ks8842_platform_data)
+		.driver_data = &timberdale_ks8842_platform_data,
 	},
 };
 
diff --git a/drivers/net/ks8842.c b/drivers/net/ks8842.c
index 928b2b8..7f0f51f 100644
--- a/drivers/net/ks8842.c
+++ b/drivers/net/ks8842.c
@@ -1145,7 +1145,7 @@ static int __devinit ks8842_probe(struct platform_device *pdev)
 	struct resource *iomem;
 	struct net_device *netdev;
 	struct ks8842_adapter *adapter;
-	struct ks8842_platform_data *pdata = pdev->dev.platform_data;
+	struct ks8842_platform_data *pdata = platform_get_drvdata(pdev);
 	u16 id;
 	unsigned i;
 
diff --git a/drivers/spi/xilinx_spi.c b/drivers/spi/xilinx_spi.c
index 7adaef6..2926dec 100644
--- a/drivers/spi/xilinx_spi.c
+++ b/drivers/spi/xilinx_spi.c
@@ -474,7 +474,7 @@ static int __devinit xilinx_spi_probe(struct platform_device *dev)
 	struct spi_master *master;
 	u8 i;
 
-	pdata = dev->dev.platform_data;
+	pdata = platform_get_drvdata(dev);
 	if (pdata) {
 		num_cs = pdata->num_chipselect;
 		little_endian = pdata->little_endian;
-- 
1.7.2.3

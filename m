From: Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH 07/19] timberdale: mfd_cell is now implicitly available
 to drivers
Date: Fri, 1 Apr 2011 13:20:31 +0200
Message-ID: <20110401112030.GA3447@sortiz-mobl>
References: <20110202195417.228e2656@queued.net>
 <20110202200812.3d8d6cba@queued.net>
 <20110331230522.GI437@ponder.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Mark Brown <broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>,
	khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org, ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org,
	Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>,
	Mauro Carvalho Chehab <mchehab-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, spi-devel-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Mocean Laboratories <info-l7gf1WXxx3uGw+nKnLezzg@public.gmane.org>
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>,
	Andres Salomon <dilinger-pFFUokh25LWsTnJN9+BGXg@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110331230522.GI437-e0URQFbLeQY2iJbIjFUEsiwD8/FfD2ys@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Grant,

On Thu, Mar 31, 2011 at 05:05:22PM -0600, Grant Likely wrote:
> On Wed, Feb 02, 2011 at 08:08:12PM -0800, Andres Salomon wrote:
> > 
> > No need to explicitly set the cell's platform_data/data_size.
> > 
> > In this case, move the various platform_data pointers
> > to driver_data.  All of the clients which make use of it
> > are also changed.
> > 
> > Signed-off-by: Andres Salomon <dilinger-pFFUokh25LWsTnJN9+BGXg@public.gmane.org>
> > ---
> >  drivers/dma/timb_dma.c           |    2 +-
> >  drivers/gpio/timbgpio.c          |    5 +-
> >  drivers/i2c/busses/i2c-ocores.c  |    2 +-
> >  drivers/i2c/busses/i2c-xiic.c    |    2 +-
> >  drivers/media/radio/radio-timb.c |    2 +-
> >  drivers/media/video/timblogiw.c  |    2 +-
> >  drivers/mfd/timberdale.c         |   81 +++++++++++++-------------------------
> >  drivers/net/ks8842.c             |    2 +-
> >  drivers/spi/xilinx_spi.c         |    2 +-
> >  9 files changed, 36 insertions(+), 64 deletions(-)
> > 
> > diff --git a/drivers/dma/timb_dma.c b/drivers/dma/timb_dma.c
> > index 3b88a4e..aa06ca4 100644
> > --- a/drivers/dma/timb_dma.c
> > +++ b/drivers/dma/timb_dma.c
> > @@ -684,7 +684,7 @@ static irqreturn_t td_irq(int irq, void *devid)
> >  
> >  static int __devinit td_probe(struct platform_device *pdev)
> >  {
> > -	struct timb_dma_platform_data *pdata = pdev->dev.platform_data;
> > +	struct timb_dma_platform_data *pdata = platform_get_drvdata(pdev);
> 
> Hold the phone.  I know this has already been merged, but this isn't correct.
> 
> drvdata is under the ownership of the driver, which means it should
> *not* be set when .probe() gets called.  It is for driver private data
> to do with as it needs, usually for internal state.
We didn't merge that version of the patchset, but one getting the
platform_data pointer from mfd_get_data(). That introduces the issue you're
talking about below.


> Gah.  Not all devices instantiated via mfd will be an mfd device,
> which means that the driver may very well expect an *entirely
> different* platform_device pointer; which further means a very high
> potential of incorrectly dereferenced structures (as evidenced by a
> patch series that is not bisectable).  For instance, the xilinx ip
> cores are used by more than just mfd.
I agree. Since the vast majority of the MFD subdevices are MFD specific IPs, I
overlooked that part. The impacted drivers are the timberdale and the DaVinci
voice codec ones.
To fix that problem I propose 2 alternatives:

1) When declaring the sub devices cells, the MFD driver should specify an
mfd_data_size value for sub devices that are not MFD specific. It's the MFD
driver responsibility to set the cell properly, and the non MFD specific
drivers are kept MFD agnostic.
See my patch below for the timberdale case.

2) Revert the mfd_get_data() call for getting sub devices platform data
pointers. That was introduced to ease the MFD cell sharing work, so if we take
this route we'll need the cs5535 MFD driver to pass its cells as platform_data
pointer. Andres, can you confirm that this would be fine for the
mfd_clone_cell() routine to keep working ?

Patch for solution 1:


 drivers/mfd/mfd-core.c          |   13 ++++++++++---
 drivers/mfd/timberdale.c        |   11 +++++++++++
 include/linux/mfd/core.h        |    1 +
 drivers/i2c/busses/i2c-ocores.c |    3 +--
 drivers/i2c/busses/i2c-xiic.c   |    3 +--
 drivers/net/ks8842.c            |    3 +--
 drivers/spi/xilinx_spi.c        |    3 +--
 7 files changed, 26 insertions(+), 11 deletions(-)

diff --git a/drivers/mfd/mfd-core.c b/drivers/mfd/mfd-core.c
index d01574d..8abe510 100644
--- a/drivers/mfd/mfd-core.c
+++ b/drivers/mfd/mfd-core.c
@@ -75,9 +75,16 @@ static int mfd_add_device(struct device *parent, int id,
 
 	pdev->dev.parent = parent;
 
-	ret = platform_device_add_data(pdev, cell, sizeof(*cell));
-	if (ret)
-		goto fail_res;
+	if (cell->mfd_data_size > 0) {
+		ret = platform_device_add_data(pdev,
+					cell->mfd_data, cell->mfd_data_size);
+		if (ret)
+			goto fail_res;
+	} else {
+		ret = platform_device_add_data(pdev, cell, sizeof(*cell));
+		if (ret)
+			goto fail_res;
+	}
 
 	for (r = 0; r < cell->num_resources; r++) {
 		res[r].name = cell->resources[r].name;
diff --git a/drivers/mfd/timberdale.c b/drivers/mfd/timberdale.c
index 94c6c8a..b4d2d09 100644
--- a/drivers/mfd/timberdale.c
+++ b/drivers/mfd/timberdale.c
@@ -396,6 +396,7 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg0[] = {
 		.num_resources = ARRAY_SIZE(timberdale_xiic_resources),
 		.resources = timberdale_xiic_resources,
 		.mfd_data = &timberdale_xiic_platform_data,
+		.mfd_data_size = sizeof(timberdale_xiic_platform_data)
 	},
 	{
 		.name = "timb-gpio",
@@ -420,12 +421,14 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg0[] = {
 		.num_resources = ARRAY_SIZE(timberdale_spi_resources),
 		.resources = timberdale_spi_resources,
 		.mfd_data = &timberdale_xspi_platform_data,
+		.mfd_data_size = sizeof(timberdale_xspi_platform_data)
 	},
 	{
 		.name = "ks8842",
 		.num_resources = ARRAY_SIZE(timberdale_eth_resources),
 		.resources = timberdale_eth_resources,
 		.mfd_data = &timberdale_ks8842_platform_data,
+		.mfd_data_size = sizeof(timberdale_ks8842_platform_data)
 	},
 };
 
@@ -451,6 +454,7 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg1[] = {
 		.num_resources = ARRAY_SIZE(timberdale_xiic_resources),
 		.resources = timberdale_xiic_resources,
 		.mfd_data = &timberdale_xiic_platform_data,
+		.mfd_data_size = sizeof(timberdale_xiic_platform_data)
 	},
 	{
 		.name = "timb-gpio",
@@ -480,12 +484,14 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg1[] = {
 		.num_resources = ARRAY_SIZE(timberdale_spi_resources),
 		.resources = timberdale_spi_resources,
 		.mfd_data = &timberdale_xspi_platform_data,
+		.mfd_data_size = sizeof(timberdale_xspi_platform_data)
 	},
 	{
 		.name = "ks8842",
 		.num_resources = ARRAY_SIZE(timberdale_eth_resources),
 		.resources = timberdale_eth_resources,
 		.mfd_data = &timberdale_ks8842_platform_data,
+		.mfd_data_size = sizeof(timberdale_ks8842_platform_data)
 	},
 };
 
@@ -506,6 +512,7 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg2[] = {
 		.num_resources = ARRAY_SIZE(timberdale_xiic_resources),
 		.resources = timberdale_xiic_resources,
 		.mfd_data = &timberdale_xiic_platform_data,
+		.mfd_data_size = sizeof(timberdale_xiic_platform_data)
 	},
 	{
 		.name = "timb-gpio",
@@ -530,6 +537,7 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg2[] = {
 		.num_resources = ARRAY_SIZE(timberdale_spi_resources),
 		.resources = timberdale_spi_resources,
 		.mfd_data = &timberdale_xspi_platform_data,
+		.mfd_data_size = sizeof(timberdale_xspi_platform_data)
 	},
 };
 
@@ -550,6 +558,7 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg3[] = {
 		.num_resources = ARRAY_SIZE(timberdale_ocores_resources),
 		.resources = timberdale_ocores_resources,
 		.mfd_data = &timberdale_ocores_platform_data,
+		.mfd_data_size = sizeof(timberdale_ocores_platform_data)
 	},
 	{
 		.name = "timb-gpio",
@@ -574,12 +583,14 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg3[] = {
 		.num_resources = ARRAY_SIZE(timberdale_spi_resources),
 		.resources = timberdale_spi_resources,
 		.mfd_data = &timberdale_xspi_platform_data,
+		.mfd_data_size = sizeof(timberdale_xspi_platform_data)
 	},
 	{
 		.name = "ks8842",
 		.num_resources = ARRAY_SIZE(timberdale_eth_resources),
 		.resources = timberdale_eth_resources,
 		.mfd_data = &timberdale_ks8842_platform_data,
+		.mfd_data_size = sizeof(timberdale_ks8842_platform_data)
 	},
 };
 
diff --git a/include/linux/mfd/core.h b/include/linux/mfd/core.h
index ad1b19a..3687e10 100644
--- a/include/linux/mfd/core.h
+++ b/include/linux/mfd/core.h
@@ -35,6 +35,7 @@ struct mfd_cell {
 
 	/* mfd_data can be used to pass data to client drivers */
 	void			*mfd_data;
+	size_t			mfd_data_size;
 
 	/*
 	 * These resources can be specified relative to the parent device.
diff --git a/drivers/i2c/busses/i2c-ocores.c b/drivers/i2c/busses/i2c-ocores.c
index fee1a26..1b46a9d 100644
--- a/drivers/i2c/busses/i2c-ocores.c
+++ b/drivers/i2c/busses/i2c-ocores.c
@@ -49,7 +49,6 @@
 #include <linux/init.h>
 #include <linux/errno.h>
 #include <linux/platform_device.h>
-#include <linux/mfd/core.h>
 #include <linux/i2c.h>
 #include <linux/interrupt.h>
 #include <linux/wait.h>
@@ -306,7 +305,7 @@ static int __devinit ocores_i2c_probe(struct platform_device *pdev)
 		return -EIO;
 	}
 
-	pdata = mfd_get_data(pdev);
+	pdata = pdev->dev.platform_data;
 	if (pdata) {
 		i2c->regstep = pdata->regstep;
 		i2c->clock_khz = pdata->clock_khz;
diff --git a/drivers/i2c/busses/i2c-xiic.c b/drivers/i2c/busses/i2c-xiic.c
index 9fbd7e6..a9c419e 100644
--- a/drivers/i2c/busses/i2c-xiic.c
+++ b/drivers/i2c/busses/i2c-xiic.c
@@ -34,7 +34,6 @@
 #include <linux/errno.h>
 #include <linux/delay.h>
 #include <linux/platform_device.h>
-#include <linux/mfd/core.h>
 #include <linux/i2c.h>
 #include <linux/interrupt.h>
 #include <linux/wait.h>
@@ -705,7 +704,7 @@ static int __devinit xiic_i2c_probe(struct platform_device *pdev)
 	if (irq < 0)
 		goto resource_missing;
 
-	pdata = mfd_get_data(pdev);
+	pdata = (struct xiic_i2c_platform_data *) pdev->dev.platform_data;
 	if (!pdata)
 		return -EINVAL;
 
diff --git a/drivers/net/ks8842.c b/drivers/net/ks8842.c
index efd44af..928b2b8 100644
--- a/drivers/net/ks8842.c
+++ b/drivers/net/ks8842.c
@@ -26,7 +26,6 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/platform_device.h>
-#include <linux/mfd/core.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
@@ -1146,7 +1145,7 @@ static int __devinit ks8842_probe(struct platform_device *pdev)
 	struct resource *iomem;
 	struct net_device *netdev;
 	struct ks8842_adapter *adapter;
-	struct ks8842_platform_data *pdata = mfd_get_data(pdev);
+	struct ks8842_platform_data *pdata = pdev->dev.platform_data;
 	u16 id;
 	unsigned i;
 
diff --git a/drivers/spi/xilinx_spi.c b/drivers/spi/xilinx_spi.c
index c69c6f2..4d2c75d 100644
--- a/drivers/spi/xilinx_spi.c
+++ b/drivers/spi/xilinx_spi.c
@@ -18,7 +18,6 @@
 #include <linux/interrupt.h>
 #include <linux/of.h>
 #include <linux/platform_device.h>
-#include <linux/mfd/core.h>
 #include <linux/spi/spi.h>
 #include <linux/spi/spi_bitbang.h>
 #include <linux/spi/xilinx_spi.h>
@@ -471,7 +470,7 @@ static int __devinit xilinx_spi_probe(struct platform_device *dev)
 	struct spi_master *master;
 	u8 i;
 
-	pdata = mfd_get_data(dev);
+	pdata = dev->dev.platform_data;
 	if (pdata) {
 		num_cs = pdata->num_chipselect;
 		little_endian = pdata->little_endian;


-- 
Intel Open Source Technology Centre
http://oss.intel.com/

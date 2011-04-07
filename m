From: Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH 07/19] timberdale: mfd_cell is now implicitly available
 to drivers
Date: Thu, 7 Apr 2011 15:40:23 +0200
Message-ID: <20110407133717.GA3923@sortiz-mobl>
References: <20110401235239.GE29397@sortiz-mobl>
 <BANLkTi=bq=OGzXFp7qiBr7x_BnGOWf=DRQ@mail.gmail.com>
 <20110404100314.GC2751@sortiz-mobl>
 <20110405030428.GB29522@ponder.secretlab.ca>
 <20110406152322.GA2757@sortiz-mobl>
 <20110406155805.GA20095@suse.de>
 <20110406170537.GB2757@sortiz-mobl>
 <20110406175647.GA8048@suse.de>
 <20110406184733.GD2757@sortiz-mobl>
 <20110406185902.GN25654@legolas.emea.dhcp.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>, Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>,
	Andres Salomon <dilinger-pFFUokh25LWsTnJN9+BGXg@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Mark Brown <broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>,
	khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org, ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org,
	Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>,
	Mauro Carvalho Chehab <mchehab-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, spi-devel-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Mocean Laboratories <info-l7gf1WXxx3uGw+nKnLezzg@public.gmane.org>
To: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110406185902.GN25654-UiBtZHVXSwEVvW8u9ZQWYwjfymiNCTlR@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Felipe,

On Wed, Apr 06, 2011 at 09:59:02PM +0300, Felipe Balbi wrote:
> Hi,
> 
> On Wed, Apr 06, 2011 at 08:47:34PM +0200, Samuel Ortiz wrote:
> > > > > What is a "MFD cell pointer" and why is it needed in struct device?
> > > > An MFD cell is an MFD instantiated device.
> > > > MFD (Multi Function Device) drivers instantiate platform devices. Those
> > > > devices drivers sometimes need a platform data pointer, sometimes an MFD
> > > > specific pointer, and sometimes both. Also, some of those drivers have been
> > > > implemented as MFD sub drivers, while others know nothing about MFD and just
> > > > expect a plain platform_data pointer.
> > > 
> > > That sounds like a bug in those drivers, why not fix them to properly
> > > pass in the correct pointer?
> > Because they're drivers for generic IPs, not MFD ones. By forcing them to use
> > MFD specific structure and APIs, we make it more difficult for platform code
> > to instantiate them.
> 
> I agree. What I do on those cases is to have a simple platform_device
> for the core IP driver and use platform_device_id tables to do runtime
> checks of the small differences. If one platform X doesn't use a
> platform_bus, it uses e.g. PCI, then you make a PCI "bridge" which
> allocates a platform_device with the correct name and adds that to the
> driver model.
I see, thanks.
Below is a patch for the Xilinx SPI example. Although this would fix the
issue, we'd still have to do that on device per device basis. I had a similar
solution where MFD drivers would set a flag for sub drivers that don't need
any of the MFD bits. In that case the MFD core code would just forward the
platform data, instead of embedding it through an MFD cell.

Cheers,
Samuel.

---
 drivers/mfd/timberdale.c |    8 ++++----
 drivers/spi/xilinx_spi.c |   19 ++++++++++++++++++-
 include/linux/mfd/core.h |    3 +++
 3 files changed, 25 insertions(+), 5 deletions(-)

diff --git a/drivers/mfd/timberdale.c b/drivers/mfd/timberdale.c
index 94c6c8a..c9220ce 100644
--- a/drivers/mfd/timberdale.c
+++ b/drivers/mfd/timberdale.c
@@ -416,7 +416,7 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg0[] = {
 		.mfd_data = &timberdale_radio_platform_data,
 	},
 	{
-		.name = "xilinx_spi",
+		.name = "mfd_xilinx_spi",
 		.num_resources = ARRAY_SIZE(timberdale_spi_resources),
 		.resources = timberdale_spi_resources,
 		.mfd_data = &timberdale_xspi_platform_data,
@@ -476,7 +476,7 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg1[] = {
 		.mfd_data = &timberdale_radio_platform_data,
 	},
 	{
-		.name = "xilinx_spi",
+		.name = "mfd_xilinx_spi",
 		.num_resources = ARRAY_SIZE(timberdale_spi_resources),
 		.resources = timberdale_spi_resources,
 		.mfd_data = &timberdale_xspi_platform_data,
@@ -526,7 +526,7 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg2[] = {
 		.mfd_data = &timberdale_radio_platform_data,
 	},
 	{
-		.name = "xilinx_spi",
+		.name = "mfd_xilinx_spi",
 		.num_resources = ARRAY_SIZE(timberdale_spi_resources),
 		.resources = timberdale_spi_resources,
 		.mfd_data = &timberdale_xspi_platform_data,
@@ -570,7 +570,7 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg3[] = {
 		.mfd_data = &timberdale_radio_platform_data,
 	},
 	{
-		.name = "xilinx_spi",
+		.name = "mfd_xilinx_spi",
 		.num_resources = ARRAY_SIZE(timberdale_spi_resources),
 		.resources = timberdale_spi_resources,
 		.mfd_data = &timberdale_xspi_platform_data,
diff --git a/drivers/spi/xilinx_spi.c b/drivers/spi/xilinx_spi.c
index c69c6f2..3287b84 100644
--- a/drivers/spi/xilinx_spi.c
+++ b/drivers/spi/xilinx_spi.c
@@ -471,7 +471,11 @@ static int __devinit xilinx_spi_probe(struct platform_device *dev)
 	struct spi_master *master;
 	u8 i;
 
-	pdata = mfd_get_data(dev);
+	if (platform_get_device_id(dev) &&
+	    platform_get_device_id(dev)->driver_data & MFD_PLATFORM_DEVICE)
+		pdata = mfd_get_data(dev);
+	else
+		pdata = dev->dev.platform_data;
 	if (pdata) {
 		num_cs = pdata->num_chipselect;
 		little_endian = pdata->little_endian;
@@ -530,6 +534,18 @@ static int __devexit xilinx_spi_remove(struct platform_device *dev)
 /* work with hotplug and coldplug */
 MODULE_ALIAS("platform:" XILINX_SPI_NAME);
 
+static const struct platform_device_id xilinx_spi_id_table[] = {
+	{
+		.name	= XILINX_SPI_NAME,
+	},
+	{
+		.name	= "mfd_xilinx_spi",
+		.driver_data = MFD_PLATFORM_DEVICE,
+	},
+	{  },	/* Terminating Entry */
+};
+MODULE_DEVICE_TABLE(platform, xilinx_spi_id_table);
+
 static struct platform_driver xilinx_spi_driver = {
 	.probe = xilinx_spi_probe,
 	.remove = __devexit_p(xilinx_spi_remove),
@@ -538,6 +554,7 @@ static struct platform_driver xilinx_spi_driver = {
 		.owner = THIS_MODULE,
 		.of_match_table = xilinx_spi_of_match,
 	},
+	.id_table	= xilinx_spi_id_table,
 };
 
 static int __init xilinx_spi_pltfm_init(void)
diff --git a/include/linux/mfd/core.h b/include/linux/mfd/core.h
index ad1b19a..13f31f4 100644
--- a/include/linux/mfd/core.h
+++ b/include/linux/mfd/core.h
@@ -89,6 +89,9 @@ static inline const struct mfd_cell *mfd_get_cell(struct platform_device *pdev)
 	return pdev->dev.platform_data;
 }
 
+/* */
+#define MFD_PLATFORM_DEVICE BIT(0)
+
 /*
  * Given a platform device that's been created by mfd_add_devices(), fetch
  * the .mfd_data entry from the mfd_cell that created it.


-- 
Intel Open Source Technology Centre
http://oss.intel.com/

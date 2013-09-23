From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 43/51] DMA-API: dma: edma.c: no need
	to	explicitly initialize DMA masks
Date: Mon, 23 Sep 2013 12:37:55 +0100
Message-ID: <20130923113755.GT25647@n2100.arm.linux.org.uk>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
 <E1VMnRj-0007sg-1Z@rmk-PC.arm.linux.org.uk>
 <20130923102533.GI17188@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alsa-devel@alsa-project.org, linux-doc@vger.kernel.org,
 linux-mmc@vger.kernel.org, linux-fbdev@vger.kernel.org,
 linux-nvme@lists.infradead.org, linux-ide@vger.kernel.org,
 devel@driverdev.osuosl.org, linux-samsung-soc@vger.kernel.org,
 linux-scsi@vger.kernel.org, e1000-devel@lists.sourceforge.net,
 b43-dev@lists.infradead.org, linux-media@vger.kernel.org,
 devicetree@vger.kernel.org, dri-devel@lists.freedesktop.org,
 linux-tegra@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>,
 linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
 netdev@vger.kernel.org, linux-usb@vger.kernel.org,
 linux-wireless@vger.kernel.org, linux-crypto@vger.kernel.org,
 uclinux-dist-devel@blackfin.uclinux.org, linuxppc-dev@lists.ozlabs.org
To: Vinod Koul <vinod.koul@intel.com>
Return-path: <alsa-devel-bounces@alsa-project.org>
Content-Disposition: inline
In-Reply-To: <20130923102533.GI17188@intel.com>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/options/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel/>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Errors-To: alsa-devel-bounces@alsa-project.org
Sender: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 23, 2013 at 03:55:33PM +0530, Vinod Koul wrote:
> On Fri, Sep 20, 2013 at 12:15:39AM +0100, Russell King wrote:
> > register_platform_device_full() can setup the DMA mask provided the
> > appropriate member is set in struct platform_device_info.  So lets
> > make that be the case.  This avoids a direct reference to the DMA
> > masks by this driver.
> > 
> > Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> Acked-by: Vinod Koul <vinod.koul@intel.com>
> 
> This also brings me question that should we force the driver to use the
> dma_set_mask_and_coherent() API or they have below flexiblity too?

There's two issues here:
1. dma_set_mask_and_coherent() will only work if dev->dma_mask points at
   some storage for the mask.  This needs to have .dma_mask in the
   platform_device_info initialised.

2. Yes, this driver should also be calling the appropriate DMA mask setting
   functions in addition to having the mask initialized at device creation
   time.

Here's a replacement patch, though maybe it would be better to roll all
the additions of dma_set_mask_and_coherent() in drivers/dma into one
patch?  In other words, combine the addition of this with these two
patches:

	dma: pl330: add dma_set_mask_and_coherent() call
	dma: pl08x: add dma_set_mask_and_coherent() call

8<=====
From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH] DMA-API: dma: edma.c: no need to explicitly initialize DMA
 masks

register_platform_device_full() can setup the DMA mask provided the
appropriate member is set in struct platform_device_info.  So lets
make that be the case.  This avoids a direct reference to the DMA
masks by this driver.

While here, add the dma_set_mask_and_coherent() call which the DMA API
requires DMA-using drivers to call.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/dma/edma.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/dma/edma.c b/drivers/dma/edma.c
index ff50ff4..fd5e48c 100644
--- a/drivers/dma/edma.c
+++ b/drivers/dma/edma.c
@@ -631,6 +631,10 @@ static int edma_probe(struct platform_device *pdev)
 	struct edma_cc *ecc;
 	int ret;
 
+	ret = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));
+	if (ret)
+		return ret;
+
 	ecc = devm_kzalloc(&pdev->dev, sizeof(*ecc), GFP_KERNEL);
 	if (!ecc) {
 		dev_err(&pdev->dev, "Can't allocate controller\n");
@@ -702,11 +706,13 @@ static struct platform_device *pdev0, *pdev1;
 static const struct platform_device_info edma_dev_info0 = {
 	.name = "edma-dma-engine",
 	.id = 0,
+	.dma_mask = DMA_BIT_MASK(32),
 };
 
 static const struct platform_device_info edma_dev_info1 = {
 	.name = "edma-dma-engine",
 	.id = 1,
+	.dma_mask = DMA_BIT_MASK(32),
 };
 
 static int edma_init(void)
@@ -720,8 +726,6 @@ static int edma_init(void)
 			ret = PTR_ERR(pdev0);
 			goto out;
 		}
-		pdev0->dev.dma_mask = &pdev0->dev.coherent_dma_mask;
-		pdev0->dev.coherent_dma_mask = DMA_BIT_MASK(32);
 	}
 
 	if (EDMA_CTLRS == 2) {
@@ -731,8 +735,6 @@ static int edma_init(void)
 			platform_device_unregister(pdev0);
 			ret = PTR_ERR(pdev1);
 		}
-		pdev1->dev.dma_mask = &pdev1->dev.coherent_dma_mask;
-		pdev1->dev.coherent_dma_mask = DMA_BIT_MASK(32);
 	}
 
 out:
-- 
1.7.4.4

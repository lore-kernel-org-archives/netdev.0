From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH 39/51] DMA-API: others: use dma_set_coherent_mask()
Date: Fri, 20 Sep 2013 00:11:38 +0100
Message-ID: <E1VMnNq-0007s4-HN@rmk-PC.arm.linux.org.uk>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Kukjin Kim <kgene.kim@samsung.com>,
 Joonyoung Shim <jy0922.shim@samsung.com>, David Airlie <airlied@linux.ie>,
 Seung-Woo Kim <sw0312.kim@samsung.com>, Inki Dae <inki.dae@samsung.com>,
 Kyungmin Park <kyungmin.park@samsung.com>, Tejun Heo <tj@kernel.org>
To: alsa-devel@alsa-project.org, b43-dev@lists.infradead.org,
 devel@driverdev.osuosl.org, devicetree@vger.kernel.org,
 dri-devel@lists.freedesktop.org, e1000-devel@lists.sourceforge.net,
 linux-arm-kernel@lists.infradead.org, linux-crypto@vger.kernel.org,
 linux-doc@vger.kernel.org, linux-fbdev@vger.kernel.org,
 linux-ide@vger.kernel.org, linux-media@vger.kernel.org,
 linux-mmc@vger.kernel.org, linux-nvme@lists.infradead.org,
 linux-omap@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org,
 linux-tegra@vger.kernel.org, linux-usb@vger.kernel.org,
 linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
 Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
 uclinux-dist-devel@blackfin.uclinux.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20130919212235.GD12758@n2100.arm.linux.org.uk>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

The correct way for a driver to specify the coherent DMA mask is
not to directly access the field in the struct device, but to use
dma_set_coherent_mask().  Only arch and bus code should access this
member directly.

Convert all direct write accesses to using the correct API.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/ata/pata_ixp4xx_cf.c             |    5 ++++-
 drivers/gpu/drm/exynos/exynos_drm_drv.c  |    6 +++++-
 drivers/gpu/drm/omapdrm/omap_dmm_tiler.c |    5 +++--
 3 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/ata/pata_ixp4xx_cf.c b/drivers/ata/pata_ixp4xx_cf.c
index 1ec53f8..ddf470c 100644
--- a/drivers/ata/pata_ixp4xx_cf.c
+++ b/drivers/ata/pata_ixp4xx_cf.c
@@ -144,6 +144,7 @@ static int ixp4xx_pata_probe(struct platform_device *pdev)
 	struct ata_host *host;
 	struct ata_port *ap;
 	struct ixp4xx_pata_data *data = dev_get_platdata(&pdev->dev);
+	int ret;
 
 	cs0 = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	cs1 = platform_get_resource(pdev, IORESOURCE_MEM, 1);
@@ -157,7 +158,9 @@ static int ixp4xx_pata_probe(struct platform_device *pdev)
 		return -ENOMEM;
 
 	/* acquire resources and fill host */
-	pdev->dev.coherent_dma_mask = DMA_BIT_MASK(32);
+	ret = dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(32));
+	if (ret)
+		return ret;
 
 	data->cs0 = devm_ioremap(&pdev->dev, cs0->start, 0x1000);
 	data->cs1 = devm_ioremap(&pdev->dev, cs1->start, 0x1000);
diff --git a/drivers/gpu/drm/exynos/exynos_drm_drv.c b/drivers/gpu/drm/exynos/exynos_drm_drv.c
index bb82ef7..81192d0 100644
--- a/drivers/gpu/drm/exynos/exynos_drm_drv.c
+++ b/drivers/gpu/drm/exynos/exynos_drm_drv.c
@@ -286,7 +286,11 @@ static struct drm_driver exynos_drm_driver = {
 
 static int exynos_drm_platform_probe(struct platform_device *pdev)
 {
-	pdev->dev.coherent_dma_mask = DMA_BIT_MASK(32);
+	int ret;
+
+	ret = dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(32));
+	if (ret)
+		return ret;
 
 	return drm_platform_init(&exynos_drm_driver, pdev);
 }
diff --git a/drivers/gpu/drm/omapdrm/omap_dmm_tiler.c b/drivers/gpu/drm/omapdrm/omap_dmm_tiler.c
index acf6678..701c4c1 100644
--- a/drivers/gpu/drm/omapdrm/omap_dmm_tiler.c
+++ b/drivers/gpu/drm/omapdrm/omap_dmm_tiler.c
@@ -664,8 +664,9 @@ static int omap_dmm_probe(struct platform_device *dev)
 	}
 
 	/* set dma mask for device */
-	/* NOTE: this is a workaround for the hwmod not initializing properly */
-	dev->dev.coherent_dma_mask = DMA_BIT_MASK(32);
+	ret = dma_set_coherent_mask(&dev->dev, DMA_BIT_MASK(32));
+	if (ret)
+		goto fail;
 
 	omap_dmm->dummy_pa = page_to_phys(omap_dmm->dummy_page);
 
-- 
1.7.4.4

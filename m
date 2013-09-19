From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH 31/51] DMA-API: media: omap3isp: use
 dma_coerce_mask_and_coherent()
Date: Thu, 19 Sep 2013 22:56:02 +0100
Message-ID: <E1VMmCg-0007j1-Pi@rmk-PC.arm.linux.org.uk>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Laurent Pinchart <laurent.pinchart@ideasonboard.com>,
 Mauro Carvalho Chehab <m.chehab@samsung.com>
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
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <20130919212235.GD12758@n2100.arm.linux.org.uk>
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

The code sequence:
	isp->raw_dmamask = DMA_BIT_MASK(32);
	isp->dev->dma_mask = &isp->raw_dmamask;
	isp->dev->coherent_dma_mask = DMA_BIT_MASK(32);
bypasses the architectures check on the DMA mask.  It can be replaced
with dma_coerce_mask_and_coherent(), avoiding the direct initialization
of this mask.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/media/platform/omap3isp/isp.c |    6 +++---
 drivers/media/platform/omap3isp/isp.h |    3 ---
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/media/platform/omap3isp/isp.c b/drivers/media/platform/omap3isp/isp.c
index df3a0ec..1c36080 100644
--- a/drivers/media/platform/omap3isp/isp.c
+++ b/drivers/media/platform/omap3isp/isp.c
@@ -2182,9 +2182,9 @@ static int isp_probe(struct platform_device *pdev)
 	isp->pdata = pdata;
 	isp->ref_count = 0;
 
-	isp->raw_dmamask = DMA_BIT_MASK(32);
-	isp->dev->dma_mask = &isp->raw_dmamask;
-	isp->dev->coherent_dma_mask = DMA_BIT_MASK(32);
+	ret = dma_coerce_mask_and_coherent(isp->dev, DMA_BIT_MASK(32));
+	if (ret)
+		return ret;
 
 	platform_set_drvdata(pdev, isp);
 
diff --git a/drivers/media/platform/omap3isp/isp.h b/drivers/media/platform/omap3isp/isp.h
index cd3eff4..ce65d3a 100644
--- a/drivers/media/platform/omap3isp/isp.h
+++ b/drivers/media/platform/omap3isp/isp.h
@@ -152,7 +152,6 @@ struct isp_xclk {
  * @mmio_base_phys: Array with physical L4 bus addresses for ISP register
  *                  regions.
  * @mmio_size: Array with ISP register regions size in bytes.
- * @raw_dmamask: Raw DMA mask
  * @stat_lock: Spinlock for handling statistics
  * @isp_mutex: Mutex for serializing requests to ISP.
  * @crashed: Bitmask of crashed entities (indexed by entity ID)
@@ -190,8 +189,6 @@ struct isp_device {
 	unsigned long mmio_base_phys[OMAP3_ISP_IOMEM_LAST];
 	resource_size_t mmio_size[OMAP3_ISP_IOMEM_LAST];
 
-	u64 raw_dmamask;
-
 	/* ISP Obj */
 	spinlock_t stat_lock;	/* common lock for statistic drivers */
 	struct mutex isp_mutex;	/* For handling ref_count field */
-- 
1.7.4.4

From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH 50/51] ARM: 7797/1: mmc: Use dma_max_pfn(dev)
 helper for bounce_limit calculations
Date: Fri, 20 Sep 2013 00:43:07 +0100
Message-ID: <E1VMnsJ-0002E4-3c@rmk-PC.arm.linux.org.uk>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Chris Ball <cjb@laptop.org>
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

From: Santosh Shilimkar <santosh.shilimkar@ti.com>

DMA bounce limit is the maximum direct DMA'able memory beyond which
bounce buffers has to be used to perform dma operations. MMC queue layr
relies on dma_mask but its calculation is based on max_*pfn which
don't have uniform meaning across architectures. So make use of
dma_max_pfn() which is expected to return the DMAable maximum pfn
value across architectures.

Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/mmc/card/queue.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/mmc/card/queue.c b/drivers/mmc/card/queue.c
index fa9632e..357bbc5 100644
--- a/drivers/mmc/card/queue.c
+++ b/drivers/mmc/card/queue.c
@@ -15,6 +15,7 @@
 #include <linux/freezer.h>
 #include <linux/kthread.h>
 #include <linux/scatterlist.h>
+#include <linux/dma-mapping.h>
 
 #include <linux/mmc/card.h>
 #include <linux/mmc/host.h>
@@ -196,7 +197,7 @@ int mmc_init_queue(struct mmc_queue *mq, struct mmc_card *card,
 	struct mmc_queue_req *mqrq_prev = &mq->mqrq[1];
 
 	if (mmc_dev(host)->dma_mask && *mmc_dev(host)->dma_mask)
-		limit = *mmc_dev(host)->dma_mask;
+		limit = dma_max_pfn(mmc_dev(host)) << PAGE_SHIFT;
 
 	mq->card = card;
 	mq->queue = blk_init_queue(mmc_request_fn, lock);
-- 
1.7.4.4

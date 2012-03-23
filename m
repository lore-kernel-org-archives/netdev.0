From: Alexandre Bounine <alexandre.bounine@idt.com>
Subject: [PATCH linux-next] dmaengine: add context parameter fixups
Date: Fri, 23 Mar 2012 10:00:42 -0400
Message-ID: <1332511242-30241-1-git-send-email-alexandre.bounine@idt.com>
Cc: Alexandre Bounine <alexandre.bounine@idt.com>, samuel@sortiz.org,
	lrg@ti.com, broonie@opensource.wolfsonmicro.com, perex@perex.cz,
	tiwai@suse.de, linux-kernel@vger.kernel.org,
	linux-next@vger.kernel.org, netdev@vger.kernel.org,
	fabio.estevam@freescale.com, alsa-devel@alsa-project.org
To: paul.gortmaker@windriver.com, vinod.koul@intel.com,
	dan.j.williams@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes drivers that use device_prep_slave_sg() and
device_prep_dma_cyclic() interfaces and have been missed during the initial
release of interface changing patches.

This patch is based on linux-next-20120322 code tree.
See https://lkml.org/lkml/2012/3/22/339 for build failure report.

Signed-off-by: Alexandre Bounine <alexandre.bounine@idt.com>
Reported-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/dma/sa11x0-dma.c      |    2 +-
 drivers/net/irda/sa1100_ir.c  |    2 +-
 sound/soc/sh/fsi.c            |    7 +++----
 sound/soc/soc-dmaengine-pcm.c |    2 +-
 4 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/dma/sa11x0-dma.c b/drivers/dma/sa11x0-dma.c
index 16a6b48..ec78cce 100644
--- a/drivers/dma/sa11x0-dma.c
+++ b/drivers/dma/sa11x0-dma.c
@@ -585,7 +585,7 @@ static dma_cookie_t sa11x0_dma_tx_submit(struct dma_async_tx_descriptor *tx)
 
 static struct dma_async_tx_descriptor *sa11x0_dma_prep_slave_sg(
 	struct dma_chan *chan, struct scatterlist *sg, unsigned int sglen,
-	enum dma_transfer_direction dir, unsigned long flags)
+	enum dma_transfer_direction dir, unsigned long flags, void *context)
 {
 	struct sa11x0_dma_chan *c = to_sa11x0_dma_chan(chan);
 	struct sa11x0_dma_desc *txd;
diff --git a/drivers/net/irda/sa1100_ir.c b/drivers/net/irda/sa1100_ir.c
index a0d1913..e250675 100644
--- a/drivers/net/irda/sa1100_ir.c
+++ b/drivers/net/irda/sa1100_ir.c
@@ -147,7 +147,7 @@ static void sa1100_irda_dma_start(struct sa1100_buf *buf,
 	struct dma_async_tx_descriptor *desc;
 	struct dma_chan *chan = buf->chan;
 
-	desc = chan->device->device_prep_slave_sg(chan, &buf->sg, 1, dir,
+	desc = dmaengine_prep_slave_sg(chan, &buf->sg, 1, dir,
 			DMA_PREP_INTERRUPT | DMA_CTRL_ACK);
 	if (desc) {
 		desc->callback = cb;
diff --git a/sound/soc/sh/fsi.c b/sound/soc/sh/fsi.c
index 378cc5b..9e730ad 100644
--- a/sound/soc/sh/fsi.c
+++ b/sound/soc/sh/fsi.c
@@ -1001,11 +1001,10 @@ static void fsi_dma_do_tasklet(unsigned long data)
 	sg_dma_address(&sg) = buf;
 	sg_dma_len(&sg) = len;
 
-	desc = chan->device->device_prep_slave_sg(chan, &sg, 1, dir,
-						  DMA_PREP_INTERRUPT |
-						  DMA_CTRL_ACK);
+	desc = dmaengine_prep_slave_sg(chan, &sg, 1, dir,
+					DMA_PREP_INTERRUPT | DMA_CTRL_ACK);
 	if (!desc) {
-		dev_err(dai->dev, "device_prep_slave_sg() fail\n");
+		dev_err(dai->dev, "dmaengine_prep_slave_sg() fail\n");
 		return;
 	}
 
diff --git a/sound/soc/soc-dmaengine-pcm.c b/sound/soc/soc-dmaengine-pcm.c
index 4420b70..4756952 100644
--- a/sound/soc/soc-dmaengine-pcm.c
+++ b/sound/soc/soc-dmaengine-pcm.c
@@ -143,7 +143,7 @@ static int dmaengine_pcm_prepare_and_submit(struct snd_pcm_substream *substream)
 	direction = snd_pcm_substream_to_dma_direction(substream);
 
 	prtd->pos = 0;
-	desc = chan->device->device_prep_dma_cyclic(chan,
+	desc = dmaengine_prep_dma_cyclic(chan,
 		substream->runtime->dma_addr,
 		snd_pcm_lib_buffer_bytes(substream),
 		snd_pcm_lib_period_bytes(substream), direction);
-- 
1.7.8.4

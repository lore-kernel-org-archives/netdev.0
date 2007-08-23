From: Shannon Nelson <shannon.nelson@intel.com>
Subject: [PATCH] IOAT: ioatdma needs to to play nice in a multi-dma-client
	world
Date: Wed, 22 Aug 2007 17:12:18 -0700
Message-ID: <20070823001218.11648.49528.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: shannon.nelson@intel.com, dan.j.williams@intel.com,
	jgarzik@pobox.com
To: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:26860 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932482AbXHWAMi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 20:12:38 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that the DMA engine has a multi-client interface, fix the ioatdma
driver to play along.  At the same time, remove a couple of unnecessary
reads and writes.

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
---

 drivers/dma/ioatdma.c |   18 ++++--------------
 1 files changed, 4 insertions(+), 14 deletions(-)

diff --git a/drivers/dma/ioatdma.c b/drivers/dma/ioatdma.c
index 2d1f178..41b18c5 100644
--- a/drivers/dma/ioatdma.c
+++ b/drivers/dma/ioatdma.c
@@ -191,17 +191,12 @@ static int ioat_dma_alloc_chan_resources(struct dma_chan *chan)
 	int i;
 	LIST_HEAD(tmp_list);
 
-	/*
-	 * In-use bit automatically set by reading chanctrl
-	 * If 0, we got it, if 1, someone else did
-	 */
-	chanctrl = readw(ioat_chan->reg_base + IOAT_CHANCTRL_OFFSET);
-	if (chanctrl & IOAT_CHANCTRL_CHANNEL_IN_USE)
-		return -EBUSY;
+	/* have we already been set up? */
+	if (!list_empty(&ioat_chan->free_desc))
+		return INITIAL_IOAT_DESC_COUNT;
 
         /* Setup register to interrupt and write completion status on error */
-	chanctrl = IOAT_CHANCTRL_CHANNEL_IN_USE |
-		IOAT_CHANCTRL_ERR_INT_EN |
+	chanctrl = IOAT_CHANCTRL_ERR_INT_EN |
 		IOAT_CHANCTRL_ANY_ERR_ABORT_EN |
 		IOAT_CHANCTRL_ERR_COMPLETION_EN;
         writew(chanctrl, ioat_chan->reg_base + IOAT_CHANCTRL_OFFSET);
@@ -282,11 +277,6 @@ static void ioat_dma_free_chan_resources(struct dma_chan *chan)
 			in_use_descs - 1);
 
 	ioat_chan->last_completion = ioat_chan->completion_addr = 0;
-
-	/* Tell hw the chan is free */
-	chanctrl = readw(ioat_chan->reg_base + IOAT_CHANCTRL_OFFSET);
-	chanctrl &= ~IOAT_CHANCTRL_CHANNEL_IN_USE;
-	writew(chanctrl, ioat_chan->reg_base + IOAT_CHANCTRL_OFFSET);
 }
 
 static struct dma_async_tx_descriptor *

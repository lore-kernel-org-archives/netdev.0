From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 17/29] ioat: preserve chanctrl bits when re-arming interrupts
Date: Thu, 03 Sep 2009 19:31:56 -0700
Message-ID: <20090904023156.32667.64825.stgit@dwillia2-linux.ch.intel.com>
References: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-raid@vger.kernel.org, netdev@vger.kernel.org,
	Maciej Sosnowski <maciej.sosnowski@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:22986 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932562AbZIDCby (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2009 22:31:54 -0400
In-Reply-To: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The register write in ioat_dma_cleanup_tasklet is unfortunate in two
ways:
1/ It clears the extra 'enable' bits that we set at alloc_chan_resources time
2/ It gives the impression that it disables interrupts when it is in
   fact re-arming interrupts

[ Impact: fix, persist the value of the chanctrl register when re-arming ]

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dma/ioat/dma.c       |   10 +++-------
 drivers/dma/ioat/dma_v2.c    |    8 ++------
 drivers/dma/ioat/registers.h |    6 +++++-
 3 files changed, 10 insertions(+), 14 deletions(-)

diff --git a/drivers/dma/ioat/dma.c b/drivers/dma/ioat/dma.c
index 5173ba9..6dd0af1 100644
--- a/drivers/dma/ioat/dma.c
+++ b/drivers/dma/ioat/dma.c
@@ -452,7 +452,6 @@ static int ioat1_dma_alloc_chan_resources(struct dma_chan *c)
 	struct ioat_dma_chan *ioat = to_ioat_chan(c);
 	struct ioat_chan_common *chan = &ioat->base;
 	struct ioat_desc_sw *desc;
-	u16 chanctrl;
 	u32 chanerr;
 	int i;
 	LIST_HEAD(tmp_list);
@@ -462,10 +461,7 @@ static int ioat1_dma_alloc_chan_resources(struct dma_chan *c)
 		return ioat->desccount;
 
 	/* Setup register to interrupt and write completion status on error */
-	chanctrl = IOAT_CHANCTRL_ERR_INT_EN |
-		IOAT_CHANCTRL_ANY_ERR_ABORT_EN |
-		IOAT_CHANCTRL_ERR_COMPLETION_EN;
-	writew(chanctrl, chan->reg_base + IOAT_CHANCTRL_OFFSET);
+	writew(IOAT_CHANCTRL_RUN, chan->reg_base + IOAT_CHANCTRL_OFFSET);
 
 	chanerr = readl(chan->reg_base + IOAT_CHANERR_OFFSET);
 	if (chanerr) {
@@ -672,9 +668,9 @@ ioat1_dma_prep_memcpy(struct dma_chan *c, dma_addr_t dma_dest,
 static void ioat1_cleanup_tasklet(unsigned long data)
 {
 	struct ioat_dma_chan *chan = (void *)data;
+
 	ioat1_cleanup(chan);
-	writew(IOAT_CHANCTRL_INT_DISABLE,
-	       chan->base.reg_base + IOAT_CHANCTRL_OFFSET);
+	writew(IOAT_CHANCTRL_RUN, chan->base.reg_base + IOAT_CHANCTRL_OFFSET);
 }
 
 static void ioat_unmap(struct pci_dev *pdev, dma_addr_t addr, size_t len,
diff --git a/drivers/dma/ioat/dma_v2.c b/drivers/dma/ioat/dma_v2.c
index 589bbc3..be617db 100644
--- a/drivers/dma/ioat/dma_v2.c
+++ b/drivers/dma/ioat/dma_v2.c
@@ -342,8 +342,7 @@ static void ioat2_cleanup_tasklet(unsigned long data)
 	struct ioat2_dma_chan *ioat = (void *) data;
 
 	ioat2_cleanup(ioat);
-	writew(IOAT_CHANCTRL_INT_DISABLE,
-	       ioat->base.reg_base + IOAT_CHANCTRL_OFFSET);
+	writew(IOAT_CHANCTRL_RUN, ioat->base.reg_base + IOAT_CHANCTRL_OFFSET);
 }
 
 /**
@@ -455,7 +454,6 @@ static int ioat2_alloc_chan_resources(struct dma_chan *c)
 	struct ioat2_dma_chan *ioat = to_ioat2_chan(c);
 	struct ioat_chan_common *chan = &ioat->base;
 	struct ioat_ring_ent **ring;
-	u16 chanctrl;
 	u32 chanerr;
 	int descs;
 	int i;
@@ -465,9 +463,7 @@ static int ioat2_alloc_chan_resources(struct dma_chan *c)
 		return 1 << ioat->alloc_order;
 
 	/* Setup register to interrupt and write completion status on error */
-	chanctrl = IOAT_CHANCTRL_ERR_INT_EN | IOAT_CHANCTRL_ANY_ERR_ABORT_EN |
-		   IOAT_CHANCTRL_ERR_COMPLETION_EN;
-	writew(chanctrl, chan->reg_base + IOAT_CHANCTRL_OFFSET);
+	writew(IOAT_CHANCTRL_RUN, chan->reg_base + IOAT_CHANCTRL_OFFSET);
 
 	chanerr = readl(chan->reg_base + IOAT_CHANERR_OFFSET);
 	if (chanerr) {
diff --git a/drivers/dma/ioat/registers.h b/drivers/dma/ioat/registers.h
index a83c733..4380f6f 100644
--- a/drivers/dma/ioat/registers.h
+++ b/drivers/dma/ioat/registers.h
@@ -75,7 +75,11 @@
 #define IOAT_CHANCTRL_ERR_INT_EN		0x0010
 #define IOAT_CHANCTRL_ANY_ERR_ABORT_EN		0x0008
 #define IOAT_CHANCTRL_ERR_COMPLETION_EN		0x0004
-#define IOAT_CHANCTRL_INT_DISABLE		0x0001
+#define IOAT_CHANCTRL_INT_REARM			0x0001
+#define IOAT_CHANCTRL_RUN			(IOAT_CHANCTRL_INT_REARM |\
+						 IOAT_CHANCTRL_ERR_COMPLETION_EN |\
+						 IOAT_CHANCTRL_ANY_ERR_ABORT_EN |\
+						 IOAT_CHANCTRL_ERR_INT_EN)
 
 #define IOAT_DMA_COMP_OFFSET			0x02	/* 16-bit DMA channel compatibility */
 #define IOAT_DMA_COMP_V1			0x0001	/* Compatibility with DMA version 1 */


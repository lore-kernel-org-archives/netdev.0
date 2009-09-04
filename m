From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 24/29] fsldma: implement a private tx_list
Date: Thu, 03 Sep 2009 19:32:32 -0700
Message-ID: <20090904023232.32667.58041.stgit@dwillia2-linux.ch.intel.com>
References: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-raid@vger.kernel.org, netdev@vger.kernel.org,
	Li Yang <leoli@freescale.com>, maciej.sosnowski@intel.com
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932813AbZIDCcg@vger.kernel.org>
In-Reply-To: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Drop fsldma's use of tx_list from struct dma_async_tx_descriptor in
preparation for removal of this field.

Cc: Li Yang <leoli@freescale.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dma/fsldma.c |    7 ++++---
 drivers/dma/fsldma.h |    1 +
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/dma/fsldma.c b/drivers/dma/fsldma.c
index f18d1bd..fb44eaa 100644
--- a/drivers/dma/fsldma.c
+++ b/drivers/dma/fsldma.c
@@ -337,7 +337,7 @@ static dma_cookie_t fsl_dma_tx_submit(struct dma_async_tx_descriptor *tx)
 
 	fsl_chan->common.cookie = cookie;
 	append_ld_queue(fsl_chan, tx_to_fsl_desc(tx));
-	list_splice_init(&tx->tx_list, fsl_chan->ld_queue.prev);
+	list_splice_init(&desc->tx_list, fsl_chan->ld_queue.prev);
 
 	spin_unlock_irqrestore(&fsl_chan->desc_lock, flags);
 
@@ -359,6 +359,7 @@ static struct fsl_desc_sw *fsl_dma_alloc_descriptor(
 	desc_sw = dma_pool_alloc(fsl_chan->desc_pool, GFP_ATOMIC, &pdesc);
 	if (desc_sw) {
 		memset(desc_sw, 0, sizeof(struct fsl_desc_sw));
+		INIT_LIST_HEAD(&desc_sw->tx_list);
 		dma_async_tx_descriptor_init(&desc_sw->async_tx,
 						&fsl_chan->common);
 		desc_sw->async_tx.tx_submit = fsl_dma_tx_submit;
@@ -448,7 +449,7 @@ fsl_dma_prep_interrupt(struct dma_chan *chan, unsigned long flags)
 	new->async_tx.flags = flags;
 
 	/* Insert the link descriptor to the LD ring */
-	list_add_tail(&new->node, &new->async_tx.tx_list);
+	list_add_tail(&new->node, &new->tx_list);
 
 	/* Set End-of-link to the last link descriptor of new list*/
 	set_ld_eol(fsl_chan, new);
@@ -506,7 +507,7 @@ static struct dma_async_tx_descriptor *fsl_dma_prep_memcpy(
 		dma_dest += copy;
 
 		/* Insert the link descriptor to the LD ring */
-		list_add_tail(&new->node, &first->async_tx.tx_list);
+		list_add_tail(&new->node, &first->tx_list);
 	} while (len);
 
 	new->async_tx.flags = flags; /* client is in control of this ack */
diff --git a/drivers/dma/fsldma.h b/drivers/dma/fsldma.h
index 4f21a51..02816e8 100644
--- a/drivers/dma/fsldma.h
+++ b/drivers/dma/fsldma.h
@@ -89,6 +89,7 @@ struct fsl_dma_ld_hw {
 struct fsl_desc_sw {
 	struct fsl_dma_ld_hw hw;
 	struct list_head node;
+	struct list_head tx_list;
 	struct dma_async_tx_descriptor async_tx;
 	struct list_head *ld;
 	void *priv;

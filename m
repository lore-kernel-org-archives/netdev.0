From: Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH 02/13] dmaengine: remove dependency on async_tx
Date: Mon, 17 Nov 2008 16:44:40 -0700
Message-ID: <1226965480.31596.16.camel@dwillia2-linux.ch.intel.com>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
	 <20081114213426.32354.75721.stgit@dwillia2-linux.ch.intel.com>
	 <20081114220214.4168ae1b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Sosnowski, Maciej" <maciej.sosnowski@intel.com>,
	"hskinnemoen@atmel.com" <hskinnemoen@atmel.com>,
	"g.liakhovetski@gmx.de" <g.liakhovetski@gmx.de>,
	"nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:6462 "EHLO mga02.intel.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751279AbYKQXom (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 18:44:42 -0500
In-Reply-To: <20081114220214.4168ae1b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the review.

On Fri, 2008-11-14 at 23:02 -0700, Andrew Morton wrote:
> > +/* dma_wait_for_async_tx - spin wait for a transcation to complete
> 
> yuo cnat sepll

Noted... and a few more:

diff --git a/drivers/dma/dmaengine.c b/drivers/dma/dmaengine.c
index dae88f2..d5d60de 100644
--- a/drivers/dma/dmaengine.c
+++ b/drivers/dma/dmaengine.c
@@ -344,9 +344,9 @@ static struct dma_chan *nth_chan(enum dma_transaction_type cap, int n)
  * dma_channel_rebalance - redistribute the available channels
  *
  * Optimize for cpu isolation (each cpu gets a dedicated channel for an
- * operation type) in the SMP case,  and opertaion isolation (avoid
- * multi-tasking channels) in the uniprocessor case.  Must be called
- * under dma_list_mutex.
+ * operation type) in the SMP case,  and operation isolation (avoid
+ * multi-tasking channels) in the non-SMP case.  Must be called under
+ * dma_list_mutex.
  */
 static void dma_channel_rebalance(void)
 {
@@ -632,7 +632,7 @@ err_out:
 EXPORT_SYMBOL(dma_async_device_register);
 
 /**
- * dma_async_device_unregister - unregisters DMA devices
+ * dma_async_device_unregister - unregister a DMA device
  * @device: &dma_device
  *
  * This routine is called by dma driver exit routines, dmaengine holds module
@@ -804,7 +804,7 @@ void dma_async_tx_descriptor_init(struct dma_async_tx_descriptor *tx,
 }
 EXPORT_SYMBOL(dma_async_tx_descriptor_init);
 
-/* dma_wait_for_async_tx - spin wait for a transcation to complete
+/* dma_wait_for_async_tx - spin wait for a transaction to complete
  * @tx: transaction to wait on
  */
 enum dma_status


> 
> > + * @tx: transaction to wait on
> > + */
> > +enum dma_status
> > +dma_wait_for_async_tx(struct dma_async_tx_descriptor *tx)
> > +{
> > +	enum dma_status status;
> > +	struct dma_async_tx_descriptor *iter;
> > +	struct dma_async_tx_descriptor *parent;
> > +
> > +	if (!tx)
> > +		return DMA_SUCCESS;
> > +
> > +	/* poll through the dependency chain, return when tx is complete */
> > +	do {
> > +		iter = tx;
> > +
> > +		/* find the root of the unsubmitted dependency chain */
> > +		do {
> > +			parent = iter->parent;
> > +			if (!parent)
> > +				break;
> > +			else
> > +				iter = parent;
> > +		} while (parent);
> > +
> > +		/* there is a small window for ->parent == NULL and
> > +		 * ->cookie == -EBUSY
> > +		 */
> > +		while (iter->cookie == -EBUSY)
> > +			cpu_relax();
> > +
> > +		status = dma_sync_wait(iter->chan, iter->cookie);
> > +	} while (status == DMA_IN_PROGRESS || (iter != tx));
> > +
> > +	return status;
> > +}
> > +EXPORT_SYMBOL_GPL(dma_wait_for_async_tx);
> 
> hm, strange.
> 
> The unlocked list walk assumes that this thread of control has
> exclusive access to *tx (somehow??), but this thread of control doesn't
> end up freeing *tx.  I guess the caller does that.

This routine was created to cover cases where the backing device driver
did not support "interrupt" descriptors for notification of operation
completion.  All drivers should be fixed up now so how about the
following:

diff --git a/drivers/dma/dmaengine.c b/drivers/dma/dmaengine.c
index d5d60de..dce6d00 100644
--- a/drivers/dma/dmaengine.c
+++ b/drivers/dma/dmaengine.c
@@ -805,7 +805,13 @@ void dma_async_tx_descriptor_init(struct dma_async_tx_descriptor *tx,
 EXPORT_SYMBOL(dma_async_tx_descriptor_init);
 
 /* dma_wait_for_async_tx - spin wait for a transaction to complete
- * @tx: transaction to wait on
+ * @tx: in-flight transaction to wait on
+ *
+ * This routine assumes that tx was obtained from a call to async_memcpy,
+ * async_xor, async_memset, etc which ensures that tx is "in-flight" (prepped
+ * and submitted).  Walking the parent chain is only meant to cover for DMA
+ * drivers that do not implement the DMA_INTERRUPT capability and may race with
+ * the driver's descriptor cleanup routine.
  */
 enum dma_status
 dma_wait_for_async_tx(struct dma_async_tx_descriptor *tx)
@@ -817,6 +823,9 @@ dma_wait_for_async_tx(struct dma_async_tx_descriptor *tx)
 	if (!tx)
 		return DMA_SUCCESS;
 
+	WARN_ONCE(tx->parent, "%s: speculatively walking dependency chain for"
+		  " %s\n", __func__, dev_name(&tx->chan->dev));
+
 	/* poll through the dependency chain, return when tx is complete */
 	do {
 		iter = tx;


Regards,
Dan


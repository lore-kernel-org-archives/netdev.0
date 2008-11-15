From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 02/13] dmaengine: remove dependency on async_tx
Date: Fri, 14 Nov 2008 22:02:14 -0800
Message-ID: <20081114220214.4168ae1b.akpm@linux-foundation.org>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
	<20081114213426.32354.75721.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	maciej.sosnowski@intel.com, hskinnemoen@atmel.com,
	g.liakhovetski@gmx.de, nicolas.ferre@atmel.com
To: Dan Williams <dan.j.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59551 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751649AbYKOGCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Nov 2008 01:02:24 -0500
In-Reply-To: <20081114213426.32354.75721.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Nov 2008 14:34:27 -0700 Dan Williams <dan.j.williams@intel.com> wrote:

> async_tx.ko is a consumer of dma channels.  A circular dependency arises
> if modules in drivers/dma rely on common code in async_tx.ko.  It
> prevents either module from being unloaded.
> 
> Move dma_wait_for_async_tx and async_tx_run_dependencies to dmaeninge.o
> where they should have been from the beginning.
> 
>
> ...
>
> --- a/drivers/dma/dmaengine.c
> +++ b/drivers/dma/dmaengine.c
> @@ -623,6 +623,81 @@ void dma_async_tx_descriptor_init(struct dma_async_tx_descriptor *tx,
>  }
>  EXPORT_SYMBOL(dma_async_tx_descriptor_init);
>  
> +/* dma_wait_for_async_tx - spin wait for a transcation to complete

yuo cnat sepll

> + * @tx: transaction to wait on
> + */
> +enum dma_status
> +dma_wait_for_async_tx(struct dma_async_tx_descriptor *tx)
> +{
> +	enum dma_status status;
> +	struct dma_async_tx_descriptor *iter;
> +	struct dma_async_tx_descriptor *parent;
> +
> +	if (!tx)
> +		return DMA_SUCCESS;
> +
> +	/* poll through the dependency chain, return when tx is complete */
> +	do {
> +		iter = tx;
> +
> +		/* find the root of the unsubmitted dependency chain */
> +		do {
> +			parent = iter->parent;
> +			if (!parent)
> +				break;
> +			else
> +				iter = parent;
> +		} while (parent);
> +
> +		/* there is a small window for ->parent == NULL and
> +		 * ->cookie == -EBUSY
> +		 */
> +		while (iter->cookie == -EBUSY)
> +			cpu_relax();
> +
> +		status = dma_sync_wait(iter->chan, iter->cookie);
> +	} while (status == DMA_IN_PROGRESS || (iter != tx));
> +
> +	return status;
> +}
> +EXPORT_SYMBOL_GPL(dma_wait_for_async_tx);

hm, strange.

The unlocked list walk assumes that this thread of control has
exclusive access to *tx (somehow??), but this thread of control doesn't
end up freeing *tx.  I guess the caller does that.

> +/* dma_run_dependencies - helper routine for dma drivers to process
> + *	(start) dependent operations on their target channel
> + * @tx: transaction with dependencies
> + */
> +void dma_run_dependencies(struct dma_async_tx_descriptor *tx)
> +{
> +	struct dma_async_tx_descriptor *dep = tx->next;
> +	struct dma_async_tx_descriptor *dep_next;
> +	struct dma_chan *chan;
> +
> +	if (!dep)
> +		return;
> +
> +	chan = dep->chan;
> +
> +	/* keep submitting up until a channel switch is detected
> +	 * in that case we will be called again as a result of
> +	 * processing the interrupt from async_tx_channel_switch
> +	 */
> +	for (; dep; dep = dep_next) {
> +		spin_lock_bh(&dep->lock);
> +		dep->parent = NULL;
> +		dep_next = dep->next;
> +		if (dep_next && dep_next->chan == chan)
> +			dep->next = NULL; /* ->next will be submitted */
> +		else
> +			dep_next = NULL; /* submit current dep and terminate */
> +		spin_unlock_bh(&dep->lock);
> +
> +		dep->tx_submit(dep);
> +	}
> +
> +	chan->device->device_issue_pending(chan);
> +}
> +EXPORT_SYMBOL_GPL(dma_run_dependencies);

Now there's a lock.



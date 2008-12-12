From: "Sosnowski, Maciej" <maciej.sosnowski@intel.com>
Subject: RE: [PATCH 07/13] dmaengine: introduce dma_request_channel and
 private	channels
Date: Fri, 12 Dec 2008 14:29:19 +0000
Message-ID: <129600E5E5FB004392DDC3FB599660D70C8F3406@irsmsx504.ger.corp.intel.com>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
 <20081114213453.32354.53002.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "hskinnemoen@atmel.com" <hskinnemoen@atmel.com>,
	"g.liakhovetski@gmx.de" <g.liakhovetski@gmx.de>,
	"nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>
To: "Williams, Dan J" <dan.j.williams@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:46018 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759012AbYLLO31 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 09:29:27 -0500
In-Reply-To: <20081114213453.32354.53002.stgit@dwillia2-linux.ch.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Williams, Dan J wrote:
> This interface is primarily for device-to-memory clients which need to
> search for dma channels with platform-specific characteristics.  The
> prototype is:
> 
> struct dma_chan *dma_request_channel(dma_cap_mask_t mask,
>                                      dma_filter_fn filter_fn,
>                                      void *filter_param);
> 
> When the optional 'filter_fn' parameter is set to NULL
> dma_request_channel simply returns the first channel that satisfies
> the 
> capability mask.  Otherwise, when the mask parameter is insufficient
> for 
> specifying the necessary channel, the filter_fn routine can be used to
> disposition the available channels in the system. The filter_fn
> routine 
> is called once for each free channel in the system.  Upon seeing a
> suitable channel filter_fn returns DMA_ACK which flags that channel to
> be the return value from dma_request_channel.  A channel allocated via
> this interface is exclusive to the caller, until dma_release_channel()
> is called.
> 
> To ensure that all channels are not consumed by the general-purpose
> allocator the DMA_PRIVATE capability is provided to exclude a
> dma_device 
> from general-purpose (memory-to-memory) consideration.
> 
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
> 
>  drivers/dma/dmaengine.c   |  161
>  ++++++++++++++++++++++++++++++++++++++++-----
>  include/linux/dmaengine.h |   16 ++++ 2 files changed, 159
> insertions(+), 18 deletions(-) 
> 
> diff --git a/drivers/dma/dmaengine.c b/drivers/dma/dmaengine.c
> index ec483cc..46fd5fa 100644
> --- a/drivers/dma/dmaengine.c
> +++ b/drivers/dma/dmaengine.c
> @@ -190,7 +190,7 @@ static int dma_chan_get(struct dma_chan *chan)
>  			chan->client_count = 0;
>  			module_put(owner);
>  			err = -ENOMEM;
> -		} else
> +		} else if (!dma_has_cap(DMA_PRIVATE, chan->device->cap_mask))
>  			balance_ref_count(chan);
>  	}
> 
> @@ -221,6 +221,8 @@ static void dma_client_chan_alloc(struct
> dma_client *client) 
> 
>  	/* Find a channel */
>  	list_for_each_entry(device, &dma_device_list, global_node) {
> +		if (dma_has_cap(DMA_PRIVATE, device->cap_mask))
> +			continue;
>  		/* Does the client require a specific DMA controller? */
>  		if (client->slave && client->slave->dma_dev
>  				&& client->slave->dma_dev != device->dev)
> @@ -313,6 +315,7 @@ static int __init dma_channel_table_init(void)
>  	 * channel_table
>  	 */
>  	clear_bit(DMA_INTERRUPT, dma_cap_mask_all.bits);
> +	clear_bit(DMA_PRIVATE, dma_cap_mask_all.bits);
>  	clear_bit(DMA_SLAVE, dma_cap_mask_all.bits);

The comment above should be updated according to this change:
-/* 'interrupt' and 'slave' are channel capabilities, but are not
+/* 'interrupt', 'private' and 'slave' are channel capabilities, but are not

> +static struct dma_chan *private_candidate(dma_cap_mask_t *mask,
> struct dma_device *dev) +{
> +	struct dma_chan *chan;
> +	struct dma_chan *ret = NULL;
> +
> +	/* devices with multiple channels need special handling as we need
> to +	 * ensure that all channels are either private or public.
> +	 */
> +	if (dev->chancnt > 1 && !dma_has_cap(DMA_PRIVATE, dev->cap_mask))
> +		list_for_each_entry(chan, &dev->channels, device_node) {
> +			/* some channels are already publicly allocated */
> +			if (chan->client_count)
> +				return NULL;
> +		}

Isn't it a dangerous approach to let clients consume for their exclusive usage channels
meant for general-purpose ("pubilc" ones)?
Why not to limit private_candidate to devices with DMA_PRIVATE capability only?

> +
> +	list_for_each_entry(chan, &dev->channels, device_node) {
> +		if (!__dma_chan_satisfies_mask(chan, mask)) {
> +			pr_debug("%s: %s wrong capabilities\n",
> +				 __func__, dev_name(&chan->dev));
> +			continue;
> +		}

As capabilities are per device, this check could be performed just once
before list_for_each_entry(chan, &dev->channels, device_node).

Regards,
Maciej
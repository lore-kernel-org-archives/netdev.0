From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Subject: Re: [PATCH 07/13] dmaengine: introduce dma_request_channel and
 private channels
Date: Tue, 2 Dec 2008 22:28:37 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0812022221180.7954@axis700.grange>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
 <20081114213453.32354.53002.stgit@dwillia2-linux.ch.intel.com>
 <Pine.LNX.4.64.0812021642120.5663@axis700.grange>
 <e9c3a7c20812020916ud0b426cvd0764f23a97973ad@mail.gmail.com>
 <Pine.LNX.4.64.0812021820560.5663@axis700.grange>
 <1228245007.8408.20.camel@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Sosnowski, Maciej" <maciej.sosnowski@intel.com>,
	"hskinnemoen@atmel.com" <hskinnemoen@atmel.com>,
	"nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>
To: Dan Williams <dan.j.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:58425 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750842AbYLBV2m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2008 16:28:42 -0500
In-Reply-To: <1228245007.8408.20.camel@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2 Dec 2008, Dan Williams wrote:

> On Tue, 2008-12-02 at 10:27 -0700, Guennadi Liakhovetski wrote:
> > Ooh... Do you really think registering 32 dma-devices is a better solution 
> > than allowing non-equal dma-channels? As I explained in the commit 
> > comment, this is a specialised Image Processing DMA Controller, and each 
> > its channel has a fixed role. So, each client has to get a specific 
> > channel.
> 
> I see your point.  Rather than doing driver gymnastics we can simply
> have dmaengine do the following (basically your patch reformatted a
> bit):

Good, so, would you commit it?

> diff --git a/drivers/dma/dmaengine.c b/drivers/dma/dmaengine.c
> index e2ccfd0..66d0ae7 100644
> --- a/drivers/dma/dmaengine.c
> +++ b/drivers/dma/dmaengine.c
> @@ -445,10 +445,10 @@ static void dma_channel_rebalance(void)
>  		}
>  }
>  
> -static struct dma_chan *private_candidate(dma_cap_mask_t *mask, struct dma_device *dev)
> +static struct dma_chan *private_candidate(dma_cap_mask_t *mask, struct dma_device *dev,
> +					  dma_filter_fn fn, void *fn_param)
>  {
>  	struct dma_chan *chan;
> -	struct dma_chan *ret = NULL;
>  
>  	/* devices with multiple channels need special handling as we need to
>  	 * ensure that all channels are either private or public.
> @@ -471,11 +471,15 @@ static struct dma_chan *private_candidate(dma_cap_mask_t *mask, struct dma_devic
>  				 __func__, dma_chan_name(chan));
>  			continue;
>  		}
> -		ret = chan;
> -		break;
> +		if (fn && !fn(chan, fn_param)) {
> +			pr_debug("%s: %s filter said false\n",
> +				 __func__, dma_chan_name(chan));
> +			continue;
> +		}
> +		return chan;
>  	}
>  
> -	return ret;
> +	return NULL;
>  }
>  
>  /**
> @@ -488,22 +492,13 @@ struct dma_chan *__dma_request_channel(dma_cap_mask_t *mask, dma_filter_fn fn, v
>  {
>  	struct dma_device *device, *_d;
>  	struct dma_chan *chan = NULL;
> -	bool ack;
>  	int err;
>  
>  	/* Find a channel */
>  	mutex_lock(&dma_list_mutex);
>  	list_for_each_entry_safe(device, _d, &dma_device_list, global_node) {
> -		chan = private_candidate(mask, device);
> -		if (!chan)
> -			continue;
> -
> -		if (fn)
> -			ack = fn(chan, fn_param);
> -		else
> -			ack = true;
> -
> -		if (ack) {
> +		chan = private_candidate(mask, device, fn, fn_param);
> +		if (chan) {
>  			/* Found a suitable channel, try to grab, prep, and
>  			 * return it.  We first set DMA_PRIVATE to disable
>  			 * balance_ref_count as this channel will not be
> @@ -521,10 +516,8 @@ struct dma_chan *__dma_request_channel(dma_cap_mask_t *mask, dma_filter_fn fn, v
>  				       dma_chan_name(chan), err);
>  			else
>  				break;
> -		} else
> -			pr_debug("%s: %s filter said false\n",
> -				 __func__, dma_chan_name(chan));
> -		chan = NULL;
> +			chan = NULL;
> +		}
>  	}
>  	mutex_unlock(&dma_list_mutex);
>  
> 
> 
> > > > Another problem I encountered with my framebuffer is the initialisation
> > > > order. You initialise dmaengine per subsys_initcall(), whereas the only
> > > > way to guarantee the order:
> > > >
> > > > dmaengine
> > > > dma-device driver
> > > > framebuffer
> > > 
> > > hmm... can the framebuffer be moved to late_initcall?
> > 
> > I assumed, that one wants to register the framebuffer as early as 
> > possible...
> 
> Yes, but I'm hesitant to escalate the initcall level.  It sounds like
> the channel(s?) for the framebuffer are an integral part of the
> framebuffer device so maybe they should not be registered separately?
> But that runs into issues if you want the channels to return to the
> general pool when the framebuffer driver is unloaded.

You mean whether it makes sense at all to manage these framebuffer 
channels outside of the framebuffer driver in a dma driver? I think yes. 
Simply because these 2 channels used by the fb share code and _registers_ 
with the rest 30 channels, which are all also quite specialised.

As for excalating the initcall level - the dmaengine init function doesn't 
do much - it just registers a device class and initialises a mutex - 
shouldn't be a problem to do it earlier?

Thanks
Guennadi
---
Guennadi Liakhovetski, Ph.D.
Freelance Open-Source Software Developer

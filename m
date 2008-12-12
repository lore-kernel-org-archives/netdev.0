From: "Sosnowski, Maciej" <maciej.sosnowski@intel.com>
Subject: RE: [PATCH 03/13] dmaengine: up-level reference counting to the
 module	level
Date: Fri, 12 Dec 2008 14:28:48 +0000
Message-ID: <129600E5E5FB004392DDC3FB599660D70C8F3405@irsmsx504.ger.corp.intel.com>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
 <20081114213432.32354.2427.stgit@dwillia2-linux.ch.intel.com>
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
Received: from mga01.intel.com ([192.55.52.88]:23947 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752494AbYLLO3S convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 09:29:18 -0500
In-Reply-To: <20081114213432.32354.2427.stgit@dwillia2-linux.ch.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Williams, Dan J wrote:
> Simply, if a client wants any dmaengine channel then prevent all
> dmaengine 
> modules from being removed.  Once the clients are done re-enable
> module 
> removal.
> 
> Why?, beyond reducing complication:
> 1/ Tracking reference counts per-transaction in an efficient manner,
>    as is currently done, requires a complicated scheme to avoid
>    cache-line bouncing effects.
> 2/ Per-transaction ref-counting gives the false impression that a
>    dma-driver can be gracefully removed ahead of its user (net, md, or
>    dma-slave)
> 3/ None of the in-tree dma-drivers talk to hot pluggable hardware, but
>    if such an engine were built one day we still would not need to
>    notify clients of remove events.  The driver can simply return
>    NULL to a ->prep() request, something that is much easier for a
> client to handle. 
> 
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---

Dan,

General concern I see about this change is that it makes impossible 
to rmmod ioatdma in case of NET_DMA enabled.
This is a specific case of situation when client is permanently registered in dmaengine,
making it impossible to rmmod any device with "public" channels.
Ioatdma is just an example here.
However in ioatdma case it would be problematic now to switch between CPU and DMA copy modes.
It seems that the only way to disable DMA after loading ioatdma would be raising tcp_dma_copybreak
to some high enough value to direct all buffers to CPU copy path.
This way is yet rather more like hacking than "normal" usage way (like "rmmod ioatdma" used so far).

Another issue I find problematic in this solution is that _any_ client 
declaring its presence in dmaengine causes holding reference for _all_ channels (and blocking them),
does not matter if they are used or not.
I agree with Guennadi's doubts here.
Why not at least hold a reference only for channels with capabilities matching client's ones?

> @@ -105,19 +106,8 @@ static ssize_t show_bytes_transferred(struct
>  device *dev, struct device_attribut static ssize_t
>  show_in_use(struct device *dev, struct device_attribute *attr, char
>  	*buf) { struct dma_chan *chan = to_dma_chan(dev);
> -	int in_use = 0;
> -
> -	if (unlikely(chan->slow_ref) &&
> -		atomic_read(&chan->refcount.refcount) > 1)
> -		in_use = 1;
> -	else {
> -		if (local_read(&(per_cpu_ptr(chan->local,
> -			get_cpu())->refcount)) > 0)
> -			in_use = 1;
> -		put_cpu();
> -	}
> 
> -	return sprintf(buf, "%d\n", in_use);
> +	return sprintf(buf, "%d\n", chan->client_count);
>  }

In this case show_in_use will not show if the channel is really in use 
but rather how many clients are present, including these with different capabilities.
Thus this number does not even show number of "potential" users of the channel...
Again, maybe it would be better to limit chan->client_count 
to number of at least potential users ( = matching capabilities)?

> 
>  	/* Find a channel */
> @@ -178,23 +228,16 @@ static void dma_client_chan_alloc(struct
>  		dma_client *client)
>		list_for_each_entry(chan, &device->channels, device_node) {
>			if (!dma_chan_satisfies_mask(chan, client->cap_mask))
>				continue;
> +			if (!chan->client_count)
> +				continue;

As cap_mask is per device not per channel, checking capabilites matching 
is not necessary to be repeated for every channel.
It would be more efficient to do it once yet before 
list_for_each_entry(chan, &device->channels, device_node).

> @@ -420,6 +443,19 @@ int dma_async_device_register(struct dma_device
>  	*device) }
> 
>  	mutex_lock(&dma_list_mutex);
> +	list_for_each_entry(chan, &device->channels, device_node) {
> +		/* if clients are already waiting for channels we need to
> +		 * take references on their behalf
> +		 */
> +		if (dmaengine_ref_count && dma_chan_get(chan) == -ENODEV) {
> +			/* note we can only get here for the first
> +			 * channel as the remaining channels are
> +			 * guaranteed to get a reference
> +			 */
> +			rc = -ENODEV;
> +			goto err_out;
> +		}
> +	}

Going through this list_for_each_entry() loop makes sense only if there are any clients,
so maybe it would be more efficient to move "if (dmaengine_ref_count)" check before 
list_for_each_entry(chan, &device->channels, device_node)?

Regards,
Maciej
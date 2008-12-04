From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Subject: Re: [PATCH 03/13] dmaengine: up-level reference counting to the
 module level
Date: Thu, 4 Dec 2008 17:56:00 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0812041746400.5079@axis700.grange>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
 <20081114213432.32354.2427.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	maciej.sosnowski@intel.com, hskinnemoen@atmel.com,
	nicolas.ferre@atmel.com
To: Dan Williams <dan.j.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:53318 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754833AbYLDQzs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Dec 2008 11:55:48 -0500
In-Reply-To: <20081114213432.32354.2427.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Nov 2008, Dan Williams wrote:

> -/**
>   * dma_async_client_register - register a &dma_client
>   * @client: ptr to a client structure with valid 'event_callback' and 'cap_mask'
>   */
>  void dma_async_client_register(struct dma_client *client)
>  {
> +	struct dma_device *device, *_d;
> +	struct dma_chan *chan;
> +	int err;
> +
>  	/* validate client data */
>  	BUG_ON(dma_has_cap(DMA_SLAVE, client->cap_mask) &&
>  		!client->slave);
>  
>  	mutex_lock(&dma_list_mutex);
> +	dmaengine_ref_count++;
> +
> +	/* try to grab channels */
> +	list_for_each_entry_safe(device, _d, &dma_device_list, global_node)
> +		list_for_each_entry(chan, &device->channels, device_node) {
> +			err = dma_chan_get(chan);

Dan, could you please explain this: dma_chan_get() takes a reference on 
the channel _and_ calls .device_alloc_chan_resources() on first invocation 
for a specific channel. I now see three locations in dmaengine.c, where 
dma_chan_get() is called: in dma_request_channel() - logical, but also in 
dmaengine_get() and dma_async_device_register(), and these latter two I 
don't understand. I do not understand why we have to grab references and 
allocate resources for all (public) channels on all controllers in the 
system if someone just called dmaengine_get()?

> @@ -420,6 +443,19 @@ int dma_async_device_register(struct dma_device *device)
>  	}
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

This is the second location - where and how are clients waiting for 
channels? In the old implementation clients had notification callbacks, 
which were called as new channels became available. Now clients are gone, 
so, what is meant here?

Confused
Guennadi
---
Guennadi Liakhovetski, Ph.D.
Freelance Open-Source Software Developer

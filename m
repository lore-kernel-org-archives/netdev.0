From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 03/13] dmaengine: up-level reference counting to the
 module level
Date: Fri, 14 Nov 2008 22:08:42 -0800
Message-ID: <20081114220842.482d56e5.akpm@linux-foundation.org>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
	<20081114213432.32354.2427.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	maciej.sosnowski@intel.com, hskinnemoen@atmel.com,
	g.liakhovetski@gmx.de, nicolas.ferre@atmel.com
To: Dan Williams <dan.j.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:47107 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752114AbYKOGIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Nov 2008 01:08:50 -0500
In-Reply-To: <20081114213432.32354.2427.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Nov 2008 14:34:32 -0700 Dan Williams <dan.j.williams@intel.com> wrote:

> Simply, if a client wants any dmaengine channel then prevent all dmaengine
> modules from being removed.  Once the clients are done re-enable module
> removal.
> 
> Why?, beyond reducing complication:
> 1/ Tracking reference counts per-transaction in an efficient manner, as
>    is currently done, requires a complicated scheme to avoid cache-line
>    bouncing effects.
> 2/ Per-transaction ref-counting gives the false impression that a
>    dma-driver can be gracefully removed ahead of its user (net, md, or
>    dma-slave)
> 3/ None of the in-tree dma-drivers talk to hot pluggable hardware, but
>    if such an engine were built one day we still would not need to notify
>    clients of remove events.  The driver can simply return NULL to a
>    ->prep() request, something that is much easier for a client to handle.
> 
> ...
>  
> +static struct module *dma_chan_to_owner(struct dma_chan *chan)
> +{
> +	return chan->device->dev->driver->owner;
> +}

Has this all been tested with CONFIG_MODULES=n?

It looks like we have a lot of unneeded code if CONFIG_MODULES=n. 
However that might not be a case which is worth bothering about.

> +/**
> + * balance_ref_count - catch up the channel reference count
> + */
> +static void balance_ref_count(struct dma_chan *chan)

Forgot to kerneldocument the argument.

> +{
> +	struct module *owner = dma_chan_to_owner(chan);
> +
> +	while (chan->client_count < dmaengine_ref_count) {
> +		__module_get(owner);
> +		chan->client_count++;
> +	}
> +}

The locking for ->client_count is undocumented.

> +/**
> + * dma_chan_get - try to grab a dma channel's parent driver module
> + * @chan - channel to grab
> + */
> +static int dma_chan_get(struct dma_chan *chan)
> +{
> +	int err = -ENODEV;
> +	struct module *owner = dma_chan_to_owner(chan);
> +
> +	if (chan->client_count) {
> +		__module_get(owner);
> +		err = 0;
> +	} else if (try_module_get(owner))
> +		err = 0;

I wonder if try_module_get() could be used in both cases (migt not make
sense to do so though).

> +	if (err == 0)
> +		chan->client_count++;

Locking for this?

> +	/* allocate upon first client reference */
> +	if (chan->client_count == 1 && err == 0) {
> +		int desc = chan->device->device_alloc_chan_resources(chan, NULL);
> +
> +		if (desc < 0) {
> +			chan->client_count = 0;
> +			module_put(owner);
> +			err = -ENOMEM;

Shouldn't we just propagate the ->device_alloc_chan_resources() return value?

> +		} else
> +			balance_ref_count(chan);
> +	}
> +
> +	return err;
> +}
> +
> +static void dma_chan_put(struct dma_chan *chan)
> +{
> +	if (!chan->client_count)
> +		return; /* this channel failed alloc_chan_resources */

Or we had a bug ;)

> +	chan->client_count--;

Undocumented locking..

>
> ...
>

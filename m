From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 1/9] [I/OAT] DMA memcpy subsystem
Date: Tue, 23 May 2006 17:51:08 -0700
Message-ID: <20060523175108.42aee1ff.akpm@osdl.org>
References: <20060524001653.19403.31396.stgit@gitlost.site>
	<20060524002012.19403.50151.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:28559 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932522AbWEXAva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 20:51:30 -0400
To: Chris Leech <christopher.leech@intel.com>
In-Reply-To: <20060524002012.19403.50151.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Leech <christopher.leech@intel.com> wrote:
>
> +/**
>  + * dma_client_chan_free - release a DMA channel
>  + * @chan: &dma_chan
>  + */
>  +void dma_chan_cleanup(struct kref *kref)
>  +{
>  +	struct dma_chan *chan = container_of(kref, struct dma_chan, refcount);
>  +	chan->device->device_free_chan_resources(chan);
>  +	chan->client = NULL;
>  +	kref_put(&chan->device->refcount, dma_async_device_cleanup);
>  +}
>  +
>  +static void dma_chan_free_rcu(struct rcu_head *rcu)
>  +{
>  +	struct dma_chan *chan = container_of(rcu, struct dma_chan, rcu);
>  +	int bias = 0x7FFFFFFF;
>  +	int i;
>  +	for_each_cpu(i)
>  +		bias -= local_read(&per_cpu_ptr(chan->local, i)->refcount);
>  +	atomic_sub(bias, &chan->refcount.refcount);
>  +	kref_put(&chan->refcount, dma_chan_cleanup);
>  +}
>  +
>  +static void dma_client_chan_free(struct dma_chan *chan)
>  +{
>  +	atomic_add(0x7FFFFFFF, &chan->refcount.refcount);
>  +	chan->slow_ref = 1;
>  +	call_rcu(&chan->rcu, dma_chan_free_rcu);
>  +}

A comment describing this `bias' magic would be nice.

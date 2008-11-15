From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 04/13] dmaengine: centralize channel allocation,
 introduce dma_find_channel
Date: Fri, 14 Nov 2008 22:14:42 -0800
Message-ID: <20081114221442.d16cdaa1.akpm@linux-foundation.org>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
	<20081114213437.32354.66972.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	maciej.sosnowski@intel.com, hskinnemoen@atmel.com,
	g.liakhovetski@gmx.de, nicolas.ferre@atmel.com
To: Dan Williams <dan.j.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36329 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752101AbYKOGOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Nov 2008 01:14:51 -0500
In-Reply-To: <20081114213437.32354.66972.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Nov 2008 14:34:37 -0700 Dan Williams <dan.j.williams@intel.com> wrote:

> Allowing multiple clients to each define their own channel allocation
> scheme quickly leads to a pathological situation.  For memory-to-memory
> offload all clients can share a central allocator.
> 
> This simply moves the existing async_tx allocator to dmaengine with
> minimal fixups:
> * async_tx.c:get_chan_ref_by_cap --> dmaengine.c:nth_chan
> * async_tx.c:async_tx_rebalance --> dmaengine.c:dma_channel_rebalance
> * split out common code from async_tx.c:__async_tx_find_channel -->
>   dma_find_channel
> 
>  /**
> + * dma_cap_mask_all - enable iteration over all operation types
> + */
> +static dma_cap_mask_t dma_cap_mask_all;
> +
> +/**
> + * dma_chan_tbl_ent - tracks channel allocations per core/opertion
> + */

Would be conventional to document the fields as well.

> +struct dma_chan_tbl_ent {
> +	struct dma_chan *chan;
> +};
> +
> +/**
> + * channel_table - percpu lookup table for memory-to-memory offload providers
> + */
> +static struct dma_chan_tbl_ent *channel_table[DMA_TX_TYPE_END];
> +
> +static int __init dma_channel_table_init(void)
> +{
> +	enum dma_transaction_type cap;
> +	int err = 0;
> +
> +	bitmap_fill(dma_cap_mask_all.bits, DMA_TX_TYPE_END);
> +
> +	/* 'interrupt' and 'slave' are channel capabilities, but are not
> +	 * associated with an operation so they do not need an entry in the
> +	 * channel_table
> +	 */
> +	clear_bit(DMA_INTERRUPT, dma_cap_mask_all.bits);
> +	clear_bit(DMA_SLAVE, dma_cap_mask_all.bits);
> +
> +	for_each_dma_cap_mask(cap, dma_cap_mask_all) {
> +		channel_table[cap] = alloc_percpu(struct dma_chan_tbl_ent);
> +		if (!channel_table[cap]) {
> +			err = 1;

initcalls can return -ve errnos, and that at least would make the
message in do_one_initcall() more meaningful.

> +			break;
> +		}
> +	}
> +
> +	if (err) {
> +		pr_err("dmaengine: initialization failure\n");
> +		for_each_dma_cap_mask(cap, dma_cap_mask_all)
> +			if (channel_table[cap])
> +				free_percpu(channel_table[cap]);
> +	}
> +
> +	return err;
> +}
> +subsys_initcall(dma_channel_table_init);
> +
> +/**
> + * dma_find_channel - find a channel to carry out the operation
> + * @tx_type: transaction type
> + */
> +struct dma_chan *dma_find_channel(enum dma_transaction_type tx_type)
> +{
> +	struct dma_chan *chan;
> +	int cpu;
> +
> +	WARN_ONCE(dmaengine_ref_count == 0,
> +		  "client called %s without a reference", __func__);
> +
> +	cpu = get_cpu();
> +	chan = per_cpu_ptr(channel_table[tx_type], cpu)->chan;
> +	put_cpu();
> +
> +	return chan;
> +}
> +EXPORT_SYMBOL(dma_find_channel);

Strange.  We return the address of a per-cpu variable, but we've
reenabled preemption so this thread can now switch CPUs.  Hence there
must be spinlocking on *chan as well?

> +/**
> + * nth_chan - returns the nth channel of the given capability
> + * @cap: capability to match
> + * @n: nth channel desired
> + *
> + * Defaults to returning the channel with the desired capability and the
> + * lowest reference count when 'n' cannot be satisfied
> + */
> +static struct dma_chan *nth_chan(enum dma_transaction_type cap, int n)
> +{
> +	struct dma_device *device;
> +	struct dma_chan *chan;
> +	struct dma_chan *ret = NULL;
> +	struct dma_chan *min = NULL;
> +
> +	list_for_each_entry(device, &dma_device_list, global_node) {
> +		if (!dma_has_cap(cap, device->cap_mask))
> +			continue;
> +		list_for_each_entry(chan, &device->channels, device_node) {
> +			if (!chan->client_count)
> +				continue;
> +			if (!min)
> +				min = chan;
> +			else if (chan->table_count < min->table_count)
> +				min = chan;
> +
> +			if (n-- == 0) {
> +				ret = chan;
> +				break; /* done */
> +			}
> +		}
> +		if (ret)
> +			break; /* done */
> +	}
> +
> +	if (!ret)
> +		ret = min;
> +
> +	if (ret)
> +		ret->table_count++;

Undocumented locking for ->table_count.

> +	return ret;
> +}
> +
> +/**
> + * dma_channel_rebalance - redistribute the available channels
> + *
> + * Optimize for cpu isolation (each cpu gets a dedicated channel for an
> + * operation type) in the SMP case,  and opertaion isolation (avoid
> + * multi-tasking channels) in the uniprocessor case.  Must be called
> + * under dma_list_mutex.
> + */
> +static void dma_channel_rebalance(void)
> +{
> +	struct dma_chan *chan;
> +	struct dma_device *device;
> +	int cpu;
> +	int cap;
> +	int n;
> +
> +	/* undo the last distribution */
> +	for_each_dma_cap_mask(cap, dma_cap_mask_all)
> +		for_each_possible_cpu(cpu)
> +			per_cpu_ptr(channel_table[cap], cpu)->chan = NULL;

The number of possible cpus can be larger than the number of online
CPUs.  Is it worth making this code hotplug-aware?

> +	list_for_each_entry(device, &dma_device_list, global_node)
> +		list_for_each_entry(chan, &device->channels, device_node)
> +			chan->table_count = 0;
> +
> +	/* don't populate the channel_table if no clients are available */
> +	if (!dmaengine_ref_count)
> +		return;
> +
> +	/* redistribute available channels */
> +	n = 0;
> +	for_each_dma_cap_mask(cap, dma_cap_mask_all)
> +		for_each_online_cpu(cpu) {
> +			if (num_possible_cpus() > 1)
> +				chan = nth_chan(cap, n++);
> +			else
> +				chan = nth_chan(cap, -1);
> +
> +			per_cpu_ptr(channel_table[cap], cpu)->chan = chan;
> +		}
> +}
> +
>
> ...
>

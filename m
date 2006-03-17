From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 1/8] [I/OAT] DMA memcpy subsystem
Date: Fri, 17 Mar 2006 01:30:19 -0600
Message-ID: <2FF801BB-F96C-4864-AC44-09B4B92531F7@kernel.crashing.org>
References: <20060311022759.3950.58788.stgit@gitlost.site> <20060311022919.3950.43835.stgit@gitlost.site>
Mime-Version: 1.0 (Apple Message framework v746.3)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux kernel mailing list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964838AbWCQH3m@vger.kernel.org>
In-Reply-To: <20060311022919.3950.43835.stgit@gitlost.site>
To: Chris Leech <christopher.leech@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[snip]

> +/**
> + * dma_async_client_register - allocate and register a &dma_client
> + * @event_callback: callback for notification of channel addition/ 
> removal
> + */
> +struct dma_client *dma_async_client_register(dma_event_callback  
> event_callback)
> +{
> +	struct dma_client *client;
> +
> +	client = kzalloc(sizeof(*client), GFP_KERNEL);
> +	if (!client)
> +		return NULL;
> +
> +	INIT_LIST_HEAD(&client->channels);
> +	spin_lock_init(&client->lock);
> +
> +	client->chans_desired = 0;
> +	client->chan_count = 0;
> +	client->event_callback = event_callback;
> +
> +	spin_lock(&dma_list_lock);
> +	list_add_tail(&client->global_node, &dma_client_list);
> +	spin_unlock(&dma_list_lock);
> +
> +	return client;
> +}

It would seem that when a client registers (or shortly there after  
when they call dma_async_client_chan_request()) they would expect to  
get the number of channels they need by some given time period.

For example, lets say a client registers but no dma device exists.   
They will never get called to be aware of this condition.

I would think most clients would either spin until they have all the  
channels they need or fall back to a non-async mechanism.

Also, what do you think about adding an operation type (MEMCPY, XOR,  
CRYPTO_AES, etc).  We can than validate if the operation type  
expected is supported by the devices that exist.

> +
> +/**
> + * dma_async_client_unregister - unregister a client and free the  
> &dma_client
> + * @client:
> + *
> + * Force frees any allocated DMA channels, frees the &dma_client  
> memory
> + */
> +void dma_async_client_unregister(struct dma_client *client)
> +{
> +	struct dma_chan *chan;
> +
> +	if (!client)
> +		return;
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(chan, &client->channels, client_node) {
> +		dma_client_chan_free(chan);
> +	}
> +	rcu_read_unlock();
> +
> +	spin_lock(&dma_list_lock);
> +	list_del(&client->global_node);
> +	spin_unlock(&dma_list_lock);
> +
> +	kfree(client);
> +	dma_chans_rebalance();
> +}
> +
> +/**
> + * dma_async_client_chan_request - request DMA channels
> + * @client: &dma_client
> + * @number: count of DMA channels requested
> + *
> + * Clients call dma_async_client_chan_request() to specify how many
> + * DMA channels they need, 0 to free all currently allocated.
> + * The resulting allocations/frees are indicated to the client via  
> the
> + * event callback.
> + */
> +void dma_async_client_chan_request(struct dma_client *client,
> +			unsigned int number)
> +{
> +	client->chans_desired = number;
> +	dma_chans_rebalance();
> +}
> +

Shouldn't we also have a dma_async_client_chan_free()?

[snip]

> +/* --- public DMA engine API --- */
> +
> +struct dma_client *dma_async_client_register(dma_event_callback  
> event_callback);
> +void dma_async_client_unregister(struct dma_client *client);
> +void dma_async_client_chan_request(struct dma_client *client,
> +		unsigned int number);
> +
> +/**
> + * dma_async_memcpy_buf_to_buf - offloaded copy between virtual  
> addresses
> + * @chan: DMA channel to offload copy to
> + * @dest: destination address (virtual)
> + * @src: source address (virtual)
> + * @len: length
> + *
> + * Both @dest and @src must be mappable to a bus address according  
> to the
> + * DMA mapping API rules for streaming mappings.
> + * Both @dest and @src must stay memory resident (kernel memory or  
> locked
> + * user space pages)
> + */
> +static inline dma_cookie_t dma_async_memcpy_buf_to_buf(struct  
> dma_chan *chan,
> +	void *dest, void *src, size_t len)
> +{
> +	int cpu = get_cpu();
> +	per_cpu_ptr(chan->local, cpu)->bytes_transferred += len;
> +	per_cpu_ptr(chan->local, cpu)->memcpy_count++;
> +	put_cpu();
> +
> +	return chan->device->device_memcpy_buf_to_buf(chan, dest, src, len);
> +}

What about renaming the dma_async_memcpy_* to something like  
dma_async_op_* and have them take an additional operation argument.

> +
> +/**
> + * dma_async_memcpy_buf_to_pg - offloaded copy
> + * @chan: DMA channel to offload copy to
> + * @page: destination page
> + * @offset: offset in page to copy to
> + * @kdata: source address (virtual)
> + * @len: length
> + *
> + * Both @page/@offset and @kdata must be mappable to a bus address  
> according
> + * to the DMA mapping API rules for streaming mappings.
> + * Both @page/@offset and @kdata must stay memory resident (kernel  
> memory or
> + * locked user space pages)
> + */
> +static inline dma_cookie_t dma_async_memcpy_buf_to_pg(struct  
> dma_chan *chan,
> +	struct page *page, unsigned int offset, void *kdata, size_t len)
> +{
> +	int cpu = get_cpu();
> +	per_cpu_ptr(chan->local, cpu)->bytes_transferred += len;
> +	per_cpu_ptr(chan->local, cpu)->memcpy_count++;
> +	put_cpu();
> +
> +	return chan->device->device_memcpy_buf_to_pg(chan, page, offset,
> +	                                             kdata, len);
> +}
> +
> +/**
> + * dma_async_memcpy_buf_to_pg - offloaded copy
> + * @chan: DMA channel to offload copy to
> + * @dest_page: destination page
> + * @dest_off: offset in page to copy to
> + * @src_page: source page
> + * @src_off: offset in page to copy from
> + * @len: length
> + *
> + * Both @dest_page/@dest_off and @src_page/@src_off must be  
> mappable to a bus
> + * address according to the DMA mapping API rules for streaming  
> mappings.
> + * Both @dest_page/@dest_off and @src_page/@src_off must stay  
> memory resident
> + * (kernel memory or locked user space pages)
> + */
> +static inline dma_cookie_t dma_async_memcpy_pg_to_pg(struct  
> dma_chan *chan,
> +	struct page *dest_pg, unsigned int dest_off, struct page *src_pg,
> +	unsigned int src_off, size_t len)
> +{
> +	int cpu = get_cpu();
> +	per_cpu_ptr(chan->local, cpu)->bytes_transferred += len;
> +	per_cpu_ptr(chan->local, cpu)->memcpy_count++;
> +	put_cpu();
> +
> +	return chan->device->device_memcpy_pg_to_pg(chan, dest_pg, dest_off,
> +	                                            src_pg, src_off, len);
> +}
> +
> +/**
> + * dma_async_memcpy_issue_pending - flush pending copies to HW
> + * @chan:
> + *
> + * This allows drivers to push copies to HW in batches,
> + * reducing MMIO writes where possible.
> + */
> +static inline void dma_async_memcpy_issue_pending(struct dma_chan  
> *chan)
> +{
> +	return chan->device->device_memcpy_issue_pending(chan);
> +}
> +
> +/**
> + * dma_async_memcpy_complete - poll for transaction completion
> + * @chan: DMA channel
> + * @cookie: transaction identifier to check status of
> + * @last: returns last completed cookie, can be NULL
> + * @used: returns last issued cookie, can be NULL
> + *
> + * If @last and @used are passed in, upon return they reflect the  
> driver
> + * internal state and can be used with dma_async_is_complete() to  
> check
> + * the status of multiple cookies without re-checking hardware state.
> + */
> +static inline enum dma_status dma_async_memcpy_complete(struct  
> dma_chan *chan,
> +	dma_cookie_t cookie, dma_cookie_t *last, dma_cookie_t *used)
> +{
> +	return chan->device->device_memcpy_complete(chan, cookie, last,  
> used);
> +}
> +
> +/**
> + * dma_async_is_complete - test a cookie against chan state
> + * @cookie: transaction identifier to test status of
> + * @last_complete: last know completed transaction
> + * @last_used: last cookie value handed out
> + *
> + * dma_async_is_complete() is used in dma_async_memcpy_complete()
> + * the test logic is seperated for lightweight testing of multiple  
> cookies
> + */
> +static inline enum dma_status dma_async_is_complete(dma_cookie_t  
> cookie,
> +			dma_cookie_t last_complete, dma_cookie_t last_used)
> +{
> +	if (last_complete <= last_used) {
> +		if ((cookie <= last_complete) || (cookie > last_used))
> +			return DMA_SUCCESS;
> +	} else {
> +		if ((cookie <= last_complete) && (cookie > last_used))
> +			return DMA_SUCCESS;
> +	}
> +	return DMA_IN_PROGRESS;
> +}
> +
> +
> +/* --- DMA device --- */
> +
> +int dma_async_device_register(struct dma_device *device);
> +void dma_async_device_unregister(struct dma_device *device);
> +
> +#endif /* CONFIG_DMA_ENGINE */
> +#endif /* DMAENGINE_H */
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

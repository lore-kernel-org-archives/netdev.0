From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v3 3/6] virtio_net: Add XDP support
Date: Wed, 30 Nov 2016 20:24:44 -0800
Message-ID: <583FA60C.4030800@gmail.com>
References: <20161129200933.26851.41883.stgit@john-Precision-Tower-5810>
 <20161129201021.26851.34352.stgit@john-Precision-Tower-5810>
 <20161130203851-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, daniel@iogearbox.net,
        shm@cumulusnetworks.com, davem@davemloft.net, tgraf@suug.ch,
        alexei.starovoitov@gmail.com, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, bblanco@plumgrid.com, brouer@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34186 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753741AbcLAEZG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 23:25:06 -0500
Received: by mail-pg0-f65.google.com with SMTP id e9so3297658pgc.1
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 20:25:06 -0800 (PST)
In-Reply-To: <20161130203851-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-30 10:54 AM, Michael S. Tsirkin wrote:
> On Tue, Nov 29, 2016 at 12:10:21PM -0800, John Fastabend wrote:
>> From: John Fastabend <john.fastabend@gmail.com>
>>
>> This adds XDP support to virtio_net. Some requirements must be
>> met for XDP to be enabled depending on the mode. First it will
>> only be supported with LRO disabled so that data is not pushed
>> across multiple buffers. Second the MTU must be less than a page
>> size to avoid having to handle XDP across multiple pages.
>>
>> If mergeable receive is enabled this patch only supports the case
>> where header and data are in the same buf which we can check when
>> a packet is received by looking at num_buf. If the num_buf is
>> greater than 1 and a XDP program is loaded the packet is dropped
>> and a warning is thrown. When any_header_sg is set this does not
>> happen and both header and data is put in a single buffer as expected
>> so we check this when XDP programs are loaded.  Subsequent patches
>> will process the packet in a degraded mode to ensure connectivity
>> and correctness is not lost even if backend pushes packets into
>> multiple buffers.
>>
>> If big packets mode is enabled and MTU/LRO conditions above are
>> met then XDP is allowed.
>>
>> This patch was tested with qemu with vhost=on and vhost=off where
>> mergable and big_packet modes were forced via hard coding feature
>> negotiation. Multiple buffers per packet was forced via a small
>> test patch to vhost.c in the vhost=on qemu mode.
>>
>> Suggested-by: Shrijeet Mukherjee <shrijeet@gmail.com>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---

[...]

>>  
>> +static u32 do_xdp_prog(struct virtnet_info *vi,
>> +		       struct bpf_prog *xdp_prog,
>> +		       struct page *page, int offset, int len)
>> +{
>> +	int hdr_padded_len;
>> +	struct xdp_buff xdp;
>> +	u32 act;
>> +	u8 *buf;
>> +
>> +	buf = page_address(page) + offset;
>> +
>> +	if (vi->mergeable_rx_bufs)
>> +		hdr_padded_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
>> +	else
>> +		hdr_padded_len = sizeof(struct padded_vnet_hdr);
>> +
>> +	xdp.data = buf + hdr_padded_len;
>> +	xdp.data_end = xdp.data + (len - vi->hdr_len);
> 
> so header seems to be ignored completely.
> but the packet could be from the time when
> e.g. checksum offloading was on, and
> so it might gave DATA_VALID (from CHECKSUM_UNNECESSARY
> in host).
> 
> I think you want to verify that flags and gso type
> are 0.

Ah yes agree. I think this might be possible in all the driver
implementations as well I wonder if there are bugs there as well.
The race between setting MTU, LRO, etc. and pushing the XDP prog
into the datapath seems unlikely but possible.

> 
> 
>> +
>> +	act = bpf_prog_run_xdp(xdp_prog, &xdp);
>> +	switch (act) {
>> +	case XDP_PASS:
>> +		return XDP_PASS;
>> +	default:
>> +		bpf_warn_invalid_xdp_action(act);
>> +	case XDP_TX:
>> +	case XDP_ABORTED:
>> +	case XDP_DROP:
>> +		return XDP_DROP;
>> +	}
>> +}
> 
> do we really want this switch just to warn?
> How about doing != XDP_PASS in the caller?

Well in later patches XDP_TX case gets handled. So its really
three cases, PASS, XDP_TX, {default|ABORT|DROP}. I don't have
a strong preference if its case statement or if/else it should
not matter except for style.

> 
>> +
>>  static struct sk_buff *receive_small(struct virtnet_info *vi, void *buf, unsigned int len)
>>  {
>>  	struct sk_buff * skb = buf;
>> @@ -340,14 +375,28 @@ static struct sk_buff *receive_big(struct net_device *dev,
>>  				   void *buf,
>>  				   unsigned int len)
>>  {
>> +	struct bpf_prog *xdp_prog;
>>  	struct page *page = buf;
>> -	struct sk_buff *skb = page_to_skb(vi, rq, page, 0, len, PAGE_SIZE);
>> +	struct sk_buff *skb;
>>  
>> +	rcu_read_lock();
>> +	xdp_prog = rcu_dereference(rq->xdp_prog);
>> +	if (xdp_prog) {
>> +		u32 act = do_xdp_prog(vi, xdp_prog, page, 0, len);
>> +
>> +		if (act == XDP_DROP)
>> +			goto err_xdp;
>> +	}
>> +	rcu_read_unlock();
>> +
>> +	skb = page_to_skb(vi, rq, page, 0, len, PAGE_SIZE);
>>  	if (unlikely(!skb))
>>  		goto err;
>>  
>>  	return skb;
>>  
>> +err_xdp:
>> +	rcu_read_unlock();
>>  err:
>>  	dev->stats.rx_dropped++;
>>  	give_pages(rq, page);
>> @@ -366,10 +415,27 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
>>  	struct page *page = virt_to_head_page(buf);
>>  	int offset = buf - page_address(page);
>>  	unsigned int truesize = max(len, mergeable_ctx_to_buf_truesize(ctx));
> 
> This is some useless computation when XDP is used, isn't it?
> 

Seems to be nice catch.

>> +	struct sk_buff *head_skb, *curr_skb;
>> +	struct bpf_prog *xdp_prog;
>>  
>> -	struct sk_buff *head_skb = page_to_skb(vi, rq, page, offset, len,
>> -					       truesize);
>> -	struct sk_buff *curr_skb = head_skb;
>> +	rcu_read_lock();
>> +	xdp_prog = rcu_dereference(rq->xdp_prog);
>> +	if (xdp_prog) {
>> +		u32 act;
>> +
>> +		if (num_buf > 1) {
>> +			bpf_warn_invalid_xdp_buffer();
>> +			goto err_xdp;
>> +		}
>> +
>> +		act = do_xdp_prog(vi, xdp_prog, page, offset, len);
>> +		if (act == XDP_DROP)
>> +			goto err_xdp;
>> +	}
>> +	rcu_read_unlock();
>> +
>> +	head_skb = page_to_skb(vi, rq, page, offset, len, truesize);
>> +	curr_skb = head_skb;
>>  
>>  	if (unlikely(!curr_skb))
>>  		goto err_skb;
> 
> I'm confused. Did the requirement to have a page per packet go away?
> I don't think this mode is doing it here.
> 

Correct its not a page per packet but there seems no reason to enforce
that here. XDP works just fine without contiguous buffers. I believe
the page per packet argument came out of the mlx driver implementation.

iirc DaveM had the most push back on the multiple packets per page
thing. Maybe he can comment again. (sorry Dave I'm dragging this up again).

> 
>> @@ -423,6 +489,8 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
>>  	ewma_pkt_len_add(&rq->mrg_avg_pkt_len, head_skb->len);
>>  	return head_skb;
>>  
>> +err_xdp:
>> +	rcu_read_unlock();
>>  err_skb:
>>  	put_page(page);
>>  	while (--num_buf) {
>> @@ -1328,6 +1396,13 @@ static int virtnet_set_channels(struct net_device *dev,
>>  	if (queue_pairs > vi->max_queue_pairs || queue_pairs == 0)
>>  		return -EINVAL;
>>  
>> +	/* For now we don't support modifying channels while XDP is loaded
>> +	 * also when XDP is loaded all RX queues have XDP programs so we only
>> +	 * need to check a single RX queue.
>> +	 */
>> +	if (vi->rq[0].xdp_prog)
>> +		return -EINVAL;
>> +
>>  	get_online_cpus();
>>  	err = virtnet_set_queues(vi, queue_pairs);
>>  	if (!err) {
>> @@ -1454,6 +1529,68 @@ static int virtnet_set_features(struct net_device *netdev,
>>  	return 0;
>>  }
>>  
>> +static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
>> +{
>> +	struct virtnet_info *vi = netdev_priv(dev);
>> +	struct bpf_prog *old_prog;
>> +	int i;
>> +
>> +	if ((dev->features & NETIF_F_LRO) && prog) {
>> +		netdev_warn(dev, "can't set XDP while LRO is on, disable LRO first\n");
>> +		return -EINVAL;
>> +	}
>> +
>> +	if (vi->mergeable_rx_bufs && !vi->any_header_sg) {
>> +		netdev_warn(dev, "XDP expects header/data in single page\n");
>> +		return -EINVAL;
>> +	}
>> +
>> +	if (dev->mtu > PAGE_SIZE) {
>> +		netdev_warn(dev, "XDP requires MTU less than %lu\n", PAGE_SIZE);
>> +		return -EINVAL;
>> +	}
>> +
>> +	if (prog) {
>> +		prog = bpf_prog_add(prog, vi->max_queue_pairs - 1);
>> +		if (IS_ERR(prog))
>> +			return PTR_ERR(prog);
>> +	}
>> +
>> +	for (i = 0; i < vi->max_queue_pairs; i++) {
>> +		old_prog = rtnl_dereference(vi->rq[i].xdp_prog);
>> +		rcu_assign_pointer(vi->rq[i].xdp_prog, prog);
>> +		if (old_prog)
>> +			bpf_prog_put(old_prog);
> 
> don't we need to sync before put?
> 

No should be handled by core infrastructure in bpf_prog_put(). Also this
aligns with other driver implementations.

> 
>> +	}
>> +
>> +	return 0;
>> +}
>> +

Thanks,
John

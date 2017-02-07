From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next PATCH v2 5/5] virtio_net: XDP support for adjust_head
Date: Tue, 7 Feb 2017 10:23:23 +0800
Message-ID: <abeb882e-0b44-12d6-d30d-d037c0813941@redhat.com>
References: <20170203031251.23054.25387.stgit@john-Precision-Tower-5810>
 <20170203031629.23054.25622.stgit@john-Precision-Tower-5810>
 <993d31de-57d9-fb7f-568e-c18fc9fadbc6@redhat.com>
 <5898CEB7.1020509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>, kubakici@wp.pl,
        ast@fb.com, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47560 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752565AbdBGCX3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Feb 2017 21:23:29 -0500
In-Reply-To: <5898CEB7.1020509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年02月07日 03:29, John Fastabend wrote:
> On 17-02-05 11:08 PM, Jason Wang wrote:
>>
>> On 2017年02月03日 11:16, John Fastabend wrote:
>>> Add support for XDP adjust head by allocating a 256B header region
>>> that XDP programs can grow into. This is only enabled when a XDP
>>> program is loaded.
>>>
>>> In order to ensure that we do not have to unwind queue headroom push
>>> queue setup below bpf_prog_add. It reads better to do a prog ref
>>> unwind vs another queue setup call.
>>>
>>> At the moment this code must do a full reset to ensure old buffers
>>> without headroom on program add or with headroom on program removal
>>> are not used incorrectly in the datapath. Ideally we would only
>>> have to disable/enable the RX queues being updated but there is no
>>> API to do this at the moment in virtio so use the big hammer. In
>>> practice it is likely not that big of a problem as this will only
>>> happen when XDP is enabled/disabled changing programs does not
>>> require the reset. There is some risk that the driver may either
>>> have an allocation failure or for some reason fail to correctly
>>> negotiate with the underlying backend in this case the driver will
>>> be left uninitialized. I have not seen this ever happen on my test
>>> systems and for what its worth this same failure case can occur
>>> from probe and other contexts in virtio framework.
>>>
>>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>>> ---
>
> [...]
>
>>> @@ -412,7 +418,6 @@ static struct sk_buff *receive_small(struct net_device *dev,
>>>        struct bpf_prog *xdp_prog;
>>>          len -= vi->hdr_len;
>>> -    skb_trim(skb, len);
>>>          rcu_read_lock();
>>>        xdp_prog = rcu_dereference(rq->xdp_prog);
>>> @@ -424,12 +429,16 @@ static struct sk_buff *receive_small(struct net_device
>>> *dev,
>>>            if (unlikely(hdr->hdr.gso_type || hdr->hdr.flags))
>>>                goto err_xdp;
>>>    -        xdp.data = skb->data;
>>> +        xdp.data_hard_start = skb->data;
>>> +        xdp.data = skb->data + VIRTIO_XDP_HEADROOM;
>>>            xdp.data_end = xdp.data + len;
>>>            act = bpf_prog_run_xdp(xdp_prog, &xdp);
>>>              switch (act) {
>>>            case XDP_PASS:
>>> +            /* Recalculate length in case bpf program changed it */
>>> +            __skb_pull(skb, xdp.data - xdp.data_hard_start);
>> But skb->len were trimmed to len below which seems wrong.
> I believe this is correct and it passes my basic iperf/ping tests.
>
> When we are using small buffers with XDP, skb->data is pointing to the front
> of the buffer. This space includes the XDP headroom. When we pass the skb up
> to the stack we need to pull this off and point to the start of the data. But
> there still is likely a bunch of room at the end of the buffer assuming the
> packet is smaller than the buffer side.
>
>>> +            len = xdp.data_end - xdp.data;
>>>                break;
>>>            case XDP_TX:
>>>                if (unlikely(!virtnet_xdp_xmit(vi, rq, &xdp, skb)))
>>> @@ -446,6 +455,7 @@ static struct sk_buff *receive_small(struct net_device *dev,
>>>        }
>>>        rcu_read_unlock();
>>>    +    skb_trim(skb, len);
> So here we trim the packet to set the length to the actual payload size. The
> 'len' parameter passed into receive_small does not include the headroom so this
> gives us the correct length of the payload.
>
> Make sense?

Yes, you are right.

>
>>>        return skb;
>>>      err_xdp:
> [...]
>
>>> @@ -569,7 +580,7 @@ static struct sk_buff *receive_mergeable(struct net_device
>>> *dev,
>>>                                  page, offset, &len);
>>>                if (!xdp_page)
>>>                    goto err_xdp;
>>> -            offset = 0;
>>> +            offset = VIRTIO_XDP_HEADROOM;
>>>            } else {
>>>                xdp_page = page;
>>>            }
>>> @@ -582,19 +593,30 @@ static struct sk_buff *receive_mergeable(struct
>>> net_device *dev,
>>>            if (unlikely(hdr->hdr.gso_type))
>>>                goto err_xdp;
>>>    +        /* Allow consuming headroom but reserve enough space to push
>>> +         * the descriptor on if we get an XDP_TX return code.
>>> +         */
>>>            data = page_address(xdp_page) + offset;
>>> +        xdp.data_hard_start = data - VIRTIO_XDP_HEADROOM + vi->hdr_len;
>> Should be data - VIRTIO_XDP_HEADROOM I think?
>>
> If the XDP program does an adjust_head() and then a XDP_TX I want to ensure
> we reserve enough headroom to push the header onto the buffer when the packet
> is sent. So the additional hdr_len reserve here is intentional. Otherwise we
> would need to detect this and do some type of linearize action.

I get the point.

>
>>>            xdp.data = data + vi->hdr_len;
>>>            xdp.data_end = xdp.data + (len - vi->hdr_len);
>>>            act = bpf_prog_run_xdp(xdp_prog, &xdp);
>>>              switch (act) {
>>>            case XDP_PASS:
>>> +            /* recalculate offset to account for any header
>>> +             * adjustments. Note other cases do not build an
>>> +             * skb and avoid using offset
>>> +             */
>>> +            offset = xdp.data -
>>> +                    page_address(xdp_page) - vi->hdr_len;
>>> +
>>>                /* We can only create skb based on xdp_page. */
>>>                if (unlikely(xdp_page != page)) {
>>>                    rcu_read_unlock();
>>>                    put_page(page);
>>>                    head_skb = page_to_skb(vi, rq, xdp_page,
>>> -                               0, len, PAGE_SIZE);
>>> +                               offset, len, PAGE_SIZE);
>>>                    ewma_pkt_len_add(&rq->mrg_avg_pkt_len, len);
>>>                    return head_skb;
> [...]
>
>>>    -static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
>>> +static int add_recvbuf_mergeable(struct virtnet_info *vi,
>>> +                 struct receive_queue *rq, gfp_t gfp)
>>>    {
>>>        struct page_frag *alloc_frag = &rq->alloc_frag;
>>> +    unsigned int headroom = virtnet_get_headroom(vi);
>>>        char *buf;
>>>        unsigned long ctx;
>>>        int err;
>>>        unsigned int len, hole;
>>>          len = get_mergeable_buf_len(&rq->mrg_avg_pkt_len);
>>> -    if (unlikely(!skb_page_frag_refill(len, alloc_frag, gfp)))
>>> +    if (unlikely(!skb_page_frag_refill(len + headroom, alloc_frag, gfp)))
>>>            return -ENOMEM;
>>>          buf = (char *)page_address(alloc_frag->page) + alloc_frag->offset;
>>> +    buf += headroom; /* advance address leaving hole at front of pkt */
>> Note: the headroom will reduce the possibility of frag coalescing which may
>> damage the performance more or less.
>>
>> [...]
> Right there are a few other performance optimizations I am looking at in
> virtio as well but these should go in as follow on series.
>
> Specifically, I'm looking at recycling buffers to see what sort of performance
> increase we can get out of that. Many of the hardware drivers do this and see
> a performance boost from it. However dynamic buffer sizes like this make it a
> bit challenging.
>
> .John

Right.

Acked-by: Jason Wang <jasowang@redhat.com>

Thanks

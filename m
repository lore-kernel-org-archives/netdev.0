From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v5 5/6] virtio_net: add XDP_TX support
Date: Thu, 8 Dec 2016 10:18:22 -0800
Message-ID: <5849A3EE.7090603@gmail.com>
References: <20161207200139.28121.4811.stgit@john-Precision-Tower-5810>
 <20161207201245.28121.95418.stgit@john-Precision-Tower-5810>
 <20161208080647-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, shm@cumulusnetworks.com, davem@davemloft.net,
        tgraf@suug.ch, alexei.starovoitov@gmail.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        brouer@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33588 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751685AbcLHSSj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 13:18:39 -0500
Received: by mail-pf0-f194.google.com with SMTP id 144so22693106pfv.0
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 10:18:39 -0800 (PST)
In-Reply-To: <20161208080647-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-12-07 10:11 PM, Michael S. Tsirkin wrote:
> On Wed, Dec 07, 2016 at 12:12:45PM -0800, John Fastabend wrote:
>> This adds support for the XDP_TX action to virtio_net. When an XDP
>> program is run and returns the XDP_TX action the virtio_net XDP
>> implementation will transmit the packet on a TX queue that aligns
>> with the current CPU that the XDP packet was processed on.
>>
>> Before sending the packet the header is zeroed.  Also XDP is expected
>> to handle checksum correctly so no checksum offload  support is
>> provided.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>  drivers/net/virtio_net.c |   99 +++++++++++++++++++++++++++++++++++++++++++---
>>  1 file changed, 92 insertions(+), 7 deletions(-)
>>
>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> index 28b1196..8e5b13c 100644
>> --- a/drivers/net/virtio_net.c
>> +++ b/drivers/net/virtio_net.c
>> @@ -330,12 +330,57 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
>>  	return skb;
>>  }
>>  
>> +static void virtnet_xdp_xmit(struct virtnet_info *vi,
>> +			     struct receive_queue *rq,
>> +			     struct send_queue *sq,
>> +			     struct xdp_buff *xdp)
>> +{
>> +	struct page *page = virt_to_head_page(xdp->data);
>> +	struct virtio_net_hdr_mrg_rxbuf *hdr;
>> +	unsigned int num_sg, len;
>> +	void *xdp_sent;
>> +	int err;
>> +
>> +	/* Free up any pending old buffers before queueing new ones. */
>> +	while ((xdp_sent = virtqueue_get_buf(sq->vq, &len)) != NULL) {
>> +		struct page *sent_page = virt_to_head_page(xdp_sent);
>> +
>> +		if (vi->mergeable_rx_bufs)
>> +			put_page(sent_page);
>> +		else
>> +			give_pages(rq, sent_page);
>> +	}
> 
> Looks like this is the only place where you do virtqueue_get_buf.
> No interrupt handler?
> This means that if you fill up the queue, nothing will clean it
> and things will get stuck.

hmm OK so the callbacks should be implemented to do this and a pair
of virtqueue_enable_cb_prepare()/virtqueue_disable_cb() used to enable
and disable callbacks if packets are enqueued.

Also in the normal xmit path via start_xmit() will the same condition
happen? It looks like free_old_xmit_skbs for example is only called if
a packet is sent could we end up holding on to skbs in this case? I
don't see free_old_xmit_skbs being called from any callbacks?

> Can this be the issue you saw?

nope see below I was mishandling the big_packets page cleanup path in
the error case.

> 
> 
>> +
>> +	/* Zero header and leave csum up to XDP layers */
>> +	hdr = xdp->data;
>> +	memset(hdr, 0, vi->hdr_len);
>> +
>> +	nu_sg = 1;
>> +	sg_init_one(sq->sg, xdp->data, xdp->data_end - xdp->data);
>> +	err = virtqueue_add_outbuf(sq->vq, sq->sg, num_sg,
>> +				   xdp->data, GFP_ATOMIC);
>> +	if (unlikely(err)) {
>> +		if (vi->mergeable_rx_bufs)
>> +			put_page(page);
>> +		else
>> +			give_pages(rq, page);
>> +	} else if (!vi->mergeable_rx_bufs) {
>> +		/* If not mergeable bufs must be big packets so cleanup pages */
>> +		give_pages(rq, (struct page *)page->private);
>> +		page->private = 0;
>> +	}
>> +
>> +	virtqueue_kick(sq->vq);
> 
> Is this unconditional kick a work-around for hang
> we could not figure out yet?

I tracked the original issue down to how I handled the big_packet page
cleanups.

> I guess this helps because it just slows down the guest.
> I don't much like it ...

I left it like this copying the pattern in balloon and input drivers. I
can change it back to the previous pattern where it is only called if
there is no errors. It has been running fine with the old pattern now
for an hour or so.

.John

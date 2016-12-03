From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v4 5/6] virtio_net: add XDP_TX support
Date: Fri, 2 Dec 2016 19:10:09 -0800
Message-ID: <58423791.4020802@gmail.com>
References: <20161202204804.4331.61904.stgit@john-Precision-Tower-5810>
 <20161202205122.4331.70274.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        bblanco@plumgrid.com, brouer@redhat.com
To: daniel@iogearbox.net, mst@redhat.com, shm@cumulusnetworks.com,
        davem@davemloft.net, tgraf@suug.ch, alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33478 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750787AbcLCDKc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 22:10:32 -0500
Received: by mail-pg0-f67.google.com with SMTP id 3so9615351pgd.0
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 19:10:31 -0800 (PST)
In-Reply-To: <20161202205122.4331.70274.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-12-02 12:51 PM, John Fastabend wrote:
> This adds support for the XDP_TX action to virtio_net. When an XDP
> program is run and returns the XDP_TX action the virtio_net XDP
> implementation will transmit the packet on a TX queue that aligns
> with the current CPU that the XDP packet was processed on.
> 
> Before sending the packet the header is zeroed.  Also XDP is expected
> to handle checksum correctly so no checksum offload  support is
> provided.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  drivers/net/virtio_net.c |   63 ++++++++++++++++++++++++++++++++++++++++++++--
>  1 file changed, 60 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index b67203e..137caba 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -330,12 +330,43 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
>  	return skb;
>  }
>  
> +static void virtnet_xdp_xmit(struct virtnet_info *vi,
> +			     unsigned int qnum, struct xdp_buff *xdp)
> +{
> +	struct send_queue *sq = &vi->sq[qnum];
> +	struct virtio_net_hdr_mrg_rxbuf *hdr;
> +	unsigned int num_sg, len;
> +	void *xdp_sent;
> +	int err;
> +
> +	/* Free up any pending old buffers before queueing new ones. */
> +	while ((xdp_sent = virtqueue_get_buf(sq->vq, &len)) != NULL) {
> +		struct page *page = virt_to_head_page(xdp_sent);
> +
> +		put_page(page);
> +	}
> +
> +	/* Zero header and leave csum up to XDP layers */
> +	hdr = xdp->data;
> +	memset(hdr, 0, vi->hdr_len);
> +
> +	num_sg = 1;
> +	sg_init_one(sq->sg, xdp->data, xdp->data_end - xdp->data);
> +	err = virtqueue_add_outbuf(sq->vq, sq->sg, num_sg,
> +				   xdp->data, GFP_ATOMIC);
> +	if (unlikely(err))
> +		put_page(virt_to_head_page(xdp->data));
> +	else
> +		virtqueue_kick(sq->vq);
> +}
> +

Hi Michael,

Any idea why the above pattern

> +	err = virtqueue_add_outbuf(sq->vq, sq->sg, num_sg,
> +				   xdp->data, GFP_ATOMIC);
> +	if (unlikely(err))
> +		put_page(virt_to_head_page(xdp->data));
> +	else
> +		virtqueue_kick(sq->vq);
> +}

would cause a hang but if I call the virtqueue_kick as below
even in the error case everything seems to be fine.

	err = virtqueue_add_outbuf(sq->vq, sq->sg, num_sg,
				   xdp->data, GFP_ATOMIC);
	if (unlikely(err))
		put_page(virt_to_head_page(xdp->data));

	virtqueue_kick(sq->vq);


I'll take a look through the virtio code but thought I might ask in
case you know off-hand or it could be something else entirely.

I noticed virtio_input.c uses the second pattern and virtio_net.c
uses the above pattern but I'm guessing it never gets exercised due
to stack backoff.

Thanks,
John

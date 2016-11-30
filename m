From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [net-next PATCH v3 6/6] virtio_net: xdp, add slowpath case for
 non contiguous buffers
Date: Wed, 30 Nov 2016 14:30:31 +0000
Message-ID: <20161130143031.2fc64ab4@jkicinski-Precision-T1700>
References: <20161129200933.26851.41883.stgit@john-Precision-Tower-5810>
        <20161129201133.26851.31803.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, daniel@iogearbox.net,
        shm@cumulusnetworks.com, davem@davemloft.net, tgraf@suug.ch,
        alexei.starovoitov@gmail.com, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, bblanco@plumgrid.com, brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>,
        "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:33164 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757413AbcK3Oaj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 09:30:39 -0500
In-Reply-To: <20161129201133.26851.31803.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[add MST]

On Tue, 29 Nov 2016 12:11:33 -0800, John Fastabend wrote:
> virtio_net XDP support expects receive buffers to be contiguous.
> If this is not the case we enable a slowpath to allow connectivity
> to continue but at a significan performance overhead associated with
> linearizing data. To make it painfully aware to users that XDP is
> running in a degraded mode we throw an xdp buffer error.
> 
> To linearize packets we allocate a page and copy the segments of
> the data, including the header, into it. After this the page can be
> handled by XDP code flow as normal.
> 
> Then depending on the return code the page is either freed or sent
> to the XDP xmit path. There is no attempt to optimize this path.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  drivers/net/virtio_net.c |   70 +++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 68 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 9604e55..b0ce4ef 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -449,6 +449,56 @@ static struct sk_buff *receive_big(struct net_device *dev,
>  	return NULL;
>  }
>  
> +/* The conditions to enable XDP should preclude the underlying device from
> + * sending packets across multiple buffers (num_buf > 1). However per spec
> + * it does not appear to be illegal to do so but rather just against convention.
> + * So in order to avoid making a system unresponsive the packets are pushed
> + * into a page and the XDP program is run. This will be extremely slow and we
> + * push a warning to the user to fix this as soon as possible. Fixing this may
> + * require resolving the underlying hardware to determine why multiple buffers
> + * are being received or simply loading the XDP program in the ingress stack
> + * after the skb is built because there is no advantage to running it here
> + * anymore.
> + */
> +static struct page *xdp_linearize_page(struct receive_queue *rq,
> +				       u16 num_buf,
> +				       struct page *p,
> +				       int offset,
> +				       unsigned int *len)
> +{
> +	struct page *page = alloc_page(GFP_ATOMIC);
> +	unsigned int page_off = 0;
> +
> +	if (!page)
> +		return NULL;
> +
> +	memcpy(page_address(page) + page_off, page_address(p) + offset, *len);
> +	while (--num_buf) {
> +		unsigned int buflen;
> +		unsigned long ctx;
> +		void *buf;
> +		int off;
> +
> +		ctx = (unsigned long)virtqueue_get_buf(rq->vq, &buflen);
> +		if (unlikely(!ctx))
> +			goto err_buf;
> +
> +		buf = mergeable_ctx_to_buf_address(ctx);
> +		p = virt_to_head_page(buf);
> +		off = buf - page_address(p);
> +
> +		memcpy(page_address(page) + page_off,
> +		       page_address(p) + off, buflen);
> +		page_off += buflen;

Could malicious user potentially submit a frame bigger than MTU?

> +	}
> +
> +	*len = page_off;
> +	return page;
> +err_buf:
> +	__free_pages(page, 0);
> +	return NULL;
> +}
> +
>  static struct sk_buff *receive_mergeable(struct net_device *dev,
>  					 struct virtnet_info *vi,
>  					 struct receive_queue *rq,
> @@ -469,21 +519,37 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
>  	rcu_read_lock();
>  	xdp_prog = rcu_dereference(rq->xdp_prog);
>  	if (xdp_prog) {
> +		struct page *xdp_page;
>  		u32 act;
>  
>  		if (num_buf > 1) {
>  			bpf_warn_invalid_xdp_buffer();
> -			goto err_xdp;
> +
> +			/* linearize data for XDP */
> +			xdp_page = xdp_linearize_page(rq, num_buf,
> +						      page, offset, &len);
> +			if (!xdp_page)
> +				goto err_xdp;
> +			offset = len;
> +		} else {
> +			xdp_page = page;
>  		}
>  
> -		act = do_xdp_prog(vi, xdp_prog, page, offset, len);
> +		act = do_xdp_prog(vi, xdp_prog, xdp_page, offset, len);
>  		switch (act) {
>  		case XDP_PASS:
> +			if (unlikely(xdp_page != page))
> +				__free_pages(xdp_page, 0);
>  			break;
>  		case XDP_TX:
> +			if (unlikely(xdp_page != page))
> +				goto err_xdp;
> +			rcu_read_unlock();

Only if there is a reason for v4 - this unlock could go to the previous
patch.

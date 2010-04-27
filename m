From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: linux-next: manual merge of the rr tree with the net tree
Date: Tue, 27 Apr 2010 07:09:13 +0300
Message-ID: <20100427040913.GA19951@redhat.com>
References: <20100427115852.9f4cbb0f.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100427115852.9f4cbb0f.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 27, 2010 at 11:58:52AM +1000, Stephen Rothwell wrote:
> Hi Rusty,
> 
> Today's linux-next merge of the rr tree got a conflict in
> drivers/net/virtio_net.c between commit
> 5e01d2f91df62be4d6f282149bc2a8858992ceca ("virtio-net: move sg off
> stack") from the net tree and commit
> 7f62a724a65f864d84f50857bbfd36c240155c8f ("virtio_net: use virtqueue_xxx
> wrappers") from the rr tree.
> 
> I fixed it up (see below) and can carry the fix as necessary.

Hmm, Rusty, do you intend for the patches to go through netdev this
time? If you do, it might be simplest to just ask Dave to merge
them in net-next-2.6 now. I can prepare and send them if you like.

> -- 
> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au
> 
> diff --cc drivers/net/virtio_net.c
> index b0a85d0,91738d8..0000000
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@@ -336,11 -335,11 +336,11 @@@ static int add_recvbuf_small(struct vir
>   	skb_put(skb, MAX_PACKET_LEN);
>   
>   	hdr = skb_vnet_hdr(skb);
>  -	sg_set_buf(sg, &hdr->hdr, sizeof hdr->hdr);
>  +	sg_set_buf(vi->rx_sg, &hdr->hdr, sizeof hdr->hdr);
>   
>  -	skb_to_sgvec(skb, sg + 1, 0, skb->len);
>  +	skb_to_sgvec(skb, vi->rx_sg + 1, 0, skb->len);
>   
> - 	err = vi->rvq->vq_ops->add_buf(vi->rvq, vi->rx_sg, 0, 2, skb);
>  -	err = virtqueue_add_buf(vi->rvq, sg, 0, 2, skb);
> ++	err = virtqueue_add_buf(vi->rvq, vi->rx_sg, 0, 2, skb);
>   	if (err < 0)
>   		dev_kfree_skb(skb);
>   
> @@@ -385,7 -386,7 +385,7 @@@ static int add_recvbuf_big(struct virtn
>   
>   	/* chain first in list head */
>   	first->private = (unsigned long)list;
> - 	err = vi->rvq->vq_ops->add_buf(vi->rvq, vi->rx_sg, 0, MAX_SKB_FRAGS + 2,
>  -	err = virtqueue_add_buf(vi->rvq, sg, 0, MAX_SKB_FRAGS + 2,
> ++	err = virtqueue_add_buf(vi->rvq, vi->rx_sg, 0, MAX_SKB_FRAGS + 2,
>   				       first);
>   	if (err < 0)
>   		give_pages(vi, first);
> @@@ -402,9 -404,9 +402,9 @@@ static int add_recvbuf_mergeable(struc
>   	if (!page)
>   		return -ENOMEM;
>   
>  -	sg_init_one(&sg, page_address(page), PAGE_SIZE);
>  +	sg_init_one(vi->rx_sg, page_address(page), PAGE_SIZE);
>   
> - 	err = vi->rvq->vq_ops->add_buf(vi->rvq, vi->rx_sg, 0, 1, page);
>  -	err = virtqueue_add_buf(vi->rvq, &sg, 0, 1, page);
> ++	err = virtqueue_add_buf(vi->rvq, vi->rx_sg, 0, 1, page);
>   	if (err < 0)
>   		give_pages(vi, page);
>   
> @@@ -549,13 -554,12 +549,12 @@@ static int xmit_skb(struct virtnet_inf
>   
>   	/* Encode metadata header at front. */
>   	if (vi->mergeable_rx_bufs)
>  -		sg_set_buf(sg, &hdr->mhdr, sizeof hdr->mhdr);
>  +		sg_set_buf(vi->tx_sg, &hdr->mhdr, sizeof hdr->mhdr);
>   	else
>  -		sg_set_buf(sg, &hdr->hdr, sizeof hdr->hdr);
>  +		sg_set_buf(vi->tx_sg, &hdr->hdr, sizeof hdr->hdr);
>   
>  -	hdr->num_sg = skb_to_sgvec(skb, sg+1, 0, skb->len) + 1;
>  -	return virtqueue_add_buf(vi->svq, sg, hdr->num_sg, 0, skb);
>  +	hdr->num_sg = skb_to_sgvec(skb, vi->tx_sg + 1, 0, skb->len) + 1;
> - 	return vi->svq->vq_ops->add_buf(vi->svq, vi->tx_sg, hdr->num_sg,
> - 					0, skb);
> ++	return virtqueue_add_buf(vi->svq, vi->tx_sg, hdr->num_sg, 0, skb);
>   }
>   
>   static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)

From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 4/4] Defer skb allocation -- change allocation &
	receiving in recv path
Date: Sun, 13 Dec 2009 13:08:22 +0200
Message-ID: <20091213110822.GA7074@redhat.com>
References: <1258697359.7416.14.camel@localhost.localdomain> <200911231123.18898.rusty@rustcorp.com.au> <20091208122134.GA17286@redhat.com> <1260534506.30371.6.camel@localhost.localdomain> <1260535793.30371.27.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Anthony Liguori <anthony@codemonkey.ws>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50299 "HELO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752275AbZLMLLM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2009 06:11:12 -0500
Content-Disposition: inline
In-Reply-To: <1260535793.30371.27.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 11, 2009 at 04:49:53AM -0800, Shirley Ma wrote:
> Signed-off-by: Shirley Ma <xma@us.ibm.com>
> -------------

Comments about splitting up this patch apply here.


> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index dde8060..b919169 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -270,99 +270,44 @@ static struct sk_buff *receive_mergeable(struct virtnet_info *vi,
>  	return skb;
>  }
>  
> -static void receive_skb(struct net_device *dev, struct sk_buff *skb,
> -			unsigned len)
> +static void receive_buf(struct net_device *dev, void *buf, unsigned int len)
>  {
>  	struct virtnet_info *vi = netdev_priv(dev);
> -	struct skb_vnet_hdr *hdr = skb_vnet_hdr(skb);
> -	int err;
> -	int i;
> +	struct sk_buff *skb = (struct sk_buff *)buf;
> +	struct page *page = (struct page *)buf;
> +	struct skb_vnet_hdr *hdr;

Do not cast away void*.
This initialization above looks very strange: in
fact only one of skb, page makes sense.
So I think you should either get rid of both page and
skb variables (routines such as give_pages get page *
so they will accept void* just as happily) or
move initialization or even use of these variables to
where they are used.

>  
>  	if (unlikely(len < sizeof(struct virtio_net_hdr) + ETH_HLEN)) {
>  		pr_debug("%s: short packet %i\n", dev->name, len);
>  		dev->stats.rx_length_errors++;
> -		goto drop;
> -	}
> -
> -	if (vi->mergeable_rx_bufs) {
> -		unsigned int copy;
> -		char *p = page_address(skb_shinfo(skb)->frags[0].page);
> -
> -		if (len > PAGE_SIZE)
> -			len = PAGE_SIZE;
> -		len -= sizeof(struct virtio_net_hdr_mrg_rxbuf);
> -
> -		memcpy(&hdr->mhdr, p, sizeof(hdr->mhdr));
> -		p += sizeof(hdr->mhdr);
> -
> -		copy = len;
> -		if (copy > skb_tailroom(skb))
> -			copy = skb_tailroom(skb);
> -
> -		memcpy(skb_put(skb, copy), p, copy);
> -
> -		len -= copy;
> -
> -		if (!len) {
> -			give_pages(vi, skb_shinfo(skb)->frags[0].page);
> -			skb_shinfo(skb)->nr_frags--;
> +		if (vi->mergeable_rx_bufs || vi->big_packets) {
> +			give_pages(vi, page);
> +			return;
>  		} else {
> -			skb_shinfo(skb)->frags[0].page_offset +=
> -				sizeof(hdr->mhdr) + copy;
> -			skb_shinfo(skb)->frags[0].size = len;
> -			skb->data_len += len;
> -			skb->len += len;
> -		}
> -
> -		while (--hdr->mhdr.num_buffers) {
> -			struct sk_buff *nskb;
> -
> -			i = skb_shinfo(skb)->nr_frags;
> -			if (i >= MAX_SKB_FRAGS) {
> -				pr_debug("%s: packet too long %d\n", dev->name,
> -					 len);
> -				dev->stats.rx_length_errors++;
> -				goto drop;
> -			}
> -
> -			nskb = vi->rvq->vq_ops->get_buf(vi->rvq, &len);
> -			if (!nskb) {
> -				pr_debug("%s: rx error: %d buffers missing\n",
> -					 dev->name, hdr->mhdr.num_buffers);
> -				dev->stats.rx_length_errors++;
> -				goto drop;
> -			}
> -
> -			__skb_unlink(nskb, &vi->recv);
> -			vi->num--;
> -
> -			skb_shinfo(skb)->frags[i] = skb_shinfo(nskb)->frags[0];
> -			skb_shinfo(nskb)->nr_frags = 0;
> -			kfree_skb(nskb);
> -
> -			if (len > PAGE_SIZE)
> -				len = PAGE_SIZE;
> -
> -			skb_shinfo(skb)->frags[i].size = len;
> -			skb_shinfo(skb)->nr_frags++;
> -			skb->data_len += len;
> -			skb->len += len;
> +			skb_unlink(skb, &vi->recv);
> +			goto drop;
>  		}
> -	} else {
> -		len -= sizeof(hdr->hdr);
> +	}
>  
> -		if (len <= MAX_PACKET_LEN)
> -			trim_pages(vi, skb);
> +	if (vi->mergeable_rx_bufs)
> +		skb = receive_mergeable(vi, page, len);
> +	else if (vi->big_packets)
> +		skb = receive_big(vi, page, len);
> +	else {
> +		__skb_unlink(skb, &vi->recv);
> +		len -= sizeof(struct virtio_net_hdr);
> +		skb_trim(skb, len);

So above you override skb that you initialized
at the start of function. It would be better
to do in the 3'd case:
		skb = buf;
as well. And then it would be clear why
" Only for mergeable and big" comment below
is true.

> +	}
>  
> -		err = pskb_trim(skb, len);
> -		if (err) {
> -			pr_debug("%s: pskb_trim failed %i %d\n", dev->name,
> -				 len, err);
> -			dev->stats.rx_dropped++;
> -			goto drop;
> -		}
> +	if (unlikely(!skb)) {
> +		dev->stats.rx_dropped++;
> +		/* only for mergeable buf and big packets */
> +		give_pages(vi, page);
> +		return;

Did you remove drop: label? If no, is it unused now?

>  	}
>  
> +	hdr = skb_vnet_hdr(skb);
> +
>  	skb->truesize += skb->data_len;
>  	dev->stats.rx_bytes += skb->len;
>  	dev->stats.rx_packets++;
> @@ -520,105 +465,22 @@ static int add_recvbuf_mergeable(struct virtnet_info *vi, gfp_t gfp, bool *oom)
>  	return err;
>  }
>  
> -static bool try_fill_recv_maxbufs(struct virtnet_info *vi, gfp_t gfp)
> -{
> -	struct sk_buff *skb;
> -	struct scatterlist sg[2+MAX_SKB_FRAGS];
> -	int num, err, i;
> -	bool oom = false;
> -
> -	sg_init_table(sg, 2+MAX_SKB_FRAGS);
> -	do {
> -		struct skb_vnet_hdr *hdr;
> -
> -		skb = netdev_alloc_skb_ip_align(vi->dev, MAX_PACKET_LEN);
> -		if (unlikely(!skb)) {
> -			oom = true;
> -			break;
> -		}
> -
> -		skb_put(skb, MAX_PACKET_LEN);
> -
> -		hdr = skb_vnet_hdr(skb);
> -		sg_set_buf(sg, &hdr->hdr, sizeof(hdr->hdr));
> -
> -		if (vi->big_packets) {
> -			for (i = 0; i < MAX_SKB_FRAGS; i++) {
> -				skb_frag_t *f = &skb_shinfo(skb)->frags[i];
> -				f->page = get_a_page(vi, gfp);
> -				if (!f->page)
> -					break;
> -
> -				f->page_offset = 0;
> -				f->size = PAGE_SIZE;
> -
> -				skb->data_len += PAGE_SIZE;
> -				skb->len += PAGE_SIZE;
> -
> -				skb_shinfo(skb)->nr_frags++;
> -			}
> -		}
> -
> -		num = skb_to_sgvec(skb, sg+1, 0, skb->len) + 1;
> -		skb_queue_head(&vi->recv, skb);
> -
> -		err = vi->rvq->vq_ops->add_buf(vi->rvq, sg, 0, num, skb);
> -		if (err < 0) {
> -			skb_unlink(skb, &vi->recv);
> -			trim_pages(vi, skb);
> -			kfree_skb(skb);
> -			break;
> -		}
> -		vi->num++;
> -	} while (err >= num);
> -	if (unlikely(vi->num > vi->max))
> -		vi->max = vi->num;
> -	vi->rvq->vq_ops->kick(vi->rvq);
> -	return !oom;
> -}
> -
>  /* Returns false if we couldn't fill entirely (OOM). */
>  static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
>  {
> -	struct sk_buff *skb;
> -	struct scatterlist sg[1];
>  	int err;
>  	bool oom = false;
>  
> -	if (!vi->mergeable_rx_bufs)
> -		return try_fill_recv_maxbufs(vi, gfp);
> -
>  	do {
> -		skb_frag_t *f;
> -
> -		skb = netdev_alloc_skb_ip_align(vi->dev, GOOD_COPY_LEN);
> -		if (unlikely(!skb)) {
> -			oom = true;
> -			break;
> -		}
> -
> -		f = &skb_shinfo(skb)->frags[0];
> -		f->page = get_a_page(vi, gfp);
> -		if (!f->page) {
> -			oom = true;
> -			kfree_skb(skb);
> -			break;
> -		}
> -
> -		f->page_offset = 0;
> -		f->size = PAGE_SIZE;
> -
> -		skb_shinfo(skb)->nr_frags++;
> -
> -		sg_init_one(sg, page_address(f->page), PAGE_SIZE);
> -		skb_queue_head(&vi->recv, skb);
> +		if (vi->mergeable_rx_bufs)
> +			err = add_recvbuf_mergeable(vi, gfp, &oom);
> +		else if (vi->big_packets)
> +			err = add_recvbuf_big(vi, gfp, &oom);
> +		else
> +			err = add_recvbuf_small(vi, gfp, &oom);
>  
> -		err = vi->rvq->vq_ops->add_buf(vi->rvq, sg, 0, 1, skb);
> -		if (err < 0) {
> -			skb_unlink(skb, &vi->recv);
> -			kfree_skb(skb);
> +		if (oom || err < 0)
>  			break;
> -		}
>  		vi->num++;
>  	} while (err > 0);
>  	if (unlikely(vi->num > vi->max))
> @@ -657,14 +519,13 @@ static void refill_work(struct work_struct *work)
>  static int virtnet_poll(struct napi_struct *napi, int budget)
>  {
>  	struct virtnet_info *vi = container_of(napi, struct virtnet_info, napi);
> -	struct sk_buff *skb = NULL;
> +	void *buf = NULL;

Does this have to be initialized? If not (as it seems) better not do it.

>  	unsigned int len, received = 0;
>  
>  again:
>  	while (received < budget &&
> -	       (skb = vi->rvq->vq_ops->get_buf(vi->rvq, &len)) != NULL) {
> -		__skb_unlink(skb, &vi->recv);
> -		receive_skb(vi->dev, skb, len);
> +	       (buf = vi->rvq->vq_ops->get_buf(vi->rvq, &len)) != NULL) {
> +		receive_buf(vi->dev, buf, len);
>  		vi->num--;
>  		received++;
>  	}
> @@ -1205,6 +1066,7 @@ static void __devexit virtnet_remove(struct virtio_device *vdev)
>  {
>  	struct virtnet_info *vi = vdev->priv;
>  	struct sk_buff *skb;
> +	int freed;
>  
>  	/* Stop all the virtqueues. */
>  	vdev->config->reset(vdev);
> @@ -1216,11 +1078,14 @@ static void __devexit virtnet_remove(struct virtio_device *vdev)
>  	}
>  	__skb_queue_purge(&vi->send);
>  
> -	BUG_ON(vi->num != 0);
> -
>  	unregister_netdev(vi->dev);
>  	cancel_delayed_work_sync(&vi->refill);
>  
> +	freed = vi->rvq->vq_ops->destroy_bufs(vi->rvq, virtio_net_free_pages);

This looks like double free to me: should not you remove code that does
__skb_dequeue on recv above?

> +	vi->num -= freed;
> +
> +	BUG_ON(vi->num != 0);
> +
>  	vdev->config->del_vqs(vi->vdev);
>  
>  	while (vi->pages)
> 

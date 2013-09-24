From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next] xen-netback: improve ring effeciency for guest
 RX
Date: Tue, 24 Sep 2013 10:41:36 +0100
Message-ID: <1380015696.23688.17.camel@kazak.uk.xensource.com>
References: <1379873024-32132-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>,
	Xi Xiong <xixiong@amazon.com>, Matt Wilson <msw@amazon.com>,
	Annie Li <annie.li@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:18331 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750713Ab3IXJlj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 05:41:39 -0400
In-Reply-To: <1379873024-32132-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-09-22 at 19:03 +0100, Wei Liu wrote:
> There was a bug that netback routines netbk/xenvif_skb_count_slots and
> netbk/xenvif_gop_frag_copy disagreed with each other, which caused
> netback to push wrong number of responses to netfront, which caused
> netfront to eventually crash. The bug was fixed in 6e43fc04a
> ("xen-netback: count number required slots for an skb more carefully").
> 
> Commit 6e43fc04a focused on backport-ability. The drawback with the
> existing packing scheme is that the ring is not used effeciently, as
> stated in 6e43fc04a.
> 
> skb->data like:
>     |        1111|222222222222|3333        |
> 
> is arranged as:
>     |1111        |222222222222|3333        |
> 
> If we can do this:
>     |111122222222|22223333    |
> That would save one ring slot, which improves ring effeciency.
> 
> This patch effectively reverts 6e43fc04a. That patch made count_slots
> agree with gop_frag_copy, while this patch goes the other way around --
> make gop_frag_copy agree with count_slots. The end result is that they
> still agree with each other, and the ring is now arranged like:
>     |111122222222|22223333    |
> 
> The patch that improves packing was first posted by Xi Xong and Matt
> Wilson. I only rebase it on top of net-next and rewrite commit message,
> so I retain all their SoBs. For more infomation about the original bug
> please refer to email listed below and commit message of 6e43fc04a.
> 
> Original patch:
> http://lists.xen.org/archives/html/xen-devel/2013-07/msg00760.html
> 
> Signed-off-by: Xi Xiong <xixiong@amazon.com>
> Reviewed-by: Matt Wilson <msw@amazon.com>
> [ msw: minor code cleanups, rewrote commit message, adjusted code
>   to count RX slots instead of meta structures ]
> Signed-off-by: Matt Wilson <msw@amazon.com>
> Cc: Annie Li <annie.li@oracle.com>
> Cc: Wei Liu <wei.liu2@citrix.com>

Acked-by: Ian Campbell <Ian.Campbell@citrix.com>

> [ liuw: rebased on top of net-next tree, rewrote commit message, coding
>   style cleanup. ]
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> Cc: David Vrabel <david.vrabel@citrix.com>
> ---
>  drivers/net/xen-netback/netback.c |  144 ++++++++++++++++---------------------
>  1 file changed, 61 insertions(+), 83 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index f3e591c..d0b0feb 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -47,6 +47,14 @@
>  #include <asm/xen/hypercall.h>
>  #include <asm/xen/page.h>
>  
> +/* SKB control block overlay is used to store useful information when
> + * doing guest RX.
> + */
> +struct skb_cb_overlay {
> +	int meta_slots_used;
> +	int peek_slots_count;
> +};
> +
>  /* Provide an option to disable split event channels at load time as
>   * event channels are limited resource. Split event channels are
>   * enabled by default.
> @@ -212,49 +220,6 @@ static bool start_new_rx_buffer(int offset, unsigned long size, int head)
>  	return false;
>  }
>  
> -struct xenvif_count_slot_state {
> -	unsigned long copy_off;
> -	bool head;
> -};
> -
> -unsigned int xenvif_count_frag_slots(struct xenvif *vif,
> -				     unsigned long offset, unsigned long size,
> -				     struct xenvif_count_slot_state *state)
> -{
> -	unsigned count = 0;
> -
> -	offset &= ~PAGE_MASK;
> -
> -	while (size > 0) {
> -		unsigned long bytes;
> -
> -		bytes = PAGE_SIZE - offset;
> -
> -		if (bytes > size)
> -			bytes = size;
> -
> -		if (start_new_rx_buffer(state->copy_off, bytes, state->head)) {
> -			count++;
> -			state->copy_off = 0;
> -		}
> -
> -		if (state->copy_off + bytes > MAX_BUFFER_OFFSET)
> -			bytes = MAX_BUFFER_OFFSET - state->copy_off;
> -
> -		state->copy_off += bytes;
> -
> -		offset += bytes;
> -		size -= bytes;
> -
> -		if (offset == PAGE_SIZE)
> -			offset = 0;
> -
> -		state->head = false;
> -	}
> -
> -	return count;
> -}
> -
>  /*
>   * Figure out how many ring slots we're going to need to send @skb to
>   * the guest. This function is essentially a dry run of
> @@ -262,40 +227,53 @@ unsigned int xenvif_count_frag_slots(struct xenvif *vif,
>   */
>  unsigned int xenvif_count_skb_slots(struct xenvif *vif, struct sk_buff *skb)
>  {
> -	struct xenvif_count_slot_state state;
>  	unsigned int count;
> -	unsigned char *data;
> -	unsigned i;
> +	int i, copy_off;
> +	struct skb_cb_overlay *sco;
>  
> -	state.head = true;
> -	state.copy_off = 0;
> +	count = DIV_ROUND_UP(skb_headlen(skb), PAGE_SIZE);
>  
> -	/* Slot for the first (partial) page of data. */
> -	count = 1;
> +	copy_off = skb_headlen(skb) % PAGE_SIZE;
>  
> -	/* Need a slot for the GSO prefix for GSO extra data? */
>  	if (skb_shinfo(skb)->gso_size)
>  		count++;
>  
> -	data = skb->data;
> -	while (data < skb_tail_pointer(skb)) {
> -		unsigned long offset = offset_in_page(data);
> -		unsigned long size = PAGE_SIZE - offset;
> +	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
> +		unsigned long size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
> +		unsigned long offset = skb_shinfo(skb)->frags[i].page_offset;
> +		unsigned long bytes;
>  
> -		if (data + size > skb_tail_pointer(skb))
> -			size = skb_tail_pointer(skb) - data;
> +		offset &= ~PAGE_MASK;
>  
> -		count += xenvif_count_frag_slots(vif, offset, size, &state);
> +		while (size > 0) {
> +			BUG_ON(offset >= PAGE_SIZE);
> +			BUG_ON(copy_off > MAX_BUFFER_OFFSET);
>  
> -		data += size;
> -	}
> +			bytes = PAGE_SIZE - offset;
>  
> -	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
> -		unsigned long size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
> -		unsigned long offset = skb_shinfo(skb)->frags[i].page_offset;
> +			if (bytes > size)
> +				bytes = size;
> +
> +			if (start_new_rx_buffer(copy_off, bytes, 0)) {
> +				count++;
> +				copy_off = 0;
> +			}
>  
> -		count += xenvif_count_frag_slots(vif, offset, size, &state);
> +			if (copy_off + bytes > MAX_BUFFER_OFFSET)
> +				bytes = MAX_BUFFER_OFFSET - copy_off;
> +
> +			copy_off += bytes;
> +
> +			offset += bytes;
> +			size -= bytes;
> +
> +			if (offset == PAGE_SIZE)
> +				offset = 0;
> +		}
>  	}
> +
> +	sco = (struct skb_cb_overlay *)skb->cb;
> +	sco->peek_slots_count = count;
>  	return count;
>  }
>  
> @@ -327,14 +305,11 @@ static struct xenvif_rx_meta *get_next_rx_buffer(struct xenvif *vif,
>  	return meta;
>  }
>  
> -/*
> - * Set up the grant operations for this fragment. If it's a flipping
> - * interface, we also set up the unmap request from here.
> - */
> +/* Set up the grant operations for this fragment. */
>  static void xenvif_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
>  				 struct netrx_pending_operations *npo,
>  				 struct page *page, unsigned long size,
> -				 unsigned long offset, int *head)
> +				 unsigned long offset, int head, int *first)
>  {
>  	struct gnttab_copy *copy_gop;
>  	struct xenvif_rx_meta *meta;
> @@ -358,12 +333,12 @@ static void xenvif_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
>  		if (bytes > size)
>  			bytes = size;
>  
> -		if (start_new_rx_buffer(npo->copy_off, bytes, *head)) {
> +		if (start_new_rx_buffer(npo->copy_off, bytes, head)) {
>  			/*
>  			 * Netfront requires there to be some data in the head
>  			 * buffer.
>  			 */
> -			BUG_ON(*head);
> +			BUG_ON(*first);
>  
>  			meta = get_next_rx_buffer(vif, npo);
>  		}
> @@ -397,10 +372,10 @@ static void xenvif_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
>  		}
>  
>  		/* Leave a gap for the GSO descriptor. */
> -		if (*head && skb_shinfo(skb)->gso_size && !vif->gso_prefix)
> +		if (*first && skb_shinfo(skb)->gso_size && !vif->gso_prefix)
>  			vif->rx.req_cons++;
>  
> -		*head = 0; /* There must be something in this buffer now. */
> +		*first = 0; /* There must be something in this buffer now. */
>  
>  	}
>  }
> @@ -426,7 +401,7 @@ static int xenvif_gop_skb(struct sk_buff *skb,
>  	struct xen_netif_rx_request *req;
>  	struct xenvif_rx_meta *meta;
>  	unsigned char *data;
> -	int head = 1;
> +	int first = 1;
>  	int old_meta_prod;
>  
>  	old_meta_prod = npo->meta_prod;
> @@ -462,7 +437,7 @@ static int xenvif_gop_skb(struct sk_buff *skb,
>  			len = skb_tail_pointer(skb) - data;
>  
>  		xenvif_gop_frag_copy(vif, skb, npo,
> -				     virt_to_page(data), len, offset, &head);
> +				     virt_to_page(data), len, offset, 1, &first);
>  		data += len;
>  	}
>  
> @@ -471,7 +446,7 @@ static int xenvif_gop_skb(struct sk_buff *skb,
>  				     skb_frag_page(&skb_shinfo(skb)->frags[i]),
>  				     skb_frag_size(&skb_shinfo(skb)->frags[i]),
>  				     skb_shinfo(skb)->frags[i].page_offset,
> -				     &head);
> +				     0, &first);
>  	}
>  
>  	return npo->meta_prod - old_meta_prod;
> @@ -529,10 +504,6 @@ static void xenvif_add_frag_responses(struct xenvif *vif, int status,
>  	}
>  }
>  
> -struct skb_cb_overlay {
> -	int meta_slots_used;
> -};
> -
>  static void xenvif_kick_thread(struct xenvif *vif)
>  {
>  	wake_up(&vif->wq);
> @@ -563,19 +534,26 @@ void xenvif_rx_action(struct xenvif *vif)
>  	count = 0;
>  
>  	while ((skb = skb_dequeue(&vif->rx_queue)) != NULL) {
> +		RING_IDX old_rx_req_cons;
> +
>  		vif = netdev_priv(skb->dev);
>  		nr_frags = skb_shinfo(skb)->nr_frags;
>  
> +		old_rx_req_cons = vif->rx.req_cons;
>  		sco = (struct skb_cb_overlay *)skb->cb;
>  		sco->meta_slots_used = xenvif_gop_skb(skb, &npo);
>  
> -		count += nr_frags + 1;
> +		count += vif->rx.req_cons - old_rx_req_cons;
>  
>  		__skb_queue_tail(&rxq, skb);
>  
> +		skb = skb_peek(&vif->rx_queue);
> +		if (skb == NULL)
> +			break;
> +		sco = (struct skb_cb_overlay *)skb->cb;
> +
>  		/* Filled the batch queue? */
> -		/* XXX FIXME: RX path dependent on MAX_SKB_FRAGS */
> -		if (count + MAX_SKB_FRAGS >= XEN_NETIF_RX_RING_SIZE)
> +		if (count + sco->peek_slots_count >= XEN_NETIF_RX_RING_SIZE)
>  			break;
>  	}
>  

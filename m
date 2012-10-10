From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH V2] xen: netback: handle compound page
 fragments on transmit.
Date: Wed, 10 Oct 2012 14:53:23 -0400
Message-ID: <20121010185323.GA7988@phenom.dumpdata.com>
References: <1349876922-11907-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org,
	Konrad Rzeszutek Wilk <konrad@kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Sander Eikelenboom <linux@eikelenboom.it>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:26027 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756982Ab2JJTF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 15:05:26 -0400
Content-Disposition: inline
In-Reply-To: <1349876922-11907-1-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 10, 2012 at 02:48:42PM +0100, Ian Campbell wrote:
> An SKB paged fragment can consist of a compound page with order > 0.
> However the netchannel protocol deals only in PAGE_SIZE frames.
> 
> Handle this in netbk_gop_frag_copy and xen_netbk_count_skb_slots by
> iterating over the frames which make up the page.
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Konrad Rzeszutek Wilk <konrad@kernel.org>

Tested-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

> Cc: Sander Eikelenboom <linux@eikelenboom.it>
> ---
> v2: Only move to next frame if there is data remaining.
> ---
>  drivers/net/xen-netback/netback.c |   40 ++++++++++++++++++++++++++++++++----
>  1 files changed, 35 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 4ebfcf3..f2d6b78 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -335,21 +335,35 @@ unsigned int xen_netbk_count_skb_slots(struct xenvif *vif, struct sk_buff *skb)
>  
>  	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
>  		unsigned long size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
> +		unsigned long offset = skb_shinfo(skb)->frags[i].page_offset;
>  		unsigned long bytes;
> +
> +		offset &= ~PAGE_MASK;
> +
>  		while (size > 0) {
> +			BUG_ON(offset >= PAGE_SIZE);
>  			BUG_ON(copy_off > MAX_BUFFER_OFFSET);
>  
> -			if (start_new_rx_buffer(copy_off, size, 0)) {
> +			bytes = PAGE_SIZE - offset;
> +
> +			if (bytes > size)
> +				bytes = size;
> +
> +			if (start_new_rx_buffer(copy_off, bytes, 0)) {
>  				count++;
>  				copy_off = 0;
>  			}
>  
> -			bytes = size;
>  			if (copy_off + bytes > MAX_BUFFER_OFFSET)
>  				bytes = MAX_BUFFER_OFFSET - copy_off;
>  
>  			copy_off += bytes;
> +
> +			offset += bytes;
>  			size -= bytes;
> +
> +			if (offset == PAGE_SIZE)
> +				offset = 0;
>  		}
>  	}
>  	return count;
> @@ -403,14 +417,24 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
>  	unsigned long bytes;
>  
>  	/* Data must not cross a page boundary. */
> -	BUG_ON(size + offset > PAGE_SIZE);
> +	BUG_ON(size + offset > PAGE_SIZE<<compound_order(page));
>  
>  	meta = npo->meta + npo->meta_prod - 1;
>  
> +	/* Skip unused frames from start of page */
> +	page += offset >> PAGE_SHIFT;
> +	offset &= ~PAGE_MASK;
> +
>  	while (size > 0) {
> +		BUG_ON(offset >= PAGE_SIZE);
>  		BUG_ON(npo->copy_off > MAX_BUFFER_OFFSET);
>  
> -		if (start_new_rx_buffer(npo->copy_off, size, *head)) {
> +		bytes = PAGE_SIZE - offset;
> +
> +		if (bytes > size)
> +			bytes = size;
> +
> +		if (start_new_rx_buffer(npo->copy_off, bytes, *head)) {
>  			/*
>  			 * Netfront requires there to be some data in the head
>  			 * buffer.
> @@ -420,7 +444,6 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
>  			meta = get_next_rx_buffer(vif, npo);
>  		}
>  
> -		bytes = size;
>  		if (npo->copy_off + bytes > MAX_BUFFER_OFFSET)
>  			bytes = MAX_BUFFER_OFFSET - npo->copy_off;
>  
> @@ -453,6 +476,13 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
>  		offset += bytes;
>  		size -= bytes;
>  
> +		/* Next frame */
> +		if (offset == PAGE_SIZE && size) {
> +			BUG_ON(!PageCompound(page));
> +			page++;
> +			offset = 0;
> +		}
> +
>  		/* Leave a gap for the GSO descriptor. */
>  		if (*head && skb_shinfo(skb)->gso_size && !vif->gso_prefix)
>  			vif->rx.req_cons++;
> -- 
> 1.7.2.5
> 
> 
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
> 

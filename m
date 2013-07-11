From: Ian Campbell <ian.campbell@citrix.com>
Subject: Re: [PATCH v2 1/1] xen/netback: correctly calculate required slots
 of skb.
Date: Thu, 11 Jul 2013 09:11:14 +0100
Message-ID: <1373530274.5453.148.camel@hastur.hellion.org.uk>
References: <1373447711-31303-1-git-send-email-annie.li@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xensource.com>, <netdev@vger.kernel.org>,
	<wei.liu2@citrix.com>, <konrad.wilk@oracle.com>, <msw@amazon.com>
To: Annie Li <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:30989 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755866Ab3GKILR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 04:11:17 -0400
In-Reply-To: <1373447711-31303-1-git-send-email-annie.li@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-10 at 17:15 +0800, Annie Li wrote:
> +static int netbk_count_slots(struct xenvif *vif, struct sk_buff *skb,
> +			    int *copy_off, unsigned long size,
> +			    unsigned long offset, int *head)
>  {
> -	unsigned int count;
> -	int i, copy_off;
> +	unsigned long bytes;
> +	int count = 0;
>  
> -	count = DIV_ROUND_UP(skb_headlen(skb), PAGE_SIZE);
> +	offset &= ~PAGE_MASK;
>  
> -	copy_off = skb_headlen(skb) % PAGE_SIZE;
> +	while (size > 0) {
> +		BUG_ON(offset >= PAGE_SIZE);
> +		BUG_ON(*copy_off > MAX_BUFFER_OFFSET);
>  
> -	if (skb_shinfo(skb)->gso_size)
> -		count++;
> +		bytes = PAGE_SIZE - offset;
>  
> -	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
> -		unsigned long size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
> -		unsigned long offset = skb_shinfo(skb)->frags[i].page_offset;
> -		unsigned long bytes;
> +		if (bytes > size)
> +			bytes = size;
>  
> -		offset &= ~PAGE_MASK;
> +		if (start_new_rx_buffer(*copy_off, bytes, *head)) {
> +			count++;
> +			*copy_off = 0;
> +		}
>  
> -		while (size > 0) {
> -			BUG_ON(offset >= PAGE_SIZE);
> -			BUG_ON(copy_off > MAX_BUFFER_OFFSET);
> +		if (*copy_off + bytes > MAX_BUFFER_OFFSET)
> +			bytes = MAX_BUFFER_OFFSET - *copy_off;
>  
> -			bytes = PAGE_SIZE - offset;
> +		*copy_off += bytes;
>  
> -			if (bytes > size)
> -				bytes = size;
> +		offset += bytes;
> +		size -= bytes;
>  
> -			if (start_new_rx_buffer(copy_off, bytes, 0)) {
> -				count++;
> -				copy_off = 0;
> -			}
> +		/* Next frame */
> +		if (offset == PAGE_SIZE && size)
> +			offset = 0;
> +
> +		if (*head)
> +			count++;

This little bit corresponds to the "/* Leave a gap for the GSO
descriptor. */" in gop_frag_copy?

If so then it would be useful to duplicate the comment, but more
importantly the condition on gop_frag_copy is:
        (head && skb_shinfo(skb)->gso_size && !vif->gso_prefix)
why the difference?

> +		*head = 0; /* There must be something in this buffer now. */
> +	}
> +
> +	return count;
> +}

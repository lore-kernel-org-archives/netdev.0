From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RESEND] [PATCH] tcp: fix for splice receive when used with
	software LRO
Date: Fri, 20 Jun 2008 06:37:06 +0000
Message-ID: <20080620063706.GA4009@ff.dom.local>
References: <485B4ADE.8070102@domat.com.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:4306 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751251AbYFTGcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 02:32:50 -0400
Received: by ug-out-1314.google.com with SMTP id h2so1106910ugf.16
        for <netdev@vger.kernel.org>; Thu, 19 Jun 2008 23:32:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200806181907.16584.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18-06-2008 18:07, Octavian Purdila wrote:
...
>     tcp: fix for splice receive when used with software LRO
>     
>     If an skb has nr_frags set to zero but its frag_list is not empty (as
>     it can happen if software LRO is enabled), and a previous
>     tcp_read_sock has consumed the linear part of the skb, then
>     __skb_splice_bits:
>     
>     (a) incorrectly reports an error and
>     
>     (b) forgets to update the offset to account for the linear part
>     
>     Any of the two problems will cause the subsequent __skb_splice_bits
>     call (the one that handles the frag_list skbs) to either skip data,
>     or, if the unadjusted offset is greater then the size of the next skb
>     in the frag_list, make tcp_splice_read loop forever.
>     
>     Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 874790b..27cb0d3 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -1198,12 +1198,14 @@ static int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
>  {
>  	unsigned int nr_pages = spd->nr_pages;
>  	unsigned int poff, plen, len, toff, tlen;
> -	int headlen, seg;
> +	int headlen, seg, error = 0;
>  
>  	toff = *offset;
>  	tlen = *total_len;
> -	if (!tlen)
> +	if (!tlen) {
> +		error = 1;
>  		goto err;
> +	}
>  
>  	/*
>  	 * if the offset is greater than the linear part, go directly to
> @@ -1245,7 +1247,8 @@ static int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
>  		 * just jump directly to update and return, no point
>  		 * in going over fragments when the output is full.
>  		 */
> -		if (spd_fill_page(spd, virt_to_page(p), plen, poff, skb))
> +		error = spd_fill_page(spd, virt_to_page(p), plen, poff, skb);
> +		if (error)
>  			goto done;
>  
>  		tlen -= plen;
> @@ -1278,7 +1281,8 @@ map_frag:
>  		if (!plen)
>  			break;
>  
> -		if (spd_fill_page(spd, f->page, plen, poff, skb))
> +		error = spd_fill_page(spd, f->page, plen, poff, skb);
> +		if (error)
>  			break;

Hi,

This patch looks fine to me, but I wonder if, btw., this place can't
be optimized a bit, so why can't we simply:

	if (spd_fill_page(spd, f->page, plen, poff, skb))
		goto err;

in both cases, since nothing more can't be filled after this?

Regards,
Jarek P.

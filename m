From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RESEND] [PATCH] tcp: fix for splice receive when used with
	software LRO
Date: Fri, 20 Jun 2008 11:01:58 +0000
Message-ID: <20080620110158.GA4299@ff.dom.local>
References: <485B4ADE.8070102@domat.com.pl> <20080620063706.GA4009@ff.dom.local> <200806201309.35272.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.235]:16268 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010AbYFTK5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 06:57:41 -0400
Received: by wr-out-0506.google.com with SMTP id 69so896714wri.5
        for <netdev@vger.kernel.org>; Fri, 20 Jun 2008 03:57:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200806201309.35272.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 20, 2008 at 01:09:35PM +0300, Octavian Purdila wrote:
> On Friday 20 June 2008, Jarek Poplawski wrote:
> 
> > This patch looks fine to me, but I wonder if, btw., this place can't
> > be optimized a bit, so why can't we simply:
> >
> > 	if (spd_fill_page(spd, f->page, plen, poff, skb))
> > 		goto err;
> >
> > in both cases, since nothing more can't be filled after this?
> 
> Yes, you are right. Here is the patch with your suggestions in place, tested. 


Hmm... Of course, this patch looks fine too, but since I didn't
expect you respond so fast with a patch, I "forgot" to add a "if so"
question (sorry for this and for breaking this thread!):

If so, can't we make it all simpler now, without this new "error"
variable, and simply skipping this: "if (spd->nr_pages - nr_pages)"
test under "done:", so, doing this block unconditional or maybe (I
didn't check this enough) changing this test a little to catch there
this offset update for frag_list?

> 
> BTW, I have another trivial fix and a RFC related to tcp splice read that I've 
> sent a while ago. Should I resend them as well? 

Since this was quite a while ago, I guess you could. And, btw. maybe
try to Cc David Miller.

Thanks,
Jarek P.

> 
> Thanks,
> tavi
> commit b4671a70a6d70cdf11537a5231193271b06a3efa
> Author: Octavian Purdila <opurdila@ixiacom.com>
> Date:   Fri Jun 20 12:49:24 2008 +0300
> 
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
> index 25fa74d..4262006 100644
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
> @@ -1245,8 +1247,9 @@ static int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
>  		 * just jump directly to update and return, no point
>  		 * in going over fragments when the output is full.
>  		 */
> -		if (spd_fill_page(spd, virt_to_page(p), plen, poff, skb))
> -			goto done;
> +		error = spd_fill_page(spd, virt_to_page(p), plen, poff, skb);
> +		if (error)
> +			goto err;
>  
>  		tlen -= plen;
>  	}
> @@ -1275,8 +1278,9 @@ map_frag:
>  		if (!plen)
>  			break;
>  
> -		if (spd_fill_page(spd, f->page, plen, poff, skb))
> -			break;
> +		error = spd_fill_page(spd, f->page, plen, poff, skb);
> +		if (error)
> +			goto err;
>  
>  		tlen -= plen;
>  	}
> @@ -1288,7 +1292,10 @@ done:
>  		return 0;
>  	}
>  err:
> -	return 1;
> +	/* update the offset to reflect the linear part skip, if any */
> +	if (!error)
> +		*offset = toff;
> +	return error;
>  }
>  
>  /*


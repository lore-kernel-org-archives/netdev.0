From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RESEND] [PATCH] tcp: fix for splice receive when used with
	software LRO
Date: Sat, 21 Jun 2008 10:39:00 +0200
Message-ID: <20080621083900.GA2488@ami.dom.local>
References: <485B4ADE.8070102@domat.com.pl> <200806201309.35272.opurdila@ixiacom.com> <485C27C0.9070005@gmail.com> <200806210340.48479.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:18794 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755513AbYFUIjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2008 04:39:20 -0400
Received: by ug-out-1314.google.com with SMTP id h2so134891ugf.16
        for <netdev@vger.kernel.org>; Sat, 21 Jun 2008 01:39:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200806210340.48479.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 21, 2008 at 03:40:48AM +0300, Octavian Purdila wrote:
> On Saturday 21 June 2008, Jarek Poplawski wrote:
> 
> > Octavian, since these readability changes later in this thread are quite
> > substantial, my proposal is to separate them from this bug fix. I'll need
> > more time to check them, but they are probably rather for net-next, while
> > the bug fix could probably make to current. If you agree with this try to
> > resend this once more as a new thread with David in To or Cc (and maybe
> > re-diff this to more current tree). You can add my ack below if you like.
> >
> 
> Yes, I completely agree. Here is yet another patch which incorporates your 
> earlier suggestions, hope I get them right. Minimally tested, rediffed to 
> current net-2.6. I'll send this one to David once you acked it.
> 

Hmm..., I hope my ack will not hinder too much...

Thanks,
Jarek P.

PS: I see this other "readability" patch seems to change even more, so
I'll really need some free time to figure this out.

> commit 41f5beb8a6e12e0c2588aee82ba68c46baf9d5f2
> Author: Octavian Purdila <opurdila@ixiacom.com>
> Date:   Sat Jun 21 03:17:10 2008 +0300
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

Acked-by: Jarek Poplawski <jarkao2@gmail.com>

> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 1e556d3..d912982 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -1290,7 +1290,6 @@ static int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
>  			     unsigned int *total_len,
>  			     struct splice_pipe_desc *spd)
>  {
> -	unsigned int nr_pages = spd->nr_pages;
>  	unsigned int poff, plen, len, toff, tlen;
>  	int headlen, seg;
>  
> @@ -1340,7 +1339,7 @@ static int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
>  		 * in going over fragments when the output is full.
>  		 */
>  		if (spd_fill_page(spd, virt_to_page(p), plen, poff, skb))
> -			goto done;
> +			goto err;
>  
>  		tlen -= plen;
>  	}
> @@ -1370,17 +1369,15 @@ map_frag:
>  			break;
>  
>  		if (spd_fill_page(spd, f->page, plen, poff, skb))
> -			break;
> +			goto err;
>  
>  		tlen -= plen;
>  	}
>  
> -done:
> -	if (spd->nr_pages - nr_pages) {
> -		*offset = 0;
> -		*total_len = tlen;
> -		return 0;
> -	}
> +	*offset = toff;
> +	*total_len = tlen;
> +
> +	return 0;
>  err:
>  	return 1;
>  }


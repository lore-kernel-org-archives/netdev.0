From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gso: Handle new frag_list of frags GRO packets
Date: Tue, 12 Nov 2013 17:13:43 -0800
Message-ID: <1384305223.28458.58.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131104041108.GA22823@gondor.apana.org.au>
	 <20131106013038.GA14894@gondor.apana.org.au>
	 <20131106123900.GA20259@gondor.apana.org.au>
	 <20131106133045.GA20931@gondor.apana.org.au>
	 <20131106143927.GA21604@gondor.apana.org.au>
	 <1383767241.21999.9.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131107004339.GA28156@gondor.apana.org.au>
	 <20131107062234.GA31156@gondor.apana.org.au>
	 <20131107070335.GA31638@gondor.apana.org.au>
	 <20131107070647.GB31638@gondor.apana.org.au>
	 <20131111185207.GA12277@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:36882 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754327Ab3KMBNw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 20:13:52 -0500
Received: by mail-pd0-f173.google.com with SMTP id x10so2446110pdj.32
        for <netdev@vger.kernel.org>; Tue, 12 Nov 2013 17:13:51 -0800 (PST)
In-Reply-To: <20131111185207.GA12277@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-11-12 at 02:52 +0800, Herbert Xu wrote:
> Recently GRO started generating packets with frag_lists of frags.
> This was not handled by GSO, thus leading to a crash.
> 
> Thankfully these packets are of a regular form and are easy to
> handle.  This patch handles them in two ways.  For completely
> non-linear frag_list entries, we simply continue to iterate over
> the frag_list frags once we exhaust the normal frags.  For frag_list
> entries with linear parts, we call pskb_trim on the first part
> of the frag_list skb, and then process the rest of the frags in
> the usual way.
> 
> This patch also kills a chunk of dead frag_list code that has
> obviously never ever been run since it ends up generating a bogus
> GSO-segmented packet with a frag_list entry.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 3735fad..557e1a5 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -2776,6 +2776,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
>  	struct sk_buff *segs = NULL;
>  	struct sk_buff *tail = NULL;
>  	struct sk_buff *fskb = skb_shinfo(skb)->frag_list;
> +	skb_frag_t *skb_frag = skb_shinfo(skb)->frags;
>  	unsigned int mss = skb_shinfo(skb)->gso_size;
>  	unsigned int doffset = skb->data - skb_mac_header(skb);
>  	unsigned int offset = doffset;
> @@ -2815,16 +2816,38 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
>  		if (hsize > len || !sg)
>  			hsize = len;
>  
> -		if (!hsize && i >= nfrags) {
> -			BUG_ON(fskb->len != len);
> +		if (!hsize && i >= nfrags && skb_headlen(fskb) &&
> +		    (skb_headlen(fskb) == len || sg)) {
> +			BUG_ON(skb_headlen(fskb) > len);
> +

Hmm, yet another BUG_ON() case...

> +			i = 0;
> +			nfrags = skb_shinfo(fskb)->nr_frags;
> +			skb_frag = skb_shinfo(fskb)->frags;
> +			pos += skb_headlen(fskb);
> +
> +			while (pos < offset + len) {
> +				BUG_ON(i >= nfrags);
> +
> +				size = skb_frag_size(skb_frag);
> +				if (pos + size > offset + len)
> +					break;
> +
> +				i++;
> +				pos += size;
> +				skb_frag++;
> +			}
>  
> -			pos += len;
>  			nskb = skb_clone(fskb, GFP_ATOMIC);
>  			fskb = fskb->next;
>  
>  			if (unlikely(!nskb))
>  				goto err;
>  
> +			if (unlikely(pskb_trim(nskb, len))) {
> +				kfree_skb(nskb);
> +				goto err;
> +			}
> +

Note this pskb_trim() will reallocate/copy nskb head completely, since
nskb is a clone. (And increment page counts of frags, then eventually
decrement them)

I tested this patch one 'router', and it seems fine, although we consume
~90% more cpu doing the skb_segment() than not doing it.


GRO not building frag_list skbs :

lpaa6:~# mpstat -P 8 1 10
05:09:47 PM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest   %idle    intr/s
05:09:48 PM    8    0.00    0.00    1.01    0.00    3.03   23.23    0.00    0.00   72.73  43462.63
05:09:49 PM    8    0.00    0.00    0.00    0.00    5.10   28.57    0.00    0.00   66.33  88079.59
05:09:50 PM    8    0.00    0.00    0.00    0.00    2.13   17.02    0.00    0.00   80.85  41297.87
05:09:51 PM    8    0.00    0.00    0.95    0.00    3.81   29.52    0.00    0.00   65.71  45741.90
05:09:52 PM    8    0.00    0.00    0.00    0.00    2.11   17.89    0.00    0.00   80.00  25413.68
05:09:53 PM    8    1.03    0.00    1.03    0.00    2.06   20.62    0.00    0.00   75.26  36131.96
05:09:54 PM    8    0.00    0.00    0.94    0.00    3.77   30.19    0.00    0.00   65.09  47100.00
05:09:55 PM    8    0.00    0.00    0.00    0.00    3.26   21.74    0.00    0.00   75.00  71805.43
05:09:56 PM    8    0.00    0.00    0.00    0.00    3.19   22.34    0.00    0.00   74.47  70672.34
05:09:57 PM    8    0.00    0.00    0.00    0.00    4.50   32.43    0.00    0.00   63.06  45919.82
Average:       8    0.10    0.00    0.40    0.00    3.33   24.62    0.00    0.00   71.54  51339.66


Current GRO (large skbs -> need to split them with skb_segment(), no TSO is used)

lpaa6:~# mpstat -P 8 1 10
05:10:05 PM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest   %idle    intr/s
05:10:06 PM    8    0.00    0.00    0.00    0.00    8.16   44.90    0.00    0.00   46.94  88982.65
05:10:07 PM    8    0.00    0.00    1.05    0.00    8.42   50.53    0.00    0.00   40.00  54796.84
05:10:08 PM    8    0.00    0.00    1.94    0.00    8.74   52.43    0.00    0.00   36.89  50163.11
05:10:09 PM    8    0.00    0.00    0.00    0.00    7.14   39.80    0.00    0.00   53.06  85137.76
05:10:10 PM    8    0.00    0.00    0.00    0.00    8.08   44.44    0.00    0.00   47.47  42262.63
05:10:11 PM    8    0.00    0.00    0.00    0.00    8.00   53.00    0.00    0.00   39.00  53444.00
05:10:12 PM    8    0.00    0.00    0.00    0.00    5.00   27.50    0.00    0.00   67.50  91098.75
05:10:13 PM    8    0.00    0.00    0.00    0.00    8.55   47.86    0.00    0.00   43.59  34316.24
05:10:14 PM    8    0.00    0.00    0.00    0.00    8.70   48.91    0.00    0.00   42.39  56921.74
05:10:15 PM    8    0.00    0.00    0.93    0.00    7.41   46.30    0.00    0.00   45.37  77129.63
Average:       8    0.00    0.00    0.40    0.00    7.88   45.96    0.00    0.00   45.76  62458.99

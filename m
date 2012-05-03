From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [v2 PATCH 1/4] tcp: Fix truesize accounting in tcp_try_coalesce
Date: Thu, 03 May 2012 09:48:54 +0200
Message-ID: <1336031334.3503.23.camel@edumazet-glaptop>
References: <20120503071141.13636.37564.stgit@gitlad.jf.intel.com>
	 <20120503071859.13636.30050.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, edumazet@google.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:57600 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752970Ab2ECHs5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 03:48:57 -0400
Received: by eaaq12 with SMTP id q12so404467eaa.19
        for <netdev@vger.kernel.org>; Thu, 03 May 2012 00:48:56 -0700 (PDT)
In-Reply-To: <20120503071859.13636.30050.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-03 at 00:18 -0700, Alexander Duyck wrote:
> This patch addresses several issues in the way we were tracking the
> truesize in tcp_try_coalesce.
> 
> First it was using ksize which prevents us from having a 0 sized head frag
> and getting a usable result.  To resolve that this patch uses the end
> pointer which is set based off either ksize, or the frag_size supplied in
> build_skb.  This allows us to compute the original truesize of the entire
> buffer and remove that value leaving us with just what was added as pages.
> 
> The second issue was the use of skb->len if there is a mergeable head frag.
> We should only need to remove the size of an data aligned sk_buff from our
> current skb->truesize to compute the delta for a buffer with a reused head.
> By using skb->len the value of truesize was being artificially reduced
> which means that head frags could use more memory than buffers using
> standard allocations.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  net/ipv4/tcp_input.c |   10 ++++------
>  1 files changed, 4 insertions(+), 6 deletions(-)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index c6f78e2..3cb273a 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -4565,12 +4565,10 @@ merge:
>  	if (skb_headlen(from) == 0 &&
>  	    (skb_shinfo(to)->nr_frags +
>  	     skb_shinfo(from)->nr_frags <= MAX_SKB_FRAGS)) {
> -		WARN_ON_ONCE(from->head_frag);
> -		delta = from->truesize - ksize(from->head) -
> -			SKB_DATA_ALIGN(sizeof(struct sk_buff));
> -
> -		WARN_ON_ONCE(delta < len);
> +		delta = from->truesize -
> +			SKB_TRUESIZE(skb_end_pointer(from) - from->head);
>  copyfrags:
> +		WARN_ON_ONCE(delta < len);
>  		memcpy(skb_shinfo(to)->frags + skb_shinfo(to)->nr_frags,
>  		       skb_shinfo(from)->frags,
>  		       skb_shinfo(from)->nr_frags * sizeof(skb_frag_t));
> @@ -4600,7 +4598,7 @@ copyfrags:
>  		skb_fill_page_desc(to, skb_shinfo(to)->nr_frags,
>  				   page, offset, skb_headlen(from));
>  		*fragstolen = true;
> -		delta = len; /* we dont know real truesize... */
> +		delta = from->truesize - SKB_DATA_ALIGN(sizeof(struct sk_buff));
>  		goto copyfrags;
>  	}
>  	return false;
> 
> --

Acked-by: Eric Dumazet <edumazet@google.com>

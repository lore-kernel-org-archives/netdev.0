From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] core: adjust checks for calling skb_copy_bits
 in skb_try_coalesce
Date: Thu, 20 Sep 2012 07:20:17 +0200
Message-ID: <1348118417.31352.52.camel@edumazet-glaptop>
References: <1348111182-6827-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:50270 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742Ab2ITFUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 01:20:22 -0400
Received: by wgbdr13 with SMTP id dr13so126243wgb.1
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2012 22:20:21 -0700 (PDT)
In-Reply-To: <1348111182-6827-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-20 at 11:19 +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> Ensure that frags and frags_list of dst skb are empty if need to call
> skb_copy_bits, or else it will break the data sequence.
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  net/core/skbuff.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index fe00d12..f0b9446 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3455,15 +3455,15 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
>  	if (skb_cloned(to))
>  		return false;
>  
> -	if (len <= skb_tailroom(to)) {
> +	if (skb_has_frag_list(to) || skb_has_frag_list(from))
> +		return false;
> +
> +	if (len <= skb_tailroom(to) && !skb_shinfo(to)->nr_frags) {
>  		BUG_ON(skb_copy_bits(from, 0, skb_put(to, len), len));
>  		*delta_truesize = 0;
>  		return true;
>  	}
>  
> -	if (skb_has_frag_list(to) || skb_has_frag_list(from))
> -		return false;
> -
>  	if (skb_headlen(from) != 0) {
>  		struct page *page;
>  		unsigned int offset;

This is not needed at all.

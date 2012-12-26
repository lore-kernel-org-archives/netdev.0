From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V2] ipv6 mcast: Fix incorrect use of pskb_may_pull().
Date: Wed, 26 Dec 2012 08:03:12 -0800
Message-ID: <1356537792.20133.20451.camel@edumazet-glaptop>
References: <50DA6B0D.6010500@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:50668 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751772Ab2LZQDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2012 11:03:15 -0500
Received: by mail-pa0-f43.google.com with SMTP id fb10so4973351pad.2
        for <netdev@vger.kernel.org>; Wed, 26 Dec 2012 08:03:15 -0800 (PST)
In-Reply-To: <50DA6B0D.6010500@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-12-26 at 12:12 +0900, YOSHIFUJI Hideaki wrote:
> pskb_may_pull(skb, len) ensures that len bytes from skb->data
> are available in a linear array.  When pskb_may_pull() is
> being used multiple times for the same buffer without
> skb_pull(), the length is not accumulated.
> 
> For example, assuming that we have done:
>   pskb_may_pull(skb, sizeof(struct icmp6hdr))
> 
> Here, we have to do:
>   pskb_may_pull(skb, sizeof(struct mld2_query))
> instead of:
>   pskb_may_pull(skb, sizeof(struct mld2_query) -
>                 sizeof(struct icmp6hdr))
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
>  net/ipv6/mcast.c |   13 ++++++-------
>  1 file changed, 6 insertions(+), 7 deletions(-)
> 
> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> index 28dfa5f..5d91832 100644
> --- a/net/ipv6/mcast.c
> +++ b/net/ipv6/mcast.c
> @@ -1124,7 +1124,7 @@ int igmp6_event_query(struct sk_buff *skb)
>  	int mark = 0;
>  	int len;
>  
> -	if (!pskb_may_pull(skb, sizeof(struct in6_addr)))
> +	if (!pskb_may_pull(skb, sizeof(struct icmp6hdr) + sizeof(struct in6_addr)))
>  		return -EINVAL;
>  

I am a bit confused by your patch.

igmp6_event_query() is called from icmpv6_rcv() _after_ 

pskb_pull(skb, sizeof(*hdr);

(hdr being struct icmp6hdr)

So this patch is wrong IMHO

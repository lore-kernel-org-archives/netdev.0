From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: compute skb->rxhash if nic hash may be
 3-tuple
Date: Sat, 27 Oct 2012 12:05:42 +0200
Message-ID: <1351332342.30380.133.camel@edumazet-glaptop>
References: <1351288328-30147-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, netdev@vger.kernel.org
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:60208 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450Ab2J0KFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Oct 2012 06:05:45 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so1120640eaa.19
        for <netdev@vger.kernel.org>; Sat, 27 Oct 2012 03:05:44 -0700 (PDT)
In-Reply-To: <1351288328-30147-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-10-26 at 17:52 -0400, Willem de Bruijn wrote:
> Network device drivers can communicate a Toeplitz hash in skb->rxhash,
> but devices differ in their hashing capabilities. All compute a 5-tuple
> hash for TCP over IPv4, but for other connection-oriented protocols,
> they may compute only a 3-tuple. This breaks RPS load balancing, e.g.,
> for TCP over IPv6 flows. Additionally, for GRE and other tunnels,
> the kernel computes a 5-tuple hash over the inner packet if possible,
> but devices do not.
> 
> This patch recomputes the rxhash in software in all cases where it
> cannot be certain that a 5-tuple was computed. Device drivers can avoid
> recomputation by setting the skb->l4_rxhash flag.
> 
> Recomputing adds cycles to each packet when RPS is enabled or the
> packet arrives over a tunnel. A comparison of 200x TCP_STREAM between
> two servers running unmodified netnext with rxhash computation
> in hardware vs software (using ethtool -K eth0 rxhash [on|off]) shows
> how much time is spent in __skb_get_rxhash in this worst case:
> 
>      0.03%          swapper  [kernel.kallsyms]     [k] __skb_get_rxhash
>      0.03%          swapper  [kernel.kallsyms]     [k] __skb_get_rxhash
>      0.05%          swapper  [kernel.kallsyms]     [k] __skb_get_rxhash
> 
> With 200x TCP_RR it increases to
> 
>      0.10%          netperf  [kernel.kallsyms]     [k] __skb_get_rxhash
>      0.10%          netperf  [kernel.kallsyms]     [k] __skb_get_rxhash
>      0.10%          netperf  [kernel.kallsyms]     [k] __skb_get_rxhash
> 
> I considered having the patch explicitly skips recomputation when it knows
> that it will not improve the hash (TCP over IPv4), but that conditional
> complicates code without saving many cycles in practice, because it has
> to take place after flow dissector.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
>  include/linux/skbuff.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 6a2c34e..a2a0bdb 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -643,7 +643,7 @@ extern unsigned int   skb_find_text(struct sk_buff *skb, unsigned int from,
>  extern void __skb_get_rxhash(struct sk_buff *skb);
>  static inline __u32 skb_get_rxhash(struct sk_buff *skb)
>  {
> -	if (!skb->rxhash)
> +	if (!skb->l4_rxhash)
>  		__skb_get_rxhash(skb);
>  
>  	return skb->rxhash;

Acked-by: Eric Dumazet <edumazet@google.com>

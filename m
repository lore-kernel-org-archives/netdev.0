From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] Set skb->protocol properly before calling
 dst_output()
Date: Wed, 30 Nov 2016 12:38:32 -0500 (EST)
Message-ID: <20161130.123832.1622349914382224831.davem@davemloft.net>
References: <20161129023529.17645-1-elicooper@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: elicooper@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37224 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754171AbcK3Rig (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 12:38:36 -0500
In-Reply-To: <20161129023529.17645-1-elicooper@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cooper <elicooper@gmx.com>
Date: Tue, 29 Nov 2016 10:35:28 +0800

> When xfrm is applied to TSO/GSO packets, it follows this path:
> 
>     xfrm_output() -> xfrm_output_gso() -> skb_gso_segment()
> 
> where skb_gso_segment() relies on skb->protocol to function properly.
> 
> This patch sets skb->protocol properly before dst_output() is called,
> fixing a bug where GSO packets sent through a sit or ipip6 tunnel are
> dropped when xfrm is involved.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Eli Cooper <elicooper@gmx.com>
> ---
>  net/ipv4/ip_output.c   | 4 +++-
>  net/ipv6/output_core.c | 4 +++-
>  2 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index 105908d..0180e44 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -117,8 +117,10 @@ int ip_local_out(struct net *net, struct sock *sk, struct sk_buff *skb)
>  	int err;
>  
>  	err = __ip_local_out(net, sk, skb);
> -	if (likely(err == 1))
> +	if (likely(err == 1)) {
> +		skb->protocol = htons(ETH_P_IP);
>  		err = dst_output(net, sk, skb);
> +	}
>  

__ip_local_out() potentially does a dst_output() call too via the
netfilter hook, so you definitely need to place the skb->protocol
assignment before that netfilter hook.

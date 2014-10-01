From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] udp: increment UDP_NO_PORTS when dropping
 unmatched multicasts
Date: Wed, 01 Oct 2014 08:41:23 -0700
Message-ID: <1412178083.16704.56.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141001151921.7131E29003A2@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Rick Jones <raj@tardy.usa.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:50164 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330AbaJAPlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 11:41:15 -0400
Received: by mail-pa0-f53.google.com with SMTP id kq14so483356pab.26
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 08:41:14 -0700 (PDT)
In-Reply-To: <20141001151921.7131E29003A2@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-10-01 at 08:19 -0700, Rick Jones wrote:
> From: Rick Jones <rick.jones2@hp.com>
> 
> When there is absolutely no match for an incoming UDP multicast we
> should increment a suitable UDP statistic in addition to the kfree_skb().
> When there were some matches, we should not and simply call consume_skb().
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>
> 
> ---
> 
> Noticed __udp4_lib_mcast_deliver showing-up in a perf dropped packet
> profile on a system sitting on a network with a bunch of Windows boxes
> sending what they are fond of sending.
> 
> Verified that UDP_MIB_NOPORTS increments when it was not before and hit
> the system with a bit of netperf multicast UDP_RR but that is the extent
> of the testing performed.
> 
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index cd0db54..376e3d3 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1656,6 +1656,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
>  	int dif = skb->dev->ifindex;
>  	unsigned int count = 0, offset = offsetof(typeof(*sk), sk_nulls_node);
>  	unsigned int hash2 = 0, hash2_any = 0, use_hash2 = (hslot->count > 10);
> +	unsigned int inner_flushed = 0;
>  
>  	if (use_hash2) {
>  		hash2_any = udp4_portaddr_hash(net, htonl(INADDR_ANY), hnum) &
> @@ -1694,8 +1695,12 @@ start_lookup:
>  	 */
>  	if (count) {
>  		flush_stack(stack, count, skb, count - 1);
> -	} else {
> +	} else if (!inner_flushed) {
> +		UDP_INC_STATS_BH(net, UDP_MIB_NOPORTS, 0);
>  		kfree_skb(skb);
> +	} else {
> +		/* there were matches flushed in the for_each */
> +		consume_skb(skb);
>  	}
>  	return 0;
>  }

It seems you imply UDP Lite do not use multicast ?

I believe we allow them, so you need to add a 'int proto' parameter to
__udp4_lib_mcast_deliver()

Also, please take care of IPv6 in the same time/patch.

Thanks

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] udp: increment UDP_NO_PORTS when dropping unmatched
 multicasts
Date: Wed, 01 Oct 2014 21:14:31 +0400
Message-ID: <542C3677.5020505@cogentembedded.com>
References: <20141001151921.7131E29003A2@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Rick Jones <raj@tardy.usa.hp.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:63152 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752976AbaJAROg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 13:14:36 -0400
Received: by mail-la0-f42.google.com with SMTP id mk6so814751lab.15
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 10:14:34 -0700 (PDT)
In-Reply-To: <20141001151921.7131E29003A2@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/01/2014 07:19 PM, Rick Jones wrote:

> From: Rick Jones <rick.jones2@hp.com>

> When there is absolutely no match for an incoming UDP multicast we
> should increment a suitable UDP statistic in addition to the kfree_skb().
> When there were some matches, we should not and simply call consume_skb().

> Signed-off-by: Rick Jones <rick.jones2@hp.com>

> ---

> Noticed __udp4_lib_mcast_deliver showing-up in a perf dropped packet
> profile on a system sitting on a network with a bunch of Windows boxes
> sending what they are fond of sending.

> Verified that UDP_MIB_NOPORTS increments when it was not before and hit
> the system with a bit of netperf multicast UDP_RR but that is the extent
> of the testing performed.

> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index cd0db54..376e3d3 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1656,6 +1656,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
>   	int dif = skb->dev->ifindex;
>   	unsigned int count = 0, offset = offsetof(typeof(*sk), sk_nulls_node);
>   	unsigned int hash2 = 0, hash2_any = 0, use_hash2 = (hslot->count > 10);
> +	unsigned int inner_flushed = 0;
>
>   	if (use_hash2) {
>   		hash2_any = udp4_portaddr_hash(net, htonl(INADDR_ANY), hnum) &
> @@ -1694,8 +1695,12 @@ start_lookup:
>   	 */
>   	if (count) {
>   		flush_stack(stack, count, skb, count - 1);
> -	} else {
> +	} else if (!inner_flushed) {

    I don't see where this new variable is changed. It's always 0 here.

> +		UDP_INC_STATS_BH(net, UDP_MIB_NOPORTS, 0);
>   		kfree_skb(skb);
> +	} else {
> +		/* there were matches flushed in the for_each */
> +		consume_skb(skb);
>   	}
>   	return 0;
>   }

WBR, Sergei

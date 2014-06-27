From: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kvGyRCNUhGIzFRTEAbKEI=?=
	<hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH v3 net] ipv6: Fix MLD Query message check
Date: Fri, 27 Jun 2014 11:11:33 +0900
Message-ID: <53ACD2D5.4000207@miraclelinux.com>
References: <1403834273-5147-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	network dev <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Hangbin Liu <liuhangbin@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og114.obsmtp.com ([64.18.2.215]:37187 "HELO
	exprod7og114.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751139AbaF0CLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 22:11:36 -0400
Received: by mail-pb0-f43.google.com with SMTP id um1so3922468pbc.30
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2014 19:11:35 -0700 (PDT)
In-Reply-To: <1403834273-5147-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hangbin Liu wrote:
> Based on RFC3810 6.2, we also need to check the hop limit and router alert
> option besides source address.
> 
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

> ---
>   net/ipv6/mcast.c | 13 +++++++++++--
>   1 file changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> index 08b367c..617f095 100644
> --- a/net/ipv6/mcast.c
> +++ b/net/ipv6/mcast.c
> @@ -1301,8 +1301,17 @@ int igmp6_event_query(struct sk_buff *skb)
>   	len = ntohs(ipv6_hdr(skb)->payload_len) + sizeof(struct ipv6hdr);
>   	len -= skb_network_header_len(skb);
>   
> -	/* Drop queries with not link local source */
> -	if (!(ipv6_addr_type(&ipv6_hdr(skb)->saddr) & IPV6_ADDR_LINKLOCAL))
> +	/* RFC3810 6.2
> +	 * Upon reception of an MLD message that contains a Query, the node
> +	 * checks if the source address of the message is a valid link-local
> +	 * address, if the Hop Limit is set to 1, and if the Router Alert
> +	 * option is present in the Hop-By-Hop Options header of the IPv6
> +	 * packet.  If any of these checks fails, the packet is dropped.
> +	 */
> +	if (!(ipv6_addr_type(&ipv6_hdr(skb)->saddr) & IPV6_ADDR_LINKLOCAL) ||
> +	    ipv6_hdr(skb)->hop_limit != 1 ||
> +	    !(IP6CB(skb)->flags & IP6SKB_ROUTERALERT) ||
> +	    IP6CB(skb)->ra != htons(IPV6_OPT_ROUTERALERT_MLD))
>   		return -EINVAL;
>   
>   	idev = __in6_dev_get(skb->dev);
> 

--yoshfuji

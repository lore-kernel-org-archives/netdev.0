From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-next] ipv6: Use ipv6_is_mld() in ip6_mc_input().
Date: Sun, 13 Jan 2013 17:43:44 +0900
Message-ID: <50F273C0.6080901@linux-ipv6.org>
References: <50F27111.9020001@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:37832 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751713Ab3AMInq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 03:43:46 -0500
In-Reply-To: <50F27111.9020001@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki wrote:
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
>  include/net/addrconf.h |    2 +-
>  net/ipv6/ip6_input.c   |   21 +++------------------
>  net/ipv6/mcast.c       |    4 ++--
>  3 files changed, 6 insertions(+), 21 deletions(-)
> 
> diff --git a/include/net/addrconf.h b/include/net/addrconf.h
> index df4ef94..59f14ab 100644
> --- a/include/net/addrconf.h
> +++ b/include/net/addrconf.h
> @@ -150,7 +150,7 @@ extern void addrconf_dad_failure(struct inet6_ifaddr *ifp);
>  extern bool ipv6_chk_mcast_addr(struct net_device *dev,
>  				const struct in6_addr *group,
>  				const struct in6_addr *src_addr);
> -extern bool ipv6_is_mld(struct sk_buff *skb, int nexthdr);
> +extern bool ipv6_is_mld(struct sk_buff *skb, int nexthdr, int offset);
>  
>  extern void addrconf_prefix_rcv(struct net_device *dev,
>  				u8 *opt, int len, bool sllao);
> diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
> index a52d864..6de509e 100644
> --- a/net/ipv6/ip6_input.c
> +++ b/net/ipv6/ip6_input.c
> @@ -212,7 +212,7 @@ resubmit:
>  			if (ipv6_addr_is_multicast(&hdr->daddr) &&
>  			    !ipv6_chk_mcast_addr(skb->dev, &hdr->daddr,
>  			    &hdr->saddr) &&
> -			    !ipv6_is_mld(skb, nexthdr))
> +			    !ipv6_is_mld(skb, nexthdr, 0))
>  				goto discard;
>  		}
>  		if (!(ipprot->flags & INET6_PROTO_NOPOLICY) &&
> @@ -283,7 +283,6 @@ int ip6_mc_input(struct sk_buff *skb)
>  		if (unlikely(opt->ra)) {
>  			/* Check if this is a mld message */
>  			u8 *ptr = skb_network_header(skb) + opt->ra;
> -			struct icmp6hdr *icmp6;
>  			u8 nexthdr = hdr->nexthdr;
>  			__be16 frag_off;
>  			int offset;
> @@ -303,24 +302,10 @@ int ip6_mc_input(struct sk_buff *skb)
>  				if (offset < 0)
>  					goto out;
>  
> -				if (nexthdr != IPPROTO_ICMPV6)
> +				if (!ipv6_is_mld(skb, offset, nexthdr))
>  					goto out;
>  
> -				if (!pskb_may_pull(skb, (skb_network_header(skb) +
> -						   offset + 1 - skb->data)))
> -					goto out;
> -
> -				icmp6 = (struct icmp6hdr *)(skb_network_header(skb) + offset);
> -
> -				switch (icmp6->icmp6_type) {
> -				case ICMPV6_MGM_QUERY:
> -				case ICMPV6_MGM_REPORT:
> -				case ICMPV6_MGM_REDUCTION:
> -				case ICMPV6_MLD2_REPORT:
> -					deliver = true;
> -					break;
> -				}
> -				goto out;
> +				deliver = true;
>  			}
>  			/* unknown RA - process it normally */
>  		}
> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> index 28dfa5f..b529c27 100644
> --- a/net/ipv6/mcast.c
> +++ b/net/ipv6/mcast.c
> @@ -937,14 +937,14 @@ int ipv6_dev_mc_dec(struct net_device *dev, const struct in6_addr *addr)
>  /*
>   * identify MLD packets for MLD filter exceptions
>   */
> -bool ipv6_is_mld(struct sk_buff *skb, int nexthdr)
> +bool ipv6_is_mld(struct sk_buff *skb, int nexthdr, int offset)
>  {
>  	struct icmp6hdr *pic;
>  
>  	if (nexthdr != IPPROTO_ICMPV6)
>  		return false;
>  
> -	if (!pskb_may_pull(skb, sizeof(struct icmp6hdr)))
> +	if (!pskb_may_pull(skb, offset + sizeof(struct icmp6hdr)))
>  		return false;
>  
>  	pic = icmp6_hdr(skb);
> 

Sorry I found some bugs, I'll repost.

--yoshfuji

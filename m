From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2/4] [IPv6] Add multicast address type inline
Date: Fri, 06 Apr 2007 12:42:23 +0900 (JST)
Message-ID: <20070406.124223.50050898.yoshfuji@linux-ipv6.org>
References: <117582818660-git-send-email-brian.haley@hp.com>
	<151538c13022864224f5ff440e1147f884abb492.1175794415.git.brian.haley@hp.com>
	<4615BCAC.8010201@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:40420 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073AbXDFDlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2007 23:41:31 -0400
In-Reply-To: <4615BCAC.8010201@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <4615BCAC.8010201@hp.com> (at Thu, 05 Apr 2007 23:21:16 -0400), Brian Haley <brian.haley@hp.com> says:

> Add multicast address type inline to avoid calls to ipv6_addr_type().
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>
> ---
>   include/net/ipv6.h    |    5 +++++
>   net/ipv6/icmp.c       |   12 ++++--------
>   net/ipv6/ip6_tunnel.c |    4 ++--
>   net/ipv6/route.c      |    4 ++--
>   4 files changed, 13 insertions(+), 12 deletions(-)
> 
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index d473789..a888b0e 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -439,6 +439,11 @@ static inline int ipv6_addr_scope_sitelocal(const struct in6_addr *a)
>   	return ((a->s6_addr32[0] & htonl(0xFFC00000)) == htonl(0xFEC00000));
>   }
> 
> +static inline int ipv6_addr_type_multicast(const struct in6_addr *a)
> +{
> +	return ((a->s6_addr32[0] & htonl(0xFF000000)) == htonl(0xFF000000));
> +}
> +

Matter of taste, but I prefer ipv6_addr_multicast() to align
with ipv6_addr_any().

> diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
> index e94992a..709037f 100644
> --- a/net/ipv6/icmp.c
> +++ b/net/ipv6/icmp.c
> @@ -312,7 +312,6 @@ void icmpv6_send(struct sk_buff *skb, int type, int code, __u32 info,
>   	struct flowi fl;
>   	struct icmpv6_msg msg;
>   	int iif = 0;
> -	int addr_type = 0;
>   	int len;
>   	int hlimit, tclass;
>   	int err = 0;
> @@ -327,8 +326,6 @@ void icmpv6_send(struct sk_buff *skb, int type, int code, __u32 info,
>   	 *	Rule (e.1) is enforced by not using icmpv6_send
>   	 *	in any code that processes icmp errors.
>   	 */
> -	addr_type = ipv6_addr_type(&hdr->daddr);
> -
>   	if (ipv6_chk_addr(&hdr->daddr, skb->dev, 0))
>   		saddr = &hdr->daddr;
> 
> @@ -336,7 +333,7 @@ void icmpv6_send(struct sk_buff *skb, int type, int code, __u32 info,
>   	 *	Dest addr check
>   	 */
> 
> -	if ((addr_type & IPV6_ADDR_MULTICAST || skb->pkt_type != PACKET_HOST)) {
> +	if (ipv6_addr_type_multicast(&hdr->daddr) || skb->pkt_type != PACKET_HOST) {
>   		if (type != ICMPV6_PKT_TOOBIG &&
>   		    !(type == ICMPV6_PARAMPROB &&
>   		      code == ICMPV6_UNK_OPTION &&

I think this is okay.

> @@ -346,13 +343,11 @@ void icmpv6_send(struct sk_buff *skb, int type, int code, __u32 info,
>   		saddr = NULL;
>   	}
> 
> -	addr_type = ipv6_addr_type(&hdr->saddr);
> -
>   	/*
>   	 *	Source addr check
>   	 */
> 
> -	if (addr_type & IPV6_ADDR_LINKLOCAL)
> +	if (ipv6_addr_scope_linklocal(&hdr->saddr))
>   		iif = skb->dev->ifindex;
> 
>   	/*

No, this is not identical.

> @@ -361,7 +356,8 @@ void icmpv6_send(struct sk_buff *skb, int type, int code, __u32 info,
>   	 *	We check unspecified / multicast addresses here,
>   	 *	and anycast addresses will be checked later.
>   	 */
> -	if ((addr_type == IPV6_ADDR_ANY) || (addr_type & IPV6_ADDR_MULTICAST)) {
> +	if (ipv6_addr_any(&hdr->saddr) ||
> +	    ipv6_addr_type_multicast(&hdr->saddr)) {
>   		LIMIT_NETDEBUG(KERN_DEBUG "icmpv6_send: addr_any/mcast source\n");
>   		return;
>   	}

I guess ipv6_addr_multicast() || ipv6_addr_any() is better.

> diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
> index a0902fb..0dd1f63 100644
> --- a/net/ipv6/ip6_tunnel.c
> +++ b/net/ipv6/ip6_tunnel.c
> @@ -1111,8 +1111,8 @@ static void ip6_tnl_link_config(struct ip6_tnl *t)
>   	dev->iflink = p->link;
> 
>   	if (p->flags & IP6_TNL_F_CAP_XMIT) {
> -		int strict = (ipv6_addr_type(&p->raddr) &
> -			      (IPV6_ADDR_MULTICAST|IPV6_ADDR_LINKLOCAL));
> +		int strict = ipv6_addr_type_multicast(&p->raddr) ||
> +			     ipv6_addr_scope_linklocal(&p->raddr);
> 
>   		struct rt6_info *rt = rt6_lookup(&p->raddr, &p->laddr,
>   						 p->link, strict);

Different logic, but seems sane.

> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 53d79ac..32c6398 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -227,8 +227,8 @@ static __inline__ int rt6_check_expired(const struct rt6_info *rt)
> 
>   static inline int rt6_need_strict(struct in6_addr *daddr)
>   {
> -	return (ipv6_addr_type(daddr) &
> -		(IPV6_ADDR_MULTICAST | IPV6_ADDR_LINKLOCAL));
> +	return (ipv6_addr_is_multicast(daddr) ||
> +		ipv6_addr_scope_linklocal(daddr));
>   }
> 

ditto.

--yoshfuji

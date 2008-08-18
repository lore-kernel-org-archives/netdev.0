From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] IPv6:fix the return interface index when get it while
 no message is received
Date: Mon, 18 Aug 2008 09:31:07 -0400
Message-ID: <48A9799B.4040409@hp.com>
References: <48A911AD.7060102@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: Yang Hongyang <yanghy@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:46734 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752115AbYHRNbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 09:31:20 -0400
In-Reply-To: <48A911AD.7060102@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yang Hongyang wrote:
> When get receiving interface index while no message is received,
> the bounded device's index of the socket should be returned.
> 
> RFC 3542:
>    Issuing getsockopt() for the above options will return the sticky
>    option value i.e., the value set with setsockopt().  If no sticky
>    option value has been set getsockopt() will return the following
>    values:
> 
>    -  For the IPV6_PKTINFO option, it will return an in6_pktinfo
>       structure with ipi6_addr being in6addr_any and ipi6_ifindex being
>       zero.
> 
> 
> Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>
> 
> ---
>  ipv6_sockglue.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
> index 2cabac9..e4f8d29 100644
> --- a/net/ipv6/ipv6_sockglue.c
> +++ b/net/ipv6/ipv6_sockglue.c
> @@ -911,7 +911,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
>  		} else {
>  			if (np->rxopt.bits.rxinfo) {
>  				struct in6_pktinfo src_info;
> -				src_info.ipi6_ifindex = np->mcast_oif;
> +				src_info.ipi6_ifindex = np->mcast_oif ? np->mcast_oif : sk->sk_bound_dev_if;
>  				ipv6_addr_copy(&src_info.ipi6_addr, &np->daddr);
>  				put_cmsg(&msg, SOL_IPV6, IPV6_PKTINFO, sizeof(src_info), &src_info);
>  			}
> @@ -921,7 +921,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
>  			}
>  			if (np->rxopt.bits.rxoinfo) {
>  				struct in6_pktinfo src_info;
> -				src_info.ipi6_ifindex = np->mcast_oif;
> +				src_info.ipi6_ifindex = np->mcast_oif ? np->mcast_oif : sk->sk_bound_dev_if;
>  				ipv6_addr_copy(&src_info.ipi6_addr, &np->daddr);
>  				put_cmsg(&msg, SOL_IPV6, IPV6_2292PKTINFO, sizeof(src_info), &src_info);
>  			}


I don't think that's correct at all.  The code path shows here is when there are no received
options and no sticky options set.  In such case, we shouldn't be returning multicast or
bound interfaces.  We should be returning 0.

Additionally the address returned is completely bogus as well.  We are returning the
address our peer instead of the one of our own addresses.

-vlad



From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-next 1/2] net: ipv6: add tokenized interface identifier
 support
Date: Fri, 05 Apr 2013 01:29:34 +0900
Message-ID: <515DAA6E.1050407@linux-ipv6.org>
References: <1365086258-4512-1-git-send-email-dborkman@redhat.com> <1365086258-4512-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:33867 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1763089Ab3DDQ3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 12:29:48 -0400
In-Reply-To: <1365086258-4512-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Borkmann wrote:
> This patch adds support for tokenized IIDs, that allow for
> administrators to assign well-known host-part addresses to
> nodes whilst still obtaining global network prefix from
> Router Advertisements. It is currently in IETF RFC draft
> status [1]:
> 
>   The primary target for such support is server platforms
>   where addresses are usually manually configured, rather
>   than using DHCPv6 or SLAAC. By using tokenised identifiers,
>   hosts can still determine their network prefix by use of
>   SLAAC, but more readily be automatically renumbered should
>   their network prefix change.
> 
>  [1] http://tools.ietf.org/html/draft-chown-6man-tokenised-ipv6-identifiers-02
> 
> The implementation is partially based on top of Mark K.
> Thompson's proof of concept. Successfully tested by myself.
> 
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  include/net/if_inet6.h       |    2 +
>  include/net/ipv6.h           |    2 +
>  include/uapi/linux/if_link.h |    1 +
>  net/ipv6/addrconf.c          |   87 ++++++++++++++++++++++++++++++++++++++++-
>  net/ipv6/addrconf_core.c     |    2 -
>  5 files changed, 89 insertions(+), 5 deletions(-)
> 
> diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
> index 9356322..f1063d6 100644
> --- a/include/net/if_inet6.h
> +++ b/include/net/if_inet6.h
> @@ -187,6 +187,8 @@ struct inet6_dev {
>  	struct list_head	tempaddr_list;
>  #endif
>  
> +	struct in6_addr		token;
> +
>  	struct neigh_parms	*nd_parms;
>  	struct inet6_dev	*next;
>  	struct ipv6_devconf	cnf;
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index 0810aa5..da8c11e 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -88,6 +88,8 @@
>  #define IPV6_ADDR_SCOPE_ORGLOCAL	0x08
>  #define IPV6_ADDR_SCOPE_GLOBAL		0x0e
>  
> +#define IPV6_ADDR_SCOPE_TYPE(scope)	((scope) << 16)
> +
>  /*
>   *	Addr flags
>   */
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index c4edfe1..6b35c42 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -201,6 +201,7 @@ enum {
>  	IFLA_INET6_MCAST,	/* MC things. What of them?	*/
>  	IFLA_INET6_CACHEINFO,	/* time values and max reasm size */
>  	IFLA_INET6_ICMP6STATS,	/* statistics (icmpv6)		*/
> +	IFLA_INET6_TOKEN,	/* device token			*/
>  	__IFLA_INET6_MAX
>  };
>  
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index a33b157..fb0e8a0 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -422,6 +422,7 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
>  		ipv6_regen_rndid((unsigned long) ndev);
>  	}
>  #endif
> +	memset(ndev->token.s6_addr, 0, sizeof(ndev->token.s6_addr));
>  
>  	if (netif_running(dev) && addrconf_qdisc_ok(dev))
>  		ndev->if_flags |= IF_READY;
> @@ -2136,8 +2137,14 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
>  
>  		if (pinfo->prefix_len == 64) {
>  			memcpy(&addr, &pinfo->prefix, 8);
> -			if (ipv6_generate_eui64(addr.s6_addr + 8, dev) &&
> -			    ipv6_inherit_eui64(addr.s6_addr + 8, in6_dev)) {
> +
> +			if (!ipv6_addr_any(&in6_dev->token)) {
> +				read_lock_bh(&in6_dev->lock);
> +				memcpy(addr.s6_addr + 8,
> +				       in6_dev->token.s6_addr + 8, 8);
> +				read_unlock_bh(&in6_dev->lock);
> +			} else if (ipv6_generate_eui64(addr.s6_addr + 8, dev) &&
> +				   ipv6_inherit_eui64(addr.s6_addr + 8, in6_dev)) {
>  				in6_dev_put(in6_dev);
>  				return;
>  			}

Why not initialize token by interface-identifier and then allow
users to "override"?

--yoshfuji

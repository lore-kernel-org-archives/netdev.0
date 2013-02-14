From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH net-next 2/3] ipv6: use newly introduced __ipv6_addr_needs_scope_id
 and ipv6_iface_scope_id
Date: Thu, 14 Feb 2013 10:25:46 -0500
Message-ID: <511D01FA.8080506@hp.com>
References: <20130212221634.GA7212@order.stressinduktion.org> <20130213001357.GB1096@order.stressinduktion.org> <511AFF9A.8040506@hp.com> <511BC3B3.3070405@linux-ipv6.org> <20130214042543.GB24534@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:17530 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758140Ab3BNPZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 10:25:52 -0500
In-Reply-To: <20130214042543.GB24534@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/13/2013 11:25 PM, Hannes Frederic Sowa wrote:
> On Thu, Feb 14, 2013 at 01:47:47AM +0900, YOSHIFUJI Hideaki wrote:
>> If you have several address checks around, please use ipv6_addr_type()
>> (or __ipv6_addr_type()).  Above "direct" checks should be used only for
>> single-shot test.  But well, I have to agree that ipv6_addr_type and
>> friends is becoming complex.  In mid-term, I would like to take look
>> at it.  I might think of having addr_type for src/dst in skb->cb
>> after all.
> 
> What do you think about the attached patch?  If you agree with the changes I
> would test it tomorrow and rebase my other patches ontop. The changes are only
> compile tested.
> 
> [PATCH net-next RFC] ipv6: introduce new type ipv6_addr_props to hold type and scope
> 
> ---
>  include/net/ipv6.h       | 16 +++++---
>  net/ipv6/addrconf.c      | 27 +++++++-------
>  net/ipv6/addrconf_core.c | 97 +++++++++++++++++++++++++++++++-----------------
>  net/ipv6/datagram.c      | 12 +++---
>  4 files changed, 95 insertions(+), 57 deletions(-)
> 
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index 851d541..3a3ec1cc 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -298,20 +298,26 @@ static inline int ip6_frag_mem(struct net *net)
>  #define IPV6_FRAG_LOW_THRESH	(3 * 1024*1024)	/* 3145728 */
>  #define IPV6_FRAG_TIMEOUT	(60 * HZ)	/* 60 seconds */
>  
> -extern int __ipv6_addr_type(const struct in6_addr *addr);
> +struct ipv6_addr_props {
> +	u16 type;
> +	s16 scope;
> +};

Seeing this makes me think we should unify the flags and scope members of
inet6_ifaddr to something like this, moving to a single set of values for IPv6
addresses.  Then ipv6_dev_get_saddr() wouldn't have to use __ipv6_adr_type() as
much since the address struct would already have the values.  Possible future
work...

> diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
> index d051e5f..cb3eb1d 100644
> --- a/net/ipv6/addrconf_core.c
> +++ b/net/ipv6/addrconf_core.c
> @@ -6,75 +6,104 @@
>  #include <linux/export.h>
>  #include <net/ipv6.h>
>  
> -#define IPV6_ADDR_SCOPE_TYPE(scope)	((scope) << 16)
> -
> -static inline unsigned int ipv6_addr_scope2type(unsigned int scope)
> +static inline struct ipv6_addr_props ipv6_addr_scope2type(unsigned int scope)
>  {

Rename to ipv6_addr_mc_props() ?

>  	switch (scope) {
>  	case IPV6_ADDR_SCOPE_NODELOCAL:
> -		return (IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_NODELOCAL) |
> -			IPV6_ADDR_LOOPBACK);
> +		return (struct ipv6_addr_props){
> +			.type = IPV6_ADDR_MULTICAST|IPV6_ADDR_LOOPBACK,
> +			.scope = IPV6_ADDR_SCOPE_NODELOCAL
> +		};
>  	case IPV6_ADDR_SCOPE_LINKLOCAL:
> -		return (IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_LINKLOCAL) |
> -			IPV6_ADDR_LINKLOCAL);
> +		return (struct ipv6_addr_props){
> +			.type = IPV6_ADDR_MULTICAST|IPV6_ADDR_LINKLOCAL,
> +			.scope = IPV6_ADDR_SCOPE_LINKLOCAL
> +		};
>  	case IPV6_ADDR_SCOPE_SITELOCAL:
> -		return (IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_SITELOCAL) |
> -			IPV6_ADDR_SITELOCAL);
> +		return (struct ipv6_addr_props){
> +			.type = IPV6_ADDR_MULTICAST|IPV6_ADDR_SITELOCAL,
> +			.scope = IPV6_ADDR_SCOPE_SITELOCAL
> +		};
>  	}
> -	return IPV6_ADDR_SCOPE_TYPE(scope);
> +	return (struct ipv6_addr_props){
> +		.type = IPV6_ADDR_MULTICAST,
> +		.scope = scope
> +	};
>  }
>  
> -int __ipv6_addr_type(const struct in6_addr *addr)
> +struct ipv6_addr_props __ipv6_addr_type(const struct in6_addr *addr)

Should this be __ipv6_addr_props() now?  It's always returned type and scope,
but now it's more obvious with the return value.

>  {
> -	__be32 st;
> -
> -	st = addr->s6_addr32[0];
> +	__be32 st = addr->s6_addr32[0];
>  
>  	/* Consider all addresses with the first three bits different of
>  	   000 and 111 as unicasts.
>  	 */
>  	if ((st & htonl(0xE0000000)) != htonl(0x00000000) &&
>  	    (st & htonl(0xE0000000)) != htonl(0xE0000000))
> -		return (IPV6_ADDR_UNICAST |
> -			IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL));
> +		return (struct ipv6_addr_props){
> +			.type = IPV6_ADDR_UNICAST,
> +			.scope = IPV6_ADDR_SCOPE_GLOBAL
> +		};
>  
>  	if ((st & htonl(0xFF000000)) == htonl(0xFF000000)) {
>  		/* multicast */
>  		/* addr-select 3.1 */
> -		return (IPV6_ADDR_MULTICAST |
> -			ipv6_addr_scope2type(IPV6_ADDR_MC_SCOPE(addr)));
> +		return ipv6_addr_scope2type(IPV6_ADDR_MC_SCOPE(addr));
>  	}
>  
>  	if ((st & htonl(0xFFC00000)) == htonl(0xFE800000))
> -		return (IPV6_ADDR_LINKLOCAL | IPV6_ADDR_UNICAST |
> -			IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_LINKLOCAL));		/* addr-select 3.1 */
> +		/* addr-select 3.1 */
> +		return (struct ipv6_addr_props){
> +			.type = IPV6_ADDR_LINKLOCAL|IPV6_ADDR_UNICAST,
> +			.scope = IPV6_ADDR_SCOPE_LINKLOCAL
> +		};
>  	if ((st & htonl(0xFFC00000)) == htonl(0xFEC00000))
> -		return (IPV6_ADDR_SITELOCAL | IPV6_ADDR_UNICAST |
> -			IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_SITELOCAL));		/* addr-select 3.1 */
> +		/* addr-select 3.1 */
> +		return (struct ipv6_addr_props){
> +			.type = IPV6_ADDR_LINKLOCAL|IPV6_ADDR_UNICAST,
> +			.scope = IPV6_ADDR_SCOPE_SITELOCAL,
> +		};

type here is wrong, should be IPV6_ADDR_SITELOCAL not linklocal.

> diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
> index f5a5478..e859899 100644
> --- a/net/ipv6/datagram.c
> +++ b/net/ipv6/datagram.c
> @@ -614,7 +614,7 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
>  	int err = 0;
>  
>  	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
> -		int addr_type;
> +		struct ipv6_addr_props addr_props;
>  
>  		if (!CMSG_OK(msg, cmsg)) {
>  			err = -EINVAL;
> @@ -644,7 +644,7 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
>  				fl6->flowi6_oif = src_info->ipi6_ifindex;
>  			}
>  
> -			addr_type = __ipv6_addr_type(&src_info->ipi6_addr);
> +			addr_props = __ipv6_addr_type(&src_info->ipi6_addr);
>  
>  			rcu_read_lock();
>  			if (fl6->flowi6_oif) {
> @@ -653,13 +653,15 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
>  					rcu_read_unlock();
>  					return -ENODEV;
>  				}
> -			} else if (addr_type & IPV6_ADDR_LINKLOCAL) {
> +			} else if (addr_props.type & IPV6_ADDR_LINKLOCAL) {

Could be (addr_props.scope == IPV6_ADDR_SCOPE_LINKLOCAL), right?

-Brian

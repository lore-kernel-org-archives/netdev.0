From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-next v3 2/4] ipv6: use newly introduced __ipv6_addr_needs_scope_id
 and ipv6_iface_scope_id
Date: Fri, 08 Mar 2013 11:21:04 +0900
Message-ID: <51394B10.5020804@linux-ipv6.org>
References: <20130307210533.GA23676@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:40180 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751029Ab3CHCVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 21:21:05 -0500
In-Reply-To: <20130307210533.GA23676@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa wrote:
> This patch requires multicast interface-scoped addresses to supply a
> sin6_scope_id. Because the sin6_scope_id is now also correctly used
> in case of interface-scoped multicast traffic this enables one to use
> interface scoped addresses over interfaces which are not targeted by the
> default multicast route (the route has to be put there manually, though).
> 
> getsockname() and getpeername() now return the correct sin6_scope_id in
> case of interface-local mc addresses.
> 
> v2:
> a) rebased ontop of patch 1/4 (now uses ipv6_addr_props)
> 
> v3:
> a) reverted changes for ipv6_addr_props
> 
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  net/ipv6/af_inet6.c              |  6 +++---
>  net/ipv6/datagram.c              | 16 +++++++++-------
>  net/ipv6/icmp.c                  |  2 +-
>  net/ipv6/inet6_connection_sock.c |  6 ++----
>  net/ipv6/raw.c                   |  9 ++++-----
>  net/ipv6/udp.c                   | 13 +++++++------
>  6 files changed, 26 insertions(+), 26 deletions(-)
> 
> diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
> index 6b793bf..f56277f 100644
> --- a/net/ipv6/af_inet6.c
> +++ b/net/ipv6/af_inet6.c
> @@ -323,7 +323,7 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
>  			struct net_device *dev = NULL;
>  
>  			rcu_read_lock();
> -			if (addr_type & IPV6_ADDR_LINKLOCAL) {
> +			if (__ipv6_addr_needs_scope_id(addr_type)) {
>  				if (addr_len >= sizeof(struct sockaddr_in6) &&
>  				    addr->sin6_scope_id) {
>  					/* Override any existing binding, if another one
> @@ -471,8 +471,8 @@ int inet6_getname(struct socket *sock, struct sockaddr *uaddr,
>  
>  		sin->sin6_port = inet->inet_sport;
>  	}
> -	if (ipv6_addr_type(&sin->sin6_addr) & IPV6_ADDR_LINKLOCAL)
> -		sin->sin6_scope_id = sk->sk_bound_dev_if;
> +	sin->sin6_scope_id = ipv6_iface_scope_id(&sin->sin6_addr,
> +						 sk->sk_bound_dev_if);
>  	*uaddr_len = sizeof(*sin);
>  	return 0;
>  }
> diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
> index f5a5478..b55e70a 100644
> --- a/net/ipv6/datagram.c
> +++ b/net/ipv6/datagram.c
> @@ -124,7 +124,7 @@ ipv4_connected:
>  		goto out;
>  	}
>  
> -	if (addr_type&IPV6_ADDR_LINKLOCAL) {
> +	if (__ipv6_addr_needs_scope_id(addr_type)) {
>  		if (addr_len >= sizeof(struct sockaddr_in6) &&
>  		    usin->sin6_scope_id) {
>  			if (sk->sk_bound_dev_if &&
> @@ -355,18 +355,19 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len)
>  		sin->sin6_family = AF_INET6;
>  		sin->sin6_flowinfo = 0;
>  		sin->sin6_port = serr->port;
> -		sin->sin6_scope_id = 0;
>  		if (skb->protocol == htons(ETH_P_IPV6)) {
>  			const struct ipv6hdr *ip6h = container_of((struct in6_addr *)(nh + serr->addr_offset),
>  								  struct ipv6hdr, daddr);
>  			sin->sin6_addr = ip6h->daddr;
>  			if (np->sndflow)
>  				sin->sin6_flowinfo = ip6_flowinfo(ip6h);
> -			if (ipv6_addr_type(&sin->sin6_addr) & IPV6_ADDR_LINKLOCAL)
> -				sin->sin6_scope_id = IP6CB(skb)->iif;
> +			sin->sin6_scope_id =
> +				ipv6_iface_scope_id(&sin->sin6_addr,
> +						    IP6CB(skb)->iif);
>  		} else {
>  			ipv6_addr_set_v4mapped(*(__be32 *)(nh + serr->addr_offset),
>  					       &sin->sin6_addr);
> +			sin->sin6_scope_id = 0;
>  		}
>  	}
>  
> @@ -376,18 +377,19 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len)
>  	if (serr->ee.ee_origin != SO_EE_ORIGIN_LOCAL) {
>  		sin->sin6_family = AF_INET6;
>  		sin->sin6_flowinfo = 0;
> -		sin->sin6_scope_id = 0;
>  		if (skb->protocol == htons(ETH_P_IPV6)) {
>  			sin->sin6_addr = ipv6_hdr(skb)->saddr;
>  			if (np->rxopt.all)
>  				ip6_datagram_recv_ctl(sk, msg, skb);
> -			if (ipv6_addr_type(&sin->sin6_addr) & IPV6_ADDR_LINKLOCAL)
> -				sin->sin6_scope_id = IP6CB(skb)->iif;
> +			sin->sin6_scope_id =
> +				ipv6_iface_scope_id(&sin->sin6_addr,
> +						    IP6CB(skb)->iif);
>  		} else {
>  			struct inet_sock *inet = inet_sk(sk);
>  
>  			ipv6_addr_set_v4mapped(ip_hdr(skb)->saddr,
>  					       &sin->sin6_addr);
> +			sin->sin6_scope_id = 0;
>  			if (inet->cmsg_flags)
>  				ip_cmsg_recv(msg, skb);
>  		}
> diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
> index fff5bdd..71b900c 100644
> --- a/net/ipv6/icmp.c
> +++ b/net/ipv6/icmp.c
> @@ -434,7 +434,7 @@ void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
>  	 *	Source addr check
>  	 */
>  
> -	if (addr_type & IPV6_ADDR_LINKLOCAL)
> +	if (__ipv6_addr_needs_scope_id(addr_type))
>  		iif = skb->dev->ifindex;
>  
>  	/*
> diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
> index 5f25510..e4311cb 100644
> --- a/net/ipv6/inet6_connection_sock.c
> +++ b/net/ipv6/inet6_connection_sock.c
> @@ -173,10 +173,8 @@ void inet6_csk_addr2sockaddr(struct sock *sk, struct sockaddr * uaddr)
>  	sin6->sin6_port	= inet_sk(sk)->inet_dport;
>  	/* We do not store received flowlabel for TCP */
>  	sin6->sin6_flowinfo = 0;
> -	sin6->sin6_scope_id = 0;
> -	if (sk->sk_bound_dev_if &&
> -	    ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL)
> -		sin6->sin6_scope_id = sk->sk_bound_dev_if;
> +	sin6->sin6_scope_id = ipv6_iface_scope_id(&sin6->sin6_addr,
> +						  sk->sk_bound_dev_if);
>  }
>  
>  EXPORT_SYMBOL_GPL(inet6_csk_addr2sockaddr);
> diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
> index 330b5e7..eedff8c 100644
> --- a/net/ipv6/raw.c
> +++ b/net/ipv6/raw.c
> @@ -263,7 +263,7 @@ static int rawv6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
>  	if (addr_type != IPV6_ADDR_ANY) {
>  		struct net_device *dev = NULL;
>  
> -		if (addr_type & IPV6_ADDR_LINKLOCAL) {
> +		if (__ipv6_addr_needs_scope_id(addr_type)) {
>  			if (addr_len >= sizeof(struct sockaddr_in6) &&
>  			    addr->sin6_scope_id) {
>  				/* Override any existing binding, if another
> @@ -498,9 +498,8 @@ static int rawv6_recvmsg(struct kiocb *iocb, struct sock *sk,
>  		sin6->sin6_port = 0;
>  		sin6->sin6_addr = ipv6_hdr(skb)->saddr;
>  		sin6->sin6_flowinfo = 0;
> -		sin6->sin6_scope_id = 0;
> -		if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL)
> -			sin6->sin6_scope_id = IP6CB(skb)->iif;
> +		sin6->sin6_scope_id = ipv6_iface_scope_id(&sin6->sin6_addr,
> +							  IP6CB(skb)->iif);
>  	}
>  
>  	sock_recv_ts_and_drops(msg, sk, skb);
> @@ -802,7 +801,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
>  
>  		if (addr_len >= sizeof(struct sockaddr_in6) &&
>  		    sin6->sin6_scope_id &&
> -		    ipv6_addr_type(daddr)&IPV6_ADDR_LINKLOCAL)
> +		    __ipv6_addr_needs_scope_id(__ipv6_addr_type(daddr)))
>  			fl6.flowi6_oif = sin6->sin6_scope_id;
>  	} else {
>  		if (sk->sk_state != TCP_ESTABLISHED)
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index 599e1ba6..3ed57ec 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -450,15 +450,16 @@ try_again:
>  		sin6->sin6_family = AF_INET6;
>  		sin6->sin6_port = udp_hdr(skb)->source;
>  		sin6->sin6_flowinfo = 0;
> -		sin6->sin6_scope_id = 0;
>  
> -		if (is_udp4)
> +		if (is_udp4) {
>  			ipv6_addr_set_v4mapped(ip_hdr(skb)->saddr,
>  					       &sin6->sin6_addr);
> -		else {
> +			sin6->sin6_scope_id = 0;
> +		} else {
>  			sin6->sin6_addr = ipv6_hdr(skb)->saddr;
> -			if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL)
> -				sin6->sin6_scope_id = IP6CB(skb)->iif;
> +			sin6->sin6_scope_id =
> +				ipv6_iface_scope_id(&sin6->sin6_addr,
> +						    IP6CB(skb)->iif);
>  		}
>  
>  	}
> @@ -1118,7 +1119,7 @@ do_udp_sendmsg:
>  
>  		if (addr_len >= sizeof(struct sockaddr_in6) &&
>  		    sin6->sin6_scope_id &&
> -		    ipv6_addr_type(daddr)&IPV6_ADDR_LINKLOCAL)
> +		    __ipv6_addr_needs_scope_id(__ipv6_addr_type(daddr)))
>  			fl6.flowi6_oif = sin6->sin6_scope_id;
>  	} else {
>  		if (sk->sk_state != TCP_ESTABLISHED)
> 

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH v3 2/2] Implement IPV6_UNICAST_IF socket option.
Date: Mon, 06 Feb 2012 16:13:47 -0500
Message-ID: <4F30428B.2080102@hp.com>
References: <1328551064-28573-2-git-send-email-ehoover@mines.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev <netdev@vger.kernel.org>
To: "Erich E. Hoover" <ehoover@mines.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:31824 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337Ab2BFVNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 16:13:49 -0500
In-Reply-To: <1328551064-28573-2-git-send-email-ehoover@mines.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/06/2012 12:57 PM, Erich E. Hoover wrote:
> 
> The IPV6_UNICAST_IF feature is the IPv6 compliment to IP_UNICAST_IF.
> 

> diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
> index 6318268..1602fb0 100644
> --- a/include/linux/ipv6.h
> +++ b/include/linux/ipv6.h
> @@ -299,6 +299,8 @@ struct ipv6_pinfo {
>  	struct in6_addr		*saddr_cache;
>  #endif
>  
> +	int			outif_index;
> +
>  	__be32			flow_label;
>  	__u32			frag_size;

I haven't done the math, but to make sure you don't add a padding hole you could
put this next to mcast_oif.  'pahole -C ipv6_pinfo net/built-in.o' showed there
was 5 bytes of padding in this cache line.

Nitpick: is ucast_oif a better name?

> diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
> index 01d46bf..18f144e 100644
> --- a/net/ipv6/icmp.c
> +++ b/net/ipv6/icmp.c
> @@ -551,6 +551,9 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
>  		return;
>  	np = inet6_sk(sk);
>  
> +	if (!fl6.flowi6_oif)
> +		fl6.flowi6_oif = ipv6_default_ifindex(sk);
> +
>  	if (!fl6.flowi6_oif && ipv6_addr_is_multicast(&fl6.daddr))
>  		fl6.flowi6_oif = np->mcast_oif;

This snippet shows (and rawv6_sendmsg() has the same problem), that
IPV6_UNICAST_IF can also affect multicast packets.  And I think we always want
SO_BINDTODEVICE to override them all.  Perhaps these checks should be:

	if (!fl6.flowi6_oif)
		fl6.flowi6_oif = sk->sk_bound_dev_if;

	if (!fl6.flowi6_oif)
		if (ipv6_addr_is_multicast(&fl6.daddr))
			fl6.flowi6_oif = np->mcast_oif;
		else
			fl6.flowi6_oif = np->ucast_oif;

> +int ipv6_default_ifindex(const struct sock *sk)
> +{
> +	struct ipv6_pinfo *np = inet6_sk(sk);
> +	int ifindex = sk->sk_bound_dev_if;
> +
> +	/*
> +         * If not bound to a specific interface then set the outgoing interface
> +	 * to the value from the IPV6_UNICAST_IF socket option.
> +         */
> +	if (!ifindex)
> +		ifindex = np->outif_index;
> +
> +	return ifindex;
> +}

All callers of this already have 'np', you could just pass it along.  Or with
the above change you don't even need it.  IPv4 code as well.

> diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
> index d02f7e4..25539a1 100644
> --- a/net/ipv6/raw.c
> +++ b/net/ipv6/raw.c
> @@ -813,7 +813,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
>  	}
>  
>  	if (fl6.flowi6_oif == 0)
> -		fl6.flowi6_oif = sk->sk_bound_dev_if;
> +		fl6.flowi6_oif = ipv6_default_ifindex(sk);

I think you should change this like above.

> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index 4f96b5c..bb8db62 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -1081,7 +1081,7 @@ do_udp_sendmsg:
>  	}
>  
>  	if (!fl6.flowi6_oif)
> -		fl6.flowi6_oif = sk->sk_bound_dev_if;
> +		fl6.flowi6_oif = ipv6_default_ifindex(sk);
>  
>  	if (!fl6.flowi6_oif)
>  		fl6.flowi6_oif = np->sticky_pktinfo.ipi6_ifindex;

This too, letting np->ucast_oif be third after PKTINFO, there's a multicast
check below in this code.

-Brian

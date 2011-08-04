From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] ipv6: check for IPv4 mapped addresses when connecting
 IPv6 sockets
Date: Thu, 04 Aug 2011 10:14:53 -0400
Message-ID: <4E3AA95D.2000407@hp.com>
References: <20110804075506.62225813270B@regina.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Max Matveev <makc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:16385 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751850Ab1HDOO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2011 10:14:59 -0400
In-Reply-To: <20110804075506.62225813270B@regina.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/04/2011 03:42 AM, Max Matveev wrote:
> When support for binding to 'mapped INADDR_ANY (::ffff.0.0.0.0)' was added
> in 0f8d3c7ac3693d7b6c731bf2159273a59bf70e12 the rest of the code
> wasn't told so now it's possible to bind IPv6 datagram socket to
> ::ffff.0.0.0.0, connect it to another IPv4 address and it will all
> work except for getsockhame() which does not return the local address
> as expected.
> 
> To give getsockname() something to work with check for 'mapped INADDR_ANY'
> when connecting and update the in-core source addresses appropriately.
> 
> Signed-off-by: Max Matveev <makc@redhat.com>

Yes.  Good catch.

-vlad

> ---
>  net/ipv6/datagram.c |   11 +++++++++--
>  1 files changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
> index 1656033..d3a65a18 100644
> --- a/net/ipv6/datagram.c
> +++ b/net/ipv6/datagram.c
> @@ -33,6 +33,11 @@
>  #include <linux/errqueue.h>
>  #include <asm/uaccess.h>
>  
> +static inline int ipv6_mapped_addr_any(const struct in6_addr *a)
> +{
> +	return (ipv6_addr_v4mapped(a) && (a->s6_addr32[3] == 0));
> +}
> +
>  int ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
>  {
>  	struct sockaddr_in6	*usin = (struct sockaddr_in6 *) uaddr;
> @@ -102,10 +107,12 @@ ipv4_connected:
>  
>  		ipv6_addr_set_v4mapped(inet->inet_daddr, &np->daddr);
>  
> -		if (ipv6_addr_any(&np->saddr))
> +		if (ipv6_addr_any(&np->saddr) ||
> +		    ipv6_mapped_addr_any(&np->saddr))
>  			ipv6_addr_set_v4mapped(inet->inet_saddr, &np->saddr);
>  
> -		if (ipv6_addr_any(&np->rcv_saddr)) {
> +		if (ipv6_addr_any(&np->rcv_saddr) || 
> +		    ipv6_mapped_addr_any(&np->rcv_saddr)) {
>  			ipv6_addr_set_v4mapped(inet->inet_rcv_saddr,
>  					       &np->rcv_saddr);
>  			if (sk->sk_prot->rehash)


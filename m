From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: PATCH: Multicast: Filter multicast traffic per socket mc_list
Date: Thu, 16 Apr 2009 11:24:29 -0400
Message-ID: <49E74DAD.4020507@hp.com>
References: <alpine.DEB.1.10.0904161035390.19650@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	nhorman@tuxdriver.com, dlstevens@us.ibm.com
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:1570 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752943AbZDPPYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 11:24:32 -0400
In-Reply-To: <alpine.DEB.1.10.0904161035390.19650@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter wrote:
> Do what David Stevens suggest: Add a per socket option
> 
> 
> 
> Subject: Multicast: Filter Multicast traffic per socket mc_list
> 
> If two processes open the same port as a multicast socket and then
> join two different multicast groups then traffic for both multicast groups
> is forwarded to either process. This means that application will get surprising
> data that they did not ask for. Applications will have to filter these out in
> order to work correctly if multiple apps run on the same system.
> 
> These are pretty strange semantics but they have been around since the
> beginning of multicast support on Unix systems. Most of the other operating
> systems supporting Multicast have since changed to only supplying multicast
> traffic to a socket that was selected through multicast join operations.
> 
> This patch does change Linux to behave in the same way. But there may be
> applications that rely on the old behavior. Therefore we provide a means
> to switch back to the old behavior using a new multicast socket option
> 
> 	IP_MULTICAST_ALL
> 
> If set then all multicast traffic to the port is forwarded to the socket
> (additional constraints are the SSM inclusion and exclusion lists!).
> If not set (default) then only traffic for multicast groups that were
> joined by thesocket is received.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> ---
>  include/linux/in.h      |    1 +
>  include/net/inet_sock.h |    3 ++-
>  net/ipv4/igmp.c         |    4 ++--
>  net/ipv4/ip_sockglue.c  |   11 +++++++++++
>  4 files changed, 16 insertions(+), 3 deletions(-)
> 
> Index: linux-2.6/include/net/inet_sock.h
> ===================================================================
> --- linux-2.6.orig/include/net/inet_sock.h	2009-04-16 08:59:20.000000000 -0500
> +++ linux-2.6/include/net/inet_sock.h	2009-04-16 09:04:47.000000000 -0500
> @@ -130,7 +130,8 @@ struct inet_sock {
>  				freebind:1,
>  				hdrincl:1,
>  				mc_loop:1,
> -				transparent:1;
> +				transparent:1,
> +				mc_all:1;
>  	int			mc_index;
>  	__be32			mc_addr;
>  	struct ip_mc_socklist	*mc_list;
> Index: linux-2.6/net/ipv4/igmp.c
> ===================================================================
> --- linux-2.6.orig/net/ipv4/igmp.c	2009-04-16 08:54:47.000000000 -0500
> +++ linux-2.6/net/ipv4/igmp.c	2009-04-16 09:04:06.000000000 -0500
> @@ -2187,7 +2187,7 @@ int ip_mc_sf_allow(struct sock *sk, __be
>  	struct ip_sf_socklist *psl;
>  	int i;
> 
> -	if (!ipv4_is_multicast(loc_addr))
> +	if (ipv4_is_lbcast(loc_addr) || !ipv4_is_multicast(loc_addr))
>  		return 1;

I don't think this change is needed.  ipv4_is_lbcast() checks if the
address is 255.255.255.255.  That address is already !ipv4_is_multicast().

Subnet broadcasts are also !ipv4_is_multicast.

> 
>  	for (pmc=inet->mc_list; pmc; pmc=pmc->next) {
> @@ -2196,7 +2196,7 @@ int ip_mc_sf_allow(struct sock *sk, __be
>  			break;
>  	}
>  	if (!pmc)
> -		return 1;
> +		return inet->mc_all;
>  	psl = pmc->sflist;
>  	if (!psl)
>  		return pmc->sfmode == MCAST_EXCLUDE;
> Index: linux-2.6/include/linux/in.h
> ===================================================================
> --- linux-2.6.orig/include/linux/in.h	2009-04-16 09:05:41.000000000 -0500
> +++ linux-2.6/include/linux/in.h	2009-04-16 09:32:52.000000000 -0500
> @@ -107,6 +107,7 @@ struct in_addr {
>  #define MCAST_JOIN_SOURCE_GROUP		46
>  #define MCAST_LEAVE_SOURCE_GROUP	47
>  #define MCAST_MSFILTER			48
> +#define IP_MULTICAST_ALL		49
> 
>  #define MCAST_EXCLUDE	0
>  #define MCAST_INCLUDE	1
> Index: linux-2.6/net/ipv4/ip_sockglue.c
> ===================================================================
> --- linux-2.6.orig/net/ipv4/ip_sockglue.c	2009-04-16 09:09:52.000000000 -0500
> +++ linux-2.6/net/ipv4/ip_sockglue.c	2009-04-16 09:31:40.000000000 -0500
> @@ -449,6 +449,7 @@ static int do_ip_setsockopt(struct sock
>  			     (1<<IP_ROUTER_ALERT) | (1<<IP_FREEBIND) |
>  			     (1<<IP_PASSSEC) | (1<<IP_TRANSPARENT))) ||
>  	    optname == IP_MULTICAST_TTL ||
> +	    optname == IP_MULTICAST_ALL ||
>  	    optname == IP_MULTICAST_LOOP ||
>  	    optname == IP_RECVORIGDSTADDR) {
>  		if (optlen >= sizeof(int)) {
> @@ -895,6 +896,13 @@ static int do_ip_setsockopt(struct sock
>  		kfree(gsf);
>  		break;
>  	}
> +	case IP_MULTICAST_ALL:
> +		if (optlen<1)
> +			goto e_inval;
> +		if (val != 0 && val != 1)
> +			goto e_inval;
> +		inet->mc_all = val;
> +		break;
>  	case IP_ROUTER_ALERT:
>  		err = ip_ra_control(sk, val ? 1 : 0, NULL);
>  		break;
> @@ -1147,6 +1155,9 @@ static int do_ip_getsockopt(struct sock
>  		release_sock(sk);
>  		return err;
>  	}
> +	case IP_MULTICAST_ALL:
> +		val = inet->mc_all;
> +		break;
>  	case IP_PKTOPTIONS:
>  	{
>  		struct msghdr msg;

You might need to set inet->mc_all to 1 in inet_create() since I am not sure if
we want to change the default behavior.  The knowledge that some apps have
a very "unique" way of doing multicast makes me a little hesitant.

-vlad

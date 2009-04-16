From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: PATCH: Multicast: Filter multicast traffic per socket mc_list
Date: Thu, 16 Apr 2009 08:09:24 -0700
Message-ID: <OF8AB07938.3DA9C6DD-ON8825759A.00522BB7-8825759A.0053414D@us.ibm.com>
References: <alpine.DEB.1.10.0904161035390.19650@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, nhorman@tuxdriver.com,
	vladislav.yasevich@hp.com
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:60401 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086AbZDPPOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 11:14:19 -0400
In-Reply-To: <alpine.DEB.1.10.0904161035390.19650@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This isn't what I suggested-- you have the default backwards. It must 
default
to current behavior, or it's pointless.

The text you have with it is overstated, too. Of course applications using
your model can still receive unexpected data-- it does not reserve the
port or multicast address to just your sender or to multicast traffic 
alone.

My suggestion is to do nothing. :-) But if that's too difficult, an 
alternative
would be a socket option that delivers traffic for joined groups only and
defaults off. In fact, it'd probably be most useful if it also prevents 
unicast
traffic for sockets using that port, too. None of these things have the 
magic
effect of preventing unwanted data delivery, but it'd allow you to receive
multiple, specific groups on a single socket with just the joins to 
indicate
which.

                                                +-DLS


netdev-owner@vger.kernel.org wrote on 04/16/2009 07:38:23 AM:

> Do what David Stevens suggest: Add a per socket option
> 
> 
> 
> Subject: Multicast: Filter Multicast traffic per socket mc_list
> 
> If two processes open the same port as a multicast socket and then
> join two different multicast groups then traffic for both multicast 
groups
> is forwarded to either process. This means that application will get 
surprising
> data that they did not ask for. Applications will have to filter these 
out in
> order to work correctly if multiple apps run on the same system.
> 
> These are pretty strange semantics but they have been around since the
> beginning of multicast support on Unix systems. Most of the other 
operating
> systems supporting Multicast have since changed to only supplying 
multicast
> traffic to a socket that was selected through multicast join operations.
> 
> This patch does change Linux to behave in the same way. But there may be
> applications that rely on the old behavior. Therefore we provide a means
> to switch back to the old behavior using a new multicast socket option
> 
>    IP_MULTICAST_ALL
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
> --- linux-2.6.orig/include/net/inet_sock.h   2009-04-16 
08:59:20.000000000 -0500
> +++ linux-2.6/include/net/inet_sock.h   2009-04-16 09:04:47.000000000 
-0500
> @@ -130,7 +130,8 @@ struct inet_sock {
>              freebind:1,
>              hdrincl:1,
>              mc_loop:1,
> -            transparent:1;
> +            transparent:1,
> +            mc_all:1;
>     int         mc_index;
>     __be32         mc_addr;
>     struct ip_mc_socklist   *mc_list;
> Index: linux-2.6/net/ipv4/igmp.c
> ===================================================================
> --- linux-2.6.orig/net/ipv4/igmp.c   2009-04-16 08:54:47.000000000 -0500
> +++ linux-2.6/net/ipv4/igmp.c   2009-04-16 09:04:06.000000000 -0500
> @@ -2187,7 +2187,7 @@ int ip_mc_sf_allow(struct sock *sk, __be
>     struct ip_sf_socklist *psl;
>     int i;
> 
> -   if (!ipv4_is_multicast(loc_addr))
> +   if (ipv4_is_lbcast(loc_addr) || !ipv4_is_multicast(loc_addr))
>        return 1;
> 
>     for (pmc=inet->mc_list; pmc; pmc=pmc->next) {
> @@ -2196,7 +2196,7 @@ int ip_mc_sf_allow(struct sock *sk, __be
>           break;
>     }
>     if (!pmc)
> -      return 1;
> +      return inet->mc_all;
>     psl = pmc->sflist;
>     if (!psl)
>        return pmc->sfmode == MCAST_EXCLUDE;
> Index: linux-2.6/include/linux/in.h
> ===================================================================
> --- linux-2.6.orig/include/linux/in.h   2009-04-16 09:05:41.000000000 
-0500
> +++ linux-2.6/include/linux/in.h   2009-04-16 09:32:52.000000000 -0500
> @@ -107,6 +107,7 @@ struct in_addr {
>  #define MCAST_JOIN_SOURCE_GROUP      46
>  #define MCAST_LEAVE_SOURCE_GROUP   47
>  #define MCAST_MSFILTER         48
> +#define IP_MULTICAST_ALL      49
> 
>  #define MCAST_EXCLUDE   0
>  #define MCAST_INCLUDE   1
> Index: linux-2.6/net/ipv4/ip_sockglue.c
> ===================================================================
> --- linux-2.6.orig/net/ipv4/ip_sockglue.c   2009-04-16 
09:09:52.000000000 -0500
> +++ linux-2.6/net/ipv4/ip_sockglue.c   2009-04-16 09:31:40.000000000 
-0500
> @@ -449,6 +449,7 @@ static int do_ip_setsockopt(struct sock
>                (1<<IP_ROUTER_ALERT) | (1<<IP_FREEBIND) |
>                (1<<IP_PASSSEC) | (1<<IP_TRANSPARENT))) ||
>         optname == IP_MULTICAST_TTL ||
> +       optname == IP_MULTICAST_ALL ||
>         optname == IP_MULTICAST_LOOP ||
>         optname == IP_RECVORIGDSTADDR) {
>        if (optlen >= sizeof(int)) {
> @@ -895,6 +896,13 @@ static int do_ip_setsockopt(struct sock
>        kfree(gsf);
>        break;
>     }
> +   case IP_MULTICAST_ALL:
> +      if (optlen<1)
> +         goto e_inval;
> +      if (val != 0 && val != 1)
> +         goto e_inval;
> +      inet->mc_all = val;
> +      break;
>     case IP_ROUTER_ALERT:
>        err = ip_ra_control(sk, val ? 1 : 0, NULL);
>        break;
> @@ -1147,6 +1155,9 @@ static int do_ip_getsockopt(struct sock
>        release_sock(sk);
>        return err;
>     }
> +   case IP_MULTICAST_ALL:
> +      val = inet->mc_all;
> +      break;
>     case IP_PKTOPTIONS:
>     {
>        struct msghdr msg;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


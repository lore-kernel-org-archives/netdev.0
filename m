From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 1/1] Fix getsockname (ipv4/ipv6)
Date: Mon, 26 Jan 2009 20:48:32 -0200
Message-ID: <20090126224832.GB13287@ghostprotocols.net>
References: <20090126220931.A8F0154A11@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Networking Development Mailing List <netdev@vger.kernel.org>
To: John Reumann <reumann.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34216 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751531AbZAZWsp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2009 17:48:45 -0500
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n0QMma3F012973
	for <netdev@vger.kernel.org>; Mon, 26 Jan 2009 17:48:36 -0500
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n0QMma0R023245
	for <netdev@vger.kernel.org>; Mon, 26 Jan 2009 17:48:36 -0500
Received: from doppio.ghostprotocols.net (vpn-13-59.rdu.redhat.com [10.11.13.59])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n0QMmYmT017751
	for <netdev@vger.kernel.org>; Mon, 26 Jan 2009 17:48:35 -0500
Content-Disposition: inline
In-Reply-To: <20090126220931.A8F0154A11@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Fri, Jan 23, 2009 at 04:45:52PM -0500, John Reumann escreveu:
> This change will return ENOSPC if the return address provided by the caller of getsockname
>  is not sufficiently large to hold the return value.  This is consistent with the rest of the
>  API. However, there are some implemenations that copy only as many bytes of sockaddr from the
>  kernel to user-space as specified in the *addrlen attribute.  (1) This wasn't the behavior now
>  (2) we should not adopt this behavior because it is quite messy, e.g., copy only part of a port,
>  IP-address? Most partial retrivals do not make sense.  This is why I suggest returning EINVAL,
>  when the return struct is too small.
> ---
>  net/ipv4/af_inet.c  |    7 +++++--
>  net/ipv6/af_inet6.c |    3 +++
>  2 files changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 743f554..9a8c5b0 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -677,10 +677,13 @@ do_err:
>  int inet_getname(struct socket *sock, struct sockaddr *uaddr,
>  			int *uaddr_len, int peer)
>  {
> -	struct sock *sk		= sock->sk;
> -	struct inet_sock *inet	= inet_sk(sk);
> +	struct sock *sk = sock->sk;
> +	struct inet_sock *inet = inet_sk(sk);

Besides the other problem pointed out by Florian, why the gratuitous
reformatting above?

>  	struct sockaddr_in *sin	= (struct sockaddr_in *)uaddr;
>  
> +        if (*uaddr_len < sizeof(struct sockaddr_in))
> +	  return -ENOSPC;
> +
>  	sin->sin_family = AF_INET;
>  	if (peer) {
>  		if (!inet->dport ||
> diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
> index c802bc1..f2772ee 100644
> --- a/net/ipv6/af_inet6.c
> +++ b/net/ipv6/af_inet6.c
> @@ -401,6 +401,9 @@ int inet6_getname(struct socket *sock, struct sockaddr *uaddr,
>  	struct inet_sock *inet = inet_sk(sk);
>  	struct ipv6_pinfo *np = inet6_sk(sk);
>  
> +	if (*uaddr_len < sizeof(struct sockaddr_in6))
> +		return -ENOSPC;
> +
>  	sin->sin6_family = AF_INET6;
>  	sin->sin6_flowinfo = 0;
>  	sin->sin6_scope_id = 0;
> -- 
> 1.5.4.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

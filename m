From: Joy Latten <latten@austin.ibm.com>
Subject: Re: when having to acquire an SA, ipsec drops the packet
Date: Mon, 05 Feb 2007 14:53:39 -0600
Message-ID: <1170708819.2603.369.camel@faith.austin.ibm.com>
References: <1170370281.2603.359.camel@faith.austin.ibm.com>
	 <Pine.LNX.4.64.0702011819070.11820@d.namei>
	 <20070204.205315.10325007.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, netdev@vger.kernel.org, paul.moore@hp.com,
	vyekkirala@TrustedCS.com, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:41306 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933446AbXBEVIw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 16:08:52 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l15L8ooD029733
	for <netdev@vger.kernel.org>; Mon, 5 Feb 2007 16:08:50 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l15L8oQW276250
	for <netdev@vger.kernel.org>; Mon, 5 Feb 2007 16:08:50 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l15L8nPp029559
	for <netdev@vger.kernel.org>; Mon, 5 Feb 2007 16:08:50 -0500
In-Reply-To: <20070204.205315.10325007.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I can run some tests with this patch and report any results... 

Regards,
Joy

On Sun, 2007-02-04 at 20:53 -0800, David Miller wrote:
> From: James Morris <jmorris@namei.org>
> Date: Thu, 1 Feb 2007 18:44:48 -0500 (EST)
> 
> > A quick & dirty solution, which is what I think the BSD kernels do, is to 
> > still drop the packet but just not return an error to the app.  The app 
> > then just sees a slight delay on the initial connection, as if a DNS 
> > lookup took a bit longer than usual.
> 
> I have another idea.
> 
> Why don't we just flat-out ignore MSG_DONTWAIT for the socket
> visible cases, and handle connect() similarly?
> 
> I think this is (just barely) legal, will be simple to implement, and
> will leave us with semantics that look like:
> 
> 1) Sockets never see -EAGAIN due to SA resolution.  They'll just
>    pause until the route is resolved, even with O_NONBLOCK or
>    MSG_DONTWAIT.
> 
> 2) Asynchronous contexts such as ICMP replies and firewalling
>    will still see the -EAGAIN and simply drop packets.
> 
> These sleeps are legal because all of the socket paths involved
> have to be able to do lock_socket() (at a minimum) anyways.
> 
> Something like this (untested) on the ipv4 side, for example:
> 
> diff --git a/include/net/route.h b/include/net/route.h
> index 486e37a..a8af632 100644
> --- a/include/net/route.h
> +++ b/include/net/route.h
> @@ -146,7 +146,8 @@ static inline char rt_tos2priority(u8 tos)
>  
>  static inline int ip_route_connect(struct rtable **rp, __be32 dst,
>  				   __be32 src, u32 tos, int oif, u8 protocol,
> -				   __be16 sport, __be16 dport, struct sock *sk)
> +				   __be16 sport, __be16 dport, struct sock *sk,
> +				   int flags)
>  {
>  	struct flowi fl = { .oif = oif,
>  			    .nl_u = { .ip4_u = { .daddr = dst,
> @@ -168,7 +169,7 @@ static inline int ip_route_connect(struct rtable **rp, __be32 dst,
>  		*rp = NULL;
>  	}
>  	security_sk_classify_flow(sk, &fl);
> -	return ip_route_output_flow(rp, &fl, sk, 0);
> +	return ip_route_output_flow(rp, &fl, sk, 1);
>  }
>  
>  static inline int ip_route_newports(struct rtable **rp, u8 protocol,
> diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
> index 90c74b4..fa2c982 100644
> --- a/net/dccp/ipv4.c
> +++ b/net/dccp/ipv4.c
> @@ -72,7 +72,7 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
>  	tmp = ip_route_connect(&rt, nexthop, inet->saddr,
>  			       RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
>  			       IPPROTO_DCCP,
> -			       inet->sport, usin->sin_port, sk);
> +			       inet->sport, usin->sin_port, sk, 1);
>  	if (tmp < 0)
>  		return tmp;
>  
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 8640096..5750a2b 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1007,7 +1007,7 @@ static int inet_sk_reselect_saddr(struct sock *sk)
>  			       RT_CONN_FLAGS(sk),
>  			       sk->sk_bound_dev_if,
>  			       sk->sk_protocol,
> -			       inet->sport, inet->dport, sk);
> +			       inet->sport, inet->dport, sk, 0);
>  	if (err)
>  		return err;
>  
> diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
> index 7b068a8..0072d79 100644
> --- a/net/ipv4/datagram.c
> +++ b/net/ipv4/datagram.c
> @@ -49,7 +49,7 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
>  	err = ip_route_connect(&rt, usin->sin_addr.s_addr, saddr,
>  			       RT_CONN_FLAGS(sk), oif,
>  			       sk->sk_protocol,
> -			       inet->sport, usin->sin_port, sk);
> +			       inet->sport, usin->sin_port, sk, 1);
>  	if (err)
>  		return err;
>  	if ((rt->rt_flags & RTCF_BROADCAST) && !sock_flag(sk, SOCK_BROADCAST)) {
> diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
> index a6c63bb..fed6a1e 100644
> --- a/net/ipv4/raw.c
> +++ b/net/ipv4/raw.c
> @@ -489,7 +489,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
>  		}
>  
>  		security_sk_classify_flow(sk, &fl);
> -		err = ip_route_output_flow(&rt, &fl, sk, !(msg->msg_flags&MSG_DONTWAIT));
> +		err = ip_route_output_flow(&rt, &fl, sk, 1);
>  	}
>  	if (err)
>  		goto done;
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index f061ec5..383e4b5 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -191,7 +191,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
>  	tmp = ip_route_connect(&rt, nexthop, inet->saddr,
>  			       RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
>  			       IPPROTO_TCP,
> -			       inet->sport, usin->sin_port, sk);
> +			       inet->sport, usin->sin_port, sk, 1);
>  	if (tmp < 0)
>  		return tmp;
>  
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index cfff930..8b54c68 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -629,7 +629,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
>  					       { .sport = inet->sport,
>  						 .dport = dport } } };
>  		security_sk_classify_flow(sk, &fl);
> -		err = ip_route_output_flow(&rt, &fl, sk, !(msg->msg_flags&MSG_DONTWAIT));
> +		err = ip_route_output_flow(&rt, &fl, sk, 1);
>  		if (err)
>  			goto out;
>  
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

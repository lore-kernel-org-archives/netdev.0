From: Neil Brown <neilb@suse.de>
Subject: Re: Undefined behaviour of connect(fd, NULL, 0);
Date: Thu, 1 Apr 2010 07:24:12 +1100
Message-ID: <20100401072412.032aa8e6@notabene.brown>
References: <20100331223637.31f5f6ed@notabene.brown>
	<20100331114936.3549ca90@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:50446 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757760Ab0CaUYU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Mar 2010 16:24:20 -0400
In-Reply-To: <20100331114936.3549ca90@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 31 Mar 2010 11:49:36 -0700
Stephen Hemminger <shemminger@vyatta.com> wrote:

> On Wed, 31 Mar 2010 22:36:37 +1100
> Neil Brown <neilb@suse.de> wrote:
> 
> > 
> > Hi Netdev.
> > 
> > We have a customer who was reporting strangely unpredictable behaviour of an
> > in-house application that used networking.
> > 
> > It called connect on a non-blocking socket and subsequently called
> >    connect(fd, NULL, 0)
> > 
> > to check if the connection had succeeded.
> > This would sometime "work" and sometimes close the connection.
> > 
> > Looking at the code (sys_connect, move_addr_to_kernel, inet_stream_connect),
> > it seems that in this case an uninitialised on-stack address is passed
> > to inet_stream_connect and it makes a decision based on ->sa_family (which is
> > uninitialised).
> > 
> > It seems clear that connect(fd, NULL, 0) is the wrong thing to do in this
> > circumstance, but I think it would be good if it failed consistently rather
> > than unpredictably.
> > 
> > Would it be appropriate for move_addr_to_kernel to zero out the remainder of
> > the address?
> >    memset(kaddr+ulen, 0, MAX_SOCK_ADDR-ulen);
> > ??
> > 
> > Then connect(fd, NULL, 0) would always break the connection.
> 
> I think the problem is inet_stream_connect referencing past addr_len.
> 
> --- a/net/ipv4/af_inet.c	2010-03-31 11:47:01.952910248 -0700
> +++ b/net/ipv4/af_inet.c	2010-03-31 11:48:09.852938406 -0700
> @@ -575,7 +575,7 @@ int inet_stream_connect(struct socket *s
>  
>  	lock_sock(sk);
>  
> -	if (uaddr->sa_family == AF_UNSPEC) {
> +	if (addr_len < sizeof(sa_family_t) || uaddr->sa_family == AF_UNSPEC) {
>  		err = sk->sk_prot->disconnect(sk, flags);
>  		sock->state = err ? SS_DISCONNECTING : SS_UNCONNECTED;
>  		goto out;

Thanks for the reply.

The implication of this patch is that
   connect(fd, NULL, 0)
is actually a valid way to check if an in-progress connection has completed.

Is that the intention?

Does all other address manipulation code check the addr_len ?? (probably).

Thanks,
NeilBrown

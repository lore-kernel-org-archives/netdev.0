From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Undefined behaviour of connect(fd, NULL, 0);
Date: Wed, 31 Mar 2010 11:49:36 -0700
Message-ID: <20100331114936.3549ca90@s6510>
References: <20100331223637.31f5f6ed@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44772 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750968Ab0CaSti (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Mar 2010 14:49:38 -0400
In-Reply-To: <20100331223637.31f5f6ed@notabene.brown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 31 Mar 2010 22:36:37 +1100
Neil Brown <neilb@suse.de> wrote:

> 
> Hi Netdev.
> 
> We have a customer who was reporting strangely unpredictable behaviour of an
> in-house application that used networking.
> 
> It called connect on a non-blocking socket and subsequently called
>    connect(fd, NULL, 0)
> 
> to check if the connection had succeeded.
> This would sometime "work" and sometimes close the connection.
> 
> Looking at the code (sys_connect, move_addr_to_kernel, inet_stream_connect),
> it seems that in this case an uninitialised on-stack address is passed
> to inet_stream_connect and it makes a decision based on ->sa_family (which is
> uninitialised).
> 
> It seems clear that connect(fd, NULL, 0) is the wrong thing to do in this
> circumstance, but I think it would be good if it failed consistently rather
> than unpredictably.
> 
> Would it be appropriate for move_addr_to_kernel to zero out the remainder of
> the address?
>    memset(kaddr+ulen, 0, MAX_SOCK_ADDR-ulen);
> ??
> 
> Then connect(fd, NULL, 0) would always break the connection.

I think the problem is inet_stream_connect referencing past addr_len.

--- a/net/ipv4/af_inet.c	2010-03-31 11:47:01.952910248 -0700
+++ b/net/ipv4/af_inet.c	2010-03-31 11:48:09.852938406 -0700
@@ -575,7 +575,7 @@ int inet_stream_connect(struct socket *s
 
 	lock_sock(sk);
 
-	if (uaddr->sa_family == AF_UNSPEC) {
+	if (addr_len < sizeof(sa_family_t) || uaddr->sa_family == AF_UNSPEC) {
 		err = sk->sk_prot->disconnect(sk, flags);
 		sock->state = err ? SS_DISCONNECTING : SS_UNCONNECTED;
 		goto out;


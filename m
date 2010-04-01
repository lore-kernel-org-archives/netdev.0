From: Neil Brown <neilb@suse.de>
Subject: Re: Undefined behaviour of connect(fd, NULL, 0);
Date: Thu, 1 Apr 2010 14:38:05 +1100
Message-ID: <20100401143805.1f83a161@notabene.brown>
References: <20100331223637.31f5f6ed@notabene.brown>
	<20100331114936.3549ca90@s6510>
	<20100401072412.032aa8e6@notabene.brown>
	<20100331.141732.225997212.davem@davemloft.net>
	<20100401090756.69bfb57d@notabene.brown>
	<n2w412e6f7f1003312000o3a69802j120acd3946458517@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:55049 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751434Ab0DADiP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Mar 2010 23:38:15 -0400
In-Reply-To: <n2w412e6f7f1003312000o3a69802j120acd3946458517@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 1 Apr 2010 11:00:23 +0800
Changli Gao <xiaosuo@gmail.com> wrote:

> I think the following patch is what Neil wants. The old code implies that
> connect(fd, NULL, 0) is used to check the socket connecting status, but
> Stephen's patch breaks it. The old code is wrong when it checks the address's
> faimly but not check the sizeof of the address to determine the family member
> is valid or not before.
> 
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index be1a6ac..3ff51f0 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -576,7 +576,8 @@ int inet_stream_connect(struct socket *sock,
> struct sockaddr *uaddr,
> 
>  	lock_sock(sk);
> 
> -	if (uaddr->sa_family == AF_UNSPEC) {
> +	if (addr_len >= sizeof(uaddr->sa_family) &&
> +	    uaddr->sa_family == AF_UNSPEC) {
>  		err = sk->sk_prot->disconnect(sk, flags);
>  		sock->state = err ? SS_DISCONNECTING : SS_UNCONNECTED;
>  		goto out;


I'm not sure I'd say that I "want" any particular patch.
I just want to know what "connect(fd, NULL, 0)" is supposed to do, and to
have the kernel be consistent in its behaviour.  I'm not really fussed what
the behaviour is.

I suspect the customer wants that patch you have supplied as it would mean
they don't need to change their code.  But I only want it if it is "right".

The patch you have provided does what I had assumed Stephen's patch did
before I actually read it properly.

My feeling is that this patch might be more useful than Stephen's as having
connect(fd, NULL, 0) do what the customer expects seems useful, where as
having it do the same as setting AF_UNSPEC doesn't add anything.

I've googled around a bit but cannot find any evidence of anyone passing NULL
to connect like this, and what documentation I can find doesn't really
address the issue at all.

Thanks,
NeilBrown

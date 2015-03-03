From: Christian Seiler <christian@iwakd.de>
Subject: Re: [PATCH] net: add =?UTF-8?Q?SO=5FMAX=5FDGRAM=5FQLEN=20for=20AF?=
 =?UTF-8?Q?=5FUNIX=20SOCK=5FDGRAM=20sockets?=
Date: Tue, 03 Mar 2015 16:05:13 +0100
Message-ID: <55ee39bff7875967acb06f25fa695f95@iwakd.de>
References: <1425342774-32667-1-git-send-email-christian@iwakd.de>
 <20150302.213807.367185406305242762.davem@davemloft.net>
 <0b5908020d83bcbaa7f4938e5cb433ea@iwakd.de>
 <1425393019.5130.181.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<dan@mindstab.net>, <edumazet@google.com>,
	<hannes@stressinduktion.org>, <linux-api@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arafel.iwakd.de ([78.46.72.57]:53154 "EHLO arafel.iwakd.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754385AbbCCPFP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2015 10:05:15 -0500
In-Reply-To: <1425393019.5130.181.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 2015-03-03 15:30, schrieb Eric Dumazet:
>> Also note that if I have a stream socket, by default I can buffer up 
>> to
>> 256 kiB of data in the kernel. I did some test measurements on 
>> x86_64
>> and including overhead of internal bookkeeping structures, I can fit 
>> up
>> to 555 datagrams in there if each is at most 192 bytes long, at 
>> least
>> 333 datagrams if each is at most 704 bytes long and at least 185
>> datagrams if each is at most 1728 bytes long. If I compare these
>> numbers to 11, that's an order of magnitude in difference.
>
> Problem about AF_UNIX socket is file descriptor passing.
>
> Increasing the 10 limit allows attackers to OOM host faster I guess.

But what's really preventing that currently? Sure, there's a limit to
the maximum number of file descriptors a process may create, but that's
usually high enough that one could create just a bunch of sockets and
queue stuff in all of them. Sure, if the limit is increased, this could
occur earlier, but my guess is that one would have to put
unrealistically tight restrictions on number of FDs / etc. in order to
really prevent OOM currently. And because modern applications tend to
use a ton of FDs, distros tend to set the FD number limits really high
by default. And my patch does allow the second limit to be changed.

> You could extend the limit if we were sure queued messages were 
> without
> passed fds.

How about this? Add a flag that allows the user to specify that
SCM_RIGHTS will never be used on this socket, and that if the user
wants to increase the queue length beyond the initial limit, the
process has to either be privileged or that flag has to be set (and can
then not be unset again). On the other hand, decreasing below the
current value will not enforce this flag.

> Then, we could either increase sysctl_max_dgram_qlen or do something
> like :
>
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 526b6edab018..a608317e7dd4 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -643,7 +643,9 @@ static struct sock *unix_create1(struct net *net,
> struct socket *sock)
>  				&af_unix_sk_receive_queue_lock_key);
>
>  	sk->sk_write_space	= unix_write_space;
> -	sk->sk_max_ack_backlog	= net->unx.sysctl_max_dgram_qlen;
> +	sk->sk_max_ack_backlog	= max_t(u32,
> +					net->unx.sysctl_max_dgram_qlen,
> +					sk->sk_rcvbuf / SKB_TRUESIZE(256));
>  	sk->sk_destruct		= unix_sock_destructor;
>  	u	  = unix_sk(sk);
>  	u->path.dentry = NULL;

Doesn't this assume a typical datagram size of 256 bytes? Isn't that
something that should be left up to the user? Also, suddenly the RCVBUF
size of UNIX domain sockets suddenly becomes relevant, even though it
is never actually checked when it comes to queuing the messages (only
the SNDBUF size of the sending socket is checked). This creates really
inconsistent semantics in my eyes where the receive buffer is useful
for some things, but not for others.

Christian

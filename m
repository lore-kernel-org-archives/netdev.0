From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Stable regression with 'tcp: allow splice() to build full TSO
 packets'
Date: Fri, 18 May 2012 00:14:54 +0200
Message-ID: <1337292894.3403.66.camel@edumazet-glaptop>
References: <20120517121800.GA18052@1wt.eu>
	 <1337287279.3403.44.camel@edumazet-glaptop> <20120517211414.GP14498@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:45557 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964993Ab2EQWO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 18:14:59 -0400
Received: by wibhm6 with SMTP id hm6so352819wib.1
        for <netdev@vger.kernel.org>; Thu, 17 May 2012 15:14:57 -0700 (PDT)
In-Reply-To: <20120517211414.GP14498@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-17 at 23:14 +0200, Willy Tarreau wrote:

> ---
> 
> From 39c3f73176118a274ec9dea9c22c83d97a7fbfe0 Mon Sep 17 00:00:00 2001
> From: Willy Tarreau <w@1wt.eu>
> Date: Thu, 17 May 2012 22:43:20 +0200
> Subject: [PATCH] tcp: do_tcp_sendpages() must try to push data out on oom conditions
> 
> Since recent changes on TCP splicing (starting with commits 2f533844
> and 35f9c09f), I started seeing massive stalls when forwarding traffic
> between two sockets using splice() when pipe buffers were larger than
> socket buffers.
> 
> Latest changes (net: netdev_alloc_skb() use build_skb()) made the
> problem even more apparent.
> 
> The reason seems to be that if do_tcp_sendpages() fails on out of memory
> condition without being able to send at least one byte, tcp_push() is not
> called and the buffers cannot be flushed.
> 
> After applying the attached patch, I cannot reproduce the stalls at all
> and the data rate it perfectly stable and steady under any condition
> which previously caused the problem to be permanent.
> 
> The issue seems to have been there since before the kernel migrated to
> git, which makes me think that the stalls I occasionally experienced
> with tux during stress-tests years ago were probably related to the
> same issue.
> 
> This issue was first encountered on 3.0.31 and 3.2.17, so please backport
> to -stable.
> 
> Signed-off-by: Willy Tarreau <w@1wt.eu>
> Cc: <stable@vger.kernel.org>
> ---
>  net/ipv4/tcp.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 63ddaee..231fe53 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -917,8 +917,7 @@ new_segment:
>  wait_for_sndbuf:
>  		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
>  wait_for_memory:
> -		if (copied)
> -			tcp_push(sk, flags & ~MSG_MORE, mss_now, TCP_NAGLE_PUSH);
> +		tcp_push(sk, flags & ~MSG_MORE, mss_now, TCP_NAGLE_PUSH);
>  
>  		if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)
>  			goto do_error;



Acked-by: Eric Dumazet <edumazet@google.com>

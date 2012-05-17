From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Stable regression with 'tcp: allow splice() to build full TSO
 packets'
Date: Thu, 17 May 2012 17:43:00 +0200
Message-ID: <1337269380.3403.10.camel@edumazet-glaptop>
References: <20120517121800.GA18052@1wt.eu>  <20120517150157.GA19274@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:60544 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752277Ab2EQPnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 11:43:06 -0400
Received: by eaak11 with SMTP id k11so559846eaa.19
        for <netdev@vger.kernel.org>; Thu, 17 May 2012 08:43:05 -0700 (PDT)
In-Reply-To: <20120517150157.GA19274@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-17 at 17:01 +0200, Willy Tarreau wrote:
> Hi Eric,
> 
> On Thu, May 17, 2012 at 02:18:00PM +0200, Willy Tarreau wrote:
> > Hi Eric,
> > 
> > I'm facing a regression in stable 3.2.17 and 3.0.31 which is
> > exhibited by your patch 'tcp: allow splice() to build full TSO
> > packets' which unfortunately I am very interested in !
> > 
> > What I'm observing is that TCP transmits using splice() stall
> > quite quickly if I'm using pipes larger than 64kB (even 65537
> > is enough to reliably observe the stall).
> (...)
> 
> I managed to fix the issue and I really think that the fix makes sense.
> I'm appending the patch, please could you review it and if approved,
> push it for inclusion ?
> 
> BTW, your patch significantly improves performance here. On this
> machine I was reaching max 515 Mbps of proxied traffic, and with
> the patch I reach 665 Mbps with the same test ! I think you managed
> to fix what caused splice() to always be slightly slower than
> recv/send() for a long time in my tests with a number of NICs !
> 

What NIC do you use exactly ?

With commit 1d0c0b328a6 in net-next
(net: makes skb_splice_bits() aware of skb->head_frag)
You'll be able to get even more speed, if NIC uses frag to hold frame.

> Thanks,
> Willy
> 
> -------
> 
> From 6da6a21798d0156e647a993c31782eec739fa5df Mon Sep 17 00:00:00 2001
> From: Willy Tarreau <w@1wt.eu>
> Date: Thu, 17 May 2012 16:48:56 +0200
> Subject: [PATCH] tcp: force push data out when buffers are missing
> 
> Commit 2f533844242 (tcp: allow splice() to build full TSO packets)
> significantly improved splice() performance for some workloads but
> caused stalls when pipe buffers were larger than socket buffers.
> 

But... This seems bug was already there ? Only having more data in pipe
trigger it more often ?

> The issue seems to happen when no data can be copied at all due to
> lack of buffers, which results in pending data never being pushed.
> 
> This change checks if all pending data has been pushed or not and
> pushes them when waiting for send buffers.
> ---
>  net/ipv4/tcp.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 80b988f..f6d9e5f 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -850,7 +850,7 @@ new_segment:
>  wait_for_sndbuf:
>  		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
>  wait_for_memory:
> -		if (copied)
> +		if (tcp_sk(sk)->pushed_seq != tcp_sk(sk)->write_seq)
>  			tcp_push(sk, flags & ~MSG_MORE, mss_now, TCP_NAGLE_PUSH);
>  
>  		if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)

Can you check you have commit 35f9c09fe9c72eb8ca2b8e89a593e1c151f28fc2 
( tcp: tcp_sendpages() should call tcp_push() once )

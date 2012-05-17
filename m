From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Stable regression with 'tcp: allow splice() to build full TSO
 packets'
Date: Thu, 17 May 2012 23:40:22 +0200
Message-ID: <1337290822.3403.47.camel@edumazet-glaptop>
References: <20120517121800.GA18052@1wt.eu>
	 <1337287279.3403.44.camel@edumazet-glaptop> <20120517211414.GP14498@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:40437 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759093Ab2EQVk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 17:40:27 -0400
Received: by weyu7 with SMTP id u7so1435376wey.19
        for <netdev@vger.kernel.org>; Thu, 17 May 2012 14:40:25 -0700 (PDT)
In-Reply-To: <20120517211414.GP14498@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-17 at 23:14 +0200, Willy Tarreau wrote:

> I understand and that could be possible indeed. Still, this precise code
> has been used for a few years now in prod at 10+ Gbps, so while that does
> not mean it's exempt from any race condition or bug, we have not observed
> this behaviour earlier. In fact, what I've not tested much was the small
> ARM based machine which is just a convenient development system to try to
> optimize network performance. Among the differences I see with usual
> deployments is that the NIC doesn't support TSO, while I've been used to
> enable splicing only where TSO was supported, because before your recent
> optimizations, it was less performant than recv/send.
> 
> > You drain bytes from fd 0xe to pipe buffers, but I dont see you check
> > write ability on destination socket prior the splice(pipe -> socket)
> 
> I don't, I only rely on EAGAIN to re-enable polling for write (otherwise
> it becomes a real mess of epoll_ctl which sensibly hurts performance). I
> only re-enable polling if FDs can't move anymore.
> 
> Before doing a splice(read), if any data are left pending in the pipe, I
> first try a splice(write) to try to flush the pipe, then I perform the
> splice(read) then try to flush the pipe again using a splice(write).
> Then polling is enabled if we block on EAGAIN.
> 
> I could fix the issue here by reworking my first patch. I think I was
> too much conservative, because if we leave do_tcp_sendpages() on OOM
> with copied == 0, in my opinion we never push. My first attempt tried
> to call tcp_push() only once but it seems like this is a wrong idea
> because it doesn't allow new attempts if for example tcp_write_xmit()
> cannot send upon first attempt.
> 
> After calling tcp_push() inconditionnally on OOM, I cannot reproduce
> the issue at all, and the traffic reaches a steady 950 Mbps in each
> direction.
> 
> I'm appending the patch, you'll know better than me if it's correct or
> not.
> 
> Best regards,
> Willy
> 
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


I dont understand why we should tcp_push() if we sent 0 bytes in this
splice() call.

The push() should have be done already by prior splice() call, dont you
think ?

out:
	if (copied && !(flags & MSG_SENDPAGE_NOTLAST))
		tcp_push(sk, flags, mss_now, tp->nonagle);

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: Check daddr_cache before use in tracepoint
Date: Mon, 16 Oct 2017 20:45:08 -0700
Message-ID: <1508211908.31614.90.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1508189387-27931-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:51322 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753420AbdJQDpL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 23:45:11 -0400
Received: by mail-pf0-f193.google.com with SMTP id n14so364773pfh.8
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 20:45:10 -0700 (PDT)
In-Reply-To: <1508189387-27931-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-10-16 at 14:29 -0700, David Ahern wrote:
> Running perf in one window to capture tcp_retransmit_skb tracepoint:
>     $ perf record -e tcp:tcp_retransmit_skb -a
> 
> And causing a retransmission on an active TCP session (e.g., dropping
> packets in the receiver, changing MTU on the interface to 500 and back
> to 1500) triggers a panic:
...

> Check that daddr_cache is non-NULL before de-referencing.
> 
> Fixes: e086101b150a ("tcp: add a tracepoint for tcp retransmission")
> Signed-off-by: David Ahern <dsahern@gmail.com>
> ---
>  include/trace/events/tcp.h | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/include/trace/events/tcp.h b/include/trace/events/tcp.h
> index 3d1cbd072b7e..13e8ee8af2c8 100644
> --- a/include/trace/events/tcp.h
> +++ b/include/trace/events/tcp.h
> @@ -48,7 +48,8 @@ TRACE_EVENT(tcp_retransmit_skb,
>  			pin6 = (struct in6_addr *)__entry->saddr_v6;
>  			*pin6 = np->saddr;
>  			pin6 = (struct in6_addr *)__entry->daddr_v6;
> -			*pin6 = *(np->daddr_cache);
> +			if (np->daddr_cache)
> +				*pin6 = *(np->daddr_cache);
>  		} else {
>  			pin6 = (struct in6_addr *)__entry->saddr_v6;
>  			ipv6_addr_set_v4mapped(inet->inet_saddr, pin6);

This is weird.

IPV6 TCP uses sk->sk_v6_daddr and sk->->sk_v6_rcv_saddr

So I would rather remove the need to fetch np = inet6_sk(sk) in the
first place, and look at sk->sk_family instead.

No need to get to np at all.

From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] net: tcp: ipv6_mapped needs sk_rx_dst_set method
Date: Sun, 19 Aug 2012 00:06:33 -0400
Message-ID: <CADVnQyn-aDMDdb_nfFyZPtmnKkuFtjwfSNWudnhMdYZz7Ddh7g@mail.gmail.com>
References: <20120809160349.d2880b5a.akpm@linux-foundation.org>
	<1344556733.31104.819.camel@edumazet-glaptop>
	<1344557460.31104.863.camel@edumazet-glaptop>
	<20120809.210600.638327100706973152.davem@davemloft.net>
	<20120818130642.GA10680@thinkpad.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org
To: Artem Savkov <artem.savkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:35514 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736Ab2HSEGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Aug 2012 00:06:34 -0400
Received: by ialo24 with SMTP id o24so1583242ial.19
        for <netdev@vger.kernel.org>; Sat, 18 Aug 2012 21:06:34 -0700 (PDT)
In-Reply-To: <20120818130642.GA10680@thinkpad.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 18, 2012 at 9:06 AM, Artem Savkov <artem.savkov@gmail.com> wrote:
> [ 1699.195040] EIP is at inet6_sk_rx_dst_set+0x40/0xa0
...
> [ 1699.198736]  [<c15662a1>] tcp_create_openreq_child+0x41/0x4e0
> [ 1699.198884]  [<c1563b54>] tcp_v4_syn_recv_sock+0x34/0x330
> [ 1699.199032]  [<c15d162e>] tcp_v6_syn_recv_sock+0x3fe/0x660
...
> [ 1699.242913] EIP: [<c15d11d0>] inet6_sk_rx_dst_set+0x40/0xa0 SS:ESP 0068:f540dce0
> [ 1699.245945] CR2: 0000000000000016
> [ 1699.280708] ---[ end trace 3fb05aeec95e7238 ]---
> [ 1699.280806] Kernel panic - not syncing: Fatal exception in interrupt
> [ 1699.284674] panic occurred, switching back to text console
>
> After some debugging I found out that rt->rt6i_node in inet6_sk_rx_dst_set
> is 0x02 when this happens.
>
> I've been able to fix this with:
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 4d63dff..a10a436 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -1198,6 +1198,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
>                  *      v6 mapped
>                  */
>
> +               inet_csk(sk)->icsk_af_ops = &ipv6_mapped;
>                 newsk = tcp_v4_syn_recv_sock(sk, skb, req, dst);
>
>                 if (newsk == NULL)
> @@ -1218,7 +1219,6 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
>
>                 newnp->rcv_saddr = newnp->saddr;
>
> -               inet_csk(newsk)->icsk_af_ops = &ipv6_mapped;
>                 newsk->sk_backlog_rcv = tcp_v4_do_rcv;
>  #ifdef CONFIG_TCP_MD5SIG
>                 newtp->af_specific = &tcp_sock_ipv6_mapped_specific;
>
> But not sure if this is safe. Is it better to add some kind of
> additional check to inet6_sk_rx_dst_set?

Thanks for the detailed report!

I don't think that particular fix is kosher, since this basically
changes the address family ops of the parent listening socket ('sk'
here).The parent listening socket needs to keep its IPv6 af_ops so its
IPv6 children can get the right af_ops.

We should probably either: (a) make sure the af_ops of the child
socket are set correctly earlier, or (b) not use dynamic dispatch
through the af_ops within tcp_create_openreq_child(), and just do the
sk_rx_dst_set a tiny bit later. I've sent out a patch for approach (b)
here, since it's simpler:

  http://patchwork.ozlabs.org/patch/178525/

I've verified that IPv4, IPv6, and IPv4-mapped-IPv6 connections work
for me with this patch. But if you could test it as well, that would
be great.

Thanks!
neal

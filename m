From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tcp_use_frto crashes on empty tcp_write_queue
Date: Wed, 13 Feb 2013 13:37:33 -0800
Message-ID: <1360791453.6884.34.camel@edumazet-glaptop>
References: <511C0127.1040604@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Frediano Ziglio <frediano.ziglio@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:47389 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760669Ab3BMVhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 16:37:39 -0500
Received: by mail-ie0-f182.google.com with SMTP id k14so2359880iea.13
        for <netdev@vger.kernel.org>; Wed, 13 Feb 2013 13:37:37 -0800 (PST)
In-Reply-To: <511C0127.1040604@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-02-13 at 21:09 +0000, Zoltan Kiss wrote:
> Hi,
> 
> I see the following WARN and then crash on 2.6.32.12:
> 
> <4>WARNING: at net/ipv4/tcp_timer.c:293 tcp_retransmit_timer+0x5dd/0x630()
> 
> ...
> 
> <1>BUG: unable to handle kernel NULL pointer dereference at (null)
> <1>IP: [<c033f2b5>] tcp_use_frto+0x45/0x90
> ...
> <0>Call Trace:
> <4> [<c0343ab9>] ? tcp_retransmit_timer+0xd9/0x630
> <4> [<c0120e58>] ? __wake_up_common+0x48/0x70
> <4> [<c0344580>] ? tcp_write_timer+0xe0/0x1a0
> <4> [<c0137fe1>] ? run_timer_softirq+0x151/0x200
> <4> [<c02af069>] ? maybe_schedule_tx_action+0x39/0x40
> <4> [<c03444a0>] ? tcp_write_timer+0x0/0x1a0
> <4> [<c013359a>] ? __do_softirq+0xba/0x180
> <4> [<c015e7a7>] ? move_native_irq+0x47/0x50
> ...
> 
> I've checked the code, tcp_use_frto() crashes because
> 
> skb = tcp_write_queue_head(sk);
> 
> returns a NULL, as the queue is empty, and in the next line:
> 
> if (tcp_skb_is_last(sk, skb))
> ===>
> static inline bool tcp_skb_is_last(const struct sock *sk,
>                     const struct sk_buff *skb)
> {
>      return skb_queue_is_last(&sk->sk_write_queue, skb);
> }
> ===>
> static inline bool skb_queue_is_last(const struct sk_buff_head *list,
>                       const struct sk_buff *skb)
> {
>      return (skb->next == (struct sk_buff *) list);
> }
> 
> That skb->next cause the NULL pointer dereference.
> 
> I've checked this in upstream, and it seems this would fail in the same 
> way. Wouldn't it be more reasonable to return from 
> tcp_retransmit_timer() instead of just signing a WARN? Something like this:
> 
> diff -r 7a748d2cb9f1 -r bb8257f0730a net/ipv4/tcp_timer.c
> --- a/net/ipv4/tcp_timer.c    Wed Feb 13 15:02:50 2013 +0000
> +++ b/net/ipv4/tcp_timer.c    Wed Feb 13 15:03:18 2013 +0000
> @@ -287,11 +287,9 @@ void tcp_retransmit_timer(struct sock *s
>       struct tcp_sock *tp = tcp_sk(sk);
>       struct inet_connection_sock *icsk = inet_csk(sk);
> 
> -    if (!tp->packets_out)
> +    if (!tp->packets_out || tcp_write_queue_empty(sk))
>           goto out;
> 
> -    WARN_ON(tcp_write_queue_empty(sk));
> -
>       if (!tp->snd_wnd && !sock_flag(sk, SOCK_DEAD) &&
>           !((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV))) {
>           /* Receiver dastardly shrinks window. Our retransmits

This doesn't seem to be a standard kernel.

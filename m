From: John Heffner <johnwheffner@gmail.com>
Subject: Re: [PATCHv3 net-next 2/4] ipv4: Use binary search to choose tcp PMTU probe_size
Date: Sat, 28 Feb 2015 18:20:41 -0500
Message-ID: <CABrhC0=ZPJwPOJFkuuJ+pJgn4CoVhZ2tJcrbce6kytVVtsy=9g@mail.gmail.com>
References: <1425093785-27380-1-git-send-email-fan.du@intel.com>
	<1425093785-27380-3-git-send-email-fan.du@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: edumazet@google.com, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Fan Du <fengyuleidian0615@gmail.com>
To: Fan Du <fan.du@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:43177 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808AbbB1XUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 18:20:43 -0500
Received: by labhv19 with SMTP id hv19so23821835lab.10
        for <netdev@vger.kernel.org>; Sat, 28 Feb 2015 15:20:41 -0800 (PST)
In-Reply-To: <1425093785-27380-3-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index a2a796c..c418829 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1837,11 +1837,13 @@ static int tcp_mtu_probe(struct sock *sk)
>         struct tcp_sock *tp = tcp_sk(sk);
>         struct inet_connection_sock *icsk = inet_csk(sk);
>         struct sk_buff *skb, *nskb, *next;
> +       struct net *net = sock_net(sk);
>         int len;
>         int probe_size;
>         int size_needed;
>         int copy;
>         int mss_now;
> +       int interval;
>
>         /* Not currently probing/verifying,
>          * not in recovery,
> @@ -1854,11 +1856,17 @@ static int tcp_mtu_probe(struct sock *sk)
>             tp->rx_opt.num_sacks || tp->rx_opt.dsack)
>                 return -1;
>
> -       /* Very simple search strategy: just double the MSS. */
> +       /* Use binary search for probe_size bewteen tcp_mss_base,
> +        * and current mss_clamp. if (search_high - search_low)
> +        * smaller than a threshold, backoff from probing.
> +        */
>         mss_now = tcp_current_mss(sk);
> -       probe_size = 2 * tp->mss_cache;
> +       probe_size = (icsk->icsk_mtup.search_high +
> +                     icsk->icsk_mtup.search_low) >> 1;
>         size_needed = probe_size + (tp->reordering + 1) * tp->mss_cache;
> -       if (probe_size > tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_high)) {
> +       interval = icsk->icsk_mtup.search_high - icsk->icsk_mtup.search_low;
> +       if (probe_size > tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_high) ||
> +           interval < net->ipv4.sysctl_tcp_probe_threshold) {
>                 /* TODO: set timer for probe_converge_event */
>                 return -1;
>         }

A couple things: the local variable probe_size here is TCP segment
size, while search_low and search_high are IP datagram sizes.  Use
tcp_mtu_to_mss to subtract headers.  Also, I think if you set
sysctl_tcp_probe_threshold <= 0, this will keep probing indefinitely
at search_low (not useful).  You probably want to test interval <
max(1, sysctl_tcp_probe_threshold).

  -John

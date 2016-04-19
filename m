From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [RFC PATCH v2 net-next 2/7] tcp: Merge tx_flags/tskey/txstamp_ack
 in tcp_collapse_retrans
Date: Tue, 19 Apr 2016 01:32:14 -0400
Message-ID: <CACSApvY5ZdyUO1i2O0KPGJM5meWHFv3hdi9Ew89CH--jFV4yOw@mail.gmail.com>
References: <1461019569-3037369-1-git-send-email-kafai@fb.com> <1461019569-3037369-3-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Soheil Hassas Yeganeh <soheil.kdev@gmail.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:33019 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751741AbcDSFdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 01:33:00 -0400
Received: by mail-ob0-f180.google.com with SMTP id tz8so2982688obc.0
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 22:32:59 -0700 (PDT)
In-Reply-To: <1461019569-3037369-3-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 18, 2016 at 6:46 PM, Martin KaFai Lau <kafai@fb.com> wrote:
> If two skbs are merged/collapsed during retransmission, the current
> logic does not merge the tx_flags, tskey and txstamp_ack.  The end
> result is the SCM_TSTAMP_ACK timestamp could be missing for a
> packet that the end-user has specifically turned on
> SOF_TIMESTAMPING_TX_ACK (e.g. by cmsg).
>
> The patch:
> 1. Merge the tx_flags and txstamp_ack
> 2. Overwrite the tskey with the later skb (next_skb)
>
> BPF Output Before:
> ~~~~~~
> <no-output-due-to-missing-tstamp-event>
>
> BPF Output After:
> ~~~~~~
> packetdrill-2092  [001] d.s.   453.998486: : ee_data:1459
>
> Packetdrill Script:
> ~~~~~~
> +0 `sysctl -q -w net.ipv4.tcp_min_tso_segs=10`
> +0 `sysctl -q -w net.ipv4.tcp_no_metrics_save=1`
> +0 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
> +0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
> +0 bind(3, ..., ...) = 0
> +0 listen(3, 1) = 0
>
> 0.100 < S 0:0(0) win 32792 <mss 1460,sackOK,nop,nop,nop,wscale 7>
> 0.100 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 7>
> 0.200 < . 1:1(0) ack 1 win 257
> 0.200 accept(3, ..., ...) = 4
> +0 setsockopt(4, SOL_TCP, TCP_NODELAY, [1], 4) = 0
>
> 0.200 write(4, ..., 730) = 730
> +0 setsockopt(4, SOL_SOCKET, 37, [2688], 4) = 0
> 0.200 write(4, ..., 730) = 730
> +0 setsockopt(4, SOL_SOCKET, 37, [2176], 4) = 0
> 0.200 write(4, ..., 11680) = 11680
>
> 0.200 > P. 1:731(730) ack 1
> 0.200 > P. 731:1461(730) ack 1
> 0.200 > . 1461:8761(7300) ack 1
> 0.200 > P. 8761:13141(4380) ack 1
>
> 0.300 < . 1:1(0) ack 1 win 257 <sack 1461:2921,nop,nop>
> 0.300 < . 1:1(0) ack 1 win 257 <sack 1461:4381,nop,nop>
> 0.300 < . 1:1(0) ack 1 win 257 <sack 1461:5841,nop,nop>
> 0.300 > P. 1:1461(1460) ack 1
> 0.400 < . 1:1(0) ack 13141 win 257
>
> 0.400 close(4) = 0
> 0.400 > F. 13141:13141(0) ack 1
> 0.500 < F. 1:1(0) ack 13142 win 257
> 0.500 > . 13142:13142(0) ack 2
>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>

Cc:  Soheil Hassas Yeganeh <soheil@google.com>

> Cc: Willem de Bruijn <willemb@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> ---
>  net/ipv4/tcp_output.c | 18 ++++++++++++++++++
>  1 file changed, 18 insertions(+)
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 0527ce9..889ed96 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2443,6 +2443,22 @@ u32 __tcp_select_window(struct sock *sk)
>         return window;
>  }
>
> +static void tcp_skb_collapse_tstamp(struct sk_buff *skb,
> +                                   const struct sk_buff *next_skb)
> +{
> +       const struct skb_shared_info *next_shinfo = skb_shinfo(next_skb);
> +
> +       if (unlikely(next_shinfo->tx_flags & SKBTX_ANY_TSTAMP)) {
> +               struct skb_shared_info *shinfo = skb_shinfo(skb);
> +               u8 tsflags = next_shinfo->tx_flags & SKBTX_ANY_TSTAMP;

nit: maybe move this local variable out of the if block?

      tsflags = ...
      if (unlikely(tsflags)) { ... }

> +
> +               shinfo->tx_flags |= tsflags;
> +               shinfo->tskey = next_shinfo->tskey;
> +               TCP_SKB_CB(skb)->txstamp_ack =
> +                       !!(shinfo->tx_flags & SKBTX_ACK_TSTAMP);

Maybe we can skip a conditional jump here (because of !!), by simply
using the cached bit in next_skb:
TCP_SKB_CB(skb)->txstamp_ack = TCP_SKB_CB(next_skb)->txstamp_ack;

> +       }
> +}
> +
>  /* Collapses two adjacent SKB's during retransmission. */
>  static void tcp_collapse_retrans(struct sock *sk, struct sk_buff *skb)
>  {
> @@ -2486,6 +2502,8 @@ static void tcp_collapse_retrans(struct sock *sk, struct sk_buff *skb)
>
>         tcp_adjust_pcount(sk, next_skb, tcp_skb_pcount(next_skb));
>
> +       tcp_skb_collapse_tstamp(skb, next_skb);
> +
>         sk_wmem_free_skb(sk, next_skb);
>  }

Really nice fixes! thanks.

> --
> 2.5.1
>

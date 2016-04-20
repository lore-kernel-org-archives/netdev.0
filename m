From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH net-next 2/2] tcp: Merge txstamp_ack in tcp_skb_collapse_tstamp
Date: Wed, 20 Apr 2016 15:15:46 -0400
Message-ID: <CACSApvaXf8ady1D7b++NgZdDzCTkkXU96RyjYoBUhMUW1kdTEA@mail.gmail.com>
References: <1461131448-1460418-1-git-send-email-kafai@fb.com> <1461131448-1460418-3-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:36572 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941AbcDTTQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 15:16:27 -0400
Received: by mail-oi0-f47.google.com with SMTP id x201so50981570oif.3
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 12:16:27 -0700 (PDT)
In-Reply-To: <1461131448-1460418-3-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 20, 2016 at 1:50 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> When collapsing skbs, txstamp_ack also needs to be merged.
>
> Retrans Collapse Test:
> ~~~~~~
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
> BPF Output Before:
> ~~~~~
> <No output due to missing SCM_TSTAMP_ACK timestamp>
>
> BPF Output After:
> ~~~~~
> <...>-2027  [007] d.s.    79.765921: : ee_data:1459
>
> Sacks Collapse Test:
> ~~~~~
> 0.200 accept(3, ..., ...) = 4
> +0 setsockopt(4, SOL_TCP, TCP_NODELAY, [1], 4) = 0
>
> 0.200 write(4, ..., 1460) = 1460
> +0 setsockopt(4, SOL_SOCKET, 37, [2688], 4) = 0
> 0.200 write(4, ..., 13140) = 13140
> +0 setsockopt(4, SOL_SOCKET, 37, [2176], 4) = 0
>
> 0.200 > P. 1:1461(1460) ack 1
> 0.200 > . 1461:8761(7300) ack 1
> 0.200 > P. 8761:14601(5840) ack 1
>
> 0.300 < . 1:1(0) ack 1 win 257 <sack 1461:14601,nop,nop>
> 0.300 > P. 1:1461(1460) ack 1
> 0.400 < . 1:1(0) ack 14601 win 257
>
> BPF Output Before:
> ~~~~~
> <No output due to missing SCM_TSTAMP_ACK timestamp>
>
> BPF Output After:
> ~~~~~
> <...>-2049  [007] d.s.    89.185538: : ee_data:14599
>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Soheil Hassas Yeganeh <soheil@google.com>
> Cc: Willem de Bruijn <willemb@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
Acked-by: Soheil Hassas Yeganeh <soheil@google.com>
Tested-by: Soheil Hassas Yeganeh <soheil@google.com>
> ---
>  net/ipv4/tcp_output.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index f7c3bc0..a6e4a83 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2454,6 +2454,8 @@ void tcp_skb_collapse_tstamp(struct sk_buff *skb,
>
>                 shinfo->tx_flags |= tsflags;
>                 shinfo->tskey = next_shinfo->tskey;
> +               TCP_SKB_CB(skb)->txstamp_ack |=
> +                       TCP_SKB_CB(next_skb)->txstamp_ack;
>         }
>  }
>
> --
> 2.5.1
>

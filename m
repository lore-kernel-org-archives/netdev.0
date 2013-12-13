From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: remove a bogus TSO split
Date: Fri, 13 Dec 2013 06:54:09 -0800
Message-ID: <1386946449.19078.147.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386876523.19078.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CADVnQymwaUNVgzqM97vfb=nfMFzVWmK8wR7fQ8Wm3i_c8+Z0jA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Van Jacobson <vanj@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:48084 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752825Ab3LMOyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 09:54:11 -0500
Received: by mail-pa0-f46.google.com with SMTP id kl14so117876pab.19
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 06:54:11 -0800 (PST)
In-Reply-To: <CADVnQymwaUNVgzqM97vfb=nfMFzVWmK8wR7fQ8Wm3i_c8+Z0jA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-13 at 09:15 -0500, Neal Cardwell wrote:

> Seems like a nice improvement, but if we apply this patch then AFAICT
> to get the Nagle-enabled case right we also have to update
> tcp_minshall_update() to notice these new non-MSS-aligned segments
> going out, and count those as non-full-size segments for the
> minshall-nagle check (to ensure we have no more than one outstanding
> un-ACKed sub-MSS packet). Maybe something like (please excuse the
> formatting):
> 
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 70e55d2..a2ec237 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -980,7 +980,8 @@ bool tcp_is_cwnd_limited(const struct sock *sk,
> u32 in_flight);
>  static inline void tcp_minshall_update(struct tcp_sock *tp, unsigned int mss,
>                                        const struct sk_buff *skb)
>  {
> -       if (skb->len < mss)
> +       if (skb->len < mss ||
> +           tcp_skb_pcount(skb) * tcp_skb_mss(skb) > skb->len)
>                 tp->snd_sml = TCP_SKB_CB(skb)->end_seq;
>  }

Very good point Neal, but dont you think tcp_skb_mss(skb) is equal to
mss at this point ? (We normally have synced with tso_segs =
tcp_init_tso_segs(sk, skb, mss_now);)

(Just trying to make this code more understandable...)

Also I think we should move this helper out of include/net/tcp.h, we
only use it from tcp_output.c

I'll submit a v2, rewording the comment in front of
tcp_mss_split_point()

Thanks

From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH v4 net-next 3/3] tcp: Handle eor bit when fragmenting a skb
Date: Mon, 25 Apr 2016 20:49:36 -0400
Message-ID: <CACSApvYmKNdvnxh1KUA8kRDxXf=79Hbwq1T9E+g8ZJjnBqK0LQ@mail.gmail.com>
References: <1461620690-1081063-1-git-send-email-kafai@fb.com> <1461620690-1081063-4-git-send-email-kafai@fb.com>
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
Received: from mail-oi0-f41.google.com ([209.85.218.41]:34991 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbcDZAuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 20:50:17 -0400
Received: by mail-oi0-f41.google.com with SMTP id x19so60935446oix.2
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 17:50:16 -0700 (PDT)
In-Reply-To: <1461620690-1081063-4-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 25, 2016 at 5:44 PM, Martin KaFai Lau <kafai@fb.com> wrote:
> When fragmenting a skb, the next_skb should carry
> the eor from prev_skb.  The eor of prev_skb should
> also be reset.
>
> Packetdrill script for testing:
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
> 0.200 sendto(4, ..., 15330, MSG_EOR, ..., ...) = 15330
> 0.200 sendto(4, ..., 730, 0, ..., ...) = 730
>
> 0.200 > .  1:7301(7300) ack 1
> 0.200 > . 7301:14601(7300) ack 1
>
> 0.300 < . 1:1(0) ack 14601 win 257
> 0.300 > P. 14601:15331(730) ack 1
> 0.300 > P. 15331:16061(730) ack 1
>
> 0.400 < . 1:1(0) ack 16061 win 257
> 0.400 close(4) = 0
> 0.400 > F. 16061:16061(0) ack 1
> 0.400 < F. 1:1(0) ack 16062 win 257
> 0.400 > . 16062:16062(0) ack 2
>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Soheil Hassas Yeganeh <soheil@google.com>
> Cc: Willem de Bruijn <willemb@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>

Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

> ---
>  net/ipv4/tcp_output.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index fa4d17f..55a926b 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1128,6 +1128,12 @@ static void tcp_fragment_tstamp(struct sk_buff *skb, struct sk_buff *skb2)
>         }
>  }
>
> +static void tcp_skb_fragment_eor(struct sk_buff *skb, struct sk_buff *skb2)
> +{
> +       TCP_SKB_CB(skb2)->eor = TCP_SKB_CB(skb)->eor;
> +       TCP_SKB_CB(skb)->eor = 0;
> +}
> +
>  /* Function to create two new TCP segments.  Shrinks the given segment
>   * to the specified size and appends a new segment with the rest of the
>   * packet to the list.  This won't be called frequently, I hope.
> @@ -1173,6 +1179,7 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
>         TCP_SKB_CB(skb)->tcp_flags = flags & ~(TCPHDR_FIN | TCPHDR_PSH);
>         TCP_SKB_CB(buff)->tcp_flags = flags;
>         TCP_SKB_CB(buff)->sacked = TCP_SKB_CB(skb)->sacked;
> +       tcp_skb_fragment_eor(skb, buff);
>
>         if (!skb_shinfo(skb)->nr_frags && skb->ip_summed != CHECKSUM_PARTIAL) {
>                 /* Copy and checksum data tail into the new buffer. */
> @@ -1733,6 +1740,8 @@ static int tso_fragment(struct sock *sk, struct sk_buff *skb, unsigned int len,
>         /* This packet was never sent out yet, so no SACK bits. */
>         TCP_SKB_CB(buff)->sacked = 0;
>
> +       tcp_skb_fragment_eor(skb, buff);
> +
>         buff->ip_summed = skb->ip_summed = CHECKSUM_PARTIAL;
>         skb_split(skb, buff, len);
>         tcp_fragment_tstamp(skb, buff);
> --
> 2.5.1
>

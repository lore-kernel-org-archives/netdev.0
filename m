From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH v2 net] tcp: add proper TS val into RST packets
Date: Wed, 23 Sep 2015 14:13:35 -0700
Message-ID: <CAK6E8=eGveAnOJKcvX6i+DNS0HYiOBW0nKeOxNFGg_+R1h2rFg@mail.gmail.com>
References: <1443039593.29850.133.camel@edumazet-glaptop2.roam.corp.google.com>
 <CADVnQynZ97Ben7TOSiNOxsfamQEkuw4VH4xxzj4=hpN_rgySJw@mail.gmail.com>
 <CAK6E8=eJfmZV_O14JqucQD4LD+OCybhB1D+PV2giz-Jmpph3qA@mail.gmail.com>
 <1443041578.29850.137.camel@edumazet-glaptop2.roam.corp.google.com> <1443042021.29850.141.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f54.google.com ([209.85.213.54]:36819 "EHLO
	mail-vk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755397AbbIWVOP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 17:14:15 -0400
Received: by vkfp126 with SMTP id p126so36189108vkf.3
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 14:14:14 -0700 (PDT)
In-Reply-To: <1443042021.29850.141.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 23, 2015 at 2:00 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> RST packets sent on behalf of TCP connections with TS option (RFC 7323
> TCP timestamps) have incorrect TS val (set to 0), but correct TS ecr.
>
> A > B: Flags [S], seq 0, win 65535, options [mss 1000,nop,nop,TS val 100
> ecr 0], length 0
> B > A: Flags [S.], seq 2444755794, ack 1, win 28960, options [mss
> 1460,nop,nop,TS val 7264344 ecr 100], length 0
> A > B: Flags [.], ack 1, win 65535, options [nop,nop,TS val 110 ecr
> 7264344], length 0
>
> B > A: Flags [R.], seq 1, ack 1, win 28960, options [nop,nop,TS val 0
> ecr 110], length 0
>
> We need to call skb_mstamp_get() to get proper TS val,
> derived from skb->skb_mstamp
>
> Note that RFC 1323 was advocating to not send TS option in RST segment,
> but RFC 7323 recommends the opposite :
>
>   Once TSopt has been successfully negotiated, that is both <SYN> and
>   <SYN,ACK> contain TSopt, the TSopt MUST be sent in every non-<RST>
>   segment for the duration of the connection, and SHOULD be sent in an
>   <RST> segment (see Section 5.2 for details)
>
> Note this RFC recommends to send TS val = 0, but we believe it is
> premature : We do not know if all TCP stacks are properly
> handling the receive side :
>
>    When an <RST> segment is
>    received, it MUST NOT be subjected to the PAWS check by verifying an
>    acceptable value in SEG.TSval, and information from the Timestamps
>    option MUST NOT be used to update connection state information.
>    SEG.TSecr MAY be used to provide stricter <RST> acceptance checks.
>
>
> In 5 years, if/when all TCP stack are RFC 7323 ready, we might consider
> to decide to send TS val = 0, if it buys something.
>
> Fixes: 7faee5c0d514 ("tcp: remove TCP_SKB_CB(skb)->when")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Yuchung Cheng <ycheng@google.com>

Nice fix (and comment)!

> ---
>  net/ipv4/tcp_output.c |    1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index f9a8a12b62ee..1100ffe4a722 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2897,6 +2897,7 @@ void tcp_send_active_reset(struct sock *sk, gfp_t priority)
>         skb_reserve(skb, MAX_TCP_HEADER);
>         tcp_init_nondata_skb(skb, tcp_acceptable_seq(sk),
>                              TCPHDR_ACK | TCPHDR_RST);
> +       skb_mstamp_get(&skb->skb_mstamp);
>         /* Send it off. */
>         if (tcp_transmit_skb(sk, skb, 0, priority))
>                 NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPABORTFAILED);
>
>

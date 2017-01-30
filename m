From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH] ipv6: fix flow labels when the traffic class is non-0
Date: Mon, 30 Jan 2017 15:40:53 -0800
Message-ID: <CALx6S375e127OSj9cHk4JuJLdee6tUmnBz7gSrsWTSLFP84JaA@mail.gmail.com>
References: <20170130220942.19105-1-dmichail@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Dimitris Michailidis <dmichail@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:36050 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753196AbdA3XmI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 18:42:08 -0500
Received: by mail-qk0-f195.google.com with SMTP id i34so18682250qkh.3
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 15:40:54 -0800 (PST)
In-Reply-To: <20170130220942.19105-1-dmichail@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 30, 2017 at 2:09 PM, Dimitris Michailidis
<dmichail@google.com> wrote:
> ip6_make_flowlabel() determines the flow label for IPv6 packets. It's
> supposed to be passed a flow label, which it returns as is if non-0 and
> in some other cases, otherwise it calculates a new value.
>
> The problem is callers often pass a flowi6.flowlabel, which may also
> contain traffic class bits. If the traffic class is non-0
> ip6_make_flowlabel() mistakes the non-0 it gets as a flow label and
> returns the whole thing. Thus it can return a 'flow label' longer than
> 20b and the low 20b of that is typically 0 resulting in packets with 0
> label. Moreover, different packets of a flow may be labeled differently.
> For a TCP flow with ECN non-payload and payload packets get different
> labels as exemplified by this pair of consecutive packets:
>
> (pure ACK)
> Internet Protocol Version 6, Src: 2002:af5:11a3::, Dst: 2002:af5:11a2::
>     0110 .... = Version: 6
>     .... 0000 0000 .... .... .... .... .... = Traffic Class: 0x00 (DSCP: CS0, ECN: Not-ECT)
>         .... 0000 00.. .... .... .... .... .... = Differentiated Services Codepoint: Default (0)
>         .... .... ..00 .... .... .... .... .... = Explicit Congestion Notification: Not ECN-Capable Transport (0)
>     .... .... .... 0001 1100 1110 0100 1001 = Flow Label: 0x1ce49
>     Payload Length: 32
>     Next Header: TCP (6)
>
> (payload)
> Internet Protocol Version 6, Src: 2002:af5:11a3::, Dst: 2002:af5:11a2::
>     0110 .... = Version: 6
>     .... 0000 0010 .... .... .... .... .... = Traffic Class: 0x02 (DSCP: CS0, ECN: ECT(0))
>         .... 0000 00.. .... .... .... .... .... = Differentiated Services Codepoint: Default (0)
>         .... .... ..10 .... .... .... .... .... = Explicit Congestion Notification: ECN-Capable Transport codepoint '10' (2)
>     .... .... .... 0000 0000 0000 0000 0000 = Flow Label: 0x00000
>     Payload Length: 688
>     Next Header: TCP (6)
>
> This patch allows ip6_make_flowlabel() to be passed more than just a
> flow label and has it extract the part it really wants. This was simpler
> than modifying the callers. With this patch packets like the above become
>
> Internet Protocol Version 6, Src: 2002:af5:11a3::, Dst: 2002:af5:11a2::
>     0110 .... = Version: 6
>     .... 0000 0000 .... .... .... .... .... = Traffic Class: 0x00 (DSCP: CS0, ECN: Not-ECT)
>         .... 0000 00.. .... .... .... .... .... = Differentiated Services Codepoint: Default (0)
>         .... .... ..00 .... .... .... .... .... = Explicit Congestion Notification: Not ECN-Capable Transport (0)
>     .... .... .... 1010 1111 1010 0101 1110 = Flow Label: 0xafa5e
>     Payload Length: 32
>     Next Header: TCP (6)
>
> Internet Protocol Version 6, Src: 2002:af5:11a3::, Dst: 2002:af5:11a2::
>     0110 .... = Version: 6
>     .... 0000 0010 .... .... .... .... .... = Traffic Class: 0x02 (DSCP: CS0, ECN: ECT(0))
>         .... 0000 00.. .... .... .... .... .... = Differentiated Services Codepoint: Default (0)
>         .... .... ..10 .... .... .... .... .... = Explicit Congestion Notification: ECN-Capable Transport codepoint '10' (2)
>     .... .... .... 1010 1111 1010 0101 1110 = Flow Label: 0xafa5e
>     Payload Length: 688
>     Next Header: TCP (6)
>
> Signed-off-by: Dimitris Michailidis <dmichail@google.com>
> ---
>  include/net/ipv6.h | 5 +++++
>  1 file changed, 5 insertions(+)
>
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index 7afe991e900e..dbf0abba33b8 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -776,6 +776,11 @@ static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
>  {
>         u32 hash;
>
> +       /* @flowlabel may include more than a flow label, eg, the traffic class.
> +        * Here we want only the flow label value.
> +        */
> +       flowlabel &= IPV6_FLOWLABEL_MASK;
> +
Thanks for pointing out the issue, but I don't think this fix is quite
right. This would be discarding traffic class from being in the return
value. I can try to fix that.

Tom

>         if (flowlabel ||
>             net->ipv6.sysctl.auto_flowlabels == IP6_AUTO_FLOW_LABEL_OFF ||
>             (!autolabel &&
> --
> 2.11.0.483.g087da7b7c-goog
>

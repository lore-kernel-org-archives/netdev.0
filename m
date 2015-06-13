From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 2/2] flow_dissector: add support for dst,
 hop-by-hop and routing ext hdrs
Date: Fri, 12 Jun 2015 18:27:53 -0700
Message-ID: <20150613012752.GA9895@Alexeis-MacBook-Pro.local>
References: <1434124866-3881537-1-git-send-email-tom@herbertland.com>
 <1434124866-3881537-3-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>, edumazet@google.com,
	netdev@vger.kernel.org, dan.carpenter@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35606 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752795AbbFMB14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 21:27:56 -0400
Received: by pacyx8 with SMTP id yx8so31144619pac.2
        for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 18:27:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1434124866-3881537-3-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 12, 2015 at 09:01:06AM -0700, Tom Herbert wrote:
> If dst, hop-by-hop or routing extension headers are present determine
> length of the options and skip over them in flow dissection.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  net/core/flow_dissector.c | 17 +++++++++++++++++
>  1 file changed, 17 insertions(+)
> 
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index 1818cdc..22e4dff 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -327,6 +327,7 @@ mpls:
>  		return false;
>  	}
>  
> +ip_proto_again:
>  	switch (ip_proto) {
>  	case IPPROTO_GRE: {
>  		struct gre_hdr {
> @@ -383,6 +384,22 @@ mpls:
>  		}
>  		goto again;
>  	}
> +	case NEXTHDR_HOP:
> +	case NEXTHDR_ROUTING:
> +	case NEXTHDR_DEST: {
> +		u8 _opthdr[2], *opthdr;
> +
> +		if (proto != htons(ETH_P_IPV6))
> +			break;
> +
> +		opthdr = __skb_header_pointer(skb, nhoff, sizeof(_opthdr),
> +					      data, hlen, &_opthdr);
> +
> +		ip_proto = _opthdr[0];
> +		nhoff += (_opthdr[1] + 1) << 3;
> +
> +		goto ip_proto_again;
> +	}

Dave,

please revert it. My server locks up during boot with:

[   32.391955] NMI watchdog: BUG: soft lockup - CPU#2 stuck for 23s! [modprobe:1550]
[   32.392043] RIP: 0010:[<ffffffff815cd8e2>]  [<ffffffff815cd8e2>] skb_copy_bits+0x12/0x260
[   32.392060] Call Trace:
[   32.392061]  <IRQ>
[   32.392063]  [<ffffffff815d9f38>] __skb_flow_dissect+0x358/0x820
[   32.392064]  [<ffffffff815da48e>] __skb_get_hash+0x8e/0x2e0
[   32.392066]  [<ffffffff815def7b>] __skb_tx_hash+0x5b/0xb0
[   32.392067]  [<ffffffff815df54a>] __netdev_pick_tx+0x18a/0x1a0
[   32.392068]  [<ffffffff815df40a>] ? __netdev_pick_tx+0x4a/0x1a0
[   32.392069]  [<ffffffff815e4db0>] ? __dev_queue_xmit+0x50/0x620
[   32.392071]  [<ffffffff815e4d0b>] netdev_pick_tx+0xcb/0x120
[   32.392072]  [<ffffffff815e4e08>] __dev_queue_xmit+0xa8/0x620
[   32.392073]  [<ffffffff815e4db0>] ? __dev_queue_xmit+0x50/0x620
[   32.392076]  [<ffffffff81698225>] ? ip6_finish_output+0xa5/0x1e0
[   32.392077]  [<ffffffff815e53a3>] dev_queue_xmit_sk+0x13/0x20
[   32.392078]  [<ffffffff81696144>] ip6_finish_output2+0x464/0x5f0
[   32.392079]  [<ffffffff81698225>] ? ip6_finish_output+0xa5/0x1e0
[   32.392081]  [<ffffffff816a5bf2>] ? ip6_mtu+0xb2/0xd0
[   32.392082]  [<ffffffff816a5b80>] ? ip6_mtu+0x40/0xd0
[   32.392083]  [<ffffffff81698225>] ip6_finish_output+0xa5/0x1e0
[   32.392084]  [<ffffffff816983be>] ip6_output+0x5e/0x1b0

From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 5/6] ipv6: Call xfrm6_xlat_addr from ipv6_rcv
Date: Wed, 30 Sep 2015 01:26:17 +0200
Message-ID: <20150929232617.GG19923@breakpoint.cc>
References: <1443565043-1287886-1-git-send-email-tom@herbertland.com>
 <1443565043-1287886-6-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:42424 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750827AbbI2X0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 19:26:23 -0400
Content-Disposition: inline
In-Reply-To: <1443565043-1287886-6-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <tom@herbertland.com> wrote:
> Call before performing NF_HOOK and routing in order to perform address
> translation in the receive path.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  net/ipv6/ip6_input.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
> index 9075acf..06dac55 100644
> --- a/net/ipv6/ip6_input.c
> +++ b/net/ipv6/ip6_input.c
> @@ -183,6 +183,9 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
>  	/* Must drop socket now because of tproxy. */
>  	skb_orphan(skb);
>  
> +	/* Translate destination address before routing */
> +	xfrm6_xlat_addr(skb);
> +

Ugh.  Yet another hook :-(
One would think we have enough by now.

In any case, I still think this ILA translation stuff should either
go into xtables (NPT-ish), nftables, or into tc if nft is unusable for
whatever reeason.  Judging by where this hook is placed, nf hooks
would work just fine.

If the iptables traverser has too high cost (unfortunately,
xtables design enforces counters and iface name matching even if its
not wanted/unneeded for instance), maybe nft would perform better in that
regard.

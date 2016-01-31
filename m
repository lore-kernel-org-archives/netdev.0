From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net] net: Allow flow dissector to handle non 4-byte
 aligned headers
Date: Sun, 31 Jan 2016 23:06:06 +0100
Message-ID: <20160131220606.GA540@breakpoint.cc>
References: <1454276221-3543907-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	sowmini.varadhan@oracle.com, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:60530 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757294AbcAaWGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jan 2016 17:06:11 -0500
Content-Disposition: inline
In-Reply-To: <1454276221-3543907-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <tom@herbertland.com> wrote:
> Call get_unaligned_be32 when we access 32-bit fields in
> __skb_flow_dissect. At the beginning check for unlikely case of
> 1-byte aligned packet.
> 
> Note that flow_dissector may be asked to parse packet unaligned
> fields in two instances:
> 
> 1) Packet from a driver which is aligned to Ethernet header
>    (2-byte alignment)
> 2) Parsing inner headers of a received GRE-TEB packet
> 
> Testing: Ran super_netperf tests did not see a regression. This was on
> x86 which does not have problems with unaligned data.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  net/core/flow_dissector.c | 19 ++++++++++++++-----
>  1 file changed, 14 insertions(+), 5 deletions(-)
> 
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index d79699c..1c64a1a 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -95,7 +95,7 @@ __be32 __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
>  		ports = __skb_header_pointer(skb, thoff + poff,
>  					     sizeof(_ports), data, hlen, &_ports);
>  		if (ports)
> -			return *ports;
> +			return get_unaligned_be32(ports);

This adds an ntohl(), is that intended (same for other places)?

> +#ifndef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
> +	if (WARN_ON(((u64)data & 0x1)))
> +		return false;
> +#endif

WARN_ON_ONCE ?

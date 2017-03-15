From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net] bridge: ebtables: fix reception of frames DNAT-ed to
 bridge device
Date: Wed, 15 Mar 2017 11:26:08 +0100
Message-ID: <20170315102608.GB24366@breakpoint.cc>
References: <20170315031811.22714-1-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        bridge@lists.linux-foundation.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, linux-kernel@vger.kernel.org
To: Linus =?iso-8859-15?Q?L=FCssing?= <linus.luessing@c0d3.blue>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:45022 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751487AbdCOK0m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 06:26:42 -0400
Content-Disposition: inline
In-Reply-To: <20170315031811.22714-1-linus.luessing@c0d3.blue>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linus Lüssing <linus.luessing@c0d3.blue> wrote:
> When trying to redirect bridged frames to the bridge device itself
> via the ebtables nat-prerouting chain and the dnat target then this
> currently fails:
> 
> The ethernet destination of the frame is dnat'ed to the MAC address of
> the bridge itself just fine and the correctly altered frame can even
> be captured via a tcpdump on br0 (with or without promisc mode).
>
> However, the IP code drops it in the beginning of ip_input.c/ip_rcv()
> as the dnat target did not update the skb->pkt_type.

Right, thats the reason why ebtables also has ebt_redirect target
which does this pkt_type fixup.

> -		if (dst->is_local)
> +		if (dst->is_local) {
> +			/* fix up potential DNAT mess */
> +			skb->pkt_type = PACKET_HOST;
> +
>  			return br_pass_frame_up(skb);
> +		}

I don't mind this change though (i.e. I don't see how this would
bite us later).

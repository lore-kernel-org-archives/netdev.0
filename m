From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 1/2] net: Export skb_zerocopy() to zerocopy from
 one skb to another
Date: Fri, 24 May 2013 17:01:06 +0100
Message-ID: <20130524160106.GA30252@casper.infradead.org>
References: <cover.1369406826.git.tgraf@suug.ch>
 <d209be514b6eff718e0b6562da289faadd014806.1369406826.git.tgraf@suug.ch>
 <1369409516.3301.407.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jesse@nicira.com, dev@openvswitch.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51926 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754721Ab3EXQBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 12:01:08 -0400
Content-Disposition: inline
In-Reply-To: <1369409516.3301.407.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/24/13 at 08:31am, Eric Dumazet wrote:
> Hmm. Big warning here : In the nfnetlink case, we specifically made sure
> that this path was taken only if skb->head_frag was set (all incoming
> packets have this property, but not outgoing ones yet)
> 
> This should be documented if we move it to net/core/skbuff.c, or we
> should add a BUG_ON()

Good point.

I guess we could ensure in skb_zerocopy() that if !head_frag then we
enforce hlen = max(hlen, skb_headlen(skb)) to always fall back to
skb_copy_bits() for !head_frag.

> I see your openvswitch code seems OK.
> 
> Maybe also put in net/core/skbuff.c the code dealing with  this stuff ?
> 
> +       if (!skb->head_frag ||
> +           skb_headlen(skb) < L1_CACHE_BYTES ||
> +           skb_shinfo(skb)->nr_frags >= MAX_SKB_FRAGS)
> +               hlen = skb_headlen(skb);
> +
> +       if (skb_has_frag_list(skb))
> +               hlen = skb->len;

I'll put this into skb_zerocopy_hdrlen()

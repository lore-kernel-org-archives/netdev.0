From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NIU support for skb->rxhash
Date: Thu, 22 Apr 2010 14:19:22 -0700 (PDT)
Message-ID: <20100422.141922.39169749.davem@davemloft.net>
References: <20100422.042157.99869295.davem@davemloft.net>
	<1271936598.7895.5304.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55441
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758296Ab0DVVTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 17:19:17 -0400
In-Reply-To: <1271936598.7895.5304.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 22 Apr 2010 13:43:18 +0200

> Then, our stack also touch all 256 bytes of skb structure itself.
> 
> offsetof(struct sk_buff, next)    =0x0
> offsetof(struct sk_buff, rxhash)  =0xa8
> offsetof(struct sk_buff, dev)     =0x20
> offsetof(struct sk_buff, len)     =0x68
> offsetof(struct sk_buff, protocol)=0x7e
> offsetof(struct sk_buff, network_header)=0xc0
> offsetof(struct sk_buff, data)    =0xd8
> offsetof(struct sk_buff, head)    =0xd0
> 
> Time for a reordering I guess ;)

Indeed.

Also I have some ideas about what we can do if we have
just the rxhash.  It seems we can avoid the type_trans
overhead on the interrupting cpu.

Things like eth_type_trans() become a netdev operation rather than
something drivers statically call by hand. ->ndo_type_trans or
similar.

SKB has a state bit saying whether ->ndo_type_trans has been invoked
yet on RX.

Drivers pass raw SKBs up into the stack.

We defer the ->ndo_type_trans as far as possible, for RPS when we have
->rxhash we can defer this all the way to the destination RPS cpu.

If we lack ->rxhash, the source cpu will need to invoke
->ndo_type_trans before it can begin parsing the packet.

Anyways, something like that.

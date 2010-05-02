From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: eth_type_trans() should inline
 skb_pull()
Date: Sun, 02 May 2010 03:03:21 -0700 (PDT)
Message-ID: <20100502.030321.191163013.davem@davemloft.net>
References: <1272696145.2230.101.camel@edumazet-laptop>
	<20100501.181558.141243424.davem@davemloft.net>
	<1272783032.2173.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, hadi@cyberus.ca
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40631
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754761Ab0EBKDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 06:03:15 -0400
In-Reply-To: <1272783032.2173.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 02 May 2010 08:50:32 +0200

> Excellent !

Great, here is the commit message I will use:

--------------------
net: Inline skb_pull() in eth_type_trans().

In commit 6be8ac2f ("[NET]: uninline skb_pull, de-bloats a lot")
we uninlined skb_pull.

But in some critical paths it makes sense to inline this thing
and it helps performance significantly.

Create an skb_pull_inline() so that we can do this in a way that
serves also as annotation.

Based upon a patch by Eric Dumazet.

Signed-off-by: David S. Miller <davem@davemloft.net>
--------------------

> Could we assume all eth_type_trans() must call it with initial
> skb->len >= (46 + 12) or not ?  (According to ethernet specs, all
> frames should have a minimum payload of 46 bytes)
>
> If not sure, maybe we should issue a WARN_ON_ONCE()
> 
> If yes, tests could be removed and we could gain two cycles ;)

Isn't the minimum ETH_ZLEN?

But yes, regardless of whether the minimum ethernet frame is 58 or 60
bytes, we should require it's at least that big, and use that test
consistently throughout.

Anything smaller is a runt packet and should be tossed or marked as an
error in some other way by the hardware.  They should never make it to
eth_type_trans().

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/icmp: restore source address if packet is NATed
Date: Sun, 25 Jun 2017 11:49:27 -0400 (EDT)
Message-ID: <20170625.114927.1055286919675288173.davem@davemloft.net>
References: <20170624021727.17835-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jason@zx2c4.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170624021727.17835-1-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Sat, 24 Jun 2017 04:17:27 +0200

> The ICMP routines use the source address for two reasons:
> 
>     1. Rate-limiting ICMP transmissions based on source address, so
>        that one source address cannot provoke a flood of replies. If
>        the source address is wrong, the rate limiting will be
>        incorrectly applied.
> 
>     2. Choosing the interface and hence new source address of the
>        generated ICMP packet. If the original packet source address
>        is wrong, ICMP replies will be sent from the wrong source
>        address, resulting in either a misdelivery, infoleak, or just
>        general network admin confusion.
> 
> Most of the time, the icmp_send and icmpv6_send routines can just reach
> down into the skb's IP header to determine the saddr. However, if
> icmp_send or icmpv6_send is being called from a network device driver --
> there are a few in the tree -- then it's possible that by the time
> icmp_send or icmpv6_send looks at the packet, the packet's source
> address has already been transformed by SNAT or MASQUERADE or some other
> transformation that CONNTRACK knows about. In this case, the packet's
> source address is most certainly the *wrong* source address to be used
> for the purpose of ICMP replies.
> 
> Rather, the source address we want to use for ICMP replies is the
> original one, from before the transformation occurred.
> 
> Fortunately, it's very easy to just ask CONNTRACK if it knows about this
> packet, and if so, how to fix it up. The saddr is the only field in the
> header we need to fix up, for the purposes of the subsequent processing
> in the icmp_send and icmpv6_send functions, so we do the lookup very
> early on, so that the rest of the ICMP machinery can progress as usual.
> In my tests, this setup works very well.
> 
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>

This violates things on so many levels.

I think this kind of thing need to be hidden inside of netfilter,
it can do the rate limiting and stuff like that in the spot
where it makes the transformation and knows all of the original
addressing and ports.

You definitely can't just rewrite header fields here either.  The
SKB could be shared, for example.

I'm definitely not applying this, sorry.

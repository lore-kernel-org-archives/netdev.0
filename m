From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in RCU.
Date: Tue, 22 Jul 2008 00:43:06 +0800
Message-ID: <20080721164306.GA13131@gondor.apana.org.au>
References: <20080721152220.GA12341@gondor.apana.org.au> <20080721.082627.128593651.davem@davemloft.net> <20080721161616.GA12938@gondor.apana.org.au> <20080721.092556.227421936.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, kaber@trash.net, netdev@vger.kernel.org,
	johannes@sipsolutions.net, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33495 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751685AbYGUQnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 12:43:18 -0400
Content-Disposition: inline
In-Reply-To: <20080721.092556.227421936.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 21, 2008 at 09:25:56AM -0700, David Miller wrote:
>
> Where are these places they are going to "jump all over"? :-)

Well consider the case where you have 4 queues, but a large number
of flows per second (>= 1000).  No matter how good your hash is,
there is just no way of squeezing 1000 flows into 4 queues without
getting loads of collisions :)

So let's assume that these flows have been distributed uniformly
by both the RX hash and the TX hash such that each queue is handling
~250 flows.  If the TX hash does not match the result produced by
the RX hash, you're going to get a hell lot of contention once you
get into the NIC driver on the TX side.

This is because for NICs like the ones from Intel ones you have to
protect the TX queue accesses so that only one CPU touches a given
queue at any point in time.

The end result is either the driver being bogged down by lock or
TX queue contention, or the mid-layer will have to redistribute
skb's to the right CPUs in which case the synchronisation cost is
simply moved over there.

> If the TX hash is good enough (current one certainly isn't and I will
> work on fixing that), it is likely to spread the accesses enough that
> there won't be many collisions to matter.

I agree that what you've got here makes total sense for a host.
But I think there is room for something different for routers.
 
> We could provide the option, but it is so dangerous and I also see no
> real tangible benfit from it.

The benefit as far as I can see is that this would allow a packet's
entire journey through Linux to stay on exactly one CPU.  There will
be zero memory written by multiple CPUs as far as that packet is
concerned.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

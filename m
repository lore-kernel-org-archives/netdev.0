From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next-2.6] gro: drivers should feed GRO only
 with TCP packets
Date: Wed, 01 Sep 2010 13:10:18 -0700 (PDT)
Message-ID: <20100901.131018.62350311.davem@davemloft.net>
References: <1283360686.2556.381.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45560
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754002Ab0IAUKB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 16:10:01 -0400
In-Reply-To: <1283360686.2556.381.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 01 Sep 2010 19:04:46 +0200

> Many network devices can tell if an incoming frame is a TCP one for a
> small cost.
> 
> Instead of feeding GRO with all packets, we could filter packets on this
> information ?
> 
> This should help machines handling a mixed UDP/TCP workload, keeping gro
> overhead as small as possible.
> 
> patch against tg3 as an example...
> 
> Alternative would be to set a bit "is_tcp" on napi_struct to let this
> choice being done in network stack, not by each driver. 
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I would rather have each and every driver unconditionally go through
the GRO receive routines, than do things like this.  Especially since
if we apply a patch like your's, the flood gates open and if IP
fragmentation support is added to GRO we have to undo all of this
stuff.

So what I actually want to see is that we remove the distinction of
GRO, and just have things like "net_receive_skb()".  It will have the
same call signature as napi_gro_receive().

Yes we'll still have things like the skge driver which currently need
to have a-priori knowledge of how to complete a NAPI sequence for the
sake of GRO, but we can at least rename the function it calls to
remove the GRO'ness of it.

Even non-NAPI drivers could use this, passing NULL for 'napi' and a GRO
usable NAPI context can be placed somewhere else and used purely for
the sake of GRO.  NULL would also mean "in hardware interrupt", and
we can make this check cost absolutely nothing by doing something inline
in net_receive_skb() like:

	if (__builtin_constant_p(napi) && napi == NULL)
		net_receive_skb_in_irq(skb, dev);

or similar.


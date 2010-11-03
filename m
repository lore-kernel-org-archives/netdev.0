From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [PATCH] drivers/net/tile/: on-chip network drivers for the tile
 architecture
Date: Wed, 3 Nov 2010 17:04:34 -0400
Message-ID: <4CD1CE62.9010307@tilera.com>
References: <201011012107.oA1L7TGd031588@farm-0027.internal.tilera.com>	 <20101103125959.3231daa1@s6510>  <4CD19DCF.1040709@tilera.com>	 <1288806622.2511.187.camel@edumazet-laptop>  <4CD1BA71.3000806@tilera.com> <1288816300.2718.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmamail.tilera.com ([72.1.168.231]:51707 "EHLO
	USMAMAIL.TILERA.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754432Ab0KCVEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Nov 2010 17:04:37 -0400
In-Reply-To: <1288816300.2718.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/3/2010 4:31 PM, Eric Dumazet wrote:
> Le mercredi 03 novembre 2010 =C3=A0 15:39 -0400, Chris Metcalf a =C3=A9=
crit=20
>> Several uses of "*(volatile int *)ptr" in that file are intended as
>> performance hints.  A more obvious way to state this, for our compil=
er, is
>> to say "prefetch_L1(ptr)".  This generates essentially the same code=
, but
>> avoids the red flag for "volatile" and also reads more clearly, so i=
t's a
>> good change.
>>
>> The other use is part of a very precise dance that involves detailed
>> knowledge of the Tile memory subsystem micro-architecture.  This doe=
sn't
>> really belong in the network device driver code, so I've moved it to
>> <asm/cacheflush.h>, and cleaned it up, with detailed comments.  The =
use
>> here is that our network hardware's DMA engine can be used in a mode=
 where
>> it reads directly from memory, in which case you must ensure that an=
y
>> cached values have been flushed.
> This kind of things really must be discussed before using it in a
> network driver.
>
> Because, an skb can be built by one CPU, queued on a qdisc queue, wit=
h
> no particular "cached values have been flushed" ...
>
> It then can be dequeued by another CPU, and given to the device.
> What happens then ?

The particular usage here is in tile_net_tx_frags(), as you can see in =
the
patch.  The skb is at the very last stage of being egressed, so we flus=
h
any dirty cache lines to memory before asking the hardware to transmit.=
=20
This is pretty standard for hardware that is not coherent with the cach=
e.

In fact, though, this is not the standard mode we run the driver in; it=
's
almost always used in the cache-coherent mode ("hash_default") where we=
 are
reading the skb data out of the caches of the cores it is resident in. =
 The
"if (!hash_default)" clause here is only true for our first-generation
hardware (TILE64) or when using our current (TILEPro) hardware in a way
that is basically backwards-compatible with TILE64, typically for some =
kind
of cache-utilization benchmarking purpose.

As to your specific question, certainly during the time an skb is being=
 set
up for egress, added to a qdisc queue, etc., we don't make any assumpti=
ons
about where or how the data is cached.

I'm happy to discuss specific details of how the driver works, but I
suspect it's the usual mix of boilerplate skb management, NAPI support,
etc., mixed in with specifics of how to set up shared memory queues for=
 the
ingress and egress hardware (or "firmware" since some of this is handle=
d by
a hypervisor layer on a dedicated core).

--=20
Chris Metcalf, Tilera Corp.
http://www.tilera.com


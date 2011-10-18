From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 6/7] mlx4_en: Adding rxhash support
Date: Tue, 18 Oct 2011 20:35:00 +0100
Message-ID: <1318966500.2783.124.camel@bwh-desktop>
References: <4E9C8D8B.90606@mellanox.co.il>
	 <1318902525.2571.24.camel@edumazet-laptop>
	 <953B660C027164448AE903364AC447D2235EEB65@MTLDAG01.mtl.com>
	 <1318926870.2657.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <953B660C027164448AE903364AC447D2235EEC80@MTLDAG01.mtl.com>
	 <20111018083606.6367ff50@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:36367 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753535Ab1JRTfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 15:35:06 -0400
In-Reply-To: <20111018083606.6367ff50@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-10-18 at 08:36 -0700, Stephen Hemminger wrote:
> On Tue, 18 Oct 2011 08:59:44 +0000
> Yevgeny Petrilin <yevgenyp@mellanox.co.il> wrote:
> 
> > > 
> > > What is the gain using random values ?
> > > 
> > > Usually, we tend to have same hardware in a single machine, or we use
> > > active-backup bonding mode, and an active slave flip can change rxhash
> > > values with litle effect, since this happens not often.
> > > 
> > > I really prefer not random values, because it allows to have replayable
> > > configurations : For a given tcp flow, the same rxhash value is given
> > > and same cpu target in RPS. Its way easier to tune your machine for some workloads.
> > > 
> > 
> > There is no gain in random values, 
> > I'll make the change to have static value for RSS function.
> > 
> > We might consider how to ensure consistency across the different drivers in this aspect.
> 
> The key should be part of the network device core. Almost all hardware just
> implements the Microsoft standard, and if all drivers used same key they should
> come up with the same hash.

It should, but that's not enough.  The core also needs to be responsible
for initialising the hash indirection table, determining how many RX
queues to create, and IRQ affinity hints.

> Although using the same key all the time makes testing easier.
> The risk of using the same key is that it makes it easier for an attacker to
> create a set of addresses that all map to the same CPU which would make a DoS
> attack work better.  Therefore the key should be randomly generated at boot time.

If I understand correctly, the core of the Toeplitz hash functions is
(pretending we have a wide enough type called bigint):

u32 toeplitz_hash(bigint input, bigint key, unsigned width)
{
	u32 hash = 0;
	unsigned i;

	for (i = 0; i < width; i++)
		if (input & ((bigint)1 << i))
		        hash ^= key >> (1 + i);
	return hash;
}

This is hardly a cryptographic hash!  And while the key probably should
be random it should not just be random *bits*.  For example, if any 32
consecutive bits of the key are zero then 1 bit of input will have no
effect on the hash at all.

There was also a proposal a while back that we should try to make the
hash symmetric w.r.t. RX and TX addresses, so that both directions of a
flow through a router/bridge are aligned.  I think this was to be done
by repeating a 16-bit pattern across the key.  Not sure whether that's
worthwhile.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

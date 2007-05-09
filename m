From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.3 - QMGR
Date: Wed, 9 May 2007 12:21:36 +0200
Message-ID: <20070509102136.GG6976@xi.wantstofly.org>
References: <m3vef5biob.fsf@maximus.localdomain> <5BB7E1AB-5CE1-43C8-8CE3-E0DE0236BD09@cam.ac.uk> <m3hcqoa772.fsf@maximus.localdomain> <86D26EBE-5899-468F-9C79-23E83E0DE04B@cam.ac.uk> <m33b289zku.fsf@maximus.localdomain> <m31whs5ehn.fsf_-_@maximus.localdomain> <20070508113232.GA32055@xi.wantstofly.org> <m3k5vj76bi.fsf@maximus.localdomain> <20070508144001.GC387@xi.wantstofly.org> <m3ps5b5k07.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael-Luke Jones <mlj28@cam.ac.uk>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	Russell King <rmk@arm.linux.org.uk>,
	ARM Linux Mailing List
	<linux-arm-kernel@lists.arm.linux.org.uk>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:51677 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751187AbXEIKVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 06:21:39 -0400
Content-Disposition: inline
In-Reply-To: <m3ps5b5k07.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 08, 2007 at 06:59:36PM +0200, Krzysztof Halasa wrote:

> >> There may be up to 6 Ethernet ports (not sure about hardware
> >> status, not yet supported even by Intel) - 7 queues * 128 entries
> >> each = ~ 3.5 KB. Add 2 long queues (RX) for HSS and something
> >> for TX, and then crypto, and maybe other things.
> >
> > You're unlikely to be using all of those at the same time, though.
> 
> That's the point.
> 
> > And what do you do if the user does compile all of these features into
> > his kernel and then tries to use them all at the same time?  Return
> > -ENOMEM?
> 
> If he is able to do so, yes - there is nothing we can do. But
> I suspect a single machine would not have all possible hardware.
> The problem is, we don't know what would it have, so it must be
> dynamic.

Well, you _would_ like to have a way to make sure that all the
capabilities on the board can be used.  If you have a future ixp4xx
based board with 16 ethernet ports, you don't want 'ifconfig eth7 up'
to give you -ENOMEM just because we ran out of SRAM.

The way I see it, that means that you do want to scale back your
other SRAM allocations if you know that you're going to need a lot
of SRAM (say, for ethernet RX/TX queues.)

Either you can do this with an ugly hack a la:

	/*
	 * The FOO board has many ethernet ports, and runs out of
	 * SRAM prematurely if we use the default TX/RX ring sizes.
	 */
	#ifdef CONFIG_MACH_IXP483_FOO_BOARD
	#define IXP4XX_ETH_RXTX_QUEUE_SIZE	32
	#else
	#define IXP4XX_ETH_RXTX_QUEUE_SIZE	256
	#endif

Or you can put this knowledge in the board support code (cleaner, IMHO.)

E.g. let arch/arm/mach-ixp4xx/nslu2.c decide, at platform device
instantiation time, which region of queue SRAM can be used by which
queue, and take static allocations for things like the crypto unit
into account.  (This is just one form of that idea, there are many
different variations.)

That way, you can _guarantee_ that you'll always have enough SRAM
to be able to use the functionality that is exposed on the board you
are running on (which is a desirable property, IMHO), which is
something that you can't achieve with an allocator, as far as I can
see.

I'm not per se against the allocator, I just think that there are
problems (running out of SRAM, fragmentation) that can't be solved
by the allocator alone (SRAM users have to be aware which other SRAM
users there are in the system, while the idea of the allocator is to
insulate these users from each other), and any solution that solves
those two problems IMHO also automatically solves the problem that
the allocator is trying to solve.

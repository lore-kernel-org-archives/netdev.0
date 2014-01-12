From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 0/5] Assorted mvneta fixes
Date: Sun, 12 Jan 2014 23:22:33 +0100
Message-ID: <20140112222233.GG16576@1wt.eu>
References: <1389519069-1619-1-git-send-email-w@1wt.eu> <87ob3hovkf.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:55271 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751026AbaALWWl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Jan 2014 17:22:41 -0500
Content-Disposition: inline
In-Reply-To: <87ob3hovkf.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnaud,

On Sun, Jan 12, 2014 at 08:21:20PM +0100, Arnaud Ebalard wrote:
> Hi,
> 
> Willy Tarreau <w@1wt.eu> writes:
> 
> > this series provides some fixes for a number of issues met with the
> > mvneta driver :
> >
> >   - driver lockup when reading stats while sending traffic from multiple
> >     CPUs : this obviously only happens on SMP and is the result of missing
> >     locking on the driver. The problem was present since the introduction
> >     of the driver in 3.8. The first patch performs some changes that are
> >     needed for the second one which actually fixes the issue by using
> >     per-cpu counters. It could make sense to backport this to the relevant
> >     stable versions.
> >
> >   - mvneta_tx_timeout calls various functions to reset the NIC, and these
> >     functions sleep, which is not allowed here, resulting in a panic.
> >     Better completely disable this Tx timeout handler for now since it is
> >     never called. The problem was encountered while developing some new
> >     features, it's uncertain whether it's possible to reproduce it with
> >     regular usage, so maybe a backport to stable is not needed.
> >
> >   - replace the Tx timer with a real Tx IRQ. As first reported by Arnaud
> >     Ebalard and explained by Eric Dumazet, there is no way this driver
> >     can work correctly if it uses a driver to recycle the Tx descriptors.
> >     If too many packets are sent at once, the driver quickly ends up with
> >     no descriptors (which happens twice as easily in GSO) and has to wait
> >     10ms for recycling its descriptors and being able to send again. Eric
> >     has worked around this in the core GSO code. But still when routing
> >     traffic or sending UDP packets, the limitation is very visible. Using
> >     Tx IRQs allows Tx descriptors to be recycled when sent. The coalesce
> >     value is still configurable using ethtool. This fix turns the UDP
> >     send bitrate from 134 Mbps to 987 Mbps (ie: line rate). It's made of
> >     two patches, one to add the relevant bits from the original Marvell's
> >     driver, and another one to implement the change. I don't know if it
> >     should be backported to stable, as the bug only causes poor performance.
> 
> First, thanks a lot for that work!
> 
> Funny enough, I spent some time this week-end trying to find the root
> cause of some kernel freezes and panics appearing randomly after some GB
> read on a ReadyNAS 102 configured as a NFS server. 
> 
> I tested your fixes and performance series together on top of current
> 3.13.0-rc7 and I am now unable to reproduce the freeze and panics after
> having read more than the 300GB of traffic from the NAS: following
> bandwith with a bwm-ng shows the rate is also far more stable than w/
> previous driver logic (55MB/sec). So, FWIW:
> 
> Tested-by: Arnaud Ebalard <arno@natisbad.org>

Thanks for this.

BTW, the "performance" series is not supposed to fix anything, and still
it seems difficult to me to find what patch might have fixed your problem.
Maybe the timer used in place of an IRQ has an even worse effect than what
we could imagine ?

> Willy, I can extend the test to RN2120 if you think it is useful to also
> do additional tests on a dual-core armada XP.

It's up to you. These patches have run extensively on my Mirabox (Armada370),
OpenBlocks AX3 (ArmadaXP dual core) and the XP-GP board (ArmadaXP quad core),
and fixed the stability issues and performance issues I was facing there. But
you may be interested in testing them with your workloads (none of my boxes
is used as an NFS server, NAS or whatever, they mainly see HTTP and very small
packets used in stress tests).

> Now, just in case someone on netdev can find something useful in the
> panics I gathered before your set, I have added those below. The fact
> that the bugs have disappeared with your set would tend to confirm that
> it was in the driver but at some point during the tests, I suspected the
> TCP stack when the device is stressed (NFS seems to do that very well on
> a 1.2GHz/512MB device). I did the following tests:
> 
> - on a 3.12.5, 3.13.0-rc4 and rc7 on a ReadyNAS 102
> - 3.13.0-rc7 on a RN2120 (dual-core Armada XP w/ mvneta and 2GB of RAM):
>   no issue seen after 200GB of traffic transfered
> - 3.13.0-rc7 on a Duo v2 (kirkwood 88F6282 @ 1.6GHz w/ mv643xx_eth): no
>   issue 

To be completely transparent, I've already faced some panics on the mirabox
during high speed testing (when trying to send 1.488 Mpps on the two gig
ports in parallel). But I've always suspected a power supply issue and never
dug deeper. I've also read some instability reports on some mirabox, so it's
pretty possible that some design rules for the armada370 are not perfectly
respected or too hard to apply and that we seldom meet hardware issues.

Cheers,
Willy

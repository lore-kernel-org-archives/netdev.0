From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [PATCH v3 08/10] ARM: mxs: add ocotp read function
Date: Wed, 5 Jan 2011 19:44:18 +0000
Message-ID: <20110105194418.GE12222@shareable.org>
References: <1294236457-17476-1-git-send-email-shawn.guo@freescale.com> <1294236457-17476-9-git-send-email-shawn.guo@freescale.com> <20110105161235.GA2112@gallagher> <20110105164409.GV25121@pengutronix.de> <20110105172501.GB2112@gallagher> <20110105175617.GD12222@shareable.org> <20110105183509.GH8638@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Iles <jamie@jamieiles.com>, gerg@snapgear.com,
	B32542@freescale.com, netdev@vger.kernel.org,
	s.hauer@pengutronix.de, bryan.wu@canonical.com, baruch@tkos.co.il,
	w.sang@pengutronix.de, r64343@freescale.com,
	Shawn Guo <shawn.guo@freescale.com>, eric@eukrea.com,
	Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, lw@karo-electronics.de
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.shareable.org ([80.68.89.115]:48797 "EHLO
	mail2.shareable.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751533Ab1AETo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 14:44:29 -0500
Content-Disposition: inline
In-Reply-To: <20110105183509.GH8638@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Russell King - ARM Linux wrote:
> > By the way, I see ARM defines cpu_relax as smp_mb() on arch >= 6.  Is
> > that correct and useful?  On other architectures*, barrier() is enough
> > of a barrier, but it's conceivable that smp_mb() would have some
> > ARM-specific fairness or bus activity benefit - in which case it
> > should probably be mb().
> 
> See a discussion last year with Linus.  It's there to ensure that one CPU
> spinning on a variable can see a write by another CPU to that same
> variable.  Without the barrier, the visibility effects are unbounded on
> ARMv6 - and it's only like that for ARMv6, not >= ARMv6.

Ah, thanks.

It might be relevant to this thread; I'm not sure.

'git show 534be1d5' explains how it works: cpu_relax() flushes buffered
writes from _this_ CPU, so that other CPUs which are polling can make
progress, which avoids this CPU getting stuck if there is an indirect
dependency (no matter how convoluted) between what it's polling and which
it wrote just before.

So cpu_relax() is *essential* in some polling loops, not a hint.

In principle that could happen for I/O polling, if (a) buffered memory
writes are delayed by I/O read transactions, and (b) the device state we're
waiting on depends on I/O yet to be done on another CPU, which could be
polling memory first (e.g. a spinlock).

I doubt (a) in practice - but what about buses that block during I/O read?
(I have a chip like that here, but it's ARMv4T.)

If so, readl() doesn't have a barrier that addresses the issue.

(b) is conceivable, and if the memory is a spinlock, spin_unlock() does
_not_ deal with this on ARMv6, as it has no barrier after the write.
('git show c5113b61' doesn't really explain why.)

It's convoluted and unlikely, but (imho) suggests cpu_relax() is good
practice in polling loops, even if not needed.  It doesn't cost anything.

-- Jamie

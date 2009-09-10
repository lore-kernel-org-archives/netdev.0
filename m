From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH v2 3/3] ucc_geth: Fix hangs after switching from full
 to	half duplex
Date: Thu, 10 Sep 2009 23:40:53 +0400
Message-ID: <20090910194053.GA24363@oksana.dev.rtsoft.ru>
References: <20090910020145.GC31083@oksana.dev.rtsoft.ru>
 <20090910175852.GA18948@oksana.dev.rtsoft.ru>
 <4AA93FB0.5060802@freescale.com>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Andy Fleming <afleming@freescale.com>,
	Timur Tabi <timur@freescale.com>, linuxppc-dev@ozlabs.org
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ru.mvista.com ([213.79.90.228]:1974 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751146AbZIJTkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 15:40:51 -0400
Content-Disposition: inline
In-Reply-To: <4AA93FB0.5060802@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 10, 2009 at 01:04:32PM -0500, Scott Wood wrote:
> Anton Vorontsov wrote:
> >MPC8360 QE UCC ethernet controllers hang when changing link duplex
> >under a load (a bit of NFS activity is enough).
> >
> >  PHY: mdio@e0102120:00 - Link is Up - 1000/Full
> >  sh-3.00# ethtool -s eth0 speed 100 duplex half autoneg off
> >  PHY: mdio@e0102120:00 - Link is Down
> >  PHY: mdio@e0102120:00 - Link is Up - 100/Half
> >  NETDEV WATCHDOG: eth0 (ucc_geth): transmit queue 0 timed out
> >  ------------[ cut here ]------------
> >  Badness at c01fcbd0 [verbose debug info unavailable]
> >  NIP: c01fcbd0 LR: c01fcbd0 CTR: c0194e44
> >  ...
> >
> >The cure is to disable the controller before changing speed/duplex
> >and enable it afterwards.
> >
> >Since ugeth_graceful_stop_{tx,rx} now may be called from an atomic
> >context, switch the two functions from msleep() to mdelay().
> 
> Ouch.

Yeah, right... delaying for 10ms with irqs off isn't good.

> Can we put this in a workqueue or something?

adjust_link() itself isn't called from an atomic context.

It's we are grabbing ugeth->lock, i.e. a spinlock. I don't see
why the lock is needed in adjust_link() in its current form,
but if we're going to disable the controller for some time,
we'll have to make sure that no start_xmit() or NAPI is running,
scheduled or will be scheduled until we say so.

I think that lock-less, and thus completely sleep-able variant
of adjust_link is doable.

Thanks,

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2

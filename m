From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] xfrm: SAD entries do not expire after suspend-resume
Date: Mon, 11 May 2009 20:30:17 +0200
Message-ID: <1242066617.6656.1311.camel@laptop>
References: <20090511142101.639cb5d6@penta.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	yoshfuji@linux-ipv6.org, mingo@elte.hu,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Yury Polyanskiy <ypolyans@Princeton.EDU>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:49972 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756316AbZEKSa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2009 14:30:57 -0400
In-Reply-To: <20090511142101.639cb5d6@penta.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-05-11 at 14:21 -0400, Yury Polyanskiy wrote:
> This fixes the following bug in the current implementation of
> net/xfrm: if SAD entry expires in 8 hr and the kernel is put into
> suspend for 10hr then upon wakeup SAD will not expire until 8 more
> hours pass. This, of course, leads to connectivity problems because
> the corresponding entry has already expired on the remote end.
> 
>   The patch is against 2.6.26.8 (applies to 2.6.26 cleanly) for two
> reasons: 
> 
> (1) that is what I am testing it on; 
> 
> (2) it can not be ported to anything post 2.6.28-rc7 because hrtimer's
> callbacks are run in hardirq context ever since. This would require a
> major rewrite of xfrm_state's locking (i.e. replacing spin_lock_bh()
> with spin_lock_irqsave() at least) which is (a) outside of my competence
> and (b) will introduce excessive irq-disabled codepaths.
> 
>   Due to (2) I am copying the authors of the hrtimer's patch. Unless
> there is an alternative (to hrtimer_start) way of requesting a
> CLOCK_REALTIME softirq callback the only solution I could think of is
> to hook into PM_POST_HIBERNATION+PM_POST_SUSPEND and force all of the
> timers on xfrm_state_all list to go off after resume.

Given that the whole problem is suspend related, this last option sounds
like the best thing.


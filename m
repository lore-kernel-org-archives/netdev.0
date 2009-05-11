From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] xfrm: SAD entries do not expire after suspend-resume
Date: Mon, 11 May 2009 22:25:57 +0200
Message-ID: <1242073557.8257.116.camel@laptop>
References: <20090511142101.639cb5d6@penta.localdomain>
	 <1242066617.6656.1311.camel@laptop>
	 <ea182b20905111307w2cdbe18dw9f9fde474216c219@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	yoshfuji@linux-ipv6.org, mingo@elte.hu,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Thomas Gleixner <tglx@linutronix.de>,
	john stultz <johnstul@us.ibm.com>
To: Yury Polyanskiy <ypolyans@princeton.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:46327 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759537AbZEKU0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2009 16:26:48 -0400
In-Reply-To: <ea182b20905111307w2cdbe18dw9f9fde474216c219@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-05-11 at 16:07 -0400, Yury Polyanskiy wrote:
> On Mon, May 11, 2009 at 2:30 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> > On Mon, 2009-05-11 at 14:21 -0400, Yury Polyanskiy wrote:
> 
> >> (2) it can not be ported to anything post 2.6.28-rc7 because hrtimer's
> >> callbacks are run in hardirq context ever since. This would require a
> >> major rewrite of xfrm_state's locking (i.e. replacing spin_lock_bh()
> >> with spin_lock_irqsave() at least) which is (a) outside of my competence
> >> and (b) will introduce excessive irq-disabled codepaths.
> >>
> >>   Due to (2) I am copying the authors of the hrtimer's patch. Unless
> >> there is an alternative (to hrtimer_start) way of requesting a
> >> CLOCK_REALTIME softirq callback the only solution I could think of is
> >> to hook into PM_POST_HIBERNATION+PM_POST_SUSPEND and force all of the
> >> timers on xfrm_state_all list to go off after resume.
> >
> > Given that the whole problem is suspend related, this last option sounds
> > like the best thing.
> >
> 
> Can somebody from the Networking Team please confirm that the other
> sources of time leaps can indeed be neglected? (such as ntp
> corrections e.g.)

ntp time adjustments are very fine grained and should not distort time.
Setting the system clock otoh might screw you over though.

What I'm not quite getting is though, if we have a real-time timer 8h in
the future, and we suspend for 10h, the timer should fire the moment we
resume and readjust the clock, finding this -2h expired timer.

Since they're realtime timers and we don't know what they're used for,
we cannot handle this time lapse in the generic code, hence its users
are stuck with dealing with this.


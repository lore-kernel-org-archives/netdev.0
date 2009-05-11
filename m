From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] xfrm: SAD entries do not expire after suspend-resume
Date: Mon, 11 May 2009 23:12:41 +0200
Message-ID: <1242076361.8257.168.camel@laptop>
References: <20090511142101.639cb5d6@penta.localdomain>
	 <1242066617.6656.1311.camel@laptop>
	 <ea182b20905111307w2cdbe18dw9f9fde474216c219@mail.gmail.com>
	 <1242073557.8257.116.camel@laptop>
	 <20090511165024.5da4e3f2@penta.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	yoshfuji@linux-ipv6.org, mingo@elte.hu,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Thomas Gleixner <tglx@linutronix.de>,
	john stultz <johnstul@us.ibm.com>
To: Yury Polyanskiy <ypolyans@Princeton.EDU>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:37876 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755760AbZEKVN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2009 17:13:56 -0400
In-Reply-To: <20090511165024.5da4e3f2@penta.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-05-11 at 16:50 -0400, Yury Polyanskiy wrote:
> On Mon, 11 May 2009 22:25:57 +0200
> Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > > >>   Due to (2) I am copying the authors of the hrtimer's patch.
> > > >> Unless there is an alternative (to hrtimer_start) way of
> > > >> requesting a CLOCK_REALTIME softirq callback the only solution I
> > > >> could think of is to hook into
> > > >> PM_POST_HIBERNATION+PM_POST_SUSPEND and force all of the timers
> > > >> on xfrm_state_all list to go off after resume.
> > > >
> > > > Given that the whole problem is suspend related, this last option
> > > > sounds like the best thing.
> > > >
> > > 
> > > Can somebody from the Networking Team please confirm that the other
> > > sources of time leaps can indeed be neglected? (such as ntp
> > > corrections e.g.)
> > 
> > ntp time adjustments are very fine grained and should not distort
> > time. Setting the system clock otoh might screw you over though.
> 
> Isn't ntp sometimes used for initial clock setting? (i.e. host boots
> with sysclock set to 1971 and then ntp makes it to the correct 2009).

ntp (as in the userspace software bits) would use something like
sys_settimeofday() to move the clock, after that they use sys_adjtimex()
to keep in sync.

> Another reason for not doing it pm_notify()-wise is to reduce the
> amount of resume code running in the system: why run a user-specific
> O(N) post-suspend code if there is already an O(1) one in the
> hres_timers_resume()?
> 
> > 
> > What I'm not quite getting is though, if we have a real-time timer 8h
> > in the future, and we suspend for 10h, the timer should fire the
> > moment we resume and readjust the clock, finding this -2h expired
> > timer.
> > 
> > Since they're realtime timers and we don't know what they're used for,
> > we cannot handle this time lapse in the generic code, hence its users
> > are stuck with dealing with this.
> > 
> 
> 
> The problem is that the current code simply arms a usual timer_list
> timer, which remains stopped during suspend. So how do you set up a
> CLOCK_REALTIME timer w/o using hrtimer_start()?

Ah, right. Well use hrtimers, just don't run all that stuff you used to
do in softirq context in it. Use it to queue a worklet somewhere or wake
a thread.


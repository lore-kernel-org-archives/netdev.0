From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH RFC] spinlock: split out debugging check from
 spin_lock_mutex
Date: Tue, 16 Apr 2013 13:24:54 -0400
Message-ID: <20130416172454.GC9241@hmsreliant.think-freely.org>
References: <1365693486-6315-1-git-send-email-nhorman@tuxdriver.com>
 <5166F35B.1040200@acm.org>
 <20130411191409.GA9790@hmsreliant.think-freely.org>
 <5167A953.1020900@acm.org>
 <20130412113232.GA19966@hmsreliant.think-freely.org>
 <516813A0.1040300@acm.org>
 <20130412184542.GB19966@hmsreliant.think-freely.org>
 <51690AAB.1030102@acm.org>
 <20130415141610.GA3505@hmsreliant.think-freely.org>
 <CAO+b5-oBfH3M0dnrQSs-p1BF_5hKy2tsU-dD=EP9+S=iqPs5ew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bart Van Assche <bvanassche@acm.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ingo Molnar <mingo@redhat.com>
To: Bart Van Assche <bart.vanassche@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38518 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936020Ab3DPRZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 13:25:10 -0400
Content-Disposition: inline
In-Reply-To: <CAO+b5-oBfH3M0dnrQSs-p1BF_5hKy2tsU-dD=EP9+S=iqPs5ew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 16, 2013 at 07:56:12AM -0700, Bart Van Assche wrote:
> On Mon, Apr 15, 2013 at 7:16 AM, Neil Horman <nhorman@tuxdriver.com> wrote:
> 
> > So I've been doing some reading over the weekend, and as a result I've been
> > developing some concerns about how mutex_trylock works.  I'm still
> > convinced its
> > safe to use with the changes we're discussing here, but all the
> > documentation
> > regarding mutex_trylock seems to say it simply shouldn't be used in
> > interrupt
> > context (though it never goes into detail as to why).  As near as I can
> > tell,
> > its because the spin locks that mutexes use are locked without disabling
> > interrupts (the implication being that, as we see in the patch we're
> > looking at
> > here), you're safe if you disable irqs independently).  Ironically, Ingo
> > patched
> > the mutex debug variants back in 2006 in commit
> > 1fb00c6cbd8356f43b46322742f3c01c2a1f02da to disable irqs to work around a
> > bug,
> > the result being that the debug variant gives you a WARNING about using
> > mutex_trylock in interrupts, when its actually safe, while the non-debug
> > variant
> > provides no warning, but is actually prone to deadlock.
> >
> > There are a few other use cases in the kernel in which mutex_trylock may
> > be used
> > in an interrupt context (crash_kexec being the most notable, as its used
> > for the
> > same purposes that we're using it in netpoll, and where I got the
> > inspiration
> > for my previous netpoll changes.
> >
> > The more I look at this, the more I'm starting to think that, in addition
> > to the
> > debug changes I've got proposed here, we should additionally convert the
> > non-debug spin_lock_mutex variants to disable irqs while manipulating the
> > mutexes.  That would make mutex_trylock safe, and give us a nice mechanism
> > to
> > create exclusion between sleepable paths that should not run atomically and
> > interrupt context paths.
> >
> > Ingo, can you comment on these thoughts above please.  I'd like to get your
> > opinion on this prior to spinning up a new patch if I could please.
> >
> 
> How about introducing a second type of mutex, and only using changing the
> spin_lock() into spin_lock_irq() for that new type of mutex ? That way no
> performance penalty would be introduced for existing mutex users and
> mutex_trylock() could be made safe for use inside IRQ-context for the new
> mutex type only.
> 
> Bart.
Thats a thought, I've actually been thinking about doing this with a completion
variable and a flag as well, but perhaps a mutex variant would be a better api
choice.  I'll put that together as an alternate, but I'd really like to see
what Ingo has to say regarding just switching the spin_lock to spin_lock_irqsave
for all cases as being a mutex, I'm not sure adding in irq protection is going
to be that much of a performance hit.

Neil

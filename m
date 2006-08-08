From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH -rt DO NOT APPLY] Fix for tg3 networking lockup
Date: Tue, 8 Aug 2006 09:13:10 -0400 (EDT)
Message-ID: <Pine.LNX.4.58.0608080859330.9872@gandalf.stny.rr.com>
References: <20060803.144845.66061203.davem@davemloft.net>
 <20060803235326.GC7894@thunk.org> <Pine.LNX.4.58.0608070124340.15870@gandalf.stny.rr.com>
 <20060806.231846.71090637.davem@davemloft.net> <Pine.LNX.4.58.0608080819080.7917@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: tytso@mit.edu, mchan@broadcom.com, herbert@gondor.apana.org.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	tglx@linutronix.de, mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms-smtp-02.nyroc.rr.com ([24.24.2.56]:2955 "EHLO
	ms-smtp-02.nyroc.rr.com") by vger.kernel.org with ESMTP
	id S932458AbWHHNNu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 09:13:50 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.58.0608080819080.7917@gandalf.stny.rr.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tue, 8 Aug 2006, Steven Rostedt wrote:

>
> On Sun, 6 Aug 2006, David Miller wrote:
>
> > From: Steven Rostedt <rostedt@goodmis.org>
> > Date: Mon, 7 Aug 2006 01:34:56 -0400 (EDT)
> >
> > > My suggestion would be to separate that tg3_timer into 4 different
> > > timers, which is what it actually looks like.
> >
> > Timers have non-trivial cost.  It's cheaper to have one and
> > vector off to the necessary operations each tick internalls.
> >
> > That's why it's implemented as one timer.
> >
>
> hrtimers don't have the cost of a normal timer. And that's why I suggested
> to convert them.  There's a much bigger cost in a single timer that always
> times out than 3 hrtimers.  hrtimers are expected to timeout, but timers
> are not.
>
> Of the 4 timers, only one is a timeout. The other three expire every time,
> forcing the timer wheel into effect.  Even though it's one timer
> implementing 4, it's expensive to use it as a watchdog.

I just got a chance to look a little more deeper at what the tg3 timer is
doing, and I was wrong.  The timeout is not a timeout but some messing
around when the network card doesn't use tagged status (whatever that is).
Which just pushes the point that this should _not_ be a timer, but a
hrtimer (expected to expire).

So you can keep this as one timer, but I would still switch it to a
hrtimer regardless, since it is expected to timeout.  (maybe separate out
the ASF if that still needs to be special?).

Ted,

I don't know what the max latency of that timer is, (I'm sure it wouldn't
be too hard to measuer, just add some timings around the timer handler,
let it run for a while and keep account of the max time).  But, since the
user that opens this network card is the one that initializes the timer,
if you simply switch the timer to be a hrtimer (that should also go in
mainline) and then have a really high prio task start up the network, that
timer would then run at the prio of the task that started the network.


-- Steve


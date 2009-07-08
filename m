From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCHv5 2/2] memory barrier: adding smp_mb__after_lock
Date: Wed, 8 Jul 2009 00:34:32 -0400
Message-ID: <20090708043432.GB26180@Krystal>
References: <20090707134601.GB6619@jolsa.lab.eng.brq.redhat.com> <20090707140135.GA5506@Krystal> <20090707143416.GB11704@redhat.com> <20090707150406.GC7124@Krystal> <20090707154440.GA15605@redhat.com> <1246981815.9777.12.camel@twins> <20090707194533.GB13858@Krystal> <4A53CFDC.6080005@gmail.com> <20090707232811.GC19217@Krystal> <20090707235149.GA10268@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Jiri Olsa <jolsa@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	htejun@gmail.com, jarkao2@gmail.com, davidel@xmailserver.org
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tomts43.bellnexxia.net ([209.226.175.110]:61850 "EHLO
	tomts43-srv.bellnexxia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750717AbZGHEeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 00:34:37 -0400
Content-Disposition: inline
In-Reply-To: <20090707235149.GA10268@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Oleg Nesterov (oleg@redhat.com) wrote:
> On 07/07, Mathieu Desnoyers wrote:
> >
> > * Eric Dumazet (eric.dumazet@gmail.com) wrote:
> > >
> > > What would be __read_lock() ? I cant see how it could *not* use lock prefix
> > > actually and or being cheaper...
> > >
> >
> > (I'll use read_lock_noacquire() instead of __read_lock() because
> > __read_lock() is already used for low-level primitives and will produce
> > name clashes. But I recognise that noacquire is just an ugly name.)
> >
> > Here, a __read_lock_noacquire _must_ be followed by a
> > smp__mb_after_lock(), and a __read_unlock_norelease() _must_ be
> > preceded by a smp__mb_before_unlock().
> 
> Your point was, smp_mb__after_lock() adds more complexity to the
> barriers/locking rules.
> 
> Do you really think __read_lock_noacquire() makes this all more
> simple/understandable? And again, we need __read_lock_irq_noaquire/etc.
> 

Yep, agreed that it also sounds like added complexity in locking rules,
and I've not yet seen the benefit of it.

> Personally, I disagree. In fact, I do not understand when/why
> _noacquire can be used, but this is another story.
> 

Because adding smp_mb__after_lock() is _only_ useful on x86. Most other
architectures _will_ suffer from a performance degradation, unless you
implement the __read_lock_noacquire.

> Let's look from the different angle. The first patch from Jiri fixes
> the bug. Yes, it is not clear if this is possible to trigger this
> bug in practice, but still nobody disagrees the bug does exist.
> The second patch fixes the added pessimization.

I fully agree with the bugfix.

> 
> So, if you do not agree with these patches, perhaps you can send
> fixes on top of these changes?

Given we can later build around the smp__mb_after_lock() to eliminate the
performance deterioration on non-x86 architectures by adding a
__read_lock_noacquire() primitive, I guess this can be done in a later
phase as an optimization.

I do not care if performance are not perfect for all architectures at
this point. What I really care about is that we do not introduce new
locking, atomic ops or memory barrier semantics that only make sense
for a single architecture and limit others.

Given that we can eventually move to a
__read_lock_noacquire()/smp_mb__after_lock() scheme, then adding just
smp_mb__after_lock() in the first place does not seem like a bad move.
It will just degrade performance of non-x86 architectures until
__read_lock_noacquire() or something similar comes.

So it looks fine if the code path is critical enough to justify adding
such new memory barrier. As long as we don't end up having
smp_mb__after_ponies().

Cheers,

Mathieu

> 
> 
> 
> Sadly, I already removed the previous emails so I can't add my
> acked-by to Jiri's patches. I didn't do this before because I
> thought I am in no position to ack these changes. But looking
> at this discussion, I'd like to vote for both these patches
> anyway ;)
> 
> Oleg.
> 

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

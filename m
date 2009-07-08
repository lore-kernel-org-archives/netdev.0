From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH/RFC] sched: Remove SYSTEM_RUNNING checks from
 cond_resched*()
Date: Wed, 8 Jul 2009 14:47:44 -0700
Message-ID: <20090708144744.5555b88d.akpm@linux-foundation.org>
References: <20090707235812.GA12824@oksana.dev.rtsoft.ru>
	<20090708005000.GA12380@redhat.com>
	<1247034263.9777.24.camel@twins>
	<alpine.LFD.2.01.0907080907210.3210@localhost.localdomain>
	<20090708141024.f8b581c5.akpm@linux-foundation.org>
	<20090708213331.GA9346@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, a.p.zijlstra@chello.nl,
	oleg@redhat.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43099 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754718AbZGHVtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 17:49:24 -0400
In-Reply-To: <20090708213331.GA9346@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(belatedly cc'ing netdev)

Original diagnosis:

: Using early netconsole and gianfar driver this error pops up:
: 
:   netconsole: timeout waiting for carrier
: 
: It appears that net/core/netpoll.c:netpoll_setup() is using
: cond_resched() in a loop waiting for a carrier.
: 
: The thing is that cond_resched() is a no-op when system_state !=
: SYSTEM_RUNNING, and so drivers/net/phy/phy.c's state_queue is never
: scheduled, therefore link detection doesn't work

> On Thu, 9 Jul 2009 01:33:31 +0400 Anton Vorontsov <avorontsov@ru.mvista.com> wrote:
> On Wed, Jul 08, 2009 at 02:10:24PM -0700, Andrew Morton wrote:
> > > On Wed, 8 Jul 2009 09:12:30 -0700 (PDT) Linus Torvalds <torvalds@linux-foundation.org> wrote:
> > > That said, I do agree that maybe SYSTEM_RUNNING isn't the right check. 
> > > Testing that the scheduler is initialized may be the more correct one. I 
> > > think the SYSTEM_RUNNING one just comes from that being used for other 
> > > debug issues.
> > 
> > Agreed.  system_state is too general.
> > 
> > If we specifically want to know whether it is safe to call schedule() then
> > let's create a global boolean it_is_safe_to_call_schedule and test that,
> > rather than testing something which indirectly and unreliably implies "it
> > is safe to call schedule".  If that boolean already exists then no-brainer.
> > 
> > All that being said, I wonder if the netconsole code should be using
> > msleep(1) instead.  Spinning on cond_resched() is a bit rude.  But one
> > would have to verify that it is safe to call schedule() at this time, and
> > for the netconsole caller, this is dubious.
> 
> What do you mean by "verify that it is safe"? If it works,
> can I assume that it's safe? ;-) It works, fwiw.
> 

netconsole is supposed to be available as early as possible in boot for
obvious reasons.  I'd say there's a decent risk now and in the future that
netconsole will be initialised prior to the scheduler being available.

In fact, if "netconsole: timeout waiting for carrier" newly added to
netpoll_setup() a depedency on the scheduler being available then perhaps
that was an incorrect change.


From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: deadlock during net device unregistration - V2
Date: Sat, 4 Oct 2008 09:42:48 +0200
Message-ID: <20081004074248.GA2536@ami.dom.local>
References: <48E34C82.2040306@fr.ibm.com> <20081001.031243.255655293.davem@davemloft.net> <20081001141432.470106980@theryb.frec.bull.fr> <20081001194825.GA2520@ami.dom.local> <48E3E64E.50106@fr.ibm.com> <20081001233152.GA2411@ami.dom.local> <48E4E772.2020208@bull.net> <20081002183819.GA2664@ami.dom.local> <20081002215502.q9and4a6kg4cs0o8@intran0x.frec.bull.fr> <20081002203435.GC2664@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Benjamin Thery <Benjamin.Thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:50908 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624AbYJDHm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2008 03:42:26 -0400
Received: by ug-out-1314.google.com with SMTP id k3so1389406ugf.37
        for <netdev@vger.kernel.org>; Sat, 04 Oct 2008 00:42:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081002203435.GC2664@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 02, 2008 at 10:34:35PM +0200, Jarek Poplawski wrote:
> On Thu, Oct 02, 2008 at 09:55:02PM +0200, Benjamin Thery  wrote:
> > Quoting Jarek Poplawski <jarkao2@gmail.com>:
> ...
> >> As a matter of fact I've thought about something even simpler, which
> >> probably should help for all above concerns too:
> >>
> >> 	if (event == NETDEV_UNREGISTER)
> >>   	        dst_gc_task(&dst_gc_work.work);
> >>
> >> dst_gc_task() locking allows for this, and running this two times in
> >> a row could be even faster than trying to cancel the unnecessary run.
> >
> > I've thought a bit more about my last proposal and come to the same
> > conclusion as you, hmm, almost. I thought we could call
> > cancel_delayed_work() unconditionally and then dst_gc_task().
> >
> >  	if (event == NETDEV_UNREGISTER) {
> >                 cancel_delayed_work(&dst_gc_work);
> >    	        dst_gc_task(&dst_gc_work.work);
> >         }
> >
> > But, you're right, calling only dst_gc_task() seems fine to me.
> 
> I'm OK with any of these versions.
> 
> >
> > I'll run some tests tomorrow and send a new patch.
> >
> > Do we agree that this fix (calling dst_gc_task() in dst_dev_event())
> > is better/more appropriate than the first one (replacing rtnl_unlock()
> > by the non-blocking __rtnl_unlock() in linkwatch_event())?

Hmm... You can kill me, but after more looking at this I've changed my
mind.

> I agree it's more appropriate, because:
> a) the job is done according to the rules (in the comment) during
>    the notification and not in some future,

But, since the rules are wrong or protocols buggy, the solution isn't
effective: there should be no deadlock after this, but it's also hard
to predict how many dst_gc_task() runs are needed to free all refs.
During this all other works would be unnecessarily blocked by the
linkwatch, what looks a bit too hoggish.

My current idea is we should move linkwatch or dst_gc_task() (or both)
to it's own workqueue.

> b) it removes some hidden dependencies between processes/works, which,
>    even if they currently don't exist except this one in the linkwatch,
>    could be extremly hard to diagnose, if added accidentally in the
>    future.
> 
> On the other hand, until we are not sure of the reasons, why something

BTW, sorry, of course:
"On the other hand, until we are sure of the reasons, why something"

> like this (the full destroying) was avoided in the past, and until it's
> heavily tested (with lockdep), your first patch looks to me much safer
> if applying to any -stable is considered.

And this first patch looks better and better each time...

Jarek P.

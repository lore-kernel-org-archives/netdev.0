From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bugme-new] [Bug 7974] New: BUG: scheduling while atomic: swapper/0x10000100/0
Date: Thu, 15 Feb 2007 15:45:23 -0800
Message-ID: <200702152345.l1FNjN22000583@death.nxdomain.ibm.com>
References: <20070209133802.01286bbb.akpm@linux-foundation.org> <20070213202905.GA26818@gospo.rdu.redhat.com> <200702132226.l1DMQS22009230@death.nxdomain.ibm.com> <20070213.143243.78711492.davem@davemloft.net> <20070213230803.GB26818@gospo.rdu.redhat.com> <200702132333.l1DNX022012433@death.nxdomain.ibm.com> <20070214013130.GD26818@gospo.rdu.redhat.com> <200702140211.l1E2BF22031298@death.nxdomain.ibm.com> <20070215210019.GB30353@gospo.rdu.redhat.com>
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	lpiccilli@gelre.com.br, bugme-daemon@bugzilla.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:54476 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932852AbXBOXp3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Feb 2007 18:45:29 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1FNjQsG006376
	for <netdev@vger.kernel.org>; Thu, 15 Feb 2007 18:45:26 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1FNjQQQ298334
	for <netdev@vger.kernel.org>; Thu, 15 Feb 2007 18:45:26 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1FNjPH1006543
	for <netdev@vger.kernel.org>; Thu, 15 Feb 2007 18:45:26 -0500
In-reply-to: <20070215210019.GB30353@gospo.rdu.redhat.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek <andy@greyhouse.net> wrote:

[...]
>That might be the case, but I feel like the code is in a place where it
>*could* work tomorrow with just some small tweaks (getting everything
>into process context).  I'm reluctant to cram a whole bunch of changes
>down someone's throat immediately (with a big patch) because it will be
>difficult to learn incrementally what is being done well and what isn't
>based on user feedback.

	Fair enough.

>> 	I like having the mode-specific monitors simply be special case
>> monitors in a unified "monitor system." It resolves the link-check
>> vs. mode-specific conflict, and allows all of the periodic things to be
>> paused as a set for mutexing purposes.  I'm happy to be convinced that
>> I'm just blowing hooey here, but that's how it seems to me.
>> 
>
>I went back and looked at my patch from a few months ago and I actually
>use a single-threaded workqueue for each bond device.  I did not use
>different queues to replace each timer -- just different types of work
>that is placed on the queue.  So it sounds like we agree -- now we just
>need to pick a decent starting point?

	For the short term, yes, I don't have any disagreement with
switching the timer based stuff over to workqueues.  Basically a one for
one replacement to get the functions in a process context and tweak the
locking.

	I do think we're having a little confusion over details of
terminology; if I'm not mistaken, you're thinking that workqueue means
single threaded: even though each individual "monitor thingie" is a
separate piece of work, they still can't collide.

	That's true, but (unless I've missed a call somewhere) there
isn't a "wq_pause_for_a_bit" type of call (that, e.g., waits for
anything running to stop, then doesn't run any further work until we
later tell it to), so suspending all of the periodic things running for
the bond is more hassle than if there's just one schedulable work thing,
which internally calls the right functions to do the various things.
This is also single threaded, but easier to stop and start.  It seems to
be simpler to have multiple link monitors running in such a system as
well (without having them thrashing the link state as would happen now).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] PKT_SCHED: Initialize list field in dummy qdiscs
Date: Sun, 7 Nov 2004 18:49:09 +0100
Message-ID: <20041107174909.GC31969@postel.suug.ch>
References: <20041105194303.GA12289@postel.suug.ch> <20041106011843.GI12289@postel.suug.ch> <418C2D40.9020300@trash.net> <20041106015931.GA28715@postel.suug.ch> <20041106145036.GB28715@postel.suug.ch> <418DE37E.2050504@trash.net> <20041107140015.GA31969@postel.suug.ch> <418E4B2E.1070407@trash.net> <20041107163330.GB31969@postel.suug.ch> <418E553C.2070006@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com, spam@crocom.com.pl,
        kuznet@ms2.inr.ac.ru, jmorris@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <418E553C.2070006@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> >We get a RTM_DELQDISC request so you'll increment refcnt in
> >qdisc_lookup and decrement it right before you call qdisc_destroy
> >so it actually can be deleted. The rcu callback works fine
> >and will set up a another rcu callback for the destroying of
> >the inner qdiscs. Right at this time you get a RTM_GETQDISC for
> >that inner qdisc so you'll lock on it, then the rcu callback
> >comes in and cannot delete the inner qdisc anymore. Do you want
> >to sleep in softirq context?
> >
> This can't happen. Once the inner qdiscs refcnt drops to zero
> they are removed from the list, before the rcu callback is scheduled.
> Once the RCU callback is scheduled it can't be found anymore.

Right, but what about when the RTM_GETQDISC comes in before the first
rcu callback is invoked? I'm not sure if this can happen in practice
though.

Anyways, I do think we should force the task to be completed, or
at least all the list unlinking, before the rtnl semaphore is given
back.  I'm fine with postponing the deletion of the object but not
to postpone list manipulations even if we cannot reproduce it now.

We might be able to get a working solution for now but
this unneeded async behaviour will definitely cause much troubles
in the future.

I think no function that can be invoked from softirq context should
ever have the chance to sleep even if there is no path at the
moment. Why bother about this when we can move the possible sleep into
a user context only area?

> BTW: An alternative, quite unintrusive solution is to prevent anyone
> from finding the inner qdiscs after the outer one has been destroyed.
> This can be done be keeping inner qdiscs on qdisc->qdisc_list and only
> keep the top-level qdisc in struct net_device. Of course, this makes
> walking all qdiscs more complicated. A generation counter for the
> top-level qdisc should also work.

I agree, that's rather non trivial.

I'll wait for your patch but it's wrong in my eyes ;->

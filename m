From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Fri, 7 Mar 2008 07:51:13 +0000
Message-ID: <20080307075113.GA3912@ff.dom.local>
References: <20080225095646.GA4321@ff.dom.local> <20080225104652.M2446@visp.net.lb> <20080225113930.GA4733@ff.dom.local> <20080305103935.M76165@visp.net.lb> <20080306134015.GA4571@ff.dom.local> <1204811995.4440.30.camel@localhost> <20080306175629.GA2876@ami.dom.local> <1204836523.4457.103.camel@localhost> <20080306214000.GC2876@ami.dom.local> <1204846839.4431.23.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:60882 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755068AbYCGHt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2008 02:49:56 -0500
Received: by ug-out-1314.google.com with SMTP id z38so4234544ugc.16
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2008 23:49:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1204846839.4431.23.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 06, 2008 at 06:40:39PM -0500, jamal wrote:
> Jarek,
> 
> On Thu, 2008-06-03 at 22:40 +0100, Jarek Poplawski wrote:
> 
> > But currently lockdep doesn't know dev->queue_lock could mean eth or lo.
> > It sees one class of devices using one lock. 
> 
> yikes ;-> I missed the implication when you mentioned it first - thanks
> for the enlightnment. IMO, it needs to be per netdevice not global; so i
> contend this is the problem i.e those warnings are false.
> 
> > We can let it know (e.g.
> > dev->_xmit_lock is different according to dev->type), but it wasn't
> > necessary. I hope it will suffice here if lockdep knows more about ifb,
> > but similar problem could theoretically happen with other devs.
> 
> I think the condition needs to be met for all netdevices, not just ifb.
> Instead of annotating each netdevice type separately, could you not use
> a different annotation in the generic netdev registration code of the
> form dev_%s->ingress/queue_lock ? (where %s is dev->name)

At first this lockdep method looks like wrong (too general). But it
works. With every lock tracked separately there would be huge overhead
(especially with some structures created in thousands of instances).
And with this general approach we can see general problems: e.g.
wrong locking order even reported on two different devices like here,
and impossible in reality, can help to analyze if the same could
happen in another, maybe even very hard to reproduce, variant, and to
fix this before ever happened.

So, current way is to start from very general tracking, and if it
doesn't work (I mean false reports, not lockups), we make it more
specific. With dev->_xmit_lock the type level seems to be enough
for some time (so lockdep doesn't even know eth0 and eth1 created
as ARPHRD_ETHER use 2 different _xmit_locks).

Such specific information is usually necessary only with nesting.
But here, with sch_ingress + act_mirred it's not about nesting: it's
really about wrong order, which could be safe only because ifb
doesn't currently work with a full egress + ingress functionality.

Making this all more specific for lockdep won't help with real
lockups then, but will make reports more exact and less reproducible.

> > Sorry, should be:
> >  dev_eth0->queue_lock, and thread3 has dev_eth0->queue_lock and wants
> 
> indeed - i understood when you said that; it doesnt invalidate what i
> said.
> 
> > > thread3 can not happen because we dont allow it (the other 2 are not
> > > contentious).
> > 
> > Could you explain why? 
> 
> Because we never redirect to ingress (it is in the todo as mentioned as
> described at the top of the source file). You can redirect from ingress
> or egress but only to egress (to sockets and ingress are going to happen
> at some future point).
> 
> > Yes, but it seems such redirection between two eths like above mentioned
> > is legal?
> 
> Indeed it is. I think it is clear to me now the issues seem to be the
> namespace of what lockdep - it should be per-device and NOT global.
> What do you think?

I've to find first what really bothers lockdep here, and why this
queue_lock vs. ingress_lock order isn't reported "by default". But if
this really is like it looks now, then it seems before doing this
ingress "future point" some change in locking could be necessary.
(Maybe even sooner if lockdep finds something real after this current
patch to ifb.)

Cheers,
Jarek P.

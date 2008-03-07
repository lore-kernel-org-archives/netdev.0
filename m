From: jamal <hadi@cyberus.ca>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Fri, 07 Mar 2008 08:53:22 -0500
Message-ID: <1204898002.4431.99.camel@localhost>
References: <20080225095646.GA4321@ff.dom.local>
	 <20080225104652.M2446@visp.net.lb> <20080225113930.GA4733@ff.dom.local>
	 <20080305103935.M76165@visp.net.lb> <20080306134015.GA4571@ff.dom.local>
	 <1204811995.4440.30.camel@localhost> <20080306175629.GA2876@ami.dom.local>
	 <1204836523.4457.103.camel@localhost> <20080306214000.GC2876@ami.dom.local>
	 <1204846839.4431.23.camel@localhost>  <20080307075113.GA3912@ff.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.225]:12860 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757628AbYCGNxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2008 08:53:30 -0500
Received: by wx-out-0506.google.com with SMTP id h31so680702wxd.4
        for <netdev@vger.kernel.org>; Fri, 07 Mar 2008 05:53:30 -0800 (PST)
In-Reply-To: <20080307075113.GA3912@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-07-03 at 07:51 +0000, Jarek Poplawski wrote:

> At first this lockdep method looks like wrong (too general). But it
> works. With every lock tracked separately there would be huge overhead
> (especially with some structures created in thousands of instances).
> And with this general approach we can see general problems: e.g.
> wrong locking order even reported on two different devices like here,
> and impossible in reality, 

The problem is not so much so that it is an impossible situation, rather
it is not a useful detail to report as is. 
As an example, heres something i consider useful to catch:
 dev->queuelock for ethx being held recursively
In your current setup, there will be many false-positives. i.e it will
show something like dev->queuelock for eth0 is being held and flagging
that as a problem because dev->queuelock for eth1 is also being held.
i.e a lot of noise.

> can help to analyze if the same could
> happen in another, maybe even very hard to reproduce, variant, and to
> fix this before ever happened.

It is possible some odd issue will be found by having the lockdeps in
their current setup - but if you have to sift through noise in order to
find it, then it makes it harder.

> So, current way is to start from very general tracking, and if it
> doesn't work (I mean false reports, not lockups), we make it more
> specific. 

Is it time to do that now? I know you said it was too much data to
carry. However, such data depends on how many netdevices are on the
system and lockdep is optional. You could even make NETDEV_LOCKDEP
version which is accurate and the other one as being less accurate.

> With dev->_xmit_lock the type level seems to be enough
> for some time (so lockdep doesn't even know eth0 and eth1 created
> as ARPHRD_ETHER use 2 different _xmit_locks).

I am curious what issue has been found with this approach. I can see
that someone who knows what they are doing could sift through reports
and be able to catch something. My thinking is it most reports are going
to be noise. People will report them because they are scary looking.

> Such specific information is usually necessary only with nesting.

It could also apply to a single lock (for example redirecting 
eth0->eth0 or eth0->manyotherredirectshere->eth0)

> But here, with sch_ingress + act_mirred it's not about nesting: it's
> really about wrong order, which could be safe only because ifb
> doesn't currently work with a full egress + ingress functionality.

ifb never ever works with ingress. It is design intent. It is a special
netdevice (as the text says) which receives only redirected packets.

> I've to find first what really bothers lockdep here, and why this
> queue_lock vs. ingress_lock order isn't reported "by default". 

I dont see the problem in this case, those traces are false-positives -
but no harm in investigating further. I still think the only time you
can find real issues is when you have per-netdevice lockdep; anything
else will only find issues only with the help of an expert.

> But if
> this really is like it looks now, then it seems before doing this
> ingress "future point" some change in locking could be necessary.

true. 

> (Maybe even sooner if lockdep finds something real after this current
> patch to ifb.)

As it stands right now Jarek, I think you need to teach lockedep more
smarter details.

cheers,
jamal


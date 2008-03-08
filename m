From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Sat, 8 Mar 2008 09:46:28 +0100
Message-ID: <20080308084628.GA2749@ami.dom.local>
References: <20080225113930.GA4733@ff.dom.local> <20080305103935.M76165@visp.net.lb> <20080306134015.GA4571@ff.dom.local> <1204811995.4440.30.camel@localhost> <20080306175629.GA2876@ami.dom.local> <1204836523.4457.103.camel@localhost> <20080306214000.GC2876@ami.dom.local> <1204846839.4431.23.camel@localhost> <20080307075113.GA3912@ff.dom.local> <1204898002.4431.99.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:48330 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753AbYCHImJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2008 03:42:09 -0500
Received: by fg-out-1718.google.com with SMTP id e21so952573fga.17
        for <netdev@vger.kernel.org>; Sat, 08 Mar 2008 00:42:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1204898002.4431.99.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 07, 2008 at 08:53:22AM -0500, jamal wrote:
...
> The problem is not so much so that it is an impossible situation, rather
> it is not a useful detail to report as is. 
> As an example, heres something i consider useful to catch:
>  dev->queuelock for ethx being held recursively
> In your current setup, there will be many false-positives. i.e it will
> show something like dev->queuelock for eth0 is being held and flagging
> that as a problem because dev->queuelock for eth1 is also being held.
> i.e a lot of noise.

But as you can see... you can't see these reports too often now.
Probably there are many people who are skeptical of lockdep like you.
But until it's an official tool you've to adjust and not scare users
with these reports (often called OOPSes!). The bad thing is that
currently any such report turns off lockdep checking for next possible
(false!?) problems.

> Is it time to do that now? I know you said it was too much data to
> carry. However, such data depends on how many netdevices are on the
> system and lockdep is optional. You could even make NETDEV_LOCKDEP
> version which is accurate and the other one as being less accurate.

That's why I'm trying now to find if making this more specific only
for ifb could suffice. This reverse locking order is used only on
sch_ingress -> act_mirred path, and it's mostly with ifb, which as you
said doesn't use this patch with it's ingress (at least currently).

> I am curious what issue has been found with this approach. I can see
> that someone who knows what they are doing could sift through reports
> and be able to catch something. My thinking is it most reports are going
> to be noise. People will report them because they are scary looking.

I never counted this, but you're mostly right, and most (90%?) of these
reports are really false-positives. But, even 10 or 5% correctness is
IMHO worth of it. I still think one of the most bothering things in
linux for users are misterious lockups, and this could be even more
so with these fast multicore boxes now.

One of the recent right-positives I can remember can be found on the
list in "Fix SMP oops in pppol2tp driver". This was really a complex
thing (and there is still something to find). The funniest of all is
David diagnosed it fastest probably without studying this report too
much, but on the other hand, nobody had spotted this issue before
lockdep. Another such a good lockdep's work is checking for
flush_workqueue() abusing (recently in "lockdep trace from rc2."
netdev thread).

> It could also apply to a single lock (for example redirecting 
> eth0->eth0 or eth0->manyotherredirectshere->eth0)

If you mean redirecting from ingress with act_mirred then of course.
I wrote earlier about eth0->ingress_redirected->eth1, eth1->
ingress_redirected->eth0 which would be right-positive IMHO. If
eth0->eth0 is legal this should be even more dangerous.

> ifb never ever works with ingress. It is design intent. It is a special
> netdevice (as the text says) which receives only redirected packets.
...
> I dont see the problem in this case, those traces are false-positives -
> but no harm in investigating further. I still think the only time you
> can find real issues is when you have per-netdevice lockdep; anything
> else will only find issues only with the help of an expert.

I think wrt ifb it's a false-positive too, that's why I din't try to
change locking but only add some info for lockdep. BTW, we shouldn't
forget such lockdep annotations are always under debugging config
options, and not intended to work (or use any resources) in production
or home boxes (at least until no need to write to kernel lists).
BTW#2, it seems this tcf_lock in act_mirred could need similar lockdep
treatment, but let's wait for Denys'es testing.

> As it stands right now Jarek, I think you need to teach lockedep more
> smarter details.

...But the beast is much smarter than me!

Regards,
Jarek P.

PS: sorry for delay, a little cold or something.

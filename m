From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: thousands of classes, e1000 TX unit hang
Date: Tue, 5 Aug 2008 12:23:40 +0000
Message-ID: <20080805122340.GB6541@ff.dom.local>
References: <20080805110453.GA6541@ff.dom.local> <200808051413.58795.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:27102 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760756AbYHEMSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 08:18:17 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1268387fgg.17
        for <netdev@vger.kernel.org>; Tue, 05 Aug 2008 05:18:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200808051413.58795.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 05, 2008 at 02:13:58PM +0300, Denys Fedoryshchenko wrote:
> On Tuesday 05 August 2008, Jarek Poplawski wrote:
> > On 05-08-2008 12:05, Denys Fedoryshchenko wrote:
> > > I found, that packetloss happening when i am deleting/adding classes.
> > > I attach result of oprofile as file.
> >
> > ...
> >
> > Deleting of estimators (gen_kill_estimator) isn't optimized for
> > a large number of them, and it's a known issue. Adding of classes
> > shouldn't be such a problem, but maybe you could try to do this
> > before adding filters directing to those classes.
> >
> > Since you can control rate with htb, I'm not sure you really need
> > policing: at least you could try if removing this changes anything.
> > And I'm not sure: do these tx hangs happen only when classes are
> > added/deleted or otherwise too?
> >
> > Jarek P.
> 
> Policer is creating burst for me.
> For example first 2Mbyte(+rate*time if need more precision) will pass on high 
> speed (1Mbit), then if flow is still using maximum bandwidth will be 
> throttled to rate of HTB. When i tried to play with cburst/burst values in 
> HTB i was not able to archieve same results. I can do same with TBF and his 
> peakrate/burst, but not with HTB.

Very interesting. Anyway tbf doesn't use gen estimators, so you could
test if it makes big difference for you.

> 
> It happens when root qdisc deleted(which holds around 130 child classes). 
> Probably gen_kill_estimator taking all resources while i am deleting root 
> class.
> I did some test, on machine with 150 ppp interfaces (Pentium 4 3.2 Ghz),
> just by deleting root qdisc and i got huge packetloss. When i am just adding 
> classes - there is no significant packetloss.
> Probably it is not right thing, when i am deleting qdisc on ppp - causing 
> packetloss on whole system? Is it possible to workaround, till 
> gen_kill_estimator will be rewritten?
> 
> But sure i can try to avoid "mass deleting" classes, but i think many people 
> will hit this bug, especially newbies, who implement "many class" setup.

Actually, gen_kill_estimator was rewritten already, but for some
reason it wasn't merged. Maybe there isn't so much users with such a
number of classes or they don't delete them, anyway this subject isn't
reported often to the list (I remember once). Some workaround could be
probably deleting individual classes (and filters) to give away a lock
and soft interrupts for a while), before deleting the root, but I
didn't test this. BTW, you are using quite long queues (3000), so there
would be interesting to make them less and check if doesn't add to the
problem (with retransmits).

Jarek P.

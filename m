From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: Use deferrable timer for watchdog
Date: Thu, 20 Dec 2007 13:08:41 -0800
Message-ID: <20071220130841.6d2801f2@deepthought>
References: <Pine.LNX.4.64.0712182008160.3616@mini.warudkars.net>
	<20071220091603.0d69b045@deepthought>
	<823114761-1198171803-cardhu_decombobulator_blackberry.rim.net-937108990-@bxe019.bisx.prod.on.blackberry>
	<20071220095121.7859c023@deepthought>
	<476ABDDF.8080607@intel.com>
	<476ABE7D.60901@linux.intel.com>
	<476AC105.9090206@intel.com>
	<82e4877d0712201200h7b994175u841d1efa047cefff@mail.gmail.com>
	<476ACABC.4010503@linux.intel.com>
	<82e4877d0712201236l2962cc86y73f0be0d6e2ae4be@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Arjan van de Ven" <arjan@linux.intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org
To: "Parag Warudkar" <parag.warudkar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41338 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754170AbXLTVJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 16:09:51 -0500
In-Reply-To: <82e4877d0712201236l2962cc86y73f0be0d6e2ae4be@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Dec 2007 15:36:13 -0500
"Parag Warudkar" <parag.warudkar@gmail.com> wrote:

> On Dec 20, 2007 3:04 PM, Arjan van de Ven <arjan@linux.intel.com> wrote:
> > > I think it is reasonable for Network driver watchdogs to use a
> > > deferrable timer - if the machine is 100% IDLE there is no one needing
> > > the network to be up. If there is something running even on the other
> > > CPU - that is going to cause an IPI, reschedule, TLB invalidation etc.
> > > which will make it very likely in practice that each CPU will be
> > > interrupted in reasonable amount of time.
> >
> > this is not correct; many machines are idle waiting for network data. Think of webservers...
> 
> Yes, I forgot the receive case. So if a server was 100% IDLE and a web
> server was listening for network data and we reach 0 wakeups per
> second on the CPU where the network watchdog timer is scheduled to run
> deferred _and_ the network link went down, it would cause the watchdog
> to not run and redo the link until some one else wakes up that CPU
> later.
> So as long as we make sure we don't convert every timer to deferrable
> we should be ok - may be this can be resolved easily by having a
> non-deferrable "dont-allow-deferring-for-too-long" timer on each CPU
> that just causes at least one wake up in some reasonable time delta
> from the previous wakeup (whoever caused that one.) It is still
> beneficial in that all deferrable timers would run at once without
> needing to have separate wakeup for each.
> 
> >
> > >
> > > Of course there are theoretical cases where we could land into a
> > > situation where a CPU in a multiprocessor machine is IDLE infinitely
> > > and that causes the watchdog that happens to be bound to run on the
> > > same CPU to not run. To take care of these unlikely cases I think the
> > > timer mechanism should have a reasonable limit on how long a CPU can
> > > go IDLE if there are deferrable timers.
> >
> > how about something else instead: a timer mechanism that takes a range instead..
> > that at least has defined semantics; the deferrable semantics really are "indefinite".
> > Lets keep at least the semantics clear and clean.
> >
> 
> Would not the simpler solution of installing a non-deferrable timer
> per cpu which will not allow the CPU to go IDLE for more than x units
> of time at once  (or something to that effect) work? Range would
> complicate the thing and I am not sure how many cases will know
> reasonably correct range for their normal operation. In this instance
> of the e1000 watchdog what range could it give and be successful at
> what it wants to do - bring up the link in reasonable amount of time,
> while also realizing the power savings?
> 
> Perhaps depending on Server/Laptop/Desktop machine (may be based on
> Preemption) we could have normal or deferrable timers but that'll
> exclude Servers from power savings and I am not sure Data center folks
> will like that :) .
> 
> Parag


The problem is that on a server the receiver will go deaf if the chip
bug that the watchdog is looking for triggers.  Yes, no packets in
and it happily will just sit there.

So for now, I am not going to apply your simple patch and work on a 
two stage timer per arjan's suggestion for a later release.

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>

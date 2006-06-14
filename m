From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/2] e1000: fix netpoll with NAPI
Date: Wed, 14 Jun 2006 16:41:58 -0400
Message-ID: <20060614204158.GA3967@hmsreliant.homelinux.net>
References: <20060606231727.GK24227@waste.org> <20060607150522.GA24608@hmsreliant.homelinux.net> <20060607164801.GX24227@waste.org> <44871A19.7080805@intel.com> <x49d5dkvm8p.fsf@segfault.boston.redhat.com> <1149787174.2928.3.camel@strongmad> <x49ac8nwo83.fsf@redhat.com> <20060612001356.GA5112@localhost.localdomain> <1150130534.2879.9.camel@strongmad> <20060612180600.GB3790@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Moyer <jmoyer@redhat.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	Matt Mackall <mpm@selenic.com>,
	"Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-70-61-120-52.midsouth.biz.rr.com ([70.61.120.52]:16911
	"EHLO ra.tuxdriver.com") by vger.kernel.org with ESMTP
	id S932257AbWFNUme (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jun 2006 16:42:34 -0400
To: Mitch Williams <mitch.a.williams@intel.com>
Content-Disposition: inline
In-Reply-To: <20060612180600.GB3790@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 12, 2006 at 02:06:00PM -0400, Neil Horman wrote:
> On Mon, Jun 12, 2006 at 09:42:14AM -0700, Mitch Williams wrote:
> > On Sun, 2006-06-11 at 17:13 -0700, Neil Horman wrote:
> > > Any further thoughts on this guys?  I still think my last solution
> > > solves all of
> > > the netpoll problems, and isn't going to have any noticable impact on
> > > performance.
> > > 
> > I haven't had time to evaluate performance on your patch (sorry!), but
> > after thinking about it, I agree that it should not have any noticeable
> > impact.  OTOH, performance tuning is a funny thing, and things you think
> > won't cause problems often do.
> > 
> Thats ok, I just didn't hear out of anyone on friday, so I was curious as to
> where we were on this.  I don't have the ability to do any real world
> performance testing here, but I'll try to record the run time of the interrupt
> routine on a limited number of frames here.
> 

Hey, as promised, I've done some rudimentary performance benchmarking on various
ways that we have talked about to solve this problem.  As I previously mentioned
I didn't have the equipment to do any real full scale testing here, so what I
did was take a read of the real time counter at the start and end of the
e1000_intr routine with various patches applied, and I recorded the number of
ticks elapsed on the tsc during its run.  I did this on my single cpu x86_64
machine here, using the latest unpatched e1000 driver as a base, and then
comparing it to the e1000 driver using my patch and separately with a patch that
spinlocks the e1000_clean_rx_irq routine (so as to serialize the critical
section that would otherwise be subject to data corruption.  Here are my
results:

Base line: 
Avg. 8145 Ticks on the tsc.

With my patch: http://marc.theaimsgroup.com/?l=linux-netdev&m=114970807606096&w=2 
Avg. 8159 Ticks on the tsc. (+0.17% increase)

With a spinlock added to e1000_clean_rx_irq:
Avg. 8238 Ticks on the tsc. (+1.1% increase)

If you like I can send you the time stamp counter patch that I used, as well as
the patch which adds spinlocks to the clean routine.  Note that the free running
counter values will vary so you probably want to look at percentage increase.
Either way, I think either solution provides very little impact on interrupt run
time.  Given that my patch (granted using my test methodology here) is the
faster of the two, and arguably the more correct in terms of not using the poll
controller method to recieve frames, We should go with that patch.

Thoughts/opinions? 
Neil


-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *gpg keyid: 1024D / 0x92A74FA1 - http://pgp.mit.edu
 ***************************************************/

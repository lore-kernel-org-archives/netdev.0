From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/2] e1000: fix netpoll with NAPI
Date: Mon, 12 Jun 2006 14:06:00 -0400
Message-ID: <20060612180600.GB3790@hmsreliant.homelinux.net>
References: <x49zmgquqn0.fsf@segfault.boston.redhat.com> <20060606231727.GK24227@waste.org> <20060607150522.GA24608@hmsreliant.homelinux.net> <20060607164801.GX24227@waste.org> <44871A19.7080805@intel.com> <x49d5dkvm8p.fsf@segfault.boston.redhat.com> <1149787174.2928.3.camel@strongmad> <x49ac8nwo83.fsf@redhat.com> <20060612001356.GA5112@localhost.localdomain> <1150130534.2879.9.camel@strongmad>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Moyer <jmoyer@redhat.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	Matt Mackall <mpm@selenic.com>,
	"Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-70-61-120-52.midsouth.biz.rr.com ([70.61.120.52]:21519
	"EHLO ra.tuxdriver.com") by vger.kernel.org with ESMTP
	id S1751517AbWFLSGf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 14:06:35 -0400
To: Mitch Williams <mitch.a.williams@intel.com>
Content-Disposition: inline
In-Reply-To: <1150130534.2879.9.camel@strongmad>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 12, 2006 at 09:42:14AM -0700, Mitch Williams wrote:
> On Sun, 2006-06-11 at 17:13 -0700, Neil Horman wrote:
> > Any further thoughts on this guys?  I still think my last solution
> > solves all of
> > the netpoll problems, and isn't going to have any noticable impact on
> > performance.
> > 
> I haven't had time to evaluate performance on your patch (sorry!), but
> after thinking about it, I agree that it should not have any noticeable
> impact.  OTOH, performance tuning is a funny thing, and things you think
> won't cause problems often do.
> 
Thats ok, I just didn't hear out of anyone on friday, so I was curious as to
where we were on this.  I don't have the ability to do any real world
performance testing here, but I'll try to record the run time of the interrupt
routine on a limited number of frames here.

> Anyway, I'm still not quite ready to ACK this because it's just not
> future-proof.  Eventually, we will need to support multiple RX queues,
> and this solution will not work in that situation.
> 
Not sure I understand this.  My patch:
http://marc.theaimsgroup.com/?l=linux-netdev&m=114970506406155&w=2
still allows for the use of multiple rx
queues in the nominal case.  Only when we have to use a relatively slow netpoll
driven operation (kgdb, netdump, etc), do we need to receive on the same
interface that we transmit on.

> A simpler short-term solution is just to schedule our NAPI polling on
> the "real" netdev instead of our polling netdev.  This is a trivial
> change and works correctly with a single queue.  But, like your patch,
> it isn't future-proof.
> 
Again, not sure what you mean here.  My last patch proposal:
http://marc.theaimsgroup.com/?l=linux-netdev&m=114970807606096&w=2
Does precisely what you describe, but it still allows for multiple rx queues in
the nominal (non poll_controller driven) receive case.

> So, I'm still thinking and pondering on this one.
> 
> If we get a patch in to fix the recursive loop in netpoll, my original
> patch will work, right?  Or is there still another issue?
> 
I assume you are referring to this patch:
http://marc.theaimsgroup.com/?l=linux-netdev&m=114970506406155&w=2
If so, then no, that patch is still broken for the reasons Jeff outlined
previously, The recursion patch that I proposed earlier today is related to a
different recursion problem, and while the e1000 driver might be suceptable to
it, your patch is also suceptible to the data corruption that arises from when
the poll_controller calls adapter->clean_rx at the same that that dev->poll is
called for the same adapter on another cpu.  If that happens we can have two
cpu's writing to the same private net_device data without the benefit of a
spinlock to protect them.  And yes, you can add a spin lock to protect the case
where you have a dev->poll_controller and a dev->poll operation at the same
time, but that seems to me like it will also re-serialize all the parallel
operations that you could otherwise do with multiple rx queues

I'll post again if I get a chance to do some performance measurements
Regrds
Neil

> -Mitch
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *gpg keyid: 1024D / 0x92A74FA1 - http://pgp.mit.edu
 ***************************************************/

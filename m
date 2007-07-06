From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: Multiqueue and virtualization WAS(Re: [PATCH 3/3] NET: [SCHED]
	Qdisc changes and sch_rr added for multiqueue
Date: Fri, 06 Jul 2007 17:32:46 +1000
Message-ID: <1183707166.6005.172.camel@localhost.localdomain>
References: <1183215164.5165.13.camel@localhost>
	 <20070630.133357.77057070.davem@davemloft.net>
	 <1183466553.5159.51.camel@localhost>
	 <20070703.142431.49854676.davem@davemloft.net>
	 <1183515611.5174.34.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:45154 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761167AbXGFHdK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 03:33:10 -0400
In-Reply-To: <1183515611.5174.34.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-07-03 at 22:20 -0400, jamal wrote:
> On Tue, 2007-03-07 at 14:24 -0700, David Miller wrote:
> [.. some useful stuff here deleted ..]
> 
> > That's why you have to copy into a purpose-built set of memory
> > that is composed of pages that _ONLY_ contain TX packet buffers
> > and nothing else.
> > 
> > The cost of going through the switch is too high, and the copies are
> > necessary, so concentrate on allowing me to map the guest ports to the
> > egress queues.  Anything else is a waste of discussion time, I've been
> > pouring over these issues endlessly for weeks, so if I'm saying doing
> > copies and avoiding the switch is necessary I do in fact mean it. :-)
> 
> ok, i get it Dave ;-> Thanks for your patience, that was useful.
> Now that is clear for me, I will go back and look at your original email
> and try to get back on track to what you really asked ;->

To expand on this, there are already "virtual" nic drivers in tree which
do the demux based on dst mac and send to appropriate other guest
(iseries_veth.c and Carsten Otte said the S/390 drivers do too).  lguest
and DaveM's LDOM make two more.

There is currently no good way to write such a driver.  If one recipient
is full, you have to drop the packet: if you netif_stop_queue, it means
a slow/buggy recipient blocks packets going to other recipients.  But
dropping packets makes networking suck.

Some hypervisors (eg. Xen) only have a virtual NIC which is
point-to-point: this sidesteps the issue, with the risk that you might
need a huge number of virtual NICs if you wanted arbitrary guests to
talk to each other (Xen doesn't support that, they route/bridge through
dom0).

Most hypervisors have a sensible maximum on the number of guests they
could talk to, so I'm not too unhappy with a static number of queues.
But the dstmac -> queue mapping changes in hypervisor-specific ways, so
it really needs to be managed by the driver...

Hope that adds something,
Rusty.



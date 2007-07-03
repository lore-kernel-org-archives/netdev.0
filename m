From: David Miller <davem@davemloft.net>
Subject: Re: Multiqueue and virtualization WAS(Re: [PATCH 3/3] NET: [SCHED]
 Qdisc changes and sch_rr added for multiqueue
Date: Tue, 03 Jul 2007 14:24:31 -0700 (PDT)
Message-ID: <20070703.142431.49854676.davem@davemloft.net>
References: <1183215164.5165.13.camel@localhost>
	<20070630.133357.77057070.davem@davemloft.net>
	<1183466553.5159.51.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36554
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752969AbXGCVYM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 17:24:12 -0400
In-Reply-To: <1183466553.5159.51.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Tue, 03 Jul 2007 08:42:33 -0400

> (likely not in the case of hypervisor based virtualization like Xen)
> just have their skbs cloned when crossing domains, is that not the
> case?[1]
> Assuming they copy, the balance that needs to be stricken now is
> between:

Sigh, I kind of hoped I wouldn't have to give a lesson in
hypervisors and virtualized I/O and all the issues contained
within, but if you keep pushing the "avoid the copy" idea I
guess I am forced to educate. :-)

First, keep in mind that my Linux guest drivers are talking
to Solaris control node servers and switches, I cannot control
the API for any of this stuff.  And I think that's a good thing
in fact.

Exporting memory between nodes is _THE_ problem with virtualized I/O
in hypervisor based systems.

These things should even be able to work between two guests that
simply DO NOT trust each other at all.

With that in mind the hypervisor provides a very small shim layer of
interface for exporting memory between two nodes.  There is a
pseudo-pagetable where you export pages, and a set of interfaces
one of which copies to/from inported memory to/from local memory.

If a guest gets stuck, reboots, crashes, or gets stuck, you have
to be able to revoke the memory the remote node has inported.
When this happens, if the inporting node comes back to life and
tries to touch those pages it takes a fault.

Taking a fault is easy if the nodes go through the hypervisor copy
interface, they just get a return value back.  If, instead, you try to
map in those pages or program them into the IOMMU of the PCI
controller, you get faults, and extremely difficult to handle faults
at that.  If the IOMMU takes the exception on a revoked page, your
E1000 card resets when it gets the master abort from the PCI
controller.  On the CPU side you have to annotate every single kernel
access to this memory mapping of inported pages, just like we have to
annotate all userspace accesses with exception tables mapping load and
store instructions to fixup code, in order to handler the fault
correctly.

Next, you don't trust the other end as we already stated, so you
can't export object in a page that belong to other objects.  For
example, if a SKB's data sits in the same page as the plain-text
password the user just typed in, you can't export that page.

That's why you have to copy into a purpose-built set of memory
that is composed of pages that _ONLY_ contain TX packet buffers
and nothing else.

The cost of going through the switch is too high, and the copies are
necessary, so concentrate on allowing me to map the guest ports to the
egress queues.  Anything else is a waste of discussion time, I've been
pouring over these issues endlessly for weeks, so if I'm saying doing
copies and avoiding the switch is necessary I do in fact mean it. :-)

From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH 1/5] try parent numa_node at first before using default
Date: Thu, 12 Jul 2007 13:30:28 +0200
Message-ID: <469610D4.70009@s5r6.in-berlin.de>
References: <200707101641.17672.yinghai.lu@sun.com>	<200707101652.31378.yinghai.lu@sun.com>	<4694B702.2050507@s5r6.in-berlin.de>	<20070711210833.GA22745@kroah.com>	<46954B92.8000407@sun.com>	<46959651.1050400@s5r6.in-berlin.de>	<4695998C.8090100@sun.com>	<4695C088.7000606@s5r6.in-berlin.de> <20070712091529.2b914ece@gondolin.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Yinghai.Lu@Sun.COM, Greg KH <greg@kroah.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andi Kleen <ak@suse.de>, rientjes@google.com,
	Christoph Lameter <clameter@sgi.com>,
	Christoph Hellwig <hch@infradead.org>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Cornelia Huck <cornelia.huck@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hp3.statik.tu-cottbus.de ([141.43.120.68]:53536 "EHLO
	hp3.statik.tu-cottbus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756349AbXGLLaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 07:30:55 -0400
In-Reply-To: <20070712091529.2b914ece@gondolin.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cornelia Huck wrote:
> On Thu, 12 Jul 2007 07:47:52 +0200,
> Stefan Richter <stefanr@s5r6.in-berlin.de> wrote:
>> Also keep in mind that either device_move() should update the numa_node,
>> or the subsystems which call device_move() should explicitly update it
>> on their own.   (Unless they know that their devices will always stay at
>> the same NUMA node even when switching parents.)
> 
> I'd trust the subsystems to know best whether something regarding NUMA
> changed.

Generally,

  - the *subsystems* know about the topology (parent devices, NUMA
    nodes).  The assumption that the child device belongs per default to
    the same NUMA node as its parent device is usually correct, but it
    really is only an assumption.

  - The *drivers* incorporate as much knowledge about topology from the
    subsystem as is necessary e.g. for correct DMA mapping.  E.g. a
    device X on bus B which is attached to controller Y needs DMA
    mapping for device Y, not for device X.  Same, NUMA-optimized
    allocations have to be done for the NUMA node of DMA device Y.  An
    association of device X with a NUMA node is not interesting to the
    driver.  It becomes a bit more difficult if the driver sits between
    two subsystems and that upper-layer subsystem has no flexible API to
    pass up the correct NUMA node.

So, since figuring the correct DMA device out is done by drivers
themselves, they usually can figure out the correct NUMA node as well.
The only precondition is that each DMA device has the correct NUMA node
set.  This is the job of subsystems like PCI, but it may be reasonable
to have simple and broadly applicable helpers for this in the driver core.

So, _is_ the dev->numa_node = dev->parent.numa_node assumption, if
implemented in device_add() and device_move(), as simple and as broadly
applicable as we want driver core's API to be?  Perhaps yes.
-- 
Stefan Richter
-=====-=-=== -=== -==--
http://arcgraph.de/sr/

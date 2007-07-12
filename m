From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH 1/5] try parent numa_node at first before using default
Date: Thu, 12 Jul 2007 09:15:29 +0200
Message-ID: <20070712091529.2b914ece@gondolin.boeblingen.de.ibm.com>
References: <200707101641.17672.yinghai.lu@sun.com>
	<200707101652.31378.yinghai.lu@sun.com>
	<4694B702.2050507@s5r6.in-berlin.de>
	<20070711210833.GA22745@kroah.com>
	<46954B92.8000407@sun.com>
	<46959651.1050400@s5r6.in-berlin.de>
	<4695998C.8090100@sun.com>
	<4695C088.7000606@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Yinghai.Lu@Sun.COM, Greg KH <greg@kroah.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andi Kleen <ak@suse.de>, rientjes@google.com,
	Christoph Lameter <clameter@sgi.com>,
	Christoph Hellwig <hch@infradead.org>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:45729 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753881AbXGLHPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 03:15:14 -0400
In-Reply-To: <4695C088.7000606@s5r6.in-berlin.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 12 Jul 2007 07:47:52 +0200,
Stefan Richter <stefanr@s5r6.in-berlin.de> wrote:

> The patch does nothing for all subsystems which do
> 
> 	device_initialize(&dev);
> 	dev->parent = pd;
> 	device_add(&dev);
> 
> Let's avoid to add infrastructure which does nothing, or only does
> something by accident.

I agree. dev->parent now is only expected to be set in device_add(),
not in device_initialize(), so the sequence above is perfectly fine.
(Why should you need it, anyway? parent information becomes necessary
only when something is added to the tree.)
> 
> The alternatives are:
> 
>   - Change all subsystems to set dev->parent before device_initialize().
>     *Document* that the device_initialize() API has this requirement.
>     This is counter-intuitive, amounts to some work across the kernel,
>     and could be gotten wrong again in future code because it's a
>     counter-intuitive API.

Yes. We shouldn't do that.
> 
>   - Move your code from device_initialize() to device_add().  One minor
>     drawback is that node-specific allocations based on the device's
>     numa_node would not be optimized before device_add(), but there is
>     probably no need for this.  Driver probes come after device_add().

I'd expect most allocations to be done when probing, so this shouldn't
hurt much.
> 
>   - Let subsystems explicitly call set_dev_node() on their own.
> 
> 
> Also keep in mind that either device_move() should update the numa_node,
> or the subsystems which call device_move() should explicitly update it
> on their own.   (Unless they know that their devices will always stay at
> the same NUMA node even when switching parents.)

I'd trust the subsystems to know best whether something regarding NUMA
changed.

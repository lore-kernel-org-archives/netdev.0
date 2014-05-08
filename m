From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] jme: Fix DMA unmap warning
Date: Thu, 08 May 2014 13:24:18 -0400 (EDT)
Message-ID: <20140508.132418.1609457131828640063.davem@davemloft.net>
References: <20140507.155613.630399521517455317.davem@davemloft.net>
	<20140507203317.GC8786@hmsreliant.think-freely.org>
	<063D6719AE5E284EB5DD2968C1650D6D0F70F4EB@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	cooldavid@cooldavid.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57728 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755143AbaEHRYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 13:24:20 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F70F4EB@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Thu, 8 May 2014 09:02:04 +0000

> From: Neil Horman
> ...
>> Perhaps a solution is a signalling mechanism tied to completion interrupts?
>> I.e. a mapping failure gets reported to the stack, which causes the
>> correspondnig queue to be stopped, until such time a the driver signals a safe
>> restart by the reception of a tx completion interrupt?  I'm actually tinkering
>> right now with a mechanism that provides guidance to the stack as to how many
>> dma descriptors are available in a given net_device that might come in handy
> 
> Is there any mileage in the driver pre-allocating a block of iommu entries
> and then allocating them to the tx and rx buffers itself?
> This might need some 'claw back' mechanism to get 'fair' (ok working)
> allocations when there aren't enough entries for all the drivers.

The idea of preallocation has been explored before, but those efforts
never went very far.

In the case that we're mapping SKBs into the TX or RX ring, there is
little benefit cost wise.  As described much of the cost is installing
the translation, and that can't be done until we have the SKB itself.

Would it help with resource exhaustion?  I'm not so sure, because I'd
rather have everything that isn't currently in use available to those
entities that have an immediate need rather than holding onto space
"just in case".

> I remember some old systems where the cost of setting up the iommu
> entries was such that the breakeven point for copying data was
> measured as about 1k bytes. I've no idea what it is for these systems.

There are usually two costs associated with that, the first is the
spinlock that protects the iommu allocation data structures, the
second is programming the IOMMU hardware to flush the I/O TLB when
mappings change.

There isn't much you can do about the spinlock, but for the other
problem I experimented and implemented a scheme where the allocations
are done sequentially and therefore the I/O TLB flush only happens
once each time we wrap around thus mitigating that code.

See arch/sparc/kernel/iommu.c:iommu_range_alloc()

Unfortunately, on newer sparc64 systems the IOMMU PTE updates are done
with hypervisor calls of which I have no control over and they
unconditionally do an IOMMU TLB flush, and therefore this mitigation
trick is no longer possible.

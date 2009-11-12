From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [net-next-2.6 PATCH 2/3] ixgbe: Set MSI-X vectors to
 NOBALANCING and set affinity
Date: Thu, 12 Nov 2009 11:12:22 -0800
Message-ID: <F86E8680A7D9D74A99DC6345E35A69293E3D4171@orsmsx503.amr.corp.intel.com>
References: <20091021022626.32449.73883.stgit@localhost.localdomain>
	<20091021022713.32449.54868.stgit@localhost.localdomain>
 <20091021.215031.57955781.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "gospo@redhat.com" <gospo@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:14176 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752570AbZKLTMR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 14:12:17 -0500
In-Reply-To: <20091021.215031.57955781.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>Date: Tue, 20 Oct 2009 19:27:14 -0700
>
>> From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
>>
>> This patch will set each MSI-X vector to IRQF_NOBALANCING to
>> prevent autobalance of the interrupts, then applies a CPU
>> affinity.  This will only be done when Flow Director is enabled,
>> which needs interrupts to be processed on the same CPUs where the
>> applications are running.
>>
>> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
>Just explain to me why irqbalanced in userspace cannot take care
>of this issue.
>
>Second, even if we cannot use irqbalanced for some reason, the last
>thing I want to see is drivers directly fiddling with interrupt
>states and attributes.  Every driver is going to do it every so
>slightly differently, and often will get it wrong.

Jesse Brandeburg and I talked with Arjan yesterday regarding these patches.  We all agreed the drivers need some mechanism to help irqbalance make smarter decisions when enforcing its balancing policies.  Arjan did convince me though that enforcing the interrupt's policy from the driver isn't the right thing to do (which echoes your stance too :-) ).

The current proposal is to add a new interface to the interrupt management that drivers can specify an allowable CPU mask.  This way a driver can be specific with where interrupt vectors can be balanced, e.g. specify a CPU mask within a NUMA node that a vector can be balanced.  Then irqbalance can make the right decisions based on cache locality of CPU cores; as long as we land on the correct NUMA node with the interrupt, we should be fine.  This new interface can also be used in the PCI space to assist setting the correct NUMA mask for a driver on load, further streamlining the NUMA affinity of a device.

This change will also require an update to irqbalance to comprehend the new mask.  This should be fairly trivial.

We also discussed the need for irqbalance to distinguish between Rx and Tx queue vectors.  Right now, irqbalance can identify an interrupt belong to an Ethernet device, but it stops there.  It needs to also distinguish the directional vectors, and make sure to balance the right queue vector with its paired queue (i.e. make sure Tx queue 0's vector lines up with Rx queue 0's vector).

I'll be getting patches together for this interface, and will push them separately.  In the meantime, I'll repush the one patch from this patch series to pair the Rx and Tx queues onto a shared vector.  That is an independent patch from this whole series, so it should be fine to apply regardless of the interrupt affinity changes.

Cheers,
-PJ Waskiewicz

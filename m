From: "Tadepalli, Hari K" <hari.k.tadepalli@intel.com>
Subject: RE: [RFC] Setting processor affinity for network queues
Date: Mon, 1 Mar 2010 10:43:15 -0700
Message-ID: <41885A88D9043444B138491FB10E15420476F1ED89@azsmsx506.amr.corp.intel.com>
References: <1267464102.2092.136.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:56926 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750976Ab0CARnU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Mar 2010 12:43:20 -0500
In-Reply-To: <1267464102.2092.136.camel@achroite.uk.solarflarecom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Ben Hutchings
>> Sent: Monday, March 01, 2010 10:22 AM
>> To: netdev
>> Cc: Waskiewicz Jr, Peter P; Peter Zijlstra; Thomas Gleixner; Tom Herbert; Stephen Hemminger; sf-linux-drivers
>> Subject: [RFC] Setting processor affinity for network queues
>>
>> Currently we have a userspace interface for setting affinity of IRQs and
>> a convention for naming each channel's IRQ handler, but no such
>> interface for memory allocation.  For RX buffers this should not be a
>> problem since they are normally allocated as older buffers are
>> completed, in the NAPI context.  However, the DMA descriptor rings and
>> driver structures for a channel should also be allocated on the NUMA
>> node where NAPI processing is done.  Currently this allocation takes
>> place when a net device is created or when it is opened, before an
>> administrator has any opportunity to configure affinity.  Reallocation
>> will normally require a complete stop to network traffic (at least on
>> the affected queues) so it should not be done automatically when the
>> driver detects a change in IRQ affinity
y.  There needs to be an explicit
>> mechanism for changing it.

I have sought clarifications on this issue 2 weeks ago in the context of IxGbE: 
http://marc.info/?l=linux-netdev&m=126638089307398&w=2

>> (i) tx_ring, rx_ring control structures of tx/rx rings:
>>	 tx_ring->tx_buffer_info = vmalloc_node(size, tx_ring->numa_node);
>> 
>> (ii) descriptor rings in the DMA region: tx_ring->dma, rx_ring->dma
>>	  tx_ring->desc = pci_alloc_consistent(pdev, tx_ring->size, &tx_ring->dma);
>> 
>> (iii) packet buffers:
>>	   struct sk_buff *skb = netdev_alloc_skb(adapter->netdev,bufsz);

The above memory allocation calls (sparing vmalloc_node()) conventionally used in a network driver allow for node awareness only at the physical device (pdev) level, where queues in a device do not have independent node-status. This is a serious setback to the benefits expected of recent developments for high throughput networking: RSS, 10/40GbE, NUMA & many cores on an SBC (single board computer or server). Cross node traffic, even in small proportions, is a retard on performance in the million packets/sec range. 

I have hacked into some of the above, by using alloc_pages_node() & setting node_id explicitly when allocating for specific queues. But, look forward to a clean, 'hack-free' solution. 

Thanks, 

- Hari
__________________________________________
Embeedded Communications Group
Intel/ IAG, Chandler, AZ

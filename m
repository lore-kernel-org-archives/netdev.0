From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [RFC 2/2] shrink size of scatterlist on common i386/x86-64
Date: Fri, 6 Jul 2007 10:14:56 -0700
Message-ID: <08FE5CC30C9A3F41BF819A502CF7BF6E0198249D@fmsmsx411.amr.corp.intel.com>
References: <20070705.171535.105173068.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>,
	<shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58291 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753747AbXGFRPG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2007 13:15:06 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070705.171535.105173068.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
>> Okay, but then using SG lists makes skbuff's much bigger.
>>     
>> 	fraglist	scatterlist		   per skbuff
>> 32 bit	8		20		+12 * 18 = +216!
>> 64 bit	16		32		+16 * 18 = +288
>> 
>> So never mind...
>
>I know, this is why nobody ever really tries to tackle this.
>
>> I'll do a fraglist to scatter list set of routines, but not sure
>> if it's worth it.
>
>It's better to add dma_map_skb() et al. interfaces to be honest.
>
>Also even with the scatterlist idea, we'd still need to do two
>map calls, one for skb->data and one for the page vector.

FWIW, I tried this about a year ago to try to improve e1000 performance
on pSeries.  I was hoping to simplify the driver transmit code and make
IOMMU mapping easier.  This was on 2.6.16 or thereabouts.

Net result:  zilch.  No performance increase, no noticeable CPU
utilization
benefits.  Nothing.  So I dropped it.

Slightly off topic:
The real problem that I saw on pSeries is lock contention for the IOMMU.
It's architected with a single table per slot, which is great in that
two boards in separate slots won't have lock contention.  However, this
all goes out the window when you drop a quad-port gigabit adapter in
there.
The time spent waiting for the IOMMU table lock goes up exponentially
as you activate each additional port.

In my opinion, IOMMU table locking is the major issue with this type of
architecture.  Since both Intel and AMD are touting IOMMUs for virtual-
ization support, this is an issue that's going to need a lot of
scrutiny.

-Mitch

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/13] net: mvneta: implement rx_copybreak
Date: Thu, 16 Jan 2014 11:49:05 -0800 (PST)
Message-ID: <20140116.114905.1582218754259744747.davem@davemloft.net>
References: <1389856819-6503-12-git-send-email-w@1wt.eu>
	<063D6719AE5E284EB5DD2968C1650D6D45D866@AcuExch.aculab.com>
	<20140116093640.GA16457@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, netdev@vger.kernel.org,
	thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53466 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750946AbaAPTtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 14:49:06 -0500
In-Reply-To: <20140116093640.GA16457@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Thu, 16 Jan 2014 10:36:40 +0100

> On Thu, Jan 16, 2014 at 09:14:00AM +0000, David Laight wrote:
>> From: Of Willy Tarreau
>> > calling dma_map_single()/dma_unmap_single() is quite expensive compared
>> > to copying a small packet. So let's copy short frames and keep the buffers
>> > mapped. We set the limit to 256 bytes which seems to give good results both
>> > on the XP-GP board and on the AX3/4.
>> 
>> Have you tried something similar for transmits?
>> Copying short tx into a preallocated memory area that is dma_mapped
>> at driver initialisation?
> 
> Not yet by lack of time, but I intend to do so. Both the NIC and the driver
> are capable of running at line rate (1.488 Mpps) when filling descriptors
> directly, so many improvements are still possible.

I don't know if this is relevant for your hardware, but there is a trick
with IOMMUs that I at least at one point was doing on sparc64.

I never flushed the IOMMU mappings explicitly on a dma_unmap call.

Instead I always allocate by moving the allocation cursor to higher
addresses in the IOMMU range looking for free space.

Then when I hit the end of the range and had to wrap the allocation
cursor back to the beginning, I flush the entire IOMMU.

So for %99 of IOMMU mapping creation and teardown calls, I didn't even
touch the hardware.

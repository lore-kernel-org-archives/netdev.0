From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 10790] New: driver "sunhme" experiences
 corrupt packets if machine has more than 2GB of memory
Date: Wed, 04 Jun 2008 11:33:17 -0700 (PDT)
Message-ID: <20080604.113317.213189757.davem@davemloft.net>
References: <20080525114548.6ad40fd7.akpm@linux-foundation.org>
	<20080603.163317.148261530.davem@davemloft.net>
	<20080604082121.GA23128@pingi.kke.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, f0h3a-kernel@yahoo.com
To: kkeil@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33370
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759051AbYFDSdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 14:33:18 -0400
In-Reply-To: <20080604082121.GA23128@pingi.kke.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <kkeil@suse.de>
Date: Wed, 4 Jun 2008 10:21:21 +0200

> Yes it is x86_64 and I think, that if you put more as 2G in this machine,
> some physical addresses are behind the 4 GB border.

If that is the case then I think there might be some bug in the
dma_sync_single_for_cpu() implementation on whatever IOMMU
implementation is being used on this x86_64 system.

sunhme has two cases:

1) If the packet is greater than 256 bytes the original packet
   is unmapped.  So, if soft-iommu uses a bounce buffer,
   for example, this should do the necessary copy from
   the bounce buffer to the actual SKB data area.

2) If the packet is less than or equal to 256 bytes, the
   packet is DMA sync'd using pci_dma_sync_single_for_cpu(),
   which should cause soft-iommu or similar to copy from any
   bounce buffer to the real buffer, and then we copy the
   SKB data into a new freshly allocated SKB and reuse the original
   one after calling pci_dma_sync_single_for_device().

I've validated that the DMA address and lengths used by those
calls in the sunmhe driver are correct, so really my top suspect
would be the IOMMU implementation being used on this system for
these specific kinds of cases.

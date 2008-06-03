From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 10790] New: driver "sunhme" experiences
 corrupt packets if machine has more than 2GB of memory
Date: Tue, 03 Jun 2008 16:33:17 -0700 (PDT)
Message-ID: <20080603.163317.148261530.davem@davemloft.net>
References: <bug-10790-10286@http.bugzilla.kernel.org/>
	<20080525114548.6ad40fd7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	f0h3a-kernel@yahoo.com, kkeil@suse.de
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53422
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752079AbYFCXdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 19:33:18 -0400
In-Reply-To: <20080525114548.6ad40fd7.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Sun, 25 May 2008 11:45:48 -0700

> Note that this patch from Karsten:
> https://bugzilla.novell.com/attachment.cgi?id=217968 did not work.

That patch is unlikely to be the issue, right.

> Stoopid question: if it fails at 2GB, should we try DMA_31BIT_MASK?

I've scoured all of the docs and the chip itself and the PCI front-end
it is connected to support full 32-bit PCI addressing.

The bug report says platform "All" but the report specifically
mentions Q6600 cpus, is this x86_64 by chance?  I wonder if the
problem is that we use GFP_ATOMIC/GFP_KERNEL for allocations
of SKB data, and we end up with buffers above 4GB but the IOMMU
mapping operation doesn't cope with that correctly.

In the arch/x86/kernel/pci-nommu.c case, this would result in
kernel log messages from check_addr():

		if (*hwdev->dma_mask >= DMA_32BIT_MASK)
			printk(KERN_ERR
			    "nommu_%s: overflow %Lx+%zu of device mask %Lx\n",
				name, (long long)bus, size,
				(long long)*hwdev->dma_mask);

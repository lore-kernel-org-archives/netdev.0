From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] skge: Fix/workaround for DMA mask quirk on ASUS
 P5NSLI/Marvell Yukon-Lite
Date: Tue, 10 Feb 2009 11:14:08 -0800
Message-ID: <20090210111408.2225e90b@extreme>
References: <f1a0791a0902101056i6fd47886gc3cee4b5aff2a23e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phillip Michael Jordan <phil@philjordan.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55840 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756769AbZBJTOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 14:14:18 -0500
In-Reply-To: <f1a0791a0902101056i6fd47886gc3cee4b5aff2a23e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Feb 2009 19:56:53 +0100
Phillip Michael Jordan <phil@philjordan.eu> wrote:

> From: Phillip Michael Jordan <phil@philjordan.eu>
> 
> The onboard Marvell Yukon-Lite gigabit ethernet chip on my ASUS P5NSLI
> motherboard with the nForce570 SLI/Intel chipset (any BIOS version,
> including latest), using the skge module, stopped working after
> upgrading the system to more than 3GB of physical RAM. The problem has
> been around for a while, at least since 2.6.22. Symptoms on earlier
> kernels (at least up to 2.6.27) are severely corrupted ethernet
> packets (observed via wireshark) and associated IP packet loss and
> eventual failure of any packets being delivered at all. As of
> 2.6.29-rc4, the kernel panics about 1-2 seconds after insmod with 8GB
> memory installed, as far as I can tell this is due to memory
> corruption.
> 
> I have now traced this problem to DMA to/from memory above the 32-bit
> boundary, which despite the pci_set_dma_mask() and
> pci_set_consistent_dma_mask() calls in skge_probe() apparently
> succeeding with a DMA_64BIT_MASK. Switching to a DMA_32BIT_MASK makes
> the problem disappear entirely, so this patch against 2.6.29-rc4 does
> just that for the affected system by identifying the board via DMI
> data and ethernet chip via vendor/product ID. I've tried to make it as
> unintrusive as possible, and attempted to make it easy to add other
> devices that behave similarly in the future. Nothing changes for
> devices not on the blacklist. (admittedly unable to verify due to lack
> of other skge hardware)
> 
> Searching the web, others have had similar problems, though not on the
> same specific motherboard. Passing iommu=force to the kernel seems to
> work in some of these previous cases. In my case, this just breaks a
> number of other PCI(e) devices, including all of USB, video, etc. -
> and skge still doesn't work. I can therefore only conclude that there
> is a bug in either the chipset or the BIOS.
> 
> Signed-off-by: Phillip Michael Jordan <phil@philjordan.eu>
> 

This looks like a good start to a workable workaround.

I wonder if other PCI devices in same system have the same problem?
If so, it should be move to PCI quirk. 
Also, since the problem is almost certainly in the PCI bridge to
skge connection, the quirk should identify based on the upstream bridge,
rather than the Marvell chip and DMI.



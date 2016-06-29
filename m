From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] [v6] net: emac: emac gigabit ethernet controller driver
Date: Wed, 29 Jun 2016 21:45:37 +0200
Message-ID: <11472258.9SNjZdPb6l@wuerfel>
References: <1466812008-26686-1-git-send-email-timur@codeaurora.org> <3914163.aNiIdzedWT@wuerfel> <5773ED4F.4050401@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	shankerd@codeaurora.org, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org, robh+dt@kernel.org,
	andrew@lunn.ch, bjorn.andersson@linaro.org, mlangsdo@redhat.com,
	jcm@redhat.com, agross@codeaurora.org, davem@davemloft.net,
	f.fainelli@gmail.com, catalin.marinas@arm.com
To: Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:62083 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752432AbcF2TuJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 15:50:09 -0400
In-Reply-To: <5773ED4F.4050401@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, June 29, 2016 10:46:23 AM CEST Timur Tabi wrote:
> Arnd Bergmann wrote:
> > Usually drivers try 64-bit mask and 32-bit masks, and the 32 bit
> > mask is practically guaranteed to succeed.
> 
> Sure, but in theory, my for-loop is correct, right?  Wouldn't there be 
> some value in setting a 36-bit or 40-bit DMA mask if it works?  We have 
> a platform where memory starts at a 40-bit address, so some devices have 
> a 44-bit address bus.  If a 64-bit mask doesn't work, then a 32-bit mask 
> certainly wont.

The question is whether it makes any difference to the driver: what decision
does the driver make differently if it has set a 44-bit mask?

We don't have ZONE_DMA44 (and it's very unlikely that we will introduce
it), so neither the driver nor the network stack can actually act on the
fact that a 64-bit mask failed but a 44-bit mask succeeded.

> > Platforms will also allow allow the driver to set a mask that
> > is larger than what the bus supports, as long as all RAM is
> > reachable by the bus.
> 
> And that check (like all others) is made in the dma_set_mask call?

Yes. Regarding the system you mentioned: I understand that it has
no memory in ZONE_DMA32 and no IOMMU (btw, that also means 32-bit
PCI devices are fundamentally broken), and the bus can only address
the lower 44 bit of address space.

Does this system support more than 15TB of RAM? If not, then there
is no problem, and if it  does, I think your best way out is not
to disable SWIOTLB. That will be a slower compared to a system
with an IOMMU or the fictional ZONE_DMA44, but it should work
correctly. In either case (less than 15TB without swiotlb, or
more than 15TB with swiotlb), the driver should just ask for
a 64-bit mask and that will succeed.

	Arnd

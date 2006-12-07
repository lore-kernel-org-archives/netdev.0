From: David Miller <davem@davemloft.net>
Subject: Re: network devices don't handle pci_dma_mapping_error()'s
Date: Wed, 06 Dec 2006 16:54:18 -0800 (PST)
Message-ID: <20061206.165418.54722201.davem@davemloft.net>
References: <20061204103949.3d05b1ff@freekitty>
	<20061205070045.GE3619@rhun.ibm.com>
	<20061206101644.27eeaf14@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: muli@il.ibm.com, jeff@garzik.org, amitkale@netxen.com,
	netdev@vger.kernel.org, brazilnut@us.ibm.com,
	netxenproj@linsyssoft.com, rob@netxen.com, romieu@fr.zoreil.com,
	sanjeev@netxen.com, wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44812
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S937867AbWLGAyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 19:54:08 -0500
To: shemminger@osdl.org
In-Reply-To: <20061206101644.27eeaf14@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Wed, 6 Dec 2006 10:16:44 -0800

> I think it is really only an issue for drivers that turn on HIGH_DMA
> and have limited mask values. The majority of drivers either only handle
> 32 bit (!HIGH_DMA) or do full 64 bit mapping. I don't know the details
> of how we manage IOMMU, but doesn't mapping always work for those drivers.
> 
> That just leaves devices with odd size mask values that need to be
> handle mapping errors.

Not true.

On platforms such as sparc64 the IOMMU is used for all DMA mappings,
no matter what, because only IOMMU based mappings can do prefetching
and write-combining in the PCI controller.

The problem with just silently dropping packets that can't get DMA
mapped is that you're going to drop a very large sequence of these
while the IOMMU is out of space, and that to me looks like a bad
quality of implementation decision.

The IOMMU layer really needs a way to callback the driver to tell it
when space is available, or something similar.

FWIW, Solaris handles this by blocking when the IOMMU is out of space
since under Solaris even interrupt contexts can block (via interrupt
threads).

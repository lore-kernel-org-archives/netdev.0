From: Prashant Sreedharan <prashant@broadcom.com>
Subject: Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]
Date: Thu, 16 Apr 2015 15:51:34 -0700
Message-ID: <1429224694.4720.68.camel@prashant>
References: <21798.24161.922394.539733@mariner.uk.xensource.com>
	 <1428595851.4720.22.camel@prashant>
	 <21798.44949.156680.399387@mariner.uk.xensource.com>
	 <21798.46590.928152.666550@mariner.uk.xensource.com>
	 <1428602883.4720.31.camel@prashant>
	 <21799.59138.666831.970946@mariner.uk.xensource.com>
	 <5528D4F0.6060203@broadcom.com>
	 <21806.17257.971957.13215@mariner.uk.xensource.com>
	 <552F241C.4080002@broadcom.com>
	 <21807.35967.660396.209954@mariner.uk.xensource.com>
	 <20150416122420.GA4051@oc0812247204.ltc.br.ibm.com>
	 <1429202353.6668.5.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <21807.60995.462892.714138@mariner.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>, <cascardo@linux.vnet.ibm.com>,
	"Konrad Rzeszutek Wilk" <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	"Vlad Yasevich" <vyasevich@gmail.com>,
	<xen-devel@lists.xensource.com>, <netdev@vger.kernel.org>,
	"Siva Reddy (Siva) Kallam" <siva.kallam@broadcom.com>,
	Sanjeev Bansal <sanjeevb@broadcom.com>
To: Ian Jackson <Ian.Jackson@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:43273 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426AbbDPXPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 19:15:38 -0400
In-Reply-To: <21807.60995.462892.714138@mariner.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-16 at 18:15 +0100, Ian Jackson wrote:
> Michael Chan writes ("Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]"):
> > On Thu, 2015-04-16 at 09:24 -0300, cascardo@linux.vnet.ibm.com wrote: 
> > > Yes, this looks like the driver is not syncing the DMA buffers. Unmap is
> > > supposed to synchronize as well.
> > 
> > For small rx packets (< 256 bytes), we sync the DMA buffer before we
> > copy the data to another SKB.  For larger packets, we unmap the DMA
> > buffer.  Do we see the corruption in both cases?
> 
> Yes, at least with swiotlb=force iommu=soft.

Ok this is what is causing the problem, the driver uses
DEFINE_DMA_UNMAP_ADDR(), dma_unmap_addr_set() to keep a copy of the dma
"mapping" and dma_unmap_addr() to get the "mapping" value. On most of
the platforms this is a no-op, but it appears with "iommu=soft and
swiotlb=force" this house keeping is required, when I pass the correct
dma_addr instead of 0 while calling pci_unmap_/pci_dma_sync_ I don't see
the corruption. ie If you set CONFIG_NEED_DMA_MAP_STATE=y in your kernel
config you should not see the problem. Can you confirm ? Thanks

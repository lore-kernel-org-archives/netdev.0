From: Ian Jackson <Ian.Jackson@eu.citrix.com>
Subject: Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]
Date: Fri, 17 Apr 2015 17:29:28 +0100
Message-ID: <21809.13544.303033.990277@mariner.uk.xensource.com>
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
	<1429224694.4720.68.camel@prashant>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>, <cascardo@linux.vnet.ibm.com>,
	"Konrad Rzeszutek Wilk" <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	"Vlad Yasevich" <vyasevich@gmail.com>,
	<xen-devel@lists.xensource.com>, <netdev@vger.kernel.org>,
	"Siva Reddy (Siva) Kallam" <siva.kallam@broadcom.com>,
	Sanjeev Bansal <sanjeevb@broadcom.com>
To: Prashant Sreedharan <prashant@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:23201 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932935AbbDQQ3d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Apr 2015 12:29:33 -0400
In-Reply-To: <1429224694.4720.68.camel@prashant>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prashant Sreedharan writes ("Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]"):
> Ok this is what is causing the problem, the driver uses
> DEFINE_DMA_UNMAP_ADDR(), dma_unmap_addr_set() to keep a copy of the dma
> "mapping" and dma_unmap_addr() to get the "mapping" value. On most of
> the platforms this is a no-op, but it appears with "iommu=soft and
> swiotlb=force" this house keeping is required, when I pass the correct
> dma_addr instead of 0 while calling pci_unmap_/pci_dma_sync_ I don't see
> the corruption. ie If you set CONFIG_NEED_DMA_MAP_STATE=y in your kernel
> config you should not see the problem. Can you confirm ? Thanks

That kernel config option is an automatically computed one:

config NEED_DMA_MAP_STATE
        def_bool y
        depends on X86_64 || INTEL_IOMMU || DMA_API_DEBUG

and grepping my .config shows:

# CONFIG_INTEL_IOMMU is not set
# CONFIG_DMA_API_DEBUG is not set

It's a 32-bit kernel so it hasn't got X86_64 enabled either.

Arguably at least some of osstest's kernels should have INTEL_IOMMU
enabled to detect conflicts between Xen's use of the iommu and
possible attempts bo Linux to do the same thing, but not having it
enabled should not cause a driver bug.

Ian.

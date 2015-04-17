From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]
Date: Fri, 17 Apr 2015 15:04:48 -0400
Message-ID: <20150417190448.GA9462@l.oracle.com>
References: <21807.60995.462892.714138@mariner.uk.xensource.com>
 <1429224694.4720.68.camel@prashant>
 <21809.13544.303033.990277@mariner.uk.xensource.com>
 <20150417.131956.2235150293184897656.davem@davemloft.net>
 <1429292769.6668.7.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Ian.Jackson@eu.citrix.com,
	prashant@broadcom.com, cascardo@linux.vnet.ibm.com,
	boris.ostrovsky@oracle.com, david.vrabel@citrix.com,
	vyasevich@gmail.com, xen-devel@lists.xensource.com,
	netdev@vger.kernel.org, siva.kallam@broadcom.com,
	sanjeevb@broadcom.com
To: Michael Chan <mchan@broadcom.com>, tglx@linutronix.de,
	mingo@redhat.com, hpa@zytor.com, x86@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30940 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751652AbbDQTFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2015 15:05:16 -0400
Content-Disposition: inline
In-Reply-To: <1429292769.6668.7.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 17, 2015 at 10:46:09AM -0700, Michael Chan wrote:
> On Fri, 2015-04-17 at 13:19 -0400, David Miller wrote:
> > So the gist of the situation is, that NEED_DMA_MAP_STATE can be 'n' in
> > situations where we might actually need it to be 'y' based upon kernel
> > comman line boot options given.
> > 
> > Right?
> 
> Yes.

Would this work ?

Peter, Ingo, Thomas, pls see Prashant's thread:

http://www.spinics.net/lists/netdev/msg325645.html
http://www.spinics.net/lists/netdev/msg325774.html

Thank you.

>From 9e417af099e3cee2b219ab28ffc1e96b0564b213 Mon Sep 17 00:00:00 2001
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Date: Fri, 17 Apr 2015 14:55:47 -0400
Subject: [PATCH] config: Enable NEED_DMA_MAP_STATE when SWIOTLB is selected

A huge amount of NIC drivers use the DMA API, however if compiled
under 32-bit an very important part of the DMA API can be ommitted leading
to the drivers not working at all (especially if used with
'swiotlb=force iommu=soft').

As Prashant Sreedharan explains it: "the driver [tg3] uses
DEFINE_DMA_UNMAP_ADDR(), dma_unmap_addr_set() to keep a copy of the dma
"mapping" and dma_unmap_addr() to get the "mapping" value. On most of
the platforms this is a no-op, but ... with "iommu=soft and
swiotlb=force" this house keeping is required, ... otherwise
we pass 0 while calling pci_unmap_/pci_dma_sync_ instead of the
DMA address."

As such enable this even when using 32-bit kernels.

Reported-by: Ian Jackson <Ian.Jackson@eu.citrix.com>
Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 arch/x86/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index b7d31ca..570c71d 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -177,7 +177,7 @@ config SBUS
 
 config NEED_DMA_MAP_STATE
 	def_bool y
-	depends on X86_64 || INTEL_IOMMU || DMA_API_DEBUG
+	depends on X86_64 || INTEL_IOMMU || DMA_API_DEBUG || SWIOTLB
 
 config NEED_SG_DMA_LENGTH
 	def_bool y
-- 
2.1.0

> > 
> > 
> 

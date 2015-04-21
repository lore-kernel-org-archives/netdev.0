From: Ian Jackson <Ian.Jackson@eu.citrix.com>
Subject: Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]
Date: Tue, 21 Apr 2015 16:05:11 +0100
Message-ID: <21814.26407.914735.236087@mariner.uk.xensource.com>
References: <20150417.131956.2235150293184897656.davem@davemloft.net>
	<1429292769.6668.7.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<20150417190448.GA9462@l.oracle.com>
	<20150417.151208.1757850423694976996.davem@davemloft.net>
	<1429296772.4720.70.camel@prashant>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Prashant Sreedharan <prashant@broadcom.com>,
	<mchan@broadcom.com>, <tglx@linutronix.de>, <mingo@redhat.com>,
	<hpa@zytor.com>, <x86@kernel.org>, <cascardo@linux.vnet.ibm.com>,
	<boris.ostrovsky@oracle.com>, <david.vrabel@citrix.com>,
	<vyasevich@gmail.com>, <xen-devel@lists.xensource.com>,
	<netdev@vger.kernel.org>, <siva.kallam@broadcom.com>,
	<sanjeevb@broadcom.com>
To: <konrad.wilk@oracle.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:19798 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606AbbDUPHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 11:07:53 -0400
In-Reply-To: <1429296772.4720.70.camel@prashant>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prashant Sreedharan writes ("Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]"):
> On Fri, 2015-04-17 at 15:12 -0400, David Miller wrote:
> > From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> > Date: Fri, 17 Apr 2015 15:04:48 -0400
> > > A huge amount of NIC drivers use the DMA API, however if
> > > compiled under 32-bit an very important part of the DMA API can
> > > be ommitted leading to the drivers not working at all
> > > (especially if used with 'swiotlb=force iommu=soft').
...
> > > As such enable this even when using 32-bit kernels.
> > > 
> > > Reported-by: Ian Jackson <Ian.Jackson@eu.citrix.com>
> > > Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Thanks.

Tested-by: Ian Jackson <ian.jackson@eu.citrix.com>

I'd appreciate it if this patch could make its way into the 3.14.y
stable branch, as well as all the other places it's applicable of
course.  I've included another copy below for convenience, with
acks etc. from this email thread folded in.

I have tested 3.14.34 plus just this patch, with my usual kernel
configuration input and the affected machine, and this fixes the
problem completely AFAICT.

I have tested both baremetal 32-bit with `iommu=soft swiotlb=force'
(which previously corrupted all received network packets) and 32-bit
Linux under 64-bit Xen without any special options (which previously
gave 25-30% packet loss).

Thanks,
Ian.

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
Acked-by: David S. Miller <davem@davemloft.net>
Acked-by: Prashant Sreedharan <prashant@broadcom.com>
Tested-by: Ian Jackson <ian.jackson@eu.citrix.com>
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

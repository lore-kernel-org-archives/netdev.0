From: Ian Jackson <Ian.Jackson@eu.citrix.com>
Subject: Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]
Date: Thu, 16 Apr 2015 11:18:39 +0100
Message-ID: <21807.35967.660396.209954@mariner.uk.xensource.com>
References: <21795.62414.465476.464027@mariner.uk.xensource.com>
	<1428425741.4212.1.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<21796.6843.983774.271495@mariner.uk.xensource.com>
	<21796.7755.270785.292996@mariner.uk.xensource.com>
	<1428448869.4212.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<1428448976.4720.15.camel@prashant>
	<21797.13348.524963.29127@mariner.uk.xensource.com>
	<1428543798.4720.20.camel@prashant>
	<21798.24161.922394.539733@mariner.uk.xensource.com>
	<1428595851.4720.22.camel@prashant>
	<21798.44949.156680.399387@mariner.uk.xensource.com>
	<21798.46590.928152.666550@mariner.uk.xensource.com>
	<1428602883.4720.31.camel@prashant>
	<21799.59138.666831.970946@mariner.uk.xensource.com>
	<5528D4F0.6060203@broadcom.com>
	<21806.17257.971957.13215@mariner.uk.xensource.com>
	<552F241C.4080002@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	"David Vrabel" <david.vrabel@citrix.com>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	<xen-devel@lists.xensource.com>, <netdev@vger.kernel.org>,
	"Siva Reddy (Siva) Kallam" <siva.kallam@broadcom.com>,
	Sanjeev Bansal <sanjeevb@broadcom.com>
To: Prashant <prashant@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:48491 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753592AbbDPKSo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2015 06:18:44 -0400
In-Reply-To: <552F241C.4080002@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prashant writes ("Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]"):
> Ian, using your config we are able to recreate the problem that you are 
> seeing. The driver finds the RX data buffer to be all zero, with a 
> analyzer trace we are seeing the chip is DMA'ing valid RX data buffer 
> contents to the host but once the driver tries to read this DMA area, it 
> is seeing all zero's which is the reason of the corruption. This is only 
> for the RX data buffer, the RX descriptor and status block update DMA 
> regions are having valid contents.

I am no expert on this area, but this suggests that the driver is
misoperating the Linux DMA management API.  This is what I think
Konrad suspected when he suggested the `iommu=soft swiotlb=force'
command line option.

Note in kernel-parameters.txt:

        swiotlb=        [ARM,IA-64,PPC,MIPS,X86]
                        Format: { <int> | force }
                        <int> -- Number of I/O TLB slabs
                        force -- force using of bounce buffers even if they
                                 wouldn't be automatically used by the kernel

So with `swiotlb=force' the DMA is _expected_ to go to a bounce buffer
managed by the kernel DMA API.

> This is unlikely to be a chip or driver issue, as the chip is doing the 
> correct DMA but the corruption occurs before driver reads it. Would 
> request iommu experts to take a look and suggest what can be done next.

As I say above I think this is probably a driver bug.

I have seen identical symptoms on a >5yo desktop box under my desk and
on two brand new rackmount servers; I therefore doubt that it's a
hardware problem.

Ian.

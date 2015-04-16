From: cascardo@linux.vnet.ibm.com
Subject: Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]
Date: Thu, 16 Apr 2015 09:24:21 -0300
Message-ID: <20150416122420.GA4051@oc0812247204.ltc.br.ibm.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Prashant <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	"Siva Reddy (Siva) Kallam" <siva.kallam@broadcom.com>,
	Sanjeev Bansal <sanjeevb@broadcom.com>
To: Ian Jackson <Ian.Jackson@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp05.br.ibm.com ([32.104.18.26]:35838 "EHLO
	e24smtp05.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752367AbbDPMYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 08:24:40 -0400
Received: from /spool/local
	by e24smtp05.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Thu, 16 Apr 2015 09:24:36 -0300
Received: from d24relay03.br.ibm.com (d24relay03.br.ibm.com [9.13.184.25])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id D65DA1DC006D
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2015 08:23:35 -0400 (EDT)
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by d24relay03.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3GCNdUU60227662
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2015 09:23:39 -0300
Received: from d24av04.br.ibm.com (localhost [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3GCOVv4010061
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2015 09:24:32 -0300
Content-Disposition: inline
In-Reply-To: <21807.35967.660396.209954@mariner.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 16, 2015 at 11:18:39AM +0100, Ian Jackson wrote:
> Prashant writes ("Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]"):
> > Ian, using your config we are able to recreate the problem that you are 
> > seeing. The driver finds the RX data buffer to be all zero, with a 
> > analyzer trace we are seeing the chip is DMA'ing valid RX data buffer 
> > contents to the host but once the driver tries to read this DMA area, it 
> > is seeing all zero's which is the reason of the corruption. This is only 
> > for the RX data buffer, the RX descriptor and status block update DMA 
> > regions are having valid contents.
> 
> I am no expert on this area, but this suggests that the driver is
> misoperating the Linux DMA management API.  This is what I think
> Konrad suspected when he suggested the `iommu=soft swiotlb=force'
> command line option.
> 
> Note in kernel-parameters.txt:
> 
>         swiotlb=        [ARM,IA-64,PPC,MIPS,X86]
>                         Format: { <int> | force }
>                         <int> -- Number of I/O TLB slabs
>                         force -- force using of bounce buffers even if they
>                                  wouldn't be automatically used by the kernel
> 
> So with `swiotlb=force' the DMA is _expected_ to go to a bounce buffer
> managed by the kernel DMA API.
> 
> > This is unlikely to be a chip or driver issue, as the chip is doing the 
> > correct DMA but the corruption occurs before driver reads it. Would 
> > request iommu experts to take a look and suggest what can be done next.
> 
> As I say above I think this is probably a driver bug.
> 

Yes, this looks like the driver is not syncing the DMA buffers. Unmap is
supposed to synchronize as well.

Prashant, can you point to where in the code you see all zeroes after
checking up the data?

Cascardo.

> I have seen identical symptoms on a >5yo desktop box under my desk and
> on two brand new rackmount servers; I therefore doubt that it's a
> hardware problem.
> 
> Ian.
> 

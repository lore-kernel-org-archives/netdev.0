From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: "swiotlb buffer is full" with 3.13-rc1+ but not 3.4.
Date: Tue, 03 Dec 2013 09:45:59 -0800
Message-ID: <1386092759.2166.85.camel@dabdike.int.hansenpartnership.com>
References: <21144.47873.639231.96901@mariner.uk.xensource.com>
	 <20131130185639.GA13039@pegasus.dumpdata.com>
	 <1385844524.2170.10.camel@dabdike>
	 <20131203173332.GE3734@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Ian Jackson <Ian.Jackson@eu.citrix.com>, netdev@vger.kernel.org,
	Michael Chan <mchan@broadcom.com>, dl-mptfusionlinux@lsi.com,
	linux-scsi@vger.kernel.org, support@lsi.com,
	Sreekanth Reddy <Sreekanth.Reddy@lsi.com>,
	Nagalakshmi Nandigama <Nagalakshmi.Nandigama@lsi.com>,
	xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131203173332.GE3734@phenom.dumpdata.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-12-03 at 12:33 -0500, Konrad Rzeszutek Wilk wrote:
> On Sat, Nov 30, 2013 at 03:48:44PM -0500, James Bottomley wrote:
> > On Sat, 2013-11-30 at 13:56 -0500, Konrad Rzeszutek Wilk wrote:
> > > My theory is that the SWIOTLB is not full - it is just that the request
> > > is for a compound page that is more than 512kB. Please note that
> > > SWIOTLB highest "chunk" of buffer it can deal with is 512kb.
> > > 
> > > And that is of course the question comes out - why would it try to
> > > bounce buffer it. In Xen the answer is simple - the sg chunks cross page
> > > boundaries which means that they are not physically contingous - so we
> > > have to use the bounce buffer. It would be better if the the sg list
> > > provided a large list of 4KB pages instead of compound pages as that
> > > could help in avoiding the bounce buffer.
> > > 
> > > But I digress - this is a theory - I don't know whether the SCSI layer
> > > does any colescing of the sg list - and if so, whether there is any
> > > easy knob to tell it to not do it.
> > 
> > Well, SCSI doesn't, but block does.  It's actually an efficiency thing
> > since most firmware descriptor formats cope with multiple pages and the
> > more descriptors you have for a transaction, the more work the on-board
> > processor on the HBA has to do.  If you have an emulated HBA, like
> > virtio, you could turn off physical coalesing by setting the
> > use_clustering flag to DISABLE_CLUSTERING.  But you can't do that for a
> > real card.  I assume the problem here is that the host is passing the
> > card directly to the guest and the guest clusters based on its idea of
> > guest pages which don't map to contiguous physical pages?
> 
> Kind of. Except that in this case the guest does know that it can't map
> them contingously - and resorts to using the bounce buffer so that it
> can provide a nice chunk of contingous area. This is detected by
> the SWIOTLB layer and also the block layer to discourage coalescing
> there.
> 
> But since SCSI is all about sg list I think it gets tangled up here:
> 
> 537         for_each_sg(sgl, sg, nelems, i) {                                       
> 538                 phys_addr_t paddr = sg_phys(sg);                                
> 539                 dma_addr_t dev_addr = xen_phys_to_bus(paddr);                   
> 540                                                                                 
> 541                 if (swiotlb_force ||                                            
> 542                     !dma_capable(hwdev, dev_addr, sg->length) ||                
> 543                     range_straddles_page_boundary(paddr, sg->length)) {         
> 544                         phys_addr_t map = swiotlb_tbl_map_single(hwdev,         
> 545                                                                  start_dma_addr,
> 546                                                                  sg_phys(sg),   
> 547                                                                  sg->length,    
> 548                                                                  dir);          
> 
> So it is either not capable of reaching that physical address (so DMA
> mask, but I doubt it - this is LSI which can do 64bit).

Right, so no bouncing.

>  Or the pages
> straddle. They can straddle it by well, being offset at odd locations, or
> compound pages.

All modern filesystems have 4k+ block sizes, so no offsets at all.  For
DIO you can get offsets at the beginning and end of the transfer, but
they will be offsets within the page, so the problem can only be
clustering (physical merging).

> But why would they in the first place - and so many of them - considering
> the flow of those printks Ian's is seeing.

Probably because compaction and our allocators are designed to give out
physically contiguous pages, which work their way back into the block
layer in order.  On a lot of I/O workloads, we see 30%+ physical
merging.

> James,
> The SCSI layer wouldn't do any funny business here right - no reording
> of bios? That is all left to the block layer right?

We don't see bios ... they're top of block.  SCSI sees requests but the
block layer does all our request and sg list manipulation for us.

James

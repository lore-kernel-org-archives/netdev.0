From: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Subject: Re: "swiotlb buffer is full" with 3.13-rc1+ but not 3.4.
Date: Sun, 1 Dec 2013 17:06:00 +0000
Message-ID: <alpine.DEB.2.02.1312011659500.3198@kaball.uk.xensource.com>
References: <21144.47873.639231.96901@mariner.uk.xensource.com>  <20131130185639.GA13039@pegasus.dumpdata.com> <1385844524.2170.10.camel@dabdike>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Ian Jackson <Ian.Jackson@eu.citrix.com>,
	<netdev@vger.kernel.org>, Michael Chan <mchan@broadcom.com>,
	<dl-mptfusionlinux@lsi.com>, <linux-scsi@vger.kernel.org>,
	<support@lsi.com>, Sreekanth Reddy <Sreekanth.Reddy@lsi.com>,
	Nagalakshmi Nandigama <Nagalakshmi.Nandigama@lsi.com>,
	<xen-devel@lists.xenproject.org>, <linux-kernel@vger.kernel.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:37125 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751599Ab3LARGT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Dec 2013 12:06:19 -0500
In-Reply-To: <1385844524.2170.10.camel@dabdike>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 30 Nov 2013, James Bottomley wrote:
> On Sat, 2013-11-30 at 13:56 -0500, Konrad Rzeszutek Wilk wrote:
> > My theory is that the SWIOTLB is not full - it is just that the request
> > is for a compound page that is more than 512kB. Please note that
> > SWIOTLB highest "chunk" of buffer it can deal with is 512kb.
> > 
> > And that is of course the question comes out - why would it try to
> > bounce buffer it. In Xen the answer is simple - the sg chunks cross page
> > boundaries which means that they are not physically contingous - so we
> > have to use the bounce buffer. It would be better if the the sg list
> > provided a large list of 4KB pages instead of compound pages as that
> > could help in avoiding the bounce buffer.
> > 
> > But I digress - this is a theory - I don't know whether the SCSI layer
> > does any colescing of the sg list - and if so, whether there is any
> > easy knob to tell it to not do it.
> 
> Well, SCSI doesn't, but block does.  It's actually an efficiency thing
> since most firmware descriptor formats cope with multiple pages and the
> more descriptors you have for a transaction, the more work the on-board
> processor on the HBA has to do.  If you have an emulated HBA, like
> virtio, you could turn off physical coalesing by setting the
> use_clustering flag to DISABLE_CLUSTERING.  But you can't do that for a
> real card.  I assume the problem here is that the host is passing the
> card directly to the guest and the guest clusters based on its idea of
> guest pages which don't map to contiguous physical pages?
> 
> The way you tell how many physically contiguous pages block is willing
> to merge is by looking at /sys/block/<dev>/queue/max_segment_size if
> that's 4k then it won't merge, if it's greater than 4k, then it will.
> 
> I'm not quite sure what to do ... you can't turn of clustering globally
> in the guest because the virtio drivers use it to reduce ring descriptor
> pressure, what you probably want is some way to flag a pass through
> device.

Given that we don't use virtio on Xen, we could actually turn off
clustering globally (if we are running on Xen).

In fact for example BIOVEC_PHYS_MERGEABLE is defined:

+#define BIOVEC_PHYS_MERGEABLE(vec1, vec2)				\
+	(__BIOVEC_PHYS_MERGEABLE(vec1, vec2) &&				\
+	 (!xen_domain() || xen_biovec_phys_mergeable(vec1, vec2)))

so that we can disable it if the two bv_page are not actually physical
contiguous.

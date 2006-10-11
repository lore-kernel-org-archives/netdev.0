From: David Miller <davem@davemloft.net>
Subject: Re: is each frag of a skb always less than 1 page?
Date: Tue, 10 Oct 2006 19:10:37 -0700 (PDT)
Message-ID: <20061010.191037.108807611.davem@davemloft.net>
References: <ba020e9f0610101537m492a957fj982097c8d7f407e0@mail.gmail.com>
	<20061010.154732.110906680.davem@davemloft.net>
	<ba020e9f0610101626rf20ce7bg1c214f91f05fb975@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:28339
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932140AbWJKCKf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 22:10:35 -0400
To: ronghuazhang@gmail.com
In-Reply-To: <ba020e9f0610101626rf20ce7bg1c214f91f05fb975@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ronghua Zhang" <ronghuazhang@gmail.com>
Date: Tue, 10 Oct 2006 16:26:58 -0700

> Thank you for your explanation, David.
> 
> But pci_map_page should work fine if we have multiple contiguous pages
> in one frag that are allocated using alloc_pages, ie:
> 
>   frag->page = alloc_pages(GFP_KERNEL, 2); // get 4 pages
>   frag->page_offset = 0;
>   frag->size = 4 * PAGE_SIZE;
> 
>   dma_addr = pci_map_page(frag->page, frag->page_offset, frag->size, ..);

You should look at the implementation of pci_map_page() on
some interesting architectures such as sparc64 and powerpc
where an IOMMU is used to map the pages into DMA space on the
PCI bus.

Those implementations (rightly) assume only a single page needs
to be mapped.

If you assume that multiple pages would get mapped properly by
such a call, things would fail.  You might even get a PCI Master
ABORT after crossing past the end of the first page in that
multi-page chunk since the IOMMU will not have a DMA translation.


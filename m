From: "Ronghua Zhang" <ronghuazhang@gmail.com>
Subject: Re: is each frag of a skb always less than 1 page?
Date: Tue, 10 Oct 2006 16:26:58 -0700
Message-ID: <ba020e9f0610101626rf20ce7bg1c214f91f05fb975@mail.gmail.com>
References: <ba020e9f0610101537m492a957fj982097c8d7f407e0@mail.gmail.com>
	 <20061010.154732.110906680.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.193]:23219 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1030684AbWJJX07 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 19:26:59 -0400
Received: by nz-out-0102.google.com with SMTP id n1so11375nzf
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2006 16:26:58 -0700 (PDT)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20061010.154732.110906680.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thank you for your explanation, David.

But pci_map_page should work fine if we have multiple contiguous pages
in one frag that are allocated using alloc_pages, ie:

  frag->page = alloc_pages(GFP_KERNEL, 2); // get 4 pages
  frag->page_offset = 0;
  frag->size = 4 * PAGE_SIZE;

  dma_addr = pci_map_page(frag->page, frag->page_offset, frag->size, ..);

The reason I asked this is that I saw the following code in forthdeth drvier:

#define NV_TX2_TSO_MAX_SHIFT) 14
/* add fragments to entries count */
for (i = 0; i < fragments; i++) {
    entries += (skb_shinfo(skb)->frags[i].size >> NV_TX2_TSO_MAX_SHIFT) +
                    ((skb_shinfo(skb)->frags[i].size &
(NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
}

This looks unnecessary if each frag is guaranteed not to span pages.

Ronghua

On 10/10/06, David Miller <davem@davemloft.net> wrote:
> From: "Ronghua Zhang" <ronghuazhang@gmail.com>
> Date: Tue, 10 Oct 2006 15:37:04 -0700
>
> > >From the code of tcp_sendmsg, it seems to me that each frag is at most
> > one page. Is it a guaranteed property or the driver should not assume
> > it? Thanks
>
> This assumption basically already exists everywhere since
> all drivers that create DMA mappings of the frags call
> pci_map_page().
>

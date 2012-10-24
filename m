From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: allow configuration of the size of page in
 __netdev_alloc_frag
Date: Wed, 24 Oct 2012 17:21:08 +0200
Message-ID: <1351092068.6537.107.camel@edumazet-glaptop>
References: <1351078936-14159-1-git-send-email-ian.campbell@citrix.com>
	 <1351081703.6537.99.camel@edumazet-glaptop>
	 <1351084618.18035.27.camel@zakaz.uk.xensource.com>
	 <1351085403.6537.102.camel@edumazet-glaptop>
	 <1351087326.18035.50.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:51472 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933750Ab2JXPVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 11:21:13 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so316051bkc.19
        for <netdev@vger.kernel.org>; Wed, 24 Oct 2012 08:21:12 -0700 (PDT)
In-Reply-To: <1351087326.18035.50.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-24 at 15:02 +0100, Ian Campbell wrote:
> On Wed, 2012-10-24 at 14:30 +0100, Eric Dumazet wrote:
> > It seems to me its a driver issue, for example
> > drivers/net/xen-netfront.c has assumptions that can be easily fixed.
> 
> The netfront ->head thing is a separate (although perhaps related)
> issue, I intended to fix along the same lines as the previous netback
> except for some unfathomable reason I haven't been able to reproduce the
> problem with netfront -- I've no idea why though since it seems like it
> should be a no brainer!
> 
> > Why skb->head can be on order-1 or order-2 pages and this is working ?
> 
> skb->head being order 1 or 2 isn't working for me. The driver I'm having
> issues with which caused me to create this particular patch is the tg3
> driver (although I don't think this is by any means specific to tg3).
> 
> For the ->head the tg3 driver does:
>         mapping = pci_map_single(tp->pdev, skb->data, len, PCI_DMA_TODEVICE);
> while for the frags it does:
>         mapping = skb_frag_dma_map(&tp->pdev->dev, frag, 0, len, DMA_TO_DEVICE);
> 
> This ought to do the Right Thing but doesn't seem to be working. Konrad
> suspected an issue with the swiotlb's handling of order>0 pages in some
> cases. As I said in the commit message he is looking into this issue.
> 
> My concern however was that even once the swiotlb is fixed to work right
> the effect of pci_map_single on a order>0 page is going to be that the
> data gets bounced into contiguous memory -- that is a memcpy which would
> undo the benefit of having allocating large pages to start with. So I
> figured that in such cases we'd be better off just using order 0
> allocations to start with.

I am really confused.

If you really have such problems, why locally generated TCP traffic
doesnt also have it ?

Your patch doesnt touch sk_page_frag_refill(), does it ?

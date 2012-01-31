From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] [RFC PATCH V3 15/16] netfront: multi page ring
 support.
Date: Tue, 31 Jan 2012 09:12:22 +0000
Message-ID: <1328001142.26983.289.camel@zakaz.uk.xensource.com>
References: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
	 <1327934734-8908-16-git-send-email-wei.liu2@citrix.com>
	 <20120130213926.GB16261@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Wei Liu (Intern)" <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:43675 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751987Ab2AaJMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 04:12:24 -0500
In-Reply-To: <20120130213926.GB16261@phenom.dumpdata.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-01-30 at 21:39 +0000, Konrad Rzeszutek Wilk wrote:

[...snip... please do consider trimming unnecessary quotes]

> > @@ -1496,50 +1523,105 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
> >               goto fail;
> >       }
> >
> > -     txs = (struct xen_netif_tx_sring *)get_zeroed_page(GFP_NOIO | __GFP_HIGH);
> > +     err = xenbus_scanf(XBT_NIL, info->xbdev->otherend,
> > +                        "max-tx-ring-page-order", "%u",
> > +                        &max_tx_ring_page_order);
> > +     if (err < 0) {
> > +             info->tx_ring_page_order = 0;
> > +             dev_info(&dev->dev, "single tx ring\n");
> > +     } else {
> > +             info->tx_ring_page_order = max_tx_ring_page_order;
> > +             dev_info(&dev->dev, "multi page tx ring, order = %d\n",
> > +                      max_tx_ring_page_order);
> > +     }
> > +     info->tx_ring_pages = (1U << info->tx_ring_page_order);
> > +
> > +     txs = (struct xen_netif_tx_sring *)
> > +             dma_alloc_coherent(NULL, PAGE_SIZE * info->tx_ring_pages,
> > +                                &info->tx_ring_dma_handle,
> > +                                __GFP_ZERO | GFP_NOIO | __GFP_HIGH);
> 
> Hm, so I see you are using 'NULL' which is a big nono (the API docs say that).
> But the other reason why it is a no-no, is b/c this way the generic DMA engine has no
> clue whether you are OK getting pages under 4GB or above it (so 64-bit support).

Does this allocation even need to be physically contiguous? I'd have
thought that virtually contiguous would be sufficient, and even then
only as a convenience at either end to avoid the need for more
complicated ring macros.

Ian.

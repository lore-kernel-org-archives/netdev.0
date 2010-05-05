From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH -next 2/3] bnx2: Add prefetches to rx path.
Date: Wed, 5 May 2010 08:01:11 -0700
Message-ID: <C27F8246C663564A84BB7AB3439772421B6C41FC37@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <1273038330.2304.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "'Eric Dumazet'" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3487 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932528Ab0EEPB2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 11:01:28 -0400
In-Reply-To: <1273038330.2304.10.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:

> > @@ -3097,7 +3099,11 @@ bnx2_rx_int(struct bnx2 *bp, struct
> bnx2_napi *bnapi, int budget)
> >
> >             rx_buf = &rxr->rx_buf_ring[sw_ring_cons];
> >             skb = rx_buf->skb;
> > +           prefetch(skb);
>
> why not a prefetchw() ?

Yes, didn't know there was a prefetchw() before you pointed it
out.

>
> >
> > +           next_rx_buf =
> > +
> &rxr->rx_buf_ring[RX_RING_IDX(NEXT_RX_BD(sw_cons))];
> > +           prefetch(next_rx_buf->desc);
>
> So cpu is allowed to start a memory transaction on
> next_skb->data, while
> not yes DMA unmapped ?

Very good point.  The prefetch() will not work and will be
wasted on systems that have pci_dma_sync_...() defined.  I
think we can skip the prefetch if pci_dma_sync_...() is
defined.  The logic to determine if the next descriptor is
ready, dma_sync it, and prefetch it will be complicated and
we may end up not gaining any performance in the end.

What do you think?  Thanks.



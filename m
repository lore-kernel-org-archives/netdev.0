From: Amos Kong <akong@redhat.com>
Subject: Re: [PATCH] mvme147: use correct order of ram pages
Date: Wed, 28 May 2014 21:58:20 +0800
Message-ID: <20140528135820.GB3127@z.redhat.com>
References: <1401250073-16603-1-git-send-email-akong@redhat.com>
 <CAMuHMdV-g35ijLgcE=sSM3eE+fCxC1WOiAX2PaWs0z4-+bDP+A@mail.gmail.com>
 <mvmvbsqjl87.fsf@hawking.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	Linux/m68k <linux-m68k@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Andreas Schwab <schwab@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65180 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753809AbaE1N62 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2014 09:58:28 -0400
Content-Disposition: inline
In-Reply-To: <mvmvbsqjl87.fsf@hawking.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 28, 2014 at 11:39:20AM +0200, Andreas Schwab wrote:
> Geert Uytterhoeven <geert@linux-m68k.org> writes:
> 
> >> -/* We have 16834 bytes of RAM for the init block and buffers. This places
> >> +/* We have 16384 bytes of RAM for the init block and buffers. This places
> >>   * an upper limit on the number of buffers we can use. NetBSD uses 8 Rx
> >>   * buffers and 2 Tx buffers.
> >>   */
> >> +#define M147LANCE_RAM_SIZE   16384 /* 16K */
> >>  #define LANCE_LOG_TX_BUFFERS 1
> >>  #define LANCE_LOG_RX_BUFFERS 3
> >

#define TX_RING_SIZE            (1 << LANCE_LOG_TX_BUFFERS)
#define RX_RING_SIZE            (1 << LANCE_LOG_RX_BUFFERS)

> > BTW,I also find it fishy why the driver uses only 1+3 buffers, since more
> > RAM is available.
> 
> It's 2^1+2^3.

tx & rx bufs aren't 2^1 + 2^3 = 10 pages. 

Rx buffers and Tx buffers are included in 'struct lance_init_block'

   volatile char tx_buf[TX_RING_SIZE][TX_BUFF_SIZE];
   volatile char rx_buf[RX_RING_SIZE][RX_BUFF_SIZE];

   volatile char tx_buf[2][1544];
   volatile char rx_buf[8][1544];

   RX_BUFF_SIZE = TX_BUFF_SIZE = 1554
   So tx_buf takes 1544 * 2 bytes, rx_buf takes 1544 * 8 bytes
        
In drivers/net/ethernet/amd/mvme147.c:
=====================================
  lp->lance.init_block = (struct lance_init_block *)(lp->ram); /* CPU addr */
  lp->lance.lance_init_block = (struct lance_init_block*)(lp->ram); /* LANCE addr of same RAM */

init_block and lance_init_block are set same address

In drivers/net/ethernet/amd/a2065.c:
===================================
  priv->init_block = (struct lance_init_block *)dev->mem_start;
  priv->lance_init_block = (struct lance_init_block *)A2065_RAM;

  The ram size (A2065_RAM_SIZE) is 0x8000 -> 8 pages -> order is 3

It seems original 3 is a right order, we need to fix the comments.
it's 2^3 * 4k = 32K = 32768 bytes.

But in drivers/net/ethernet/amd/hplance.c:
=========================================
  #define HPLANCE_MEMOFF 0x8000 /* struct lance_init_block */
  lp->lance.init_block = (struct lance_init_block *)(va + HPLANCE_MEMOFF); /* CPU addr */
                                                          ^^^^ it skips 0x8000, that is for HPLANCE
  lp->lance.lance_init_block = NULL; /* LANCE addr of same RAM */

  We need 2 * 32k for lp->ram?

 
> Andreas.
> 
> -- 
> Andreas Schwab, schwab@linux-m68k.org
> GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
> "And now for something completely different."
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
			Amos.

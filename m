From: Dave Jones <davej@redhat.com>
Subject: Re: velocity driver unmaps incorrect size.
Date: Sun, 21 Jun 2009 22:40:44 -0400
Message-ID: <20090622024044.GA3157@redhat.com>
References: <20090621173745.GC26093@redhat.com> <20090621.184345.194558005.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:41916 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753369AbZFVCko (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Jun 2009 22:40:44 -0400
Content-Disposition: inline
In-Reply-To: <20090621.184345.194558005.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 21, 2009 at 06:43:45PM -0700, David Miller wrote:

 > > ------------[ cut here ]------------
 > > WARNING: at lib/dma-debug.c:505 check_unmap+0x1f8/0x4d4()
 > > Hardware name:  
 > > via-velocity 0000:00:0e.0: DMA-API: device driver frees DMA memory with different size [device address=0x000000001a456242] [map size=90 bytes] [unmap size=1 bytes]
 > 
 > Ok, bad unmap size is "1".
 > 
 > >  [<c05e1029>] ? check_unmap+0x1f8/0x4d4
 > >  [<c0443533>] warn_slowpath_fmt+0x34/0x48
 > >  [<c05e1029>] check_unmap+0x1f8/0x4d4
 > >  [<c05e15a8>] debug_dma_unmap_page+0x71/0x8a
 > >  [<dcf88829>] pci_unmap_single+0x74/0x90 [via_velocity]
 > >  [<dcf88922>] velocity_tx_srv+0xdd/0x1a0 [via_velocity]
 > >  [<dcf89e76>] velocity_intr+0x52f/0x5a1 [via_velocity]
 > 
 > So since this is happening in velocity_tx_srv() it has to be
 > velocity_free_tx_buf().  It has two cases, one for when
 > VELOCITY_ZERO_COPY_SUPPORT is defined and one for when that
 > is not defined.
 > 
 > There is no way to set that define that I can see in the
 > tree, so we only need to consider the case where this
 > macro is not defined:
 > 
 > static void velocity_free_tx_buf(struct velocity_info *vptr, struct velocity_td_info *tdinfo)
 > {
 >  ...
 > 	if (tdinfo->skb_dma) {
 > 		pktlen = (skb->len > ETH_ZLEN ? : ETH_ZLEN);
 > 		for (i = 0; i < tdinfo->nskb_dma; i++) {
 > 			pci_unmap_single(vptr->pdev, tdinfo->skb_dma[i], pktlen, PCI_DMA_TODEVICE);
 > 			tdinfo->skb_dma[i] = 0;
 > 		}
 > 	}
 >  ...
 > }
 > 
 > It seems to me that it's impossible for 'pktlen' to every be
 > '1' here as the DMA debug code is claiming.  It must always
 > be at least ETH_ZLEN.  And that is what is passed in for the
 > unmap length.
 > 
 > David is there something wonky in your build or do you have
 > any local patches applied?

Nothing obvious that could explain it.
(It's the Fedora 11 kernel, which has no patches to this driver,
 nor to net/)

 > Is it possible that for some reason
 > your build is forcing VELOCITY_ZERO_COPY_SUPPORT to be defined
 > for some reason?

Memory corruption maybe?
It's especially odd in that it only happens once during boot,
and never happens again. This is my firewall/router, so there's
more packets going through that box than any other I have.


btw, given the zerocopy stuff has been disabled for so long,
is it worth keeping it ?

	Dave



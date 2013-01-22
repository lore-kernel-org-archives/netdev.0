From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: BUG in netxen_release_tx_buffers when TSO enabled on kernels >= 3.3 and <= 3.6
Date: Tue, 22 Jan 2013 16:43:58 +0100
Message-ID: <3172160.NCYvLW6RVJ@cpaasch-mac>
References: <1659861.dHpGAGoXHj@cpaasch-mac> <1358862966.3464.3797.camel@edumazet-glaptop> <2166577.r0iRQtU7qE@cpaasch-mac>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:38846 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753248Ab3AVPoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 10:44:08 -0500
Received: by mail-wi0-f170.google.com with SMTP id hq7so3489612wib.3
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 07:44:07 -0800 (PST)
In-Reply-To: <2166577.r0iRQtU7qE@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In netxen_map_tx_skb() I think we also have to set nf->dma to 0ULL (like the 
diff below).

Otherwise, netxen_release_tx_buffer() may try to unmap something that has 
already been unmapped.

I'm not sure - I don't feel very comfortable in driver-code...


diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c 
b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 342b3a7..a1516a6 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -1959,10 +1959,12 @@ unwind:
        while (--i >= 0) {
                nf = &pbuf->frag_array[i+1];
                pci_unmap_page(pdev, nf->dma, nf->length, PCI_DMA_TODEVICE);
+               nf->dma = 0ULL;
        }
 
        nf = &pbuf->frag_array[0];
        pci_unmap_single(pdev, nf->dma, skb_headlen(skb), PCI_DMA_TODEVICE);
+       nf->dma = 0ULL;
 
 out_err:
        return -ENOMEM;



On Tuesday 22 January 2013 16:03:59 Christoph Paasch wrote:
> On Tuesday 22 January 2013 05:56:06 Eric Dumazet wrote:
> > I guess netxen driver has a bug.
> > 
> > Please try the following patch :
> > 
> > diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
> > b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c index
> > bc165f4..695667d 100644
> > --- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
> > +++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
> > @@ -144,7 +144,7 @@ void netxen_release_tx_buffers(struct netxen_adapter
> > *adapter) buffrag->length, PCI_DMA_TODEVICE); buffrag->dma = 0ULL;
> > 
> >                 }
> > 
> > -               for (j = 0; j < cmd_buf->frag_count; j++) {
> > +               for (j = 1; j < cmd_buf->frag_count; j++) {
> > 
> >                         buffrag++;
> >                         if (buffrag->dma) {
> >                         
> >                                 pci_unmap_page(adapter->pdev,
> >                                 buffrag->dma,
> 
> Perfect, I tested it, and this fixes the bug.
> 
> I should have found it on my own, I have been starring for too long at this
> function... :)
> 
> Feel free to add
> Tested-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> 
> 
> Thanks, Eric!
> 
> 
> Christoph
-- 
IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://mptcp.info.ucl.ac.be
UCLouvain
--

From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] sky2: Fix WARNING: at lib/dma-debug.c:902 check_sync
Date: Wed, 20 Jan 2010 09:41:03 +0000
Message-ID: <20100120094103.GA6225@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Michael Breuer <mbreuer@majjas.com>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:62637 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010Ab0ATJlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 04:41:11 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ previously: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit() ]
On Tue, Jan 19, 2010 at 05:10:13PM -0800, Stephen Hemminger wrote:
> On Tue, 19 Jan 2010 20:01:10 -0500
> Michael Breuer <mbreuer@majjas.com> wrote:
> 
> > On 1/19/2010 5:45 PM, Jarek Poplawski wrote:
> > > On Tue, Jan 19, 2010 at 03:06:01PM -0500, Michael Breuer wrote:
> > >    
> > >> On 1/19/2010 2:59 PM, Jarek Poplawski wrote:
> > >>      
> > >>> On Tue, Jan 19, 2010 at 10:47:27AM -0500, Michael Breuer wrote:
> > >>> ...
> > >>>        
> > >>>> Still get the warning... but now 60 bytes.
> > >>>> Jan 19 10:43:50 mail kernel: ------------[ cut here ]------------
> > >>>> Jan 19 10:43:50 mail kernel: WARNING: at lib/dma-debug.c:902
...
> > That not only compiled, but it cleared the error as well. Additionally, 
> > I used to see a bit of a delay receiving the login prompt when first 
> > connecting to the box by ssh. That delay is gone with this patch. I'd 
> > guess that the warning wasn't quite as innocuous as I thought.
> > Note: tested on 2.6.32.4.  I'll leave this up for a bit before 
> > attempting to move back to head.
> 
> Seems like an underlying bug in the DMA api. Maybe it just can't
> handle operations on partial mapping.
> 
> Other drivers with same problem:
>   bnx2, cassini, pcnet32, r8169, rrunner, skge, sungem, tg3, 

It seems using the same length (even without pci_unmap_len()) is
crucial here, but I hope maintainers (added to CC) will take care.

Btw, it's not tested yet, but it might affect CONFIG_DMAR problems.

Thanks,
Jarek P.
----------------------->

Using pci_unmap_len(), with the same length as pci_map_single(), with
pci_dma_sync_single_for_cpu()/_device() fixes this warning (2.6.32.4):

> Jan 19 10:43:50 mail kernel: WARNING: at lib/dma-debug.c:902 
> check_sync+0xc1/0x43f()
> Jan 19 10:43:50 mail kernel: Hardware name: System Product Name
> Jan 19 10:43:50 mail kernel: sky2 0000:04:00.0: DMA-API: device driver 
> tries to sync DMA memory it has not allocated [device 
> address=0x0000000320a0b022] [size=60 bytes]

Reported-by: Michael Breuer <mbreuer@majjas.com>
Tested-by: Michael Breuer <mbreuer@majjas.com>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 drivers/net/sky2.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 7650f73..cdebdd3 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -2252,12 +2252,14 @@ static struct sk_buff *receive_copy(struct sky2_port *sky2,
 	skb = netdev_alloc_skb_ip_align(sky2->netdev, length);
 	if (likely(skb)) {
 		pci_dma_sync_single_for_cpu(sky2->hw->pdev, re->data_addr,
-					    length, PCI_DMA_FROMDEVICE);
+					    pci_unmap_len(re, data_size),
+					    PCI_DMA_FROMDEVICE);
 		skb_copy_from_linear_data(re->skb, skb->data, length);
 		skb->ip_summed = re->skb->ip_summed;
 		skb->csum = re->skb->csum;
 		pci_dma_sync_single_for_device(sky2->hw->pdev, re->data_addr,
-					       length, PCI_DMA_FROMDEVICE);
+					       pci_unmap_len(re, data_size),
+					       PCI_DMA_FROMDEVICE);
 		re->skb->ip_summed = CHECKSUM_NONE;
 		skb_put(skb, length);
 	}

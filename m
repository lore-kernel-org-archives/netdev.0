From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Hang: 2.6.32.4 sky2/DMAR (was [PATCH] sky2: Fix WARNING: at
 lib/dma-debug.c:902 check_sync)
Date: Wed, 27 Jan 2010 20:23:12 +0100
Message-ID: <20100127192312.GA3135@del.dom.local>
References: <4B5A33D8.90501@majjas.com>
 <20100122234656.GC3105@del.dom.local>
 <4B5A39BD.8020305@majjas.com>
 <20100123232133.GA3487@del.dom.local>
 <4B605D1B.60402@majjas.com>
 <20100127085049.5b5048e9@nehalam>
 <4B60707F.1000608@majjas.com>
 <20100127095614.14313677@nehalam>
 <4B608128.7090607@majjas.com>
 <4B6089C7.4010803@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754355Ab0A0TX0@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B6089C7.4010803@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 27, 2010 at 01:45:27PM -0500, Michael Breuer wrote:
> On 1/27/2010 1:08 PM, Michael Breuer wrote:
> >On 01/27/2010 12:56 PM, Stephen Hemminger wrote:
> >>--- a/drivers/net/sky2.c    2010-01-27 09:46:10.940005248 -0800
> >>+++ b/drivers/net/sky2.c    2010-01-27 09:53:47.141267850 -0800
> >>@@ -2257,13 +2257,16 @@ static struct sk_buff *receive_copy(stru
> >>
> >>      skb = netdev_alloc_skb_ip_align(sky2->netdev, length);
> >>      if (likely(skb)) {
> >>+        unsigned dma_align = dma_get_cache_alignment();
> >>+        unsigned dma_size = ALIGN(length+1, dma_align);
> >>+
> >>          pci_dma_sync_single_for_cpu(sky2->hw->pdev, re->data_addr,
> >>-                        length, PCI_DMA_FROMDEVICE);
> >>+                        dma_size, PCI_DMA_FROMDEVICE);
> >>          skb_copy_from_linear_data(re->skb, skb->data, length);
> >>          skb->ip_summed = re->skb->ip_summed;
> >>          skb->csum = re->skb->csum;
> >>          pci_dma_sync_single_for_device(sky2->hw->pdev, re->data_addr,
> >>-                           length, PCI_DMA_FROMDEVICE);
> >>+                           dma_size, PCI_DMA_FROMDEVICE);
> >>          re->skb->ip_summed = CHECKSUM_NONE;
> >>          skb_put(skb, length);
> >>      }
> >This doesn't apply - I'm missing some intermediate patch.
> >
> >I've got (both in 2.6.32.4 and 2.6.33-rc5: pci_unmap_len(re,
> >data_size) vs., "length." I assume that I can just replace the
> >pci_unmap_len with dma_size... but perhaps the intermediate change
> >may have affected this as well?
> >
> Never mind - that was from one of the earlier patches I had been
> trying out. will try the above patch after reestablishing that the
> system still crashes without copybreak=1.
> 

Stephen, I'm not sure this patch can show much after the patch with
"legal" dma_size == re->data_addr didn't help. It looks like David
was right: dma_sync can't affect dmar, because it doesn't use it at
all.

Then I'd rather suggest to test if using copybreak more often, e.g.
with copybreak=1000 or even more can trigger these errors faster.

Jarek P.

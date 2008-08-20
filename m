From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: r8169 MTU greater than 1500 causes corruption for other controllers
Date: Wed, 20 Aug 2008 22:21:11 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808202053510.24321@wrl-59.cs.helsinki.fi>
References: <20080820170951.GA1771@tophat.atxconsulting.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Timothy J Fontaine <tjfontaine@atxconsulting.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39321 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752857AbYHTTVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 15:21:14 -0400
In-Reply-To: <20080820170951.GA1771@tophat.atxconsulting.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Aug 2008, Timothy J Fontaine wrote:

> Setting the MTU to greater than 1500 causes the host system to run out
> of SW-IOMMU space for the transfer. This results in corruption for other
> controllers like my AAR-2410SA or IDE controller.
> 
> Host system:
>  ASUS P5M2 w/ Intel Core 2 Duo 6320
>  Linux version 2.6.24-19-server (buildd@king) (gcc version 4.2.3 (Ubuntu 4.2.3-2ubuntu7)) #1 SMP Fri Jul 11 21:50:43 UTC 2008
>  r8169 chipset pci card
> 
> Connected via Cross-Over cable to:
>  SuperMicro 6014Hi
>  Onboard Intel 82546GB e1000 chipset
>  Running latest VMware ESXi or Vanilla 2.6.26
> 
> Initially I presumed the issue was with my aacraid because of the
> trace[1], so I built a vanilla 2.6.26.2 and hit the same bug. I have
> another system running 2.6.20 and the same card working so I tried
> 2.6.22 and had no problem. However, 2.6.23 failed. I sifted through the
> ChangeLog for 2.6.23 and narrowed the field to some potential problem
> commits regarding aacraid. I then proceeded to do a git bisect and found
> commit b449655ff52ff8a29c66c5fc3fc03617e61182ee[2] which had nothing to
> do with aacraid. Instead, the commit deals with large packets so I reset
> the MTU to 1500 and retried on 2.6.24 and found that there was no
> corruption, I then proceeded to try with various different size MTU only
> to find that an MTU greater than 1500 triggers the corruption.

Hmm, there was no explanation why the tp->rx_buf_sz to pkt_size change
was made in that commit (I have no idea whether those sizes have to match 
to other places that use tp->rx_buf_sz)... Below is a patch to revert 
that part of the change fully though it could be enough to change just 
pci_unmap_single arg (but that would probably need also 
rtl8169_mark_to_asic arg to be changed to match pkt_size).

> Below you'll find a list of files referenced from REPORTING-BUGS that
> are meant to be helpful, including the lspci and module information,
> they can all be reached from the toplevel directory index

Thanks for the detailed report btw... :-)

-- 
 i.

----
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index a3e3895..44961ef 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2720,7 +2720,7 @@ static inline bool rtl8169_try_rx_copy(struct sk_buff **sk_buff,
 	if (!skb)
 		goto out;
 
-	pci_dma_sync_single_for_cpu(tp->pci_dev, addr, pkt_size,
+	pci_dma_sync_single_for_cpu(tp->pci_dev, addr, tp->rx_buf_sz,
 				    PCI_DMA_FROMDEVICE);
 	skb_reserve(skb, NET_IP_ALIGN);
 	skb_copy_from_linear_data(*sk_buff, skb->data, pkt_size);
@@ -2789,10 +2789,10 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 
 			if (rtl8169_try_rx_copy(&skb, tp, pkt_size, addr)) {
 				pci_dma_sync_single_for_device(pdev, addr,
-					pkt_size, PCI_DMA_FROMDEVICE);
+					tp->rx_buf_sz, PCI_DMA_FROMDEVICE);
 				rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
 			} else {
-				pci_unmap_single(pdev, addr, pkt_size,
+				pci_unmap_single(pdev, addr, tp->rx_buf_sz,
 						 PCI_DMA_FROMDEVICE);
 				tp->Rx_skbuff[entry] = NULL;
 			}

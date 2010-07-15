From: Junchang Wang <junchangwang@gmail.com>
Subject: Question about way that NICs deliver packets to the kernel
Date: Thu, 15 Jul 2010 22:24:23 +0800
Message-ID: <20100715142418.GA26491@host-a-229.ustcsz.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: romieu@fr.zoreil.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:41176 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933300Ab0GOOYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 10:24:55 -0400
Received: by pwi5 with SMTP id 5so271796pwi.19
        for <netdev@vger.kernel.org>; Thu, 15 Jul 2010 07:24:55 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi list,
My understand of the way that NICs deliver packets to the kernel is
as follows. Correct me if any of this is wrong. Thanks.

1) The device buffer is fixed. When the kernel is acknowledged arrival of a 
new packet, it dynamically allocate a new skb and copy the packet into it. 
For example, 8139too.

2) The device buffer is mapped by streaming DMA. When the kernel is 
acknowledged arrival of a new packet, it unmaps the region previously mapped. 
Obviously, there is NO memcpy operation. Additional cost is streaming DMA 
map/unmap operations. For example, e100 and e1000.

Here comes my question:
1) Is there a principle indicating which one is better? Is streaming DMA
map/unmap operations more expensive than memcpy operation?


2) Why does r8169 bias towards the first approach even if it support both? I 
convert r8169 to the second one and get a 5% performance boost. Below is result
running netperf TCP_STREAM test with 1.6K byte packet length.
        scheme 1    scheme 2    Imp.
r8169     683M        718M       5%

The following patch shows what I did:

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 239d7ef..707876f 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4556,15 +4556,9 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 
 			rtl8169_rx_csum(skb, desc);
 
-			if (rtl8169_try_rx_copy(&skb, tp, pkt_size, addr)) {
-				pci_dma_sync_single_for_device(pdev, addr,
-					pkt_size, PCI_DMA_FROMDEVICE);
-				rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
-			} else {
-				pci_unmap_single(pdev, addr, tp->rx_buf_sz,
-						 PCI_DMA_FROMDEVICE);
-				tp->Rx_skbuff[entry] = NULL;
-			}
+			pci_unmap_single(pdev, addr, tp->rx_buf_sz,
+					 PCI_DMA_FROMDEVICE);
+			tp->Rx_skbuff[entry] = NULL;
 
 			skb_put(skb, pkt_size);
 			skb->protocol = eth_type_trans(skb, dev);

Thanks in advance.

--Junchang

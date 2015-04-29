From: Stephen Hemminger <shemming@brocade.com>
Subject: [RFC] r8169 DMA failure with iommu=off
Date: Wed, 29 Apr 2015 16:58:13 -0700
Message-ID: <20150429165813.5d64daf0@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:25975 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751477AbbD2X6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 19:58:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This only fixes the Rx side, what about Tx?

I think maybe just removing the whole use_dac flag completely?

Subject: r8169: allocate rx memory in correct region

This fixes failure when using r8169 with IOMMU defined but not
enabled. Reproduced on a 16G machine with LOM r8169 and kernel
set to 'iommu=off'.

This driver has two dma modes. By default use_dac module parameter
is zero and therefore the driver uses only has a 32 bit DMA
mask. But since it calls kmalloc_node() without setting DMA32 flag
the receive buffer maybe above 4G and the dma_map_single will fail.

In either case since this is a receive DMA buffer, it should set
the appropriate GFP_DMA since that may matter on some platforms.

This an old bug was introduced by:

commit 6f0333b8fde44b8c04a53b2461504f0e8f1cebe6
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Mon Oct 11 11:17:47 2010 +0000

    r8169: use 50% less ram for RX ring
    
    Using standard skb allocations in r8169 leads to order-3 allocations (if
    PAGE_SIZE=4096), because NIC needs 16383 bytes, and skb overhead makes
    this bigger than 16384 -> 32768 bytes per "skb"
    
    Using kmalloc() permits to reduce memory requirements of one r8169 nic
    by 4Mbytes. (256 frames * 16Kbytes). This is fine since a hardware bug
    requires us to copy incoming frames, so we build real skb when doing
    this copy.
    
Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5721,14 +5721,16 @@ static struct sk_buff *rtl8169_alloc_rx_
 	struct device *d = &tp->pci_dev->dev;
 	struct net_device *dev = tp->dev;
 	int node = dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
+	gfp_t flags = GFP_KERNEL;
 
-	data = kmalloc_node(rx_buf_sz, GFP_KERNEL, node);
+	flags |= (dev->features & NETIF_F_HIGHDMA) ? GFP_DMA : GFP_DMA32;
+	data = kmalloc_node(rx_buf_sz, flags, node);
 	if (!data)
 		return NULL;
 
 	if (rtl8169_align(data) != data) {
 		kfree(data);
-		data = kmalloc_node(rx_buf_sz + 15, GFP_KERNEL, node);
+		data = kmalloc_node(rx_buf_sz + 15, flags, node);
 		if (!data)
 			return NULL;
 	}

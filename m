From: Don Fry <pcnet32@verizon.net>
Subject: [PATCH ] pcnet32: Fix PCnet32 performance bug on non-coherent architecutres
Date: Mon, 5 Mar 2007 18:13:09 -0800
Message-ID: <20070306021309.GB7139@verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [71.117.224.81] ([71.117.224.81]:16656 "EHLO linux.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933863AbXCFCea (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 21:34:30 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PCnet32 driver always passed the the size of the largest possible packet
to the pci_dma_sync_single_for_cpu and pci_dma_sync_single_for_device.
This results in a fairly large "colateral damage" in the caches and makes
the flush operation itself much slower.  On a system with a 40MHz CPU this
patch increases network bandwidth by about 12%.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
Acked-by: Don Fry <pcnet32@verizon.net>

diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index 36f9d98..4d94ba7 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -1234,14 +1234,14 @@ static void pcnet32_rx_entry(struct net_device *dev,
 		skb_put(skb, pkt_len);	/* Make room */
 		pci_dma_sync_single_for_cpu(lp->pci_dev,
 					    lp->rx_dma_addr[entry],
-					    PKT_BUF_SZ - 2,
+					    pkt_len,
 					    PCI_DMA_FROMDEVICE);
 		eth_copy_and_sum(skb,
 				 (unsigned char *)(lp->rx_skbuff[entry]->data),
 				 pkt_len, 0);
 		pci_dma_sync_single_for_device(lp->pci_dev,
 					       lp->rx_dma_addr[entry],
-					       PKT_BUF_SZ - 2,
+					       pkt_len,
 					       PCI_DMA_FROMDEVICE);
 	}
 	lp->stats.rx_bytes += skb->len;


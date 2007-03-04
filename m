From: Ralf Baechle <ralf@linux-mips.org>
Subject: [NET] Fix PCnet32 performance bug on non-coherent architecutres
Date: Sun, 4 Mar 2007 22:30:33 +0000
Message-ID: <20070304223033.GA23622@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
	pcnet32@verizon.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:57072 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752670AbXCDWc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2007 17:32:27 -0500
Received: from localhost.localdomain ([127.0.0.1]:10219 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20037863AbXCDWc0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Mar 2007 22:32:26 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PCnet32 driver always passed the the size of the largest possible packet
to the pci_dma_sync_single_for_cpu and pci_dma_sync_single_for_device.
This results in a fairly large "colateral damage" in the caches and makes
the flush operation itself much slower.  On a system with a 40MHz CPU this
patch increases network bandwidth by about 12%.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

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

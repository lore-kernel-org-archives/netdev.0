From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH net] tulip: Properly check dma mapping result
Date: Thu, 13 Jun 2013 15:31:28 -0400
Message-ID: <1371151888-12138-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Grant Grundler <grundler@parisc-linux.org>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36149 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756352Ab3FMTbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 15:31:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tulip throws an error when dma debugging is enabled, as it doesn't properly
check dma mapping results with dma_mapping_error() durring tx ring refills.

Easy fix, just add it in, and drop the frame if the mapping is bad

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Grant Grundler <grundler@parisc-linux.org>
CC: "David S. Miller" <davem@davemloft.net>
---
 drivers/net/ethernet/dec/tulip/interrupt.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/dec/tulip/interrupt.c b/drivers/net/ethernet/dec/tulip/interrupt.c
index 28a5e42..92306b3 100644
--- a/drivers/net/ethernet/dec/tulip/interrupt.c
+++ b/drivers/net/ethernet/dec/tulip/interrupt.c
@@ -76,6 +76,12 @@ int tulip_refill_rx(struct net_device *dev)
 
 			mapping = pci_map_single(tp->pdev, skb->data, PKT_BUF_SZ,
 						 PCI_DMA_FROMDEVICE);
+			if (dma_mapping_error(&tp->pdev->dev, mapping)) {
+				dev_kfree_skb(skb);
+				tp->rx_buffers[entry].skb = NULL;
+				break;
+			}
+
 			tp->rx_buffers[entry].mapping = mapping;
 
 			tp->rx_ring[entry].buffer1 = cpu_to_le32(mapping);
-- 
1.8.1.4

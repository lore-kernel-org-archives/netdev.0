From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 1/7] 2.6.5-bk-netdev - r8169 queue
Date: Mon, 5 Apr 2004 23:56:48 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040405235648.A23436@electric-eye.fr.zoreil.com>
References: <20040405235545.A20805@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20040405235545.A20805@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Mon, Apr 05, 2004 at 11:55:45PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


DMA api resync.


 drivers/net/r8169.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff -puN drivers/net/r8169.c~r8169-dma-api-resync drivers/net/r8169.c
--- linux-2.6.5/drivers/net/r8169.c~r8169-dma-api-resync	2004-04-05 23:05:27.000000000 +0200
+++ linux-2.6.5-fr/drivers/net/r8169.c	2004-04-05 23:05:27.000000000 +0200
@@ -1429,19 +1429,22 @@ rtl8169_rx_interrupt(struct net_device *
 			struct RxDesc *desc = tp->RxDescArray + entry;
 			struct sk_buff *skb = tp->Rx_skbuff[entry];
 			int pkt_size = (status & 0x00001FFF) - 4;
+			void (*pci_action)(struct pci_dev *, dma_addr_t,
+				size_t, int) = pci_dma_sync_single_for_device;
 
-			pci_dma_sync_single(tp->pci_dev,
-					    le32_to_cpu(desc->buf_addr),
-					    RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
+
+			pci_dma_sync_single_for_cpu(tp->pci_dev,
+				le32_to_cpu(desc->buf_addr), RX_BUF_SIZE,
+				PCI_DMA_FROMDEVICE);
 
 			if (rtl8169_try_rx_copy(&skb, pkt_size, desc, dev)) {
-				pci_unmap_single(tp->pci_dev,
-						 le32_to_cpu(desc->buf_addr),
-						 RX_BUF_SIZE,
-						 PCI_DMA_FROMDEVICE);
+				pci_action = pci_unmap_single;
 				tp->Rx_skbuff[entry] = NULL;
 			}
 
+			pci_action(tp->pci_dev, le32_to_cpu(desc->buf_addr),
+				   RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
+
 			skb_put(skb, pkt_size);
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);

_

From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 4/4] 2.6.5-rc2-mm5 - r8169 queue
Date: Mon, 29 Mar 2004 19:39:17 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040329193917.D5411@electric-eye.fr.zoreil.com>
References: <20040329193604.A4744@electric-eye.fr.zoreil.com> <20040329193710.A5411@electric-eye.fr.zoreil.com> <20040329193747.B5411@electric-eye.fr.zoreil.com> <20040329193831.C5411@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20040329193831.C5411@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Mon, Mar 29, 2004 at 07:38:31PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


pci_dma_sync_single_for_{cpu/device} sneaked in 2.6.5-rcX. Let's resync.


 drivers/net/r8169.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff -puN drivers/net/r8169.c~r8169-dma-api-update drivers/net/r8169.c
--- linux-2.6.5-rc2-mm5/drivers/net/r8169.c~r8169-dma-api-update	2004-03-29 19:01:07.000000000 +0200
+++ linux-2.6.5-rc2-mm5-fr/drivers/net/r8169.c	2004-03-29 19:03:19.000000000 +0200
@@ -1443,19 +1443,22 @@ rtl8169_rx_interrupt(struct net_device *
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

From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 5/8]  2.6.5-rc2 - sis190 update
Date: Sat, 27 Mar 2004 03:14:43 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040327031443.E31053@electric-eye.fr.zoreil.com>
References: <20040327030853.A30849@electric-eye.fr.zoreil.com> <20040327031131.A31053@electric-eye.fr.zoreil.com> <20040327031219.B31053@electric-eye.fr.zoreil.com> <20040327031302.C31053@electric-eye.fr.zoreil.com> <20040327031351.D31053@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040327031351.D31053@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Sat, Mar 27, 2004 at 03:13:51AM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Still no functionnal change. See r8169 driver for details.


 drivers/net/sis190.c |   49 +++++++++++++++++++++++++++++++++++++------------
 1 files changed, 37 insertions(+), 12 deletions(-)

diff -puN drivers/net/sis190.c~sis190-dma-api-rx-buffers-10 drivers/net/sis190.c
--- linux-2.6.5-rc2/drivers/net/sis190.c~sis190-dma-api-rx-buffers-10	2004-03-27 02:37:12.000000000 +0100
+++ linux-2.6.5-rc2-fr/drivers/net/sis190.c	2004-03-27 02:37:12.000000000 +0100
@@ -817,10 +817,42 @@ static inline void sis190_give_to_asic(s
 	desc->status |= cpu_to_le32(OWNbit | INTbit);
 }
 
+static int sis190_alloc_rx_skb(struct pci_dev *pdev, struct net_device *dev,
+			       char *tail, struct RxDesc *desc)
+{
+	dma_addr_t mapping;
+	int ret = 0;
+
+	mapping = pci_map_single(pdev, tail, RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
+
+	desc->PSize = 0x0;
+	desc->buf_Len |= cpu_to_le32(RX_BUF_SIZE);
+
+	sis190_give_to_asic(desc, mapping);
+
+	return ret;
+}
+
+static u32 sis190_rx_fill(struct sis190_private *tp, struct net_device *dev,
+			  u32 start, u32 end)
+{
+	u32 cur;
+
+	for (cur = start; end - cur > 0; cur++) {
+		int ret, i = cur % NUM_RX_DESC;
+
+		ret = sis190_alloc_rx_skb(tp->pci_dev, dev,
+					  tp->RxBufferRings + i * RX_BUF_SIZE,
+					  tp->RxDescArray + i);
+		if (ret < 0)
+			break;
+	}
+	return cur - start;
+}
+
 static int SiS190_init_ring(struct net_device *dev)
 {
 	struct sis190_private *tp = dev->priv;
-	int i;
 
 	tp->cur_rx = 0;
 	tp->cur_tx = tp->dirty_tx = 0;
@@ -836,22 +868,15 @@ static int SiS190_init_ring(struct net_d
 		goto err_out;
 	}
 
-	for (i = 0; i < NUM_RX_DESC; i++) {
-		struct RxDesc *desc = tp->RxDescArray + i;
-		dma_addr_t mapping;
-
-		desc->PSize = 0x0;
-		desc->buf_Len = cpu_to_le32(RX_BUF_SIZE);
+	if (sis190_rx_fill(tp, dev, 0, NUM_RX_DESC) != NUM_RX_DESC)
+		goto err_out_free;
 
-		tp->RxBufferRing[i] = tp->RxBufferRings + i * RX_BUF_SIZE;
-		mapping = pci_map_single(tp->pci_dev,
-			tp->RxBufferRing[i], RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
-		sis190_give_to_asic(desc, mapping);
-	}
 	sis190_mark_as_last_descriptor(tp->RxDescArray + NUM_RX_DESC - 1);
 
 	return 0;
 
+err_out_free:
+	kfree(tp->RxBufferRings);
 err_out:
 	return -ENOMEM;
 }

_

From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patches] 2.6.0-test9 - r8169 DMA API conversion
Date: Fri, 21 Nov 2003 01:36:37 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031121013637.B31929@electric-eye.fr.zoreil.com>
References: <47973.68.105.173.45.1069042089.squirrel@mail.mainstreetsoftworks.com> <3FB9A277.70309@pobox.com> <20031118135848.A2451@electric-eye.fr.zoreil.com> <3FBBA76B.4070606@pobox.com> <20031120010056.A19444@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="4Ckj6UjgE2iN1+kY"
Cc: Jeff Garzik <jgarzik@pobox.com>, Brad House <brad_mssw@gentoo.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20031120010056.A19444@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Thu, Nov 20, 2003 at 01:00:56AM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Francois Romieu <romieu@fr.zoreil.com> :
[...]
> Feel free to comment/review. Next patch tomorrow.

The attached patches apply on top of yesterday's ones:
r8169-start-xmit-fixes.patch
r8169-dma-api-tx-buffers.patch
r8169-rx_copybreak.patch

Bugs apart, there shouldn't be anything subtle.

--
Ueimor

--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="r8169-start-xmit-fixes.patch"


rtl8169_start_xmit fixes:
- it forgot to update stats if the skb couldn't be expanded;
- it didn't free it either if the descriptor was not available;
- move the spin_unlock nearer of the exit point instead of duplicating
  it in the new branch.


 drivers/net/r8169.c |   31 ++++++++++++++++++-------------
 1 files changed, 18 insertions(+), 13 deletions(-)

diff -puN drivers/net/r8169.c~r8169-start-xmit-fixes drivers/net/r8169.c
--- linux-2.6.0-test9/drivers/net/r8169.c~r8169-start-xmit-fixes	2003-11-21 01:08:38.000000000 +0100
+++ linux-2.6.0-test9-fr/drivers/net/r8169.c	2003-11-21 01:08:38.000000000 +0100
@@ -918,11 +918,13 @@ rtl8169_start_xmit(struct sk_buff *skb, 
 	struct rtl8169_private *tp = dev->priv;
 	void *ioaddr = tp->mmio_addr;
 	int entry = tp->cur_tx % NUM_TX_DESC;
+	u32 len = skb->len;
 
-	if (skb->len < ETH_ZLEN) {
+	if (unlikely(skb->len < ETH_ZLEN)) {
 		skb = skb_padto(skb, ETH_ZLEN);
-		if (skb == NULL)
-			return 0;
+		if (!skb)
+			goto err_update_stats;
+		len = ETH_ZLEN;
 	}
 	
 	spin_lock_irq(&tp->lock);
@@ -930,29 +932,32 @@ rtl8169_start_xmit(struct sk_buff *skb, 
 	if ((tp->TxDescArray[entry].status & OWNbit) == 0) {
 		tp->Tx_skbuff[entry] = skb;
 		tp->TxDescArray[entry].buf_addr = virt_to_bus(skb->data);
-		if (entry != (NUM_TX_DESC - 1))
-			tp->TxDescArray[entry].status =
-			    (OWNbit | FSbit | LSbit) | ((skb->len > ETH_ZLEN) ?
-							skb->len : ETH_ZLEN);
-		else
-			tp->TxDescArray[entry].status =
-			    (OWNbit | EORbit | FSbit | LSbit) |
-			    ((skb->len > ETH_ZLEN) ? skb->len : ETH_ZLEN);
 
+		tp->TxDescArray[entry].status = OWNbit | FSbit | LSbit | len |
+				(EORbit * !((entry + 1) % NUM_TX_DESC));
+			
 		RTL_W8(TxPoll, 0x40);	//set polling bit
 
 		dev->trans_start = jiffies;
 
 		tp->cur_tx++;
-	}
+	} else
+		goto err_drop;
 
-	spin_unlock_irq(&tp->lock);
 
 	if ((tp->cur_tx - NUM_TX_DESC) == tp->dirty_tx) {
 		netif_stop_queue(dev);
 	}
+out:
+	spin_unlock_irq(&tp->lock);
 
 	return 0;
+
+err_drop:
+	dev_kfree_skb(skb);
+err_update_stats:
+	tp->stats.tx_dropped++;
+	goto out;
 }
 
 static void

_

--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="r8169-dma-api-tx-buffers.patch"


Conversion of Tx data buffers to PCI DMA:
- endianness is kept in a fscked state as it is in the original code
  (will be adressed in a later patch);
- buf_addr of an unmapped descriptor is always set to the same value 
  (cf rtl8169_unmap_tx_skb);
- nothing fancy, really.


 drivers/net/r8169.c |   36 +++++++++++++++++++++++++++++-------
 1 files changed, 29 insertions(+), 7 deletions(-)

diff -puN drivers/net/r8169.c~r8169-dma-api-tx-buffers drivers/net/r8169.c
--- linux-2.6.0-test9/drivers/net/r8169.c~r8169-dma-api-tx-buffers	2003-11-21 01:08:42.000000000 +0100
+++ linux-2.6.0-test9-fr/drivers/net/r8169.c	2003-11-21 01:08:42.000000000 +0100
@@ -871,6 +871,17 @@ err_out:
 	return -ENOMEM;
 }
 
+static void rtl8169_unmap_tx_skb(struct pci_dev *pdev, struct sk_buff **sk_buff,
+				 struct TxDesc *desc)
+{
+	u32 len = sk_buff[0]->len;
+
+	pci_unmap_single(pdev, desc->buf_addr, len < ETH_ZLEN ? ETH_ZLEN : len,
+			 PCI_DMA_TODEVICE);
+	desc->buf_addr = 0x00;
+	*sk_buff = NULL;
+}
+
 static void
 rtl8169_tx_clear(struct rtl8169_private *tp)
 {
@@ -878,9 +889,12 @@ rtl8169_tx_clear(struct rtl8169_private 
 
 	tp->cur_tx = 0;
 	for (i = 0; i < NUM_TX_DESC; i++) {
-		if (tp->Tx_skbuff[i] != NULL) {
-			dev_kfree_skb(tp->Tx_skbuff[i]);
-			tp->Tx_skbuff[i] = NULL;
+		struct sk_buff *skb = tp->Tx_skbuff[i];
+
+		if (skb) {
+			rtl8169_unmap_tx_skb(tp->pci_dev, tp->Tx_skbuff + i,
+					     tp->TxDescArray + i);
+			dev_kfree_skb(skb);
 			tp->stats.tx_dropped++;
 		}
 	}
@@ -930,8 +944,13 @@ rtl8169_start_xmit(struct sk_buff *skb, 
 	spin_lock_irq(&tp->lock);
 
 	if ((tp->TxDescArray[entry].status & OWNbit) == 0) {
+		dma_addr_t mapping;
+
+		mapping = pci_map_single(tp->pci_dev, skb->data, len,
+					 PCI_DMA_TODEVICE);
+
 		tp->Tx_skbuff[entry] = skb;
-		tp->TxDescArray[entry].buf_addr = virt_to_bus(skb->data);
+		tp->TxDescArray[entry].buf_addr = mapping;
 
 		tp->TxDescArray[entry].status = OWNbit | FSbit | LSbit | len |
 				(EORbit * !((entry + 1) % NUM_TX_DESC));
@@ -976,9 +995,12 @@ rtl8169_tx_interrupt(struct net_device *
 
 	while (tx_left > 0) {
 		if ((tp->TxDescArray[entry].status & OWNbit) == 0) {
-			dev_kfree_skb_irq(tp->
-					  Tx_skbuff[dirty_tx % NUM_TX_DESC]);
-			tp->Tx_skbuff[dirty_tx % NUM_TX_DESC] = NULL;
+			int cur = dirty_tx % NUM_TX_DESC;
+			struct sk_buff *skb = tp->Tx_skbuff[cur];
+
+			rtl8169_unmap_tx_skb(tp->pci_dev, tp->Tx_skbuff + cur,
+					     tp->TxDescArray + cur);
+			dev_kfree_skb_irq(skb);
 			tp->stats.tx_packets++;
 			dirty_tx++;
 			tx_left--;

_

--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="r8169-rx_copybreak.patch"


Rx copybreak for small packets.
- removal of rtl8169_unmap_rx() (unneeded as for now).


 drivers/net/r8169.c |   47 +++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 39 insertions(+), 8 deletions(-)

diff -puN drivers/net/r8169.c~r8169-rx_copybreak drivers/net/r8169.c
--- linux-2.6.0-test9/drivers/net/r8169.c~r8169-rx_copybreak	2003-11-21 01:08:46.000000000 +0100
+++ linux-2.6.0-test9-fr/drivers/net/r8169.c	2003-11-21 01:08:46.000000000 +0100
@@ -116,6 +116,8 @@ static struct pci_device_id rtl8169_pci_
 
 MODULE_DEVICE_TABLE(pci, rtl8169_pci_tbl);
 
+static int rx_copybreak = 200;
+
 enum RTL8169_registers {
 	MAC0 = 0,		/* Ethernet hardware address. */
 	MAR0 = 8,		/* Multicast filter. */
@@ -294,6 +296,7 @@ struct rtl8169_private {
 MODULE_AUTHOR("Realtek");
 MODULE_DESCRIPTION("RealTek RTL-8169 Gigabit Ethernet driver");
 MODULE_PARM(media, "1-" __MODULE_STRING(MAX_UNITS) "i");
+MODULE_PARM(rx_copybreak, "i");
 
 static int rtl8169_open(struct net_device *dev);
 static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev);
@@ -771,6 +774,11 @@ static void rtl8169_free_rx_skb(struct p
 	rtl8169_make_unusable_by_asic(desc);
 }
 
+static inline void rtl8169_return_to_asic(struct RxDesc *desc)
+{
+	desc->status |= OWNbit + RX_BUF_SIZE;
+}
+
 static inline void rtl8169_give_to_asic(struct RxDesc *desc, dma_addr_t mapping)
 {
 	desc->buf_addr = mapping;
@@ -1015,12 +1023,26 @@ rtl8169_tx_interrupt(struct net_device *
 	}
 }
 
-static inline void rtl8169_unmap_rx(struct pci_dev *pdev, struct RxDesc *desc)
+static inline int rtl8169_try_rx_copy(struct sk_buff **sk_buff, int pkt_size,
+				      struct RxDesc *desc,
+				      struct net_device *dev)
 {
-	pci_dma_sync_single(pdev, le32_to_cpu(desc->buf_addr), RX_BUF_SIZE,
-			    PCI_DMA_FROMDEVICE);
-	pci_unmap_single(pdev, le32_to_cpu(desc->buf_addr), RX_BUF_SIZE,
-			 PCI_DMA_FROMDEVICE);
+	int ret = -1;
+
+	if (pkt_size < rx_copybreak) {
+		struct sk_buff *skb;
+
+		skb = dev_alloc_skb(pkt_size + 2);
+		if (skb) {
+			skb->dev = dev;
+			skb_reserve(skb, 2);
+			eth_copy_and_sum(skb, sk_buff[0]->tail, pkt_size, 0);
+			*sk_buff = skb;
+			rtl8169_return_to_asic(desc);
+			ret = 0;
+		}
+	}
+	return ret;
 }
 
 static void
@@ -1046,17 +1068,26 @@ rtl8169_rx_interrupt(struct net_device *
 			if (status & RxCRC)
 				tp->stats.rx_crc_errors++;
 		} else {
+			struct RxDesc *desc = tp->RxDescArray + cur_rx;
 			struct sk_buff *skb = tp->Rx_skbuff[cur_rx];
 			int pkt_size = (status & 0x00001FFF) - 4;
 
-			rtl8169_unmap_rx(tp->pci_dev, tp->RxDescArray + cur_rx);
+			pci_dma_sync_single(tp->pci_dev,
+					    le32_to_cpu(desc->buf_addr),
+					    RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
+
+			if (rtl8169_try_rx_copy(&skb, pkt_size, desc, dev)) {
+				pci_unmap_single(tp->pci_dev,
+						 le32_to_cpu(desc->buf_addr),
+						 RX_BUF_SIZE,
+						 PCI_DMA_FROMDEVICE);
+				tp->Rx_skbuff[cur_rx] = NULL;
+			}
 
 			skb_put(skb, pkt_size);
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
 
-			tp->Rx_skbuff[cur_rx] = NULL;
-
 			dev->last_rx = jiffies;
 			tp->stats.rx_bytes += pkt_size;
 			tp->stats.rx_packets++;

_

--4Ckj6UjgE2iN1+kY--

From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patches] 2.6.0-test9 - r8169 DMA API conversion
Date: Sat, 22 Nov 2003 00:20:02 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031122002002.A12448@electric-eye.fr.zoreil.com>
References: <47973.68.105.173.45.1069042089.squirrel@mail.mainstreetsoftworks.com> <3FB9A277.70309@pobox.com> <20031118135848.A2451@electric-eye.fr.zoreil.com> <3FBBA76B.4070606@pobox.com> <20031120010056.A19444@electric-eye.fr.zoreil.com> <20031121013637.B31929@electric-eye.fr.zoreil.com> <3FBD6C9D.3000207@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="bp/iNruPH9dso1Pn"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <3FBD6C9D.3000207@pobox.com>; from jgarzik@pobox.com on Thu, Nov 20, 2003 at 08:38:37PM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Jeff Garzik <jgarzik@pobox.com> :
> The rx_copybreak didn't apply, but everything else did.  Thanks much. 

Oops, I forgot there was an extra MODULE_LICENSE() in net-drivers-2.5-exp.

> Just posted a new net-drivers-2.5-exp patch, to which you may sync with.

Updated rx_copybreak attached.

--
Ueimor

--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="r8169-rx_copybreak.patch"


Rx copybreak for small packets.
- removal of rtl8169_unmap_rx() (unneeded as for now).


 drivers/net/r8169.c |   47 +++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 39 insertions(+), 8 deletions(-)

diff -puN drivers/net/r8169.c~r8169-rx_copybreak drivers/net/r8169.c
--- linux-2.6.0-test9-bk24-netdrvr-exp3/drivers/net/r8169.c~r8169-rx_copybreak	2003-11-22 00:14:22.000000000 +0100
+++ linux-2.6.0-test9-bk24-netdrvr-exp3-fr/drivers/net/r8169.c	2003-11-22 00:14:37.000000000 +0100
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
 MODULE_LICENSE("GPL");
 
 static int rtl8169_open(struct net_device *dev);
@@ -772,6 +775,11 @@ static void rtl8169_free_rx_skb(struct p
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
@@ -1016,12 +1024,26 @@ rtl8169_tx_interrupt(struct net_device *
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
@@ -1047,17 +1069,26 @@ rtl8169_rx_interrupt(struct net_device *
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

--bp/iNruPH9dso1Pn--

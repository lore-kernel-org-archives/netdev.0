From: "Ravinandan Arakali" <ravinandan.arakali@s2io.com>
Subject: [PATCH 2.6.9-rc2 10/12] S2io: 2 buffer mode with copy
Date: Thu, 28 Oct 2004 15:51:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <004501c4bd40$ae5529f0$9810100a@S2IOtech.com>
Reply-To: <ravinandan.arakali@s2io.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <leonid.grossman@s2io.com>,
        <raghavendra.koushik@s2io.com>, <rapuru.sriram@s2io.com>,
        <alicia.pena@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>,
        "'Francois Romieu'" <romieu@fr.zoreil.com>
In-reply-to: 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi All,
This patch addresses the comments by Chris Leech about skb->mac.ethernet
resulting in NULL dereference with the old method of implementing 2 buffer
mode. The new method performs a copy of the MAC header to the head of
the payload. This is a stop-gap measure till the fragmented skb receive
feature in the kernel is made functional.
Also, using GFP_KERNEL flag for buffer0, buffer1 memory allocation instead 
of GFP_ATOMIC.

Signed-off-by: Raghavendra Koushik <raghavendra.koushik@s2io.com>
Signed-off-by: Ravinandan Arakali <ravinandan.arakali@s2io.com>
---
diff -urN vanilla-linux/drivers/net/s2io.c linux-2.6.8.1/drivers/net/s2io.c
--- vanilla-linux/drivers/net/s2io.c	2004-10-26 16:40:58.271982080 -0700
+++ linux-2.6.8.1/drivers/net/s2io.c	2004-10-26 16:40:42.944312240 -0700
@@ -497,7 +497,7 @@
 				ba = &nic->ba[i][j][k];
 
 				ba->ba_0_org = (void *) kmalloc
-				    (BUF0_LEN + ALIGN_SIZE, GFP_ATOMIC);
+				    (BUF0_LEN + ALIGN_SIZE, GFP_KERNEL);
 				if (!ba->ba_0_org)
 					return -ENOMEM;
 				tmp = (u64) ba->ba_0_org;
@@ -506,7 +506,7 @@
 				ba->ba_0 = (void *) tmp;
 
 				ba->ba_1_org = (void *) kmalloc
-				    (BUF1_LEN + ALIGN_SIZE, GFP_ATOMIC);
+				    (BUF1_LEN + ALIGN_SIZE, GFP_KERNEL);
 				if (!ba->ba_1_org)
 					return -ENOMEM;
 				tmp = (u64) ba->ba_1_org;
@@ -1791,8 +1791,7 @@
 #ifndef	CONFIG_2BUFF_MODE
 		skb = dev_alloc_skb(size + NET_IP_ALIGN);
 #else
-		skb = dev_alloc_skb(dev->mtu + ALIGN_SIZE +
-				    /*BUF0_LEN + */ 22);
+		skb = dev_alloc_skb(dev->mtu + ALIGN_SIZE + BUF0_LEN + 4);
 #endif
 		if (!skb) {
 			DBG_PRINT(ERR_DBG, "%s: Out of ", dev->name);
@@ -1813,14 +1812,16 @@
 		mac_control->rx_curr_put_info[ring_no].offset = off;
 #else
 		ba = &nic->ba[ring_no][block_no][off];
+		skb_reserve(skb, BUF0_LEN);
 		tmp = (u64) skb->data;
 		tmp += ALIGN_SIZE;
 		tmp &= ~ALIGN_SIZE;
 		skb->data = (void *) tmp;
+		skb->tail = (void *) tmp;
 
 		memset(rxdp, 0, sizeof(RxD_t));
 		rxdp->Buffer2_ptr = pci_map_single
-		    (nic->pdev, skb->data, dev->mtu + 22,
+		    (nic->pdev, skb->data, dev->mtu + BUF0_LEN + 4,
 		     PCI_DMA_FROMDEVICE);
 		rxdp->Buffer0_ptr =
 		    pci_map_single(nic->pdev, ba->ba_0, BUF0_LEN,
@@ -1829,7 +1830,7 @@
 		    pci_map_single(nic->pdev, ba->ba_1, BUF1_LEN,
 				   PCI_DMA_FROMDEVICE);
 
-		rxdp->Control_2 = SET_BUFFER2_SIZE(dev->mtu + 22);
+		rxdp->Control_2 = SET_BUFFER2_SIZE(dev->mtu + 4);
 		rxdp->Control_2 |= SET_BUFFER0_SIZE(BUF0_LEN);
 		rxdp->Control_2 |= SET_BUFFER1_SIZE(1);	/* dummy. */
 		rxdp->Control_2 |= BIT(0);	/* Set Buffer_Empty bit. */
@@ -1919,7 +1920,7 @@
 						 PCI_DMA_FROMDEVICE);
 				pci_unmap_single(sp->pdev, (dma_addr_t)
 						 rxdp->Buffer2_ptr,
-						 dev->mtu + 22,
+						 dev->mtu + BUF0_LEN + 4,
 						 PCI_DMA_FROMDEVICE);
 #endif
 				dev_kfree_skb(skb);
@@ -2073,7 +2074,7 @@
 					 BUF1_LEN, PCI_DMA_FROMDEVICE);
 			pci_unmap_single(nic->pdev, (dma_addr_t)
 					 rxdp->Buffer2_ptr,
-					 dev->mtu + 22,
+					 dev->mtu + BUF0_LEN + 4,
 					 PCI_DMA_FROMDEVICE);
 			ba = &nic->ba[i][get_block][get_info.offset];
 
@@ -2270,7 +2271,7 @@
 					 BUF1_LEN, PCI_DMA_FROMDEVICE);
 			pci_unmap_single(nic->pdev, (dma_addr_t)
 					 rxdp->Buffer2_ptr,
-					 dev->mtu + 22,
+					 dev->mtu + BUF0_LEN + 4,
 					 PCI_DMA_FROMDEVICE);
 			ba = &nic->ba[i][get_block][get_info.offset];
 
@@ -4471,7 +4472,7 @@
 	u16 l3_csum, l4_csum;
 #ifdef CONFIG_2BUFF_MODE
 	int buf0_len, buf2_len;
-	struct ethhdr *eth = (struct ethhdr *) ba->ba_0;
+	unsigned char *buff;
 #endif
 
 	l3_csum = RXD_GET_L3_CKSUM(rxdp->Control_1);
@@ -4510,21 +4511,10 @@
 	skb_put(skb, len);
 	skb->protocol = eth_type_trans(skb, dev);
 #else
+	buff = skb_push(skb, buf0_len);
+	memcpy(buff, ba->ba_0, buf0_len);
 	skb_put(skb, buf2_len);
-	/* 
-	 * Reproducing eth_type_trans functionality and running
-	 * on the ethernet header 'eth' stripped and given to us
-	 * by the hardware in 2Buff mode.
-	 */
-	if (*eth->h_dest & 1) {
-		if (!memcmp(eth->h_dest, dev->broadcast, ETH_ALEN))
-			skb->pkt_type = PACKET_BROADCAST;
-		else
-			skb->pkt_type = PACKET_MULTICAST;
-	} else if (memcmp(eth->h_dest, dev->dev_addr, ETH_ALEN)) {
-		skb->pkt_type = PACKET_OTHERHOST;
-	}
-	skb->protocol = eth->h_proto;
+	skb->protocol = eth_type_trans(skb, dev);
 #endif
 
 #ifdef CONFIG_S2IO_NAPI

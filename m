From: David Miller <davem@davemloft.net>
Subject: [PATCH RFC 01/12] s2io: Remove UFO support.
Date: Wed, 05 Jul 2017 16:04:09 +0100 (WEST)
Message-ID: <20170705.160409.713364759007084379.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42534 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751716AbdGEPEO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 11:04:14 -0400
Received: from localhost (unknown [193.136.225.129])
        (using TLSv1 with cipher AES256-SHA (256/256 bits))
        (Client did not present a certificate)
        (Authenticated sender: davem-davemloft)
        by shards.monkeyblade.net (Postfix) with ESMTPSA id 106A3126C97E4
        for <netdev@vger.kernel.org>; Wed,  5 Jul 2017 08:04:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/neterion/s2io.c | 45 ------------------------------------
 1 file changed, 45 deletions(-)

diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index fd2ec36..462eda9 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -42,8 +42,6 @@
  *     aggregated as a single large packet
  * napi: This parameter used to enable/disable NAPI (polling Rx)
  *     Possible values '1' for enable and '0' for disable. Default is '1'
- * ufo: This parameter used to enable/disable UDP Fragmentation Offload(UFO)
- *      Possible values '1' for enable and '0' for disable. Default is '0'
  * vlan_tag_strip: This can be used to enable or disable vlan stripping.
  *                 Possible values '1' for enable , '0' for disable.
  *                 Default is '2' - which means disable in promisc mode
@@ -453,7 +451,6 @@ S2IO_PARM_INT(lro_max_pkts, 0xFFFF);
 S2IO_PARM_INT(indicate_max_pkts, 0);
 
 S2IO_PARM_INT(napi, 1);
-S2IO_PARM_INT(ufo, 0);
 S2IO_PARM_INT(vlan_tag_strip, NO_STRIP_IN_PROMISC);
 
 static unsigned int tx_fifo_len[MAX_TX_FIFOS] =
@@ -4128,32 +4125,6 @@ static netdev_tx_t s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	frg_len = skb_headlen(skb);
-	if (offload_type == SKB_GSO_UDP) {
-		int ufo_size;
-
-		ufo_size = s2io_udp_mss(skb);
-		ufo_size &= ~7;
-		txdp->Control_1 |= TXD_UFO_EN;
-		txdp->Control_1 |= TXD_UFO_MSS(ufo_size);
-		txdp->Control_1 |= TXD_BUFFER0_SIZE(8);
-#ifdef __BIG_ENDIAN
-		/* both variants do cpu_to_be64(be32_to_cpu(...)) */
-		fifo->ufo_in_band_v[put_off] =
-			(__force u64)skb_shinfo(skb)->ip6_frag_id;
-#else
-		fifo->ufo_in_band_v[put_off] =
-			(__force u64)skb_shinfo(skb)->ip6_frag_id << 32;
-#endif
-		txdp->Host_Control = (unsigned long)fifo->ufo_in_band_v;
-		txdp->Buffer_Pointer = pci_map_single(sp->pdev,
-						      fifo->ufo_in_band_v,
-						      sizeof(u64),
-						      PCI_DMA_TODEVICE);
-		if (pci_dma_mapping_error(sp->pdev, txdp->Buffer_Pointer))
-			goto pci_map_failed;
-		txdp++;
-	}
-
 	txdp->Buffer_Pointer = pci_map_single(sp->pdev, skb->data,
 					      frg_len, PCI_DMA_TODEVICE);
 	if (pci_dma_mapping_error(sp->pdev, txdp->Buffer_Pointer))
@@ -4161,8 +4132,6 @@ static netdev_tx_t s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	txdp->Host_Control = (unsigned long)skb;
 	txdp->Control_1 |= TXD_BUFFER0_SIZE(frg_len);
-	if (offload_type == SKB_GSO_UDP)
-		txdp->Control_1 |= TXD_UFO_EN;
 
 	frg_cnt = skb_shinfo(skb)->nr_frags;
 	/* For fragmented SKB. */
@@ -4177,14 +4146,9 @@ static netdev_tx_t s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 							     skb_frag_size(frag),
 							     DMA_TO_DEVICE);
 		txdp->Control_1 = TXD_BUFFER0_SIZE(skb_frag_size(frag));
-		if (offload_type == SKB_GSO_UDP)
-			txdp->Control_1 |= TXD_UFO_EN;
 	}
 	txdp->Control_1 |= TXD_GATHER_CODE_LAST;
 
-	if (offload_type == SKB_GSO_UDP)
-		frg_cnt++; /* as Txd0 was used for inband header */
-
 	tx_fifo = mac_control->tx_FIFO_start[queue];
 	val64 = fifo->list_info[put_off].list_phy_addr;
 	writeq(val64, &tx_fifo->TxDL_Pointer);
@@ -7910,11 +7874,6 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 		NETIF_F_RXCSUM | NETIF_F_LRO;
 	dev->features |= dev->hw_features |
 		NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
-	if (sp->device_type & XFRAME_II_DEVICE) {
-		dev->hw_features |= NETIF_F_UFO;
-		if (ufo)
-			dev->features |= NETIF_F_UFO;
-	}
 	if (sp->high_dma_flag == true)
 		dev->features |= NETIF_F_HIGHDMA;
 	dev->watchdog_timeo = WATCH_DOG_TIMEOUT;
@@ -8147,10 +8106,6 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 
 	DBG_PRINT(ERR_DBG, "%s: Large receive offload enabled\n",
 		  dev->name);
-	if (ufo)
-		DBG_PRINT(ERR_DBG,
-			  "%s: UDP Fragmentation Offload(UFO) enabled\n",
-			  dev->name);
 	/* Initialize device name */
 	snprintf(sp->name, sizeof(sp->name), "%s Neterion %s", dev->name,
 		 sp->product_name);
-- 
2.9.4

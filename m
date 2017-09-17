From: Roman Yeryomin <leroi.lists@gmail.com>
Subject: [PATCH net-next v2 2/7] net: korina: optimize rx descriptor flags processing
Date: Sun, 17 Sep 2017 20:24:26 +0300
Message-ID: <20170917172426.32345-1-roman@advem.lv>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:37719 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751554AbdIQRY2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 17 Sep 2017 13:24:28 -0400
Received: by mail-lf0-f66.google.com with SMTP id q132so3432956lfe.4
        for <netdev@vger.kernel.org>; Sun, 17 Sep 2017 10:24:27 -0700 (PDT)
Received: from ubrain.corp.ubnt.com ([2a02:16d8:105:4000:76d4:35ff:fe88:7631])
        by smtp.googlemail.com with ESMTPSA id 34sm1136538lfy.54.2017.09.17.10.24.26
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Sep 2017 10:24:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Yeryomin <roman@advem.lv>
---
 drivers/net/ethernet/korina.c | 87 ++++++++++++++++++++++---------------------
 1 file changed, 44 insertions(+), 43 deletions(-)

diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index 98d686ed69a9..e5466e19994a 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -363,59 +363,60 @@ static int korina_rx(struct net_device *dev, int limit)
 		if ((KORINA_RBSIZE - (u32)DMA_COUNT(rd->control)) == 0)
 			break;
 
-		/* Update statistics counters */
-		if (devcs & ETH_RX_CRC)
-			dev->stats.rx_crc_errors++;
-		if (devcs & ETH_RX_LOR)
-			dev->stats.rx_length_errors++;
-		if (devcs & ETH_RX_LE)
-			dev->stats.rx_length_errors++;
-		if (devcs & ETH_RX_OVR)
-			dev->stats.rx_fifo_errors++;
-		if (devcs & ETH_RX_CV)
-			dev->stats.rx_frame_errors++;
-		if (devcs & ETH_RX_CES)
-			dev->stats.rx_length_errors++;
-		if (devcs & ETH_RX_MP)
-			dev->stats.multicast++;
-
-		if ((devcs & ETH_RX_LD) != ETH_RX_LD) {
-			/* check that this is a whole packet
-			 * WARNING: DMA_FD bit incorrectly set
-			 * in Rc32434 (errata ref #077) */
+		/* check that this is a whole packet
+		 * WARNING: DMA_FD bit incorrectly set
+		 * in Rc32434 (errata ref #077) */
+		if (!(devcs & ETH_RX_LD))
+			goto next;
+
+		if (!(devcs & ETH_RX_ROK)) {
+			/* Update statistics counters */
 			dev->stats.rx_errors++;
 			dev->stats.rx_dropped++;
-		} else if ((devcs & ETH_RX_ROK)) {
-			pkt_len = RCVPKT_LENGTH(devcs);
+			if (devcs & ETH_RX_CRC)
+				dev->stats.rx_crc_errors++;
+			if (devcs & ETH_RX_LE)
+				dev->stats.rx_length_errors++;
+			if (devcs & ETH_RX_OVR)
+				dev->stats.rx_fifo_errors++;
+			if (devcs & ETH_RX_CV)
+				dev->stats.rx_frame_errors++;
+			if (devcs & ETH_RX_CES)
+				dev->stats.rx_frame_errors++;
+
+			goto next;
+		}
 
-			/* must be the (first and) last
-			 * descriptor then */
-			pkt_buf = (u8 *)lp->rx_skb[lp->rx_next_done]->data;
+		pkt_len = RCVPKT_LENGTH(devcs);
 
-			/* invalidate the cache */
-			dma_cache_inv((unsigned long)pkt_buf, pkt_len - 4);
+		/* must be the (first and) last
+		 * descriptor then */
+		pkt_buf = (u8 *)lp->rx_skb[lp->rx_next_done]->data;
 
-			/* Malloc up new buffer. */
-			skb_new = netdev_alloc_skb_ip_align(dev, KORINA_RBSIZE);
+		/* invalidate the cache */
+		dma_cache_inv((unsigned long)pkt_buf, pkt_len - 4);
 
-			if (!skb_new)
-				break;
-			/* Do not count the CRC */
-			skb_put(skb, pkt_len - 4);
-			skb->protocol = eth_type_trans(skb, dev);
+		/* Malloc up new buffer. */
+		skb_new = netdev_alloc_skb_ip_align(dev, KORINA_RBSIZE);
 
-			/* Pass the packet to upper layers */
-			netif_receive_skb(skb);
-			dev->stats.rx_packets++;
-			dev->stats.rx_bytes += pkt_len;
+		if (!skb_new)
+			break;
+		/* Do not count the CRC */
+		skb_put(skb, pkt_len - 4);
+		skb->protocol = eth_type_trans(skb, dev);
 
-			/* Update the mcast stats */
-			if (devcs & ETH_RX_MP)
-				dev->stats.multicast++;
+		/* Pass the packet to upper layers */
+		netif_receive_skb(skb);
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += pkt_len;
 
-			lp->rx_skb[lp->rx_next_done] = skb_new;
-		}
+		/* Update the mcast stats */
+		if (devcs & ETH_RX_MP)
+			dev->stats.multicast++;
+
+		lp->rx_skb[lp->rx_next_done] = skb_new;
 
+next:
 		rd->devcs = 0;
 
 		/* Restore descriptor's curr_addr */
-- 
2.11.0

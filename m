From: Ron Angeles <ronangeles@gmail.com>
Subject: [PATCH net-next] net: atl1c: add BQL support
Date: Tue, 11 Aug 2015 23:01:20 -0700
Message-ID: <55CAE130.8040406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:35173 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933719AbbHLGBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 02:01:24 -0400
Received: by pdrg1 with SMTP id g1so3640793pdr.2
        for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 23:01:23 -0700 (PDT)
Received: from [172.16.100.189] (c-76-126-252-17.hsd1.ca.comcast.net. [76.126.252.17])
        by smtp.googlemail.com with ESMTPSA id z8sm4913635pas.42.2015.08.11.23.01.21
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Aug 2015 23:01:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This BQL implementation is mostly derived from its related driver, alx.
Tested on AR8131 (rev c0) [1969:1063]. Saturated a 100mbps link with 5
concurrent runs of netperf. Ping latency dropped from 14ms to 3ms.

Signed-off-by: Ron Angeles <ronangeles@gmail.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 932bd18..2795d6d 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -874,6 +874,8 @@ static void atl1c_clean_tx_ring(struct atl1c_adapter *adapter,
 		atl1c_clean_buffer(pdev, buffer_info);
 	}
 
+	netdev_reset_queue(adapter->netdev);
+
 	/* Zero out Tx-buffers */
 	memset(tpd_ring->desc, 0, sizeof(struct atl1c_tpd_desc) *
 		ring_count);
@@ -1551,6 +1553,7 @@ static bool atl1c_clean_tx_irq(struct atl1c_adapter *adapter,
 	u16 next_to_clean = atomic_read(&tpd_ring->next_to_clean);
 	u16 hw_next_to_clean;
 	u16 reg;
+	unsigned int total_bytes = 0, total_packets = 0;
 
 	reg = type == atl1c_trans_high ? REG_TPD_PRI1_CIDX : REG_TPD_PRI0_CIDX;
 
@@ -1558,12 +1561,18 @@ static bool atl1c_clean_tx_irq(struct atl1c_adapter *adapter,
 
 	while (next_to_clean != hw_next_to_clean) {
 		buffer_info = &tpd_ring->buffer_info[next_to_clean];
+		if (buffer_info->skb) {
+			total_bytes += buffer_info->skb->len;
+			total_packets++;
+		}
 		atl1c_clean_buffer(pdev, buffer_info);
 		if (++next_to_clean == tpd_ring->count)
 			next_to_clean = 0;
 		atomic_set(&tpd_ring->next_to_clean, next_to_clean);
 	}
 
+	netdev_completed_queue(adapter->netdev, total_packets, total_bytes);
+
 	if (netif_queue_stopped(adapter->netdev) &&
 			netif_carrier_ok(adapter->netdev)) {
 		netif_wake_queue(adapter->netdev);
@@ -2256,6 +2265,7 @@ static netdev_tx_t atl1c_xmit_frame(struct sk_buff *skb,
 		spin_unlock_irqrestore(&adapter->tx_lock, flags);
 		dev_kfree_skb_any(skb);
 	} else {
+		netdev_sent_queue(adapter->netdev, skb->len);
 		atl1c_tx_queue(adapter, skb, tpd, type);
 		spin_unlock_irqrestore(&adapter->tx_lock, flags);
 	}
-- 
2.4.6

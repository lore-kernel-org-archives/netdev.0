From: Ondrej Puzman <puzman@gmail.com>
Subject: [PATCH] pch_gbe: Add DQL support to the driver
Date: Thu, 28 Nov 2013 00:29:09 +0100
Message-ID: <1385594950-2662-3-git-send-email-puzman@gmail.com>
References: <1385594950-2662-1-git-send-email-puzman@gmail.com>
 <1385594950-2662-2-git-send-email-puzman@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ondrej Puzman <puzman@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1385594950-2662-2-git-send-email-puzman@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add dynamic queue limits support to the driver.

Signed-off-by: Ondrej Puzman <puzman@gmail.com>
---
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index d967603..2c14e2e 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -994,6 +994,8 @@ static void pch_gbe_clean_tx_ring(struct pch_gbe_adapter *adapter,
 	netdev_dbg(adapter->netdev,
 		   "call pch_gbe_unmap_and_free_tx_resource() %d count\n", i);
 
+	netdev_reset_queue(adapter->netdev);
+
 	size = (unsigned long)sizeof(struct pch_gbe_buffer) * tx_ring->count;
 	memset(tx_ring->buffer_info, 0, size);
 
@@ -1544,6 +1546,7 @@ pch_gbe_clean_tx(struct pch_gbe_adapter *adapter,
 	unsigned int cleaned_count = 0;
 	bool cleaned = false;
 	int unused, thresh;
+	unsigned int bytes_compl = 0, pkts_compl = 0;
 
 	netdev_dbg(adapter->netdev, "next_to_clean : %d\n",
 		   tx_ring->next_to_clean);
@@ -1622,6 +1625,8 @@ pch_gbe_clean_tx(struct pch_gbe_adapter *adapter,
 			buffer_info->mapped = false;
 		}
 		if (buffer_info->skb) {
+			bytes_compl += buffer_info->skb->len;
+			pkts_compl++;
 			netdev_dbg(adapter->netdev,
 				   "trim buffer_info->skb : %d\n", i);
 			skb_trim(buffer_info->skb, 0);
@@ -1641,6 +1646,9 @@ pch_gbe_clean_tx(struct pch_gbe_adapter *adapter,
 		   "called pch_gbe_unmap_and_free_tx_resource() %d count\n",
 		   cleaned_count);
 	if (cleaned_count > 0)  { /*skip this if nothing cleaned*/
+		netdev_completed_queue(adapter->netdev,
+				       pkts_compl, bytes_compl);
+
 		/* Recover from running out of Tx resources in xmit_frame */
 		spin_lock(&tx_ring->tx_lock);
 		if (unlikely(cleaned && (netif_queue_stopped(adapter->netdev))))
@@ -2152,6 +2160,7 @@ static int pch_gbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	/* CRC,ITAG no support */
 	pch_gbe_tx_queue(adapter, tx_ring, skb);
+	netdev_sent_queue(netdev, skb->len);
 
 	if (unlikely(!PCH_GBE_DESC_UNUSED(tx_ring)))
 		netif_stop_queue(netdev);
-- 
1.5.6.5

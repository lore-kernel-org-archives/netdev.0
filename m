From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/9] e1000e: Be drop monitor friendly
Date: Tue, 10 Oct 2017 10:21:38 -0700
Message-ID: <20171010172139.77914-9-jeffrey.t.kirsher@intel.com>
References: <20171010172139.77914-1-jeffrey.t.kirsher@intel.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:65517 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932566AbdJJRWC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Oct 2017 13:22:02 -0400
In-Reply-To: <20171010172139.77914-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>

e1000e_put_txbuf() can be called from normal reclamation path as well as
when a DMA mapping failure, so we need to differentiate these two cases
when freeing SKBs to be drop monitor friendly. e1000e_tx_hwtstamp_work()
and e1000_remove() are processing TX timestamped SKBs and those should
not be accounted as drops either.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 00f48d4cabec..bf8f38f76953 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1071,7 +1071,8 @@ static bool e1000_clean_rx_irq(struct e1000_ring *rx_ring, int *work_done,
 }
 
 static void e1000_put_txbuf(struct e1000_ring *tx_ring,
-			    struct e1000_buffer *buffer_info)
+			    struct e1000_buffer *buffer_info,
+			    bool drop)
 {
 	struct e1000_adapter *adapter = tx_ring->adapter;
 
@@ -1085,7 +1086,10 @@ static void e1000_put_txbuf(struct e1000_ring *tx_ring,
 		buffer_info->dma = 0;
 	}
 	if (buffer_info->skb) {
-		dev_kfree_skb_any(buffer_info->skb);
+		if (drop)
+			dev_kfree_skb_any(buffer_info->skb);
+		else
+			dev_consume_skb_any(buffer_info->skb);
 		buffer_info->skb = NULL;
 	}
 	buffer_info->time_stamp = 0;
@@ -1199,7 +1203,7 @@ static void e1000e_tx_hwtstamp_work(struct work_struct *work)
 		wmb(); /* force write prior to skb_tstamp_tx */
 
 		skb_tstamp_tx(skb, &shhwtstamps);
-		dev_kfree_skb_any(skb);
+		dev_consume_skb_any(skb);
 	} else if (time_after(jiffies, adapter->tx_hwtstamp_start
 			      + adapter->tx_timeout_factor * HZ)) {
 		dev_kfree_skb_any(adapter->tx_hwtstamp_skb);
@@ -1254,7 +1258,7 @@ static bool e1000_clean_tx_irq(struct e1000_ring *tx_ring)
 				}
 			}
 
-			e1000_put_txbuf(tx_ring, buffer_info);
+			e1000_put_txbuf(tx_ring, buffer_info, false);
 			tx_desc->upper.data = 0;
 
 			i++;
@@ -2437,7 +2441,7 @@ static void e1000_clean_tx_ring(struct e1000_ring *tx_ring)
 
 	for (i = 0; i < tx_ring->count; i++) {
 		buffer_info = &tx_ring->buffer_info[i];
-		e1000_put_txbuf(tx_ring, buffer_info);
+		e1000_put_txbuf(tx_ring, buffer_info, false);
 	}
 
 	netdev_reset_queue(adapter->netdev);
@@ -5625,7 +5629,7 @@ static int e1000_tx_map(struct e1000_ring *tx_ring, struct sk_buff *skb,
 			i += tx_ring->count;
 		i--;
 		buffer_info = &tx_ring->buffer_info[i];
-		e1000_put_txbuf(tx_ring, buffer_info);
+		e1000_put_txbuf(tx_ring, buffer_info, true);
 	}
 
 	return 0;
@@ -7419,7 +7423,7 @@ static void e1000_remove(struct pci_dev *pdev)
 	if (adapter->flags & FLAG_HAS_HW_TIMESTAMP) {
 		cancel_work_sync(&adapter->tx_hwtstamp_work);
 		if (adapter->tx_hwtstamp_skb) {
-			dev_kfree_skb_any(adapter->tx_hwtstamp_skb);
+			dev_consume_skb_any(adapter->tx_hwtstamp_skb);
 			adapter->tx_hwtstamp_skb = NULL;
 		}
 	}
-- 
2.14.2

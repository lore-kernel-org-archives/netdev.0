From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] ath6kl: Use net_device_stats from struct net_device
Date: Thu,  9 Feb 2017 12:21:17 +0100
Message-ID: <20170209112117.23994-1-tklauser@distanz.ch>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:52096 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752029AbdBILgI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Feb 2017 06:36:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using a private copy of struct net_device_stats in struct
ath6kl_vif, use stats from struct net_device. Also remove the now
unnecessary .ndo_get_stats function.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/wireless/ath/ath6kl/core.h |  1 -
 drivers/net/wireless/ath/ath6kl/main.c |  8 --------
 drivers/net/wireless/ath/ath6kl/txrx.c | 22 +++++++++++-----------
 3 files changed, 11 insertions(+), 20 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/core.h b/drivers/net/wireless/ath/ath6kl/core.h
index ac25f1781b42..87e99c12d4ba 100644
--- a/drivers/net/wireless/ath/ath6kl/core.h
+++ b/drivers/net/wireless/ath/ath6kl/core.h
@@ -641,7 +641,6 @@ struct ath6kl_vif {
 	u32 txe_intvl;
 	u16 bg_scan_period;
 	u8 assoc_bss_dtim_period;
-	struct net_device_stats net_stats;
 	struct target_stats target_stats;
 	struct wmi_connect_cmd profile;
 	u16 rsn_capab;
diff --git a/drivers/net/wireless/ath/ath6kl/main.c b/drivers/net/wireless/ath/ath6kl/main.c
index 1af3fed5a72c..91ee542de3d7 100644
--- a/drivers/net/wireless/ath/ath6kl/main.c
+++ b/drivers/net/wireless/ath/ath6kl/main.c
@@ -1113,13 +1113,6 @@ static int ath6kl_close(struct net_device *dev)
 	return 0;
 }
 
-static struct net_device_stats *ath6kl_get_stats(struct net_device *dev)
-{
-	struct ath6kl_vif *vif = netdev_priv(dev);
-
-	return &vif->net_stats;
-}
-
 static int ath6kl_set_features(struct net_device *dev,
 			       netdev_features_t features)
 {
@@ -1285,7 +1278,6 @@ static const struct net_device_ops ath6kl_netdev_ops = {
 	.ndo_open               = ath6kl_open,
 	.ndo_stop               = ath6kl_close,
 	.ndo_start_xmit         = ath6kl_data_tx,
-	.ndo_get_stats          = ath6kl_get_stats,
 	.ndo_set_features       = ath6kl_set_features,
 	.ndo_set_rx_mode	= ath6kl_set_multicast_list,
 };
diff --git a/drivers/net/wireless/ath/ath6kl/txrx.c b/drivers/net/wireless/ath/ath6kl/txrx.c
index 9df41d5e3249..a531e0c5c1e2 100644
--- a/drivers/net/wireless/ath/ath6kl/txrx.c
+++ b/drivers/net/wireless/ath/ath6kl/txrx.c
@@ -405,7 +405,7 @@ int ath6kl_data_tx(struct sk_buff *skb, struct net_device *dev)
 			skb = skb_realloc_headroom(skb, dev->needed_headroom);
 			kfree_skb(tmp_skb);
 			if (skb == NULL) {
-				vif->net_stats.tx_dropped++;
+				dev->stats.tx_dropped++;
 				return 0;
 			}
 		}
@@ -520,8 +520,8 @@ int ath6kl_data_tx(struct sk_buff *skb, struct net_device *dev)
 fail_tx:
 	dev_kfree_skb(skb);
 
-	vif->net_stats.tx_dropped++;
-	vif->net_stats.tx_aborted_errors++;
+	dev->stats.tx_dropped++;
+	dev->stats.tx_aborted_errors++;
 
 	return 0;
 }
@@ -767,7 +767,7 @@ void ath6kl_tx_complete(struct htc_target *target,
 				/* a packet was flushed  */
 				flushing[if_idx] = true;
 
-			vif->net_stats.tx_errors++;
+			vif->ndev->stats.tx_errors++;
 
 			if (status != -ENOSPC && status != -ECANCELED)
 				ath6kl_warn("tx complete error: %d\n", status);
@@ -783,8 +783,8 @@ void ath6kl_tx_complete(struct htc_target *target,
 				   eid, "OK");
 
 			flushing[if_idx] = false;
-			vif->net_stats.tx_packets++;
-			vif->net_stats.tx_bytes += skb->len;
+			vif->ndev->stats.tx_packets++;
+			vif->ndev->stats.tx_bytes += skb->len;
 		}
 
 		ath6kl_tx_clear_node_map(vif, eid, map_no);
@@ -1365,8 +1365,8 @@ void ath6kl_rx(struct htc_target *target, struct htc_packet *packet)
 	 */
 	spin_lock_bh(&vif->if_lock);
 
-	vif->net_stats.rx_packets++;
-	vif->net_stats.rx_bytes += packet->act_len;
+	vif->ndev->stats.rx_packets++;
+	vif->ndev->stats.rx_bytes += packet->act_len;
 
 	spin_unlock_bh(&vif->if_lock);
 
@@ -1395,8 +1395,8 @@ void ath6kl_rx(struct htc_target *target, struct htc_packet *packet)
 	    ((packet->act_len < min_hdr_len) ||
 	     (packet->act_len > WMI_MAX_AMSDU_RX_DATA_FRAME_LENGTH))) {
 		ath6kl_info("frame len is too short or too long\n");
-		vif->net_stats.rx_errors++;
-		vif->net_stats.rx_length_errors++;
+		vif->ndev->stats.rx_errors++;
+		vif->ndev->stats.rx_length_errors++;
 		dev_kfree_skb(skb);
 		return;
 	}
@@ -1619,7 +1619,7 @@ void ath6kl_rx(struct htc_target *target, struct htc_packet *packet)
 			return;
 		}
 	} else if (!is_broadcast_ether_addr(datap->h_dest)) {
-		vif->net_stats.multicast++;
+		vif->ndev->stats.multicast++;
 	}
 
 	ath6kl_deliver_frames_to_nw_stack(vif->ndev, skb);
-- 
2.11.0

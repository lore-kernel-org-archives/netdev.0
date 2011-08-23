From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next,v4 07/12] bna: Ethtool Enhancements and Fix
Date: Tue, 23 Aug 2011 10:56:03 -0700
Message-ID: <1314122168-14314-8-git-send-email-rmody@brocade.com>
References: <1314122168-14314-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>,
	Gurunatha Karaje <gkaraje@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:39340 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753418Ab1HWR4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 13:56:43 -0400
In-Reply-To: <1314122168-14314-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Use available bnad_dim_timer_stop macro in bnad_set_coalesce.
 - Add tx_skb counters and NAPI debug counters to ethtool stats.
 - Add rlb stats strings to bnad_net_stats_strings{} array. rlb_stats field
   was added to struct bfi_enet_stats {} but the corresponding name structure
   array for ethtool was not initialized with right strings, even though the
   actual name structure array got expanded. This caused a NULL pointer
   violation and a crash when doing ehtool -S <if_name>.
 - While setting the ring parameter restore the rx, vlan configuration and
   set rx mode
 - Indentation fix

Signed-off-by: Gurunatha Karaje <gkaraje@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c         |    8 +-
 drivers/net/ethernet/brocade/bna/bnad.h         |   10 ++-
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c |   88 +++++++++++++++++++----
 3 files changed, 84 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index dfbd23e..cf4e09c 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -2015,7 +2015,7 @@ bnad_rx_coalescing_timeo_set(struct bnad *bnad)
 /*
  * Called with bnad->bna_lock held
  */
-static int
+int
 bnad_mac_addr_set_locked(struct bnad *bnad, u8 *mac_addr)
 {
 	int ret;
@@ -2035,7 +2035,7 @@ bnad_mac_addr_set_locked(struct bnad *bnad, u8 *mac_addr)
 }
 
 /* Should be called with conf_lock held */
-static int
+int
 bnad_enable_default_bcast(struct bnad *bnad)
 {
 	struct bnad_rx_info *rx_info = &bnad->rx_info[0];
@@ -2061,7 +2061,7 @@ bnad_enable_default_bcast(struct bnad *bnad)
 }
 
 /* Called with mutex_lock(&bnad->conf_mutex) held */
-static void
+void
 bnad_restore_vlans(struct bnad *bnad, u32 rx_id)
 {
 	u16 vid;
@@ -2815,7 +2815,7 @@ bnad_get_stats64(struct net_device *netdev, struct rtnl_link_stats64 *stats)
 	return stats;
 }
 
-static void
+void
 bnad_set_rx_mode(struct net_device *netdev)
 {
 	struct bnad *bnad = netdev_priv(netdev);
diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
index b03e3a9..b31b893 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.h
+++ b/drivers/net/ethernet/brocade/bna/bnad.h
@@ -328,6 +328,12 @@ extern u32		bnad_rxqs_per_cq;
  */
 extern u32 *cna_get_firmware_buf(struct pci_dev *pdev);
 /* Netdev entry point prototypes */
+extern void bnad_set_rx_mode(struct net_device *netdev);
+extern struct net_device_stats *bnad_get_netdev_stats(
+				struct net_device *netdev);
+extern int bnad_mac_addr_set_locked(struct bnad *bnad, u8 *mac_addr);
+extern int bnad_enable_default_bcast(struct bnad *bnad);
+extern void bnad_restore_vlans(struct bnad *bnad, u32 rx_id);
 extern void bnad_set_ethtool_ops(struct net_device *netdev);
 
 /* Configuration & setup */
@@ -366,10 +372,6 @@ extern void bnad_netdev_hwstats_fill(struct bnad *bnad,
 	}							\
 }
 
-#define bnad_dim_timer_running(_bnad)				\
-	(((_bnad)->cfg_flags & BNAD_CF_DIM_ENABLED) &&		\
-	(test_bit(BNAD_RF_DIM_TIMER_RUNNING, &((_bnad)->run_flags))))
-
 /*
  * Stops the DIM timer
  * Called with bnad->bna_lock held
diff --git a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
index 1c19dce..1199f01 100644
--- a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
+++ b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
@@ -75,14 +75,25 @@ static char *bnad_net_stats_strings[BNAD_ETHTOOL_STATS_NUM] = {
 	"tcpcsum_offload",
 	"udpcsum_offload",
 	"csum_help",
-	"csum_help_err",
+	"tx_skb_too_short",
+	"tx_skb_stopping",
+	"tx_skb_max_vectors",
+	"tx_skb_mss_too_long",
+	"tx_skb_tso_too_short",
+	"tx_skb_tso_prepare",
+	"tx_skb_non_tso_too_long",
+	"tx_skb_tcp_hdr",
+	"tx_skb_udp_hdr",
+	"tx_skb_csum_err",
+	"tx_skb_headlen_too_long",
+	"tx_skb_headlen_zero",
+	"tx_skb_frag_zero",
+	"tx_skb_len_mismatch",
 	"hw_stats_updates",
-	"netif_rx_schedule",
-	"netif_rx_complete",
 	"netif_rx_dropped",
 
 	"link_toggle",
-	"cee_up",
+	"cee_toggle",
 
 	"rxp_info_alloc_failed",
 	"mbox_intr_disabled",
@@ -201,6 +212,20 @@ static char *bnad_net_stats_strings[BNAD_ETHTOOL_STATS_NUM] = {
 	"rad_rx_bcast_vlan",
 	"rad_rx_drops",
 
+	"rlb_rad_rx_frames",
+	"rlb_rad_rx_octets",
+	"rlb_rad_rx_vlan_frames",
+	"rlb_rad_rx_ucast",
+	"rlb_rad_rx_ucast_octets",
+	"rlb_rad_rx_ucast_vlan",
+	"rlb_rad_rx_mcast",
+	"rlb_rad_rx_mcast_octets",
+	"rlb_rad_rx_mcast_vlan",
+	"rlb_rad_rx_bcast",
+	"rlb_rad_rx_bcast_octets",
+	"rlb_rad_rx_bcast_vlan",
+	"rlb_rad_rx_drops",
+
 	"fc_rx_ucast_octets",
 	"fc_rx_ucast",
 	"fc_rx_ucast_vlan",
@@ -321,7 +346,6 @@ bnad_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *coalesce)
 {
 	struct bnad *bnad = netdev_priv(netdev);
 	unsigned long flags;
-	int dim_timer_del = 0;
 
 	if (coalesce->rx_coalesce_usecs == 0 ||
 	    coalesce->rx_coalesce_usecs >
@@ -348,14 +372,7 @@ bnad_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *coalesce)
 	} else {
 		if (bnad->cfg_flags & BNAD_CF_DIM_ENABLED) {
 			bnad->cfg_flags &= ~BNAD_CF_DIM_ENABLED;
-			dim_timer_del = bnad_dim_timer_running(bnad);
-			if (dim_timer_del) {
-				clear_bit(BNAD_RF_DIM_TIMER_RUNNING,
-							&bnad->run_flags);
-				spin_unlock_irqrestore(&bnad->bna_lock, flags);
-				del_timer_sync(&bnad->dim_timer);
-				spin_lock_irqsave(&bnad->bna_lock, flags);
-			}
+			bnad_dim_timer_stop(bnad, flags);
 			bnad_rx_coalescing_timeo_set(bnad);
 		}
 	}
@@ -407,6 +424,7 @@ bnad_set_ringparam(struct net_device *netdev,
 {
 	int i, current_err, err = 0;
 	struct bnad *bnad = netdev_priv(netdev);
+	unsigned long flags;
 
 	mutex_lock(&bnad->conf_mutex);
 	if (ringparam->rx_pending == bnad->rxq_depth &&
@@ -430,6 +448,11 @@ bnad_set_ringparam(struct net_device *netdev,
 
 	if (ringparam->rx_pending != bnad->rxq_depth) {
 		bnad->rxq_depth = ringparam->rx_pending;
+		if (!netif_running(netdev)) {
+			mutex_unlock(&bnad->conf_mutex);
+			return 0;
+		}
+
 		for (i = 0; i < bnad->num_rx; i++) {
 			if (!bnad->rx_info[i].rx)
 				continue;
@@ -437,10 +460,26 @@ bnad_set_ringparam(struct net_device *netdev,
 			current_err = bnad_setup_rx(bnad, i);
 			if (current_err && !err)
 				err = current_err;
+			if (!err)
+				bnad_restore_vlans(bnad, i);
+		}
+
+		if (!err && bnad->rx_info[0].rx) {
+			/* restore rx configuration */
+			bnad_enable_default_bcast(bnad);
+			spin_lock_irqsave(&bnad->bna_lock, flags);
+			bnad_mac_addr_set_locked(bnad, netdev->dev_addr);
+			spin_unlock_irqrestore(&bnad->bna_lock, flags);
+			bnad_set_rx_mode(netdev);
 		}
 	}
 	if (ringparam->tx_pending != bnad->txq_depth) {
 		bnad->txq_depth = ringparam->tx_pending;
+		if (!netif_running(netdev)) {
+			mutex_unlock(&bnad->conf_mutex);
+			return 0;
+		}
+
 		for (i = 0; i < bnad->num_tx; i++) {
 			if (!bnad->tx_info[i].tx)
 				continue;
@@ -578,6 +617,16 @@ bnad_get_strings(struct net_device *netdev, u32 stringset, u8 * string)
 				sprintf(string, "cq%d_hw_producer_index",
 					q_num);
 				string += ETH_GSTRING_LEN;
+				sprintf(string, "cq%d_intr", q_num);
+				string += ETH_GSTRING_LEN;
+				sprintf(string, "cq%d_poll", q_num);
+				string += ETH_GSTRING_LEN;
+				sprintf(string, "cq%d_schedule", q_num);
+				string += ETH_GSTRING_LEN;
+				sprintf(string, "cq%d_keep_poll", q_num);
+				string += ETH_GSTRING_LEN;
+				sprintf(string, "cq%d_complete", q_num);
+				string += ETH_GSTRING_LEN;
 				q_num++;
 			}
 		}
@@ -660,7 +709,7 @@ static int
 bnad_get_stats_count_locked(struct net_device *netdev)
 {
 	struct bnad *bnad = netdev_priv(netdev);
-	int i, j, count, rxf_active_num = 0, txf_active_num = 0;
+	int i, j, count = 0, rxf_active_num = 0, txf_active_num = 0;
 	u32 bmap;
 
 	bmap = bna_tx_rid_mask(&bnad->bna);
@@ -718,6 +767,17 @@ bnad_per_q_stats_fill(struct bnad *bnad, u64 *buf, int bi)
 				buf[bi++] = 0; /* ccb->consumer_index */
 				buf[bi++] = *(bnad->rx_info[i].rx_ctrl[j].
 						ccb->hw_producer_index);
+
+				buf[bi++] = bnad->rx_info[i].
+						rx_ctrl[j].rx_intr_ctr;
+				buf[bi++] = bnad->rx_info[i].
+						rx_ctrl[j].rx_poll_ctr;
+				buf[bi++] = bnad->rx_info[i].
+						rx_ctrl[j].rx_schedule;
+				buf[bi++] = bnad->rx_info[i].
+						rx_ctrl[j].rx_keep_poll;
+				buf[bi++] = bnad->rx_info[i].
+						rx_ctrl[j].rx_complete;
 			}
 	}
 	for (i = 0; i < bnad->num_rx; i++) {
-- 
1.7.1


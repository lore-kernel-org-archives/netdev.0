From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 41/45] bna: Ethtool Ring Param Set changes and Add Stats Attr
Date: Mon, 18 Jul 2011 01:23:01 -0700
Message-ID: <1310977385-5268-31-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:37845 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754772Ab1GRIZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:25:19 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - While setting the ring parameter restore the rx, vlan configuration and
   set rx mode
 - Added attributes to ethtool stats
 - Indentation fix

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bnad.c         |   10 ++--
 drivers/net/bna/bnad.h         |    6 +++
 drivers/net/bna/bnad_ethtool.c |   97 ++++++++++++++++++++++++++++++++-------
 3 files changed, 90 insertions(+), 23 deletions(-)

diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index d4de429..6128045 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -2047,7 +2047,7 @@ bnad_rx_coalescing_timeo_set(struct bnad *bnad)
 /*
  * Called with bnad->bna_lock held
  */
-static int
+int
 bnad_mac_addr_set_locked(struct bnad *bnad, u8 *mac_addr)
 {
 	int ret;
@@ -2067,7 +2067,7 @@ bnad_mac_addr_set_locked(struct bnad *bnad, u8 *mac_addr)
 }
 
 /* Should be called with conf_lock held */
-static int
+int
 bnad_enable_default_bcast(struct bnad *bnad)
 {
 	struct bnad_rx_info *rx_info = &bnad->rx_info[0];
@@ -2092,8 +2092,8 @@ bnad_enable_default_bcast(struct bnad *bnad)
 	return 0;
 }
 
-/* Called with bnad_conf_lock() held */
-static void
+/* Called with mutex_lock(&bnad->conf_mutex) held */
+void
 bnad_restore_vlans(struct bnad *bnad, u32 rx_id)
 {
 	u16 vlan_id;
@@ -2872,7 +2872,7 @@ bnad_tx_select_queue(struct net_device *netdev, struct sk_buff *skb)
 	return (u16)prio;
 }
 
-static void
+void
 bnad_set_rx_mode(struct net_device *netdev)
 {
 	struct bnad *bnad = netdev_priv(netdev);
diff --git a/drivers/net/bna/bnad.h b/drivers/net/bna/bnad.h
index 02c6342..1f9bb56 100644
--- a/drivers/net/bna/bnad.h
+++ b/drivers/net/bna/bnad.h
@@ -344,6 +344,12 @@ extern u32		bnad_rxqs_per_cq;
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
diff --git a/drivers/net/bna/bnad_ethtool.c b/drivers/net/bna/bnad_ethtool.c
index 1c19dce..51fffdf 100644
--- a/drivers/net/bna/bnad_ethtool.c
+++ b/drivers/net/bna/bnad_ethtool.c
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
@@ -237,10 +262,10 @@ bnad_get_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
 	cmd->phy_address = 0;
 
 	if (netif_carrier_ok(netdev)) {
-		ethtool_cmd_speed_set(cmd, SPEED_10000);
+		cmd->speed = SPEED_10000;
 		cmd->duplex = DUPLEX_FULL;
 	} else {
-		ethtool_cmd_speed_set(cmd, -1);
+		cmd->speed = -1;
 		cmd->duplex = -1;
 	}
 	cmd->transceiver = XCVR_EXTERNAL;
@@ -255,8 +280,9 @@ bnad_set_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
 {
 	/* 10G full duplex setting supported only */
 	if (cmd->autoneg == AUTONEG_ENABLE)
-		return -EOPNOTSUPP; else {
-		if ((ethtool_cmd_speed(cmd) == SPEED_10000)
+		return -EOPNOTSUPP;
+	else {
+		if ((cmd->speed == SPEED_10000)
 		    && (cmd->duplex == DUPLEX_FULL))
 			return 0;
 	}
@@ -321,7 +347,6 @@ bnad_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *coalesce)
 {
 	struct bnad *bnad = netdev_priv(netdev);
 	unsigned long flags;
-	int dim_timer_del = 0;
 
 	if (coalesce->rx_coalesce_usecs == 0 ||
 	    coalesce->rx_coalesce_usecs >
@@ -348,14 +373,7 @@ bnad_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *coalesce)
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
@@ -407,6 +425,7 @@ bnad_set_ringparam(struct net_device *netdev,
 {
 	int i, current_err, err = 0;
 	struct bnad *bnad = netdev_priv(netdev);
+	unsigned long flags;
 
 	mutex_lock(&bnad->conf_mutex);
 	if (ringparam->rx_pending == bnad->rxq_depth &&
@@ -430,6 +449,11 @@ bnad_set_ringparam(struct net_device *netdev,
 
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
@@ -437,10 +461,26 @@ bnad_set_ringparam(struct net_device *netdev,
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
@@ -578,6 +618,16 @@ bnad_get_strings(struct net_device *netdev, u32 stringset, u8 * string)
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
@@ -660,7 +710,7 @@ static int
 bnad_get_stats_count_locked(struct net_device *netdev)
 {
 	struct bnad *bnad = netdev_priv(netdev);
-	int i, j, count, rxf_active_num = 0, txf_active_num = 0;
+	int i, j, count = 0, rxf_active_num = 0, txf_active_num = 0;
 	u32 bmap;
 
 	bmap = bna_tx_rid_mask(&bnad->bna);
@@ -718,6 +768,17 @@ bnad_per_q_stats_fill(struct bnad *bnad, u64 *buf, int bi)
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


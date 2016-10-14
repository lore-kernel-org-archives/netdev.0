From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH net-next v2 2/6] fjes: Enhance ethtool -S for fjes driver
Date: Fri, 14 Oct 2016 20:27:32 +0900
Message-ID: <1476444452-28770-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1476444345-28673-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm02.jp.fujitsu.com ([202.219.69.169]:62279 "EHLO
        mgwkm02.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754150AbcJNLii (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 07:38:38 -0400
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
        by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id 790D6AC0158
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 20:38:32 +0900 (JST)
In-Reply-To: <1476444345-28673-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enhances ethtool -S for fjes driver so that
EP related statistics can be retrieved.

The following statistics can be displayed via ethtool -S:

     ep%d_com_regist_buf_exec
     ep%d_com_unregist_buf_exec
     ep%d_send_intr_rx
     ep%d_send_intr_unshare
     ep%d_send_intr_zoneupdate
     ep%d_recv_intr_rx
     ep%d_recv_intr_unshare
     ep%d_recv_intr_stop
     ep%d_recv_intr_zoneupdate
     ep%d_tx_buffer_full
     ep%d_tx_dropped_not_shared
     ep%d_tx_dropped_ver_mismatch
     ep%d_tx_dropped_buf_size_mismatch
     ep%d_tx_dropped_vlanid_mismatch

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_ethtool.c | 70 ++++++++++++++++++++++++++++++++++++++++-
 drivers/net/fjes/fjes_hw.c      |  9 ++++++
 drivers/net/fjes/fjes_hw.h      | 19 +++++++++++
 drivers/net/fjes/fjes_main.c    | 44 +++++++++++++++++++++++---
 4 files changed, 137 insertions(+), 5 deletions(-)

diff --git a/drivers/net/fjes/fjes_ethtool.c b/drivers/net/fjes/fjes_ethtool.c
index 8397634..68ef287 100644
--- a/drivers/net/fjes/fjes_ethtool.c
+++ b/drivers/net/fjes/fjes_ethtool.c
@@ -49,10 +49,18 @@ static const struct fjes_stats fjes_gstrings_stats[] = {
 	FJES_STAT("tx_dropped", stats64.tx_dropped),
 };
 
+#define FJES_EP_STATS_LEN 14
+#define FJES_STATS_LEN \
+	(ARRAY_SIZE(fjes_gstrings_stats) + \
+	 ((&((struct fjes_adapter *)netdev_priv(netdev))->hw)->max_epid - 1) * \
+	 FJES_EP_STATS_LEN)
+
 static void fjes_get_ethtool_stats(struct net_device *netdev,
 				   struct ethtool_stats *stats, u64 *data)
 {
 	struct fjes_adapter *adapter = netdev_priv(netdev);
+	struct fjes_hw *hw = &adapter->hw;
+	int epidx;
 	char *p;
 	int i;
 
@@ -61,11 +69,39 @@ static void fjes_get_ethtool_stats(struct net_device *netdev,
 		data[i] = (fjes_gstrings_stats[i].sizeof_stat == sizeof(u64))
 			? *(u64 *)p : *(u32 *)p;
 	}
+	for (epidx = 0; epidx < hw->max_epid; epidx++) {
+		if (epidx == hw->my_epid)
+			continue;
+		data[i++] = hw->ep_shm_info[epidx].ep_stats
+				.com_regist_buf_exec;
+		data[i++] = hw->ep_shm_info[epidx].ep_stats
+				.com_unregist_buf_exec;
+		data[i++] = hw->ep_shm_info[epidx].ep_stats.send_intr_rx;
+		data[i++] = hw->ep_shm_info[epidx].ep_stats.send_intr_unshare;
+		data[i++] = hw->ep_shm_info[epidx].ep_stats
+				.send_intr_zoneupdate;
+		data[i++] = hw->ep_shm_info[epidx].ep_stats.recv_intr_rx;
+		data[i++] = hw->ep_shm_info[epidx].ep_stats.recv_intr_unshare;
+		data[i++] = hw->ep_shm_info[epidx].ep_stats.recv_intr_stop;
+		data[i++] = hw->ep_shm_info[epidx].ep_stats
+				.recv_intr_zoneupdate;
+		data[i++] = hw->ep_shm_info[epidx].ep_stats.tx_buffer_full;
+		data[i++] = hw->ep_shm_info[epidx].ep_stats
+				.tx_dropped_not_shared;
+		data[i++] = hw->ep_shm_info[epidx].ep_stats
+				.tx_dropped_ver_mismatch;
+		data[i++] = hw->ep_shm_info[epidx].ep_stats
+				.tx_dropped_buf_size_mismatch;
+		data[i++] = hw->ep_shm_info[epidx].ep_stats
+				.tx_dropped_vlanid_mismatch;
+	}
 }
 
 static void fjes_get_strings(struct net_device *netdev,
 			     u32 stringset, u8 *data)
 {
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	struct fjes_hw *hw = &adapter->hw;
 	u8 *p = data;
 	int i;
 
@@ -76,6 +112,38 @@ static void fjes_get_strings(struct net_device *netdev,
 			       ETH_GSTRING_LEN);
 			p += ETH_GSTRING_LEN;
 		}
+		for (i = 0; i < hw->max_epid; i++) {
+			if (i == hw->my_epid)
+				continue;
+			sprintf(p, "ep%u_com_regist_buf_exec", i);
+			p += ETH_GSTRING_LEN;
+			sprintf(p, "ep%u_com_unregist_buf_exec", i);
+			p += ETH_GSTRING_LEN;
+			sprintf(p, "ep%u_send_intr_rx", i);
+			p += ETH_GSTRING_LEN;
+			sprintf(p, "ep%u_send_intr_unshare", i);
+			p += ETH_GSTRING_LEN;
+			sprintf(p, "ep%u_send_intr_zoneupdate", i);
+			p += ETH_GSTRING_LEN;
+			sprintf(p, "ep%u_recv_intr_rx", i);
+			p += ETH_GSTRING_LEN;
+			sprintf(p, "ep%u_recv_intr_unshare", i);
+			p += ETH_GSTRING_LEN;
+			sprintf(p, "ep%u_recv_intr_stop", i);
+			p += ETH_GSTRING_LEN;
+			sprintf(p, "ep%u_recv_intr_zoneupdate", i);
+			p += ETH_GSTRING_LEN;
+			sprintf(p, "ep%u_tx_buffer_full", i);
+			p += ETH_GSTRING_LEN;
+			sprintf(p, "ep%u_tx_dropped_not_shared", i);
+			p += ETH_GSTRING_LEN;
+			sprintf(p, "ep%u_tx_dropped_ver_mismatch", i);
+			p += ETH_GSTRING_LEN;
+			sprintf(p, "ep%u_tx_dropped_buf_size_mismatch", i);
+			p += ETH_GSTRING_LEN;
+			sprintf(p, "ep%u_tx_dropped_vlanid_mismatch", i);
+			p += ETH_GSTRING_LEN;
+		}
 		break;
 	}
 }
@@ -84,7 +152,7 @@ static int fjes_get_sset_count(struct net_device *netdev, int sset)
 {
 	switch (sset) {
 	case ETH_SS_STATS:
-		return ARRAY_SIZE(fjes_gstrings_stats);
+		return FJES_STATS_LEN;
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/drivers/net/fjes/fjes_hw.c b/drivers/net/fjes/fjes_hw.c
index 0dbafed..82b56e8 100644
--- a/drivers/net/fjes/fjes_hw.c
+++ b/drivers/net/fjes/fjes_hw.c
@@ -752,6 +752,7 @@ void fjes_hw_raise_epstop(struct fjes_hw *hw)
 		case EP_PARTNER_SHARED:
 			fjes_hw_raise_interrupt(hw, epidx,
 						REG_ICTL_MASK_TXRX_STOP_REQ);
+			hw->ep_shm_info[epidx].ep_stats.send_intr_unshare += 1;
 			break;
 		default:
 			break;
@@ -1062,6 +1063,9 @@ static void fjes_hw_update_zone_task(struct work_struct *work)
 				break;
 			}
 			mutex_unlock(&hw->hw_info.lock);
+
+			hw->ep_shm_info[epidx].ep_stats
+					      .com_regist_buf_exec += 1;
 		}
 
 		if (test_bit(epidx, &unshare_bit)) {
@@ -1085,6 +1089,9 @@ static void fjes_hw_update_zone_task(struct work_struct *work)
 
 			mutex_unlock(&hw->hw_info.lock);
 
+			hw->ep_shm_info[epidx].ep_stats
+					      .com_unregist_buf_exec += 1;
+
 			if (ret == 0) {
 				spin_lock_irqsave(&hw->rx_status_lock, flags);
 				fjes_hw_setup_epbuf(
@@ -1099,6 +1106,8 @@ static void fjes_hw_update_zone_task(struct work_struct *work)
 			fjes_hw_raise_interrupt(hw, epidx,
 						REG_ICTL_MASK_TXRX_STOP_REQ);
 
+			hw->ep_shm_info[epidx].ep_stats.send_intr_unshare += 1;
+
 			set_bit(epidx, &hw->txrx_stop_req_bit);
 			spin_lock_irqsave(&hw->rx_status_lock, flags);
 			hw->ep_shm_info[epidx].tx.
diff --git a/drivers/net/fjes/fjes_hw.h b/drivers/net/fjes/fjes_hw.h
index 1445ac9..205182e 100644
--- a/drivers/net/fjes/fjes_hw.h
+++ b/drivers/net/fjes/fjes_hw.h
@@ -228,6 +228,24 @@ union ep_buffer_info {
 
 };
 
+/* statistics of EP */
+struct fjes_drv_ep_stats {
+	u64 com_regist_buf_exec;
+	u64 com_unregist_buf_exec;
+	u64 send_intr_rx;
+	u64 send_intr_unshare;
+	u64 send_intr_zoneupdate;
+	u64 recv_intr_rx;
+	u64 recv_intr_unshare;
+	u64 recv_intr_stop;
+	u64 recv_intr_zoneupdate;
+	u64 tx_buffer_full;
+	u64 tx_dropped_not_shared;
+	u64 tx_dropped_ver_mismatch;
+	u64 tx_dropped_buf_size_mismatch;
+	u64 tx_dropped_vlanid_mismatch;
+};
+
 /* buffer pair for Extended Partition */
 struct ep_share_mem_info {
 	struct epbuf_handler {
@@ -238,6 +256,7 @@ struct ep_share_mem_info {
 	} tx, rx;
 
 	struct rtnl_link_stats64 net_stats;
+	struct fjes_drv_ep_stats ep_stats;
 
 	u16 tx_status_work;
 
diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index e46b1eb..03e2383 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -366,6 +366,8 @@ static int fjes_setup_resources(struct fjes_adapter *adapter)
 		     FJES_ZONING_STATUS_ENABLE)) {
 			fjes_hw_raise_interrupt(hw, epidx,
 						REG_ICTL_MASK_INFO_UPDATE);
+			hw->ep_shm_info[epidx].ep_stats
+				.send_intr_zoneupdate += 1;
 		}
 	}
 
@@ -397,6 +399,9 @@ static int fjes_setup_resources(struct fjes_adapter *adapter)
 				adapter->force_reset = true;
 				return result;
 			}
+
+			hw->ep_shm_info[epidx].ep_stats
+				.com_regist_buf_exec += 1;
 		}
 	}
 
@@ -422,6 +427,8 @@ static void fjes_free_resources(struct fjes_adapter *adapter)
 		result = fjes_hw_unregister_buff_addr(hw, epidx);
 		mutex_unlock(&hw->hw_info.lock);
 
+		hw->ep_shm_info[epidx].ep_stats.com_unregist_buf_exec += 1;
+
 		if (result)
 			reset_flag = true;
 
@@ -567,6 +574,7 @@ static void fjes_raise_intr_rxdata_task(struct work_struct *work)
 		      FJES_RX_POLL_WORK)) {
 			fjes_hw_raise_interrupt(hw, epid,
 						REG_ICTL_MASK_RX_DATA);
+			hw->ep_shm_info[epid].ep_stats.send_intr_rx += 1;
 		}
 	}
 
@@ -663,6 +671,9 @@ fjes_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 		pstatus = fjes_hw_get_partner_ep_status(hw, dest_epid);
 		if (pstatus != EP_PARTNER_SHARED) {
+			if (!is_multi)
+				hw->ep_shm_info[dest_epid].ep_stats
+					.tx_dropped_not_shared += 1;
 			ret = NETDEV_TX_OK;
 		} else if (!fjes_hw_check_epbuf_version(
 				&adapter->hw.ep_shm_info[dest_epid].rx, 0)) {
@@ -670,6 +681,8 @@ fjes_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 			adapter->stats64.tx_carrier_errors += 1;
 			hw->ep_shm_info[dest_epid].net_stats
 						.tx_carrier_errors += 1;
+			hw->ep_shm_info[dest_epid].ep_stats
+					.tx_dropped_ver_mismatch += 1;
 
 			ret = NETDEV_TX_OK;
 		} else if (!fjes_hw_check_mtu(
@@ -679,12 +692,16 @@ fjes_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 			hw->ep_shm_info[dest_epid].net_stats.tx_dropped += 1;
 			adapter->stats64.tx_errors += 1;
 			hw->ep_shm_info[dest_epid].net_stats.tx_errors += 1;
+			hw->ep_shm_info[dest_epid].ep_stats
+					.tx_dropped_buf_size_mismatch += 1;
 
 			ret = NETDEV_TX_OK;
 		} else if (vlan &&
 			   !fjes_hw_check_vlan_id(
 				&adapter->hw.ep_shm_info[dest_epid].rx,
 				vlan_id)) {
+			hw->ep_shm_info[dest_epid].ep_stats
+				.tx_dropped_vlanid_mismatch += 1;
 			ret = NETDEV_TX_OK;
 		} else {
 			if (len < VLAN_ETH_HLEN) {
@@ -718,6 +735,8 @@ fjes_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 					ret = NETDEV_TX_OK;
 				} else {
 					netif_trans_update(netdev);
+					hw->ep_shm_info[dest_epid].ep_stats
+						.tx_buffer_full += 1;
 					netif_tx_stop_queue(cur_queue);
 
 					if (!work_pending(&adapter->tx_stall_task))
@@ -970,21 +989,33 @@ static irqreturn_t fjes_intr(int irq, void *data)
 	icr = fjes_hw_capture_interrupt_status(hw);
 
 	if (icr & REG_IS_MASK_IS_ASSERT) {
-		if (icr & REG_ICTL_MASK_RX_DATA)
+		if (icr & REG_ICTL_MASK_RX_DATA) {
 			fjes_rx_irq(adapter, icr & REG_IS_MASK_EPID);
+			hw->ep_shm_info[icr & REG_IS_MASK_EPID].ep_stats
+				.recv_intr_rx += 1;
+		}
 
-		if (icr & REG_ICTL_MASK_DEV_STOP_REQ)
+		if (icr & REG_ICTL_MASK_DEV_STOP_REQ) {
 			fjes_stop_req_irq(adapter, icr & REG_IS_MASK_EPID);
+			hw->ep_shm_info[icr & REG_IS_MASK_EPID].ep_stats
+				.recv_intr_stop += 1;
+		}
 
-		if (icr & REG_ICTL_MASK_TXRX_STOP_REQ)
+		if (icr & REG_ICTL_MASK_TXRX_STOP_REQ) {
 			fjes_txrx_stop_req_irq(adapter, icr & REG_IS_MASK_EPID);
+			hw->ep_shm_info[icr & REG_IS_MASK_EPID].ep_stats
+				.recv_intr_unshare += 1;
+		}
 
 		if (icr & REG_ICTL_MASK_TXRX_STOP_DONE)
 			fjes_hw_set_irqmask(hw,
 					    REG_ICTL_MASK_TXRX_STOP_DONE, true);
 
-		if (icr & REG_ICTL_MASK_INFO_UPDATE)
+		if (icr & REG_ICTL_MASK_INFO_UPDATE) {
 			fjes_update_zone_irq(adapter, icr & REG_IS_MASK_EPID);
+			hw->ep_shm_info[icr & REG_IS_MASK_EPID].ep_stats
+				.recv_intr_zoneupdate += 1;
+		}
 
 		ret = IRQ_HANDLED;
 	} else {
@@ -1364,6 +1395,8 @@ static void fjes_watch_unshare_task(struct work_struct *work)
 				break;
 			}
 			mutex_unlock(&hw->hw_info.lock);
+			hw->ep_shm_info[epidx].ep_stats
+					.com_unregist_buf_exec += 1;
 
 			spin_lock_irqsave(&hw->rx_status_lock, flags);
 			fjes_hw_setup_epbuf(&hw->ep_shm_info[epidx].tx,
@@ -1406,6 +1439,9 @@ static void fjes_watch_unshare_task(struct work_struct *work)
 				}
 				mutex_unlock(&hw->hw_info.lock);
 
+				hw->ep_shm_info[epidx].ep_stats
+					.com_unregist_buf_exec += 1;
+
 				spin_lock_irqsave(&hw->rx_status_lock, flags);
 				fjes_hw_setup_epbuf(
 					&hw->ep_shm_info[epidx].tx,
-- 
2.6.6

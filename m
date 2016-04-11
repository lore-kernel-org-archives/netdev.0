From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH net-next 05/11] fjes: show EP stats at statistics file in debugfs
Date: Mon, 11 Apr 2016 17:10:23 +0900
Message-ID: <1460362223-15208-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm04.jp.fujitsu.com ([202.219.69.171]:13939 "EHLO
	mgwkm04.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050AbcDKISu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 04:18:50 -0400
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id B0A88AC01B0
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 17:18:39 +0900 (JST)
In-Reply-To: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enriches information in
/sys/kernel/debug/fjes/fjes.N/statistics file.
By applying this patch, each EP's stats information
are displayed in this file.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_debugfs.c | 27 ++++++++++++++++++++++++
 drivers/net/fjes/fjes_hw.c      |  9 ++++++++
 drivers/net/fjes/fjes_hw.h      | 18 ++++++++++++++++
 drivers/net/fjes/fjes_main.c    | 46 +++++++++++++++++++++++++++++++++++++----
 4 files changed, 96 insertions(+), 4 deletions(-)

diff --git a/drivers/net/fjes/fjes_debugfs.c b/drivers/net/fjes/fjes_debugfs.c
index b0807c2..fc6cfa6 100644
--- a/drivers/net/fjes/fjes_debugfs.c
+++ b/drivers/net/fjes/fjes_debugfs.c
@@ -81,6 +81,33 @@ static int fjes_dbg_stats_show(struct seq_file *m, void *v)
 	FJES_DEBUGFS_NET_STATS_ENTRY(rx_compressed);
 	FJES_DEBUGFS_NET_STATS_ENTRY(tx_compressed);
 
+#define FJES_DEBUGFS_EP_STATS_ENTRY(X) do {				\
+	seq_printf(m, "%-41s", #X);					\
+	for (epidx = 0; epidx < max_epid; epidx++) {			\
+		if (epidx == my_epid)					\
+			seq_printf(m, "          -");			\
+		else							\
+			seq_printf(m, " %10llu",			\
+				   hw->ep_shm_info[epidx].ep_stats.X);	\
+	}								\
+	seq_printf(m, "\n");						\
+} while (0)
+
+	FJES_DEBUGFS_EP_STATS_ENTRY(command_register_buffer_executed);
+	FJES_DEBUGFS_EP_STATS_ENTRY(command_unregister_buffer_executed);
+	FJES_DEBUGFS_EP_STATS_ENTRY(send_interrupts_rx);
+	FJES_DEBUGFS_EP_STATS_ENTRY(send_interrupts_unshare);
+	FJES_DEBUGFS_EP_STATS_ENTRY(send_interrupts_zoneupdate);
+	FJES_DEBUGFS_EP_STATS_ENTRY(receive_interrupts_rx);
+	FJES_DEBUGFS_EP_STATS_ENTRY(receive_interrupts_unshare);
+	FJES_DEBUGFS_EP_STATS_ENTRY(receive_interrupts_stop);
+	FJES_DEBUGFS_EP_STATS_ENTRY(receive_interrupts_zoneupdate);
+	FJES_DEBUGFS_EP_STATS_ENTRY(tx_buffer_full);
+	FJES_DEBUGFS_EP_STATS_ENTRY(tx_dropped_not_shared);
+	FJES_DEBUGFS_EP_STATS_ENTRY(tx_dropped_version_mismatch);
+	FJES_DEBUGFS_EP_STATS_ENTRY(tx_dropped_buffer_size_discrepancy);
+	FJES_DEBUGFS_EP_STATS_ENTRY(tx_dropped_vlan_id_mismatch);
+
 	return 0;
 }
 
diff --git a/drivers/net/fjes/fjes_hw.c b/drivers/net/fjes/fjes_hw.c
index 0b0795e..b2b11c3 100644
--- a/drivers/net/fjes/fjes_hw.c
+++ b/drivers/net/fjes/fjes_hw.c
@@ -745,6 +745,7 @@ void fjes_hw_raise_epstop(struct fjes_hw *hw)
 		case EP_PARTNER_SHARED:
 			fjes_hw_raise_interrupt(hw, epidx,
 						REG_ICTL_MASK_TXRX_STOP_REQ);
+			hw->ep_shm_info[epidx].ep_stats.send_interrupts_unshare += 1;
 			break;
 		default:
 			break;
@@ -1046,6 +1047,9 @@ static void fjes_hw_update_zone_task(struct work_struct *work)
 				break;
 			}
 			mutex_unlock(&hw->hw_info.lock);
+
+			hw->ep_shm_info[epidx].ep_stats
+					      .command_register_buffer_executed += 1;
 		}
 
 		if (test_bit(epidx, &unshare_bit)) {
@@ -1069,6 +1073,9 @@ static void fjes_hw_update_zone_task(struct work_struct *work)
 
 			mutex_unlock(&hw->hw_info.lock);
 
+			hw->ep_shm_info[epidx].ep_stats
+					      .command_unregister_buffer_executed += 1;
+
 			if (ret == 0)
 				fjes_hw_setup_epbuf(
 					&hw->ep_shm_info[epidx].tx,
@@ -1078,6 +1085,8 @@ static void fjes_hw_update_zone_task(struct work_struct *work)
 		if (test_bit(epidx, &irq_bit)) {
 			fjes_hw_raise_interrupt(hw, epidx,
 						REG_ICTL_MASK_TXRX_STOP_REQ);
+			hw->ep_shm_info[epidx].ep_stats
+					      .send_interrupts_unshare += 1;
 
 			set_bit(epidx, &hw->txrx_stop_req_bit);
 			hw->ep_shm_info[epidx].tx.
diff --git a/drivers/net/fjes/fjes_hw.h b/drivers/net/fjes/fjes_hw.h
index 38be7d9..41fe418 100644
--- a/drivers/net/fjes/fjes_hw.h
+++ b/drivers/net/fjes/fjes_hw.h
@@ -235,6 +235,23 @@ union ep_buffer_info {
 
 };
 
+struct fjes_drv_ep_stats {
+	u64 command_register_buffer_executed;
+	u64 command_unregister_buffer_executed;
+	u64 send_interrupts_rx;
+	u64 send_interrupts_unshare;
+	u64 send_interrupts_zoneupdate;
+	u64 receive_interrupts_rx;
+	u64 receive_interrupts_unshare;
+	u64 receive_interrupts_stop;
+	u64 receive_interrupts_zoneupdate;
+	u64 tx_buffer_full;
+	u64 tx_dropped_not_shared;
+	u64 tx_dropped_version_mismatch;
+	u64 tx_dropped_buffer_size_discrepancy;
+	u64 tx_dropped_vlan_id_mismatch;
+};
+
 /* buffer pair for Extended Partition */
 struct ep_share_mem_info {
 	struct epbuf_handler {
@@ -245,6 +262,7 @@ struct ep_share_mem_info {
 	} tx, rx;
 
 	struct rtnl_link_stats64 net_stats;
+	struct fjes_drv_ep_stats ep_stats;
 
 	u16 tx_status_work;
 
diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index 7595415..f2327d8 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -363,6 +363,8 @@ static int fjes_setup_resources(struct fjes_adapter *adapter)
 		     FJES_ZONING_STATUS_ENABLE)) {
 			fjes_hw_raise_interrupt(hw, epidx,
 						REG_ICTL_MASK_INFO_UPDATE);
+			hw->ep_shm_info[epidx].ep_stats
+					      .send_interrupts_zoneupdate += 1;
 		}
 	}
 
@@ -392,6 +394,9 @@ static int fjes_setup_resources(struct fjes_adapter *adapter)
 				adapter->force_reset = true;
 				return result;
 			}
+
+			hw->ep_shm_info[epidx].ep_stats
+					      .command_register_buffer_executed += 1;
 		}
 	}
 
@@ -419,6 +424,9 @@ static void fjes_free_resources(struct fjes_adapter *adapter)
 		if (result)
 			reset_flag = true;
 
+		hw->ep_shm_info[epidx].ep_stats
+				      .command_unregister_buffer_executed += 1;
+
 		buf_pair = &hw->ep_shm_info[epidx];
 
 		fjes_hw_setup_epbuf(&buf_pair->tx,
@@ -555,6 +563,7 @@ static void fjes_raise_intr_rxdata_task(struct work_struct *work)
 		    !(hw->ep_shm_info[epid].rx.info->v1i.rx_status)) {
 			fjes_hw_raise_interrupt(hw, epid,
 						REG_ICTL_MASK_RX_DATA);
+			hw->ep_shm_info[epid].ep_stats.send_interrupts_rx += 1;
 		}
 	}
 
@@ -651,6 +660,9 @@ fjes_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 		pstatus = fjes_hw_get_partner_ep_status(hw, dest_epid);
 		if (pstatus != EP_PARTNER_SHARED) {
+			if (!is_multi)
+				hw->ep_shm_info[dest_epid].ep_stats
+							  .tx_dropped_not_shared += 1;
 			ret = NETDEV_TX_OK;
 		} else if (!fjes_hw_check_epbuf_version(
 				&adapter->hw.ep_shm_info[dest_epid].rx, 0)) {
@@ -658,6 +670,8 @@ fjes_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 			adapter->stats64.tx_carrier_errors += 1;
 			hw->ep_shm_info[my_epid].net_stats
 						.tx_carrier_errors += 1;
+			hw->ep_shm_info[dest_epid].ep_stats
+						  .tx_dropped_version_mismatch += 1;
 
 			ret = NETDEV_TX_OK;
 		} else if (!fjes_hw_check_mtu(
@@ -667,12 +681,16 @@ fjes_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 			hw->ep_shm_info[my_epid].net_stats.tx_dropped += 1;
 			adapter->stats64.tx_errors += 1;
 			hw->ep_shm_info[my_epid].net_stats.tx_errors += 1;
+			hw->ep_shm_info[dest_epid].ep_stats
+						  .tx_dropped_buffer_size_discrepancy += 1;
 
 			ret = NETDEV_TX_OK;
 		} else if (vlan &&
 			   !fjes_hw_check_vlan_id(
 				&adapter->hw.ep_shm_info[dest_epid].rx,
 				vlan_id)) {
+			hw->ep_shm_info[dest_epid].ep_stats
+						  .tx_dropped_vlan_id_mismatch += 1;
 			ret = NETDEV_TX_OK;
 		} else {
 			if (len < VLAN_ETH_HLEN) {
@@ -706,6 +724,8 @@ fjes_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 					ret = NETDEV_TX_OK;
 				} else {
 					netdev->trans_start = jiffies;
+					hw->ep_shm_info[dest_epid].ep_stats
+								  .tx_buffer_full += 1;
 					netif_tx_stop_queue(cur_queue);
 
 					if (!work_pending(&adapter->tx_stall_task))
@@ -1117,21 +1137,33 @@ static irqreturn_t fjes_intr(int irq, void *data)
 	icr = fjes_hw_capture_interrupt_status(hw);
 
 	if (icr & REG_IS_MASK_IS_ASSERT) {
-		if (icr & REG_ICTL_MASK_RX_DATA)
+		if (icr & REG_ICTL_MASK_RX_DATA) {
 			fjes_rx_irq(adapter, icr & REG_IS_MASK_EPID);
+			hw->ep_shm_info[icr & REG_IS_MASK_EPID].ep_stats.
+				receive_interrupts_rx += 1;
+		}
 
-		if (icr & REG_ICTL_MASK_DEV_STOP_REQ)
+		if (icr & REG_ICTL_MASK_DEV_STOP_REQ) {
 			fjes_stop_req_irq(adapter, icr & REG_IS_MASK_EPID);
+			hw->ep_shm_info[icr & REG_IS_MASK_EPID].ep_stats.
+				receive_interrupts_stop += 1;
+		}
 
-		if (icr & REG_ICTL_MASK_TXRX_STOP_REQ)
+		if (icr & REG_ICTL_MASK_TXRX_STOP_REQ) {
 			fjes_txrx_stop_req_irq(adapter, icr & REG_IS_MASK_EPID);
+			hw->ep_shm_info[icr & REG_IS_MASK_EPID].ep_stats.
+				receive_interrupts_unshare += 1;
+		}
 
 		if (icr & REG_ICTL_MASK_TXRX_STOP_DONE)
 			fjes_hw_set_irqmask(hw,
 					    REG_ICTL_MASK_TXRX_STOP_DONE, true);
 
-		if (icr & REG_ICTL_MASK_INFO_UPDATE)
+		if (icr & REG_ICTL_MASK_INFO_UPDATE) {
 			fjes_update_zone_irq(adapter, icr & REG_IS_MASK_EPID);
+			hw->ep_shm_info[icr & REG_IS_MASK_EPID].ep_stats.
+				receive_interrupts_zoneupdate += 1;
+		}
 
 		ret = IRQ_HANDLED;
 	} else {
@@ -1506,6 +1538,9 @@ static void fjes_watch_unshare_task(struct work_struct *work)
 			}
 			mutex_unlock(&hw->hw_info.lock);
 
+			hw->ep_shm_info[epidx].ep_stats
+					      .command_unregister_buffer_executed += 1;
+
 			fjes_hw_setup_epbuf(&hw->ep_shm_info[epidx].tx,
 					    netdev->dev_addr, netdev->mtu);
 
@@ -1545,6 +1580,9 @@ static void fjes_watch_unshare_task(struct work_struct *work)
 				}
 				mutex_unlock(&hw->hw_info.lock);
 
+				hw->ep_shm_info[epidx].ep_stats
+						      .command_unregister_buffer_executed += 1;
+
 				fjes_hw_setup_epbuf(
 					&hw->ep_shm_info[epidx].tx,
 					netdev->dev_addr, netdev->mtu);
-- 
2.4.3

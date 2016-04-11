From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH net-next 09/11] fjes: Enhance changing MTU related work
Date: Mon, 11 Apr 2016 17:10:46 +0900
Message-ID: <1460362246-15380-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm01.jp.fujitsu.com ([202.219.69.168]:60048 "EHLO
	mgwkm01.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752925AbcDKITJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 04:19:09 -0400
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id 910BCAC01BC
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 17:19:02 +0900 (JST)
In-Reply-To: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enhances the fjes_change_mtu() method
by introducing new flag named FJES_RX_MTU_CHANGING_DONE
in rx_status. At the same time, default MTU value is
changed into 65510 bytes.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_hw.c   |  8 +++++-
 drivers/net/fjes/fjes_hw.h   |  1 +
 drivers/net/fjes/fjes_main.c | 60 ++++++++++++++++++++++++++++++++++++--------
 3 files changed, 58 insertions(+), 11 deletions(-)

diff --git a/drivers/net/fjes/fjes_hw.c b/drivers/net/fjes/fjes_hw.c
index b2b11c3..4861e36 100644
--- a/drivers/net/fjes/fjes_hw.c
+++ b/drivers/net/fjes/fjes_hw.c
@@ -179,6 +179,8 @@ void fjes_hw_setup_epbuf(struct epbuf_handler *epbh, u8 *mac_addr, u32 mtu)
 
 	for (i = 0; i < EP_BUFFER_SUPPORT_VLAN_MAX; i++)
 		info->v1i.vlan_id[i] = vlan_id[i];
+
+	info->v1i.rx_status |= FJES_RX_MTU_CHANGING_DONE;
 }
 
 void
@@ -811,7 +813,8 @@ bool fjes_hw_check_mtu(struct epbuf_handler *epbh, u32 mtu)
 {
 	union ep_buffer_info *info = epbh->info;
 
-	return (info->v1i.frame_max == FJES_MTU_TO_FRAME_SIZE(mtu));
+	return ((info->v1i.frame_max == FJES_MTU_TO_FRAME_SIZE(mtu)) &&
+		info->v1i.rx_status & FJES_RX_MTU_CHANGING_DONE);
 }
 
 bool fjes_hw_check_vlan_id(struct epbuf_handler *epbh, u16 vlan_id)
@@ -864,6 +867,9 @@ bool fjes_hw_epbuf_rx_is_empty(struct epbuf_handler *epbh)
 {
 	union ep_buffer_info *info = epbh->info;
 
+	if (!(info->v1i.rx_status & FJES_RX_MTU_CHANGING_DONE))
+		return true;
+
 	if (info->v1i.count_max == 0)
 		return true;
 
diff --git a/drivers/net/fjes/fjes_hw.h b/drivers/net/fjes/fjes_hw.h
index a1c3d65..66cefd1 100644
--- a/drivers/net/fjes/fjes_hw.h
+++ b/drivers/net/fjes/fjes_hw.h
@@ -58,6 +58,7 @@ struct fjes_hw;
 #define FJES_RX_STOP_REQ_DONE		(0x1)
 #define FJES_RX_STOP_REQ_REQUEST	(0x2)
 #define FJES_RX_POLL_WORK		(0x4)
+#define FJES_RX_MTU_CHANGING_DONE	(0x8)
 
 #define EP_BUFFER_SIZE \
 	(((sizeof(union ep_buffer_info) + (128 * (64 * 1024))) \
diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index 8c7a8b0..8ab0523 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -492,6 +492,9 @@ static void fjes_tx_stall_task(struct work_struct *work)
 
 			info = adapter->hw.ep_shm_info[epid].tx.info;
 
+			if (!(info->v1i.rx_status & FJES_RX_MTU_CHANGING_DONE))
+				return;
+
 			if (EP_RING_FULL(info->v1i.head, info->v1i.tail,
 					 info->v1i.count_max)) {
 				all_queue_available = 0;
@@ -783,9 +786,11 @@ fjes_get_stats64(struct net_device *netdev, struct rtnl_link_stats64 *stats)
 
 static int fjes_change_mtu(struct net_device *netdev, int new_mtu)
 {
+	struct fjes_adapter *adapter = netdev_priv(netdev);
 	bool running = netif_running(netdev);
-	int ret = 0;
-	int idx;
+	struct fjes_hw *hw = &adapter->hw;
+	int ret = -EINVAL;
+	int idx, epidx;
 
 	for (idx = 0; fjes_support_mtu[idx] != 0; idx++) {
 		if (new_mtu <= fjes_support_mtu[idx]) {
@@ -793,19 +798,54 @@ static int fjes_change_mtu(struct net_device *netdev, int new_mtu)
 			if (new_mtu == netdev->mtu)
 				return 0;
 
-			if (running)
-				fjes_close(netdev);
+			ret = 0;
+			break;
+		}
+	}
+
+	if (ret)
+		return ret;
 
-			netdev->mtu = new_mtu;
+	if (running) {
+		for (epidx = 0; epidx < hw->max_epid; epidx++) {
+			if (epidx == hw->my_epid)
+				continue;
+			hw->ep_shm_info[epidx].tx.info->v1i.rx_status &=
+				~FJES_RX_MTU_CHANGING_DONE;
+		}
+		netif_tx_stop_all_queues(netdev);
+		netif_carrier_off(netdev);
+		cancel_work_sync(&adapter->tx_stall_task);
+		napi_disable(&adapter->napi);
 
-			if (running)
-				ret = fjes_open(netdev);
+		msleep(1000);
 
-			return ret;
+		netif_tx_stop_all_queues(netdev);
+	}
+
+	netdev->mtu = new_mtu;
+
+	if (running) {
+		for (epidx = 0; epidx < hw->max_epid; epidx++) {
+			if (epidx == hw->my_epid)
+				continue;
+
+			local_irq_disable();
+			fjes_hw_setup_epbuf(&hw->ep_shm_info[epidx].tx,
+					    netdev->dev_addr,
+					    netdev->mtu);
+			local_irq_enable();
+
+			hw->ep_shm_info[epidx].tx.info->v1i.rx_status |=
+				FJES_RX_MTU_CHANGING_DONE;
 		}
+
+		netif_tx_wake_all_queues(netdev);
+		netif_carrier_on(netdev);
+		napi_enable(&adapter->napi);
 	}
 
-	return -EINVAL;
+	return ret;
 }
 
 static int fjes_vlan_rx_add_vid(struct net_device *netdev,
@@ -1450,7 +1490,7 @@ static void fjes_netdev_setup(struct net_device *netdev)
 	netdev->watchdog_timeo = FJES_TX_RETRY_INTERVAL;
 	netdev->netdev_ops = &fjes_netdev_ops;
 	fjes_set_ethtool_ops(netdev);
-	netdev->mtu = fjes_support_mtu[0];
+	netdev->mtu = fjes_support_mtu[3];
 	netdev->flags |= IFF_BROADCAST;
 	netdev->features |= NETIF_F_HW_CSUM | NETIF_F_HW_VLAN_CTAG_FILTER;
 }
-- 
2.4.3

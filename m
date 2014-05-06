From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net 2/2] qlcnic: Set real_num_{tx|rx}_queues properly
Date: Tue, 6 May 2014 03:46:49 -0400
Message-ID: <1399362409-17039-3-git-send-email-rajesh.borundia@qlogic.com>
References: <1399362409-17039-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:40286 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934244AbaEFIPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 04:15:35 -0400
In-Reply-To: <1399362409-17039-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Do not set netdev->real_num_tx_queues directly,
let netif_set_real_num_tx_queues() take care of it.
Do not overwrite netdev->num_tx_queues everytime when driver
changes its Tx ring size through ethtool -L and also notify
stack to update number of Rx queues.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h      |   16 -------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   49 +++++++++++++++++++++-
 2 files changed, 47 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 7b52a88..f785d01 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1719,22 +1719,6 @@ static inline u32 qlcnic_tx_avail(struct qlcnic_host_tx_ring *tx_ring)
 				tx_ring->producer;
 }
 
-static inline int qlcnic_set_real_num_queues(struct qlcnic_adapter *adapter,
-					     struct net_device *netdev)
-{
-	int err;
-
-	netdev->num_tx_queues = adapter->drv_tx_rings;
-	netdev->real_num_tx_queues = adapter->drv_tx_rings;
-
-	err = netif_set_real_num_tx_queues(netdev, adapter->drv_tx_rings);
-	if (err)
-		netdev_err(netdev, "failed to set %d Tx queues\n",
-			   adapter->drv_tx_rings);
-
-	return err;
-}
-
 struct qlcnic_nic_template {
 	int (*config_bridged_mode) (struct qlcnic_adapter *, u32);
 	int (*config_led) (struct qlcnic_adapter *, u32, u32);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index be78951..7e55e88 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2206,6 +2206,31 @@ static void qlcnic_82xx_set_mac_filter_count(struct qlcnic_adapter *adapter)
 	ahw->max_uc_count = count;
 }
 
+static int qlcnic_set_real_num_queues(struct qlcnic_adapter *adapter,
+				      u8 tx_queues, u8 rx_queues)
+{
+	struct net_device *netdev = adapter->netdev;
+	int err = 0;
+
+	if (tx_queues) {
+		err = netif_set_real_num_tx_queues(netdev, tx_queues);
+		if (err) {
+			netdev_err(netdev, "failed to set %d Tx queues\n",
+				   tx_queues);
+			return err;
+		}
+	}
+
+	if (rx_queues) {
+		err = netif_set_real_num_rx_queues(netdev, rx_queues);
+		if (err)
+			netdev_err(netdev, "failed to set %d Rx queues\n",
+				   rx_queues);
+	}
+
+	return err;
+}
+
 int
 qlcnic_setup_netdev(struct qlcnic_adapter *adapter, struct net_device *netdev,
 		    int pci_using_dac)
@@ -2269,7 +2294,8 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter, struct net_device *netdev,
 	netdev->priv_flags |= IFF_UNICAST_FLT;
 	netdev->irq = adapter->msix_entries[0].vector;
 
-	err = qlcnic_set_real_num_queues(adapter, netdev);
+	err = qlcnic_set_real_num_queues(adapter, adapter->drv_tx_rings,
+					 adapter->drv_sds_rings);
 	if (err)
 		return err;
 
@@ -3982,12 +4008,21 @@ int qlcnic_validate_rings(struct qlcnic_adapter *adapter, __u32 ring_cnt,
 int qlcnic_setup_rings(struct qlcnic_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
+	u8 tx_rings, rx_rings;
 	int err;
 
 	if (test_bit(__QLCNIC_RESETTING, &adapter->state))
 		return -EBUSY;
 
+	tx_rings = adapter->drv_tss_rings;
+	rx_rings = adapter->drv_rss_rings;
+
 	netif_device_detach(netdev);
+
+	err = qlcnic_set_real_num_queues(adapter, tx_rings, rx_rings);
+	if (err)
+		goto done;
+
 	if (netif_running(netdev))
 		__qlcnic_down(adapter, netdev);
 
@@ -4007,7 +4042,17 @@ int qlcnic_setup_rings(struct qlcnic_adapter *adapter)
 		return err;
 	}
 
-	netif_set_real_num_tx_queues(netdev, adapter->drv_tx_rings);
+	/* Check if we need to update real_num_{tx|rx}_queues because
+	 * qlcnic_setup_intr() may change Tx/Rx rings size
+	 */
+	if ((tx_rings != adapter->drv_tx_rings) ||
+	    (rx_rings != adapter->drv_sds_rings)) {
+		err = qlcnic_set_real_num_queues(adapter,
+						 adapter->drv_tx_rings,
+						 adapter->drv_sds_rings);
+		if (err)
+			goto done;
+	}
 
 	if (qlcnic_83xx_check(adapter)) {
 		qlcnic_83xx_initialize_nic(adapter, 1);
-- 
1.6.3.3

From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next 06/15] ethernet/qlogic: use core min/max MTU checking
Date: Mon, 17 Oct 2016 15:54:08 -0400
Message-ID: <20161017195417.48259-7-jarod@redhat.com>
References: <20161017195417.48259-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        Yuval Mintz <Yuval.Mintz@qlogic.com>,
        Ariel Elior <Ariel.Elior@qlogic.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161017195417.48259-1-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

qede: min_mtu 46, max_mtu 9600
- Put define for max in qede.h

qlcnic: min_mtu 68, max_mtu 9600

CC: netdev@vger.kernel.org
CC Dept-GELinuxNICDev@qlogic.com
CC: Yuval Mintz <Yuval.Mintz@qlogic.com>
CC: Ariel Elior <Ariel.Elior@qlogic.com>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/qlogic/qede/qede.h          | 5 +++--
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c  | 8 --------
 drivers/net/ethernet/qlogic/qede/qede_main.c     | 4 ++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c   | 6 ------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 4 ++++
 5 files changed, 11 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index f50e527..9135b9d 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -362,8 +362,9 @@ void qede_recycle_rx_bd_ring(struct qede_rx_queue *rxq, struct qede_dev *edev,
 #define NUM_TX_BDS_MIN		128
 #define NUM_TX_BDS_DEF		NUM_TX_BDS_MAX
 
-#define QEDE_MIN_PKT_LEN	64
-#define QEDE_RX_HDR_SIZE	256
+#define QEDE_MIN_PKT_LEN		64
+#define QEDE_RX_HDR_SIZE		256
+#define QEDE_MAX_JUMBO_PACKET_SIZE	9600
 #define	for_each_queue(i) for (i = 0; i < edev->num_queues; i++)
 
 #endif /* _QEDE_H_ */
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index 25a9b29..b7dbb44 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -723,19 +723,11 @@ static void qede_update_mtu(struct qede_dev *edev, union qede_reload_args *args)
 }
 
 /* Netdevice NDOs */
-#define ETH_MAX_JUMBO_PACKET_SIZE	9600
-#define ETH_MIN_PACKET_SIZE		60
 int qede_change_mtu(struct net_device *ndev, int new_mtu)
 {
 	struct qede_dev *edev = netdev_priv(ndev);
 	union qede_reload_args args;
 
-	if ((new_mtu > ETH_MAX_JUMBO_PACKET_SIZE) ||
-	    ((new_mtu + ETH_HLEN) < ETH_MIN_PACKET_SIZE)) {
-		DP_ERR(edev, "Can't support requested MTU size\n");
-		return -EINVAL;
-	}
-
 	DP_VERBOSE(edev, (NETIF_MSG_IFUP | NETIF_MSG_IFDOWN),
 		   "Configuring MTU size of %d\n", new_mtu);
 
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 0e483af..4f29865 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -2391,6 +2391,10 @@ static void qede_init_ndev(struct qede_dev *edev)
 
 	ndev->hw_features = hw_features;
 
+	/* MTU range: 46 - 9600 */
+	ndev->min_mtu = ETH_ZLEN - ETH_HLEN;
+	ndev->max_mtu = QEDE_MAX_JUMBO_PACKET_SIZE;
+
 	/* Set network device HW mac */
 	ether_addr_copy(edev->ndev->dev_addr, edev->dev_info.common.hw_mac);
 }
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 509b596..838cc0c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -1024,12 +1024,6 @@ int qlcnic_change_mtu(struct net_device *netdev, int mtu)
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	int rc = 0;
 
-	if (mtu < P3P_MIN_MTU || mtu > P3P_MAX_MTU) {
-		dev_err(&adapter->netdev->dev, "%d bytes < mtu < %d bytes"
-			" not supported\n", P3P_MAX_MTU, P3P_MIN_MTU);
-		return -EINVAL;
-	}
-
 	rc = qlcnic_fw_cmd_set_mtu(adapter, mtu);
 
 	if (!rc)
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 3ae3968..4c0cce96 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2342,6 +2342,10 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter, struct net_device *netdev,
 	netdev->priv_flags |= IFF_UNICAST_FLT;
 	netdev->irq = adapter->msix_entries[0].vector;
 
+	/* MTU range: 68 - 9600 */
+	netdev->min_mtu = P3P_MIN_MTU;
+	netdev->max_mtu = P3P_MAX_MTU;
+
 	err = qlcnic_set_real_num_queues(adapter, adapter->drv_tx_rings,
 					 adapter->drv_sds_rings);
 	if (err)
-- 
2.10.0

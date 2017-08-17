From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: [PATCH V6 20/21] net-next/hinic: Add ethtool and stats
Date: Thu, 17 Aug 2017 20:25:28 +0800
Message-ID: <ebe9fc1518f3dd5d3fe436b1ea463593300a65dd.1502972069.git.aviad.krawczyk@huawei.com>
References: <cover.1502972068.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <bc.y@huawei.com>, <victor.gissin@huawei.com>,
        <aviad.krawczyk@huawei.com>, <zhaochen6@huawei.com>,
        <tony.qu@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1502972068.git.aviad.krawczyk@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add ethtool operations and statistics operations.

Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
---
 drivers/net/ethernet/huawei/hinic/hinic_dev.h  |   3 +
 drivers/net/ethernet/huawei/hinic/hinic_main.c | 218 ++++++++++++++++++++++++-
 drivers/net/ethernet/huawei/hinic/hinic_port.c |  31 ++++
 drivers/net/ethernet/huawei/hinic/hinic_port.h |  45 +++++
 drivers/net/ethernet/huawei/hinic/hinic_rx.c   |  19 +++
 drivers/net/ethernet/huawei/hinic/hinic_rx.h   |   2 +
 drivers/net/ethernet/huawei/hinic/hinic_tx.c   |  22 +++
 drivers/net/ethernet/huawei/hinic/hinic_tx.h   |   2 +
 8 files changed, 341 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/huawei/hinic/hinic_dev.h b/drivers/net/ethernet/huawei/hinic/hinic_dev.h
index 15d0c2e..5186cc9 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_dev.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_dev.h
@@ -56,6 +56,9 @@ struct hinic_dev {
 
 	struct hinic_txq                *txqs;
 	struct hinic_rxq                *rxqs;
+
+	struct hinic_txq_stats          tx_stats;
+	struct hinic_rxq_stats          rx_stats;
 };
 
 #endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_main.c b/drivers/net/ethernet/huawei/hinic/hinic_main.c
index 4a5f23f..a77a7f8 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_main.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_main.c
@@ -69,6 +69,186 @@
 
 static int change_mac_addr(struct net_device *netdev, const u8 *addr);
 
+static void set_link_speed(struct ethtool_link_ksettings *link_ksettings,
+			   enum hinic_speed speed)
+{
+	switch (speed) {
+	case HINIC_SPEED_10MB_LINK:
+		link_ksettings->base.speed = SPEED_10;
+		break;
+
+	case HINIC_SPEED_100MB_LINK:
+		link_ksettings->base.speed = SPEED_100;
+		break;
+
+	case HINIC_SPEED_1000MB_LINK:
+		link_ksettings->base.speed = SPEED_1000;
+		break;
+
+	case HINIC_SPEED_10GB_LINK:
+		link_ksettings->base.speed = SPEED_10000;
+		break;
+
+	case HINIC_SPEED_25GB_LINK:
+		link_ksettings->base.speed = SPEED_25000;
+		break;
+
+	case HINIC_SPEED_40GB_LINK:
+		link_ksettings->base.speed = SPEED_40000;
+		break;
+
+	case HINIC_SPEED_100GB_LINK:
+		link_ksettings->base.speed = SPEED_100000;
+		break;
+
+	default:
+		link_ksettings->base.speed = SPEED_UNKNOWN;
+		break;
+	}
+}
+
+static int hinic_get_link_ksettings(struct net_device *netdev,
+				    struct ethtool_link_ksettings
+				    *link_ksettings)
+{
+	struct hinic_dev *nic_dev = netdev_priv(netdev);
+	enum hinic_port_link_state link_state;
+	struct hinic_port_cap port_cap;
+	int err;
+
+	ethtool_link_ksettings_zero_link_mode(link_ksettings, advertising);
+	ethtool_link_ksettings_add_link_mode(link_ksettings, supported,
+					     Autoneg);
+
+	link_ksettings->base.speed   = SPEED_UNKNOWN;
+	link_ksettings->base.autoneg = AUTONEG_DISABLE;
+	link_ksettings->base.duplex  = DUPLEX_UNKNOWN;
+
+	err = hinic_port_get_cap(nic_dev, &port_cap);
+	if (err) {
+		netif_err(nic_dev, drv, netdev,
+			  "Failed to get port capabilities\n");
+		return err;
+	}
+
+	err = hinic_port_link_state(nic_dev, &link_state);
+	if (err) {
+		netif_err(nic_dev, drv, netdev,
+			  "Failed to get port link state\n");
+		return err;
+	}
+
+	if (link_state != HINIC_LINK_STATE_UP) {
+		netif_info(nic_dev, drv, netdev, "No link\n");
+		return err;
+	}
+
+	set_link_speed(link_ksettings, port_cap.speed);
+
+	if (!!(port_cap.autoneg_cap & HINIC_AUTONEG_SUPPORTED))
+		ethtool_link_ksettings_add_link_mode(link_ksettings,
+						     advertising, Autoneg);
+
+	if (port_cap.autoneg_state == HINIC_AUTONEG_ACTIVE)
+		link_ksettings->base.autoneg = AUTONEG_ENABLE;
+
+	link_ksettings->base.duplex = (port_cap.duplex == HINIC_DUPLEX_FULL) ?
+				       DUPLEX_FULL : DUPLEX_HALF;
+	return 0;
+}
+
+static void hinic_get_drvinfo(struct net_device *netdev,
+			      struct ethtool_drvinfo *info)
+{
+	struct hinic_dev *nic_dev = netdev_priv(netdev);
+	struct hinic_hwdev *hwdev = nic_dev->hwdev;
+	struct hinic_hwif *hwif = hwdev->hwif;
+
+	strlcpy(info->driver, HINIC_DRV_NAME, sizeof(info->driver));
+	strlcpy(info->bus_info, pci_name(hwif->pdev), sizeof(info->bus_info));
+}
+
+static void hinic_get_ringparam(struct net_device *netdev,
+				struct ethtool_ringparam *ring)
+{
+	ring->rx_max_pending = HINIC_RQ_DEPTH;
+	ring->tx_max_pending = HINIC_SQ_DEPTH;
+	ring->rx_pending = HINIC_RQ_DEPTH;
+	ring->tx_pending = HINIC_SQ_DEPTH;
+}
+
+static void hinic_get_channels(struct net_device *netdev,
+			       struct ethtool_channels *channels)
+{
+	struct hinic_dev *nic_dev = netdev_priv(netdev);
+	struct hinic_hwdev *hwdev = nic_dev->hwdev;
+
+	channels->max_rx = hwdev->nic_cap.max_qps;
+	channels->max_tx = hwdev->nic_cap.max_qps;
+	channels->max_other    = 0;
+	channels->max_combined = 0;
+	channels->rx_count = hinic_hwdev_num_qps(hwdev);
+	channels->tx_count = hinic_hwdev_num_qps(hwdev);
+	channels->other_count    = 0;
+	channels->combined_count = 0;
+}
+
+static const struct ethtool_ops hinic_ethtool_ops = {
+	.get_link_ksettings = hinic_get_link_ksettings,
+	.get_drvinfo = hinic_get_drvinfo,
+	.get_link = ethtool_op_get_link,
+	.get_ringparam = hinic_get_ringparam,
+	.get_channels = hinic_get_channels,
+};
+
+static void update_rx_stats(struct hinic_dev *nic_dev, struct hinic_rxq *rxq)
+{
+	struct hinic_rxq_stats *nic_rx_stats = &nic_dev->rx_stats;
+	struct hinic_rxq_stats rx_stats;
+
+	u64_stats_init(&rx_stats.syncp);
+
+	hinic_rxq_get_stats(rxq, &rx_stats);
+
+	u64_stats_update_begin(&nic_rx_stats->syncp);
+	nic_rx_stats->bytes += rx_stats.bytes;
+	nic_rx_stats->pkts  += rx_stats.pkts;
+	u64_stats_update_end(&nic_rx_stats->syncp);
+
+	hinic_rxq_clean_stats(rxq);
+}
+
+static void update_tx_stats(struct hinic_dev *nic_dev, struct hinic_txq *txq)
+{
+	struct hinic_txq_stats *nic_tx_stats = &nic_dev->tx_stats;
+	struct hinic_txq_stats tx_stats;
+
+	u64_stats_init(&tx_stats.syncp);
+
+	hinic_txq_get_stats(txq, &tx_stats);
+
+	u64_stats_update_begin(&nic_tx_stats->syncp);
+	nic_tx_stats->bytes += tx_stats.bytes;
+	nic_tx_stats->pkts += tx_stats.pkts;
+	nic_tx_stats->tx_busy += tx_stats.tx_busy;
+	nic_tx_stats->tx_wake += tx_stats.tx_wake;
+	nic_tx_stats->tx_dropped += tx_stats.tx_dropped;
+	u64_stats_update_end(&nic_tx_stats->syncp);
+
+	hinic_txq_clean_stats(txq);
+}
+
+static void update_nic_stats(struct hinic_dev *nic_dev)
+{
+	int i, num_qps = hinic_hwdev_num_qps(nic_dev->hwdev);
+
+	for (i = 0; i < num_qps; i++)
+		update_rx_stats(nic_dev, &nic_dev->rxqs[i]);
+
+	for (i = 0; i < num_qps; i++)
+		update_tx_stats(nic_dev, &nic_dev->txqs[i]);
+}
+
 /**
  * create_txqs - Create the Logical Tx Queues of specific NIC device
  * @nic_dev: the specific NIC device
@@ -303,6 +483,8 @@ static int hinic_close(struct net_device *netdev)
 	netif_carrier_off(netdev);
 	netif_tx_disable(netdev);
 
+	update_nic_stats(nic_dev);
+
 	up(&nic_dev->mgmt_lock);
 
 	err = hinic_port_set_func_state(nic_dev, HINIC_FUNC_PORT_DISABLE);
@@ -580,6 +762,31 @@ static void hinic_tx_timeout(struct net_device *netdev)
 	netif_err(nic_dev, drv, netdev, "Tx timeout\n");
 }
 
+static void hinic_get_stats64(struct net_device *netdev,
+			      struct rtnl_link_stats64 *stats)
+{
+	struct hinic_dev *nic_dev = netdev_priv(netdev);
+	struct hinic_rxq_stats *nic_rx_stats;
+	struct hinic_txq_stats *nic_tx_stats;
+
+	nic_rx_stats = &nic_dev->rx_stats;
+	nic_tx_stats = &nic_dev->tx_stats;
+
+	down(&nic_dev->mgmt_lock);
+
+	if (nic_dev->flags & HINIC_INTF_UP)
+		update_nic_stats(nic_dev);
+
+	up(&nic_dev->mgmt_lock);
+
+	stats->rx_bytes   = nic_rx_stats->bytes;
+	stats->rx_packets = nic_rx_stats->pkts;
+
+	stats->tx_bytes   = nic_tx_stats->bytes;
+	stats->tx_packets = nic_tx_stats->pkts;
+	stats->tx_errors  = nic_tx_stats->tx_dropped;
+}
+
 static const struct net_device_ops hinic_netdev_ops = {
 	.ndo_open = hinic_open,
 	.ndo_stop = hinic_close,
@@ -591,7 +798,7 @@ static void hinic_tx_timeout(struct net_device *netdev)
 	.ndo_set_rx_mode = hinic_set_rx_mode,
 	.ndo_start_xmit = hinic_xmit_frame,
 	.ndo_tx_timeout = hinic_tx_timeout,
-	/* more operations should be filled */
+	.ndo_get_stats64 = hinic_get_stats64,
 };
 
 static void netdev_features_init(struct net_device *netdev)
@@ -663,6 +870,8 @@ static void link_status_event_handler(void *handle, void *buf_in, u16 in_size,
 static int nic_dev_init(struct pci_dev *pdev)
 {
 	struct hinic_rx_mode_work *rx_mode_work;
+	struct hinic_txq_stats *tx_stats;
+	struct hinic_rxq_stats *rx_stats;
 	struct hinic_dev *nic_dev;
 	struct net_device *netdev;
 	struct hinic_hwdev *hwdev;
@@ -689,6 +898,7 @@ static int nic_dev_init(struct pci_dev *pdev)
 	}
 
 	netdev->netdev_ops = &hinic_netdev_ops;
+	netdev->ethtool_ops = &hinic_ethtool_ops;
 
 	nic_dev = (struct hinic_dev *)netdev_priv(netdev);
 	nic_dev->netdev = netdev;
@@ -702,6 +912,12 @@ static int nic_dev_init(struct pci_dev *pdev)
 
 	sema_init(&nic_dev->mgmt_lock, 1);
 
+	tx_stats = &nic_dev->tx_stats;
+	rx_stats = &nic_dev->rx_stats;
+
+	u64_stats_init(&tx_stats->syncp);
+	u64_stats_init(&rx_stats->syncp);
+
 	nic_dev->vlan_bitmap = devm_kzalloc(&pdev->dev,
 					    VLAN_BITMAP_SIZE(nic_dev),
 					    GFP_KERNEL);
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_port.c b/drivers/net/ethernet/huawei/hinic/hinic_port.c
index 528ec6f..4d4e3f0 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_port.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_port.c
@@ -346,3 +346,34 @@ int hinic_port_set_func_state(struct hinic_dev *nic_dev,
 
 	return 0;
 }
+
+/**
+ * hinic_port_get_cap - get port capabilities
+ * @nic_dev: nic device
+ * @port_cap: returned port capabilities
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_port_get_cap(struct hinic_dev *nic_dev,
+		       struct hinic_port_cap *port_cap)
+{
+	struct hinic_hwdev *hwdev = nic_dev->hwdev;
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	u16 out_size;
+	int err;
+
+	port_cap->func_idx = HINIC_HWIF_FUNC_IDX(hwif);
+
+	err = hinic_port_msg_cmd(hwdev, HINIC_PORT_CMD_GET_CAP,
+				 port_cap, sizeof(*port_cap),
+				 port_cap, &out_size);
+	if (err || (out_size != sizeof(*port_cap)) || port_cap->status) {
+		dev_err(&pdev->dev,
+			"Failed to get port capabilities, ret = %d\n",
+			port_cap->status);
+		return -EINVAL;
+	}
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_port.h b/drivers/net/ethernet/huawei/hinic/hinic_port.h
index 17f9d7fc..9404365 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_port.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_port.h
@@ -45,6 +45,33 @@ enum hinic_func_port_state {
 	HINIC_FUNC_PORT_ENABLE  = 2,
 };
 
+enum hinic_autoneg_cap {
+	HINIC_AUTONEG_UNSUPPORTED,
+	HINIC_AUTONEG_SUPPORTED,
+};
+
+enum hinic_autoneg_state {
+	HINIC_AUTONEG_DISABLED,
+	HINIC_AUTONEG_ACTIVE,
+};
+
+enum hinic_duplex {
+	HINIC_DUPLEX_HALF,
+	HINIC_DUPLEX_FULL,
+};
+
+enum hinic_speed {
+	HINIC_SPEED_10MB_LINK = 0,
+	HINIC_SPEED_100MB_LINK,
+	HINIC_SPEED_1000MB_LINK,
+	HINIC_SPEED_10GB_LINK,
+	HINIC_SPEED_25GB_LINK,
+	HINIC_SPEED_40GB_LINK,
+	HINIC_SPEED_100GB_LINK,
+
+	HINIC_SPEED_UNKNOWN = 0xFF,
+};
+
 struct hinic_port_mac_cmd {
 	u8              status;
 	u8              version;
@@ -125,6 +152,21 @@ struct hinic_port_func_state_cmd {
 	u8      rsvd2[3];
 };
 
+struct hinic_port_cap {
+	u8      status;
+	u8      version;
+	u8      rsvd0[6];
+
+	u16     func_idx;
+	u16     rsvd1;
+	u8      port_type;
+	u8      autoneg_cap;
+	u8      autoneg_state;
+	u8      duplex;
+	u8      speed;
+	u8      rsvd2[3];
+};
+
 int hinic_port_add_mac(struct hinic_dev *nic_dev, const u8 *addr,
 		       u16 vlan_id);
 
@@ -150,4 +192,7 @@ int hinic_port_set_state(struct hinic_dev *nic_dev,
 int hinic_port_set_func_state(struct hinic_dev *nic_dev,
 			      enum hinic_func_port_state state);
 
+int hinic_port_get_cap(struct hinic_dev *nic_dev,
+		       struct hinic_port_cap *port_cap);
+
 #endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_rx.c b/drivers/net/ethernet/huawei/hinic/hinic_rx.c
index 6367fa1..bbe5d7d 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_rx.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_rx.c
@@ -58,6 +58,25 @@ void hinic_rxq_clean_stats(struct hinic_rxq *rxq)
 }
 
 /**
+ * hinic_rxq_get_stats - get statistics of Rx Queue
+ * @rxq: Logical Rx Queue
+ * @stats: return updated stats here
+ **/
+void hinic_rxq_get_stats(struct hinic_rxq *rxq, struct hinic_rxq_stats *stats)
+{
+	struct hinic_rxq_stats *rxq_stats = &rxq->rxq_stats;
+	unsigned int start;
+
+	u64_stats_update_begin(&stats->syncp);
+	do {
+		start = u64_stats_fetch_begin(&rxq_stats->syncp);
+		stats->pkts = rxq_stats->pkts;
+		stats->bytes = rxq_stats->bytes;
+	} while (u64_stats_fetch_retry(&rxq_stats->syncp, start));
+	u64_stats_update_end(&stats->syncp);
+}
+
+/**
  * rxq_stats_init - Initialize the statistics of specific queue
  * @rxq: Logical Rx Queue
  **/
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_rx.h b/drivers/net/ethernet/huawei/hinic/hinic_rx.h
index 538c886..27c9af4 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_rx.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_rx.h
@@ -45,6 +45,8 @@ struct hinic_rxq {
 
 void hinic_rxq_clean_stats(struct hinic_rxq *rxq);
 
+void hinic_rxq_get_stats(struct hinic_rxq *rxq, struct hinic_rxq_stats *stats);
+
 int hinic_init_rxq(struct hinic_rxq *rxq, struct hinic_rq *rq,
 		   struct net_device *netdev);
 
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_tx.c b/drivers/net/ethernet/huawei/hinic/hinic_tx.c
index d0c539f..b5056c3 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_tx.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_tx.c
@@ -67,6 +67,28 @@ void hinic_txq_clean_stats(struct hinic_txq *txq)
 }
 
 /**
+ * hinic_txq_get_stats - get statistics of Tx Queue
+ * @txq: Logical Tx Queue
+ * @stats: return updated stats here
+ **/
+void hinic_txq_get_stats(struct hinic_txq *txq, struct hinic_txq_stats *stats)
+{
+	struct hinic_txq_stats *txq_stats = &txq->txq_stats;
+	unsigned int start;
+
+	u64_stats_update_begin(&stats->syncp);
+	do {
+		start = u64_stats_fetch_begin(&txq_stats->syncp);
+		stats->pkts = txq_stats->pkts;
+		stats->bytes = txq_stats->bytes;
+		stats->tx_busy = txq_stats->tx_busy;
+		stats->tx_wake = txq_stats->tx_wake;
+		stats->tx_dropped = txq_stats->tx_dropped;
+	} while (u64_stats_fetch_retry(&txq_stats->syncp, start));
+	u64_stats_update_end(&stats->syncp);
+}
+
+/**
  * txq_stats_init - Initialize the statistics of specific queue
  * @txq: Logical Tx Queue
  **/
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_tx.h b/drivers/net/ethernet/huawei/hinic/hinic_tx.h
index 7123c7f..1fa55dc 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_tx.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_tx.h
@@ -50,6 +50,8 @@ struct hinic_txq {
 
 void hinic_txq_clean_stats(struct hinic_txq *txq);
 
+void hinic_txq_get_stats(struct hinic_txq *txq, struct hinic_txq_stats *stats);
+
 netdev_tx_t hinic_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
 
 int hinic_init_txq(struct hinic_txq *txq, struct hinic_sq *sq,
-- 
1.9.1

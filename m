From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH 2/6] qlcnic: additional driver statistics.
Date: Mon,  8 Mar 2010 02:14:46 -0800
Message-ID: <1268043290-19929-3-git-send-email-amit.salecha@qlogic.com>
References: <1268043290-19929-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com,
	ameen.rahman@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:53032 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753227Ab0CHKOw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Mar 2010 05:14:52 -0500
In-Reply-To: <1268043290-19929-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

Statistics added for lro/lso bytes, count for tx stop queue and
wake queue and skb alloc failure count.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h         |    5 +++++
 drivers/net/qlcnic/qlcnic_ethtool.c |   11 +++++++++++
 drivers/net/qlcnic/qlcnic_hw.c      |    1 +
 drivers/net/qlcnic/qlcnic_init.c    |    8 ++++++--
 drivers/net/qlcnic/qlcnic_main.c    |    5 +++++
 5 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index b40a851..9897b69 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -423,6 +423,11 @@ struct qlcnic_adapter_stats {
 	u64  lro_pkts;
 	u64  rxbytes;
 	u64  txbytes;
+	u64  lrobytes;
+	u64  lso_frames;
+	u64  xmit_on;
+	u64  xmit_off;
+	u64  skb_alloc_failure;
 };
 
 /*
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index ef12792..f83e15f 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -59,6 +59,17 @@ static const struct qlcnic_stats qlcnic_gstrings_stats[] = {
 		QLC_SIZEOF(stats.rxbytes), QLC_OFF(stats.rxbytes)},
 	{"tx_bytes",
 		QLC_SIZEOF(stats.txbytes), QLC_OFF(stats.txbytes)},
+	{"lrobytes",
+		QLC_SIZEOF(stats.lrobytes), QLC_OFF(stats.lrobytes)},
+	{"lso_frames",
+		QLC_SIZEOF(stats.lso_frames), QLC_OFF(stats.lso_frames)},
+	{"xmit_on",
+		QLC_SIZEOF(stats.xmit_on), QLC_OFF(stats.xmit_on)},
+	{"xmit_off",
+		QLC_SIZEOF(stats.xmit_off), QLC_OFF(stats.xmit_off)},
+	{"skb_alloc_failure", QLC_SIZEOF(stats.skb_alloc_failure),
+		QLC_OFF(stats.skb_alloc_failure)},
+
 };
 
 #define QLCNIC_STATS_LEN	ARRAY_SIZE(qlcnic_gstrings_stats)
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index 99a4d13..e95646b 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -349,6 +349,7 @@ qlcnic_send_cmd_descs(struct qlcnic_adapter *adapter,
 	if (nr_desc >= qlcnic_tx_avail(tx_ring)) {
 		netif_tx_stop_queue(tx_ring->txq);
 		__netif_tx_unlock_bh(tx_ring->txq);
+		adapter->stats.xmit_off++;
 		return -EBUSY;
 	}
 
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index ea00ab4..f0df971 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -1114,8 +1114,10 @@ qlcnic_alloc_rx_skb(struct qlcnic_adapter *adapter,
 	struct pci_dev *pdev = adapter->pdev;
 
 	buffer->skb = dev_alloc_skb(rds_ring->skb_size);
-	if (!buffer->skb)
+	if (!buffer->skb) {
+		adapter->stats.skb_alloc_failure++;
 		return -ENOMEM;
+	}
 
 	skb = buffer->skb;
 
@@ -1289,7 +1291,7 @@ qlcnic_process_lro(struct qlcnic_adapter *adapter,
 	netif_receive_skb(skb);
 
 	adapter->stats.lro_pkts++;
-	adapter->stats.rxbytes += length;
+	adapter->stats.lrobytes += length;
 
 	return buffer;
 }
@@ -1505,6 +1507,8 @@ qlcnic_process_rcv_diag(struct qlcnic_adapter *adapter,
 		adapter->diag_cnt++;
 
 	dev_kfree_skb_any(skb);
+	adapter->stats.rx_pkts++;
+	adapter->stats.rxbytes += length;
 
 	return buffer;
 }
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 665e8e5..fc72156 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -118,6 +118,7 @@ qlcnic_update_cmd_producer(struct qlcnic_adapter *adapter,
 	if (qlcnic_tx_avail(tx_ring) <= TX_STOP_THRESH) {
 		netif_stop_queue(adapter->netdev);
 		smp_mb();
+		adapter->stats.xmit_off++;
 	}
 }
 
@@ -1385,6 +1386,7 @@ qlcnic_tso_check(struct net_device *netdev,
 	int copied, offset, copy_len, hdr_len = 0, tso = 0, vlan_oob = 0;
 	struct cmd_desc_type0 *hwdesc;
 	struct vlan_ethhdr *vh;
+	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 
 	if (protocol == cpu_to_be16(ETH_P_8021Q)) {
 
@@ -1494,6 +1496,7 @@ qlcnic_tso_check(struct net_device *netdev,
 
 	tx_ring->producer = producer;
 	barrier();
+	adapter->stats.lso_frames++;
 }
 
 static int
@@ -1573,6 +1576,7 @@ qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	if (unlikely(no_of_desc + 2 > qlcnic_tx_avail(tx_ring))) {
 		netif_stop_queue(netdev);
+		adapter->stats.xmit_off++;
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1880,6 +1884,7 @@ static int qlcnic_process_cmd_ring(struct qlcnic_adapter *adapter)
 			if (qlcnic_tx_avail(tx_ring) > TX_STOP_THRESH) {
 				netif_wake_queue(netdev);
 				adapter->tx_timeo_cnt = 0;
+				adapter->stats.xmit_on++;
 			}
 			__netif_tx_unlock(tx_ring->txq);
 		}
-- 
1.6.0.2


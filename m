From: Shreyas N Bhatewara <sbhatewara@vmware.com>
Subject: [PATCH net-next 5/8] vmxnet3: Make ethtool handlers multiqueue aware
Date: Fri, 14 Jan 2011 16:59:47 -0800
Message-ID: <20110115005946.1064.97955.stgit@sbhatewara-dev1.eng.vmware.com>
References: <20110115005701.1064.67435.stgit@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110115005701.1064.67435.stgit@sbhatewara-dev1.eng.vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Show per-queue stats in ethtool -S output for vmxnet3 interface. Register dump
of ethtool should dump registers for all tx and rx queues.

Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_ethtool.c |  259 ++++++++++++++++++---------------
 1 files changed, 145 insertions(+), 114 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index 8e17fc8..d70cee1 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -68,76 +68,78 @@ vmxnet3_set_rx_csum(struct net_device *netdev, u32 val)
 static const struct vmxnet3_stat_desc
 vmxnet3_tq_dev_stats[] = {
 	/* description,         offset */
-	{ "TSO pkts tx",        offsetof(struct UPT1_TxStats, TSOPktsTxOK) },
-	{ "TSO bytes tx",       offsetof(struct UPT1_TxStats, TSOBytesTxOK) },
-	{ "ucast pkts tx",      offsetof(struct UPT1_TxStats, ucastPktsTxOK) },
-	{ "ucast bytes tx",     offsetof(struct UPT1_TxStats, ucastBytesTxOK) },
-	{ "mcast pkts tx",      offsetof(struct UPT1_TxStats, mcastPktsTxOK) },
-	{ "mcast bytes tx",     offsetof(struct UPT1_TxStats, mcastBytesTxOK) },
-	{ "bcast pkts tx",      offsetof(struct UPT1_TxStats, bcastPktsTxOK) },
-	{ "bcast bytes tx",     offsetof(struct UPT1_TxStats, bcastBytesTxOK) },
-	{ "pkts tx err",        offsetof(struct UPT1_TxStats, pktsTxError) },
-	{ "pkts tx discard",    offsetof(struct UPT1_TxStats, pktsTxDiscard) },
+	{ "Tx Queue#",        0 },
+	{ "  TSO pkts tx",	offsetof(struct UPT1_TxStats, TSOPktsTxOK) },
+	{ "  TSO bytes tx",	offsetof(struct UPT1_TxStats, TSOBytesTxOK) },
+	{ "  ucast pkts tx",	offsetof(struct UPT1_TxStats, ucastPktsTxOK) },
+	{ "  ucast bytes tx",	offsetof(struct UPT1_TxStats, ucastBytesTxOK) },
+	{ "  mcast pkts tx",	offsetof(struct UPT1_TxStats, mcastPktsTxOK) },
+	{ "  mcast bytes tx",	offsetof(struct UPT1_TxStats, mcastBytesTxOK) },
+	{ "  bcast pkts tx",	offsetof(struct UPT1_TxStats, bcastPktsTxOK) },
+	{ "  bcast bytes tx",	offsetof(struct UPT1_TxStats, bcastBytesTxOK) },
+	{ "  pkts tx err",	offsetof(struct UPT1_TxStats, pktsTxError) },
+	{ "  pkts tx discard",	offsetof(struct UPT1_TxStats, pktsTxDiscard) },
 };
 
 /* per tq stats maintained by the driver */
 static const struct vmxnet3_stat_desc
 vmxnet3_tq_driver_stats[] = {
 	/* description,         offset */
-	{"drv dropped tx total", offsetof(struct vmxnet3_tq_driver_stats,
-					drop_total) },
-	{ "   too many frags",  offsetof(struct vmxnet3_tq_driver_stats,
-					drop_too_many_frags) },
-	{ "   giant hdr",       offsetof(struct vmxnet3_tq_driver_stats,
-					drop_oversized_hdr) },
-	{ "   hdr err",         offsetof(struct vmxnet3_tq_driver_stats,
-					drop_hdr_inspect_err) },
-	{ "   tso",             offsetof(struct vmxnet3_tq_driver_stats,
-					drop_tso) },
-	{ "ring full",          offsetof(struct vmxnet3_tq_driver_stats,
-					tx_ring_full) },
-	{ "pkts linearized",    offsetof(struct vmxnet3_tq_driver_stats,
-					linearized) },
-	{ "hdr cloned",         offsetof(struct vmxnet3_tq_driver_stats,
-					copy_skb_header) },
-	{ "giant hdr",          offsetof(struct vmxnet3_tq_driver_stats,
-					oversized_hdr) },
+	{"  drv dropped tx total",	offsetof(struct vmxnet3_tq_driver_stats,
+						 drop_total) },
+	{ "     too many frags", offsetof(struct vmxnet3_tq_driver_stats,
+					  drop_too_many_frags) },
+	{ "     giant hdr",	offsetof(struct vmxnet3_tq_driver_stats,
+					 drop_oversized_hdr) },
+	{ "     hdr err",	offsetof(struct vmxnet3_tq_driver_stats,
+					 drop_hdr_inspect_err) },
+	{ "     tso",		offsetof(struct vmxnet3_tq_driver_stats,
+					 drop_tso) },
+	{ "  ring full",	offsetof(struct vmxnet3_tq_driver_stats,
+					 tx_ring_full) },
+	{ "  pkts linearized",	offsetof(struct vmxnet3_tq_driver_stats,
+					 linearized) },
+	{ "  hdr cloned",	offsetof(struct vmxnet3_tq_driver_stats,
+					 copy_skb_header) },
+	{ "  giant hdr",	offsetof(struct vmxnet3_tq_driver_stats,
+					 oversized_hdr) },
 };
 
 /* per rq stats maintained by the device */
 static const struct vmxnet3_stat_desc
 vmxnet3_rq_dev_stats[] = {
-	{ "LRO pkts rx",        offsetof(struct UPT1_RxStats, LROPktsRxOK) },
-	{ "LRO byte rx",        offsetof(struct UPT1_RxStats, LROBytesRxOK) },
-	{ "ucast pkts rx",      offsetof(struct UPT1_RxStats, ucastPktsRxOK) },
-	{ "ucast bytes rx",     offsetof(struct UPT1_RxStats, ucastBytesRxOK) },
-	{ "mcast pkts rx",      offsetof(struct UPT1_RxStats, mcastPktsRxOK) },
-	{ "mcast bytes rx",     offsetof(struct UPT1_RxStats, mcastBytesRxOK) },
-	{ "bcast pkts rx",      offsetof(struct UPT1_RxStats, bcastPktsRxOK) },
-	{ "bcast bytes rx",     offsetof(struct UPT1_RxStats, bcastBytesRxOK) },
-	{ "pkts rx out of buf", offsetof(struct UPT1_RxStats, pktsRxOutOfBuf) },
-	{ "pkts rx err",        offsetof(struct UPT1_RxStats, pktsRxError) },
+	{ "Rx Queue#",        0 },
+	{ "  LRO pkts rx",	offsetof(struct UPT1_RxStats, LROPktsRxOK) },
+	{ "  LRO byte rx",	offsetof(struct UPT1_RxStats, LROBytesRxOK) },
+	{ "  ucast pkts rx",	offsetof(struct UPT1_RxStats, ucastPktsRxOK) },
+	{ "  ucast bytes rx",	offsetof(struct UPT1_RxStats, ucastBytesRxOK) },
+	{ "  mcast pkts rx",	offsetof(struct UPT1_RxStats, mcastPktsRxOK) },
+	{ "  mcast bytes rx",	offsetof(struct UPT1_RxStats, mcastBytesRxOK) },
+	{ "  bcast pkts rx",	offsetof(struct UPT1_RxStats, bcastPktsRxOK) },
+	{ "  bcast bytes rx",	offsetof(struct UPT1_RxStats, bcastBytesRxOK) },
+	{ "  pkts rx OOB",	offsetof(struct UPT1_RxStats, pktsRxOutOfBuf) },
+	{ "  pkts rx err",	offsetof(struct UPT1_RxStats, pktsRxError) },
 };
 
 /* per rq stats maintained by the driver */
 static const struct vmxnet3_stat_desc
 vmxnet3_rq_driver_stats[] = {
 	/* description,         offset */
-	{ "drv dropped rx total", offsetof(struct vmxnet3_rq_driver_stats,
-					   drop_total) },
-	{ "   err",            offsetof(struct vmxnet3_rq_driver_stats,
-					drop_err) },
-	{ "   fcs",            offsetof(struct vmxnet3_rq_driver_stats,
-					drop_fcs) },
-	{ "rx buf alloc fail", offsetof(struct vmxnet3_rq_driver_stats,
-					rx_buf_alloc_failure) },
+	{ "  drv dropped rx total", offsetof(struct vmxnet3_rq_driver_stats,
+					     drop_total) },
+	{ "     err",		offsetof(struct vmxnet3_rq_driver_stats,
+					 drop_err) },
+	{ "     fcs",		offsetof(struct vmxnet3_rq_driver_stats,
+					 drop_fcs) },
+	{ "  rx buf alloc fail", offsetof(struct vmxnet3_rq_driver_stats,
+					  rx_buf_alloc_failure) },
 };
 
 /* gloabl stats maintained by the driver */
 static const struct vmxnet3_stat_desc
 vmxnet3_global_stats[] = {
 	/* description,         offset */
-	{ "tx timeout count",   offsetof(struct vmxnet3_adapter,
+	{ "tx timeout count",	offsetof(struct vmxnet3_adapter,
 					 tx_timeout_count) }
 };
 
@@ -193,12 +195,15 @@ vmxnet3_get_stats(struct net_device *netdev)
 static int
 vmxnet3_get_sset_count(struct net_device *netdev, int sset)
 {
+	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
 	switch (sset) {
 	case ETH_SS_STATS:
-		return ARRAY_SIZE(vmxnet3_tq_dev_stats) +
-			ARRAY_SIZE(vmxnet3_tq_driver_stats) +
-			ARRAY_SIZE(vmxnet3_rq_dev_stats) +
-			ARRAY_SIZE(vmxnet3_rq_driver_stats) +
+		return (ARRAY_SIZE(vmxnet3_tq_dev_stats) +
+			ARRAY_SIZE(vmxnet3_tq_driver_stats)) *
+		       adapter->num_tx_queues +
+		       (ARRAY_SIZE(vmxnet3_rq_dev_stats) +
+			ARRAY_SIZE(vmxnet3_rq_driver_stats)) *
+		       adapter->num_rx_queues +
 			ARRAY_SIZE(vmxnet3_global_stats);
 	default:
 		return -EOPNOTSUPP;
@@ -206,10 +211,16 @@ vmxnet3_get_sset_count(struct net_device *netdev, int sset)
 }
 
 
+/* Should be multiple of 4 */
+#define NUM_TX_REGS	8
+#define NUM_RX_REGS	12
+
 static int
 vmxnet3_get_regs_len(struct net_device *netdev)
 {
-	return 20 * sizeof(u32);
+	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
+	return (adapter->num_tx_queues * NUM_TX_REGS * sizeof(u32) +
+		adapter->num_rx_queues * NUM_RX_REGS * sizeof(u32));
 }
 
 
@@ -240,29 +251,37 @@ vmxnet3_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *drvinfo)
 static void
 vmxnet3_get_strings(struct net_device *netdev, u32 stringset, u8 *buf)
 {
+	 struct vmxnet3_adapter *adapter = netdev_priv(netdev);
 	if (stringset == ETH_SS_STATS) {
-		int i;
-
-		for (i = 0; i < ARRAY_SIZE(vmxnet3_tq_dev_stats); i++) {
-			memcpy(buf, vmxnet3_tq_dev_stats[i].desc,
-			       ETH_GSTRING_LEN);
-			buf += ETH_GSTRING_LEN;
-		}
-		for (i = 0; i < ARRAY_SIZE(vmxnet3_tq_driver_stats); i++) {
-			memcpy(buf, vmxnet3_tq_driver_stats[i].desc,
-			       ETH_GSTRING_LEN);
-			buf += ETH_GSTRING_LEN;
-		}
-		for (i = 0; i < ARRAY_SIZE(vmxnet3_rq_dev_stats); i++) {
-			memcpy(buf, vmxnet3_rq_dev_stats[i].desc,
-			       ETH_GSTRING_LEN);
-			buf += ETH_GSTRING_LEN;
+		int i, j;
+		for (j = 0; j < adapter->num_tx_queues; j++) {
+			for (i = 0; i < ARRAY_SIZE(vmxnet3_tq_dev_stats); i++) {
+				memcpy(buf, vmxnet3_tq_dev_stats[i].desc,
+				       ETH_GSTRING_LEN);
+				buf += ETH_GSTRING_LEN;
+			}
+			for (i = 0; i < ARRAY_SIZE(vmxnet3_tq_driver_stats);
+			     i++) {
+				memcpy(buf, vmxnet3_tq_driver_stats[i].desc,
+				       ETH_GSTRING_LEN);
+				buf += ETH_GSTRING_LEN;
+			}
 		}
-		for (i = 0; i < ARRAY_SIZE(vmxnet3_rq_driver_stats); i++) {
-			memcpy(buf, vmxnet3_rq_driver_stats[i].desc,
-			       ETH_GSTRING_LEN);
-			buf += ETH_GSTRING_LEN;
+
+		for (j = 0; j < adapter->num_rx_queues; j++) {
+			for (i = 0; i < ARRAY_SIZE(vmxnet3_rq_dev_stats); i++) {
+				memcpy(buf, vmxnet3_rq_dev_stats[i].desc,
+				       ETH_GSTRING_LEN);
+				buf += ETH_GSTRING_LEN;
+			}
+			for (i = 0; i < ARRAY_SIZE(vmxnet3_rq_driver_stats);
+			     i++) {
+				memcpy(buf, vmxnet3_rq_driver_stats[i].desc,
+				       ETH_GSTRING_LEN);
+				buf += ETH_GSTRING_LEN;
+			}
 		}
+
 		for (i = 0; i < ARRAY_SIZE(vmxnet3_global_stats); i++) {
 			memcpy(buf, vmxnet3_global_stats[i].desc,
 				ETH_GSTRING_LEN);
@@ -310,23 +329,31 @@ vmxnet3_get_ethtool_stats(struct net_device *netdev,
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD, VMXNET3_CMD_GET_STATS);
 
 	/* this does assume each counter is 64-bit wide */
-/* TODO change this for multiple queues */
-
-	base = (u8 *)&adapter->tqd_start[j].stats;
-	for (i = 0; i < ARRAY_SIZE(vmxnet3_tq_dev_stats); i++)
-		*buf++ = *(u64 *)(base + vmxnet3_tq_dev_stats[i].offset);
-
-	base = (u8 *)&adapter->tx_queue[j].stats;
-	for (i = 0; i < ARRAY_SIZE(vmxnet3_tq_driver_stats); i++)
-		*buf++ = *(u64 *)(base + vmxnet3_tq_driver_stats[i].offset);
-
-	base = (u8 *)&adapter->rqd_start[j].stats;
-	for (i = 0; i < ARRAY_SIZE(vmxnet3_rq_dev_stats); i++)
-		*buf++ = *(u64 *)(base + vmxnet3_rq_dev_stats[i].offset);
+	for (j = 0; j < adapter->num_tx_queues; j++) {
+		base = (u8 *)&adapter->tqd_start[j].stats;
+		*buf++ = (u64)j;
+		for (i = 1; i < ARRAY_SIZE(vmxnet3_tq_dev_stats); i++)
+			*buf++ = *(u64 *)(base +
+					  vmxnet3_tq_dev_stats[i].offset);
+
+		base = (u8 *)&adapter->tx_queue[j].stats;
+		for (i = 0; i < ARRAY_SIZE(vmxnet3_tq_driver_stats); i++)
+			*buf++ = *(u64 *)(base +
+					  vmxnet3_tq_driver_stats[i].offset);
+	}
 
-	base = (u8 *)&adapter->rx_queue[j].stats;
-	for (i = 0; i < ARRAY_SIZE(vmxnet3_rq_driver_stats); i++)
-		*buf++ = *(u64 *)(base + vmxnet3_rq_driver_stats[i].offset);
+	for (j = 0; j < adapter->num_tx_queues; j++) {
+		base = (u8 *)&adapter->rqd_start[j].stats;
+		*buf++ = (u64) j;
+		for (i = 1; i < ARRAY_SIZE(vmxnet3_rq_dev_stats); i++)
+			*buf++ = *(u64 *)(base +
+					  vmxnet3_rq_dev_stats[i].offset);
+
+		base = (u8 *)&adapter->rx_queue[j].stats;
+		for (i = 0; i < ARRAY_SIZE(vmxnet3_rq_driver_stats); i++)
+			*buf++ = *(u64 *)(base +
+					  vmxnet3_rq_driver_stats[i].offset);
+	}
 
 	base = (u8 *)adapter;
 	for (i = 0; i < ARRAY_SIZE(vmxnet3_global_stats); i++)
@@ -339,7 +366,7 @@ vmxnet3_get_regs(struct net_device *netdev, struct ethtool_regs *regs, void *p)
 {
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
 	u32 *buf = p;
-	int i = 0;
+	int i = 0, j = 0;
 
 	memset(p, 0, vmxnet3_get_regs_len(netdev));
 
@@ -348,31 +375,35 @@ vmxnet3_get_regs(struct net_device *netdev, struct ethtool_regs *regs, void *p)
 	/* Update vmxnet3_get_regs_len if we want to dump more registers */
 
 	/* make each ring use multiple of 16 bytes */
-/* TODO change this for multiple queues */
-	buf[0] = adapter->tx_queue[i].tx_ring.next2fill;
-	buf[1] = adapter->tx_queue[i].tx_ring.next2comp;
-	buf[2] = adapter->tx_queue[i].tx_ring.gen;
-	buf[3] = 0;
-
-	buf[4] = adapter->tx_queue[i].comp_ring.next2proc;
-	buf[5] = adapter->tx_queue[i].comp_ring.gen;
-	buf[6] = adapter->tx_queue[i].stopped;
-	buf[7] = 0;
-
-	buf[8] = adapter->rx_queue[i].rx_ring[0].next2fill;
-	buf[9] = adapter->rx_queue[i].rx_ring[0].next2comp;
-	buf[10] = adapter->rx_queue[i].rx_ring[0].gen;
-	buf[11] = 0;
-
-	buf[12] = adapter->rx_queue[i].rx_ring[1].next2fill;
-	buf[13] = adapter->rx_queue[i].rx_ring[1].next2comp;
-	buf[14] = adapter->rx_queue[i].rx_ring[1].gen;
-	buf[15] = 0;
-
-	buf[16] = adapter->rx_queue[i].comp_ring.next2proc;
-	buf[17] = adapter->rx_queue[i].comp_ring.gen;
-	buf[18] = 0;
-	buf[19] = 0;
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		buf[j++] = adapter->tx_queue[i].tx_ring.next2fill;
+		buf[j++] = adapter->tx_queue[i].tx_ring.next2comp;
+		buf[j++] = adapter->tx_queue[i].tx_ring.gen;
+		buf[j++] = 0;
+
+		buf[j++] = adapter->tx_queue[i].comp_ring.next2proc;
+		buf[j++] = adapter->tx_queue[i].comp_ring.gen;
+		buf[j++] = adapter->tx_queue[i].stopped;
+		buf[j++] = 0;
+	}
+
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		buf[j++] = adapter->rx_queue[i].rx_ring[0].next2fill;
+		buf[j++] = adapter->rx_queue[i].rx_ring[0].next2comp;
+		buf[j++] = adapter->rx_queue[i].rx_ring[0].gen;
+		buf[j++] = 0;
+
+		buf[j++] = adapter->rx_queue[i].rx_ring[1].next2fill;
+		buf[j++] = adapter->rx_queue[i].rx_ring[1].next2comp;
+		buf[j++] = adapter->rx_queue[i].rx_ring[1].gen;
+		buf[j++] = 0;
+
+		buf[j++] = adapter->rx_queue[i].comp_ring.next2proc;
+		buf[j++] = adapter->rx_queue[i].comp_ring.gen;
+		buf[j++] = 0;
+		buf[j++] = 0;
+	}
+
 }
 
 

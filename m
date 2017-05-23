From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH v2 net-next 01/11] qede: Fix sparse warnings
Date: Tue, 23 May 2017 09:41:18 +0300
Message-ID: <1495521688-27669-2-git-send-email-Yuval.Mintz@cavium.com>
References: <1495521688-27669-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Manish Chopra <Manish.Chopra@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0062.outbound.protection.outlook.com ([104.47.32.62]:4848
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1761791AbdEWGmP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 02:42:15 -0400
In-Reply-To: <1495521688-27669-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <Manish.Chopra@cavium.com>

Solves the following warning in qede -
 - Several cases of missing cpu_to_le16() conversions
 - Adds 'static' to one function declaration
 - Removes dcbnl operation that's currently getting populated twice

Signed-off-by: Manish Chopra <Manish.Chopra@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede_dcbnl.c   |  1 -
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 10 ++++++----
 drivers/net/ethernet/qlogic/qede/qede_fp.c      | 25 ++++++++++++++-----------
 drivers/net/ethernet/qlogic/qede/qede_roce.c    |  4 ++--
 4 files changed, 22 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_dcbnl.c b/drivers/net/ethernet/qlogic/qede/qede_dcbnl.c
index a9e7379..6e7747b 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_dcbnl.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_dcbnl.c
@@ -313,7 +313,6 @@ static int qede_dcbnl_ieee_peer_getets(struct net_device *netdev,
 	.ieee_setets = qede_dcbnl_ieee_setets,
 	.ieee_getapp = qede_dcbnl_ieee_getapp,
 	.ieee_setapp = qede_dcbnl_ieee_setapp,
-	.getdcbx = qede_dcbnl_getdcbx,
 	.ieee_peer_getpfc = qede_dcbnl_ieee_peer_getpfc,
 	.ieee_peer_getets = qede_dcbnl_ieee_peer_getets,
 	.getstate = qede_dcbnl_getstate,
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index 6c76a12..6a03d3e 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -1290,7 +1290,8 @@ static int qede_selftest_transmit_traffic(struct qede_dev *edev,
 	struct qede_tx_queue *txq = NULL;
 	struct eth_tx_1st_bd *first_bd;
 	dma_addr_t mapping;
-	int i, idx, val;
+	int i, idx;
+	u16 val;
 
 	for_each_queue(i) {
 		if (edev->fp_array[i].type & QEDE_FASTPATH_TX) {
@@ -1312,7 +1313,8 @@ static int qede_selftest_transmit_traffic(struct qede_dev *edev,
 	val = 1 << ETH_TX_1ST_BD_FLAGS_START_BD_SHIFT;
 	first_bd->data.bd_flags.bitfields = val;
 	val = skb->len & ETH_TX_DATA_1ST_BD_PKT_LEN_MASK;
-	first_bd->data.bitfields |= (val << ETH_TX_DATA_1ST_BD_PKT_LEN_SHIFT);
+	val = val << ETH_TX_DATA_1ST_BD_PKT_LEN_SHIFT;
+	first_bd->data.bitfields |= cpu_to_le16(val);
 
 	/* Map skb linear data for DMA and set in the first BD */
 	mapping = dma_map_single(&edev->pdev->dev, skb->data,
@@ -1327,8 +1329,8 @@ static int qede_selftest_transmit_traffic(struct qede_dev *edev,
 	first_bd->data.nbds = 1;
 	txq->sw_tx_prod = (txq->sw_tx_prod + 1) % txq->num_tx_buffers;
 	/* 'next page' entries are counted in the producer value */
-	val = cpu_to_le16(qed_chain_get_prod_idx(&txq->tx_pbl));
-	txq->tx_db.data.bd_prod = val;
+	val = qed_chain_get_prod_idx(&txq->tx_pbl);
+	txq->tx_db.data.bd_prod = cpu_to_le16(val);
 
 	/* wmb makes sure that the BDs data is updated before updating the
 	 * producer, otherwise FW may read old data from the BDs.
diff --git a/drivers/net/ethernet/qlogic/qede/qede_fp.c b/drivers/net/ethernet/qlogic/qede/qede_fp.c
index 38c8265..892eb98 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_fp.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_fp.c
@@ -335,6 +335,7 @@ static int qede_xdp_xmit(struct qede_dev *edev, struct qede_fastpath *fp,
 	struct qede_tx_queue *txq = fp->xdp_tx;
 	struct eth_tx_1st_bd *first_bd;
 	u16 idx = txq->sw_tx_prod;
+	u16 val;
 
 	if (!qed_chain_get_elem_left(&txq->tx_pbl)) {
 		txq->stopped_cnt++;
@@ -346,9 +347,11 @@ static int qede_xdp_xmit(struct qede_dev *edev, struct qede_fastpath *fp,
 	memset(first_bd, 0, sizeof(*first_bd));
 	first_bd->data.bd_flags.bitfields =
 	    BIT(ETH_TX_1ST_BD_FLAGS_START_BD_SHIFT);
-	first_bd->data.bitfields |=
-	    (length & ETH_TX_DATA_1ST_BD_PKT_LEN_MASK) <<
-	    ETH_TX_DATA_1ST_BD_PKT_LEN_SHIFT;
+
+	val = (length & ETH_TX_DATA_1ST_BD_PKT_LEN_MASK) <<
+	       ETH_TX_DATA_1ST_BD_PKT_LEN_SHIFT;
+
+	first_bd->data.bitfields |= cpu_to_le16(val);
 	first_bd->data.nbds = 1;
 
 	/* We can safely ignore the offset, as it's 0 for XDP */
@@ -1424,7 +1427,7 @@ netdev_tx_t qede_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	struct eth_tx_2nd_bd *second_bd = NULL;
 	struct eth_tx_3rd_bd *third_bd = NULL;
 	struct eth_tx_bd *tx_data_bd = NULL;
-	u16 txq_index;
+	u16 txq_index, val = 0;
 	u8 nbd = 0;
 	dma_addr_t mapping;
 	int rc, frag_idx = 0, ipv6_ext = 0;
@@ -1513,8 +1516,8 @@ netdev_tx_t qede_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 		if (xmit_type & XMIT_ENC) {
 			first_bd->data.bd_flags.bitfields |=
 				1 << ETH_TX_1ST_BD_FLAGS_IP_CSUM_SHIFT;
-			first_bd->data.bitfields |=
-			    1 << ETH_TX_DATA_1ST_BD_TUNN_FLAG_SHIFT;
+
+			val |= (1 << ETH_TX_DATA_1ST_BD_TUNN_FLAG_SHIFT);
 		}
 
 		/* Legacy FW had flipped behavior in regard to this bit -
@@ -1522,8 +1525,7 @@ netdev_tx_t qede_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 		 * packets when it didn't need to.
 		 */
 		if (unlikely(txq->is_legacy))
-			first_bd->data.bitfields ^=
-			    1 << ETH_TX_DATA_1ST_BD_TUNN_FLAG_SHIFT;
+			val ^= (1 << ETH_TX_DATA_1ST_BD_TUNN_FLAG_SHIFT);
 
 		/* If the packet is IPv6 with extension header, indicate that
 		 * to FW and pass few params, since the device cracker doesn't
@@ -1587,11 +1589,12 @@ netdev_tx_t qede_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 			data_split = true;
 		}
 	} else {
-		first_bd->data.bitfields |=
-		    (skb->len & ETH_TX_DATA_1ST_BD_PKT_LEN_MASK) <<
-		    ETH_TX_DATA_1ST_BD_PKT_LEN_SHIFT;
+		val |= ((skb->len & ETH_TX_DATA_1ST_BD_PKT_LEN_MASK) <<
+			 ETH_TX_DATA_1ST_BD_PKT_LEN_SHIFT);
 	}
 
+	first_bd->data.bitfields = cpu_to_le16(val);
+
 	/* Handle fragmented skb */
 	/* special handle for frags inside 2nd and 3rd bds.. */
 	while (tx_data_bd && frag_idx < skb_shinfo(skb)->nr_frags) {
diff --git a/drivers/net/ethernet/qlogic/qede/qede_roce.c b/drivers/net/ethernet/qlogic/qede/qede_roce.c
index f00657c..c0030fb 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_roce.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_roce.c
@@ -221,8 +221,8 @@ static void qede_roce_changeaddr(struct qede_dev *edev)
 		qedr_drv->notify(edev->rdma_info.qedr_dev, QEDE_CHANGE_ADDR);
 }
 
-struct qede_roce_event_work *qede_roce_get_free_event_node(struct qede_dev
-							   *edev)
+static struct qede_roce_event_work *
+qede_roce_get_free_event_node(struct qede_dev *edev)
 {
 	struct qede_roce_event_work *event_node = NULL;
 	struct list_head *list_node = NULL;
-- 
1.9.3

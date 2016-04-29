From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net-next 3/3] qede: add implementation for internal loopback test.
Date: Thu, 28 Apr 2016 20:20:54 -0400
Message-ID: <1461889254-10534-4-git-send-email-sudarsana.kalluru@qlogic.com>
References: <1461889254-10534-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>, <manish.chopra@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:60849 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752922AbcD2BDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 21:03:40 -0400
In-Reply-To: <1461889254-10534-1-git-send-email-sudarsana.kalluru@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the qede implementation for internal loopback test.

Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede.h         |   4 +
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 234 ++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qede/qede_main.c    |   8 +-
 3 files changed, 242 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index a687e7a..ff3ac0c 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -308,6 +308,10 @@ void qede_reload(struct qede_dev *edev,
 		 union qede_reload_args *args);
 int qede_change_mtu(struct net_device *dev, int new_mtu);
 void qede_fill_by_demand_stats(struct qede_dev *edev);
+bool qede_has_rx_work(struct qede_rx_queue *rxq);
+int qede_txq_has_work(struct qede_tx_queue *txq);
+void qede_recycle_rx_bd_ring(struct qede_rx_queue *rxq, struct qede_dev *edev,
+			     u8 count);
 
 #define RX_RING_SIZE_POW	13
 #define RX_RING_SIZE		((u16)BIT(RX_RING_SIZE_POW))
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index e25a05b..0d04f16 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -9,6 +9,7 @@
 #include <linux/version.h>
 #include <linux/types.h>
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/string.h>
 #include <linux/pci.h>
@@ -27,6 +28,9 @@
 #define QEDE_RQSTAT_STRING(stat_name) (#stat_name)
 #define QEDE_RQSTAT(stat_name) \
 	 {QEDE_RQSTAT_OFFSET(stat_name), QEDE_RQSTAT_STRING(stat_name)}
+
+#define QEDE_SELFTEST_POLL_COUNT 100
+
 static const struct {
 	u64 offset;
 	char string[ETH_GSTRING_LEN];
@@ -126,6 +130,7 @@ static const char qede_private_arr[QEDE_PRI_FLAG_LEN][ETH_GSTRING_LEN] = {
 };
 
 enum qede_ethtool_tests {
+	QEDE_ETHTOOL_INT_LOOPBACK,
 	QEDE_ETHTOOL_INTERRUPT_TEST,
 	QEDE_ETHTOOL_MEMORY_TEST,
 	QEDE_ETHTOOL_REGISTER_TEST,
@@ -134,6 +139,7 @@ enum qede_ethtool_tests {
 };
 
 static const char qede_tests_str_arr[QEDE_ETHTOOL_TEST_MAX][ETH_GSTRING_LEN] = {
+	"Internal loopback (offline)",
 	"Interrupt (online)\t",
 	"Memory (online)\t\t",
 	"Register (online)\t",
@@ -847,6 +853,226 @@ static int qede_set_rxfh(struct net_device *dev, const u32 *indir,
 	return 0;
 }
 
+/* This function enables the interrupt generation and the NAPI on the device */
+static void qede_netif_start(struct qede_dev *edev)
+{
+	int i;
+
+	if (!netif_running(edev->ndev))
+		return;
+
+	for_each_rss(i) {
+		/* Update and reenable interrupts */
+		qed_sb_ack(edev->fp_array[i].sb_info, IGU_INT_ENABLE, 1);
+		napi_enable(&edev->fp_array[i].napi);
+	}
+}
+
+/* This function disables the NAPI and the interrupt generation on the device */
+static void qede_netif_stop(struct qede_dev *edev)
+{
+	int i;
+
+	for_each_rss(i) {
+		napi_disable(&edev->fp_array[i].napi);
+		/* Disable interrupts */
+		qed_sb_ack(edev->fp_array[i].sb_info, IGU_INT_DISABLE, 0);
+	}
+}
+
+static int qede_selftest_transmit_traffic(struct qede_dev *edev,
+					  struct sk_buff *skb)
+{
+	struct qede_tx_queue *txq = &edev->fp_array[0].txqs[0];
+	struct eth_tx_1st_bd *first_bd;
+	dma_addr_t mapping;
+	int i, idx, val;
+
+	/* Fill the entry in the SW ring and the BDs in the FW ring */
+	idx = txq->sw_tx_prod & NUM_TX_BDS_MAX;
+	txq->sw_tx_ring[idx].skb = skb;
+	first_bd = qed_chain_produce(&txq->tx_pbl);
+	memset(first_bd, 0, sizeof(*first_bd));
+	val = 1 << ETH_TX_1ST_BD_FLAGS_START_BD_SHIFT;
+	first_bd->data.bd_flags.bitfields = val;
+
+	/* Map skb linear data for DMA and set in the first BD */
+	mapping = dma_map_single(&edev->pdev->dev, skb->data,
+				 skb_headlen(skb), DMA_TO_DEVICE);
+	if (unlikely(dma_mapping_error(&edev->pdev->dev, mapping))) {
+		DP_NOTICE(edev, "SKB mapping failed\n");
+		return -ENOMEM;
+	}
+	BD_SET_UNMAP_ADDR_LEN(first_bd, mapping, skb_headlen(skb));
+
+	/* update the first BD with the actual num BDs */
+	first_bd->data.nbds = 1;
+	txq->sw_tx_prod++;
+	/* 'next page' entries are counted in the producer value */
+	val = cpu_to_le16(qed_chain_get_prod_idx(&txq->tx_pbl));
+	txq->tx_db.data.bd_prod = val;
+
+	/* wmb makes sure that the BDs data is updated before updating the
+	 * producer, otherwise FW may read old data from the BDs.
+	 */
+	wmb();
+	barrier();
+	writel(txq->tx_db.raw, txq->doorbell_addr);
+
+	/* mmiowb is needed to synchronize doorbell writes from more than one
+	 * processor. It guarantees that the write arrives to the device before
+	 * the queue lock is released and another start_xmit is called (possibly
+	 * on another CPU). Without this barrier, the next doorbell can bypass
+	 * this doorbell. This is applicable to IA64/Altix systems.
+	 */
+	mmiowb();
+
+	for (i = 0; i < QEDE_SELFTEST_POLL_COUNT; i++) {
+		if (qede_txq_has_work(txq))
+			break;
+		usleep_range(100, 200);
+	}
+
+	if (!qede_txq_has_work(txq)) {
+		DP_NOTICE(edev, "Tx completion didn't happen\n");
+		return -1;
+	}
+
+	first_bd = (struct eth_tx_1st_bd *)qed_chain_consume(&txq->tx_pbl);
+	dma_unmap_page(&edev->pdev->dev, BD_UNMAP_ADDR(first_bd),
+		       BD_UNMAP_LEN(first_bd), DMA_TO_DEVICE);
+	txq->sw_tx_cons++;
+	txq->sw_tx_ring[idx].skb = NULL;
+
+	return 0;
+}
+
+static int qede_selftest_receive_traffic(struct qede_dev *edev)
+{
+	struct qede_rx_queue *rxq = edev->fp_array[0].rxq;
+	u16 hw_comp_cons, sw_comp_cons, sw_rx_index, len;
+	struct eth_fast_path_rx_reg_cqe *fp_cqe;
+	struct sw_rx_data *sw_rx_data;
+	union eth_rx_cqe *cqe;
+	u8 *data_ptr;
+	int i;
+
+	/* The packet is expected to receive on rx-queue 0 even though RSS is
+	 * enabled. This is because the queue 0 is configured as the default
+	 * queue and that the loopback traffic is not IP.
+	 */
+	for (i = 0; i < QEDE_SELFTEST_POLL_COUNT; i++) {
+		if (qede_has_rx_work(rxq))
+			break;
+		usleep_range(100, 200);
+	}
+
+	if (!qede_has_rx_work(rxq)) {
+		DP_NOTICE(edev, "Failed to receive the traffic\n");
+		return -1;
+	}
+
+	hw_comp_cons = le16_to_cpu(*rxq->hw_cons_ptr);
+	sw_comp_cons = qed_chain_get_cons_idx(&rxq->rx_comp_ring);
+
+	/* Memory barrier to prevent the CPU from doing speculative reads of CQE
+	 * / BD before reading hw_comp_cons. If the CQE is read before it is
+	 * written by FW, then FW writes CQE and SB, and then the CPU reads the
+	 * hw_comp_cons, it will use an old CQE.
+	 */
+	rmb();
+
+	/* Get the CQE from the completion ring */
+	cqe = (union eth_rx_cqe *)qed_chain_consume(&rxq->rx_comp_ring);
+
+	/* Get the data from the SW ring */
+	sw_rx_index = rxq->sw_rx_cons & NUM_RX_BDS_MAX;
+	sw_rx_data = &rxq->sw_rx_ring[sw_rx_index];
+	fp_cqe = &cqe->fast_path_regular;
+	len =  le16_to_cpu(fp_cqe->len_on_first_bd);
+	data_ptr = (u8 *)(page_address(sw_rx_data->data) +
+		     fp_cqe->placement_offset + sw_rx_data->page_offset);
+	for (i = ETH_HLEN; i < len; i++)
+		if (data_ptr[i] != (unsigned char)(i & 0xff)) {
+			DP_NOTICE(edev, "Loopback test failed\n");
+			qede_recycle_rx_bd_ring(rxq, edev, 1);
+			return -1;
+		}
+
+	qede_recycle_rx_bd_ring(rxq, edev, 1);
+
+	return 0;
+}
+
+static int qede_selftest_run_loopback(struct qede_dev *edev, u32 loopback_mode)
+{
+	struct qed_link_params link_params;
+	struct sk_buff *skb = NULL;
+	int rc = 0, i;
+	u32 pkt_size;
+	u8 *packet;
+
+	if (!netif_running(edev->ndev)) {
+		DP_NOTICE(edev, "Interface is down\n");
+		return -EINVAL;
+	}
+
+	qede_netif_stop(edev);
+
+	/* Bring up the link in Loopback mode */
+	memset(&link_params, 0, sizeof(link_params));
+	link_params.link_up = true;
+	link_params.override_flags = QED_LINK_OVERRIDE_LOOPBACK_MODE;
+	link_params.loopback_mode = loopback_mode;
+	edev->ops->common->set_link(edev->cdev, &link_params);
+
+	/* Wait for loopback configuration to apply */
+	msleep_interruptible(500);
+
+	/* prepare the loopback packet */
+	pkt_size = edev->ndev->mtu + ETH_HLEN;
+
+	skb = netdev_alloc_skb(edev->ndev, pkt_size);
+	if (!skb) {
+		DP_INFO(edev, "Can't allocate skb\n");
+		rc = -ENOMEM;
+		goto test_loopback_exit;
+	}
+	packet = skb_put(skb, pkt_size);
+	ether_addr_copy(packet, edev->ndev->dev_addr);
+	ether_addr_copy(packet + ETH_ALEN, edev->ndev->dev_addr);
+	memset(packet + (2 * ETH_ALEN), 0x77, (ETH_HLEN - (2 * ETH_ALEN)));
+	for (i = ETH_HLEN; i < pkt_size; i++)
+		packet[i] = (unsigned char)(i & 0xff);
+
+	rc = qede_selftest_transmit_traffic(edev, skb);
+	if (rc)
+		goto test_loopback_exit;
+
+	rc = qede_selftest_receive_traffic(edev);
+	if (rc)
+		goto test_loopback_exit;
+
+	DP_VERBOSE(edev, NETIF_MSG_RX_STATUS, "Loopback test successful\n");
+
+test_loopback_exit:
+	dev_kfree_skb(skb);
+
+	/* Bring up the link in Normal mode */
+	memset(&link_params, 0, sizeof(link_params));
+	link_params.link_up = true;
+	link_params.override_flags = QED_LINK_OVERRIDE_LOOPBACK_MODE;
+	link_params.loopback_mode = QED_LINK_LOOPBACK_NONE;
+	edev->ops->common->set_link(edev->cdev, &link_params);
+
+	/* Wait for loopback configuration to apply */
+	msleep_interruptible(500);
+
+	qede_netif_start(edev);
+
+	return rc;
+}
+
 static void qede_self_test(struct net_device *dev,
 			   struct ethtool_test *etest, u64 *buf)
 {
@@ -859,6 +1085,14 @@ static void qede_self_test(struct net_device *dev,
 
 	memset(buf, 0, sizeof(u64) * QEDE_ETHTOOL_TEST_MAX);
 
+	if (etest->flags & ETH_TEST_FL_OFFLINE) {
+		if (qede_selftest_run_loopback(edev,
+					       QED_LINK_LOOPBACK_INT_PHY)) {
+			buf[QEDE_ETHTOOL_INT_LOOPBACK] = 1;
+			etest->flags |= ETH_TEST_FL_FAILED;
+		}
+	}
+
 	if (edev->ops->common->selftest->selftest_interrupt(edev->cdev)) {
 		buf[QEDE_ETHTOOL_INTERRUPT_TEST] = 1;
 		etest->flags |= ETH_TEST_FL_FAILED;
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 1e3ee49..82d85cc 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -668,7 +668,7 @@ netdev_tx_t qede_start_xmit(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 }
 
-static int qede_txq_has_work(struct qede_tx_queue *txq)
+int qede_txq_has_work(struct qede_tx_queue *txq)
 {
 	u16 hw_bd_cons;
 
@@ -751,7 +751,7 @@ static int qede_tx_int(struct qede_dev *edev,
 	return 0;
 }
 
-static bool qede_has_rx_work(struct qede_rx_queue *rxq)
+bool qede_has_rx_work(struct qede_rx_queue *rxq)
 {
 	u16 hw_comp_cons, sw_comp_cons;
 
@@ -806,8 +806,8 @@ static inline void qede_reuse_page(struct qede_dev *edev,
 /* In case of allocation failures reuse buffers
  * from consumer index to produce buffers for firmware
  */
-static void qede_recycle_rx_bd_ring(struct qede_rx_queue *rxq,
-				    struct qede_dev *edev, u8 count)
+void qede_recycle_rx_bd_ring(struct qede_rx_queue *rxq,
+			     struct qede_dev *edev, u8 count)
 {
 	struct sw_rx_data *curr_cons;
 
-- 
1.8.3.1

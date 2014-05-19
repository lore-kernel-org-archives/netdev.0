From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 9/9] net: mv643xx_eth: Implement software TSO
Date: Mon, 19 May 2014 14:00:00 -0300
Message-ID: <1400518800-6111-10-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1400518800-6111-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:53633 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S964837AbaESRBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 13:01:25 -0400
In-Reply-To: <1400518800-6111-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that the TSO helper API has been introduced, this commit makes use
of it to add support for software TSO in this driver.

This feature allows to improve outbound throughput performance significantly.
Running iperf tests shows a 30% improvement, tested on a Kirkwood Openblocks
A6 board.

$ ethtool -K eth0 tso off
$ iperf -c 192.168.0.45 -t 3
------------------------------------------------------------
Client connecting to 192.168.0.45, TCP port 5001
TCP window size: 43.8 KByte (default)
------------------------------------------------------------
[  3] local 192.168.0.159 port 46389 connected with 192.168.0.45 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0- 3.0 sec   217 MBytes   607 Mbits/sec

$ ethtool -K eth0 tso on
$ iperf -c 192.168.0.45 -t 3
------------------------------------------------------------
Client connecting to 192.168.0.45, TCP port 5001
TCP window size: 43.8 KByte (default)
------------------------------------------------------------
[  3] local 192.168.0.159 port 46390 connected with 192.168.0.45 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0- 3.0 sec   336 MBytes   938 Mbits/sec

This commit is just an example of the usage of the TSO API, it works fine
but needs some more work. In particular, the descriptor unmapping path must
avoid unmapping the TSO headers.

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c | 164 ++++++++++++++++++++++++++++-
 1 file changed, 160 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 8854751..3b0f818 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -42,6 +42,7 @@
 #include <linux/dma-mapping.h>
 #include <linux/in.h>
 #include <linux/ip.h>
+#include <net/tso.h>
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/etherdevice.h>
@@ -179,9 +180,10 @@ static char mv643xx_eth_driver_version[] = "1.4";
  * Misc definitions.
  */
 #define DEFAULT_RX_QUEUE_SIZE	128
-#define DEFAULT_TX_QUEUE_SIZE	256
+#define DEFAULT_TX_QUEUE_SIZE	512
 #define SKB_DMA_REALIGN		((PAGE_SIZE - NET_SKB_PAD) % SMP_CACHE_BYTES)
 
+#define TSO_HEADER_SIZE		128
 
 /*
  * RX/TX descriptors.
@@ -346,6 +348,9 @@ struct tx_queue {
 	int tx_curr_desc;
 	int tx_used_desc;
 
+	char *tso_hdrs;
+	dma_addr_t tso_hdrs_dma;
+
 	struct tx_desc *tx_desc_area;
 	dma_addr_t tx_desc_dma;
 	int tx_desc_area_size;
@@ -722,6 +727,138 @@ no_csum:
 	return 0;
 }
 
+static inline int
+txq_put_data_tso(struct net_device *dev, struct tx_queue *txq,
+		 struct sk_buff *skb, char *data, int length,
+		 bool last_tcp, bool is_last)
+{
+	int tx_index;
+	u32 cmd_sts;
+	struct tx_desc *desc;
+
+	tx_index = txq->tx_curr_desc++;
+	if (txq->tx_curr_desc == txq->tx_ring_size)
+		txq->tx_curr_desc = 0;
+	desc = &txq->tx_desc_area[tx_index];
+
+	desc->l4i_chk = 0;
+	desc->byte_cnt = length;
+	desc->buf_ptr = dma_map_single(dev->dev.parent, data,
+				       length, DMA_TO_DEVICE);
+	if (unlikely(dma_mapping_error(dev->dev.parent, desc->buf_ptr))) {
+		WARN(1, "dma_map_single failed!\n");
+		return -ENOMEM;
+	}
+
+	cmd_sts = BUFFER_OWNED_BY_DMA;
+	if (last_tcp) {
+		/* last descriptor in the TCP packet */
+		cmd_sts |= ZERO_PADDING | TX_LAST_DESC;
+		/* last descriptor in SKB */
+		if (is_last)
+			cmd_sts |= TX_ENABLE_INTERRUPT;
+	}
+	desc->cmd_sts = cmd_sts;
+	return 0;
+}
+
+static inline void
+txq_put_hdr_tso(struct sk_buff *skb, struct tx_queue *txq, int length)
+{
+	struct mv643xx_eth_private *mp = txq_to_mp(txq);
+	int hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
+	int tx_index;
+	struct tx_desc *desc;
+	int ret;
+	u32 cmd_csum = 0;
+	u16 l4i_chk = 0;
+
+	tx_index = txq->tx_curr_desc;
+	desc = &txq->tx_desc_area[tx_index];
+
+	ret = skb_tx_csum(mp, skb, &l4i_chk, &cmd_csum, length);
+	if (ret)
+		WARN(1, "failed to prepare checksum!");
+
+	/* Should we set this? Can't use the value from skb_tx_csum()
+	 * as it's not the correct initial L4 checksum to use. */
+	desc->l4i_chk = 0;
+
+	desc->byte_cnt = hdr_len;
+	desc->buf_ptr = txq->tso_hdrs_dma +
+			txq->tx_curr_desc * TSO_HEADER_SIZE;
+	desc->cmd_sts = cmd_csum | BUFFER_OWNED_BY_DMA  | TX_FIRST_DESC |
+				   GEN_CRC;
+
+	txq->tx_curr_desc++;
+	if (txq->tx_curr_desc == txq->tx_ring_size)
+		txq->tx_curr_desc = 0;
+}
+
+static int txq_submit_tso(struct tx_queue *txq, struct sk_buff *skb,
+			  struct net_device *dev)
+{
+	struct mv643xx_eth_private *mp = txq_to_mp(txq);
+	int total_len, data_left, ret;
+	int desc_count = 0;
+	struct tso_t tso;
+	int hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
+
+	/* Count needed descriptors */
+	if ((txq->tx_desc_count + tso_count_descs(skb)) >= txq->tx_ring_size) {
+		netdev_dbg(dev, "not enough descriptors for TSO!\n");
+		return -EBUSY;
+	}
+
+	/* Initialize the TSO handler, and prepare the first payload */
+	tso_start(skb, &tso);
+
+	total_len = skb->len - hdr_len;
+	while (total_len > 0) {
+		char *hdr;
+
+		data_left = min_t(int, skb_shinfo(skb)->gso_size, total_len);
+		total_len -= data_left;
+		desc_count++;
+
+		/* prepare packet headers: MAC + IP + TCP */
+		hdr = txq->tso_hdrs + txq->tx_curr_desc * TSO_HEADER_SIZE;
+		tso_build_hdr(skb, hdr, &tso, data_left, total_len == 0);
+		txq_put_hdr_tso(skb, txq, data_left);
+
+		while (data_left > 0) {
+			int size;
+			desc_count++;
+
+			size = min_t(int, tso.size, data_left);
+			ret = txq_put_data_tso(dev, txq, skb, tso.data, size,
+					       size == data_left,
+					       total_len == 0);
+			if (ret)
+				goto err_release;
+			data_left -= size;
+			tso_build_data(skb, &tso, size);
+		}
+	}
+
+	__skb_queue_tail(&txq->tx_skb, skb);
+	skb_tx_timestamp(skb);
+
+	/* clear TX_END status */
+	mp->work_tx_end &= ~(1 << txq->index);
+
+	/* ensure all descriptors are written before poking hardware */
+	wmb();
+	txq_enable(txq);
+	txq->tx_desc_count += desc_count;
+	return 0;
+err_release:
+	/* TODO: Release all used data descriptors; header descriptors must not
+	 * be DMA-unmapped.
+	 */
+	return ret;
+}
+
 static void txq_submit_frag_skb(struct tx_queue *txq, struct sk_buff *skb)
 {
 	struct mv643xx_eth_private *mp = txq_to_mp(txq);
@@ -821,7 +958,7 @@ static int txq_submit_skb(struct tx_queue *txq, struct sk_buff *skb)
 static netdev_tx_t mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
-	int length, queue;
+	int length, queue, ret;
 	struct tx_queue *txq;
 	struct netdev_queue *nq;
 
@@ -845,7 +982,11 @@ static netdev_tx_t mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	length = skb->len;
 
-	if (!txq_submit_skb(txq, skb)) {
+	if (skb_is_gso(skb))
+		ret = txq_submit_tso(txq, skb, dev);
+	else
+		ret = txq_submit_skb(txq, skb);
+	if (!ret) {
 		int entries_left;
 
 		txq->tx_bytes += length;
@@ -854,6 +995,8 @@ static netdev_tx_t mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 		entries_left = txq->tx_ring_size - txq->tx_desc_count;
 		if (entries_left < MAX_SKB_FRAGS + 1)
 			netif_tx_stop_queue(nq);
+	} else if (ret == -EBUSY) {
+		return NETDEV_TX_BUSY;
 	}
 
 	return NETDEV_TX_OK;
@@ -1885,6 +2028,15 @@ static int txq_init(struct mv643xx_eth_private *mp, int index)
 					nexti * sizeof(struct tx_desc);
 	}
 
+	/* Allocate DMA buffers for TSO MAC/IP/TCP headers */
+	txq->tso_hdrs = dma_alloc_coherent(mp->dev->dev.parent,
+					   txq->tx_ring_size * TSO_HEADER_SIZE,
+					   &txq->tso_hdrs_dma, GFP_KERNEL);
+	if (txq->tso_hdrs == NULL) {
+		dma_free_coherent(mp->dev->dev.parent, txq->tx_desc_area_size,
+				  txq->tx_desc_area, txq->tx_desc_dma);
+		return -ENOMEM;
+	}
 	skb_queue_head_init(&txq->tx_skb);
 
 	return 0;
@@ -1905,6 +2057,10 @@ static void txq_deinit(struct tx_queue *txq)
 	else
 		dma_free_coherent(mp->dev->dev.parent, txq->tx_desc_area_size,
 				  txq->tx_desc_area, txq->tx_desc_dma);
+	if (txq->tso_hdrs)
+		dma_free_coherent(mp->dev->dev.parent,
+				  txq->tx_ring_size * TSO_HEADER_SIZE,
+				  txq->tso_hdrs, txq->tso_hdrs_dma);
 }
 
 
@@ -2935,7 +3091,7 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	dev->watchdog_timeo = 2 * HZ;
 	dev->base_addr = 0;
 
-	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM;
+	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
 	dev->vlan_features = dev->features;
 
 	dev->features |= NETIF_F_RXCSUM;
-- 
1.9.1

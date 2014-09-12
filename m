From: <Frank.Li@freescale.com>
Subject: [Patch v4 net-next 09/12] net: fec: change FEC alignment according to
 i.mx6 sx requirement
Date: Sat, 13 Sep 2014 05:00:54 +0800
Message-ID: <1410555657-10744-10-git-send-email-Frank.Li@freescale.com>
References: <1410555657-10744-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, Frank Li <Frank.Li@freescale.com>,
 Fugang Duan <B38611@freescale.com>, linux@arm.linux.org.uk,
 shawn.guo@linaro.org, linux-arm-kernel@lists.infradead.org
To: <b38611@freescale.com>, <davem@davemloft.net>, <netdev@vger.kernel.org>,
 <lznuaa@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1410555657-10744-1-git-send-email-Frank.Li@freescale.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Fugang Duan <B38611@freescale.com>

i.MX6 SX change FEC alignment requirement.
i.MX6 SX change internal bus from AHB to AXI.
It require RX buffer must be 64 bytes alignment.
And remove TX buffer alignment requirement.

Signed-off-by: Fugang Duan <B38611@freescale.com>
Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/fec.h      |  3 +++
 drivers/net/ethernet/freescale/fec_main.c | 35 +++++++++++++++++++++----------
 2 files changed, 27 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 5ec3828..b7c7722 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -443,6 +443,9 @@ struct fec_enet_private {
 	int hwts_tx_en;
 	struct delayed_work time_keep;
 	struct regulator *reg_phy;
+
+	unsigned int tx_align;
+	unsigned int rx_align;
 };
 
 void fec_ptp_init(struct platform_device *pdev);
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 0cc7313..9840a10 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -64,12 +64,6 @@
 
 static void set_multicast_list(struct net_device *ndev);
 
-#if defined(CONFIG_ARM)
-#define FEC_ALIGNMENT	0xf
-#else
-#define FEC_ALIGNMENT	0x3
-#endif
-
 #define DRIVER_NAME	"fec"
 
 #define FEC_ENET_GET_QUQUE(_x) ((_x == 0) ? 1 : ((_x == 1) ? 2 : 0))
@@ -434,7 +428,7 @@ fec_enet_txq_submit_frag_skb(struct fec_enet_priv_tx_q *txq,
 		bufaddr = page_address(this_frag->page.p) + this_frag->page_offset;
 
 		index = fec_enet_get_bd_index(txq->tx_bd_base, bdp, fep);
-		if (((unsigned long) bufaddr) & FEC_ALIGNMENT ||
+		if (((unsigned long) bufaddr) & fep->tx_align ||
 			id_entry->driver_data & FEC_QUIRK_SWAP_FRAME) {
 			memcpy(txq->tx_bounce[index], bufaddr, frag_len);
 			bufaddr = txq->tx_bounce[index];
@@ -514,7 +508,7 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 
 	queue = skb_get_queue_mapping(skb);
 	index = fec_enet_get_bd_index(txq->tx_bd_base, bdp, fep);
-	if (((unsigned long) bufaddr) & FEC_ALIGNMENT ||
+	if (((unsigned long) bufaddr) & fep->tx_align ||
 		id_entry->driver_data & FEC_QUIRK_SWAP_FRAME) {
 		memcpy(txq->tx_bounce[index], skb->data, buflen);
 		bufaddr = txq->tx_bounce[index];
@@ -607,7 +601,7 @@ fec_enet_txq_put_data_tso(struct fec_enet_priv_tx_q *txq, struct sk_buff *skb,
 
 	status |= (BD_ENET_TX_TC | BD_ENET_TX_READY);
 
-	if (((unsigned long) data) & FEC_ALIGNMENT ||
+	if (((unsigned long) data) & fep->tx_align ||
 		id_entry->driver_data & FEC_QUIRK_SWAP_FRAME) {
 		memcpy(txq->tx_bounce[index], data, size);
 		data = txq->tx_bounce[index];
@@ -669,7 +663,7 @@ fec_enet_txq_put_hdr_tso(struct fec_enet_priv_tx_q *txq,
 
 	bufaddr = txq->tso_hdrs + index * TSO_HEADER_SIZE;
 	dmabuf = txq->tso_hdrs_dma + index * TSO_HEADER_SIZE;
-	if (((unsigned long) bufaddr) & FEC_ALIGNMENT ||
+	if (((unsigned long)bufaddr) & fep->tx_align ||
 		id_entry->driver_data & FEC_QUIRK_SWAP_FRAME) {
 		memcpy(txq->tx_bounce[index], skb->data, hdr_len);
 		bufaddr = txq->tx_bounce[index];
@@ -2399,6 +2393,7 @@ fec_enet_alloc_rxq_buffers(struct net_device *ndev, unsigned int queue)
 	struct sk_buff *skb;
 	struct bufdesc	*bdp;
 	struct fec_enet_priv_rx_q *rxq;
+	unsigned int off;
 
 	rxq = fep->rx_queue[queue];
 	bdp = rxq->rx_bd_base;
@@ -2409,8 +2404,13 @@ fec_enet_alloc_rxq_buffers(struct net_device *ndev, unsigned int queue)
 		if (!skb)
 			goto err_alloc;
 
+		off = ((unsigned long)skb->data) & fep->rx_align;
+		if (off)
+			skb_reserve(skb, fep->rx_align + 1 - off);
+
 		addr = dma_map_single(&fep->pdev->dev, skb->data,
-				FEC_ENET_RX_FRSIZE, DMA_FROM_DEVICE);
+				FEC_ENET_RX_FRSIZE - fep->rx_align, DMA_FROM_DEVICE);
+
 		if (dma_mapping_error(&fep->pdev->dev, addr)) {
 			dev_kfree_skb(skb);
 			if (net_ratelimit())
@@ -2743,6 +2743,14 @@ static int fec_enet_init(struct net_device *ndev)
 	int bd_size;
 	unsigned int i;
 
+#if defined(CONFIG_ARM)
+	fep->rx_align = 0xf;
+	fep->tx_align = 0xf;
+#else
+	fep->rx_align = 0x3;
+	fep->tx_align = 0x3;
+#endif
+
 	fec_enet_alloc_queue(ndev);
 
 	if (fep->bufdesc_ex)
@@ -2819,6 +2827,11 @@ static int fec_enet_init(struct net_device *ndev)
 		fep->csum_flags |= FLAG_RX_CSUM_ENABLED;
 	}
 
+	if (id_entry->driver_data & FEC_QUIRK_HAS_AVB) {
+		fep->tx_align = 0;
+		fep->rx_align = 0x3f;
+	}
+
 	ndev->hw_features = ndev->features;
 
 	fec_restart(ndev);
-- 
1.9.1

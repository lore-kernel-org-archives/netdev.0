From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 1/8] qlcnic: additional driver statistics
Date: Thu, 22 Apr 2010 05:51:35 -0700
Message-ID: <1271940702-17064-2-git-send-email-amit.salecha@qlogic.com>
References: <1271940702-17064-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:62532 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754533Ab0DVMvo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 08:51:44 -0400
In-Reply-To: <1271940702-17064-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added additional driver statistics to track errors in rcv/tx path.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h         |    4 ++++
 drivers/net/qlcnic/qlcnic_ethtool.c |    8 ++++++++
 drivers/net/qlcnic/qlcnic_init.c    |    7 ++++++-
 drivers/net/qlcnic/qlcnic_main.c    |    4 +++-
 4 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 28c148c..6c1da71 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -428,6 +428,10 @@ struct qlcnic_adapter_stats {
 	u64  xmit_on;
 	u64  xmit_off;
 	u64  skb_alloc_failure;
+	u64  null_skb;
+	u64  null_rxbuf;
+	u64  rx_dma_map_error;
+	u64  tx_dma_map_error;
 };
 
 /*
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 08d6f10..6cdc5eb 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -69,6 +69,14 @@ static const struct qlcnic_stats qlcnic_gstrings_stats[] = {
 		QLC_SIZEOF(stats.xmit_off), QLC_OFF(stats.xmit_off)},
 	{"skb_alloc_failure", QLC_SIZEOF(stats.skb_alloc_failure),
 		QLC_OFF(stats.skb_alloc_failure)},
+	{"null skb",
+		QLC_SIZEOF(stats.null_skb), QLC_OFF(stats.null_skb)},
+	{"null rxbuf",
+		QLC_SIZEOF(stats.null_rxbuf), QLC_OFF(stats.null_rxbuf)},
+	{"rx dma map error", QLC_SIZEOF(stats.rx_dma_map_error),
+					 QLC_OFF(stats.rx_dma_map_error)},
+	{"tx dma map error", QLC_SIZEOF(stats.tx_dma_map_error),
+					 QLC_OFF(stats.tx_dma_map_error)},
 
 };
 
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 01ce74e..9ef9f58 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -1287,6 +1287,7 @@ qlcnic_alloc_rx_skb(struct qlcnic_adapter *adapter,
 			rds_ring->dma_size, PCI_DMA_FROMDEVICE);
 
 	if (pci_dma_mapping_error(pdev, dma)) {
+		adapter->stats.rx_dma_map_error++;
 		dev_kfree_skb_any(skb);
 		buffer->skb = NULL;
 		return -ENOMEM;
@@ -1311,8 +1312,10 @@ static struct sk_buff *qlcnic_process_rxbuf(struct qlcnic_adapter *adapter,
 			PCI_DMA_FROMDEVICE);
 
 	skb = buffer->skb;
-	if (!skb)
+	if (!skb) {
+		adapter->stats.null_skb++;
 		goto no_skb;
+	}
 
 	if (likely(adapter->rx_csum && cksum == STATUS_CKSUM_OK)) {
 		adapter->stats.csummed++;
@@ -1502,6 +1505,8 @@ qlcnic_process_rcv_ring(struct qlcnic_host_sds_ring *sds_ring, int max)
 
 		if (rxbuf)
 			list_add_tail(&rxbuf->list, &sds_ring->free_list[ring]);
+		else
+			adapter->stats.null_rxbuf++;
 
 skip:
 		for (; desc_cnt > 0; desc_cnt--) {
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index e4fd5dc..5845dc0 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1589,8 +1589,10 @@ qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	pdev = adapter->pdev;
 
-	if (qlcnic_map_tx_skb(pdev, skb, pbuf))
+	if (qlcnic_map_tx_skb(pdev, skb, pbuf)) {
+		adapter->stats.tx_dma_map_error++;
 		goto drop_packet;
+	}
 
 	pbuf->skb = skb;
 	pbuf->frag_count = frag_count;
-- 
1.6.0.2


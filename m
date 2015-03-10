From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next] net: bcmgenet: collect Rx discarded packet count
Date: Tue, 10 Mar 2015 12:18:00 -0700 (PDT)
Message-ID: <20150310191800.C5812220365@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f201.google.com ([209.85.216.201]:33517 "EHLO
	mail-qc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330AbbCJTXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 15:23:32 -0400
Received: by qcvx3 with SMTP id x3so643390qcv.0
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 12:23:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bits 31:16 of RDMA_PROD_INDEX contain Rx discarded packet count, which
are the Rx packets that had to be dropped by MAC hardware since there
was no room on the Rx queue. Add code to collect this information into
the netdev stats.

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 275be56..7aa1834 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1384,9 +1384,19 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
 	int len, err;
 	unsigned int rxpktprocessed = 0, rxpkttoprocess;
 	unsigned int p_index;
+	unsigned int discards;
 	unsigned int chksum_ok = 0;
 
 	p_index = bcmgenet_rdma_ring_readl(priv, index, RDMA_PROD_INDEX);
+
+	discards = (p_index >> DMA_P_INDEX_DISCARD_CNT_SHIFT) &
+		   DMA_P_INDEX_DISCARD_CNT_MASK;
+	if (discards > 0) {
+		bcmgenet_rdma_ring_writel(priv, index, 0, RDMA_PROD_INDEX);
+		dev->stats.rx_missed_errors += discards;
+		dev->stats.rx_errors += discards;
+	}
+
 	p_index &= DMA_P_INDEX_MASK;
 
 	if (likely(p_index >= ring->c_index))
-- 
2.2.0.rc0.207.ga3a616c

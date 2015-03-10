From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next v2] net: bcmgenet: collect Rx discarded packet count
Date: Tue, 10 Mar 2015 15:55:00 -0700 (PDT)
Message-ID: <20150310225500.8FA34220365@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f74.google.com ([209.85.220.74]:33414 "EHLO
	mail-pa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbbCJWzC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 18:55:02 -0400
Received: by pablj1 with SMTP id lj1so1601030pab.0
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 15:55:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bits 31:16 of RDMA_PROD_INDEX contain Rx discarded packet count, which
are the Rx packets that had to be dropped by MAC hardware since there
was no room on the Rx queue. Add code to collect this information into
the netdev stats.

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 18 ++++++++++++++++++
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  1 +
 2 files changed, 19 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 275be56..d3be1aeb 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1384,9 +1384,27 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
 	int len, err;
 	unsigned int rxpktprocessed = 0, rxpkttoprocess;
 	unsigned int p_index;
+	unsigned int discards;
 	unsigned int chksum_ok = 0;
 
 	p_index = bcmgenet_rdma_ring_readl(priv, index, RDMA_PROD_INDEX);
+
+	discards = (p_index >> DMA_P_INDEX_DISCARD_CNT_SHIFT) &
+		   DMA_P_INDEX_DISCARD_CNT_MASK;
+	if (discards > ring->old_discards) {
+		discards = discards - ring->old_discards;
+		dev->stats.rx_missed_errors += discards;
+		dev->stats.rx_errors += discards;
+		ring->old_discards += discards;
+
+		/* Clear HW register when we reach 75% of maximum 0xFFFF */
+		if (ring->old_discards >= 0xC000) {
+			ring->old_discards = 0;
+			bcmgenet_rdma_ring_writel(priv, index, 0,
+						  RDMA_PROD_INDEX);
+		}
+	}
+
 	p_index &= DMA_P_INDEX_MASK;
 
 	if (likely(p_index >= ring->c_index))
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 17443db..2a81138 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -548,6 +548,7 @@ struct bcmgenet_rx_ring {
 	unsigned int	read_ptr;	/* Rx ring read pointer */
 	unsigned int	cb_ptr;		/* Rx ring initial CB ptr */
 	unsigned int	end_ptr;	/* Rx ring end CB ptr */
+	unsigned int	old_discards;
 };
 
 /* device context */
-- 
2.2.0.rc0.207.ga3a616c

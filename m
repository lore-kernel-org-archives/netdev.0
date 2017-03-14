From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH net-next 07/12] net: bcmgenet: clear status to reduce spurious interrupts
Date: Mon, 13 Mar 2017 17:41:37 -0700
Message-ID: <20170314004142.4746-8-opendmb@gmail.com>
References: <20170314004142.4746-1-opendmb@gmail.com>
Cc: robh+dt@kernel.org, mark.rutland@arm.com, davem@davemloft.net,
        rafal@milecki.pl, xow@google.com, joel@jms.id.au,
        jon.mason@broadcom.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        pgynther@google.com, jaedon.shin@gmail.com,
        Doug Berger <opendmb@gmail.com>
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170314004142.4746-1-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since the DMA interrupt status is latched and the DMA servicing can be
polled, it is a good idea to clear the latched status of a DMA interrupt
before performing the service that would be invoked by the interrupt.

This prevents old status from causing spurious interrupts when the
interrupt is unmasked at a later time.

Signed-off-by: Doug Berger <opendmb@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 661ca1b39c89..1f94ba1773dd 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1174,6 +1174,14 @@ static unsigned int __bcmgenet_tx_reclaim(struct net_device *dev,
 	unsigned int txbds_ready;
 	unsigned int txbds_processed = 0;
 
+	/* Clear status before servicing to reduce spurious interrupts */
+	if (ring->index == DESC_INDEX)
+		bcmgenet_intrl2_0_writel(priv, UMAC_IRQ_TXDMA_DONE,
+					 INTRL2_CPU_CLEAR);
+	else
+		bcmgenet_intrl2_1_writel(priv, (1 << ring->index),
+					 INTRL2_CPU_CLEAR);
+
 	/* Compute how many buffers are transmitted since last xmit call */
 	c_index = bcmgenet_tdma_ring_readl(priv, ring->index, TDMA_CONS_INDEX)
 		& DMA_C_INDEX_MASK;
@@ -1584,10 +1592,21 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_rx_ring *ring,
 	unsigned long dma_flag;
 	int len;
 	unsigned int rxpktprocessed = 0, rxpkttoprocess;
-	unsigned int p_index;
+	unsigned int p_index, mask;
 	unsigned int discards;
 	unsigned int chksum_ok = 0;
 
+	/* Clear status before servicing to reduce spurious interrupts */
+	if (ring->index == DESC_INDEX) {
+		bcmgenet_intrl2_0_writel(priv, UMAC_IRQ_RXDMA_DONE,
+					 INTRL2_CPU_CLEAR);
+	} else {
+		mask = 1 << (UMAC_IRQ1_RX_INTR_SHIFT + ring->index);
+		bcmgenet_intrl2_1_writel(priv,
+					 mask,
+					 INTRL2_CPU_CLEAR);
+	}
+
 	p_index = bcmgenet_rdma_ring_readl(priv, ring->index, RDMA_PROD_INDEX);
 
 	discards = (p_index >> DMA_P_INDEX_DISCARD_CNT_SHIFT) &
-- 
2.11.1

From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 6/6] net: mvpp2: simplify the Tx desc set DMA logic
Date: Mon, 30 Oct 2017 11:23:33 +0100
Message-ID: <20171030102333.30781-7-antoine.tenart@free-electrons.com>
References: <20171030102333.30781-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171030102333.30781-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Two functions were always used to set the DMA addresses in Tx
descriptors, because this address is split into a base+offset in the
descriptors. A mask was used to come up with the base and offset
addresses and two functions were called, mvpp2_txdesc_dma_addr_set() and
mvpp2_txdesc_offset_set().

This patch moves the base+offset calculation logic to
mvpp2_txdesc_dma_addr_set(), and removes mvpp2_txdesc_offset_set() to
simplify things.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 39 ++++++++++++------------------------
 1 file changed, 13 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 4b8c727ffea9..dbeeda88b9b5 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -1290,13 +1290,20 @@ static void mvpp2_txdesc_dma_addr_set(struct mvpp2_port *port,
 				      struct mvpp2_tx_desc *tx_desc,
 				      dma_addr_t dma_addr)
 {
+	dma_addr_t addr, offset;
+
+	addr = dma_addr & ~MVPP2_TX_DESC_ALIGN;
+	offset = dma_addr & MVPP2_TX_DESC_ALIGN;
+
 	if (port->priv->hw_version == MVPP21) {
-		tx_desc->pp21.buf_dma_addr = dma_addr;
+		tx_desc->pp21.buf_dma_addr = addr;
+		tx_desc->pp21.packet_offset = offset;
 	} else {
-		u64 val = (u64)dma_addr;
+		u64 val = (u64)addr;
 
 		tx_desc->pp22.buf_dma_addr_ptp &= ~GENMASK_ULL(40, 0);
 		tx_desc->pp22.buf_dma_addr_ptp |= val;
+		tx_desc->pp22.packet_offset = offset;
 	}
 }
 
@@ -1339,16 +1346,6 @@ static void mvpp2_txdesc_cmd_set(struct mvpp2_port *port,
 		tx_desc->pp22.command = command;
 }
 
-static void mvpp2_txdesc_offset_set(struct mvpp2_port *port,
-				    struct mvpp2_tx_desc *tx_desc,
-				    unsigned int offset)
-{
-	if (port->priv->hw_version == MVPP21)
-		tx_desc->pp21.packet_offset = offset;
-	else
-		tx_desc->pp22.packet_offset = offset;
-}
-
 static unsigned int mvpp2_txdesc_offset_get(struct mvpp2_port *port,
 					    struct mvpp2_tx_desc *tx_desc)
 {
@@ -6292,10 +6289,7 @@ static int mvpp2_tx_frag_process(struct mvpp2_port *port, struct sk_buff *skb,
 			goto cleanup;
 		}
 
-		mvpp2_txdesc_offset_set(port, tx_desc,
-					buf_dma_addr & MVPP2_TX_DESC_ALIGN);
-		mvpp2_txdesc_dma_addr_set(port, tx_desc,
-					  buf_dma_addr & ~MVPP2_TX_DESC_ALIGN);
+		mvpp2_txdesc_dma_addr_set(port, tx_desc, buf_dma_addr);
 
 		if (i == (skb_shinfo(skb)->nr_frags - 1)) {
 			/* Last descriptor */
@@ -6338,8 +6332,7 @@ static inline void mvpp2_tso_put_hdr(struct sk_buff *skb,
 
 	addr = txq_pcpu->tso_headers_dma +
 	       txq_pcpu->txq_put_index * TSO_HEADER_SIZE;
-	mvpp2_txdesc_offset_set(port, tx_desc, addr & MVPP2_TX_DESC_ALIGN);
-	mvpp2_txdesc_dma_addr_set(port, tx_desc, addr & ~MVPP2_TX_DESC_ALIGN);
+	mvpp2_txdesc_dma_addr_set(port, tx_desc, addr);
 
 	mvpp2_txdesc_cmd_set(port, tx_desc, mvpp2_skb_tx_csum(port, skb) |
 					    MVPP2_TXD_F_DESC |
@@ -6368,10 +6361,7 @@ static inline int mvpp2_tso_put_data(struct sk_buff *skb,
 		return -ENOMEM;
 	}
 
-	mvpp2_txdesc_offset_set(port, tx_desc,
-				buf_dma_addr & MVPP2_TX_DESC_ALIGN);
-	mvpp2_txdesc_dma_addr_set(port, tx_desc,
-				  buf_dma_addr & ~MVPP2_TX_DESC_ALIGN);
+	mvpp2_txdesc_dma_addr_set(port, tx_desc, buf_dma_addr);
 
 	if (!left) {
 		mvpp2_txdesc_cmd_set(port, tx_desc, MVPP2_TXD_L_DESC);
@@ -6483,10 +6473,7 @@ static int mvpp2_tx(struct sk_buff *skb, struct net_device *dev)
 		goto out;
 	}
 
-	mvpp2_txdesc_offset_set(port, tx_desc,
-				buf_dma_addr & MVPP2_TX_DESC_ALIGN);
-	mvpp2_txdesc_dma_addr_set(port, tx_desc,
-				  buf_dma_addr & ~MVPP2_TX_DESC_ALIGN);
+	mvpp2_txdesc_dma_addr_set(port, tx_desc, buf_dma_addr);
 
 	tx_cmd = mvpp2_skb_tx_csum(port, skb);
 
-- 
2.14.3

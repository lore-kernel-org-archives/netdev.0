From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv2 net-next 09/16] net: mvpp2: adjust mvpp2_{rxq,txq}_init for PPv2.2
Date: Wed, 28 Dec 2016 17:46:25 +0100
Message-ID: <1482943592-12556-10-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1482943592-12556-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        linux-arm-kernel@lists.infradead.org,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        devicetree@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
        Ian Campbell <ijc+devicetree@hellion.org.uk>,
        Pawel Moll <pawel.moll@arm.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Kumar Gala <galak@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:47964 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751935AbcL1QsD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 11:48:03 -0500
In-Reply-To: <1482943592-12556-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In PPv2.2, the MVPP2_RXQ_DESC_ADDR_REG and MVPP2_TXQ_DESC_ADDR_REG
registers have a slightly different layout, because they need to contain
a 64-bit address for the RX and TX descriptor arrays. This commit
adjusts those functions accordingly.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 26 +++++++++++++++++++++-----
 1 file changed, 21 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 23f2368..22f7970 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -102,6 +102,7 @@
 /* Descriptor Manager Top Registers */
 #define MVPP2_RXQ_NUM_REG			0x2040
 #define MVPP2_RXQ_DESC_ADDR_REG			0x2044
+#define     MVPP22_DESC_ADDR_OFFS		8
 #define MVPP2_RXQ_DESC_SIZE_REG			0x2048
 #define     MVPP2_RXQ_DESC_SIZE_MASK		0x3ff0
 #define MVPP2_RXQ_STATUS_UPDATE_REG(rxq)	(0x3000 + 4 * (rxq))
@@ -143,6 +144,7 @@
 #define MVPP2_TXQ_RSVD_CLR_REG			0x20b8
 #define     MVPP2_TXQ_RSVD_CLR_OFFSET		16
 #define MVPP2_AGGR_TXQ_DESC_ADDR_REG(cpu)	(0x2100 + 4 * (cpu))
+#define     MVPP22_AGGR_TXQ_DESC_ADDR_OFFS	8
 #define MVPP2_AGGR_TXQ_DESC_SIZE_REG(cpu)	(0x2140 + 4 * (cpu))
 #define     MVPP2_AGGR_TXQ_DESC_SIZE_MASK	0x3ff0
 #define MVPP2_AGGR_TXQ_STATUS_REG(cpu)		(0x2180 + 4 * (cpu))
@@ -4769,6 +4771,8 @@ static int mvpp2_aggr_txq_init(struct platform_device *pdev,
 			       int desc_num, int cpu,
 			       struct mvpp2 *priv)
 {
+	u32 txq_phys;
+
 	/* Allocate memory for TX descriptors */
 	aggr_txq->descs = dma_alloc_coherent(&pdev->dev,
 				desc_num * MVPP2_DESC_ALIGNED_SIZE,
@@ -4782,10 +4786,16 @@ static int mvpp2_aggr_txq_init(struct platform_device *pdev,
 	aggr_txq->next_desc_to_proc = mvpp2_read(priv,
 						 MVPP2_AGGR_TXQ_INDEX_REG(cpu));
 
-	/* Set Tx descriptors queue starting address */
-	/* indirect access */
-	mvpp2_write(priv, MVPP2_AGGR_TXQ_DESC_ADDR_REG(cpu),
-		    aggr_txq->descs_phys);
+	/* Set Tx descriptors queue starting address indirect
+	 * access
+	 */
+	if (priv->hw_version == MVPP21)
+		txq_phys = aggr_txq->descs_phys;
+	else
+		txq_phys = aggr_txq->descs_phys >>
+			MVPP22_AGGR_TXQ_DESC_ADDR_OFFS;
+
+	mvpp2_write(priv, MVPP2_AGGR_TXQ_DESC_ADDR_REG(cpu), txq_phys);
 	mvpp2_write(priv, MVPP2_AGGR_TXQ_DESC_SIZE_REG(cpu), desc_num);
 
 	return 0;
@@ -4796,6 +4806,8 @@ static int mvpp2_rxq_init(struct mvpp2_port *port,
 			  struct mvpp2_rx_queue *rxq)
 
 {
+	u32 rxq_phys;
+
 	rxq->size = port->rx_ring_size;
 
 	/* Allocate memory for RX descriptors */
@@ -4812,7 +4824,11 @@ static int mvpp2_rxq_init(struct mvpp2_port *port,
 
 	/* Set Rx descriptors queue starting address - indirect access */
 	mvpp2_write(port->priv, MVPP2_RXQ_NUM_REG, rxq->id);
-	mvpp2_write(port->priv, MVPP2_RXQ_DESC_ADDR_REG, rxq->descs_phys);
+	if (port->priv->hw_version == MVPP21)
+		rxq_phys = rxq->descs_phys;
+	else
+		rxq_phys = rxq->descs_phys >> MVPP22_DESC_ADDR_OFFS;
+	mvpp2_write(port->priv, MVPP2_RXQ_DESC_ADDR_REG, rxq_phys);
 	mvpp2_write(port->priv, MVPP2_RXQ_DESC_SIZE_REG, rxq->size);
 	mvpp2_write(port->priv, MVPP2_RXQ_INDEX_REG, 0);
 
-- 
2.7.4

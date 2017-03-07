From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv3 net-next 10/22] net: mvpp2: introduce PPv2.2 HW descriptors and adapt accessors
Date: Tue,  7 Mar 2017 16:53:08 +0100
Message-ID: <1488902000-2658-11-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1488902000-2658-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Nadav Haklai <nadavh@marvell.com>, Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        linux-arm-kernel@lists.infradead.org,
        Russell King <linux@arm.linux.org.uk>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
        Ian Campbell <ijc+devicetree@hellion.org.uk>,
        Pawel Moll <pawel.moll@arm.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Kumar Gala <galak@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:32852 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755444AbdCGP4k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 10:56:40 -0500
In-Reply-To: <1488902000-2658-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit adds the definition of the PPv2.2 HW descriptors, adjusts
the mvpp2_tx_desc and mvpp2_rx_desc structures accordingly, and adapts
the accessors to work on both PPv2.1 and PPv2.2.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 88 +++++++++++++++++++++++++++++++-----
 1 file changed, 76 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index e9710e8..746b5be 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -767,18 +767,42 @@ struct mvpp21_rx_desc {
 	u32 reserved8;
 };
 
+/* HW TX descriptor for PPv2.2 */
+struct mvpp22_tx_desc {
+	u32 command;
+	u8  packet_offset;
+	u8  phys_txq;
+	u16 data_size;
+	u64 reserved1;
+	u64 buf_dma_addr_ptp;
+	u64 buf_cookie_misc;
+};
+
+/* HW RX descriptor for PPv2.2 */
+struct mvpp22_rx_desc {
+	u32 status;
+	u16 reserved1;
+	u16 data_size;
+	u32 reserved2;
+	u32 reserved3;
+	u64 buf_dma_addr_key_hash;
+	u64 buf_cookie_misc;
+};
+
 /* Opaque type used by the driver to manipulate the HW TX and RX
  * descriptors
  */
 struct mvpp2_tx_desc {
 	union {
 		struct mvpp21_tx_desc pp21;
+		struct mvpp22_tx_desc pp22;
 	};
 };
 
 struct mvpp2_rx_desc {
 	union {
 		struct mvpp21_rx_desc pp21;
+		struct mvpp22_rx_desc pp22;
 	};
 };
 
@@ -969,78 +993,118 @@ static u32 mvpp2_read(struct mvpp2 *priv, u32 offset)
 static dma_addr_t mvpp2_txdesc_dma_addr_get(struct mvpp2_port *port,
 					    struct mvpp2_tx_desc *tx_desc)
 {
-	return tx_desc->pp21.buf_dma_addr;
+	if (port->priv->hw_version == MVPP21)
+		return tx_desc->pp21.buf_dma_addr;
+	else
+		return tx_desc->pp22.buf_dma_addr_ptp & GENMASK_ULL(40, 0);
 }
 
 static void mvpp2_txdesc_dma_addr_set(struct mvpp2_port *port,
 				      struct mvpp2_tx_desc *tx_desc,
 				      dma_addr_t dma_addr)
 {
-	tx_desc->pp21.buf_dma_addr = dma_addr;
+	if (port->priv->hw_version == MVPP21) {
+		tx_desc->pp21.buf_dma_addr = dma_addr;
+	} else {
+		u64 val = (u64)dma_addr;
+
+		tx_desc->pp22.buf_dma_addr_ptp &= ~GENMASK_ULL(40, 0);
+		tx_desc->pp22.buf_dma_addr_ptp |= val;
+	}
 }
 
 static size_t mvpp2_txdesc_size_get(struct mvpp2_port *port,
 				    struct mvpp2_tx_desc *tx_desc)
 {
-	return tx_desc->pp21.data_size;
+	if (port->priv->hw_version == MVPP21)
+		return tx_desc->pp21.data_size;
+	else
+		return tx_desc->pp22.data_size;
 }
 
 static void mvpp2_txdesc_size_set(struct mvpp2_port *port,
 				  struct mvpp2_tx_desc *tx_desc,
 				  size_t size)
 {
-	tx_desc->pp21.data_size = size;
+	if (port->priv->hw_version == MVPP21)
+		tx_desc->pp21.data_size = size;
+	else
+		tx_desc->pp22.data_size = size;
 }
 
 static void mvpp2_txdesc_txq_set(struct mvpp2_port *port,
 				 struct mvpp2_tx_desc *tx_desc,
 				 unsigned int txq)
 {
-	tx_desc->pp21.phys_txq = txq;
+	if (port->priv->hw_version == MVPP21)
+		tx_desc->pp21.phys_txq = txq;
+	else
+		tx_desc->pp22.phys_txq = txq;
 }
 
 static void mvpp2_txdesc_cmd_set(struct mvpp2_port *port,
 				 struct mvpp2_tx_desc *tx_desc,
 				 unsigned int command)
 {
-	tx_desc->pp21.command = command;
+	if (port->priv->hw_version == MVPP21)
+		tx_desc->pp21.command = command;
+	else
+		tx_desc->pp22.command = command;
 }
 
 static void mvpp2_txdesc_offset_set(struct mvpp2_port *port,
 				    struct mvpp2_tx_desc *tx_desc,
 				    unsigned int offset)
 {
-	tx_desc->pp21.packet_offset = offset;
+	if (port->priv->hw_version == MVPP21)
+		tx_desc->pp21.packet_offset = offset;
+	else
+		tx_desc->pp22.packet_offset = offset;
 }
 
 static unsigned int mvpp2_txdesc_offset_get(struct mvpp2_port *port,
 					    struct mvpp2_tx_desc *tx_desc)
 {
-	return tx_desc->pp21.packet_offset;
+	if (port->priv->hw_version == MVPP21)
+		return tx_desc->pp21.packet_offset;
+	else
+		return tx_desc->pp22.packet_offset;
 }
 
 static dma_addr_t mvpp2_rxdesc_dma_addr_get(struct mvpp2_port *port,
 					    struct mvpp2_rx_desc *rx_desc)
 {
-	return rx_desc->pp21.buf_dma_addr;
+	if (port->priv->hw_version == MVPP21)
+		return rx_desc->pp21.buf_dma_addr;
+	else
+		return rx_desc->pp22.buf_dma_addr_key_hash & GENMASK_ULL(40, 0);
 }
 
 static unsigned long mvpp2_rxdesc_cookie_get(struct mvpp2_port *port,
 					     struct mvpp2_rx_desc *rx_desc)
 {
-	return rx_desc->pp21.buf_cookie;
+	if (port->priv->hw_version == MVPP21)
+		return rx_desc->pp21.buf_cookie;
+	else
+		return rx_desc->pp22.buf_cookie_misc & GENMASK_ULL(40, 0);
 }
 
 static size_t mvpp2_rxdesc_size_get(struct mvpp2_port *port,
 				    struct mvpp2_rx_desc *rx_desc)
 {
-	return rx_desc->pp21.data_size;
+	if (port->priv->hw_version == MVPP21)
+		return rx_desc->pp21.data_size;
+	else
+		return rx_desc->pp22.data_size;
 }
 
 static u32 mvpp2_rxdesc_status_get(struct mvpp2_port *port,
 				   struct mvpp2_rx_desc *rx_desc)
 {
-	return rx_desc->pp21.status;
+	if (port->priv->hw_version == MVPP21)
+		return rx_desc->pp21.status;
+	else
+		return rx_desc->pp22.status;
 }
 
 static void mvpp2_txq_inc_get(struct mvpp2_txq_pcpu *txq_pcpu)
-- 
2.7.4

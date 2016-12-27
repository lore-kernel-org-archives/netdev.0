From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH v2 05/16] net: mvpp2: introduce PPv2.2 HW descriptors and adapt accessors
Date: Tue, 27 Dec 2016 17:54:26 +0100
Message-ID: <1482857677-16166-6-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1482857677-16166-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Nadav Haklai <nadavh@marvell.com>, Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:36724 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933166AbcL0Qyq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 11:54:46 -0500
In-Reply-To: <1482857677-16166-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit adds the definition of the PPv2.2 HW descriptors, adjusts
the mvpp2_tx_desc and mvpp2_rx_desc structures accordingly, and adapts
the accessors to work on both PPv2.1 and PPv2.2.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 109 +++++++++++++++++++++++++++++++----
 1 file changed, 98 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index a37ff50..0e00ec0 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -773,18 +773,42 @@ struct mvpp21_rx_desc {
 	u32 reserved8;
 };
 
+/* HW TX descriptor for PPv2.2 */
+struct mvpp22_tx_desc {
+	u32 command;
+	u8  packet_offset;
+	u8  phys_txq;
+	u16 data_size;
+	u64 reserved1;
+	u64 buf_phys_addr_ptp;
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
+	u64 buf_phys_addr_key_hash;
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
 
@@ -991,72 +1015,135 @@ static u32 mvpp2_read(struct mvpp2 *priv, u32 offset)
 static dma_addr_t mvpp2_txdesc_phys_addr_get(struct mvpp2_port *port,
 					     struct mvpp2_tx_desc *tx_desc)
 {
-	return tx_desc->pp21.buf_phys_addr;
+	if (port->priv->hw_version == MVPP21)
+		return tx_desc->pp21.buf_phys_addr;
+	else
+		return tx_desc->pp22.buf_phys_addr_ptp & DMA_BIT_MASK(40);
 }
 
 static void mvpp2_txdesc_phys_addr_set(struct mvpp2_port *port,
 				       struct mvpp2_tx_desc *tx_desc,
 				       dma_addr_t phys_addr)
 {
-	tx_desc->pp21.buf_phys_addr = phys_addr;
+	if (port->priv->hw_version == MVPP21) {
+		tx_desc->pp21.buf_phys_addr = phys_addr;
+	} else {
+		u64 val = (u64)phys_addr;
+
+		tx_desc->pp22.buf_phys_addr_ptp &= ~DMA_BIT_MASK(40);
+		tx_desc->pp22.buf_phys_addr_ptp |= val;
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
 
 static dma_addr_t mvpp2_rxdesc_phys_addr_get(struct mvpp2_port *port,
 					     struct mvpp2_rx_desc *rx_desc)
 {
-	return rx_desc->pp21.buf_phys_addr;
+	if (port->priv->hw_version == MVPP21)
+		return rx_desc->pp21.buf_phys_addr;
+	else
+		return rx_desc->pp22.buf_phys_addr_key_hash & DMA_BIT_MASK(40);
 }
 
 static unsigned long mvpp2_rxdesc_virt_addr_get(struct mvpp2_port *port,
 						struct mvpp2_rx_desc *rx_desc)
 {
-	return rx_desc->pp21.buf_cookie;
+	/* PPv2.1 can only be used on 32 bits architectures, and there
+	 * are 32 bits in buf_cookie which are enough to store the
+	 * full virtual address, so things are easy.
+	 */
+	if (port->priv->hw_version == MVPP21) {
+		return rx_desc->pp21.buf_cookie;
+	} else {
+		/* On PPv2.2, the situation is more complicated,
+		 * because there is only 40 bits to store the virtual
+		 * address, which is not sufficient. So on 64 bits
+		 * systems, we use phys_to_virt() to get the virtual
+		 * address from the physical address, which is fine
+		 * because the kernel linear mapping includes the
+		 * entire 40 bits physical address space. On 32 bits
+		 * systems however, we can't use phys_to_virt(), but
+		 * since virtual addresses are 32 bits only, there is
+		 * enough space in the RX descriptor for the full
+		 * virtual address.
+		 */
+#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
+		dma_addr_t dma_addr =
+			rx_desc->pp22.buf_phys_addr_key_hash & DMA_BIT_MASK(40);
+		phys_addr_t phys_addr =
+			dma_to_phys(port->dev->dev.parent, dma_addr);
+
+		return (unsigned long)phys_to_virt(phys_addr);
+#else
+		return rx_desc->pp22.buf_cookie_misc & DMA_BIT_MASK(40);
+#endif
+	}
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

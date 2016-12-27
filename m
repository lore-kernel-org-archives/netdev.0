From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH v2 04/16] net: mvpp2: introduce an intermediate union for the TX/RX descriptors
Date: Tue, 27 Dec 2016 17:54:25 +0100
Message-ID: <1482857677-16166-5-git-send-email-thomas.petazzoni@free-electrons.com>
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
Received: from mail.free-electrons.com ([62.4.15.54]:36717 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933157AbcL0Qyq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 11:54:46 -0500
In-Reply-To: <1482857677-16166-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the format of the HW descriptors is different between PPv2.1 and
PPv2.2, this commit introduces an intermediate union, with for now
only the PPv2.1 descriptors. The bulk of the driver code only
manipulates opaque mvpp2_tx_desc and mvpp2_rx_desc pointers, and the
descriptors can only be accessed and modified through the accessor
functions. A follow-up commit will add the descriptor definitions for
PPv2.2.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 43 +++++++++++++++++++++++++-----------
 1 file changed, 30 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index bc359a9..a37ff50 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -745,7 +745,8 @@ struct mvpp2_port {
 #define MVPP2_RXD_L3_IP6		BIT(30)
 #define MVPP2_RXD_BUF_HDR		BIT(31)
 
-struct mvpp2_tx_desc {
+/* HW TX descriptor for PPv2.1 */
+struct mvpp21_tx_desc {
 	u32 command;		/* Options used by HW for packet transmitting.*/
 	u8  packet_offset;	/* the offset from the buffer beginning	*/
 	u8  phys_txq;		/* destination queue ID			*/
@@ -756,7 +757,8 @@ struct mvpp2_tx_desc {
 	u32 reserved2;		/* reserved (for future use)		*/
 };
 
-struct mvpp2_rx_desc {
+/* HW RX descriptor for PPv2.1 */
+struct mvpp21_rx_desc {
 	u32 status;		/* info about received packet		*/
 	u16 reserved1;		/* parser_info (for future use, PnC)	*/
 	u16 data_size;		/* size of received packet in bytes	*/
@@ -771,6 +773,21 @@ struct mvpp2_rx_desc {
 	u32 reserved8;
 };
 
+/* Opaque type used by the driver to manipulate the HW TX and RX
+ * descriptors
+ */
+struct mvpp2_tx_desc {
+	union {
+		struct mvpp21_tx_desc pp21;
+	};
+};
+
+struct mvpp2_rx_desc {
+	union {
+		struct mvpp21_rx_desc pp21;
+	};
+};
+
 struct mvpp2_txq_pcpu_buf {
 	/* Transmitted SKB */
 	struct sk_buff *skb;
@@ -974,72 +991,72 @@ static u32 mvpp2_read(struct mvpp2 *priv, u32 offset)
 static dma_addr_t mvpp2_txdesc_phys_addr_get(struct mvpp2_port *port,
 					     struct mvpp2_tx_desc *tx_desc)
 {
-	return tx_desc->buf_phys_addr;
+	return tx_desc->pp21.buf_phys_addr;
 }
 
 static void mvpp2_txdesc_phys_addr_set(struct mvpp2_port *port,
 				       struct mvpp2_tx_desc *tx_desc,
 				       dma_addr_t phys_addr)
 {
-	tx_desc->buf_phys_addr = phys_addr;
+	tx_desc->pp21.buf_phys_addr = phys_addr;
 }
 
 static size_t mvpp2_txdesc_size_get(struct mvpp2_port *port,
 				    struct mvpp2_tx_desc *tx_desc)
 {
-	return tx_desc->data_size;
+	return tx_desc->pp21.data_size;
 }
 
 static void mvpp2_txdesc_size_set(struct mvpp2_port *port,
 				  struct mvpp2_tx_desc *tx_desc,
 				  size_t size)
 {
-	tx_desc->data_size = size;
+	tx_desc->pp21.data_size = size;
 }
 
 static void mvpp2_txdesc_txq_set(struct mvpp2_port *port,
 				 struct mvpp2_tx_desc *tx_desc,
 				 unsigned int txq)
 {
-	tx_desc->phys_txq = txq;
+	tx_desc->pp21.phys_txq = txq;
 }
 
 static void mvpp2_txdesc_cmd_set(struct mvpp2_port *port,
 				 struct mvpp2_tx_desc *tx_desc,
 				 unsigned int command)
 {
-	tx_desc->command = command;
+	tx_desc->pp21.command = command;
 }
 
 static void mvpp2_txdesc_offset_set(struct mvpp2_port *port,
 				    struct mvpp2_tx_desc *tx_desc,
 				    unsigned int offset)
 {
-	tx_desc->packet_offset = offset;
+	tx_desc->pp21.packet_offset = offset;
 }
 
 static dma_addr_t mvpp2_rxdesc_phys_addr_get(struct mvpp2_port *port,
 					     struct mvpp2_rx_desc *rx_desc)
 {
-	return rx_desc->buf_phys_addr;
+	return rx_desc->pp21.buf_phys_addr;
 }
 
 static unsigned long mvpp2_rxdesc_virt_addr_get(struct mvpp2_port *port,
 						struct mvpp2_rx_desc *rx_desc)
 {
-	return rx_desc->buf_cookie;
+	return rx_desc->pp21.buf_cookie;
 }
 
 static size_t mvpp2_rxdesc_size_get(struct mvpp2_port *port,
 				    struct mvpp2_rx_desc *rx_desc)
 {
-	return rx_desc->data_size;
+	return rx_desc->pp21.data_size;
 }
 
 static u32 mvpp2_rxdesc_status_get(struct mvpp2_port *port,
 				   struct mvpp2_rx_desc *rx_desc)
 {
-	return rx_desc->status;
+	return rx_desc->pp21.status;
 }
 
 static void mvpp2_txq_inc_get(struct mvpp2_txq_pcpu *txq_pcpu)
-- 
2.7.4

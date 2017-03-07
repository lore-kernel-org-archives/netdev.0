From: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: [PATCHv3 net-next 09/22] net: mvpp2: introduce an intermediate union for the TX/RX descriptors
Date: Tue,  7 Mar 2017 16:53:07 +0100
Message-ID: <1488902000-2658-10-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1488902000-2658-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Nadav Haklai <nadavh-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>, Hanna Hawa <hannah-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Yehuda Yitschak <yehuday-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Gregory Clement <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Stefan Chulski <stefanc-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Marcin Wojtas <mw-nYOzD4b6Jr9Wk0Htik3J/w@public.gmane.org>,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
        Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
        Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1488902000-2658-1-git-send-email-thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Since the format of the HW descriptors is different between PPv2.1 and
PPv2.2, this commit introduces an intermediate union, with for now
only the PPv2.1 descriptors. The bulk of the driver code only
manipulates opaque mvpp2_tx_desc and mvpp2_rx_desc pointers, and the
descriptors can only be accessed and modified through the accessor
functions. A follow-up commit will add the descriptor definitions for
PPv2.2.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
---
 drivers/net/ethernet/marvell/mvpp2.c | 45 +++++++++++++++++++++++++-----------
 1 file changed, 31 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 27d8838..e9710e8 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -739,7 +739,8 @@ struct mvpp2_port {
 #define MVPP2_RXD_L3_IP6		BIT(30)
 #define MVPP2_RXD_BUF_HDR		BIT(31)
 
-struct mvpp2_tx_desc {
+/* HW TX descriptor for PPv2.1 */
+struct mvpp21_tx_desc {
 	u32 command;		/* Options used by HW for packet transmitting.*/
 	u8  packet_offset;	/* the offset from the buffer beginning	*/
 	u8  phys_txq;		/* destination queue ID			*/
@@ -750,7 +751,8 @@ struct mvpp2_tx_desc {
 	u32 reserved2;		/* reserved (for future use)		*/
 };
 
-struct mvpp2_rx_desc {
+/* HW RX descriptor for PPv2.1 */
+struct mvpp21_rx_desc {
 	u32 status;		/* info about received packet		*/
 	u16 reserved1;		/* parser_info (for future use, PnC)	*/
 	u16 data_size;		/* size of received packet in bytes	*/
@@ -765,6 +767,21 @@ struct mvpp2_rx_desc {
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
@@ -952,78 +969,78 @@ static u32 mvpp2_read(struct mvpp2 *priv, u32 offset)
 static dma_addr_t mvpp2_txdesc_dma_addr_get(struct mvpp2_port *port,
 					    struct mvpp2_tx_desc *tx_desc)
 {
-	return tx_desc->buf_dma_addr;
+	return tx_desc->pp21.buf_dma_addr;
 }
 
 static void mvpp2_txdesc_dma_addr_set(struct mvpp2_port *port,
 				      struct mvpp2_tx_desc *tx_desc,
 				      dma_addr_t dma_addr)
 {
-	tx_desc->buf_dma_addr = dma_addr;
+	tx_desc->pp21.buf_dma_addr = dma_addr;
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
 
 static unsigned int mvpp2_txdesc_offset_get(struct mvpp2_port *port,
 					    struct mvpp2_tx_desc *tx_desc)
 {
-	return tx_desc->packet_offset;
+	return tx_desc->pp21.packet_offset;
 }
 
 static dma_addr_t mvpp2_rxdesc_dma_addr_get(struct mvpp2_port *port,
 					    struct mvpp2_rx_desc *rx_desc)
 {
-	return rx_desc->buf_dma_addr;
+	return rx_desc->pp21.buf_dma_addr;
 }
 
 static unsigned long mvpp2_rxdesc_cookie_get(struct mvpp2_port *port,
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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

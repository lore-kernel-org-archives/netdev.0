From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 1/2] net: mvneta: move the RX and TX desc macros outside of the structs
Date: Mon, 15 Jul 2013 15:27:25 +0200
Message-ID: <1373894846-1147-2-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1373894846-1147-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: linux-arm-kernel@lists.infradead.org,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:57028 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756556Ab3GON1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jul 2013 09:27:41 -0400
In-Reply-To: <1373894846-1147-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macros used for the various fields of the RX and TX descriptions
are currently declared next to those fields within the structure
definitions of the RX and TX descriptors.

However, in order to support big endian, we'll have to use the "swap
descriptors" features of the hardware, which swaps every byte within
each 64 bits word of the descriptors. This requires a separate
definition of the RX and TX descriptor structures for little and big
endian, as is done in the mv643xx_eth. Those macros can therefore no
longer be defined inside those structures.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 26 +++++++++++++++-----------
 1 file changed, 15 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 712779f..649162e 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -262,8 +262,7 @@ struct mvneta_port {
  * layout of the transmit and reception DMA descriptors, and their
  * layout is therefore defined by the hardware design
  */
-struct mvneta_tx_desc {
-	u32  command;		/* Options used by HW for packet transmitting.*/
+
 #define MVNETA_TX_L3_OFF_SHIFT	0
 #define MVNETA_TX_IP_HLEN_SHIFT	8
 #define MVNETA_TX_L4_UDP	BIT(16)
@@ -278,15 +277,6 @@ struct mvneta_tx_desc {
 #define MVNETA_TX_L4_CSUM_FULL	BIT(30)
 #define MVNETA_TX_L4_CSUM_NOT	BIT(31)
 
-	u16  reserverd1;	/* csum_l4 (for future use)		*/
-	u16  data_size;		/* Data size of transmitted packet in bytes */
-	u32  buf_phys_addr;	/* Physical addr of transmitted buffer	*/
-	u32  reserved2;		/* hw_cmd - (for future use, PMT)	*/
-	u32  reserved3[4];	/* Reserved - (for future use)		*/
-};
-
-struct mvneta_rx_desc {
-	u32  status;		/* Info about received packet		*/
 #define MVNETA_RXD_ERR_CRC		0x0
 #define MVNETA_RXD_ERR_SUMMARY		BIT(16)
 #define MVNETA_RXD_ERR_OVERRUN		BIT(17)
@@ -297,13 +287,27 @@ struct mvneta_rx_desc {
 #define MVNETA_RXD_FIRST_LAST_DESC	(BIT(26) | BIT(27))
 #define MVNETA_RXD_L4_CSUM_OK		BIT(30)
 
+struct mvneta_tx_desc {
+	u32  command;		/* Options used by HW for packet transmitting.*/
+	u16  reserverd1;	/* csum_l4 (for future use)		*/
+	u16  data_size;		/* Data size of transmitted packet in bytes */
+	u32  buf_phys_addr;	/* Physical addr of transmitted buffer	*/
+	u32  reserved2;		/* hw_cmd - (for future use, PMT)	*/
+	u32  reserved3[4];	/* Reserved - (for future use)		*/
+};
+
+struct mvneta_rx_desc {
+	u32  status;		/* Info about received packet		*/
 	u16  reserved1;		/* pnc_info - (for future use, PnC)	*/
 	u16  data_size;		/* Size of received packet in bytes	*/
+
 	u32  buf_phys_addr;	/* Physical address of the buffer	*/
 	u32  reserved2;		/* pnc_flow_id  (for future use, PnC)	*/
+
 	u32  buf_cookie;	/* cookie for access to RX buffer in rx path */
 	u16  reserved3;		/* prefetch_cmd, for future use		*/
 	u16  reserved4;		/* csum_l4 - (for future use, PnC)	*/
+
 	u32  reserved5;		/* pnc_extra PnC (for future use, PnC)	*/
 	u32  reserved6;		/* hw_cmd (for future use, PnC and HWF)	*/
 };
-- 
1.8.1.2

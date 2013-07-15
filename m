From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 2/2] net: mvneta: support big endian
Date: Mon, 15 Jul 2013 15:27:26 +0200
Message-ID: <1373894846-1147-3-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1373894846-1147-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: linux-arm-kernel@lists.infradead.org,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:57031 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756556Ab3GON1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jul 2013 09:27:47 -0400
In-Reply-To: <1373894846-1147-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the "swap descriptor" feature of the hardware to properly swap the
descriptors when running in big endian mode. Since the swapping occurs
on 64 bits words, we also need to provide a separate structure layout
for the DMA descriptors between little endian and big endian mode,
like is done in the mv643xx_eth driver.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 35 ++++++++++++++++++++++++++++++++---
 1 file changed, 32 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 649162e..9647976 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -79,10 +79,10 @@
 #define MVNETA_MAC_ADDR_HIGH                     0x2418
 #define MVNETA_SDMA_CONFIG                       0x241c
 #define      MVNETA_SDMA_BRST_SIZE_16            4
-#define      MVNETA_NO_DESC_SWAP                 0x0
 #define      MVNETA_RX_BRST_SZ_MASK(burst)       ((burst) << 1)
 #define      MVNETA_RX_NO_DATA_SWAP              BIT(4)
 #define      MVNETA_TX_NO_DATA_SWAP              BIT(5)
+#define      MVNETA_DESC_SWAP                    BIT(6)
 #define      MVNETA_TX_BRST_SZ_MASK(burst)       ((burst) << 22)
 #define MVNETA_PORT_STATUS                       0x2444
 #define      MVNETA_TX_IN_PRGRS                  BIT(1)
@@ -287,6 +287,7 @@ struct mvneta_port {
 #define MVNETA_RXD_FIRST_LAST_DESC	(BIT(26) | BIT(27))
 #define MVNETA_RXD_L4_CSUM_OK		BIT(30)
 
+#if defined(__LITTLE_ENDIAN)
 struct mvneta_tx_desc {
 	u32  command;		/* Options used by HW for packet transmitting.*/
 	u16  reserverd1;	/* csum_l4 (for future use)		*/
@@ -311,6 +312,32 @@ struct mvneta_rx_desc {
 	u32  reserved5;		/* pnc_extra PnC (for future use, PnC)	*/
 	u32  reserved6;		/* hw_cmd (for future use, PnC and HWF)	*/
 };
+#else
+struct mvneta_tx_desc {
+	u16  data_size;		/* Data size of transmitted packet in bytes */
+	u16  reserverd1;	/* csum_l4 (for future use)		*/
+	u32  command;		/* Options used by HW for packet transmitting.*/
+	u32  reserved2;		/* hw_cmd - (for future use, PMT)	*/
+	u32  buf_phys_addr;	/* Physical addr of transmitted buffer	*/
+	u32  reserved3[4];	/* Reserved - (for future use)		*/
+};
+
+struct mvneta_rx_desc {
+	u16  data_size;		/* Size of received packet in bytes	*/
+	u16  reserved1;		/* pnc_info - (for future use, PnC)	*/
+	u32  status;		/* Info about received packet		*/
+
+	u32  reserved2;		/* pnc_flow_id  (for future use, PnC)	*/
+	u32  buf_phys_addr;	/* Physical address of the buffer	*/
+
+	u16  reserved4;		/* csum_l4 - (for future use, PnC)	*/
+	u16  reserved3;		/* prefetch_cmd, for future use		*/
+	u32  buf_cookie;	/* cookie for access to RX buffer in rx path */
+
+	u32  reserved5;		/* pnc_extra PnC (for future use, PnC)	*/
+	u32  reserved6;		/* hw_cmd (for future use, PnC and HWF)	*/
+};
+#endif
 
 struct mvneta_tx_queue {
 	/* Number of this TX queue, in the range 0-7 */
@@ -908,9 +935,11 @@ static void mvneta_defaults_set(struct mvneta_port *pp)
 	/* Default burst size */
 	val |= MVNETA_TX_BRST_SZ_MASK(MVNETA_SDMA_BRST_SIZE_16);
 	val |= MVNETA_RX_BRST_SZ_MASK(MVNETA_SDMA_BRST_SIZE_16);
+	val |= MVNETA_RX_NO_DATA_SWAP | MVNETA_TX_NO_DATA_SWAP;
 
-	val |= (MVNETA_RX_NO_DATA_SWAP | MVNETA_TX_NO_DATA_SWAP |
-		MVNETA_NO_DESC_SWAP);
+#if defined(__BIG_ENDIAN)
+	val |= MVNETA_DESC_SWAP;
+#endif
 
 	/* Assign port SDMA configuration */
 	mvreg_write(pp, MVNETA_SDMA_CONFIG, val);
-- 
1.8.1.2

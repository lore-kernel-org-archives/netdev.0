From: Marek Vasut <marex@denx.de>
Subject: [PATCH V2 4/4] net: can: ifi: Add obscure bit swap for EFF frame IDs
Date: Wed,  2 Mar 2016 21:23:21 +0100
Message-ID: <1456950201-4812-5-git-send-email-marex@denx.de>
References: <1456950201-4812-1-git-send-email-marex@denx.de>
Cc: netdev@vger.kernel.org, Marek Vasut <marex@denx.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Mark Rutland <mark.rutland@arm.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>
To: linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1456950201-4812-1-git-send-email-marex@denx.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In case of CAN2.0 EFF frame, the controller handles frame IDs in a
rather bizzare way. The ID is split into an extended part, IDX[28:11]
and standard part, ID[10:0]. In the TX path, the core first sends the
top 11 bits of the IDX, followed by ID and finally the rest of IDX.
In the RX path, the core stores the ID the LSbit part of IDX field,
followed by the LSbit parts of real IDX. The MSbit parts of IDX are
stored in ID field of the register.

This patch implements the necessary bit shuffling to mitigate this
obscure behavior. In case two of these controllers are connected
together, the RX and TX bit swapping nullifies itself and the issue
does not manifest. The issue only manifests when talking to another
different CAN controller.

Signed-off-by: Marek Vasut <marex@denx.de>
Cc: Marc Kleine-Budde <mkl@pengutronix.de>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Oliver Hartkopp <socketcan@hartkopp.net>
Cc: Wolfgang Grandegger <wg@grandegger.com>
---
V2: Rebase on top of patch 3/4, no change to the patch
---
 drivers/net/can/ifi_canfd/ifi_canfd.c | 31 +++++++++++++++++++++++++++++--
 1 file changed, 29 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/ifi_canfd/ifi_canfd.c b/drivers/net/can/ifi_canfd/ifi_canfd.c
index 9b8638e..dc40d9c 100644
--- a/drivers/net/can/ifi_canfd/ifi_canfd.c
+++ b/drivers/net/can/ifi_canfd/ifi_canfd.c
@@ -136,7 +136,11 @@
 #define IFI_CANFD_RXFIFO_ID			0x6c
 #define IFI_CANFD_RXFIFO_ID_ID_OFFSET		0
 #define IFI_CANFD_RXFIFO_ID_ID_STD_MASK		CAN_SFF_MASK
+#define IFI_CANFD_RXFIFO_ID_ID_STD_OFFSET	0
+#define IFI_CANFD_RXFIFO_ID_ID_STD_WIDTH	10
 #define IFI_CANFD_RXFIFO_ID_ID_XTD_MASK		CAN_EFF_MASK
+#define IFI_CANFD_RXFIFO_ID_ID_XTD_OFFSET	11
+#define IFI_CANFD_RXFIFO_ID_ID_XTD_WIDTH	18
 #define IFI_CANFD_RXFIFO_ID_IDE			BIT(29)
 
 #define IFI_CANFD_RXFIFO_DATA			0x70	/* 0x70..0xac */
@@ -157,7 +161,11 @@
 #define IFI_CANFD_TXFIFO_ID			0xbc
 #define IFI_CANFD_TXFIFO_ID_ID_OFFSET		0
 #define IFI_CANFD_TXFIFO_ID_ID_STD_MASK		CAN_SFF_MASK
+#define IFI_CANFD_TXFIFO_ID_ID_STD_OFFSET	0
+#define IFI_CANFD_TXFIFO_ID_ID_STD_WIDTH	10
 #define IFI_CANFD_TXFIFO_ID_ID_XTD_MASK		CAN_EFF_MASK
+#define IFI_CANFD_TXFIFO_ID_ID_XTD_OFFSET	11
+#define IFI_CANFD_TXFIFO_ID_ID_XTD_WIDTH	18
 #define IFI_CANFD_TXFIFO_ID_IDE			BIT(29)
 
 #define IFI_CANFD_TXFIFO_DATA			0xc0	/* 0xb0..0xfc */
@@ -229,10 +237,20 @@ static void ifi_canfd_read_fifo(struct net_device *ndev)
 
 	rxid = readl(priv->base + IFI_CANFD_RXFIFO_ID);
 	id = (rxid >> IFI_CANFD_RXFIFO_ID_ID_OFFSET);
-	if (id & IFI_CANFD_RXFIFO_ID_IDE)
+	if (id & IFI_CANFD_RXFIFO_ID_IDE) {
 		id &= IFI_CANFD_RXFIFO_ID_ID_XTD_MASK;
-	else
+		/*
+		 * In case the Extended ID frame is received, the standard
+		 * and extended part of the ID are swapped in the register,
+		 * so swap them back to obtain the correct ID.
+		 */
+		id = (id >> IFI_CANFD_RXFIFO_ID_ID_XTD_OFFSET) |
+		     ((id & IFI_CANFD_RXFIFO_ID_ID_STD_MASK) <<
+		       IFI_CANFD_RXFIFO_ID_ID_XTD_WIDTH);
+		id |= CAN_EFF_FLAG;
+	} else {
 		id &= IFI_CANFD_RXFIFO_ID_ID_STD_MASK;
+	}
 	cf->can_id = id;
 
 	if (rxdlc & IFI_CANFD_RXFIFO_DLC_ESI) {
@@ -766,6 +784,15 @@ static netdev_tx_t ifi_canfd_start_xmit(struct sk_buff *skb,
 
 	if (cf->can_id & CAN_EFF_FLAG) {
 		txid = cf->can_id & CAN_EFF_MASK;
+		/*
+		 * In case the Extended ID frame is transmitted, the
+		 * standard and extended part of the ID are swapped
+		 * in the register, so swap them back to send the
+		 * correct ID.
+		 */
+		txid = (txid >> IFI_CANFD_TXFIFO_ID_ID_XTD_WIDTH) |
+		       ((txid & IFI_CANFD_TXFIFO_ID_ID_XTD_MASK) <<
+		         IFI_CANFD_TXFIFO_ID_ID_XTD_OFFSET);
 		txid |= IFI_CANFD_TXFIFO_ID_IDE;
 	} else {
 		txid = cf->can_id & CAN_SFF_MASK;
-- 
2.7.0


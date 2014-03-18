From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 10/12] can: c_can: Store dlc private
Date: Tue, 18 Mar 2014 17:19:14 -0000
Message-ID: <20140318171127.684183642@linutronix.de>
References: <20140318171007.528610837@linutronix.de>
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Markus Pargmann <mpa@pengutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=can-c_can-store-dlc-private.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We can avoid the HW access in TX cleanup path for retrieving the DLC
of the sent package if we store the DLC in a private array.

Ideally this should be handled in the can_echo_skb functions, but I
leave that exercise to the CAN folks.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 drivers/net/can/c_can/c_can.c |   28 +---------------------------
 drivers/net/can/c_can/c_can.h |   28 ++++++++++++++++++++++++++++
 2 files changed, 29 insertions(+), 27 deletions(-)

Index: linux/drivers/net/can/c_can/c_can.c
===================================================================
--- linux.orig/drivers/net/can/c_can/c_can.c
+++ linux/drivers/net/can/c_can/c_can.c
@@ -145,33 +145,6 @@
 #define IF_RX			0
 #define IF_TX			1
 
-/*
- * IFx register masks:
- * allow easy operation on 16-bit registers when the
- * argument is 32-bit instead
- */
-#define IFX_WRITE_LOW_16BIT(x)	((x) & 0xFFFF)
-#define IFX_WRITE_HIGH_16BIT(x)	(((x) & 0xFFFF0000) >> 16)
-
-/* message object split */
-#define C_CAN_NO_OF_OBJECTS	32
-#define C_CAN_MSG_OBJ_RX_NUM	16
-#define C_CAN_MSG_OBJ_TX_NUM	16
-
-#define C_CAN_MSG_OBJ_RX_FIRST	1
-#define C_CAN_MSG_OBJ_RX_LAST	(C_CAN_MSG_OBJ_RX_FIRST + \
-				C_CAN_MSG_OBJ_RX_NUM - 1)
-
-#define C_CAN_MSG_OBJ_TX_FIRST	(C_CAN_MSG_OBJ_RX_LAST + 1)
-#define C_CAN_MSG_OBJ_TX_LAST	(C_CAN_MSG_OBJ_TX_FIRST + \
-				C_CAN_MSG_OBJ_TX_NUM - 1)
-
-#define C_CAN_MSG_OBJ_RX_SPLIT	9
-#define C_CAN_MSG_RX_LOW_LAST	(C_CAN_MSG_OBJ_RX_SPLIT - 1)
-
-#define C_CAN_NEXT_MSG_OBJ_MASK	(C_CAN_MSG_OBJ_TX_NUM - 1)
-#define RECEIVE_OBJECT_BITS	0x0000ffff
-
 /* status interrupt */
 #define STATUS_INTERRUPT	0x8000
 
@@ -537,6 +510,7 @@ static netdev_tx_t c_can_start_xmit(stru
 
 	/* prepare message object for transmission */
 	c_can_write_msg_object(dev, IF_TX, frame, msg_obj_no);
+	priv->dlc[msg_obj_no - C_CAN_MSG_OBJ_TX_FIRST] = frame->can_dlc;
 	can_put_echo_skb(skb, dev, msg_obj_no - C_CAN_MSG_OBJ_TX_FIRST);
 
 	/*
Index: linux/drivers/net/can/c_can/c_can.h
===================================================================
--- linux.orig/drivers/net/can/c_can/c_can.h
+++ linux/drivers/net/can/c_can/c_can.h
@@ -22,6 +22,33 @@
 #ifndef C_CAN_H
 #define C_CAN_H
 
+/*
+ * IFx register masks:
+ * allow easy operation on 16-bit registers when the
+ * argument is 32-bit instead
+ */
+#define IFX_WRITE_LOW_16BIT(x)	((x) & 0xFFFF)
+#define IFX_WRITE_HIGH_16BIT(x)	(((x) & 0xFFFF0000) >> 16)
+
+/* message object split */
+#define C_CAN_NO_OF_OBJECTS	32
+#define C_CAN_MSG_OBJ_RX_NUM	16
+#define C_CAN_MSG_OBJ_TX_NUM	16
+
+#define C_CAN_MSG_OBJ_RX_FIRST	1
+#define C_CAN_MSG_OBJ_RX_LAST	(C_CAN_MSG_OBJ_RX_FIRST + \
+				C_CAN_MSG_OBJ_RX_NUM - 1)
+
+#define C_CAN_MSG_OBJ_TX_FIRST	(C_CAN_MSG_OBJ_RX_LAST + 1)
+#define C_CAN_MSG_OBJ_TX_LAST	(C_CAN_MSG_OBJ_TX_FIRST + \
+				C_CAN_MSG_OBJ_TX_NUM - 1)
+
+#define C_CAN_MSG_OBJ_RX_SPLIT	9
+#define C_CAN_MSG_RX_LOW_LAST	(C_CAN_MSG_OBJ_RX_SPLIT - 1)
+
+#define C_CAN_NEXT_MSG_OBJ_MASK	(C_CAN_MSG_OBJ_TX_NUM - 1)
+#define RECEIVE_OBJECT_BITS	0x0000ffff
+
 enum reg {
 	C_CAN_CTRL_REG = 0,
 	C_CAN_CTRL_EX_REG,
@@ -173,6 +200,7 @@ struct c_can_priv {
 	u32 __iomem *raminit_ctrlreg;
 	unsigned int instance;
 	void (*raminit) (const struct c_can_priv *priv, bool enable);
+	u32 dlc[C_CAN_MSG_OBJ_TX_NUM];
 };
 
 struct net_device *alloc_c_can_dev(void);

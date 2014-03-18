From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 05/12] can: c_can: Fix the lost message handling
Date: Tue, 18 Mar 2014 17:19:10 -0000
Message-ID: <20140318171127.064073034@linutronix.de>
References: <20140318171007.528610837@linutronix.de>
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Markus Pargmann <mpa@pengutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=can-c-can-fix-msg-lost-handling.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The lost message handling is broken in several ways. 

1) Clearing the message lost flag is done by writing 0 to the
   message control register of the object.

   #define IF_MCONT_CLR_MSGLST    (0 << 14)

   That clears the object buffer configuration in the worst case,
   which results in a loss of the EOB flag. That leaves the FIFO chain
   without a limit and causes a complete lockup of the HW

2) In case that the error skb allocation fails, the code happily
   claims that it handed down a packet. Just an accounting bug, but ....

3) The code adds a lot of pointless overhead to that error case, where
   we need to get stuff done as fast as possible to avoid more packet
   loss.

   - printk an annoying error message
   - reread the object buffer for nothing

Fix is simple again:

  - Use the already known MSGCTRL content and only clear the MSGLST bit
  - Fix the buffer accounting by adding a proper return code
  - Remove the pointless operations

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 drivers/net/can/c_can/c_can.c |   31 +++++++++++++++----------------
 1 file changed, 15 insertions(+), 16 deletions(-)

Index: linux/drivers/net/can/c_can/c_can.c
===================================================================
--- linux.orig/drivers/net/can/c_can/c_can.c
+++ linux/drivers/net/can/c_can/c_can.c
@@ -122,7 +122,6 @@
 /* IFx message control */
 #define IF_MCONT_NEWDAT		BIT(15)
 #define IF_MCONT_MSGLST		BIT(14)
-#define IF_MCONT_CLR_MSGLST	(0 << 14)
 #define IF_MCONT_INTPND		BIT(13)
 #define IF_MCONT_UMASK		BIT(12)
 #define IF_MCONT_TXIE		BIT(11)
@@ -411,27 +410,22 @@ static inline void c_can_activate_rx_msg
 	c_can_object_put(dev, iface, obj, IF_COMM_CONTROL);
 }
 
-static void c_can_handle_lost_msg_obj(struct net_device *dev,
-					int iface, int objno)
+static int c_can_handle_lost_msg_obj(struct net_device *dev,
+				     int iface, int objno, u32 ctrl)
 {
-	struct c_can_priv *priv = netdev_priv(dev);
 	struct net_device_stats *stats = &dev->stats;
-	struct sk_buff *skb;
+	struct c_can_priv *priv = netdev_priv(dev);
 	struct can_frame *frame;
+	struct sk_buff *skb;
 
-	netdev_err(dev, "msg lost in buffer %d\n", objno);
-
-	c_can_object_get(dev, iface, objno, IF_COMM_ALL & ~IF_COMM_TXRQST);
-
-	priv->write_reg(priv, C_CAN_IFACE(MSGCTRL_REG, iface),
-			IF_MCONT_CLR_MSGLST);
-
+	ctrl &= ~(IF_MCONT_MSGLST | IF_MCONT_INTPND | IF_MCONT_NEWDAT);
+	priv->write_reg(priv, C_CAN_IFACE(MSGCTRL_REG, iface), ctrl);
 	c_can_object_put(dev, iface, objno, IF_COMM_CONTROL);
 
 	/* create an error msg */
 	skb = alloc_can_err_skb(dev, &frame);
 	if (unlikely(!skb))
-		return;
+		return 0;
 
 	frame->can_id |= CAN_ERR_CRTL;
 	frame->data[1] = CAN_ERR_CRTL_RX_OVERFLOW;
@@ -439,6 +433,7 @@ static void c_can_handle_lost_msg_obj(st
 	stats->rx_over_errors++;
 
 	netif_receive_skb(skb);
+	return 1;
 }
 
 static int c_can_read_msg_object(struct net_device *dev, int iface, int ctrl)
@@ -901,9 +896,13 @@ static int c_can_do_rx_poll(struct net_d
 					C_CAN_IFACE(MSGCTRL_REG, IF_RX));
 
 			if (msg_ctrl_save & IF_MCONT_MSGLST) {
-				c_can_handle_lost_msg_obj(dev, IF_RX, msg_obj);
-				num_rx_pkts++;
-				quota--;
+				int n;
+
+				n = c_can_handle_lost_msg_obj(dev, IF_RX,
+							      msg_obj,
+							      msg_ctrl_save);
+				num_rx_pkts += n;
+				quota -=n;
 				continue;
 			}
 

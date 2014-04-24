From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 07/26] can: c_can: Always update error stats
Date: Fri, 25 Apr 2014 00:00:10 +0200
Message-ID: <1398376829-6771-8-git-send-email-mkl@pengutronix.de>
References: <1398376829-6771-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Thomas Gleixner <tglx@linutronix.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1398376829-6771-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Gleixner <tglx@linutronix.de>

If the allocation of the error skb fails, we still want to see the
error statistics.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Tested-by: Alexander Stein <alexander.stein@systec-electronic.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 9ef45b0..6170e64 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -378,6 +378,9 @@ static int c_can_handle_lost_msg_obj(struct net_device *dev,
 	priv->write_reg(priv, C_CAN_IFACE(MSGCTRL_REG, iface), ctrl);
 	c_can_object_put(dev, iface, objno, IF_COMM_CONTROL);
 
+	stats->rx_errors++;
+	stats->rx_over_errors++;
+
 	/* create an error msg */
 	skb = alloc_can_err_skb(dev, &frame);
 	if (unlikely(!skb))
@@ -385,8 +388,6 @@ static int c_can_handle_lost_msg_obj(struct net_device *dev,
 
 	frame->can_id |= CAN_ERR_CRTL;
 	frame->data[1] = CAN_ERR_CRTL_RX_OVERFLOW;
-	stats->rx_errors++;
-	stats->rx_over_errors++;
 
 	netif_receive_skb(skb);
 	return 1;
@@ -996,6 +997,10 @@ static int c_can_handle_bus_err(struct net_device *dev,
 	if (!(priv->can.ctrlmode & CAN_CTRLMODE_BERR_REPORTING))
 		return 0;
 
+	/* common for all type of bus errors */
+	priv->can.can_stats.bus_error++;
+	stats->rx_errors++;
+
 	/* propagate the error condition to the CAN stack */
 	skb = alloc_can_err_skb(dev, &cf);
 	if (unlikely(!skb))
@@ -1005,10 +1010,6 @@ static int c_can_handle_bus_err(struct net_device *dev,
 	 * check for 'last error code' which tells us the
 	 * type of the last error to occur on the CAN bus
 	 */
-
-	/* common for all type of bus errors */
-	priv->can.can_stats.bus_error++;
-	stats->rx_errors++;
 	cf->can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
 	cf->data[2] |= CAN_ERR_PROT_UNSPEC;
 
-- 
1.9.0.279.gdc9e3eb


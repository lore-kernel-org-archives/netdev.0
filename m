From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/4] can: c_can: fix "BUG! echo_skb is occupied!" during transmit
Date: Mon,  4 Jun 2012 00:21:57 +0200
Message-ID: <1338762120-12695-2-git-send-email-mkl@pengutronix.de>
References: <1338762120-12695-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	AnilKumar Ch <anilkumar@ti.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:55226 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754920Ab2FCWWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jun 2012 18:22:17 -0400
In-Reply-To: <1338762120-12695-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: AnilKumar Ch <anilkumar@ti.com>

This patch fixes an issue with transmit routine, which causes
"can_put_echo_skb: BUG! echo_skb is occupied!" message when
using "cansequence -p" on D_CAN controller.

In c_can driver, while transmitting packets tx_echo flag holds
the no of can frames put for transmission into the hardware.

As the comment above c_can_do_tx() indicates, if we find any packet
which is not transmitted then we should stop looking for more.
In the current implementation this is not taken care of causing the
said message.

Also, fix the condition used to find if the packet is transmitted
or not. Current code skips the first tx message object and ends up
checking one extra invalid object.

While at it, fix the comment on top of c_can_do_tx() to use the
terminology "packet" instead of "package" since it is more
standard.

Cc: stable@kernel.org # 2.6.39+
Signed-off-by: AnilKumar Ch <anilkumar@ti.com>
Acked-by: Wolfgang Grandegger <wg@grandegger.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 536bda0..9ac28df 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -686,7 +686,7 @@ static int c_can_get_berr_counter(const struct net_device *dev,
  *
  * We iterate from priv->tx_echo to priv->tx_next and check if the
  * packet has been transmitted, echo it back to the CAN framework.
- * If we discover a not yet transmitted package, stop looking for more.
+ * If we discover a not yet transmitted packet, stop looking for more.
  */
 static void c_can_do_tx(struct net_device *dev)
 {
@@ -698,7 +698,7 @@ static void c_can_do_tx(struct net_device *dev)
 	for (/* nix */; (priv->tx_next - priv->tx_echo) > 0; priv->tx_echo++) {
 		msg_obj_no = get_tx_echo_msg_obj(priv);
 		val = c_can_read_reg32(priv, &priv->regs->txrqst1);
-		if (!(val & (1 << msg_obj_no))) {
+		if (!(val & (1 << (msg_obj_no - 1)))) {
 			can_get_echo_skb(dev,
 					msg_obj_no - C_CAN_MSG_OBJ_TX_FIRST);
 			stats->tx_bytes += priv->read_reg(priv,
@@ -706,6 +706,8 @@ static void c_can_do_tx(struct net_device *dev)
 					& IF_MCONT_DLC_MASK;
 			stats->tx_packets++;
 			c_can_inval_msg_object(dev, 0, msg_obj_no);
+		} else {
+			break;
 		}
 	}
 
-- 
1.7.4.1

From: Marek Vasut <marex@denx.de>
Subject: [PATCH 2/4] net: can: ifi: Fix TX DLC configuration
Date: Mon, 29 Feb 2016 20:59:29 +0100
Message-ID: <1456775971-4946-3-git-send-email-marex@denx.de>
References: <1456775971-4946-1-git-send-email-marex@denx.de>
Cc: netdev@vger.kernel.org, Marek Vasut <marex@denx.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Mark Rutland <mark.rutland@arm.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>
To: linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1456775971-4946-1-git-send-email-marex@denx.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The TX DLC, the transmission length information, was not written
into the transmit configuration register. When using the CAN core
with different CAN controller, the receiving CAN controller will
receive only the ID part of the CAN frame, but no data at all.

This patch adds the TX DLC into the register to fix this issue.

Signed-off-by: Marek Vasut <marex@denx.de>
Cc: Marc Kleine-Budde <mkl@pengutronix.de>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Oliver Hartkopp <socketcan@hartkopp.net>
Cc: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/ifi_canfd/ifi_canfd.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/can/ifi_canfd/ifi_canfd.c b/drivers/net/can/ifi_canfd/ifi_canfd.c
index 72f5205..82a33bd 100644
--- a/drivers/net/can/ifi_canfd/ifi_canfd.c
+++ b/drivers/net/can/ifi_canfd/ifi_canfd.c
@@ -774,10 +774,15 @@ static netdev_tx_t ifi_canfd_start_xmit(struct sk_buff *skb,
 
 	if (priv->can.ctrlmode & (CAN_CTRLMODE_FD | CAN_CTRLMODE_FD_NON_ISO)) {
 		if (can_is_canfd_skb(skb)) {
+			txdlc |= can_len2dlc(cf->len);
 			txdlc |= IFI_CANFD_TXFIFO_DLC_EDL;
 			if (cf->flags & CANFD_BRS)
 				txdlc |= IFI_CANFD_TXFIFO_DLC_BRS;
+		} else {
+			txdlc |= cf->len;
 		}
+	} else {
+		txdlc |= cf->len;
 	}
 
 	if (cf->can_id & CAN_RTR_FLAG)
-- 
2.7.0


From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 6/7] can: flexcan: fix bus-off error state handling.
Date: Sun, 22 Mar 2015 20:13:37 +0100
Message-ID: <1427051618-28318-7-git-send-email-mkl@pengutronix.de>
References: <1427051618-28318-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Andri Yngvason <andri.yngvason@marel.com>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:38561 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751997AbbCVTNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 15:13:47 -0400
In-Reply-To: <1427051618-28318-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andri Yngvason <andri.yngvason@marel.com>

Making sure that the bus-off state gets passed to can_change_state().

Signed-off-by: Andri Yngvason <andri.yngvason@marel.com>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/flexcan.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index 80c46ad4cee4..ee944ae6bb96 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -592,13 +592,12 @@ static int flexcan_poll_state(struct net_device *dev, u32 reg_esr)
 		rx_state = unlikely(reg_esr & FLEXCAN_ESR_RX_WRN) ?
 			   CAN_STATE_ERROR_WARNING : CAN_STATE_ERROR_ACTIVE;
 		new_state = max(tx_state, rx_state);
-	} else if (unlikely(flt == FLEXCAN_ESR_FLT_CONF_PASSIVE)) {
+	} else {
 		__flexcan_get_berr_counter(dev, &bec);
-		new_state = CAN_STATE_ERROR_PASSIVE;
+		new_state = flt == FLEXCAN_ESR_FLT_CONF_PASSIVE ?
+			    CAN_STATE_ERROR_PASSIVE : CAN_STATE_BUS_OFF;
 		rx_state = bec.rxerr >= bec.txerr ? new_state : 0;
 		tx_state = bec.rxerr <= bec.txerr ? new_state : 0;
-	} else {
-		new_state = CAN_STATE_BUS_OFF;
 	}
 
 	/* state hasn't changed */
-- 
2.1.4

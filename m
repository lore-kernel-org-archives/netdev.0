From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/6] can: dev: make can_change_state() robust to be called with cf == NULL
Date: Fri,  9 Jun 2017 14:55:08 +0200
Message-ID: <20170609125513.24436-2-mkl@pengutronix.de>
References: <20170609125513.24436-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:59501 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751591AbdFIMzU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 08:55:20 -0400
In-Reply-To: <20170609125513.24436-1-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In OOM situations where no skb can be allocated, can_change_state() may
be called with cf == NULL. As this function updates the state and error
statistics it's not an option to skip the call to can_change_state() in
OOM situations.

This patch makes can_change_state() robust, so that it can be called
with cf == NULL.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/dev.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index 611d16a7061d..ae4ed03dc642 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -391,6 +391,9 @@ void can_change_state(struct net_device *dev, struct can_frame *cf,
 	can_update_state_error_stats(dev, new_state);
 	priv->state = new_state;
 
+	if (!cf)
+		return;
+
 	if (unlikely(new_state == CAN_STATE_BUS_OFF)) {
 		cf->can_id |= CAN_ERR_BUSOFF;
 		return;
-- 
2.11.0

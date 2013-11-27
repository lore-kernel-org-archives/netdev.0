From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/4] can: c_can: don't call pm_runtime_get_sync() from interrupt context
Date: Wed, 27 Nov 2013 22:11:33 +0100
Message-ID: <1385586695-11134-3-git-send-email-mkl@pengutronix.de>
References: <1385586695-11134-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>,
	Andrew Glen <AGlen@bepmarine.com>,
	linux-stable <stable@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:49155 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757681Ab3K0VLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 16:11:51 -0500
In-Reply-To: <1385586695-11134-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The c_can driver contians a callpath (c_can_poll -> c_can_state_change ->
c_can_get_berr_counter) which may call pm_runtime_get_sync() from the IRQ
handler, which is not allowed and results in "BUG: scheduling while atomic".

This problem is fixed by introducing __c_can_get_berr_counter, which will not
call pm_runtime_get_sync().

Reported-by: Andrew Glen <AGlen@bepmarine.com>
Tested-by: Andrew Glen <AGlen@bepmarine.com>
Signed-off-by: Andrew Glen <AGlen@bepmarine.com>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c | 21 +++++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index e3fc07c..e59c42b 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -712,22 +712,31 @@ static int c_can_set_mode(struct net_device *dev, enum can_mode mode)
 	return 0;
 }
 
-static int c_can_get_berr_counter(const struct net_device *dev,
-					struct can_berr_counter *bec)
+static int __c_can_get_berr_counter(const struct net_device *dev,
+				    struct can_berr_counter *bec)
 {
 	unsigned int reg_err_counter;
 	struct c_can_priv *priv = netdev_priv(dev);
 
-	c_can_pm_runtime_get_sync(priv);
-
 	reg_err_counter = priv->read_reg(priv, C_CAN_ERR_CNT_REG);
 	bec->rxerr = (reg_err_counter & ERR_CNT_REC_MASK) >>
 				ERR_CNT_REC_SHIFT;
 	bec->txerr = reg_err_counter & ERR_CNT_TEC_MASK;
 
+	return 0;
+}
+
+static int c_can_get_berr_counter(const struct net_device *dev,
+				  struct can_berr_counter *bec)
+{
+	struct c_can_priv *priv = netdev_priv(dev);
+	int err;
+
+	c_can_pm_runtime_get_sync(priv);
+	err = __c_can_get_berr_counter(dev, bec);
 	c_can_pm_runtime_put_sync(priv);
 
-	return 0;
+	return err;
 }
 
 /*
@@ -872,7 +881,7 @@ static int c_can_handle_state_change(struct net_device *dev,
 	if (unlikely(!skb))
 		return 0;
 
-	c_can_get_berr_counter(dev, &bec);
+	__c_can_get_berr_counter(dev, &bec);
 	reg_err_counter = priv->read_reg(priv, C_CAN_ERR_CNT_REG);
 	rx_err_passive = (reg_err_counter & ERR_CNT_RP_MASK) >>
 				ERR_CNT_RP_SHIFT;
-- 
1.8.5.rc0

From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH] can: c_can: add xceiver enable/disable support
Date: Wed, 20 Jan 2016 12:55:30 +0100
Message-ID: <1453290930-19136-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel@pengutronix.de
To: mkl@pengutronix.de, wg@grandegger.com
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support to enable and disable the xceiver
in case it's switchable by the regulator framework.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c | 31 +++++++++++++++++++++++++++++++
 drivers/net/can/c_can/c_can.h |  1 +
 2 files changed, 32 insertions(+)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index f91b094..ca42044 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -36,6 +36,7 @@
 #include <linux/io.h>
 #include <linux/pm_runtime.h>
 #include <linux/pinctrl/consumer.h>
+#include <linux/regulator/consumer.h>
 
 #include <linux/can.h>
 #include <linux/can/dev.h>
@@ -588,6 +589,22 @@ static int c_can_chip_config(struct net_device *dev)
 	return c_can_set_bittiming(dev);
 }
 
+static inline int c_can_transceiver_enable(const struct c_can_priv *priv)
+{
+	if (!priv->reg_xceiver)
+		return 0;
+
+	return regulator_enable(priv->reg_xceiver);
+}
+
+static inline int c_can_transceiver_disable(const struct c_can_priv *priv)
+{
+	if (!priv->reg_xceiver)
+		return 0;
+
+	return regulator_disable(priv->reg_xceiver);
+}
+
 static int c_can_start(struct net_device *dev)
 {
 	struct c_can_priv *priv = netdev_priv(dev);
@@ -612,6 +629,10 @@ static int c_can_start(struct net_device *dev)
 	else
 		pinctrl_pm_select_default_state(priv->device);
 
+	err = c_can_transceiver_enable(priv);
+	if (err)
+		return err;
+
 	return 0;
 }
 
@@ -626,6 +647,9 @@ static void c_can_stop(struct net_device *dev)
 
 	/* deactivate pins */
 	pinctrl_pm_select_sleep_state(dev->dev.parent);
+
+	c_can_transceiver_disable(priv);
+
 	priv->can.state = CAN_STATE_STOPPED;
 }
 
@@ -1263,6 +1287,13 @@ int register_c_can_dev(struct net_device *dev)
 	 */
 	pinctrl_pm_select_sleep_state(dev->dev.parent);
 
+	priv->reg_xceiver = devm_regulator_get(priv->device, "xceiver");
+	if (IS_ERR(priv->reg_xceiver)) {
+		if (PTR_ERR(priv->reg_xceiver) == -EPROBE_DEFER)
+			return -EPROBE_DEFER;
+		priv->reg_xceiver = NULL;
+	}
+
 	c_can_pm_runtime_enable(priv);
 
 	dev->flags |= IFF_ECHO;	/* we support local echo */
diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_can.h
index 8acdc7f..59246e3 100644
--- a/drivers/net/can/c_can/c_can.h
+++ b/drivers/net/can/c_can/c_can.h
@@ -213,6 +213,7 @@ struct c_can_priv {
 	u32 comm_rcv_high;
 	u32 rxmasked;
 	u32 dlc[C_CAN_MSG_OBJ_TX_NUM];
+	struct regulator *reg_xceiver;
 };
 
 struct net_device *alloc_c_can_dev(void);
-- 
2.7.0.rc3


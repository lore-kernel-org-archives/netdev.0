From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH v2] can: c_can: add xceiver enable/disable support
Date: Wed, 20 Jan 2016 14:44:03 +0100
Message-ID: <1453297443-23279-1-git-send-email-m.grzeschik@pengutronix.de>
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
v1 -> v2:
 - always returning PTR_ERR in case devm_regulator_get fails
 - removed inline wrapper functions with checks for xceiver == NULL

 drivers/net/can/c_can/c_can.c | 12 ++++++++++++
 drivers/net/can/c_can/c_can.h |  1 +
 2 files changed, 13 insertions(+)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index f91b094..0723aeb 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -36,6 +36,7 @@
 #include <linux/io.h>
 #include <linux/pm_runtime.h>
 #include <linux/pinctrl/consumer.h>
+#include <linux/regulator/consumer.h>
 
 #include <linux/can.h>
 #include <linux/can/dev.h>
@@ -612,6 +613,10 @@ static int c_can_start(struct net_device *dev)
 	else
 		pinctrl_pm_select_default_state(priv->device);
 
+	err = regulator_enable(priv->reg_xceiver);
+	if (err)
+		return err;
+
 	return 0;
 }
 
@@ -626,6 +631,9 @@ static void c_can_stop(struct net_device *dev)
 
 	/* deactivate pins */
 	pinctrl_pm_select_sleep_state(dev->dev.parent);
+
+	regulator_disable(priv->reg_xceiver);
+
 	priv->can.state = CAN_STATE_STOPPED;
 }
 
@@ -1263,6 +1271,10 @@ int register_c_can_dev(struct net_device *dev)
 	 */
 	pinctrl_pm_select_sleep_state(dev->dev.parent);
 
+	priv->reg_xceiver = devm_regulator_get(priv->device, "xceiver");
+	if (IS_ERR(priv->reg_xceiver))
+		return PTR_ERR(priv->reg_xceiver);
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


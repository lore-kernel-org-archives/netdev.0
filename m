From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH v3] can: c_can: add xceiver enable/disable support
Date: Thu, 21 Jan 2016 12:24:51 +0100
Message-ID: <1453375491-21140-1-git-send-email-m.grzeschik@pengutronix.de>
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
v2 -> v3:
 - adding documentation for the devicetree binding (already generic)

 Documentation/devicetree/bindings/net/can/c_can.txt |  2 ++
 drivers/net/can/c_can/c_can.c                       | 12 ++++++++++++
 drivers/net/can/c_can/c_can.h                       |  1 +
 3 files changed, 15 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/can/c_can.txt b/Documentation/devicetree/bindings/net/can/c_can.txt
index 5a1d8b0..a36fea2 100644
--- a/Documentation/devicetree/bindings/net/can/c_can.txt
+++ b/Documentation/devicetree/bindings/net/can/c_can.txt
@@ -18,6 +18,8 @@ Optional properties:
 			  RAMINIT register, register offset to the RAMINIT
 			  register and the CAN instance number (0 offset).
 
+- xceiver-supply: Regulator that powers the CAN transceiver
+
 Note: "ti,hwmods" field is used to fetch the base address and irq
 resources from TI, omap hwmod data base during device registration.
 Future plan is to migrate hwmod data base contents into device tree
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


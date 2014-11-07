From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH v4 6/8] net: can: c_can: Disable pins when CAN interface is down
Date: Fri, 7 Nov 2014 16:49:20 +0200
Message-ID: <1415371762-29885-7-git-send-email-rogerq@ti.com>
References: <1415371762-29885-1-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <wsa@the-dreams.de>, <tony@atomide.com>, <tglx@linutronix.de>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <balbi@ti.com>,
	<nsekhar@ti.com>, <nm@ti.com>,
	<sergei.shtylyov@cogentembedded.com>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	Roger Quadros <rogerq@ti.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1415371762-29885-1-git-send-email-rogerq@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DRA7 CAN IP suffers from a problem which causes it to be prevented
from fully turning OFF (i.e. stuck in transition) if the module was
disabled while there was traffic on the CAN_RX line.

To work around this issue we select the SLEEP pin state by default
on probe and use the DEFAULT pin state on CAN up and back to the
SLEEP pin state on CAN down.

Signed-off-by: Roger Quadros <rogerq@ti.com>
---
 drivers/net/can/c_can/c_can.c          | 20 ++++++++++++++++++++
 drivers/net/can/c_can/c_can.h          |  1 +
 drivers/net/can/c_can/c_can_platform.c | 20 ++++++++++++++++++++
 3 files changed, 41 insertions(+)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 8e78bb4..4dfc3ce 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -35,6 +35,7 @@
 #include <linux/list.h>
 #include <linux/io.h>
 #include <linux/pm_runtime.h>
+#include <linux/pinctrl/consumer.h>
 
 #include <linux/can.h>
 #include <linux/can/dev.h>
@@ -603,6 +604,15 @@ static int c_can_start(struct net_device *dev)
 
 	priv->can.state = CAN_STATE_ERROR_ACTIVE;
 
+	/* activate pins */
+	if (!IS_ERR(priv->pinctrl)) {
+		struct pinctrl_state *s;
+
+		s = pinctrl_lookup_state(priv->pinctrl, PINCTRL_STATE_DEFAULT);
+		if (!IS_ERR(s))
+			pinctrl_select_state(priv->pinctrl, s);
+	}
+
 	return 0;
 }
 
@@ -611,6 +621,16 @@ static void c_can_stop(struct net_device *dev)
 	struct c_can_priv *priv = netdev_priv(dev);
 
 	c_can_irq_control(priv, false);
+
+	/* deactivate pins */
+	if (!IS_ERR(priv->pinctrl)) {
+		struct pinctrl_state *s;
+
+		s = pinctrl_lookup_state(priv->pinctrl, PINCTRL_STATE_SLEEP);
+		if (!IS_ERR(s))
+			pinctrl_select_state(priv->pinctrl, s);
+	}
+
 	priv->can.state = CAN_STATE_STOPPED;
 }
 
diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_can.h
index c6715ca..3cedf48 100644
--- a/drivers/net/can/c_can/c_can.h
+++ b/drivers/net/can/c_can/c_can.h
@@ -210,6 +210,7 @@ struct c_can_priv {
 	u32 comm_rcv_high;
 	u32 rxmasked;
 	u32 dlc[C_CAN_MSG_OBJ_TX_NUM];
+	struct pinctrl *pinctrl;
 };
 
 struct net_device *alloc_c_can_dev(void);
diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index b838c6b..71b9063 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -34,6 +34,7 @@
 #include <linux/of_device.h>
 #include <linux/mfd/syscon.h>
 #include <linux/regmap.h>
+#include <linux/pinctrl/consumer.h>
 
 #include <linux/can/dev.h>
 
@@ -230,6 +231,7 @@ static int c_can_plat_probe(struct platform_device *pdev)
 	struct clk *clk;
 	const struct c_can_driver_data *drvdata;
 	struct device_node *np = pdev->dev.of_node;
+	struct pinctrl *pinctrl;
 
 	match = of_match_device(c_can_of_table, &pdev->dev);
 	if (match) {
@@ -241,6 +243,23 @@ static int c_can_plat_probe(struct platform_device *pdev)
 		return -ENODEV;
 	}
 
+	pinctrl = devm_pinctrl_get(&pdev->dev);
+	if (!IS_ERR(pinctrl)) {
+		struct pinctrl_state *s;
+
+		/* Deactivate pins to prevent DRA7 DCAN IP from being
+		 * stuck in transition when module is disabled.
+		 * Pins are activated in c_can_start() and deactivated
+		 * in c_can_stop()
+		 */
+		s = pinctrl_lookup_state(pinctrl, PINCTRL_STATE_SLEEP);
+		if (!IS_ERR(s))
+			pinctrl_select_state(pinctrl, s);
+	} else {
+		dev_warn(&pdev->dev,
+			 "failed to get pinctrl\n");
+	}
+
 	/* get the appropriate clk */
 	clk = devm_clk_get(&pdev->dev, NULL);
 	if (IS_ERR(clk)) {
@@ -270,6 +289,7 @@ static int c_can_plat_probe(struct platform_device *pdev)
 	}
 
 	priv = netdev_priv(dev);
+	priv->pinctrl = pinctrl;
 
 	switch (drvdata->id) {
 	case BOSCH_C_CAN:
-- 
1.8.3.2


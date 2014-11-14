From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH v7 6/8] net: can: c_can: Disable pins when CAN interface is
 down
Date: Fri, 14 Nov 2014 17:40:13 +0200
Message-ID: <5466225D.2070202@ti.com>
References: <1415371762-29885-1-git-send-email-rogerq@ti.com> <1415371762-29885-7-git-send-email-rogerq@ti.com> <5464CCFF.5010004@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <wsa@the-dreams.de>, <tony@atomide.com>, <tglx@linutronix.de>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <balbi@ti.com>,
	<nsekhar@ti.com>, <nm@ti.com>,
	<sergei.shtylyov@cogentembedded.com>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	Roger Quadros <rogerq@ti.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5464CCFF.5010004@ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DRA7 CAN IP suffers from a problem which causes it to be prevented
from fully turning OFF (i.e. stuck in transition) if the module was
disabled while there was traffic on the CAN_RX line.

To work around this issue we select the SLEEP pin state by default
on probe and use the DEFAULT pin state on CAN up and back to the
SLEEP pin state on CAN down.

Signed-off-by: Roger Quadros <rogerq@ti.com>
---
 drivers/net/can/c_can/c_can.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 8e78bb4..f94a9fa 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -35,6 +35,7 @@
 #include <linux/list.h>
 #include <linux/io.h>
 #include <linux/pm_runtime.h>
+#include <linux/pinctrl/consumer.h>
 
 #include <linux/can.h>
 #include <linux/can/dev.h>
@@ -603,6 +604,8 @@ static int c_can_start(struct net_device *dev)
 
 	priv->can.state = CAN_STATE_ERROR_ACTIVE;
 
+	/* activate pins */
+	pinctrl_pm_select_default_state(dev->dev.parent);
 	return 0;
 }
 
@@ -611,6 +614,9 @@ static void c_can_stop(struct net_device *dev)
 	struct c_can_priv *priv = netdev_priv(dev);
 
 	c_can_irq_control(priv, false);
+
+	/* deactivate pins */
+	pinctrl_pm_select_sleep_state(dev->dev.parent);
 	priv->can.state = CAN_STATE_STOPPED;
 }
 
@@ -1244,6 +1250,13 @@ int register_c_can_dev(struct net_device *dev)
 	struct c_can_priv *priv = netdev_priv(dev);
 	int err;
 
+	/* Deactivate pins to prevent DRA7 DCAN IP from being
+	 * stuck in transition when module is disabled.
+	 * Pins are activated in c_can_start() and deactivated
+	 * in c_can_stop()
+	 */
+	pinctrl_pm_select_sleep_state(dev->dev.parent);
+
 	c_can_pm_runtime_enable(priv);
 
 	dev->flags |= IFF_ECHO;	/* we support local echo */
-- 
1.8.3.2



From: Franklin S Cooper Jr <fcooper@ti.com>
Subject: [PATCH 1/4] can: dev: Add support for limiting configured bitrate
Date: Wed, 19 Jul 2017 18:36:51 -0500
Message-ID: <20170719233654.25908-2-fcooper@ti.com>
References: <20170719233654.25908-1-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Franklin S Cooper Jr <fcooper@ti.com>
To: <linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-can@vger.kernel.org>,
        <wg@grandegger.com>, <mkl@pengutronix.de>, <robh+dt@kernel.org>,
        <quentin.schulz@free-electrons.com>,
        <dev.kurt@vandijck-laurijssen.be>, <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170719233654.25908-1-fcooper@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Various CAN or CAN-FD IP may be able to run at a faster rate than
what the transceiver the CAN node is connected to. This can lead to
unexpected errors. However, CAN transceivers typically have fixed
limitations and provide no means to discover these limitations at
runtime. Therefore, add support for a fixed-transceiver node that
can be reused by other CAN peripheral drivers to determine for both
CAN and CAN-FD what the max bitrate that can be used. If the user
tries to configure CAN to pass these maximum bitrates it will throw
an error.

Signed-off-by: Franklin S Cooper Jr <fcooper@ti.com>
---
 drivers/net/can/dev.c   | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/can/dev.h |  5 +++++
 2 files changed, 53 insertions(+)

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index 365a8cc..fbab87d 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -27,6 +27,7 @@
 #include <linux/can/skb.h>
 #include <linux/can/netlink.h>
 #include <linux/can/led.h>
+#include <linux/of.h>
 #include <net/rtnetlink.h>
 
 #define MOD_DESC "CAN device driver interface"
@@ -806,6 +807,21 @@ int open_candev(struct net_device *dev)
 		return -EINVAL;
 	}
 
+	if (priv->max_trans_arbitration_speed > 0 &&
+	    priv->bittiming.bitrate > priv->max_trans_arbitration_speed) {
+		netdev_err(dev, "arbitration bitrate surpasses transceiver capabilities of %d bps\n",
+			   priv->max_trans_arbitration_speed);
+		return -EINVAL;
+	}
+
+	if (priv->max_trans_data_speed  >= 0 &&
+	    (priv->ctrlmode & CAN_CTRLMODE_FD) &&
+	    (priv->data_bittiming.bitrate > priv->max_trans_data_speed)) {
+		netdev_err(dev, "canfd data bitrate surpasses transceiver capabilities of %d bps\n",
+			   priv->max_trans_data_speed);
+		return -EINVAL;
+	}
+
 	/* Switch carrier on if device was stopped while in bus-off state */
 	if (!netif_carrier_ok(dev))
 		netif_carrier_on(dev);
@@ -814,6 +830,38 @@ int open_candev(struct net_device *dev)
 }
 EXPORT_SYMBOL_GPL(open_candev);
 
+#ifdef CONFIG_OF
+void of_transceiver_is_fixed(struct net_device *dev)
+{
+	struct device_node *dn;
+	struct can_priv *priv = netdev_priv(dev);
+	u32 max_frequency;
+	struct device_node *np;
+
+	np = dev->dev.parent->of_node;
+
+	/* New binding */
+	dn = of_get_child_by_name(np, "fixed-transceiver");
+	if (!dn)
+		return;
+
+	of_property_read_u32(dn, "max-arbitration-speed", &max_frequency);
+
+	if (max_frequency > 0)
+		priv->max_trans_arbitration_speed = max_frequency;
+	else
+		priv->max_trans_arbitration_speed = -1;
+
+	of_property_read_u32(dn, "max-data-speed", &max_frequency);
+
+	if (max_frequency >= 0)
+		priv->max_trans_data_speed = max_frequency;
+	else
+		priv->max_trans_data_speed = -1;
+}
+EXPORT_SYMBOL(of_transceiver_is_fixed);
+#endif
+
 /*
  * Common close function for cleanup before the device gets closed.
  *
diff --git a/include/linux/can/dev.h b/include/linux/can/dev.h
index 141b05a..aec72b5 100644
--- a/include/linux/can/dev.h
+++ b/include/linux/can/dev.h
@@ -69,6 +69,9 @@ struct can_priv {
 	unsigned int echo_skb_max;
 	struct sk_buff **echo_skb;
 
+	unsigned int max_trans_arbitration_speed;
+	unsigned int max_trans_data_speed;
+
 #ifdef CONFIG_CAN_LEDS
 	struct led_trigger *tx_led_trig;
 	char tx_led_trig_name[CAN_LED_NAME_SZ];
@@ -165,6 +168,8 @@ void can_put_echo_skb(struct sk_buff *skb, struct net_device *dev,
 unsigned int can_get_echo_skb(struct net_device *dev, unsigned int idx);
 void can_free_echo_skb(struct net_device *dev, unsigned int idx);
 
+void of_transceiver_is_fixed(struct net_device *dev);
+
 struct sk_buff *alloc_can_skb(struct net_device *dev, struct can_frame **cf);
 struct sk_buff *alloc_canfd_skb(struct net_device *dev,
 				struct canfd_frame **cfd);
-- 
2.10.0

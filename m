From: Franklin S Cooper Jr <fcooper@ti.com>
Subject: [PATCH v3 1/4] can: dev: Add support for limiting configured bitrate
Date: Wed, 2 Aug 2017 19:51:47 -0500
Message-ID: <20170803005150.9286-2-fcooper@ti.com>
References: <20170803005150.9286-1-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Franklin S Cooper Jr <fcooper@ti.com>
To: <linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-can@vger.kernel.org>,
        <wg@grandegger.com>, <mkl@pengutronix.de>, <robh+dt@kernel.org>,
        <quentin.schulz@free-electrons.com>,
        <dev.kurt@vandijck-laurijssen.be>, <andrew@lunn.ch>,
        <sergei.shtylyov@cogentembedded.com>, <socketcan@hartkopp.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170803005150.9286-1-fcooper@ti.com>
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
 drivers/net/can/dev.c   | 50 +++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/can/dev.h |  5 +++++
 2 files changed, 55 insertions(+)

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index 365a8cc..db56914 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -27,6 +27,7 @@
 #include <linux/can/skb.h>
 #include <linux/can/netlink.h>
 #include <linux/can/led.h>
+#include <linux/of.h>
 #include <net/rtnetlink.h>
 
 #define MOD_DESC "CAN device driver interface"
@@ -814,6 +815,39 @@ int open_candev(struct net_device *dev)
 }
 EXPORT_SYMBOL_GPL(open_candev);
 
+#ifdef CONFIG_OF
+/*
+ * Common function that can be used to understand the limitation of
+ * a transceiver when it provides no means to determine these limitations
+ * at runtime.
+ */
+void of_can_transceiver_fixed(struct net_device *dev)
+{
+	struct device_node *dn;
+	struct can_priv *priv = netdev_priv(dev);
+	struct device_node *np;
+	unsigned int max_bitrate;
+	int ret;
+
+	np = dev->dev.parent->of_node;
+
+	dn = of_get_child_by_name(np, "fixed-transceiver");
+	if (!dn)
+		return;
+
+	max_bitrate = 0;
+	ret = of_property_read_u32(dn, "max-bitrate", &max_bitrate);
+
+	if (max_bitrate > 0) {
+		priv->max_bitrate = max_bitrate;
+		priv->is_bitrate_limited = true;
+	} else if (ret != -EINVAL) {
+		netdev_warn(dev, "Invalid value for transceiver max bitrate\n");
+	}
+}
+EXPORT_SYMBOL(of_can_transceiver_fixed);
+#endif
+
 /*
  * Common close function for cleanup before the device gets closed.
  *
@@ -913,6 +947,14 @@ static int can_changelink(struct net_device *dev, struct nlattr *tb[],
 					priv->bitrate_const_cnt);
 		if (err)
 			return err;
+
+		if (priv->is_bitrate_limited &&
+		    bt.bitrate > priv->max_bitrate) {
+			netdev_err(dev, "arbitration bitrate surpasses transceiver capabilities of %d bps\n",
+				   priv->max_bitrate);
+			return -EINVAL;
+		}
+
 		memcpy(&priv->bittiming, &bt, sizeof(bt));
 
 		if (priv->do_set_bittiming) {
@@ -997,6 +1039,14 @@ static int can_changelink(struct net_device *dev, struct nlattr *tb[],
 					priv->data_bitrate_const_cnt);
 		if (err)
 			return err;
+
+		if (priv->is_bitrate_limited &&
+		    dbt.bitrate > priv->max_bitrate) {
+			netdev_err(dev, "canfd data bitrate surpasses transceiver capabilities of %d bps\n",
+				   priv->max_bitrate);
+			return -EINVAL;
+		}
+
 		memcpy(&priv->data_bittiming, &dbt, sizeof(dbt));
 
 		if (priv->do_set_data_bittiming) {
diff --git a/include/linux/can/dev.h b/include/linux/can/dev.h
index 141b05a..a6e62df 100644
--- a/include/linux/can/dev.h
+++ b/include/linux/can/dev.h
@@ -47,6 +47,9 @@ struct can_priv {
 	unsigned int data_bitrate_const_cnt;
 	struct can_clock clock;
 
+	unsigned int max_bitrate;
+	bool is_bitrate_limited;
+
 	enum can_state state;
 
 	/* CAN controller features - see include/uapi/linux/can/netlink.h */
@@ -165,6 +168,8 @@ void can_put_echo_skb(struct sk_buff *skb, struct net_device *dev,
 unsigned int can_get_echo_skb(struct net_device *dev, unsigned int idx);
 void can_free_echo_skb(struct net_device *dev, unsigned int idx);
 
+void of_can_transceiver_fixed(struct net_device *dev);
+
 struct sk_buff *alloc_can_skb(struct net_device *dev, struct can_frame **cf);
 struct sk_buff *alloc_canfd_skb(struct net_device *dev,
 				struct canfd_frame **cfd);
-- 
2.9.4.dirty

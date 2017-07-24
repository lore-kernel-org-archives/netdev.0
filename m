From: Franklin S Cooper Jr <fcooper@ti.com>
Subject: [PATCH v2 1/4] can: dev: Add support for limiting configured bitrate
Date: Mon, 24 Jul 2017 18:05:18 -0500
Message-ID: <20170724230521.1436-2-fcooper@ti.com>
References: <20170724230521.1436-1-fcooper@ti.com>
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
In-Reply-To: <20170724230521.1436-1-fcooper@ti.com>
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
Version 2 changes:
Rename new function to of_can_transceiver_fixed
Use version of of_property_read that supports signed/negative values
Return error when user tries to use CAN-FD if the transceiver doesn't
support it (max-data-speed = -1).

 drivers/net/can/dev.c   | 59 +++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/can/dev.h |  5 +++++
 2 files changed, 64 insertions(+)

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index 365a8cc..c046631 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -27,6 +27,7 @@
 #include <linux/can/skb.h>
 #include <linux/can/netlink.h>
 #include <linux/can/led.h>
+#include <linux/of.h>
 #include <net/rtnetlink.h>
 
 #define MOD_DESC "CAN device driver interface"
@@ -814,6 +815,41 @@ int open_candev(struct net_device *dev)
 }
 EXPORT_SYMBOL_GPL(open_candev);
 
+#ifdef CONFIG_OF
+void of_can_transceiver_fixed(struct net_device *dev)
+{
+	struct device_node *dn;
+	struct can_priv *priv = netdev_priv(dev);
+	int max_frequency;
+	struct device_node *np;
+
+	np = dev->dev.parent->of_node;
+
+	dn = of_get_child_by_name(np, "fixed-transceiver");
+	if (!dn)
+		return;
+
+	/* Value of 0 implies ignore max speed constraint */
+	max_frequency = 0;
+	of_property_read_s32(dn, "max-arbitration-speed", &max_frequency);
+
+	if (max_frequency >= 0)
+		priv->max_trans_arbitration_speed = max_frequency;
+	else
+		priv->max_trans_arbitration_speed = 0;
+
+	max_frequency = 0;
+
+	of_property_read_s32(dn, "max-data-speed", &max_frequency);
+
+	if (max_frequency >= -1)
+		priv->max_trans_data_speed = max_frequency;
+	else
+		priv->max_trans_data_speed = 0;
+}
+EXPORT_SYMBOL(of_can_transceiver_fixed);
+#endif
+
 /*
  * Common close function for cleanup before the device gets closed.
  *
@@ -913,6 +949,14 @@ static int can_changelink(struct net_device *dev, struct nlattr *tb[],
 					priv->bitrate_const_cnt);
 		if (err)
 			return err;
+
+		if (priv->max_trans_arbitration_speed > 0 &&
+		    bt.bitrate > priv->max_trans_arbitration_speed) {
+			netdev_err(dev, "arbitration bitrate surpasses transceiver capabilities of %d bps\n",
+				   priv->max_trans_arbitration_speed);
+			return -EINVAL;
+		}
+
 		memcpy(&priv->bittiming, &bt, sizeof(bt));
 
 		if (priv->do_set_bittiming) {
@@ -989,6 +1033,12 @@ static int can_changelink(struct net_device *dev, struct nlattr *tb[],
 		if (!priv->data_bittiming_const && !priv->do_set_data_bittiming)
 			return -EOPNOTSUPP;
 
+		if ((priv->ctrlmode & CAN_CTRLMODE_FD) &&
+		    priv->max_trans_data_speed == -1) {
+			netdev_err(dev, "canfd mode is not supported by transceiver\n");
+			return -EINVAL;
+		}
+
 		memcpy(&dbt, nla_data(data[IFLA_CAN_DATA_BITTIMING]),
 		       sizeof(dbt));
 		err = can_get_bittiming(dev, &dbt,
@@ -997,6 +1047,15 @@ static int can_changelink(struct net_device *dev, struct nlattr *tb[],
 					priv->data_bitrate_const_cnt);
 		if (err)
 			return err;
+
+		if (priv->max_trans_data_speed  > 0 &&
+		    (priv->ctrlmode & CAN_CTRLMODE_FD) &&
+		    (dbt.bitrate > priv->max_trans_data_speed)) {
+			netdev_err(dev, "canfd data bitrate surpasses transceiver capabilities of %d bps\n",
+				   priv->max_trans_data_speed);
+			return -EINVAL;
+		}
+
 		memcpy(&priv->data_bittiming, &dbt, sizeof(dbt));
 
 		if (priv->do_set_data_bittiming) {
diff --git a/include/linux/can/dev.h b/include/linux/can/dev.h
index 141b05a..926fc7e 100644
--- a/include/linux/can/dev.h
+++ b/include/linux/can/dev.h
@@ -47,6 +47,9 @@ struct can_priv {
 	unsigned int data_bitrate_const_cnt;
 	struct can_clock clock;
 
+	int max_trans_arbitration_speed;
+	int max_trans_data_speed;
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
2.10.0

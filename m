From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] can: dev: fix deadlock reported after bus-off
Date: Thu, 22 Sep 2016 14:42:22 +0200
Message-ID: <20160922124222.31598-2-mkl@pengutronix.de>
References: <20160922124222.31598-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de,
        Sergei Miroshnichenko <sergeimir@emcraft.com>,
        linux-stable <stable@vger.kernel.org>,
        Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20160922124222.31598-1-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Miroshnichenko <sergeimir@emcraft.com>

A timer was used to restart after the bus-off state, leading to a
relatively large can_restart() executed in an interrupt context,
which in turn sets up pinctrl. When this happens during system boot,
there is a high probability of grabbing the pinctrl_list_mutex,
which is locked already by the probe() of other device, making the
kernel suspect a deadlock condition [1].

To resolve this issue, the restart_timer is replaced by a delayed
work.

[1] https://github.com/victronenergy/venus/issues/24

Signed-off-by: Sergei Miroshnichenko <sergeimir@emcraft.com>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/dev.c   | 27 +++++++++++++++++----------
 include/linux/can/dev.h |  3 ++-
 2 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index e21f7cc5ae4d..8d6208c0b400 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -21,6 +21,7 @@
 #include <linux/slab.h>
 #include <linux/netdevice.h>
 #include <linux/if_arp.h>
+#include <linux/workqueue.h>
 #include <linux/can.h>
 #include <linux/can/dev.h>
 #include <linux/can/skb.h>
@@ -501,9 +502,8 @@ EXPORT_SYMBOL_GPL(can_free_echo_skb);
 /*
  * CAN device restart for bus-off recovery
  */
-static void can_restart(unsigned long data)
+static void can_restart(struct net_device *dev)
 {
-	struct net_device *dev = (struct net_device *)data;
 	struct can_priv *priv = netdev_priv(dev);
 	struct net_device_stats *stats = &dev->stats;
 	struct sk_buff *skb;
@@ -543,6 +543,14 @@ restart:
 		netdev_err(dev, "Error %d during restart", err);
 }
 
+static void can_restart_work(struct work_struct *work)
+{
+	struct delayed_work *dwork = to_delayed_work(work);
+	struct can_priv *priv = container_of(dwork, struct can_priv, restart_work);
+
+	can_restart(priv->dev);
+}
+
 int can_restart_now(struct net_device *dev)
 {
 	struct can_priv *priv = netdev_priv(dev);
@@ -556,8 +564,8 @@ int can_restart_now(struct net_device *dev)
 	if (priv->state != CAN_STATE_BUS_OFF)
 		return -EBUSY;
 
-	/* Runs as soon as possible in the timer context */
-	mod_timer(&priv->restart_timer, jiffies);
+	cancel_delayed_work_sync(&priv->restart_work);
+	can_restart(dev);
 
 	return 0;
 }
@@ -578,8 +586,8 @@ void can_bus_off(struct net_device *dev)
 	netif_carrier_off(dev);
 
 	if (priv->restart_ms)
-		mod_timer(&priv->restart_timer,
-			  jiffies + (priv->restart_ms * HZ) / 1000);
+		schedule_delayed_work(&priv->restart_work,
+				      msecs_to_jiffies(priv->restart_ms));
 }
 EXPORT_SYMBOL_GPL(can_bus_off);
 
@@ -688,6 +696,7 @@ struct net_device *alloc_candev(int sizeof_priv, unsigned int echo_skb_max)
 		return NULL;
 
 	priv = netdev_priv(dev);
+	priv->dev = dev;
 
 	if (echo_skb_max) {
 		priv->echo_skb_max = echo_skb_max;
@@ -697,7 +706,7 @@ struct net_device *alloc_candev(int sizeof_priv, unsigned int echo_skb_max)
 
 	priv->state = CAN_STATE_STOPPED;
 
-	init_timer(&priv->restart_timer);
+	INIT_DELAYED_WORK(&priv->restart_work, can_restart_work);
 
 	return dev;
 }
@@ -778,8 +787,6 @@ int open_candev(struct net_device *dev)
 	if (!netif_carrier_ok(dev))
 		netif_carrier_on(dev);
 
-	setup_timer(&priv->restart_timer, can_restart, (unsigned long)dev);
-
 	return 0;
 }
 EXPORT_SYMBOL_GPL(open_candev);
@@ -794,7 +801,7 @@ void close_candev(struct net_device *dev)
 {
 	struct can_priv *priv = netdev_priv(dev);
 
-	del_timer_sync(&priv->restart_timer);
+	cancel_delayed_work_sync(&priv->restart_work);
 	can_flush_echo_skb(dev);
 }
 EXPORT_SYMBOL_GPL(close_candev);
diff --git a/include/linux/can/dev.h b/include/linux/can/dev.h
index 5261751f6bd4..5f5270941ba0 100644
--- a/include/linux/can/dev.h
+++ b/include/linux/can/dev.h
@@ -32,6 +32,7 @@ enum can_mode {
  * CAN common private data
  */
 struct can_priv {
+	struct net_device *dev;
 	struct can_device_stats can_stats;
 
 	struct can_bittiming bittiming, data_bittiming;
@@ -47,7 +48,7 @@ struct can_priv {
 	u32 ctrlmode_static;	/* static enabled options for driver/hardware */
 
 	int restart_ms;
-	struct timer_list restart_timer;
+	struct delayed_work restart_work;
 
 	int (*do_set_bittiming)(struct net_device *dev);
 	int (*do_set_data_bittiming)(struct net_device *dev);
-- 
2.9.3


From: akpm@osdl.org
Subject: [patch 02/10] net: Netconsole poll support for 3c509
Date: Tue, 04 Jan 2005 21:59:27 -0800
Message-ID: <200501050559.j055xa614669@mail.osdl.org>
Cc: davem@davemloft.net, netdev@oss.sgi.com, akpm@osdl.org, kernel@kolivas.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Con Kolivas <kernel@kolivas.org>

This patch provides poll support to allow netconsole to work with 3c509
network cards.

Status: Compiled, debugged and tested working by Michael Buesch.

Signed-off-by: Con Kolivas <kernel@kolivas.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/3c509.c |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+)

diff -puN drivers/net/3c509.c~net-netconsole-poll-support-for-3c509 drivers/net/3c509.c
--- 25/drivers/net/3c509.c~net-netconsole-poll-support-for-3c509	2005-01-04 21:57:35.537731728 -0800
+++ 25-akpm/drivers/net/3c509.c	2005-01-04 21:57:35.542730968 -0800
@@ -209,6 +209,9 @@ static int el3_pm_callback(struct pm_dev
 #if defined(CONFIG_EISA) || defined(CONFIG_MCA)
 static int el3_device_remove (struct device *device);
 #endif
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void el3_poll_controller(struct net_device *dev);
+#endif
 
 #ifdef CONFIG_EISA
 struct eisa_device_id el3_eisa_ids[] = {
@@ -321,6 +324,9 @@ static int __init el3_common_init(struct
 	dev->set_multicast_list = &set_multicast_list;
 	dev->tx_timeout = el3_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = el3_poll_controller;
+#endif
 	SET_ETHTOOL_OPS(dev, &ethtool_ops);
 
 	err = register_netdev(dev);
@@ -999,6 +1005,19 @@ el3_interrupt(int irq, void *dev_id, str
 }
 
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/*
+ * Polling receive - used by netconsole and other diagnostic tools
+ * to allow network i/o with interrupts disabled.
+ */
+static void el3_poll_controller(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	el3_interrupt(dev->irq, dev, NULL);
+	enable_irq(dev->irq);
+}
+#endif
+
 static struct net_device_stats *
 el3_get_stats(struct net_device *dev)
 {
_

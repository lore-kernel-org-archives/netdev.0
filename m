From: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
Subject: [PATCH v3 2/3] Packet sniffer core framework
Date: Mon, 23 Feb 2015 14:26:21 +0000
Message-ID: <3f43e4376bec64ded755e202c11d2f07886194af.1424698609.git.stathis.voukelatos@linn.co.uk>
References: <cover.1424698609.git.stathis.voukelatos@linn.co.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<devicetree@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1424698609.git.stathis.voukelatos@linn.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The framework registers each backend sniffer channel as a netdev,
which can be accessed from user space through a raw packet socket.
Packets received from user space are treated as a command string
configuration. Each match event from the backend driver will
generate a packet with the matching bytes plus an optional
timestamp, if configured by the command string.

Signed-off-by: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
---
 MAINTAINERS                                        |   6 +
 drivers/net/ethernet/Kconfig                       |   1 +
 drivers/net/ethernet/Makefile                      |   1 +
 drivers/net/ethernet/linn/Kconfig                  |  25 ++
 drivers/net/ethernet/linn/Makefile                 |  19 ++
 .../net/ethernet/linn/pkt-sniffer/core/Makefile    |  20 ++
 .../net/ethernet/linn/pkt-sniffer/core/module.c    |  37 +++
 .../net/ethernet/linn/pkt-sniffer/core/netdev.c    | 254 +++++++++++++++++++++
 .../net/ethernet/linn/pkt-sniffer/core/snf_core.h  |  60 +++++
 9 files changed, 423 insertions(+)
 create mode 100644 drivers/net/ethernet/linn/Kconfig
 create mode 100644 drivers/net/ethernet/linn/Makefile
 create mode 100644 drivers/net/ethernet/linn/pkt-sniffer/core/Makefile
 create mode 100644 drivers/net/ethernet/linn/pkt-sniffer/core/module.c
 create mode 100644 drivers/net/ethernet/linn/pkt-sniffer/core/netdev.c
 create mode 100644 drivers/net/ethernet/linn/pkt-sniffer/core/snf_core.h

diff --git a/MAINTAINERS b/MAINTAINERS
index ddc5a8c..716b10c 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5835,6 +5835,12 @@ M:	Sasha Levin <sasha.levin@oracle.com>
 S:	Maintained
 F:	tools/lib/lockdep/
 
+LINN PACKET SNIFFER DRIVER
+M: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
+S: Maintained
+F: drivers/net/ethernet/linn/
+F: Documentation/devicetree/bindings/net/linn-ether-packet-sniffer.txt
+
 LINUX FOR IBM pSERIES (RS/6000)
 M:	Paul Mackerras <paulus@au.ibm.com>
 W:	http://www.ibm.com/linux/ltc/projects/ppc
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index eadcb05..ee4b3ed 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -103,6 +103,7 @@ config LANTIQ_ETOP
 	---help---
 	  Support for the MII0 inside the Lantiq SoC
 
+source "drivers/net/ethernet/linn/Kconfig"
 source "drivers/net/ethernet/marvell/Kconfig"
 source "drivers/net/ethernet/mellanox/Kconfig"
 source "drivers/net/ethernet/micrel/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 1367afc..f8071d3 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -38,6 +38,7 @@ obj-$(CONFIG_NET_VENDOR_HP) += hp/
 obj-$(CONFIG_NET_VENDOR_IBM) += ibm/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_NET_VENDOR_I825XX) += i825xx/
+obj-$(CONFIG_NET_VENDOR_LINN) += linn/
 obj-$(CONFIG_NET_VENDOR_XSCALE) += xscale/
 obj-$(CONFIG_IP1000) += icplus/
 obj-$(CONFIG_JME) += jme.o
diff --git a/drivers/net/ethernet/linn/Kconfig b/drivers/net/ethernet/linn/Kconfig
new file mode 100644
index 0000000..6654f4e
--- /dev/null
+++ b/drivers/net/ethernet/linn/Kconfig
@@ -0,0 +1,25 @@
+#
+# Linn device configuration
+#
+
+config NET_VENDOR_LINN
+	bool "Linn devices"
+	---help---
+	  Say Y to add support for Linn Products devices.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Linn devices. If you say Y, you will be asked for
+	  your specific device in the following questions.
+
+if NET_VENDOR_LINN
+
+menuconfig PKT_SNIFFER
+    tristate "Packet sniffer support"
+    ---help---
+    Say Y to add support for the packet sniffer driver framework.
+
+    The core driver can also be built as a module. If so, the module
+    will be called snf_core.
+
+endif # NET_VENDOR_LINN
diff --git a/drivers/net/ethernet/linn/Makefile b/drivers/net/ethernet/linn/Makefile
new file mode 100644
index 0000000..f3338f3
--- /dev/null
+++ b/drivers/net/ethernet/linn/Makefile
@@ -0,0 +1,19 @@
+###############################################################################
+# Makefile for the Linn Products device drivers
+#
+# Copyright (C) 2015 Linn Products Ltd
+#
+# This program is free software; you can redistribute it and/or modify
+# it under the terms of the GNU General Public License version 2
+# as published by the Free Software Foundation.
+#
+# This program is distributed in the hope that it will be useful,
+# but WITHOUT ANY WARRANTY; without even the implied warranty of
+# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+# GNU General Public License for more details.
+#
+# Written by:
+# Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
+###############################################################################
+
+obj-$(CONFIG_PKT_SNIFFER) += pkt-sniffer/core/
diff --git a/drivers/net/ethernet/linn/pkt-sniffer/core/Makefile b/drivers/net/ethernet/linn/pkt-sniffer/core/Makefile
new file mode 100644
index 0000000..137db75
--- /dev/null
+++ b/drivers/net/ethernet/linn/pkt-sniffer/core/Makefile
@@ -0,0 +1,20 @@
+###############################################################################
+# Makefile for the Linn packet sniffer framework driver
+#
+# Copyright (C) 2015 Linn Products Ltd
+#
+# This program is free software; you can redistribute it and/or modify
+# it under the terms of the GNU General Public License version 2
+# as published by the Free Software Foundation.
+#
+# This program is distributed in the hope that it will be useful,
+# but WITHOUT ANY WARRANTY; without even the implied warranty of
+# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+# GNU General Public License for more details.
+#
+# Written by:
+# Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
+###############################################################################
+
+obj-$(CONFIG_PKT_SNIFFER) += snf_core.o
+snf_core-objs := netdev.o module.o
diff --git a/drivers/net/ethernet/linn/pkt-sniffer/core/module.c b/drivers/net/ethernet/linn/pkt-sniffer/core/module.c
new file mode 100644
index 0000000..1dbed1f
--- /dev/null
+++ b/drivers/net/ethernet/linn/pkt-sniffer/core/module.c
@@ -0,0 +1,37 @@
+/*
+ * Packet sniffer core driver:
+ *  - backend channel management
+ *  - interface to userland as a network I/F
+ *
+ * Copyright (C) 2015 Linn Products Ltd
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * Written by:
+ * Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
+ */
+#include <linux/module.h>
+#include <linux/init.h>
+
+static int __init snf_core_init(void)
+{
+	return 0;
+}
+
+static void __exit snf_core_cleanup(void)
+{
+}
+
+module_init(snf_core_init);
+module_exit(snf_core_cleanup);
+
+MODULE_LICENSE("GPL v2");
+MODULE_DESCRIPTION("Core packet sniffer driver");
+MODULE_AUTHOR("Linn Products Ltd");
diff --git a/drivers/net/ethernet/linn/pkt-sniffer/core/netdev.c b/drivers/net/ethernet/linn/pkt-sniffer/core/netdev.c
new file mode 100644
index 0000000..ba25cc0
--- /dev/null
+++ b/drivers/net/ethernet/linn/pkt-sniffer/core/netdev.c
@@ -0,0 +1,254 @@
+#include <linux/module.h>
+#include <linux/string.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/net_tstamp.h>
+#include <linux/if_arp.h>
+#include <linux/spinlock.h>
+#include "snf_core.h"
+
+struct snf_ndev_state {
+	struct snf_chan *chan;
+	bool rx_tstamp_enabled;
+	spinlock_t lock;
+};
+
+static int hw_timestamp_set(struct net_device *dev, struct ifreq *ifr)
+{
+	struct snf_ndev_state *priv = netdev_priv(dev);
+	struct hwtstamp_config tconf;
+
+	if (copy_from_user(&tconf, ifr->ifr_data, sizeof(tconf)))
+		return -EFAULT;
+
+	/* No TX timestamping supported.
+	 * This interface only receives packets from the sniffer backend
+	 */
+	if (tconf.tx_type != HWTSTAMP_TX_OFF)
+		return -ERANGE;
+
+	if (tconf.rx_filter != HWTSTAMP_FILTER_NONE) {
+		/* If timestamping is not enabled in the command string then
+		 * we cannot return any RX timestamps
+		 */
+		if (!priv->chan->ts_enabled(priv->chan))
+			return -ERANGE;
+		priv->rx_tstamp_enabled = true;
+		tconf.rx_filter = HWTSTAMP_FILTER_ALL;
+	} else {
+		priv->rx_tstamp_enabled = false;
+	}
+
+	return copy_to_user(ifr->ifr_data, &tconf, sizeof(tconf)) ? -EFAULT : 0;
+}
+
+static int hw_timestamp_get(struct net_device *dev, struct ifreq *ifr)
+{
+	struct snf_ndev_state *priv = netdev_priv(dev);
+	struct hwtstamp_config tconf;
+
+	memset(&tconf, 0, sizeof(tconf));
+	tconf.tx_type = HWTSTAMP_TX_OFF;
+	/* We also need to check here that the current command string
+	 * will cause timestamps to be generated
+	 */
+	tconf.rx_filter = (priv->rx_tstamp_enabled &&
+			   priv->chan->ts_enabled(priv->chan)) ?
+			   HWTSTAMP_FILTER_ALL : HWTSTAMP_FILTER_NONE;
+
+	return copy_to_user(ifr->ifr_data, &tconf, sizeof(tconf)) ? -EFAULT : 0;
+}
+
+static int snf_init(struct net_device *dev)
+{
+	struct snf_ndev_state *priv = netdev_priv(dev);
+
+	/* Two bytes per command string entry */
+	dev->mtu = priv->chan->max_ptn_entries(priv->chan) * 2;
+	return 0;
+}
+
+static int snf_open(struct net_device *dev)
+{
+	struct snf_ndev_state *priv = netdev_priv(dev);
+	unsigned long flags;
+	int ret;
+
+	spin_lock_irqsave(&priv->lock, flags);
+	ret = priv->chan->start(priv->chan);
+	spin_unlock_irqrestore(&priv->lock, flags);
+	return ret;
+}
+
+static int snf_stop(struct net_device *dev)
+{
+	struct snf_ndev_state *priv = netdev_priv(dev);
+	unsigned long flags;
+	int ret;
+
+	spin_lock_irqsave(&priv->lock, flags);
+	ret = priv->chan->stop(priv->chan);
+	spin_unlock_irqrestore(&priv->lock, flags);
+	return ret;
+}
+
+static int snf_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	switch (cmd) {
+	case SIOCSHWTSTAMP:
+		return hw_timestamp_set(dev, ifr);
+
+	case SIOCGHWTSTAMP:
+		return hw_timestamp_get(dev, ifr);
+
+	default:
+		return -EINVAL;
+	}
+}
+
+static int snf_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct snf_ndev_state *priv = netdev_priv(dev);
+	struct snf_chan *sch = priv->chan;
+	unsigned long flags;
+	int ret;
+
+	spin_lock_irqsave(&priv->lock, flags);
+	/* Stop the hardware */
+	sch->stop(sch);
+	/* Set the new command pattern */
+	ret = sch->set_pattern(sch, skb->data, skb->len / 2);
+	/* Restart the hardware */
+	sch->start(sch);
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	if (ret < 0) {
+		dev->stats.tx_dropped++;
+	} else {
+		dev->stats.tx_packets++;
+		dev->stats.tx_bytes += skb->len;
+	}
+
+	dev_kfree_skb(skb);
+	return NETDEV_TX_OK;
+}
+
+static const struct net_device_ops snf_netdev_ops = {
+	.ndo_init       = snf_init,
+	.ndo_open       = snf_open,
+	.ndo_stop       = snf_stop,
+	.ndo_start_xmit	= snf_start_xmit,
+	.ndo_do_ioctl   = snf_ioctl
+};
+
+static void snf_setup(struct net_device *dev)
+{
+	dev->netdev_ops   = &snf_netdev_ops;
+	dev->tx_queue_len = 1;
+	dev->flags        = IFF_NOARP;
+	dev->type         = ARPHRD_NONE;
+}
+
+/* Initialise netdev for a sniffer channel */
+int snf_channel_add(struct snf_chan *sch, const char *name)
+{
+	int ret;
+	struct net_device *ndev;
+	struct snf_ndev_state *priv;
+
+	ndev = alloc_netdev(sizeof(*priv), name, NET_NAME_UNKNOWN, snf_setup);
+	if (!ndev)
+		return -ENOMEM;
+
+	priv = netdev_priv(ndev);
+	priv->chan = sch;
+	priv->rx_tstamp_enabled = false;
+	spin_lock_init(&priv->lock);
+
+	ret = register_netdev(ndev);
+	if (ret < 0) {
+		free_netdev(ndev);
+		return ret;
+	}
+
+	sch->cstate = ndev;
+	return 0;
+}
+EXPORT_SYMBOL(snf_channel_add);
+
+/* Release netdev for a sniffer channel and free resources */
+int snf_channel_remove(struct snf_chan *sch)
+{
+	struct net_device *ndev = (struct net_device *)sch->cstate;
+
+	unregister_netdev(ndev);
+	free_netdev(ndev);
+	return 0;
+}
+EXPORT_SYMBOL(snf_channel_remove);
+
+/* Send a packet to user space for a sniffer match event */
+int snf_channel_notify_match(struct snf_chan *sch, struct snf_match_evt *mt)
+{
+	struct net_device *ndev = (struct net_device *)sch->cstate;
+	struct snf_ndev_state *priv = netdev_priv(ndev);
+	struct sk_buff *skb;
+	struct skb_shared_hwtstamps *skts;
+
+	skb = netdev_alloc_skb(ndev, mt->len);
+	if (!skb) {
+		ndev->stats.rx_dropped++;
+		return -ENOMEM;
+	}
+
+	skb_put(skb, mt->len);
+	skb_copy_to_linear_data(skb, mt->data, mt->len);
+	if (mt->ts_valid && priv->rx_tstamp_enabled) {
+		skts = skb_hwtstamps(skb);
+		skts->hwtstamp = ns_to_ktime(mt->ts);
+	}
+	ndev->stats.rx_packets++;
+	ndev->stats.rx_bytes += mt->len;
+	netif_rx(skb);
+	return 0;
+}
+EXPORT_SYMBOL(snf_channel_notify_match);
+
+/* Suspend the interface */
+int snf_channel_suspend(struct snf_chan *sch)
+{
+	struct net_device *ndev = (struct net_device *)sch->cstate;
+	struct snf_ndev_state *priv = netdev_priv(ndev);
+	unsigned long flags;
+	int ret;
+
+	if (!netif_running(ndev))
+		return 0;
+
+	spin_lock_irqsave(&priv->lock, flags);
+	ret = sch->stop(sch);
+	spin_unlock_irqrestore(&priv->lock, flags);
+	netif_device_detach(ndev);
+	return ret;
+}
+EXPORT_SYMBOL(snf_channel_suspend);
+
+/* Resume the interface */
+int snf_channel_resume(struct snf_chan *sch)
+{
+	struct net_device *ndev = (struct net_device *)sch->cstate;
+	struct snf_ndev_state *priv = netdev_priv(ndev);
+	unsigned long flags;
+	int ret;
+
+	if (!netif_running(ndev))
+		return 0;
+
+	netif_device_attach(ndev);
+	spin_lock_irqsave(&priv->lock, flags);
+	ret = sch->start(sch);
+	spin_unlock_irqrestore(&priv->lock, flags);
+	return ret;
+}
+EXPORT_SYMBOL(snf_channel_resume);
+
diff --git a/drivers/net/ethernet/linn/pkt-sniffer/core/snf_core.h b/drivers/net/ethernet/linn/pkt-sniffer/core/snf_core.h
new file mode 100644
index 0000000..73a30ff
--- /dev/null
+++ b/drivers/net/ethernet/linn/pkt-sniffer/core/snf_core.h
@@ -0,0 +1,60 @@
+/*
+ * Packet sniffer core driver
+ * - this header provides the interface to specific backend packet
+ *   sniffer implementations
+ *
+ * Copyright (C) 2015 Linn Products Ltd
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * Written by:
+ * Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
+ */
+#ifndef __SNF_CORE_H
+#define __SNF_CORE_H
+
+#include <linux/types.h>
+
+/* This is a global maximum. Each backend will have its own limit */
+#define MAX_MATCH_BYTES 512
+
+/* Sniffer channel data structure */
+struct snf_chan {
+	int  (*start)(struct snf_chan *sch);
+	int  (*stop)(struct snf_chan *sch);
+	int  (*set_pattern)(struct snf_chan *sch, const u8 *pattern, int count);
+	int  (*max_ptn_entries)(struct snf_chan *sch);
+	int  (*ts_enabled)(struct snf_chan *sch);
+	void *cstate;
+};
+
+/* Data from a sniffer match event */
+struct snf_match_evt {
+	int ts_valid;     /* flag indicating if timestamp is present */
+	u64 ts;           /* timestamp value */
+	u8 data[MAX_MATCH_BYTES]; /* packet data bytes matched by sniffer */
+	int len;          /* number of valid bytes in the 'data' buffer */
+};
+
+/* Registers a sniffer channel */
+int snf_channel_add(struct snf_chan *sch, const char *name);
+
+/* Removes a sniffer channel */
+int snf_channel_remove(struct snf_chan *sch);
+
+/* Send a packet to user space for a sniffer match event */
+int snf_channel_notify_match(struct snf_chan *sch, struct snf_match_evt *mt);
+
+/* Suspend and resume operations */
+int snf_channel_suspend(struct snf_chan *sch);
+int snf_channel_resume(struct snf_chan *sch);
+
+#endif
+
-- 
1.9.1

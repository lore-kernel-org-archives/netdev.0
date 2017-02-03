From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 5/6] net: dsa: add switch notifier
Date: Fri,  3 Feb 2017 13:20:20 -0500
Message-ID: <20170203182021.14246-6-vivien.didelot@savoirfairelinux.com>
References: <20170203182021.14246-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, cphealy@gmail.com,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170203182021.14246-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a notifier block per DSA switch, registered against a notifier head
in the switch fabric they belong to.

This infrastructure will allow to propagate fabric-wide events such as
port bridging, VLAN configuration, etc. If a DSA switch driver cares
about cross-chip configuration, such events can be caught.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h  |  7 +++++++
 net/dsa/Makefile   |  1 +
 net/dsa/dsa.c      |  6 ++++++
 net/dsa/dsa2.c     |  6 ++++++
 net/dsa/dsa_priv.h |  4 ++++
 net/dsa/switch.c   | 53 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 77 insertions(+)
 create mode 100644 net/dsa/switch.c

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 2cb77e64d648..ac4ea7c3a102 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -13,6 +13,7 @@
 
 #include <linux/if_ether.h>
 #include <linux/list.h>
+#include <linux/notifier.h>
 #include <linux/timer.h>
 #include <linux/workqueue.h>
 #include <linux/of.h>
@@ -92,6 +93,9 @@ struct packet_type;
 struct dsa_switch_tree {
 	struct list_head	list;
 
+	/* Notifier chain for switch-wide events */
+	struct raw_notifier_head	nh;
+
 	/* Tree identifier */
 	u32 tree;
 
@@ -182,6 +186,9 @@ struct dsa_switch {
 	struct dsa_switch_tree	*dst;
 	int			index;
 
+	/* Listener for switch fabric events */
+	struct notifier_block	nb;
+
 	/*
 	 * Give the switch driver somewhere to hang its private data
 	 * structure.
diff --git a/net/dsa/Makefile b/net/dsa/Makefile
index a3380ed0e0be..72912982de3d 100644
--- a/net/dsa/Makefile
+++ b/net/dsa/Makefile
@@ -1,6 +1,7 @@
 # the core
 obj-$(CONFIG_NET_DSA) += dsa_core.o
 dsa_core-y += dsa.o slave.o dsa2.o
+dsa_core-y += dsa.o slave.o dsa2.o switch.o
 
 # tagging formats
 dsa_core-$(CONFIG_NET_DSA_TAG_BRCM) += tag_brcm.o
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index beb79ccf0f59..22e44f691ab9 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -275,6 +275,10 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	if (ret < 0)
 		return ret;
 
+	ret = dsa_switch_register_notifier(ds);
+	if (ret)
+		return ret;
+
 	if (ops->set_addr) {
 		ret = ops->set_addr(ds, dst->master_netdev->dev_addr);
 		if (ret < 0)
@@ -400,6 +404,8 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 
 	if (ds->slave_mii_bus && ds->ops->phy_read)
 		mdiobus_unregister(ds->slave_mii_bus);
+
+	dsa_switch_unregister_notifier(ds);
 }
 
 #ifdef CONFIG_PM_SLEEP
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 9f8cc26be9ea..1c546b6621ee 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -294,6 +294,10 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 	if (err < 0)
 		return err;
 
+	err = dsa_switch_register_notifier(ds);
+	if (err)
+		return err;
+
 	if (ds->ops->set_addr) {
 		err = ds->ops->set_addr(ds, dst->master_netdev->dev_addr);
 		if (err < 0)
@@ -364,6 +368,8 @@ static void dsa_ds_unapply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 
 	if (ds->slave_mii_bus && ds->ops->phy_read)
 		mdiobus_unregister(ds->slave_mii_bus);
+
+	dsa_switch_unregister_notifier(ds);
 }
 
 static int dsa_dst_apply(struct dsa_switch_tree *dst)
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 591a40aea9ca..0706a511244e 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -66,6 +66,10 @@ int dsa_slave_resume(struct net_device *slave_dev);
 int dsa_slave_register_notifier(void);
 void dsa_slave_unregister_notifier(void);
 
+/* switch.c */
+int dsa_switch_register_notifier(struct dsa_switch *ds);
+void dsa_switch_unregister_notifier(struct dsa_switch *ds);
+
 /* tag_dsa.c */
 extern const struct dsa_device_ops dsa_netdev_ops;
 
diff --git a/net/dsa/switch.c b/net/dsa/switch.c
new file mode 100644
index 000000000000..e22fa7633d03
--- /dev/null
+++ b/net/dsa/switch.c
@@ -0,0 +1,53 @@
+/*
+ * Handling of a single switch chip, part of a switch fabric
+ *
+ * Copyright (c) 2017 Vivien Didelot <vivien.didelot@savoirfairelinux.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/netdevice.h>
+#include <linux/notifier.h>
+#include <net/dsa.h>
+
+static int dsa_switch_event(struct notifier_block *nb,
+			    unsigned long event, void *info)
+{
+	struct dsa_switch *ds = container_of(nb, struct dsa_switch, nb);
+	int err;
+
+	switch (event) {
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
+
+	/* Non-switchdev operations cannot be rolled back. If a DSA driver
+	 * returns an error during the chained call, switch chips may be in an
+	 * inconsistent state.
+	 */
+	if (err)
+		dev_dbg(ds->dev, "breaking chain for DSA event %lu (%d)\n",
+			event, err);
+
+	return notifier_from_errno(err);
+}
+
+int dsa_switch_register_notifier(struct dsa_switch *ds)
+{
+	ds->nb.notifier_call = dsa_switch_event;
+
+	return raw_notifier_chain_register(&ds->dst->nh, &ds->nb);
+}
+
+void dsa_switch_unregister_notifier(struct dsa_switch *ds)
+{
+	int err;
+
+	err = raw_notifier_chain_unregister(&ds->dst->nh, &ds->nb);
+	if (err)
+		dev_err(ds->dev, "failed to unregister notifier (%d)\n", err);
+}
-- 
2.11.0

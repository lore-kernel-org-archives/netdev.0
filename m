From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 02/11] net: dsa: add debugfs interface
Date: Mon, 14 Aug 2017 18:22:33 -0400
Message-ID: <20170814222242.10643-3-vivien.didelot@savoirfairelinux.com>
References: <20170814222242.10643-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Maxime Hadjinlian <maxime@devialet.com>,
        Chris Healy <cphealy@gmail.com>,
        Maxim Uvarov <muvarov@gmail.com>,
        Stefan Eichenberger <eichest@gmail.com>,
        Jason Cobham <jcobham@questertangent.com>,
        Juergen Borleis <jbe@pengutronix.de>,
        Tobias Waldekranz <tobias@waldekranz.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170814222242.10643-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This commit adds a DEBUG_FS dependent DSA core file creating a generic
debug filesystem interface for the DSA switch devices.

The interface can be mounted with:

    # mount -t debugfs none /sys/kernel/debug

The dsa directory contains one directory per switch chip:

    # cd /sys/kernel/debug/dsa/
    # ls
    switch0  switch1 switch2

Each chip directory contains one directory per port:

    # ls -l switch0/
    drwxr-xr-x 2 root root 0 Jan  1 00:00 port0
    drwxr-xr-x 2 root root 0 Jan  1 00:00 port1
    drwxr-xr-x 2 root root 0 Jan  1 00:00 port2
    drwxr-xr-x 2 root root 0 Jan  1 00:00 port5
    drwxr-xr-x 2 root root 0 Jan  1 00:00 port6

Future patches will add entry files to these directories.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h  |   7 ++++
 net/dsa/Kconfig    |  14 +++++++
 net/dsa/Makefile   |   1 +
 net/dsa/debugfs.c  | 121 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/dsa/dsa.c      |   3 ++
 net/dsa/dsa2.c     |   4 ++
 net/dsa/dsa_priv.h |  13 ++++++
 net/dsa/legacy.c   |   4 ++
 8 files changed, 167 insertions(+)
 create mode 100644 net/dsa/debugfs.c

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 7f46b521313e..4ef5d38755d9 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -212,6 +212,13 @@ struct dsa_switch {
 	 */
 	void *priv;
 
+#ifdef CONFIG_NET_DSA_DEBUGFS
+	/*
+	 * Debugfs interface.
+	 */
+	struct dentry *debugfs_dir;
+#endif
+
 	/*
 	 * Configuration data for this switch.
 	 */
diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index cc5f8f971689..0f05a1e59dd2 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -15,6 +15,20 @@ config NET_DSA
 
 if NET_DSA
 
+config NET_DSA_DEBUGFS
+	bool "Distributed Switch Architecture debugfs interface"
+	depends on DEBUG_FS
+	---help---
+	  Enable creation of debugfs files for the DSA core.
+
+	  These debugfs files provide per-switch information, such as the tag
+	  protocol in use and ports connectivity. They also allow querying the
+	  hardware directly through the switch operations for debugging instead
+	  of going through the bridge, switchdev and DSA layers.
+
+	  This is also a way to inspect the stats and FDB, MDB or VLAN entries
+	  of CPU and DSA links, since they are not exposed to userspace.
+
 # tagging formats
 config NET_DSA_TAG_BRCM
 	bool
diff --git a/net/dsa/Makefile b/net/dsa/Makefile
index fcce25da937c..7f60c6dfaffb 100644
--- a/net/dsa/Makefile
+++ b/net/dsa/Makefile
@@ -1,6 +1,7 @@
 # the core
 obj-$(CONFIG_NET_DSA) += dsa_core.o
 dsa_core-y += dsa.o dsa2.o legacy.o port.o slave.o switch.o
+dsa_core-$(CONFIG_NET_DSA_DEBUGFS) += debugfs.o
 
 # tagging formats
 dsa_core-$(CONFIG_NET_DSA_TAG_BRCM) += tag_brcm.o
diff --git a/net/dsa/debugfs.c b/net/dsa/debugfs.c
new file mode 100644
index 000000000000..68caf5a2c0c3
--- /dev/null
+++ b/net/dsa/debugfs.c
@@ -0,0 +1,121 @@
+/*
+ * net/dsa/debugfs.c - DSA debugfs interface
+ * Copyright (c) 2017 Savoir-faire Linux, Inc.
+ *	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/debugfs.h>
+
+#include "dsa_priv.h"
+
+#define DSA_SWITCH_FMT	"switch%d"
+#define DSA_PORT_FMT	"port%d"
+
+/* DSA module debugfs directory */
+static struct dentry *dsa_debugfs_dir;
+
+static int dsa_debugfs_create_port(struct dsa_switch *ds, int port)
+{
+	struct dentry *dir;
+	char name[32];
+
+	snprintf(name, sizeof(name), DSA_PORT_FMT, port);
+
+	dir = debugfs_create_dir(name, ds->debugfs_dir);
+	if (IS_ERR_OR_NULL(dir))
+		return -EFAULT;
+
+	return 0;
+}
+
+static int dsa_debugfs_create_switch(struct dsa_switch *ds)
+{
+	char name[32];
+	int i;
+
+	/* skip if there is no debugfs support */
+	if (!dsa_debugfs_dir)
+		return 0;
+
+	snprintf(name, sizeof(name), DSA_SWITCH_FMT, ds->index);
+
+	ds->debugfs_dir = debugfs_create_dir(name, dsa_debugfs_dir);
+	if (IS_ERR_OR_NULL(ds->debugfs_dir))
+		return -EFAULT;
+
+	for (i = 0; i < ds->num_ports; i++) {
+		if (!ds->ports[i].dn)
+			continue;
+
+		err = dsa_debugfs_create_port(ds, i);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+static void dsa_debugfs_destroy_switch(struct dsa_switch *ds)
+{
+	/* handles NULL */
+	debugfs_remove_recursive(ds->debugfs_dir);
+}
+
+void dsa_debugfs_create_tree(struct dsa_switch_tree *dst)
+{
+	struct dsa_switch *ds;
+	int i, err;
+
+	WARN_ON(!dst->applied);
+
+	for (i = 0; i < DSA_MAX_SWITCHES; i++) {
+		ds = dst->ds[i];
+		if (!ds)
+			continue;
+
+		err = dsa_debugfs_create_switch(ds);
+		if (err) {
+			pr_warn("DSA: failed to create debugfs interface for switch %d (%d)\n",
+				ds->index, err);
+			dsa_debugfs_destroy_tree(dst);
+			break;
+		}
+	}
+}
+
+void dsa_debugfs_destroy_tree(struct dsa_switch_tree *dst)
+{
+	struct dsa_switch *ds;
+	int i;
+
+	for (i = 0; i < DSA_MAX_SWITCHES; i++) {
+		ds = dst->ds[i];
+		if (!ds)
+			continue;
+
+		dsa_debugfs_destroy_switch(ds);
+	}
+}
+
+void dsa_debugfs_create_module(void)
+{
+	dsa_debugfs_dir = debugfs_create_dir("dsa", NULL);
+	if (IS_ERR(dsa_debugfs_dir)) {
+		pr_warn("DSA: failed to create debugfs interface\n");
+		dsa_debugfs_dir = NULL;
+	}
+
+	if (dsa_debugfs_dir)
+		pr_info("DSA: debugfs interface created\n");
+}
+
+void dsa_debugfs_destroy_module(void)
+{
+	/* handles NULL */
+	debugfs_remove_recursive(dsa_debugfs_dir);
+}
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 99e38af85fc5..62e49ff6d737 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -308,12 +308,15 @@ static int __init dsa_init_module(void)
 
 	dev_add_pack(&dsa_pack_type);
 
+	dsa_debugfs_create_module();
+
 	return 0;
 }
 module_init(dsa_init_module);
 
 static void __exit dsa_cleanup_module(void)
 {
+	dsa_debugfs_destroy_module();
 	dsa_slave_unregister_notifier();
 	dev_remove_pack(&dsa_pack_type);
 	dsa_legacy_unregister();
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index cceaa4dd9f53..5912618ad63d 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -447,6 +447,8 @@ static int dsa_dst_apply(struct dsa_switch_tree *dst)
 	dst->cpu_dp->netdev->dsa_ptr = dst;
 	dst->applied = true;
 
+	dsa_debugfs_create_tree(dst);
+
 	return 0;
 }
 
@@ -458,6 +460,8 @@ static void dsa_dst_unapply(struct dsa_switch_tree *dst)
 	if (!dst->applied)
 		return;
 
+	dsa_debugfs_destroy_tree(dst);
+
 	dst->cpu_dp->netdev->dsa_ptr = NULL;
 
 	/* If we used a tagging format that doesn't have an ethertype
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 9c3eeb72462d..84ca3a50a58b 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -93,6 +93,19 @@ struct dsa_slave_priv {
 	struct list_head	mall_tc_list;
 };
 
+/* debugfs.c */
+#ifdef CONFIG_NET_DSA_DEBUGFS
+void dsa_debugfs_create_module(void);
+void dsa_debugfs_destroy_module(void);
+void dsa_debugfs_create_tree(struct dsa_switch_tree *dst);
+void dsa_debugfs_destroy_tree(struct dsa_switch_tree *dst);
+#else
+static inline void dsa_debugfs_create_module(void) { }
+static inline void dsa_debugfs_destroy_module(void) { }
+static inline void dsa_debugfs_create_tree(struct dsa_switch_tree *dst) { }
+static inline void dsa_debugfs_destroy_tree(struct dsa_switch_tree *dst) { }
+#endif
+
 /* dsa.c */
 int dsa_cpu_dsa_setup(struct dsa_port *port);
 void dsa_cpu_dsa_destroy(struct dsa_port *dport);
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index a6a0849483d1..007034ebd218 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -607,6 +607,8 @@ static int dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 	dev->dsa_ptr = dst;
 	dst->applied = true;
 
+	dsa_debugfs_create_tree(dst);
+
 	return 0;
 }
 
@@ -672,6 +674,8 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
 {
 	int i;
 
+	dsa_debugfs_destroy_tree(dst);
+
 	dst->cpu_dp->netdev->dsa_ptr = NULL;
 
 	/* If we used a tagging format that doesn't have an ethertype
-- 
2.14.0

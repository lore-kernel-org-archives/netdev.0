From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH v2 net-next 4/8] net/ncsi: Add debugging infrastructurre
Date: Thu, 13 Apr 2017 17:48:17 +1000
Message-ID: <1492069701-20772-5-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1492069701-20772-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: joe@perches.com, davem@davemloft.net,
        Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:50188 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1756304AbdDMHuA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 03:50:00 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3D7nqUu092092
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 03:49:59 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29t2muduek-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 03:49:59 -0400
Received: from localhost
        by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 13 Apr 2017 17:49:28 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
        by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3D7nH6F51052694
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 17:49:25 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
        by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3D7mmcA013871
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 17:48:49 +1000
In-Reply-To: <1492069701-20772-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This creates debugfs directories as NCSI debugging infrastructure.
With the patch applied, We will see below debugfs directories. Every
NCSI package and channel has one corresponding directory. Other than
presenting the NCSI topology, No real function has been achieved
through these debugfs directories so far.

     /sys/kernel/debug/ncsi/eth0
     /sys/kernel/debug/ncsi/eth0/p0
     /sys/kernel/debug/ncsi/eth0/p0/c0
     /sys/kernel/debug/ncsi/eth0/p0/c1

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 net/ncsi/Kconfig       |  9 +++++
 net/ncsi/Makefile      |  1 +
 net/ncsi/internal.h    | 45 ++++++++++++++++++++++++
 net/ncsi/ncsi-debug.c  | 93 ++++++++++++++++++++++++++++++++++++++++++++++++++
 net/ncsi/ncsi-manage.c | 16 +++++++++
 5 files changed, 164 insertions(+)
 create mode 100644 net/ncsi/ncsi-debug.c

diff --git a/net/ncsi/Kconfig b/net/ncsi/Kconfig
index 08a8a60..baa42501 100644
--- a/net/ncsi/Kconfig
+++ b/net/ncsi/Kconfig
@@ -10,3 +10,12 @@ config NET_NCSI
 	  support. Enable this only if your system connects to a network
 	  device via NCSI and the ethernet driver you're using supports
 	  the protocol explicitly.
+
+config NET_NCSI_DEBUG
+	bool "Enable NCSI debugging"
+	depends on NET_NCSI && DEBUG_FS
+	default n
+	---help---
+	  This enables the interfaces (e.g. debugfs) for NCSI debugging purpose.
+
+	  If unsure, say Y.
diff --git a/net/ncsi/Makefile b/net/ncsi/Makefile
index dd12b56..2897fa0 100644
--- a/net/ncsi/Makefile
+++ b/net/ncsi/Makefile
@@ -2,3 +2,4 @@
 # Makefile for NCSI API
 #
 obj-$(CONFIG_NET_NCSI) += ncsi-cmd.o ncsi-rsp.o ncsi-aen.o ncsi-manage.o
+obj-$(CONFIG_NET_NCSI_DEBUG) += ncsi-debug.o
diff --git a/net/ncsi/internal.h b/net/ncsi/internal.h
index 1308a56..e9ede4f 100644
--- a/net/ncsi/internal.h
+++ b/net/ncsi/internal.h
@@ -198,6 +198,9 @@ struct ncsi_channel {
 	} monitor;
 	struct list_head            node;
 	struct list_head            link;
+#ifdef CONFIG_NET_NCSI_DEBUG
+	struct dentry               *dentry;    /* Debugfs directory    */
+#endif
 };
 
 struct ncsi_package {
@@ -208,6 +211,9 @@ struct ncsi_package {
 	unsigned int         channel_num; /* Number of channels     */
 	struct list_head     channels;    /* List of chanels        */
 	struct list_head     node;        /* Form list of packages  */
+#ifdef CONFIG_NET_NCSI_DEBUG
+	struct dentry        *dentry;     /* Debugfs directory       */
+#endif
 };
 
 struct ncsi_request {
@@ -276,6 +282,9 @@ struct ncsi_dev_priv {
 	struct work_struct  work;            /* For channel management     */
 	struct packet_type  ptype;           /* NCSI packet Rx handler     */
 	struct list_head    node;            /* Form NCSI device list      */
+#ifdef CONFIG_NET_NCSI_DEBUG
+	struct dentry       *dentry;         /* Procfs directory           */
+#endif
 };
 
 struct ncsi_cmd_arg {
@@ -337,4 +346,40 @@ int ncsi_rcv_rsp(struct sk_buff *skb, struct net_device *dev,
 		 struct packet_type *pt, struct net_device *orig_dev);
 int ncsi_aen_handler(struct ncsi_dev_priv *ndp, struct sk_buff *skb);
 
+/* Debugging functionality */
+#ifdef CONFIG_NET_NCSI_DEBUG
+int ncsi_dev_init_debug(struct ncsi_dev_priv *ndp);
+void ncsi_dev_release_debug(struct ncsi_dev_priv *ndp);
+int ncsi_package_init_debug(struct ncsi_package *np);
+void ncsi_package_release_debug(struct ncsi_package *np);
+int ncsi_channel_init_debug(struct ncsi_channel *nc);
+void ncsi_channel_release_debug(struct ncsi_channel *nc);
+#else
+static inline int ncsi_dev_init_debug(struct ncsi_dev_priv *ndp)
+{
+	return -ENOTTY;
+}
+
+static inline void ncsi_dev_release_debug(struct ncsi_dev_priv *ndp)
+{
+}
+
+static inline int ncsi_package_init_debug(struct ncsi_package *np)
+{
+	return -ENOTTY;
+}
+
+static inline void ncsi_package_release_debug(struct ncsi_package *np)
+{
+}
+
+static inline int ncsi_channel_init_debug(struct ncsi_channel *nc)
+{
+	return -ENOTTY;
+}
+
+static inline void ncsi_channel_release_debug(struct ncsi_channel *nc)
+{
+}
+#endif /* CONFIG_NET_NCSI_DEBUG */
 #endif /* __NCSI_INTERNAL_H__ */
diff --git a/net/ncsi/ncsi-debug.c b/net/ncsi/ncsi-debug.c
new file mode 100644
index 0000000..6c00e9b
--- /dev/null
+++ b/net/ncsi/ncsi-debug.c
@@ -0,0 +1,93 @@
+/*
+ * Copyright Gavin Shan, IBM Corporation 2017.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/atomic.h>
+#include <linux/netdevice.h>
+#include <linux/debugfs.h>
+#include <linux/skbuff.h>
+
+#include <net/ncsi.h>
+#include <net/net_namespace.h>
+#include <net/sock.h>
+
+#include "internal.h"
+#include "ncsi-pkt.h"
+
+static struct dentry *ncsi_dentry;
+
+int ncsi_dev_init_debug(struct ncsi_dev_priv *ndp)
+{
+	if (WARN_ON_ONCE(ndp->dentry))
+		return 0;
+
+	if (!ncsi_dentry) {
+		ncsi_dentry = debugfs_create_dir("ncsi", NULL);
+		if (!ncsi_dentry) {
+			pr_warn("NCSI: Cannot create /sys/kernel/debug/ncsi\n");
+			return -ENOENT;
+		}
+	}
+
+	ndp->dentry = debugfs_create_dir(netdev_name(ndp->ndev.dev),
+					 ncsi_dentry);
+	if (!ndp->dentry)
+		return -ENOMEM;
+
+	return 0;
+}
+
+void ncsi_dev_release_debug(struct ncsi_dev_priv *ndp)
+{
+	debugfs_remove(ndp->dentry);
+}
+
+int ncsi_package_init_debug(struct ncsi_package *np)
+{
+	struct ncsi_dev_priv *ndp = np->ndp;
+	char name[4];
+
+	if (!ndp->dentry)
+		return -ENOENT;
+
+	sprintf(name, "p%d", np->id);
+	np->dentry = debugfs_create_dir(name, ndp->dentry);
+	if (!np->dentry)
+		return -ENOMEM;
+
+	return 0;
+}
+
+void ncsi_package_release_debug(struct ncsi_package *np)
+{
+	debugfs_remove(np->dentry);
+}
+
+int ncsi_channel_init_debug(struct ncsi_channel *nc)
+{
+	struct ncsi_package *np = nc->package;
+	char name[3];
+
+	if (!np->dentry)
+		return -ENOENT;
+
+	sprintf(name, "c%d", nc->id);
+	nc->dentry = debugfs_create_dir(name, np->dentry);
+	if (!nc->dentry)
+		return -ENOMEM;
+
+	return 0;
+}
+
+void ncsi_channel_release_debug(struct ncsi_channel *nc)
+{
+	debugfs_remove(nc->dentry);
+}
diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
index 13ad1f26..84f1405 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -322,6 +322,8 @@ struct ncsi_channel *ncsi_add_channel(struct ncsi_package *np, unsigned char id)
 	np->channel_num++;
 	spin_unlock_irqrestore(&np->lock, flags);
 
+	ncsi_channel_init_debug(nc);
+
 	return nc;
 }
 
@@ -332,6 +334,8 @@ static void ncsi_remove_channel(struct ncsi_channel *nc)
 	unsigned long flags;
 	int i;
 
+	ncsi_channel_release_debug(nc);
+
 	/* Release filters */
 	spin_lock_irqsave(&nc->lock, flags);
 	for (i = 0; i < NCSI_FILTER_MAX; i++) {
@@ -396,6 +400,8 @@ struct ncsi_package *ncsi_add_package(struct ncsi_dev_priv *ndp,
 	ndp->package_num++;
 	spin_unlock_irqrestore(&ndp->lock, flags);
 
+	ncsi_package_init_debug(np);
+
 	return np;
 }
 
@@ -409,6 +415,8 @@ void ncsi_remove_package(struct ncsi_package *np)
 	list_for_each_entry_safe(nc, tmp, &np->channels, node)
 		ncsi_remove_channel(nc);
 
+	ncsi_package_release_debug(np);
+
 	/* Remove and free package */
 	spin_lock_irqsave(&ndp->lock, flags);
 	list_del_rcu(&np->node);
@@ -1280,6 +1288,13 @@ int ncsi_start_dev(struct ncsi_dev *nd)
 		return -ENOTTY;
 
 	if (!(ndp->flags & NCSI_DEV_PROBED)) {
+		/* The debugging functionality should have been initialized
+		 * when registerring the NCSI device. As the network device
+		 * name isn't available that time, we have to delay the work
+		 * to here.
+		 */
+		ncsi_dev_init_debug(ndp);
+
 		nd->state = ncsi_dev_state_probe;
 		schedule_work(&ndp->work);
 		return 0;
@@ -1329,6 +1344,7 @@ void ncsi_unregister_dev(struct ncsi_dev *nd)
 	struct ncsi_package *np, *tmp;
 	unsigned long flags;
 
+	ncsi_dev_release_debug(ndp);
 	dev_remove_pack(&ndp->ptype);
 
 	list_for_each_entry_safe(np, tmp, &ndp->packages, node)
-- 
2.7.4

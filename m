From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/5] net: dsa: Add support for DSA specific notifiers
Date: Wed, 11 Oct 2017 10:57:48 -0700
Message-ID: <20171011175752.22030-2-f.fainelli@gmail.com>
References: <20171011175752.22030-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:35598 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751659AbdJKR7e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 13:59:34 -0400
Received: by mail-qt0-f195.google.com with SMTP id z19so669059qtg.2
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 10:59:34 -0700 (PDT)
In-Reply-To: <20171011175752.22030-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for communicating a given DSA network device's port
number and switch index, create a specialized DSA notifier and two
events: DSA_PORT_REGISTER and DSA_PORT_UNREGISTER that communicate: the
slave network device (slave_dev), port number and switch number in the
tree.

This will be later used for network device drivers like bcmsysport which
needs to cooperate with its DSA network devices to set-up queue mapping
and scheduling.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h | 45 +++++++++++++++++++++++++++++++++++++++++++++
 net/dsa/dsa.c     | 23 +++++++++++++++++++++++
 net/dsa/slave.c   | 13 +++++++++++++
 3 files changed, 81 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 10dceccd9ce8..40a709a0754d 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -471,4 +471,49 @@ static inline int dsa_switch_resume(struct dsa_switch *ds)
 }
 #endif /* CONFIG_PM_SLEEP */
 
+enum dsa_notifier_type {
+	DSA_PORT_REGISTER,
+	DSA_PORT_UNREGISTER,
+};
+
+struct dsa_notifier_info {
+	struct net_device *dev;
+};
+
+struct dsa_notifier_register_info {
+	struct dsa_notifier_info info;	/* must be first */
+	struct net_device *master;
+	unsigned int port_number;
+	unsigned int switch_number;
+};
+
+static inline struct net_device *
+dsa_notifier_info_to_dev(const struct dsa_notifier_info *info)
+{
+	return info->dev;
+}
+
+#if IS_ENABLED(CONFIG_NET_DSA)
+int register_dsa_notifier(struct notifier_block *nb);
+int unregister_dsa_notifier(struct notifier_block *nb);
+int call_dsa_notifiers(unsigned long val, struct net_device *dev,
+		       struct dsa_notifier_info *info);
+#else
+static inline int register_dsa_notifier(struct notifier_block *nb)
+{
+	return 0;
+}
+
+static inline int unregister_dsa_notifier(struct notifier_block *nb)
+{
+	return 0;
+}
+
+static inline int call_dsa_notifiers(unsigned long val, struct net_device *dev,
+				     struct dsa_notifier_info *info)
+{
+	return NOTIFY_DONE;
+}
+#endif
+
 #endif
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 51ca2a524a27..832c659ff993 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -14,6 +14,7 @@
 #include <linux/platform_device.h>
 #include <linux/slab.h>
 #include <linux/module.h>
+#include <linux/notifier.h>
 #include <linux/of.h>
 #include <linux/of_mdio.h>
 #include <linux/of_platform.h>
@@ -261,6 +262,28 @@ bool dsa_schedule_work(struct work_struct *work)
 	return queue_work(dsa_owq, work);
 }
 
+static ATOMIC_NOTIFIER_HEAD(dsa_notif_chain);
+
+int register_dsa_notifier(struct notifier_block *nb)
+{
+	return atomic_notifier_chain_register(&dsa_notif_chain, nb);
+}
+EXPORT_SYMBOL_GPL(register_dsa_notifier);
+
+int unregister_dsa_notifier(struct notifier_block *nb)
+{
+	return atomic_notifier_chain_unregister(&dsa_notif_chain, nb);
+}
+EXPORT_SYMBOL_GPL(unregister_dsa_notifier);
+
+int call_dsa_notifiers(unsigned long val, struct net_device *dev,
+		       struct dsa_notifier_info *info)
+{
+	info->dev = dev;
+	return atomic_notifier_call_chain(&dsa_notif_chain, val, info);
+}
+EXPORT_SYMBOL_GPL(call_dsa_notifiers);
+
 static int __init dsa_init_module(void)
 {
 	int rc;
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index fb2954ff198c..45f4ea845c07 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1116,6 +1116,7 @@ int dsa_slave_resume(struct net_device *slave_dev)
 
 int dsa_slave_create(struct dsa_port *port, const char *name)
 {
+	struct dsa_notifier_register_info rinfo = { };
 	struct dsa_switch *ds = port->ds;
 	struct net_device *master;
 	struct net_device *slave_dev;
@@ -1177,6 +1178,12 @@ int dsa_slave_create(struct dsa_port *port, const char *name)
 		goto out_free;
 	}
 
+	rinfo.info.dev = slave_dev;
+	rinfo.master = master;
+	rinfo.port_number = p->dp->index;
+	rinfo.switch_number = p->dp->ds->index;
+	call_dsa_notifiers(DSA_PORT_REGISTER, slave_dev, &rinfo.info);
+
 	ret = register_netdev(slave_dev);
 	if (ret) {
 		netdev_err(master, "error %d registering interface %s\n",
@@ -1200,6 +1207,7 @@ int dsa_slave_create(struct dsa_port *port, const char *name)
 void dsa_slave_destroy(struct net_device *slave_dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(slave_dev);
+	struct dsa_notifier_register_info rinfo = { };
 	struct device_node *port_dn;
 
 	port_dn = p->dp->dn;
@@ -1211,6 +1219,11 @@ void dsa_slave_destroy(struct net_device *slave_dev)
 		if (of_phy_is_fixed_link(port_dn))
 			of_phy_deregister_fixed_link(port_dn);
 	}
+	rinfo.info.dev = slave_dev;
+	rinfo.master = p->dp->cpu_dp->netdev;
+	rinfo.port_number = p->dp->index;
+	rinfo.switch_number = p->dp->ds->index;
+	call_dsa_notifiers(DSA_PORT_UNREGISTER, slave_dev, &rinfo.info);
 	unregister_netdev(slave_dev);
 	free_percpu(p->stats64);
 	free_netdev(slave_dev);
-- 
2.9.3

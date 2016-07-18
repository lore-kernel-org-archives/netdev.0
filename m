From: kan.liang@intel.com
Subject: [RFC PATCH 01/30] net: introduce NET policy
Date: Sun, 17 Jul 2016 23:55:55 -0700
Message-ID: <1468824984-65318-2-git-send-email-kan.liang@intel.com>
References: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
Cc: jeffrey.t.kirsher@intel.com, mingo@redhat.com,
	peterz@infradead.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, jesse.brandeburg@intel.com,
	andi@firstfloor.org, Kan Liang <kan.liang@intel.com>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kan Liang <kan.liang@intel.com>

This patch introduce NET policy subsystem. If proc is supported in the
system, it creates netpolicy node in proc system.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 include/linux/netdevice.h   |   7 +++
 include/net/net_namespace.h |   3 ++
 net/Kconfig                 |   7 +++
 net/core/Makefile           |   1 +
 net/core/netpolicy.c        | 128 ++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 146 insertions(+)
 create mode 100644 net/core/netpolicy.c

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 49736a3..9e30a31 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1584,6 +1584,8 @@ enum netdev_priv_flags {
  *			switch driver and used to set the phys state of the
  *			switch port.
  *
+ *	@proc_dev:	device node in proc to configure device net policy
+ *
  *	FIXME: cleanup struct net_device such that network protocol info
  *	moves out.
  */
@@ -1851,6 +1853,11 @@ struct net_device {
 	struct lock_class_key	*qdisc_tx_busylock;
 	struct lock_class_key	*qdisc_running_key;
 	bool			proto_down;
+#ifdef CONFIG_NETPOLICY
+#ifdef CONFIG_PROC_FS
+	struct proc_dir_entry	*proc_dev;
+#endif /* CONFIG_PROC_FS */
+#endif /* CONFIG_NETPOLICY */
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 4089abc..d2ff6c4 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -142,6 +142,9 @@ struct net {
 #endif
 	struct sock		*diag_nlsk;
 	atomic_t		fnhe_genid;
+#ifdef CONFIG_NETPOLICY
+	struct proc_dir_entry	*proc_netpolicy;
+#endif /* CONFIG_NETPOLICY */
 };
 
 #include <linux/seq_file_net.h>
diff --git a/net/Kconfig b/net/Kconfig
index ff40562..c3ed726 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -205,6 +205,13 @@ source "net/bridge/netfilter/Kconfig"
 
 endif
 
+config NETPOLICY
+	depends on NET
+	bool "Net policy support"
+	default y
+	---help---
+	Net policy support
+
 source "net/dccp/Kconfig"
 source "net/sctp/Kconfig"
 source "net/rds/Kconfig"
diff --git a/net/core/Makefile b/net/core/Makefile
index d6508c2..0be7092 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -27,3 +27,4 @@ obj-$(CONFIG_LWTUNNEL) += lwtunnel.o
 obj-$(CONFIG_DST_CACHE) += dst_cache.o
 obj-$(CONFIG_HWBM) += hwbm.o
 obj-$(CONFIG_NET_DEVLINK) += devlink.o
+obj-$(CONFIG_NETPOLICY) += netpolicy.o
diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
new file mode 100644
index 0000000..faabfe7
--- /dev/null
+++ b/net/core/netpolicy.c
@@ -0,0 +1,128 @@
+/*
+ * netpolicy.c: Net policy support
+ * Copyright (c) 2016, Intel Corporation.
+ * Author: Kan Liang (kan.liang@intel.com)
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * NET policy intends to simplify the network configuration and get a good
+ * network performance according to the hints(policy) which is applied by user.
+ *
+ * Motivation
+ * 	- The network performance is not good with default system settings.
+ *	- It is too difficult to do automatic tuning for all possible
+ *	  workloads, since workloads have different requirements. Some
+ *	  workloads may want high throughput. Some may need low latency.
+ *	- There are lots of manual configurations. Fine grained configuration
+ *	  is too difficult for users.
+ * 	So, it is a big challenge to get good network performance.
+ *
+ */
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/init.h>
+#include <linux/seq_file.h>
+#include <linux/proc_fs.h>
+#include <linux/uaccess.h>
+#include <linux/netdevice.h>
+#include <net/net_namespace.h>
+
+#ifdef CONFIG_PROC_FS
+
+static int net_policy_proc_show(struct seq_file *m, void *v)
+{
+	struct net_device *dev = (struct net_device *)m->private;
+
+	seq_printf(m, "%s doesn't support net policy manager\n", dev->name);
+
+	return 0;
+}
+
+static int net_policy_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, net_policy_proc_show, PDE_DATA(inode));
+}
+
+static const struct file_operations proc_net_policy_operations = {
+	.open		= net_policy_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+	.owner		= THIS_MODULE,
+};
+
+static int netpolicy_proc_dev_init(struct net *net, struct net_device *dev)
+{
+	dev->proc_dev = proc_net_mkdir(net, dev->name, net->proc_netpolicy);
+	if (!dev->proc_dev)
+		return -ENOMEM;
+
+	if (!proc_create_data("policy", S_IWUSR | S_IRUGO,
+			      dev->proc_dev, &proc_net_policy_operations,
+			      (void *)dev)) {
+		remove_proc_subtree(dev->name, net->proc_netpolicy);
+		return -ENOMEM;
+	}
+	return 0;
+}
+
+static int __net_init netpolicy_net_init(struct net *net)
+{
+	struct net_device *dev, *aux;
+
+	net->proc_netpolicy = proc_net_mkdir(net, "netpolicy",
+					     net->proc_net);
+	if (!net->proc_netpolicy)
+		return -ENOMEM;
+
+	for_each_netdev_safe(net, dev, aux) {
+		netpolicy_proc_dev_init(net, dev);
+	}
+
+	return 0;
+}
+
+#else /* CONFIG_PROC_FS */
+
+static int __net_init netpolicy_net_init(struct net *net)
+{
+	return 0;
+}
+#endif /* CONFIG_PROC_FS */
+
+static void __net_exit netpolicy_net_exit(struct net *net)
+{
+#ifdef CONFIG_PROC_FS
+	remove_proc_subtree("netpolicy", net->proc_net);
+#endif /* CONFIG_PROC_FS */
+}
+
+static struct pernet_operations netpolicy_net_ops = {
+	.init = netpolicy_net_init,
+	.exit = netpolicy_net_exit,
+};
+
+static int __init netpolicy_init(void)
+{
+	int ret;
+
+	ret = register_pernet_subsys(&netpolicy_net_ops);
+
+	return ret;
+}
+
+static void __exit netpolicy_exit(void)
+{
+	unregister_pernet_subsys(&netpolicy_net_ops);
+}
+
+subsys_initcall(netpolicy_init);
+module_exit(netpolicy_exit);
-- 
2.5.5

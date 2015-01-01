From: kan.liang@intel.com
Subject: [RFC V2 PATCH 02/25] net/netpolicy: init NET policy
Date: Wed, 31 Dec 2014 20:38:51 -0500
Message-ID: <1420076354-4861-3-git-send-email-kan.liang@intel.com>
References: <1420076354-4861-1-git-send-email-kan.liang@intel.com>
Cc: jeffrey.t.kirsher@intel.com, mingo@redhat.com,
	peterz@infradead.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, fw@strlen.de, alexander.duyck@gmail.com,
	daniel@iogearbox.net, tom@herbertland.com, rdunlap@infradead.org,
	xiyou.wangcong@gmail.com, hannes@stressinduktion.org,
	jesse.brandeburg@intel.com, andi@firstfloor.org,
	Kan Liang <kan.liang@intel.com>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12645 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934130AbcHDTM7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2016 15:12:59 -0400
In-Reply-To: <1420076354-4861-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

This patch tries to initialize NET policy for all the devices in the
system. However, not all device drivers have NET policy support. For
those drivers who does not have NET policy support, the node will not be
showed in /proc/net/netpolicy/.
The device driver who has NET policy support must implement the
interface ndo_netpolicy_init, which is used to do necessory
initialization and collect information (E.g. supported policies) from
driver.

The user can check /proc/net/netpolicy/ and
/proc/net/netpolicy/$DEV/policy to know the available device and its
supported policy.

np_lock is also introduced to protect the state of NET policy.

Device hotplug will be handled later in this series.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 include/linux/netdevice.h | 12 +++++++
 include/linux/netpolicy.h | 31 +++++++++++++++++
 net/core/netpolicy.c      | 86 +++++++++++++++++++++++++++++++++++++++++------
 3 files changed, 118 insertions(+), 11 deletions(-)
 create mode 100644 include/linux/netpolicy.h

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 19638d6..2e0a7e7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -52,6 +52,7 @@
 #include <uapi/linux/netdevice.h>
 #include <uapi/linux/if_bonding.h>
 #include <uapi/linux/pkt_cls.h>
+#include <linux/netpolicy.h>
 
 struct netpoll_info;
 struct device;
@@ -1120,6 +1121,9 @@ struct netdev_xdp {
  * int (*ndo_xdp)(struct net_device *dev, struct netdev_xdp *xdp);
  *	This function is used to set or query state related to XDP on the
  *	netdevice. See definition of enum xdp_netdev_command for details.
+ * int(*ndo_netpolicy_init)(struct net_device *dev,
+ *			    struct netpolicy_info *info);
+ *	This function is used to init and get supported policy.
  *
  */
 struct net_device_ops {
@@ -1306,6 +1310,10 @@ struct net_device_ops {
 						       int needed_headroom);
 	int			(*ndo_xdp)(struct net_device *dev,
 					   struct netdev_xdp *xdp);
+#ifdef CONFIG_NETPOLICY
+	int			(*ndo_netpolicy_init)(struct net_device *dev,
+						      struct netpolicy_info *info);
+#endif /* CONFIG_NETPOLICY */
 };
 
 /**
@@ -1620,6 +1628,8 @@ enum netdev_priv_flags {
  *			switch port.
  *
  *	@proc_dev:	device node in proc to configure device net policy
+ *	@netpolicy:	NET policy related information of net device
+ *	@np_lock:	protect the state of NET policy
  *
  *	FIXME: cleanup struct net_device such that network protocol info
  *	moves out.
@@ -1892,6 +1902,8 @@ struct net_device {
 #ifdef CONFIG_PROC_FS
 	struct proc_dir_entry	*proc_dev;
 #endif /* CONFIG_PROC_FS */
+	struct netpolicy_info	*netpolicy;
+	spinlock_t		np_lock;
 #endif /* CONFIG_NETPOLICY */
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
diff --git a/include/linux/netpolicy.h b/include/linux/netpolicy.h
new file mode 100644
index 0000000..ca1f131
--- /dev/null
+++ b/include/linux/netpolicy.h
@@ -0,0 +1,31 @@
+/*
+ * netpolicy.h: Net policy support
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
+ */
+#ifndef __LINUX_NETPOLICY_H
+#define __LINUX_NETPOLICY_H
+
+enum netpolicy_name {
+	NET_POLICY_NONE		= 0,
+	NET_POLICY_MAX,
+};
+
+extern const char *policy_name[];
+
+struct netpolicy_info {
+	enum netpolicy_name	cur_policy;
+	unsigned long avail_policy[BITS_TO_LONGS(NET_POLICY_MAX)];
+};
+
+#endif /*__LINUX_NETPOLICY_H*/
diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
index faabfe7..5f304d5 100644
--- a/net/core/netpolicy.c
+++ b/net/core/netpolicy.c
@@ -35,13 +35,29 @@
 #include <linux/netdevice.h>
 #include <net/net_namespace.h>
 
+const char *policy_name[NET_POLICY_MAX] = {
+	"NONE"
+};
 #ifdef CONFIG_PROC_FS
 
 static int net_policy_proc_show(struct seq_file *m, void *v)
 {
 	struct net_device *dev = (struct net_device *)m->private;
-
-	seq_printf(m, "%s doesn't support net policy manager\n", dev->name);
+	int i;
+
+	if (WARN_ON(!dev->netpolicy))
+		return -EINVAL;
+
+	if (dev->netpolicy->cur_policy == NET_POLICY_NONE) {
+		seq_printf(m, "%s: There is no policy applied\n", dev->name);
+		seq_printf(m, "%s: The available policy include:", dev->name);
+		for_each_set_bit(i, dev->netpolicy->avail_policy, NET_POLICY_MAX)
+			seq_printf(m, " %s", policy_name[i]);
+		seq_printf(m, "\n");
+	} else {
+		seq_printf(m, "%s: POLICY %s is running on the system\n",
+			   dev->name, policy_name[dev->netpolicy->cur_policy]);
+	}
 
 	return 0;
 }
@@ -73,33 +89,81 @@ static int netpolicy_proc_dev_init(struct net *net, struct net_device *dev)
 	}
 	return 0;
 }
+#endif /* CONFIG_PROC_FS */
+
+int init_netpolicy(struct net_device *dev)
+{
+	int ret;
+
+	spin_lock(&dev->np_lock);
+	ret = 0;
+
+	if (!dev->netdev_ops->ndo_netpolicy_init) {
+		ret = -ENOTSUPP;
+		goto unlock;
+	}
+
+	if (dev->netpolicy)
+		goto unlock;
+
+	dev->netpolicy = kzalloc(sizeof(*dev->netpolicy), GFP_ATOMIC);
+	if (!dev->netpolicy) {
+		ret = -ENOMEM;
+		goto unlock;
+	}
+
+	ret = dev->netdev_ops->ndo_netpolicy_init(dev, dev->netpolicy);
+	if (ret) {
+		kfree(dev->netpolicy);
+		dev->netpolicy = NULL;
+	}
+
+unlock:
+	spin_unlock(&dev->np_lock);
+	return ret;
+}
+
+void uninit_netpolicy(struct net_device *dev)
+{
+	spin_lock(&dev->np_lock);
+	if (dev->netpolicy) {
+		kfree(dev->netpolicy);
+		dev->netpolicy = NULL;
+	}
+	spin_unlock(&dev->np_lock);
+}
 
 static int __net_init netpolicy_net_init(struct net *net)
 {
 	struct net_device *dev, *aux;
 
+#ifdef CONFIG_PROC_FS
 	net->proc_netpolicy = proc_net_mkdir(net, "netpolicy",
 					     net->proc_net);
 	if (!net->proc_netpolicy)
 		return -ENOMEM;
+#endif /* CONFIG_PROC_FS */
 
 	for_each_netdev_safe(net, dev, aux) {
-		netpolicy_proc_dev_init(net, dev);
+		if (!init_netpolicy(dev)) {
+#ifdef CONFIG_PROC_FS
+			if (netpolicy_proc_dev_init(net, dev))
+				uninit_netpolicy(dev);
+			else
+#endif /* CONFIG_PROC_FS */
+			pr_info("NETPOLICY: Init net policy for %s\n", dev->name);
+		}
 	}
 
 	return 0;
 }
 
-#else /* CONFIG_PROC_FS */
-
-static int __net_init netpolicy_net_init(struct net *net)
-{
-	return 0;
-}
-#endif /* CONFIG_PROC_FS */
-
 static void __net_exit netpolicy_net_exit(struct net *net)
 {
+	struct net_device *dev, *aux;
+
+	for_each_netdev_safe(net, dev, aux)
+		uninit_netpolicy(dev);
 #ifdef CONFIG_PROC_FS
 	remove_proc_subtree("netpolicy", net->proc_net);
 #endif /* CONFIG_PROC_FS */
-- 
2.5.5

From: kan.liang@intel.com
Subject: [RFC PATCH 17/30] net/netpolicy: support CPU hotplug
Date: Sun, 17 Jul 2016 23:56:11 -0700
Message-ID: <1468824984-65318-18-git-send-email-kan.liang@intel.com>
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

For CPU hotplug, the net policy module will rebuild the sys map and
object list.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 net/core/netpolicy.c | 78 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 78 insertions(+)

diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
index 2a04fcf..46af407 100644
--- a/net/core/netpolicy.c
+++ b/net/core/netpolicy.c
@@ -37,6 +37,7 @@
 #include <net/net_namespace.h>
 #include <linux/sort.h>
 #include <linux/ctype.h>
+#include <linux/cpu.h>
 
 static int netpolicy_get_dev_info(struct net_device *dev,
 				  struct netpolicy_dev_info *d_info)
@@ -838,6 +839,75 @@ static struct notifier_block netpolicy_dev_notf = {
 	.notifier_call = netpolicy_notify,
 };
 
+/**
+ * update_netpolicy_sys_map() - rebuild the sys map and object list
+ *
+ * This function go through all the available net policy supported device,
+ * and rebuild sys map and object list.
+ *
+ */
+void update_netpolicy_sys_map(void)
+{
+	struct net *net;
+	struct net_device *dev, *aux;
+	enum netpolicy_name cur_policy;
+
+	for_each_net(net) {
+		for_each_netdev_safe(net, dev, aux) {
+			spin_lock(&dev->np_lock);
+			if (!dev->netpolicy)
+				goto unlock;
+			cur_policy = dev->netpolicy->cur_policy;
+			if (cur_policy == NET_POLICY_NONE)
+				goto unlock;
+
+			dev->netpolicy->cur_policy = NET_POLICY_NONE;
+
+			/* rebuild everything */
+			netpolicy_disable(dev);
+			netpolicy_enable(dev);
+			if (netpolicy_gen_obj_list(dev, cur_policy)) {
+				pr_warn("NETPOLICY: Failed to generate "
+					"netpolicy object list for dev %s\n",
+					dev->name);
+				netpolicy_disable(dev);
+				goto unlock;
+			}
+			if (dev->netdev_ops->ndo_set_net_policy(dev, cur_policy)) {
+				pr_warn("NETPOLICY: Failed to set "
+					"netpolicy for dev %s\n",
+					dev->name);
+				netpolicy_disable(dev);
+				goto unlock;
+			}
+
+			dev->netpolicy->cur_policy = cur_policy;
+unlock:
+			spin_unlock(&dev->np_lock);
+		}
+	}
+}
+
+static int netpolicy_cpu_callback(struct notifier_block *nfb,
+				  unsigned long action, void *hcpu)
+{
+	switch (action & ~CPU_TASKS_FROZEN) {
+	case CPU_ONLINE:
+		update_netpolicy_sys_map();
+		break;
+	case CPU_DYING:
+		update_netpolicy_sys_map();
+		break;
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block netpolicy_cpu_notifier = {
+	&netpolicy_cpu_callback,
+	NULL,
+	0
+};
+
 static int __init netpolicy_init(void)
 {
 	int ret;
@@ -846,6 +916,10 @@ static int __init netpolicy_init(void)
 	if (!ret)
 		register_netdevice_notifier(&netpolicy_dev_notf);
 
+	cpu_notifier_register_begin();
+	__register_cpu_notifier(&netpolicy_cpu_notifier);
+	cpu_notifier_register_done();
+
 	return ret;
 }
 
@@ -853,6 +927,10 @@ static void __exit netpolicy_exit(void)
 {
 	unregister_netdevice_notifier(&netpolicy_dev_notf);
 	unregister_pernet_subsys(&netpolicy_net_ops);
+
+	cpu_notifier_register_begin();
+	__unregister_cpu_notifier(&netpolicy_cpu_notifier);
+	cpu_notifier_register_done();
 }
 
 subsys_initcall(netpolicy_init);
-- 
2.5.5

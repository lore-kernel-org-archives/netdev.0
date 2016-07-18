From: kan.liang@intel.com
Subject: [RFC PATCH 16/30] net/netpolicy: net device hotplug
Date: Sun, 17 Jul 2016 23:56:10 -0700
Message-ID: <1468824984-65318-17-git-send-email-kan.liang@intel.com>
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

Support net device up/down/namechange in the netpolicy code.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 net/core/netpolicy.c | 66 +++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 58 insertions(+), 8 deletions(-)

diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
index 8336106..2a04fcf 100644
--- a/net/core/netpolicy.c
+++ b/net/core/netpolicy.c
@@ -684,6 +684,9 @@ static const struct file_operations proc_net_policy_operations = {
 
 static int netpolicy_proc_dev_init(struct net *net, struct net_device *dev)
 {
+	if (dev->proc_dev)
+		proc_remove(dev->proc_dev);
+
 	dev->proc_dev = proc_net_mkdir(net, dev->name, net->proc_netpolicy);
 	if (!dev->proc_dev)
 		return -ENOMEM;
@@ -750,6 +753,19 @@ void uninit_netpolicy(struct net_device *dev)
 	spin_unlock(&dev->np_lock);
 }
 
+static void netpolicy_dev_init(struct net *net,
+			       struct net_device *dev)
+{
+	if (!init_netpolicy(dev)) {
+#ifdef CONFIG_PROC_FS
+		if (netpolicy_proc_dev_init(net, dev))
+			uninit_netpolicy(dev);
+		else
+#endif /* CONFIG_PROC_FS */
+		pr_info("NETPOLICY: Init net policy for %s\n", dev->name);
+	}
+}
+
 static int __net_init netpolicy_net_init(struct net *net)
 {
 	struct net_device *dev, *aux;
@@ -762,14 +778,7 @@ static int __net_init netpolicy_net_init(struct net *net)
 #endif /* CONFIG_PROC_FS */
 
 	for_each_netdev_safe(net, dev, aux) {
-		if (!init_netpolicy(dev)) {
-#ifdef CONFIG_PROC_FS
-			if (netpolicy_proc_dev_init(net, dev))
-				uninit_netpolicy(dev);
-			else
-#endif /* CONFIG_PROC_FS */
-			pr_info("NETPOLICY: Init net policy for %s\n", dev->name);
-		}
+		netpolicy_dev_init(net, dev);
 	}
 
 	return 0;
@@ -791,17 +800,58 @@ static struct pernet_operations netpolicy_net_ops = {
 	.exit = netpolicy_net_exit,
 };
 
+static int netpolicy_notify(struct notifier_block *this,
+			    unsigned long event,
+			    void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+
+	switch (event) {
+	case NETDEV_CHANGENAME:
+#ifdef CONFIG_PROC_FS
+		if (dev->proc_dev) {
+			proc_remove(dev->proc_dev);
+			if ((netpolicy_proc_dev_init(dev_net(dev), dev) < 0) &&
+			    dev->proc_dev) {
+				proc_remove(dev->proc_dev);
+				dev->proc_dev = NULL;
+			}
+		}
+#endif
+		break;
+	case NETDEV_UP:
+		netpolicy_dev_init(dev_net(dev), dev);
+		break;
+	case NETDEV_GOING_DOWN:
+		uninit_netpolicy(dev);
+#ifdef CONFIG_PROC_FS
+		proc_remove(dev->proc_dev);
+		dev->proc_dev = NULL;
+#endif
+		break;
+	}
+
+	return NOTIFY_OK;
+}
+
+static struct notifier_block netpolicy_dev_notf = {
+	.notifier_call = netpolicy_notify,
+};
+
 static int __init netpolicy_init(void)
 {
 	int ret;
 
 	ret = register_pernet_subsys(&netpolicy_net_ops);
+	if (!ret)
+		register_netdevice_notifier(&netpolicy_dev_notf);
 
 	return ret;
 }
 
 static void __exit netpolicy_exit(void)
 {
+	unregister_netdevice_notifier(&netpolicy_dev_notf);
 	unregister_pernet_subsys(&netpolicy_net_ops);
 }
 
-- 
2.5.5

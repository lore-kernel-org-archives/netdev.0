From: kan.liang@intel.com
Subject: [RFC PATCH 11/30] net/netpolicy: set net policy by policy name
Date: Sun, 17 Jul 2016 23:56:05 -0700
Message-ID: <1468824984-65318-12-git-send-email-kan.liang@intel.com>
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

User can write policy name to /proc/net/netpolicy/$DEV/policy to enable
net policy for specific device.

When the policy is enabled, the module automatically disables irq
balance and set irq affinity. The object list is also generated
accordingly.

np_lock will be used to protect the state.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 include/linux/netdevice.h |  5 +++
 include/linux/netpolicy.h |  1 +
 net/core/netpolicy.c      | 95 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 101 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e60c30f..45cb589 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1094,6 +1094,9 @@ struct tc_to_netdev {
  * int (*ndo_get_irq_info)(struct net_device *dev,
  * 			   struct netpolicy_dev_info *info);
  * 	This function is used to get irq information of rx and tx queues
+ * int (*ndo_set_net_policy)(struct net_device *dev,
+ * 			     enum netpolicy_name name);
+ * 	This function is used to set global net policy by name
  *
  */
 struct net_device_ops {
@@ -1283,6 +1286,8 @@ struct net_device_ops {
 						      struct netpolicy_info *info);
 	int			(*ndo_get_irq_info)(struct net_device *dev,
 						    struct netpolicy_dev_info *info);
+	int			(*ndo_set_net_policy)(struct net_device *dev,
+						      enum netpolicy_name name);
 #endif /* CONFIG_NETPOLICY */
 };
 
diff --git a/include/linux/netpolicy.h b/include/linux/netpolicy.h
index 73a5fa6..b1d9277 100644
--- a/include/linux/netpolicy.h
+++ b/include/linux/netpolicy.h
@@ -27,6 +27,7 @@ enum netpolicy_traffic {
 	NETPOLICY_RXTX,
 };
 
+#define POLICY_NAME_LEN_MAX	64
 extern const char *policy_name[];
 
 struct netpolicy_dev_info {
diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
index 0f8ff16..8112839 100644
--- a/net/core/netpolicy.c
+++ b/net/core/netpolicy.c
@@ -36,6 +36,7 @@
 #include <linux/netdevice.h>
 #include <net/net_namespace.h>
 #include <linux/sort.h>
+#include <linux/ctype.h>
 
 static int netpolicy_get_dev_info(struct net_device *dev,
 				  struct netpolicy_dev_info *d_info)
@@ -430,6 +431,69 @@ err:
 	return ret;
 }
 
+static int net_policy_set_by_name(char *name, struct net_device *dev)
+{
+	int i, ret;
+
+	spin_lock(&dev->np_lock);
+	ret = 0;
+
+	if (!dev->netpolicy ||
+	    !dev->netdev_ops->ndo_set_net_policy) {
+		ret = -ENOTSUPP;
+		goto unlock;
+	}
+
+	for (i = 0; i < NET_POLICY_MAX; i++) {
+		if (!strncmp(name, policy_name[i], strlen(policy_name[i])))
+		break;
+	}
+
+	if (!test_bit(i, dev->netpolicy->avail_policy)) {
+		ret = -ENOTSUPP;
+		goto unlock;
+	}
+
+	if (i == dev->netpolicy->cur_policy)
+		goto unlock;
+
+	/* If there is no policy applied yet, need to do enable first . */
+	if (dev->netpolicy->cur_policy == NET_POLICY_NONE) {
+		ret = netpolicy_enable(dev);
+		if (ret)
+			goto unlock;
+	}
+
+	netpolicy_free_obj_list(dev);
+
+	/* Generate object list according to policy name */
+	ret = netpolicy_gen_obj_list(dev, i);
+	if (ret)
+		goto err;
+
+	/* set policy */
+	ret = dev->netdev_ops->ndo_set_net_policy(dev, i);
+	if (ret)
+		goto err;
+
+	/* If removing policy, need to do disable. */
+	if (i == NET_POLICY_NONE)
+		netpolicy_disable(dev);
+
+	dev->netpolicy->cur_policy = i;
+
+	spin_unlock(&dev->np_lock);
+	return 0;
+
+err:
+	netpolicy_free_obj_list(dev);
+	if (dev->netpolicy->cur_policy == NET_POLICY_NONE)
+		netpolicy_disable(dev);
+unlock:
+	spin_unlock(&dev->np_lock);
+	return ret;
+}
+
 #ifdef CONFIG_PROC_FS
 
 static int net_policy_proc_show(struct seq_file *m, void *v)
@@ -459,11 +523,40 @@ static int net_policy_proc_open(struct inode *inode, struct file *file)
 	return single_open(file, net_policy_proc_show, PDE_DATA(inode));
 }
 
+static ssize_t net_policy_proc_write(struct file *file, const char __user *buf,
+				     size_t count, loff_t *pos)
+{
+	struct seq_file *m = file->private_data;
+	struct net_device *dev = (struct net_device *)m->private;
+	char name[POLICY_NAME_LEN_MAX];
+	int i, ret;
+
+	if (!dev->netpolicy)
+		return -ENOTSUPP;
+
+	if (count > POLICY_NAME_LEN_MAX)
+		return -EINVAL;
+
+	if (copy_from_user(name, buf, count))
+		return -EINVAL;
+
+	for (i = 0; i < count - 1; i++)
+		name[i] = toupper(name[i]);
+	name[POLICY_NAME_LEN_MAX - 1] = 0;
+
+	ret = net_policy_set_by_name(name, dev);
+	if (ret)
+		return ret;
+
+	return count;
+}
+
 static const struct file_operations proc_net_policy_operations = {
 	.open		= net_policy_proc_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
 	.release	= seq_release,
+	.write		= net_policy_proc_write,
 	.owner		= THIS_MODULE,
 };
 
@@ -527,6 +620,8 @@ void uninit_netpolicy(struct net_device *dev)
 {
 	spin_lock(&dev->np_lock);
 	if (dev->netpolicy) {
+		if (dev->netpolicy->cur_policy > NET_POLICY_NONE)
+			netpolicy_disable(dev);
 		kfree(dev->netpolicy);
 		dev->netpolicy = NULL;
 	}
-- 
2.5.5

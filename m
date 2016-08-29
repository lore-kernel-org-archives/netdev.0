From: Kirill Tkhai <ktkhai@virtuozzo.com>
Subject: [PATCH RFC 1/2] net: Implement net_stats callbacks
Date: Mon, 29 Aug 2016 22:03:59 +0300
Message-ID: <147249743915.18175.18376811998714650854.stgit@pro>
References: <147249730528.18175.4772805024092024580.stgit@pro>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <yoshfuji@linux-ipv6.org>, <jmorris@namei.org>,
        <davem@davemloft.net>, <peterz@infradead.org>,
        <edumazet@google.com>, <mingo@redhat.com>, <kaber@trash.net>,
        <ktkhai@virtuozzo.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147249730528.18175.4772805024092024580.stgit@pro>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net_stats callbacks are functions, which are called
during a cpu is going down. They operate on percpu
statistics and should move it from dying cpu to an
alive one.

The callbacks are called on CPU_DYING stage, when
machine is stopped, and they are executed on dying
cpu.

This allows to minimize overhead of summation of
percpu statistics on all possible cpus, and iterate
only present cpus instead. It may give a signify
growth of performance on configurations with big
number of possible cpus.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 include/net/stats.h |    9 ++++++
 net/core/Makefile   |    1 +
 net/core/stats.c    |   83 +++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 93 insertions(+)
 create mode 100644 include/net/stats.h
 create mode 100644 net/core/stats.c

diff --git a/include/net/stats.h b/include/net/stats.h
new file mode 100644
index 0000000..7aebc56
--- /dev/null
+++ b/include/net/stats.h
@@ -0,0 +1,9 @@
+#ifndef _NET_STATS_H_
+#define _NET_STATS_H_
+
+typedef int (*net_stats_cb_t)(int cpu);
+
+extern int register_net_stats_cb(net_stats_cb_t func);
+extern int unregister_net_stats_cb(net_stats_cb_t func);
+
+#endif /* _NET_STATS_H_ */
diff --git a/net/core/Makefile b/net/core/Makefile
index d6508c2..c1093c3 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -27,3 +27,4 @@ obj-$(CONFIG_LWTUNNEL) += lwtunnel.o
 obj-$(CONFIG_DST_CACHE) += dst_cache.o
 obj-$(CONFIG_HWBM) += hwbm.o
 obj-$(CONFIG_NET_DEVLINK) += devlink.o
+obj-$(CONFIG_HOTPLUG_CPU) += stats.o
diff --git a/net/core/stats.c b/net/core/stats.c
new file mode 100644
index 0000000..0307e2c
--- /dev/null
+++ b/net/core/stats.c
@@ -0,0 +1,83 @@
+#include <linux/init.h>
+#include <linux/cpu.h>
+#include <linux/vmalloc.h>
+#include <net/stats.h>
+
+struct net_stats_cb_entry {
+	struct list_head list;
+	net_stats_cb_t func;
+};
+
+static DEFINE_SPINLOCK(net_stats_lock);
+static LIST_HEAD(net_stats_cb_list);
+
+int register_net_stats_cb(net_stats_cb_t func)
+{
+	struct net_stats_cb_entry *entry = vmalloc(sizeof(*entry));
+
+	if (!entry)
+		return -ENOMEM;
+	entry->func = func;
+	spin_lock(&net_stats_lock);
+	list_add_tail(&entry->list, &net_stats_cb_list);
+	spin_unlock(&net_stats_lock);
+	return 0;
+}
+EXPORT_SYMBOL(register_net_stats_cb);
+
+int unregister_net_stats_cb(net_stats_cb_t func)
+{
+	struct net_stats_cb_entry *entry;
+	bool found = false;
+
+	spin_lock(&net_stats_lock);
+	list_for_each_entry(entry, &net_stats_cb_list, list) {
+		if (entry->func == func) {
+			found = true;
+			break;
+		}
+	}
+	spin_unlock(&net_stats_lock);
+
+	if (!found)
+		return -ENOENT;
+
+	list_del(&entry->list);
+	vfree(entry);
+	return 0;
+}
+EXPORT_SYMBOL(unregister_net_stats_cb);
+
+static int net_stats_cpu_notify(struct notifier_block *nb,
+				unsigned long action, void *hcpu)
+{
+	struct net_stats_cb_entry *entry;
+	long cpu = (long)hcpu;
+	int ret;
+
+	if ((action & ~CPU_TASKS_FROZEN) == CPU_DYING) {
+		/* We call callbacks in dying stage, when machine is stopped */
+		spin_lock(&net_stats_lock);
+		list_for_each_entry(entry, &net_stats_cb_list, list) {
+			ret = entry->func(cpu);
+			if (ret)
+				break;
+		}
+		spin_unlock(&net_stats_lock);
+
+		if (ret)
+			return NOTIFY_BAD;
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block net_stats_nfb = {
+	.notifier_call = net_stats_cpu_notify,
+};
+
+static int __init net_stats_init(void)
+{
+	return register_cpu_notifier(&net_stats_nfb);
+}
+
+subsys_initcall(net_stats_init);

From: kan.liang@intel.com
Subject: [RFC PATCH 26/30] net/netpolicy: set per task policy by proc
Date: Sun, 17 Jul 2016 23:56:20 -0700
Message-ID: <1468824984-65318-27-git-send-email-kan.liang@intel.com>
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

Users may not want to change the source code to add per task net polic
support. Or they may want to change a running task's net policy. prctl
does not work for both cases.

This patch adds an interface in /proc, which can be used to set and
retrieve policy of already running tasks. User can write the policy name
into /proc/$PID/net_policy to set per task net policy.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 fs/proc/base.c | 64 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 64 insertions(+)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index a11eb71..7679785 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -91,6 +91,8 @@
 #include <asm/hardwall.h>
 #endif
 #include <trace/events/oom.h>
+#include <linux/netpolicy.h>
+#include <linux/ctype.h>
 #include "internal.h"
 #include "fd.h"
 
@@ -2807,6 +2809,65 @@ static int proc_pid_personality(struct seq_file *m, struct pid_namespace *ns,
 	return err;
 }
 
+#ifdef CONFIG_NETPOLICY
+static int proc_net_policy_show(struct seq_file *m, void *v)
+{
+	struct inode *inode = m->private;
+	struct task_struct *task = get_proc_task(inode);
+
+	if (is_net_policy_valid(task->task_netpolicy.policy))
+		seq_printf(m, "%s\n", policy_name[task->task_netpolicy.policy]);
+
+	return 0;
+}
+
+static int proc_net_policy_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, proc_net_policy_show, inode);
+}
+
+static ssize_t proc_net_policy_write(struct file *file, const char __user *buf,
+				     size_t count, loff_t *ppos)
+{
+	struct inode *inode = file_inode(file);
+	struct task_struct *task = get_proc_task(inode);
+	char name[POLICY_NAME_LEN_MAX];
+	int i, ret;
+
+	if (count >= POLICY_NAME_LEN_MAX)
+		return -EINVAL;
+
+	if (copy_from_user(name, buf, count))
+		return -EINVAL;
+
+	for (i = 0; i < count - 1; i++)
+		name[i] = toupper(name[i]);
+	name[POLICY_NAME_LEN_MAX - 1] = 0;
+
+	for (i = 0; i < NET_POLICY_MAX; i++) {
+		if (!strncmp(name, policy_name[i], strlen(policy_name[i]))) {
+			ret = netpolicy_register(&task->task_netpolicy, i);
+			if (ret)
+				return ret;
+			break;
+		}
+	}
+
+	if (i == NET_POLICY_MAX)
+		return -EINVAL;
+
+	return count;
+}
+
+static const struct file_operations proc_net_policy_operations = {
+	.open		= proc_net_policy_open,
+	.write		= proc_net_policy_write,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+#endif /* CONFIG_NETPOLICY */
+
 /*
  * Thread groups
  */
@@ -2906,6 +2967,9 @@ static const struct pid_entry tgid_base_stuff[] = {
 	REG("timers",	  S_IRUGO, proc_timers_operations),
 #endif
 	REG("timerslack_ns", S_IRUGO|S_IWUGO, proc_pid_set_timerslack_ns_operations),
+#if IS_ENABLED(CONFIG_NETPOLICY)
+	REG("net_policy", S_IRUSR|S_IWUSR, proc_net_policy_operations),
+#endif
 };
 
 static int proc_tgid_base_readdir(struct file *file, struct dir_context *ctx)
-- 
2.5.5

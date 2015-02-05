From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 17/29] net: vrf: Add vrf context to task struct
Date: Wed,  4 Feb 2015 18:34:18 -0700
Message-ID: <1423100070-31848-18-git-send-email-dsahern@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:44317 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756325AbbBEBgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:36:08 -0500
Received: by mail-ig0-f180.google.com with SMTP id b16so8428500igk.1
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:36:07 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vrf context is passed parent to child. Defaults to 1 and can be read
and changed via /proc/<pid>/vrf. In time the /proc write option can be
removed in favor of a prctl; writing to a proc file is a lot simpler
at this point.

A tasks' vrf context is the default used for sockets created by the
task. This is addressed in the next patch.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 fs/proc/base.c            | 94 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/init_task.h |  1 +
 include/linux/sched.h     |  2 +
 kernel/fork.c             |  2 +
 4 files changed, 99 insertions(+)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 3f3d7aeb0712..9e538075f7e5 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -90,6 +90,7 @@
 #ifdef CONFIG_HARDWALL
 #include <asm/hardwall.h>
 #endif
+#include <net/vrf.h>
 #include <trace/events/oom.h>
 #include "internal.h"
 #include "fd.h"
@@ -456,6 +457,97 @@ static int proc_pid_limits(struct seq_file *m, struct pid_namespace *ns,
 	return 0;
 }
 
+static ssize_t vrf_read(struct file *file, char __user *buf,
+				size_t count, loff_t *ppos)
+{
+	struct task_struct *task = get_proc_task(file->f_path.dentry->d_inode);
+	char buffer[16];
+	size_t len;
+	__u32 vrf = 0;
+	unsigned long flags;
+
+	if (!task)
+		return -ESRCH;
+
+	if (lock_task_sighand(task, &flags)) {
+		vrf = task->vrf;
+		unlock_task_sighand(task, &flags);
+	}
+
+	put_task_struct(task);
+
+	if (vrf == VRF_ANY)
+		len = snprintf(buffer, sizeof(buffer), "any\n");
+	else
+		len = snprintf(buffer, sizeof(buffer), "%i\n", vrf);
+
+	return simple_read_from_buffer(buf, count, ppos, buffer, len);
+}
+
+static ssize_t vrf_write(struct file *file, const char __user *buf,
+				size_t count, loff_t *ppos)
+{
+	struct task_struct *task;
+	char buffer[16], *pbuf;
+	__u32 vrf;
+	unsigned long flags;
+	int err;
+
+	memset(buffer, 0, sizeof(buffer));
+	if (count > sizeof(buffer) - 1)
+		count = sizeof(buffer) - 1;
+	if (copy_from_user(buffer, buf, count)) {
+		err = -EFAULT;
+		goto out;
+	}
+
+	pbuf = strstrip(buffer);
+	if (strcmp(pbuf, "any") == 0)
+		vrf = VRF_ANY;
+	else {
+		err = kstrtouint(strstrip(buffer), 0, &vrf);
+		if (err)
+			goto out;
+
+		if (!vrf_is_valid(vrf)) {
+			err = -EINVAL;
+			goto out;
+		}
+	}
+
+	task = get_proc_task(file_inode(file));
+	if (!task) {
+		err = -ESRCH;
+		goto out;
+	}
+
+	task_lock(task);
+	if (!task->mm) {
+		err = -EINVAL;
+		goto err_task_lock;
+	}
+
+	if (!lock_task_sighand(task, &flags)) {
+		err = -ESRCH;
+		goto err_task_lock;
+	}
+
+	task->vrf = vrf;
+
+	unlock_task_sighand(task, &flags);
+err_task_lock:
+	task_unlock(task);
+	put_task_struct(task);
+out:
+	return err < 0 ? err : count;
+}
+
+static const struct file_operations proc_vrf_operations = {
+	.read		= vrf_read,
+	.write		= vrf_write,
+	.llseek		= generic_file_llseek,
+};
+
 #ifdef CONFIG_HAVE_ARCH_TRACEHOOK
 static int proc_pid_syscall(struct seq_file *m, struct pid_namespace *ns,
 			    struct pid *pid, struct task_struct *task)
@@ -2628,6 +2720,7 @@ static const struct pid_entry tgid_base_stuff[] = {
 #ifdef CONFIG_CHECKPOINT_RESTORE
 	REG("timers",	  S_IRUGO, proc_timers_operations),
 #endif
+	REG("vrf",   S_IRUGO|S_IWUSR, proc_vrf_operations),
 };
 
 static int proc_tgid_base_readdir(struct file *file, struct dir_context *ctx)
@@ -2970,6 +3063,7 @@ static const struct pid_entry tid_base_stuff[] = {
 	REG("projid_map", S_IRUGO|S_IWUSR, proc_projid_map_operations),
 	REG("setgroups",  S_IRUGO|S_IWUSR, proc_setgroups_operations),
 #endif
+	REG("vrf",   S_IRUGO|S_IWUSR, proc_vrf_operations),
 };
 
 static int proc_tid_base_readdir(struct file *file, struct dir_context *ctx)
diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index 3037fc085e8e..3ae3a93d42ce 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -247,6 +247,7 @@ extern struct task_group root_task_group;
 	INIT_RT_MUTEXES(tsk)						\
 	INIT_VTIME(tsk)							\
 	INIT_NUMA_BALANCING(tsk)					\
+	.vrf = VRF_DEFAULT,						\
 }
 
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 8db31ef98d2f..8b40ba202906 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1459,6 +1459,8 @@ struct task_struct {
 	struct files_struct *files;
 /* namespaces */
 	struct nsproxy *nsproxy;
+/* vrf context within a namespace */
+	__u32 vrf;
 /* signal handlers */
 	struct signal_struct *signal;
 	struct sighand_struct *sighand;
diff --git a/kernel/fork.c b/kernel/fork.c
index 4dc2ddade9f1..a6f412da1378 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -352,6 +352,8 @@ static struct task_struct *dup_task_struct(struct task_struct *orig)
 	tsk->splice_pipe = NULL;
 	tsk->task_frag.page = NULL;
 
+	tsk->vrf = orig->vrf;
+
 	account_kernel_stack(ti, 1);
 
 	return tsk;
-- 
1.9.3 (Apple Git-50)

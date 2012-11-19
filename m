From: Rui Xiang <leo.ruixiang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH RFC 2/5] Syslog_ns: add CLONE_NEWSYSLOG and create syslog_ns
	when copying process
Date: Mon, 19 Nov 2012 16:16:38 +0800
Message-ID: <50A9EAE6.50909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Xiang Rui <rui.xiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

We add a new clone flag named CLONE_NEWSYSLOG, and use 0x02000000 which was
previously the unused CLONE_STOPPED and is now available for re-use.

In syslog_namespaces.c, the interface copy_syslog_ns is implemented for create
a new syslog_ns. When a new namespace was created for one process copying, the
interface was used.

Signed-off-by: Xiang Rui <rui.xiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 include/linux/nsproxy.h          |    2 ++
 include/linux/syslog_namespace.h |   19 +++++++++++++++++++
 include/uapi/linux/sched.h       |    3 +--
 kernel/nsproxy.c                 |   16 +++++++++++++++-
 kernel/syslog_namespace.c        |   32 ++++++++++++++++++++++++++++++++
 5 files changed, 69 insertions(+), 3 deletions(-)

diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
index cc37a55..9db2527 100644
--- a/include/linux/nsproxy.h
+++ b/include/linux/nsproxy.h
@@ -8,6 +8,7 @@ struct mnt_namespace;
 struct uts_namespace;
 struct ipc_namespace;
 struct pid_namespace;
+struct syslog_namespace;
 struct fs_struct;

 /*
@@ -29,6 +30,7 @@ struct nsproxy {
 	struct mnt_namespace *mnt_ns;
 	struct pid_namespace *pid_ns;
 	struct net 	     *net_ns;
+	struct syslog_namespace *syslog_ns;
 };
 extern struct nsproxy init_nsproxy;

diff --git a/include/linux/syslog_namespace.h b/include/linux/syslog_namespace.h
index 8c8ac5a..1ecb8b8 100644
--- a/include/linux/syslog_namespace.h
+++ b/include/linux/syslog_namespace.h
@@ -2,6 +2,9 @@
 #define _LINUX_SYSLOG_NAMESPACE_H

 #include <linux/kref.h>
+#include <linux/sched.h>
+#include <linux/nsproxy.h>
+#include <linux/err.h>

 /* record buffer */
 #if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
@@ -47,8 +50,16 @@ struct syslog_namespace {

 extern struct syslog_namespace init_syslog_ns;

+static inline struct syslog_namespace *current_syslog_ns(void)
+{
+	return current->nsproxy->syslog_ns;
+}
+
 #ifdef CONFIG_SYSLOG_NS
 extern void free_syslog_ns(struct kref *kref);
+extern struct syslog_namespace *copy_syslog_ns(unsigned long flags,
+					struct task_struct *tsk);
+
 static inline struct syslog_namespace *get_syslog_ns(
 				struct syslog_namespace *ns)
 {
@@ -64,6 +75,14 @@ static inline void put_syslog_ns(struct syslog_namespace *ns)
 }

 #else
+static inline struct syslog_namespace *copy_syslog_ns(unsigned long flags,
+					struct task_struct *tsk)
+{
+	if (flags & CLONE_NEWSYSLOG)
+		return ERR_PTR(-EINVAL);
+	return tsk->nsproxy->syslog_ns;
+}
+
 static inline struct syslog_namespace *get_syslog_ns(
 				struct syslog_namespace *ns)
 {
diff --git a/include/uapi/linux/sched.h b/include/uapi/linux/sched.h
index 5a0f945..906a3da 100644
--- a/include/uapi/linux/sched.h
+++ b/include/uapi/linux/sched.h
@@ -21,8 +21,7 @@
 #define CLONE_DETACHED		0x00400000	/* Unused, ignored */
 #define CLONE_UNTRACED		0x00800000	/* set if the tracing process can't force CLONE_PTRACE on this clone */
 #define CLONE_CHILD_SETTID	0x01000000	/* set the TID in the child */
-/* 0x02000000 was previously the unused CLONE_STOPPED (Start in stopped state)
-   and is now available for re-use. */
+#define CLONE_NEWSYSLOG	0x02000000      /* New syslog namespace */
 #define CLONE_NEWUTS		0x04000000	/* New utsname group? */
 #define CLONE_NEWIPC		0x08000000	/* New ipcs */
 #define CLONE_NEWUSER		0x10000000	/* New user namespace */
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index b576f7f..331d31f 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -22,6 +22,7 @@
 #include <linux/pid_namespace.h>
 #include <net/net_namespace.h>
 #include <linux/ipc_namespace.h>
+#include <linux/syslog_namespace.h>
 #include <linux/proc_fs.h>
 #include <linux/file.h>
 #include <linux/syscalls.h>
@@ -36,6 +37,7 @@ struct nsproxy init_nsproxy = {
 #endif
 	.mnt_ns	= NULL,
 	.pid_ns	= &init_pid_ns,
+	.syslog_ns = &init_syslog_ns,
 #ifdef CONFIG_NET
 	.net_ns	= &init_net,
 #endif
@@ -96,8 +98,17 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
 		goto out_net;
 	}

+	new_nsp->syslog_ns = copy_syslog_ns(flags, tsk);
+	if (IS_ERR(new_nsp->syslog_ns)) {
+		err = PTR_ERR(new_nsp->syslog_ns);
+		goto out_syslog;
+	}
+
 	return new_nsp;

+out_syslog:
+	if (new_nsp->net_ns)
+		put_net(new_nsp->net_ns);
 out_net:
 	if (new_nsp->pid_ns)
 		put_pid_ns(new_nsp->pid_ns);
@@ -131,7 +142,8 @@ int copy_namespaces(unsigned long flags, struct task_struct *tsk)
 	get_nsproxy(old_ns);

 	if (!(flags & (CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC |
-				CLONE_NEWPID | CLONE_NEWNET)))
+				CLONE_NEWPID | CLONE_NEWNET |
+				CLONE_NEWSYSLOG)))
 		return 0;

 	if (!capable(CAP_SYS_ADMIN)) {
@@ -174,6 +186,8 @@ void free_nsproxy(struct nsproxy *ns)
 		put_ipc_ns(ns->ipc_ns);
 	if (ns->pid_ns)
 		put_pid_ns(ns->pid_ns);
+	if (ns->syslog_ns)
+		put_syslog_ns(ns->syslog_ns);
 	put_net(ns->net_ns);
 	kmem_cache_free(nsproxy_cachep, ns);
 }
diff --git a/kernel/syslog_namespace.c b/kernel/syslog_namespace.c
index 9482927..a12e1c1 100644
--- a/kernel/syslog_namespace.c
+++ b/kernel/syslog_namespace.c
@@ -7,6 +7,7 @@

 #include <linux/slab.h>
 #include <linux/module.h>
+#include <linux/bootmem.h>
 #include <linux/syslog_namespace.h>

 static char __log_buf[__LOG_BUF_LEN] __aligned(LOG_ALIGN);
@@ -21,6 +22,37 @@ struct syslog_namespace init_syslog_ns = {
 };
 EXPORT_SYMBOL_GPL(init_syslog_ns);

+static struct syslog_namespace *create_syslog_ns(unsigned int buf_len)
+{
+	struct syslog_namespace *ns;
+
+	if (buf_len <= 0)
+		return ERR_PTR(-EINVAL);
+	ns = kzalloc(sizeof(*ns), GFP_KERNEL);
+	if (!ns)
+		return ERR_PTR(-ENOMEM);
+
+	kref_init(&(ns->kref));
+
+	ns->log_buf_len = buf_len;
+	ns->log_buf = kzalloc(buf_len, GFP_KERNEL);
+	if (!ns->log_buf) {
+		kfree(ns);
+		return ERR_PTR(-ENOMEM);
+	}
+	raw_spin_lock_init(&(ns->logbuf_lock));
+
+	return ns;
+}
+
+struct syslog_namespace *copy_syslog_ns(unsigned long flags,
+					struct task_struct *tsk)
+{
+	if (!(flags & CLONE_NEWSYSLOG))
+		return get_syslog_ns(tsk->nsproxy->syslog_ns);
+	return create_syslog_ns(CONTAINER_BUF_LEN);
+}
+
 void free_syslog_ns(struct kref *kref)
 {
 	struct syslog_namespace *ns;
-- 
1.7.1

From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 2/2] proc: Usable inode numbers for the namespace file descriptors.
Date: Fri, 17 Jun 2011 16:33:19 -0700
Message-ID: <m1mxhgav9c.fsf_-_@fess.ebiederm.org>
References: <20110521093936.GA3015@p183> <m11uzsxdty.fsf@fess.ebiederm.org>
	<20110521223054.GA3198@p183> <m1vcx3r3o5.fsf@fess.ebiederm.org>
	<20110523014303.GA2351982@jupiter.n2.diac24.net>
	<20110523014751.GB2351982@jupiter.n2.diac24.net>
	<m1wrgkavbm.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org,
	David Lamparter <equinox@diac24.net>,
	<linux-kernel@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>
To: Linux Containers <containers@lists.osdl.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1wrgkavbm.fsf_-_@fess.ebiederm.org> (Eric W. Biederman's
	message of "Fri, 17 Jun 2011 16:31:57 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Assign a unique proc inode to each namespace, yielding an
identifier that userspace can use for identifying a namespace.

This has been a long requested feature and only blocked because
a naive implementation would put the id in a global space and
would ultimately require having a namespace for the names of
namespaces, making migration and certain virtualization tricks
impossible.

We still don't have per superblock inode numbers for proc, which
appears necessary for application unaware checkpoint/restart and
migrations (if the application is using namespace filedescriptors)
but that is now allowd by the design if it becomes important.

I have preallocated the ipc and uts initial proc inode numbers so
their structures can be statically initialized.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/namespaces.c          |    1 +
 include/linux/ipc_namespace.h |    2 ++
 include/linux/proc_fs.h       |    4 ++++
 include/linux/utsname.h       |    1 +
 include/net/net_namespace.h   |    2 ++
 init/version.c                |    2 ++
 ipc/msgutil.c                 |    2 ++
 ipc/namespace.c               |   16 ++++++++++++++++
 kernel/utsname.c              |   17 ++++++++++++++++-
 net/core/net_namespace.c      |   24 ++++++++++++++++++++++++
 10 files changed, 70 insertions(+), 1 deletions(-)

diff --git a/fs/proc/namespaces.c b/fs/proc/namespaces.c
index be177f7..ddc2bb4 100644
--- a/fs/proc/namespaces.c
+++ b/fs/proc/namespaces.c
@@ -54,6 +54,7 @@ static struct dentry *proc_ns_instantiate(struct inode *dir,
 	ei->ns_ops    = ns_ops;
 	ei->ns	      = ns;
 
+	inode->i_ino = ns_ops->inum(ei->ns);
 	dentry->d_op = &pid_dentry_operations;
 	d_add(dentry, inode);
 	/* Close the race of the process dying before we return the dentry */
diff --git a/include/linux/ipc_namespace.h b/include/linux/ipc_namespace.h
index a6d1655..22a4dc4 100644
--- a/include/linux/ipc_namespace.h
+++ b/include/linux/ipc_namespace.h
@@ -60,6 +60,8 @@ struct ipc_namespace {
 
 	/* user_ns which owns the ipc ns */
 	struct user_namespace *user_ns;
+
+	unsigned int	proc_inum;
 };
 
 extern struct ipc_namespace init_ipc_ns;
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 3067b44..1aee7f0 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -29,8 +29,11 @@ struct mm_struct;
 
 enum {
 	PROC_ROOT_INO = 1,
+	PROC_IPC_INIT_INO = 2,
+	PROC_UTS_INIT_INO = 3,
 };
 
+
 /*
  * This is not completely implemented yet. The idea is to
  * create an in-memory tree (like the actual /proc filesystem
@@ -257,6 +260,7 @@ struct proc_ns_operations {
 	void *(*get)(struct task_struct *task);
 	void (*put)(void *ns);
 	int (*install)(struct nsproxy *nsproxy, void *ns);
+	unsigned int (*inum)(void *ns);
 };
 extern const struct proc_ns_operations netns_operations;
 extern const struct proc_ns_operations utsns_operations;
diff --git a/include/linux/utsname.h b/include/linux/utsname.h
index 4e5b021..03db764 100644
--- a/include/linux/utsname.h
+++ b/include/linux/utsname.h
@@ -44,6 +44,7 @@ struct uts_namespace {
 	struct kref kref;
 	struct new_utsname name;
 	struct user_namespace *user_ns;
+	unsigned int proc_inum;
 };
 extern struct uts_namespace init_uts_ns;
 
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 2bf9ed9..4b85be2 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -49,6 +49,8 @@ struct net {
 	struct list_head	cleanup_list;	/* namespaces on death row */
 	struct list_head	exit_list;	/* Use only net_mutex */
 
+	unsigned int		proc_inum;
+
 	struct proc_dir_entry 	*proc_net;
 	struct proc_dir_entry 	*proc_net_stat;
 
diff --git a/init/version.c b/init/version.c
index 86fe0cc..58170f1 100644
--- a/init/version.c
+++ b/init/version.c
@@ -12,6 +12,7 @@
 #include <linux/utsname.h>
 #include <generated/utsrelease.h>
 #include <linux/version.h>
+#include <linux/proc_fs.h>
 
 #ifndef CONFIG_KALLSYMS
 #define version(a) Version_ ## a
@@ -34,6 +35,7 @@ struct uts_namespace init_uts_ns = {
 		.domainname	= UTS_DOMAINNAME,
 	},
 	.user_ns = &init_user_ns,
+	.proc_inum = PROC_UTS_INIT_INO,
 };
 EXPORT_SYMBOL_GPL(init_uts_ns);
 
diff --git a/ipc/msgutil.c b/ipc/msgutil.c
index 8b5ce5d..f7da485 100644
--- a/ipc/msgutil.c
+++ b/ipc/msgutil.c
@@ -14,6 +14,7 @@
 #include <linux/slab.h>
 #include <linux/ipc.h>
 #include <linux/ipc_namespace.h>
+#include <linux/proc_fs.h>
 #include <asm/uaccess.h>
 
 #include "util.h"
@@ -33,6 +34,7 @@ struct ipc_namespace init_ipc_ns = {
 	.mq_msgsize_max  = DFLT_MSGSIZEMAX,
 #endif
 	.user_ns = &init_user_ns,
+	.proc_inum = PROC_IPC_INIT_INO,
 };
 
 atomic_t nr_ipc_ns = ATOMIC_INIT(1);
diff --git a/ipc/namespace.c b/ipc/namespace.c
index ce0a647..cd7f733 100644
--- a/ipc/namespace.c
+++ b/ipc/namespace.c
@@ -26,9 +26,16 @@ static struct ipc_namespace *create_ipc_ns(struct task_struct *tsk,
 	if (ns == NULL)
 		return ERR_PTR(-ENOMEM);
 
+	err = proc_alloc_inum(&ns->proc_inum);
+	if (err) {
+		kfree(ns);
+		return ERR_PTR(err);
+	}
+
 	atomic_set(&ns->count, 1);
 	err = mq_init_ns(ns);
 	if (err) {
+		proc_free_inum(ns->proc_inum);
 		kfree(ns);
 		return ERR_PTR(err);
 	}
@@ -113,6 +120,7 @@ static void free_ipc_ns(struct ipc_namespace *ns)
 	 */
 	ipcns_notify(IPCNS_REMOVED);
 	put_user_ns(ns->user_ns);
+	proc_free_inum(ns->proc_inum);
 	kfree(ns);
 }
 
@@ -170,10 +178,18 @@ static int ipcns_install(struct nsproxy *nsproxy, void *ns)
 	return 0;
 }
 
+static unsigned int ipcns_inum(void *vp)
+{
+	struct ipc_namespace *ns = vp;
+
+	return ns->proc_inum;
+}
+
 const struct proc_ns_operations ipcns_operations = {
 	.name		= "ipc",
 	.type		= CLONE_NEWIPC,
 	.get		= ipcns_get,
 	.put		= ipcns_put,
 	.install	= ipcns_install,
+	.inum		= ipcns_inum,
 };
diff --git a/kernel/utsname.c b/kernel/utsname.c
index bff131b..3ab6a08 100644
--- a/kernel/utsname.c
+++ b/kernel/utsname.c
@@ -36,11 +36,18 @@ static struct uts_namespace *clone_uts_ns(struct task_struct *tsk,
 					  struct uts_namespace *old_ns)
 {
 	struct uts_namespace *ns;
+	int err;
 
 	ns = create_uts_ns();
 	if (!ns)
 		return ERR_PTR(-ENOMEM);
 
+	err = proc_alloc_inum(&ns->proc_inum);
+	if (err) {
+		kfree(ns);
+		return ERR_PTR(err);
+	}
+
 	down_read(&uts_sem);
 	memcpy(&ns->name, &old_ns->name, sizeof(ns->name));
 	ns->user_ns = get_user_ns(task_cred_xxx(tsk, user)->user_ns);
@@ -78,6 +85,7 @@ void free_uts_ns(struct kref *kref)
 
 	ns = container_of(kref, struct uts_namespace, kref);
 	put_user_ns(ns->user_ns);
+	proc_free_inum(ns->proc_inum);
 	kfree(ns);
 }
 
@@ -110,11 +118,18 @@ static int utsns_install(struct nsproxy *nsproxy, void *ns)
 	return 0;
 }
 
+static unsigned int utsns_inum(void *vp)
+{
+	struct uts_namespace *ns = vp;
+
+	return ns->proc_inum;
+}
+
 const struct proc_ns_operations utsns_operations = {
 	.name		= "uts",
 	.type		= CLONE_NEWUTS,
 	.get		= utsns_get,
 	.put		= utsns_put,
 	.install	= utsns_install,
+	.inum		= utsns_inum,
 };
-
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index e41e511..6199ec2 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -358,6 +358,21 @@ struct net *get_net_ns_by_pid(pid_t pid)
 }
 EXPORT_SYMBOL_GPL(get_net_ns_by_pid);
 
+static __net_init int net_ns_net_init(struct net *net)
+{
+	return proc_alloc_inum(&net->proc_inum);
+}
+
+static __net_exit void net_ns_net_exit(struct net *net)
+{
+	proc_free_inum(net->proc_inum);
+}
+
+static struct pernet_operations __net_initdata net_ns_ops = {
+	.init = net_ns_net_init,
+	.exit = net_ns_net_exit,		
+};
+
 static int __init net_ns_init(void)
 {
 	struct net_generic *ng;
@@ -389,6 +404,8 @@ static int __init net_ns_init(void)
 
 	mutex_unlock(&net_mutex);
 
+	register_pernet_subsys(&net_ns_ops);
+
 	return 0;
 }
 
@@ -616,11 +633,18 @@ static int netns_install(struct nsproxy *nsproxy, void *ns)
 	return 0;
 }
 
+static unsigned int netns_inum(void *ns)
+{
+	struct net *net = ns;
+	return net->proc_inum;
+}
+
 const struct proc_ns_operations netns_operations = {
 	.name		= "net",
 	.type		= CLONE_NEWNET,
 	.get		= netns_get,
 	.put		= netns_put,
 	.install	= netns_install,
+	.inum		= netns_inum,
 };
 #endif
-- 
1.7.5.1.217.g4e3aa

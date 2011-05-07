From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 5/7] ns proc: Add support for the ipc namespace
Date: Fri,  6 May 2011 19:24:59 -0700
Message-ID: <1304735101-1824-5-git-send-email-ebiederm@xmission.com>
References: <m1tyd7p7tq.fsf@fess.ebiederm.org>
 <1304735101-1824-1-git-send-email-ebiederm@xmission.com>
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Linux Containers <containers@lists.osdl.org>,
	Renato Westphal <renatowestphal@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <linux-arch@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304735101-1824-1-git-send-email-ebiederm@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/namespaces.c    |    3 +++
 include/linux/proc_fs.h |    1 +
 ipc/namespace.c         |   37 +++++++++++++++++++++++++++++++++++++
 3 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/fs/proc/namespaces.c b/fs/proc/namespaces.c
index b017181..f18d6d5 100644
--- a/fs/proc/namespaces.c
+++ b/fs/proc/namespaces.c
@@ -22,6 +22,9 @@ static const struct proc_ns_operations *ns_entries[] = {
 #ifdef CONFIG_UTS_NS
 	&utsns_operations,
 #endif
+#ifdef CONFIG_IPC_NS
+	&ipcns_operations,
+#endif
 };
 
 static const struct file_operations ns_file_operations = {
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 52aa89d..a23f0b7 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -267,6 +267,7 @@ struct proc_ns_operations {
 };
 extern const struct proc_ns_operations netns_operations;
 extern const struct proc_ns_operations utsns_operations;
+extern const struct proc_ns_operations ipcns_operations;
 
 union proc_op {
 	int (*proc_get_link)(struct inode *, struct path *);
diff --git a/ipc/namespace.c b/ipc/namespace.c
index 8054c8e..ce0a647 100644
--- a/ipc/namespace.c
+++ b/ipc/namespace.c
@@ -12,6 +12,7 @@
 #include <linux/fs.h>
 #include <linux/mount.h>
 #include <linux/user_namespace.h>
+#include <linux/proc_fs.h>
 
 #include "util.h"
 
@@ -140,3 +141,39 @@ void put_ipc_ns(struct ipc_namespace *ns)
 		free_ipc_ns(ns);
 	}
 }
+
+static void *ipcns_get(struct task_struct *task)
+{
+	struct ipc_namespace *ns = NULL;
+	struct nsproxy *nsproxy;
+
+	rcu_read_lock();
+	nsproxy = task_nsproxy(task);
+	if (nsproxy)
+		ns = get_ipc_ns(nsproxy->ipc_ns);
+	rcu_read_unlock();
+
+	return ns;
+}
+
+static void ipcns_put(void *ns)
+{
+	return put_ipc_ns(ns);
+}
+
+static int ipcns_install(struct nsproxy *nsproxy, void *ns)
+{
+	/* Ditch state from the old ipc namespace */
+	exit_sem(current);
+	put_ipc_ns(nsproxy->ipc_ns);
+	nsproxy->ipc_ns = get_ipc_ns(ns);
+	return 0;
+}
+
+const struct proc_ns_operations ipcns_operations = {
+	.name		= "ipc",
+	.type		= CLONE_NEWIPC,
+	.get		= ipcns_get,
+	.put		= ipcns_put,
+	.install	= ipcns_install,
+};
-- 
1.6.5.2.143.g8cc62

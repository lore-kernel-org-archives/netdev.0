From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 5/8] ns proc: Add support for the ipc namespace
Date: Thu, 23 Sep 2010 01:49:59 -0700
Message-ID: <m1sk10q1xk.fsf@fess.ebiederm.org>
References: <m1ocborgq7.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Containers <containers@lists.osdl.org>,
	<netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	<linux-fsdevel@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	Ulrich Drepper <drepper@gmail.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Pavel Emelyanov <xemul@parallels.com>,
	Ben Greear <greearb@candelatech.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>
To: <linux-kernel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <m1ocborgq7.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 23 Sep 2010 01:45:04 -0700")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/namespaces.c    |    3 +++
 include/linux/proc_fs.h |    1 +
 ipc/namespace.c         |   31 +++++++++++++++++++++++++++++++
 3 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/fs/proc/namespaces.c b/fs/proc/namespaces.c
index 902443e..2f503b5 100644
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
index 28b4ffd..9a9ef31 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -264,6 +264,7 @@ struct proc_ns_operations {
 #define PROC_NSNAME(NAME) { .name = (NAME), .len = (sizeof(NAME) - 1), }
 extern const struct proc_ns_operations netns_operations;
 extern const struct proc_ns_operations utsns_operations;
+extern const struct proc_ns_operations ipcns_operations;
 extern struct file *proc_ns_fget(int fd);
 
 union proc_op {
diff --git a/ipc/namespace.c b/ipc/namespace.c
index a1094ff..2c5947f 100644
--- a/ipc/namespace.c
+++ b/ipc/namespace.c
@@ -11,6 +11,7 @@
 #include <linux/slab.h>
 #include <linux/fs.h>
 #include <linux/mount.h>
+#include <linux/proc_fs.h>
 
 #include "util.h"
 
@@ -132,3 +133,33 @@ void put_ipc_ns(struct ipc_namespace *ns)
 		free_ipc_ns(ns);
 	}
 }
+
+static void *ipcns_get(struct task_struct *task)
+{
+	struct ipc_namespace *ns;
+	rcu_read_lock();
+	ns = get_ipc_ns(task->nsproxy->ipc_ns);
+	rcu_read_unlock();
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
+	.name		= PROC_NSNAME("ipc"),
+	.get		= ipcns_get,
+	.put		= ipcns_put,
+	.install	= ipcns_install,
+};
-- 
1.6.5.2.143.g8cc62


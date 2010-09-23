From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 6/8] ns proc: Add support for the mount namespace
Date: Thu, 23 Sep 2010 01:50:45 -0700
Message-ID: <m1mxr8q1wa.fsf@fess.ebiederm.org>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:53772 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752262Ab0IWIuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 04:50:50 -0400
In-Reply-To: <m1ocborgq7.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 23 Sep 2010 01:45:04 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The mount namespace is a little tricky as an arbitrary
decision must be made about what to set fs->root and
fs->pwd to, as there is no expectation of a relationship
between the two mount namespaces.

Therefor I arbitrary find the root mount point, and follow
every mount on top of it to find the top of the mount stack.
Then I set fs->root and fs->pwd to that location.

The topmost root of the mount stack seems like a reasonable place to be.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/namespace.c          |   57 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/proc/namespaces.c    |    1 +
 include/linux/proc_fs.h |    1 +
 3 files changed, 59 insertions(+), 0 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index a72eaab..ed11bac 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -32,6 +32,7 @@
 #include <linux/idr.h>
 #include <linux/fs_struct.h>
 #include <linux/fsnotify.h>
+#include <linux/proc_fs.h>
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
 #include "pnode.h"
@@ -2418,3 +2419,59 @@ void put_mnt_ns(struct mnt_namespace *ns)
 	kfree(ns);
 }
 EXPORT_SYMBOL(put_mnt_ns);
+
+
+static void *mntns_get(struct task_struct *task)
+{
+	struct mnt_namespace *ns;
+	rcu_read_lock();
+	ns = task->nsproxy->mnt_ns;
+	get_mnt_ns(ns);
+	rcu_read_unlock();
+	return ns;
+}
+
+static void mntns_put(void *ns)
+{
+	put_mnt_ns(ns);
+}
+
+static int mntns_install(struct nsproxy *nsproxy, void *ns)
+{
+	struct fs_struct *fs = current->fs;
+	struct mnt_namespace *mnt_ns = ns;
+	struct path root;
+
+	if (fs->users != 1)
+		return -EINVAL;
+
+	get_mnt_ns(mnt_ns);
+	put_mnt_ns(nsproxy->mnt_ns);
+	nsproxy->mnt_ns = mnt_ns;
+
+	/* Find the root */
+	root.mnt    = mnt_ns->root;
+	root.dentry = mnt_ns->root->mnt_root;
+	path_get(&root);
+	while(d_mountpoint(root.dentry) && follow_down(&root))
+		;
+
+	/* Update the pwd and root */
+	path_get(&root);
+	path_get(&root);
+	path_put(&fs->root);
+	path_put(&fs->pwd);
+	fs->root = root;
+	fs->pwd  = root;
+	path_put(&root);
+
+	return 0;
+}
+
+const struct proc_ns_operations mntns_operations = {
+	.name		= PROC_NSNAME("mnt"),
+	.get		= mntns_get,
+	.put		= mntns_put,
+	.install	= mntns_install,
+};
+
diff --git a/fs/proc/namespaces.c b/fs/proc/namespaces.c
index 2f503b5..c5956ad 100644
--- a/fs/proc/namespaces.c
+++ b/fs/proc/namespaces.c
@@ -25,6 +25,7 @@ static const struct proc_ns_operations *ns_entries[] = {
 #ifdef CONFIG_IPC_NS
 	&ipcns_operations,
 #endif
+	&mntns_operations,
 };
 
 static const struct file_operations ns_file_operations = {
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 9a9ef31..8a260b0 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -265,6 +265,7 @@ struct proc_ns_operations {
 extern const struct proc_ns_operations netns_operations;
 extern const struct proc_ns_operations utsns_operations;
 extern const struct proc_ns_operations ipcns_operations;
+extern const struct proc_ns_operations mntns_operations;
 extern struct file *proc_ns_fget(int fd);
 
 union proc_op {
-- 
1.6.5.2.143.g8cc62


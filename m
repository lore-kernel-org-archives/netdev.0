From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 2/7] ns: Introduce the setns syscall
Date: Fri,  6 May 2011 19:24:56 -0700
Message-ID: <1304735101-1824-2-git-send-email-ebiederm@xmission.com>
References: <m1tyd7p7tq.fsf@fess.ebiederm.org>
	<1304735101-1824-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
        "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: <linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1304735101-1824-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

With the networking stack today there is demand to handle
multiple network stacks at a time.  Not in the context
of containers but in the context of people doing interesting
things with routing.

There is also demand in the context of containers to have
an efficient way to execute some code in the container itself.
If nothing else it is very useful ad a debugging technique.

Both problems can be solved by starting some form of login
daemon in the namespaces people want access to, or you
can play games by ptracing a process and getting the
traced process to do things you want it to do. However
it turns out that a login daemon or a ptrace puppet
controller are more code, they are more prone to
failure, and generally they are less efficient than
simply changing the namespace of a process to a
specified one.

Pieces of this puzzle can also be solved by instead of
coming up with a general purpose system call coming up
with targed system calls perhaps socketat that solve
a subset of the larger problem.  Overall that appears
to be more work for less reward.

int setns(int fd, int nstype);

The fd argument is a file descriptor referring to a proc
file of the namespace you want to switch the process to.

In the setns system call the nstype is 0 or specifies
an clone flag of the namespace you intend to change
to prevent changing a namespace unintentionally.

v2: Most of the architecture support added by Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
v3: ported to v2.6.36-rc4 by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
v4: Moved wiring up of the system call to another patch

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 kernel/nsproxy.c |   37 +++++++++++++++++++++++++++++++++++++
 1 files changed, 37 insertions(+), 0 deletions(-)

diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index a05d191..96059d8 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -22,6 +22,9 @@
 #include <linux/pid_namespace.h>
 #include <net/net_namespace.h>
 #include <linux/ipc_namespace.h>
+#include <linux/proc_fs.h>
+#include <linux/file.h>
+#include <linux/syscalls.h>
 
 static struct kmem_cache *nsproxy_cachep;
 
@@ -233,6 +236,40 @@ void exit_task_namespaces(struct task_struct *p)
 	switch_task_namespaces(p, NULL);
 }
 
+SYSCALL_DEFINE2(setns, int, fd, int, nstype)
+{
+	const struct proc_ns_operations *ops;
+	struct task_struct *tsk = current;
+	struct nsproxy *new_nsproxy;
+	struct proc_inode *ei;
+	struct file *file;
+	int err;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	file = proc_ns_fget(fd);
+	if (IS_ERR(file))
+		return PTR_ERR(file);
+
+	err = -EINVAL;
+	ei = PROC_I(file->f_dentry->d_inode);
+	ops = ei->ns_ops;
+	if (nstype && (ops->type != nstype))
+		goto out;
+
+	new_nsproxy = create_new_namespaces(0, tsk, tsk->fs);
+	err = ops->install(new_nsproxy, ei->ns);
+	if (err) {
+		free_nsproxy(new_nsproxy);
+		goto out;
+	}
+	switch_task_namespaces(tsk, new_nsproxy);
+out:
+	fput(file);
+	return err;
+}
+
 static int __init nsproxy_cache_init(void)
 {
 	nsproxy_cachep = KMEM_CACHE(nsproxy, SLAB_PANIC);
-- 
1.6.5.2.143.g8cc62

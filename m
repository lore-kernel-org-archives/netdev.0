From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 2/8] ns: Introduce the setns syscall
Date: Thu, 23 Sep 2010 01:46:56 -0700
Message-ID: <m1d3s4rgn3.fsf@fess.ebiederm.org>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1ocborgq7.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 23 Sep 2010 01:45:04 -0700")
Sender: linux-kernel-owner@vger.kernel.org
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

int setns(unsigned int nstype, int fd);

In the setns system call the nstype is 0 or specifies
an the name of the namespace you think you are changing,
to prevent changing a namespace unintentionally.

The fd argument is a file descriptor referring to a proc
file of the namespace you want to switch the process to.

v2: Most of the architecture support added by Daniel Lezcano <dlezcano@fr.ibm.com>
v3: ported to v2.6.36-rc4 by: Eric W. Biederman <ebiederm@xmission.com>
v4: Moved wiring up of the system call to another patch

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 kernel/nsproxy.c |   39 +++++++++++++++++++++++++++++++++++++++
 1 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index f74e6c0..0bf2dba 100644
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
 
@@ -233,6 +236,42 @@ void exit_task_namespaces(struct task_struct *p)
 	switch_task_namespaces(p, NULL);
 }
 
+SYSCALL_DEFINE2(setns, unsigned int, nstype, int, fd)
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
+	if (nstype &&
+	    ((ops->name.len >= sizeof(nstype)) ||
+	    memcmp(&nstype, ops->name.name, ops->name.len)))
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

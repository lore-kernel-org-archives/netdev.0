From: Alban Crequy <alban.crequy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [RFC v2 1/2] proc connector: add namespace events
Date: Sat, 15 Oct 2016 14:26:09 +0200
Message-ID: <1476534370-4027-2-git-send-email-alban@kinvolk.io>
References: <1476534370-4027-1-git-send-email-alban@kinvolk.io>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Iago Lopez Galeiras <iago-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Aaron Campbell <aaron-J6AcJDG0ZEwdnm+yROfE0A@public.gmane.org>,
	Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Jesper Derehag <jderehag-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>,
	Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>,
	Dimitri John Ledkov <dimitri.j.ledkov-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1476534370-4027-1-git-send-email-alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
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

From: Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>

The act of a process creating or joining a namespace via clone(),
unshare() or setns() is a useful signal for monitoring applications.

I am working on a monitoring application that keeps track of all the
containers and all processes inside each container. The current way of
doing it is by polling regularly in /proc for the list of processes and
in /proc/*/ns/* to know which namespaces they belong to. This is
inefficient on systems with a large number of containers and a large
number of processes.

Instead, I would inspect /proc only one time and get the updates with
the proc connector. Unfortunately, the proc connector gives me the list
of processes but does not notify me when a process changes namespaces.
So I would still need to inspect /proc/*/ns/*.

This patch adds namespace events for processes. It generates a namespace
event each time a process changes namespace via clone(), unshare() or
setns().

For example, the following command:
| # unshare -n -i -f ls -l /proc/self/ns/
| total 0
| lrwxrwxrwx 1 root root 0 Sep 25 22:31 cgroup -> 'cgroup:[4026531835]'
| lrwxrwxrwx 1 root root 0 Sep 25 22:31 ipc -> 'ipc:[4026532208]'
| lrwxrwxrwx 1 root root 0 Sep 25 22:31 mnt -> 'mnt:[4026531840]'
| lrwxrwxrwx 1 root root 0 Sep 25 22:31 net -> 'net:[4026532210]'
| lrwxrwxrwx 1 root root 0 Sep 25 22:31 pid -> 'pid:[4026531836]'
| lrwxrwxrwx 1 root root 0 Sep 25 22:31 user -> 'user:[4026531837]'
| lrwxrwxrwx 1 root root 0 Sep 25 22:31 uts -> 'uts:[4026531838]'

causes the proc connector to generate the following events:
| fork: ppid=691 pid=808
| exec: pid=808
| ns: pid=808 reason=unshare count=2
|     type=ipc  4026531839 -> 4026532208
|     type=net  4026531957 -> 4026532210
| fork: ppid=808 pid=809
| exec: pid=809
| exit: pid=809
| exit: pid=808

Signed-off-by: Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
---
 drivers/connector/cn_proc.c  | 138 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/cn_proc.h      |  25 ++++++++
 include/uapi/linux/cn_proc.h |  23 +++++++-
 kernel/fork.c                |  10 ++++
 kernel/nsproxy.c             |   6 ++
 5 files changed, 201 insertions(+), 1 deletion(-)

diff --git a/drivers/connector/cn_proc.c b/drivers/connector/cn_proc.c
index a782ce8..c38733d 100644
--- a/drivers/connector/cn_proc.c
+++ b/drivers/connector/cn_proc.c
@@ -30,8 +30,13 @@
 #include <linux/ptrace.h>
 #include <linux/atomic.h>
 #include <linux/pid_namespace.h>
+#include <linux/ipc_namespace.h>
+#include <linux/utsname.h>
+#include <net/net_namespace.h>
+#include <linux/mnt_namespace.h>
 
 #include <linux/cn_proc.h>
+#include <linux/proc_ns.h>
 
 /*
  * Size of a cn_msg followed by a proc_event structure.  Since the
@@ -296,6 +301,139 @@ void proc_exit_connector(struct task_struct *task)
 	send_msg(msg);
 }
 
+void proc_ns_connector_prepare(struct ns_event_prepare *prepare, u16 reason)
+{
+	struct nsproxy *ns = current->nsproxy;
+	struct ns_common *mntns;
+
+	prepare->num_listeners = atomic_read(&proc_event_num_listeners);
+
+	if (prepare->num_listeners < 1)
+		return;
+
+	prepare->reason = reason;
+
+	prepare->user_inum = current->cred->user_ns->ns.inum;
+	prepare->uts_inum = ns->uts_ns->ns.inum;
+	prepare->ipc_inum = ns->ipc_ns->ns.inum;
+
+	mntns = mntns_operations.get(current);
+	if (mntns) {
+		prepare->mnt_inum = mntns->inum;
+		mntns_operations.put(mntns);
+	} else
+		prepare->mnt_inum = 0;
+
+	prepare->pid_inum = ns->pid_ns_for_children->ns.inum;
+	prepare->net_inum = ns->net_ns->ns.inum;
+	prepare->cgroup_inum = ns->cgroup_ns->ns.inum;
+}
+
+void proc_ns_connector_send(struct ns_event_prepare *prepare, struct task_struct *task)
+{
+	struct nsproxy *ns = task->nsproxy;
+	struct ns_common *mntns;
+	struct cn_msg *msg;
+	struct proc_event *ev;
+	__u8 buffer[CN_PROC_MSG_SIZE] __aligned(8);
+	int count;
+
+	if (prepare->num_listeners < 1)
+		return;
+
+	if (atomic_read(&proc_event_num_listeners) < 1)
+		return;
+
+	msg = buffer_to_cn_msg(buffer);
+	ev = (struct proc_event *)msg->data;
+	memset(&ev->event_data, 0, sizeof(ev->event_data));
+	ev->timestamp_ns = ktime_get_ns();
+	ev->what = PROC_EVENT_NS;
+
+	ev->event_data.ns.process_pid  = task->pid;
+	ev->event_data.ns.process_tgid = task->tgid;
+	ev->event_data.ns.reason = prepare->reason;
+	count = 0;
+
+	/* user */
+	if (prepare->user_inum != task->cred->user_ns->ns.inum) {
+		ev->event_data.ns.items[count].type = CLONE_NEWUSER;
+		ev->event_data.ns.items[count].flags = 0;
+		ev->event_data.ns.items[count].old_inum = prepare->user_inum;
+		ev->event_data.ns.items[count].inum = task->cred->user_ns->ns.inum;
+		count++;
+	}
+
+	/* uts */
+	if (prepare->uts_inum != ns->uts_ns->ns.inum) {
+		ev->event_data.ns.items[count].type = CLONE_NEWUTS;
+		ev->event_data.ns.items[count].flags = 0;
+		ev->event_data.ns.items[count].old_inum = prepare->uts_inum;
+		ev->event_data.ns.items[count].inum = ns->uts_ns->ns.inum;
+		count++;
+	}
+
+	/* ipc */
+	if (prepare->ipc_inum != ns->ipc_ns->ns.inum) {
+		ev->event_data.ns.items[count].type = CLONE_NEWIPC;
+		ev->event_data.ns.items[count].flags = 0;
+		ev->event_data.ns.items[count].old_inum = prepare->ipc_inum;
+		ev->event_data.ns.items[count].inum = ns->ipc_ns->ns.inum;
+		count++;
+	}
+
+	/* mnt */
+	mntns = mntns_operations.get(task);
+	if (mntns) {
+		if (mntns && prepare->mnt_inum != mntns->inum) {
+			ev->event_data.ns.items[count].type = CLONE_NEWNS;
+			ev->event_data.ns.items[count].flags = 0;
+			ev->event_data.ns.items[count].old_inum = prepare->mnt_inum;
+			ev->event_data.ns.items[count].inum = mntns->inum;
+			count++;
+		}
+		mntns_operations.put(mntns);
+	}
+
+	/* pid */
+	if (prepare->pid_inum != ns->pid_ns_for_children->ns.inum) {
+		ev->event_data.ns.items[count].type = CLONE_NEWPID;
+		ev->event_data.ns.items[count].flags = 0;
+		ev->event_data.ns.items[count].old_inum = prepare->pid_inum;
+		ev->event_data.ns.items[count].inum = ns->pid_ns_for_children->ns.inum;
+		count++;
+	}
+
+	/* net */
+	if (prepare->net_inum != ns->net_ns->ns.inum) {
+		ev->event_data.ns.items[count].type = CLONE_NEWNET;
+		ev->event_data.ns.items[count].flags = 0;
+		ev->event_data.ns.items[count].old_inum = prepare->net_inum;
+		ev->event_data.ns.items[count].inum = ns->net_ns->ns.inum;
+		count++;
+	}
+
+	/* cgroup */
+	if (prepare->cgroup_inum != ns->cgroup_ns->ns.inum) {
+		ev->event_data.ns.items[count].type = CLONE_NEWNET;
+		ev->event_data.ns.items[count].flags = 0;
+		ev->event_data.ns.items[count].old_inum = prepare->cgroup_inum;
+		ev->event_data.ns.items[count].inum = ns->cgroup_ns->ns.inum;
+		count++;
+	}
+
+	if (count == 0)
+		return;
+
+	ev->event_data.ns.count = count;
+
+	memcpy(&msg->id, &cn_proc_event_id, sizeof(msg->id));
+	msg->ack = 0; /* not used */
+	msg->len = sizeof(*ev);
+	msg->flags = 0; /* not used */
+	send_msg(msg);
+}
+
 /*
  * Send an acknowledgement message to userspace
  *
diff --git a/include/linux/cn_proc.h b/include/linux/cn_proc.h
index 1d5b02a..8bf42f4 100644
--- a/include/linux/cn_proc.h
+++ b/include/linux/cn_proc.h
@@ -19,6 +19,20 @@
 
 #include <uapi/linux/cn_proc.h>
 
+struct ns_event_prepare {
+	int num_listeners;
+
+	u16 reason;
+
+	u64 user_inum;
+	u64 uts_inum;
+	u64 ipc_inum;
+	u64 mnt_inum;
+	u64 pid_inum;
+	u64 net_inum;
+	u64 cgroup_inum;
+};
+
 #ifdef CONFIG_PROC_EVENTS
 void proc_fork_connector(struct task_struct *task);
 void proc_exec_connector(struct task_struct *task);
@@ -28,6 +42,9 @@ void proc_ptrace_connector(struct task_struct *task, int which_id);
 void proc_comm_connector(struct task_struct *task);
 void proc_coredump_connector(struct task_struct *task);
 void proc_exit_connector(struct task_struct *task);
+
+void proc_ns_connector_prepare(struct ns_event_prepare *prepare, u16 reason);
+void proc_ns_connector_send(struct ns_event_prepare *prepare, struct task_struct *task);
 #else
 static inline void proc_fork_connector(struct task_struct *task)
 {}
@@ -54,5 +71,13 @@ static inline void proc_coredump_connector(struct task_struct *task)
 
 static inline void proc_exit_connector(struct task_struct *task)
 {}
+
+static inline void proc_ns_connector_prepare(struct ns_event_prepare *prepare,
+					     u16 reason)
+{}
+
+static inline void proc_ns_connector_send(struct ns_event_prepare *prepare,
+					  struct task_struct *task)
+{}
 #endif	/* CONFIG_PROC_EVENTS */
 #endif	/* CN_PROC_H */
diff --git a/include/uapi/linux/cn_proc.h b/include/uapi/linux/cn_proc.h
index f6c2710..3270e8c 100644
--- a/include/uapi/linux/cn_proc.h
+++ b/include/uapi/linux/cn_proc.h
@@ -55,7 +55,8 @@ struct proc_event {
 		PROC_EVENT_SID  = 0x00000080,
 		PROC_EVENT_PTRACE = 0x00000100,
 		PROC_EVENT_COMM = 0x00000200,
-		/* "next" should be 0x00000400 */
+		PROC_EVENT_NS   = 0x00000400,
+		/* "next" should be 0x00000800 */
 		/* "last" is the last process event: exit,
 		 * while "next to last" is coredumping event */
 		PROC_EVENT_COREDUMP = 0x40000000,
@@ -112,6 +113,26 @@ struct proc_event {
 			char           comm[16];
 		} comm;
 
+		/* There are 7 kind of namespaces */
+		#define MAX_NS_PROC_EVENT_COUNT 7
+		struct ns_proc_event {
+			__kernel_pid_t process_pid;
+			__kernel_pid_t process_tgid;
+			enum reason {
+				PROC_NS_REASON_CLONE   = 0x00000001,
+				PROC_NS_REASON_SETNS   = 0x00000002,
+				PROC_NS_REASON_UNSHARE = 0x00000003,
+				PROC_NS_REASON_LAST    = 0x80000000,
+			} reason;
+			__u32 count;
+			struct {
+				__u32 type;   /* CLONE_NEWNS, CLONE_NEWPID, ... */
+				__u32 flags;  /* unused */
+				__u64 old_inum;
+				__u64 inum;
+			} items[MAX_NS_PROC_EVENT_COUNT];
+		} ns;
+
 		struct coredump_proc_event {
 			__kernel_pid_t process_pid;
 			__kernel_pid_t process_tgid;
diff --git a/kernel/fork.c b/kernel/fork.c
index beb3172..a625394 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1759,6 +1759,7 @@ long _do_fork(unsigned long clone_flags,
 	struct task_struct *p;
 	int trace = 0;
 	long nr;
+	struct ns_event_prepare ns_event;
 
 	/*
 	 * Determine whether and which event to report to ptracer.  When
@@ -1778,8 +1779,11 @@ long _do_fork(unsigned long clone_flags,
 			trace = 0;
 	}
 
+	proc_ns_connector_prepare(&ns_event, PROC_NS_REASON_CLONE);
 	p = copy_process(clone_flags, stack_start, stack_size,
 			 child_tidptr, NULL, trace, tls, NUMA_NO_NODE);
+	proc_ns_connector_send(&ns_event, p);
+
 	/*
 	 * Do this prior waking up the new thread - the thread pointer
 	 * might get invalid after that point, if the thread exits quickly.
@@ -2024,6 +2028,7 @@ SYSCALL_DEFINE1(unshare, unsigned long, unshare_flags)
 	struct nsproxy *new_nsproxy = NULL;
 	int do_sysvsem = 0;
 	int err;
+	struct ns_event_prepare ns_event;
 
 	/*
 	 * If unsharing a user namespace must also unshare the thread group
@@ -2050,6 +2055,9 @@ SYSCALL_DEFINE1(unshare, unsigned long, unshare_flags)
 	err = check_unshare_flags(unshare_flags);
 	if (err)
 		goto bad_unshare_out;
+
+	proc_ns_connector_prepare(&ns_event, PROC_NS_REASON_UNSHARE);
+
 	/*
 	 * CLONE_NEWIPC must also detach from the undolist: after switching
 	 * to a new ipc namespace, the semaphore arrays from the old
@@ -2115,6 +2123,8 @@ SYSCALL_DEFINE1(unshare, unsigned long, unshare_flags)
 		}
 	}
 
+	proc_ns_connector_send(&ns_event, current);
+
 bad_unshare_cleanup_cred:
 	if (new_cred)
 		put_cred(new_cred);
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 782102e..16721fa 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -26,6 +26,7 @@
 #include <linux/file.h>
 #include <linux/syscalls.h>
 #include <linux/cgroup.h>
+#include <linux/cn_proc.h>
 
 static struct kmem_cache *nsproxy_cachep;
 
@@ -239,6 +240,7 @@ SYSCALL_DEFINE2(setns, int, fd, int, nstype)
 	struct nsproxy *new_nsproxy;
 	struct file *file;
 	struct ns_common *ns;
+	struct ns_event_prepare ns_event;
 	int err;
 
 	file = proc_ns_fget(fd);
@@ -250,6 +252,8 @@ SYSCALL_DEFINE2(setns, int, fd, int, nstype)
 	if (nstype && (ns->ops->type != nstype))
 		goto out;
 
+	proc_ns_connector_prepare(&ns_event, PROC_NS_REASON_SETNS);
+
 	new_nsproxy = create_new_namespaces(0, tsk, current_user_ns(), tsk->fs);
 	if (IS_ERR(new_nsproxy)) {
 		err = PTR_ERR(new_nsproxy);
@@ -262,6 +266,8 @@ SYSCALL_DEFINE2(setns, int, fd, int, nstype)
 		goto out;
 	}
 	switch_task_namespaces(tsk, new_nsproxy);
+
+	proc_ns_connector_send(&ns_event, current);
 out:
 	fput(file);
 	return err;
-- 
2.7.4

From: Alban Crequy <alban.crequy@gmail.com>
Subject: [PATCH] [RFC] proc connector: add namespace events
Date: Thu,  8 Sep 2016 11:38:06 -0400
Message-ID: <1473349086-31260-1-git-send-email-alban@kinvolk.io>
Cc: Evgeniy Polyakov <zbr@ioremap.net>, Tejun Heo <tj@kernel.org>,
        Aditya Kali <adityakali@google.com>,
        Serge Hallyn <serge.hallyn@canonical.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Iago Lopez Galeiras <iago@kinvolk.io>
To: Alban Crequy <alban@kinvolk.io>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alban Crequy <alban@kinvolk.io>

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

This patch add namespace events for processes. It generates a namespace
event each time a process changes namespace via clone(), unshare() or
setns().

For example, the following command:
| # unshare -n -f ls -l /proc/self/ns/net
| lrwxrwxrwx 1 root root 0 Sep  6 05:35 /proc/self/ns/net -> 'net:[4026532142]'

causes the proc connector to generate the following events:
| fork: ppid=696 pid=858
| exec: pid=858
| ns: pid=858 type=net reason=set old_inum=4026531957 inum=4026532142
| fork: ppid=858 pid=859
| exec: pid=859
| exit: pid=859
| exit: pid=858

Note: this patch is just a RFC, we are exploring other ways to achieve
      the same feature.

The current implementation has the following limitations:

- Ideally, I want to know whether the event is cause by clone(),
  unshare() or setns(). At the moment, the reason field only
  distinguishes between clone() and non-clone.

- The event for pid namespaces is generated when pid_ns_for_children
  changes. I think that's ok, and it just needs to be documented for
  userspace in the same way it is already documented in
  pid_namespaces(7). Userspace really needs to know whether the event is
  caused by clone() or non-clone to interpret the event correctly.

- Events for userns are not implemented yet. I skipped it for now
  because user namespaces are not managed with nsproxy as other namespaces.

- The mnt namespace struct is more private than other so the code is a
  bit different for this. I don't know if there is a better way to do
  this.

- Userspace needs a way to know whether namespace events are implemented
  in the proc connector. If not implemented, userspaces needs to
  fallback to polling changes in /proc/*/ns/*. I am not sure whether to
  add a Netlink message to query the kernel if the feature is implemented
  or otherwise.

- There is no granularity when subscribing for proc connector events. I
  figured it might not be a problem since namespace events are more rare
  than other fork/exec events. It will probably not flood existing users
  of the proc connector.

Signed-off-by: Alban Crequy <alban@kinvolk.io>
---
 drivers/connector/cn_proc.c  | 28 +++++++++++++++++
 include/linux/cn_proc.h      |  4 +++
 include/uapi/linux/cn_proc.h | 16 +++++++++-
 kernel/nsproxy.c             | 71 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 118 insertions(+), 1 deletion(-)

diff --git a/drivers/connector/cn_proc.c b/drivers/connector/cn_proc.c
index a782ce8..69e6815 100644
--- a/drivers/connector/cn_proc.c
+++ b/drivers/connector/cn_proc.c
@@ -246,6 +246,34 @@ void proc_comm_connector(struct task_struct *task)
 	send_msg(msg);
 }
 
+void proc_ns_connector(struct task_struct *task, int type, int reason, u64 old_inum, u64 inum)
+{
+	struct cn_msg *msg;
+	struct proc_event *ev;
+	__u8 buffer[CN_PROC_MSG_SIZE] __aligned(8);
+
+	if (atomic_read(&proc_event_num_listeners) < 1)
+		return;
+
+	msg = buffer_to_cn_msg(buffer);
+	ev = (struct proc_event *)msg->data;
+	memset(&ev->event_data, 0, sizeof(ev->event_data));
+	ev->timestamp_ns = ktime_get_ns();
+	ev->what = PROC_EVENT_NM;
+	ev->event_data.nm.process_pid  = task->pid;
+	ev->event_data.nm.process_tgid = task->tgid;
+	ev->event_data.nm.type = type;
+	ev->event_data.nm.reason = reason;
+	ev->event_data.nm.old_inum = old_inum;
+	ev->event_data.nm.inum = inum;
+
+	memcpy(&msg->id, &cn_proc_event_id, sizeof(msg->id));
+	msg->ack = 0; /* not used */
+	msg->len = sizeof(*ev);
+	msg->flags = 0; /* not used */
+	send_msg(msg);
+}
+
 void proc_coredump_connector(struct task_struct *task)
 {
 	struct cn_msg *msg;
diff --git a/include/linux/cn_proc.h b/include/linux/cn_proc.h
index 1d5b02a..2e6915e 100644
--- a/include/linux/cn_proc.h
+++ b/include/linux/cn_proc.h
@@ -26,6 +26,7 @@ void proc_id_connector(struct task_struct *task, int which_id);
 void proc_sid_connector(struct task_struct *task);
 void proc_ptrace_connector(struct task_struct *task, int which_id);
 void proc_comm_connector(struct task_struct *task);
+void proc_ns_connector(struct task_struct *task, int type, int change, u64 old_inum, u64 inum);
 void proc_coredump_connector(struct task_struct *task);
 void proc_exit_connector(struct task_struct *task);
 #else
@@ -45,6 +46,9 @@ static inline void proc_sid_connector(struct task_struct *task)
 static inline void proc_comm_connector(struct task_struct *task)
 {}
 
+static inline void proc_ns_connector(struct task_struct *task, int type, int change, u64 old_inum, u64 inum)
+{}
+
 static inline void proc_ptrace_connector(struct task_struct *task,
 					 int ptrace_id)
 {}
diff --git a/include/uapi/linux/cn_proc.h b/include/uapi/linux/cn_proc.h
index f6c2710..95607304 100644
--- a/include/uapi/linux/cn_proc.h
+++ b/include/uapi/linux/cn_proc.h
@@ -55,7 +55,8 @@ struct proc_event {
 		PROC_EVENT_SID  = 0x00000080,
 		PROC_EVENT_PTRACE = 0x00000100,
 		PROC_EVENT_COMM = 0x00000200,
-		/* "next" should be 0x00000400 */
+		PROC_EVENT_NM   = 0x00000400,
+		/* "next" should be 0x00000800 */
 		/* "last" is the last process event: exit,
 		 * while "next to last" is coredumping event */
 		PROC_EVENT_COREDUMP = 0x40000000,
@@ -112,6 +113,19 @@ struct proc_event {
 			char           comm[16];
 		} comm;
 
+		struct nm_proc_event {
+			__kernel_pid_t process_pid;
+			__kernel_pid_t process_tgid;
+			__u32 type;   /* CLONE_NEWNS, CLONE_NEWPID, ... */
+			enum reason {
+				PROC_NM_REASON_CLONE = 0x00000001,
+				PROC_NM_REASON_SET   = 0x00000002, /* setns or unshare */
+				PROC_NM_REASON_LAST  = 0x80000000,
+			} reason;
+			__u64 old_inum;
+			__u64 inum;
+		} nm;
+
 		struct coredump_proc_event {
 			__kernel_pid_t process_pid;
 			__kernel_pid_t process_tgid;
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 782102e..34306f7 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -26,6 +26,7 @@
 #include <linux/file.h>
 #include <linux/syscalls.h>
 #include <linux/cgroup.h>
+#include <linux/cn_proc.h>
 
 static struct kmem_cache *nsproxy_cachep;
 
@@ -139,6 +140,8 @@ int copy_namespaces(unsigned long flags, struct task_struct *tsk)
 	struct nsproxy *old_ns = tsk->nsproxy;
 	struct user_namespace *user_ns = task_cred_xxx(tsk, user_ns);
 	struct nsproxy *new_ns;
+	struct ns_common *mntns;
+	u64 old_mntns_inum = 0;
 
 	if (likely(!(flags & (CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC |
 			      CLONE_NEWPID | CLONE_NEWNET |
@@ -165,7 +168,41 @@ int copy_namespaces(unsigned long flags, struct task_struct *tsk)
 	if (IS_ERR(new_ns))
 		return  PTR_ERR(new_ns);
 
+	mntns = mntns_operations.get(tsk);
+	if (mntns) {
+		old_mntns_inum = mntns->inum;
+		mntns_operations.put(mntns);
+	}
+
 	tsk->nsproxy = new_ns;
+
+	if (old_ns && new_ns) {
+		struct ns_common *mntns;
+		u64 new_mntns_inum = 0;
+		mntns = mntns_operations.get(tsk);
+		if (mntns) {
+			new_mntns_inum = mntns->inum;
+			mntns_operations.put(mntns);
+		}
+		if (old_ns->mnt_ns != new_ns->mnt_ns)
+			proc_ns_connector(tsk, CLONE_NEWNS, PROC_NM_REASON_CLONE, old_mntns_inum, new_mntns_inum);
+
+		if (old_ns->uts_ns != new_ns->uts_ns)
+			proc_ns_connector(tsk, CLONE_NEWUTS, PROC_NM_REASON_CLONE, old_ns->uts_ns->ns.inum, new_ns->uts_ns->ns.inum);
+
+		if (old_ns->ipc_ns != new_ns->ipc_ns)
+			proc_ns_connector(tsk, CLONE_NEWIPC, PROC_NM_REASON_CLONE, old_ns->ipc_ns->ns.inum, new_ns->ipc_ns->ns.inum);
+
+		if (old_ns->net_ns != new_ns->net_ns)
+			proc_ns_connector(tsk, CLONE_NEWNET, PROC_NM_REASON_CLONE, old_ns->net_ns->ns.inum, new_ns->net_ns->ns.inum);
+
+		if (old_ns->cgroup_ns != new_ns->cgroup_ns)
+			proc_ns_connector(tsk, CLONE_NEWCGROUP, PROC_NM_REASON_CLONE, old_ns->cgroup_ns->ns.inum, new_ns->cgroup_ns->ns.inum);
+
+		if (old_ns->pid_ns_for_children != new_ns->pid_ns_for_children)
+			proc_ns_connector(tsk, CLONE_NEWPID, PROC_NM_REASON_CLONE, old_ns->pid_ns_for_children->ns.inum, new_ns->pid_ns_for_children->ns.inum);
+	}
+
 	return 0;
 }
 
@@ -216,14 +253,48 @@ out:
 void switch_task_namespaces(struct task_struct *p, struct nsproxy *new)
 {
 	struct nsproxy *ns;
+	struct ns_common *mntns;
+	u64 old_mntns_inum = 0;
 
 	might_sleep();
 
+	mntns = mntns_operations.get(p);
+	if (mntns) {
+		old_mntns_inum = mntns->inum;
+		mntns_operations.put(mntns);
+	}
+
 	task_lock(p);
 	ns = p->nsproxy;
 	p->nsproxy = new;
 	task_unlock(p);
 
+	if (ns && new) {
+		u64 new_mntns_inum = 0;
+		mntns = mntns_operations.get(p);
+		if (mntns) {
+			new_mntns_inum = mntns->inum;
+			mntns_operations.put(mntns);
+		}
+		if (ns->mnt_ns != new->mnt_ns)
+			proc_ns_connector(p, CLONE_NEWNS, PROC_NM_REASON_SET, old_mntns_inum, new_mntns_inum);
+
+		if (ns->uts_ns != new->uts_ns)
+			proc_ns_connector(p, CLONE_NEWUTS, PROC_NM_REASON_SET, ns->uts_ns->ns.inum, new->uts_ns->ns.inum);
+
+		if (ns->ipc_ns != new->ipc_ns)
+			proc_ns_connector(p, CLONE_NEWIPC, PROC_NM_REASON_SET, ns->ipc_ns->ns.inum, new->ipc_ns->ns.inum);
+
+		if (ns->net_ns != new->net_ns)
+			proc_ns_connector(p, CLONE_NEWNET, PROC_NM_REASON_SET, ns->net_ns->ns.inum, new->net_ns->ns.inum);
+
+		if (ns->cgroup_ns != new->cgroup_ns)
+			proc_ns_connector(p, CLONE_NEWCGROUP, PROC_NM_REASON_SET, ns->cgroup_ns->ns.inum, new->cgroup_ns->ns.inum);
+
+		if (ns->pid_ns_for_children != new->pid_ns_for_children)
+			proc_ns_connector(p, CLONE_NEWPID, PROC_NM_REASON_SET, ns->pid_ns_for_children->ns.inum, new->pid_ns_for_children->ns.inum);
+	}
+
 	if (ns && atomic_dec_and_test(&ns->count))
 		free_nsproxy(ns);
 }
-- 
2.7.4

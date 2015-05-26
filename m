From: Dimitri John Ledkov <dimitri.j.ledkov-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/2] connector: add cgroup release event report to proc connector
Date: Tue, 26 May 2015 23:07:30 +0100
Message-ID: <1432678051-4372-1-git-send-email-dimitri.j.ledkov@intel.com>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add a kernel API to send a proc connector notification that a cgroup
has become empty. A userspace daemon can then act upon such
information, and usually clean-up and remove such a group as it's no
longer needed.

Currently there are two other ways (one for current & one for unified
cgroups) to receive such notifications, but they either involve
spawning userspace helper or monitoring a lot of files. This is a
firehose of all such events instead from a single place.

In the current cgroups structure the way to get notifications is by
enabling `release_agent' and setting `notify_on_release' for a given
cgroup hierarchy. This will then spawn userspace helper with removed
cgroup as an argument. It has been acknowledged that this is
expensive, especially in the exit-heavy workloads. In userspace this
is currently used by systemd and CGmanager that I know of, both of
agents establish connection to the long running daemon and pass the
message to it. As a courtesy to other processes, such an event is
sometimes forwarded further on, e.g. systemd forwards it to the system
DBus.

In the future/unified cgroups structure support for `release_agent' is
removed, without a direct replacement. However, there is a new
`cgroup.populated' file exposed that recursively reports if there are
any tasks in a given cgroup hierarchy. It's a very good flag to
quickly/lazily scan for empty things, however one would need to
establish inotify watch on each and every cgroup.populated file at
cgroup setup time (ideally before any pids enter said cgroup). Thus
again anybody else, but the original creator of a given cgroup, has a
chance to reliably monitor cgroup becoming empty (since there is no
reliable recursive inotify watch).

Hence, the addition to the proc connector firehose. Multiple things,
albeit with a CAP_NET_ADMIN in the init pid/user namespace), could
connect and monitor cgroups release notifications. In a way, this
repeats udev history, at first it was a userspace helper, which later
became a netlink socket. And I hope, that proc connector is a
naturally good fit for this notification type.

For precisely when cgroups should emit this event, see next patch
against kernel/cgroup.c.

Signed-off-by: Dimitri John Ledkov <dimitri.j.ledkov-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/connector/cn_proc.c  | 56 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/cn_proc.h      |  6 +++++
 include/uapi/linux/cn_proc.h |  8 ++++++-
 3 files changed, 69 insertions(+), 1 deletion(-)

diff --git a/drivers/connector/cn_proc.c b/drivers/connector/cn_proc.c
index 15d06fc..ef71bd9 100644
--- a/drivers/connector/cn_proc.c
+++ b/drivers/connector/cn_proc.c
@@ -31,6 +31,7 @@
 #include <linux/ptrace.h>
 #include <linux/atomic.h>
 #include <linux/pid_namespace.h>
+#include <linux/cgroup.h>
 
 #include <linux/cn_proc.h>
 
@@ -244,6 +245,61 @@ void proc_comm_connector(struct task_struct *task)
 	cn_netlink_send(msg, 0, CN_IDX_PROC, GFP_KERNEL);
 }
 
+void proc_cgrelease_connector(struct cgroup *cgrp)
+{
+	struct cn_msg *msg;
+	struct proc_event *ev;
+	char *path_buffer, *path;
+	__u8 *buffer;
+	__u8 length;
+
+	if (atomic_read(&proc_event_num_listeners) < 1)
+		return;
+
+	/* ENOMEM */
+	path_buffer = kmalloc(PATH_MAX, GFP_KERNEL);
+	if (!path_buffer)
+		return;
+
+	/* ENAMETOOLONG */
+	path = cgroup_path(cgrp, path_buffer, PATH_MAX);
+	if (!path)
+		goto out_path_buffer;
+
+	length = strlen(path);
+
+	buffer = kmalloc(CN_PROC_MSG_SIZE + length, GFP_KERNEL);
+	if (!buffer)
+		goto out_path_buffer;
+
+	msg = buffer_to_cn_msg(buffer);
+	ev = (struct proc_event *)msg->data;
+	memset(&ev->event_data, 0, sizeof(ev->event_data) + length);
+	get_seq(&msg->seq, &ev->cpu);
+	ev->timestamp_ns = ktime_get_ns();
+	ev->what = PROC_EVENT_CGROUP_RELEASE;
+
+	/* If MAX_CGROUP_ROOT_NAMELEN is ever increased,
+	 * ./include/uapi/linux/cn_proc.h will need an update */
+	BUILD_BUG_ON(MAX_CGROUP_ROOT_NAMELEN > 64);
+	memcpy(ev->event_data.cgroup_release.cgroup_root,
+	       cgrp->root->name,
+	       MAX_CGROUP_ROOT_NAMELEN);
+
+	memcpy(ev->event_data.cgroup_release.cgroup_path, path, length);
+
+	memcpy(&msg->id, &cn_proc_event_id, sizeof(msg->id));
+	msg->ack = 0; /* not used */
+	msg->len = sizeof(*ev) + length;
+	msg->flags = 0; /* not used */
+	cn_netlink_send(msg, 0, CN_IDX_PROC, GFP_KERNEL);
+
+	kfree(buffer);
+
+out_path_buffer:
+	kfree(path_buffer);
+}
+
 void proc_coredump_connector(struct task_struct *task)
 {
 	struct cn_msg *msg;
diff --git a/include/linux/cn_proc.h b/include/linux/cn_proc.h
index 1d5b02a..cf7cc56 100644
--- a/include/linux/cn_proc.h
+++ b/include/linux/cn_proc.h
@@ -19,6 +19,8 @@
 
 #include <uapi/linux/cn_proc.h>
 
+struct cgroup;
+
 #ifdef CONFIG_PROC_EVENTS
 void proc_fork_connector(struct task_struct *task);
 void proc_exec_connector(struct task_struct *task);
@@ -28,6 +30,7 @@ void proc_ptrace_connector(struct task_struct *task, int which_id);
 void proc_comm_connector(struct task_struct *task);
 void proc_coredump_connector(struct task_struct *task);
 void proc_exit_connector(struct task_struct *task);
+void proc_cgrelease_connector(struct cgroup *cgrp);
 #else
 static inline void proc_fork_connector(struct task_struct *task)
 {}
@@ -54,5 +57,8 @@ static inline void proc_coredump_connector(struct task_struct *task)
 
 static inline void proc_exit_connector(struct task_struct *task)
 {}
+
+static inline void proc_cgrelease_connector(struct cgroup *cgrp)
+{}
 #endif	/* CONFIG_PROC_EVENTS */
 #endif	/* CN_PROC_H */
diff --git a/include/uapi/linux/cn_proc.h b/include/uapi/linux/cn_proc.h
index f6c2710..bed7b6b 100644
--- a/include/uapi/linux/cn_proc.h
+++ b/include/uapi/linux/cn_proc.h
@@ -55,7 +55,8 @@ struct proc_event {
 		PROC_EVENT_SID  = 0x00000080,
 		PROC_EVENT_PTRACE = 0x00000100,
 		PROC_EVENT_COMM = 0x00000200,
-		/* "next" should be 0x00000400 */
+		PROC_EVENT_CGROUP_RELEASE = 0x00000400,
+		/* "next" should be 0x00000800 */
 		/* "last" is the last process event: exit,
 		 * while "next to last" is coredumping event */
 		PROC_EVENT_COREDUMP = 0x40000000,
@@ -123,6 +124,11 @@ struct proc_event {
 			__u32 exit_code, exit_signal;
 		} exit;
 
+		struct cgroup_release_proc_event {
+			char cgroup_root[64];
+			char cgroup_path[];
+		} cgroup_release;
+
 	} event_data;
 };
 
-- 
2.1.4

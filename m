From: Alban Crequy <alban.crequy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [RFC v2 2/2] proc connector: add a "get feature" op
Date: Sat, 15 Oct 2016 14:26:10 +0200
Message-ID: <1476534370-4027-3-git-send-email-alban@kinvolk.io>
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

As more kinds of events are being added in the proc connector, userspace
needs a way to detect whether the kernel supports those new events.

When a kind of event is not supported, userspace should report an error
propertly, or fallback to other methods (regular polling of procfs).

The events fork, exec, uid, gid, sid, ptrace, comm, exit were added
together. Then commit 2b5faa4c ("connector: Added coredumping event to
the process connector") added coredump events but without a way for
userspace to detect if the kernel will emit those. So I am grouping
them all together in PROC_CN_FEATURE_BASIC.

- PROC_CN_FEATURE_BASIC: supports fork, exec, uid, gid, sid, ptrace,
  comm, exit, coredump.

- PROC_CN_FEATURE_NS: supports ns.

Signed-off-by: Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
---
 drivers/connector/cn_proc.c  | 25 +++++++++++++++----------
 include/uapi/linux/cn_proc.h |  4 ++++
 2 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/drivers/connector/cn_proc.c b/drivers/connector/cn_proc.c
index c38733d..5f9ace6 100644
--- a/drivers/connector/cn_proc.c
+++ b/drivers/connector/cn_proc.c
@@ -442,15 +442,12 @@ void proc_ns_connector_send(struct ns_event_prepare *prepare, struct task_struct
  * values because it's not being returned via syscall return
  * mechanisms.
  */
-static void cn_proc_ack(int err, int rcvd_seq, int rcvd_ack)
+static void cn_proc_ack(int err, u16 flags, int rcvd_seq, int rcvd_ack)
 {
 	struct cn_msg *msg;
 	struct proc_event *ev;
 	__u8 buffer[CN_PROC_MSG_SIZE] __aligned(8);
 
-	if (atomic_read(&proc_event_num_listeners) < 1)
-		return;
-
 	msg = buffer_to_cn_msg(buffer);
 	ev = (struct proc_event *)msg->data;
 	memset(&ev->event_data, 0, sizeof(ev->event_data));
@@ -462,7 +459,7 @@ static void cn_proc_ack(int err, int rcvd_seq, int rcvd_ack)
 	memcpy(&msg->id, &cn_proc_event_id, sizeof(msg->id));
 	msg->ack = rcvd_ack + 1;
 	msg->len = sizeof(*ev);
-	msg->flags = 0; /* not used */
+	msg->flags = flags;
 	send_msg(msg);
 }
 
@@ -475,9 +472,12 @@ static void cn_proc_mcast_ctl(struct cn_msg *msg,
 {
 	enum proc_cn_mcast_op *mc_op = NULL;
 	int err = 0;
+	u16 flags = 0;
 
-	if (msg->len != sizeof(*mc_op))
-		return;
+	if (msg->len != sizeof(*mc_op)) {
+		err = EINVAL;
+		goto out;
+	}
 
 	/* 
 	 * Events are reported with respect to the initial pid
@@ -485,8 +485,10 @@ static void cn_proc_mcast_ctl(struct cn_msg *msg,
 	 * other namespaces.
 	 */
 	if ((current_user_ns() != &init_user_ns) ||
-	    (task_active_pid_ns(current) != &init_pid_ns))
-		return;
+	    (task_active_pid_ns(current) != &init_pid_ns)) {
+		err = EPERM;
+		goto out;
+	}
 
 	/* Can only change if privileged. */
 	if (!__netlink_ns_capable(nsp, &init_user_ns, CAP_NET_ADMIN)) {
@@ -496,6 +498,9 @@ static void cn_proc_mcast_ctl(struct cn_msg *msg,
 
 	mc_op = (enum proc_cn_mcast_op *)msg->data;
 	switch (*mc_op) {
+	case PROC_CN_GET_FEATURES:
+		flags = PROC_CN_FEATURE_BASIC | PROC_CN_FEATURE_NS;
+		break;
 	case PROC_CN_MCAST_LISTEN:
 		atomic_inc(&proc_event_num_listeners);
 		break;
@@ -508,7 +513,7 @@ static void cn_proc_mcast_ctl(struct cn_msg *msg,
 	}
 
 out:
-	cn_proc_ack(err, msg->seq, msg->ack);
+	cn_proc_ack(err, flags, msg->seq, msg->ack);
 }
 
 /*
diff --git a/include/uapi/linux/cn_proc.h b/include/uapi/linux/cn_proc.h
index 3270e8c..2ea0e5d 100644
--- a/include/uapi/linux/cn_proc.h
+++ b/include/uapi/linux/cn_proc.h
@@ -25,10 +25,14 @@
  * for events on the connector.
  */
 enum proc_cn_mcast_op {
+	PROC_CN_GET_FEATURES = 0,
 	PROC_CN_MCAST_LISTEN = 1,
 	PROC_CN_MCAST_IGNORE = 2
 };
 
+#define PROC_CN_FEATURE_BASIC 0x0001
+#define PROC_CN_FEATURE_NS    0x0002
+
 /*
  * From the user's point of view, the process
  * ID is the thread group ID and thread ID is the internal
-- 
2.7.4

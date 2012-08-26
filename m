From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 06/15] userns: Convert audit to use kuid and kgid where appropriate
Date: Sun, 26 Aug 2012 06:00:13 -0700
Message-ID: <87y5l1byg2.fsf@xmission.com>
References: <87lih2h6i4.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	David Miller <davem@davemloft.net>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Eric Paris <eparis@redhat.com>,
	Paul Moore <paul@paul-moore.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87lih2h6i4.fsf@xmission.com> (Eric W. Biederman's message of
	"Sat, 25 Aug 2012 16:54:59 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


- Explicitly deny permission for audit messages sent from processes
  outside of the initial pid or user namespace.  This removes the need
  to format audit messages in other the initial user and pid namespaces.

- Explicitly format uids gids in audit messges in the initial user
  namespace. This is safe because auditd is restrected to be in
  the initial user namespace.

- Expliclty format pids in audit messages in the initial pid namespace.
  This is safe because auditd is restricted to be in the initial pid
  namespace.

- Modify audit_get_loginuid to return a kuid
- Modify /proc/<pid>/loginuid on read to convert the loginuid
  into the user namespace of the opener of the file.
- Modify /proc/<pid>/loginud on write to convert the loginuid
  from the user namespace of the opener of the file.

- In audit_krule store kuid_t values in a new uid field.  Allowing
  type safety when filtering on uids.
- In audit_krule store kgidt_t values in a new gid field.  Allowing
  type safety when filtering on gids.

- Get caller process uid and gid from the current task instead of the
  NETLINK_CB.  This results in simpler code yielding kuid_t and kgid_t
  values.  This is safe because netlink requests are now all processed
  in the task of the sender.

- Convert audit_sig_uid into a kuid_t.

- Deny bitmask comparisons of uids and gids

- Introduce audit_uid_comparitor and audit_gid_compartor typesafe
  variants of audit_compartor without the bitmask operations.

- Replace audit_compare_id with audit_compare_uid and audit_compare_gid.
  This is one of those odd cases where being type safe and duplicating
  code leads to simpler short and more concise code.

- For uid comparisons replace audit_comparator with audit_uid comparator.
- For gid comparisons replace audit_comparator with audit_gid_comparator.

The net result is that the audit subsystem now uses kuid_t and kgid_t whenever
possible making it almost impossible to confuse a raw uid_t with a kuid_t
preventing bugs.

Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Eric Paris <eparis@redhat.com>
Cc: Paul Moore <paul@paul-moore.com>
Cc: David Miller <davem@davemloft.net>
Cc: Greg Kroah-Hartman <gregkh@suse.de>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---

Apologies if you are receiving this twice.  I am resending because
it looks like this message failed to be delivered to most of it's
recepients.

 drivers/tty/tty_audit.c           |   16 ++--
 fs/proc/base.c                    |   12 ++-
 include/linux/audit.h             |   12 ++-
 include/linux/init_task.h         |    2 +-
 include/linux/sched.h             |    2 +-
 include/linux/tty.h               |    4 +-
 include/net/netlabel.h            |    2 +-
 include/net/xfrm.h                |   23 ++--
 init/Kconfig                      |    2 -
 kernel/audit.c                    |   42 +++++---
 kernel/audit.h                    |    4 +-
 kernel/audit_watch.c              |    2 +-
 kernel/auditfilter.c              |  142 +++++++++++++++++++++----
 kernel/auditsc.c                  |  214 +++++++++++++++++++------------------
 net/core/dev.c                    |    2 +-
 net/netlabel/netlabel_unlabeled.c |    2 +-
 net/netlabel/netlabel_user.c      |    2 +-
 net/xfrm/xfrm_policy.c            |    8 +-
 net/xfrm/xfrm_state.c             |    6 +-
 net/xfrm/xfrm_user.c              |   12 +-
 20 files changed, 320 insertions(+), 191 deletions(-)

diff --git a/drivers/tty/tty_audit.c b/drivers/tty/tty_audit.c
index 7c58669..e6b2422 100644
--- a/drivers/tty/tty_audit.c
+++ b/drivers/tty/tty_audit.c
@@ -61,7 +61,7 @@ static void tty_audit_buf_put(struct tty_audit_buf *buf)
 }
 
 static void tty_audit_log(const char *description, struct task_struct *tsk,
-			  uid_t loginuid, unsigned sessionid, int major,
+			  kuid_t loginuid, unsigned sessionid, int major,
 			  int minor, unsigned char *data, size_t size)
 {
 	struct audit_buffer *ab;
@@ -69,11 +69,13 @@ static void tty_audit_log(const char *description, struct task_struct *tsk,
 	ab = audit_log_start(NULL, GFP_KERNEL, AUDIT_TTY);
 	if (ab) {
 		char name[sizeof(tsk->comm)];
-		uid_t uid = task_uid(tsk);
+		uid_t uid = from_kuid_munged(&init_user_ns, task_uid(tsk));
 
 		audit_log_format(ab, "%s pid=%u uid=%u auid=%u ses=%u "
 				 "major=%d minor=%d comm=", description,
-				 tsk->pid, uid, loginuid, sessionid,
+				 tsk->pid, uid,
+				 from_kuid(&init_user_ns, loginuid),
+				 sessionid,
 				 major, minor);
 		get_task_comm(name, tsk);
 		audit_log_untrustedstring(ab, name);
@@ -89,7 +91,7 @@ static void tty_audit_log(const char *description, struct task_struct *tsk,
  *	Generate an audit message from the contents of @buf, which is owned by
  *	@tsk with @loginuid.  @buf->mutex must be locked.
  */
-static void tty_audit_buf_push(struct task_struct *tsk, uid_t loginuid,
+static void tty_audit_buf_push(struct task_struct *tsk, kuid_t loginuid,
 			       unsigned int sessionid,
 			       struct tty_audit_buf *buf)
 {
@@ -112,7 +114,7 @@ static void tty_audit_buf_push(struct task_struct *tsk, uid_t loginuid,
  */
 static void tty_audit_buf_push_current(struct tty_audit_buf *buf)
 {
-	uid_t auid = audit_get_loginuid(current);
+	kuid_t auid = audit_get_loginuid(current);
 	unsigned int sessionid = audit_get_sessionid(current);
 	tty_audit_buf_push(current, auid, sessionid, buf);
 }
@@ -179,7 +181,7 @@ void tty_audit_tiocsti(struct tty_struct *tty, char ch)
 	}
 
 	if (should_audit && audit_enabled) {
-		uid_t auid;
+		kuid_t auid;
 		unsigned int sessionid;
 
 		auid = audit_get_loginuid(current);
@@ -199,7 +201,7 @@ void tty_audit_tiocsti(struct tty_struct *tty, char ch)
  * reference to the tty audit buffer if available.
  * Flush the buffer or return an appropriate error code.
  */
-int tty_audit_push_task(struct task_struct *tsk, uid_t loginuid, u32 sessionid)
+int tty_audit_push_task(struct task_struct *tsk, kuid_t loginuid, u32 sessionid)
 {
 	struct tty_audit_buf *buf = ERR_PTR(-EPERM);
 	unsigned long flags;
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 1b6c84c..138cff4 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1089,7 +1089,8 @@ static ssize_t proc_loginuid_read(struct file * file, char __user * buf,
 	if (!task)
 		return -ESRCH;
 	length = scnprintf(tmpbuf, TMPBUFLEN, "%u",
-				audit_get_loginuid(task));
+			   from_kuid(file->f_cred->user_ns,
+				     audit_get_loginuid(task)));
 	put_task_struct(task);
 	return simple_read_from_buffer(buf, count, ppos, tmpbuf, length);
 }
@@ -1101,6 +1102,7 @@ static ssize_t proc_loginuid_write(struct file * file, const char __user * buf,
 	char *page, *tmp;
 	ssize_t length;
 	uid_t loginuid;
+	kuid_t kloginuid;
 
 	rcu_read_lock();
 	if (current != pid_task(proc_pid(inode), PIDTYPE_PID)) {
@@ -1130,7 +1132,13 @@ static ssize_t proc_loginuid_write(struct file * file, const char __user * buf,
 		goto out_free_page;
 
 	}
-	length = audit_set_loginuid(loginuid);
+	kloginuid = make_kuid(file->f_cred->user_ns, loginuid);
+	if (!uid_valid(kloginuid)) {
+		length = -EINVAL;
+		goto out_free_page;
+	}
+
+	length = audit_set_loginuid(kloginuid);
 	if (likely(length == 0))
 		length = count;
 
diff --git a/include/linux/audit.h b/include/linux/audit.h
index 36abf2a..4af8ba7 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -442,6 +442,8 @@ struct audit_krule {
 struct audit_field {
 	u32				type;
 	u32				val;
+	kuid_t				uid;
+	kgid_t				gid;
 	u32				op;
 	char				*lsm_str;
 	void				*lsm_rule;
@@ -525,7 +527,7 @@ static inline void audit_ptrace(struct task_struct *t)
 extern unsigned int audit_serial(void);
 extern int auditsc_get_stamp(struct audit_context *ctx,
 			      struct timespec *t, unsigned int *serial);
-extern int  audit_set_loginuid(uid_t loginuid);
+extern int  audit_set_loginuid(kuid_t loginuid);
 #define audit_get_loginuid(t) ((t)->loginuid)
 #define audit_get_sessionid(t) ((t)->sessionid)
 extern void audit_log_task_context(struct audit_buffer *ab);
@@ -637,7 +639,7 @@ extern int audit_signals;
 #define audit_core_dumps(i) do { ; } while (0)
 #define audit_seccomp(i,s,c) do { ; } while (0)
 #define auditsc_get_stamp(c,t,s) (0)
-#define audit_get_loginuid(t) (-1)
+#define audit_get_loginuid(t) (INVALID_UID)
 #define audit_get_sessionid(t) (-1)
 #define audit_log_task_context(b) do { ; } while (0)
 #define audit_ipc_obj(i) ((void)0)
@@ -700,10 +702,10 @@ extern void 		    audit_log_secctx(struct audit_buffer *ab, u32 secid);
 extern int		    audit_update_lsm_rules(void);
 
 				/* Private API (for audit.c only) */
-extern int audit_filter_user(struct netlink_skb_parms *cb);
+extern int audit_filter_user(void);
 extern int audit_filter_type(int type);
-extern int  audit_receive_filter(int type, int pid, int uid, int seq,
-				void *data, size_t datasz, uid_t loginuid,
+extern int  audit_receive_filter(int type, int pid, kuid_t uid, int seq,
+				void *data, size_t datasz, kuid_t loginuid,
 				u32 sessionid, u32 sid);
 extern int audit_enabled;
 #else
diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index 89f1cb1..6d087c5 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -92,7 +92,7 @@ extern struct group_info init_groups;
 
 #ifdef CONFIG_AUDITSYSCALL
 #define INIT_IDS \
-	.loginuid = -1, \
+	.loginuid = INVALID_UID, \
 	.sessionid = -1,
 #else
 #define INIT_IDS
diff --git a/include/linux/sched.h b/include/linux/sched.h
index c147e70..f64d092 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1426,7 +1426,7 @@ struct task_struct {
 
 	struct audit_context *audit_context;
 #ifdef CONFIG_AUDITSYSCALL
-	uid_t loginuid;
+	kuid_t loginuid;
 	unsigned int sessionid;
 #endif
 	struct seccomp seccomp;
diff --git a/include/linux/tty.h b/include/linux/tty.h
index 9f47ab5..7298385 100644
--- a/include/linux/tty.h
+++ b/include/linux/tty.h
@@ -553,7 +553,7 @@ extern void tty_audit_fork(struct signal_struct *sig);
 extern void tty_audit_tiocsti(struct tty_struct *tty, char ch);
 extern void tty_audit_push(struct tty_struct *tty);
 extern int tty_audit_push_task(struct task_struct *tsk,
-			       uid_t loginuid, u32 sessionid);
+			       kuid_t loginuid, u32 sessionid);
 #else
 static inline void tty_audit_add_data(struct tty_struct *tty,
 				      unsigned char *data, size_t size)
@@ -572,7 +572,7 @@ static inline void tty_audit_push(struct tty_struct *tty)
 {
 }
 static inline int tty_audit_push_task(struct task_struct *tsk,
-				      uid_t loginuid, u32 sessionid)
+				      kuid_t loginuid, u32 sessionid)
 {
 	return 0;
 }
diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index f674409..2c95d55 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -110,7 +110,7 @@ struct cipso_v4_doi;
 /* NetLabel audit information */
 struct netlbl_audit {
 	u32 secid;
-	uid_t loginuid;
+	kuid_t loginuid;
 	u32 sessionid;
 };
 
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index d9509eb..1f217e2 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -662,7 +662,7 @@ struct xfrm_spi_skb_cb {
 /* Audit Information */
 struct xfrm_audit {
 	u32	secid;
-	uid_t	loginuid;
+	kuid_t	loginuid;
 	u32	sessionid;
 };
 
@@ -681,13 +681,14 @@ static inline struct audit_buffer *xfrm_audit_start(const char *op)
 	return audit_buf;
 }
 
-static inline void xfrm_audit_helper_usrinfo(uid_t auid, u32 ses, u32 secid,
+static inline void xfrm_audit_helper_usrinfo(kuid_t auid, u32 ses, u32 secid,
 					     struct audit_buffer *audit_buf)
 {
 	char *secctx;
 	u32 secctx_len;
 
-	audit_log_format(audit_buf, " auid=%u ses=%u", auid, ses);
+	audit_log_format(audit_buf, " auid=%u ses=%u",
+			 from_kuid(&init_user_ns, auid), ses);
 	if (secid != 0 &&
 	    security_secid_to_secctx(secid, &secctx, &secctx_len) == 0) {
 		audit_log_format(audit_buf, " subj=%s", secctx);
@@ -697,13 +698,13 @@ static inline void xfrm_audit_helper_usrinfo(uid_t auid, u32 ses, u32 secid,
 }
 
 extern void xfrm_audit_policy_add(struct xfrm_policy *xp, int result,
-				  u32 auid, u32 ses, u32 secid);
+				  kuid_t auid, u32 ses, u32 secid);
 extern void xfrm_audit_policy_delete(struct xfrm_policy *xp, int result,
-				  u32 auid, u32 ses, u32 secid);
+				  kuid_t auid, u32 ses, u32 secid);
 extern void xfrm_audit_state_add(struct xfrm_state *x, int result,
-				 u32 auid, u32 ses, u32 secid);
+				 kuid_t auid, u32 ses, u32 secid);
 extern void xfrm_audit_state_delete(struct xfrm_state *x, int result,
-				    u32 auid, u32 ses, u32 secid);
+				    kuid_t auid, u32 ses, u32 secid);
 extern void xfrm_audit_state_replay_overflow(struct xfrm_state *x,
 					     struct sk_buff *skb);
 extern void xfrm_audit_state_replay(struct xfrm_state *x,
@@ -716,22 +717,22 @@ extern void xfrm_audit_state_icvfail(struct xfrm_state *x,
 #else
 
 static inline void xfrm_audit_policy_add(struct xfrm_policy *xp, int result,
-				  u32 auid, u32 ses, u32 secid)
+				  kuid_t auid, u32 ses, u32 secid)
 {
 }
 
 static inline void xfrm_audit_policy_delete(struct xfrm_policy *xp, int result,
-				  u32 auid, u32 ses, u32 secid)
+				  kuid_t auid, u32 ses, u32 secid)
 {
 }
 
 static inline void xfrm_audit_state_add(struct xfrm_state *x, int result,
-				 u32 auid, u32 ses, u32 secid)
+				 kuid_t auid, u32 ses, u32 secid)
 {
 }
 
 static inline void xfrm_audit_state_delete(struct xfrm_state *x, int result,
-				    u32 auid, u32 ses, u32 secid)
+				    kuid_t auid, u32 ses, u32 secid)
 {
 }
 
diff --git a/init/Kconfig b/init/Kconfig
index 4daf449..525f4e8 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -927,8 +927,6 @@ config UIDGID_CONVERTED
 	# Features
 	depends on IMA = n
 	depends on EVM = n
-	depends on AUDIT = n
-	depends on AUDITSYSCALL = n
 	depends on TASKSTATS = n
 	depends on TRACING = n
 	depends on FS_POSIX_ACL = n
diff --git a/kernel/audit.c b/kernel/audit.c
index ea3b7b6..b25afb7 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -61,6 +61,7 @@
 #include <linux/netlink.h>
 #include <linux/freezer.h>
 #include <linux/tty.h>
+#include <linux/pid_namespace.h>
 
 #include "audit.h"
 
@@ -104,7 +105,7 @@ static int	audit_backlog_wait_time = 60 * HZ;
 static int	audit_backlog_wait_overflow = 0;
 
 /* The identity of the user shutting down the audit system. */
-uid_t		audit_sig_uid = -1;
+kuid_t		audit_sig_uid = INVALID_UID;
 pid_t		audit_sig_pid = -1;
 u32		audit_sig_sid = 0;
 
@@ -264,7 +265,7 @@ void audit_log_lost(const char *message)
 }
 
 static int audit_log_config_change(char *function_name, int new, int old,
-				   uid_t loginuid, u32 sessionid, u32 sid,
+				   kuid_t loginuid, u32 sessionid, u32 sid,
 				   int allow_changes)
 {
 	struct audit_buffer *ab;
@@ -272,7 +273,7 @@ static int audit_log_config_change(char *function_name, int new, int old,
 
 	ab = audit_log_start(NULL, GFP_KERNEL, AUDIT_CONFIG_CHANGE);
 	audit_log_format(ab, "%s=%d old=%d auid=%u ses=%u", function_name, new,
-			 old, loginuid, sessionid);
+			 old, from_kuid(&init_user_ns, loginuid), sessionid);
 	if (sid) {
 		char *ctx = NULL;
 		u32 len;
@@ -292,7 +293,7 @@ static int audit_log_config_change(char *function_name, int new, int old,
 }
 
 static int audit_do_config_change(char *function_name, int *to_change,
-				  int new, uid_t loginuid, u32 sessionid,
+				  int new, kuid_t loginuid, u32 sessionid,
 				  u32 sid)
 {
 	int allow_changes, rc = 0, old = *to_change;
@@ -319,21 +320,21 @@ static int audit_do_config_change(char *function_name, int *to_change,
 	return rc;
 }
 
-static int audit_set_rate_limit(int limit, uid_t loginuid, u32 sessionid,
+static int audit_set_rate_limit(int limit, kuid_t loginuid, u32 sessionid,
 				u32 sid)
 {
 	return audit_do_config_change("audit_rate_limit", &audit_rate_limit,
 				      limit, loginuid, sessionid, sid);
 }
 
-static int audit_set_backlog_limit(int limit, uid_t loginuid, u32 sessionid,
+static int audit_set_backlog_limit(int limit, kuid_t loginuid, u32 sessionid,
 				   u32 sid)
 {
 	return audit_do_config_change("audit_backlog_limit", &audit_backlog_limit,
 				      limit, loginuid, sessionid, sid);
 }
 
-static int audit_set_enabled(int state, uid_t loginuid, u32 sessionid, u32 sid)
+static int audit_set_enabled(int state, kuid_t loginuid, u32 sessionid, u32 sid)
 {
 	int rc;
 	if (state < AUDIT_OFF || state > AUDIT_LOCKED)
@@ -348,7 +349,7 @@ static int audit_set_enabled(int state, uid_t loginuid, u32 sessionid, u32 sid)
 	return rc;
 }
 
-static int audit_set_failure(int state, uid_t loginuid, u32 sessionid, u32 sid)
+static int audit_set_failure(int state, kuid_t loginuid, u32 sessionid, u32 sid)
 {
 	if (state != AUDIT_FAIL_SILENT
 	    && state != AUDIT_FAIL_PRINTK
@@ -467,7 +468,7 @@ static int kauditd_thread(void *dummy)
 	return 0;
 }
 
-static int audit_prepare_user_tty(pid_t pid, uid_t loginuid, u32 sessionid)
+static int audit_prepare_user_tty(pid_t pid, kuid_t loginuid, u32 sessionid)
 {
 	struct task_struct *tsk;
 	int err;
@@ -588,6 +589,11 @@ static int audit_netlink_ok(struct sk_buff *skb, u16 msg_type)
 {
 	int err = 0;
 
+	/* Only support the initial namespaces for now. */
+	if ((current_user_ns() != &init_user_ns) ||
+	    (task_active_pid_ns(current) != &init_pid_ns))
+		return -EPERM;
+
 	switch (msg_type) {
 	case AUDIT_GET:
 	case AUDIT_LIST:
@@ -619,7 +625,7 @@ static int audit_netlink_ok(struct sk_buff *skb, u16 msg_type)
 }
 
 static int audit_log_common_recv_msg(struct audit_buffer **ab, u16 msg_type,
-				     u32 pid, u32 uid, uid_t auid, u32 ses,
+				     u32 pid, kuid_t uid, kuid_t auid, u32 ses,
 				     u32 sid)
 {
 	int rc = 0;
@@ -633,7 +639,10 @@ static int audit_log_common_recv_msg(struct audit_buffer **ab, u16 msg_type,
 
 	*ab = audit_log_start(NULL, GFP_KERNEL, msg_type);
 	audit_log_format(*ab, "pid=%d uid=%u auid=%u ses=%u",
-			 pid, uid, auid, ses);
+			 pid,
+			 from_kuid(&init_user_ns, uid),
+			 from_kuid(&init_user_ns, auid),
+			 ses);
 	if (sid) {
 		rc = security_secid_to_secctx(sid, &ctx, &len);
 		if (rc)
@@ -649,13 +658,14 @@ static int audit_log_common_recv_msg(struct audit_buffer **ab, u16 msg_type,
 
 static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
-	u32			uid, pid, seq, sid;
+	u32			pid, seq, sid;
+	kuid_t			uid;
 	void			*data;
 	struct audit_status	*status_get, status_set;
 	int			err;
 	struct audit_buffer	*ab;
 	u16			msg_type = nlh->nlmsg_type;
-	uid_t			loginuid; /* loginuid of sender */
+	kuid_t			loginuid; /* loginuid of sender */
 	u32			sessionid;
 	struct audit_sig_info   *sig_data;
 	char			*ctx = NULL;
@@ -676,7 +686,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	}
 
 	pid  = NETLINK_CREDS(skb)->pid;
-	uid  = NETLINK_CREDS(skb)->uid;
+	uid = current_uid();
 	loginuid = audit_get_loginuid(current);
 	sessionid = audit_get_sessionid(current);
 	security_task_getsecid(current, &sid);
@@ -738,7 +748,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		if (!audit_enabled && msg_type != AUDIT_USER_AVC)
 			return 0;
 
-		err = audit_filter_user(&NETLINK_CB(skb));
+		err = audit_filter_user();
 		if (err == 1) {
 			err = 0;
 			if (msg_type == AUDIT_USER_TTY) {
@@ -866,7 +876,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 				security_release_secctx(ctx, len);
 			return -ENOMEM;
 		}
-		sig_data->uid = audit_sig_uid;
+		sig_data->uid = from_kuid(&init_user_ns, audit_sig_uid);
 		sig_data->pid = audit_sig_pid;
 		if (audit_sig_sid) {
 			memcpy(sig_data->ctx, ctx, len);
diff --git a/kernel/audit.h b/kernel/audit.h
index 8167668..fd30cc7 100644
--- a/kernel/audit.h
+++ b/kernel/audit.h
@@ -76,6 +76,8 @@ static inline int audit_hash_ino(u32 ino)
 
 extern int audit_match_class(int class, unsigned syscall);
 extern int audit_comparator(const u32 left, const u32 op, const u32 right);
+extern int audit_uid_comparator(kuid_t left, const u32 op, kuid_t right);
+extern int audit_gid_comparator(kgid_t left, const u32 op, kgid_t right);
 extern int audit_compare_dname_path(const char *dname, const char *path,
 				    int *dirlen);
 extern struct sk_buff *	    audit_make_reply(int pid, int seq, int type,
@@ -144,7 +146,7 @@ extern void audit_kill_trees(struct list_head *);
 extern char *audit_unpack_string(void **, size_t *, size_t);
 
 extern pid_t audit_sig_pid;
-extern uid_t audit_sig_uid;
+extern kuid_t audit_sig_uid;
 extern u32 audit_sig_sid;
 
 #ifdef CONFIG_AUDITSYSCALL
diff --git a/kernel/audit_watch.c b/kernel/audit_watch.c
index 3823281..1c22ec3 100644
--- a/kernel/audit_watch.c
+++ b/kernel/audit_watch.c
@@ -241,7 +241,7 @@ static void audit_watch_log_rule_change(struct audit_krule *r, struct audit_watc
 		struct audit_buffer *ab;
 		ab = audit_log_start(NULL, GFP_NOFS, AUDIT_CONFIG_CHANGE);
 		audit_log_format(ab, "auid=%u ses=%u op=",
-				 audit_get_loginuid(current),
+				 from_kuid(&init_user_ns, audit_get_loginuid(current)),
 				 audit_get_sessionid(current));
 		audit_log_string(ab, op);
 		audit_log_format(ab, " path=");
diff --git a/kernel/auditfilter.c b/kernel/auditfilter.c
index a6c3f1a..1a8a648 100644
--- a/kernel/auditfilter.c
+++ b/kernel/auditfilter.c
@@ -342,6 +342,8 @@ static struct audit_entry *audit_rule_to_entry(struct audit_rule *rule)
 
 		f->type = rule->fields[i] & ~(AUDIT_NEGATE|AUDIT_OPERATORS);
 		f->val = rule->values[i];
+		f->uid = INVALID_UID;
+		f->gid = INVALID_GID;
 
 		err = -EINVAL;
 		if (f->op == Audit_bad)
@@ -350,16 +352,34 @@ static struct audit_entry *audit_rule_to_entry(struct audit_rule *rule)
 		switch(f->type) {
 		default:
 			goto exit_free;
-		case AUDIT_PID:
 		case AUDIT_UID:
 		case AUDIT_EUID:
 		case AUDIT_SUID:
 		case AUDIT_FSUID:
+		case AUDIT_LOGINUID:
+			/* bit ops not implemented for uid comparisons */
+			if (f->op == Audit_bitmask || f->op == Audit_bittest)
+				goto exit_free;
+
+			f->uid = make_kuid(current_user_ns(), f->val);
+			if (!uid_valid(f->uid))
+				goto exit_free;
+			break;
+
 		case AUDIT_GID:
 		case AUDIT_EGID:
 		case AUDIT_SGID:
 		case AUDIT_FSGID:
-		case AUDIT_LOGINUID:
+			/* bit ops not implemented for gid comparisons */
+			if (f->op == Audit_bitmask || f->op == Audit_bittest)
+				goto exit_free;
+
+			f->gid = make_kgid(current_user_ns(), f->val);
+			if (!gid_valid(f->gid))
+				goto exit_free;
+			break;
+
+		case AUDIT_PID:
 		case AUDIT_PERS:
 		case AUDIT_MSGTYPE:
 		case AUDIT_PPID:
@@ -437,19 +457,41 @@ static struct audit_entry *audit_data_to_entry(struct audit_rule_data *data,
 
 		f->type = data->fields[i];
 		f->val = data->values[i];
+		f->uid = INVALID_UID;
+		f->gid = INVALID_GID;
 		f->lsm_str = NULL;
 		f->lsm_rule = NULL;
 		switch(f->type) {
-		case AUDIT_PID:
 		case AUDIT_UID:
 		case AUDIT_EUID:
 		case AUDIT_SUID:
 		case AUDIT_FSUID:
+		case AUDIT_LOGINUID:
+		case AUDIT_OBJ_UID:
+			/* bit ops not implemented for uid comparisons */
+			if (f->op == Audit_bitmask || f->op == Audit_bittest)
+				goto exit_free;
+
+			f->uid = make_kuid(current_user_ns(), f->val);
+			if (!uid_valid(f->uid))
+				goto exit_free;
+			break;
+
 		case AUDIT_GID:
 		case AUDIT_EGID:
 		case AUDIT_SGID:
 		case AUDIT_FSGID:
-		case AUDIT_LOGINUID:
+		case AUDIT_OBJ_GID:
+			/* bit ops not implemented for gid comparisons */
+			if (f->op == Audit_bitmask || f->op == Audit_bittest)
+				goto exit_free;
+
+			f->gid = make_kgid(current_user_ns(), f->val);
+			if (!gid_valid(f->gid))
+				goto exit_free;
+			break;
+
+		case AUDIT_PID:
 		case AUDIT_PERS:
 		case AUDIT_MSGTYPE:
 		case AUDIT_PPID:
@@ -461,9 +503,8 @@ static struct audit_entry *audit_data_to_entry(struct audit_rule_data *data,
 		case AUDIT_ARG1:
 		case AUDIT_ARG2:
 		case AUDIT_ARG3:
-		case AUDIT_OBJ_UID:
-		case AUDIT_OBJ_GID:
 			break;
+		/* arch is only allowed to be = or != */
 		case AUDIT_ARCH:
 			entry->rule.arch_f = f;
 			break;
@@ -707,6 +748,23 @@ static int audit_compare_rule(struct audit_krule *a, struct audit_krule *b)
 			if (strcmp(a->filterkey, b->filterkey))
 				return 1;
 			break;
+		case AUDIT_UID:
+		case AUDIT_EUID:
+		case AUDIT_SUID:
+		case AUDIT_FSUID:
+		case AUDIT_LOGINUID:
+		case AUDIT_OBJ_UID:
+			if (!uid_eq(a->fields[i].uid, b->fields[i].uid))
+				return 1;
+			break;
+		case AUDIT_GID:
+		case AUDIT_EGID:
+		case AUDIT_SGID:
+		case AUDIT_FSGID:
+		case AUDIT_OBJ_GID:
+			if (!gid_eq(a->fields[i].gid, b->fields[i].gid))
+				return 1;
+			break;
 		default:
 			if (a->fields[i].val != b->fields[i].val)
 				return 1;
@@ -1056,7 +1114,7 @@ static void audit_list_rules(int pid, int seq, struct sk_buff_head *q)
 }
 
 /* Log rule additions and removals */
-static void audit_log_rule_change(uid_t loginuid, u32 sessionid, u32 sid,
+static void audit_log_rule_change(kuid_t loginuid, u32 sessionid, u32 sid,
 				  char *action, struct audit_krule *rule,
 				  int res)
 {
@@ -1068,7 +1126,8 @@ static void audit_log_rule_change(uid_t loginuid, u32 sessionid, u32 sid,
 	ab = audit_log_start(NULL, GFP_KERNEL, AUDIT_CONFIG_CHANGE);
 	if (!ab)
 		return;
-	audit_log_format(ab, "auid=%u ses=%u", loginuid, sessionid);
+	audit_log_format(ab, "auid=%u ses=%u",
+			 from_kuid(&init_user_ns, loginuid), sessionid);
 	if (sid) {
 		char *ctx = NULL;
 		u32 len;
@@ -1098,8 +1157,8 @@ static void audit_log_rule_change(uid_t loginuid, u32 sessionid, u32 sid,
  * @sessionid: sessionid for netlink audit message
  * @sid: SE Linux Security ID of sender
  */
-int audit_receive_filter(int type, int pid, int uid, int seq, void *data,
-			 size_t datasz, uid_t loginuid, u32 sessionid, u32 sid)
+int audit_receive_filter(int type, int pid, kuid_t uid, int seq, void *data,
+			 size_t datasz, kuid_t loginuid, u32 sessionid, u32 sid)
 {
 	struct task_struct *tsk;
 	struct audit_netlink_list *dest;
@@ -1198,6 +1257,52 @@ int audit_comparator(u32 left, u32 op, u32 right)
 	}
 }
 
+int audit_uid_comparator(kuid_t left, u32 op, kuid_t right)
+{
+	switch (op) {
+	case Audit_equal:
+		return uid_eq(left, right);
+	case Audit_not_equal:
+		return !uid_eq(left, right);
+	case Audit_lt:
+		return uid_lt(left, right);
+	case Audit_le:
+		return uid_lte(left, right);
+	case Audit_gt:
+		return uid_gt(left, right);
+	case Audit_ge:
+		return uid_gte(left, right);
+	case Audit_bitmask:
+	case Audit_bittest:
+	default:
+		BUG();
+		return 0;
+	}
+}
+
+int audit_gid_comparator(kgid_t left, u32 op, kgid_t right)
+{
+	switch (op) {
+	case Audit_equal:
+		return gid_eq(left, right);
+	case Audit_not_equal:
+		return !gid_eq(left, right);
+	case Audit_lt:
+		return gid_lt(left, right);
+	case Audit_le:
+		return gid_lte(left, right);
+	case Audit_gt:
+		return gid_gt(left, right);
+	case Audit_ge:
+		return gid_gte(left, right);
+	case Audit_bitmask:
+	case Audit_bittest:
+	default:
+		BUG();
+		return 0;
+	}
+}
+
 /* Compare given dentry name with last component in given path,
  * return of 0 indicates a match. */
 int audit_compare_dname_path(const char *dname, const char *path,
@@ -1236,8 +1341,7 @@ int audit_compare_dname_path(const char *dname, const char *path,
 	return strncmp(p, dname, dlen);
 }
 
-static int audit_filter_user_rules(struct netlink_skb_parms *cb,
-				   struct audit_krule *rule,
+static int audit_filter_user_rules(struct audit_krule *rule,
 				   enum audit_state *state)
 {
 	int i;
@@ -1249,17 +1353,17 @@ static int audit_filter_user_rules(struct netlink_skb_parms *cb,
 
 		switch (f->type) {
 		case AUDIT_PID:
-			result = audit_comparator(cb->creds.pid, f->op, f->val);
+			result = audit_comparator(task_pid_nr(current), f->op, f->val);
 			break;
 		case AUDIT_UID:
-			result = audit_comparator(cb->creds.uid, f->op, f->val);
+			result = audit_uid_comparator(current_uid(), f->op, f->uid);
 			break;
 		case AUDIT_GID:
-			result = audit_comparator(cb->creds.gid, f->op, f->val);
+			result = audit_gid_comparator(current_gid(), f->op, f->gid);
 			break;
 		case AUDIT_LOGINUID:
-			result = audit_comparator(audit_get_loginuid(current),
-						  f->op, f->val);
+			result = audit_uid_comparator(audit_get_loginuid(current),
+						  f->op, f->uid);
 			break;
 		case AUDIT_SUBJ_USER:
 		case AUDIT_SUBJ_ROLE:
@@ -1287,7 +1391,7 @@ static int audit_filter_user_rules(struct netlink_skb_parms *cb,
 	return 1;
 }
 
-int audit_filter_user(struct netlink_skb_parms *cb)
+int audit_filter_user(void)
 {
 	enum audit_state state = AUDIT_DISABLED;
 	struct audit_entry *e;
@@ -1295,7 +1399,7 @@ int audit_filter_user(struct netlink_skb_parms *cb)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(e, &audit_filter_list[AUDIT_FILTER_USER], list) {
-		if (audit_filter_user_rules(cb, &e->rule, &state)) {
+		if (audit_filter_user_rules(&e->rule, &state)) {
 			if (state == AUDIT_DISABLED)
 				ret = 0;
 			break;
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index 4b96415..0795f58 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -113,8 +113,8 @@ struct audit_names {
 	unsigned long	ino;
 	dev_t		dev;
 	umode_t		mode;
-	uid_t		uid;
-	gid_t		gid;
+	kuid_t		uid;
+	kgid_t		gid;
 	dev_t		rdev;
 	u32		osid;
 	struct audit_cap_data fcap;
@@ -149,8 +149,8 @@ struct audit_aux_data_execve {
 struct audit_aux_data_pids {
 	struct audit_aux_data	d;
 	pid_t			target_pid[AUDIT_AUX_PIDS];
-	uid_t			target_auid[AUDIT_AUX_PIDS];
-	uid_t			target_uid[AUDIT_AUX_PIDS];
+	kuid_t			target_auid[AUDIT_AUX_PIDS];
+	kuid_t			target_uid[AUDIT_AUX_PIDS];
 	unsigned int		target_sessionid[AUDIT_AUX_PIDS];
 	u32			target_sid[AUDIT_AUX_PIDS];
 	char 			target_comm[AUDIT_AUX_PIDS][TASK_COMM_LEN];
@@ -208,14 +208,14 @@ struct audit_context {
 	size_t sockaddr_len;
 				/* Save things to print about task_struct */
 	pid_t		    pid, ppid;
-	uid_t		    uid, euid, suid, fsuid;
-	gid_t		    gid, egid, sgid, fsgid;
+	kuid_t		    uid, euid, suid, fsuid;
+	kgid_t		    gid, egid, sgid, fsgid;
 	unsigned long	    personality;
 	int		    arch;
 
 	pid_t		    target_pid;
-	uid_t		    target_auid;
-	uid_t		    target_uid;
+	kuid_t		    target_auid;
+	kuid_t		    target_uid;
 	unsigned int	    target_sessionid;
 	u32		    target_sid;
 	char		    target_comm[TASK_COMM_LEN];
@@ -231,8 +231,8 @@ struct audit_context {
 			long args[6];
 		} socketcall;
 		struct {
-			uid_t			uid;
-			gid_t			gid;
+			kuid_t			uid;
+			kgid_t			gid;
 			umode_t			mode;
 			u32			osid;
 			int			has_perm;
@@ -464,37 +464,47 @@ static int match_tree_refs(struct audit_context *ctx, struct audit_tree *tree)
 	return 0;
 }
 
-static int audit_compare_id(uid_t uid1,
-			    struct audit_names *name,
-			    unsigned long name_offset,
-			    struct audit_field *f,
-			    struct audit_context *ctx)
+static int audit_compare_uid(kuid_t uid,
+			     struct audit_names *name,
+			     struct audit_field *f,
+			     struct audit_context *ctx)
 {
 	struct audit_names *n;
-	unsigned long addr;
-	uid_t uid2;
 	int rc;
 
-	BUILD_BUG_ON(sizeof(uid_t) != sizeof(gid_t));
-
 	if (name) {
-		addr = (unsigned long)name;
-		addr += name_offset;
-
-		uid2 = *(uid_t *)addr;
-		rc = audit_comparator(uid1, f->op, uid2);
+		rc = audit_uid_comparator(uid, f->op, name->uid);
 		if (rc)
 			return rc;
 	}
 
 	if (ctx) {
 		list_for_each_entry(n, &ctx->names_list, list) {
-			addr = (unsigned long)n;
-			addr += name_offset;
+			rc = audit_uid_comparator(uid, f->op, n->uid);
+			if (rc)
+				return rc;
+		}
+	}
+	return 0;
+}
+
+static int audit_compare_gid(kgid_t gid,
+			     struct audit_names *name,
+			     struct audit_field *f,
+			     struct audit_context *ctx)
+{
+	struct audit_names *n;
+	int rc;
 
-			uid2 = *(uid_t *)addr;
+	if (name) {
+		rc = audit_gid_comparator(gid, f->op, name->gid);
+		if (rc)
+			return rc;
+	}
 
-			rc = audit_comparator(uid1, f->op, uid2);
+	if (ctx) {
+		list_for_each_entry(n, &ctx->names_list, list) {
+			rc = audit_gid_comparator(gid, f->op, n->gid);
 			if (rc)
 				return rc;
 		}
@@ -511,80 +521,62 @@ static int audit_field_compare(struct task_struct *tsk,
 	switch (f->val) {
 	/* process to file object comparisons */
 	case AUDIT_COMPARE_UID_TO_OBJ_UID:
-		return audit_compare_id(cred->uid,
-					name, offsetof(struct audit_names, uid),
-					f, ctx);
+		return audit_compare_uid(cred->uid, name, f, ctx);
 	case AUDIT_COMPARE_GID_TO_OBJ_GID:
-		return audit_compare_id(cred->gid,
-					name, offsetof(struct audit_names, gid),
-					f, ctx);
+		return audit_compare_gid(cred->gid, name, f, ctx);
 	case AUDIT_COMPARE_EUID_TO_OBJ_UID:
-		return audit_compare_id(cred->euid,
-					name, offsetof(struct audit_names, uid),
-					f, ctx);
+		return audit_compare_uid(cred->euid, name, f, ctx);
 	case AUDIT_COMPARE_EGID_TO_OBJ_GID:
-		return audit_compare_id(cred->egid,
-					name, offsetof(struct audit_names, gid),
-					f, ctx);
+		return audit_compare_gid(cred->egid, name, f, ctx);
 	case AUDIT_COMPARE_AUID_TO_OBJ_UID:
-		return audit_compare_id(tsk->loginuid,
-					name, offsetof(struct audit_names, uid),
-					f, ctx);
+		return audit_compare_uid(tsk->loginuid, name, f, ctx);
 	case AUDIT_COMPARE_SUID_TO_OBJ_UID:
-		return audit_compare_id(cred->suid,
-					name, offsetof(struct audit_names, uid),
-					f, ctx);
+		return audit_compare_uid(cred->suid, name, f, ctx);
 	case AUDIT_COMPARE_SGID_TO_OBJ_GID:
-		return audit_compare_id(cred->sgid,
-					name, offsetof(struct audit_names, gid),
-					f, ctx);
+		return audit_compare_gid(cred->sgid, name, f, ctx);
 	case AUDIT_COMPARE_FSUID_TO_OBJ_UID:
-		return audit_compare_id(cred->fsuid,
-					name, offsetof(struct audit_names, uid),
-					f, ctx);
+		return audit_compare_uid(cred->fsuid, name, f, ctx);
 	case AUDIT_COMPARE_FSGID_TO_OBJ_GID:
-		return audit_compare_id(cred->fsgid,
-					name, offsetof(struct audit_names, gid),
-					f, ctx);
+		return audit_compare_gid(cred->fsgid, name, f, ctx);
 	/* uid comparisons */
 	case AUDIT_COMPARE_UID_TO_AUID:
-		return audit_comparator(cred->uid, f->op, tsk->loginuid);
+		return audit_uid_comparator(cred->uid, f->op, tsk->loginuid);
 	case AUDIT_COMPARE_UID_TO_EUID:
-		return audit_comparator(cred->uid, f->op, cred->euid);
+		return audit_uid_comparator(cred->uid, f->op, cred->euid);
 	case AUDIT_COMPARE_UID_TO_SUID:
-		return audit_comparator(cred->uid, f->op, cred->suid);
+		return audit_uid_comparator(cred->uid, f->op, cred->suid);
 	case AUDIT_COMPARE_UID_TO_FSUID:
-		return audit_comparator(cred->uid, f->op, cred->fsuid);
+		return audit_uid_comparator(cred->uid, f->op, cred->fsuid);
 	/* auid comparisons */
 	case AUDIT_COMPARE_AUID_TO_EUID:
-		return audit_comparator(tsk->loginuid, f->op, cred->euid);
+		return audit_uid_comparator(tsk->loginuid, f->op, cred->euid);
 	case AUDIT_COMPARE_AUID_TO_SUID:
-		return audit_comparator(tsk->loginuid, f->op, cred->suid);
+		return audit_uid_comparator(tsk->loginuid, f->op, cred->suid);
 	case AUDIT_COMPARE_AUID_TO_FSUID:
-		return audit_comparator(tsk->loginuid, f->op, cred->fsuid);
+		return audit_uid_comparator(tsk->loginuid, f->op, cred->fsuid);
 	/* euid comparisons */
 	case AUDIT_COMPARE_EUID_TO_SUID:
-		return audit_comparator(cred->euid, f->op, cred->suid);
+		return audit_uid_comparator(cred->euid,	f->op, cred->suid);
 	case AUDIT_COMPARE_EUID_TO_FSUID:
-		return audit_comparator(cred->euid, f->op, cred->fsuid);
+		return audit_uid_comparator(cred->euid, f->op, cred->fsuid);
 	/* suid comparisons */
 	case AUDIT_COMPARE_SUID_TO_FSUID:
-		return audit_comparator(cred->suid, f->op, cred->fsuid);
+		return audit_uid_comparator(cred->suid,	f->op, cred->fsuid);
 	/* gid comparisons */
 	case AUDIT_COMPARE_GID_TO_EGID:
-		return audit_comparator(cred->gid, f->op, cred->egid);
+		return audit_gid_comparator(cred->gid, f->op, cred->egid);
 	case AUDIT_COMPARE_GID_TO_SGID:
-		return audit_comparator(cred->gid, f->op, cred->sgid);
+		return audit_gid_comparator(cred->gid, f->op, cred->sgid);
 	case AUDIT_COMPARE_GID_TO_FSGID:
-		return audit_comparator(cred->gid, f->op, cred->fsgid);
+		return audit_gid_comparator(cred->gid, f->op, cred->fsgid);
 	/* egid comparisons */
 	case AUDIT_COMPARE_EGID_TO_SGID:
-		return audit_comparator(cred->egid, f->op, cred->sgid);
+		return audit_gid_comparator(cred->egid,	f->op, cred->sgid);
 	case AUDIT_COMPARE_EGID_TO_FSGID:
-		return audit_comparator(cred->egid, f->op, cred->fsgid);
+		return audit_gid_comparator(cred->egid,	f->op, cred->fsgid);
 	/* sgid comparison */
 	case AUDIT_COMPARE_SGID_TO_FSGID:
-		return audit_comparator(cred->sgid, f->op, cred->fsgid);
+		return audit_gid_comparator(cred->sgid,	f->op, cred->fsgid);
 	default:
 		WARN(1, "Missing AUDIT_COMPARE define.  Report as a bug\n");
 		return 0;
@@ -630,28 +622,28 @@ static int audit_filter_rules(struct task_struct *tsk,
 			}
 			break;
 		case AUDIT_UID:
-			result = audit_comparator(cred->uid, f->op, f->val);
+			result = audit_uid_comparator(cred->uid, f->op, f->uid);
 			break;
 		case AUDIT_EUID:
-			result = audit_comparator(cred->euid, f->op, f->val);
+			result = audit_uid_comparator(cred->euid, f->op, f->uid);
 			break;
 		case AUDIT_SUID:
-			result = audit_comparator(cred->suid, f->op, f->val);
+			result = audit_uid_comparator(cred->suid, f->op, f->uid);
 			break;
 		case AUDIT_FSUID:
-			result = audit_comparator(cred->fsuid, f->op, f->val);
+			result = audit_uid_comparator(cred->fsuid, f->op, f->uid);
 			break;
 		case AUDIT_GID:
-			result = audit_comparator(cred->gid, f->op, f->val);
+			result = audit_gid_comparator(cred->gid, f->op, f->gid);
 			break;
 		case AUDIT_EGID:
-			result = audit_comparator(cred->egid, f->op, f->val);
+			result = audit_gid_comparator(cred->egid, f->op, f->gid);
 			break;
 		case AUDIT_SGID:
-			result = audit_comparator(cred->sgid, f->op, f->val);
+			result = audit_gid_comparator(cred->sgid, f->op, f->gid);
 			break;
 		case AUDIT_FSGID:
-			result = audit_comparator(cred->fsgid, f->op, f->val);
+			result = audit_gid_comparator(cred->fsgid, f->op, f->gid);
 			break;
 		case AUDIT_PERS:
 			result = audit_comparator(tsk->personality, f->op, f->val);
@@ -717,10 +709,10 @@ static int audit_filter_rules(struct task_struct *tsk,
 			break;
 		case AUDIT_OBJ_UID:
 			if (name) {
-				result = audit_comparator(name->uid, f->op, f->val);
+				result = audit_uid_comparator(name->uid, f->op, f->uid);
 			} else if (ctx) {
 				list_for_each_entry(n, &ctx->names_list, list) {
-					if (audit_comparator(n->uid, f->op, f->val)) {
+					if (audit_uid_comparator(n->uid, f->op, f->uid)) {
 						++result;
 						break;
 					}
@@ -729,10 +721,10 @@ static int audit_filter_rules(struct task_struct *tsk,
 			break;
 		case AUDIT_OBJ_GID:
 			if (name) {
-				result = audit_comparator(name->gid, f->op, f->val);
+				result = audit_gid_comparator(name->gid, f->op, f->gid);
 			} else if (ctx) {
 				list_for_each_entry(n, &ctx->names_list, list) {
-					if (audit_comparator(n->gid, f->op, f->val)) {
+					if (audit_gid_comparator(n->gid, f->op, f->gid)) {
 						++result;
 						break;
 					}
@@ -750,7 +742,7 @@ static int audit_filter_rules(struct task_struct *tsk,
 		case AUDIT_LOGINUID:
 			result = 0;
 			if (ctx)
-				result = audit_comparator(tsk->loginuid, f->op, f->val);
+				result = audit_uid_comparator(tsk->loginuid, f->op, f->uid);
 			break;
 		case AUDIT_SUBJ_USER:
 		case AUDIT_SUBJ_ROLE:
@@ -1184,7 +1176,7 @@ static void audit_log_task_info(struct audit_buffer *ab, struct task_struct *tsk
 }
 
 static int audit_log_pid_context(struct audit_context *context, pid_t pid,
-				 uid_t auid, uid_t uid, unsigned int sessionid,
+				 kuid_t auid, kuid_t uid, unsigned int sessionid,
 				 u32 sid, char *comm)
 {
 	struct audit_buffer *ab;
@@ -1196,8 +1188,9 @@ static int audit_log_pid_context(struct audit_context *context, pid_t pid,
 	if (!ab)
 		return rc;
 
-	audit_log_format(ab, "opid=%d oauid=%d ouid=%d oses=%d", pid, auid,
-			 uid, sessionid);
+	audit_log_format(ab, "opid=%d oauid=%d ouid=%d oses=%d", pid,
+			 from_kuid(&init_user_ns, auid),
+			 from_kuid(&init_user_ns, uid), sessionid);
 	if (security_secid_to_secctx(sid, &ctx, &len)) {
 		audit_log_format(ab, " obj=(none)");
 		rc = 1;
@@ -1447,7 +1440,9 @@ static void show_special(struct audit_context *context, int *call_panic)
 		u32 osid = context->ipc.osid;
 
 		audit_log_format(ab, "ouid=%u ogid=%u mode=%#ho",
-			 context->ipc.uid, context->ipc.gid, context->ipc.mode);
+				 from_kuid(&init_user_ns, context->ipc.uid),
+				 from_kgid(&init_user_ns, context->ipc.gid),
+				 context->ipc.mode);
 		if (osid) {
 			char *ctx = NULL;
 			u32 len;
@@ -1560,8 +1555,8 @@ static void audit_log_name(struct audit_context *context, struct audit_names *n,
 				 MAJOR(n->dev),
 				 MINOR(n->dev),
 				 n->mode,
-				 n->uid,
-				 n->gid,
+				 from_kuid(&init_user_ns, n->uid),
+				 from_kgid(&init_user_ns, n->gid),
 				 MAJOR(n->rdev),
 				 MINOR(n->rdev));
 	}
@@ -1638,11 +1633,16 @@ static void audit_log_exit(struct audit_context *context, struct task_struct *ts
 		  context->name_count,
 		  context->ppid,
 		  context->pid,
-		  tsk->loginuid,
-		  context->uid,
-		  context->gid,
-		  context->euid, context->suid, context->fsuid,
-		  context->egid, context->sgid, context->fsgid, tty,
+		  from_kuid(&init_user_ns, tsk->loginuid),
+		  from_kuid(&init_user_ns, context->uid),
+		  from_kgid(&init_user_ns, context->gid),
+		  from_kuid(&init_user_ns, context->euid),
+		  from_kuid(&init_user_ns, context->suid),
+		  from_kuid(&init_user_ns, context->fsuid),
+		  from_kgid(&init_user_ns, context->egid),
+		  from_kgid(&init_user_ns, context->sgid),
+		  from_kgid(&init_user_ns, context->fsgid),
+		  tty,
 		  tsk->sessionid);
 
 
@@ -2299,14 +2299,14 @@ static atomic_t session_id = ATOMIC_INIT(0);
  *
  * Called (set) from fs/proc/base.c::proc_loginuid_write().
  */
-int audit_set_loginuid(uid_t loginuid)
+int audit_set_loginuid(kuid_t loginuid)
 {
 	struct task_struct *task = current;
 	struct audit_context *context = task->audit_context;
 	unsigned int sessionid;
 
 #ifdef CONFIG_AUDIT_LOGINUID_IMMUTABLE
-	if (task->loginuid != -1)
+	if (uid_valid(task->loginuid))
 		return -EPERM;
 #else /* CONFIG_AUDIT_LOGINUID_IMMUTABLE */
 	if (!capable(CAP_AUDIT_CONTROL))
@@ -2322,8 +2322,10 @@ int audit_set_loginuid(uid_t loginuid)
 			audit_log_format(ab, "login pid=%d uid=%u "
 				"old auid=%u new auid=%u"
 				" old ses=%u new ses=%u",
-				task->pid, task_uid(task),
-				task->loginuid, loginuid,
+				task->pid,
+				from_kuid(&init_user_ns, task_uid(task)),
+				from_kuid(&init_user_ns, task->loginuid),
+				from_kuid(&init_user_ns, loginuid),
 				task->sessionid, sessionid);
 			audit_log_end(ab);
 		}
@@ -2546,15 +2548,14 @@ int __audit_signal_info(int sig, struct task_struct *t)
 	struct audit_aux_data_pids *axp;
 	struct task_struct *tsk = current;
 	struct audit_context *ctx = tsk->audit_context;
-	uid_t uid = current_uid(), t_uid = task_uid(t);
 
 	if (audit_pid && t->tgid == audit_pid) {
 		if (sig == SIGTERM || sig == SIGHUP || sig == SIGUSR1 || sig == SIGUSR2) {
 			audit_sig_pid = tsk->pid;
-			if (tsk->loginuid != -1)
+			if (uid_valid(tsk->loginuid))
 				audit_sig_uid = tsk->loginuid;
 			else
-				audit_sig_uid = uid;
+				audit_sig_uid = current_uid();
 			security_task_getsecid(tsk, &audit_sig_sid);
 		}
 		if (!audit_signals || audit_dummy_context())
@@ -2566,7 +2567,7 @@ int __audit_signal_info(int sig, struct task_struct *t)
 	if (!ctx->target_pid) {
 		ctx->target_pid = t->tgid;
 		ctx->target_auid = audit_get_loginuid(t);
-		ctx->target_uid = t_uid;
+		ctx->target_uid = task_uid(t);
 		ctx->target_sessionid = audit_get_sessionid(t);
 		security_task_getsecid(t, &ctx->target_sid);
 		memcpy(ctx->target_comm, t->comm, TASK_COMM_LEN);
@@ -2587,7 +2588,7 @@ int __audit_signal_info(int sig, struct task_struct *t)
 
 	axp->target_pid[axp->pid_count] = t->tgid;
 	axp->target_auid[axp->pid_count] = audit_get_loginuid(t);
-	axp->target_uid[axp->pid_count] = t_uid;
+	axp->target_uid[axp->pid_count] = task_uid(t);
 	axp->target_sessionid[axp->pid_count] = audit_get_sessionid(t);
 	security_task_getsecid(t, &axp->target_sid[axp->pid_count]);
 	memcpy(axp->target_comm[axp->pid_count], t->comm, TASK_COMM_LEN);
@@ -2676,9 +2677,10 @@ static void audit_log_abend(struct audit_buffer *ab, char *reason, long signr)
 	gid_t gid;
 	unsigned int sessionid;
 
-	auid = audit_get_loginuid(current);
+	auid = from_kuid(&init_user_ns, audit_get_loginuid(current));
 	sessionid = audit_get_sessionid(current);
-	current_uid_gid(&uid, &gid);
+	uid = from_kuid(&init_user_ns, current_uid());
+	gid = from_kgid(&init_user_ns, current_gid());
 
 	audit_log_format(ab, "auid=%u uid=%u gid=%u ses=%u",
 			 auid, uid, gid, sessionid);
diff --git a/net/core/dev.c b/net/core/dev.c
index 026bb4a..1c0d082 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4524,7 +4524,7 @@ static int __dev_set_promiscuity(struct net_device *dev, int inc)
 				"dev=%s prom=%d old_prom=%d auid=%u uid=%u gid=%u ses=%u",
 				dev->name, (dev->flags & IFF_PROMISC),
 				(old_flags & IFF_PROMISC),
-				audit_get_loginuid(current),
+				from_kuid(&init_user_ns, audit_get_loginuid(current)),
 				from_kuid(&init_user_ns, uid),
 				from_kgid(&init_user_ns, gid),
 				audit_get_sessionid(current));
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index e7ff694..729a345 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -1541,7 +1541,7 @@ int __init netlbl_unlabel_defconf(void)
 	 * it is called is at bootup before the audit subsystem is reporting
 	 * messages so don't worry to much about these values. */
 	security_task_getsecid(current, &audit_info.secid);
-	audit_info.loginuid = 0;
+	audit_info.loginuid = GLOBAL_ROOT_UID;
 	audit_info.sessionid = 0;
 
 	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
diff --git a/net/netlabel/netlabel_user.c b/net/netlabel/netlabel_user.c
index 9fae63f..9650c4a 100644
--- a/net/netlabel/netlabel_user.c
+++ b/net/netlabel/netlabel_user.c
@@ -109,7 +109,7 @@ struct audit_buffer *netlbl_audit_start_common(int type,
 		return NULL;
 
 	audit_log_format(audit_buf, "netlabel: auid=%u ses=%u",
-			 audit_info->loginuid,
+			 from_kuid(&init_user_ns, audit_info->loginuid),
 			 audit_info->sessionid);
 
 	if (audit_info->secid != 0 &&
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index c5a5165..2f47515 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2630,12 +2630,12 @@ static void xfrm_policy_fini(struct net *net)
 
 	flush_work(&net->xfrm.policy_hash_work);
 #ifdef CONFIG_XFRM_SUB_POLICY
-	audit_info.loginuid = -1;
+	audit_info.loginuid = INVALID_UID;
 	audit_info.sessionid = -1;
 	audit_info.secid = 0;
 	xfrm_policy_flush(net, XFRM_POLICY_TYPE_SUB, &audit_info);
 #endif
-	audit_info.loginuid = -1;
+	audit_info.loginuid = INVALID_UID;
 	audit_info.sessionid = -1;
 	audit_info.secid = 0;
 	xfrm_policy_flush(net, XFRM_POLICY_TYPE_MAIN, &audit_info);
@@ -2742,7 +2742,7 @@ static void xfrm_audit_common_policyinfo(struct xfrm_policy *xp,
 }
 
 void xfrm_audit_policy_add(struct xfrm_policy *xp, int result,
-			   uid_t auid, u32 sessionid, u32 secid)
+			   kuid_t auid, u32 sessionid, u32 secid)
 {
 	struct audit_buffer *audit_buf;
 
@@ -2757,7 +2757,7 @@ void xfrm_audit_policy_add(struct xfrm_policy *xp, int result,
 EXPORT_SYMBOL_GPL(xfrm_audit_policy_add);
 
 void xfrm_audit_policy_delete(struct xfrm_policy *xp, int result,
-			      uid_t auid, u32 sessionid, u32 secid)
+			      kuid_t auid, u32 sessionid, u32 secid)
 {
 	struct audit_buffer *audit_buf;
 
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 5b228f9..fce6a49 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -2045,7 +2045,7 @@ void xfrm_state_fini(struct net *net)
 	unsigned int sz;
 
 	flush_work(&net->xfrm.state_hash_work);
-	audit_info.loginuid = -1;
+	audit_info.loginuid = INVALID_UID;
 	audit_info.sessionid = -1;
 	audit_info.secid = 0;
 	xfrm_state_flush(net, IPSEC_PROTO_ANY, &audit_info);
@@ -2112,7 +2112,7 @@ static void xfrm_audit_helper_pktinfo(struct sk_buff *skb, u16 family,
 }
 
 void xfrm_audit_state_add(struct xfrm_state *x, int result,
-			  uid_t auid, u32 sessionid, u32 secid)
+			  kuid_t auid, u32 sessionid, u32 secid)
 {
 	struct audit_buffer *audit_buf;
 
@@ -2127,7 +2127,7 @@ void xfrm_audit_state_add(struct xfrm_state *x, int result,
 EXPORT_SYMBOL_GPL(xfrm_audit_state_add);
 
 void xfrm_audit_state_delete(struct xfrm_state *x, int result,
-			     uid_t auid, u32 sessionid, u32 secid)
+			     kuid_t auid, u32 sessionid, u32 secid)
 {
 	struct audit_buffer *audit_buf;
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index e75d8e4..9ea55db 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -575,7 +575,7 @@ static int xfrm_add_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct xfrm_state *x;
 	int err;
 	struct km_event c;
-	uid_t loginuid = audit_get_loginuid(current);
+	kuid_t loginuid = audit_get_loginuid(current);
 	u32 sessionid = audit_get_sessionid(current);
 	u32 sid;
 
@@ -654,7 +654,7 @@ static int xfrm_del_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	int err = -ESRCH;
 	struct km_event c;
 	struct xfrm_usersa_id *p = nlmsg_data(nlh);
-	uid_t loginuid = audit_get_loginuid(current);
+	kuid_t loginuid = audit_get_loginuid(current);
 	u32 sessionid = audit_get_sessionid(current);
 	u32 sid;
 
@@ -1369,7 +1369,7 @@ static int xfrm_add_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct km_event c;
 	int err;
 	int excl;
-	uid_t loginuid = audit_get_loginuid(current);
+	kuid_t loginuid = audit_get_loginuid(current);
 	u32 sessionid = audit_get_sessionid(current);
 	u32 sid;
 
@@ -1624,7 +1624,7 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 					    NETLINK_CB(skb).pid);
 		}
 	} else {
-		uid_t loginuid = audit_get_loginuid(current);
+		kuid_t loginuid = audit_get_loginuid(current);
 		u32 sessionid = audit_get_sessionid(current);
 		u32 sid;
 
@@ -1918,7 +1918,7 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	err = 0;
 	if (up->hard) {
-		uid_t loginuid = audit_get_loginuid(current);
+		kuid_t loginuid = audit_get_loginuid(current);
 		u32 sessionid = audit_get_sessionid(current);
 		u32 sid;
 
@@ -1961,7 +1961,7 @@ static int xfrm_add_sa_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	km_state_expired(x, ue->hard, current->pid);
 
 	if (ue->hard) {
-		uid_t loginuid = audit_get_loginuid(current);
+		kuid_t loginuid = audit_get_loginuid(current);
 		u32 sessionid = audit_get_sessionid(current);
 		u32 sid;
 
-- 
1.7.5.4

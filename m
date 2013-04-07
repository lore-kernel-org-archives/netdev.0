From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH] kernel: audit: beautify code, for extern function, better
 to check its parameters by itself
Date: Sun, 07 Apr 2013 16:55:23 +0800
Message-ID: <5161347B.8090604@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Al Viro <viro@zeniv.linux.org.uk>, eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:29569 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932988Ab3DGIzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 04:55:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


  __audit_socketcall is an extern function.
  better to check its parameters by itself.

    also can return error code, when fail (find invalid parameters).
    also use macro instead of real hard code number
    also give related comments for it.

Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 include/linux/audit.h |   12 ++++++++----
 kernel/auditsc.c      |    9 ++++++---
 net/socket.c          |    6 ++++--
 3 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/include/linux/audit.h b/include/linux/audit.h
index 5a6d718..3fe9b7b 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -84,6 +84,9 @@ extern int audit_classify_arch(int arch);
 #define	AUDIT_TYPE_CHILD_DELETE 3	/* a child being deleted */
 #define	AUDIT_TYPE_CHILD_CREATE 4	/* a child being created */
 
+/* maximized args number that audit_socketcall can process */
+#define AUDITSC_ARGS		6
+
 struct filename;
 
 #ifdef CONFIG_AUDITSYSCALL
@@ -190,7 +193,7 @@ extern void audit_log_task_info(struct audit_buffer *ab, struct task_struct *tsk
 extern void __audit_ipc_obj(struct kern_ipc_perm *ipcp);
 extern void __audit_ipc_set_perm(unsigned long qbytes, uid_t uid, gid_t gid, umode_t mode);
 extern int __audit_bprm(struct linux_binprm *bprm);
-extern void __audit_socketcall(int nargs, unsigned long *args);
+extern int __audit_socketcall(int nargs, unsigned long *args);
 extern int __audit_sockaddr(int len, void *addr);
 extern void __audit_fd_pair(int fd1, int fd2);
 extern void __audit_mq_open(int oflag, umode_t mode, struct mq_attr *attr);
@@ -224,10 +227,11 @@ static inline int audit_bprm(struct linux_binprm *bprm)
 		return __audit_bprm(bprm);
 	return 0;
 }
-static inline void audit_socketcall(int nargs, unsigned long *args)
+static inline int audit_socketcall(int nargs, unsigned long *args)
 {
 	if (unlikely(!audit_dummy_context()))
-		__audit_socketcall(nargs, args);
+		return __audit_socketcall(nargs, args);
+	return 0;
 }
 static inline int audit_sockaddr(int len, void *addr)
 {
@@ -354,7 +358,7 @@ static inline int audit_bprm(struct linux_binprm *bprm)
 {
 	return 0;
 }
-static inline void audit_socketcall(int nargs, unsigned long *args)
+static inline int audit_socketcall(int nargs, unsigned long *args)
 { }
 static inline void audit_fd_pair(int fd1, int fd2)
 { }
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index a371f85..91270f0 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -226,7 +226,7 @@ struct audit_context {
 	union {
 		struct {
 			int nargs;
-			long args[6];
+			long args[AUDITSC_ARGS];
 		} socketcall;
 		struct {
 			kuid_t			uid;
@@ -2477,17 +2477,20 @@ int __audit_bprm(struct linux_binprm *bprm)
 
 /**
  * audit_socketcall - record audit data for sys_socketcall
- * @nargs: number of args
+ * @nargs: number of args, which should not be more than AUDITSC_ARGS.
  * @args: args array
  *
  */
-void __audit_socketcall(int nargs, unsigned long *args)
+int __audit_socketcall(int nargs, unsigned long *args)
 {
 	struct audit_context *context = current->audit_context;
 
+	if (nargs <= 0 || nargs > AUDITSC_ARGS || !args)
+		return -EINVAL;
 	context->type = AUDIT_SOCKETCALL;
 	context->socketcall.nargs = nargs;
 	memcpy(context->socketcall.args, args, nargs * sizeof(unsigned long));
+	return 0;
 }
 
 /**
diff --git a/net/socket.c b/net/socket.c
index 88f759a..122e460 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2434,7 +2434,7 @@ static const unsigned char nargs[21] = {
 
 SYSCALL_DEFINE2(socketcall, int, call, unsigned long __user *, args)
 {
-	unsigned long a[6];
+	unsigned long a[AUDITSC_ARGS];
 	unsigned long a0, a1;
 	int err;
 	unsigned int len;
@@ -2450,7 +2450,9 @@ SYSCALL_DEFINE2(socketcall, int, call, unsigned long __user *, args)
 	if (copy_from_user(a, args, len))
 		return -EFAULT;
 
-	audit_socketcall(nargs[call] / sizeof(unsigned long), a);
+	err = audit_socketcall(nargs[call] / sizeof(unsigned long), a);
+	if (err)
+		return err;
 
 	a0 = a[0];
 	a1 = a[1];
-- 
1.7.7.6

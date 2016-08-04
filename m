From: Sargun Dhillon <sargun@sargun.me>
Subject: [RFC 2/4] bpf, security: Add Checmate
Date: Thu, 4 Aug 2016 00:11:42 -0700
Message-ID: <20160804071140.GA19121@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:34162 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755051AbcHDHLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 03:11:45 -0400
Received: by mail-io0-f176.google.com with SMTP id q83so264849405iod.1
        for <netdev@vger.kernel.org>; Thu, 04 Aug 2016 00:11:44 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds the minor LSM Checmate. The purpose of Checmate is to act as an
extensible LSM in which you can load security modules. The module has a
simple API, as it's meant to have most of the logic in BPF hooks. It has
three APIs that are accessible via prctl.

As follows:
* Install hook: This appends a new BPF program to a given hook. Hook
		programs themselves must be unique BPF programs.
* Reset hook: This detaches all bpf programs asssociated with a hook.
* Deny Reset: This locks a hook, preventing reset. In production
	      operation, it's expected that the user would lock
	      their hooks.

Signed-off-by: Sargun Dhillon <sargun@sargun.me>
---
 include/linux/checmate.h         |  38 +++++
 include/uapi/linux/Kbuild        |   1 +
 include/uapi/linux/bpf.h         |   1 +
 include/uapi/linux/checmate.h    |  65 +++++++++
 include/uapi/linux/prctl.h       |   3 +
 security/Kconfig                 |   1 +
 security/Makefile                |   2 +
 security/checmate/Kconfig        |   6 +
 security/checmate/Makefile       |   3 +
 security/checmate/checmate_bpf.c |  67 +++++++++
 security/checmate/checmate_lsm.c | 304 +++++++++++++++++++++++++++++++++++++++
 11 files changed, 491 insertions(+)
 create mode 100644 include/linux/checmate.h
 create mode 100644 include/uapi/linux/checmate.h
 create mode 100644 security/checmate/Kconfig
 create mode 100644 security/checmate/Makefile
 create mode 100644 security/checmate/checmate_bpf.c
 create mode 100644 security/checmate/checmate_lsm.c

diff --git a/include/linux/checmate.h b/include/linux/checmate.h
new file mode 100644
index 0000000..3e492b0
--- /dev/null
+++ b/include/linux/checmate.h
@@ -0,0 +1,38 @@
+#ifndef _LINUX_CHECMATE_H_
+#define _LINUX_CHECMATE_H_ 1
+#include <uapi/linux/checmate.h>
+#include <linux/security.h>
+
+/* Miscellanious contexts */
+struct checmate_file_open_ctx {
+	struct file *file;
+	const struct cred *cred;
+};
+
+struct checmate_task_create_ctx {
+	unsigned long clone_flags;
+};
+
+struct checmate_task_free_ctx {
+	struct task_struct *task;
+};
+
+struct checmate_socket_connect_ctx {
+	struct socket *sock;
+	struct sockaddr *address;
+	int addrlen;
+};
+
+struct checmate_ctx {
+	int hook;
+	union {
+		/* Miscellanious contexts */
+		struct checmate_file_open_ctx			file_open_ctx;
+		struct checmate_task_create_ctx			task_create_ctx;
+		struct checmate_task_free_ctx			task_free_ctx;
+		/* CONFIG_SECURITY_NET contexts */
+		struct checmate_socket_connect_ctx		socket_connect_ctx;
+	};
+};
+
+#endif
diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index ec10cfe..f8670a7 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -82,6 +82,7 @@ header-y += cciss_defs.h
 header-y += cciss_ioctl.h
 header-y += cdrom.h
 header-y += cgroupstats.h
+header-y += checmate.h
 header-y += chio.h
 header-y += cm4000_cs.h
 header-y += cn_proc.h
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index da218fe..6cafb58 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -95,6 +95,7 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_SCHED_ACT,
 	BPF_PROG_TYPE_TRACEPOINT,
 	BPF_PROG_TYPE_XDP,
+	BPF_PROG_TYPE_CHECMATE,
 };
 
 #define BPF_PSEUDO_MAP_FD	1
diff --git a/include/uapi/linux/checmate.h b/include/uapi/linux/checmate.h
new file mode 100644
index 0000000..18af381
--- /dev/null
+++ b/include/uapi/linux/checmate.h
@@ -0,0 +1,65 @@
+#ifndef _UAPI__LINUX_CHECMATE_H__
+#define _UAPI__LINUX_CHECMATE_H__
+
+#define CHECMATE_INSTALL_HOOK 1
+#define CHECMATE_DENY_RESET 2
+#define CHECMATE_RESET 3
+
+enum checmate_hook {
+	CHECMATE_HOOK_UNSPEC,
+	/* CONFIG_SECURITY_NET hooks */
+	CHECMATE_HOOK_UNIX_STREAM_CONNECT,
+	CHECMATE_HOOK_UNIX_MAY_SEND,
+	CHECMATE_HOOK_SOCKET_CREATE,
+	CHECMATE_HOOK_SOCKET_POST_CREATE,
+	CHECMATE_HOOK_SOCKET_BIND,
+	CHECMATE_HOOK_SOCKET_CONNECT,
+	CHECMATE_HOOK_SOCKET_LISTEN,
+	CHECMATE_HOOK_SOCKET_ACCEPT,
+	CHECMATE_HOOK_SOCKET_SENDMSG,
+	CHECMATE_HOOK_SOCKET_RECVMSG,
+	CHECMATE_HOOK_SOCKET_GETSOCKNAME,
+	CHECMATE_HOOK_SOCKET_GETPEERNAME,
+	CHECMATE_HOOK_SOCKET_GETSOCKOPT,
+	CHECMATE_HOOK_SOCKET_SETSOCKOPT,
+	CHECMATE_HOOK_SOCKET_SHUTDOWN,
+	CHECMATE_HOOK_SOCKET_SOCK_RCV_SKB,
+	CHECMATE_HOOK_SOCKET_GETPEERSEC_STREAM,
+	CHECMATE_HOOK_SOCKET_GETPEERSEC_DGRAM,
+	CHECMATE_HOOK_SK_ALLOC_SECURITY,
+	CHECMATE_HOOK_SK_FREE_SECURITY,
+	CHECMATE_HOOK_SK_CLONE_SECURITY,
+	CHECMATE_HOOK_SK_GETSECID,
+	CHECMATE_HOOK_SOCK_GRAFT,
+	CHECMATE_HOOK_INET_CONN_REQUEST,
+	CHECMATE_HOOK_INET_CSK_CLONE,
+	CHECMATE_HOOK_INET_CONN_ESTABLISHED,
+	CHECMATE_HOOK_SECMARK_RELABEL_PACKET,
+	CHECMATE_HOOK_SECMARK_REFCOUNT_INC,
+	CHECMATE_HOOK_SECMARK_REFCOUNT_DEC,
+	CHECMATE_HOOK_REQ_CLASSIFY_FLOW,
+	CHECMATE_HOOK_TUN_DEV_ALLOC_SECURITY,
+	CHECMATE_HOOK_TUN_DEV_FREE_SECURITY,
+	CHECMATE_HOOK_TUN_DEV_CREATE,
+	CHECMATE_HOOK_TUN_DEV_ATTACH_QUEUE,
+	CHECMATE_HOOK_TUN_DEV_ATTACH,
+	CHECMATE_HOOK_TUN_DEV_OPEN,
+	/* CONFIG_SECURITY_PATH hooks */
+	CHECMATE_HOOK_PATH_UNLINK,
+	CHECMATE_HOOK_PATH_MKDIR,
+	CHECMATE_HOOK_PATH_RMDIR,
+	CHECMATE_HOOK_PATH_MKNOD,
+	CHECMATE_HOOK_PATH_TRUNCATE,
+	CHECMATE_HOOK_PATH_SYMLINK,
+	CHECMATE_HOOK_PATH_LINK,
+	CHECMATE_HOOK_PATH_RENAME,
+	CHECMATE_HOOK_PATH_CHMOD,
+	CHECMATE_HOOK_PATH_CHOWN,
+	CHECMATE_HOOK_PATH_CHROOT,
+	/* Other hooks */
+	CHECMATE_HOOK_FILE_OPEN,
+	CHECMATE_HOOK_TASK_CREATE,
+	CHECMATE_HOOK_TASK_FREE,
+	__CHECMATE_HOOK_MAX,
+};
+#endif
diff --git a/include/uapi/linux/prctl.h b/include/uapi/linux/prctl.h
index a8d0759..f520d1e 100644
--- a/include/uapi/linux/prctl.h
+++ b/include/uapi/linux/prctl.h
@@ -197,4 +197,7 @@ struct prctl_mm_map {
 # define PR_CAP_AMBIENT_LOWER		3
 # define PR_CAP_AMBIENT_CLEAR_ALL	4
 
+/* (CHEC)MATE operations */
+#define PR_CHECMATE 0x43484543
+
 #endif /* _LINUX_PRCTL_H */
diff --git a/security/Kconfig b/security/Kconfig
index 176758c..36cafc7 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -124,6 +124,7 @@ source security/tomoyo/Kconfig
 source security/apparmor/Kconfig
 source security/loadpin/Kconfig
 source security/yama/Kconfig
+source security/checmate/Kconfig
 
 source security/integrity/Kconfig
 
diff --git a/security/Makefile b/security/Makefile
index f2d71cd..6cc3342 100644
--- a/security/Makefile
+++ b/security/Makefile
@@ -8,6 +8,7 @@ subdir-$(CONFIG_SECURITY_SMACK)		+= smack
 subdir-$(CONFIG_SECURITY_TOMOYO)        += tomoyo
 subdir-$(CONFIG_SECURITY_APPARMOR)	+= apparmor
 subdir-$(CONFIG_SECURITY_YAMA)		+= yama
+subdir-$(CONFIG_SECURITY_CHECMATE)	+= checmate
 subdir-$(CONFIG_SECURITY_LOADPIN)	+= loadpin
 
 # always enable default capabilities
@@ -25,6 +26,7 @@ obj-$(CONFIG_SECURITY_APPARMOR)		+= apparmor/
 obj-$(CONFIG_SECURITY_YAMA)		+= yama/
 obj-$(CONFIG_SECURITY_LOADPIN)		+= loadpin/
 obj-$(CONFIG_CGROUP_DEVICE)		+= device_cgroup.o
+obj-$(CONFIG_SECURITY_CHECMATE)		+= checmate/
 
 # Object integrity file lists
 subdir-$(CONFIG_INTEGRITY)		+= integrity
diff --git a/security/checmate/Kconfig b/security/checmate/Kconfig
new file mode 100644
index 0000000..6a5c3f3
--- /dev/null
+++ b/security/checmate/Kconfig
@@ -0,0 +1,6 @@
+config SECURITY_CHECMATE
+	bool "Checmate support"
+	depends on SECURITY
+	default n
+	help
+	  This turns on checmate
diff --git a/security/checmate/Makefile b/security/checmate/Makefile
new file mode 100644
index 0000000..c676773
--- /dev/null
+++ b/security/checmate/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_SECURITY_CHECMATE) := checmate.o
+
+checmate-y := checmate_bpf.o checmate_lsm.o
diff --git a/security/checmate/checmate_bpf.c b/security/checmate/checmate_bpf.c
new file mode 100644
index 0000000..5bf1a8e
--- /dev/null
+++ b/security/checmate/checmate_bpf.c
@@ -0,0 +1,67 @@
+/*
+ * Checmate Linux Security Module
+ *
+ * Copyright (C) 2016 Sargun Dhillon <sargun@sargun.me>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#include <linux/bpf.h>
+#include <linux/checmate.h>
+
+static const struct bpf_func_proto *checmate_prog_func_proto(enum bpf_func_id func_id)
+{
+	switch (func_id) {
+	case BPF_FUNC_map_lookup_elem:
+		return &bpf_map_lookup_elem_proto;
+	case BPF_FUNC_map_update_elem:
+		return &bpf_map_update_elem_proto;
+	case BPF_FUNC_map_delete_elem:
+		return &bpf_map_delete_elem_proto;
+	case BPF_FUNC_probe_read:
+		return &bpf_probe_read_proto;
+	case BPF_FUNC_tail_call:
+		return &bpf_tail_call_proto;
+	case BPF_FUNC_get_current_pid_tgid:
+		return &bpf_get_current_pid_tgid_proto;
+	case BPF_FUNC_get_current_task:
+		return &bpf_get_current_task_proto;
+	case BPF_FUNC_get_current_uid_gid:
+		return &bpf_get_current_uid_gid_proto;
+	case BPF_FUNC_get_current_comm:
+		return &bpf_get_current_comm_proto;
+	case BPF_FUNC_trace_printk:
+		return bpf_get_trace_printk_proto();
+	default:
+		return NULL;
+	}
+}
+
+static bool checmate_prog_is_valid_access(int off, int size,
+					  enum bpf_access_type type,
+					  enum bpf_reg_type *reg_type)
+{
+	if (type != BPF_READ)
+		return false;
+	if (off < 0 || off >= sizeof(struct checmate_ctx))
+		return false;
+	return true;
+}
+
+static const struct bpf_verifier_ops checmate_prog_ops = {
+	.get_func_proto		= checmate_prog_func_proto,
+	.is_valid_access	= checmate_prog_is_valid_access,
+};
+
+static struct bpf_prog_type_list checmate_tl = {
+	.ops	= &checmate_prog_ops,
+	.type	= BPF_PROG_TYPE_CHECMATE,
+};
+
+void register_checmate_prog_ops(void)
+{
+	bpf_register_prog_type(&checmate_tl);
+}
diff --git a/security/checmate/checmate_lsm.c b/security/checmate/checmate_lsm.c
new file mode 100644
index 0000000..ba403e5
--- /dev/null
+++ b/security/checmate/checmate_lsm.c
@@ -0,0 +1,304 @@
+/*
+ * Checmate Linux Security Module
+ *
+ * Copyright (C) 2016 Sargun Dhillon <sargun@sargun.me>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#include <linux/prctl.h>
+#include <linux/checmate.h>
+#include <linux/lsm_hooks.h>
+#include <linux/mutex.h>
+#include <linux/bpf.h>
+#include <linux/filter.h>
+
+#define HOOK_LIST_INIT(HOOK_NUM) \
+	LIST_HEAD_INIT(checmate_bpf_hooks[HOOK_NUM].hook_list)
+
+#define CHECMATE_HOOK(HOOK_NUM)				\
+	[HOOK_NUM] =					\
+	{						\
+		.enabled = true,			\
+		.hook_list = HOOK_LIST_INIT(HOOK_NUM),	\
+	}
+
+void register_checmate_prog_ops(void);
+
+/*
+ * Global write lock for all BPF program hook manipulation. This shouldn't
+ * see much contention, as installation / reset / deny_reset are rare
+ * operations.
+ */
+static DEFINE_MUTEX(checmate_write_lock);
+
+struct checmate_bpf_hook {
+	bool			enabled;
+	bool			deny_reset;
+	struct list_head	hook_list;
+};
+
+struct checmate_bpf_hook_instance {
+	struct list_head	list;
+	struct bpf_prog		*prog;
+};
+
+/* This is the internal array of the heads of BPF hooks */
+static struct checmate_bpf_hook checmate_bpf_hooks[__CHECMATE_HOOK_MAX] = {
+	CHECMATE_HOOK(CHECMATE_HOOK_FILE_OPEN),
+	CHECMATE_HOOK(CHECMATE_HOOK_TASK_CREATE),
+	CHECMATE_HOOK(CHECMATE_HOOK_TASK_FREE),
+#ifdef CONFIG_SECURITY_NETWORK
+	CHECMATE_HOOK(CHECMATE_HOOK_SOCKET_CONNECT),
+#endif /* CONFIG_SECURITY_NETWORK */
+};
+
+/*
+ * checmate_task_prctl_install_hook - Install a checmate hook
+ * @hook: Hook ID
+ * @prog_fd: BPF prog fd
+ *
+ * Return 0 on success, return -ve on error
+ */
+static int checmate_prctl_install_hook(int hook, int prog_fd)
+{
+	int rc = 0;
+	struct bpf_prog *prog;
+	struct checmate_bpf_hook_instance *hook_instance;
+
+	prog = bpf_prog_get_type(prog_fd, BPF_PROG_TYPE_CHECMATE);
+	if (IS_ERR(prog))
+		return PTR_ERR(prog);
+
+	mutex_lock(&checmate_write_lock);
+	list_for_each_entry(hook_instance,
+			    &checmate_bpf_hooks[hook].hook_list, list) {
+		if (hook_instance->prog == prog) {
+			rc = -EEXIST;
+			goto err;
+		}
+	}
+	hook_instance = kmalloc(sizeof(*hook_instance), GFP_KERNEL);
+
+	if (!hook_instance) {
+		rc = -ENOMEM;
+		goto err;
+	}
+	hook_instance->prog = prog;
+	list_add_tail_rcu(&hook_instance->list,
+			  &checmate_bpf_hooks[hook].hook_list);
+	mutex_unlock(&checmate_write_lock);
+	return rc;
+
+err:
+	mutex_unlock(&checmate_write_lock);
+	bpf_prog_put(prog);
+	return rc;
+}
+
+/*
+ * checmate_prctl_deny_reset - Set deny bit on hook
+ * @hook: The Hook ID
+ *
+ * Return 0 or -EALREADY on success, to indicate the deny bit was set
+ */
+static int checmate_prctl_deny_reset(int hook)
+{
+	int rc = 0;
+
+	mutex_lock(&checmate_write_lock);
+	if (checmate_bpf_hooks[hook].deny_reset)
+		rc = -EALREADY;
+	else
+		checmate_bpf_hooks[hook].deny_reset = true;
+	mutex_unlock(&checmate_write_lock);
+
+	return rc;
+}
+
+/*
+ * checmate_reset - Reset (disassociate) the BPF programs for a checmate hook
+ * @hook: Hook ID
+ *
+ * Return 0 on success, -ve on error.
+ */
+static int checmate_reset(int hook)
+{
+	int rc = 0;
+	struct checmate_bpf_hook_instance *hook_instance, *next;
+
+	mutex_lock(&checmate_write_lock);
+	if (checmate_bpf_hooks[hook].deny_reset) {
+		rc = -EPERM;
+		goto out;
+	}
+	list_for_each_entry_safe(hook_instance, next,
+				 &checmate_bpf_hooks[hook].hook_list, list) {
+		list_del_rcu(&hook_instance->list);
+		synchronize_rcu();
+		bpf_prog_put(hook_instance->prog);
+		kfree(hook_instance);
+	}
+out:
+	mutex_unlock(&checmate_write_lock);
+	return rc;
+}
+
+/* checmate_task_prctl_op - Run a checmate specific prctl operation
+ * @op - Used to specify the Checmate operation ID
+ * @hook - Hook ID
+ * @ufd - BPF Program user file descriptor
+ * @arg5 - Unused
+ *
+ * Return 0 on success, -ve on error. -EINVAL when option unhandled.
+ */
+
+static int checmate_task_prctl_op(unsigned long op, unsigned long hook,
+				  unsigned long ufd, unsigned long arg5)
+{
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+	if (!(hook > 0 && hook < __CHECMATE_HOOK_MAX))
+		return -EINVAL;
+	if (!checmate_bpf_hooks[hook].enabled)
+		return -ENOENT;
+
+	if (op == CHECMATE_INSTALL_HOOK)
+		return checmate_prctl_install_hook(hook, ufd);
+	else if (op == CHECMATE_DENY_RESET)
+		return checmate_prctl_deny_reset(hook);
+	else if (op == CHECMATE_RESET)
+		return checmate_reset(hook);
+
+	return -EINVAL;
+}
+
+/*
+ * checmate_task_prctl - check for Checmate-specific prctl operations
+ * @option: If PR_CHECMATE, passes to handler
+ * @arg2:
+ * @arg3:
+ * @arg4:
+ * @arg5:
+ *
+ * Return 0 on success, -ve on error.  -ENOSYS is returned when checmate
+ * does not handle the given option.
+ */
+static int checmate_task_prctl(int option, unsigned long arg2,
+			       unsigned long arg3, unsigned long arg4,
+			       unsigned long arg5)
+{
+	if (option == PR_CHECMATE)
+		return checmate_task_prctl_op(arg2, arg3, arg4, arg5);
+	return -ENOSYS;
+}
+
+/*
+ * call_bpf_int_hook - Run all the BPF programs associated with a hook
+ * @hook: The Hook ID
+ * @ctx: The context which is passed to the hook
+ *
+ * Return 0 on success, on first hook erroring, the error is returned
+ * to the caller
+ *
+ * Requires that the context struct is populated before passing, but
+ * the actual ctx->hook is set inside this function
+ */
+static int call_bpf_int_hook(int hook, struct checmate_ctx *ctx)
+{
+	int rc = 0;
+	struct checmate_bpf_hook_instance *hook_instance;
+
+	ctx->hook = hook;
+
+	preempt_disable();
+	rcu_read_lock();
+	list_for_each_entry_rcu(hook_instance,
+				&checmate_bpf_hooks[hook].hook_list, list) {
+		rc = BPF_PROG_RUN(hook_instance->prog, (void *)ctx);
+		if (rc != 0)
+			goto out;
+	}
+out:
+	rcu_read_unlock();
+	preempt_enable();
+	return rc;
+}
+
+/*
+ * call_bpf_void_hook - Run all the BPF programs associated with a hook
+ * @hook: The Hook ID
+ * @ctx: The context which is passed to the hook
+ *
+ * Return 0 on success, on first hook erroring, the error is returned
+ * to the caller
+ *
+ * Requires that the context struct is populated before passing, but
+ * the actual ctx->hook is set inside this function
+ */
+static void call_bpf_void_hook(int hook, struct checmate_ctx *ctx)
+{
+	call_bpf_int_hook(hook, ctx);
+}
+
+/* Checmate hooks */
+static int checmate_file_open(struct file *file, const struct cred *cred)
+{
+	struct checmate_ctx ctx;
+
+	ctx.file_open_ctx.file = file;
+	ctx.file_open_ctx.cred = cred;
+	return call_bpf_int_hook(CHECMATE_HOOK_FILE_OPEN, &ctx);
+}
+
+static int checmate_task_create(unsigned long clone_flags)
+{
+	struct checmate_ctx ctx;
+
+	ctx.task_create_ctx.clone_flags = clone_flags;
+	return call_bpf_int_hook(CHECMATE_HOOK_TASK_CREATE, &ctx);
+}
+
+static void checmate_task_free(struct task_struct *task)
+{
+	struct checmate_ctx ctx;
+
+	ctx.task_free_ctx.task = task;
+	call_bpf_void_hook(CHECMATE_HOOK_TASK_FREE, &ctx);
+}
+
+#ifdef CONFIG_SECURITY_NETWORK
+static int checmate_socket_connect(struct socket *sock,
+				   struct sockaddr *address, int addrlen)
+{
+	struct checmate_ctx ctx;
+
+	ctx.socket_connect_ctx.sock = sock;
+	ctx.socket_connect_ctx.address = address;
+	ctx.socket_connect_ctx.addrlen = addrlen;
+	return call_bpf_int_hook(CHECMATE_HOOK_SOCKET_CONNECT, &ctx);
+}
+
+#endif /* CONFIG_SECURITY_NETWORK */
+
+static struct security_hook_list checmate_hooks[] = {
+	LSM_HOOK_INIT(task_prctl, checmate_task_prctl),
+	LSM_HOOK_INIT(file_open, checmate_file_open),
+	LSM_HOOK_INIT(task_create, checmate_task_create),
+	LSM_HOOK_INIT(task_free, checmate_task_free),
+#ifdef CONFIG_SECURITY_NETWORK
+	LSM_HOOK_INIT(socket_connect, checmate_socket_connect),
+#endif /* CONFIG_SECURITY_NETWORK */
+};
+
+static int __init checmate_setup(void)
+{
+	pr_info("Checmate activating.\n");
+	register_checmate_prog_ops();
+	security_add_hooks(checmate_hooks, ARRAY_SIZE(checmate_hooks));
+	return 0;
+}
+late_initcall(checmate_setup);
-- 
2.7.4

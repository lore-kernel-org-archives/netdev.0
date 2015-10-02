From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: [PATCH v5 1/3] seccomp: add the concept of a seccomp filter FD
Date: Fri,  2 Oct 2015 10:27:21 -0600
Message-ID: <1443803243-25912-2-git-send-email-tycho.andersen@canonical.com>
References: <1443803243-25912-1-git-send-email-tycho.andersen@canonical.com>
Cc: Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-api@vger.kernel.org,
	Tycho Andersen <tycho.andersen@canonical.com>
To: Kees Cook <keescook@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:35461 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752633AbbJBQ17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 12:27:59 -0400
Received: by ioiz6 with SMTP id z6so125473963ioi.2
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 09:27:58 -0700 (PDT)
In-Reply-To: <1443803243-25912-1-git-send-email-tycho.andersen@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces the concept of a seccomp fd, with a similar interface
and usage to ebpf fds. Initially, one is allowed to create, install, and
dump these fds. Any manipulation of seccomp fds requires users to be root
in their own user namespace, matching the checks done for
SECCOMP_SET_MODE_FILTER.

v2: Force users to specify the parent (as another fd) during fd creation,
    and don't allow them to install filters when a previously installed
    filter is not the parent of the to be installed filter. This avoids
    "re-parenting" scenarios, which can be racy or perhaps insecure.

Signed-off-by: Tycho Andersen <tycho.andersen@canonical.com>
CC: Kees Cook <keescook@chromium.org>
CC: Will Drewry <wad@chromium.org>
CC: Oleg Nesterov <oleg@redhat.com>
CC: Andy Lutomirski <luto@amacapital.net>
CC: Pavel Emelyanov <xemul@parallels.com>
CC: Serge E. Hallyn <serge.hallyn@ubuntu.com>
CC: Alexei Starovoitov <ast@kernel.org>
CC: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/seccomp.h      |   5 ++
 include/uapi/linux/seccomp.h |  27 ++++++
 kernel/seccomp.c             | 203 ++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 232 insertions(+), 3 deletions(-)

diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index f426503..4253579 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -85,6 +85,7 @@ static inline int seccomp_mode(struct seccomp *s)
 #ifdef CONFIG_SECCOMP_FILTER
 extern void put_seccomp_filter(struct task_struct *tsk);
 extern void get_seccomp_filter(struct task_struct *tsk);
+extern struct seccomp_filter *seccomp_filter_from_file(struct file *f);
 #else  /* CONFIG_SECCOMP_FILTER */
 static inline void put_seccomp_filter(struct task_struct *tsk)
 {
@@ -94,5 +95,9 @@ static inline void get_seccomp_filter(struct task_struct *tsk)
 {
 	return;
 }
+static inline struct seccomp_filter *seccomp_filter_from_file(struct file *f)
+{
+	return ERR_PTR(-EINVAL);
+}
 #endif /* CONFIG_SECCOMP_FILTER */
 #endif /* _LINUX_SECCOMP_H */
diff --git a/include/uapi/linux/seccomp.h b/include/uapi/linux/seccomp.h
index 0f238a4..e9f3660 100644
--- a/include/uapi/linux/seccomp.h
+++ b/include/uapi/linux/seccomp.h
@@ -13,10 +13,16 @@
 /* Valid operations for seccomp syscall. */
 #define SECCOMP_SET_MODE_STRICT	0
 #define SECCOMP_SET_MODE_FILTER	1
+#define SECCOMP_FILTER_FD		2
 
 /* Valid flags for SECCOMP_SET_MODE_FILTER */
 #define SECCOMP_FILTER_FLAG_TSYNC	1
 
+/* Valid commands for SECCOMP_FILTER_FD */
+#define SECCOMP_FD_NEW		0
+#define SECCOMP_FD_INSTALL	1
+#define SECCOMP_FD_DUMP	2
+
 /*
  * All BPF programs must return a 32-bit value.
  * The bottom 16-bits are for optional return data.
@@ -51,4 +57,25 @@ struct seccomp_data {
 	__u64 args[6];
 };
 
+struct seccomp_fd {
+	__u32			size;
+
+	union {
+		/* SECCOMP_FD_NEW */
+		struct {
+			struct sock_fprog __user	*new_prog;
+			int				new_parent;
+		};
+
+		/* SECCOMP_FD_INSTALL */
+		int	install_fd;
+
+		/* SECCOMP_FD_DUMP */
+		struct {
+			int				dump_fd;
+			struct sock_filter __user	*insns;
+		};
+	};
+};
+
 #endif /* _UAPI_LINUX_SECCOMP_H */
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 06858a7..ea3337d 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -26,6 +26,8 @@
 #endif
 
 #ifdef CONFIG_SECCOMP_FILTER
+#include <linux/anon_inodes.h>
+#include <linux/file.h>
 #include <linux/filter.h>
 #include <linux/pid.h>
 #include <linux/ptrace.h>
@@ -474,10 +476,8 @@ static inline void seccomp_filter_free(struct seccomp_filter *filter)
 	}
 }
 
-/* put_seccomp_filter - decrements the ref count of tsk->seccomp.filter */
-void put_seccomp_filter(struct task_struct *tsk)
+static void seccomp_filter_decref(struct seccomp_filter *orig)
 {
-	struct seccomp_filter *orig = tsk->seccomp.filter;
 	/* Clean up single-reference branches iteratively. */
 	while (orig && atomic_dec_and_test(&orig->usage)) {
 		struct seccomp_filter *freeme = orig;
@@ -486,6 +486,12 @@ void put_seccomp_filter(struct task_struct *tsk)
 	}
 }
 
+/* put_seccomp_filter - decrements the ref count of tsk->seccomp.filter */
+void put_seccomp_filter(struct task_struct *tsk)
+{
+	seccomp_filter_decref(tsk->seccomp.filter);
+}
+
 /**
  * seccomp_send_sigsys - signals the task to allow in-process syscall emulation
  * @syscall: syscall number to send to userland
@@ -804,12 +810,201 @@ out_free:
 	seccomp_filter_free(prepared);
 	return ret;
 }
+
+int seccomp_fd_release(struct inode *ino, struct file *f)
+{
+	seccomp_filter_decref(f->private_data);
+	return 0;
+}
+
+static const struct file_operations seccomp_fops = {
+	.release = seccomp_fd_release,
+};
+
+struct seccomp_filter *seccomp_filter_from_file(struct file *f)
+{
+	struct seccomp_filter *filter;
+
+	if (!f)
+		return ERR_PTR(-EBADF);
+
+	if (f->f_op != &seccomp_fops)
+		return ERR_PTR(-EINVAL);
+
+	filter = f->private_data;
+
+	return filter;
+}
+
+static long seccomp_fd_new(struct seccomp_fd *seccomp_fd)
+{
+	struct seccomp_filter *filter, *parent = NULL;
+	long fd = -1;
+	char __user *prog = (char __user *) seccomp_fd->new_prog;
+
+	if (seccomp_fd->new_parent >= 0) {
+		struct fd f;
+
+		f = fdget(seccomp_fd->new_parent);
+		parent = seccomp_filter_from_file(f.file);
+		if (IS_ERR(parent)) {
+			fdput(f);
+			return PTR_ERR(parent);
+		}
+
+		atomic_inc(&parent->usage);
+		fdput(f);
+	}
+
+	filter = seccomp_prepare_user_filter(prog);
+	if (IS_ERR(filter)) {
+		fd = PTR_ERR(filter);
+		goto out;
+	}
+
+	filter->prev = parent;
+
+	fd = anon_inode_getfd("seccomp", &seccomp_fops, filter,
+			      O_RDONLY | O_CLOEXEC);
+out:
+	/* decref iteravely frees parent, so we don't need to do so */
+	if (fd < 0)
+		seccomp_filter_decref(filter);
+
+	return fd;
+}
+
+static long seccomp_fd_install(struct seccomp_fd *seccomp_fd)
+{
+	struct fd f;
+	struct seccomp_filter *filter;
+	int ret = -EINVAL;
+
+	f = fdget(seccomp_fd->install_fd);
+	filter = seccomp_filter_from_file(f.file);
+	if (IS_ERR(filter)) {
+		fdput(f);
+		return PTR_ERR(filter);
+	}
+	atomic_inc(&filter->usage);
+	fdput(f);
+
+	spin_lock_irq(&current->sighand->siglock);
+	if (!seccomp_may_assign_mode(SECCOMP_MODE_FILTER))
+		goto out_sigunlock;
+
+	if (current->seccomp.mode == SECCOMP_MODE_FILTER &&
+	    current->seccomp.filter != filter->prev)
+		goto out_sigunlock;
+
+	ret = seccomp_attach_filter(0, filter);
+	/* This may be the first filter installed, so let's set mode */
+	if (ret >= 0)
+		seccomp_assign_mode(current, SECCOMP_MODE_FILTER);
+
+out_sigunlock:
+	spin_unlock_irq(&current->sighand->siglock);
+
+	/* If the filter failed to install, let's decref it */
+	if (ret < 0)
+		seccomp_filter_decref(filter);
+	return ret;
+}
+
+static long seccomp_fd_dump(struct seccomp_fd *seccomp_fd)
+{
+	struct fd f;
+	int len;
+	struct sock_fprog_kern *orig;
+	struct seccomp_filter *filter;
+
+	f = fdget(seccomp_fd->dump_fd);
+	filter = seccomp_filter_from_file(f.file);
+	if (IS_ERR(filter)) {
+		fdput(f);
+		return PTR_ERR(filter);
+	}
+
+	orig = filter->prog->orig_prog;
+	len = bpf_classic_proglen(orig);
+
+	/* Allow asking how long the filter is by passing a null buffer. */
+	if (seccomp_fd->insns &&
+	    copy_to_user(seccomp_fd->insns, orig->filter, len))
+		len = -EFAULT;
+
+	fdput(f);
+	return len;
+}
+
+static long seccomp_filter_fd(unsigned int cmd,
+			      const char __user *ulayer)
+{
+	long ret;
+	u32 size;
+	struct seccomp_fd seccomp_fd;
+	struct seccomp_fd __user *useccomp_fd =
+		(struct seccomp_fd __user *) ulayer;
+
+	/* As above, we restrict access to seccomp fds to processes who are
+	 * root in their own user ns.
+	 */
+	if (!task_no_new_privs(current) &&
+	    security_capable_noaudit(current_cred(), current_user_ns(),
+				     CAP_SYS_ADMIN) != 0)
+		return -EACCES;
+
+	if (get_user(size, &useccomp_fd->size))
+		return -EFAULT;
+
+	if (size > sizeof(seccomp_fd)) {
+		unsigned char __user *addr;
+		unsigned char __user *end;
+		unsigned char val;
+
+		addr = (void __user *)useccomp_fd + sizeof(seccomp_fd);
+		end  = (void __user *)useccomp_fd + size;
+
+		for (; addr < end; addr++) {
+			if (get_user(val, addr))
+				return -EFAULT;
+			if (val)
+				return -E2BIG;
+		}
+		size = sizeof(seccomp_fd);
+	}
+
+	if (copy_from_user(&seccomp_fd, useccomp_fd, size))
+		return -EFAULT;
+
+	switch (cmd) {
+	case SECCOMP_FD_NEW:
+		ret = seccomp_fd_new(&seccomp_fd);
+		break;
+	case SECCOMP_FD_INSTALL:
+		ret = seccomp_fd_install(&seccomp_fd);
+		break;
+	case SECCOMP_FD_DUMP:
+		ret = seccomp_fd_dump(&seccomp_fd);
+		break;
+	default:
+		ret = -EINVAL;
+	}
+
+	return ret;
+}
 #else
 static inline long seccomp_set_mode_filter(unsigned int flags,
 					   const char __user *filter)
 {
 	return -EINVAL;
 }
+
+static inline long seccomp_filter_fd(unsigned int flags,
+				     const char __user *filter)
+{
+	return -EINVAL;
+}
 #endif
 
 /* Common entry point for both prctl and syscall. */
@@ -823,6 +1018,8 @@ static long do_seccomp(unsigned int op, unsigned int flags,
 		return seccomp_set_mode_strict();
 	case SECCOMP_SET_MODE_FILTER:
 		return seccomp_set_mode_filter(flags, uargs);
+	case SECCOMP_FILTER_FD:
+		return seccomp_filter_fd(flags, uargs);
 	default:
 		return -EINVAL;
 	}
-- 
2.5.0

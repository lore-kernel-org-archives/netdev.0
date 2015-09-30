From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: [PATCH v3 2/5] seccomp: add the concept of a seccomp filter FD
Date: Wed, 30 Sep 2015 12:13:37 -0600
Message-ID: <1443636820-17083-3-git-send-email-tycho.andersen@canonical.com>
References: <1443636820-17083-1-git-send-email-tycho.andersen@canonical.com>
Cc: Will Drewry <wad@chromium.org>, Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-api@vger.kernel.org,
	Tycho Andersen <tycho.andersen@canonical.com>
To: Kees Cook <keescook@chromium.org>,
	Alexei Starovoitov <ast@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443636820-17083-1-git-send-email-tycho.andersen@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces the concept of a seccomp fd, with a similar interface
and usage to ebpf fds. Initially, one is allowed to create, install, and
dump these fds. Any manipulation of seccomp fds requires users to be root
in their own user namespace, matching the checks done for
SECCOMP_SET_MODE_FILTER.

Installing a filterfd has some gotchas, though. Andy mentioned previously
that we should restrict installation to filter fds whose parent is already
in the filter tree. This doesn't quite work in the case of created seccomp
fds, since once you install a filter fd, you can't install any other filter
fd since it has no parent and there is no way to "pre-chain" filters before
installing them. To work around this, we allow installing filters who have
no parent. If the filter has a parent, we require the current filter try to
be an ancestor of it.

I'm not quite sure that the ancestor restriction is correct, since it can
still allow for "re-parenting" of filters, potentially introducing new
filters to a task. However, since these operations are limited to root in
the user ns, perhaps it is ok. There is also some potentially racy
behavior where a task re-parents a filter that another task has installed.

One option to work around this is to keep a bit on struct seccomp_filter to
allow each filter to have its parent set exactly once. (This would still
allow you to install a filter multiple times, as long as the parent was the
same in each case.)

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
 include/uapi/linux/seccomp.h |  24 ++++++
 kernel/seccomp.c             | 189 ++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 210 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/seccomp.h b/include/uapi/linux/seccomp.h
index 0f238a4..4ee8770 100644
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
@@ -51,4 +57,22 @@ struct seccomp_data {
 	__u64 args[6];
 };
 
+struct seccomp_fd {
+	__u32			size;
+
+	union {
+		/* SECCOMP_FD_NEW */
+		struct sock_fprog __user	*new_prog;
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
index 09f3769..6f0465c 100644
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
@@ -58,6 +60,7 @@ struct seccomp_filter {
 	atomic_t usage;
 	struct seccomp_filter *prev;
 	struct bpf_prog *prog;
+	spinlock_t prev_lock;
 };
 
 /* Limit any path through the tree to 256KB worth of instructions. */
@@ -393,6 +396,7 @@ static struct seccomp_filter *seccomp_prepare_filter(struct sock_fprog *fprog)
 	}
 
 	atomic_set(&sfilter->usage, 1);
+	sfilter->prev_lock = __SPIN_LOCK_UNLOCKED(&sfilter->prev_lock);
 
 	return sfilter;
 }
@@ -441,6 +445,7 @@ static long seccomp_attach_filter(unsigned int flags,
 	struct seccomp_filter *walker;
 
 	assert_spin_locked(&current->sighand->siglock);
+	assert_spin_locked(&filter->prev_lock);
 
 	/* Validate resulting filter length. */
 	total_insns = filter->prog->len;
@@ -482,10 +487,8 @@ void get_seccomp_filter(struct task_struct *tsk)
 	atomic_inc(&orig->usage);
 }
 
-/* put_seccomp_filter - decrements the ref count of tsk->seccomp.filter */
-void put_seccomp_filter(struct task_struct *tsk)
+static void seccomp_filter_decref(struct seccomp_filter *orig)
 {
-	struct seccomp_filter *orig = tsk->seccomp.filter;
 	/* Clean up single-reference branches iteratively. */
 	while (orig && atomic_dec_and_test(&orig->usage)) {
 		struct seccomp_filter *freeme = orig;
@@ -494,6 +497,12 @@ void put_seccomp_filter(struct task_struct *tsk)
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
@@ -797,7 +806,9 @@ static long seccomp_set_mode_filter(unsigned int flags,
 	if (!seccomp_may_assign_mode(seccomp_mode))
 		goto out;
 
+	spin_lock_irq(&prepared->prev_lock);
 	ret = seccomp_attach_filter(flags, prepared);
+	spin_unlock_irq(&prepared->prev_lock);
 	if (ret)
 		goto out;
 	/* Do not free the successfully attached filter. */
@@ -812,12 +823,182 @@ out_free:
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
+static long seccomp_fd_new(struct seccomp_fd *seccomp_fd)
+{
+	struct seccomp_filter *filter;
+	long fd;
+	char __user *prog = (char __user *) seccomp_fd->new_prog;
+
+	filter = seccomp_prepare_user_filter(prog);
+	if (IS_ERR(filter))
+		return PTR_ERR(filter);
+
+	fd = anon_inode_getfd("seccomp", &seccomp_fops, filter,
+			      O_RDONLY | O_CLOEXEC);
+	if (fd < 0)
+		seccomp_filter_decref(filter);
+
+	return fd;
+}
+
+static struct seccomp_filter *seccomp_filter_get(struct fd f)
+{
+	struct seccomp_filter *filter;
+
+	if (!f.file)
+		return ERR_PTR(-EBADF);
+
+	if (f.file->f_op != &seccomp_fops) {
+		fdput(f);
+		return ERR_PTR(-EINVAL);
+	}
+
+	filter = f.file->private_data;
+
+	return filter;
+}
+
+static long seccomp_fd_install(struct seccomp_fd *seccomp_fd)
+{
+	struct fd f;
+	struct seccomp_filter *filter;
+	int ret = -EINVAL;
+
+	f = fdget(seccomp_fd->install_fd);
+	filter = seccomp_filter_get(f);
+	if (IS_ERR(filter))
+		return PTR_ERR(filter);
+	atomic_inc(&filter->usage);
+	fdput(f);
+
+	spin_lock_irq(&current->sighand->siglock);
+	if (!seccomp_may_assign_mode(SECCOMP_MODE_FILTER))
+		goto out_sigunlock;
+
+	spin_lock_irq(&filter->prev_lock);
+	if (filter->prev && !is_ancestor(current->seccomp.filter, filter))
+		goto out_prev_unlock;
+
+	ret = seccomp_attach_filter(0, filter);
+	/* This may be the first filter installed, so let's set mode */
+	if (ret >= 0)
+		seccomp_assign_mode(current, SECCOMP_MODE_FILTER);
+
+out_prev_unlock:
+	spin_unlock_irq(&filter->prev_lock);
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
+	filter = seccomp_filter_get(f);
+	if (IS_ERR(filter))
+		return PTR_ERR(filter);
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
+static inline long seccomp_filter_fd(unsigned int flags
+				     const char __user *filter)
+{
+	return -EINVAL;
+}
 #endif
 
 /* Common entry point for both prctl and syscall. */
@@ -831,6 +1012,8 @@ static long do_seccomp(unsigned int op, unsigned int flags,
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

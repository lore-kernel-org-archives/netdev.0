From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: [PATCH v2 4/5] seccomp: add a way to access filters via bpf fds
Date: Thu, 10 Sep 2015 18:21:01 -0600
Message-ID: <1441930862-14347-5-git-send-email-tycho.andersen@canonical.com>
References: <1441930862-14347-1-git-send-email-tycho.andersen@canonical.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
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
In-Reply-To: <1441930862-14347-1-git-send-email-tycho.andersen@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a way for a process that is "real root" to access the
seccomp filters of another process. The process first does a
PTRACE_SECCOMP_GET_FILTER_FD to get an fd with that process' seccomp filter
attached, and then iterates on this with PTRACE_SECCOMP_NEXT_FILTER using
bpf(BPF_PROG_DUMP) to dump the actual program at each step.

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
 include/linux/bpf.h         | 12 ++++++++++
 include/linux/seccomp.h     | 14 +++++++++++
 include/uapi/linux/ptrace.h |  3 +++
 kernel/bpf/syscall.c        | 26 ++++++++++++++++++++-
 kernel/ptrace.c             |  7 ++++++
 kernel/seccomp.c            | 57 +++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 118 insertions(+), 1 deletion(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index f57d7fe..bfd9cab 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -162,6 +162,8 @@ void bpf_register_prog_type(struct bpf_prog_type_list *tl);
 void bpf_register_map_type(struct bpf_map_type_list *tl);
 
 struct bpf_prog *bpf_prog_get(u32 ufd);
+int bpf_prog_set(u32 ufd, struct bpf_prog *new);
+int bpf_new_fd(struct bpf_prog *prog, int flags);
 void bpf_prog_put(struct bpf_prog *prog);
 void bpf_prog_put_rcu(struct bpf_prog *prog);
 
@@ -180,6 +182,16 @@ static inline struct bpf_prog *bpf_prog_get(u32 ufd)
 	return ERR_PTR(-EOPNOTSUPP);
 }
 
+static inline int bpf_prog_set(u32 ufd, struct bpf_prog *new)
+{
+	return -EINVAL;
+}
+
+static inline int bpf_new_fd(struct bpf_prog *prog, int flags)
+{
+	return -EINVAL;
+}
+
 static inline void bpf_prog_put(struct bpf_prog *prog)
 {
 }
diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index a19ddac..41b083c 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -95,4 +95,18 @@ static inline void get_seccomp_filter(struct task_struct *tsk)
 	return;
 }
 #endif /* CONFIG_SECCOMP_FILTER */
+
+#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_CHECKPOINT_RESTORE)
+extern long seccomp_get_filter_fd(struct task_struct *child);
+extern long seccomp_next_filter(struct task_struct *child, u32 fd);
+#else
+static inline long seccomp_get_filter_fd(struct task_struct *child)
+{
+	return -EINVAL;
+}
+static inline long seccomp_next_filter(struct task_struct *child, u32 fd)
+{
+	return -EINVAL;
+}
+#endif /* CONFIG_SECCOMP_FILTER && CONFIG_CHECKPOINT_RESTORE */
 #endif /* _LINUX_SECCOMP_H */
diff --git a/include/uapi/linux/ptrace.h b/include/uapi/linux/ptrace.h
index cf1019e..041c3c3 100644
--- a/include/uapi/linux/ptrace.h
+++ b/include/uapi/linux/ptrace.h
@@ -23,6 +23,9 @@
 
 #define PTRACE_SYSCALL		  24
 
+#define PTRACE_SECCOMP_GET_FILTER_FD	40
+#define PTRACE_SECCOMP_NEXT_FILTER	41
+
 /* 0x4200-0x4300 are reserved for architecture-independent additions.  */
 #define PTRACE_SETOPTIONS	0x4200
 #define PTRACE_GETEVENTMSG	0x4201
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 58ae9f4..ac3ed1c 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -506,6 +506,30 @@ struct bpf_prog *bpf_prog_get(u32 ufd)
 }
 EXPORT_SYMBOL_GPL(bpf_prog_get);
 
+int bpf_prog_set(u32 ufd, struct bpf_prog *new)
+{
+	struct fd f;
+	struct bpf_prog *prog;
+
+	f = fdget(ufd);
+
+	prog = get_prog(f);
+	if (!IS_ERR(prog) && prog)
+		bpf_prog_put(prog);
+
+	atomic_inc(&new->aux->refcnt);
+	f.file->private_data = new;
+	fdput(f);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(bpf_prog_set);
+
+int bpf_new_fd(struct bpf_prog *prog, int flags)
+{
+	return anon_inode_getfd("bpf-prog", &bpf_prog_fops, prog, flags);
+}
+EXPORT_SYMBOL_GPL(bpf_new_fd);
+
 /* last field in 'union bpf_attr' used by this command */
 #define	BPF_PROG_LOAD_LAST_FIELD kern_version
 
@@ -572,7 +596,7 @@ static int bpf_prog_load(union bpf_attr *attr)
 	if (err < 0)
 		goto free_used_maps;
 
-	err = anon_inode_getfd("bpf-prog", &bpf_prog_fops, prog, O_RDWR | O_CLOEXEC);
+	err = bpf_new_fd(prog, O_RDWR | O_CLOEXEC);
 	if (err < 0)
 		/* failed to allocate fd */
 		goto free_used_maps;
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index c8e0e05..a151c35 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -1003,6 +1003,13 @@ int ptrace_request(struct task_struct *child, long request,
 		break;
 	}
 #endif
+
+	case PTRACE_SECCOMP_GET_FILTER_FD:
+		return seccomp_get_filter_fd(child);
+
+	case PTRACE_SECCOMP_NEXT_FILTER:
+		return seccomp_next_filter(child, data);
+
 	default:
 		break;
 	}
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index afaeddf..1856f69 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -26,6 +26,8 @@
 #endif
 
 #ifdef CONFIG_SECCOMP_FILTER
+#include <linux/bpf.h>
+#include <uapi/linux/bpf.h>
 #include <linux/filter.h>
 #include <linux/pid.h>
 #include <linux/ptrace.h>
@@ -807,6 +809,61 @@ static inline long seccomp_set_mode_filter(unsigned int flags,
 }
 #endif
 
+#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_CHECKPOINT_RESTORE)
+long seccomp_get_filter_fd(struct task_struct *child)
+{
+	long fd;
+	struct seccomp_filter *filter;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EACCES;
+
+	if (child->seccomp.mode != SECCOMP_MODE_FILTER)
+		return -EINVAL;
+
+	filter = child->seccomp.filter;
+
+	fd = bpf_new_fd(filter->prog, O_RDONLY);
+	if (fd > 0)
+		atomic_inc(&filter->prog->aux->refcnt);
+
+	return fd;
+}
+
+long seccomp_next_filter(struct task_struct *child, u32 fd)
+{
+	struct seccomp_filter *cur;
+	struct bpf_prog *prog;
+	long ret = -ESRCH;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EACCES;
+
+	if (child->seccomp.mode != SECCOMP_MODE_FILTER)
+		return -EINVAL;
+
+	prog = bpf_prog_get(fd);
+	if (IS_ERR(prog)) {
+		ret = PTR_ERR(prog);
+		goto out;
+	}
+
+	for (cur = child->seccomp.filter; cur; cur = cur->prev) {
+		if (cur->prog == prog) {
+			if (!cur->prev)
+				ret = -ENOENT;
+			else
+				ret = bpf_prog_set(fd, cur->prev->prog);
+			break;
+		}
+	}
+
+out:
+	bpf_prog_put(prog);
+	return ret;
+}
+#endif
+
 /* Common entry point for both prctl and syscall. */
 static long do_seccomp(unsigned int op, unsigned int flags,
 		       const char __user *uargs)
-- 
2.1.4

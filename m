From: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH v2 5/5] seccomp: add a way to attach a filter via eBPF fd
Date: Thu, 10 Sep 2015 18:21:02 -0600
Message-ID: <1441930862-14347-6-git-send-email-tycho.andersen@canonical.com>
References: <1441930862-14347-1-git-send-email-tycho.andersen@canonical.com>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
To: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1441930862-14347-1-git-send-email-tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is the final bit needed to support seccomp filters created via the bpf
syscall. The patch adds a new seccomp operation SECCOMP_MODE_FILTER_EBPF,
which takes exactly one command (presumably to be expanded upon later when
seccomp EBPFs support more interesting things) and an argument struct
similar to that of bpf(), although the size is explicit in the struct to
avoid changing the signature of seccomp().

v2: Don't abuse seccomp's third argument; use a separate command and a
    pointer to a structure instead.

Signed-off-by: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
CC: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
CC: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
CC: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
CC: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
CC: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
CC: Serge E. Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
CC: Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
CC: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
---
 include/uapi/linux/seccomp.h |  16 +++++
 kernel/seccomp.c             | 135 ++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 138 insertions(+), 13 deletions(-)

diff --git a/include/uapi/linux/seccomp.h b/include/uapi/linux/seccomp.h
index 0f238a4..a8694e2 100644
--- a/include/uapi/linux/seccomp.h
+++ b/include/uapi/linux/seccomp.h
@@ -13,10 +13,14 @@
 /* Valid operations for seccomp syscall. */
 #define SECCOMP_SET_MODE_STRICT	0
 #define SECCOMP_SET_MODE_FILTER	1
+#define SECCOMP_MODE_FILTER_EBPF	2
 
 /* Valid flags for SECCOMP_SET_MODE_FILTER */
 #define SECCOMP_FILTER_FLAG_TSYNC	1
 
+/* Valid cmds for SECCOMP_MODE_FILTER_EBPF */
+#define SECCOMP_EBPF_ADD_FD	0
+
 /*
  * All BPF programs must return a 32-bit value.
  * The bottom 16-bits are for optional return data.
@@ -51,4 +55,16 @@ struct seccomp_data {
 	__u64 args[6];
 };
 
+struct seccomp_ebpf {
+	unsigned int size;
+
+	union {
+		/* SECCOMP_EBPF_ADD_FD */
+		struct {
+			unsigned int	add_flags;
+			__u32		add_fd;
+		};
+	};
+};
+
 #endif /* _UAPI_LINUX_SECCOMP_H */
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 1856f69..e78175a 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -65,6 +65,9 @@ struct seccomp_filter {
 /* Limit any path through the tree to 256KB worth of instructions. */
 #define MAX_INSNS_PER_PATH ((1 << 18) / sizeof(struct sock_filter))
 
+static long seccomp_install_filter(unsigned int flags,
+				   struct seccomp_filter *prepared);
+
 /*
  * Endianness is explicitly ignored and left for BPF program authors to manage
  * as per the specific architecture.
@@ -356,17 +359,6 @@ static struct seccomp_filter *seccomp_prepare_filter(struct sock_fprog *fprog)
 
 	BUG_ON(INT_MAX / fprog->len < sizeof(struct sock_filter));
 
-	/*
-	 * Installing a seccomp filter requires that the task has
-	 * CAP_SYS_ADMIN in its namespace or be running with no_new_privs.
-	 * This avoids scenarios where unprivileged tasks can affect the
-	 * behavior of privileged children.
-	 */
-	if (!task_no_new_privs(current) &&
-	    security_capable_noaudit(current_cred(), current_user_ns(),
-				     CAP_SYS_ADMIN) != 0)
-		return ERR_PTR(-EACCES);
-
 	/* Allocate a new seccomp_filter */
 	sfilter = kzalloc(sizeof(*sfilter), GFP_KERNEL | __GFP_NOWARN);
 	if (!sfilter)
@@ -510,8 +502,105 @@ static void seccomp_send_sigsys(int syscall, int reason)
 	info.si_syscall = syscall;
 	force_sig_info(SIGSYS, &info, current);
 }
+
 #endif	/* CONFIG_SECCOMP_FILTER */
 
+#if defined(CONFIG_BPF_SYSCALL) && defined(CONFIG_SECCOMP_FILTER)
+static struct seccomp_filter *seccomp_prepare_ebpf(int fd)
+{
+	struct seccomp_filter *ret;
+	struct bpf_prog *prog;
+
+	prog = bpf_prog_get(fd);
+	if (IS_ERR(prog))
+		return (struct seccomp_filter *) prog;
+
+	if (prog->type != BPF_PROG_TYPE_SECCOMP) {
+		bpf_prog_put(prog);
+		return ERR_PTR(-EINVAL);
+	}
+
+	ret = kzalloc(sizeof(*ret), GFP_KERNEL | __GFP_NOWARN);
+	if (!ret) {
+		bpf_prog_put(prog);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	ret->prog = prog;
+	atomic_set(&ret->usage, 1);
+
+	/* Intentionally don't bpf_prog_put() here, because the underlying prog
+	 * is refcounted too and we're holding a reference from the struct
+	 * seccomp_filter object.
+	 */
+	return ret;
+}
+
+static long seccomp_ebpf_add_fd(struct seccomp_ebpf *ebpf)
+{
+	struct seccomp_filter *prepared;
+
+	prepared = seccomp_prepare_ebpf(ebpf->add_fd);
+	if (IS_ERR(prepared))
+		return PTR_ERR(prepared);
+
+	return seccomp_install_filter(ebpf->add_flags, prepared);
+}
+
+static long seccomp_mode_filter_ebpf(unsigned int cmd, const char __user *uargs)
+{
+	const struct seccomp_ebpf __user *uebpf;
+	struct seccomp_ebpf ebpf;
+	unsigned int size;
+	long ret = -EFAULT;
+
+	uebpf = (const struct seccomp_ebpf __user *) uargs;
+
+	if (get_user(size, &uebpf->size) != 0)
+		return -EFAULT;
+
+	/* If we're handed a bigger struct than we know of,
+	 * ensure all the unknown bits are 0 - i.e. new
+	 * user-space does not rely on any kernel feature
+	 * extensions we dont know about yet.
+	 */
+	if (size > sizeof(ebpf)) {
+		unsigned char __user *addr;
+		unsigned char __user *end;
+		unsigned char val;
+
+		addr = (void __user *)uebpf + sizeof(ebpf);
+		end  = (void __user *)uebpf + size;
+
+		for (; addr < end; addr++) {
+			int err = get_user(val, addr);
+
+			if (err)
+				return err;
+			if (val)
+				return -E2BIG;
+		}
+		size = sizeof(ebpf);
+	}
+
+	if (copy_from_user(&ebpf, uebpf, size) != 0)
+		return -EFAULT;
+
+	switch (cmd) {
+	case SECCOMP_EBPF_ADD_FD:
+		ret = seccomp_ebpf_add_fd(&ebpf);
+		break;
+	}
+
+	return ret;
+}
+#else
+static long seccomp_mode_filter_ebpf(unsigned int cmd, const char __user *uargs)
+{
+	return -EINVAL;
+}
+#endif
+
 /*
  * Secure computing mode 1 allows only read/write/exit/sigreturn.
  * To be fully secure this must be combined with rlimit
@@ -760,9 +849,7 @@ out:
 static long seccomp_set_mode_filter(unsigned int flags,
 				    const char __user *filter)
 {
-	const unsigned long seccomp_mode = SECCOMP_MODE_FILTER;
 	struct seccomp_filter *prepared = NULL;
-	long ret = -EINVAL;
 
 	/* Validate flags. */
 	if (flags & ~SECCOMP_FILTER_FLAG_MASK)
@@ -773,6 +860,26 @@ static long seccomp_set_mode_filter(unsigned int flags,
 	if (IS_ERR(prepared))
 		return PTR_ERR(prepared);
 
+	return seccomp_install_filter(flags, prepared);
+}
+
+static long seccomp_install_filter(unsigned int flags,
+				   struct seccomp_filter *prepared)
+{
+	const unsigned long seccomp_mode = SECCOMP_MODE_FILTER;
+	long ret = -EINVAL;
+
+	/*
+	 * Installing a seccomp filter requires that the task has
+	 * CAP_SYS_ADMIN in its namespace or be running with no_new_privs.
+	 * This avoids scenarios where unprivileged tasks can affect the
+	 * behavior of privileged children.
+	 */
+	if (!task_no_new_privs(current) &&
+	    security_capable_noaudit(current_cred(), current_user_ns(),
+				     CAP_SYS_ADMIN) != 0)
+		return -EACCES;
+
 	/*
 	 * Make sure we cannot change seccomp or nnp state via TSYNC
 	 * while another thread is in the middle of calling exec.
@@ -875,6 +982,8 @@ static long do_seccomp(unsigned int op, unsigned int flags,
 		return seccomp_set_mode_strict();
 	case SECCOMP_SET_MODE_FILTER:
 		return seccomp_set_mode_filter(flags, uargs);
+	case SECCOMP_MODE_FILTER_EBPF:
+		return seccomp_mode_filter_ebpf(flags, uargs);
 	default:
 		return -EINVAL;
 	}
-- 
2.1.4
